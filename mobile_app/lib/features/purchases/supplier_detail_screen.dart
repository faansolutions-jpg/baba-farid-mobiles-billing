/// Supplier detail — route `/suppliers/:id`.
///
/// Supplier profile, total payable, supplier ledger (date, description,
/// debit/credit, running balance) and the supplier's purchases.
/// Record a payment: pick one of the supplier's unpaid purchases,
/// enter the amount (capped at that purchase's balance due) and method;
/// the payable updates immediately on reload. Owner / Manager only.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/config/constants.dart';
import '../../core/l10n/app_strings.dart';
import '../../core/theme/app_theme.dart';
import '../../core/theme/cyber_colors.dart';
import '../../core/theme/cyber_text_styles.dart';
import '../../core/theme/cyber_widgets.dart';
import '../../data/repositories/product_repository.dart';
import '../../data/repositories/purchase_repository.dart';
import '../../data/repositories/report_repository.dart';
import '../../domain/models/ledger_entry.dart';
import '../../domain/models/purchase.dart';
import '../../domain/money.dart';
import '../auth/auth_state.dart';
import '../customers/customer_helpers.dart';
import 'purchase_detail_screen.dart';
import 'purchase_helpers.dart';

class SupplierDetailScreen extends ConsumerStatefulWidget {
  const SupplierDetailScreen({
    super.key,
    required this.purchaseRepository,
    required this.reportRepository,
    required this.productRepository,
    required this.supplier,
  });

  static const String routeName = '/suppliers/:id';

  final PurchaseRepository purchaseRepository;
  final ReportRepository reportRepository;
  final ProductRepository productRepository;
  final SupplierSummary supplier;

  @override
  ConsumerState<SupplierDetailScreen> createState() =>
      _SupplierDetailScreenState();
}

class _SupplierDetailScreenState extends ConsumerState<SupplierDetailScreen> {
  int _payable = 0;
  List<LedgerEntry> _ledger = [];
  List<Purchase> _purchases = [];
  bool _loading = true;
  String? _error;

  String get _lang => ref.read(languageProvider);

  String _t(String key) => AppStrings.tr(key, language: _lang);

  @override
  void initState() {
    super.initState();
    _payable = widget.supplier.payable;
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final payable = await widget.purchaseRepository
          .supplierPayable(widget.supplier.id);
      final ledger = await widget.purchaseRepository
          .supplierLedger(widget.supplier.id);
      final purchases = await widget.purchaseRepository.listPurchases(
        supplierId: widget.supplier.id,
      );
      if (!mounted) return;
      setState(() {
        _payable = payable;
        _ledger = ledger;
        _purchases = purchases;
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

  String _userId() => ref.read(authStateProvider).user?.id ?? 'system';

  List<Purchase> get _unpaid =>
      _purchases.where((p) => p.balanceDue > 0).toList();

  Future<void> _recordPayment() async {
    if (_unpaid.isEmpty) {
      showSnack(context, _t('noUnpaidPurchase'));
      return;
    }
    final input = await showDialog<_SupplierPaymentInput>(
      context: context,
      builder: (dialogContext) => _SupplierPaymentDialog(
        purchases: _unpaid,
        language: _lang,
      ),
    );
    if (input == null) return;
    try {
      await widget.purchaseRepository.recordPurchasePayment(
        purchaseId: input.purchase.id,
        amount: input.amount,
        method: input.method,
        userId: _userId(),
        notes: input.note,
      );
      if (!mounted) return;
      showSnack(context, _t('paymentRecorded'));
      _load();
    } catch (e) {
      if (!mounted) return;
      showSnack(context, e.toString(), isError: true);
    }
  }

  void _openPurchase(Purchase purchase) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => PurchaseDetailScreen(
          purchaseRepository: widget.purchaseRepository,
          reportRepository: widget.reportRepository,
          productRepository: widget.productRepository,
          purchaseId: purchase.id,
        ),
      ),
    ).then((_) => _load());
  }

