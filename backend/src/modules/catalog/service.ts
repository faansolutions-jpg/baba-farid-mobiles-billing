// Accessories Master Catalog service.
// Catalog tables (catalog_items, catalog_stock, barcode_links, stock_counts,
// catalog_versions, catalog_item_models) are created by migration
// database/migrations/001_accessories_catalog.sql — this module never
// creates or alters them, and never touches any other table except
// audit_logs (via writeAudit).
//
// Rules enforced here:
//  - Cashiers NEVER receive purchase_price_est / last_purchase_price.
//  - Bulk stock-in is one transaction: all rows or none.
//  - A catalog version update inserts new SKUs and refreshes ESTIMATED
//    prices only; it never touches catalog_stock or is_custom items.
//  - Barcode links are permanent (first scan wins; re-linking the same
//    barcode to a different SKU is a conflict).
// Wiring into app.ts happens after the Module 4 backend agent finishes —
// do not wire it here.
import type { PoolClient } from 'pg';
import type { Request } from 'express';
import { query, withTransaction } from '../../config/db';
import { ApiError, conflict, notFound } from '../../middleware/errors';
import { writeAudit } from '../../middleware/audit';
import { parseCsv } from '../../utils/csv';
import { COST_VISIBLE_ROLES } from '../../config/constants';
import type { AuthUser, Pagination } from '../../types';

type Row = Record<string, unknown>;

const CATALOG_COLUMNS =
  `i.sku, i.category, i.brand, i.name_en, i.name_ur, i.model_compatibility,
   i.colors, i.variants, i.purchase_price_est, i.sale_price_est, i.min_price,
   i.unit, i.barcode, i.is_custom, i.estimated, i.created_at, i.updated_at,
   COALESCE(s.quantity, 0) AS stock_qty,
   COALESCE(s.low_stock_threshold, 5) AS low_stock_threshold,
   s.last_purchase_price, s.last_supplier, s.last_stock_date`;

/** Cashiers must never see cost prices. The shared stripCosts() does not
 *  know the catalog's *_est column names, so strip them here. */
function stripCatalogCosts<T>(data: T, role: string): T {
  if (COST_VISIBLE_ROLES.includes(role as 'owner' | 'manager')) return data;
  const strip = (value: unknown): unknown => {
    if (Array.isArray(value)) return value.map(strip);
    if (value !== null && typeof value === 'object') {
      const out: Record<string, unknown> = {};
      for (const [k, v] of Object.entries(value as Record<string, unknown>)) {
        if (k === 'purchase_price_est' || k === 'last_purchase_price') continue;
        out[k] = strip(v);
      }
      return out;
    }
    return value;
  };
  return strip(data) as T;
}

function itemWithStock(row: Row): Row {
  return {
    ...row,
    stockQty: Number(row.stock_qty ?? 0),
    lowStockThreshold: Number(row.low_stock_threshold ?? 5),
  };
}

async function requireItem(client: PoolClient, sku: string): Promise<Row> {
  const res = await client.query<Row>(
    `SELECT ${CATALOG_COLUMNS} FROM catalog_items i
      LEFT JOIN catalog_stock s ON s.sku = i.sku WHERE i.sku = $1`,
    [sku],
  );
  if (res.rows.length === 0) throw notFound(`Catalog item ${sku} not found`);
  return res.rows[0];
}

/** Apply one stock-in inside an open transaction (shared by stockIn and
 *  bulkStockIn). Updates quantity + last purchase price/supplier/date. */
