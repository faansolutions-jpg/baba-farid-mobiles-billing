// Repair job cards + service sales (easyload / recharge / bill payment).
// Schema notes (database/schema.sql):
// - repairs has job_no (not repair_no), customer_name + customer_phone
//   denormalised, device_brand / device_model, fault_description,
//   estimated_cost, final_cost, advance_paid. NO branch_id, NO technician,
//   NO estimated_days, NO balance_due column (balance is computed).
// - repair_status enum: received, in_progress, ready, delivered, cancelled.
// - repair_parts stores name + unit_price (not unit_cost).
// - final_cost accumulates fitted parts; at delivery it is the total bill.
import { query, withTransaction } from '../../config/db';
import { badRequest, conflict, notFound } from '../../middleware/errors';
import { writeAudit } from '../../middleware/audit';
import { appendLedger } from '../sales/service';
import { toWholePKR } from '../../utils/money';
import { nextDocumentNo } from '../../utils/invoiceNo';
import { COUNTER_NAMES } from '../../config/constants';
import type { AuthUser, Pagination } from '../../types';
import type { Request } from 'express';
import type { PoolClient } from 'pg';

type Row = Record<string, unknown>;

const STATUS_ORDER = ['received', 'in_progress', 'ready', 'delivered'] as const;

/** Computed balance on a job: what the customer still owes. */
function withBalance(repair: Row): Row {
  const finalCost = Number(repair.final_cost ?? 0);
  const advance = Number(repair.advance_paid ?? 0);
  return { ...repair, balance_due: Math.max(0, finalCost - advance) };
}

async function resolveBranchId(client: PoolClient, user: AuthUser): Promise<string> {
  // Repairs are not branch-scoped in the schema; the branch is only needed
  // for the job-number counter (counters PK is branch_id + name).
  if (user.branchId) return user.branchId;
  const res = await client.query<{ id: string }>(
    'SELECT id FROM branches WHERE is_active = TRUE ORDER BY created_at ASC LIMIT 1',
  );
  if (res.rows.length === 0) throw badRequest('No active branch exists');
  return res.rows[0].id;
}

async function getRepairInternal(client: PoolClient, id: string): Promise<Row> {
  const res = await client.query<Row>(
    `SELECT r.*, c.name AS customer_full_name
       FROM repairs r LEFT JOIN customers c ON c.id = r.customer_id
      WHERE r.id = $1`,
    [id],
  );
  if (res.rows.length === 0) throw notFound('Repair job not found');
  const repair = res.rows[0];
  repair.parts = (
    await client.query<Row>(
      `SELECT rp.*, pr.name AS product_name, v.name AS variant_name
         FROM repair_parts rp
         LEFT JOIN products pr ON pr.id = rp.product_id
         LEFT JOIN product_variants v ON v.id = rp.variant_id
        WHERE rp.repair_id = $1 ORDER BY rp.created_at`,
      [id],
    )
  ).rows;
  return withBalance(repair);
}

