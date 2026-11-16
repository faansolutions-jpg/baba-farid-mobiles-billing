/// Money helpers for Baba Farid Mobiles.
///
/// Rule (PLAN.md / DECISIONS.md): **all money is integer whole PKR**.
/// No paisa decimals anywhere. Rounding happens only at display time.
/// Profit = sale price - purchase cost, per item.
library;

/// Rounds a whole-PKR amount. Amounts are already whole rupees, so this
/// is an identity function kept for API symmetry with [roundPkrDouble].
int roundPkr(int amount) => amount;

/// Rounds a computed (double) amount to the nearest whole rupee.
int roundPkrDouble(double amount) => amount.round();

/// Formats a whole-PKR amount as e.g. `Rs 12,500` (negative: `Rs -1,250`).
String formatPkr(int amount) {
  final negative = amount < 0;
  final digits = amount.abs().toString();
  final buf = StringBuffer();
  for (var i = 0; i < digits.length; i++) {
    if (i > 0 && (digits.length - i) % 3 == 0) buf.write(',');
    buf.write(digits[i]);
  }
  return 'Rs ${negative ? '-' : ''}$buf';
}

/// Profit on one item: sale price minus purchase cost (whole PKR).
int profitPerItem(int salePrice, int cost) => salePrice - cost;

/// Applies a discount to [amount].
///
/// * [discount] is a flat rupee amount when [isPercent] is false.
/// * [discount] is a percentage (0-100) when [isPercent] is true.
/// The result is clamped to `0..amount` and is always whole PKR.
int applyDiscount(int amount, num discount, bool isPercent) {
  if (amount <= 0) return 0;
  if (isPercent) {
    final pct = discount.clamp(0, 100).toDouble();
    final value = (amount * pct / 100).round();
    return value < 0 ? 0 : (value > amount ? amount : value);
  }
  final flat = discount.round();
  return flat < 0 ? 0 : (flat > amount ? amount : flat);
}

/// Tax on [amount] at [taxRate] percent (e.g. 17 means 17%). Whole PKR.
int applyTax(int amount, double taxRate) {
  if (amount <= 0 || taxRate <= 0) return 0;
  return (amount * taxRate / 100).round();
}

/// One line of a bill, used by [billTotals].
class BillLine {
  /// Sale (unit) price in whole PKR.
  final int unitPrice;

  /// Quantity of this line.
  final int quantity;

  /// Flat per-line discount in whole PKR (already applied per line).
  final int discount;

  const BillLine({
    required this.unitPrice,
    this.quantity = 1,
    this.discount = 0,
  });

  /// Line total after its own discount, never negative.
  int get total {
    final value = unitPrice * quantity - discount;
    return value < 0 ? 0 : value;
  }
}

/// Computes bill totals from [items].
///
/// * [discount] is a flat rupee discount on the subtotal.
/// * [taxRate] is a percentage applied after the discount.
/// * Set [discountIsPercent] to treat [discount] as a percentage.
///
/// Returns `{subtotal, discount, tax, total}` — all whole PKR.
Map<String, int> billTotals(
  List<BillLine> items,
  int discount,
  double taxRate, {
  bool discountIsPercent = false,
}) {
  final subtotal = items.fold<int>(0, (sum, line) => sum + line.total);
  final discountAmount = applyDiscount(subtotal, discount, discountIsPercent);
  final taxable = subtotal - discountAmount;
  final tax = applyTax(taxable, taxRate);
  final total = taxable + tax;
  return {
    'subtotal': subtotal,
    'discount': discountAmount,
    'tax': tax,
    'total': total,
  };
}
