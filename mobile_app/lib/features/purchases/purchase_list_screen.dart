/// Purchase list — route `/purchases`.
///
/// Filters by supplier, date range and status. Each row shows the
/// supplier invoice no., supplier name, date, grand total and remaining
/// payable. Tap opens the purchase detail. Owner / Manager only.
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
import '../catalog/catalog_repository.dart';
import '../customers/customer_helpers.dart';
import 'purchase_detail_screen.dart';
import 'purchase_entry_screen.dart';
import 'purchase_helpers.dart';

const List<String> _purchaseStatuses = [
  'received',
  'partially_returned',
  'returned',
  'cancelled',
];

class PurchaseListScreen extends ConsumerStatefulWidget {
  const PurchaseListScreen({
    super.key,
    required this.purchaseRepository,
    required this.reportRepository,
    required this.productRepository,
    this.catalogRepository,
  });

  static const String routeName = '/purchases';

  final PurchaseRepository purchaseRepository;
  final ReportRepository reportRepository;
  final ProductRepository productRepository;

  /// When null, the entry screen offers product-variant accessories
  /// only (no catalog search).
  final CatalogRepository? catalogRepository;

  @override
  ConsumerState<PurchaseListScreen> createState() => _PurchaseListScreenState();
}

class _PurchaseListScreenState extends ConsumerState<PurchaseListScreen> {
  List<Purchase> _purchases = [];
  List<SupplierSummary> _suppliers = [];
  bool _loading = true;
  String? _error;

  String? _supplierId;
  String? _status;
  DateTime? _from;
  DateTime? _to;

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
      final suppliers = await loadSupplierSummaries(
        suppliers: ref.read(supplierRepositoryProvider),
      );
      final purchases = await widget.purchaseRepository.listPurchases(
        supplierId: _supplierId,
        from: _from,
        to: _to == null
            ? null
            : DateTime(_to!.year, _to!.month, _to!.day, 23, 59, 59),
        status: _status,
      );
      if (!mounted) return;
      setState(() {
        _suppliers = suppliers;
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

  Future<void> _pickDate({required bool isFrom}) async {
    final initial = isFrom ? (_from ?? DateTime.now()) : (_to ?? DateTime.now());
    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked == null) return;
    setState(() {
      if (isFrom) {
        _from = DateTime(picked.year, picked.month, picked.day);
      } else {
        _to = DateTime(picked.year, picked.month, picked.day);
      }
    });
    _load();
  }

  void _clearFilters() {
    setState(() {
      _supplierId = null;
      _status = null;
      _from = null;
      _to = null;
    });
    _load();
  }

  void _openDetail(Purchase purchase) {
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

  Future<void> _openNew() async {
    final saved = await Navigator.of(context).push<bool>(
      MaterialPageRoute<bool>(
        builder: (_) => PurchaseEntryScreen(
          purchaseRepository: widget.purchaseRepository,
          reportRepository: widget.reportRepository,
          productRepository: widget.productRepository,
          catalogRepository: widget.catalogRepository,
        ),
      ),
    );
    if (saved == true) _load();
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
      floatingActionButton: isCashier
          ? null
          : FloatingActionButton.extended(
              onPressed: _openNew,
              icon: const Icon(Icons.add),
              label: Text(_t('newPurchase')),
            ),
      body: Padding(
        padding: const EdgeInsets.all(AppConstants.paddingMedium),
        child: isCashier
            ? cyberRestricted(c, _t('purchasesRestricted'))
            : Column(
                children: [
                  _filters(c),
                  const SizedBox(height: 8),
                  Expanded(child: _buildBody(c)),
                ],
              ),
      ),
    );
  }

  Widget _filters(CyberColors c) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: DropdownButtonFormField<String?>(
                initialValue: _supplierId,
                isExpanded: true,
                decoration:
                    InputDecoration(labelText: _t('filterSupplier')),
                items: [
                  DropdownMenuItem<String?>(
                    value: null,
                    child: Text(_t('all'),
                        style: CyberTextStyles.body(c, size: 14)),
                  ),
                  ..._suppliers.map((supplier) {
                    return DropdownMenuItem<String?>(
                      value: supplier.id,
                      child: Text(supplier.name,
                          style: CyberTextStyles.body(c, size: 14),
                          overflow: TextOverflow.ellipsis),
                    );
                  }),
                ],
                onChanged: (value) {
                  setState(() => _supplierId = value);
                  _load();
                },
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: DropdownButtonFormField<String?>(
                initialValue: _status,
                isExpanded: true,
                decoration: InputDecoration(labelText: _t('filterStatus')),
                items: [
                  DropdownMenuItem<String?>(
                    value: null,
                    child: Text(_t('all'),
                        style: CyberTextStyles.body(c, size: 14)),
                  ),
                  ..._purchaseStatuses.map((status) {
                    return DropdownMenuItem<String?>(
                      value: status,
                      child: Text(_statusLabel(status),
                          style: CyberTextStyles.body(c, size: 14),
                          overflow: TextOverflow.ellipsis),
                    );
                  }),
                ],
                onChanged: (value) {
                  setState(() => _status = value);
                  _load();
                },
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () => _pickDate(isFrom: true),
                icon: const Icon(Icons.calendar_today, size: 18),
                label: Text(
                  _from == null
                      ? _t('fromDate')
                      : '${_t('fromDate')}: ${fmtDate(_from!)}',
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () => _pickDate(isFrom: false),
                icon: const Icon(Icons.calendar_today, size: 18),
                label: Text(
                  _to == null
                      ? _t('toDate')
                      : '${_t('toDate')}: ${fmtDate(_to!)}',
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
            const SizedBox(width: 8),
            TextButton(
              onPressed: _clearFilters,
              child: Text(_t('clearFilters')),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildBody(CyberColors c) {
    if (_loading) return cyberLoading(c, _t('splashLoading'));
    if (_error != null) {
      return cyberError(c, _error!, _load, _t('tryAgain'));
    }
    if (_purchases.isEmpty) {
      return cyberEmpty(c, _t('noPurchases'),
          icon: Icons.receipt_long_outlined);
    }
    return RefreshIndicator(
      onRefresh: _load,
      color: c.primary,
      child: ListView.builder(
        itemCount: _purchases.length,
        itemBuilder: (context, index) {
          final purchase = _purchases[index];
          return CyberCard(
            onTap: () => _openDetail(purchase),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        purchase.supplierInvoiceNo ??
                            purchase.id.substring(0, 8),
                        style: CyberTextStyles.mono(c, size: 15),
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${_supplierName(purchase.supplierId)} · ${fmtDate(purchase.purchaseDate)}',
                        style: CyberTextStyles.bodySecondary(c, size: 13),
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      CyberBadge(
                        label: _statusLabel(purchase.status),
                        color: purchase.status == 'received'
                            ? c.success
                            : c.warning,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    moneyText(c, purchase.grandTotal, size: 15),
                    Text(
                      purchase.balanceDue > 0
                          ? '${_t('balanceDue')}: ${formatPkr(purchase.balanceDue)}'
                          : _t('paid'),
                      style: CyberTextStyles.mono(c, size: 12).copyWith(
                        color: purchase.balanceDue > 0 ? c.error : c.success,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
