// Purchases & suppliers service.
// A purchase (one transaction): purchase + items + new IMEI items marked
// available (phones) or quantity added (accessories) + supplier ledger
// (payable) + optional payment + audit log.
import type { PoolClient } from 'pg';
import { query, withTransaction } from '../../config/db';
import { badRequest, conflict, notFound } from '../../middleware/errors';
import { writeAudit } from '../../middleware/audit';
import { appendLedger } from '../sales/service';
import { toWholePKR } from '../../utils/money';
import type { AuthUser, Pagination } from '../../types';
import type { Request } from 'express';

type Row = Record<string, unknown>;

async function resolveBranchId(client: PoolClient, user: AuthUser): Promise<string> {
  if (user.branchId) return user.branchId;
  const res = await client.query<{ id: string }>(
    'SELECT id FROM branches WHERE is_active = TRUE ORDER BY created_at ASC LIMIT 1',
  );
  if (res.rows.length === 0) throw badRequest('No active branch exists');
  return res.rows[0].id;
}

export interface PurchaseItemInput {
  productId: string;
  variantId: string;
  imei1?: string | null;
  imei2?: string | null;
  quantity: number;
  unitCost: number;
}

export interface CreatePurchaseInput {
  supplierId: string;
  supplierInvoiceNo?: string | null;
  items: PurchaseItemInput[];
  discount?: number;
  paidAmount?: number;
  paymentMethod?: string;
  notes?: string | null;
  clientUuid?: string | null;
}

export async function createPurchase(
  input: CreatePurchaseInput,
  user: AuthUser,
  req?: Request,
): Promise<Row> {
  return withTransaction(async (client) => {
    if (input.clientUuid) {
      const existing = await client.query<{ id: string }>(
        'SELECT id FROM purchases WHERE client_uuid = $1',
        [input.clientUuid],
      );
      if (existing.rows.length > 0) return getPurchaseByIdInternal(client, existing.rows[0].id);
    }
    const branchId = await resolveBranchId(client, user);
    const supplierRes = await client.query<Row>(
      'SELECT * FROM suppliers WHERE id = $1 FOR UPDATE',
      [input.supplierId],
    );
    if (supplierRes.rows.length === 0) throw notFound('Supplier not found');
    const supplier = supplierRes.rows[0];
    if (!supplier.is_active) throw badRequest('Supplier is inactive');

    // Validate every line first (locks variants; checks IMEI uniqueness).
    let subtotal = 0;
    for (const item of input.items) {
      const v = await client.query<Row>(
        `SELECT v.*, p.type AS product_type
           FROM product_variants v JOIN products p ON p.id = v.product_id
          WHERE v.id = $1 FOR UPDATE`,
        [item.variantId],
      );
      if (v.rows.length === 0) throw notFound(`Variant not found: ${item.variantId}`);
      const variant = v.rows[0];
      if (String(variant.product_id) !== item.productId) {
        throw badRequest('Variant does not belong to the given product');
      }
      if (variant.product_type === 'phone') {
        if (!item.imei1) throw badRequest('IMEI 1 is required for every phone purchased');
        if (item.quantity !== 1) {
          throw badRequest('Each phone IMEI is a single unit — quantity must be 1');
        }
        const dup = await client.query(
          'SELECT id FROM imei_items WHERE imei1 = $1 OR imei2 = $1',
          [item.imei1],
        );
        if (dup.rows.length > 0) throw conflict(`IMEI ${item.imei1} already exists in stock`);
      }
      subtotal += toWholePKR(item.unitCost) * item.quantity;
    }
    const discount = toWholePKR(input.discount ?? 0);
    if (discount > subtotal) throw badRequest('Discount cannot exceed the subtotal');
    const grandTotal = subtotal - discount;
    const paid = toWholePKR(input.paidAmount ?? 0);
    if (paid > grandTotal) throw badRequest('Paid amount cannot exceed the grand total');
    const balanceDue = grandTotal - paid;

    const purchaseRes = await client.query<Row>(
      `INSERT INTO purchases
         (supplier_id, branch_id, user_id, supplier_invoice_no, subtotal, discount,
          grand_total, paid_amount, balance_due, notes, client_uuid)
       VALUES ($1,$2,$3,$4,$5,$6,$7,$8,$9,$10,$11) RETURNING *`,
      [
        input.supplierId,
        branchId,
        user.id,
        input.supplierInvoiceNo ?? null,
        subtotal,
        discount,
        grandTotal,
        paid,
        balanceDue,
        input.notes ?? null,
        input.clientUuid ?? null,
      ],
    );
    const purchase = purchaseRes.rows[0];

    for (const item of input.items) {
      await client.query(
        `INSERT INTO purchase_items
           (purchase_id, product_id, variant_id, imei1, imei2, quantity, unit_cost, total)
         VALUES ($1,$2,$3,$4,$5,$6,$7,$8)`,
        [
          purchase.id,
          item.productId,
          item.variantId,
          item.imei1 ?? null,
          item.imei2 ?? null,
          item.quantity,
          item.unitCost,
          toWholePKR(item.unitCost) * item.quantity,
        ],
      );
      if (item.imei1) {
        // New phone: one IMEI row, available for sale.
        const vSale = await client.query<{ sale_price: number }>(
          'SELECT sale_price FROM product_variants WHERE id = $1',
          [item.variantId],
        );
        await client.query(
          `INSERT INTO imei_items
             (product_id, variant_id, imei1, imei2, status, purchase_id, purchase_price, sale_price)
           VALUES ($1,$2,$3,$4,'available',$5,$6,$7)`,
          [
            item.productId,
            item.variantId,
            item.imei1,
            item.imei2 ?? null,
            purchase.id,
            item.unitCost,
            Number(vSale.rows[0]?.sale_price ?? item.unitCost),
          ],
        );
      } else {
        await client.query(
          'UPDATE product_variants SET quantity = quantity + $1 WHERE id = $2',
          [item.quantity, item.variantId],
        );
      }
    }

    // Supplier ledger: what we owe increases by (grand - paid).
    await appendLedger(client, {
      side: 'supplier',
      supplierId: String(supplier.id),
      referenceType: 'purchase',
      referenceId: String(purchase.id),
      debit: paid,
      credit: grandTotal,
      userId: user.id,
      notes: `Purchase ${input.supplierInvoiceNo ?? purchase.id}`,
    });
    if (paid > 0) {
      await client.query(
        `INSERT INTO payments (payment_type, purchase_id, supplier_id, method, amount, user_id)
         VALUES ('purchase', $1, $2, $3, $4, $5)`,
        [purchase.id, supplier.id, input.paymentMethod ?? 'cash', paid, user.id],
      );
    }
    await writeAudit(client, {
      userId: user.id,
      action: 'create',
      entityType: 'purchase',
      entityId: String(purchase.id),
      newValues: { supplier: supplier.name, grandTotal, paid },
      req,
    });
    return getPurchaseByIdInternal(client, String(purchase.id));
  });
}

