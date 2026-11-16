import { Router } from 'express';
import { authenticate, requireOwner, requireStaff } from '../../middleware/auth';
import { validateBody } from '../../middleware/validate';
import { created, ok, paginated, parsePagination } from '../../utils/responses';
import * as service from './service';
import {
  cashMovementSchema,
  closeRegisterSchema,
  expenseSchema,
  openRegisterSchema,
  salarySchema,
  staffSchema,
  updateExpenseSchema,
  updateStaffSchema,
} from './schemas';

const router = Router();
router.use(authenticate);

// ---- Expense categories (plain text list; no category table in the schema) ----
router.get('/expenses/categories', async (_req, res, next) => {
  try {
    ok(res, await service.listExpenseCategories());
  } catch (err) {
    next(err);
  }
});

// ---- Expenses ----
router.get('/expenses', async (req, res, next) => {
  try {
    const pagination = parsePagination(req.query as Record<string, unknown>);
    const { rows, total } = await service.listExpenses(
      {
        category: req.query.category as string | undefined,
        from: req.query.from as string | undefined,
        to: req.query.to as string | undefined,
      },
      pagination,
    );
    paginated(res, rows, pagination, total);
  } catch (err) {
    next(err);
  }
});

router.post('/expenses', validateBody(expenseSchema), async (req, res, next) => {
  try {
    created(res, await service.createExpense(req.body, req.user!, req));
  } catch (err) {
    next(err);
  }
});

router.get('/expenses/:id', async (req, res, next) => {
  try {
    ok(res, await service.getExpense(req.params.id));
  } catch (err) {
    next(err);
  }
});

router.patch('/expenses/:id', validateBody(updateExpenseSchema), async (req, res, next) => {
  try {
    ok(res, await service.updateExpense(req.params.id, req.body, req.user!, req));
  } catch (err) {
    next(err);
  }
});

router.delete('/expenses/:id', requireOwner, async (req, res, next) => {
  try {
    await service.deleteExpense(req.params.id, req.user!, req);
    ok(res, { message: 'Expense deleted' });
  } catch (err) {
    next(err);
  }
});

// ---- Staff ----
router.get('/staff', requireStaff, async (req, res, next) => {
  try {
    const pagination = parsePagination(req.query as Record<string, unknown>);
    const { rows, total } = await service.listStaff(pagination);
    paginated(res, rows, pagination, total);
  } catch (err) {
    next(err);
  }
});

router.post('/staff', requireStaff, validateBody(staffSchema), async (req, res, next) => {
  try {
    created(res, await service.createStaff(req.body, req.user!, req));
  } catch (err) {
    next(err);
  }
});

router.patch('/staff/:id', requireStaff, validateBody(updateStaffSchema), async (req, res, next) => {
  try {
    ok(res, await service.updateStaff(req.params.id, req.body, req.user!, req));
  } catch (err) {
    next(err);
  }
});

// ---- Salaries ----
router.get('/salaries', requireStaff, async (req, res, next) => {
  try {
    const pagination = parsePagination(req.query as Record<string, unknown>);
    const { rows, total } = await service.listSalaries(
      req.query.month as string | undefined,
      pagination,
    );
    paginated(res, rows, pagination, total);
  } catch (err) {
    next(err);
  }
});

router.post('/salaries', requireOwner, validateBody(salarySchema), async (req, res, next) => {
  try {
    created(res, await service.paySalary(req.body, req.user!, req));
  } catch (err) {
    next(err);
  }
});

// ---- Cash register ----
router.get('/cash-register/today', async (req, res, next) => {
  try {
    const branchId = req.user!.branchId ?? '';
    const register = branchId ? await service.getTodayRegister(branchId) : null;
    ok(res, register);
  } catch (err) {
    next(err);
  }
});

router.post('/cash-register/open', validateBody(openRegisterSchema), async (req, res, next) => {
  try {
    created(res, await service.openRegister(req.body, req.user!, req));
  } catch (err) {
    next(err);
  }
});

router.post('/cash-register/movements', validateBody(cashMovementSchema), async (req, res, next) => {
  try {
    created(res, await service.recordCashMovement(req.body, req.user!, req));
  } catch (err) {
    next(err);
  }
});

router.post('/cash-register/close', requireStaff, validateBody(closeRegisterSchema), async (req, res, next) => {
  try {
    ok(res, await service.closeRegister(req.body, req.user!, req));
  } catch (err) {
    next(err);
  }
});

router.get('/cash-register/day-summary', async (req, res, next) => {
  try {
    const branchId = req.user!.branchId;
    if (!branchId) {
      ok(res, { registerStatus: 'not_opened', expectedCash: 0 });
      return;
    }
    ok(res, await service.dayEndSummary(branchId));
  } catch (err) {
    next(err);
  }
});

export default router;
