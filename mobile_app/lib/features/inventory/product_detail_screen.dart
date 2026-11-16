library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/config/constants.dart';
import '../../core/l10n/app_strings.dart';
import '../../core/theme/app_theme.dart';
import '../../core/theme/cyber_colors.dart';
import '../../core/theme/cyber_text_styles.dart';
import '../../core/theme/cyber_widgets.dart';
import '../../domain/models/imei_item.dart';
import '../../domain/models/product.dart';
import '../../domain/models/product_variant.dart';
import '../../domain/money.dart';
import '../auth/auth_state.dart';
import '../../core/providers/app_providers.dart';
import 'imei_search_screen.dart';
import 'product_form_screen.dart';
import 'stock_adjust_screen.dart';

/// Product detail (route `/inventory/:id`).
///
/// Photo placeholder, name / brand / model / colour / storage / RAM /
/// condition / PTA, prices, stock quantity, IMEI list with status, and
/// the low-stock threshold. Cost price is hidden from cashiers; only
/// owner/manager see it (and profit). Edit opens the product form.
class ProductDetailScreen extends ConsumerStatefulWidget {
  const ProductDetailScreen({super.key, required this.productId});

  final String productId;

  @override
  ConsumerState<ProductDetailScreen> createState() =>
      _ProductDetailScreenState();
}

class _ProductDetailScreenState extends ConsumerState<ProductDetailScreen> {
  bool _loading = true;
  String? _error;
  Product? _product;
  List<ProductVariant> _variants = <ProductVariant>[];
  List<ImeiItem> _imeis = <ImeiItem>[];

  @override
  void initState() {
    super.initState();
    _load();
  }

