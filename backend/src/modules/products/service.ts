// Product catalog service: products, variants, IMEI items, brands,
// categories, low-stock, CSV import/export.
// Stock model (see docs/database.md §3.3): phones are counted by IMEI
// items with status='available'; accessories by variant.quantity.
import { PoolClient } from 'pg';
import { query, withTransaction } from '../../config/db';
import { ApiError, conflict, notFound } from '../../middleware/errors';
import { writeAudit } from '../../middleware/audit';
import { stripCosts } from '../../utils/sanitize';
import { parseCsv, toCsv } from '../../utils/csv';
import type { AuthUser, Pagination } from '../../types';
import type { Request } from 'express';

type Row = Record<string, unknown>;

/** Available-phone count per variant (for the POS stock display). */
async function availableCounts(variantIds: string[]): Promise<Record<string, number>> {
  if (variantIds.length === 0) return {};
  const res = await query<{ variant_id: string; count: string }>(
    `SELECT variant_id, COUNT(*)::text AS count FROM imei_items
      WHERE status = 'available' AND variant_id = ANY($1) GROUP BY variant_id`,
    [variantIds],
  );
  const out: Record<string, number> = {};
  for (const r of res.rows) out[r.variant_id] = Number(r.count);
  return out;
}

function attachStock(
  variants: Row[],
  counts: Record<string, number>,
  productType: string,
): Row[] {
  return variants.map((v) => ({
    ...v,
    available_stock: productType === 'phone' ? counts[String(v.id)] ?? 0 : v.quantity,
  }));
}

export async function listProducts(
  filters: { search?: string; type?: string; brandId?: string; categoryId?: string; isActive?: boolean },
  pagination: Pagination,
  role: string,
): Promise<{ rows: Row[]; total: number }> {
  const where: string[] = [];
  const params: unknown[] = [];
  if (filters.search) {
    params.push(`%${filters.search}%`);
    where.push(`(p.name ILIKE $${params.length} OR p.barcode ILIKE $${params.length})`);
  }
  if (filters.type) {
    params.push(filters.type);
    where.push(`p.type = $${params.length}`);
  }
  if (filters.brandId) {
    params.push(filters.brandId);
    where.push(`p.brand_id = $${params.length}`);
  }
  if (filters.categoryId) {
    params.push(filters.categoryId);
    where.push(`p.category_id = $${params.length}`);
  }
  if (filters.isActive !== undefined) {
    params.push(filters.isActive);
    where.push(`p.is_active = $${params.length}`);
  }
  const whereSql = where.length ? `WHERE ${where.join(' AND ')}` : '';
  const totalRes = await query<{ count: string }>(
    `SELECT COUNT(*)::text AS count FROM products p ${whereSql}`,
    params,
  );
  const res = await query<Row>(
    `SELECT p.*, b.name AS brand_name, c.name AS category_name
       FROM products p
       LEFT JOIN brands b ON b.id = p.brand_id
       LEFT JOIN categories c ON c.id = p.category_id
      ${whereSql}
      ORDER BY p.name ASC
      LIMIT $${params.length + 1} OFFSET $${params.length + 2}`,
    [...params, pagination.limit, pagination.offset],
  );
  const products = res.rows;
  if (products.length > 0) {
    const ids = products.map((p) => String(p.id));
    const variants = await query<Row>(
      `SELECT * FROM product_variants WHERE product_id = ANY($1) AND is_active = TRUE ORDER BY name`,
      [ids],
    );
    const counts = await availableCounts(
      variants.rows.map((v) => String(v.id)),
    );
    const byProduct: Record<string, Row[]> = {};
    for (const v of variants.rows) {
      const pid = String(v.product_id);
      (byProduct[pid] ??= []).push(v);
    }
    for (const p of products) {
      const vs = byProduct[String(p.id)] ?? [];
      p.variants = attachStock(vs, counts, String(p.type));
    }
  }
  return { rows: products.map((p) => stripCosts(p, role)), total: Number(totalRes.rows[0].count) };
}

