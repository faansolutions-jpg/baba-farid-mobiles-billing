import { Router } from 'express';
import { authenticate, requireOwner, requireStaff } from '../../middleware/auth';
import { validateBody } from '../../middleware/validate';
import { created, ok, paginated, parsePagination } from '../../utils/responses';
import * as service from './service';
import {
  createSaleSchema,
  holdBillSchema,
  returnSaleSchema,
  salePaymentSchema,
} from './schemas';

const router = Router();
router.use(authenticate);

// Create a bill (cashier and above).
router.post('/sales', validateBody(createSaleSchema), async (req, res, next) => {
  try {
    created(res, await service.createSale(req.body, req.user!, req));
  } catch (err) {
    next(err);
  }
});

router.get('/sales', async (req, res, next) => {
  try {
    const pagination = parsePagination(req.query as Record<string, unknown>);
    const { rows, total } = await service.listSales(
      {
        from: req.query.from as string | undefined,
        to: req.query.to as string | undefined,
        customerId: req.query.customerId as string | undefined,
        status: req.query.status as string | undefined,
        paymentStatus: req.query.paymentStatus as string | undefined,
        branchId: req.query.branchId as string | undefined,
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

// ---- Held bills (defined before /sales/:id so 'hold' is not treated as an id) ----
router.post('/sales/hold', validateBody(holdBillSchema), async (req, res, next) => {
  try {
    created(res, await service.holdBill(req.body, req.user!));
  } catch (err) {
    next(err);
  }
});

router.get('/sales/hold', async (req, res, next) => {
  try {
    ok(res, await service.listHeldBills(req.user!));
  } catch (err) {
    next(err);
  }
});

router.post('/sales/hold/:id/resume', async (req, res, next) => {
  try {
    ok(res, await service.resumeHeldBill(req.params.id));
  } catch (err) {
    next(err);
  }
});

router.delete('/sales/hold/:id', async (req, res, next) => {
  try {
    await service.deleteHeldBill(req.params.id);
    ok(res, { message: 'Held bill deleted' });
  } catch (err) {
    next(err);
  }
});

router.get('/sales/:id', async (req, res, next) => {
  try {
    ok(res, await service.getSaleById(req.params.id, req.user!.role));
  } catch (err) {
    next(err);
  }
});

router.get('/sales/:id/invoice', async (req, res, next) => {
  try {
    ok(res, await service.getInvoiceData(req.params.id, req.user!.role));
  } catch (err) {
    next(err);
  }
});

// Return items (and optionally link an exchange bill).
router.post('/sales/:id/return', requireStaff, validateBody(returnSaleSchema), async (req, res, next) => {
  try {
    const data = await service.returnSale(req.params.id, req.body.items, req.user!, {
      exchangeSaleId: req.body.exchangeSaleId ?? null,
      req,
    });
    ok(res, data);
  } catch (err) {
    next(err);
  }
});

// Cancel a whole bill (owner only — matches the seeded role permissions:
// manager has sales.cancel = false).
router.post('/sales/:id/cancel', requireOwner, async (req, res, next) => {
  try {
    const data = await service.cancelSale(req.params.id, req.user!, req);
    ok(res, data);
  } catch (err) {
    next(err);
  }
});

// Record a payment against the bill's remaining balance (udhaar recovery).
router.post('/sales/:id/payments', validateBody(salePaymentSchema), async (req, res, next) => {
  try {
    const data = await service.recordSalePayment(req.params.id, req.body, req.user!, req);
    ok(res, data);
  } catch (err) {
    next(err);
  }
});

export default router;
