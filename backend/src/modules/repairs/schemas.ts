import { z } from 'zod';

const money = z.number().int().nonnegative();
const uuid = z.string().uuid();

// repair_status enum in the schema: received, in_progress, ready, delivered, cancelled.
export const REPAIR_STATUSES = [
  'received',
  'in_progress',
  'ready',
  'delivered',
  'cancelled',
] as const;

export const repairSchema = z.object({
  customerId: uuid.optional().nullable(),
  customerName: z.string().trim().min(2).max(100).optional().nullable(),
  customerPhone: z.string().trim().min(10).max(15).optional().nullable(),
  deviceBrand: z.string().trim().max(50).optional().nullable(),
  deviceModel: z.string().trim().max(100).optional().nullable(),
  imei: z.string().trim().max(17).optional().nullable(),
  faultDescription: z.string().trim().min(3).max(1000),
  estimatedCost: money.optional(),
  advancePaid: money.default(0),
  notes: z.string().max(1000).optional().nullable(),
}).refine(
  (v) => v.customerId || (v.customerName && v.customerPhone),
  { message: 'Provide either a registered customerId or a walk-in customerName + customerPhone' },
);

export const updateRepairSchema = z.object({
  deviceBrand: z.string().trim().max(50).optional().nullable(),
  deviceModel: z.string().trim().max(100).optional().nullable(),
  imei: z.string().trim().max(17).optional().nullable(),
  faultDescription: z.string().trim().min(3).max(1000).optional(),
  estimatedCost: money.optional(),
  notes: z.string().max(1000).optional().nullable(),
  status: z.enum(['received', 'in_progress', 'ready', 'cancelled']).optional(),
});

export const repairPartSchema = z.object({
  productId: uuid,
  variantId: uuid,
  quantity: z.number().int().positive().default(1),
  unitPrice: money,
});

export const deliverRepairSchema = z.object({
  parts: z.array(repairPartSchema).optional().default([]),
  finalCost: money.optional(),
  paymentMethod: z.enum(['cash', 'jazzcash', 'easypaisa', 'bank_transfer', 'card']).default('cash'),
  notes: z.string().max(1000).optional().nullable(),
});

export const serviceSaleSchema = z.object({
  serviceType: z.enum(['easyload', 'recharge', 'bill_payment', 'other']),
  customerPhone: z.string().trim().max(15).optional().nullable(),
  provider: z.string().trim().max(50).optional().nullable(),
  amount: z.number().int().positive(),
  commission: money.default(0),
});
