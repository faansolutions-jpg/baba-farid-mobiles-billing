// Unit tests for money math (utils/money.ts) — whole PKR integers only.
import { describe, expect, it } from 'vitest';
import {
  balanceDue,
  calcBillTotals,
  calcInstallments,
  calcLineProfit,
  calcLineTotal,
  expectedCash,
  paymentStatusFor,
  toWholePKR,
} from '../src/utils/money';

describe('toWholePKR', () => {
  it('rounds to whole rupees', () => {
    expect(toWholePKR(100.4)).toBe(100);
    expect(toWholePKR(100.5)).toBe(101);
    expect(toWholePKR(0)).toBe(0);
  });
  it('returns 0 for non-finite input', () => {
    expect(toWholePKR(NaN)).toBe(0);
    expect(toWholePKR(Infinity)).toBe(0);
  });
});

describe('calcLineTotal', () => {
  it('multiplies unit price by quantity and subtracts the line discount', () => {
    expect(calcLineTotal(1500, 2, 100)).toBe(2900);
    expect(calcLineTotal(450, 1)).toBe(450);
  });
  it('never goes negative', () => {
    expect(calcLineTotal(100, 1, 500)).toBe(0);
  });
});

describe('calcLineProfit', () => {
  it('is sale minus purchase cost per item', () => {
    // Sold at 1500, bought at 1200, qty 2, discount 100 on the line.
    expect(calcLineProfit(1500, 1200, 2, 100)).toBe(500);
  });
  it('can be negative when sold below cost', () => {
    expect(calcLineProfit(1000, 1200, 1)).toBe(-200);
  });
});

describe('calcBillTotals', () => {
  it('sums lines, applies a flat discount, adds tax', () => {
    const t = calcBillTotals({
      lineTotals: [1500, 450, 2800],
      discountAmount: 500,
      taxAmount: 0,
    });
    expect(t.subtotal).toBe(4750);
    expect(t.discountAmount).toBe(500);
    expect(t.grandTotal).toBe(4250);
  });
  it('applies a percent discount when no flat amount is given', () => {
    const t = calcBillTotals({ lineTotals: [10000], discountPercent: 10 });
    expect(t.discountAmount).toBe(1000);
    expect(t.grandTotal).toBe(9000);
  });
  it('a flat discount wins over a percent discount', () => {
    const t = calcBillTotals({
      lineTotals: [10000],
      discountAmount: 300,
      discountPercent: 10,
    });
    expect(t.discountAmount).toBe(300);
    expect(t.grandTotal).toBe(9700);
  });
  it('caps the discount at the subtotal and never goes negative', () => {
    const t = calcBillTotals({ lineTotals: [500], discountAmount: 2000 });
    expect(t.discountAmount).toBe(500);
    expect(t.grandTotal).toBe(0);
  });
  it('adds tax on top of the discounted subtotal', () => {
    const t = calcBillTotals({ lineTotals: [1000], taxAmount: 170 });
    expect(t.grandTotal).toBe(1170);
  });
});

describe('paymentStatusFor / balanceDue', () => {
  it('derives the right status', () => {
    expect(paymentStatusFor(0, 5000)).toBe('unpaid');
    expect(paymentStatusFor(2000, 5000)).toBe('partial');
    expect(paymentStatusFor(5000, 5000)).toBe('paid');
  });
  it('balance is grand total minus paid, never negative', () => {
    expect(balanceDue(5000, 2000)).toBe(3000);
    expect(balanceDue(5000, 5000)).toBe(0);
    expect(balanceDue(5000, 6000)).toBe(0);
  });
});

describe('calcInstallments', () => {
  it('splits an amount into equal monthly parts, remainder on the last', () => {
    const slices = calcInstallments(10000, 3, '2026-11-20');
    expect(slices).toHaveLength(3);
    expect(slices.map((s) => s.amount)).toEqual([3333, 3333, 3334]);
    expect(slices.reduce((a, s) => a + s.amount, 0)).toBe(10000);
    expect(slices[0].dueDate).toBe('2026-11-20');
    expect(slices[1].dueDate).toBe('2026-12-20');
    expect(slices[2].dueDate).toBe('2027-01-20');
  });
  it('clamps the due day to the end of short months', () => {
    const slices = calcInstallments(6000, 2, '2026-01-31');
    expect(slices[0].dueDate).toBe('2026-01-31');
    expect(slices[1].dueDate).toBe('2026-02-28');
  });
});

describe('expectedCash', () => {
  it('opening + cash in − cash out', () => {
    expect(
      expectedCash({
        openingCash: 10000,
        cashSales: 45000,
        cashIn: 2000,
        expenses: 5000,
        cashRefunds: 1500,
        cashOut: 1000,
      }),
    ).toBe(49500);
  });
});
