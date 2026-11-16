// Augment Express Request with the authenticated user (set by authenticate middleware).
import type { AuthUser } from './index';

declare global {
  // eslint-disable-next-line @typescript-eslint/no-namespace
  namespace Express {
    interface Request {
      user?: AuthUser;
    }
  }
}

export {};
