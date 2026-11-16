import { z } from 'zod';

const money = z.number().int().nonnegative();
const uuid = z.string().uuid();

// A sale created offline on the phone. Mirrors the server's createSale
// input, except phones are identified by their IMEI number (the phone does
// not know the server-side imei_item UUID — the sync service resolves it).
export const syncSaleItemSchema = z.object({
  variantId: uuid,
  imei1: z.string().trim().min(15).max(17).optional().nullable(),
  quantity: z.number().int().positive().default(1),
  unitPrice: money,
  discount: money.default(0),
});

export const syncSaleSchema = z.object({
  clientUuid: uuid,
  customerId: uuid.optional().nullable(),
  customerName: z.string().trim().max(100).optional().nullable(),
  customerPhone: z.string().trim().max(15).optional().nullable(),
  items: z.array(syncSaleItemSchema).min(1).max(100),
  discountAmount: money.default(0),
  discountPercent: z.number().min(0).max(100).default(0),
  taxAmount: money.default(0),
  paidAmount: money,
  paymentMethod: z
    .enum(['cash', 'jazzcash', 'easypaisa', 'bank_transfer', 'card', 'partial', 'udhaar'])
    .default('cash'),
  notes: z.string().max(1000).optional().nullable(),
  adminApprovedBy: uuid.optional().nullable(),
});

export const syncPushSchema = z.object({
  deviceId: z.string().trim().min(3).max(100),
  sales: z.array(syncSaleSchema).max(200).default([]),
});

export const syncPullQuerySchema = z.object({
  since: z.string().datetime({ offset: true }).optional(),
  deviceId: z.string().trim().min(3).max(100).optional(),
});
