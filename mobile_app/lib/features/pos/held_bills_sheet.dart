library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/l10n/app_strings.dart';
import '../../core/theme/app_theme.dart';
import '../../core/theme/cyber_text_styles.dart';
import '../../core/theme/cyber_widgets.dart';
import '../../domain/models/held_bill.dart';
import '../../domain/money.dart';
import '../auth/auth_state.dart';
import '../../core/providers/app_providers.dart';

/// Held-bills sheet for the POS screen: lists parked bills, lets the
/// cashier resume one (it is deleted from the held list by the
/// repository and its cart is restored) or delete it. Returns the
/// resumed [HeldBill], or null when dismissed / deleted.
Future<HeldBill?> showHeldBillsSheet(BuildContext context) {
  return showModalBottomSheet<HeldBill>(
    context: context,
    isScrollControlled: true,
    builder: (context) => const HeldBillsSheet(),
  );
}

class HeldBillsSheet extends ConsumerStatefulWidget {
  const HeldBillsSheet({super.key});

  @override
  ConsumerState<HeldBillsSheet> createState() => _HeldBillsSheetState();
}

class _HeldBillsSheetState extends ConsumerState<HeldBillsSheet> {
  bool _loading = true;
  String? _error;
  List<HeldBill> _bills = <HeldBill>[];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final bills =
          await ref.read(saleRepositoryProvider).listHeldBills();
      if (!mounted) return;
      setState(() {
        _bills = bills;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  int _billTotal(HeldBill bill) {
    var total = 0;
    for (final line in bill.cart) {
      if (line['_meta'] == true) continue;
      final unit = (line['unitPrice'] as num?)?.toInt() ?? 0;
      final qty = (line['quantity'] as num?)?.toInt() ?? 1;
      total += unit * qty;
    }
    return total;
  }

  Future<void> _resume(HeldBill bill) async {
    try {
      final userId = ref.read(authStateProvider).user?.id;
      final resumed = await ref
          .read(saleRepositoryProvider)
          .resumeBill(bill.id, userId: userId);
      if (!mounted) return;
      Navigator.of(context).pop(resumed);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    }
  }

  Future<void> _delete(HeldBill bill) async {
    final userId = ref.read(authStateProvider).user?.id;
    await ref.read(saleRepositoryProvider).deleteHeldBill(
          bill.id,
          userId: userId,
        );
    await _load();
  }

  @override
  Widget build(BuildContext context) {
    final c = ref.watch(themeNotifierProvider).colors;
    final lang = ref.watch(languageProvider);
    String tr(String key) => AppStrings.tr(key, language: lang);

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(tr('heldBills'), style: CyberTextStyles.title(c, size: 18)),
          const SizedBox(height: 12),
          if (_loading)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 24),
              child: Center(child: CircularProgressIndicator()),
            )
          else if (_error != null)
            Column(
              children: [
                Text(_error!, style: CyberTextStyles.error(c)),
                const SizedBox(height: 8),
                CyberButton(
                  label: tr('retry'),
                  variant: CyberButtonVariant.ghost,
                  onPressed: _load,
                ),
              ],
            )
          else if (_bills.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: Text(
                tr('noHeldBills'),
                style: CyberTextStyles.bodySecondary(c),
              ),
            )
          else
            Flexible(
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: _bills.length,
                itemBuilder: (context, index) {
                  final bill = _bills[index];
                  final itemCount = bill.cart
                      .where((line) => line['_meta'] != true)
                      .length;
                  return CyberCard(
                    onTap: () => _resume(bill),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                bill.customerName ??
                                    tr('walkIn'),
                                style: CyberTextStyles.subtitle(c),
                              ),
                              Text(
                                '$itemCount ${tr('cart')} · ${formatPkr(_billTotal(bill))}',
                                style: CyberTextStyles.mono(c, size: 13),
                              ),
                              Text(
                                bill.createdAt.toString().substring(0, 16),
                                style: CyberTextStyles.caption(c),
                              ),
                            ],
                          ),
                        ),
                        CyberButton(
                          label: tr('resume'),
                          fullWidth: false,
                          onPressed: () => _resume(bill),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete_outline),
                          color: c.error,
                          constraints: const BoxConstraints(
                            minWidth: 48,
                            minHeight: 48,
                          ),
                          onPressed: () => _delete(bill),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          const SizedBox(height: 8),
          CyberButton(
            label: tr('close'),
            variant: CyberButtonVariant.ghost,
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      ),
    );
  }
}
