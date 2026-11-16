// Sales / Billing (POS) service.
// The bill is created in ONE database transaction: sale + sale_items +
// IMEI status change + accessory stock deduction + payment + customer
// ledger + audit log. It either fully succeeds or fully rolls back —
// never a half-saved bill.
import type { PoolClient } from 'pg';
import { query, withTransaction } from '../../config/db';
import { ApiError, badRequest, conflict, forbidden, notFound } from '../../middleware/errors';
import { writeAudit } from '../../middleware/audit';
import { nextDocumentNo } from '../../utils/invoiceNo';
import {
  balanceDue,
  calcBillTotals,
  calcLineProfit,
  calcLineTotal,
  paymentStatusFor,
  toWholePKR,
} from '../../utils/money';
import { stripCosts } from '../../utils/sanitize';
import type { AuthUser, Pagination } from '../../types';
import type { Request } from 'express';

type Row = Record<string, unknown>;

/** Resolve the branch for a write: the user's branch, else the first active branch. */
async function resolveBranchId(client: PoolClient, user: AuthUser): Promise<string> {
  if (user.branchId) return user.branchId;
  const res = await client.query<{ id: string }>(
    'SELECT id FROM branches WHERE is_active = TRUE ORDER BY created_at ASC LIMIT 1',
  );
  if (res.rows.length === 0) throw badRequest('No active branch exists');
  return res.rows[0].id;
}

/**
 * Append one ledger entry, computing the running balance. The customer /
 * supplier row is locked first so concurrent writes cannot compute the
 * same balance. If the person has an opening balance and no entries yet,
 * the opening entry is written first so statements are complete.
 */
export async function appendLedger(
  client: PoolClient,
  input: {
    side: 'customer' | 'supplier';
    customerId?: string | null;
    supplierId?: string | null;
    referenceType: string;
    referenceId?: string | null;
    debit: number;
    credit: number;
    userId: string;
    notes?: string | null;
  },
): Promise<number> {
  const isCustomer = input.side === 'customer';
  const personId = isCustomer ? input.customerId : input.supplierId;
  if (!personId) throw badRequest('Ledger entry needs a customer or supplier');

  // Lock the person row: serialises ledger writes for this person.
  const personRes = await client.query<Row>(
    isCustomer
      ? 'SELECT opening_balance FROM customers WHERE id = $1 FOR UPDATE'
      : 'SELECT opening_payable FROM suppliers WHERE id = $1 FOR UPDATE',
    [personId],
  );
  if (personRes.rows.length === 0) throw notFound(isCustomer ? 'Customer not found' : 'Supplier not found');
  const opening = Number(
    isCustomer ? personRes.rows[0].opening_balance : personRes.rows[0].opening_payable,
  );

  // Current balance as a SUM over the person's ledger rows, not the
  // "latest" row: two entries can share an entry_date + created_at
  // (the seed writes such a pair), which makes ORDER BY ... LIMIT 1
  // ambiguous — a supplier purchase once read 944500 instead of
  // 244500 as its previous balance. The sum is order-independent.
  const latest = await client.query<{ count: string; balance: number }>(
    isCustomer
      ? `SELECT COUNT(*)::text AS count,
                COALESCE(SUM(debit - credit), 0)::bigint AS balance
           FROM ledger_entries WHERE customer_id = $1`
      : `SELECT COUNT(*)::text AS count,
                COALESCE(SUM(credit - debit), 0)::bigint AS balance
           FROM ledger_entries WHERE supplier_id = $1`,
    [personId],
  );
  const hasEntries = Number(latest.rows[0].count) > 0;
  let balance = hasEntries ? Number(latest.rows[0].balance) : 0;
  if (!hasEntries && opening !== 0) {
    // First entry: record the opening balance so the statement is complete.
    // Customer opening balance is a debit (the customer owes us);
    // supplier opening payable is a credit (we owe the supplier).
    const openingDebit = isCustomer ? opening : 0;
    const openingCredit = isCustomer ? 0 : opening;
    await client.query(
      `INSERT INTO ledger_entries
         (side, ${isCustomer ? 'customer_id' : 'supplier_id'}, reference_type, debit, credit, balance_after, user_id, notes)
       VALUES ($1, $2, 'opening', $3, $4, $5, $6, 'Opening balance')`,
      [input.side, personId, openingDebit, openingCredit, opening, input.userId],
    );
    balance = opening;
  }
  // Customer: balance grows with debit (goods sold on credit) and shrinks
  // with credit (payments / returns). Supplier: the opposite — the payable
  // grows with credit (goods received) and shrinks with debit (payments /
  // returns). This mirrors DriftPurchaseRepository._supplierLedger and
  // DriftSaleRepository._customerLedger; the old code used debit - credit
  // for both sides, so every supplier purchase REDUCED the payable.
  balance = isCustomer
    ? balance + toWholePKR(input.debit) - toWholePKR(input.credit)
    : balance + toWholePKR(input.credit) - toWholePKR(input.debit);
  await client.query(
    `INSERT INTO ledger_entries
       (side, ${isCustomer ? 'customer_id' : 'supplier_id'}, reference_type, reference_id,
        debit, credit, balance_after, user_id, notes)
     VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9)`,
    [
      input.side,
      personId,
      input.referenceType,
      input.referenceId ?? null,
      toWholePKR(input.debit),
      toWholePKR(input.credit),
      balance,
      input.userId,
      input.notes ?? null,
    ],
  );
  return balance;
}

