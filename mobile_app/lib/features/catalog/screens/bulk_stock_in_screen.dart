import 'package:flutter/material.dart';

import '../catalog_models.dart';
import '../catalog_repository.dart';
import 'catalog_strings.dart';
import 'catalog_theme.dart';

/// Bulk Stock-In.
///
/// Pick a category (and optionally a brand); the whole category is shown
/// as a list with a quantity box next to EACH item. Fill quantities and
/// press Save — one atomic [bulkStockIn] call. Progress shows
/// filled/total. Optional buying price + supplier apply to the whole batch.
class BulkStockInScreen extends StatefulWidget {
  const BulkStockInScreen({super.key, required this.repository});

  final CatalogRepository repository;

  @override
  State<BulkStockInScreen> createState() => _BulkStockInScreenState();
}

class _BulkStockInScreenState extends State<BulkStockInScreen> {
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _supplierController = TextEditingController();
  final Map<String, TextEditingController> _qtyControllers =
      <String, TextEditingController>{};

  bool _loading = true;
  bool _saving = false;
  String? _error;
  List<String> _categories = <String>[];
  String? _selectedCategory;
  List<String> _brands = <String>[];
  String? _selectedBrand; // null = all brands in the category
  List<CatalogItem> _items = <CatalogItem>[];

  @override
  void initState() {
    super.initState();
    _loadCategories();
  }

  @override
  void dispose() {
    _priceController.dispose();
    _supplierController.dispose();
    _disposeQtyControllers();
    super.dispose();
  }