export async function createRepair(
  input: {
    customerId?: string | null;
    customerName?: string | null;
    customerPhone?: string | null;
    deviceBrand?: string | null;
    deviceModel?: string | null;
    imei?: string | null;
    faultDescription: string;
    estimatedCost?: number;
    advancePaid?: number;
    notes?: string | null;
  },
  user: AuthUser,
  req?: Request,
): Promise<Row> {
  return withTransaction(async (client) => {
    const branchId = await resolveBranchId(client, user);
    let customerName = input.customerName ?? null;
    let customerPhone = input.customerPhone ?? null;
    if (input.customerId) {
      const customer = await client.query<Row>(
        'SELECT * FROM customers WHERE id = $1',
        [input.customerId],
      );
      if (customer.rows.length === 0) throw notFound('Customer not found');
      customerName = customerName ?? String(customer.rows[0].name);
      customerPhone = customerPhone ?? String(customer.rows[0].phone);
    }
    if (!customerName || !customerPhone) {
      throw badRequest('Customer name and phone are required');
    }
    const jobNo = await nextDocumentNo(
      client,
      branchId,
      COUNTER_NAMES.REPAIR_JOB.name,
      COUNTER_NAMES.REPAIR_JOB.prefix,
    );
    const estimated = toWholePKR(input.estimatedCost ?? 0);
    const advance = toWholePKR(input.advancePaid ?? 0);
    if (advance > estimated && estimated > 0) {
      throw badRequest('Advance cannot exceed the estimated cost');
    }
    const res = await client.query<Row>(
      `INSERT INTO repairs
         (job_no, customer_id, customer_name, customer_phone, device_brand, device_model,
          imei, fault_description, estimated_cost, final_cost, advance_paid, user_id, notes)
       VALUES ($1,$2,$3,$4,$5,$6,$7,$8,$9,0,$10,$11,$12) RETURNING *`,
      [
        jobNo,
        input.customerId ?? null,
        customerName,
        customerPhone,
        input.deviceBrand ?? null,
        input.deviceModel ?? null,
        input.imei ?? null,
        input.faultDescription,
        estimated,
        advance,
        user.id,
        input.notes ?? null,
      ],
    );
    const repair = res.rows[0];
    if (advance > 0) {
      await client.query(
        `INSERT INTO payments (payment_type, repair_id, customer_id, method, amount, user_id)
         VALUES ('repair', $1, $2, 'cash', $3, $4)`,
        [repair.id, input.customerId ?? null, advance, user.id],
      );
      // Prepayment: a credit on the customer's ledger (they hold credit with
      // us until the job is billed at delivery). Walk-ins have no ledger.
      if (input.customerId) {
        await appendLedger(client, {
          side: 'customer',
          customerId: String(input.customerId),
          referenceType: 'repair',
          referenceId: String(repair.id),
          debit: 0,
          credit: advance,
          userId: user.id,
          notes: `Advance for repair ${jobNo}`,
        });
      }
    }
    await writeAudit(client, {
      userId: user.id,
      action: 'create',
      entityType: 'repair',
      entityId: String(repair.id),
      newValues: { jobNo, device: `${input.deviceBrand ?? ''} ${input.deviceModel ?? ''}`.trim(), estimatedCost: estimated },
      req,
    });
    return getRepairInternal(client, String(repair.id));
  });
}

export async function listRepairs(
  filters: { status?: string; customerId?: string; search?: string },
  pagination: Pagination,
): Promise<{ rows: Row[]; total: number }> {
  const where: string[] = [];
  const params: unknown[] = [];
  if (filters.status) {
    params.push(filters.status);
    where.push(`r.status = $${params.length}`);
  }
  if (filters.customerId) {
    params.push(filters.customerId);
    where.push(`r.customer_id = $${params.length}`);
  }
  if (filters.search) {
    params.push(`%${filters.search}%`);
    where.push(
      `(r.job_no ILIKE $${params.length} OR r.customer_name ILIKE $${params.length} OR r.customer_phone ILIKE $${params.length} OR r.device_brand ILIKE $${params.length} OR r.device_model ILIKE $${params.length} OR r.imei ILIKE $${params.length})`,
    );
  }
  const whereSql = where.length ? `WHERE ${where.join(' AND ')}` : '';
  const totalRes = await query<{ count: string }>(
    `SELECT COUNT(*)::text AS count FROM repairs r ${whereSql}`,
    params,
  );
  const res = await query<Row>(
    `SELECT r.*,
            (r.final_cost - r.advance_paid) AS balance_due
       FROM repairs r
      ${whereSql}
      ORDER BY r.received_date DESC
      LIMIT $${params.length + 1} OFFSET $${params.length + 2}`,
    [...params, pagination.limit, pagination.offset],
  );
  return { rows: res.rows, total: Number(totalRes.rows[0].count) };
}

