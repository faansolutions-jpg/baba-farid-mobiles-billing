// Auth + user management service.
// Passwords: bcryptjs, cost factor 12 (spec). Same API as bcrypt, pure JS
// so `npm install` needs no native build tools on Windows.
// Tokens: stateless JWT. Access 15 min, refresh 7 days. Logout is
// client-side token discard (no refresh-token table in the schema);
// a stolen refresh token dies at its 7-day expiry.
import bcrypt from 'bcryptjs';
import jwt from 'jsonwebtoken';
import { env } from '../../config/env';
import { query, withTransaction } from '../../config/db';
import { ApiError, notFound, unauthorized } from '../../middleware/errors';
import { signAccessToken, signRefreshToken, RefreshTokenPayload } from '../../middleware/auth';
import { writeAudit } from '../../middleware/audit';
import { stripSecrets } from '../../utils/sanitize';
import type { AuthUser } from '../../types';
import type { Request } from 'express';

interface UserRow {
  id: string;
  branch_id: string | null;
  role_id: string;
  role_name: string;
  name: string;
  phone: string;
  email: string | null;
  password_hash: string;
  is_active: boolean;
  last_login_at: string | null;
  created_at: string;
  updated_at: string;
}

const USER_SELECT = `
  SELECT u.*, r.name AS role_name
    FROM users u JOIN roles r ON r.id = u.role_id
`;

export async function login(
  phone: string,
  password: string,
  req?: Request,
): Promise<{ accessToken: string; refreshToken: string; user: AuthUser }> {
  const res = await query<UserRow>(`${USER_SELECT} WHERE u.phone = $1`, [phone]);
  const user = res.rows[0];
  // Same generic error for unknown phone and wrong password (no user enumeration).
  if (!user || !user.is_active) throw unauthorized('Invalid phone or password');
  const ok = await bcrypt.compare(password, user.password_hash);
  if (!ok) throw unauthorized('Invalid phone or password');

  const authUser: AuthUser = {
    id: user.id,
    name: user.name,
    phone: user.phone,
    role: user.role_name,
    branchId: user.branch_id,
  };
  await withTransaction(async (client) => {
    await client.query('UPDATE users SET last_login_at = now() WHERE id = $1', [user.id]);
    await writeAudit(client, {
      userId: user.id,
      action: 'login',
      entityType: 'user',
      entityId: user.id,
      req,
    });
  });
  return {
    accessToken: signAccessToken(authUser),
    refreshToken: signRefreshToken(user.id),
    user: authUser,
  };
}

export async function refresh(
  refreshToken: string,
): Promise<{ accessToken: string; refreshToken: string }> {
  let payload: RefreshTokenPayload;
  try {
    payload = jwt.verify(refreshToken, env.jwtRefreshSecret) as RefreshTokenPayload;
  } catch {
    throw unauthorized('Invalid or expired refresh token');
  }
  if (payload.type !== 'refresh') throw unauthorized('Invalid token type');
  const res = await query<UserRow>(`${USER_SELECT} WHERE u.id = $1`, [payload.sub]);
  const user = res.rows[0];
  if (!user || !user.is_active) throw unauthorized('User not found or disabled');
  const authUser: AuthUser = {
    id: user.id,
    name: user.name,
    phone: user.phone,
    role: user.role_name,
    branchId: user.branch_id,
  };
  // Rotate the refresh token on every use.
  return { accessToken: signAccessToken(authUser), refreshToken: signRefreshToken(user.id) };
}

export async function changePassword(
  userId: string,
  currentPassword: string,
  newPassword: string,
): Promise<void> {
  const res = await query<{ password_hash: string }>(
    'SELECT password_hash FROM users WHERE id = $1',
    [userId],
  );
  const row = res.rows[0];
  if (!row) throw notFound('User not found');
  const ok = await bcrypt.compare(currentPassword, row.password_hash);
  if (!ok) throw new ApiError(400, 'Current password is incorrect', 'BAD_REQUEST');
  const hash = await bcrypt.hash(newPassword, env.bcryptRounds);
  await query('UPDATE users SET password_hash = $1 WHERE id = $2', [hash, userId]);
}

export async function getMe(userId: string): Promise<Record<string, unknown>> {
  const res = await query<UserRow>(`${USER_SELECT} WHERE u.id = $1`, [userId]);
  const user = res.rows[0];
  if (!user) throw notFound('User not found');
  return stripSecrets(user);
}

