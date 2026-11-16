import { Router } from 'express';
import { authenticate, requireStaff } from '../../middleware/auth';
import { validateBody } from '../../middleware/validate';
import { created, ok, paginated, parsePagination } from '../../utils/responses';
import * as service from './service';
import {
  deliverRepairSchema,
  repairPartSchema,
  repairSchema,
  serviceSaleSchema,
  updateRepairSchema,
} from './schemas';

const router = Router();
router.use(authenticate);

router.post('/repairs', validateBody(repairSchema), async (req, res, next) => {
  try {
    created(res, await service.createRepair(req.body, req.user!, req));
  } catch (err) {
    next(err);
  }
});

router.get('/repairs', async (req, res, next) => {
  try {
    const pagination = parsePagination(req.query as Record<string, unknown>);
    const { rows, total } = await service.listRepairs(
      {
        status: req.query.status as string | undefined,
        customerId: req.query.customerId as string | undefined,
        search: req.query.search as string | undefined,
      },
      pagination,
    );
    paginated(res, rows, pagination, total);
  } catch (err) {
    next(err);
  }
});

router.get('/repairs/:id', async (req, res, next) => {
  try {
    ok(res, await service.getRepair(req.params.id));
  } catch (err) {
    next(err);
  }
});

router.patch('/repairs/:id', validateBody(updateRepairSchema), async (req, res, next) => {
  try {
    ok(res, await service.updateRepair(req.params.id, req.body, req.user!, req));
  } catch (err) {
    next(err);
  }
});

router.post('/repairs/:id/cancel', requireStaff, async (req, res, next) => {
  try {
    ok(res, await service.cancelRepair(req.params.id, req.user!, req));
  } catch (err) {
    next(err);
  }
});

router.post(
  '/repairs/:id/parts',
  validateBody(repairPartSchema),
  async (req, res, next) => {
    try {
      const data = await service.addRepairPart(req.params.id, req.body, req.user!, req);
      ok(res, data);
    } catch (err) {
      next(err);
    }
  },
);

router.post(
  '/repairs/:id/deliver',
  validateBody(deliverRepairSchema),
  async (req, res, next) => {
    try {
      const data = await service.deliverRepair(req.params.id, req.body, req.user!, req);
      ok(res, data);
    } catch (err) {
      next(err);
    }
  },
);

// ---- Service sales (easyload / recharge / bill payment) ----
router.get('/service-sales', async (req, res, next) => {
  try {
    const pagination = parsePagination(req.query as Record<string, unknown>);
    const { rows, total } = await service.listServiceSales(
      {
        serviceType: req.query.serviceType as string | undefined,
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

router.post('/service-sales', validateBody(serviceSaleSchema), async (req, res, next) => {
  try {
    created(res, await service.createServiceSale(req.body, req.user!, req));
  } catch (err) {
    next(err);
  }
});

export default router;
