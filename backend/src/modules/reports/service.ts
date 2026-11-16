// Reports & dashboard — read-only aggregates over sales, stock, ledgers.
// Schema notes (database/schema.sql):
// - sales has NO profit_total column — profit lives on sale_items.profit,
//   so profit is always summed from sale_items joined to non-cancelled sales.
// - products.brand is a FK (brand_id -> brands); the brand name comes from
//   the brands table. products.type is TEXT ('phone' / 'accessory').
// - product_variants low-stock column is low_stock_threshold (not min_stock).
// - salaries live in salary_payments (amount, paid_date, month TEXT 'YYYY-MM');
//   no branch_id, no net_amount. P&L uses SUM(amount) by paid_date.
// - sale_returns has no return_date — use created_at.
import { query } from '../../config/db';

type Row = Record<string, unknown>;

export async function dashboard(
  branchId: string | undefined,
  userBranchId: string | null | undefined,
): Promise<Row> {
  const branch = branchId ?? userBranchId ?? undefined;
  const params: unknown[] = branch ? [branch] : [];
  const branchSql = branch ? ' AND s.branch_id = $1' : '';
  const sales = await query<Row>(
    `SELECT
       COALESCE(SUM(CASE WHEN s.sale_date::date = CURRENT_DATE THEN s.grand_total ELSE 0 END), 0)::bigint AS today_sales,
       COUNT(CASE WHEN s.sale_date::date = CURRENT_DATE THEN 1 END)::bigint AS today_bills,
       COALESCE(SUM(CASE WHEN s.sale_date::date >= DATE_TRUNC('month', CURRENT_DATE) THEN s.grand_total ELSE 0 END), 0)::bigint AS month_sales,
       COALESCE(SUM(s.balance_due), 0)::bigint AS total_udhaar
       FROM sales s WHERE s.status <> 'cancelled'${branchSql}`,
    params,
  );
  const monthProfit = await query<Row>(
    `SELECT COALESCE(SUM(si.profit), 0)::bigint AS month_profit
       FROM sale_items si JOIN sales s ON s.id = si.sale_id
      WHERE s.status <> 'cancelled'
        AND s.sale_date::date >= DATE_TRUNC('month', CURRENT_DATE)${branchSql}`,
    params,
  );
  const stock = await query<Row>(
    `SELECT
       COALESCE(SUM(v.quantity * v.purchase_price), 0)::bigint AS stock_value_cost,
       COALESCE(SUM(v.quantity * v.sale_price), 0)::bigint AS stock_value_sale,
       COUNT(*) FILTER (WHERE v.quantity <= v.low_stock_threshold)::bigint AS low_stock_count,
       COUNT(*) FILTER (WHERE v.quantity = 0)::bigint AS out_of_stock_count
       FROM product_variants v
       JOIN products p ON p.id = v.product_id
      WHERE p.is_active = TRUE`,
  );
  const imei = await query<Row>(
    `SELECT COUNT(*)::bigint AS phones_in_stock
       FROM imei_items WHERE status = 'available'`,
  );
  const repairs = await query<Row>(
    `SELECT COUNT(*) FILTER (WHERE status NOT IN ('delivered','cancelled'))::bigint AS open_jobs,
            COUNT(*) FILTER (WHERE status = 'ready')::bigint AS ready_pickup
       FROM repairs`,
  );
  const installments = await query<Row>(
    `SELECT COUNT(*)::bigint AS overdue_count,
            COALESCE(SUM(amount - paid_amount), 0)::bigint AS overdue_amount
       FROM installment_payments
      WHERE due_date < CURRENT_DATE AND status IN ('pending', 'partial', 'overdue')`,
  );
  return {
    ...sales.rows[0],
    ...monthProfit.rows[0],
    ...stock.rows[0],
    ...imei.rows[0],
    ...repairs.rows[0],
    ...installments.rows[0],
  };
}

