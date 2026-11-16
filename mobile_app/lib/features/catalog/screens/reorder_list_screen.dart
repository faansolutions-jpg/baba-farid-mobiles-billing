import 'package:flutter/material.dart';

import '../catalog_models.dart';
import '../catalog_repository.dart';
import 'catalog_strings.dart';
import 'catalog_theme.dart';

/// Reorder List.
///
/// Low-stock items ([lowStock]) grouped by supplier
/// ([reorderListBySupplier]). Each group has a supplier header with its
/// items and the quantity to order for each. The suggested order quantity
/// brings stock back up to twice the low-stock threshold.
class ReorderListScreen extends StatefulWidget {
  const ReorderListScreen({super.key, required this.repository});

  final CatalogRepository repository;

  @override
  State<ReorderListScreen> createState() => _ReorderListScreenState();
}

class _ReorderListScreenState extends State<ReorderListScreen> {
  bool _loading = true;
  String? _error;
  Map<String, List<CatalogItem>> _groups = <String, List<CatalogItem>>{};
  int _lowStockTotal = 0;

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
      final results = await Future.wait(<Future<Object>>[
        widget.repository.reorderListBySupplier(),
        widget.repository.lowStock(),
      ]);
      if (!mounted) return;
      setState(() {
        _groups = (results[0] as Map<String, List<CatalogItem>>);
        _lowStockTotal = (results[1] as List<CatalogItem>).length;
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

  /// Suggested quantity to order: restock to twice the low-stock
  /// threshold, at least 1 piece.
  int _suggestedQty(CatalogItem item) {
    final target = item.lowStockThreshold * 2;
    final needed = target - item.stockQty;
    return needed < 1 ? 1 : needed;
  }

  int _groupValue(List<CatalogItem> items) {
    return items.fold<int>(
      0,
      (sum, item) => sum + _suggestedQty(item) * item.purchasePriceEst,
    );
  }

  int get _totalValue => _groups.values.fold<int>(
        0,
        (sum, items) => sum + _groupValue(items),
      );

  int get _totalItems => _groups.values.fold<int>(
        0,
        (sum, items) => sum + items.length,
      );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: CatalogTheme.background,
      appBar: CatalogTheme.appBar(
        CatalogStrings.tr('reorderList'),
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.refresh, color: CatalogTheme.text),
            tooltip: CatalogStrings.tr('refresh'),
            onPressed: _load,
          ),
        ],
      ),
      body: _loading
          ? CatalogTheme.loadingView(CatalogStrings.tr('loading'))
          : _error != null
              ? CatalogTheme.errorView(
                  CatalogStrings.tr('somethingWentWrong'),
                  _load,
                )
              : _groups.isEmpty
                  ? CatalogTheme.emptyView(
                      CatalogStrings.tr('noLowStock'),
                      CatalogStrings.tr('reorderSubtitle'),
                    )
                  : _buildList(),
    );
  }

  Widget _buildList() {
    final suppliers = _groups.keys.toList()..sort();
    return Column(
      children: <Widget>[
        Container(
          margin: const EdgeInsets.fromLTRB(12, 12, 12, 4),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: CatalogTheme.cardDecoration(
            borderColor: CatalogTheme.amber.withValues(alpha: 0.7),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Text(
                '$_totalItems ${CatalogStrings.tr('items')}  •  '
                '$_lowStockTotal ${CatalogStrings.tr('lowStock')}',
                style: CatalogTheme.monoSmall.copyWith(color: CatalogTheme.text),
              ),
              Text(
                CatalogTheme.formatPkr(_totalValue),
                style: CatalogTheme.mono.copyWith(color: CatalogTheme.amber),
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView.builder(
            itemCount: suppliers.length,
            itemBuilder: (context, index) {
              final supplier = suppliers[index];
              final items = _groups[supplier] ?? <CatalogItem>[];
              return _buildSupplierGroup(supplier, items);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildSupplierGroup(String supplier, List<CatalogItem> items) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: CatalogTheme.cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: const BoxDecoration(
              color: CatalogTheme.surface,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
            ),
            child: Row(
              children: <Widget>[
                const Icon(Icons.storefront, color: CatalogTheme.cyan, size: 22),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    supplier,
                    style: CatalogTheme.heading,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  '${items.length} ${CatalogStrings.tr('items')}',
                  style: CatalogTheme.monoSmall,
                ),
              ],
            ),
          ),
          ...items.map((item) {
            final orderQty = _suggestedQty(item);
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          item.nameEn,
                          style: CatalogTheme.body.copyWith(fontWeight: FontWeight.w600),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '${item.brand}  •  ${item.sku}',
                          style: CatalogTheme.monoSmall,
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: <Widget>[
                            Text(
                              '${CatalogStrings.tr('stock')}: ${item.stockQty}',
                              style: CatalogTheme.monoSmall.copyWith(color: CatalogTheme.red),
                            ),
                            const SizedBox(width: 10),
                            Text(
                              '${CatalogStrings.tr('threshold')}: ${item.lowStockThreshold}',
                              style: CatalogTheme.monoSmall,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 10),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: <Widget>[
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: CatalogTheme.amber.withValues(alpha: 0.14),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: CatalogTheme.amber),
                        ),
                        child: Text(
                          '${CatalogStrings.tr('orderQty')}: $orderQty',
                          style: CatalogTheme.mono.copyWith(
                            fontSize: 13,
                            color: CatalogTheme.amber,
                          ),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        CatalogTheme.formatPkr(orderQty * item.purchasePriceEst),
                        style: CatalogTheme.monoSmall.copyWith(color: CatalogTheme.text),
                      ),
                    ],
                  ),
                ],
              ),
            );
          }),
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 4, 14, 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Text(
                  CatalogStrings.tr('orderValue'),
                  style: CatalogTheme.bodySmall,
                ),
                Text(
                  CatalogTheme.formatPkr(_groupValue(items)),
                  style: CatalogTheme.price.copyWith(color: CatalogTheme.amber),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
