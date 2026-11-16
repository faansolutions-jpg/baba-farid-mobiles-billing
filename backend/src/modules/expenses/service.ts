// Expenses, staff & salaries, and the cash register.
// Schema notes (database/schema.sql):
// - expenses: category is a TEXT column (no expense_categories table),
//   no payment_method / receipt_no / notes columns.
// - staff has no joining_date.
// - salaries live in salary_payments: month is TEXT 'YYYY-MM', columns are
//   amount + advance (no deductions/bonus/net_amount/payment_method).
// - cash_register has no closed_at column (updated_at is maintained by trigger).
// - Expenses are paid in cash from the drawer (no payment method stored),
//   so every expense reduces the day's expected cash.
import { query, withTransaction } from '../../config/db';
import { badRequest, conflict, notFound } from '../../middleware/errors';
import { writeAudit } from '../../middleware/audit';
import { toWholePKR } from '../../utils/money';
import { STANDARD_EXPENSE_CATEGORIES } from './schemas';
import type { AuthUser, Pagination } from '../../types';
import type { Request } from 'express';
import type { PoolClient } from 'pg';

type Row = Record<string, unknown>;

async function resolveBranchId(client: PoolClient, user: AuthUser): Promise<string> {
  if (user.branchId) return user.branchId;
  const res = await client.query<{ id: string }>(
    'SELECT id FROM branches WHERE is_active = TRUE ORDER BY created_at ASC LIMIT 1',
  );
  if (res.rows.length === 0) throw badRequest('No active branch exists');
  return res.rows[0].id;
}

// ---- Expenses ----
export async function listExpenseCategories(): Promise<string[]> {
  const used = await query<{ category: string }>(
    'SELECT DISTINCT category FROM expenses ORDER BY category',
  );
  const set = new Set<string>(STANDARD_EXPENSE_CATEGORIES);
  for (const r of used.rows) set.add(r.category);
  return [...set].sort();
}

export async function createExpense(
  input: { category: string; amount: number; description?: string | null },
  user: AuthUser,
  req?: Request,
): Promise<Row> {
  return withTransaction(async (client) => {
    const branchId = await resolveBranchId(client, user);
    const res = await client.query<Row>(
      `INSERT INTO expenses (branch_id, category, amount, description, user_id)
       VALUES ($1,$2,$3,$4,$5) RETURNING *`,
      [branchId, input.category, toWholePKR(input.amount), input.description ?? null, user.id],
    );
    await writeAudit(client, {
      userId: user.id,
      action: 'create',
      entityType: 'expense',
      entityId: String(res.rows[0].id),
      newValues: { category: input.category, amount: input.amount },
      req,
    });
    return res.rows[0];
  });
}

export async function listExpenses(
  filters: { category?: string; from?: string; to?: string },
  pagination: Pagination,
): Promise<{ rows: Row[]; total: number }> {
  const where: string[] = [];
  const params: unknown[] = [];
  if (filters.category) {
    params.push(filters.category);
    where.push(`e.category = $${params.length}`);
  }
  if (filters.from) {
    params.push(filters.from);
    where.push(`e.expense_date::date >= $${params.length}`);
  }
  if (filters.to) {
    params.push(filters.to);
    where.push(`e.expense_date::date <= $${params.length}`);
  }
  const whereSql = where.length ? `WHERE ${where.join(' AND ')}` : '';
  const totalRes = await query<{ count: string }>(
    `SELECT COUNT(*)::text AS count FROM expenses e ${whereSql}`,
    params,
  );
  const res = await query<Row>(
    `SELECT e.*, u.name AS user_name
       FROM expenses e JOIN users u ON u.id = e.user_id
      ${whereSql}
      ORDER BY e.expense_date DESC
      LIMIT $${params.length + 1} OFFSET $${params.length + 2}`,
    [...params, pagination.limit, pagination.offset],
  );
  return { rows: res.rows, total: Number(totalRes.rows[0].count) };
}

export async function getExpense(id: string): Promise<Row> {
  const res = await query<Row>('SELECT * FROM expenses WHERE id = $1', [id]);
  if (res.rows.length === 0) throw notFound('Expense not found');
  return res.rows[0];
}

export async function updateExpense(
  id: string,
  input: Record<string, unknown>,
  actor: AuthUser,
  req?: Request,
): Promise<Row> {
  return withTransaction(async (client) => {
    const existing = await client.query<Row>('SELECT * FROM expenses WHERE id = $1', [id]);
    if (existing.rows.length === 0) throw notFound('Expense not found');
    const sets: string[] = [];
    const params: unknown[] = [];
    const push = (col: string, v: unknown) => {
      params.push(v);
      sets.push(`${col} = $${params.length}`);
    };
    if (input.category !== undefined) push('category', input.category);
    if (input.amount !== undefined) push('amount', input.amount);
    if (input.description !== undefined) push('description', input.description);
    if (sets.length > 0) {
      params.push(id);
      await client.query(`UPDATE expenses SET ${sets.join(', ')} WHERE id = $${params.length}`, params);
    }
    const updated = await client.query<Row>('SELECT * FROM expenses WHERE id = $1', [id]);
    await writeAudit(client, {
      userId: actor.id,
      action: 'update',
      entityType: 'expense',
      entityId: id,
      oldValues: existing.rows[0],
      newValues: input,
      req,
    });
    return updated.rows[0];
  });
}

