// Customers, udhaar ledger, and installment plans.
import { query, withTransaction } from '../../config/db';
import { badRequest, notFound } from '../../middleware/errors';
import { writeAudit } from '../../middleware/audit';
import { appendLedger } from '../sales/service';
import { calcInstallments, paymentStatusFor } from '../../utils/money';
import type { AuthUser, Pagination } from '../../types';
import type { Request } from 'express';

type Row = Record<string, unknown>;

/** Current udhaar balance: latest ledger balance, else the opening balance. */
async function currentBalance(customerId: string): Promise<number> {
  // Balance as SUM(debit - credit): the "latest row" lookup is ambiguous
  // when two entries share an entry_date + created_at (the seed writes
  // such a pair), so the sum — order-independent — is used everywhere.
  const res = await query<{ balance_after: number; opening_balance: number }>(
    `SELECT
       (SELECT SUM(debit - credit) FROM ledger_entries
         WHERE side = 'customer' AND customer_id = $1) AS balance_after,
       opening_balance FROM customers WHERE id = $1`,
    [customerId],
  );
  if (res.rows.length === 0) throw notFound('Customer not found');
  const r = res.rows[0];
  return r.balance_after !== null && r.balance_after !== undefined
    ? Number(r.balance_after)
    : Number(r.opening_balance);
}

export async function listCustomers(
  search: string | undefined,
  pagination: Pagination,
): Promise<{ rows: Row[]; total: number }> {
  const where: string[] = [];
  const params: unknown[] = [];
  if (search) {
    params.push(`%${search}%`);
    where.push(`(c.name ILIKE $${params.length} OR c.phone ILIKE $${params.length} OR c.cnic ILIKE $${params.length})`);
  }
  const whereSql = where.length ? `WHERE ${where.join(' AND ')}` : '';
  const totalRes = await query<{ count: string }>(
    `SELECT COUNT(*)::text AS count FROM customers c ${whereSql}`,
    params,
  );
  const res = await query<Row>(
    `SELECT c.*,
            COALESCE((
              SELECT SUM(debit - credit) FROM ledger_entries
               WHERE side = 'customer' AND customer_id = c.id
            ), c.opening_balance) AS balance
       FROM customers c ${whereSql}
      ORDER BY c.name ASC
      LIMIT $${params.length + 1} OFFSET $${params.length + 2}`,
    [...params, pagination.limit, pagination.offset],
  );
  return { rows: res.rows, total: Number(totalRes.rows[0].count) };
}

export async function getCustomer(id: string): Promise<Row> {
  const res = await query<Row>('SELECT * FROM customers WHERE id = $1', [id]);
  if (res.rows.length === 0) throw notFound('Customer not found');
  const customer = res.rows[0];
  customer.balance = await currentBalance(id);
  return customer;
}

export async function createCustomer(
  input: Record<string, unknown>,
  actor: AuthUser,
  req?: Request,
): Promise<Row> {
  const created = await withTransaction(async (client) => {
    const res = await client.query<Row>(
      `INSERT INTO customers (name, phone, cnic, address, opening_balance)
       VALUES ($1,$2,$3,$4,$5) RETURNING *`,
      [
        input.name,
        input.phone,
        input.cnic ?? null,
        input.address ?? null,
        input.openingBalance ?? 0,
      ],
    );
    await writeAudit(client, {
      userId: actor.id,
      action: 'create',
      entityType: 'customer',
      entityId: String(res.rows[0].id),
      newValues: input,
      req,
    });
    return res.rows[0];
  });
  return created;
}

export async function updateCustomer(
  id: string,
  input: Record<string, unknown>,
  actor: AuthUser,
  req?: Request,
): Promise<Row> {
  return withTransaction(async (client) => {
    const existing = await client.query<Row>('SELECT * FROM customers WHERE id = $1', [id]);
    if (existing.rows.length === 0) throw notFound('Customer not found');
    const sets: string[] = [];
    const params: unknown[] = [];
    const push = (col: string, v: unknown) => {
      params.push(v);
      sets.push(`${col} = $${params.length}`);
    };
    if (input.name !== undefined) push('name', input.name);
    if (input.phone !== undefined) push('phone', input.phone);
    if (input.cnic !== undefined) push('cnic', input.cnic);
    if (input.address !== undefined) push('address', input.address);
    if (input.isActive !== undefined) push('is_active', input.isActive);
    if (sets.length > 0) {
      params.push(id);
      await client.query(`UPDATE customers SET ${sets.join(', ')} WHERE id = $${params.length}`, params);
    }
    const updated = await client.query<Row>('SELECT * FROM customers WHERE id = $1', [id]);
    await writeAudit(client, {
      userId: actor.id,
      action: 'update',
      entityType: 'customer',
      entityId: id,
      oldValues: existing.rows[0],
      newValues: input,
      req,
    });
    return updated.rows[0];
  });
}

