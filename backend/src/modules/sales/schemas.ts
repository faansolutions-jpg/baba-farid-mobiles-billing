import { z } from 'zod';

const money = z.number().int().nonnegative();
const moneyPositive = z.number().int().positive();
const uuid = z.string().uuid();

export const saleItemSchema = z.object({
  variantId: uuid,
  imeiItemId: uuid.optional().nullable(),
  quantity: z.number().int().positive().default(1),
  unitPrice: money,
  discount: money.default(0),
});

export const createSaleSchema = z.object({
  customerId: uuid.optional().nullable(),
  customerName: z.string().trim().max(100).optional().nullable(),
  customerPhone: z.string().trim().max(15).optional().nullable(),
  items: z.array(saleItemSchema).min(1).max(200),
  discountAmount: money.default(0),
  discountPercent: z.number().min(0).max(100).default(0),
  taxAmount: money.default(0),
  paymentMethod: z.enum(['cash', 'jazzcash', 'easypaisa', 'bank_transfer', 'card', 'partial', 'udhaar']),
  paidAmount: money,
  adminApprovedBy: uuid.optional().nullable(),
  notes: z.string().max(1000).optional().nullable(),
  clientUuid: uuid.optional().nullable(),
});

export const returnItemSchema = z.object({
  saleItemId: uuid,
  quantity: z.number().int().positive(),
  reason: z.string().trim().max(500).optional().nullable(),
});

export const returnSaleSchema = z.object({
  items: z.array(returnItemSchema).min(1),
  exchangeSaleId: uuid.optional().nullable(),
});

export const salePaymentSchema = z.object({
  amount: moneyPositive,
  method: z.enum(['cash', 'jazzcash', 'easypaisa', 'bank_transfer', 'card']).default('cash'),
  reference: z.string().trim().max(100).optional().nullable(),
  notes: z.string().max(500).optional().nullable(),
});

export const holdBillSchema = z.object({
  customerName: z.string().trim().max(100).optional().nullable(),
  cart: z.array(z.record(z.unknown())).min(1),
});