// ---------------------------------------------------------------------------
// Create a bill
// ---------------------------------------------------------------------------
export interface SaleItemInput {
  variantId: string;
  imeiItemId?: string | null;
  quantity: number;
  unitPrice: number;
  discount?: number;
}

export interface CreateSaleInput {
  customerId?: string | null;
  customerName?: string | null;
  customerPhone?: string | null;
  items: SaleItemInput[];
  discountAmount?: number;
  discountPercent?: number;
  taxAmount?: number;
  paymentMethod: string;
  paidAmount: number;
  adminApprovedBy?: string | null;
  notes?: string | null;
  clientUuid?: string | null;
}

export async function createSale(
  input: CreateSaleInput,
  user: AuthUser,
  req?: Request,
): Promise<Row> {
  return withTransaction(async (client) => {
    // Idempotency (offline sync retry): same client_uuid returns the original bill.
    if (input.clientUuid) {
      const existing = await client.query<{ id: string }>(
        'SELECT id FROM sales WHERE client_uuid = $1',
        [input.clientUuid],
      );
      if (existing.rows.length > 0) {
        return getSaleByIdInternal(client, existing.rows[0].id, user.role);
      }
    }
    const branchId = await resolveBranchId(client, user);

    let customer: Row | null = null;
    if (input.customerId) {
      const r = await client.query<Row>(
        'SELECT * FROM customers WHERE id = $1 FOR UPDATE',
        [input.customerId],
      );
      if (r.rows.length === 0) throw notFound('Customer not found');
      customer = r.rows[0];
    }

    // ---- Validate and price every line (locks variant + IMEI rows) ----
    const prepared: {
      variant: Row;
      imeiRow: Row | null;
      quantity: number;
      unitPrice: number;
      lineDiscount: number;
      lineTotal: number;
      profit: number;
      purchaseCost: number;
      nameSnapshot: string;
    }[] = [];

    for (const item of input.items) {
      const v = await client.query<Row>(
        `SELECT v.*, p.type AS product_type, p.name AS product_name
           FROM product_variants v JOIN products p ON p.id = v.product_id
          WHERE v.id = $1 FOR UPDATE`,
        [item.variantId],
      );
      if (v.rows.length === 0) throw notFound(`Variant not found: ${item.variantId}`);
      const variant = v.rows[0];
      if (!variant.is_active) throw badRequest(`Variant is inactive: ${variant.name}`);

      // Business rule: below minimum price needs an owner/manager approval.
      if (item.unitPrice < Number(variant.min_price)) {
        if (!input.adminApprovedBy) {
          throw new ApiError(
            403,
            `Price Rs ${item.unitPrice} is below the minimum price Rs ${variant.min_price} for ${variant.name}. Admin approval required.`,
            'MIN_PRICE_APPROVAL_REQUIRED',
          );
        }
        const approver = await client.query<{ role_name: string }>(
          `SELECT r.name AS role_name FROM users u JOIN roles r ON r.id = u.role_id
            WHERE u.id = $1 AND u.is_active = TRUE`,
          [input.adminApprovedBy],
        );
        if (
          approver.rows.length === 0 ||
          !['owner', 'manager'].includes(approver.rows[0].role_name)
        ) {
          throw forbidden('Minimum-price approval must come from an owner or manager');
        }
      }

      let purchaseCost = Number(variant.purchase_price);
      let imeiRow: Row | null = null;
      if (variant.product_type === 'phone') {
        if (!item.imeiItemId) throw badRequest('An IMEI is required for every phone sold');
        if (item.quantity !== 1) {
          throw badRequest('Each phone IMEI is a single unit — quantity must be 1');
        }
        const ir = await client.query<Row>(
          'SELECT * FROM imei_items WHERE id = $1 FOR UPDATE',
          [item.imeiItemId],
        );
        if (ir.rows.length === 0) throw notFound(`IMEI item not found: ${item.imeiItemId}`);
        imeiRow = ir.rows[0];
        // Business rule: a sold IMEI can never be sold again.
        if (imeiRow.status !== 'available') {
          throw conflict(
            `IMEI ${imeiRow.imei1} is not available (status: ${imeiRow.status})`,
          );
        }
        if (String(imeiRow.variant_id) !== String(item.variantId)) {
          throw badRequest('The IMEI does not belong to the selected variant');
        }
        purchaseCost = Number(imeiRow.purchase_price);
      } else {
        if (Number(variant.quantity) < item.quantity) {
          throw conflict(
            `Insufficient stock for ${variant.name} (have ${variant.quantity}, need ${item.quantity})`,
          );
        }
      }

      const lineDiscount = item.discount ?? 0;
      const lineTotal = calcLineTotal(item.unitPrice, item.quantity, lineDiscount);
      const profit = calcLineProfit(item.unitPrice, purchaseCost, item.quantity, lineDiscount);
      prepared.push({
        variant,
        imeiRow,
        quantity: item.quantity,
        unitPrice: item.unitPrice,
        lineDiscount,
        lineTotal,
        profit,
        purchaseCost,
        nameSnapshot: `${variant.product_name} — ${variant.name}`,
      });
    }

    const totals = calcBillTotals({
      lineTotals: prepared.map((p) => p.lineTotal),
      discountAmount: input.discountAmount ?? 0,
      discountPercent: input.discountPercent ?? 0,
      taxAmount: input.taxAmount ?? 0,
    });

    // ---- Payment rules ----
    const paid = toWholePKR(input.paidAmount ?? 0);
    if (paid > totals.grandTotal) throw badRequest('Paid amount cannot exceed the grand total');
    if (input.paymentMethod === 'udhaar' && paid !== 0) {
      throw badRequest('An udhaar (credit) bill must have paid amount 0');
    }
    if (input.paymentMethod === 'partial' && (paid <= 0 || paid >= totals.grandTotal)) {
      throw badRequest('A partial payment must be more than 0 and less than the grand total');
    }
    if (
      ['cash', 'jazzcash', 'easypaisa', 'bank_transfer', 'card'].includes(input.paymentMethod) &&
      paid !== totals.grandTotal
    ) {
      throw badRequest('Full payment methods require the full grand total to be paid');
    }
    const due = balanceDue(totals.grandTotal, paid);
    const paymentStatus = paymentStatusFor(paid, totals.grandTotal);

    const invoiceNo = await nextDocumentNo(client, branchId, 'sale_invoice', 'INV');
    const saleRes = await client.query<Row>(
      `INSERT INTO sales
         (invoice_no, branch_id, customer_id, customer_name, customer_phone, user_id,
          subtotal, discount_amount, discount_percent, tax_amount, grand_total,
          paid_amount, balance_due, payment_method, payment_status, status, notes, client_uuid)
       VALUES ($1,$2,$3,$4,$5,$6,$7,$8,$9,$10,$11,$12,$13,$14,$15,'completed',$16,$17)
       RETURNING *`,
      [
        invoiceNo,
        branchId,
        customer?.id ?? null,
        input.customerName ?? (customer ? String(customer.name) : null),
        input.customerPhone ?? (customer ? String(customer.phone) : null),
        user.id,
        totals.subtotal,
        totals.discountAmount,
        input.discountPercent ?? 0,
        totals.taxAmount,
        totals.grandTotal,
        paid,
        due,
        input.paymentMethod,
        paymentStatus,
        input.notes ?? null,
        input.clientUuid ?? null,
      ],
    );
    const sale = saleRes.rows[0];

    for (const p of prepared) {
      await client.query(
        `INSERT INTO sale_items
           (sale_id, product_id, variant_id, imei_item_id, name_snapshot, quantity,
            unit_price, purchase_cost, discount, total, profit)
         VALUES ($1,$2,$3,$4,$5,$6,$7,$8,$9,$10,$11)`,
        [
          sale.id,
          p.variant.product_id,
          p.variant.id,
          p.imeiRow ? p.imeiRow.id : null,
          p.nameSnapshot,
          p.quantity,
          p.unitPrice,
          p.purchaseCost,
          p.lineDiscount,
          p.lineTotal,
          p.profit,
        ],
      );
      // Stock movement (same transaction as the bill).
      if (p.imeiRow) {
        await client.query(
          `UPDATE imei_items SET status = 'sold', sold_sale_id = $1 WHERE id = $2`,
          [sale.id, p.imeiRow.id],
        );
      } else {
        await client.query(
          'UPDATE product_variants SET quantity = quantity - $1 WHERE id = $2',
          [p.quantity, p.variant.id],
        );
      }
    }

    if (paid > 0) {
      await client.query(
        `INSERT INTO payments (payment_type, sale_id, customer_id, method, amount, user_id)
         VALUES ('sale', $1, $2, $3, $4, $5)`,
        [sale.id, customer?.id ?? null, input.paymentMethod, paid, user.id],
      );
    }
    if (customer && due > 0) {
      await appendLedger(client, {
        side: 'customer',
        customerId: String(customer.id),
        referenceType: 'sale',
        referenceId: String(sale.id),
        debit: due,
        credit: 0,
        userId: user.id,
        notes: `Bill ${invoiceNo}`,
      });
    }
    await writeAudit(client, {
      userId: user.id,
      action: 'sale',
      entityType: 'sale',
      entityId: String(sale.id),
      newValues: { invoiceNo, grandTotal: totals.grandTotal, paid, method: input.paymentMethod },
      req,
    });
    return getSaleByIdInternal(client, String(sale.id), user.role);
  });
}