export async function getProduct(id: string, role: string): Promise<Row> {
  const res = await query<Row>(
    `SELECT p.*, b.name AS brand_name, c.name AS category_name
       FROM products p
       LEFT JOIN brands b ON b.id = p.brand_id
       LEFT JOIN categories c ON c.id = p.category_id
      WHERE p.id = $1`,
    [id],
  );
  const product = res.rows[0];
  if (!product) throw notFound('Product not found');
  const variants = await query<Row>(
    'SELECT * FROM product_variants WHERE product_id = $1 ORDER BY name',
    [id],
  );
  const counts = await availableCounts(variants.rows.map((v) => String(v.id)));
  product.variants = attachStock(variants.rows, counts, String(product.type));
  return stripCosts(product, role);
}

export async function createProduct(
  input: Record<string, unknown>,
  actor: AuthUser,
  req?: Request,
): Promise<Row> {
  const created = await withTransaction(async (client) => {
    const res = await client.query<Row>(
      `INSERT INTO products (brand_id, category_id, type, name, description, barcode, image_url)
       VALUES ($1, $2, $3, $4, $5, $6, $7) RETURNING *`,
      [
        input.brandId ?? null,
        input.categoryId ?? null,
        input.type,
        input.name,
        input.description ?? null,
        input.barcode ?? null,
        input.imageUrl ?? null,
      ],
    );
    await writeAudit(client, {
      userId: actor.id,
      action: 'create',
      entityType: 'product',
      entityId: String(res.rows[0].id),
      newValues: input,
      req,
    });
    return res.rows[0];
  });
  return stripCosts(created, actor.role);
}

export async function updateProduct(
  id: string,
  input: Record<string, unknown>,
  actor: AuthUser,
  req?: Request,
): Promise<Row> {
  return withTransaction(async (client) => {
    const existing = await client.query<Row>('SELECT * FROM products WHERE id = $1', [id]);
    if (existing.rows.length === 0) throw notFound('Product not found');
    const sets: string[] = [];
    const params: unknown[] = [];
    const push = (col: string, v: unknown) => {
      params.push(v);
      sets.push(`${col} = $${params.length}`);
    };
    if (input.brandId !== undefined) push('brand_id', input.brandId);
    if (input.categoryId !== undefined) push('category_id', input.categoryId);
    if (input.type !== undefined) push('type', input.type);
    if (input.name !== undefined) push('name', input.name);
    if (input.description !== undefined) push('description', input.description);
    if (input.barcode !== undefined) push('barcode', input.barcode);
    if (input.imageUrl !== undefined) push('image_url', input.image_url ?? input.imageUrl);
    if (input.isActive !== undefined) push('is_active', input.isActive);
    if (sets.length > 0) {
      params.push(id);
      await client.query(`UPDATE products SET ${sets.join(', ')} WHERE id = $${params.length}`, params);
    }
    const updated = await client.query<Row>('SELECT * FROM products WHERE id = $1', [id]);
    await writeAudit(client, {
      userId: actor.id,
      action: 'update',
      entityType: 'product',
      entityId: id,
      oldValues: existing.rows[0],
      newValues: input,
      req,
    });
    return stripCosts(updated.rows[0], actor.role);
  });
}

/** Soft-deactivate a product (and its variants). Never hard-deleted:
 *  past bills keep their item snapshots. */
export async function deactivateProduct(id: string, actor: AuthUser, req?: Request): Promise<void> {
  await withTransaction(async (client) => {
    const res = await client.query('UPDATE products SET is_active = FALSE WHERE id = $1 RETURNING id', [id]);
    if (res.rows.length === 0) throw notFound('Product not found');
    await client.query('UPDATE product_variants SET is_active = FALSE WHERE product_id = $1', [id]);
    await writeAudit(client, { userId: actor.id, action: 'delete', entityType: 'product', entityId: id, req });
  });
}

