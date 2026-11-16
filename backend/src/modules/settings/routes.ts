import { Router } from 'express';
import { authenticate, requireOwner } from '../../middleware/auth';
import { validateBody } from '../../middleware/validate';
import { ok } from '../../utils/responses';
import * as service from './service';
import { updateShopProfileSchema } from './schemas';

const router = Router();
router.use(authenticate);

router.get('/settings', async (_req, res, next) => {
  try {
    ok(res, await service.getSettings());
  } catch (err) {
    next(err);
  }
});

router.patch('/settings', requireOwner, validateBody(updateShopProfileSchema), async (req, res, next) => {
  try {
    ok(res, await service.updateSettings(req.body, req.user!, req));
  } catch (err) {
    next(err);
  }
});

export default router;