  void _disposeQtyControllers() {
    for (final controller in _qtyControllers.values) {
      controller.dispose();
    }
    _qtyControllers.clear();
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

  Future<void> _selectCategory(String? category) async {
    _disposeQtyControllers();
    setState(() {
      _selectedCategory = category;
      _selectedBrand = null;
      _brands = <String>[];
      _items = <CatalogItem>[];
    });
    if (category == null) return;
    setState(() => _loading = true);
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

  Future<void> _selectBrand(String? brand) async {
    final category = _selectedCategory;
    if (category == null) return;
    _disposeQtyControllers();
    setState(() {
      _selectedBrand = brand;
      _loading = true;
      _error = null;
    });
    try {
      final items = brand == null
          ? await widget.repository.byCategory(category)
          : await widget.repository.byBrand(category, brand);
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

  int get _filledCount =>
      _items.where((item) => _qtyOf(item) > 0).length;

  int get _totalQty =>
      _items.fold<int>(0, (sum, item) => sum + _qtyOf(item));

  Future<void> _save() async {
    final quantities = <String, int>{
      for (final item in _items)
        if (_qtyOf(item) > 0) item.id: _qtyOf(item),
    };
    if (quantities.isEmpty) {
      _showMessage(CatalogStrings.tr('nothingToSave'), isError: true);
      return;
    }
    final price = int.tryParse(_priceController.text.trim());
    if (price != null && price < 0) {
      _showMessage(CatalogStrings.tr('invalidNumber'), isError: true);
      return;
    }
    final supplier = _supplierController.text.trim();
    setState(() => _saving = true);
    try {
      await widget.repository.bulkStockIn(
        quantities,
        price: price,
        supplier: supplier.isEmpty ? null : supplier,
        date: DateTime.now(),
      );
      if (!mounted) return;
      final count = quantities.length;
      _disposeQtyControllers();
      setState(() => _saving = false);
      _showMessage(CatalogStrings.trArgs('bulkSaved', {'count': count}));
      // Reload so the new stock quantities show immediately.
      await _selectBrand(_selectedBrand);
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
      appBar: CatalogTheme.appBar(CatalogStrings.tr('bulkStockIn')),
      body: Column(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 12, 12, 4),
            child: Text(
              CatalogStrings.tr('bulkStockInSubtitle'),
              style: CatalogTheme.bodySmall,
            ),
          ),
          _buildPickers(),
          if (_selectedCategory != null) _buildProgress(),
          Expanded(child: _buildBody()),
          if (_selectedCategory != null) _buildSaveBar(),
        ],
      ),
    );
  }

  Widget _buildPickers() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: Row(
        children: <Widget>[
          Expanded(
            child: DropdownButtonFormField<String>(
              initialValue: _selectedCategory,
              dropdownColor: CatalogTheme.surface,
              style: CatalogTheme.body,
              decoration: CatalogTheme.inputDecoration(
                hint: CatalogStrings.tr('pickCategory'),
              ),
              items: _categories
                  .map(
                    (c) => DropdownMenuItem<String>(value: c, child: Text(c)),
                  )
                  .toList(),
              onChanged: _selectCategory,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: DropdownButtonFormField<String>(
              initialValue: _selectedBrand,
              dropdownColor: CatalogTheme.surface,
              style: CatalogTheme.body,
              decoration: CatalogTheme.inputDecoration(
                hint: CatalogStrings.tr('pickBrand'),
              ),
              items: <DropdownMenuItem<String>>[
                DropdownMenuItem<String>(
                  child: Text(CatalogStrings.tr('allBrandsOption')),
                ),
                ..._brands.map(
                  (b) => DropdownMenuItem<String>(value: b, child: Text(b)),
                ),
              ],
              onChanged: _selectedCategory == null ? null : _selectBrand,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgress() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: CatalogTheme.progressBar(
        _filledCount,
        _items.length,
        label:
            '${CatalogStrings.tr('filled')}: $_filledCount  •  ${CatalogStrings.tr('totalQty')}: $_totalQty',
      ),
    );
  }

  Widget _buildBody() {
    if (_loading) return CatalogTheme.loadingView(CatalogStrings.tr('loading'));
    if (_error != null) {
      return CatalogTheme.errorView(
        CatalogStrings.tr('somethingWentWrong'),
        _loadCategories,
      );
    }
    if (_selectedCategory == null) {
      return CatalogTheme.emptyView(
        CatalogStrings.tr('pickCategory'),
        CatalogStrings.tr('bulkStockInSubtitle'),
      );
    }
    if (_items.isEmpty) {
      return CatalogTheme.emptyView(CatalogStrings.tr('noItemsInCategory'));
    }
    return ListView.builder(
      itemCount: _items.length,
      itemBuilder: (context, index) {
        final item = _items[index];
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: CatalogTheme.cardDecoration(),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      item.nameEn,
                      style: CatalogTheme.body.copyWith(fontWeight: FontWeight.w600),
                    ),
                    if (item.nameUr.isNotEmpty)
                      Text(item.nameUr, style: CatalogTheme.urdu),
                    const SizedBox(height: 4),
                    Text(
                      '${item.brand}  •  ${item.sku}',
                      style: CatalogTheme.monoSmall,
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: <Widget>[
                        Text(
                          CatalogTheme.formatPkr(item.salePriceEst),
                          style: CatalogTheme.price,
                        ),
                        const SizedBox(width: 10),
                        CatalogTheme.stockChip(item),
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
                  controller: _qtyControllerFor(item),
                  keyboardType: TextInputType.number,
                  textAlign: TextAlign.center,
                  style: CatalogTheme.monoLarge,
                  onChanged: (_) => setState(() {}),
                  decoration: CatalogTheme.inputDecoration(
                    hint: '0',
                  ),
                ),
              ),
            ],
          ),
        );
      },
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
          Row(
            children: <Widget>[
              Expanded(
                child: TextField(
                  controller: _priceController,
                  keyboardType: TextInputType.number,
                  style: CatalogTheme.mono,
                  decoration: CatalogTheme.inputDecoration(
                    hint: CatalogStrings.tr('buyPrice'),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: TextField(
                  controller: _supplierController,
                  style: CatalogTheme.body,
                  decoration: CatalogTheme.inputDecoration(
                    hint: CatalogStrings.tr('supplierHint'),
                  ),
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
                  : Text(
                      '${CatalogStrings.tr('saveAll')}  •  '
                      '$_filledCount/${_items.length}  •  $_totalQty pcs',
                    ),
            ),
          ),
        ],
      ),
    );
  }
}
