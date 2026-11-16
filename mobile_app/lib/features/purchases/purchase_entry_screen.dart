/// Purchase entry — route `/purchases/new`.
///
/// Pick a supplier, supplier invoice no. + date, then add lines:
/// * Phones — pick a product + variant, enter the unit cost, paste many
///   IMEIs (one per line). Each IMEI is validated (15 digits + Luhn
///   check digit) and duplicates — inside the paste or already in the
///   purchase — are shown as a per-line error list, never silently
///   dropped. One purchase line is created per IMEI.
/// * Accessories — pick from the accessories catalog
///   ([CatalogRepository.search] + `stockIn` on save) or from a product
///   variant, with quantity + unit cost per line.
/// "Repeat last supplier invoice" loads the supplier's most recent
/// purchase as a template (phone IMEIs are never copied — new IMEIs
/// must be pasted). Save goes through
/// [PurchaseRepository.createPurchase] so stock auto-adds. Owner /
/// Manager only: the whole screen is cost prices.
library;

import 'dart:async';

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
import '../../domain/models/product.dart';
import '../../domain/models/product_variant.dart';
import '../../domain/models/purchase.dart';
import '../../domain/money.dart';
import '../../domain/rules.dart';
import '../auth/auth_state.dart';
import '../catalog/catalog_models.dart';
import '../catalog/catalog_repository.dart';
import '../customers/customer_helpers.dart';
import 'purchase_helpers.dart';

class PurchaseEntryScreen extends ConsumerStatefulWidget {
  const PurchaseEntryScreen({
    super.key,
    required this.purchaseRepository,
    required this.reportRepository,
    required this.productRepository,
    this.catalogRepository,
  });

  static const String routeName = '/purchases/new';

  final PurchaseRepository purchaseRepository;
  final ReportRepository reportRepository;
  final ProductRepository productRepository;

  /// When null, accessories can only come from product variants.
  final CatalogRepository? catalogRepository;

  @override
  ConsumerState<PurchaseEntryScreen> createState() =>
      _PurchaseEntryScreenState();
}

class _PurchaseEntryScreenState extends ConsumerState<PurchaseEntryScreen> {
  List<SupplierSummary> _suppliers = [];
  bool _loadingSuppliers = true;
  bool _saving = false;

  String? _supplierId;
  final _invoiceController = TextEditingController();
  DateTime _purchaseDate = DateTime.now();
  final _discountController = TextEditingController(text: '0');
  final _paidController = TextEditingController(text: '0');

  final List<DraftPurchaseLine> _lines = [];

  // -- Phone section ---------------------------------------------------------
  final _phoneSearchController = TextEditingController();
  final _phoneCostController = TextEditingController();
  final _imeiController = TextEditingController();
  Timer? _phoneSearchDebounce;
  List<Product> _phoneResults = [];
  bool _searchingPhones = false;
  Product? _phoneProduct;
  List<ProductVariant> _phoneVariants = [];
  ProductVariant? _phoneVariant;
  List<String> _imeiErrors = [];

  // -- Accessory section -----------------------------------------------------
  bool _accessoryFromCatalog = true;
  final _accSearchController = TextEditingController();
  final _accQtyController = TextEditingController(text: '1');
  final _accCostController = TextEditingController();
  Timer? _accSearchDebounce;
  List<CatalogItem> _catalogResults = [];
  List<Product> _accProductResults = [];
  bool _searchingAccessories = false;
  CatalogItem? _selectedCatalogItem;
  Product? _accProduct;
  List<ProductVariant> _accVariants = [];
  ProductVariant? _accVariant;

  String get _lang => ref.read(languageProvider);

  String _t(String key) => AppStrings.tr(key, language: _lang);

  @override
  void initState() {
    super.initState();
    if (widget.catalogRepository == null) _accessoryFromCatalog = false;
    _loadSuppliers();
  }

