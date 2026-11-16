// Consistent JSON envelope: every success is { ok: true, data, meta? },
// every failure is { ok: false, error: { message, code?, details? } }.
import type { Response } from 'express';
import type { Pagination } from '../types';

export function ok<T>(res: Response, data: T, status = 200, meta?: Record<string, unknown>): void {
  res.status(status).json({ ok: true, data, ...(meta ? { meta } : {}) });
}

export function created<T>(res: Response, data: T): void {
  ok(res, data, 201);
}

export function paginated<T>(
  res: Response,
  items: T[],
  pagination: Pagination,
  total: number,
): void {
  const totalPages = Math.max(1, Math.ceil(total / pagination.limit));
  ok(res, items, 200, {
    page: pagination.page,
    limit: pagination.limit,
    total,
    totalPages,
  });
}

/** Parse ?page=&limit= safely (defaults 1 / 20, limit capped at 100). */
export function parsePagination(query: Record<string, unknown>): Pagination {
  const page = Math.max(1, Number(query.page ?? 1) || 1);
  const limit = Math.min(100, Math.max(1, Number(query.limit ?? 20) || 20));
  return { page, limit, offset: (page - 1) * limit };
}