export async function listUsers(page: number, limit: number): Promise<{
  rows: Record<string, unknown>[];
  total: number;
}> {
  const total = await query<{ count: string }>('SELECT COUNT(*)::text AS count FROM users');
  const res = await query<UserRow>(
    `${USER_SELECT} ORDER BY u.created_at DESC LIMIT $1 OFFSET $2`,
    [limit, (page - 1) * limit],
  );
  return { rows: res.rows.map((r) => stripSecrets(r)), total: Number(total.rows[0].count) };
}

export async function createUser(input: {
  name: string;
  phone: string;
  email?: string | null;
  password: string;
  role: string;
  branchId?: string | null;
}, actor: AuthUser, req?: Request): Promise<Record<string, unknown>> {
  const roleRes = await query<{ id: string }>('SELECT id FROM roles WHERE name = $1', [input.role]);
  if (roleRes.rows.length === 0) throw new ApiError(400, `Unknown role: ${input.role}`, 'BAD_REQUEST');
  const hash = await bcrypt.hash(input.password, env.bcryptRounds);
  return withTransaction(async (client) => {
    const res = await client.query<UserRow>(
      `INSERT INTO users (branch_id, role_id, name, phone, email, password_hash)
       VALUES ($1, $2, $3, $4, $5, $6) RETURNING *`,
      [input.branchId ?? null, roleRes.rows[0].id, input.name, input.phone, input.email ?? null, hash],
    );
    const created = await client.query<UserRow>(`${USER_SELECT} WHERE u.id = $1`, [res.rows[0].id]);
    await writeAudit(client, {
      userId: actor.id,
      action: 'create',
      entityType: 'user',
      entityId: res.rows[0].id,
      newValues: { name: input.name, phone: input.phone, role: input.role },
      req,
    });
    return stripSecrets(created.rows[0]);
  });
}

export async function updateUser(
  id: string,
  input: {
    name?: string;
    phone?: string;
    email?: string | null;
    role?: string;
    branchId?: string | null;
    isActive?: boolean;
    password?: string;
  },
  actor: AuthUser,
  req?: Request,
): Promise<Record<string, unknown>> {
  return withTransaction(async (client) => {
    const existing = await client.query<UserRow>(`${USER_SELECT} WHERE u.id = $1`, [id]);
    if (existing.rows.length === 0) throw notFound('User not found');
    const sets: string[] = [];
    const params: unknown[] = [];
    const push = (sql: string, v: unknown) => {
      params.push(v);
      sets.push(`${sql} = $${params.length}`);
    };
    if (input.name !== undefined) push('name', input.name);
    if (input.phone !== undefined) push('phone', input.phone);
    if (input.email !== undefined) push('email', input.email);
    if (input.branchId !== undefined) push('branch_id', input.branchId);
    if (input.isActive !== undefined) push('is_active', input.isActive);
    if (input.password !== undefined) {
      push('password_hash', await bcrypt.hash(input.password, env.bcryptRounds));
    }
    if (input.role !== undefined) {
      const roleRes = await client.query<{ id: string }>(
        'SELECT id FROM roles WHERE name = $1',
        [input.role],
      );
      if (roleRes.rows.length === 0) throw new ApiError(400, `Unknown role: ${input.role}`, 'BAD_REQUEST');
      push('role_id', roleRes.rows[0].id);
    }
    if (sets.length > 0) {
      params.push(id);
      await client.query(`UPDATE users SET ${sets.join(', ')} WHERE id = $${params.length}`, params);
    }
    const updated = await client.query<UserRow>(`${USER_SELECT} WHERE u.id = $1`, [id]);
    await writeAudit(client, {
      userId: actor.id,
      action: 'update',
      entityType: 'user',
      entityId: id,
      oldValues: stripSecrets(existing.rows[0]) as Record<string, unknown>,
      newValues: input as Record<string, unknown>,
      req,
    });
    return stripSecrets(updated.rows[0]);
  });
}

/** Deactivate a user (soft delete). Users are never hard-deleted: their
 *  past bills and audit rows must keep pointing at them. */
export async function deactivateUser(
  id: string,
  actor: AuthUser,
  req?: Request,
): Promise<void> {
  if (id === actor.id) throw new ApiError(400, 'You cannot deactivate your own account', 'BAD_REQUEST');
  await withTransaction(async (client) => {
    const res = await client.query('UPDATE users SET is_active = FALSE WHERE id = $1 RETURNING id', [id]);
    if (res.rows.length === 0) throw notFound('User not found');
    await writeAudit(client, {
      userId: actor.id,
      action: 'delete',
      entityType: 'user',
      entityId: id,
      req,
    });
  });
}