export async function createVariant(
  productId: string,
  input: Record<string, unknown>,
  actor: AuthUser,
  req?: Request,
): Promise<Row> {
  const created = await withTransaction(async (client) => {
    const product = await client.query('SELECT id FROM products WHERE id = $1', [productId]);
    if (product.rows.length === 0) throw notFound('Product not found');
    const res = await client.query<Row>(
      `INSERT INTO product_variants
         (product_id, name, color, storage_gb, ram_gb, condition, pta_status, barcode,
          purchase_price, sale_price, min_price, warranty_months, quantity, low_stock_threshold)
       VALUES ($1,$2,$3,$4,$5,$6,$7,$8,$9,$10,$11,$12,$13,$14) RETURNING *`,
      [
        productId,
        input.name,
        input.color ?? null,
        input.storageGb ?? null,
        input.ramGb ?? null,
        input.condition ?? 'new',
        input.ptaStatus ?? 'not_applicable',
        input.barcode ?? null,
        input.purchasePrice ?? 0,
        input.salePrice ?? 0,
        input.minPrice ?? 0,
        input.warrantyMonths ?? 0,
        input.quantity ?? 0,
        input.lowStockThreshold ?? 3,
      ],
    );
    await writeAudit(client, {
      userId: actor.id,
      action: 'create',
      entityType: 'product_variant',
      entityId: String(res.rows[0].id),
      newValues: input,
      req,
    });
    return res.rows[0];
  });
  return stripCosts(created, actor.role);
}

export async function updateVariant(
  id: string,
  input: Record<string, unknown>,
  actor: AuthUser,
  req?: Request,
): Promise<Row> {
  return withTransaction(async (client) => {
    const existing = await client.query<Row>('SELECT * FROM product_variants WHERE id = $1', [id]);
    if (existing.rows.length === 0) throw notFound('Variant not found');
    const map: Record<string, string> = {
      name: 'name',
      color: 'color',
      storageGb: 'storage_gb',
      ramGb: 'ram_gb',
      condition: 'condition',
      ptaStatus: 'pta_status',
      barcode: 'barcode',
      purchasePrice: 'purchase_price',
      salePrice: 'sale_price',
      minPrice: 'min_price',
      warrantyMonths: 'warranty_months',
      quantity: 'quantity',
      lowStockThreshold: 'low_stock_threshold',
      isActive: 'is_active',
    };
    const sets: string[] = [];
    const params: unknown[] = [];
    for (const [key, col] of Object.entries(map)) {
      if (input[key] !== undefined) {
        params.push(input[key]);
        sets.push(`${col} = $${params.length}`);
      }
    }
    if (sets.length > 0) {
      params.push(id);
      await client.query(`UPDATE product_variants SET ${sets.join(', ')} WHERE id = $${params.length}`, params);
    }
    const updated = await client.query<Row>('SELECT * FROM product_variants WHERE id = $1', [id]);
    await writeAudit(client, {
      userId: actor.id,
      action: 'update',
      entityType: 'product_variant',
      entityId: id,
      oldValues: existing.rows[0],
      newValues: input,
      req,
    });
    return stripCosts(updated.rows[0], actor.role);
  });
}

export async function deactivateVariant(id: string, actor: AuthUser, req?: Request): Promise<void> {
  await withTransaction(async (client) => {
    const res = await client.query(
      'UPDATE product_variants SET is_active = FALSE WHERE id = $1 RETURNING id',
      [id],
    );
    if (res.rows.length === 0) throw notFound('Variant not found');
    await writeAudit(client, { userId: actor.id, action: 'delete', entityType: 'product_variant', entityId: id, req });
  });
}

// ---- IMEI items ----
export async function listImei(
  filters: { status?: string; productId?: string; search?: string },
  pagination: { page: number; limit: number; offset: number },
  role: string,
): Promise<{ rows: Row[]; total: number }> {
  const where: string[] = [];
  const params: unknown[] = [];
  if (filters.status) {
    params.push(filters.status);
    where.push(`i.status = $${params.length}`);
  }
  if (filters.productId) {
    params.push(filters.productId);
    where.push(`i.product_id = $${params.length}`);
  }
  if (filters.search) {
    params.push(`%${filters.search}%`);
    where.push(`(i.imei1 ILIKE $${params.length} OR i.imei2 ILIKE $${params.length})`);
  }
  const whereSql = where.length ? `WHERE ${where.join(' AND ')}` : '';
  const totalRes = await query<{ count: string }>(
    `SELECT COUNT(*)::text AS count FROM imei_items i ${whereSql}`,
    params,
  );
  const res = await query<Row>(
    `SELECT i.*, p.name AS product_name, v.name AS variant_name
       FROM imei_items i
       JOIN products p ON p.id = i.product_id
       LEFT JOIN product_variants v ON v.id = i.variant_id
      ${whereSql}
      ORDER BY i.created_at DESC
      LIMIT $${params.length + 1} OFFSET $${params.length + 2}`,
    [...params, pagination.limit, pagination.offset],
  );
  return { rows: res.rows.map((r) => stripCosts(r, role)), total: Number(totalRes.rows[0].count) };
}