export async function deleteExpense(id: string, actor: AuthUser, req?: Request): Promise<void> {
  await withTransaction(async (client) => {
    const existing = await client.query<Row>('SELECT * FROM expenses WHERE id = $1', [id]);
    if (existing.rows.length === 0) throw notFound('Expense not found');
    await client.query('DELETE FROM expenses WHERE id = $1', [id]);
    await writeAudit(client, {
      userId: actor.id,
      action: 'delete',
      entityType: 'expense',
      entityId: id,
      oldValues: existing.rows[0],
      req,
    });
  });
}

/** Monthly expense totals grouped by category (for the P&L / reports). */
export async function expenseSummaryByCategory(month: string): Promise<Row[]> {
  const res = await query<Row>(
    `SELECT category, COALESCE(SUM(amount), 0)::bigint AS total,
            COUNT(*)::bigint AS count
       FROM expenses
      WHERE DATE_TRUNC('month', expense_date) = $1::date
      GROUP BY category
      ORDER BY total DESC`,
    [`${month}-01`],
  );
  return res.rows;
}

// ---- Staff ----
export async function listStaff(pagination: Pagination): Promise<{ rows: Row[]; total: number }> {
  const totalRes = await query<{ count: string }>(
    'SELECT COUNT(*)::text AS count FROM staff',
  );
  const res = await query<Row>(
    'SELECT * FROM staff ORDER BY name ASC LIMIT $1 OFFSET $2',
    [pagination.limit, pagination.offset],
  );
  return { rows: res.rows, total: Number(totalRes.rows[0].count) };
}

export async function createStaff(
  input: Record<string, unknown>,
  actor: AuthUser,
  req?: Request,
): Promise<Row> {
  const res = await withTransaction(async (client) => {
    const r = await client.query<Row>(
      `INSERT INTO staff (name, phone, role, salary, is_active)
       VALUES ($1,$2,$3,$4,$5) RETURNING *`,
      [input.name, input.phone ?? null, input.role, input.salary ?? 0, input.isActive ?? true],
    );
    await writeAudit(client, {
      userId: actor.id,
      action: 'create',
      entityType: 'staff',
      entityId: String(r.rows[0].id),
      newValues: input,
      req,
    });
    return r.rows[0];
  });
  return res;
}

export async function updateStaff(
  id: string,
  input: Record<string, unknown>,
  actor: AuthUser,
  req?: Request,
): Promise<Row> {
  return withTransaction(async (client) => {
    const existing = await client.query<Row>('SELECT * FROM staff WHERE id = $1', [id]);
    if (existing.rows.length === 0) throw notFound('Staff member not found');
    const sets: string[] = [];
    const params: unknown[] = [];
    const push = (col: string, v: unknown) => {
      params.push(v);
      sets.push(`${col} = $${params.length}`);
    };
    if (input.name !== undefined) push('name', input.name);
    if (input.phone !== undefined) push('phone', input.phone);
    if (input.role !== undefined) push('role', input.role);
    if (input.salary !== undefined) push('salary', input.salary);
    if (input.isActive !== undefined) push('is_active', input.isActive);
    if (sets.length > 0) {
      params.push(id);
      await client.query(`UPDATE staff SET ${sets.join(', ')} WHERE id = $${params.length}`, params);
    }
    const updated = await client.query<Row>('SELECT * FROM staff WHERE id = $1', [id]);
    await writeAudit(client, {
      userId: actor.id,
      action: 'update',
      entityType: 'staff',
      entityId: id,
      oldValues: existing.rows[0],
      newValues: input,
      req,
    });
    return updated.rows[0];
  });
}