async function applyStockIn(
  client: PoolClient,
  sku: string,
  qty: number,
  opts: { price?: number; supplier?: string; date?: string },
): Promise<void> {
  const existing = await client.query<{ sku: string }>(
    'SELECT sku FROM catalog_items WHERE sku = $1',
    [sku],
  );
  if (existing.rows.length === 0) throw notFound(`Catalog item ${sku} not found`);
  await client.query(
    `INSERT INTO catalog_stock (sku, quantity, last_purchase_price, last_supplier, last_stock_date)
     VALUES ($1, $2, $3, $4, $5)
     ON CONFLICT (sku) DO UPDATE SET
       quantity = catalog_stock.quantity + EXCLUDED.quantity,
       last_purchase_price = COALESCE(EXCLUDED.last_purchase_price, catalog_stock.last_purchase_price),
       last_supplier = COALESCE(EXCLUDED.last_supplier, catalog_stock.last_supplier),
       last_stock_date = COALESCE(EXCLUDED.last_stock_date, catalog_stock.last_stock_date)`,
    [sku, qty, opts.price ?? null, opts.supplier ?? null, opts.date ?? new Date().toISOString()],
  );
}

// ---- Reads ----
export async function listCatalog(
  filters: { search?: string; category?: string; brand?: string },
  pagination: Pagination,
  role: string,
): Promise<{ rows: Row[]; total: number }> {
  const where: string[] = [];
  const params: unknown[] = [];
  if (filters.search) {
    params.push(`%${filters.search}%`);
    where.push(
      `(i.name_en ILIKE $${params.length} OR i.name_ur ILIKE $${params.length} OR i.sku ILIKE $${params.length} OR i.brand ILIKE $${params.length})`,
    );
  }
  if (filters.category) {
    params.push(filters.category);
    where.push(`i.category = $${params.length}`);
  }
  if (filters.brand) {
    params.push(filters.brand);
    where.push(`i.brand = $${params.length}`);
  }
  const whereSql = where.length ? `WHERE ${where.join(' AND ')}` : '';
  const totalRes = await query<{ count: string }>(
    `SELECT COUNT(*)::text AS count FROM catalog_items i ${whereSql}`,
    params,
  );
  const res = await query<Row>(
    `SELECT ${CATALOG_COLUMNS} FROM catalog_items i
      LEFT JOIN catalog_stock s ON s.sku = i.sku
     ${whereSql}
     ORDER BY i.category, i.brand, i.name_en
     LIMIT $${params.length + 1} OFFSET $${params.length + 2}`,
    [...params, pagination.limit, pagination.offset],
  );
  return {
    rows: res.rows.map((r) => stripCatalogCosts(itemWithStock(r), role)),
    total: Number(totalRes.rows[0].count),
  };
}

export async function getCatalogItem(sku: string, role: string): Promise<Row> {
  const res = await query<Row>(
    `SELECT ${CATALOG_COLUMNS} FROM catalog_items i
      LEFT JOIN catalog_stock s ON s.sku = i.sku WHERE i.sku = $1`,
    [sku],
  );
  if (res.rows.length === 0) throw notFound(`Catalog item ${sku} not found`);
  const models = await query<{ device_brand: string; device_model: string }>(
    'SELECT device_brand, device_model FROM catalog_item_models WHERE sku = $1 ORDER BY device_brand, device_model',
    [sku],
  );
  const item = itemWithStock(res.rows[0]);
  item.models = models.rows;
  return stripCatalogCosts(item, role);
}

// ---- Stock-in ----
export async function stockIn(
  input: { sku: string; qty: number; price?: number; supplier?: string; date?: string },
  actor: AuthUser,
  req?: Request,
): Promise<Row> {
  const updated = await withTransaction(async (client) => {
    await applyStockIn(client, input.sku, input.qty, input);
    await writeAudit(client, {
      userId: actor.id,
      action: 'stock_in',
      entityType: 'catalog_item',
      entityId: input.sku,
      newValues: { qty: input.qty, price: input.price ?? null, supplier: input.supplier ?? null },
      req,
    });
    return requireItem(client, input.sku);
  });
  return stripCatalogCosts(itemWithStock(updated), actor.role);
}