async function getPurchaseByIdInternal(client: PoolClient, id: string): Promise<Row> {
  const res = await client.query<Row>(
    `SELECT p.*, s.name AS supplier_name, u.name AS user_name
       FROM purchases p
       JOIN suppliers s ON s.id = p.supplier_id
       JOIN users u ON u.id = p.user_id
      WHERE p.id = $1`,
    [id],
  );
  if (res.rows.length === 0) throw notFound('Purchase not found');
  const purchase = res.rows[0];
  purchase.items = (
    await client.query<Row>(
      `SELECT pi.*, pr.name AS product_name, v.name AS variant_name
         FROM purchase_items pi
         JOIN products pr ON pr.id = pi.product_id
         JOIN product_variants v ON v.id = pi.variant_id
        WHERE pi.purchase_id = $1 ORDER BY pi.created_at`,
      [id],
    )
  ).rows;
  purchase.payments = (
    await client.query<Row>(
      'SELECT * FROM payments WHERE purchase_id = $1 ORDER BY payment_date',
      [id],
    )
  ).rows;
  return purchase;
}

export async function getPurchaseById(id: string): Promise<Row> {
  return withTransaction(async (client) => getPurchaseByIdInternal(client, id));
}

export async function listPurchases(
  filters: { supplierId?: string; from?: string; to?: string; status?: string },
  pagination: Pagination,
): Promise<{ rows: Row[]; total: number }> {
  const where: string[] = [];
  const params: unknown[] = [];
  if (filters.supplierId) {
    params.push(filters.supplierId);
    where.push(`p.supplier_id = $${params.length}`);
  }
  if (filters.from) {
    params.push(filters.from);
    where.push(`p.purchase_date >= $${params.length}`);
  }
  if (filters.to) {
    params.push(filters.to);
    where.push(`p.purchase_date <= $${params.length}`);
  }
  if (filters.status) {
    params.push(filters.status);
    where.push(`p.status = $${params.length}`);
  }
  const whereSql = where.length ? `WHERE ${where.join(' AND ')}` : '';
  const totalRes = await query<{ count: string }>(
    `SELECT COUNT(*)::text AS count FROM purchases p ${whereSql}`,
    params,
  );
  const res = await query<Row>(
    `SELECT p.*, s.name AS supplier_name,
            (SELECT COUNT(*) FROM purchase_items pi WHERE pi.purchase_id = p.id) AS item_count
       FROM purchases p JOIN suppliers s ON s.id = p.supplier_id
      ${whereSql}
      ORDER BY p.purchase_date DESC
      LIMIT $${params.length + 1} OFFSET $${params.length + 2}`,
    [...params, pagination.limit, pagination.offset],
  );
  return { rows: res.rows, total: Number(totalRes.rows[0].count) };
}

