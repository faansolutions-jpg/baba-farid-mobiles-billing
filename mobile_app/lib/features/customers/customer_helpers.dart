/// Shared helpers for the Customers / Ledger / Installments screens
/// (Round 2E). Purchase screens reuse these too — one source of truth
/// for money/date formatting, balance colours, the WhatsApp reminder
/// launcher and the payment dialog. No screen invents its own copy.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/config/constants.dart';
import '../../core/l10n/app_strings.dart';
import '../../core/theme/app_theme.dart';
import '../../core/theme/cyber_colors.dart';
import '../../core/theme/cyber_text_styles.dart';
import '../../core/theme/cyber_widgets.dart';
import '../../domain/money.dart';

// ---------------------------------------------------------------------------
// Formatting
// ---------------------------------------------------------------------------

/// `12 Nov 2026`.
String fmtDate(DateTime date) => DateFormat('dd MMM yyyy').format(date);

/// `12 Nov 2026, 02:30 PM`.
String fmtDateTime(DateTime date) =>
    DateFormat('dd MMM yyyy, hh:mm a').format(date);

/// Customer balance colour: owes money = red, settled = green,
/// advance (negative) = amber.
Color balanceColor(CyberColors c, int balance) {
  if (balance > 0) return c.error;
  if (balance < 0) return c.warning;
  return c.success;
}

/// Supplier payable colour: owes money = red, settled = green.
Color payableColor(CyberColors c, int payable) =>
    payable > 0 ? c.error : c.success;

/// Monospace money text (`Rs 12,500`) in JetBrains Mono.
Widget moneyText(
  CyberColors c,
  int amount, {
  double size = 16,
  Color? color,
  FontWeight? weight,
}) {
  return Text(
    formatPkr(amount),
    style: CyberTextStyles.amount(c, size: size).copyWith(
      color: color,
      fontWeight: weight,
    ),
  );
}

// ---------------------------------------------------------------------------
// Snackbars / state widgets
// ---------------------------------------------------------------------------

void showSnack(BuildContext context, String message, {bool isError = false}) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(message),
      backgroundColor:
          isError ? Theme.of(context).colorScheme.error : null,
    ),
  );
}

/// Centred loading state: spinner + label.
Widget cyberLoading(CyberColors c, String label) {
  return Center(
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        CircularProgressIndicator(color: c.primary),
        const SizedBox(height: 16),
        Text(label, style: CyberTextStyles.bodySecondary(c)),
      ],
    ),
  );
}

/// Centred error state with a retry button (min 48dp).
Widget cyberError(
  CyberColors c,
  String message,
  VoidCallback onRetry,
  String retryLabel,
) {
  return Center(
    child: Padding(
      padding: const EdgeInsets.all(AppConstants.paddingLarge),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.error_outline, color: c.error, size: 48),
          const SizedBox(height: 12),
          Text(
            message,
            style: CyberTextStyles.body(c),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          CyberButton(
            label: retryLabel,
            fullWidth: false,
            icon: Icons.refresh,
            onPressed: onRetry,
          ),
        ],
      ),
    ),
  );
}

/// Centred empty state: icon + message.
Widget cyberEmpty(CyberColors c, String message, {IconData icon = Icons.inbox}) {
  return Center(
    child: Padding(
      padding: const EdgeInsets.all(AppConstants.paddingLarge),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: c.textSecondary, size: 48),
          const SizedBox(height: 12),
          Text(
            message,
            style: CyberTextStyles.bodySecondary(c),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    ),
  );
}

/// "This area is not for this role" state (cashiers + purchase screens).
Widget cyberRestricted(CyberColors c, String message) {
  return Center(
    child: Padding(
      padding: const EdgeInsets.all(AppConstants.paddingLarge),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.lock_outline, color: c.warning, size: 48),
          const SizedBox(height: 12),
          Text(
            AppStrings.tr('accessDenied', language: 'en'),
            style: CyberTextStyles.title(c, size: 18),
          ),
          const SizedBox(height: 8),
          Text(
            message,
            style: CyberTextStyles.bodySecondary(c),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    ),
  );
}

// ---------------------------------------------------------------------------
// WhatsApp reminders (wa.me share links — DECISIONS.md #17, no Business API)
// ---------------------------------------------------------------------------

/// Normalises a Pakistani phone to international form for wa.me.
String _waPhone(String phone) {
  final digits = phone.replaceAll(RegExp(r'[^0-9]'), '');
  if (digits.startsWith('92')) return digits;
  if (digits.startsWith('0')) return '92${digits.substring(1)}';
  return '92$digits';
}

