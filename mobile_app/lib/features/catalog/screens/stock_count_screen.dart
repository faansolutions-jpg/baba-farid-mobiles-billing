import 'dart:async';

import 'package:flutter/material.dart';

import '../catalog_models.dart';
import '../catalog_repository.dart';
import '../catalog_search.dart';
import 'catalog_strings.dart';
import 'catalog_theme.dart';

/// Stock Count — physical audit.
///
/// Lists items with their system stock; the shopkeeper enters the counted
/// quantity per item. Differences are highlighted (green = match, red =
/// shortage, amber = extra). Save calls [recordStockCount] once per
/// changed item (audit-logged) and shows a summary of adjustments.
class StockCountScreen extends StatefulWidget {
  const StockCountScreen({super.key, required this.repository});

  final CatalogRepository repository;

  @override
  State<StockCountScreen> createState() => _StockCountScreenState();
}

class _StockCountScreenState extends State<StockCountScreen> {
  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _noteController = TextEditingController();
  final Map<String, TextEditingController> _countControllers =
      <String, TextEditingController>{};
  Timer? _searchDebounce;

  bool _loading = true;
  bool _saving = false;
  String? _error;

  List<String> _categories = <String>[];
  String? _selectedCategory; // null = all categories
  List<CatalogItem> _allItems = <CatalogItem>[];
  List<CatalogItem>? _searchResults;

  /// Counted quantities, keyed by item id. Only filled when the user
  /// typed a value for that item.
  final Map<String, int> _counted = <String, int>{};

  @override
  void initState() {
    super.initState();
    _loadAll();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _noteController.dispose();
    for (final controller in _countControllers.values) {
      controller.dispose();
    }
    _searchDebounce?.cancel();
    super.dispose();
  }

