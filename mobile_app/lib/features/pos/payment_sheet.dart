library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/l10n/app_strings.dart';
import '../../core/theme/app_theme.dart';
import '../../core/theme/cyber_text_styles.dart';
import '../../core/theme/cyber_widgets.dart';
import '../../domain/money.dart';
import 'pos_models.dart';

/// Bottom sheet for choosing how the bill is paid.
///
/// Full-payment methods (Cash / JazzCash / Easypaisa / Bank / Card)
/// pay the whole grand total. Partial lets the cashier enter the amount
/// received now (the rest stays as udhaar on the customer ledger);
/// Udhaar records nothing paid now. A transaction reference can be
/// entered for JazzCash / Easypaisa / Bank / Card. Returns a
/// [PaymentChoice], or null when dismissed.
Future<PaymentChoice?> showPaymentSheet(
  BuildContext context, {
  required int grandTotal,
}) {
  return showModalBottomSheet<PaymentChoice>(
    context: context,
    isScrollControlled: true,
    builder: (context) => PaymentSheet(grandTotal: grandTotal),
  );
}

class PaymentSheet extends ConsumerStatefulWidget {
  const PaymentSheet({super.key, required this.grandTotal});

  final int grandTotal;

  @override
  ConsumerState<PaymentSheet> createState() => _PaymentSheetState();
}

class _PaymentSheetState extends ConsumerState<PaymentSheet> {
  String _method = 'cash';
  late final TextEditingController _paidController;
  final TextEditingController _referenceController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _paidController =
        TextEditingController(text: widget.grandTotal.toString());
  }

  @override
  void dispose() {
    _paidController.dispose();
    _referenceController.dispose();
    super.dispose();
  }

  int get _paidAmount {
    if (_method == 'udhaar') return 0;
    if (_method == 'partial') {
      return int.tryParse(_paidController.text.trim()) ?? 0;
    }
    return widget.grandTotal;
  }

  int get _due => widget.grandTotal - _paidAmount;

  void _selectMethod(String method) {
    setState(() {
      _method = method;
      if (method == 'udhaar') {
        _paidController.text = '0';
      } else if (method != 'partial') {
        _paidController.text = widget.grandTotal.toString();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final c = ref.watch(themeNotifierProvider).colors;
    final lang = ref.watch(languageProvider);
    String tr(String key) => AppStrings.tr(key, language: lang);
    final paidEditable = _method == 'partial';
    final showReference = _method == 'jazzcash' ||
        _method == 'easypaisa' ||
        _method == 'bank_transfer' ||
        _method == 'card';

    return Padding(
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        top: 16,
        bottom: MediaQuery.of(context).viewInsets.bottom + 16,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              tr('paymentMethod'),
              style: CyberTextStyles.title(c, size: 18),
            ),
            const SizedBox(height: 4),
            Text(
              '${tr('grandTotal')}: ${formatPkr(widget.grandTotal)}',
              style: CyberTextStyles.amount(c, size: 24),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final method in paymentMethodValues)
                  CyberChip(
                    label: tr(paymentMethodLabelKey(method)),
                    selected: _method == method,
                    onSelected: (_) => _selectMethod(method),
                  ),
              ],
            ),
            const SizedBox(height: 16),
            CyberTextField(
              controller: _paidController,
              label: tr('amountPaid'),
              monospace: true,
              keyboardType: TextInputType.number,
              readOnly: !paidEditable,
              enabled: paidEditable,
              onChanged: (_) => setState(() {}),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(tr('balance'), style: CyberTextStyles.body(c)),
                Text(
                  formatPkr(_due),
                  style: CyberTextStyles.mono(c, size: 17).copyWith(
                    color: _due > 0 ? c.warning : c.success,
                  ),
                ),
              ],
            ),
            if (_method == 'partial' && _paidAmount > 0) ...[
              const SizedBox(height: 8),
              Text(
                '${tr('changeDue')}: ${formatPkr(0)}',
                style: CyberTextStyles.bodySecondary(c),
              ),
            ],
            if (showReference) ...[
              const SizedBox(height: 12),
              CyberTextField(
                controller: _referenceController,
                label: tr('referenceNo'),
                hint: tr('enterReference'),
              ),
            ],
            const SizedBox(height: 20),
            CyberButton(
              label: tr('completeSale'),
              icon: Icons.check_circle_outline,
              onPressed: (_method == 'partial' &&
                          (_paidAmount < 0 ||
                              _paidAmount > widget.grandTotal)) ||
                      (_method == 'partial' && _paidAmount == 0)
                  ? null
                  : () {
                      final reference =
                          _referenceController.text.trim();
                      Navigator.of(context).pop(
                        PaymentChoice(
                          method: _method,
                          paidAmount: _paidAmount,
                          reference: reference.isEmpty ? null : reference,
                        ),
                      );
                    },
            ),
            const SizedBox(height: 8),
            CyberButton(
              label: tr('cancel'),
              variant: CyberButtonVariant.ghost,
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        ),
      ),
    );
  }
}
