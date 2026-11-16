import { Router } from 'express';
import { authenticate, requireOwner, requireStaff } from '../../middleware/auth';
import { validateBody } from '../../middleware/validate';
import { created, ok, paginated, parsePagination } from '../../utils/responses';
import * as service from './service';
import {
  brandSchema,
  categorySchema,
  imeiSchema,
  imeiStatusSchema,
  importSchema,
  productSchema,
  updateProductSchema,
  updateVariantSchema,
  variantSchema,
} from './schemas';

const router = Router();
router.use(authenticate);

// ---- Products ----
router.get('/products', async (req, res, next) => {
  try {
    const pagination = parsePagination(req.query as Record<string, unknown>);
    const { rows, total } = await service.listProducts(
      {
        search: req.query.search as string | undefined,
        type: req.query.type as string | undefined,
        brandId: req.query.brandId as string | undefined,
        categoryId: req.query.categoryId as string | undefined,
        isActive: req.query.isActive === undefined ? undefined : req.query.isActive === 'true',
      },
      pagination,
      req.user!.role,
    );
    paginated(res, rows, pagination, total);
  } catch (err) {
    next(err);
  }
});

router.get('/products/low-stock', async (req, res, next) => {
  try {
    ok(res, await service.lowStock(req.user!.role));
  } catch (err) {
    next(err);
  }
});

router.get('/products/export', requireStaff, async (req, res, next) => {
  try {
    const csv = await service.exportCsv(req.user!.role);
    res.header('Content-Type', 'text/csv');
    res.attachment('products-export.csv');
    res.send(csv);
  } catch (err) {
    next(err);
  }
});

router.post('/products/import', requireStaff, validateBody(importSchema), async (req, res, next) => {
  try {
    const result = await service.importProducts(req.body, req.user!, req);
    created(res, result);
  } catch (err) {
    next(err);
  }
});

router.get('/products/:id', async (req, res, next) => {
  try {
    ok(res, await service.getProduct(req.params.id, req.user!.role));
  } catch (err) {
    next(err);
  }
});

router.post('/products', requireStaff, validateBody(productSchema), async (req, res, next) => {
  try {
    created(res, await service.createProduct(req.body, req.user!, req));
  } catch (err) {
    next(err);
  }
});

router.patch('/products/:id', requireStaff, validateBody(updateProductSchema), async (req, res, next) => {
  try {
    ok(res, await service.updateProduct(req.params.id, req.body, req.user!, req));
  } catch (err) {
    next(err);
  }
});

router.delete('/products/:id', requireStaff, async (req, res, next) => {
  try {
    await service.deactivateProduct(req.params.id, req.user!, req);
    ok(res, { message: 'Product deactivated' });
  } catch (err) {
    next(err);
  }
});

// ---- Variants ----
router.post(
  '/products/:id/variants',
  requireStaff,
  validateBody(variantSchema),
  async (req, res, next) => {
    try {
      created(res, await service.createVariant(req.params.id, req.body, req.user!, req));
    } catch (err) {
      next(err);
    }
  },
);

router.patch('/variants/:id', requireStaff, validateBody(updateVariantSchema), async (req, res, next) => {
  try {
    ok(res, await service.updateVariant(req.params.id, req.body, req.user!, req));
  } catch (err) {
    next(err);
  }
});

router.delete('/variants/:id', requireStaff, async (req, res, next) => {
  try {
    await service.deactivateVariant(req.params.id, req.user!, req);
    ok(res, { message: 'Variant deactivated' });
  } catch (err) {
    next(err);
  }
});

// ---- IMEI items ----
router.get('/imei', async (req, res, next) => {
  try {
    const pagination = parsePagination(req.query as Record<string, unknown>);
    const { rows, total } = await service.listImei(
      {
        status: req.query.status as string | undefined,
        productId: req.query.productId as string | undefined,
        search: req.query.search as string | undefined,
      },
      pagination,
      req.user!.role,
    );
    paginated(res, rows, pagination, total);
  } catch (err) {
    next(err);
  }
});

router.get('/imei/:imei', async (req, res, next) => {
  try {
    ok(res, await service.getImeiByNumber(req.params.imei, req.user!.role));
  } catch (err) {
    next(err);
  }
});

router.post('/imei', requireStaff, validateBody(imeiSchema), async (req, res, next) => {
  try {
    created(res, await service.createImei(req.body, req.user!, req));
  } catch (err) {
    next(err);
  }
});

router.patch('/imei/:id/status', requireStaff, validateBody(imeiStatusSchema), async (req, res, next) => {
  try {
    ok(res, await service.updateImeiStatus(req.params.id, req.body.status, req.user!, req));
  } catch (err) {
    next(err);
  }
});

// ---- Brands & categories ----
router.get('/brands', async (_req, res, next) => {
  try {
    ok(res, await service.listBrands());
  } catch (err) {
    next(err);
  }
});

router.post('/brands', requireStaff, validateBody(brandSchema), async (req, res, next) => {
  try {
    created(res, await service.createBrand(req.body.name, req.user!, req));
  } catch (err) {
    next(err);
  }
});

router.get('/categories', async (_req, res, next) => {
  try {
    ok(res, await service.listCategories());
  } catch (err) {
    next(err);
  }
});

router.post('/categories', requireStaff, validateBody(categorySchema), async (req, res, next) => {
  try {
    created(res, await service.createCategory(req.body, req.user!, req));
  } catch (err) {
    next(err);
  }
});

export default router;
