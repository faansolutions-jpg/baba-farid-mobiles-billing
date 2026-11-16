// Money math — pure functions, whole PKR integers only.
// All money in this system is an integer number of rupees (no paisa).
// Every function here is covered by tests/money.test.ts and tests/billing.test.ts.

/** Force any number to a whole-rupee integer (round half up). */
export function toWholePKR(n: number): number {
  if (!Number.isFinite(n)) return 0;
  return Math.round(n);
}

/** One bill line: unit price x quantity minus line discount. Never negative. */
export function calcLineTotal(unitPrice: number, quantity: number, discount = 0): number {
  return Math.max(0, toWholePKR(unitPrice) * quantity - toWholePKR(discount));
}

/** Profit on one line: what the shop keeps after cost. */
export function calcLineProfit(
  unitPrice: number,
  purchaseCost: number,
  quantity: number,
  discount = 0,
): number {
  return calcLineTotal(unitPrice, quantity, discount) - toWholePKR(purchaseCost) * quantity;
}

export interface BillInput {
  /** Per-line subtotals BEFORE bill-level discount (unitPrice*qty - line discount). */
  lineTotals: number[];
  /** Bill-level discount as a flat rupee amount. Takes priority over percent. */
  discountAmount?: number;
  /** Bill-level discount as a percent (0–100). Used only when discountAmount is 0/absent. */
  discountPercent?: number;
  /** Optional tax (flat rupees). 0 when tax is disabled. */
  taxAmount?: number;
}

export interface BillTotals {
  subtotal: number;
  discountAmount: number;
  taxAmount: number;
  grandTotal: number;
}

/**
 * Bill totals. Rule: if a flat discount amount is given it wins; otherwise
 * the percent is applied to the subtotal. Grand total can never be negative.
 */
export function calcBillTotals(input: BillInput): BillTotals {
  const subtotal = input.lineTotals.reduce((a, b) => a + toWholePKR(b), 0);
  let discountAmount = toWholePKR(input.discountAmount ?? 0);
  if (discountAmount === 0 && (input.discountPercent ?? 0) > 0) {
    const pct = Math.min(100, Math.max(0, input.discountPercent ?? 0));
    discountAmount = Math.round((subtotal * pct) / 100);
  }
  discountAmount = Math.min(discountAmount, subtotal);
  const taxAmount = Math.max(0, toWholePKR(input.taxAmount ?? 0));
  const grandTotal = Math.max(0, subtotal - discountAmount + taxAmount);
  return { subtotal, discountAmount, taxAmount, grandTotal };
}

/** Payment status from paid vs grand total. */
export function paymentStatusFor(
  paidAmount: number,
  grandTotal: number,
): 'paid' | 'partial' | 'unpaid' {
  const paid = toWholePKR(paidAmount);
  if (paid <= 0) return 'unpaid';
  if (paid >= grandTotal) return 'paid';
  return 'partial';
}

/** Remaining balance on a bill. Never negative. */
export function balanceDue(grandTotal: number, paidAmount: number): number {
  return Math.max(0, toWholePKR(grandTotal) - toWholePKR(paidAmount));
}

export interface InstallmentSlice {
  dueDate: string; // ISO date (YYYY-MM-DD)
  amount: number;
}

/**
 * Split a remaining amount into N monthly installments.
 * The remainder (from rounding) goes on the LAST installment so the parts
 * always sum exactly to the remaining amount. Due dates are monthly from
 * the start date (same day-of-month, clamped to month end).
 */
export function calcInstallments(
  remainingAmount: number,
  count: number,
  startDate: string, // YYYY-MM-DD, first due date
): InstallmentSlice[] {
  const total = toWholePKR(remainingAmount);
  const n = Math.max(1, Math.floor(count));
  const base = Math.floor(total / n);
  const slices: InstallmentSlice[] = [];
  const [y, m, d] = startDate.split('-').map(Number);
  for (let i = 0; i < n; i++) {
    const amount = i === n - 1 ? total - base * (n - 1) : base;
    // Add i months, clamping the day to the last day of the target month.
    const target = new Date(Date.UTC(y, m - 1 + i, 1));
    const lastDay = new Date(Date.UTC(target.getUTCFullYear(), target.getUTCMonth() + 1, 0)).getUTCDate();
    const day = Math.min(d, lastDay);
    const due = new Date(Date.UTC(target.getUTCFullYear(), target.getUTCMonth(), day));
    slices.push({ dueDate: due.toISOString().slice(0, 10), amount });
  }
  return slices;
}

/** Day-end expected cash: opening + cash in − cash out. */
export function expectedCash(args: {
  openingCash: number;
  cashSales: number;
  cashIn: number;
  expenses: number;
  cashRefunds: number;
  cashOut: number;
}): number {
  const { openingCash, cashSales, cashIn, expenses, cashRefunds, cashOut } = args;
  return (
    toWholePKR(openingCash) +
    toWholePKR(cashSales) +
    toWholePKR(cashIn) -
    toWholePKR(expenses) -
    toWholePKR(cashRefunds) -
    toWholePKR(cashOut)
  );
}
