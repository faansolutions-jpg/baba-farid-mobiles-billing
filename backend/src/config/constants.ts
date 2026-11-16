// Shared constants: roles, payment methods, pagination limits.
export const ROLES = {
  OWNER: 'owner',
  MANAGER: 'manager',
  CASHIER: 'cashier',
} as const;

export type RoleName = (typeof ROLES)[keyof typeof ROLES];

/** Roles allowed to see cost prices and profit. Cashiers never do. */
export const COST_VISIBLE_ROLES: RoleName[] = ['owner', 'manager'];

export const PAYMENT_METHODS = [
  'cash',
  'jazzcash',
  'easypaisa',
  'bank_transfer',
  'card',
  'partial',
  'udhaar',
] as const;

export const DEFAULT_PAGE = 1;
export const DEFAULT_LIMIT = 20;
export const MAX_LIMIT = 100;

/** Invoice / job-number prefixes (match the counters table). */
export const COUNTER_NAMES = {
  SALE_INVOICE: { name: 'sale_invoice', prefix: 'INV' },
  REPAIR_JOB: { name: 'repair_job', prefix: 'REP' },
} as const;
