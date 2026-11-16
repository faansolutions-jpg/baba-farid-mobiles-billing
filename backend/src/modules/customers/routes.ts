import { Router } from 'express';
import { authenticate } from '../../middleware/auth';
import { validateBody } from '../../middleware/validate';
import { created, ok, paginated, parsePagination } from '../../utils/responses';
import * as service from './service';
import {
  customerSchema,
  installmentPaymentSchema,
  installmentSchema,
  updateCustomerSchema,
} from './schemas';

const router = Router();
router.use(authenticate);

// ---- Customers ----
router.get('/customers', async (req, res, next) => {
  try {
    const pagination = parsePagination(req.query as Record<string, unknown>);
    const { rows, total } = await service.listCustomers(
      req.query.search as string | undefined,
      pagination,
    );
    paginated(res, rows, pagination, total);
  } catch (err) {
    next(err);
  }
});

router.post('/customers', validateBody(customerSchema), async (req, res, next) => {
  try {
    created(res, await service.createCustomer(req.body, req.user!, req));
  } catch (err) {
    next(err);
  }
});

router.get('/customers/:id', async (req, res, next) => {
  try {
    ok(res, await service.getCustomer(req.params.id));
  } catch (err) {
    next(err);
  }
});

router.patch('/customers/:id', validateBody(updateCustomerSchema), async (req, res, next) => {
  try {
    ok(res, await service.updateCustomer(req.params.id, req.body, req.user!, req));
  } catch (err) {
    next(err);
  }
});

router.delete('/customers/:id', async (req, res, next) => {
  try {
    await service.deactivateCustomer(req.params.id, req.user!, req);
    ok(res, { message: 'Customer deactivated' });
  } catch (err) {
    next(err);
  }
});

// ---- Ledger statement ----
router.get('/customers/:id/ledger', async (req, res, next) => {
  try {
    const pagination = parsePagination(req.query as Record<string, unknown>);
    const data = await service.customerLedger(req.params.id, pagination);
    const totalPages = Math.max(1, Math.ceil(data.total / pagination.limit));
    ok(res, data.rows, 200, {
      page: pagination.page,
      limit: pagination.limit,
      total: data.total,
      totalPages,
      balance: data.balance,
    });
  } catch (err) {
    next(err);
  }
});

// ---- Installments ----
router.get('/customers/:id/installments', async (req, res, next) => {
  try {
    ok(res, await service.listCustomerInstallments(req.params.id));
  } catch (err) {
    next(err);
  }
});

router.post('/installments', validateBody(installmentSchema), async (req, res, next) => {
  try {
    created(res, await service.createInstallment(req.body, req.user!, req));
  } catch (err) {
    next(err);
  }
});

router.get('/installments/overdue', async (req, res, next) => {
  try {
    ok(res, await service.overdueInstallments());
  } catch (err) {
    next(err);
  }
});

router.get('/installments/:id', async (req, res, next) => {
  try {
    ok(res, await service.getInstallment(req.params.id));
  } catch (err) {
    next(err);
  }
});

router.post(
  '/installments/:id/payments',
  validateBody(installmentPaymentSchema),
  async (req, res, next) => {
    try {
      const data = await service.payInstallment(req.params.id, req.body, req.user!, req);
      ok(res, data);
    } catch (err) {
      next(err);
    }
  },
);

export default router;
