import 'package:flutter/material.dart';

import '../catalog_models.dart';
import '../catalog_repository.dart';
import 'catalog_strings.dart';
import 'catalog_theme.dart';

/// Opening Stock — first-day setup.
///
/// Walks through the catalog category by category, entering quantities
/// for everything at once. Progress bar shows e.g. "320 of 1500 items
/// counted". Each category can be skipped. One Save at the end persists
/// everything in a single [bulkStockIn] call — saving adds stock, so it
/// happens exactly once — and then a summary is shown.
///
/// Quantities of 0 still count as "counted" (the shelf was checked and
/// is empty); only quantities > 0 are sent to [bulkStockIn].
class OpeningStockScreen extends StatefulWidget {
  const OpeningStockScreen({super.key, required this.repository});

  final CatalogRepository repository;

  @override
  State<OpeningStockScreen> createState() => _OpeningStockScreenState();
}

class _OpeningStockScreenState extends State<OpeningStockScreen> {
  final Map<String, TextEditingController> _qtyControllers =
      <String, TextEditingController>{};

  bool _loading = true;
  bool _saving = false;
  bool _saved = false;
  String? _error;

  List<String> _categories = <String>[];
  final Map<String, List<CatalogItem>> _itemsByCategory =
      <String, List<CatalogItem>>{};
  int _currentIndex = 0;

  /// Item ids with a quantity typed in (including 0 = checked, empty shelf).
  final Set<String> _counted = <String>{};

  /// Categories the shopkeeper chose to skip.
  final Set<String> _skipped = <String>{};

  // Summary (filled after a successful save).
  int _summaryItems = 0;
  int _summaryQty = 0;
  int _summaryValue = 0;

  @override
  void initState() {
    super.initState();
    _loadAll();
  }

