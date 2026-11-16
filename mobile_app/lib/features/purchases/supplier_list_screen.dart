/// Suppliers list — route `/suppliers`.
///
/// Search by name; each row shows the name, phone and total payable
/// (red = owes, green = settled). Tap opens the supplier detail with
/// the supplier ledger. Owner / Manager only: cost-side data is hidden
/// from cashiers (see `purchasesRestricted`).
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
import '../../data/repositories/supplier_repository.dart';
import '../../domain/models/supplier.dart';
import '../auth/auth_state.dart';
import '../customers/customer_helpers.dart';
import 'purchase_helpers.dart';
import 'supplier_detail_screen.dart';

class SupplierListScreen extends ConsumerStatefulWidget {
  const SupplierListScreen({
    super.key,
    required this.purchaseRepository,
    required this.reportRepository,
    required this.productRepository,
    this.supplierRepository,
  });

  static const String routeName = '/suppliers';

  final PurchaseRepository purchaseRepository;
  final ReportRepository reportRepository;

  /// When null, the shared [supplierRepositoryProvider] is used, so
  /// the list always sources ALL suppliers (including zero-payable
  /// ones) from [SupplierRepository].
  final SupplierRepository? supplierRepository;

  /// Passed through to the detail screen so purchase returns can
  /// resolve IMEI item ids.
  final ProductRepository productRepository;

  @override
  ConsumerState<SupplierListScreen> createState() => _SupplierListScreenState();
}

class _SupplierListScreenState extends ConsumerState<SupplierListScreen> {
  final _searchController = TextEditingController();

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

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final suppliers = await loadSupplierSummaries(
        suppliers: widget.supplierRepository ??
            ref.read(supplierRepositoryProvider),
      );
      if (!mounted) return;
      setState(() {
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

  List<SupplierSummary> get _filtered {
    final query = _searchController.text.trim().toLowerCase();
    if (query.isEmpty) return _suppliers;
    return _suppliers
        .where((s) =>
            s.name.toLowerCase().contains(query) ||
            s.phone.toLowerCase().contains(query))
        .toList();
  }

  void _openDetail(SupplierSummary supplier) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => SupplierDetailScreen(
          purchaseRepository: widget.purchaseRepository,
          reportRepository: widget.reportRepository,
          productRepository: widget.productRepository,
          supplier: supplier,
        ),
      ),
    ).then((_) => _load());
  }

  Future<void> _addSupplierDialog() async {
    final nameController = TextEditingController();
    final phoneController = TextEditingController();
    final addressController = TextEditingController();
    final payableController = TextEditingController(text: '0');
    final formKey = GlobalKey<FormState>();
    final saved = await showDialog<bool>(
      context: context,
      builder: (context) => CyberDialog(
        title: _t('addSupplier'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(_t('cancel')),
          ),
          CyberButton(
            label: _t('save'),
            fullWidth: false,
            onPressed: () {
              if (formKey.currentState?.validate() ?? false) {
                Navigator.of(context).pop(true);
              }
            },
          ),
        ],
        child: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CyberTextField(
                controller: nameController,
                label: _t('supplierName'),
                autofocus: true,
                validator: (v) => (v == null || v.trim().isEmpty)
                    ? _t('fieldRequired')
                    : null,
              ),
              const SizedBox(height: 12),
              CyberTextField(
                controller: phoneController,
                label: _t('phone'),
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 12),
              CyberTextField(
                controller: addressController,
                label: _t('address'),
              ),
              const SizedBox(height: 12),
              CyberTextField(
                controller: payableController,
                label: _t('openingPayable'),
                keyboardType: TextInputType.number,
                monospace: true,
                validator: (v) {
                  final amount =
                      int.tryParse((v ?? '').trim().replaceAll(',', ''));
                  if (amount == null || amount < 0) {
                    return _t('invalidAmount');
                  }
                  return null;
                },
              ),
            ],
          ),
        ),
      ),
    );
    final name = nameController.text.trim();
    final phone = phoneController.text.trim();
    final address = addressController.text.trim();
    final openingPayable =
        int.tryParse(payableController.text.trim().replaceAll(',', '')) ??
            0;
    nameController.dispose();
    phoneController.dispose();
    addressController.dispose();
    payableController.dispose();
    if (saved != true || name.isEmpty) return;
    try {
      final SupplierRepository repository = widget.supplierRepository ??
          ref.read(supplierRepositoryProvider);
      await repository.createSupplier(
        Supplier(
          id: '',
          name: name,
          phone: phone.isEmpty ? null : phone,
          address: address.isEmpty ? null : address,
          openingPayable: openingPayable,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
        userId: ref.read(authStateProvider).user?.id ?? 'system',
      );
      if (!mounted) return;
      showSnack(context, _t('saved'));
      await _load();
    } catch (e) {
      if (!mounted) return;
      showSnack(context, e.toString(), isError: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = ref.watch(themeNotifierProvider).colors;
    final isCashier =
        ref.watch(authStateProvider).user?.role == UserRoles.cashier;
    return Scaffold(
      appBar: CyberAppBar(
        title: _t('suppliers'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            tooltip: _t('addSupplier'),
            onPressed: _addSupplierDialog,
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: _t('refresh'),
            onPressed: _load,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(AppConstants.paddingMedium),
        child: isCashier
            ? cyberRestricted(c, _t('purchasesRestricted'))
            : Column(
                children: [
                  CyberSearchBar(
                    hint: _t('searchSuppliersHint'),
                    controller: _searchController,
                    onChanged: (_) => setState(() {}),
                  ),
                  const SizedBox(height: 8),
                  Expanded(child: _buildBody(c)),
                ],
              ),
      ),
    );
  }

  Widget _buildBody(CyberColors c) {
    if (_loading) return cyberLoading(c, _t('splashLoading'));
    if (_error != null) {
      return cyberError(c, _error!, _load, _t('tryAgain'));
    }
    final suppliers = _filtered;
    if (suppliers.isEmpty) {
      return cyberEmpty(c, _t('noSuppliers'), icon: Icons.store_outlined);
    }
    return RefreshIndicator(
      onRefresh: _load,
      color: c.primary,
      child: ListView.builder(
        itemCount: suppliers.length,
        itemBuilder: (context, index) {
          final supplier = suppliers[index];
          return CyberCard(
            onTap: () => _openDetail(supplier),
            child: Row(
              children: [
                CircleAvatar(
                  backgroundColor: c.secondary.withValues(alpha: 0.15),
                  child: Text(
                    supplier.name.isEmpty
                        ? '?'
                        : supplier.name[0].toUpperCase(),
                    style: CyberTextStyles.title(c, size: 18)
                        .copyWith(color: c.secondary),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        supplier.name,
                        style: CyberTextStyles.subtitle(c),
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        supplier.phone,
                        style: CyberTextStyles.mono(c, size: 13)
                            .copyWith(color: c.textSecondary),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      _t('payable'),
                      style: CyberTextStyles.caption(c, size: 11),
                    ),
                    moneyText(
                      c,
                      supplier.payable,
                      size: 16,
                      color: payableColor(c, supplier.payable),
                    ),
                  ],
                ),
                const SizedBox(width: 4),
                Icon(Icons.chevron_right, color: c.textSecondary),
              ],
            ),
          );
        },
      ),
    );
  }
}
