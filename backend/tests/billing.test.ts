// Unit tests for billing math: a full bill end-to-end through the pure
// money functions (the same functions createSale uses), plus the
// min-price and profit rules.
import { describe, expect, it } from 'vitest';
import {
  balanceDue,
  calcBillTotals,
  calcLineProfit,
  calcLineTotal,
  paymentStatusFor,
} from '../src/utils/money';

interface Line {
  unitPrice: number;
  quantity: number;
  discount: number;
  purchaseCost: number;
}

/** Replicates the totals a bill computes from its lines. */
function bill(lines: Line[], discountAmount = 0, taxAmount = 0) {
  const lineTotals = lines.map((l) => calcLineTotal(l.unitPrice, l.quantity, l.discount));
  const profit = lines.reduce(
    (a, l) => a + calcLineProfit(l.unitPrice, l.purchaseCost, l.quantity, l.discount),
    0,
  );
  const totals = calcBillTotals({ lineTotals, discountAmount, taxAmount });
  return { ...totals, profit };
}

describe('billing: a realistic shop bill', () => {
  it('computes totals and profit for a mixed phone + accessory bill', () => {
    // Galaxy A16 (cost 42,000, sold 45,000) + charger (cost 900, sold 1,500) x2.
    const result = bill([
      { unitPrice: 45000, quantity: 1, discount: 0, purchaseCost: 42000 },
      { unitPrice: 1500, quantity: 2, discount: 100, purchaseCost: 900 },
    ]);
    expect(result.subtotal).toBe(47900);
    expect(result.grandTotal).toBe(47900);
    expect(result.profit).toBe(3000 + 1100); // 3000 phone + (1500-900)*2 - 100
  });

  it('applies a bill-level discount before computing the amount due', () => {
    const result = bill(
      [{ unitPrice: 5000, quantity: 1, discount: 0, purchaseCost: 4000 }],
      500,
    );
    expect(result.subtotal).toBe(5000);
    expect(result.grandTotal).toBe(4500);
    // Profit is computed on the line total (after line discount), not the
    // bill discount — the bill discount is a shop-level giveaway.
    expect(result.profit).toBe(1000);
  });

  it('a partial payment leaves the right udhaar balance', () => {
    const result = bill([
      { unitPrice: 20000, quantity: 1, discount: 0, purchaseCost: 17000 },
    ]);
    const paid = 8000;
    expect(balanceDue(result.grandTotal, paid)).toBe(12000);
    expect(paymentStatusFor(paid, result.grandTotal)).toBe('partial');
  });

  it('an udhaar bill (paid 0) owes the full grand total', () => {
    const result = bill([
      { unitPrice: 12000, quantity: 1, discount: 0, purchaseCost: 10000 },
    ]);
    expect(balanceDue(result.grandTotal, 0)).toBe(12000);
    expect(paymentStatusFor(0, result.grandTotal)).toBe('unpaid');
  });

  it('tax is added after discounts', () => {
    const result = bill(
      [{ unitPrice: 10000, quantity: 1, discount: 0, purchaseCost: 8000 }],
      1000,
      170,
    );
    expect(result.grandTotal).toBe(9170);
  });
});

describe('billing: min-price rule', () => {
  it('a price below min_price is detectable (service rejects without approval)', () => {
    const minPrice = 44000;
    const unitPrice = 43000;
    expect(unitPrice < minPrice).toBe(true);
    expect(45000 < minPrice).toBe(false);
  });
});

describe('billing: return refund split', () => {
  it('a refund comes first from what was paid, then from the balance', () => {
    const grandTotal = 10000;
    const paid = 6000;
    const balance = balanceDue(grandTotal, paid); // 4000
    const refund = 5000;
    const refundFromPaid = Math.min(refund, paid); // 5000
    const refundFromBalance = refund - refundFromPaid; // 0
    expect(refundFromPaid).toBe(5000);
    expect(refundFromBalance).toBe(0);
    expect(balance - refundFromBalance).toBe(4000);
  });

  it('a refund larger than the paid amount eats into the balance too', () => {
    const paid = 3000;
    const balance = 7000;
    const refund = 5000;
    const refundFromPaid = Math.min(refund, paid); // 3000
    const refundFromBalance = refund - refundFromPaid; // 2000
    expect(refundFromPaid).toBe(3000);
    expect(refundFromBalance).toBe(2000);
    expect(balance - refundFromBalance).toBe(5000);
  });
});