export async function salesByPeriod(
  branchId: string | undefined,
  userBranchId: string | null | undefined,
  from: string | undefined,
  to: string | undefined,
  groupBy: 'day' | 'week' | 'month',
): Promise<Row[]> {
  const branch = branchId ?? userBranchId ?? undefined;
  const params: unknown[] = [];
  const where: string[] = [`s.status <> 'cancelled'`];
  if (branch) {
    params.push(branch);
    where.push(`s.branch_id = $${params.length}`);
  }
  if (from) {
    params.push(from);
    where.push(`s.sale_date::date >= $${params.length}`);
  }
  if (to) {
    params.push(to);
    where.push(`s.sale_date::date <= $${params.length}`);
  }
  const bucket =
    groupBy === 'week'
      ? `DATE_TRUNC('week', s.sale_date)`
      : groupBy === 'month'
        ? `DATE_TRUNC('month', s.sale_date)`
        : `DATE_TRUNC('day', s.sale_date)`;
  // Period totals (profit is summed from sale_items in a separate query —
  // sales has no profit_total column).
  const res = await query<Row>(
    `SELECT ${bucket}::date AS period,
            COUNT(*)::bigint AS bills,
            COALESCE(SUM(s.grand_total), 0)::bigint AS total_sales,
            COALESCE(SUM(s.paid_amount), 0)::bigint AS total_paid,
            COALESCE(SUM(s.balance_due), 0)::bigint AS total_udhaar
       FROM sales s
      WHERE ${where.join(' AND ')}
      GROUP BY ${bucket}
      ORDER BY period ASC`,
    params,
  );
  const profitRes = await query<{ period: string; total_profit: number }>(
    `SELECT ${bucket}::date AS period,
            COALESCE(SUM(si.profit), 0)::bigint AS total_profit
       FROM sales s JOIN sale_items si ON si.sale_id = s.id
      WHERE ${where.join(' AND ')}
      GROUP BY ${bucket}
      ORDER BY period ASC`,
    params,
  );
  const profitByPeriod = new Map<string, number>();
  for (const r of profitRes.rows) profitByPeriod.set(String(r.period), Number(r.total_profit));
  return res.rows.map((r) => ({
    ...r,
    total_profit: profitByPeriod.get(String(r.period)) ?? 0,
  }));
}

export async function profitAndLoss(
  branchId: string | undefined,
  userBranchId: string | null | undefined,
  from: string,
  to: string,
): Promise<Row> {
  const branch = branchId ?? userBranchId ?? undefined;
  const params: unknown[] = [from, to];
  const salesWhere = [`s.status <> 'cancelled'`, `s.sale_date::date BETWEEN $1 AND $2`];
  if (branch) {
    params.push(branch);
    salesWhere.push(`s.branch_id = $${params.length}`);
  }
  const sales = await query<Row>(
    `SELECT COALESCE(SUM(s.grand_total), 0)::bigint AS revenue,
            COALESCE(SUM(s.discount_amount), 0)::bigint AS discounts,
            COUNT(*)::bigint AS bills
       FROM sales s WHERE ${salesWhere.join(' AND ')}`,
    params,
  );
  const profit = await query<Row>(
    `SELECT COALESCE(SUM(si.profit), 0)::bigint AS gross_profit
       FROM sale_items si JOIN sales s ON s.id = si.sale_id
      WHERE ${salesWhere.join(' AND ')}`,
    params,
  );
  const expenses = await query<Row>(
    `SELECT COALESCE(SUM(e.amount), 0)::bigint AS total_expenses
       FROM expenses e
      WHERE e.expense_date::date BETWEEN $1 AND $2
        ${branch ? 'AND e.branch_id = $3' : ''}`,
    branch ? [from, to, branch] : [from, to],
  );
  // Salaries have no branch_id; P&L uses the amount paid in the period.
  const salaries = await query<Row>(
    `SELECT COALESCE(SUM(sp.amount), 0)::bigint AS total_salaries
       FROM salary_payments sp WHERE sp.paid_date::date BETWEEN $1 AND $2`,
    [from, to],
  );
  const revenue = Number(sales.rows[0].revenue);
  const grossProfit = Number(profit.rows[0].gross_profit);
  const totalExpenses = Number(expenses.rows[0].total_expenses);
  const totalSalaries = Number(salaries.rows[0].total_salaries);
  const netProfit = grossProfit - totalExpenses - totalSalaries;
  return {
    from,
    to,
    revenue,
    grossProfit,
    discounts: Number(sales.rows[0].discounts),
    bills: Number(sales.rows[0].bills),
    totalExpenses,
    totalSalaries,
    netProfit,
    netMarginPercent: revenue > 0 ? Math.round((netProfit / revenue) * 10000) / 100 : 0,
  };
}

