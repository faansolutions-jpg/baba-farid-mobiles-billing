import { Router } from 'express';
import { authenticate } from '../../middleware/auth';
import { validateBody, validateQuery } from '../../middleware/validate';
import { ok } from '../../utils/responses';
import * as service from './service';
import { syncPullQuerySchema, syncPushSchema } from './schemas';

const router = Router();
router.use(authenticate);

// Push bills created offline (idempotent by client_uuid).
router.post('/sync/push', validateBody(syncPushSchema), async (req, res, next) => {
  try {
    const result = await service.pushSales(
      req.body.deviceId,
      req.body.sales ?? [],
      req.user!,
      req,
    );
    ok(res, result);
  } catch (err) {
    next(err);
  }
});

// Pull everything changed since a timestamp (server wins on conflict).
router.get('/sync/pull', validateQuery(syncPullQuerySchema), async (req, res, next) => {
  try {
    const result = await service.pullChanges(req.query.since as string | undefined);
    ok(res, result);
  } catch (err) {
    next(err);
  }
});

router.get('/sync/history', async (req, res, next) => {
  try {
    const limit = Math.min(100, Math.max(1, Number(req.query.limit ?? 20) || 20));
    ok(res, await service.syncHistory(req.query.deviceId as string | undefined, limit));
  } catch (err) {
    next(err);
  }
});

export default router;
