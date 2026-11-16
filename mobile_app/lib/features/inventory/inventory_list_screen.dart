library;

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/config/constants.dart';
import '../../core/l10n/app_strings.dart';
import '../../core/theme/app_theme.dart';
import '../../core/theme/cyber_text_styles.dart';
import '../../core/theme/cyber_widgets.dart';
import '../../domain/models/brand.dart';
import '../../domain/models/category.dart';
import '../../domain/models/imei_item.dart';
import '../../domain/models/product.dart';
import '../../domain/models/product_variant.dart';
import '../../domain/money.dart';
import '../../core/providers/app_providers.dart';
import 'imei_search_screen.dart';
import 'product_detail_screen.dart';
import 'product_form_screen.dart';

/// One product row with its variants + available-IMEI count, loaded
/// once per list refresh so filters and badges are computed locally.
class _ProductRow {
  const _ProductRow({
    required this.product,
    required this.variants,
    required this.availableImeiCount,
  });

  final Product product;
  final List<ProductVariant> variants;
  final int availableImeiCount;

  int get accessoryStock =>
      variants.fold<int>(0, (sum, v) => sum + v.quantity);

  /// Display stock: phones are counted by available IMEI, accessories
  /// by variant quantity.
  int get stockQty =>
      product.type == 'phone' ? availableImeiCount : accessoryStock;

  /// Low stock = strictly below the threshold (DECISIONS.md #56).
  bool get isLowStock {
    if (variants.isEmpty) return false;
    if (product.type == 'phone') {
      final threshold =
          variants.map((v) => v.lowStockThreshold).reduce((a, b) => a < b ? a : b);
      return availableImeiCount < threshold;
    }
    return variants.any((v) => v.quantity < v.lowStockThreshold);
  }

  bool get isOutOfStock => stockQty <= 0;

  Set<String> get conditions =>
      variants.map((v) => v.condition).toSet();

  Set<String> get ptaStatuses =>
      variants.map((v) => v.ptaStatus).toSet();
}

/// Inventory list (route `/inventory`).
///
/// Search by name / barcode, filter by category, brand, condition
/// (New / Used / Open Box), PTA status and low-stock only. Low-stock
/// and out-of-stock badges are shown per product; tapping a product
/// opens its detail screen.
class InventoryListScreen extends ConsumerStatefulWidget {
  const InventoryListScreen({super.key});

  @override
  ConsumerState<InventoryListScreen> createState() =>
      _InventoryListScreenState();
}

class _InventoryListScreenState extends ConsumerState<InventoryListScreen> {
  final TextEditingController _searchController = TextEditingController();
  Timer? _searchDebounce;

  bool _loading = true;
  String? _error;
  List<_ProductRow> _rows = <_ProductRow>[];

  List<Category> _categories = <Category>[];
  List<Brand> _brands = <Brand>[];

  String _query = '';
  String? _categoryId;
  String? _brandId;
  String? _type; // null = all, 'phone', 'accessory'
  String? _condition; // null = all, 'new', 'used', 'open_box'
  String? _ptaStatus; // null = all, 'approved', 'non_pta', 'not_applicable'
  bool _lowStockOnly = false;

  @override
  void initState() {
    super.initState();
    _loadFilters();
    _load();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchDebounce?.cancel();
    super.dispose();
  }

