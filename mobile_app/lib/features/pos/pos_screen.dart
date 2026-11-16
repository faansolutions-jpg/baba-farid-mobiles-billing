library;

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/config/constants.dart';
import '../../core/l10n/app_strings.dart';
import '../../core/theme/app_theme.dart';
import '../../core/theme/cyber_colors.dart';
import '../../core/theme/cyber_text_styles.dart';
import '../../core/theme/cyber_widgets.dart';
import '../../domain/models/customer.dart';
import '../../domain/models/held_bill.dart';
import '../../domain/models/imei_item.dart';
import '../../domain/models/product.dart';
import '../../domain/models/product_variant.dart';
import '../../domain/models/sale.dart';
import '../../domain/money.dart';
import '../../domain/rules.dart';
import '../auth/auth_state.dart';
import 'admin_approval_dialog.dart';
import 'cart_line_tile.dart';
import 'customer_picker_sheet.dart';
import 'held_bills_sheet.dart';
import 'payment_sheet.dart';
import 'pos_models.dart';
import '../../core/providers/app_providers.dart';

/// POS billing screen (route `/pos`).
///
/// Search / scan by name, barcode or IMEI, tap to add to the cart,
/// edit quantity / price / per-line discount, pick or create a customer,
/// choose a payment method, hold/resume bills, and pay. On pay the
/// bill is saved with [SaleRepository.createSale] (whole PKR ints);
/// `createSale` already records the payment row for the amount paid
/// now, so no separate `recordPayment` call is needed for a new bill.
/// On success the app goes to `/invoice/<saleId>`.
///
/// Rules enforced here (the repository enforces them again in its
/// transaction): a sold IMEI can never be re-sold; a line below the
/// variant minimum price needs owner/manager approval; cashiers never
/// see cost price or profit.
class PosScreen extends ConsumerStatefulWidget {
  const PosScreen({super.key});

  @override
  ConsumerState<PosScreen> createState() => _PosScreenState();
}

class _PosScreenState extends ConsumerState<PosScreen> {
  final TextEditingController _searchController = TextEditingController();
  Timer? _searchDebounce;

  List<CartLine> _cart = <CartLine>[];
  Customer? _customer;
  int _billDiscount = 0;
  bool _billDiscountIsPercent = false;

  List<Product> _results = <Product>[];
  bool _searching = false;
  String? _searchError;
  bool _hasSearched = false;

  bool _taxEnabled = false;
  double _taxRate = 0;
  bool _paying = false;
  String? _payError;

  @override
  void initState() {
    super.initState();
    _loadTaxSettings();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchDebounce?.cancel();
    super.dispose();
  }

  Future<void> _loadTaxSettings() async {
    try {
      final settings =
          await ref.read(settingsRepositoryProvider).getSettings();
      if (!mounted) return;
      setState(() {
        _taxEnabled = settings.taxEnabled;
        _taxRate = settings.taxRate;
      });
    } catch (_) {
      // Tax stays off when settings cannot be read; the bill still works.
    }
  }

  bool get _canSeeCosts {
    final role = ref.watch(authStateProvider).user?.role;
    return UserRoles.canSeeCosts.contains(role);
  }

  String get _userId => ref.read(authStateProvider).user?.id ?? '';

  // -- Totals ---------------------------------------------------------------

  int get _subtotal =>
      _cart.fold<int>(0, (sum, line) => sum + line.total);

  int get _billDiscountAmount =>
      applyDiscount(_subtotal, _billDiscount, _billDiscountIsPercent);

  int get _taxAmount =>
      _taxEnabled ? applyTax(_subtotal - _billDiscountAmount, _taxRate) : 0;

  int get _grandTotal => _subtotal - _billDiscountAmount + _taxAmount;

  // -- Search ---------------------------------------------------------------

  void _onSearchChanged(String value) {
    _searchDebounce?.cancel();
    _searchDebounce = Timer(
      const Duration(milliseconds: AppConstants.searchDebounceMs),
      () => _runSearch(value),
    );
  }

