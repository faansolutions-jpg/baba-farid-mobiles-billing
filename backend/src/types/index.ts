// Shared types used across the backend.
export interface AuthUser {
  id: string;
  name: string;
  phone: string;
  role: string; // 'owner' | 'manager' | 'cashier'
  branchId: string | null;
}

export interface Pagination {
  page: number;
  limit: number;
  offset: number;
}

export interface PaginatedResult<T> {
  items: T[];
  meta: {
    page: number;
    limit: number;
    total: number;
    totalPages: number;
  };
}

/** A row returned by pg (all columns are plain JS values; NUMERIC is parsed to number in db.ts). */
export type DbRow = Record<string, unknown>;