export async function getImeiByNumber(imei: string, role: string): Promise<Row> {
  const res = await query<Row>(
    `SELECT i.*, p.name AS product_name, v.name AS variant_name,
            s.invoice_no AS sold_invoice_no
       FROM imei_items i
       JOIN products p ON p.id = i.product_id
       LEFT JOIN product_variants v ON v.id = i.variant_id
       LEFT JOIN sales s ON s.id = i.sold_sale_id
      WHERE i.imei1 = $1 OR i.imei2 = $1`,
    [imei],
  );
  if (res.rows.length === 0) throw notFound('IMEI not found');
  return stripCosts(res.rows[0], role);
}

export async function createImei(
  input: Record<string, unknown>,
  actor: AuthUser,
  req?: Request,
): Promise<Row> {
  return withTransaction(async (client) => {
    const dup = await client.query('SELECT id FROM imei_items WHERE imei1 = $1 OR imei2 = $1', [
      input.imei1,
    ]);
    if (dup.rows.length > 0) throw conflict('This IMEI already exists in stock');
    const product = await client.query<{ type: string }>(
      'SELECT type FROM products WHERE id = $1',
      [input.productId],
    );
    if (product.rows.length === 0) throw notFound('Product not found');
    if (product.rows[0].type !== 'phone') {
      throw new ApiError(400, 'IMEI items can only be added for phone products', 'BAD_REQUEST');
    }
    const res = await client.query<Row>(
      `INSERT INTO imei_items
         (product_id, variant_id, imei1, imei2, purchase_price, sale_price, purchase_id)
       VALUES ($1,$2,$3,$4,$5,$6,$7) RETURNING *`,
      [
        input.productId,
        input.variantId ?? null,
        input.imei1,
        input.imei2 ?? null,
        input.purchasePrice ?? 0,
        input.salePrice ?? 0,
        input.purchaseId ?? null,
      ],
    );
    await writeAudit(client, {
      userId: actor.id,
      action: 'create',
      entityType: 'imei_item',
      entityId: String(res.rows[0].id),
      newValues: input,
      req,
    });
    return stripCosts(res.rows[0], actor.role);
  });
}

export async function updateImeiStatus(
  id: string,
  status: string,
  actor: AuthUser,
  req?: Request,
): Promise<Row> {
  return withTransaction(async (client) => {
    const existing = await client.query<Row>('SELECT * FROM imei_items WHERE id = $1', [id]);
    if (existing.rows.length === 0) throw notFound('IMEI item not found');
    if (existing.rows[0].status === 'sold' && status !== 'returned') {
      throw new ApiError(
        400,
        'A sold IMEI can only be returned (via a sale return), not re-marked manually',
        'BAD_REQUEST',
      );
    }
    const res = await client.query<Row>(
      'UPDATE imei_items SET status = $1 WHERE id = $2 RETURNING *',
      [status, id],
    );
    await writeAudit(client, {
      userId: actor.id,
      action: 'update',
      entityType: 'imei_item',
      entityId: id,
      oldValues: { status: existing.rows[0].status },
      newValues: { status },
      req,
    });
    return stripCosts(res.rows[0], actor.role);
  });
}