  Future<void> _runSearch(String query) async {
    final q = query.trim();
    if (q.isEmpty) {
      setState(() {
        _results = <Product>[];
        _hasSearched = false;
        _searchError = null;
      });
      return;
    }
    setState(() {
      _searching = true;
      _searchError = null;
      _hasSearched = true;
    });
    try {
      final repo = ref.read(productRepositoryProvider);
      // A 15-digit entry is an IMEI first: it resolves to exactly one
      // phone (or a clear SOLD / not-found message).
      if (RegExp(r'^\d{15}$').hasMatch(q)) {
        final imei = await repo.getImeiByNumber(q);
        if (imei != null) {
          if (!canSellImei(imei)) {
            throw Exception(AppStrings.tr(
              'imeiSoldCannotSell',
              language: ref.read(languageProvider),
            ));
          }
          final product = await repo.getProduct(imei.productId);
          if (product == null) throw Exception('Product not found');
          await _addImeiLine(product, imei);
          if (!mounted) return;
          setState(() {
            _searching = false;
            _results = <Product>[];
            _searchController.clear();
          });
          return;
        }
        // Not an IMEI in stock: fall through to a normal text search.
      }
      final byBarcode = await repo.getProductByBarcode(q);
      final found = await repo.searchProducts(q, limit: 20);
      if (!mounted) return;
      final merged = <Product>[];
      if (byBarcode != null) merged.add(byBarcode);
      for (final p in found) {
        if (!merged.any((m) => m.id == p.id)) merged.add(p);
      }
      setState(() {
        _results = merged;
        _searching = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _searchError = e.toString();
        _searching = false;
      });
    }
  }

  // -- Adding to the cart ---------------------------------------------------