export async function bulkStockIn(
  input: {
    items: { sku: string; qty: number }[];
    price?: number;
    supplier?: string;
    date?: string;
  },
  actor: AuthUser,
  req?: Request,
): Promise<{ updated: number; items: Row[] }> {
  // One transaction: every row applies or the whole batch rolls back.
  const updated = await withTransaction(async (client) => {
    const seen = new Set<string>();
    for (const line of input.items) {
      if (seen.has(line.sku)) throw new ApiError(400, `Duplicate SKU in batch: ${line.sku}`, 'BAD_REQUEST');
      seen.add(line.sku);
      await applyStockIn(client, line.sku, line.qty, input);
    }
    await writeAudit(client, {
      userId: actor.id,
      action: 'bulk_stock_in',
      entityType: 'catalog_item',
      newValues: { count: input.items.length, supplier: input.supplier ?? null },
      req,
    });
    const rows: Row[] = [];
    for (const line of input.items) rows.push(await requireItem(client, line.sku));
    return rows;
  });
  return {
    updated: updated.length,
    items: updated.map((r) => stripCatalogCosts(itemWithStock(r), actor.role)),
  };
}

// ---- Barcodes ----
export async function linkBarcode(
  barcode: string,
  sku: string,
  actor: AuthUser,
  req?: Request,
): Promise<Row> {
  return withTransaction(async (client) => {
    const item = await client.query<{ sku: string; barcode: string | null }>(
      'SELECT sku, barcode FROM catalog_items WHERE sku = $1',
      [sku],
    );
    if (item.rows.length === 0) throw notFound(`Catalog item ${sku} not found`);
    const existing = await client.query<{ sku: string }>(
      'SELECT sku FROM barcode_links WHERE barcode = $1',
      [barcode],
    );
    if (existing.rows.length > 0 && existing.rows[0].sku !== sku) {
      throw conflict(`Barcode ${barcode} is already linked to ${existing.rows[0].sku}`);
    }
    await client.query(
      `INSERT INTO barcode_links (barcode, sku) VALUES ($1, $2)
       ON CONFLICT (barcode) DO NOTHING`,
      [barcode, sku],
    );
    await client.query('UPDATE catalog_items SET barcode = $1 WHERE sku = $2', [barcode, sku]);
    await writeAudit(client, {
      userId: actor.id,
      action: 'barcode_link',
      entityType: 'catalog_item',
      entityId: sku,
      newValues: { barcode },
      req,
    });
    return stripCatalogCosts(itemWithStock(await requireItem(client, sku)), actor.role);
  });
}

export async function byBarcode(barcode: string, role: string): Promise<Row> {
  const res = await query<Row>(
    `SELECT ${CATALOG_COLUMNS} FROM catalog_items i
      LEFT JOIN catalog_stock s ON s.sku = i.sku
     WHERE i.barcode = $1 OR EXISTS (
       SELECT 1 FROM barcode_links b WHERE b.barcode = $1 AND b.sku = i.sku
     )`,
    [barcode],
  );
  if (res.rows.length === 0) throw notFound(`No catalog item linked to barcode ${barcode}`);
  return stripCatalogCosts(itemWithStock(res.rows[0]), role);
}