// ---- Salaries (salary_payments table) ----
export async function paySalary(
  input: {
    staffId: string;
    month: string;
    amount: number;
    advance?: number;
    notes?: string | null;
  },
  user: AuthUser,
  req?: Request,
): Promise<Row> {
  return withTransaction(async (client) => {
    const staff = await client.query<Row>('SELECT * FROM staff WHERE id = $1', [input.staffId]);
    if (staff.rows.length === 0) throw notFound('Staff member not found');
    const existing = await client.query(
      'SELECT id FROM salary_payments WHERE staff_id = $1 AND month = $2',
      [input.staffId, input.month],
    );
    if (existing.rows.length > 0) {
      throw conflict(`Salary for ${input.month} has already been recorded for this staff member`);
    }
    const amount = toWholePKR(input.amount);
    const advance = toWholePKR(input.advance ?? 0);
    if (advance > amount) throw badRequest('Advance cannot exceed the salary amount');
    const res = await client.query<Row>(
      `INSERT INTO salary_payments (staff_id, month, amount, advance, user_id, notes)
       VALUES ($1,$2,$3,$4,$5,$6) RETURNING *`,
      [input.staffId, input.month, amount, advance, user.id, input.notes ?? null],
    );
    const row = res.rows[0];
    row.net_paid = amount - advance;
    await writeAudit(client, {
      userId: user.id,
      action: 'create',
      entityType: 'salary',
      entityId: String(row.id),
      newValues: { staffId: input.staffId, month: input.month, amount, advance },
      req,
    });
    return row;
  });
}

export async function listSalaries(month: string | undefined, pagination: Pagination): Promise<{ rows: Row[]; total: number }> {
  const where: string[] = [];
  const params: unknown[] = [];
  if (month) {
    params.push(month);
    where.push(`sp.month = $${params.length}`);
  }
  const whereSql = where.length ? `WHERE ${where.join(' AND ')}` : '';
  const totalRes = await query<{ count: string }>(
    `SELECT COUNT(*)::text AS count FROM salary_payments sp ${whereSql}`,
    params,
  );
  const res = await query<Row>(
    `SELECT sp.*, st.name AS staff_name, (sp.amount - sp.advance) AS net_paid
       FROM salary_payments sp JOIN staff st ON st.id = sp.staff_id
      ${whereSql}
      ORDER BY sp.month DESC, st.name ASC
      LIMIT $${params.length + 1} OFFSET $${params.length + 2}`,
    [...params, pagination.limit, pagination.offset],
  );
  return { rows: res.rows, total: Number(totalRes.rows[0].count) };
}

// ---- Cash register ----
async function todayRegister(client: PoolClient, branchId: string): Promise<Row | null> {
  const res = await client.query<Row>(
    `SELECT * FROM cash_register
      WHERE branch_id = $1 AND register_date = CURRENT_DATE
      ORDER BY created_at DESC LIMIT 1`,
    [branchId],
  );
  return res.rows.length ? res.rows[0] : null;
}

export async function getTodayRegister(branchId: string): Promise<Row | null> {
  return withTransaction(async (client) => todayRegister(client, branchId));
}

export async function openRegister(
  input: { openingCash: number; notes?: string | null },
  user: AuthUser,
  req?: Request,
): Promise<Row> {
  return withTransaction(async (client) => {
    const branchId = await resolveBranchId(client, user);
    const existing = await todayRegister(client, branchId);
    if (existing && String(existing.status) === 'open') {
      throw conflict('A register is already open for today');
    }
    const res = await client.query<Row>(
      `INSERT INTO cash_register (branch_id, register_date, opening_cash, status, opened_by, notes)
       VALUES ($1, CURRENT_DATE, $2, 'open', $3, $4) RETURNING *`,
      [branchId, toWholePKR(input.openingCash), user.id, input.notes ?? null],
    );
    await writeAudit(client, {
      userId: user.id,
      action: 'create',
      entityType: 'cash_register',
      entityId: String(res.rows[0].id),
      newValues: { openingCash: input.openingCash },
      req,
    });
    return res.rows[0];
  });
}

export async function recordCashMovement(
  input: { type: 'in' | 'out'; amount: number; reason: string },
  user: AuthUser,
  req?: Request,
): Promise<Row> {
  return withTransaction(async (client) => {
    const branchId = await resolveBranchId(client, user);
    const register = await todayRegister(client, branchId);
    if (!register || String(register.status) !== 'open') {
      throw badRequest('Open the cash register first (no open register today)');
    }
    const res = await client.query<Row>(
      `INSERT INTO cash_movements (register_id, type, amount, reason, user_id)
       VALUES ($1,$2,$3,$4,$5) RETURNING *`,
      [register.id, input.type, toWholePKR(input.amount), input.reason, user.id],
    );
    await writeAudit(client, {
      userId: user.id,
      action: 'create',
      entityType: 'cash_movement',
      entityId: String(res.rows[0].id),
      newValues: { type: input.type, amount: input.amount, reason: input.reason },
      req,
    });
    return res.rows[0];
  });
}

/** Close the register: expected cash = opening + cash received (sales /
 *  installments / repairs) + movements in − supplier cash payments −
 *  cash expenses − movements out. Difference = counted − expected. */
