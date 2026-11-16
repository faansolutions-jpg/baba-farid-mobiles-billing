// API tests (supertest against the Express app).
// These tests do NOT need a live database: they cover the health endpoint,
// the auth guard (401 without a token) and Zod request validation (400 on
// bad bodies) — all of which run before any DB access. Full DB-backed
// flows (create a bill, pay a supplier, close the register) need a test
// database; see docs/api.md "Testing" for how to run those.
import request from 'supertest';
import { describe, expect, it } from 'vitest';
import app from '../src/app';
import { env } from '../src/config/env';

describe('GET /health', () => {
  it('responds 200 with status up', async () => {
    const res = await request(app).get('/health');
    expect(res.status).toBe(200);
    expect(res.body.ok).toBe(true);
    expect(res.body.data.status).toBe('up');
  });
});

describe('auth guard', () => {
  it('rejects /api/v1/products without a token', async () => {
    const res = await request(app).get('/api/v1/products');
    expect(res.status).toBe(401);
    expect(res.body.ok).toBe(false);
    expect(res.body.error.code).toBe('UNAUTHORIZED');
  });

  it('rejects /api/v1/sales without a token', async () => {
    const res = await request(app).get('/api/v1/sales');
    expect(res.status).toBe(401);
  });

  it('rejects /api/v1/reports/dashboard without a token', async () => {
    const res = await request(app).get('/api/v1/reports/dashboard');
    expect(res.status).toBe(401);
  });

  it('rejects a malformed Bearer token', async () => {
    const res = await request(app)
      .get('/api/v1/products')
      .set('Authorization', 'Bearer not-a-real-token');
    expect(res.status).toBe(401);
  });
});

describe('request validation (Zod)', () => {
  it('rejects a login with a missing password', async () => {
    const res = await request(app)
      .post('/api/v1/login')
      .send({ phone: '03299966771' });
    // Validation runs before the DB, so this is a 400 even with no database.
    expect(res.status).toBe(400);
    expect(res.body.ok).toBe(false);
    expect(res.body.error.code).toBe('BAD_REQUEST');
  });

  it('rejects a login with a bad phone format', async () => {
    const res = await request(app)
      .post('/api/v1/login')
      .send({ phone: 'abc', password: 'x' });
    expect(res.status).toBe(400);
  });

  it('rejects a sale with no items', async () => {
    // A valid JWT is needed to reach validation; sign with the app's
    // configured access secret (dev fallback or the real .env secret).
    const jwt = await import('jsonwebtoken');
    const token = jwt.sign(
      {
        sub: '00000000-0000-0000-0000-000000000000',
        name: 'Test',
        phone: '03000000000',
        role: 'cashier',
        branchId: null,
        type: 'access',
      },
      env.jwtAccessSecret,
      { expiresIn: '15m' },
    );
    const res = await request(app)
      .post('/api/v1/sales')
      .set('Authorization', `Bearer ${token}`)
      .send({ items: [], paymentMethod: 'cash', paidAmount: 0 });
    expect(res.status).toBe(400);
    expect(res.body.ok).toBe(false);
  });
});

describe('unknown routes', () => {
  it('returns 401 without a token (auth runs before route matching)', async () => {
    const res = await request(app).get('/api/v1/no-such-route');
    expect(res.status).toBe(401);
    expect(res.body.ok).toBe(false);
  });

  it('returns the standard 404 envelope for an authenticated request', async () => {
    const jwt = await import('jsonwebtoken');
    const token = jwt.sign(
      {
        sub: '00000000-0000-0000-0000-000000000000',
        name: 'Test',
        phone: '03000000000',
        role: 'cashier',
        branchId: null,
        type: 'access',
      },
      env.jwtAccessSecret,
      { expiresIn: '15m' },
    );
    const res = await request(app)
      .get('/api/v1/no-such-route')
      .set('Authorization', `Bearer ${token}`);
    expect(res.status).toBe(404);
    expect(res.body.ok).toBe(false);
    expect(res.body.error.code).toBe('NOT_FOUND');
  });
});