// ---- Low stock ----
export async function lowStock(role: string): Promise<Row[]> {
  // Accessories: quantity at or below threshold.
  const accessories = await query<Row>(
    `SELECT v.*, p.name AS product_name, p.type
       FROM product_variants v JOIN products p ON p.id = v.product_id
      WHERE p.type = 'accessory' AND v.is_active = TRUE
        AND v.quantity <= v.low_stock_threshold
      ORDER BY v.quantity ASC`,
  );
  // Phones: available IMEI count at or below threshold.
  const phones = await query<Row>(
    `SELECT v.*, p.name AS product_name, p.type,
            COALESCE(a.available_count, 0) AS available_stock
       FROM product_variants v
       JOIN products p ON p.id = v.product_id
       LEFT JOIN (
         SELECT variant_id, COUNT(*) AS available_count
           FROM imei_items WHERE status = 'available' GROUP BY variant_id
       ) a ON a.variant_id = v.id
      WHERE p.type = 'phone' AND v.is_active = TRUE
        AND COALESCE(a.available_count, 0) <= v.low_stock_threshold
      ORDER BY available_stock ASC`,
  );
  return [...accessories.rows, ...phones.rows].map((r) => stripCosts(r, role));
}

// ---- CSV export / import ----
export async function exportCsv(role: string): Promise<string> {
  const res = await query<Row>(
    `SELECT p.name AS product, p.type, COALESCE(b.name,'') AS brand,
            COALESCE(c.name,'') AS category, v.name AS variant, v.color,
            v.storage_gb, v.ram_gb, v.condition, v.pta_status, v.barcode,
            v.purchase_price, v.sale_price, v.min_price, v.warranty_months,
            v.quantity, v.low_stock_threshold
       FROM product_variants v
       JOIN products p ON p.id = v.product_id
       LEFT JOIN brands b ON b.id = p.brand_id
       LEFT JOIN categories c ON c.id = p.category_id
      WHERE v.is_active = TRUE
      ORDER BY p.name, v.name`,
  );
  const header = [
    'name', 'type', 'brand', 'category', 'variantName', 'color', 'storageGb', 'ramGb',
    'condition', 'ptaStatus', 'barcode', 'purchasePrice', 'salePrice', 'minPrice',
    'warrantyMonths', 'quantity', 'lowStockThreshold',
  ];
  const rows = res.rows.map((r) => {
    const row = stripCosts(r, role) as Row;
    return header.map((h) => {
      const map: Record<string, string> = {
        name: 'product', variantName: 'variant', purchasePrice: 'purchase_price',
        salePrice: 'sale_price', minPrice: 'min_price', warrantyMonths: 'warranty_months',
        storageGb: 'storage_gb', ramGb: 'ram_gb', ptaStatus: 'pta_status',
        lowStockThreshold: 'low_stock_threshold',
      };
      const key = map[h] ?? h;
      const v = row[key];
      return v === null || v === undefined ? '' : (v as string | number);
    });
  });
  return toCsv(header, rows);
}

interface ImportResult {
  imported: number;
  skipped: number;
  errors: { row: number; message: string }[];
}

/** Bulk import from parsed rows (JSON) or raw CSV text. Upserts by
 *  (product name + brand) and (variant name / barcode). */