// ---------------------------------------------------------------------------
// Read a bill (with items + payments)
// ---------------------------------------------------------------------------
async function getSaleByIdInternal(
  client: PoolClient,
  saleId: string,
  role: string,
): Promise<Row> {
  const saleRes = await client.query<Row>(
    `SELECT s.*, u.name AS cashier_name, c.name AS customer_full_name
       FROM sales s
       JOIN users u ON u.id = s.user_id
       LEFT JOIN customers c ON c.id = s.customer_id
      WHERE s.id = $1`,
    [saleId],
  );
  if (saleRes.rows.length === 0) throw notFound('Sale not found');
  const sale = saleRes.rows[0];
  const items = await client.query<Row>(
    `SELECT si.*, i.imei1, i.imei2
       FROM sale_items si LEFT JOIN imei_items i ON i.id = si.imei_item_id
      WHERE si.sale_id = $1 ORDER BY si.created_at`,
    [saleId],
  );
  const payments = await client.query<Row>(
    `SELECT * FROM payments WHERE sale_id = $1 ORDER BY payment_date`,
    [saleId],
  );
  const returns = await client.query<Row>(
    'SELECT * FROM sale_returns WHERE sale_id = $1 ORDER BY created_at',
    [saleId],
  );
  sale.items = items.rows.map((r) => stripCosts(r, role));
  sale.payments = payments.rows;
  sale.returns = returns.rows;
  return stripCosts(sale, role);
}