// ---- Custom items ----
export async function createCustomItem(
  input: Record<string, unknown>,
  actor: AuthUser,
  req?: Request,
): Promise<Row> {
  const created = await withTransaction(async (client) => {
    const dup = await client.query('SELECT sku FROM catalog_items WHERE sku = $1', [input.sku]);
    if (dup.rows.length > 0) throw conflict(`SKU ${String(input.sku)} already exists`);
    if (input.barcode) {
      const b = await client.query('SELECT sku FROM barcode_links WHERE barcode = $1', [
        input.barcode,
      ]);
      if (b.rows.length > 0) throw conflict(`Barcode ${String(input.barcode)} is already linked`);
    }
    const res = await client.query<Row>(
      `INSERT INTO catalog_items
         (sku, category, brand, name_en, name_ur, model_compatibility, colors, variants,
          purchase_price_est, sale_price_est, min_price, unit, barcode, is_custom, estimated)
       VALUES ($1,$2,$3,$4,$5,$6,$7::jsonb,$8::jsonb,$9,$10,$11,$12,$13,TRUE,TRUE)
       RETURNING *`,
      [
        input.sku,
        input.category,
        input.brand,
        input.nameEn,
        input.nameUr ?? '',
        input.modelCompatibility ?? null,
        JSON.stringify(input.colors ?? []),
        JSON.stringify(input.variants ?? []),
        input.purchasePriceEst ?? 0,
        input.salePriceEst ?? 0,
        input.minPrice ?? 0,
        input.unit ?? 'piece',
        input.barcode ?? null,
      ],
    );
    await client.query(
      `INSERT INTO catalog_stock (sku, quantity, low_stock_threshold)
       VALUES ($1, 0, $2) ON CONFLICT (sku) DO NOTHING`,
      [input.sku, input.lowStockThreshold ?? 5],
    );
    if (input.barcode) {
      await client.query('INSERT INTO barcode_links (barcode, sku) VALUES ($1, $2)', [
        input.barcode,
        input.sku,
      ]);
    }
    await writeAudit(client, {
      userId: actor.id,
      action: 'create',
      entityType: 'catalog_item',
      entityId: String(input.sku),
      newValues: input,
      req,
    });
    return res.rows[0];
  });
  return stripCatalogCosts(itemWithStock({ ...created, stock_qty: 0 }), actor.role);
}

// ---- Low stock / reorder ----
export async function lowStock(role: string): Promise<Row[]> {
  const res = await query<Row>(
    `SELECT ${CATALOG_COLUMNS} FROM catalog_items i
      JOIN catalog_stock s ON s.sku = i.sku
     WHERE s.quantity <= s.low_stock_threshold
     ORDER BY s.quantity ASC, i.name_en ASC`,
  );
  return res.rows.map((r) => stripCatalogCosts(itemWithStock(r), role));
}

export async function reorderList(role: string): Promise<Record<string, Row[]>> {
  const res = await query<Row>(
    `SELECT ${CATALOG_COLUMNS} FROM catalog_items i
      JOIN catalog_stock s ON s.sku = i.sku
     WHERE s.quantity <= s.low_stock_threshold
     ORDER BY COALESCE(s.last_supplier, 'Unknown'), i.name_en ASC`,
  );
  const grouped: Record<string, Row[]> = {};
  for (const row of res.rows) {
    const supplier = String(row.last_supplier ?? 'Unknown supplier');
    (grouped[supplier] ??= []).push(stripCatalogCosts(itemWithStock(row), role));
  }
  return grouped;
}

// ---- Stock count (audit) ----
export async function recordStockCount(
  input: { sku: string; countedQty: number; note: string; countedBy?: string },
  actor: AuthUser,
  req?: Request,
): Promise<Row> {
  const result = await withTransaction(async (client) => {
    const item = await requireItem(client, input.sku);
    const systemQty = Number(item.stock_qty ?? 0);
    const difference = input.countedQty - systemQty;
    const res = await client.query<Row>(
      `INSERT INTO stock_counts (sku, counted_qty, system_qty, difference, note, counted_by)
       VALUES ($1,$2,$3,$4,$5,$6) RETURNING *`,
      [input.sku, input.countedQty, systemQty, difference, input.note || null, input.countedBy ?? actor.name],
    );
    await client.query('UPDATE catalog_stock SET quantity = $1 WHERE sku = $2', [
      input.countedQty,
      input.sku,
    ]);
    await writeAudit(client, {
      userId: actor.id,
      action: 'stock_count',
      entityType: 'catalog_item',
      entityId: input.sku,
      oldValues: { systemQty },
      newValues: { countedQty: input.countedQty, difference, note: input.note },
      req,
    });
    return { count: res.rows[0], item: await requireItem(client, input.sku) };
  });
  return {
    ...result.count,
    item: stripCatalogCosts(itemWithStock(result.item), actor.role),
  };
}

