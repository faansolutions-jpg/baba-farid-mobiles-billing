// Zod request validation. Every mutating endpoint runs its body through
// one of these before any service code (and before any DB access).
import type { NextFunction, Request, Response } from 'express';
import type { z } from 'zod';
import { badRequest } from './errors';

export function validateBody<T extends z.ZodTypeAny>(schema: T) {
  return (req: Request, _res: Response, next: NextFunction): void => {
    const parsed = schema.safeParse(req.body);
    if (!parsed.success) {
      return next(
        badRequest('Validation failed', parsed.error.flatten().fieldErrors),
      );
    }
    req.body = parsed.data;
    return next();
  };
}

export function validateQuery<T extends z.ZodTypeAny>(schema: T) {
  return (req: Request, _res: Response, next: NextFunction): void => {
    const parsed = schema.safeParse(req.query);
    if (!parsed.success) {
      return next(
        badRequest('Invalid query parameters', parsed.error.flatten().fieldErrors),
      );
    }
    // Attach the coerced values back onto req.query for handlers to use.
    Object.assign(req.query, parsed.data);
    return next();
  };
}