export async function getSaleById(id: string, role: string): Promise<Row> {
  return withTransaction(async (client) => getSaleByIdInternal(client, id, role));
}

export async function listSales(
  filters: {
    from?: string;
    to?: string;
    customerId?: string;
    status?: string;
    paymentStatus?: string;
    branchId?: string;
    search?: string;
  },
  pagination: Pagination,
  role: string,
): Promise<{ rows: Row[]; total: number }> {
  const where: string[] = [];
  const params: unknown[] = [];
  if (filters.from) {
    params.push(filters.from);
    where.push(`s.sale_date >= $${params.length}`);
  }
  if (filters.to) {
    params.push(filters.to);
    where.push(`s.sale_date <= $${params.length}`);
  }
  if (filters.customerId) {
    params.push(filters.customerId);
    where.push(`s.customer_id = $${params.length}`);
  }
  if (filters.status) {
    params.push(filters.status);
    where.push(`s.status = $${params.length}`);
  }
  if (filters.paymentStatus) {
    params.push(filters.paymentStatus);
    where.push(`s.payment_status = $${params.length}`);
  }
  if (filters.branchId) {
    params.push(filters.branchId);
    where.push(`s.branch_id = $${params.length}`);
  }
  if (filters.search) {
    params.push(`%${filters.search}%`);
    where.push(`(s.invoice_no ILIKE $${params.length} OR s.customer_name ILIKE $${params.length} OR s.customer_phone ILIKE $${params.length})`);
  }
  const whereSql = where.length ? `WHERE ${where.join(' AND ')}` : '';
  const totalRes = await query<{ count: string }>(
    `SELECT COUNT(*)::text AS count FROM sales s ${whereSql}`,
    params,
  );
  const res = await query<Row>(
    `SELECT s.*, u.name AS cashier_name,
            (SELECT COUNT(*) FROM sale_items si WHERE si.sale_id = s.id) AS item_count
       FROM sales s JOIN users u ON u.id = s.user_id
      ${whereSql}
      ORDER BY s.sale_date DESC
      LIMIT $${params.length + 1} OFFSET $${params.length + 2}`,
    [...params, pagination.limit, pagination.offset],
  );
  return { rows: res.rows.map((r) => stripCosts(r, role)), total: Number(totalRes.rows[0].count) };
}