// ---- Version ----
export async function catalogVersion(): Promise<Row | null> {
  const res = await query<Row>(
    'SELECT version, applied_at, item_count, notes FROM catalog_versions ORDER BY applied_at DESC, version DESC LIMIT 1',
  );
  return res.rows[0] ?? null;
}

// ---- Catalog version update (apply a new JSON version) ----
// Inserts new SKUs and refreshes estimated prices ONLY, for non-custom
// items. Never touches catalog_stock, barcode_links or is_custom rows.
export async function applyCatalogUpdate(
  input: { version: string; items: Record<string, unknown>[] },
  actor: AuthUser,
  req?: Request,
): Promise<{ inserted: number; updated: number; version: string }> {
  return withTransaction(async (client) => {
    let inserted = 0;
    let updated = 0;
    for (const it of input.items) {
      const res = await client.query<{ inserted: boolean; updated: boolean }>(
        `INSERT INTO catalog_items
           (sku, category, brand, name_en, name_ur, model_compatibility, colors, variants,
            purchase_price_est, sale_price_est, min_price, unit, barcode, is_custom, estimated)
         VALUES ($1,$2,$3,$4,$5,$6,$7::jsonb,$8::jsonb,$9,$10,$11,$12,$13,FALSE,TRUE)
         ON CONFLICT (sku) DO UPDATE SET
           purchase_price_est = EXCLUDED.purchase_price_est,
           sale_price_est     = EXCLUDED.sale_price_est,
           min_price          = EXCLUDED.min_price,
           updated_at         = now()
         WHERE catalog_items.is_custom = FALSE
         RETURNING (xmax = 0) AS inserted`,
        [
          it.sku,
          it.category,
          it.brand,
          it.nameEn ?? it.name_en,
          it.nameUr ?? it.name_ur ?? '',
          it.modelCompatibility ?? it.model_compatibility ?? null,
          JSON.stringify(it.colors ?? []),
          JSON.stringify(it.variants ?? []),
          it.purchasePriceEst ?? it.purchase_price_est ?? 0,
          it.salePriceEst ?? it.sale_price_est ?? 0,
          it.minPrice ?? it.min_price ?? 0,
          it.unit ?? 'piece',
          it.barcode ?? null,
        ],
      );
      // xmax = 0 means the row was inserted, not updated (Postgres idiom).
      // No row is returned when the existing item is_custom (update skipped).
      if (res.rows.length === 0) continue;
      if (res.rows[0]?.inserted) {
        inserted++;
        await client.query(
          'INSERT INTO catalog_stock (sku, quantity) VALUES ($1, 0) ON CONFLICT (sku) DO NOTHING',
          [it.sku],
        );
      } else {
        updated++;
      }
    }
    await client.query(
      `INSERT INTO catalog_versions (version, item_count, notes)
       VALUES ($1, $2, $3) ON CONFLICT (version) DO NOTHING`,
      [input.version, input.items.length, 'Applied via POST /api/v1/catalog/import (version update)'],
    );
    await writeAudit(client, {
      userId: actor.id,
      action: 'catalog_update',
      entityType: 'catalog_version',
      entityId: input.version,
      newValues: { inserted, updated },
      req,
    });
    return { inserted, updated, version: input.version };
  });
}

// ---- CSV import with auto-matching ----
export interface CatalogImportResult {
  matched: number;
  created: number;
  skipped: number;
  errors: { row: number; message: string }[];
}

/** Normalise a name the same way the app search does: lowercase, strip
 *  spaces/hyphens/underscores — so "Type-C Cable" matches "type c cable". */
export function normalizeName(value: string): string {
  return value.toLowerCase().replace(/[\s\-_]+/g, '');
}