/** Return goods to the supplier: stock is removed and the payable is reduced. */
export async function returnPurchase(
  purchaseId: string,
  lines: { purchaseItemId: string; quantity: number; reason?: string | null }[],
  user: AuthUser,
  req?: Request,
): Promise<Row> {
  return withTransaction(async (client) => {
    const purchaseRes = await client.query<Row>(
      'SELECT * FROM purchases WHERE id = $1 FOR UPDATE',
      [purchaseId],
    );
    if (purchaseRes.rows.length === 0) throw notFound('Purchase not found');
    const purchase = purchaseRes.rows[0];
    if (!['received', 'partially_returned'].includes(String(purchase.status))) {
      throw badRequest(`Cannot return goods on a ${purchase.status} purchase`);
    }
    let totalRefund = 0;
    let fullyReturned = true;
    for (const line of lines) {
      const itemRes = await client.query<Row>(
        'SELECT * FROM purchase_items WHERE id = $1 AND purchase_id = $2 FOR UPDATE',
        [line.purchaseItemId, purchaseId],
      );
      if (itemRes.rows.length === 0) throw notFound(`Purchase item not found: ${line.purchaseItemId}`);
      const item = itemRes.rows[0];
      // Remaining for this LINE, and remaining for the VARIANT in this purchase
      // (a variant can appear on several lines, so both caps are checked).
      const alreadyReturned = await client.query<{ total: string }>(
        `SELECT COALESCE(SUM(quantity), 0)::text AS total
           FROM purchase_returns WHERE purchase_id = $1 AND product_id = $2 AND variant_id = $3`,
        [purchaseId, item.product_id, item.variant_id],
      );
      const purchasedTotal = await client.query<{ total: string }>(
        `SELECT COALESCE(SUM(quantity), 0)::text AS total
           FROM purchase_items WHERE purchase_id = $1 AND product_id = $2 AND variant_id = $3`,
        [purchaseId, item.product_id, item.variant_id],
      );
      const variantRemaining =
        Number(purchasedTotal.rows[0].total) - Number(alreadyReturned.rows[0].total);
      const remaining = Math.min(Number(item.quantity), variantRemaining);
      if (line.quantity > remaining) {
        throw badRequest(`Cannot return ${line.quantity} — only ${remaining} left to return`);
      }
      const refund = toWholePKR(Number(item.unit_cost)) * line.quantity;
      totalRefund += refund;
      let imeiItemId: string | null = null;
      if (item.imei1) {
        const imeiRes = await client.query<{ id: string; status: string }>(
          'SELECT id, status FROM imei_items WHERE imei1 = $1 FOR UPDATE',
          [item.imei1],
        );
        if (imeiRes.rows.length > 0) {
          imeiItemId = imeiRes.rows[0].id;
          if (imeiRes.rows[0].status === 'sold') {
            throw badRequest(`IMEI ${item.imei1} has already been sold and cannot be returned to the supplier`);
          }
          await client.query(
            `UPDATE imei_items SET status = 'returned' WHERE id = $1`,
            [imeiItemId],
          );
        }
      } else {
        await client.query(
          'UPDATE product_variants SET quantity = GREATEST(0, quantity - $1) WHERE id = $2',
          [line.quantity, item.variant_id],
        );
      }
      await client.query(
        `INSERT INTO purchase_returns
           (purchase_id, imei_item_id, product_id, variant_id, quantity, reason, refund_amount, user_id)
         VALUES ($1,$2,$3,$4,$5,$6,$7,$8)`,
        [
          purchaseId,
          imeiItemId,
          item.product_id,
          item.variant_id,
          line.quantity,
          line.reason ?? null,
          refund,
          user.id,
        ],
      );
      if (line.quantity < remaining) fullyReturned = false;
    }
    // Payable reduces by the refund (a debit on the supplier ledger).
    await appendLedger(client, {
      side: 'supplier',
      supplierId: String(purchase.supplier_id),
      referenceType: 'return',
      referenceId: purchaseId,
      debit: totalRefund,
      credit: 0,
      userId: user.id,
      notes: `Purchase return on ${purchase.supplier_invoice_no ?? purchase.id}`,
    });
    const newBalance = Math.max(0, Number(purchase.balance_due) - totalRefund);
    await client.query(
      `UPDATE purchases SET balance_due = $1, status = $2 WHERE id = $3`,
      [newBalance, fullyReturned ? 'returned' : 'partially_returned', purchaseId],
    );
    await writeAudit(client, {
      userId: user.id,
      action: 'return',
      entityType: 'purchase',
      entityId: purchaseId,
      newValues: { refund: totalRefund },
      req,
    });
    return getPurchaseByIdInternal(client, purchaseId);
  });
}