export async function getRepair(id: string): Promise<Row> {
  return withTransaction(async (client) => getRepairInternal(client, id));
}

export async function updateRepair(
  id: string,
  input: Record<string, unknown>,
  user: AuthUser,
  req?: Request,
): Promise<Row> {
  return withTransaction(async (client) => {
    const existing = await client.query<Row>(
      'SELECT * FROM repairs WHERE id = $1 FOR UPDATE',
      [id],
    );
    if (existing.rows.length === 0) throw notFound('Repair job not found');
    const current = existing.rows[0];
    if (String(current.status) === 'delivered') {
      throw badRequest('A delivered job cannot be edited');
    }
    if (String(current.status) === 'cancelled') {
      throw badRequest('A cancelled job cannot be edited');
    }
    if (input.status !== undefined) {
      const from = String(current.status);
      const to = String(input.status);
      if (to !== from) {
        if (to === 'delivered') {
          throw badRequest('Use the deliver endpoint to hand a job over (it finalises billing)');
        }
        const fromIdx = STATUS_ORDER.indexOf(from as (typeof STATUS_ORDER)[number]);
        const toIdx = STATUS_ORDER.indexOf(to as (typeof STATUS_ORDER)[number]);
        // Forward movement only; back to 'received' is allowed for rework.
        if (toIdx < fromIdx && to !== 'received') {
          throw badRequest(`Cannot move a job backwards from ${from} to ${to}`);
        }
      }
    }
    const sets: string[] = [];
    const params: unknown[] = [];
    const push = (col: string, v: unknown) => {
      params.push(v);
      sets.push(`${col} = $${params.length}`);
    };
    if (input.deviceBrand !== undefined) push('device_brand', input.deviceBrand);
    if (input.deviceModel !== undefined) push('device_model', input.deviceModel);
    if (input.imei !== undefined) push('imei', input.imei);
    if (input.faultDescription !== undefined) push('fault_description', input.faultDescription);
    if (input.estimatedCost !== undefined) push('estimated_cost', input.estimatedCost);
    if (input.notes !== undefined) push('notes', input.notes);
    if (input.status !== undefined) {
      push('status', input.status);
      if (input.status === 'ready') push('ready_date', new Date().toISOString());
    }
    if (sets.length > 0) {
      params.push(id);
      await client.query(
        `UPDATE repairs SET ${sets.join(', ')} WHERE id = $${params.length}`,
        params,
      );
    }
    await writeAudit(client, {
      userId: user.id,
      action: 'update',
      entityType: 'repair',
      entityId: id,
      oldValues: current,
      newValues: input,
      req,
    });
    return getRepairInternal(client, id);
  });
}

export async function cancelRepair(id: string, user: AuthUser, req?: Request): Promise<Row> {
  return withTransaction(async (client) => {
    const existing = await client.query<Row>(
      'SELECT * FROM repairs WHERE id = $1 FOR UPDATE',
      [id],
    );
    if (existing.rows.length === 0) throw notFound('Repair job not found');
    const current = existing.rows[0];
    if (String(current.status) === 'delivered') {
      throw badRequest('A delivered job cannot be cancelled');
    }
    if (String(current.status) === 'cancelled') {
      throw badRequest('Job is already cancelled');
    }
    // Any parts already fitted go back to stock.
    const parts = await client.query<Row>(
      'SELECT * FROM repair_parts WHERE repair_id = $1',
      [id],
    );
    for (const part of parts.rows) {
      if (part.variant_id) {
        await client.query(
          'UPDATE product_variants SET quantity = quantity + $1 WHERE id = $2',
          [part.quantity, part.variant_id],
        );
      }
    }
    await client.query(`UPDATE repairs SET status = 'cancelled' WHERE id = $1`, [id]);
    await writeAudit(client, {
      userId: user.id,
      action: 'cancel',
      entityType: 'repair',
      entityId: id,
      oldValues: current,
      req,
    });
    return getRepairInternal(client, id);
  });
}

