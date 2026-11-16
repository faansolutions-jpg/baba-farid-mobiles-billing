/// Shared helpers for the Repairs / Expenses / Cash features
/// (Round 2 agent F).
///
/// Repository providers used to live here too; they now live in the
/// single shared file `core/providers/app_providers.dart`. Each screen
/// also accepts its repository as a constructor argument (same pattern
/// as the catalog screens), so tests can inject fakes without a
/// ProviderScope.
/// * Helpers: date formatting, whole-PKR parsing, Pakistani phone
///   normalisation, service-sale commission, and the wa.me launcher
///   (WhatsApp is wa.me share links only — DECISIONS.md #17).
///
/// Money is integer whole PKR everywhere. No cost / profit figure is
/// rendered by any screen in these features: repair parts show the
/// *sale* price charged to the customer, never the catalog purchase
/// price, so cashiers never see costs.
library;

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../domain/money.dart';

// ---------------------------------------------------------------------------
// Intended routes (registered by the router agent, Round 2 H).
// Screens navigate between each other with MaterialPageRoute until the
// router exists, so they work standalone today.
// ---------------------------------------------------------------------------

class RepairExpenseRoutes {
  const RepairExpenseRoutes._();

  static const String repairs = '/repairs';
  static const String repairNew = '/repairs/new';
  static const String repairDetailPrefix = '/repairs/';
  static const String serviceSales = '/repairs/services';
  static const String expenses = '/expenses';
  static const String staff = '/expenses/staff';
  static const String cash = '/cash';
  static const String dayEnd = '/cash/day-end';
}

// ---------------------------------------------------------------------------
// Formatting / parsing
// ---------------------------------------------------------------------------

/// `16 Nov 2026`.
String fmtDate(DateTime d) => DateFormat('d MMM yyyy').format(d);

/// `16 Nov 2026, 05:14 PM`.
String fmtDateTime(DateTime d) => DateFormat('d MMM yyyy, hh:mm a').format(d);

/// `YYYY-MM` (salary month key, e.g. `2026-11`).
String monthKey(DateTime d) =>
    '${d.year}-${d.month.toString().padLeft(2, '0')}';

/// Parses a whole-PKR amount typed by the user ("12,500" -> 12500).
/// Returns null when the text is not a number.
int? parsePkr(String text) {
  final cleaned = text.trim().replaceAll(',', '').replaceAll(' ', '');
  if (cleaned.isEmpty) return null;
  return int.tryParse(cleaned);
}

/// Normalises a Pakistani mobile to `03XXXXXXXXX`, or null when invalid.
/// Accepts `03XX-XXXXXXX`, `+92 3XX XXXXXXX`, `923XXXXXXXXX`.
String? normalizePkPhone(String value) {
  final cleaned = value.replaceAll(RegExp(r'[\s-]'), '');
  final match = RegExp(r'^(\+92|92|0)?(3\d{9})$').firstMatch(cleaned);
  if (match == null) return null;
  return '0${match.group(2)!}';
}

/// `03XXXXXXXXX` -> `92XXXXXXXXXXX` for wa.me links.
String? phoneToWa(String value) {
  final local = normalizePkPhone(value);
  if (local == null) return null;
  return '92${local.substring(1)}';
}

bool isValidMonthKey(String value) =>
    RegExp(r'^\d{4}-(0[1-9]|1[0-2])$').hasMatch(value.trim());

// ---------------------------------------------------------------------------
// Service-sale commission
// ---------------------------------------------------------------------------

/// Default commission rate (percent) when no setting is stored.
const double defaultServiceCommissionRate = 2.0;

/// Reads the stored `service_commission_rate` setting. The value is
/// stored as a percent (e.g. `2` = 2%); a fractional value such as
/// `0.02` is also accepted and treated as 2%.
double commissionRateFromSetting(dynamic value) {
  if (value == null) return defaultServiceCommissionRate;
  final num? parsed =
      value is num ? value : num.tryParse(value.toString());
  if (parsed == null) return defaultServiceCommissionRate;
  final rate = parsed.toDouble();
  if (rate <= 0) return defaultServiceCommissionRate;
  if (rate <= 1) return rate * 100;
  return rate.clamp(0, 100);
}

/// Whole-PKR commission on [amount] at [ratePercent] percent.
int commissionFor(int amount, double ratePercent) =>
    roundPkrDouble(amount * ratePercent / 100);

// ---------------------------------------------------------------------------
// WhatsApp (wa.me) + feedback
// ---------------------------------------------------------------------------

/// Opens WhatsApp with a prefilled message.
///
/// When [phone] is given the chat opens with that number (Pakistani
/// numbers are converted to international format); without a phone the
/// wa.me share link opens so the user picks the contact. Returns false
/// when WhatsApp could not be opened (caller shows a message).
Future<bool> openWhatsApp({
  String? phone,
  required String message,
}) async {
  final encoded = Uri.encodeComponent(message);
  final Uri uri;
  final waPhone = phone == null ? null : phoneToWa(phone);
  if (waPhone != null) {
    uri = Uri.parse('https://wa.me/$waPhone?text=$encoded');
  } else {
    uri = Uri.parse('https://wa.me/?text=$encoded');
  }
  try {
    return await launchUrl(uri, mode: LaunchMode.externalApplication);
  } catch (_) {
    return false;
  }
}

/// Short feedback snackbar (success = primary colour, error = red).
void showSnack(BuildContext context, String message, {bool isError = false}) {
  final colors = Theme.of(context).colorScheme;
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(message),
      backgroundColor: isError ? colors.error : colors.primary,
    ),
  );
}

/// Repair-ready WhatsApp text. Built from translated labels + the job's
/// own values so no user-facing string is hard-coded here.
String repairReadyMessage({
  required String shopName,
  required String jobNo,
  required String device,
  required int balanceDue,
  required String readyLabel,
  required String balanceLabel,
}) {
  final devicePart = device.isEmpty ? '' : '\n$device';
  return '$shopName\n'
      '$readyLabel — $jobNo$devicePart\n'
      '$balanceLabel: ${formatPkr(balanceDue)}';
}
