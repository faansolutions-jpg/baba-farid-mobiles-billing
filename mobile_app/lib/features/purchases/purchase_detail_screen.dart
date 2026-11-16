/// Purchase detail — route `/purchases/:id`.
///
/// Items (with IMEI list), returns, paid / remaining payable, and
/// actions to record a payment or return items. Owner / Manager only.
///
/// Note: no repository method lists the individual payments made
/// against one purchase, so the screen shows the paid total and the
/// remaining payable from the purchase itself; the per-payment rows
/// live on the supplier ledger (supplier detail screen).
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/config/constants.dart';
import '../../core/l10n/app_strings.dart';
import '../../core/providers/app_providers.dart';
import '../../core/theme/app_theme.dart';
import '../../core/theme/cyber_colors.dart';
import '../../core/theme/cyber_text_styles.dart';
import '../../core/theme/cyber_widgets.dart';
import '../../data/repositories/product_repository.dart';
import '../../data/repositories/purchase_repository.dart';
import '../../data/repositories/report_repository.dart';
import '../../domain/models/purchase.dart';
import '../../domain/money.dart';
import '../auth/auth_state.dart';
import '../customers/customer_helpers.dart';
import 'purchase_helpers.dart';
import 'purchase_return_screen.dart';

class PurchaseDetailScreen extends ConsumerStatefulWidget {
  const PurchaseDetailScreen({
    super.key,
    required this.purchaseRepository,
    required this.reportRepository,
    required this.productRepository,
    required this.purchaseId,
  });

  static const String routeName = '/purchases/:id';

  final PurchaseRepository purchaseRepository;
  final ReportRepository reportRepository;

  /// Passed through to the return screen (resolves IMEI item ids).
  final ProductRepository productRepository;
  final String purchaseId;

  @override
  ConsumerState<PurchaseDetailScreen> createState() =>
      _PurchaseDetailScreenState();
}

class _PurchaseDetailScreenState extends ConsumerState<PurchaseDetailScreen> {
  Purchase? _purchase;
  List<PurchaseReturn> _returns = [];
  List<SupplierSummary> _suppliers = [];
  bool _loading = true;
  String? _error;

  String get _lang => ref.read(languageProvider);

