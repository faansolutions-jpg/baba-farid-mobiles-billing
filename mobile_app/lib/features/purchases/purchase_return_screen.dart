/// Purchase return — route `/purchases/:id/return`.
///
/// Select items / IMEIs to send back to the supplier, enter a reason,
/// and submit. Phones return by IMEI (resolved to the IMEI-item id via
/// [ProductRepository.getImeiByNumber]); accessories return by purchase
/// item with a quantity stepper. Each return calls
/// [PurchaseRepository.returnPurchase], which removes the IMEI row (or
/// reduces accessory stock) and reduces the supplier payable.
/// Owner / Manager only (refund amounts are cost prices).
///
/// Catalog accessories are identified by [PurchaseItem.catalogSku]
/// (main-DB accessories always carry a `variantId`; catalog lines
/// carry a SKU and no variant). After a catalog return succeeds, this
/// screen calls [CatalogRepository.stockOut] for that SKU — the
/// catalog lives in a separate database, so the decrement happens
/// here, like the matching `stockIn` call in the purchase entry
/// screen. A stockOut failure is reported but does not undo the
/// recorded return / payable reduction.
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
import '../../domain/models/purchase.dart';
import '../../domain/money.dart';
import '../auth/auth_state.dart';
import '../catalog/catalog_repository.dart';
import '../customers/customer_helpers.dart';

class PurchaseReturnScreen extends ConsumerStatefulWidget {
  const PurchaseReturnScreen({
    super.key,
    required this.purchaseRepository,
    required this.productRepository,
    required this.purchaseId,
    this.catalogRepository,
  });

  static const String routeName = '/purchases/:id/return';

  final PurchaseRepository purchaseRepository;
  final ProductRepository productRepository;
  final String purchaseId;

  /// When null, the shared [catalogRepositoryProvider] is used.
  final CatalogRepository? catalogRepository;

  @override
  ConsumerState<PurchaseReturnScreen> createState() =>
      _PurchaseReturnScreenState();
}

class _PurchaseReturnScreenState extends ConsumerState<PurchaseReturnScreen> {
  Purchase? _purchase;

  /// IMEI-item id per purchase-item id, for phone lines. Null means the
  /// IMEI row is gone (already returned) or sold — not returnable.
  final Map<String, String?> _imeiItemIdByItem = {};

  /// Already-returned accessory quantity per variant id.
  Map<String, int> _returnedQtyByVariant = {};

  /// Already-returned accessory quantity per catalog SKU.
  Map<String, int> _returnedQtyByCatalogSku = {};

  /// Selected phone purchase-item ids.
  final Set<String> _selectedPhones = {};

  /// Accessory quantity to return, per purchase-item id.
  final Map<String, int> _returnQty = {};