  bool get _canSeeCosts {
    final role = ref.read(authStateProvider).user?.role;
    return UserRoles.canSeeCosts.contains(role);
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final repo = ref.read(productRepositoryProvider);
      final product = await repo.getProduct(widget.productId);
      if (product == null) throw Exception('Product not found');
      final variants = await repo.listVariants(product.id);
      final imeis = await repo.listImeiItems(productId: product.id);
      if (!mounted) return;
      setState(() {
        _product = product;
        _variants = variants;
        _imeis = imeis;
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

  Future<void> _delete() async {
    final lang = ref.read(languageProvider);
    String tr(String key) => AppStrings.tr(key, language: lang);
    final product = _product;
    if (product == null) return;
    final confirmed = await showCyberDialog(
      context,
      title: tr('delete'),
      message: tr('confirmDeleteProduct'),
      confirmLabel: tr('delete'),
      danger: true,
    );
    if (!confirmed) return;
    try {
      await ref.read(productRepositoryProvider).deleteProduct(
            product.id,
            userId: ref.read(authStateProvider).user?.id,
          );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(tr('deleted'))),
      );
      Navigator.of(context).pop();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = ref.watch(themeNotifierProvider).colors;
    final lang = ref.watch(languageProvider);
    String tr(String key) => AppStrings.tr(key, language: lang);
    final product = _product;
    final canSeeCosts = _canSeeCosts;
    final canDelete = ref.watch(authStateProvider).user?.role !=
        UserRoles.cashier;

    return Scaffold(
      appBar: CyberAppBar(
        title: product?.name ?? tr('productDetails'),
        actions: [
          if (product != null)
            IconButton(
              icon: const Icon(Icons.edit_outlined),
              tooltip: tr('edit'),
              onPressed: () async {
                await Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) =>
                        ProductFormScreen(productId: product.id),
                  ),
                );
                await _load();
              },
            ),
          if (product != null && canDelete)
            IconButton(
              icon: const Icon(Icons.delete_outline),
              tooltip: tr('delete'),
              onPressed: _delete,
            ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          _error!,
                          style: CyberTextStyles.error(c),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 12),
                        CyberButton(
                          label: tr('retry'),
                          fullWidth: false,
                          onPressed: _load,
                        ),
                      ],
                    ),
                  ),
                )
              : product == null
                  ? Center(
                      child: Text(
                        tr('noData'),
                        style: CyberTextStyles.bodySecondary(c),
                      ),
                    )
                  : RefreshIndicator(
                      onRefresh: _load,
                      child: ListView(
                        padding: const EdgeInsets.all(12),
                        children: [
                          CyberCard(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                if (product.imageUrl != null)
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(8),
                                    child: Image.network(
                                      product.imageUrl!,
                                      height: 180,
                                      width: double.infinity,
                                      fit: BoxFit.cover,
                                      errorBuilder:
                                          (context, error, stackTrace) =>
                                              const SizedBox.shrink(),
                                    ),
                                  ),
                                Text(
                                  product.name,
                                  style: CyberTextStyles.title(c, size: 20),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  [
                                    if (product.brandName != null)
                                      product.brandName!,
                                    if (product.categoryName != null)
                                      product.categoryName!,
                                    product.type,
                                  ].join(' · '),
                                  style: CyberTextStyles.bodySecondary(c),
                                ),
                                if (product.barcode != null) ...[
                                  const SizedBox(height: 4),
                                  Text(
                                    '${tr('barcode')}: ${product.barcode}',
                                    style: CyberTextStyles.mono(c, size: 13),
                                  ),
                                ],
                                if (product.description != null &&
                                    product.description!.isNotEmpty) ...[
                                  const SizedBox(height: 8),
                                  Text(
                                    product.description!,
                                    style: CyberTextStyles.body(c),
                                  ),
                                ],
                              ],
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            tr('variants'),
                            style: CyberTextStyles.subtitle(c),
                          ),
                          if (_variants.isEmpty)
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(vertical: 8),
                              child: Text(
                                tr('noVariants'),
                                style: CyberTextStyles.bodySecondary(c),
                              ),
                            ),
                          for (final variant in _variants)
                            _variantCard(variant, tr, c, canSeeCosts),
                          const SizedBox(height: 8),
                          Text(
                            tr('imeiList'),
                            style: CyberTextStyles.subtitle(c),
                          ),
                          if (_imeis.isEmpty)
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(vertical: 8),
                              child: Text(
                                tr('noImeiItems'),
                                style: CyberTextStyles.bodySecondary(c),
                              ),
                            ),
                          for (final imei in _imeis)
                            CyberCard(
                              onTap: () => Navigator.of(context).push(
                                MaterialPageRoute<void>(
                                  builder: (_) => ImeiSearchScreen(
                                    initialImei: imei.imei1,
                                  ),
                                ),
                              ),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          imei.imei1,
                                          style: CyberTextStyles.imei(c),
                                        ),
                                        if (imei.imei2 != null)
                                          Text(
                                            imei.imei2!,
                                            style: CyberTextStyles.imei(
                                              c,
                                              size: 12,
                                            ),
                                          ),
                                        Text(
                                          imei.soldSaleId == null
                                              ? tr('available')
                                              : '${tr('saleRef')}: ${imei.soldSaleId}',
                                          style:
                                              CyberTextStyles.caption(c),
                                        ),
                                      ],
                                    ),
                                  ),
                                  CyberBadge(
                                    label: imei.status.toUpperCase(),
                                    color: imei.status ==
                                            ImeiStatus.available
                                        ? c.success
                                        : imei.status == ImeiStatus.sold
                                            ? c.error
                                            : c.warning,
                                  ),
                                ],
                              ),
                            ),
                          const SizedBox(height: 12),
                          if (product.type == 'accessory')
                            CyberButton(
                              label: tr('adjustStock'),
                              variant: CyberButtonVariant.ghost,
                              icon: Icons.tune_outlined,
                              onPressed: () async {
                                await Navigator.of(context).push(
                                  MaterialPageRoute<void>(
                                    builder: (_) => StockAdjustScreen(
                                      productId: product.id,
                                    ),
                                  ),
                                );
                                await _load();
                              },
                            ),
                        ],
                      ),
                    ),
    );
  }

  Widget _variantCard(
    ProductVariant variant,
    String Function(String) tr,
    CyberColors c,
    bool canSeeCosts,
  ) {
    final isLowStock = variant.quantity < variant.lowStockThreshold;
    return CyberCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  variant.name,
                  style: CyberTextStyles.subtitle(c),
                ),
              ),
              if (isLowStock)
                CyberBadge(label: tr('lowStock'), color: c.warning)
              else
                CyberBadge(label: tr('inStock'), color: c.success),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            [
              if (variant.color != null) variant.color!,
              if (variant.storageGb != null) '${variant.storageGb}GB',
              if (variant.ramGb != null) '${variant.ramGb}GB RAM',
              variant.condition,
              variant.ptaStatus,
            ].join(' · '),
            style: CyberTextStyles.bodySecondary(c),
          ),
          const SizedBox(height: 8),
          CyberTable(
            headers: [
              tr('salePrice'),
              if (canSeeCosts) tr('costPrice'),
              tr('minPrice'),
              tr('stock'),
            ],
            rows: [
              [
                formatPkr(variant.salePrice),
                if (canSeeCosts) formatPkr(variant.purchasePrice),
                formatPkr(variant.minPrice),
                '${variant.quantity}',
              ],
            ],
            monospaceColumns: const {0, 1, 2, 3},
          ),
          const SizedBox(height: 4),
          Text(
            '${tr('lowStockThreshold')}: ${variant.lowStockThreshold} · ${tr('warrantyMonths')}: ${variant.warrantyMonths}',
            style: CyberTextStyles.caption(c),
          ),
          if (canSeeCosts)
            Text(
              '${tr('profit')}: ${formatPkr(variant.salePrice - variant.purchasePrice)}',
              style: CyberTextStyles.mono(c, size: 13)
                  .copyWith(color: c.success),
            ),
        ],
      ),
    );
  }
}