export async function importCatalog(
  input: { rows?: Record<string, unknown>[]; csv?: string },
  actor: AuthUser,
  req?: Request,
): Promise<CatalogImportResult> {
  let rows: Record<string, unknown>[] = input.rows ?? [];
  if (input.csv) {
    const parsed = parseCsv(input.csv);
    if (parsed.length < 2) throw new ApiError(400, 'CSV has no data rows', 'BAD_REQUEST');
    const header = parsed[0].map((h) => h.trim());
    rows = parsed.slice(1).map((cells) => {
      const obj: Record<string, unknown> = {};
      header.forEach((h, i) => {
        const raw = cells[i] ?? '';
        const num = Number(raw);
        obj[h] = raw === '' ? undefined : Number.isFinite(num) && /^-?\d+(\.\d+)?$/.test(raw) ? num : raw;
      });
      return obj;
    });
  }
  const result: CatalogImportResult = { matched: 0, created: 0, skipped: 0, errors: [] };
  await withTransaction(async (client) => {
    // Build a normalised-name lookup once, so matching is one pass.
    const all = await client.query<{ sku: string; name_en: string; barcode: string | null }>(
      'SELECT sku, name_en, barcode FROM catalog_items',
    );
    const bySku = new Map(all.rows.map((r) => [r.sku, r]));
    const byName = new Map(all.rows.map((r) => [normalizeName(r.name_en), r]));
    const byBarcode = new Map(
      all.rows.filter((r) => r.barcode).map((r) => [String(r.barcode), r]),
    );
    for (let i = 0; i < rows.length; i++) {
      const r = rows[i];
      try {
        // Match 1: SKU. Match 2: barcode. Match 3: normalised name.
        const match =
          (r.sku ? bySku.get(String(r.sku)) : undefined) ??
          (r.barcode ? byBarcode.get(String(r.barcode)) : undefined) ??
          (r.nameEn ? byName.get(normalizeName(String(r.nameEn))) : undefined);
        if (match) {
          result.matched++;
          // A matched row is a stock-in when a qty is given.
          if (r.qty !== undefined && Number(r.qty) > 0) {
            await applyStockIn(client, match.sku, Number(r.qty), {
              price: r.purchasePriceEst !== undefined ? Number(r.purchasePriceEst) : undefined,
            });
          }
          continue;
        }
        // No match: create a custom item (needs sku + name at minimum).
        if (!r.sku || !r.nameEn) {
          result.skipped++;
          result.errors.push({ row: i + 1, message: 'No match and no sku/nameEn to create a new item' });
          continue;
        }
        await client.query(
          `INSERT INTO catalog_items
             (sku, category, brand, name_en, name_ur, model_compatibility, colors, variants,
              purchase_price_est, sale_price_est, min_price, unit, barcode, is_custom, estimated)
           VALUES ($1,$2,$3,$4,$5,$6,'[]'::jsonb,'[]'::jsonb,$7,$8,$9,$10,$11,TRUE,TRUE)`,
          [
            r.sku,
            r.category ?? 'Others',
            r.brand ?? 'Generic',
            r.nameEn,
            r.nameUr ?? '',
            r.modelCompatibility ?? null,
            r.purchasePriceEst ?? 0,
            r.salePriceEst ?? 0,
            r.minPrice ?? 0,
            r.unit ?? 'piece',
            r.barcode ?? null,
          ],
        );
        await client.query(
          'INSERT INTO catalog_stock (sku, quantity) VALUES ($1, $2) ON CONFLICT (sku) DO NOTHING',
          [r.sku, r.qty ?? 0],
        );
        result.created++;
      } catch (err) {
        result.errors.push({ row: i + 1, message: (err as Error).message });
      }
    }
    await writeAudit(client, {
      userId: actor.id,
      action: 'import',
      entityType: 'catalog_item',
      newValues: { matched: result.matched, created: result.created, skipped: result.skipped },
      req,
    });
  });
  return result;
}
