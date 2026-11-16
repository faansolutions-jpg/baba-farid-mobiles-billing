import { z } from 'zod';

const uuid = z.string().uuid();

export const reportQuerySchema = z.object({
  branchId: uuid.optional(),
  from: z.string().regex(/^\d{4}-\d{2}-\d{2}$/, 'from must be YYYY-MM-DD').optional(),
  to: z.string().regex(/^\d{4}-\d{2}-\d{2}$/, 'to must be YYYY-MM-DD').optional(),
});

export const periodQuerySchema = z.object({
  branchId: uuid.optional(),
  from: z.string().regex(/^\d{4}-\d{2}-\d{2}$/, 'from must be YYYY-MM-DD').optional(),
  to: z.string().regex(/^\d{4}-\d{2}-\d{2}$/, 'to must be YYYY-MM-DD').optional(),
  groupBy: z.enum(['day', 'week', 'month']).default('day'),
});
