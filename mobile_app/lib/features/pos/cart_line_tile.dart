library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/l10n/app_strings.dart';
import '../../core/theme/app_theme.dart';
import '../../core/theme/cyber_text_styles.dart';
import '../../core/theme/cyber_widgets.dart';
import '../../domain/money.dart';
import 'pos_models.dart';

/// One editable cart line on the POS screen.
///
/// Quantity stepper (48dp targets), tap the price to edit it, tap the
/// discount to change it (Rs or %), profit shown only when
/// [canSeeCosts] is true (owner/manager — never a cashier).
class CartLineTile extends ConsumerWidget {
  const CartLineTile({
    super.key,
    required this.line,
    required this.canSeeCosts,
    required this.onQuantityChanged,
    required this.onEditPrice,
    required this.onEditDiscount,
    required this.onRemove,
  });

  final CartLine line;
  final bool canSeeCosts;
  final ValueChanged<int> onQuantityChanged;
  final VoidCallback onEditPrice;
  final VoidCallback onEditDiscount;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c = ref.watch(themeNotifierProvider).colors;
    final lang = ref.watch(languageProvider);
    String tr(String key) => AppStrings.tr(key, language: lang);

    return CyberCard(
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(line.name, style: CyberTextStyles.subtitle(c)),
                    if (line.imei1 != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        line.imei1!,
                        style: CyberTextStyles.imei(c, size: 13),
                      ),
                    ],
                    if (line.isBelowMinPrice) ...[
                      const SizedBox(height: 4),
                      CyberBadge(
                        label: tr('priceBelowMin'),
                        color: c.warning,
                      ),
                    ],
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.delete_outline),
                color: c.error,
                tooltip: tr('removeItem'),
                constraints:
                    const BoxConstraints(minWidth: 48, minHeight: 48),
                onPressed: onRemove,
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              // Quantity stepper. Phones (IMEI) are always quantity 1.
              SizedBox(
                width: 48,
                height: 48,
                child: IconButton(
                  icon: const Icon(Icons.remove),
                  tooltip: '-1',
                  onPressed: line.isPhone || line.quantity <= 1
                      ? null
                      : () => onQuantityChanged(line.quantity - 1),
                ),
              ),
              SizedBox(
                width: 44,
                child: Text(
                  '${line.quantity}',
                  textAlign: TextAlign.center,
                  style: CyberTextStyles.mono(c, size: 17),
                ),
              ),
              SizedBox(
                width: 48,
                height: 48,
                child: IconButton(
                  icon: const Icon(Icons.add),
                  tooltip: '+1',
                  onPressed: line.isPhone
                      ? null
                      : () => onQuantityChanged(line.quantity + 1),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: InkWell(
                  onTap: onEditPrice,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          tr('salePrice'),
                          style: CyberTextStyles.caption(c),
                        ),
                        Text(
                          formatPkr(line.unitPrice),
                          style: CyberTextStyles.mono(c, size: 16),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              InkWell(
                onTap: onEditDiscount,
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        tr('discount'),
                        style: CyberTextStyles.caption(c),
                      ),
                      Text(
                        line.discountAmount > 0
                            ? '-${formatPkr(line.discountAmount)}'
                            : formatPkr(0),
                        style: CyberTextStyles.mono(c, size: 16)
                            .copyWith(color: c.secondary),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Text(
                formatPkr(line.total),
                style: CyberTextStyles.amount(c, size: 18),
              ),
            ],
          ),
          if (canSeeCosts)
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(
                '${tr('profit')}: ${formatPkr(line.profit)}',
                style: CyberTextStyles.mono(c, size: 13)
                    .copyWith(color: c.success),
              ),
            ),
        ],
      ),
    );
  }
}

/// Small dialog to edit one whole-PKR amount (line price, discount,
/// paid amount). Returns the entered value, or null when cancelled.
Future<int?> showAmountDialog(
  BuildContext context, {
  required String title,
  required int initialValue,
  String? hint,
}) async {
  final controller =
      TextEditingController(text: initialValue > 0 ? '$initialValue' : '');
  final result = await showDialog<int>(
    context: context,
    builder: (context) => Consumer(
      builder: (context, ref, _) {
        final lang = ref.watch(languageProvider);
        String tr(String key) => AppStrings.tr(key, language: lang);
        return CyberDialog(
          title: title,
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(tr('cancel')),
            ),
            CyberButton(
              label: tr('save'),
              fullWidth: false,
              onPressed: () {
                final value = int.tryParse(controller.text.trim());
                if (value == null || value < 0) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(tr('enterValidAmount'))),
                  );
                  return;
                }
                Navigator.of(context).pop(value);
              },
            ),
          ],
          child: CyberTextField(
            controller: controller,
            hint: hint ?? tr('amount'),
            monospace: true,
            keyboardType: TextInputType.number,
            autofocus: true,
            prefixIcon: Icons.attach_money,
          ),
        );
      },
    ),
  );
  controller.dispose();
  return result;
}

/// Dialog to edit a per-line discount: Rs amount or percent.
Future<({int value, bool isPercent})?> showLineDiscountDialog(
  BuildContext context, {
  required CartLine line,
}) async {
  var isPercent = line.discountIsPercent;
  final controller = TextEditingController(
    text: line.discountValue > 0 ? '${line.discountValue}' : '',
  );
  final result = await showDialog<({int value, bool isPercent})>(
    context: context,
    builder: (context) => Consumer(
      builder: (context, ref, _) {
        final lang = ref.watch(languageProvider);
        String tr(String key) => AppStrings.tr(key, language: lang);
        return StatefulBuilder(
          builder: (context, setDialogState) => CyberDialog(
            title: tr('lineDiscount'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text(tr('cancel')),
              ),
              CyberButton(
                label: tr('save'),
                fullWidth: false,
                onPressed: () {
                  final value = int.tryParse(controller.text.trim()) ?? 0;
                  if (value < 0 || (isPercent && value > 100)) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(tr('enterValidAmount'))),
                    );
                    return;
                  }
                  Navigator.of(context)
                      .pop((value: value, isPercent: isPercent));
                },
              ),
            ],
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: CyberChip(
                        label: tr('discountRs'),
                        selected: !isPercent,
                        onSelected: (_) =>
                            setDialogState(() => isPercent = false),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: CyberChip(
                        label: tr('discountPct'),
                        selected: isPercent,
                        onSelected: (_) =>
                            setDialogState(() => isPercent = true),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                CyberTextField(
                  controller: controller,
                  hint: isPercent ? '0-100' : tr('amount'),
                  monospace: true,
                  keyboardType: TextInputType.number,
                  autofocus: true,
                ),
              ],
            ),
          ),
        );
      },
    ),
  );
  controller.dispose();
  return result;
}
