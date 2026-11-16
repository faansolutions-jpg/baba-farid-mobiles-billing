import express from 'express';
import cors from 'cors';
import helmet from 'helmet';
import authRoutes from './modules/auth/routes';
import productsRoutes from './modules/products/routes';
import salesRoutes from './modules/sales/routes';
import purchasesRoutes from './modules/purchases/routes';
import customersRoutes from './modules/customers/routes';
import repairsRoutes from './modules/repairs/routes';
import expensesRoutes from './modules/expenses/routes';
import reportsRoutes from './modules/reports/routes';
import settingsRoutes from './modules/settings/routes';
import syncRoutes from './modules/sync/routes';
import catalogRoutes from './modules/catalog/routes';
import { errorHandler, notFoundHandler } from './middleware/errorHandler';
import { env } from './config/env';
import { logger } from './utils/logger';

const app = express();

app.use(helmet());
app.use(
  cors({
    origin: env.corsOrigin.includes('*') ? true : env.corsOrigin,
    credentials: true,
  }),
);
app.use(express.json({ limit: '1mb' }));

// Tiny request log (morgan is not a dependency; this is enough).
app.use((req, _res, next) => {
  if (env.nodeEnv !== 'production') {
    logger.info(`${req.method} ${req.path}`);
  }
  next();
});

app.get('/health', (_req, res) => {
  res.json({ ok: true, data: { status: 'up', time: new Date().toISOString() } });
});

const api = express.Router();
api.use(authRoutes);
api.use(productsRoutes);
api.use(salesRoutes);
api.use(purchasesRoutes);
api.use(customersRoutes);
api.use(repairsRoutes);
api.use(expensesRoutes);
api.use(reportsRoutes);
api.use(settingsRoutes);
api.use(syncRoutes);
api.use('/catalog', catalogRoutes);
app.use('/api/v1', api);

app.use(notFoundHandler);
app.use(errorHandler);

export default app;
