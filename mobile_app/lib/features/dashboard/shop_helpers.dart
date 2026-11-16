library;

/// Shared formatting helpers for the Round 2 screens (dashboard,
/// reports, settings, command palette, AI). All money is whole PKR.
import 'package:intl/intl.dart';

/// 125000 -> "Rs 125,000" (JetBrains Mono is applied by the caller
/// through [CyberTextStyles.mono]/[CyberTextStyles.amount]).
String formatPkr(int value) {
  final digits = value.abs().toString();
  final buf = StringBuffer();
  for (var i = 0; i < digits.length; i++) {
    if (i > 0 && (digits.length - i) % 3 == 0) buf.write(',');
    buf.write(digits[i]);
  }
  return 'Rs ${value < 0 ? '-' : ''}$buf';
}

/// Hides a money amount when privacy mode is on (DECISIONS.md #11).
String maybeHideAmount(int value, bool privacyMode) =>
    privacyMode ? '****' : formatPkr(value);

/// Short date, e.g. 16 Nov 2026.
String formatShortDate(DateTime d) => DateFormat('d MMM yyyy').format(d);

/// Short date + time, e.g. 16 Nov 2026, 05:14 PM.
String formatShortDateTime(DateTime d) =>
    DateFormat('d MMM yyyy, h:mm a').format(d);

/// Start of the day (00:00) in local time.
DateTime startOfDay(DateTime d) => DateTime(d.year, d.month, d.day);

/// End of the day (23:59:59) in local time.
DateTime endOfDay(DateTime d) =>
    DateTime(d.year, d.month, d.day, 23, 59, 59);