/** Fit a part to a job: validates stock, deducts it, records the part and
 *  adds its cost to the job's running final_cost. */
async function fitPart(
  client: PoolClient,
  repairId: string,
  input: { productId: string; variantId: string; quantity: number; unitPrice: number },
): Promise<void> {
  const variantRes = await client.query<Row>(
    'SELECT * FROM product_variants WHERE id = $1 FOR UPDATE',
    [input.variantId],
  );
  if (variantRes.rows.length === 0) throw notFound('Variant not found');
  const variant = variantRes.rows[0];
  if (String(variant.product_id) !== input.productId) {
    throw badRequest('Variant does not belong to the given product');
  }
  if (Number(variant.quantity) < input.quantity) {
    throw conflict(
      `Not enough stock for ${variant.name}: available ${variant.quantity}, needed ${input.quantity}`,
    );
  }
  await client.query(
    'UPDATE product_variants SET quantity = quantity - $1 WHERE id = $2',
    [input.quantity, input.variantId],
  );
  const total = toWholePKR(input.unitPrice) * input.quantity;
  await client.query(
    `INSERT INTO repair_parts (repair_id, product_id, variant_id, name, quantity, unit_price, total)
     VALUES ($1,$2,$3,$4,$5,$6,$7)`,
    [repairId, input.productId, input.variantId, String(variant.name), input.quantity, input.unitPrice, total],
  );
  await client.query(
    'UPDATE repairs SET final_cost = final_cost + $1 WHERE id = $2',
    [total, repairId],
  );
}

export async function addRepairPart(
  repairId: string,
  input: { productId: string; variantId: string; quantity: number; unitPrice: number },
  user: AuthUser,
  req?: Request,
): Promise<Row> {
  return withTransaction(async (client) => {
    const repairRes = await client.query<Row>(
      'SELECT * FROM repairs WHERE id = $1 FOR UPDATE',
      [repairId],
    );
    if (repairRes.rows.length === 0) throw notFound('Repair job not found');
    const repair = repairRes.rows[0];
    if (['delivered', 'cancelled'].includes(String(repair.status))) {
      throw badRequest(`Cannot add parts to a ${repair.status} job`);
    }
    await fitPart(client, repairId, input);
    await writeAudit(client, {
      userId: user.id,
      action: 'update',
      entityType: 'repair',
      entityId: repairId,
      newValues: { part: input.variantId, qty: input.quantity, unitPrice: input.unitPrice },
      req,
    });
    return getRepairInternal(client, repairId);
  });
}

/** Deliver a job: settle the bill (final_cost incl. any extra parts),
 *  collect the remaining amount, and hand the device over. The advance was
 *  already credited on the customer's ledger at intake; the delivery writes
 *  the charge (debit final_cost) and the pickup payment (credit remaining)
 *  so the job nets to zero on the ledger. */