export async function stockValuation(): Promise<Row[]> {
  const res = await query<Row>(
    `SELECT p.id AS product_id, p.name AS product_name, b.name AS brand, p.type,
            COALESCE(SUM(v.quantity), 0)::bigint AS total_qty,
            COALESCE(SUM(v.quantity * v.purchase_price), 0)::bigint AS value_at_cost,
            COALESCE(SUM(v.quantity * v.sale_price), 0)::bigint AS value_at_sale
       FROM products p
       LEFT JOIN brands b ON b.id = p.brand_id
       JOIN product_variants v ON v.product_id = p.id
      WHERE p.is_active = TRUE
      GROUP BY p.id, p.name, b.name, p.type
      ORDER BY value_at_cost DESC`,
  );
  return res.rows;
}

export async function brandModelSales(
  branchId: string | undefined,
  userBranchId: string | null | undefined,
  from: string | undefined,
  to: string | undefined,
): Promise<Row[]> {
  const branch = branchId ?? userBranchId ?? undefined;
  const params: unknown[] = [];
  const where: string[] = [`s.status <> 'cancelled'`];
  if (branch) {
    params.push(branch);
    where.push(`s.branch_id = $${params.length}`);
  }
  if (from) {
    params.push(from);
    where.push(`s.sale_date::date >= $${params.length}`);
  }
  if (to) {
    params.push(to);
    where.push(`s.sale_date::date <= $${params.length}`);
  }
  const res = await query<Row>(
    `SELECT b.name AS brand, p.name AS model, p.type,
            COALESCE(SUM(si.quantity - COALESCE(r.returned_qty, 0)), 0)::bigint AS units_sold,
            COALESCE(SUM(si.total - COALESCE(r.refunded, 0)), 0)::bigint AS revenue,
            COALESCE(SUM(si.profit), 0)::bigint AS profit
       FROM sale_items si
       JOIN sales s ON s.id = si.sale_id
       JOIN products p ON p.id = si.product_id
       LEFT JOIN brands b ON b.id = p.brand_id
       LEFT JOIN (SELECT sale_item_id, SUM(quantity) AS returned_qty,
                         SUM(refund_amount) AS refunded
                    FROM sale_returns GROUP BY sale_item_id) r
              ON r.sale_item_id = si.id
      WHERE ${where.join(' AND ')}
      GROUP BY b.name, p.name, p.type
      ORDER BY revenue DESC`,
    params,
  );
  return res.rows;
}

export async function bestSellers(
  branchId: string | undefined,
  userBranchId: string | null | undefined,
  from: string | undefined,
  to: string | undefined,
  limit: number,
): Promise<Row[]> {
  const branch = branchId ?? userBranchId ?? undefined;
  const params: unknown[] = [];
  const where: string[] = [`s.status <> 'cancelled'`];
  if (branch) {
    params.push(branch);
    where.push(`s.branch_id = $${params.length}`);
  }
  if (from) {
    params.push(from);
    where.push(`s.sale_date::date >= $${params.length}`);
  }
  if (to) {
    params.push(to);
    where.push(`s.sale_date::date <= $${params.length}`);
  }
  params.push(limit);
  const res = await query<Row>(
    `SELECT p.name AS product_name, b.name AS brand, v.name AS variant_name,
            COALESCE(SUM(si.quantity - COALESCE(r.returned_qty, 0)), 0)::bigint AS units_sold,
            COALESCE(SUM(si.total - COALESCE(r.refunded, 0)), 0)::bigint AS revenue,
            COALESCE(SUM(si.profit), 0)::bigint AS profit
       FROM sale_items si
       JOIN sales s ON s.id = si.sale_id
       JOIN products p ON p.id = si.product_id
       LEFT JOIN brands b ON b.id = p.brand_id
       JOIN product_variants v ON v.id = si.variant_id
       LEFT JOIN (SELECT sale_item_id, SUM(quantity) AS returned_qty,
                         SUM(refund_amount) AS refunded
                    FROM sale_returns GROUP BY sale_item_id) r
              ON r.sale_item_id = si.id
      WHERE ${where.join(' AND ')}
      GROUP BY p.id, p.name, b.name, v.id, v.name
      ORDER BY units_sold DESC
      LIMIT $${params.length}`,
    params,
  );
  return res.rows;
}