/** Pay a supplier against a purchase's remaining balance. */
export async function paySupplier(
  purchaseId: string,
  input: { amount: number; method: string; reference?: string | null; notes?: string | null },
  user: AuthUser,
  req?: Request,
): Promise<Row> {
  return withTransaction(async (client) => {
    const purchaseRes = await client.query<Row>(
      'SELECT * FROM purchases WHERE id = $1 FOR UPDATE',
      [purchaseId],
    );
    if (purchaseRes.rows.length === 0) throw notFound('Purchase not found');
    const purchase = purchaseRes.rows[0];
    if (Number(purchase.balance_due) <= 0) throw badRequest('This purchase has no remaining balance');
    if (input.amount > Number(purchase.balance_due)) {
      throw badRequest(`Amount exceeds the remaining balance Rs ${purchase.balance_due}`);
    }
    const newPaid = Number(purchase.paid_amount) + input.amount;
    const newBalance = Number(purchase.balance_due) - input.amount;
    await client.query(
      `INSERT INTO payments (payment_type, purchase_id, supplier_id, method, amount, reference, user_id, notes)
       VALUES ('purchase', $1, $2, $3, $4, $5, $6, $7)`,
      [
        purchaseId,
        purchase.supplier_id,
        input.method,
        input.amount,
        input.reference ?? null,
        user.id,
        input.notes ?? null,
      ],
    );
    await client.query(
      'UPDATE purchases SET paid_amount = $1, balance_due = $2 WHERE id = $3',
      [newPaid, newBalance, purchaseId],
    );
    await appendLedger(client, {
      side: 'supplier',
      supplierId: String(purchase.supplier_id),
      referenceType: 'payment',
      referenceId: purchaseId,
      debit: input.amount,
      credit: 0,
      userId: user.id,
      notes: `Payment for purchase ${purchase.supplier_invoice_no ?? purchase.id}`,
    });
    await writeAudit(client, {
      userId: user.id,
      action: 'payment',
      entityType: 'purchase',
      entityId: purchaseId,
      newValues: { amount: input.amount, method: input.method },
      req,
    });
    return getPurchaseByIdInternal(client, purchaseId);
  });
}

