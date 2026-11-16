import { Router } from 'express';
import { authenticate, requireStaff } from '../../middleware/auth';
import { validateBody } from '../../middleware/validate';
import { created, ok, paginated, parsePagination } from '../../utils/responses';
import * as service from './service';
import {
  createPurchaseSchema,
  purchaseReturnSchema,
  supplierPaymentSchema,
  supplierSchema,
  updateSupplierSchema,
} from './schemas';

const router = Router();
router.use(authenticate);

// ---- Purchases (owner/manager) ----
router.post('/purchases', requireStaff, validateBody(createPurchaseSchema), async (req, res, next) => {
  try {
    created(res, await service.createPurchase(req.body, req.user!, req));
  } catch (err) {
    next(err);
  }
});

router.get('/purchases', requireStaff, async (req, res, next) => {
  try {
    const pagination = parsePagination(req.query as Record<string, unknown>);
    const { rows, total } = await service.listPurchases(
      {
        supplierId: req.query.supplierId as string | undefined,
        from: req.query.from as string | undefined,
        to: req.query.to as string | undefined,
        status: req.query.status as string | undefined,
      },
      pagination,
    );
    paginated(res, rows, pagination, total);
  } catch (err) {
    next(err);
  }
});

router.get('/purchases/:id', requireStaff, async (req, res, next) => {
  try {
    ok(res, await service.getPurchaseById(req.params.id));
  } catch (err) {
    next(err);
  }
});

router.post(
  '/purchases/:id/return',
  requireStaff,
  validateBody(purchaseReturnSchema),
  async (req, res, next) => {
    try {
      const data = await service.returnPurchase(req.params.id, req.body.items, req.user!, req);
      ok(res, data);
    } catch (err) {
      next(err);
    }
  },
);

router.post(
  '/purchases/:id/payments',
  requireStaff,
  validateBody(supplierPaymentSchema),
  async (req, res, next) => {
    try {
      const data = await service.paySupplier(req.params.id, req.body, req.user!, req);
      ok(res, data);
    } catch (err) {
      next(err);
    }
  },
);

// ---- Suppliers ----
router.get('/suppliers', requireStaff, async (req, res, next) => {
  try {
    const pagination = parsePagination(req.query as Record<string, unknown>);
    const { rows, total } = await service.listSuppliers(
      req.query.search as string | undefined,
      pagination,
    );
    paginated(res, rows, pagination, total);
  } catch (err) {
    next(err);
  }
});

router.post('/suppliers', requireStaff, validateBody(supplierSchema), async (req, res, next) => {
  try {
    created(res, await service.createSupplier(req.body, req.user!, req));
  } catch (err) {
    next(err);
  }
});

router.get('/suppliers/:id', requireStaff, async (req, res, next) => {
  try {
    ok(res, await service.getSupplier(req.params.id));
  } catch (err) {
    next(err);
  }
});

router.patch('/suppliers/:id', requireStaff, validateBody(updateSupplierSchema), async (req, res, next) => {
  try {
    ok(res, await service.updateSupplier(req.params.id, req.body, req.user!, req));
  } catch (err) {
    next(err);
  }
});

router.get('/suppliers/:id/ledger', requireStaff, async (req, res, next) => {
  try {
    const pagination = parsePagination(req.query as Record<string, unknown>);
    const data = await service.supplierLedger(req.params.id, pagination);
    const totalPages = Math.max(1, Math.ceil(data.total / pagination.limit));
    ok(res, data.rows, 200, {
      page: pagination.page,
      limit: pagination.limit,
      total: data.total,
      totalPages,
      payableBalance: data.balance,
    });
  } catch (err) {
    next(err);
  }
});

export default router;