export async function importProducts(
  input: { rows?: Record<string, unknown>[]; csv?: string },
  actor: AuthUser,
  req?: Request,
): Promise<ImportResult> {
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
  const result: ImportResult = { imported: 0, skipped: 0, errors: [] };
  await withTransaction(async (client) => {
    for (let i = 0; i < rows.length; i++) {
      const r = rows[i];
      try {
        if (!r.name || !r.type) throw new Error('name and type are required');
        const brandId = await findOrCreateBrand(client, String(r.brand ?? ''));
        const categoryId = await findOrCreateCategory(
          client,
          String(r.category ?? ''),
          String(r.type),
        );
        let product = await client.query<{ id: string }>(
          'SELECT id FROM products WHERE name = $1 AND type = $2 AND (brand_id = $3 OR ($3 IS NULL AND brand_id IS NULL))',
          [r.name, r.type, brandId],
        );
        let productId: string;
        if (product.rows.length === 0) {
          const ins = await client.query<{ id: string }>(
            `INSERT INTO products (brand_id, category_id, type, name)
             VALUES ($1,$2,$3,$4) RETURNING id`,
            [brandId, categoryId, r.type, r.name],
          );
          productId = ins.rows[0].id;
        } else {
          productId = product.rows[0].id;
        }
        const variantName = String(r.variantName ?? r.variant ?? 'Default');
        const barcode = r.barcode ? String(r.barcode) : null;
        const existingVariant = await client.query<{ id: string }>(
          barcode
            ? 'SELECT id FROM product_variants WHERE barcode = $1'
            : 'SELECT id FROM product_variants WHERE product_id = $1 AND name = $2',
          barcode ? [barcode] : [productId, variantName],
        );
        const vals = [
          productId,
          variantName,
          r.color ?? null,
          r.storageGb ?? null,
          r.ramGb ?? null,
          r.condition ?? 'new',
          r.ptaStatus ?? 'not_applicable',
          barcode,
          r.purchasePrice ?? 0,
          r.salePrice ?? 0,
          r.minPrice ?? 0,
          r.warrantyMonths ?? 0,
          r.quantity ?? 0,
          r.lowStockThreshold ?? 3,
        ];
        if (existingVariant.rows.length === 0) {
          await client.query(
            `INSERT INTO product_variants
               (product_id, name, color, storage_gb, ram_gb, condition, pta_status, barcode,
                purchase_price, sale_price, min_price, warranty_months, quantity, low_stock_threshold)
             VALUES ($1,$2,$3,$4,$5,$6,$7,$8,$9,$10,$11,$12,$13,$14)`,
            vals,
          );
          result.imported++;
        } else {
          result.skipped++;
        }
      } catch (err) {
        result.errors.push({ row: i + 1, message: (err as Error).message });
      }
    }
    await writeAudit(client, {
      userId: actor.id,
      action: 'import',
      entityType: 'product',
      newValues: { imported: result.imported, skipped: result.skipped },
      req,
    });
  });
  return result;
}

async function findOrCreateBrand(client: PoolClient, name: string): Promise<string | null> {
  const clean = name.trim();
  if (!clean) return null;
  const found = await client.query<{ id: string }>('SELECT id FROM brands WHERE name = $1', [clean]);
  if (found.rows.length > 0) return found.rows[0].id;
  const ins = await client.query<{ id: string }>(
    'INSERT INTO brands (name) VALUES ($1) ON CONFLICT (name) DO UPDATE SET name = EXCLUDED.name RETURNING id',
    [clean],
  );
  return ins.rows[0].id;
}

async function findOrCreateCategory(
  client: PoolClient,
  name: string,
  type: string,
): Promise<string | null> {
  const clean = name.trim();
  if (!clean) return null;
  const found = await client.query<{ id: string }>(
    'SELECT id FROM categories WHERE name = $1 AND type = $2',
    [clean, type],
  );
  if (found.rows.length > 0) return found.rows[0].id;
  const ins = await client.query<{ id: string }>(
    'INSERT INTO categories (name, type) VALUES ($1, $2) RETURNING id',
    [clean, type],
  );
  return ins.rows[0].id;
}

// ---- Brands & categories ----
export async function listBrands(): Promise<Row[]> {
  const res = await query<Row>('SELECT * FROM brands WHERE is_active = TRUE ORDER BY name');
  return res.rows;
}

export async function createBrand(name: string, actor: AuthUser, req?: Request): Promise<Row> {
  return withTransaction(async (client) => {
    const res = await client.query<Row>(
      'INSERT INTO brands (name) VALUES ($1) ON CONFLICT (name) DO UPDATE SET name = EXCLUDED.name RETURNING *',
      [name],
    );
    await writeAudit(client, { userId: actor.id, action: 'create', entityType: 'brand', entityId: String(res.rows[0].id), newValues: { name }, req });
    return res.rows[0];
  });
}

export async function listCategories(): Promise<Row[]> {
  const res = await query<Row>('SELECT * FROM categories WHERE is_active = TRUE ORDER BY name');
  return res.rows;
}

export async function createCategory(
  input: { name: string; type: string; parentId?: string | null },
  actor: AuthUser,
  req?: Request,
): Promise<Row> {
  return withTransaction(async (client) => {
    const res = await client.query<Row>(
      'INSERT INTO categories (name, type, parent_id) VALUES ($1, $2, $3) RETURNING *',
      [input.name, input.type, input.parentId ?? null],
    );
    await writeAudit(client, { userId: actor.id, action: 'create', entityType: 'category', entityId: String(res.rows[0].id), newValues: input as Record<string, unknown>, req });
    return res.rows[0];
  });
}
