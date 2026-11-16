import 'dart:async';

import 'package:flutter/material.dart';

import '../catalog_models.dart';
import '../catalog_repository.dart';
import '../catalog_search.dart';
import 'catalog_strings.dart';
import 'catalog_theme.dart';
import 'quick_stock_in_screen.dart';

/// Category > Brand > Item drill-down browser for the accessories catalog.
///
/// Big touch-friendly tiles, a search bar (fuzzy / Roman-Urdu tolerant via
/// [searchCatalog]), and a zero-stock toggle — zero-stock items are hidden
/// by default. Tapping an item opens [QuickStockInScreen] for it; when
/// [onItemSelected] is given it is called instead of navigating (so the
/// browser can be embedded in other flows).
class CatalogBrowserScreen extends StatefulWidget {
  const CatalogBrowserScreen({
    super.key,
    required this.repository,
    this.onItemSelected,
  });

  final CatalogRepository repository;

  /// Optional tap handler. When null, tapping opens Quick Stock-In.
  final void Function(CatalogItem item)? onItemSelected;

  @override
  State<CatalogBrowserScreen> createState() => _CatalogBrowserScreenState();
}

class _CatalogBrowserScreenState extends State<CatalogBrowserScreen> {
  final TextEditingController _searchController = TextEditingController();
  Timer? _searchDebounce;

  bool _loading = true;
  String? _error;
  List<String> _categories = <String>[];
  String? _selectedCategory;
  List<String> _brands = <String>[];
  String? _selectedBrand;
  List<CatalogItem> _items = <CatalogItem>[];

  bool _showZeroStock = false;
  bool _searching = false;
  List<CatalogItem>? _searchResults;

  // Full catalog, loaded lazily once, so search runs over everything.
  List<CatalogItem> _allItems = <CatalogItem>[];
  bool _allItemsLoaded = false;

  @override
  void initState() {
    super.initState();
    _loadCategories();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchDebounce?.cancel();
    super.dispose();
  }

