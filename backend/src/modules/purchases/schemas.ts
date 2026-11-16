import { z } from 'zod';

const money = z.number().int().nonnegative();
const uuid = z.string().uuid();

export const purchaseItemSchema = z.object({
  productId: uuid,
  variantId: uuid,
  imei1: z.string().trim().min(15).max(17).optional().nullable(),
  imei2: z.string().trim().min(15).max(17).optional().nullable(),
  quantity: z.number().int().positive().default(1),
  unitCost: money,
});

export const createPurchaseSchema = z.object({
  supplierId: uuid,
  supplierInvoiceNo: z.string().trim().max(100).optional().nullable(),
  items: z.array(purchaseItemSchema).min(1).max(500),
  discount: money.default(0),
  paidAmount: money.default(0),
  paymentMethod: z.enum(['cash', 'jazzcash', 'easypaisa', 'bank_transfer', 'card']).default('cash'),
  notes: z.string().max(1000).optional().nullable(),
  clientUuid: uuid.optional().nullable(),
});

export const purchaseReturnItemSchema = z.object({
  purchaseItemId: uuid,
  quantity: z.number().int().positive(),
  reason: z.string().trim().max(500).optional().nullable(),
});

export const purchaseReturnSchema = z.object({
  items: z.array(purchaseReturnItemSchema).min(1),
});

export const supplierPaymentSchema = z.object({
  amount: z.number().int().positive(),
  method: z.enum(['cash', 'jazzcash', 'easypaisa', 'bank_transfer', 'card']).default('cash'),
  reference: z.string().trim().max(100).optional().nullable(),
  notes: z.string().max(500).optional().nullable(),
});

export const supplierSchema = z.object({
  name: z.string().trim().min(2).max(100),
  phone: z.string().trim().max(15).optional().nullable(),
  address: z.string().max(500).optional().nullable(),
  openingPayable: money.default(0),
});

export const updateSupplierSchema = supplierSchema.partial();