  final _reasonController = TextEditingController();
  bool _loading = true;
  bool _submitting = false;
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
    _reasonController.dispose();
    super.dispose();
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
      final returnedByVariant = <String, int>{};
      final returnedByCatalogSku = <String, int>{};
      for (final ret in returns) {
        if (ret.imeiItemId == null && ret.variantId != null) {
          returnedByVariant[ret.variantId!] =
              (returnedByVariant[ret.variantId!] ?? 0) + ret.quantity;
        } else if (ret.imeiItemId == null && ret.catalogSku != null) {
          returnedByCatalogSku[ret.catalogSku!] =
              (returnedByCatalogSku[ret.catalogSku!] ?? 0) + ret.quantity;
        }
      }
      final imeiIds = <String, String?>{};
      for (final item in purchase.items) {
        if (item.imei1 != null && item.imei1!.isNotEmpty) {
          final imeiItem = await widget.productRepository
              .getImeiByNumber(item.imei1!);
          imeiIds[item.id] = imeiItem?.id;
        }
      }
      if (!mounted) return;
      setState(() {
        _purchase = purchase;
        _returnedQtyByVariant = returnedByVariant;
        _returnedQtyByCatalogSku = returnedByCatalogSku;
        _imeiItemIdByItem.clear();
        _imeiItemIdByItem.addAll(imeiIds);
        _selectedPhones.clear();
        _returnQty.clear();
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

  int _remainingQty(PurchaseItem item) {
    if (item.variantId != null) {
      final returned = _returnedQtyByVariant[item.variantId!] ?? 0;
      final remaining = item.quantity - returned;
      return remaining < 0 ? 0 : remaining;
    }
    if (item.catalogSku != null) {
      final returned = _returnedQtyByCatalogSku[item.catalogSku!] ?? 0;
      final remaining = item.quantity - returned;
      return remaining < 0 ? 0 : remaining;
    }
    return item.quantity;
  }

  int get _totalRefund {
    var total = 0;
    final purchase = _purchase;
    if (purchase == null) return total;
    for (final item in purchase.items) {
      if (item.imei1 != null && _selectedPhones.contains(item.id)) {
        total += item.total;
      } else {
        final qty = _returnQty[item.id] ?? 0;
        total += item.unitCost * qty;
      }
    }
    return total;
  }

  bool get _hasSelection =>
      _selectedPhones.isNotEmpty ||
      _returnQty.values.any((qty) => qty > 0);

  Future<void> _submit() async {
    final purchase = _purchase;
    if (purchase == null || !_hasSelection) return;
    final reason = _reasonController.text.trim().isEmpty
        ? null
        : _reasonController.text.trim();
    setState(() => _submitting = true);
    final failures = <String>[];
    var done = 0;
    try {
      for (final item in purchase.items) {
        if (item.imei1 != null && _selectedPhones.contains(item.id)) {
          final imeiItemId = _imeiItemIdByItem[item.id];
          if (imeiItemId == null) continue;
          try {
            await widget.purchaseRepository.returnPurchase(
              purchaseId: purchase.id,
              imeiItemId: imeiItemId,
              reason: reason,
              userId: _userId(),
            );
            done++;
          } catch (e) {
            failures.add('${item.imei1}: $e');
          }
        } else {
          final qty = _returnQty[item.id] ?? 0;
          if (qty <= 0) continue;
          try {
            await widget.purchaseRepository.returnPurchase(
              purchaseId: purchase.id,
              purchaseItemId: item.id,
              quantity: qty,
              reason: reason,
              userId: _userId(),
            );
            done++;
            // Catalog accessory: decrement catalog stock for the
            // returned SKU (main-DB accessories were already reduced
            // by returnPurchase via their variant).
            if (item.catalogSku != null) {
              final CatalogRepository catalog = widget.catalogRepository ??
                  ref.read(catalogRepositoryProvider);
              try {
                await catalog.stockOut(item.catalogSku!, qty);
              } catch (e) {
                failures.add(
                    '${item.catalogSku}: catalog stock not updated: $e');
              }
            }
          } catch (e) {
            failures.add('${item.imei1 ?? _t('accessoryItem')}: $e');
          }
        }
      }
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
    if (!mounted) return;
    if (failures.isNotEmpty) {
      showSnack(
        context,
        failures.join('\n'),
        isError: true,
      );
    } else if (done > 0) {
      showSnack(context, _t('returnRecorded'));
    }
    if (done > 0) _load();
  }

  @override
  Widget build(BuildContext context) {
    final c = ref.watch(themeNotifierProvider).colors;
    final isCashier =
        ref.watch(authStateProvider).user?.role == UserRoles.cashier;
    return Scaffold(
      appBar: CyberAppBar(title: _t('returnItems')),
      body: isCashier
          ? Padding(
              padding: const EdgeInsets.all(AppConstants.paddingMedium),
              child: cyberRestricted(c, _t('purchasesRestricted')),
            )
          : _loading
              ? cyberLoading(c, _t('splashLoading'))
              : _error != null
                  ? cyberError(c, _error!, _load, _t('tryAgain'))
                  : _buildBody(c),
    );
  }

  Widget _buildBody(CyberColors c) {
    final purchase = _purchase!;
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppConstants.paddingMedium),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            '${purchase.supplierInvoiceNo ?? purchase.id.substring(0, 8)}'
            ' · ${fmtDate(purchase.purchaseDate)}',
            style: CyberTextStyles.mono(c, size: 14)
                .copyWith(color: c.textSecondary),
          ),
          const SizedBox(height: 12),
          Text(_t('selectItemsToReturn'),
              style: CyberTextStyles.title(c, size: 17)),
          const SizedBox(height: 8),
          if (purchase.items.isEmpty)
            Text(_t('noPurchases'), style: CyberTextStyles.bodySecondary(c))
          else
            ...purchase.items.map((item) => _itemCard(c, item)),
          const SizedBox(height: 12),
          CyberTextField(
            controller: _reasonController,
            label: _t('returnReason'),
          ),
          const SizedBox(height: 12),
          CyberCard(
            child: Row(
              children: [
                Expanded(
                  child: Text(_t('refundAmount'),
                      style: CyberTextStyles.subtitle(c)),
                ),
                moneyText(c, _totalRefund, size: 20, color: c.warning),
              ],
            ),
          ),
          const SizedBox(height: 16),
          CyberButton(
            label: _t('returnItems'),
            icon: Icons.undo,
            isLoading: _submitting,
            onPressed:
                (_submitting || !_hasSelection) ? null : _submit,
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _itemCard(CyberColors c, PurchaseItem item) {
    final isPhone = item.imei1 != null && item.imei1!.isNotEmpty;
    if (isPhone) {
      final imeiItemId = _imeiItemIdByItem[item.id];
      final returnable = imeiItemId != null;
      final selected = _selectedPhones.contains(item.id);
      return CyberCard(
        child: Row(
          children: [
            Checkbox(
              value: selected,
              onChanged: returnable
                  ? (value) => setState(() {
                        if (value == true) {
                          _selectedPhones.add(item.id);
                        } else {
                          _selectedPhones.remove(item.id);
                        }
                      })
                  : null,
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(item.imei1!, style: CyberTextStyles.imei(c)),
                  Text(
                    returnable ? _t('phoneItem') : _t('alreadyReturned'),
                    style: CyberTextStyles.bodySecondary(c, size: 13),
                  ),
                ],
              ),
            ),
            moneyText(c, item.total, size: 15),
          ],
        ),
      );
    }
    final remaining = _remainingQty(item);
    final qty = _returnQty[item.id] ?? 0;
    return CyberCard(
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(_t('accessoryItem'),
                    style: CyberTextStyles.body(c, size: 14)),
                Text(
                  '${_t('quantity')}: $remaining / ${item.quantity}'
                  ' · ${formatPkr(item.unitCost)}',
                  style: CyberTextStyles.mono(c, size: 12)
                      .copyWith(color: c.textSecondary),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.remove_circle_outline),
            tooltip: _t('remove'),
            onPressed: qty <= 0
                ? null
                : () => setState(() => _returnQty[item.id] = qty - 1),
          ),
          SizedBox(
            width: 36,
            child: Text(
              qty.toString(),
              textAlign: TextAlign.center,
              style: CyberTextStyles.mono(c, size: 16),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.add_circle_outline),
            tooltip: _t('add'),
            onPressed: qty >= remaining
                ? null
                : () => setState(() => _returnQty[item.id] = qty + 1),
          ),
        ],
      ),
    );
  }
}
