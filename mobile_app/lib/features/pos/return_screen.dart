library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/l10n/app_strings.dart';
import '../../core/theme/app_theme.dart';
import '../../core/theme/cyber_text_styles.dart';
import '../../core/theme/cyber_widgets.dart';
import '../../domain/models/sale.dart';
import '../../domain/money.dart';
import '../auth/auth_state.dart';
import '../../core/providers/app_providers.dart';

/// Returns & exchange screen (route `/pos/returns`).
///
/// Find a sale by invoice number (or sale id), tick the items to
/// return, set a quantity per item and a reason. The refund is shown
/// live. Confirming calls [SaleRepository.returnSale] once per item —
/// the repository restores the IMEI to `available` (or the accessory
/// quantity), credits the customer ledger and refunds cash. This
/// screen only collects the input and confirms the result.
class ReturnScreen extends ConsumerStatefulWidget {
  const ReturnScreen({super.key});

  @override
  ConsumerState<ReturnScreen> createState() => _ReturnScreenState();
}

class _ReturnScreenState extends ConsumerState<ReturnScreen> {
  final TextEditingController _invoiceController = TextEditingController();
  final TextEditingController _reasonController = TextEditingController();

  bool _finding = false;
  bool _returning = false;
  String? _error;
  Sale? _sale;
  final Map<String, bool> _selected = <String, bool>{};
  final Map<String, int> _quantities = <String, int>{};
  String _reasonKey = 'reasonChangedMind';
  bool _isExchange = false;
  int? _completedRefund;

  @override
  void dispose() {
    _invoiceController.dispose();
    _reasonController.dispose();
    super.dispose();
  }

  String get _userId => ref.read(authStateProvider).user?.id ?? '';

  static const List<String> _reasonKeys = <String>[
    'reasonDamaged',
    'reasonWrongItem',
    'reasonChangedMind',
    'reasonDefective',
    'reasonOther',
  ];

  Future<void> _findSale() async {
    final lang = ref.read(languageProvider);
    String tr(String key) => AppStrings.tr(key, language: lang);
    final query = _invoiceController.text.trim();
    if (query.isEmpty) return;
    setState(() {
      _finding = true;
      _error = null;
      _sale = null;
      _completedRefund = null;
    });
    try {
      final repo = ref.read(saleRepositoryProvider);
      Sale? sale;
      // Direct id lookup first (deep links / QR), then invoice number
      // among recent sales — the repository has no invoice search.
      sale = await repo.getSale(query);
      sale ??= (await repo.listSales(limit: 100))
          .where(
            (s) => s.invoiceNo.toLowerCase() == query.toLowerCase(),
          )
          .firstOrNull;
      if (!mounted) return;
      if (sale == null) {
        setState(() {
          _error = tr('noSaleFound');
          _finding = false;
        });
        return;
      }
      setState(() {
        _sale = sale;
        _selected.clear();
        _quantities.clear();
        for (final item in sale!.items) {
          _selected[item.id] = false;
          _quantities[item.id] = item.quantity;
        }
        _finding = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString();
        _finding = false;
      });
    }
  }

  int _refundFor(SaleItem item, int qty) {
    // Mirrors the repository: unit price * qty minus the item's
    // per-unit discount share (integer division, same as the server).
    final discountShare = item.discount * qty ~/ item.quantity;
    return item.unitPrice * qty - discountShare;
  }

  int get _totalRefund {
    final sale = _sale;
    if (sale == null) return 0;
    var total = 0;
    for (final item in sale.items) {
      if (_selected[item.id] == true) {
        total += _refundFor(item, _quantities[item.id] ?? 1);
      }
    }
    return total;
  }

  bool get _hasSelection =>
      _selected.values.any((selected) => selected);

