// Shop settings: key/value rows in the `settings` table
// (key TEXT PRIMARY KEY, value JSONB). getSettings returns a flat object
// of all keys; updateSettings upserts the given keys.
import { query, withTransaction } from '../../config/db';
import { writeAudit } from '../../middleware/audit';
import type { AuthUser } from '../../types';
import type { Request } from 'express';

type Row = Record<string, unknown>;

/** Friendly field name -> settings key. */
const FIELD_TO_KEY: Record<string, string> = {
  shopName: 'shop.name',
  address: 'shop.address',
  phone: 'shop.phone',
  phone2: 'shop.phone2',
  email: 'shop.email',
  whatsapp: 'shop.whatsapp',
  taxNumber: 'shop.tax_number',
  logoUrl: 'shop.logo_url',
  invoicePrefix: 'invoice.prefix',
  invoiceFooter: 'invoice.footer',
  taxEnabled: 'tax.enabled',
  defaultTaxRate: 'tax.rate',
  currency: 'shop.currency',
  language: 'shop.language',
  timezone: 'shop.timezone',
};

export async function getSettings(): Promise<Row> {
  const res = await query<{ key: string; value: unknown }>(
    'SELECT key, value FROM settings ORDER BY key',
  );
  const out: Row = {};
  for (const r of res.rows) out[r.key] = r.value;
  return out;
}

export async function updateSettings(
  input: Record<string, unknown>,
  actor: AuthUser,
  req?: Request,
): Promise<Row> {
  return withTransaction(async (client) => {
    const before = await client.query<{ key: string; value: unknown }>(
      'SELECT key, value FROM settings ORDER BY key',
    );
    const oldValues: Row = {};
    for (const r of before.rows) oldValues[r.key] = r.value;

    const changed: Row = {};
    for (const [field, value] of Object.entries(input)) {
      const key = FIELD_TO_KEY[field];
      if (!key) continue;
      await client.query(
        `INSERT INTO settings (key, value) VALUES ($1, $2::jsonb)
         ON CONFLICT (key) DO UPDATE SET value = EXCLUDED.value, updated_at = now()`,
        [key, JSON.stringify(value)],
      );
      changed[key] = value;
    }
    // Settings have no UUID, so the audit row carries no entity_id.
    await writeAudit(client, {
      userId: actor.id,
      action: 'update',
      entityType: 'settings',
      entityId: null,
      oldValues,
      newValues: changed,
      req,
    });
    return getSettings();
  });
}
