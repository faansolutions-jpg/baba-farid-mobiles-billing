import { z } from 'zod';

const money = z.number().int().nonnegative();
const uuid = z.string().uuid();

export const customerSchema = z.object({
  name: z.string().trim().min(2).max(100),
  phone: z.string().trim().min(10).max(15),
  cnic: z.string().trim().max(15).optional().nullable(),
  address: z.string().max(500).optional().nullable(),
  openingBalance: money.default(0),
});

export const updateCustomerSchema = customerSchema.partial();

export const installmentSchema = z.object({
  saleId: uuid,
  downPayment: money.optional(),
  installmentCount: z.number().int().min(1).max(36),
  startDate: z.string().regex(/^\d{4}-\d{2}-\d{2}$/, 'startDate must be YYYY-MM-DD'),
});

export const installmentPaymentSchema = z.object({
  installmentPaymentId: uuid,
  amount: z.number().int().positive(),
  method: z.enum(['cash', 'jazzcash', 'easypaisa', 'bank_transfer', 'card']).default('cash'),
  reference: z.string().trim().max(100).optional().nullable(),
  notes: z.string().max(500).optional().nullable(),
});