  Future<void> _pickVariantAndAdd(Product product) async {
    final lang = ref.read(languageProvider);
    String tr(String key) => AppStrings.tr(key, language: lang);
    try {
      final repo = ref.read(productRepositoryProvider);
      final variants = await repo.listVariants(product.id);
      if (variants.isEmpty) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(tr('noVariants'))),
        );
        return;
      }
      final variant = variants.length == 1
          ? variants.first
          : await _showVariantPicker(product, variants);
      if (variant == null) return;
      if (product.type == 'phone') {
        final imeis = await repo.listImeiItems(
          variantId: variant.id,
          status: ImeiStatus.available,
        );
        if (imeis.isEmpty) {
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(tr('noAvailableImei'))),
          );
          return;
        }
        final imei = imeis.length == 1
            ? imeis.first
            : await _showImeiPicker(variant, imeis);
        if (imei == null) return;
        await _addImeiLine(product, imei, variant: variant);
      } else {
        _addAccessoryLine(product, variant);
      }
      setState(() {
        _results = <Product>[];
        _searchController.clear();
        _hasSearched = false;
      });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    }
  }

  Future<ProductVariant?> _showVariantPicker(
    Product product,
    List<ProductVariant> variants,
  ) async {
    final lang = ref.read(languageProvider);
    String tr(String key) => AppStrings.tr(key, language: lang);
    return showModalBottomSheet<ProductVariant>(
      context: context,
      isScrollControlled: true,
      builder: (context) => Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(product.name, style: CyberTextStyles.title(
              ref.read(themeNotifierProvider).colors,
              size: 18,
            )),
            const SizedBox(height: 4),
            Text(tr('selectVariant')),
            const SizedBox(height: 12),
            Flexible(
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: variants.length,
                itemBuilder: (context, index) {
                  final v = variants[index];
                  return ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(v.name),
                    subtitle: Text(
                      '${v.condition} · ${v.ptaStatus} · ${tr('stock')}: ${v.quantity}',
                    ),
                    trailing: Text(
                      formatPkr(v.salePrice),
                      style: CyberTextStyles.mono(
                        ref.read(themeNotifierProvider).colors,
                        size: 15,
                      ),
                    ),
                    onTap: () => Navigator.of(context).pop(v),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<ImeiItem?> _showImeiPicker(
    ProductVariant variant,
    List<ImeiItem> imeis,
  ) async {
    final lang = ref.read(languageProvider);
    String tr(String key) => AppStrings.tr(key, language: lang);
    return showModalBottomSheet<ImeiItem>(
      context: context,
      isScrollControlled: true,
      builder: (context) => Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(variant.name, style: CyberTextStyles.title(
              ref.read(themeNotifierProvider).colors,
              size: 18,
            )),
            const SizedBox(height: 4),
            Text(tr('selectImei')),
            const SizedBox(height: 12),
            Flexible(
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: imeis.length,
                itemBuilder: (context, index) {
                  final item = imeis[index];
                  return ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(
                      item.imei1,
                      style: CyberTextStyles.imei(
                        ref.read(themeNotifierProvider).colors,
                      ),
                    ),
                    subtitle: item.imei2 == null
                        ? null
                        : Text(item.imei2!),
                    trailing: Text(
                      formatPkr(item.salePrice > 0
                          ? item.salePrice
                          : variant.salePrice),
                      style: CyberTextStyles.mono(
                        ref.read(themeNotifierProvider).colors,
                        size: 15,
                      ),
                    ),
                    onTap: () => Navigator.of(context).pop(item),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _addImeiLine(
    Product product,
    ImeiItem imei, {
    ProductVariant? variant,
  }) async {
    final v = variant ??
        await ref.read(productRepositoryProvider).getVariant(
              imei.variantId ?? '',
            );
    if (_cart.any((line) => line.imeiItemId == imei.id)) {
      return; // Same IMEI already in this cart.
    }
    final price = imei.salePrice > 0
        ? imei.salePrice
        : (v?.salePrice ?? 0);
    setState(() {
      _cart.add(
        CartLine(
          productId: product.id,
          variantId: imei.variantId,
          imeiItemId: imei.id,
          name: '${product.name} — ${v?.name ?? ''}'.trim(),
          imei1: imei.imei1,
          unitPrice: price,
          costPrice: imei.purchasePrice,
          minPrice: v?.minPrice ?? 0,
          quantity: 1,
        ),
      );
    });
  }

  void _addAccessoryLine(Product product, ProductVariant variant) {
    final existingIndex = _cart.indexWhere(
      (line) => line.variantId == variant.id && line.imeiItemId == null,
    );
    setState(() {
      if (existingIndex >= 0) {
        final line = _cart[existingIndex];
        if (line.quantity < variant.quantity) {
          _cart[existingIndex] =
              line.copyWith(quantity: line.quantity + 1);
        }
      } else {
        _cart.add(
          CartLine(
            productId: product.id,
            variantId: variant.id,
            name: '${product.name} — ${variant.name}'.trim(),
            unitPrice: variant.salePrice,
            costPrice: variant.purchasePrice,
            minPrice: variant.minPrice,
            quantity: 1,
          ),
        );
      }
    });
  }

  // -- Cart edits -----------------------------------------------------------

  void _updateLine(int index, CartLine updated) {
    setState(() => _cart[index] = updated);
  }

  Future<void> _editLinePrice(int index) async {
    final lang = ref.read(languageProvider);
    String tr(String key) => AppStrings.tr(key, language: lang);
    final line = _cart[index];
    final value = await showAmountDialog(
      context,
      title: tr('salePrice'),
      initialValue: line.unitPrice,
    );
    if (value != null) _updateLine(index, line.copyWith(unitPrice: value));
  }

  Future<void> _editLineDiscount(int index) async {
    final line = _cart[index];
    final result = await showLineDiscountDialog(context, line: line);
    if (result != null) {
      _updateLine(
        index,
        line.copyWith(
          discountValue: result.value,
          discountIsPercent: result.isPercent,
        ),
      );
    }
  }

  Future<void> _editBillDiscount() async {
    final lang = ref.read(languageProvider);
    String tr(String key) => AppStrings.tr(key, language: lang);
    final result = await showDialog<({int value, bool isPercent})>(
      context: context,
      builder: (context) => Consumer(
        builder: (context, ref, _) {
          var isPercent = _billDiscountIsPercent;
          final controller = TextEditingController(
            text: _billDiscount > 0 ? '$_billDiscount' : '',
          );
          return StatefulBuilder(
            builder: (context, setDialogState) => CyberDialog(
              title: tr('billDiscount'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text(tr('cancel')),
                ),
                CyberButton(
                  label: tr('save'),
                  fullWidth: false,
                  onPressed: () {
                    final value =
                        int.tryParse(controller.text.trim()) ?? 0;
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
    if (result != null) {
      setState(() {
        _billDiscount = result.value;
        _billDiscountIsPercent = result.isPercent;
      });
    }
  }

  // -- Hold / resume ----------------------------------------------------------

  Future<void> _holdBill() async {
    if (_cart.isEmpty) return;
    final lang = ref.read(languageProvider);
    String tr(String key) => AppStrings.tr(key, language: lang);
    try {
      final cartJson =
          _cart.map((line) => line.toJson()).toList();
      cartJson.add({
        '_meta': true,
        'customerId': _customer?.id,
        'customerName': _customer?.name,
        'customerPhone': _customer?.phone,
      });
      final now = DateTime.now();
      await ref.read(saleRepositoryProvider).holdBill(
            HeldBill(
              id: '',
              userId: _userId,
              customerName: _customer?.name,
              cart: cartJson,
              createdAt: now,
            ),
            userId: _userId,
          );
      setState(() {
        _cart = <CartLine>[];
        _customer = null;
        _billDiscount = 0;
      });
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(tr('billHeld'))),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    }
  }

  Future<void> _openHeldBills() async {
    final lang = ref.read(languageProvider);
    String tr(String key) => AppStrings.tr(key, language: lang);
    final resumed = await showHeldBillsSheet(context);
    if (resumed == null) return;
    final lines = <CartLine>[];
    Customer? customer;
    for (final entry in resumed.cart) {
      if (entry['_meta'] == true) {
        final customerId = entry['customerId'] as String?;
        if (customerId != null) {
          customer = await ref
              .read(customerRepositoryProvider)
              .getCustomer(customerId);
        }
        continue;
      }
      lines.add(CartLine.fromJson(entry));
    }
    setState(() {
      _cart = lines;
      _customer = customer;
    });
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(tr('billResumed'))),
    );
  }

  // -- Pay --------------------------------------------------------------------

  Future<void> _pay() async {
    final lang = ref.read(languageProvider);
    String tr(String key) => AppStrings.tr(key, language: lang);
    if (_cart.isEmpty || _paying) return;
    final choice = await showPaymentSheet(
      context,
      grandTotal: _grandTotal,
    );
    if (choice == null || !mounted) return;

    // Below-minimum-price lines need owner/manager approval first.
    String? adminApprovedBy;
    final belowMin = _cart.where((line) => line.isBelowMinPrice).toList();
    if (belowMin.isNotEmpty) {
      final reason = belowMin
          .map((line) =>
              '${line.name}: ${formatPkr(line.unitPrice)} < ${formatPkr(line.minPrice)}')
          .join('\n');
      adminApprovedBy = await showAdminApprovalDialog(
        context,
        reason: reason,
      );
      if (adminApprovedBy == null) return; // Not approved: stop.
    }

    setState(() {
      _paying = true;
      _payError = null;
    });
    try {
      final now = DateTime.now();
      final sale = Sale(
        id: '',
        invoiceNo: '',
        customerId: _customer?.id,
        customerName: _customer?.name,
        customerPhone: _customer?.phone,
        userId: _userId,
        saleDate: now,
        subtotal: _subtotal,
        discountAmount: _billDiscountAmount,
        taxAmount: _taxAmount,
        grandTotal: _grandTotal,
        paidAmount: choice.paidAmount,
        balanceDue: _grandTotal - choice.paidAmount,
        paymentMethod: choice.method,
        notes: choice.reference == null
            ? null
            : 'Ref: ${choice.reference}',
        items: _cart
            .map(
              (line) => SaleItem(
                id: '',
                saleId: '',
                productId: line.productId,
                variantId: line.variantId,
                imeiItemId: line.imeiItemId,
                nameSnapshot: line.imei1 == null
                    ? line.name
                    : '${line.name} [${line.imei1}]',
                quantity: line.quantity,
                unitPrice: line.unitPrice,
                purchaseCost: line.costPrice,
                discount: line.discountAmount,
                total: line.total,
                profit: line.profit,
                createdAt: now,
              ),
            )
            .toList(),
        createdAt: now,
        updatedAt: now,
        adminApprovedBy: adminApprovedBy,
      );
      final saved = await ref.read(saleRepositoryProvider).createSale(
            sale: sale,
            adminApprovedBy: adminApprovedBy,
            userId: _userId,
          );
      // createSale already wrote the payment row for the amount paid
      // now, so recordPayment is NOT called again (it would double
      // the payment). It is only for later payments on an existing
      // bill (udhaar recovery).
      setState(() {
        _cart = <CartLine>[];
        _customer = null;
        _billDiscount = 0;
        _paying = false;
      });
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(tr('saleCompleted'))),
      );
      try {
        context.go('/invoice/${saved.id}');
      } catch (_) {
        // Router not wired yet (Round 2H): the bill is saved, the
        // invoice screen just cannot open until the router exists.
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _payError = e.toString();
        _paying = false;
      });
    }
  }

  // -- Build ------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    final c = ref.watch(themeNotifierProvider).colors;
    final lang = ref.watch(languageProvider);
    String tr(String key) => AppStrings.tr(key, language: lang);
    final canSeeCosts = _canSeeCosts;

    return Scaffold(
      appBar: CyberAppBar(
        title: tr('newBill'),
        actions: [
          IconButton(
            icon: const Icon(Icons.pause_circle_outline),
            tooltip: tr('holdBill'),
            onPressed: _cart.isEmpty ? null : _holdBill,
          ),
          IconButton(
            icon: const Icon(Icons.play_circle_outline),
            tooltip: tr('resumeBill'),
            onPressed: _openHeldBills,
          ),
          IconButton(
            icon: const Icon(Icons.assignment_return_outlined),
            tooltip: tr('returnItem'),
            onPressed: () => context.go('/pos/returns'),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: CyberSearchBar(
              hint: tr('scanOrSearch'),
              controller: _searchController,
              onChanged: _onSearchChanged,
              onSubmitted: _runSearch,
              onScanPressed: () => _runSearch(_searchController.text),
            ),
          ),
          if (_searching)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 8),
              child: CircularProgressIndicator(),
            )
          else if (_searchError != null)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: CyberCard(
                child: Row(
                  children: [
                    Icon(Icons.error_outline, color: c.error),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _searchError!,
                        style: CyberTextStyles.error(c, size: 13),
                      ),
                    ),
                  ],
                ),
              ),
            )
          else if (_hasSearched && _results.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Text(
                tr('noProductsFound'),
                style: CyberTextStyles.bodySecondary(c),
              ),
            )
          else if (_results.isNotEmpty)
            ConstrainedBox(
              constraints: const BoxConstraints(maxHeight: 240),
              child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: _results.length,
                  itemBuilder: (context, index) {
                    final product = _results[index];
                    return ListTile(
                      title: Text(product.name),
                      subtitle: Text(
                        [
                          if (product.brandName != null) product.brandName!,
                          product.type,
                          if (product.barcode != null) product.barcode!,
                        ].join(' · '),
                      ),
                      trailing: Text(
                        tr('tapToAdd'),
                        style: CyberTextStyles.caption(c),
                      ),
                      onTap: () => _pickVariantAndAdd(product),
                    );
                  },
                ),
              ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Row(
              children: [
                Expanded(
                  child: CyberCard(
                    onTap: () async {
                      final picked =
                          await showCustomerPickerSheet(context);
                      if (picked != null) {
                        setState(() => _customer = picked);
                      }
                    },
                    child: Row(
                      children: [
                        Icon(Icons.person_outline, color: c.primary),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            _customer == null
                                ? tr('walkIn')
                                : '${_customer!.name} · ${_customer!.phone}',
                            style: _customer == null
                                ? CyberTextStyles.bodySecondary(c)
                                : CyberTextStyles.body(c),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Text(
                          tr('addCustomer'),
                          style: CyberTextStyles.caption(c),
                        ),
                      ],
                    ),
                  ),
                ),
                if (_customer != null)
                  IconButton(
                    icon: const Icon(Icons.clear),
                    tooltip: tr('cancel'),
                    constraints:
                        const BoxConstraints(minWidth: 48, minHeight: 48),
                    onPressed: () => setState(() => _customer = null),
                  ),
              ],
            ),
          ),
          Expanded(
            child: _cart.isEmpty
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Text(
                        tr('emptyCart'),
                        textAlign: TextAlign.center,
                        style: CyberTextStyles.bodySecondary(c),
                      ),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    itemCount: _cart.length,
                    itemBuilder: (context, index) {
                      final line = _cart[index];
                      return CartLineTile(
                        line: line,
                        canSeeCosts: canSeeCosts,
                        onQuantityChanged: (qty) =>
                            _updateLine(index, line.copyWith(quantity: qty)),
                        onEditPrice: () => _editLinePrice(index),
                        onEditDiscount: () => _editLineDiscount(index),
                        onRemove: () {
                          setState(() => _cart.removeAt(index));
                        },
                      );
                    },
                  ),
          ),
          if (_cart.isNotEmpty) ...[
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: CyberCard(
                child: Column(
                  children: [
                    _totalRow(tr('subtotal'), _subtotal, c),
                    InkWell(
                      onTap: _editBillDiscount,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: _totalRow(
                          tr('discount'),
                          -_billDiscountAmount,
                          c,
                          valueColor: c.secondary,
                        ),
                      ),
                    ),
                    if (_taxEnabled)
                      _totalRow(
                        '${tr('tax')} (${_taxRate.toStringAsFixed(1)}%)',
                        _taxAmount,
                        c,
                      ),
                    const Divider(),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          tr('grandTotal'),
                          style: CyberTextStyles.title(c, size: 17),
                        ),
                        Text(
                          formatPkr(_grandTotal),
                          style: CyberTextStyles.amount(c, size: 26),
                        ),
                      ],
                    ),
                    if (_payError != null) ...[
                      const SizedBox(height: 8),
                      Text(_payError!, style: CyberTextStyles.error(c)),
                    ],
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 4, 12, 16),
              child: Row(
                children: [
                  Expanded(
                    child: CyberButton(
                      label: tr('clearCart'),
                      variant: CyberButtonVariant.ghost,
                      onPressed: () => setState(() {
                        _cart = <CartLine>[];
                        _billDiscount = 0;
                      }),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 2,
                    child: CyberButton(
                      label:
                          '${tr('completeSale')} · ${formatPkr(_grandTotal)}',
                      icon: Icons.payments_outlined,
                      isLoading: _paying,
                      onPressed: _pay,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _totalRow(
    String label,
    int value,
    CyberColors colors, {
    Color? valueColor,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: CyberTextStyles.body(colors)),
        Text(
          formatPkr(value),
          style: CyberTextStyles.mono(colors, size: 15).copyWith(
            color: valueColor ?? colors.textPrimary,
          ),
        ),
      ],
    );
  }
}
