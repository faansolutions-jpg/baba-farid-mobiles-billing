// Audit logging. Every mutating service call writes one row to audit_logs
// INSIDE the same transaction as the change, so the audit entry and the
// change commit (or roll back) together. Never log passwords or tokens.
import type { PoolClient } from 'pg';
import type { Request } from 'express';

export interface AuditInput {
  userId: string | null;
  action: string; // create, update, delete, login, sale, payment, return, ...
  entityType: string; // sale, product, customer, settings, ...
  entityId?: string | null;
  oldValues?: Record<string, unknown> | null;
  newValues?: Record<string, unknown> | null;
  req?: Request;
}

export async function writeAudit(client: PoolClient, input: AuditInput): Promise<void> {
  await client.query(
    `INSERT INTO audit_logs
       (user_id, action, entity_type, entity_id, old_values, new_values, ip_address, device_info)
     VALUES ($1, $2, $3, $4, $5::jsonb, $6::jsonb, $7, $8)`,
    [
      input.userId,
      input.action,
      input.entityType,
      input.entityId ?? null,
      input.oldValues ? JSON.stringify(input.oldValues) : null,
      input.newValues ? JSON.stringify(input.newValues) : null,
      input.req?.ip ?? null,
      input.req?.headers['user-agent'] ?? null,
    ],
  );
}

/** Read audit logs (owner only). Newest first, paginated. */
export async function listAuditLogs(
  client: PoolClient,
  opts: { userId?: string; entityType?: string; limit: number; offset: number },
): Promise<{ rows: Record<string, unknown>[]; total: number }> {
  const where: string[] = [];
  const params: unknown[] = [];
  if (opts.userId) {
    params.push(opts.userId);
    where.push(`user_id = $${params.length}`);
  }
  if (opts.entityType) {
    params.push(opts.entityType);
    where.push(`entity_type = $${params.length}`);
  }
  const whereSql = where.length ? `WHERE ${where.join(' AND ')}` : '';
  const totalRes = await client.query<{ count: string }>(
    `SELECT COUNT(*)::text AS count FROM audit_logs ${whereSql}`,
    params,
  );
  const rowsRes = await client.query(
    `SELECT a.*, u.name AS user_name
       FROM audit_logs a LEFT JOIN users u ON u.id = a.user_id
      ${whereSql}
      ORDER BY a.created_at DESC
      LIMIT $${params.length + 1} OFFSET $${params.length + 2}`,
    [...params, opts.limit, opts.offset],
  );
  return { rows: rowsRes.rows as Record<string, unknown>[], total: Number(totalRes.rows[0].count) };
}
