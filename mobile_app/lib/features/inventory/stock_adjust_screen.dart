library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/l10n/app_strings.dart';
import '../../core/theme/app_theme.dart';
import '../../core/theme/cyber_text_styles.dart';
import '../../core/theme/cyber_widgets.dart';
import '../../domain/models/product.dart';
import '../../domain/models/product_variant.dart';
import '../../domain/money.dart';
import '../auth/auth_state.dart';
import '../../core/providers/app_providers.dart';

/// Stock adjust screen (route `/inventory/adjust`).
///
/// Pick a product, pick one of its variants, enter an increase or
/// decrease and a reason. The correction goes through
/// [ProductRepository.adjustVariantQuantity], which writes the audit-log
/// entry — this screen only collects the input and shows the new stock.
///
/// Phone variants are IMEI-driven, so their quantity is not adjusted
/// here: the screen says so and points at IMEI add/remove instead.
class StockAdjustScreen extends ConsumerStatefulWidget {
  const StockAdjustScreen({super.key, this.productId});

  final String? productId;

  @override
  ConsumerState<StockAdjustScreen> createState() =>
      _StockAdjustScreenState();
}

class _StockAdjustScreenState extends ConsumerState<StockAdjustScreen> {
  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _reasonController = TextEditingController();

  bool _loadingProducts = false;
  bool _adjusting = false;
  String? _error;
  String? _success;
  List<Product> _searchResults = <Product>[];
  Product? _product;
  List<ProductVariant> _variants = <ProductVariant>[];
  ProductVariant? _variant;
  bool _isIncrease = true;

  @override
  void initState() {
    super.initState();
    if (widget.productId != null) {
      _loadProduct(widget.productId!);
    }
  }

