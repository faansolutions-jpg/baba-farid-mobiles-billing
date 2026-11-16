import { z } from 'zod';

const money = z.number().int().nonnegative();
const uuid = z.string().uuid();

export const productSchema = z.object({
  brandId: uuid.optional().nullable(),
  categoryId: uuid.optional().nullable(),
  type: z.enum(['phone', 'accessory']),
  name: z.string().trim().min(1).max(200),
  description: z.string().max(2000).optional().nullable(),
  barcode: z.string().trim().max(64).optional().nullable(),
  imageUrl: z.string().url().optional().nullable(),
});

export const updateProductSchema = productSchema.partial();

export const variantSchema = z.object({
  name: z.string().trim().min(1).max(200),
  color: z.string().trim().max(64).optional().nullable(),
  storageGb: z.number().int().positive().optional().nullable(),
  ramGb: z.number().int().positive().optional().nullable(),
  condition: z.enum(['new', 'used', 'open_box']).default('new'),
  ptaStatus: z.enum(['approved', 'non_pta', 'not_applicable']).default('not_applicable'),
  barcode: z.string().trim().max(64).optional().nullable(),
  purchasePrice: money,
  salePrice: money,
  minPrice: money.default(0),
  warrantyMonths: z.number().int().nonnegative().default(0),
  quantity: z.number().int().nonnegative().default(0),
  lowStockThreshold: z.number().int().nonnegative().default(3),
});

export const updateVariantSchema = variantSchema.partial();

export const imeiSchema = z.object({
  productId: uuid,
  variantId: uuid.optional().nullable(),
  imei1: z.string().trim().min(15).max(17),
  imei2: z.string().trim().min(15).max(17).optional().nullable(),
  purchasePrice: money,
  salePrice: money,
  purchaseId: uuid.optional().nullable(),
});

export const imeiStatusSchema = z.object({
  status: z.enum(['available', 'sold', 'reserved', 'returned', 'defective']),
});

export const brandSchema = z.object({
  name: z.string().trim().min(1).max(100),
});

export const categorySchema = z.object({
  name: z.string().trim().min(1).max(100),
  type: z.enum(['phone', 'accessory', 'service']),
  parentId: uuid.optional().nullable(),
});

/** One row of a bulk import (JSON array or parsed CSV row). */
export const importRowSchema = z.object({
  name: z.string().trim().min(1),
  type: z.enum(['phone', 'accessory']),
  brand: z.string().trim().min(1).optional(),
  category: z.string().trim().min(1).optional(),
  variantName: z.string().trim().min(1).optional(),
  color: z.string().trim().optional(),
  storageGb: z.number().int().positive().optional(),
  ramGb: z.number().int().positive().optional(),
  condition: z.enum(['new', 'used', 'open_box']).optional(),
  ptaStatus: z.enum(['approved', 'non_pta', 'not_applicable']).optional(),
  barcode: z.string().trim().optional(),
  purchasePrice: z.number().int().nonnegative().optional(),
  salePrice: z.number().int().nonnegative().optional(),
  minPrice: z.number().int().nonnegative().optional(),
  warrantyMonths: z.number().int().nonnegative().optional(),
  quantity: z.number().int().nonnegative().optional(),
  lowStockThreshold: z.number().int().nonnegative().optional(),
});

export const importSchema = z.object({
  rows: z.array(importRowSchema).min(1).max(5000),
});
