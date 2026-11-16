import { Router } from 'express';
import { authenticate } from '../../middleware/auth';
import { ok } from '../../utils/responses';
import * as service from './service';

const router = Router();
router.use(authenticate);

router.get('/reports/dashboard', async (req, res, next) => {
  try {
    ok(
      res,
      await service.dashboard(
        req.query.branchId as string | undefined,
        req.user!.branchId,
      ),
    );
  } catch (err) {
    next(err);
  }
});

router.get('/reports/sales', async (req, res, next) => {
  try {
    const groupBy = (req.query.groupBy as 'day' | 'week' | 'month') ?? 'day';
    ok(
      res,
      await service.salesByPeriod(
        req.query.branchId as string | undefined,
        req.user!.branchId,
        req.query.from as string | undefined,
        req.query.to as string | undefined,
        groupBy,
      ),
    );
  } catch (err) {
    next(err);
  }
});

router.get('/reports/profit-loss', async (req, res, next) => {
  try {
    const from = (req.query.from as string) ?? new Date().toISOString().slice(0, 7) + '-01';
    const to = (req.query.to as string) ?? new Date().toISOString().slice(0, 10);
    ok(
      res,
      await service.profitAndLoss(
        req.query.branchId as string | undefined,
        req.user!.branchId,
        from,
        to,
      ),
    );
  } catch (err) {
    next(err);
  }
});

router.get('/reports/stock-valuation', async (_req, res, next) => {
  try {
    ok(res, await service.stockValuation());
  } catch (err) {
    next(err);
  }
});

router.get('/reports/brand-model-sales', async (req, res, next) => {
  try {
    ok(
      res,
      await service.brandModelSales(
        req.query.branchId as string | undefined,
        req.user!.branchId,
        req.query.from as string | undefined,
        req.query.to as string | undefined,
      ),
    );
  } catch (err) {
    next(err);
  }
});

router.get('/reports/best-sellers', async (req, res, next) => {
  try {
    const limit = Math.min(100, Math.max(1, Number(req.query.limit ?? 10) || 10));
    ok(
      res,
      await service.bestSellers(
        req.query.branchId as string | undefined,
        req.user!.branchId,
        req.query.from as string | undefined,
        req.query.to as string | undefined,
        limit,
      ),
    );
  } catch (err) {
    next(err);
  }
});

router.get('/reports/dead-stock', async (req, res, next) => {
  try {
    const days = Math.max(1, Number(req.query.days ?? 90) || 90);
    ok(res, await service.deadStock(days));
  } catch (err) {
    next(err);
  }
});

router.get('/reports/pending-udhaar', async (_req, res, next) => {
  try {
    ok(res, await service.pendingUdhaar());
  } catch (err) {
    next(err);
  }
});

router.get('/reports/supplier-payables', async (_req, res, next) => {
  try {
    ok(res, await service.supplierPayables());
  } catch (err) {
    next(err);
  }
});

router.get('/reports/imei/:imei', async (req, res, next) => {
  try {
    ok(res, await service.imeiHistory(req.params.imei));
  } catch (err) {
    next(err);
  }
});

export default router;
