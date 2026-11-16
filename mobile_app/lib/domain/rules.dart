/// Pure business rules for Baba Farid Mobiles.
///
/// Every function here is pure Dart with no I/O, so it is unit-testable
/// without a database or network. The repositories enforce these rules
/// inside their transactions; the UI must never be the only enforcement.
library;

import 'models/imei_item.dart';

/// Validates an IMEI: exactly 15 digits **and** a valid Luhn check digit
/// (IMEI check digit, GSM 03.19). Returns false for anything else.
bool validateImei(String imei) {
  final value = imei.trim();
  if (!RegExp(r'^\d{15}$').hasMatch(value)) return false;
  // Luhn check: double every second digit counting from the right,
  // starting with the second-to-last digit.
  var sum = 0;
  for (var i = 0; i < 15; i++) {
    var digit = int.parse(value[14 - i]);
    if (i.isOdd) {
      digit *= 2;
      if (digit > 9) digit -= 9;
    }
    sum += digit;
  }
  return sum % 10 == 0;
}

/// An IMEI item can only be sold when its status is `available`.
bool canSellImei(ImeiItem item) => item.status == 'available';

/// Returns true when [salePrice] is below the product's [minPrice],
/// i.e. the sale needs admin approval (admin PIN / username) before
/// it may proceed. See DECISIONS.md rule 13.
bool minPriceCheck(int salePrice, int minPrice) => salePrice < minPrice;

/// One generated installment row.
typedef InstallmentRow = Map<String, dynamic>;

/// Builds an installment schedule for the amount remaining after the
/// down payment.
///
/// * [total] — grand total of the sale (whole PKR).
/// * [downPayment] — paid up front (whole PKR, 0..total).
/// * [count] — number of installments (> 0).
/// * [startDate] — due date of the first installment.
///
/// The remaining amount is split as evenly as possible in whole rupees;
/// leftover rupees go to the earliest installments. Due dates are
/// monthly, clamped to the last day of short months (e.g. 31 Jan -> 28 Feb).
/// Throws [ArgumentError] for invalid inputs.
List<InstallmentRow> installmentSchedule(
  int total,
  int downPayment,
  int count,
  DateTime startDate,
) {
  if (count <= 0) throw ArgumentError('installment count must be > 0');
  if (total <= 0) throw ArgumentError('total must be > 0');
  if (downPayment < 0 || downPayment > total) {
    throw ArgumentError('downPayment must be between 0 and total');
  }
  final remaining = total - downPayment;
  if (remaining <= 0) return <InstallmentRow>[];
  final base = remaining ~/ count;
  final extra = remaining % count;
  final rows = <InstallmentRow>[];
  for (var i = 0; i < count; i++) {
    final amount = base + (i < extra ? 1 : 0);
    rows.add({
      'dueDate': _addMonths(startDate, i),
      'amount': amount,
    });
  }
  return rows;
}

DateTime _addMonths(DateTime date, int months) {
  final monthIndex = date.month - 1 + months;
  final year = date.year + monthIndex ~/ 12;
  final month = monthIndex % 12 + 1;
  final lastDay = DateTime(year, month + 1, 0).day;
  final day = date.day > lastDay ? lastDay : date.day;
  return DateTime(year, month, day);
}

/// True when [dueDate] is before today (date-only comparison, so an
/// installment due today is not yet overdue).
bool isOverdue(DateTime dueDate, {DateTime? now}) {
  final today = now ?? DateTime.now();
  final due = DateTime(dueDate.year, dueDate.month, dueDate.day);
  final current = DateTime(today.year, today.month, today.day);
  return due.isBefore(current);
}

/// Whole days since [lastSoldDate].
///
/// Returns -1 when [lastSoldDate] is null (never sold), which callers
/// treat as the oldest possible stock.
int deadStockDays(DateTime? lastSoldDate, {DateTime? now}) {
  if (lastSoldDate == null) return -1;
  final current = now ?? DateTime.now();
  return current.difference(lastSoldDate).inDays;
}

/// Loyalty points earned on a spend: 1 point per Rs 100 spent
/// (DECISIONS.md rule 23). 100 points = Rs 100 discount.
int loyaltyPointsForSpend(int amountSpent) => amountSpent ~/ 100;