// ---------------------------------------------------------------------------
// Returns / exchange / cancel
// ---------------------------------------------------------------------------
interface ReturnLine {
  saleItemId: string;
  quantity: number;
  reason?: string | null;
}

/**
 * Reverse part (or all) of a bill: restock, refund, ledger credit.
 * Shared by the return endpoint and by cancel (which returns everything).
 * Returns the total refunded amount.
 */
async function applyReturn(
  client: PoolClient,
  sale: Row,
  lines: ReturnLine[],
  user: AuthUser,
  opts: { exchangeSaleId?: string | null; reason?: string | null; req?: Request },
): Promise<number> {
  let totalRefund = 0;
  for (const line of lines) {
    const itemRes = await client.query<Row>(
      'SELECT * FROM sale_items WHERE id = $1 AND sale_id = $2 FOR UPDATE',
      [line.saleItemId, sale.id],
    );
    if (itemRes.rows.length === 0) throw notFound(`Sale item not found: ${line.saleItemId}`);
    const item = itemRes.rows[0];
    const alreadyReturned = await client.query<{ total: string }>(
      'SELECT COALESCE(SUM(quantity), 0)::text AS total FROM sale_returns WHERE sale_item_id = $1',
      [line.saleItemId],
    );
    const remaining = Number(item.quantity) - Number(alreadyReturned.rows[0].total);
    if (line.quantity > remaining) {
      throw badRequest(
        `Cannot return ${line.quantity} of ${item.name_snapshot} — only ${remaining} left to return`,
      );
    }
    // Refund = pro-rata share of the line total.
    const refund = Math.round((Number(item.total) / Number(item.quantity)) * line.quantity);
    totalRefund += refund;
    await client.query(
      `INSERT INTO sale_returns
         (sale_id, sale_item_id, imei_item_id, quantity, reason, refund_amount, is_exchange, exchange_sale_id, user_id)
       VALUES ($1,$2,$3,$4,$5,$6,$7,$8,$9)`,
      [
        sale.id,
        line.saleItemId,
        item.imei_item_id ?? null,
        line.quantity,
        line.reason ?? opts.reason ?? null,
        refund,
        opts.exchangeSaleId ? true : false,
        opts.exchangeSaleId ?? null,
        user.id,
      ],
    );
    // Restock: IMEI back to available; accessory quantity back.
    if (item.imei_item_id) {
      await client.query(
        `UPDATE imei_items SET status = 'available', sold_sale_id = NULL WHERE id = $1`,
        [item.imei_item_id],
      );
    } else if (item.variant_id) {
      await client.query(
        'UPDATE product_variants SET quantity = quantity + $1 WHERE id = $2',
        [line.quantity, item.variant_id],
      );
    }
    // The returned goods are no longer profit: shrink the line's profit
    // pro-rata, so dashboard / P&L totals (which sum sale_items.profit
    // for non-cancelled sales) stop counting returned goods. This also
    // runs for cancel (which returns everything); a cancelled bill's
    // profit is 0, which is honest — it is excluded from reports anyway.
    const profitReduction = Math.round(
      (Number(item.profit ?? 0) / Number(item.quantity)) * line.quantity,
    );
    if (profitReduction !== 0) {
      await client.query(
        `UPDATE sale_items SET profit = GREATEST(0, profit - $1) WHERE id = $2`,
        [profitReduction, line.saleItemId],
      );
    }
  }
  return totalRefund;
}