/// Polite Urdu/English udhaar reminder for a customer.
String udhaarReminderText(String name, int balance) {
  return 'Assalam-o-Alaikum $name,\n'
      'Baba Farid Mobiles (Jamal Chowk, Depalpur Road, Pakpattan) se '
      'yaad dehani: aap ka udhaar balance ${formatPkr(balance)} hai. '
      'Meherbani farma kar jald ada kar dein.\n'
      'Shukriya!\n'
      '- Baba Farid Mobiles';
}

/// Polite Urdu/English reminder for one overdue installment.
String installmentReminderText(
  String name,
  int amount,
  DateTime dueDate,
  int daysOverdue,
) {
  return 'Assalam-o-Alaikum $name,\n'
      'Baba Farid Mobiles se yaad dehani: aap ki qist '
      '${formatPkr(amount)} (${fmtDate(dueDate)} ko due thi) '
      '$daysOverdue din se overdue hai. '
      'Meherbani farma kar jald ada kar dein.\n'
      'Shukriya!\n'
      '- Baba Farid Mobiles';
}

/// Opens WhatsApp (wa.me) with [message] for [phone]. Shows a snackbar
/// when WhatsApp cannot be opened.
Future<void> openWhatsApp(
  BuildContext context,
  String phone,
  String message,
) async {
  final lang = Localizations.localeOf(context).languageCode;
  final uri = Uri.parse(
    'https://wa.me/${_waPhone(phone)}?text=${Uri.encodeComponent(message)}',
  );
  final ok = await launchUrl(uri, mode: LaunchMode.externalApplication);
  if (!ok && context.mounted) {
    showSnack(
      context,
      AppStrings.tr('somethingWentWrong', language: lang),
      isError: true,
    );
  }
}

// ---------------------------------------------------------------------------
// Payment dialog (amount + method + optional note)
// ---------------------------------------------------------------------------

/// Result of [showPaymentDialog].
class PaymentInput {
  const PaymentInput({
    required this.amount,
    required this.method,
    this.note,
  });

  final int amount;
  final String method;
  final String? note;
}

/// Amount + payment-method + note dialog. Validates whole-PKR amount
/// (> 0, and <= [maxAmount] when given). Returns null when cancelled.
Future<PaymentInput?> showPaymentDialog(
  BuildContext context, {
  required String title,
  int? maxAmount,
  int? defaultAmount,
  String language = 'en',
}) async {
  return showDialog<PaymentInput>(
    context: context,
    builder: (dialogContext) => _PaymentDialog(
      title: title,
      maxAmount: maxAmount,
      defaultAmount: defaultAmount,
      language: language,
    ),
  );
}

class _PaymentDialog extends StatefulWidget {
  const _PaymentDialog({
    required this.title,
    this.maxAmount,
    this.defaultAmount,
    required this.language,
  });

  final String title;
  final int? maxAmount;
  final int? defaultAmount;
  final String language;

  @override
  State<_PaymentDialog> createState() => _PaymentDialogState();
}

class _PaymentDialogState extends State<_PaymentDialog> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _noteController = TextEditingController();
  String _method = PaymentMethods.cash;

  @override
  void initState() {
    super.initState();
    if (widget.defaultAmount != null) {
      _amountController.text = widget.defaultAmount.toString();
    }
  }

  @override
  void dispose() {
    _amountController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  String _t(String key) => AppStrings.tr(key, language: widget.language);

  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (context, ref, _) {
        final c = ref.watch(themeNotifierProvider).colors;
        return CyberDialog(
          title: widget.title,
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(_t('cancel')),
            ),
            CyberButton(
              label: _t('save'),
              fullWidth: false,
              onPressed: () {
                if (!_formKey.currentState!.validate()) return;
                Navigator.of(context).pop(
                  PaymentInput(
                    amount: int.parse(_amountController.text.trim()),
                    method: _method,
                    note: _noteController.text.trim().isEmpty
                        ? null
                        : _noteController.text.trim(),
                  ),
                );
              },
            ),
          ],
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                CyberTextField(
                  controller: _amountController,
                  label: _t('paymentAmount'),
                  hint: '0',
                  monospace: true,
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    final amount = int.tryParse((value ?? '').trim());
                    if (amount == null || amount <= 0) {
                      return _t('invalidAmount');
                    }
                    if (widget.maxAmount != null &&
                        amount > widget.maxAmount!) {
                      return '${_t('invalidAmount')} (max ${formatPkr(widget.maxAmount!)})';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                Text(_t('paymentMethod'),
                    style: CyberTextStyles.label(c)),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: PaymentMethods.fullPaymentMethods.map((method) {
                    return CyberChip(
                      label: method,
                      selected: _method == method,
                      onSelected: (_) => setState(() => _method = method),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 12),
                CyberTextField(
                  controller: _noteController,
                  label: _t('paymentNote'),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