  Future<void> _loadCategories() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final categories = await widget.repository.categories();
      if (!mounted) return;
      setState(() {
        _categories = categories;
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

  Future<void> _selectCategory(String category) async {
    setState(() {
      _selectedCategory = category;
      _selectedBrand = null;
      _brands = <String>[];
      _items = <CatalogItem>[];
      _loading = true;
      _error = null;
    });
    try {
      final results = await Future.wait(<Future<Object>>[
        widget.repository.brands(category),
        widget.repository.byCategory(category),
      ]);
      if (!mounted) return;
      setState(() {
        _brands = (results[0] as List<String>);
        _items = (results[1] as List<CatalogItem>);
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

  Future<void> _selectBrand(String brand) async {
    final category = _selectedCategory;
    if (category == null) return;
    setState(() {
      _selectedBrand = brand;
      _loading = true;
      _error = null;
    });
    try {
      final items = await widget.repository.byBrand(category, brand);
      if (!mounted) return;
      setState(() {
        _items = items;
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

  void _clearDrillDown() {
    setState(() {
      _selectedCategory = null;
      _selectedBrand = null;
      _brands = <String>[];
      _items = <CatalogItem>[];
    });
  }

  Future<void> _ensureAllItems() async {
    if (_allItemsLoaded) return;
    final categories = _categories.isNotEmpty
        ? _categories
        : await widget.repository.categories();
    final all = <CatalogItem>[];
    for (final category in categories) {
      all.addAll(await widget.repository.byCategory(category));
    }
    _allItems = all;
    _allItemsLoaded = true;
  }

  void _onSearchChanged(String value) {
    _searchDebounce?.cancel();
    setState(() {});
    _searchDebounce = Timer(const Duration(milliseconds: 300), () {
      _runSearch(value);
    });
  }

  Future<void> _runSearch(String rawQuery) async {
    final query = normalizeQuery(rawQuery).trim();
    if (query.length < 2) {
      setState(() {
        _searchResults = null;
        _searching = false;
      });
      return;
    }
    setState(() => _searching = true);
    try {
      await _ensureAllItems();
      final results = searchCatalog(_allItems, query);
      if (!mounted) return;
      setState(() {
        _searchResults = results;
        _searching = false;
      });
    } catch (_) {
      // Local index failed — fall back to the repository search.
      try {
        final results = await widget.repository.search(query);
        if (!mounted) return;
        setState(() {
          _searchResults = results;
          _searching = false;
        });
      } catch (e) {
        if (!mounted) return;
        setState(() => _searching = false);
        _showMessage(CatalogStrings.tr('searchFailed'), isError: true);
      }
    }
  }

  List<CatalogItem> get _visibleItems {
    final source = _searchResults ?? _items;
    if (_showZeroStock) return source;
    return source.where((item) => item.stockQty > 0).toList();
  }

  bool get _isSearching =>
      normalizeQuery(_searchController.text).trim().length >= 2;

  void _onItemTap(CatalogItem item) {
    if (widget.onItemSelected != null) {
      widget.onItemSelected!(item);
      return;
    }
    Navigator.of(context)
        .push(
          MaterialPageRoute<void>(
            builder: (_) => QuickStockInScreen(
              repository: widget.repository,
              initialItem: item,
            ),
          ),
        )
        .then((_) => _refreshCurrentList());
  }

  Future<void> _refreshCurrentList() async {
    // Stock may have changed while stocking in — reload the current view.
    if (_isSearching) {
      await _runSearch(_searchController.text);
      return;
    }
    if (_selectedBrand != null) {
      await _selectBrand(_selectedBrand!);
    } else if (_selectedCategory != null) {
      await _selectCategory(_selectedCategory!);
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
      appBar: CatalogTheme.appBar(CatalogStrings.tr('catalogBrowser')),
      body: Column(
        children: <Widget>[
          _buildSearchBar(),
          _buildZeroStockToggle(),
          if (_selectedCategory != null) _buildBreadcrumbs(),
          Expanded(child: _buildBody()),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 4),
      child: TextField(
        controller: _searchController,
        onChanged: _onSearchChanged,
        style: CatalogTheme.body,
        decoration: CatalogTheme.inputDecoration(
          hint: CatalogStrings.tr('searchCatalogHint'),
          prefixIcon: const Icon(Icons.search, color: CatalogTheme.muted),
          suffixIcon: _searchController.text.isEmpty
              ? null
              : IconButton(
                  icon: const Icon(Icons.clear, color: CatalogTheme.muted),
                  onPressed: () {
                    _searchController.clear();
                    _runSearch('');
                    setState(() {});
                  },
                ),
        ),
      ),
    );
  }

  Widget _buildZeroStockToggle() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
      child: Row(
        children: <Widget>[
          Expanded(
            child: Text(
              CatalogStrings.tr('showZeroStock'),
              style: CatalogTheme.bodySmall,
            ),
          ),
          Switch(
            value: _showZeroStock,
            activeThumbColor: CatalogTheme.primary,
            onChanged: (value) => setState(() => _showZeroStock = value),
          ),
        ],
      ),
    );
  }

  Widget _buildBreadcrumbs() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: Row(
        children: <Widget>[
          _crumb(CatalogStrings.tr('allCategories'), _clearDrillDown),
          if (_selectedCategory != null) ...<Widget>[
            const Icon(Icons.chevron_right, color: CatalogTheme.muted, size: 18),
            _crumb(
              _selectedCategory!,
              () => _selectCategory(_selectedCategory!),
            ),
          ],
          if (_selectedBrand != null) ...<Widget>[
            const Icon(Icons.chevron_right, color: CatalogTheme.muted, size: 18),
            _crumb(_selectedBrand!, null),
          ],
        ],
      ),
    );
  }

  Widget _crumb(String label, VoidCallback? onTap) {
    final chip = Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: CatalogTheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: CatalogTheme.primary.withValues(alpha: 0.5)),
      ),
      child: Text(label, style: CatalogTheme.monoSmall.copyWith(color: CatalogTheme.primary)),
    );
    if (onTap == null) return chip;
    return InkWell(onTap: onTap, borderRadius: BorderRadius.circular(16), child: chip);
  }

  Widget _buildBody() {
    if (_loading) return CatalogTheme.loadingView(CatalogStrings.tr('loading'));
    if (_error != null) {
      return CatalogTheme.errorView(
        CatalogStrings.tr('somethingWentWrong'),
        _selectedCategory == null ? _loadCategories : () => _selectCategory(_selectedCategory!),
      );
    }
    if (_isSearching) {
      if (_searching) return CatalogTheme.loadingView();
      final results = _visibleItems;
      if (results.isEmpty) {
        return CatalogTheme.emptyView(
          CatalogStrings.tr('noItemsFound'),
          CatalogStrings.tr('tryDifferentSearch'),
        );
      }
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: Text(
              '${results.length} ${CatalogStrings.tr('search')}',
              style: CatalogTheme.monoSmall,
            ),
          ),
          Expanded(child: _buildItemList(results)),
        ],
      );
    }
    // Drill-down: categories -> brands -> items.
    if (_selectedCategory == null) return _buildCategoryGrid();
    if (_selectedBrand == null && _brands.isNotEmpty) return _buildBrandGrid();
    final items = _visibleItems;
    if (items.isEmpty) {
      return CatalogTheme.emptyView(
        CatalogStrings.tr('noItemsInCategory'),
        CatalogStrings.tr('tapToStockIn'),
      );
    }
    return _buildItemList(items);
  }

  Widget _buildCategoryGrid() {
    if (_categories.isEmpty) {
      return CatalogTheme.emptyView(CatalogStrings.tr('noCategories'));
    }
    return GridView.builder(
      padding: const EdgeInsets.all(12),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: 1.6,
      ),
      itemCount: _categories.length,
      itemBuilder: (context, index) {
        final category = _categories[index];
        return _buildTile(
          label: category,
          icon: Icons.category_outlined,
          onTap: () => _selectCategory(category),
        );
      },
    );
  }

  Widget _buildBrandGrid() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        CatalogTheme.sectionHeader(
          CatalogStrings.tr('brandsInCategory'),
          subtitle: _selectedCategory,
        ),
        Expanded(
          child: GridView.builder(
            padding: const EdgeInsets.all(12),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 1.6,
            ),
            itemCount: _brands.length,
            itemBuilder: (context, index) {
              final brand = _brands[index];
              return _buildTile(
                label: brand,
                icon: Icons.label_outline,
                onTap: () => _selectBrand(brand),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildTile({
    required String label,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return Container(
      decoration: CatalogTheme.cardDecoration(glow: false),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Icon(icon, color: CatalogTheme.primary, size: 28),
                const SizedBox(height: 10),
                Text(
                  label,
                  style: CatalogTheme.heading,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                const Icon(Icons.arrow_forward, color: CatalogTheme.muted, size: 18),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildItemList(List<CatalogItem> items) {
    return ListView.builder(
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        return CatalogTheme.itemTile(
          item,
          onTap: () => _onItemTap(item),
        );
      },
    );
  }
}