export async function deactivateCustomer(id: string, actor: AuthUser, req?: Request): Promise<void> {
  await withTransaction(async (client) => {
    const res = await client.query(
      'UPDATE customers SET is_active = FALSE WHERE id = $1 RETURNING id',
      [id],
    );
    if (res.rows.length === 0) throw notFound('Customer not found');
    await writeAudit(client, { userId: actor.id, action: 'delete', entityType: 'customer', entityId: id, req });
  });
}

/** Full ledger statement (newest first) + current balance. */
export async function customerLedger(
  customerId: string,
  pagination: Pagination,
): Promise<{ rows: Row[]; total: number; balance: number }> {
  const balance = await currentBalance(customerId);
  const totalRes = await query<{ count: string }>(
    `SELECT COUNT(*)::text AS count FROM ledger_entries
      WHERE side = 'customer' AND customer_id = $1`,
    [customerId],
  );
  const res = await query<Row>(
    `SELECT * FROM ledger_entries
      WHERE side = 'customer' AND customer_id = $1
      ORDER BY entry_date DESC, created_at DESC
      LIMIT $2 OFFSET $3`,
    [customerId, pagination.limit, pagination.offset],
  );
  return { rows: res.rows, total: Number(totalRes.rows[0].count), balance };
}

// ---- Installments ----
export async function createInstallment(
  input: { saleId: string; downPayment?: number; installmentCount: number; startDate: string },
  user: AuthUser,
  req?: Request,
): Promise<Row> {
  return withTransaction(async (client) => {
    const saleRes = await client.query<Row>(
      'SELECT * FROM sales WHERE id = $1 FOR UPDATE',
      [input.saleId],
    );
    if (saleRes.rows.length === 0) throw notFound('Sale not found');
    const sale = saleRes.rows[0];
    if (!sale.customer_id) throw badRequest('Installments need a registered customer');
    if (String(sale.status) === 'cancelled') throw badRequest('Cannot create a plan on a cancelled bill');
    const existing = await client.query(
      'SELECT id FROM installments WHERE sale_id = $1',
      [input.saleId],
    );
    if (existing.rows.length > 0) throw badRequest('An installment plan already exists for this bill');

    const downPayment = Number(sale.paid_amount);
    if (input.downPayment !== undefined && input.downPayment !== downPayment) {
      throw badRequest(
        `Down payment must equal what was already collected on the bill (Rs ${downPayment}). ` +
          'Record any extra payment on the bill first, then create the plan.',
      );
    }
    const remaining = Number(sale.balance_due);
    if (remaining <= 0) throw badRequest('Nothing left to split into installments');
    const perAmount = Math.ceil(remaining / input.installmentCount);
    const slices = calcInstallments(remaining, input.installmentCount, input.startDate);

    const instRes = await client.query<Row>(
      `INSERT INTO installments
         (sale_id, customer_id, total_amount, down_payment, installment_count,
          installment_amount, start_date)
       VALUES ($1,$2,$3,$4,$5,$6,$7) RETURNING *`,
      [
        input.saleId,
        sale.customer_id,
        Number(sale.grand_total),
        downPayment,
        input.installmentCount,
        perAmount,
        input.startDate,
      ],
    );
    const inst = instRes.rows[0];
    for (const s of slices) {
      await client.query(
        `INSERT INTO installment_payments (installment_id, due_date, amount, status)
         VALUES ($1,$2,$3,'pending')`,
        [inst.id, s.dueDate, s.amount],
      );
    }
    await writeAudit(client, {
      userId: user.id,
      action: 'create',
      entityType: 'installment',
      entityId: String(inst.id),
      newValues: { saleId: input.saleId, count: input.installmentCount, remaining },
      req,
    });
    return getInstallmentInternal(client, String(inst.id));
  });
}

async function getInstallmentInternal(client: import('pg').PoolClient, id: string): Promise<Row> {
  const res = await client.query<Row>(
    `SELECT i.*, c.name AS customer_name, s.invoice_no
       FROM installments i
       JOIN customers c ON c.id = i.customer_id
       JOIN sales s ON s.id = i.sale_id
      WHERE i.id = $1`,
    [id],
  );
  if (res.rows.length === 0) throw notFound('Installment plan not found');
  const inst = res.rows[0];
  inst.schedule = (
    await client.query<Row>(
      'SELECT * FROM installment_payments WHERE installment_id = $1 ORDER BY due_date',
      [id],
    )
  ).rows;
  return inst;
}

export async function getInstallment(id: string): Promise<Row> {
  return withTransaction(async (client) => getInstallmentInternal(client, id));
}

export async function listCustomerInstallments(customerId: string): Promise<Row[]> {
  const res = await query<Row>(
    `SELECT i.*, s.invoice_no FROM installments i
       JOIN sales s ON s.id = i.sale_id
      WHERE i.customer_id = $1 ORDER BY i.created_at DESC`,
    [customerId],
  );
  return res.rows;
}