export async function closeRegister(
  input: { closingCash: number; notes?: string | null },
  user: AuthUser,
  req?: Request,
): Promise<Row> {
  return withTransaction(async (client) => {
    const branchId = await resolveBranchId(client, user);
    const register = await todayRegister(client, branchId);
    if (!register) throw badRequest('No register was opened today');
    if (String(register.status) !== 'open') throw badRequest('Register is already closed');
    const summary = await computeDaySummary(client, branchId);
    const counted = toWholePKR(input.closingCash);
    const expected = Number(summary.expectedCash);
    const res = await client.query<Row>(
      `UPDATE cash_register
          SET status = 'closed', closing_cash = $1, expected_cash = $2,
              difference = $3, closed_by = $4, notes = $5
        WHERE id = $6 RETURNING *`,
      [counted, expected, counted - expected, user.id, input.notes ?? null, register.id],
    );
    await writeAudit(client, {
      userId: user.id,
      action: 'close',
      entityType: 'cash_register',
      entityId: String(register.id),
      oldValues: register,
      newValues: { closingCash: counted, expectedCash: expected, difference: counted - expected },
      req,
    });
    return { ...res.rows[0], summary };
  });
}

async function computeDaySummary(client: PoolClient, branchId: string): Promise<Row> {
  const register = await todayRegister(client, branchId);
  const sales = await client.query<{ total: number; count: number }>(
    `SELECT COALESCE(SUM(grand_total), 0)::bigint AS total,
            COUNT(*)::bigint AS count
       FROM sales WHERE branch_id = $1 AND sale_date::date = CURRENT_DATE AND status <> 'cancelled'`,
    [branchId],
  );
  // Expenses have no payment-method column — the shop pays them in cash
  // from the drawer, so every expense reduces expected cash.
  const expenses = await client.query<{ total: number; count: number }>(
    `SELECT COALESCE(SUM(amount), 0)::bigint AS total, COUNT(*)::bigint AS count
       FROM expenses WHERE branch_id = $1 AND expense_date::date = CURRENT_DATE`,
    [branchId],
  );
  // Cash in/out through the payments table. Branch is resolved via the
  // linked sale / purchase; repairs have no branch column, so a repair
  // payment is attributed to the branch of the user who recorded it
  // (or to this shop when that user has no branch set).
  const payments = await client.query<{ cash_in: number; cash_out_suppliers: number }>(
    `SELECT
       COALESCE(SUM(CASE WHEN p.payment_type IN ('sale','installment','repair') AND p.method = 'cash'
                         THEN p.amount ELSE 0 END), 0)::bigint AS cash_in,
       COALESCE(SUM(CASE WHEN p.payment_type = 'purchase' AND p.method = 'cash'
                         THEN p.amount ELSE 0 END), 0)::bigint AS cash_out_suppliers
       FROM payments p
       LEFT JOIN sales s ON s.id = p.sale_id
       LEFT JOIN purchases pu ON pu.id = p.purchase_id
       LEFT JOIN users u ON u.id = p.user_id
      WHERE p.payment_date::date = CURRENT_DATE
        AND (
          $1 IN (s.branch_id, pu.branch_id)
          OR (p.payment_type = 'repair' AND ($1 = u.branch_id OR u.branch_id IS NULL))
        )`,
    [branchId],
  );
  const movements = await client.query<{ in_total: number; out_total: number }>(
    `SELECT
       COALESCE(SUM(CASE WHEN type = 'in' THEN amount ELSE 0 END), 0)::bigint AS in_total,
       COALESCE(SUM(CASE WHEN type = 'out' THEN amount ELSE 0 END), 0)::bigint AS out_total
       FROM cash_movements
      WHERE register_id = $1`,
    [register?.id ?? null],
  );
  const opening = Number(register?.opening_cash ?? 0);
  const cashInPayments = Number(payments.rows[0].cash_in);
  const cashOutSuppliers = Number(payments.rows[0].cash_out_suppliers);
  const cashExpenses = Number(expenses.rows[0].total);
  const cashInMovements = Number(movements.rows[0].in_total);
  const cashOutMovements = Number(movements.rows[0].out_total);
  const expectedCash =
    opening + cashInPayments + cashInMovements - cashOutSuppliers - cashExpenses - cashOutMovements;
  return {
    registerId: register?.id ?? null,
    registerStatus: register?.status ?? 'not_opened',
    openingCash: opening,
    totalSales: Number(sales.rows[0].total),
    salesCount: Number(sales.rows[0].count),
    cashSales: cashInPayments,
    totalExpenses: cashExpenses,
    expenseCount: Number(expenses.rows[0].count),
    cashExpenses,
    supplierPaymentsCash: cashOutSuppliers,
    cashIn: cashInMovements,
    cashOut: cashOutMovements,
    expectedCash,
  };
}

export async function dayEndSummary(branchId: string): Promise<Row> {
  return withTransaction(async (client) => computeDaySummary(client, branchId));
}