  Future<void> _loadAll() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final categories = await widget.repository.categories();
      final all = <CatalogItem>[];
      for (final category in categories) {
        all.addAll(await widget.repository.byCategory(category));
      }
      if (!mounted) return;
      setState(() {
        _categories = categories;
        _allItems = all;
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

  TextEditingController _countControllerFor(CatalogItem item) {
    return _countControllers.putIfAbsent(
      item.id,
      () => TextEditingController(),
    );
  }

  void _onCountChanged(CatalogItem item, String value) {
    final trimmed = value.trim();
    setState(() {
      if (trimmed.isEmpty) {
        _counted.remove(item.id);
      } else {
        final parsed = int.tryParse(trimmed);
        if (parsed != null && parsed >= 0) {
          _counted[item.id] = parsed;
        }
      }
    });
  }

  void _onSearchChanged(String value) {
    _searchDebounce?.cancel();
    _searchDebounce = Timer(const Duration(milliseconds: 300), () {
      final query = normalizeQuery(value).trim();
      if (query.length < 2) {
        setState(() => _searchResults = null);
        return;
      }
      setState(() => _searchResults = searchCatalog(_allItems, query));
    });
  }

  List<CatalogItem> get _visibleItems {
    final source = _searchResults ?? _allItems;
    if (_selectedCategory == null) return source;
    return source.where((item) => item.category == _selectedCategory).toList();
  }

  bool get _hasCounted => _counted.isNotEmpty;

  int get _matchedCount => _counted.entries.where((entry) {
        final item = _allItems.where((i) => i.id == entry.key).toList();
        return item.isNotEmpty && item.first.stockQty == entry.value;
      }).length;

  int get _shortageCount => _counted.entries.where((entry) {
        final item = _allItems.where((i) => i.id == entry.key).toList();
        return item.isNotEmpty && entry.value < item.first.stockQty;
      }).length;

  int get _overageCount => _counted.entries.where((entry) {
        final item = _allItems.where((i) => i.id == entry.key).toList();
        return item.isNotEmpty && entry.value > item.first.stockQty;
      }).length;

  int get _changedCount => _shortageCount + _overageCount;

  Future<void> _save() async {
    if (!_hasCounted) {
      _showMessage(CatalogStrings.tr('notCountedYet'), isError: true);
      return;
    }
    if (_changedCount == 0) {
      _showMessage(CatalogStrings.tr('noAdjustments'));
      return;
    }
    final note = _noteController.text.trim();
    final failures = <String>[];
    var saved = 0;
    setState(() => _saving = true);
    // One audit-logged recordStockCount per changed item, in order.
    for (final entry in _counted.entries) {
      final matches = _allItems.where((i) => i.id == entry.key).toList();
      if (matches.isEmpty) continue;
      final item = matches.first;
      if (entry.value == item.stockQty) continue;
      final fullNote = note.isEmpty
          ? 'Physical count: system ${item.stockQty}, counted ${entry.value}'
          : '$note — system ${item.stockQty}, counted ${entry.value}';
      try {
        await widget.repository.recordStockCount(item.id, entry.value, fullNote);
        saved++;
      } catch (e) {
        failures.add(item.nameEn);
      }
    }
    if (!mounted) return;
    final shortage = _shortageCount;
    final overage = _overageCount;
    setState(() => _saving = false);
    await _showSummaryDialog(saved, shortage, overage, failures);
    // Reload so system stock reflects the adjustments just saved.
    _counted.clear();
    for (final controller in _countControllers.values) {
      controller.clear();
    }
    await _loadAll();
  }

  Future<void> _showSummaryDialog(
    int saved,
    int shortage,
    int overage,
    List<String> failures,
  ) async {
    await showDialog<void>(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: CatalogTheme.surface,
          title: Text(
            CatalogStrings.tr('adjustments'),
            style: CatalogTheme.heading,
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                CatalogStrings.trArgs(
                  'adjustmentsSaved',
                  {'count': saved},
                ),
                style: CatalogTheme.body,
              ),
              const SizedBox(height: 10),
              Text(
                '${CatalogStrings.tr('shortage')}: $shortage',
                style: CatalogTheme.body.copyWith(color: CatalogTheme.red),
              ),
              Text(
                '${CatalogStrings.tr('overage')}: $overage',
                style: CatalogTheme.body.copyWith(color: CatalogTheme.amber),
              ),
              if (failures.isNotEmpty) ...<Widget>[
                const SizedBox(height: 10),
                Text(
                  '${CatalogStrings.tr('somethingWentWrong')}: ${failures.join(', ')}',
                  style: CatalogTheme.bodySmall.copyWith(color: CatalogTheme.red),
                ),
              ],
            ],
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                CatalogStrings.tr('done'),
                style: const TextStyle(color: CatalogTheme.primary),
              ),
            ),
          ],
        );
      },
    );
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
      appBar: CatalogTheme.appBar(CatalogStrings.tr('stockCount')),
      body: Column(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 12, 12, 4),
            child: Text(
              CatalogStrings.tr('stockCountSubtitle'),
              style: CatalogTheme.bodySmall,
            ),
          ),
          _buildFilters(),
          if (_hasCounted) _buildCountSummary(),
          Expanded(child: _buildBody()),
          _buildSaveBar(),
        ],
      ),
    );
  }

  Widget _buildFilters() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: Row(
        children: <Widget>[
          Expanded(
            flex: 3,
            child: TextField(
              controller: _searchController,
              onChanged: _onSearchChanged,
              style: CatalogTheme.body,
              decoration: CatalogTheme.inputDecoration(
                hint: CatalogStrings.tr('searchCatalogHint'),
                prefixIcon: const Icon(Icons.search, color: CatalogTheme.muted),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            flex: 2,
            child: DropdownButtonFormField<String>(
              initialValue: _selectedCategory,
              dropdownColor: CatalogTheme.surface,
              style: CatalogTheme.body,
              decoration: CatalogTheme.inputDecoration(
                hint: CatalogStrings.tr('allCategories'),
              ),
              items: <DropdownMenuItem<String>>[
                DropdownMenuItem<String>(
                  child: Text(CatalogStrings.tr('allCategories')),
                ),
                ..._categories.map(
                  (c) => DropdownMenuItem<String>(value: c, child: Text(c)),
                ),
              ],
              onChanged: (value) => setState(() => _selectedCategory = value),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCountSummary() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: CatalogTheme.cardDecoration(
        borderColor: _changedCount > 0
            ? CatalogTheme.amber.withValues(alpha: 0.7)
            : CatalogTheme.primary.withValues(alpha: 0.6),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Text(
            '${CatalogStrings.tr('counted')}: ${_counted.length}',
            style: CatalogTheme.monoSmall.copyWith(color: CatalogTheme.text),
          ),
          Text(
            '${CatalogStrings.tr('matched')}: $_matchedCount',
            style: CatalogTheme.monoSmall.copyWith(color: CatalogTheme.primary),
          ),
          Text(
            '${CatalogStrings.tr('shortage')}: $_shortageCount',
            style: CatalogTheme.monoSmall.copyWith(color: CatalogTheme.red),
          ),
          Text(
            '${CatalogStrings.tr('overage')}: $_overageCount',
            style: CatalogTheme.monoSmall.copyWith(color: CatalogTheme.amber),
          ),
        ],
      ),
    );
  }

  Widget _buildBody() {
    if (_loading) return CatalogTheme.loadingView(CatalogStrings.tr('loading'));
    if (_error != null) {
      return CatalogTheme.errorView(
        CatalogStrings.tr('somethingWentWrong'),
        _loadAll,
      );
    }
    final items = _visibleItems;
    if (items.isEmpty) {
      return CatalogTheme.emptyView(
        CatalogStrings.tr('noItemsFound'),
        CatalogStrings.tr('tryDifferentSearch'),
      );
    }
    return ListView.builder(
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        final counted = _counted[item.id];
        final diff = counted == null ? null : counted - item.stockQty;
        final Color edge;
        final Widget diffChip;
        if (diff == null) {
          edge = CatalogTheme.border;
          diffChip = Text(
            CatalogStrings.tr('notCountedYet'),
            style: CatalogTheme.monoSmall,
          );
        } else if (diff == 0) {
          edge = CatalogTheme.primary;
          diffChip = _diffBadge('✓ 0', CatalogTheme.primary);
        } else if (diff < 0) {
          edge = CatalogTheme.red;
          diffChip = _diffBadge('$diff', CatalogTheme.red);
        } else {
          edge = CatalogTheme.amber;
          diffChip = _diffBadge('+$diff', CatalogTheme.amber);
        }
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: CatalogTheme.cardDecoration(borderColor: edge),
          child: Row(
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
                    Text('${item.brand}  •  ${item.sku}', style: CatalogTheme.monoSmall),
                    const SizedBox(height: 6),
                    Row(
                      children: <Widget>[
                        Text(
                          '${CatalogStrings.tr('systemStock')}: ',
                          style: CatalogTheme.bodySmall,
                        ),
                        Text('${item.stockQty}', style: CatalogTheme.mono),
                        const SizedBox(width: 12),
                        diffChip,
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              SizedBox(
                width: 96,
                height: 52,
                child: TextField(
                  controller: _countControllerFor(item),
                  keyboardType: TextInputType.number,
                  textAlign: TextAlign.center,
                  style: CatalogTheme.monoLarge,
                  onChanged: (value) => _onCountChanged(item, value),
                  decoration: CatalogTheme.inputDecoration(hint: '—'),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _diffBadge(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color),
      ),
      child: Text(
        label,
        style: CatalogTheme.mono.copyWith(fontSize: 12, color: color),
      ),
    );
  }

  Widget _buildSaveBar() {
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 16),
      decoration: const BoxDecoration(
        color: CatalogTheme.surface,
        border: Border(top: BorderSide(color: CatalogTheme.border)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          TextField(
            controller: _noteController,
            style: CatalogTheme.body,
            decoration: CatalogTheme.inputDecoration(
              hint: CatalogStrings.tr('countNoteHint'),
            ),
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
                  : Text(
                      '${CatalogStrings.tr('saveAdjustments')}  •  '
                      '$_changedCount ${CatalogStrings.tr('adjustments')}',
                    ),
            ),
          ),
        ],
      ),
    );
  }
}