  String _t(String key) => AppStrings.tr(key, language: _lang);

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
      final purchase =
          await widget.purchaseRepository.getPurchase(widget.purchaseId);
      if (purchase == null) {
        throw Exception(_t('purchaseNotFound'));
      }
      final returns = await widget.purchaseRepository
          .listPurchaseReturns(widget.purchaseId);
      final suppliers = await loadSupplierSummaries(
        suppliers: ref.read(supplierRepositoryProvider),
      );
      if (!mounted) return;
      setState(() {
        _purchase = purchase;
        _returns = returns;
        _suppliers = suppliers;
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

  String _supplierName(String supplierId) {
    for (final supplier in _suppliers) {
      if (supplier.id == supplierId) return supplier.name;
    }
    return _t('unknownSupplier');
  }

  String _statusLabel(String status) {
    switch (status) {
      case 'received':
        return _t('statusReceived');
      case 'partially_returned':
        return _t('statusPartiallyReturned');
      case 'returned':
        return _t('statusReturned');
      case 'cancelled':
        return _t('statusCancelled');
      default:
        return status;
    }
  }

  Future<void> _recordPayment() async {
    final purchase = _purchase;
    if (purchase == null || purchase.balanceDue <= 0) return;
    final input = await showPaymentDialog(
      context,
      title: _t('recordPayment'),
      maxAmount: purchase.balanceDue,
      defaultAmount: purchase.balanceDue,
      language: _lang,
    );
    if (input == null) return;
    try {
      await widget.purchaseRepository.recordPurchasePayment(
        purchaseId: purchase.id,
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

  void _openReturn() {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => PurchaseReturnScreen(
          purchaseRepository: widget.purchaseRepository,
          productRepository: widget.productRepository,
          purchaseId: widget.purchaseId,
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
        title: _t('purchaseList'),
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
    final purchase = _purchase!;
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppConstants.paddingMedium),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          CyberCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        purchase.supplierInvoiceNo ??
                            purchase.id.substring(0, 8),
                        style: CyberTextStyles.mono(c, size: 18),
                      ),
                    ),
                    CyberBadge(
                      label: _statusLabel(purchase.status),
                      color: purchase.status == 'received'
                          ? c.success
                          : c.warning,
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  '${_supplierName(purchase.supplierId)} · ${fmtDate(purchase.purchaseDate)}',
                  style: CyberTextStyles.bodySecondary(c),
                ),
                if (purchase.notes?.isNotEmpty == true) ...[
                  const SizedBox(height: 4),
                  Text(purchase.notes!,
                      style: CyberTextStyles.bodySecondary(c, size: 13)),
                ],
              ],
            ),
          ),
          const SizedBox(height: 12),
          CyberCard(
            child: Column(
              children: [
                _totalRow(c, _t('subtotal'), purchase.subtotal),
                _totalRow(c, _t('discount'), purchase.discount),
                _totalRow(c, _t('grandTotal'), purchase.grandTotal,
                    bold: true),
                _totalRow(c, _t('paid'), purchase.paidAmount),
                _totalRow(
                  c,
                  _t('balanceDue'),
                  purchase.balanceDue,
                  color: purchase.balanceDue > 0 ? c.error : c.success,
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: CyberButton(
                  label: _t('recordPayment'),
                  icon: Icons.payments,
                  onPressed: purchase.balanceDue > 0 ? _recordPayment : null,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: CyberButton(
                  label: _t('returnItems'),
                  variant: CyberButtonVariant.ghost,
                  icon: Icons.undo,
                  onPressed: _openReturn,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Text(_t('purchaseItems'),
              style: CyberTextStyles.title(c, size: 17)),
          const SizedBox(height: 8),
          if (purchase.items.isEmpty)
            Text(_t('noPurchases'), style: CyberTextStyles.bodySecondary(c))
          else
            ...purchase.items.map((item) => CyberCard(
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (item.imei1 != null)
                              Text(item.imei1!,
                                  style: CyberTextStyles.imei(c, size: 14))
                            else
                              Text(
                                _t('accessoryItem'),
                                style: CyberTextStyles.body(c, size: 14),
                              ),
                            if (item.imei2 != null)
                              Text(item.imei2!,
                                  style: CyberTextStyles.imei(c, size: 12)
                                      .copyWith(color: c.textSecondary)),
                            Text(
                              '× ${item.quantity}',
                              style: CyberTextStyles.bodySecondary(c,
                                  size: 13),
                            ),
                          ],
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          moneyText(c, item.total, size: 15),
                          Text(
                            '${formatPkr(item.unitCost)} / ${_t('unitCost').toLowerCase()}',
                            style: CyberTextStyles.mono(c, size: 12)
                                .copyWith(color: c.textSecondary),
                          ),
                        ],
                      ),
                    ],
                  ),
                )),
          const SizedBox(height: 20),
          Text(_t('purchaseReturns'),
              style: CyberTextStyles.title(c, size: 17)),
          const SizedBox(height: 8),
          if (_returns.isEmpty)
            Text(_t('noReturns'), style: CyberTextStyles.bodySecondary(c))
          else
            ..._returns.map((ret) => CyberCard(
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              ret.reason ?? _t('purchaseReturn'),
                              style: CyberTextStyles.body(c, size: 14),
                            ),
                            Text(
                              '${fmtDate(ret.createdAt)} · × ${ret.quantity}',
                              style: CyberTextStyles.bodySecondary(c,
                                  size: 13),
                            ),
                          ],
                        ),
                      ),
                      moneyText(c, ret.refundAmount,
                          size: 15, color: c.warning),
                    ],
                  ),
                )),
        ],
      ),
    );
  }

  Widget _totalRow(CyberColors c, String label, int amount,
      {bool bold = false, Color? color}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: bold
                  ? CyberTextStyles.subtitle(c)
                  : CyberTextStyles.body(c, size: 14),
            ),
          ),
          moneyText(c, amount, size: bold ? 18 : 15, color: color),
        ],
      ),
    );
  }
}
