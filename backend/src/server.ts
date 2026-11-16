import app from './app';
import { env } from './config/env';
import { pool } from './config/db';
import { logger } from './utils/logger';

async function start(): Promise<void> {
  try {
    await pool.query('SELECT 1');
    logger.info('Database connected');
  } catch (err) {
    logger.error('Database connection failed — check DATABASE_URL', err);
    process.exit(1);
  }
  app.listen(env.port, () => {
    logger.info(
      `Baba Farid Mobiles API listening on port ${env.port} (${env.nodeEnv})`,
    );
    logger.info(`Health check: http://localhost:${env.port}/health`);
  });
}

process.on('SIGINT', async () => {
  await pool.end();
  process.exit(0);
});
process.on('SIGTERM', async () => {
  await pool.end();
  process.exit(0);
});

start();
