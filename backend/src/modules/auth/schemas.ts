import { z } from 'zod';

export const loginSchema = z.object({
  phone: z.string().trim().min(10).max(15),
  password: z.string().min(1),
});

export const refreshSchema = z.object({
  refreshToken: z.string().min(1),
});

export const changePasswordSchema = z.object({
  currentPassword: z.string().min(1),
  newPassword: z.string().min(6).max(72),
});

export const createUserSchema = z.object({
  name: z.string().trim().min(2).max(100),
  phone: z.string().trim().min(10).max(15),
  email: z.string().email().optional().nullable(),
  password: z.string().min(6).max(72),
  role: z.enum(['owner', 'manager', 'cashier']),
  branchId: z.string().uuid().optional().nullable(),
});

export const updateUserSchema = z.object({
  name: z.string().trim().min(2).max(100).optional(),
  phone: z.string().trim().min(10).max(15).optional(),
  email: z.string().email().optional().nullable(),
  role: z.enum(['owner', 'manager', 'cashier']).optional(),
  branchId: z.string().uuid().optional().nullable(),
  isActive: z.boolean().optional(),
  password: z.string().min(6).max(72).optional(),
});