  @override
  void dispose() {
    for (final controller in _qtyControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  int get _totalItems => _itemsByCategory.values
      .fold<int>(0, (sum, items) => sum + items.length);

  String? get _currentCategory =>
      _categories.isEmpty ? null : _categories[_currentIndex];

  List<CatalogItem> get _currentItems =>
      _currentCategory == null ? <CatalogItem>[] : (_itemsByCategory[_currentCategory] ?? <CatalogItem>[]);

  Future<void> _loadAll() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final categories = await widget.repository.categories();
      final byCategory = <String, List<CatalogItem>>{};
      for (final category in categories) {
        byCategory[category] = await widget.repository.byCategory(category);
      }
      if (!mounted) return;
      setState(() {
        _categories = categories;
        _itemsByCategory
          ..clear()
          ..addAll(byCategory);
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

  TextEditingController _qtyControllerFor(CatalogItem item) {
    return _qtyControllers.putIfAbsent(
      item.id,
      () => TextEditingController(),
    );
  }

  int _qtyOf(CatalogItem item) {
    final controller = _qtyControllers[item.id];
    if (controller == null) return 0;
    return int.tryParse(controller.text.trim()) ?? 0;
  }

  void _onQtyChanged(CatalogItem item, String value) {
    setState(() {
      if (value.trim().isEmpty) {
        _counted.remove(item.id);
      } else {
        _counted.add(item.id);
      }
    });
  }

  void _goTo(int index) {
    if (index < 0 || index >= _categories.length) return;
    setState(() => _currentIndex = index);
  }

  void _skipCurrentCategory() {
    final category = _currentCategory;
    if (category == null) return;
    setState(() {
      _skipped.add(category);
      // A skipped category's items are not counted; clear any stray input.
      for (final item in _itemsByCategory[category] ?? <CatalogItem>[]) {
        _counted.remove(item.id);
        _qtyControllers[item.id]?.clear();
      }
    });
    _goTo(_currentIndex + 1);
  }

  Future<void> _save() async {
    final quantities = <String, int>{};
    var totalQty = 0;
    var totalValue = 0;
    for (final items in _itemsByCategory.values) {
      for (final item in items) {
        final qty = _qtyOf(item);
        if (qty > 0) {
          quantities[item.id] = qty;
          totalQty += qty;
          totalValue += qty * item.purchasePriceEst;
        }
      }
    }
    if (quantities.isEmpty) {
      _showMessage(CatalogStrings.tr('nothingToSave'), isError: true);
      return;
    }
    setState(() => _saving = true);
    try {
      await widget.repository.bulkStockIn(quantities, date: DateTime.now());
      if (!mounted) return;
      setState(() {
        _saving = false;
        _saved = true;
        _summaryItems = quantities.length;
        _summaryQty = totalQty;
        _summaryValue = totalValue;
      });
      _showMessage(
        CatalogStrings.trArgs('openingSaved', {'count': quantities.length}),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => _saving = false);
      _showMessage('${CatalogStrings.tr('somethingWentWrong')} ($e)',
          isError: true);
    }
  }

  void _showMessage(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? CatalogTheme.red : CatalogTheme.surface,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: CatalogTheme.background,
      appBar: CatalogTheme.appBar(CatalogStrings.tr('openingStock')),
      body: _loading
          ? CatalogTheme.loadingView(CatalogStrings.tr('loading'))
          : _error != null
              ? CatalogTheme.errorView(
                  CatalogStrings.tr('somethingWentWrong'),
                  _loadAll,
                )
              : _saved
                  ? _buildSummary()
                  : _buildCounting(),
    );
  }

  Widget _buildCounting() {
    if (_categories.isEmpty) {
      return CatalogTheme.emptyView(CatalogStrings.tr('noCategories'));
    }
    final category = _currentCategory!;
    final items = _currentItems;
    final countedInCategory =
        items.where((item) => _counted.contains(item.id)).length;
    return Column(
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
          child: CatalogTheme.progressBar(
            _counted.length,
            _totalItems,
            label: CatalogStrings.tr('countedOf'),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(12, 10, 12, 4),
          child: Text(
            CatalogStrings.tr('saveOnceNote'),
            style: CatalogTheme.bodySmall.copyWith(color: CatalogTheme.amber),
          ),
        ),
        _buildCategoryChips(),
        CatalogTheme.sectionHeader(
          category,
          subtitle:
              '$countedInCategory/${items.length} ${CatalogStrings.tr('countedOf')}'
              '${_skipped.contains(category) ? '  •  ${CatalogStrings.tr('skipCategory')}' : ''}',
        ),
        Expanded(
          child: items.isEmpty
              ? CatalogTheme.emptyView(CatalogStrings.tr('noItemsInCategory'))
              : ListView.builder(
                  itemCount: items.length,
                  itemBuilder: (context, index) {
                    final item = items[index];
                    final counted = _counted.contains(item.id);
                    return Container(
                      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                      decoration: CatalogTheme.cardDecoration(
                        borderColor: counted
                            ? CatalogTheme.primary.withValues(alpha: 0.6)
                            : null,
                      ),
                      child: Row(
                        children: <Widget>[
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Text(
                                  item.nameEn,
                                  style: CatalogTheme.body.copyWith(
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                if (item.nameUr.isNotEmpty)
                                  Text(item.nameUr, style: CatalogTheme.urdu),
                                const SizedBox(height: 4),
                                Text(
                                  '${item.brand}  •  ${item.sku}',
                                  style: CatalogTheme.monoSmall,
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  CatalogTheme.formatPkr(item.purchasePriceEst),
                                  style: CatalogTheme.monoSmall.copyWith(
                                    color: CatalogTheme.cyan,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 10),
                          SizedBox(
                            width: 96,
                            height: 52,
                            child: TextField(
                              controller: _qtyControllerFor(item),
                              keyboardType: TextInputType.number,
                              textAlign: TextAlign.center,
                              style: CatalogTheme.monoLarge,
                              onChanged: (value) => _onQtyChanged(item, value),
                              decoration: CatalogTheme.inputDecoration(hint: '0'),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
        ),
        _buildNavBar(),
      ],
    );
  }

  Widget _buildCategoryChips() {
    return SizedBox(
      height: 44,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        itemCount: _categories.length,
        itemBuilder: (context, index) {
          final category = _categories[index];
          final isCurrent = index == _currentIndex;
          final isSkipped = _skipped.contains(category);
          final countedInCategory = (_itemsByCategory[category] ?? <CatalogItem>[])
              .where((item) => _counted.contains(item.id))
              .length;
          final totalInCategory = (_itemsByCategory[category] ?? <CatalogItem>[]).length;
          final isDone = totalInCategory > 0 && countedInCategory == totalInCategory;
          final Color edge;
          if (isCurrent) {
            edge = CatalogTheme.primary;
          } else if (isSkipped) {
            edge = CatalogTheme.muted;
          } else if (isDone) {
            edge = CatalogTheme.primary;
          } else {
            edge = CatalogTheme.border;
          }
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: InkWell(
              onTap: () => _goTo(index),
              borderRadius: BorderRadius.circular(20),
              child: Container(
                alignment: Alignment.center,
                padding: const EdgeInsets.symmetric(horizontal: 14),
                decoration: BoxDecoration(
                  color: isCurrent
                      ? CatalogTheme.primary.withValues(alpha: 0.16)
                      : CatalogTheme.surface,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: edge),
                ),
                child: Text(
                  isSkipped
                      ? '$category ✕'
                      : isDone
                          ? '$category ✓'
                          : category,
                  style: CatalogTheme.monoSmall.copyWith(
                    color: isCurrent || isDone
                        ? CatalogTheme.primary
                        : CatalogTheme.text,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildNavBar() {
    final isLast = _currentIndex >= _categories.length - 1;
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 16),
      decoration: const BoxDecoration(
        color: CatalogTheme.surface,
        border: Border(top: BorderSide(color: CatalogTheme.border)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Row(
            children: <Widget>[
              Expanded(
                child: OutlinedButton(
                  onPressed: _currentIndex == 0 ? null : () => _goTo(_currentIndex - 1),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: CatalogTheme.text,
                    minimumSize: const Size(0, 48),
                    side: const BorderSide(color: CatalogTheme.border),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: Text(CatalogStrings.tr('previous')),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: OutlinedButton(
                  onPressed: _skipCurrentCategory,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: CatalogTheme.amber,
                    minimumSize: const Size(0, 48),
                    side: const BorderSide(color: CatalogTheme.amber),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: Text(CatalogStrings.tr('skipCategory')),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: OutlinedButton(
                  onPressed: isLast ? null : () => _goTo(_currentIndex + 1),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: CatalogTheme.text,
                    minimumSize: const Size(0, 48),
                    side: const BorderSide(color: CatalogTheme.border),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: Text(CatalogStrings.tr('next')),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _saving ? null : _save,
              style: CatalogTheme.primaryButtonStyle,
              child: _saving
                  ? const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(
                        color: CatalogTheme.onPrimary,
                        strokeWidth: 2.5,
                      ),
                    )
                  : Text(CatalogStrings.tr('saveOpeningStock')),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummary() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: <Widget>[
        const Icon(Icons.check_circle, color: CatalogTheme.primary, size: 56),
        const SizedBox(height: 12),
        Text(
          CatalogStrings.tr('openingSummary'),
          style: CatalogTheme.title,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 20),
        _summaryRow(
          CatalogStrings.tr('items'),
          '$_summaryItems',
        ),
        _summaryRow(
          CatalogStrings.tr('totalPieces'),
          '$_summaryQty',
        ),
        _summaryRow(
          CatalogStrings.tr('stockValue'),
          CatalogTheme.formatPkr(_summaryValue),
          isMoney: true,
        ),
        _summaryRow(
          CatalogStrings.tr('categoriesSkipped'),
          '${_skipped.length}',
        ),
        _summaryRow(
          CatalogStrings.tr('countedOf'),
          '${_counted.length} / $_totalItems',
        ),
        const SizedBox(height: 24),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () => Navigator.of(context).pop(),
            style: CatalogTheme.primaryButtonStyle,
            child: Text(CatalogStrings.tr('done')),
          ),
        ),
      ],
    );
  }

  Widget _summaryRow(String label, String value, {bool isMoney = false}) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 5),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: CatalogTheme.cardDecoration(),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Text(label, style: CatalogTheme.body),
          Text(
            value,
            style: isMoney
                ? CatalogTheme.monoLarge
                : CatalogTheme.mono.copyWith(color: CatalogTheme.primary),
          ),
        ],
      ),
    );
  }
}