export async function returnSale(
  saleId: string,
  lines: ReturnLine[],
  user: AuthUser,
  opts: { exchangeSaleId?: string | null; req?: Request },
): Promise<Row> {
  return withTransaction(async (client) => {
    const saleRes = await client.query<Row>('SELECT * FROM sales WHERE id = $1 FOR UPDATE', [saleId]);
    if (saleRes.rows.length === 0) throw notFound('Sale not found');
    const sale = saleRes.rows[0];
    if (!['completed', 'partially_returned'].includes(String(sale.status))) {
      throw badRequest(`Cannot return a ${sale.status} bill`);
    }
    const totalRefund = await applyReturn(client, sale, lines, user, opts);
    // Split the refund: first from what was paid (cash out), then from what was owed.
    const refundFromPaid = Math.min(totalRefund, Number(sale.paid_amount));
    const refundFromBalance = totalRefund - refundFromPaid;
    const newPaid = Number(sale.paid_amount) - refundFromPaid;
    const newBalance = Math.max(0, Number(sale.balance_due) - refundFromBalance);
    // A return reverses the sale: the returned goods are no longer
    // revenue, so the bill total shrinks by the refund (mirrors the
    // Flutter repository, which reduces grand_total on return). Reports
    // sum grand_total for non-cancelled sales, so without this a fully
    // returned bill still counted as revenue and profit.
    const newGrandTotal = Math.max(0, Number(sale.grand_total) - totalRefund);
    // Was everything returned?
    const remaining = await client.query<{ left: string }>(
      `SELECT COALESCE(SUM(si.quantity - COALESCE(r.returned_qty, 0)), 0)::text AS left
         FROM sale_items si
         LEFT JOIN (SELECT sale_item_id, SUM(quantity) AS returned_qty FROM sale_returns GROUP BY sale_item_id) r
           ON r.sale_item_id = si.id
        WHERE si.sale_id = $1`,
      [saleId],
    );
    const newStatus = Number(remaining.rows[0].left) === 0 ? 'returned' : 'partially_returned';
    await client.query(
      `UPDATE sales SET paid_amount = $1, balance_due = $2, payment_status = $3, status = $4, grand_total = $5 WHERE id = $6`,
      [newPaid, newBalance, paymentStatusFor(newPaid, newGrandTotal), newStatus, newGrandTotal, saleId],
    );
    if (refundFromBalance > 0 && sale.customer_id) {
      await appendLedger(client, {
        side: 'customer',
        customerId: String(sale.customer_id),
        referenceType: 'return',
        referenceId: saleId,
        debit: 0,
        credit: refundFromBalance,
        userId: user.id,
        notes: `Return on bill ${sale.invoice_no}`,
      });
    }
    if (refundFromPaid > 0) {
      // Cash out of today's open register (best effort — no register, no entry).
      const reg = await client.query<{ id: string }>(
        `SELECT id FROM cash_register WHERE branch_id = $1 AND register_date = CURRENT_DATE AND status = 'open' LIMIT 1`,
        [sale.branch_id],
      );
      if (reg.rows.length > 0) {
        await client.query(
          `INSERT INTO cash_movements (register_id, type, amount, reason, user_id)
           VALUES ($1, 'out', $2, $3, $4)`,
          [reg.rows[0].id, refundFromPaid, `Return on bill ${sale.invoice_no}`, user.id],
        );
      }
    }
    await writeAudit(client, {
      userId: user.id,
      action: 'return',
      entityType: 'sale',
      entityId: saleId,
      newValues: { refund: totalRefund, status: newStatus },
      req: opts.req,
    });
    return getSaleByIdInternal(client, saleId, user.role);
  });
}

