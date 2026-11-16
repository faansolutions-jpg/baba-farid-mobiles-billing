// Accessories Master Catalog routes.
// Wiring into app.ts happens after the Module 4 backend agent finishes —
// do not wire it here.
//
// Mount (later, in app.ts): app.use('/api/v1/catalog', catalogRouter)
// and set `router` paths below relative to that mount, e.g.
// GET /api/v1/catalog, GET /api/v1/catalog/:sku, ...
import { Router } from 'express';
import { authenticate, requireStaff } from '../../middleware/auth';
import { validateBody, validateQuery } from '../../middleware/validate';
import { created, ok, paginated, parsePagination } from '../../utils/responses';
import * as service from './service';
import {
  barcodeLinkSchema,
  bulkStockInSchema,
  catalogImportSchema,
  catalogQuerySchema,
  customItemSchema,
  stockCountSchema,
  stockInSchema,
} from './schemas';

const router = Router();
router.use(authenticate);

// ---- Reads (all roles; cost prices are stripped for cashiers) ----
router.get('/', validateQuery(catalogQuerySchema), async (req, res, next) => {
  try {
    const pagination = parsePagination(req.query as Record<string, unknown>);
    const { rows, total } = await service.listCatalog(
      {
        search: req.query.search as string | undefined,
        category: req.query.category as string | undefined,
        brand: req.query.brand as string | undefined,
      },
      pagination,
      req.user!.role,
    );
    paginated(res, rows, pagination, total);
  } catch (err) {
    next(err);
  }
});

router.get('/low-stock', async (req, res, next) => {
  try {
    ok(res, await service.lowStock(req.user!.role));
  } catch (err) {
    next(err);
  }
});

router.get('/reorder-list', async (req, res, next) => {
  try {
    ok(res, await service.reorderList(req.user!.role));
  } catch (err) {
    next(err);
  }
});

router.get('/version', async (_req, res, next) => {
  try {
    ok(res, await service.catalogVersion());
  } catch (err) {
    next(err);
  }
});

router.get('/barcode/:barcode', async (req, res, next) => {
  try {
    ok(res, await service.byBarcode(req.params.barcode, req.user!.role));
  } catch (err) {
    next(err);
  }
});

router.get('/:sku', async (req, res, next) => {
  try {
    ok(res, await service.getCatalogItem(req.params.sku, req.user!.role));
  } catch (err) {
    next(err);
  }
});

// ---- Writes (staff only: owner / manager) ----
router.post('/stock-in', requireStaff, validateBody(stockInSchema), async (req, res, next) => {
  try {
    created(res, await service.stockIn(req.body, req.user!, req));
  } catch (err) {
    next(err);
  }
});

router.post(
  '/bulk-stock-in',
  requireStaff,
  validateBody(bulkStockInSchema),
  async (req, res, next) => {
    try {
      created(res, await service.bulkStockIn(req.body, req.user!, req));
    } catch (err) {
      next(err);
    }
  },
);

router.post(
  '/barcode-link',
  requireStaff,
  validateBody(barcodeLinkSchema),
  async (req, res, next) => {
    try {
      created(res, await service.linkBarcode(req.body.barcode, req.body.sku, req.user!, req));
    } catch (err) {
      next(err);
    }
  },
);

router.post('/custom-item', requireStaff, validateBody(customItemSchema), async (req, res, next) => {
  try {
    created(res, await service.createCustomItem(req.body, req.user!, req));
  } catch (err) {
    next(err);
  }
});

router.post(
  '/stock-count',
  requireStaff,
  validateBody(stockCountSchema),
  async (req, res, next) => {
    try {
      created(res, await service.recordStockCount(req.body, req.user!, req));
    } catch (err) {
      next(err);
    }
  },
);

router.post('/import', requireStaff, validateBody(catalogImportSchema), async (req, res, next) => {
  try {
    created(res, await service.importCatalog(req.body, req.user!, req));
  } catch (err) {
    next(err);
  }
});

export default router;