  Future<void> _loadFilters() async {
    try {
      final repo = ref.read(productRepositoryProvider);
      final categories = await repo.listCategories();
      final brands = await repo.listBrands();
      if (!mounted) return;
      setState(() {
        _categories = categories;
        _brands = brands;
      });
    } catch (_) {
      // Filters stay empty; the list still loads.
    }
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final repo = ref.read(productRepositoryProvider);
      final products = await repo.listProducts(
        search: _query.isEmpty ? null : _query,
        categoryId: _categoryId,
        brandId: _brandId,
        type: _type,
        limit: 100,
      );
      final rows = <_ProductRow>[];
      for (final product in products) {
        final variants = await repo.listVariants(product.id);
        var availableImei = 0;
        if (product.type == 'phone') {
          final imeis = await repo.listImeiItems(
            productId: product.id,
            status: ImeiStatus.available,
            limit: 200,
          );
          availableImei = imeis.length;
        }
        rows.add(
          _ProductRow(
            product: product,
            variants: variants,
            availableImeiCount: availableImei,
          ),
        );
      }
      if (!mounted) return;
      setState(() {
        _rows = rows;
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

  List<_ProductRow> get _filtered {
    return _rows.where((row) {
      if (_condition != null && !row.conditions.contains(_condition)) {
        return false;
      }
      if (_ptaStatus != null && !row.ptaStatuses.contains(_ptaStatus)) {
        return false;
      }
      if (_lowStockOnly && !row.isLowStock && !row.isOutOfStock) {
        return false;
      }
      return true;
    }).toList();
  }

  void _onSearchChanged(String value) {
    _searchDebounce?.cancel();
    _searchDebounce = Timer(
      const Duration(milliseconds: AppConstants.searchDebounceMs),
      () {
        setState(() => _query = value.trim());
        _load();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final c = ref.watch(themeNotifierProvider).colors;
    final lang = ref.watch(languageProvider);
    String tr(String key) => AppStrings.tr(key, language: lang);
    final rows = _filtered;

    return Scaffold(
      appBar: CyberAppBar(
        title: tr('inventory'),
        actions: [
          IconButton(
            icon: const Icon(Icons.qr_code_scanner),
            tooltip: tr('searchImei'),
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (_) => const ImeiSearchScreen(),
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.add),
            tooltip: tr('addProduct'),
            onPressed: () async {
              await Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => const ProductFormScreen(),
                ),
              );
              await _load();
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: CyberSearchBar(
              hint: tr('searchHint'),
              controller: _searchController,
              onChanged: _onSearchChanged,
              onSubmitted: (value) {
                setState(() => _query = value.trim());
                _load();
              },
            ),
          ),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Row(
              children: [
                _filterChip(
                  tr('all'),
                  _type == null,
                  () => setState(() {
                    _type = null;
                    _load();
                  }),
                ),
                _filterChip(
                  tr('phone'),
                  _type == 'phone',
                  () => setState(() {
                    _type = 'phone';
                    _load();
                  }),
                ),
                _filterChip(
                  tr('accessory'),
                  _type == 'accessory',
                  () => setState(() {
                    _type = 'accessory';
                    _load();
                  }),
                ),
                const SizedBox(width: 8),
                CyberChip(
                  label: tr('lowStock'),
                  selected: _lowStockOnly,
                  onSelected: (value) =>
                      setState(() => _lowStockOnly = value),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<String?>(
                    initialValue: _categoryId,
                    decoration: InputDecoration(
                      labelText: tr('filterCategory'),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                    ),
                    items: [
                      DropdownMenuItem<String?>(
                        value: null,
                        child: Text(tr('all')),
                      ),
                      for (final category in _categories)
                        DropdownMenuItem<String?>(
                          value: category.id,
                          child: Text(category.name),
                        ),
                    ],
                    onChanged: (value) {
                      setState(() => _categoryId = value);
                      _load();
                    },
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: DropdownButtonFormField<String?>(
                    initialValue: _brandId,
                    decoration: InputDecoration(
                      labelText: tr('filterBrand'),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                    ),
                    items: [
                      DropdownMenuItem<String?>(
                        value: null,
                        child: Text(tr('all')),
                      ),
                      for (final brand in _brands)
                        DropdownMenuItem<String?>(
                          value: brand.id,
                          child: Text(brand.name),
                        ),
                    ],
                    onChanged: (value) {
                      setState(() => _brandId = value);
                      _load();
                    },
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<String?>(
                    initialValue: _condition,
                    decoration: InputDecoration(
                      labelText: tr('filterCondition'),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                    ),
                    items: [
                      DropdownMenuItem<String?>(value: null, child: Text(tr('all'))),
                      DropdownMenuItem<String?>(
                        value: 'new',
                        child: Text(tr('newCondition')),
                      ),
                      DropdownMenuItem<String?>(
                        value: 'used',
                        child: Text(tr('usedCondition')),
                      ),
                      DropdownMenuItem<String?>(
                        value: 'open_box',
                        child: Text(tr('openBoxCondition')),
                      ),
                    ],
                    onChanged: (value) =>
                        setState(() => _condition = value),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: DropdownButtonFormField<String?>(
                    initialValue: _ptaStatus,
                    decoration: InputDecoration(
                      labelText: tr('filterPta'),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                    ),
                    items: [
                      DropdownMenuItem<String?>(value: null, child: Text(tr('all'))),
                      DropdownMenuItem<String?>(
                        value: 'approved',
                        child: Text(tr('ptaApproved')),
                      ),
                      DropdownMenuItem<String?>(
                        value: 'non_pta',
                        child: Text(tr('ptaNotApproved')),
                      ),
                      const DropdownMenuItem<String?>(
                        value: 'not_applicable',
                        child: Text('N/A'),
                      ),
                    ],
                    onChanged: (value) =>
                        setState(() => _ptaStatus = value),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: _loading
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
                    : rows.isEmpty
                        ? Center(
                            child: Text(
                              tr('noProductsFound'),
                              style: CyberTextStyles.bodySecondary(c),
                            ),
                          )
                        : RefreshIndicator(
                            onRefresh: _load,
                            child: ListView.builder(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                              ),
                              itemCount: rows.length,
                              itemBuilder: (context, index) {
                                final row = rows[index];
                                final product = row.product;
                                final minPrice = row.variants.isEmpty
                                    ? 0
                                    : row.variants
                                        .map((v) => v.salePrice)
                                        .reduce(
                                          (a, b) => a < b ? a : b,
                                        );
                                return CyberCard(
                                  onTap: () async {
                                    await Navigator.of(context).push(
                                      MaterialPageRoute<void>(
                                        builder: (_) =>
                                            ProductDetailScreen(
                                          productId: product.id,
                                        ),
                                      ),
                                    );
                                    await _load();
                                  },
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              product.name,
                                              style:
                                                  CyberTextStyles.subtitle(c),
                                            ),
                                            Text(
                                              [
                                                if (product.brandName !=
                                                    null)
                                                  product.brandName!,
                                                product.type,
                                                if (product.barcode != null)
                                                  product.barcode!,
                                              ].join(' · '),
                                              style:
                                                  CyberTextStyles.caption(c),
                                            ),
                                            const SizedBox(height: 4),
                                            Row(
                                              children: [
                                                if (row.isOutOfStock)
                                                  CyberBadge(
                                                    label: tr('outOfStock'),
                                                    color: c.error,
                                                  )
                                                else if (row.isLowStock)
                                                  CyberBadge(
                                                    label: tr('lowStock'),
                                                    color: c.warning,
                                                  )
                                                else
                                                  CyberBadge(
                                                    label: tr('inStock'),
                                                    color: c.success,
                                                  ),
                                                const SizedBox(width: 8),
                                                Text(
                                                  '${tr('stock')}: ${row.stockQty}',
                                                  style:
                                                      CyberTextStyles.mono(
                                                    c,
                                                    size: 13,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.end,
                                        children: [
                                          Text(
                                            formatPkr(minPrice),
                                            style: CyberTextStyles.mono(
                                              c,
                                              size: 15,
                                            ),
                                          ),
                                          Text(
                                            '${row.variants.length} ${tr('variants')}',
                                            style:
                                                CyberTextStyles.caption(c),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                          ),
          ),
        ],
      ),
    );
  }

  Widget _filterChip(String label, bool selected, VoidCallback onTap) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: CyberChip(
        label: label,
        selected: selected,
        onSelected: (_) => onTap(),
      ),
    );
  }
}