export async function deadStock(days: number): Promise<Row[]> {
  const res = await query<Row>(
    `SELECT p.name AS product_name, b.name AS brand, v.name AS variant_name,
            v.quantity, v.purchase_price, v.sale_price,
            (v.quantity * v.purchase_price)::bigint AS tied_up_cost,
            MAX(s.sale_date) AS last_sold
       FROM product_variants v
       JOIN products p ON p.id = v.product_id
       LEFT JOIN brands b ON b.id = p.brand_id
       LEFT JOIN sale_items si ON si.variant_id = v.id
       LEFT JOIN sales s ON s.id = si.sale_id AND s.status <> 'cancelled'
      WHERE p.is_active = TRUE AND v.quantity > 0
      GROUP BY p.id, p.name, b.name, v.id, v.name, v.quantity, v.purchase_price, v.sale_price
      HAVING MAX(s.sale_date) IS NULL
          OR MAX(s.sale_date) < CURRENT_DATE - ($1::int * INTERVAL '1 day')
      ORDER BY tied_up_cost DESC`,
    [days],
  );
  return res.rows;
}

/** All customers who owe money, with their oldest unpaid bill date. */
export async function pendingUdhaar(): Promise<Row[]> {
  const res = await query<Row>(
    `SELECT c.id, c.name, c.phone,
            COALESCE((
              SELECT SUM(debit - credit) FROM ledger_entries
               WHERE side = 'customer' AND customer_id = c.id
            ), c.opening_balance) AS balance,
            (SELECT MIN(s.sale_date) FROM sales s
              WHERE s.customer_id = c.id AND s.balance_due > 0 AND s.status <> 'cancelled') AS oldest_unpaid_bill
       FROM customers c
      WHERE c.is_active = TRUE
        AND COALESCE((
              SELECT SUM(debit - credit) FROM ledger_entries
               WHERE side = 'customer' AND customer_id = c.id
            ), c.opening_balance) > 0
      ORDER BY balance DESC`,
  );
  return res.rows;
}

/** All suppliers we owe money to. */
export async function supplierPayables(): Promise<Row[]> {
  const res = await query<Row>(
    `SELECT s.id, s.name, s.phone,
            COALESCE((
              SELECT SUM(credit - debit) FROM ledger_entries
               WHERE side = 'supplier' AND supplier_id = s.id
            ), s.opening_payable) AS balance,
            (SELECT MIN(p.purchase_date) FROM purchases p
              WHERE p.supplier_id = s.id AND p.balance_due > 0 AND p.status <> 'returned') AS oldest_unpaid_purchase
       FROM suppliers s
      WHERE s.is_active = TRUE
        AND COALESCE((
              SELECT SUM(credit - debit) FROM ledger_entries
               WHERE side = 'supplier' AND supplier_id = s.id
            ), s.opening_payable) > 0
      ORDER BY balance DESC`,
  );
  return res.rows;
}

/** Full lifecycle of one IMEI: purchase → sale → return / exchange. */
export async function imeiHistory(imei: string): Promise<Row> {
  const item = await query<Row>('SELECT * FROM imei_items WHERE imei1 = $1 OR imei2 = $1', [imei]);
  if (item.rows.length === 0) {
    return { found: false, imei };
  }
  const row = item.rows[0];
  const sales = await query<Row>(
    `SELECT s.id AS sale_id, s.invoice_no, s.sale_date, s.grand_total, s.status,
            si.unit_price, c.name AS customer_name
       FROM sale_items si
       JOIN sales s ON s.id = si.sale_id
       LEFT JOIN customers c ON c.id = s.customer_id
      WHERE si.imei_item_id = $1 ORDER BY s.sale_date DESC`,
    [row.id],
  );
  const returns = await query<Row>(
    `SELECT sr.*, s.invoice_no FROM sale_returns sr
       JOIN sales s ON s.id = sr.sale_id
      WHERE sr.imei_item_id = $1 ORDER BY sr.created_at DESC`,
    [row.id],
  );
  const purchase = await query<Row>(
    `SELECT p.id, p.purchase_date, p.supplier_invoice_no, s.name AS supplier_name
       FROM purchases p JOIN suppliers s ON s.id = p.supplier_id
      WHERE p.id = $1`,
    [row.purchase_id],
  );
  return {
    found: true,
    imeiItem: row,
    purchase: purchase.rows[0] ?? null,
    sales: sales.rows,
    returns: returns.rows,
  };
}
