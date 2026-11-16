// Environment configuration. Fails fast on missing required secrets in
// production, but uses safe dev defaults locally so `npm run dev` works.
import 'dotenv/config';

function required(name: string, fallback?: string): string {
  const v = process.env[name] ?? fallback;
  if (!v && process.env.NODE_ENV === 'production') {
    throw new Error(`Missing required env var: ${name}`);
  }
  return v ?? '';
}

export const env = {
  port: Number(process.env.PORT ?? 3000),
  nodeEnv: process.env.NODE_ENV ?? 'development',
  databaseUrl:
    process.env.DATABASE_URL ??
    'postgres://shopuser:StrongPassword123@localhost:5432/shopdb',
  corsOrigin: (process.env.CORS_ORIGIN ?? '*')
    .split(',')
    .map((s) => s.trim())
    .filter(Boolean),
  jwtAccessSecret: required(
    'JWT_ACCESS_SECRET',
    'dev-access-secret-change-me-in-production-0123456789',
  ),
  jwtRefreshSecret: required(
    'JWT_REFRESH_SECRET',
    'dev-refresh-secret-change-me-in-production-0123456789',
  ),
  jwtAccessExpiresIn: process.env.JWT_ACCESS_EXPIRES_IN ?? '15m',
  jwtRefreshExpiresIn: process.env.JWT_REFRESH_EXPIRES_IN ?? '7d',
  bcryptRounds: Number(process.env.BCRYPT_ROUNDS ?? 12),
  loginRateLimitMax: Number(process.env.LOGIN_RATE_LIMIT_MAX ?? 5),
} as const;
