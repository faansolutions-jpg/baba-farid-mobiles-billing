import { z } from 'zod';

// The settings table is key/value (settings.key TEXT PK, settings.value JSONB).
// Seeded keys: shop.name, shop.address, shop.phone, shop.phone2, shop.email,
// shop.currency, tax.enabled, tax.rate. This schema maps friendly field
// names to those keys (and accepts new ones: shop.whatsapp, shop.tax_number,
// shop.logo_url, invoice.prefix, invoice.footer, shop.language, shop.timezone).
export const shopProfileSchema = z.object({
  shopName: z.string().trim().min(2).max(100),
  address: z.string().trim().max(500).optional().nullable(),
  phone: z.string().trim().max(20).optional().nullable(),
  phone2: z.string().trim().max(20).optional().nullable(),
  email: z.string().email().optional().nullable(),
  whatsapp: z.string().trim().max(20).optional().nullable(),
  taxNumber: z.string().trim().max(50).optional().nullable(),
  logoUrl: z.string().url().optional().nullable(),
  invoicePrefix: z.string().trim().max(20).optional(),
  invoiceFooter: z.string().max(500).optional().nullable(),
  taxEnabled: z.boolean().optional(),
  defaultTaxRate: z.number().min(0).max(100).optional(),
  currency: z.string().trim().max(10).optional(),
  language: z.enum(['en', 'ur']).optional(),
  timezone: z.string().trim().max(50).optional(),
});

export const updateShopProfileSchema = shopProfileSchema.partial();
