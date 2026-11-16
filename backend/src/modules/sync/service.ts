// Offline sync: the phone pushes bills it created while offline and pulls
// everything that changed on the server since its last sync.
// Idempotency: every pushed sale carries a client_uuid. If the server already
// has a sale with that client_uuid, the push is a no-op for that sale
// (safe retries, no duplicate bills). Phones are identified by IMEI number
// in the push payload; the server resolves each IMEI to its imei_item row.
// Sync history lives in sync_logs (device_id, user_id, entity_type,
// entity_id, action, detail JSONB).
import { query, withTransaction } from '../../config/db';
import { badRequest, notFound } from '../../middleware/errors';
import { writeAudit } from '../../middleware/audit';
import { createSale } from '../sales/service';
import type { AuthUser } from '../../types';
import type { Request } from 'express';

type Row = Record<string, unknown>;

interface SyncSaleInput {
  clientUuid: string;
  customerId?: string | null;
  customerName?: string | null;
  customerPhone?: string | null;
  items: {
    variantId: string;
    imei1?: string | null;
    quantity: number;
    unitPrice: number;
    discount?: number;
  }[];
  discountAmount?: number;
  discountPercent?: number;
  taxAmount?: number;
  paidAmount: number;
  paymentMethod?: string;
  notes?: string | null;
  adminApprovedBy?: string | null;
}

export interface SyncPushResult {
  accepted: Row[];
  skipped: { clientUuid: string; reason: string }[];
  errors: { clientUuid: string; error: string }[];
  serverTime: string;
}

export async function pushSales(
  deviceId: string,
  sales: SyncSaleInput[],
  user: AuthUser,
  req?: Request,
): Promise<SyncPushResult> {
  const accepted: Row[] = [];
  const skipped: SyncPushResult['skipped'] = [];
  const errors: SyncPushResult['errors'] = [];
  for (const sale of sales) {
    try {
      const existing = await query<{ id: string }>(
        'SELECT id FROM sales WHERE client_uuid = $1',
        [sale.clientUuid],
      );
      if (existing.rows.length > 0) {
        skipped.push({ clientUuid: sale.clientUuid, reason: 'already_synced' });
        continue;
      }
      // Resolve phone IMEIs to server-side imei_item ids.
      const items = [];
      for (const item of sale.items) {
        let imeiItemId: string | null = null;
        if (item.imei1) {
          const found = await query<{ id: string }>(
            'SELECT id FROM imei_items WHERE imei1 = $1',
            [item.imei1],
          );
          if (found.rows.length === 0) {
            throw notFound(`IMEI ${item.imei1} is not in stock on the server`);
          }
          imeiItemId = found.rows[0].id;
        }
        items.push({
          variantId: item.variantId,
          imeiItemId,
          quantity: item.quantity,
          unitPrice: item.unitPrice,
          discount: item.discount ?? 0,
        });
      }
      const created = await createSale(
        {
          customerId: sale.customerId ?? null,
          customerName: sale.customerName ?? null,
          customerPhone: sale.customerPhone ?? null,
          items,
          discountAmount: sale.discountAmount ?? 0,
          discountPercent: sale.discountPercent ?? 0,
          taxAmount: sale.taxAmount ?? 0,
          paymentMethod: sale.paymentMethod ?? 'cash',
          paidAmount: sale.paidAmount,
          adminApprovedBy: sale.adminApprovedBy ?? null,
          notes: sale.notes ?? null,
          clientUuid: sale.clientUuid,
        },
        user,
        req,
      );
      accepted.push(created);
    } catch (err) {
      const message = err instanceof Error ? err.message : 'Unknown error';
      errors.push({ clientUuid: sale.clientUuid, error: message });
    }
  }
  // Record the device's push in sync_logs (for conflict diagnostics).
  await withTransaction(async (client) => {
    await client.query(
      `INSERT INTO sync_logs (device_id, user_id, entity_type, action, detail)
       VALUES ($1,$2,'sale','push',$3::jsonb)`,
      [
        deviceId,
        user.id,
        JSON.stringify({
          accepted: accepted.length,
          skipped: skipped.length,
          errors: errors.map((e) => ({ clientUuid: e.clientUuid, error: e.error })),
        }),
      ],
    );
    await writeAudit(client, {
      userId: user.id,
      action: 'sync',
      entityType: 'sync',
      entityId: null,
      newValues: { deviceId, accepted: accepted.length, skipped: skipped.length, errors: errors.length },
      req,
    });
  });
  return { accepted, skipped, errors, serverTime: new Date().toISOString() };
}

export interface SyncPullResult {
  serverTime: string;
  products: Row[];
  variants: Row[];
  customers: Row[];
  suppliers: Row[];
  sales: Row[];
  settings: Row;
}

/** Everything that changed since `since` (ISO timestamp). The client applies
 *  these rows over its local copy (server wins on conflicts). */
export async function pullChanges(since: string | undefined): Promise<SyncPullResult> {
  const sinceTs = since ?? new Date(0).toISOString();
  const params = [sinceTs];
  const products = await query<Row>(
    'SELECT * FROM products WHERE updated_at > $1 ORDER BY updated_at',
    params,
  );
  const variants = await query<Row>(
    'SELECT * FROM product_variants WHERE updated_at > $1 ORDER BY updated_at',
    params,
  );
  const customers = await query<Row>(
    'SELECT * FROM customers WHERE updated_at > $1 ORDER BY updated_at',
    params,
  );
  const suppliers = await query<Row>(
    'SELECT * FROM suppliers WHERE updated_at > $1 ORDER BY updated_at',
    params,
  );
  const sales = await query<Row>(
    `SELECT s.*, u.name AS user_name FROM sales s
       JOIN users u ON u.id = s.user_id
      WHERE s.updated_at > $1 ORDER BY s.updated_at`,
    params,
  );
  const settingsRes = await query<{ key: string; value: unknown }>(
    'SELECT key, value FROM settings ORDER BY key',
  );
  const settings: Row = {};
  for (const r of settingsRes.rows) settings[r.key] = r.value;
  return {
    serverTime: new Date().toISOString(),
    products: products.rows,
    variants: variants.rows,
    customers: customers.rows,
    suppliers: suppliers.rows,
    sales: sales.rows,
    settings,
  };
}

/** Per-device sync history (for the admin to see which device last synced). */
export async function syncHistory(deviceId: string | undefined, limit: number): Promise<Row[]> {
  const params: unknown[] = [limit];
  const where = deviceId ? 'WHERE device_id = $2' : '';
  if (deviceId) params.push(deviceId);
  const res = await query<Row>(
    `SELECT sl.*, u.name AS user_name
       FROM sync_logs sl LEFT JOIN users u ON u.id = sl.user_id
      ${where} ORDER BY sl.created_at DESC LIMIT $1`,
    params,
  );
  return res.rows;
}

export function validateSyncPayload(body: unknown): void {
  if (!body || typeof body !== 'object') throw badRequest('Sync payload must be an object');
  const b = body as Record<string, unknown>;
  if (!b.deviceId || typeof b.deviceId !== 'string') {
    throw badRequest('deviceId is required');
  }
  if (b.sales !== undefined && !Array.isArray(b.sales)) {
    throw badRequest('sales must be an array');
  }
}