  Future<void> _confirmReturn() async {
    final lang = ref.read(languageProvider);
    String tr(String key) => AppStrings.tr(key, language: lang);
    final sale = _sale;
    if (sale == null || !_hasSelection || _returning) return;
    final reason = _reasonKey == 'reasonOther'
        ? (_reasonController.text.trim().isEmpty
            ? tr('reasonOther')
            : _reasonController.text.trim())
        : tr(_reasonKey);
    final confirmed = await showCyberDialog(
      context,
      title: tr('confirmReturn'),
      message:
          '${tr('totalRefund')}: ${formatPkr(_totalRefund)}\n${tr('returnReason')}: $reason',
      confirmLabel: tr('confirmReturn'),
    );
    if (!confirmed) return;
    setState(() {
      _returning = true;
      _error = null;
    });
    try {
      final repo = ref.read(saleRepositoryProvider);
      var refund = 0;
      for (final item in sale.items) {
        if (_selected[item.id] != true) continue;
        final qty = _quantities[item.id] ?? 1;
        refund += _refundFor(item, qty);
        await repo.returnSale(
          saleId: sale.id,
          saleItemId: item.id,
          quantity: qty,
          reason: reason,
          userId: _userId,
          isExchange: _isExchange,
        );
      }
      if (!mounted) return;
      setState(() {
        _completedRefund = refund;
        _returning = false;
        _sale = null;
        _selected.clear();
        _quantities.clear();
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(tr('returnCompleted'))),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString();
        _returning = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = ref.watch(themeNotifierProvider).colors;
    final lang = ref.watch(languageProvider);
    String tr(String key) => AppStrings.tr(key, language: lang);
    final sale = _sale;

    return Scaffold(
      appBar: CyberAppBar(title: tr('returnItem')),
      body: ListView(
        padding: const EdgeInsets.all(12),
        children: [
          Row(
            children: [
              Expanded(
                child: CyberTextField(
                  controller: _invoiceController,
                  label: tr('invoiceNo'),
                  hint: 'INV-0001',
                  monospace: true,
                  textInputAction: TextInputAction.search,
                  onSubmitted: (_) => _findSale(),
                ),
              ),
              const SizedBox(width: 8),
              CyberButton(
                label: tr('search'),
                fullWidth: false,
                isLoading: _finding,
                onPressed: _findSale,
              ),
            ],
          ),
          if (_error != null) ...[
            const SizedBox(height: 12),
            CyberCard(
              borderColor: c.error,
              child: Text(_error!, style: CyberTextStyles.error(c)),
            ),
          ],
          if (_completedRefund != null) ...[
            const SizedBox(height: 12),
            CyberCard(
              borderColor: c.success,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    tr('itemsReturned'),
                    style: CyberTextStyles.subtitle(c),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${tr('totalRefund')}: ${formatPkr(_completedRefund!)}',
                    style: CyberTextStyles.amount(c, size: 22),
                  ),
                ],
              ),
            ),
          ],
          if (sale != null) ...[
            const SizedBox(height: 12),
            CyberCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        sale.invoiceNo,
                        style: CyberTextStyles.mono(c, size: 17),
                      ),
                      CyberBadge(
                        label: sale.status.toUpperCase(),
                        color: sale.status == 'completed'
                            ? c.success
                            : c.warning,
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${sale.customerName ?? tr('walkIn')} · ${sale.saleDate.toString().substring(0, 16)}',
                    style: CyberTextStyles.bodySecondary(c),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${tr('grandTotal')}: ${formatPkr(sale.grandTotal)} · ${tr('paid')}: ${formatPkr(sale.paidAmount)}',
                    style: CyberTextStyles.mono(c, size: 14),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              tr('selectItemsToReturn'),
              style: CyberTextStyles.subtitle(c),
            ),
            ...sale.items.map((item) {
              final selected = _selected[item.id] == true;
              final qty = _quantities[item.id] ?? 1;
              return CyberCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Checkbox(
                          value: selected,
                          onChanged: (value) => setState(
                            () => _selected[item.id] = value ?? false,
                          ),
                        ),
                        Expanded(
                          child: Text(
                            item.nameSnapshot,
                            style: CyberTextStyles.body(c),
                          ),
                        ),
                        Text(
                          formatPkr(item.unitPrice),
                          style: CyberTextStyles.mono(c, size: 15),
                        ),
                      ],
                    ),
                    if (selected)
                      Row(
                        children: [
                          Text('${tr('returnQty')}: '),
                          SizedBox(
                            width: 48,
                            height: 48,
                            child: IconButton(
                              icon: const Icon(Icons.remove),
                              onPressed: qty <= 1
                                  ? null
                                  : () => setState(
                                        () => _quantities[item.id] = qty - 1,
                                      ),
                            ),
                          ),
                          Text(
                            '$qty',
                            style: CyberTextStyles.mono(c, size: 16),
                          ),
                          SizedBox(
                            width: 48,
                            height: 48,
                            child: IconButton(
                              icon: const Icon(Icons.add),
                              onPressed: qty >= item.quantity
                                  ? null
                                  : () => setState(
                                        () => _quantities[item.id] = qty + 1,
                                      ),
                            ),
                          ),
                          const Spacer(),
                          Text(
                            '${tr('refundAmount')}: ${formatPkr(_refundFor(item, qty))}',
                            style: CyberTextStyles.mono(c, size: 14)
                                .copyWith(color: c.secondary),
                          ),
                        ],
                      ),
                  ],
                ),
              );
            }),
            const SizedBox(height: 12),
            Text(tr('returnReason'), style: CyberTextStyles.subtitle(c)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final key in _reasonKeys)
                  CyberChip(
                    label: tr(key),
                    selected: _reasonKey == key,
                    onSelected: (_) =>
                        setState(() => _reasonKey = key),
                  ),
              ],
            ),
            if (_reasonKey == 'reasonOther') ...[
              const SizedBox(height: 12),
              CyberTextField(
                controller: _reasonController,
                label: tr('returnReason'),
              ),
            ],
            const SizedBox(height: 12),
            CyberToggle(
              label: tr('exchange'),
              value: _isExchange,
              onChanged: (value) => setState(() => _isExchange = value),
            ),
            const SizedBox(height: 12),
            CyberCard(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    tr('totalRefund'),
                    style: CyberTextStyles.title(c, size: 17),
                  ),
                  Text(
                    formatPkr(_totalRefund),
                    style: CyberTextStyles.amount(c, size: 24),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            CyberButton(
              label: tr('confirmReturn'),
              icon: Icons.assignment_return_outlined,
              isLoading: _returning,
              onPressed: _hasSelection ? _confirmReturn : null,
            ),
          ] else if (!_finding) ...[
            const SizedBox(height: 24),
            Center(
              child: Text(
                tr('selectSaleFirst'),
                style: CyberTextStyles.bodySecondary(c),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