  @override
  void dispose() {
    _invoiceController.dispose();
    _discountController.dispose();
    _paidController.dispose();
    _phoneSearchController.dispose();
    _phoneCostController.dispose();
    _imeiController.dispose();
    _accSearchController.dispose();
    _accQtyController.dispose();
    _accCostController.dispose();
    _phoneSearchDebounce?.cancel();
    _accSearchDebounce?.cancel();
    super.dispose();
  }

  Future<void> _loadSuppliers() async {
    try {
      final suppliers = await loadSupplierSummaries(
        suppliers: ref.read(supplierRepositoryProvider),
      );
      if (!mounted) return;
      setState(() {
        _suppliers = suppliers;
        _loadingSuppliers = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _loadingSuppliers = false);
      showSnack(context, e.toString(), isError: true);
    }
  }

  String _userId() => ref.read(authStateProvider).user?.id ?? 'system';

  String? get _supplierName {
    for (final supplier in _suppliers) {
      if (supplier.id == _supplierId) return supplier.name;
    }
    return null;
  }

  int get _subtotal => _lines.fold<int>(0, (sum, line) => sum + line.total);

  int get _discount => int.tryParse(_discountController.text.trim()) ?? 0;

  int get _grandTotal => _subtotal - _discount;

  int get _paidNow => int.tryParse(_paidController.text.trim()) ?? 0;

  // -- Phone search ----------------------------------------------------------

  void _onPhoneSearchChanged(String value) {
    _phoneSearchDebounce?.cancel();
    _phoneSearchDebounce = Timer(
      const Duration(milliseconds: AppConstants.searchDebounceMs),
      () async {
        final query = value.trim();
        if (query.isEmpty) {
          setState(() => _phoneResults = []);
          return;
        }
        setState(() => _searchingPhones = true);
        try {
          final results = await widget.productRepository.listProducts(
            search: query,
            type: 'phone',
            limit: 20,
          );
          if (!mounted) return;
          setState(() {
            _phoneResults = results;
            _searchingPhones = false;
          });
        } catch (e) {
          if (!mounted) return;
          setState(() => _searchingPhones = false);
          showSnack(context, e.toString(), isError: true);
        }
      },
    );
  }

  Future<void> _selectPhoneProduct(Product product) async {
    setState(() {
      _phoneProduct = product;
      _phoneResults = [];
      _phoneSearchController.text = product.name;
      _phoneVariant = null;
      _phoneVariants = [];
    });
    try {
      final variants =
          await widget.productRepository.listVariants(product.id);
      if (!mounted) return;
      setState(() => _phoneVariants = variants);
    } catch (e) {
      if (!mounted) return;
      showSnack(context, e.toString(), isError: true);
    }
  }

  void _selectPhoneVariant(ProductVariant? variant) {
    setState(() {
      _phoneVariant = variant;
      if (variant != null && variant.purchasePrice > 0) {
        _phoneCostController.text = variant.purchasePrice.toString();
      }
    });
  }

  void _addImeis() {
    final cost = int.tryParse(_phoneCostController.text.trim()) ?? 0;
    if (_phoneProduct == null || _phoneVariant == null) {
      showSnack(context, _t('chooseVariantFirst'), isError: true);
      return;
    }
    if (cost <= 0) {
      showSnack(context, _t('enterCostFirst'), isError: true);
      return;
    }
    final existingImeis =
        _lines.map((line) => line.imei1).whereType<String>().toSet();
    final seenInPaste = <String>{};
    final errors = <String>[];
    var added = 0;
    final label =
        '${_phoneProduct!.name} · ${_phoneVariant!.name}';
    for (final raw in _imeiController.text.split('\n')) {
      final imei = raw.trim();
      if (imei.isEmpty) continue;
      if (!validateImei(imei)) {
        errors.add('$imei — ${_t('invalidImei')}');
        continue;
      }
      if (seenInPaste.contains(imei) || existingImeis.contains(imei)) {
        errors.add('$imei — ${_t('duplicateImei')}');
        continue;
      }
      seenInPaste.add(imei);
      _lines.add(DraftPurchaseLine(
        kind: DraftLineKind.phone,
        label: label,
        productId: _phoneProduct!.id,
        variantId: _phoneVariant!.id,
        imei1: imei,
        quantity: 1,
        unitCost: cost,
      ));
      added++;
    }
    setState(() {
      _imeiErrors = errors;
      if (added > 0) _imeiController.clear();
    });
    if (added > 0) {
      showSnack(context, '${_t('imeiCount')}: $added');
    }
  }

  // -- Accessory search ------------------------------------------------------

  void _onAccSearchChanged(String value) {
    _accSearchDebounce?.cancel();
    _accSearchDebounce = Timer(
      const Duration(milliseconds: AppConstants.searchDebounceMs),
      () async {
        final query = value.trim();
        if (query.isEmpty) {
          setState(() {
            _catalogResults = [];
            _accProductResults = [];
          });
          return;
        }
        setState(() => _searchingAccessories = true);
        try {
          if (_accessoryFromCatalog && widget.catalogRepository != null) {
            final results =
                await widget.catalogRepository!.search(query);
            if (!mounted) return;
            setState(() {
              _catalogResults = results.take(20).toList();
              _searchingAccessories = false;
            });
          } else {
            final results = await widget.productRepository.listProducts(
              search: query,
              type: 'accessory',
              limit: 20,
            );
            if (!mounted) return;
            setState(() {
              _accProductResults = results;
              _searchingAccessories = false;
            });
          }
        } catch (e) {
          if (!mounted) return;
          setState(() => _searchingAccessories = false);
          showSnack(context, e.toString(), isError: true);
        }
      },
    );
  }

  void _selectCatalogItem(CatalogItem item) {
    setState(() {
      _selectedCatalogItem = item;
      _catalogResults = [];
      _accSearchController.text = item.nameEn;
      _accCostController.text = item.purchasePriceEst.toString();
    });
  }

  Future<void> _selectAccProduct(Product product) async {
    setState(() {
      _accProduct = product;
      _accProductResults = [];
      _accSearchController.text = product.name;
      _accVariant = null;
      _accVariants = [];
    });
    try {
      final variants =
          await widget.productRepository.listVariants(product.id);
      if (!mounted) return;
      setState(() => _accVariants = variants);
    } catch (e) {
      if (!mounted) return;
      showSnack(context, e.toString(), isError: true);
    }
  }

  void _selectAccVariant(ProductVariant? variant) {
    setState(() {
      _accVariant = variant;
      if (variant != null && variant.purchasePrice > 0) {
        _accCostController.text = variant.purchasePrice.toString();
      }
    });
  }

  void _addAccessory() {
    final qty = int.tryParse(_accQtyController.text.trim()) ?? 0;
    final cost = int.tryParse(_accCostController.text.trim()) ?? 0;
    if (qty <= 0) {
      showSnack(context, _t('invalidAmount'), isError: true);
      return;
    }
    if (cost <= 0) {
      showSnack(context, _t('enterCostFirst'), isError: true);
      return;
    }
    if (_accessoryFromCatalog) {
      final item = _selectedCatalogItem;
      if (item == null) {
        showSnack(context, _t('chooseProductFirst'), isError: true);
        return;
      }
      setState(() {
        _lines.add(DraftPurchaseLine(
          kind: DraftLineKind.accessory,
          label: '${item.nameEn} (${item.sku})',
          catalogSku: item.sku,
          quantity: qty,
          unitCost: cost,
        ));
        _selectedCatalogItem = null;
        _accSearchController.clear();
        _accQtyController.text = '1';
      });
    } else {
      if (_accProduct == null || _accVariant == null) {
        showSnack(context, _t('chooseVariantFirst'), isError: true);
        return;
      }
      setState(() {
        _lines.add(DraftPurchaseLine(
          kind: DraftLineKind.accessory,
          label: '${_accProduct!.name} · ${_accVariant!.name}',
          productId: _accProduct!.id,
          variantId: _accVariant!.id,
          quantity: qty,
          unitCost: cost,
        ));
        _accProduct = null;
        _accVariant = null;
        _accSearchController.clear();
        _accQtyController.text = '1';
      });
    }
  }

  // -- Repeat last invoice ---------------------------------------------------

  Future<void> _repeatLastInvoice() async {
    if (_supplierId == null) {
      showSnack(context, _t('selectSupplier'), isError: true);
      return;
    }
    try {
      final previous = await widget.purchaseRepository.listPurchases(
        supplierId: _supplierId,
        limit: 1,
      );
      if (!mounted) return;
      if (previous.isEmpty) {
        showSnack(context, _t('noPreviousInvoice'));
        return;
      }
      final last = previous.first;
      var copied = 0;
      var skippedPhones = 0;
      for (final item in last.items) {
        if (item.imei1 != null && item.imei1!.isNotEmpty) {
          skippedPhones++;
          continue;
        }
        if (item.variantId == null) {
          continue;
        }
        final variant =
            await widget.productRepository.getVariant(item.variantId!);
        if (variant == null) {
          continue;
        }
        final product =
            await widget.productRepository.getProduct(variant.productId);
        setState(() {
          _lines.add(DraftPurchaseLine(
            kind: DraftLineKind.accessory,
            label: product == null
                ? variant.name
                : '${product.name} · ${variant.name}',
            productId: variant.productId,
            variantId: variant.id,
            quantity: item.quantity,
            unitCost: item.unitCost,
          ));
        });
        copied++;
      }
      if (!mounted) return;
      _discountController.text = last.discount.toString();
      setState(() {});
      showSnack(
        context,
        copied > 0
            ? _t('lastInvoiceLoaded')
            : _t('noPreviousInvoice'),
      );
      if (skippedPhones > 0) {
        showSnack(context, _t('imeisNeedReentry'));
      }
    } catch (e) {
      if (!mounted) return;
      showSnack(context, e.toString(), isError: true);
    }
  }

  // -- Save ------------------------------------------------------------------

  Future<void> _save() async {
    if (_supplierId == null) {
      showSnack(context, _t('selectSupplier'), isError: true);
      return;
    }
    if (_lines.isEmpty) {
      showSnack(context, _t('noLines'), isError: true);
      return;
    }
    if (_discount < 0 || _discount > _subtotal) {
      showSnack(context, _t('invalidAmount'), isError: true);
      return;
    }
    if (_paidNow < 0 || _paidNow > _grandTotal) {
      showSnack(context, _t('invalidAmount'), isError: true);
      return;
    }
    setState(() => _saving = true);
    try {
      final now = DateTime.now();
      final purchase = Purchase(
        id: '',
        supplierId: _supplierId!,
        userId: _userId(),
        supplierInvoiceNo: _invoiceController.text.trim().isEmpty
            ? null
            : _invoiceController.text.trim(),
        purchaseDate: _purchaseDate,
        subtotal: _subtotal,
        discount: _discount,
        grandTotal: _grandTotal,
        paidAmount: _paidNow,
        balanceDue: _grandTotal - _paidNow,
        status: 'received',
        items: _lines
            .map((line) => PurchaseItem(
                  id: '',
                  purchaseId: '',
                  productId: line.productId,
                  variantId: line.variantId,
                  imei1: line.imei1,
                  imei2: line.imei2,
                  catalogSku: line.catalogSku,
                  quantity: line.quantity,
                  unitCost: line.unitCost,
                  total: line.total,
                  createdAt: now,
                ))
            .toList(),
        createdAt: now,
        updatedAt: now,
      );
      await widget.purchaseRepository.createPurchase(
        purchase,
        userId: _userId(),
      );
      // Catalog accessories live in catalog.db, not the main DB: add
      // their stock now (the purchase above already recorded the cost
      // and the supplier payable).
      final catalogFailures = <String>[];
      if (widget.catalogRepository != null) {
        for (final line in _lines.where((l) => l.isCatalog)) {
          try {
            await widget.catalogRepository!.stockIn(
              line.catalogSku!,
              line.quantity,
              price: line.unitCost,
              supplier: _supplierName,
              date: _purchaseDate,
            );
          } catch (e) {
            catalogFailures.add(line.label);
          }
        }
      }
      if (!mounted) return;
      if (catalogFailures.isNotEmpty) {
        showSnack(
          context,
          '${_t('purchaseSaved')} (${_t('catalogStockNote')} — '
          '${catalogFailures.join(', ')})',
          isError: true,
        );
      } else {
        showSnack(context, _t('purchaseSaved'));
      }
      Navigator.of(context).pop(true);
    } catch (e) {
      if (!mounted) return;
      showSnack(context, e.toString(), isError: true);
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _purchaseDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) setState(() => _purchaseDate = picked);
  }

  @override
  Widget build(BuildContext context) {
    final c = ref.watch(themeNotifierProvider).colors;
    final isCashier =
        ref.watch(authStateProvider).user?.role == UserRoles.cashier;
    return Scaffold(
      appBar: CyberAppBar(title: _t('newPurchase')),
      body: isCashier
          ? Padding(
              padding: const EdgeInsets.all(AppConstants.paddingMedium),
              child: cyberRestricted(c, _t('purchasesRestricted')),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(AppConstants.paddingMedium),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _supplierCard(c),
                  const SizedBox(height: 12),
                  _phoneCard(c),
                  const SizedBox(height: 12),
                  _accessoryCard(c),
                  const SizedBox(height: 12),
                  _linesCard(c),
                  const SizedBox(height: 12),
                  _totalsCard(c),
                  const SizedBox(height: 16),
                  CyberButton(
                    label: _t('save'),
                    icon: Icons.save,
                    isLoading: _saving,
                    onPressed: _saving ? null : _save,
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
    );
  }

  Widget _supplierCard(CyberColors c) {
    return CyberCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (_loadingSuppliers)
            const LinearProgressIndicator()
          else
            DropdownButtonFormField<String>(
              initialValue: _supplierId,
              isExpanded: true,
              decoration: InputDecoration(labelText: _t('selectSupplier')),
              items: _suppliers.map((supplier) {
                return DropdownMenuItem<String>(
                  value: supplier.id,
                  child: Text(
                    '${supplier.name} · ${formatPkr(supplier.payable)} ${_t('payable')}',
                    style: CyberTextStyles.body(c, size: 14),
                    overflow: TextOverflow.ellipsis,
                  ),
                );
              }).toList(),
              onChanged: (value) => setState(() => _supplierId = value),
            ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: CyberTextField(
                  controller: _invoiceController,
                  label: _t('supplierInvoice'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(_t('purchaseDate'),
                      style: CyberTextStyles.body(c, size: 14)),
                  subtitle: Text(fmtDate(_purchaseDate),
                      style: CyberTextStyles.mono(c, size: 14)),
                  trailing:
                      Icon(Icons.calendar_today, color: c.primary),
                  onTap: _pickDate,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          CyberButton(
            label: _t('repeatLastInvoice'),
            variant: CyberButtonVariant.ghost,
            icon: Icons.replay,
            onPressed: _supplierId == null ? null : _repeatLastInvoice,
          ),
        ],
      ),
    );
  }

  Widget _phoneCard(CyberColors c) {
    return CyberCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(_t('addPhone'), style: CyberTextStyles.title(c, size: 17)),
          const SizedBox(height: 12),
          CyberSearchBar(
            hint: _t('search'),
            controller: _phoneSearchController,
            onChanged: _onPhoneSearchChanged,
          ),
          if (_searchingPhones)
            const Padding(
              padding: EdgeInsets.only(top: 8),
              child: LinearProgressIndicator(),
            ),
          ..._phoneResults.map((product) => ListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(product.name,
                    style: CyberTextStyles.body(c, size: 14)),
                subtitle: product.brandName == null
                    ? null
                    : Text(product.brandName!,
                        style: CyberTextStyles.bodySecondary(c, size: 13)),
                trailing: Icon(Icons.add, color: c.primary),
                onTap: () => _selectPhoneProduct(product),
              )),
          if (_phoneProduct != null) ...[
            const SizedBox(height: 8),
            Text(
              '${_t('chooseProduct')}: ${_phoneProduct!.name}',
              style: CyberTextStyles.bodySecondary(c),
            ),
            const SizedBox(height: 8),
            DropdownButtonFormField<ProductVariant>(
              initialValue: _phoneVariant,
              isExpanded: true,
              decoration: InputDecoration(labelText: _t('chooseVariant')),
              items: _phoneVariants.map((variant) {
                return DropdownMenuItem<ProductVariant>(
                  value: variant,
                  child: Text(variant.name,
                      style: CyberTextStyles.body(c, size: 14),
                      overflow: TextOverflow.ellipsis),
                );
              }).toList(),
              onChanged: _selectPhoneVariant,
            ),
            const SizedBox(height: 12),
            CyberTextField(
              controller: _phoneCostController,
              label: _t('unitCost'),
              hint: '0',
              monospace: true,
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _imeiController,
              minLines: 3,
              maxLines: 6,
              keyboardType: TextInputType.multiline,
              cursorColor: c.primary,
              style: CyberTextStyles.mono(c, size: 14),
              decoration: InputDecoration(
                labelText: _t('pasteImeis'),
                hintText: _t('imeiPasteHint'),
                alignLabelWithHint: true,
              ),
            ),
            const SizedBox(height: 8),
            CyberButton(
              label: _t('addPhone'),
              variant: CyberButtonVariant.ghost,
              icon: Icons.add,
              onPressed: _addImeis,
            ),
            if (_imeiErrors.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(_t('imeiIssues'),
                  style: CyberTextStyles.error(c, size: 13)),
              ..._imeiErrors.map((error) => Padding(
                    padding: const EdgeInsets.only(top: 2),
                    child: Text(error,
                        style: CyberTextStyles.mono(c, size: 12)
                            .copyWith(color: c.error)),
                  )),
            ],
          ],
        ],
      ),
    );
  }

  Widget _accessoryCard(CyberColors c) {
    return CyberCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(_t('addAccessory'),
              style: CyberTextStyles.title(c, size: 17)),
          const SizedBox(height: 12),
          if (widget.catalogRepository != null)
            Wrap(
              spacing: 8,
              children: [
                CyberChip(
                  label: _t('catalogItem'),
                  selected: _accessoryFromCatalog,
                  onSelected: (_) => setState(() {
                    _accessoryFromCatalog = true;
                    _accProduct = null;
                    _accVariant = null;
                    _accProductResults = [];
                  }),
                ),
                CyberChip(
                  label: _t('products'),
                  selected: !_accessoryFromCatalog,
                  onSelected: (_) => setState(() {
                    _accessoryFromCatalog = false;
                    _selectedCatalogItem = null;
                    _catalogResults = [];
                  }),
                ),
              ],
            ),
          const SizedBox(height: 12),
          CyberSearchBar(
            hint: _accessoryFromCatalog
                ? _t('catalogSearchHint')
                : _t('productSearchHint'),
            controller: _accSearchController,
            onChanged: _onAccSearchChanged,
          ),
          if (_searchingAccessories)
            const Padding(
              padding: EdgeInsets.only(top: 8),
              child: LinearProgressIndicator(),
            ),
          if (_accessoryFromCatalog)
            ..._catalogResults.map((item) => ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(item.nameEn,
                      style: CyberTextStyles.body(c, size: 14)),
                  subtitle: Text(
                    '${item.sku} · ${formatPkr(item.purchasePriceEst)}',
                    style: CyberTextStyles.mono(c, size: 12)
                        .copyWith(color: c.textSecondary),
                  ),
                  trailing: Icon(Icons.add, color: c.primary),
                  onTap: () => _selectCatalogItem(item),
                ))
          else
            ..._accProductResults.map((product) => ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(product.name,
                      style: CyberTextStyles.body(c, size: 14)),
                  trailing: Icon(Icons.add, color: c.primary),
                  onTap: () => _selectAccProduct(product),
                )),
          if (_selectedCatalogItem != null ||
              _accProduct != null) ...[
            const SizedBox(height: 8),
            if (!_accessoryFromCatalog && _accProduct != null)
              DropdownButtonFormField<ProductVariant>(
                initialValue: _accVariant,
                isExpanded: true,
                decoration:
                    InputDecoration(labelText: _t('chooseVariant')),
                items: _accVariants.map((variant) {
                  return DropdownMenuItem<ProductVariant>(
                    value: variant,
                    child: Text(variant.name,
                        style: CyberTextStyles.body(c, size: 14),
                        overflow: TextOverflow.ellipsis),
                  );
                }).toList(),
                onChanged: _selectAccVariant,
              ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: CyberTextField(
                    controller: _accQtyController,
                    label: _t('quantity'),
                    monospace: true,
                    keyboardType: TextInputType.number,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: CyberTextField(
                    controller: _accCostController,
                    label: _t('unitCost'),
                    hint: '0',
                    monospace: true,
                    keyboardType: TextInputType.number,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            if (_accessoryFromCatalog)
              Text(_t('catalogStockNote'),
                  style: CyberTextStyles.caption(c)),
            const SizedBox(height: 8),
            CyberButton(
              label: _t('addLine'),
              variant: CyberButtonVariant.ghost,
              icon: Icons.add,
              onPressed: _addAccessory,
            ),
          ],
        ],
      ),
    );
  }

  Widget _linesCard(CyberColors c) {
    return CyberCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text('${_t('items')} (${_lines.length})',
              style: CyberTextStyles.title(c, size: 17)),
          const SizedBox(height: 8),
          if (_lines.isEmpty)
            Text(_t('noLines'), style: CyberTextStyles.bodySecondary(c))
          else
            ..._lines.asMap().entries.map((entry) {
              final index = entry.key;
              final line = entry.value;
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 6),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(line.label,
                              style: CyberTextStyles.body(c, size: 14),
                              overflow: TextOverflow.ellipsis),
                          Text(
                            line.imei1 ??
                                '${line.kind == DraftLineKind.phone ? _t('phoneItem') : _t('accessoryItem')}'
                                    ' × ${line.quantity}',
                            style: CyberTextStyles.mono(c, size: 12)
                                .copyWith(color: c.textSecondary),
                          ),
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        moneyText(c, line.total, size: 14),
                        Text(
                          '${formatPkr(line.unitCost)} × ${line.quantity}',
                          style: CyberTextStyles.mono(c, size: 12)
                              .copyWith(color: c.textSecondary),
                        ),
                      ],
                    ),
                    IconButton(
                      icon: Icon(Icons.delete_outline, color: c.error),
                      tooltip: _t('remove'),
                      onPressed: () =>
                          setState(() => _lines.removeAt(index)),
                    ),
                  ],
                ),
              );
            }),
        ],
      ),
    );
  }

  Widget _totalsCard(CyberColors c) {
    return CyberCard(
      child: Column(
        children: [
          _totalRow(c, _t('subtotal'), _subtotal),
          _totalRow(c, _t('discount'), _discount),
          _totalRow(c, _t('grandTotal'), _grandTotal, bold: true),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: CyberTextField(
                  controller: _discountController,
                  label: _t('purchaseDiscount'),
                  hint: '0',
                  monospace: true,
                  keyboardType: TextInputType.number,
                  onChanged: (_) => setState(() {}),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: CyberTextField(
                  controller: _paidController,
                  label: _t('paidNow'),
                  hint: '0',
                  monospace: true,
                  keyboardType: TextInputType.number,
                  onChanged: (_) => setState(() {}),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          _totalRow(c, _t('balanceDue'), _grandTotal - _paidNow),
        ],
      ),
    );
  }

  Widget _totalRow(CyberColors c, String label, int amount,
      {bool bold = false}) {
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
          moneyText(c, amount, size: bold ? 18 : 15),
        ],
      ),
    );
  }
}