  Future<void> _loadProduct(String productId) async {
    final product =
        await ref.read(productRepositoryProvider).getProduct(productId);
    if (product != null && mounted) {
      await _selectProduct(product);
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    _amountController.dispose();
    _reasonController.dispose();
    super.dispose();
  }

  String get _userId => ref.read(authStateProvider).user?.id ?? '';

  Future<void> _searchProducts(String query) async {
    final q = query.trim();
    if (q.length < 2) {
      setState(() => _searchResults = <Product>[]);
      return;
    }
    setState(() => _loadingProducts = true);
    try {
      final results = await ref
          .read(productRepositoryProvider)
          .searchProducts(q, limit: 20);
      if (!mounted) return;
      setState(() {
        _searchResults = results;
        _loadingProducts = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString();
        _loadingProducts = false;
      });
    }
  }

  Future<void> _selectProduct(Product product) async {
    setState(() {
      _product = product;
      _variant = null;
      _searchResults = <Product>[];
      _searchController.clear();
      _error = null;
      _success = null;
    });
    try {
      final variants = await ref
          .read(productRepositoryProvider)
          .listVariants(product.id);
      if (!mounted) return;
      setState(() {
        _variants = variants;
        if (variants.isNotEmpty) _variant = variants.first;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _error = e.toString());
    }
  }

  Future<void> _adjust() async {
    final lang = ref.read(languageProvider);
    String tr(String key) => AppStrings.tr(key, language: lang);
    final variant = _variant;
    if (variant == null) return;
    final amount = int.tryParse(_amountController.text.trim()) ?? 0;
    final reason = _reasonController.text.trim();
    if (amount <= 0 || reason.isEmpty) {
      setState(() => _error = tr('fieldRequired'));
      return;
    }
    final delta = _isIncrease ? amount : -amount;
    if (variant.quantity + delta < 0) {
      setState(() => _error = tr('enterValidAmount'));
      return;
    }
    setState(() {
      _adjusting = true;
      _error = null;
      _success = null;
    });
    try {
      final updated = await ref
          .read(productRepositoryProvider)
          .adjustVariantQuantity(
            variant.id,
            delta,
            userId: _userId,
            reason: reason,
          );
      if (!mounted) return;
      setState(() {
        _variants = _variants
            .map((v) => v.id == updated.id ? updated : v)
            .toList();
        _variant = updated;
        _adjusting = false;
        _amountController.clear();
        _reasonController.clear();
        _success =
            '${tr('stockAdjusted')} — ${tr('newStock')}: ${updated.quantity}';
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString();
        _adjusting = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = ref.watch(themeNotifierProvider).colors;
    final lang = ref.watch(languageProvider);
    String tr(String key) => AppStrings.tr(key, language: lang);
    final product = _product;
    final variant = _variant;
    final isPhone = product?.type == 'phone';

    return Scaffold(
      appBar: CyberAppBar(title: tr('stockAdjust')),
      body: ListView(
        padding: const EdgeInsets.all(12),
        children: [
          Text(
            tr('stockAdjustmentNote'),
            style: CyberTextStyles.bodySecondary(c),
          ),
          const SizedBox(height: 12),
          CyberSearchBar(
            hint: tr('searchHint'),
            controller: _searchController,
            onChanged: _searchProducts,
            onSubmitted: _searchProducts,
          ),
          if (_loadingProducts)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 8),
              child: CircularProgressIndicator(),
            ),
          if (_searchResults.isNotEmpty)
            ..._searchResults.map(
              (p) => ListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(p.name),
                subtitle: Text(p.type),
                onTap: () => _selectProduct(p),
              ),
            ),
          if (product != null) ...[
            const SizedBox(height: 12),
            CyberCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(product.name, style: CyberTextStyles.title(c)),
                  Text(
                    [
                      if (product.brandName != null) product.brandName!,
                      product.type,
                    ].join(' · '),
                    style: CyberTextStyles.bodySecondary(c),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Text(tr('selectVariant'), style: CyberTextStyles.subtitle(c)),
            const SizedBox(height: 8),
            DropdownButtonFormField<String?>(
              initialValue: variant?.id,
              decoration: InputDecoration(labelText: tr('variants')),
              items: [
                for (final v in _variants)
                  DropdownMenuItem<String?>(
                    value: v.id,
                    child: Text(
                      '${v.name} — ${tr('stock')}: ${v.quantity}',
                    ),
                  ),
              ],
              onChanged: (value) => setState(() {
                _variant = _variants
                    .where((v) => v.id == value)
                    .firstOrNull;
                _success = null;
                _error = null;
              }),
            ),
          ],
          if (variant != null) ...[
            const SizedBox(height: 12),
            CyberCard(
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        tr('currentStock'),
                        style: CyberTextStyles.body(c),
                      ),
                      Text(
                        '${variant.quantity}',
                        style: CyberTextStyles.amount(c, size: 26),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${tr('lowStockThreshold')}: ${variant.lowStockThreshold} · ${tr('salePrice')}: ${formatPkr(variant.salePrice)}',
                    style: CyberTextStyles.caption(c),
                  ),
                ],
              ),
            ),
            if (isPhone) ...[
              const SizedBox(height: 12),
              CyberCard(
                borderColor: c.warning,
                child: Text(
                  tr('phoneStockNote'),
                  style: CyberTextStyles.warning(c),
                ),
              ),
            ] else ...[
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: CyberChip(
                      label: tr('increase'),
                      selected: _isIncrease,
                      onSelected: (_) =>
                          setState(() => _isIncrease = true),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: CyberChip(
                      label: tr('decrease'),
                      selected: !_isIncrease,
                      onSelected: (_) =>
                          setState(() => _isIncrease = false),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              CyberTextField(
                controller: _amountController,
                label: tr('quantity'),
                monospace: true,
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 12),
              CyberTextField(
                controller: _reasonController,
                label: tr('adjustmentReason'),
                hint: 'e.g. damaged in shop, counting error',
              ),
              const SizedBox(height: 16),
              CyberButton(
                label: tr('adjustStock'),
                icon: Icons.tune_outlined,
                isLoading: _adjusting,
                onPressed: _adjust,
              ),
            ],
          ],
          if (_error != null) ...[
            const SizedBox(height: 12),
            Text(_error!, style: CyberTextStyles.error(c)),
          ],
          if (_success != null) ...[
            const SizedBox(height: 12),
            CyberCard(
              borderColor: c.success,
              child: Text(_success!, style: CyberTextStyles.success(c)),
            ),
          ],
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}
