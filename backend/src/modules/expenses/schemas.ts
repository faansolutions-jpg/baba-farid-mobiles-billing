import { z } from 'zod';

const money = z.number().int().nonnegative();
const uuid = z.string().uuid();

// expenses.category is a plain TEXT column in the schema
// (rent, electricity, salary, transport, other, ...). No category table.
export const STANDARD_EXPENSE_CATEGORIES = [
  'rent',
  'electricity',
  'salary',
  'transport',
  'internet',
  'shop_supplies',
  'marketing',
  'other',
] as const;

export const expenseSchema = z.object({
  category: z.string().trim().min(2).max(100),
  amount: z.number().int().positive(),
  description: z.string().trim().max(500).optional().nullable(),
});

export const updateExpenseSchema = expenseSchema.partial();

export const staffSchema = z.object({
  name: z.string().trim().min(2).max(100),
  phone: z.string().trim().max(15).optional().nullable(),
  role: z.string().trim().max(50),
  salary: money.default(0),
  isActive: z.boolean().default(true),
});

export const updateStaffSchema = staffSchema.partial();

// salary_payments: month is TEXT 'YYYY-MM'; amount = gross salary for the
// month, advance = advance already given (net paid = amount - advance).
export const salarySchema = z.object({
  staffId: uuid,
  month: z.string().regex(/^\d{4}-\d{2}$/, 'month must be YYYY-MM'),
  amount: z.number().int().positive(),
  advance: money.default(0),
  notes: z.string().max(500).optional().nullable(),
});

export const openRegisterSchema = z.object({
  openingCash: money,
  notes: z.string().max(500).optional().nullable(),
});

export const cashMovementSchema = z.object({
  type: z.enum(['in', 'out']),
  amount: z.number().int().positive(),
  reason: z.string().trim().min(2).max(500),
});

export const closeRegisterSchema = z.object({
  closingCash: money,
  notes: z.string().max(500).optional().nullable(),
});