  @override
  Widget build(BuildContext context) {
    final c = ref.watch(themeNotifierProvider).colors;
    final isCashier =
        ref.watch(authStateProvider).user?.role == UserRoles.cashier;
    return Scaffold(
      appBar: CyberAppBar(
        title: widget.supplier.name,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: _t('refresh'),
            onPressed: _load,
          ),
        ],
      ),
      body: isCashier
          ? Padding(
              padding: const EdgeInsets.all(AppConstants.paddingMedium),
              child: cyberRestricted(c, _t('purchasesRestricted')),
            )
          : _loading
              ? cyberLoading(c, _t('splashLoading'))
              : _error != null
                  ? cyberError(c, _error!, _load, _t('tryAgain'))
                  : _buildDetail(c),
    );
  }

  Widget _buildDetail(CyberColors c) {
    final supplier = widget.supplier;
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppConstants.paddingMedium),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          CyberCard(
            borderColor: payableColor(c, _payable),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(supplier.name,
                          style: CyberTextStyles.title(c)),
                      const SizedBox(height: 2),
                      Text(supplier.phone,
                          style: CyberTextStyles.mono(c, size: 14)
                              .copyWith(color: c.textSecondary)),
                      const SizedBox(height: 8),
                      Text(_t('totalPayable'),
                          style: CyberTextStyles.label(c)),
                      moneyText(c, _payable,
                          size: 28, color: payableColor(c, _payable)),
                    ],
                  ),
                ),
                CyberBadge(
                  label: _payable > 0 ? _t('payable') : _t('paid'),
                  color: payableColor(c, _payable),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          CyberButton(
            label: _t('recordSupplierPayment'),
            icon: Icons.payments,
            onPressed: _recordPayment,
          ),
          const SizedBox(height: 20),
          Text(_t('supplierPurchases'),
              style: CyberTextStyles.title(c, size: 17)),
          const SizedBox(height: 8),
          if (_purchases.isEmpty)
            Text(_t('noPurchases'),
                style: CyberTextStyles.bodySecondary(c))
          else
            ..._purchases.map((purchase) => CyberCard(
                  onTap: () => _openPurchase(purchase),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              purchase.supplierInvoiceNo ??
                                  purchase.id.substring(0, 8),
                              style: CyberTextStyles.mono(c, size: 14),
                            ),
                            Text(
                              fmtDate(purchase.purchaseDate),
                              style: CyberTextStyles.bodySecondary(c,
                                  size: 13),
                            ),
                          ],
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          moneyText(c, purchase.grandTotal, size: 15),
                          Text(
                            purchase.balanceDue > 0
                                ? '${_t('balanceDue')}: ${formatPkr(purchase.balanceDue)}'
                                : _t('paid'),
                            style: CyberTextStyles.mono(c, size: 12)
                                .copyWith(
                              color: purchase.balanceDue > 0
                                  ? c.error
                                  : c.success,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                )),
          const SizedBox(height: 20),
          Text(_t('ledger'), style: CyberTextStyles.title(c, size: 17)),
          const SizedBox(height: 8),
          if (_ledger.isEmpty)
            Text(_t('ledgerEmpty'),
                style: CyberTextStyles.bodySecondary(c))
          else
            CyberTable(
              headers: [
                _t('date'),
                _t('description'),
                _t('debit'),
                _t('credit'),
                _t('balance'),
              ],
              rows: _ledger.map((entry) {
                return [
                  fmtDate(entry.entryDate),
                  entry.notes?.isNotEmpty == true
                      ? entry.notes!
                      : entry.referenceType,
                  entry.debit == 0 ? '-' : formatPkr(entry.debit),
                  entry.credit == 0 ? '-' : formatPkr(entry.credit),
                  formatPkr(entry.balanceAfter),
                ];
              }).toList(),
              monospaceColumns: const {0, 2, 3, 4},
            ),
        ],
      ),
    );
  }
}

class _SupplierPaymentInput {
  const _SupplierPaymentInput({
    required this.purchase,
    required this.amount,
    required this.method,
    this.note,
  });

  final Purchase purchase;
  final int amount;
  final String method;
  final String? note;
}

/// Payment dialog with a picker for which unpaid purchase to pay
/// against (the repository records payments per purchase, not per
/// supplier, so the purchase must be chosen explicitly).
class _SupplierPaymentDialog extends StatefulWidget {
  const _SupplierPaymentDialog({
    required this.purchases,
    required this.language,
  });

  final List<Purchase> purchases;
  final String language;

  @override
  State<_SupplierPaymentDialog> createState() => _SupplierPaymentDialogState();
}

class _SupplierPaymentDialogState extends State<_SupplierPaymentDialog> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _noteController = TextEditingController();
  late Purchase _selected;
  String _method = PaymentMethods.cash;

  String _t(String key) => AppStrings.tr(key, language: widget.language);

  @override
  void initState() {
    super.initState();
    _selected = widget.purchases.first;
    _amountController.text = _selected.balanceDue.toString();
  }

  @override
  void dispose() {
    _amountController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (context, ref, _) {
        final c = ref.watch(themeNotifierProvider).colors;
        return CyberDialog(
          title: _t('recordSupplierPayment'),
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
                  _SupplierPaymentInput(
                    purchase: _selected,
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
                DropdownButtonFormField<Purchase>(
                  initialValue: _selected,
                  isExpanded: true,
                  decoration:
                      InputDecoration(labelText: _t('selectPurchase')),
                  items: widget.purchases.map((purchase) {
                    return DropdownMenuItem<Purchase>(
                      value: purchase,
                      child: Text(
                        '${purchase.supplierInvoiceNo ?? purchase.id.substring(0, 8)}'
                        ' · ${_t('balanceDue')} ${formatPkr(purchase.balanceDue)}',
                        style: CyberTextStyles.body(c, size: 14),
                        overflow: TextOverflow.ellipsis,
                      ),
                    );
                  }).toList(),
                  onChanged: (purchase) {
                    if (purchase == null) return;
                    setState(() {
                      _selected = purchase;
                      _amountController.text =
                          purchase.balanceDue.toString();
                    });
                  },
                ),
                const SizedBox(height: 12),
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
                    if (amount > _selected.balanceDue) {
                      return '${_t('invalidAmount')} (max ${formatPkr(_selected.balanceDue)})';
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
