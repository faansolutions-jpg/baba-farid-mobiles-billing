import { Router } from 'express';
import rateLimit from 'express-rate-limit';
import { env } from '../../config/env';
import { authenticate, requireOwner } from '../../middleware/auth';
import { validateBody } from '../../middleware/validate';
import { created, ok, paginated, parsePagination } from '../../utils/responses';
import * as service from './service';
import {
  changePasswordSchema,
  createUserSchema,
  loginSchema,
  refreshSchema,
  updateUserSchema,
} from './schemas';

const router = Router();

// 5 failed logins per 15 min per IP, then a temporary block.
const loginLimiter = rateLimit({
  windowMs: 15 * 60 * 1000,
  max: env.loginRateLimitMax,
  standardHeaders: true,
  legacyHeaders: false,
  message: { ok: false, error: { message: 'Too many login attempts, try again later', code: 'RATE_LIMITED' } },
});

router.post('/login', loginLimiter, validateBody(loginSchema), async (req, res, next) => {
  try {
    const data = await service.login(req.body.phone, req.body.password, req);
    ok(res, data);
  } catch (err) {
    next(err);
  }
});

router.post('/refresh', validateBody(refreshSchema), async (req, res, next) => {
  try {
    const data = await service.refresh(req.body.refreshToken);
    ok(res, data);
  } catch (err) {
    next(err);
  }
});

// Stateless JWT: the client discards both tokens. Documented in api.md.
router.post('/logout', authenticate, async (_req, res) => {
  ok(res, { message: 'Logged out. Discard the access and refresh tokens on the client.' });
});

router.get('/me', authenticate, async (req, res, next) => {
  try {
    ok(res, await service.getMe(req.user!.id));
  } catch (err) {
    next(err);
  }
});

router.post(
  '/change-password',
  authenticate,
  validateBody(changePasswordSchema),
  async (req, res, next) => {
    try {
      await service.changePassword(req.user!.id, req.body.currentPassword, req.body.newPassword);
      ok(res, { message: 'Password changed' });
    } catch (err) {
      next(err);
    }
  },
);

// ---- User management (owner only) ----
router.get('/users', authenticate, requireOwner, async (req, res, next) => {
  try {
    const { page, limit, offset } = parsePagination(req.query as Record<string, unknown>);
    void offset;
    const { rows, total } = await service.listUsers(page, limit);
    paginated(res, rows, { page, limit, offset }, total);
  } catch (err) {
    next(err);
  }
});

router.post('/users', authenticate, requireOwner, validateBody(createUserSchema), async (req, res, next) => {
  try {
    const data = await service.createUser(req.body, req.user!, req);
    created(res, data);
  } catch (err) {
    next(err);
  }
});

router.get('/users/:id', authenticate, requireOwner, async (req, res, next) => {
  try {
    ok(res, await service.getMe(req.params.id));
  } catch (err) {
    next(err);
  }
});

router.patch('/users/:id', authenticate, requireOwner, validateBody(updateUserSchema), async (req, res, next) => {
  try {
    const data = await service.updateUser(req.params.id, req.body, req.user!, req);
    ok(res, data);
  } catch (err) {
    next(err);
  }
});

router.delete('/users/:id', authenticate, requireOwner, async (req, res, next) => {
  try {
    await service.deactivateUser(req.params.id, req.user!, req);
    ok(res, { message: 'User deactivated' });
  } catch (err) {
    next(err);
  }
});

export default router;