/** Cancel a whole bill (owner/manager only). Reverses everything, like a
 *  full return, then marks the bill cancelled. */
export async function cancelSale(
  saleId: string,
  user: AuthUser,
  req?: Request,
): Promise<Row> {
  return withTransaction(async (client) => {
    const saleRes = await client.query<Row>('SELECT * FROM sales WHERE id = $1 FOR UPDATE', [saleId]);
    if (saleRes.rows.length === 0) throw notFound('Sale not found');
    const sale = saleRes.rows[0];
    if (String(sale.status) !== 'completed') {
      throw badRequest(`Cannot cancel a ${sale.status} bill`);
    }
    const items = await client.query<Row>(
      `SELECT si.*,
              COALESCE(SUM(sr.quantity), 0) AS returned_qty
         FROM sale_items si
         LEFT JOIN sale_returns sr ON sr.sale_item_id = si.id
        WHERE si.sale_id = $1 GROUP BY si.id`,
      [saleId],
    );
    const lines: ReturnLine[] = items.rows
      .filter((i) => Number(i.quantity) - Number(i.returned_qty) > 0)
      .map((i) => ({
        saleItemId: String(i.id),
        quantity: Number(i.quantity) - Number(i.returned_qty),
        reason: 'Bill cancelled',
      }));
    if (lines.length > 0) {
      await applyReturn(client, sale, lines, user, { reason: 'Bill cancelled', req });
    }
    await client.query(
      `UPDATE sales SET status = 'cancelled', paid_amount = 0, balance_due = 0,
         payment_status = 'unpaid' WHERE id = $1`,
      [saleId],
    );
    // Refund the cash that was already collected (if any) via today's register.
    if (Number(sale.paid_amount) > 0) {
      const reg = await client.query<{ id: string }>(
        `SELECT id FROM cash_register WHERE branch_id = $1 AND register_date = CURRENT_DATE AND status = 'open' LIMIT 1`,
        [sale.branch_id],
      );
      if (reg.rows.length > 0) {
        await client.query(
          `INSERT INTO cash_movements (register_id, type, amount, reason, user_id)
           VALUES ($1, 'out', $2, $3, $4)`,
          [reg.rows[0].id, Number(sale.paid_amount), `Bill ${sale.invoice_no} cancelled — cash refund`, user.id],
        );
      }
    }
    if (sale.customer_id && Number(sale.balance_due) > 0) {
      await appendLedger(client, {
        side: 'customer',
        customerId: String(sale.customer_id),
        referenceType: 'return',
        referenceId: saleId,
        debit: 0,
        credit: Number(sale.balance_due),
        userId: user.id,
        notes: `Bill ${sale.invoice_no} cancelled`,
      });
    }
    await writeAudit(client, {
      userId: user.id,
      action: 'cancel',
      entityType: 'sale',
      entityId: saleId,
      req,
    });
    return getSaleByIdInternal(client, saleId, user.role);
  });
}

