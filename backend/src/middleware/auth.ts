// JWT authentication + role checks.
// Access tokens are short-lived (15 min); refresh tokens last 7 days.
// The role name comes from the `roles` table and is embedded in the token
// at login, so every request knows the caller's role without a DB lookup.
// NOTE: the schema names the admin role 'owner' (not 'admin').
import type { NextFunction, Request, Response } from 'express';
import jwt from 'jsonwebtoken';
import { env } from '../config/env';
import { forbidden, unauthorized } from './errors';
import type { AuthUser } from '../types';

export interface AccessTokenPayload {
  sub: string;
  name: string;
  phone: string;
  role: string;
  branchId: string | null;
  type: 'access';
}

export interface RefreshTokenPayload {
  sub: string;
  type: 'refresh';
}

export function signAccessToken(user: AuthUser): string {
  return jwt.sign(
    {
      sub: user.id,
      name: user.name,
      phone: user.phone,
      role: user.role,
      branchId: user.branchId,
      type: 'access',
    } satisfies AccessTokenPayload,
    env.jwtAccessSecret,
    { expiresIn: env.jwtAccessExpiresIn } as jwt.SignOptions,
  );
}

export function signRefreshToken(userId: string): string {
  return jwt.sign(
    { sub: userId, type: 'refresh' } satisfies RefreshTokenPayload,
    env.jwtRefreshSecret,
    { expiresIn: env.jwtRefreshExpiresIn } as jwt.SignOptions,
  );
}

/** Verify the Bearer access token and attach req.user. 401 when missing/invalid. */
export function authenticate(req: Request, _res: Response, next: NextFunction): void {
  const header = req.headers.authorization ?? '';
  const token = header.startsWith('Bearer ') ? header.slice(7) : null;
  if (!token) return next(unauthorized('Missing access token'));
  try {
    const payload = jwt.verify(token, env.jwtAccessSecret) as AccessTokenPayload & {
      type?: string;
    };
    if (payload.type !== 'access') return next(unauthorized('Invalid token type'));
    req.user = {
      id: payload.sub,
      name: payload.name,
      phone: payload.phone,
      role: payload.role,
      branchId: payload.branchId ?? null,
    };
    return next();
  } catch {
    return next(unauthorized('Invalid or expired access token'));
  }
}

/** Require one of the given roles. Use after `authenticate`. */
export function requireRole(...roles: string[]) {
  return (req: Request, _res: Response, next: NextFunction): void => {
    if (!req.user) return next(unauthorized());
    if (!roles.includes(req.user.role)) {
      return next(forbidden(`Requires role: ${roles.join(' or ')}`));
    }
    return next();
  };
}

/** Convenience: owner or manager (staff who may manage stock, purchases, reports). */
export const requireStaff = requireRole('owner', 'manager');
/** Owner only (settings, users, profit config). */
export const requireOwner = requireRole('owner');
