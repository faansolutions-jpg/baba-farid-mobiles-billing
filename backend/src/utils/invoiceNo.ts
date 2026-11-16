// Sequential document numbers (INV-000123, REP-000123) using the counters
// table. The row is locked (FOR UPDATE) inside the caller's transaction so
// two concurrent bills can never receive the same number.
import type { PoolClient } from 'pg';

export async function nextDocumentNo(
  client: PoolClient,
  branchId: string,
  counterName: string,
  prefix: string,
): Promise<string> {
  const found = await client.query<{ last_value: number }>(
    'SELECT last_value FROM counters WHERE branch_id = $1 AND name = $2 FOR UPDATE',
    [branchId, counterName],
  );
  let next: number;
  if (found.rows.length === 0) {
    await client.query(
      'INSERT INTO counters (branch_id, name, prefix, last_value) VALUES ($1, $2, $3, 1)',
      [branchId, counterName, prefix],
    );
    next = 1;
  } else {
    next = Number(found.rows[0].last_value) + 1;
    await client.query(
      'UPDATE counters SET last_value = $1 WHERE branch_id = $2 AND name = $3',
      [next, branchId, counterName],
    );
  }
  return `${prefix}-${String(next).padStart(6, '0')}`;
}