/** Pay one installment (full or partial). Updates the schedule, the bill,
 *  the customer ledger and records the payment — one transaction. */
export async function payInstallment(
  installmentId: string,
  input: {
    installmentPaymentId: string;
    amount: number;
    method: string;
    reference?: string | null;
    notes?: string | null;
  },
  user: AuthUser,
  req?: Request,
): Promise<Row> {
  return withTransaction(async (client) => {
    const instRes = await client.query<Row>(
      'SELECT * FROM installments WHERE id = $1 FOR UPDATE',
      [installmentId],
    );
    if (instRes.rows.length === 0) throw notFound('Installment plan not found');
    const inst = instRes.rows[0];
    const rowRes = await client.query<Row>(
      `SELECT * FROM installment_payments
        WHERE id = $1 AND installment_id = $2 FOR UPDATE`,
      [input.installmentPaymentId, installmentId],
    );
    if (rowRes.rows.length === 0) throw notFound('Installment payment row not found');
    const row = rowRes.rows[0];
    const remaining = Number(row.amount) - Number(row.paid_amount);
    if (remaining <= 0) throw badRequest('This installment is already fully paid');
    if (input.amount > remaining) {
      throw badRequest(`Amount exceeds the remaining Rs ${remaining} on this installment`);
    }
    const newPaid = Number(row.paid_amount) + input.amount;
    const newStatus = newPaid >= Number(row.amount) ? 'paid' : 'partial';
    await client.query(
      `UPDATE installment_payments
          SET paid_amount = $1, status = $2, paid_date = CURRENT_DATE
        WHERE id = $3`,
      [newPaid, newStatus, row.id],
    );
    await client.query(
      `INSERT INTO payments (payment_type, sale_id, installment_id, customer_id, method, amount, reference, user_id, notes)
       VALUES ('installment', $1, $2, $3, $4, $5, $6, $7, $8)`,
      [
        inst.sale_id,
        installmentId,
        inst.customer_id,
        input.method,
        input.amount,
        input.reference ?? null,
        user.id,
        input.notes ?? null,
      ],
    );
    // Update the bill's paid / balance.
    const saleRes = await client.query<Row>(
      'SELECT * FROM sales WHERE id = $1 FOR UPDATE',
      [inst.sale_id],
    );
    const sale = saleRes.rows[0];
    const newSalePaid = Number(sale.paid_amount) + input.amount;
    const newSaleBalance = Math.max(0, Number(sale.balance_due) - input.amount);
    await client.query(
      `UPDATE sales SET paid_amount = $1, balance_due = $2, payment_status = $3 WHERE id = $4`,
      [newSalePaid, newSaleBalance, paymentStatusFor(newSalePaid, Number(sale.grand_total)), sale.id],
    );
    await appendLedger(client, {
      side: 'customer',
      customerId: String(inst.customer_id),
      referenceType: 'installment',
      referenceId: installmentId,
      debit: 0,
      credit: input.amount,
      userId: user.id,
      notes: `Installment payment for bill ${sale.invoice_no}`,
    });
    // Plan completes when every row is paid.
    const unpaid = await client.query<{ count: string }>(
      `SELECT COUNT(*)::text AS count FROM installment_payments
        WHERE installment_id = $1 AND status <> 'paid'`,
      [installmentId],
    );
    if (Number(unpaid.rows[0].count) === 0) {
      await client.query(
        `UPDATE installments SET status = 'completed' WHERE id = $1`,
        [installmentId],
      );
    }
    await writeAudit(client, {
      userId: user.id,
      action: 'payment',
      entityType: 'installment',
      entityId: installmentId,
      newValues: { amount: input.amount, method: input.method },
      req,
    });
    return getInstallmentInternal(client, installmentId);
  });
}

/** Installments past their due date (for the recovery list + reminders).
 * Mirrors DriftCustomerRepository.overdueInstallments: first flip newly
 * past-due pending/partial rows to status 'overdue', then list every
 * 'overdue' row. The old filter (`status IN ('pending','partial')`)
 * never flipped anything and never returned rows already marked
 * 'overdue', so the seed's overdue installment (and any row the app
 * had flipped) was invisible here and on the dashboard. */
export async function overdueInstallments(): Promise<Row[]> {
  await query(
    `UPDATE installment_payments SET status = 'overdue', updated_at = now()
      WHERE due_date < CURRENT_DATE AND status IN ('pending', 'partial')`,
  );
  const res = await query<Row>(
    `SELECT ip.*, i.sale_id, i.customer_id, c.name AS customer_name, c.phone AS customer_phone,
            s.invoice_no
       FROM installment_payments ip
       JOIN installments i ON i.id = ip.installment_id
       JOIN customers c ON c.id = i.customer_id
       JOIN sales s ON s.id = i.sale_id
      WHERE ip.status = 'overdue'
      ORDER BY ip.due_date ASC`,
  );
  return res.rows;
}
