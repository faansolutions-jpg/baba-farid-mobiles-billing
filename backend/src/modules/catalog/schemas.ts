// Accessories Master Catalog — Zod schemas.
// Wiring into app.ts happens after the Module 4 backend agent finishes —
// do not wire it here.
import { z } from 'zod';

const money = z.number().int().nonnegative();

export const catalogQuerySchema = z.object({
  search: z.string().trim().max(200).optional(),
  category: z.string().trim().max(100).optional(),
  brand: z.string().trim().max(100).optional(),
  page: z.coerce.number().int().min(1).default(1),
  limit: z.coerce.number().int().min(1).max(100).default(20),
});

export const stockInSchema = z.object({
  sku: z.string().trim().min(1).max(64),
  qty: z.number().int().positive().max(100_000),
  price: money.optional(),
  supplier: z.string().trim().max(200).optional(),
  date: z.string().datetime().optional(),
});

export const bulkStockInSchema = z.object({
  items: z
    .array(
      z.object({
        sku: z.string().trim().min(1).max(64),
        qty: z.number().int().positive().max(100_000),
      }),
    )
    .min(1)
    .max(1000),
  price: money.optional(),
  supplier: z.string().trim().max(200).optional(),
  date: z.string().datetime().optional(),
});

export const barcodeLinkSchema = z.object({
  barcode: z.string().trim().min(1).max(64),
  sku: z.string().trim().min(1).max(64),
});

export const customItemSchema = z.object({
  sku: z
    .string()
    .trim()
    .min(1)
    .max(64)
    .regex(/^[A-Za-z0-9-]+$/, 'SKU may only contain letters, numbers and hyphens'),
  category: z.string().trim().min(1).max(100),
  brand: z.string().trim().min(1).max(100),
  nameEn: z.string().trim().min(1).max(200),
  nameUr: z.string().trim().max(200).optional().nullable(),
  modelCompatibility: z.string().trim().max(200).optional().nullable(),
  colors: z.array(z.string().trim().max(64)).max(20).default([]),
  variants: z.array(z.string().trim().max(64)).max(20).default([]),
  purchasePriceEst: money.default(0),
  salePriceEst: money.default(0),
  minPrice: money.default(0),
  unit: z.string().trim().max(32).default('piece'),
  barcode: z.string().trim().max(64).optional().nullable(),
  lowStockThreshold: z.number().int().nonnegative().default(5),
});

export const stockCountSchema = z.object({
  sku: z.string().trim().min(1).max(64),
  countedQty: z.number().int().nonnegative().max(100_000),
  note: z.string().trim().max(500).default(''),
  countedBy: z.string().trim().max(100).optional(),
});

export const catalogImportRowSchema = z.object({
  sku: z.string().trim().min(1).max(64).optional(),
  nameEn: z.string().trim().min(1).max(200).optional(),
  category: z.string().trim().min(1).max(100).optional(),
  brand: z.string().trim().min(1).max(100).optional(),
  nameUr: z.string().trim().max(200).optional(),
  modelCompatibility: z.string().trim().max(200).optional(),
  purchasePriceEst: money.optional(),
  salePriceEst: money.optional(),
  minPrice: money.optional(),
  unit: z.string().trim().max(32).optional(),
  barcode: z.string().trim().max(64).optional(),
  qty: z.number().int().nonnegative().optional(),
  lowStockThreshold: z.number().int().nonnegative().optional(),
});

export const catalogImportSchema = z.object({
  rows: z.array(catalogImportRowSchema).min(1).max(5000),
  csv: z.string().max(5_000_000).optional(),
});