export async function deliverRepair(
  repairId: string,
  input: {
    parts?: { productId: string; variantId: string; quantity: number; unitPrice: number }[];
    finalCost?: number;
    paymentMethod?: string;
    notes?: string | null;
  },
  user: AuthUser,
  req?: Request,
): Promise<Row> {
  return withTransaction(async (client) => {
    const repairRes = await client.query<Row>(
      'SELECT * FROM repairs WHERE id = $1 FOR UPDATE',
      [repairId],
    );
    if (repairRes.rows.length === 0) throw notFound('Repair job not found');
    const repair = repairRes.rows[0];
    if (String(repair.status) === 'delivered') throw badRequest('Job is already delivered');
    if (String(repair.status) === 'cancelled') throw badRequest('Job was cancelled');

    for (const part of input.parts ?? []) {
      await fitPart(client, repairId, part);
    }

    const fresh = await client.query<Row>('SELECT * FROM repairs WHERE id = $1', [repairId]);
    const current = fresh.rows[0];
    const finalCost =
      input.finalCost !== undefined ? toWholePKR(input.finalCost) : Number(current.final_cost);
    if (finalCost <= 0 && Number(current.advance_paid) === 0) {
      throw badRequest('Set the final cost before delivering (nothing billed yet)');
    }
    const advance = Number(current.advance_paid);
    const remaining = Math.max(0, finalCost - advance);

    if (remaining > 0) {
      await client.query(
        `INSERT INTO payments (payment_type, repair_id, customer_id, method, amount, user_id)
         VALUES ('repair', $1, $2, $3, $4, $5)`,
        [repairId, current.customer_id ?? null, input.paymentMethod ?? 'cash', remaining, user.id],
      );
    }
    if (current.customer_id && finalCost > 0) {
      await appendLedger(client, {
        side: 'customer',
        customerId: String(current.customer_id),
        referenceType: 'repair',
        referenceId: repairId,
        debit: finalCost,
        credit: remaining,
        userId: user.id,
        notes: `Repair ${current.job_no} delivered — billed Rs ${finalCost}`,
      });
    }
    await client.query(
      `UPDATE repairs
          SET final_cost = $1, status = 'delivered', delivered_date = CURRENT_TIMESTAMP,
              notes = COALESCE($2, notes)
        WHERE id = $3`,
      [finalCost, input.notes ?? null, repairId],
    );
    await writeAudit(client, {
      userId: user.id,
      action: 'deliver',
      entityType: 'repair',
      entityId: repairId,
      oldValues: current,
      newValues: { finalCost, collected: remaining },
      req,
    });
    return getRepairInternal(client, repairId);
  });
}

// ---- Service sales (easyload / recharge / bill payment) ----
export async function createServiceSale(
  input: {
    serviceType: string;
    customerPhone?: string | null;
    provider?: string | null;
    amount: number;
    commission?: number;
  },
  user: AuthUser,
  req?: Request,
): Promise<Row> {
  return withTransaction(async (client) => {
    const res = await client.query<Row>(
      `INSERT INTO service_sales (service_type, customer_phone, provider, amount, commission, user_id)
       VALUES ($1,$2,$3,$4,$5,$6) RETURNING *`,
      [
        input.serviceType,
        input.customerPhone ?? null,
        input.provider ?? null,
        toWholePKR(input.amount),
        toWholePKR(input.commission ?? 0),
        user.id,
      ],
    );
    await writeAudit(client, {
      userId: user.id,
      action: 'create',
      entityType: 'service_sale',
      entityId: String(res.rows[0].id),
      newValues: { serviceType: input.serviceType, amount: input.amount },
      req,
    });
    return res.rows[0];
  });
}

export async function listServiceSales(
  filters: { serviceType?: string; from?: string; to?: string },
  pagination: Pagination,
): Promise<{ rows: Row[]; total: number }> {
  const where: string[] = [];
  const params: unknown[] = [];
  if (filters.serviceType) {
    params.push(filters.serviceType);
    where.push(`service_type = $${params.length}`);
  }
  if (filters.from) {
    params.push(filters.from);
    where.push(`sale_date::date >= $${params.length}`);
  }
  if (filters.to) {
    params.push(filters.to);
    where.push(`sale_date::date <= $${params.length}`);
  }
  const whereSql = where.length ? `WHERE ${where.join(' AND ')}` : '';
  const totalRes = await query<{ count: string }>(
    `SELECT COUNT(*)::text AS count FROM service_sales ${whereSql}`,
    params,
  );
  const res = await query<Row>(
    `SELECT ss.*, u.name AS user_name
       FROM service_sales ss JOIN users u ON u.id = ss.user_id
      ${whereSql}
      ORDER BY ss.sale_date DESC
      LIMIT $${params.length + 1} OFFSET $${params.length + 2}`,
    [...params, pagination.limit, pagination.offset],
  );
  return { rows: res.rows, total: Number(totalRes.rows[0].count) };
}