// ---- Suppliers ----
export async function listSuppliers(
  search: string | undefined,
  pagination: Pagination,
): Promise<{ rows: Row[]; total: number }> {
  const where: string[] = [];
  const params: unknown[] = [];
  if (search) {
    params.push(`%${search}%`);
    where.push(`(name ILIKE $${params.length} OR phone ILIKE $${params.length})`);
  }
  const whereSql = where.length ? `WHERE ${where.join(' AND ')}` : '';
  const totalRes = await query<{ count: string }>(
    `SELECT COUNT(*)::text AS count FROM suppliers ${whereSql}`,
    params,
  );
  const res = await query<Row>(
    `SELECT s.*,
            COALESCE((
              SELECT SUM(credit - debit) FROM ledger_entries
               WHERE side = 'supplier' AND supplier_id = s.id
            ), s.opening_payable) AS payable_balance
       FROM suppliers s ${whereSql}
      ORDER BY s.name ASC
      LIMIT $${params.length + 1} OFFSET $${params.length + 2}`,
    [...params, pagination.limit, pagination.offset],
  );
  return { rows: res.rows, total: Number(totalRes.rows[0].count) };
}

export async function getSupplier(id: string): Promise<Row> {
  const res = await query<Row>('SELECT * FROM suppliers WHERE id = $1', [id]);
  if (res.rows.length === 0) throw notFound('Supplier not found');
  const supplier = res.rows[0];
  const bal = await query<{ balance: number | null }>(
    `SELECT SUM(credit - debit) AS balance FROM ledger_entries
      WHERE side = 'supplier' AND supplier_id = $1`,
    [id],
  );
  supplier.payable_balance =
    bal.rows[0].balance !== null
      ? Number(bal.rows[0].balance)
      : Number(supplier.opening_payable);
  return supplier;
}

export async function createSupplier(
  input: Record<string, unknown>,
  actor: AuthUser,
  req?: Request,
): Promise<Row> {
  const created = await withTransaction(async (client) => {
    const res = await client.query<Row>(
      `INSERT INTO suppliers (name, phone, address, opening_payable)
       VALUES ($1,$2,$3,$4) RETURNING *`,
      [input.name, input.phone ?? null, input.address ?? null, input.openingPayable ?? 0],
    );
    await writeAudit(client, {
      userId: actor.id,
      action: 'create',
      entityType: 'supplier',
      entityId: String(res.rows[0].id),
      newValues: input,
      req,
    });
    return res.rows[0];
  });
  return created;
}

export async function updateSupplier(
  id: string,
  input: Record<string, unknown>,
  actor: AuthUser,
  req?: Request,
): Promise<Row> {
  return withTransaction(async (client) => {
    const existing = await client.query<Row>('SELECT * FROM suppliers WHERE id = $1', [id]);
    if (existing.rows.length === 0) throw notFound('Supplier not found');
    const sets: string[] = [];
    const params: unknown[] = [];
    const push = (col: string, v: unknown) => {
      params.push(v);
      sets.push(`${col} = $${params.length}`);
    };
    if (input.name !== undefined) push('name', input.name);
    if (input.phone !== undefined) push('phone', input.phone);
    if (input.address !== undefined) push('address', input.address);
    if (input.isActive !== undefined) push('is_active', input.isActive);
    if (sets.length > 0) {
      params.push(id);
      await client.query(`UPDATE suppliers SET ${sets.join(', ')} WHERE id = $${params.length}`, params);
    }
    const updated = await client.query<Row>('SELECT * FROM suppliers WHERE id = $1', [id]);
    await writeAudit(client, {
      userId: actor.id,
      action: 'update',
      entityType: 'supplier',
      entityId: id,
      oldValues: existing.rows[0],
      newValues: input,
      req,
    });
    return updated.rows[0];
  });
}

export async function supplierLedger(
  supplierId: string,
  pagination: Pagination,
): Promise<{ rows: Row[]; total: number; balance: number }> {
  const supplier = await getSupplier(supplierId);
  const totalRes = await query<{ count: string }>(
    `SELECT COUNT(*)::text AS count FROM ledger_entries
      WHERE side = 'supplier' AND supplier_id = $1`,
    [supplierId],
  );
  const res = await query<Row>(
    `SELECT * FROM ledger_entries
      WHERE side = 'supplier' AND supplier_id = $1
      ORDER BY entry_date DESC, created_at DESC
      LIMIT $2 OFFSET $3`,
    [supplierId, pagination.limit, pagination.offset],
  );
  return { rows: res.rows, total: Number(totalRes.rows[0].count), balance: Number(supplier.payable_balance) };
}
