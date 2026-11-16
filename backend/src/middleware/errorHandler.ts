// Central error handler (last middleware in app.ts). Translates thrown
// errors — ApiError, Zod, PostgreSQL codes — into the standard envelope.
import type { NextFunction, Request, Response } from 'express';
import { ApiError } from './errors';
import { logger } from '../utils/logger';

/** Map common PostgreSQL error codes to HTTP statuses. */
function pgStatus(code: string | undefined): number | null {
  switch (code) {
    case '23505': // unique_violation (duplicate IMEI, phone, invoice no.)
      return 409;
    case '23503': // foreign_key_violation (referenced record missing)
      return 400;
    case '23514': // check_violation (negative money, bad enum value)
      return 400;
    case '23502': // not_null_violation
      return 400;
    default:
      return null;
  }
}

export function errorHandler(
  err: unknown,
  _req: Request,
  res: Response,
  _next: NextFunction,
): void {
  if (err instanceof ApiError) {
    res.status(err.status).json({
      ok: false,
      error: { message: err.message, code: err.code, details: err.details },
    });
    return;
  }
  const pgErr = err as { code?: string; message?: string; detail?: string };
  const status = pgStatus(pgErr.code);
  if (status) {
    const message =
      pgErr.code === '23505'
        ? 'Duplicate record — this value already exists (e.g. IMEI, phone or invoice number).'
        : pgErr.message ?? 'Database constraint failed';
    res.status(status).json({
      ok: false,
      error: { message, code: pgErr.code, details: pgErr.detail },
    });
    return;
  }
  logger.error('Unhandled error', err);
  res.status(500).json({
    ok: false,
    error: { message: 'Internal server error', code: 'INTERNAL' },
  });
}

/** 404 for unknown routes under /api. */
export function notFoundHandler(_req: Request, res: Response): void {
  res.status(404).json({ ok: false, error: { message: 'Route not found', code: 'NOT_FOUND' } });
}