// ---------------------------------------------------------------------------
// Udhaar recovery: record a payment against a bill's remaining balance
// ---------------------------------------------------------------------------
export async function recordSalePayment(
  saleId: string,
  input: { amount: number; method: string; reference?: string | null; notes?: string | null },
  user: AuthUser,
  req?: Request,
): Promise<Row> {
  return withTransaction(async (client) => {
    const saleRes = await client.query<Row>('SELECT * FROM sales WHERE id = $1 FOR UPDATE', [saleId]);
    if (saleRes.rows.length === 0) throw notFound('Sale not found');
    const sale = saleRes.rows[0];
    if (String(sale.status) === 'cancelled') throw badRequest('Cannot take payment on a cancelled bill');
    if (Number(sale.balance_due) <= 0) throw badRequest('This bill has no remaining balance');
    if (input.amount > Number(sale.balance_due)) {
      throw badRequest(`Amount exceeds the remaining balance Rs ${sale.balance_due}`);
    }
    const newPaid = Number(sale.paid_amount) + input.amount;
    const newBalance = Number(sale.balance_due) - input.amount;
    await client.query(
      `INSERT INTO payments (payment_type, sale_id, customer_id, method, amount, reference, user_id, notes)
       VALUES ('udhaar_recovery', $1, $2, $3, $4, $5, $6, $7)`,
      [
        saleId,
        sale.customer_id ?? null,
        input.method,
        input.amount,
        input.reference ?? null,
        user.id,
        input.notes ?? null,
      ],
    );
    await client.query(
      `UPDATE sales SET paid_amount = $1, balance_due = $2, payment_status = $3 WHERE id = $4`,
      [newPaid, newBalance, paymentStatusFor(newPaid, Number(sale.grand_total)), saleId],
    );
    if (sale.customer_id) {
      await appendLedger(client, {
        side: 'customer',
        customerId: String(sale.customer_id),
        referenceType: 'payment',
        referenceId: saleId,
        debit: 0,
        credit: input.amount,
        userId: user.id,
        notes: `Payment on bill ${sale.invoice_no}`,
      });
    }
    await writeAudit(client, {
      userId: user.id,
      action: 'payment',
      entityType: 'sale',
      entityId: saleId,
      newValues: { amount: input.amount, method: input.method },
      req,
    });
    return getSaleByIdInternal(client, saleId, user.role);
  });
}

// ---------------------------------------------------------------------------
// Held bills (park a bill, resume it later)
// ---------------------------------------------------------------------------
export async function holdBill(
  input: { customerName?: string | null; cart: Record<string, unknown>[] },
  user: AuthUser,
): Promise<Row> {
  const res = await query<Row>(
    `INSERT INTO held_bills (branch_id, user_id, customer_name, cart)
     VALUES ($1, $2, $3, $4::jsonb) RETURNING *`,
    [user.branchId, user.id, input.customerName ?? null, JSON.stringify(input.cart)],
  );
  return res.rows[0];
}

export async function listHeldBills(user: AuthUser): Promise<Row[]> {
  const res = await query<Row>(
    `SELECT hb.*, u.name AS user_name FROM held_bills hb JOIN users u ON u.id = hb.user_id
      WHERE hb.branch_id = $1 OR $1 IS NULL ORDER BY hb.created_at DESC`,
    [user.branchId],
  );
  return res.rows;
}

export async function resumeHeldBill(id: string): Promise<Row> {
  return withTransaction(async (client) => {
    const res = await client.query<Row>('SELECT * FROM held_bills WHERE id = $1', [id]);
    if (res.rows.length === 0) throw notFound('Held bill not found');
    await client.query('DELETE FROM held_bills WHERE id = $1', [id]);
    return res.rows[0];
  });
}

export async function deleteHeldBill(id: string): Promise<void> {
  const res = await query('DELETE FROM held_bills WHERE id = $1 RETURNING id', [id]);
  if (res.rows.length === 0) throw notFound('Held bill not found');
}

// ---------------------------------------------------------------------------
// Invoice data for thermal printing / PDF / WhatsApp share
// ---------------------------------------------------------------------------
export async function getInvoiceData(id: string, role: string): Promise<Row> {
  const sale = await getSaleById(id, role);
  const settingsRes = await query<{ key: string; value: unknown }>(
    `SELECT key, value FROM settings WHERE key LIKE 'shop.%' OR key LIKE 'tax.%' OR key LIKE 'invoice.%'`,
  );
  const shop: Record<string, unknown> = {};
  for (const r of settingsRes.rows) shop[r.key] = r.value;
  return { shop, sale };
}
