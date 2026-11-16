// Role-based field stripping. Cashiers must NEVER receive cost prices or
// profit in any API response. Apply to product/variant/sale payloads
// before sending them out.
import { COST_VISIBLE_ROLES } from '../config/constants';

const COST_FIELDS = new Set([
  'purchase_price',
  'purchase_cost',
  'min_price',
  'profit',
  'cost',
]);

function stripValue(value: unknown, role: string): unknown {
  if (Array.isArray(value)) return value.map((v) => stripValue(v, role));
  if (value !== null && typeof value === 'object') {
    const out: Record<string, unknown> = {};
    for (const [k, v] of Object.entries(value as Record<string, unknown>)) {
      if (COST_FIELDS.has(k)) continue;
      out[k] = stripValue(v, role);
    }
    return out;
  }
  return value;
}

/** Remove cost/profit fields when the caller's role may not see them. */
export function stripCosts<T>(data: T, role: string): T {
  if (COST_VISIBLE_ROLES.includes(role as 'owner' | 'manager')) return data;
  return stripValue(data, role) as T;
}

/** Never send a password hash (or any secret) to a client. */
export function stripSecrets<T extends object>(row: T): Omit<T, 'password_hash'> {
  const copy = { ...(row as Record<string, unknown>) };
  delete copy.password_hash;
  return copy as Omit<T, 'password_hash'>;
}
