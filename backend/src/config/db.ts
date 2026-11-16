// PostgreSQL connection pool + transaction helper.
// All SQL in this codebase is parameterised ($1, $2, ...) — never
// string-interpolated — so SQL injection is not possible via app code.
import { Pool, PoolClient, QueryResult, QueryResultRow } from 'pg';
import { types } from 'pg';
import { env } from './env';

// OID 1700 = NUMERIC. pg returns NUMERIC as a string by default; parse it
// as a JS number. All money in this system is whole PKR integers, so this
// is exact (no floating-point paisa values ever exist).
types.setTypeParser(1700, (v: string) => parseInt(v, 10));

export const pool = new Pool({
  connectionString: env.databaseUrl,
  max: 20,
  idleTimeoutMillis: 30_000,
  connectionTimeoutMillis: 5_000,
});

pool.on('error', (err) => {
  // A pool error must never crash the process silently; log it.
  // eslint-disable-next-line no-console
  console.error('[db] idle client error', err);
});

/** Run a single parameterised query. */
export async function query<T extends QueryResultRow = QueryResultRow>(
  text: string,
  params: unknown[] = [],
): Promise<QueryResult<T>> {
  return pool.query<T>(text, params as never[]);
}

/**
 * Run work inside a single database transaction. The callback receives a
 * client bound to the transaction; COMMIT on success, ROLLBACK on error.
 * Use this for every multi-table write (sale, purchase, return, payment).
 */
export async function withTransaction<T>(
  fn: (client: PoolClient) => Promise<T>,
): Promise<T> {
  const client = await pool.connect();
  try {
    await client.query('BEGIN');
    const result = await fn(client);
    await client.query('COMMIT');
    return result;
  } catch (err) {
    await client.query('ROLLBACK');
    throw err;
  } finally {
    client.release();
  }
}
