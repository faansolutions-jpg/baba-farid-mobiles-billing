import 'package:flutter/material.dart';

import '../catalog_models.dart';
import '../catalog_repository.dart';
import 'catalog_strings.dart';
import 'catalog_theme.dart';
import 'quick_stock_in_screen.dart';

const String _newCategoryValue = '__new_category__';
const String _newBrandValue = '__new_brand__';

/// Add Custom Item.
///
/// Creates a catalog item that is not in the pre-loaded list, in about
/// 10 seconds: name, category, brand, prices, unit. The item joins the
/// catalog via [addCustomItem] for future use. Category / brand pickers
/// offer the existing values plus a "new..." option with a free-text field.
class AddCustomItemScreen extends StatefulWidget {
  const AddCustomItemScreen({super.key, required this.repository});

  final CatalogRepository repository;

  @override
  State<AddCustomItemScreen> createState() => _AddCustomItemScreenState();
}

class _AddCustomItemScreenState extends State<AddCustomItemScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _nameEnController = TextEditingController();
  final TextEditingController _nameUrController = TextEditingController();
  final TextEditingController _newCategoryController = TextEditingController();
  final TextEditingController _newBrandController = TextEditingController();
  final TextEditingController _buyPriceController = TextEditingController();
  final TextEditingController _salePriceController = TextEditingController();
  final TextEditingController _minPriceController = TextEditingController();
  final TextEditingController _thresholdController =
      TextEditingController(text: '5');
  final TextEditingController _colorsController = TextEditingController();
  final TextEditingController _variantsController = TextEditingController();
  final TextEditingController _modelsController = TextEditingController();
  final TextEditingController _barcodeController = TextEditingController();

  bool _loading = true;
  bool _saving = false;
  String? _error;

  List<String> _categories = <String>[];
  String? _selectedCategory;
  List<String> _brands = <String>[];
  String? _selectedBrand;
  String _unit = 'pcs';

  CatalogItem? _createdItem;

  static const List<String> _units = <String>[
    'pcs',
    'box',
    'pack',
    'pair',
    'set',
    'meter',
  ];

  @override
  void initState() {
    super.initState();
    _loadCategories();
  }

  @override
  void dispose() {
    _nameEnController.dispose();
    _nameUrController.dispose();
    _newCategoryController.dispose();
    _newBrandController.dispose();
    _buyPriceController.dispose();
    _salePriceController.dispose();
    _minPriceController.dispose();
    _thresholdController.dispose();
    _colorsController.dispose();
    _variantsController.dispose();
    _modelsController.dispose();
    _barcodeController.dispose();
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

  Future<void> _onCategoryChanged(String? value) async {
    setState(() {
      _selectedCategory = value;
      _selectedBrand = null;
      _brands = <String>[];
    });
    if (value == null || value == _newCategoryValue) return;
    try {
      final brands = await widget.repository.brands(value);
      if (!mounted) return;
      setState(() => _brands = brands);
    } catch (e) {
      if (!mounted) return;
      _showMessage('${CatalogStrings.tr('somethingWentWrong')} ($e)',
          isError: true);
    }
  }

  String _resolvedCategory() {
    if (_selectedCategory == _newCategoryValue) {
      return _newCategoryController.text.trim();
    }
    return _selectedCategory ?? '';
  }

  String _resolvedBrand() {
    if (_selectedBrand == _newBrandValue) {
      return _newBrandController.text.trim();
    }
    return _selectedBrand ?? '';
  }

  List<String> _splitList(String raw) {
    return raw
        .split(',')
        .map((part) => part.trim())
        .where((part) => part.isNotEmpty)
        .toList();
  }

  /// SKU for a custom item: CUS-<category prefix>-<time suffix>.
  /// id == sku for catalog items.
  String _generateSku(String category) {
    final letters = category
        .replaceAll(RegExp(r'[^A-Za-z]'), '')
        .toUpperCase();
    final prefix = (letters.length >= 3
            ? letters.substring(0, 3)
            : letters.padRight(3, 'X'))
        .toUpperCase();
    final suffix = DateTime.now()
        .millisecondsSinceEpoch
        .toString()
        .substring(7);
    return 'CUS-$prefix-$suffix';
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    final category = _resolvedCategory();
    final brand = _resolvedBrand();
    if (category.isEmpty || brand.isEmpty) {
      _showMessage(CatalogStrings.tr('fieldRequired'), isError: true);
      return;
    }
    final buyPrice = int.tryParse(_buyPriceController.text.trim()) ?? 0;
    final salePrice = int.tryParse(_salePriceController.text.trim()) ?? 0;
    if (salePrice <= 0) {
      _showMessage(CatalogStrings.tr('salePriceRequired'), isError: true);
      return;
    }
    final minPriceText = _minPriceController.text.trim();
    final minPrice =
        minPriceText.isEmpty ? buyPrice : (int.tryParse(minPriceText) ?? buyPrice);
    if (minPrice > salePrice) {
      _showMessage(CatalogStrings.tr('minAboveSale'), isError: true);
      return;
    }
    final threshold = int.tryParse(_thresholdController.text.trim()) ?? 5;
    final barcode = _barcodeController.text.trim();
    final models = _modelsController.text.trim();
    final sku = _generateSku(category);

    final item = CatalogItem(
      sku: sku,
      category: category,
      brand: brand,
      nameEn: _nameEnController.text.trim(),
      nameUr: _nameUrController.text.trim(),
      modelCompatibility: models.isEmpty ? null : models,
      colors: _splitList(_colorsController.text),
      variants: _splitList(_variantsController.text),
      purchasePriceEst: buyPrice,
      salePriceEst: salePrice,
      minPrice: minPrice,
      unit: _unit,
      barcode: barcode.isEmpty ? null : barcode,
      isCustom: true,
      stockQty: 0,
      lowStockThreshold: threshold < 0 ? 0 : threshold,
    );

    setState(() => _saving = true);
    try {
      await widget.repository.addCustomItem(item);
      if (!mounted) return;
      setState(() {
        _saving = false;
        _createdItem = item;
      });
      _showMessage(CatalogStrings.tr('itemCreated'));
    } catch (e) {
      if (!mounted) return;
      setState(() => _saving = false);
      _showMessage('${CatalogStrings.tr('somethingWentWrong')} ($e)',
          isError: true);
    }
  }

  void _resetForm() {
    _formKey.currentState?.reset();
    for (final controller in <TextEditingController>[
      _nameEnController,
      _nameUrController,
      _newCategoryController,
      _newBrandController,
      _buyPriceController,
      _salePriceController,
      _minPriceController,
      _colorsController,
      _variantsController,
      _modelsController,
      _barcodeController,
    ]) {
      controller.clear();
    }
    _thresholdController.text = '5';
    setState(() {
      _selectedCategory = null;
      _selectedBrand = null;
      _brands = <String>[];
      _unit = 'pcs';
      _createdItem = null;
    });
  }

  void _showMessage(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? CatalogTheme.red : CatalogTheme.surface,
      ),
    );
  }

  String? _required(String? value) {
    if (value == null || value.trim().isEmpty) {
      return CatalogStrings.tr('requiredField');
    }
    return null;
  }

  String? _wholeNumber(String? value, {bool required = false}) {
    if (value == null || value.trim().isEmpty) {
      return required ? CatalogStrings.tr('requiredField') : null;
    }
    final parsed = int.tryParse(value.trim());
    if (parsed == null || parsed < 0) {
      return CatalogStrings.tr('invalidNumber');
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: CatalogTheme.background,
      appBar: CatalogTheme.appBar(CatalogStrings.tr('addCustomItem')),
      body: _loading
          ? CatalogTheme.loadingView(CatalogStrings.tr('loading'))
          : _error != null
              ? CatalogTheme.errorView(
                  CatalogStrings.tr('somethingWentWrong'),
                  _loadCategories,
                )
              : _createdItem != null
                  ? _buildSuccess()
                  : _buildForm(),
    );
  }

  Widget _buildForm() {
    return Form(
      key: _formKey,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(12, 12, 12, 24),
        children: <Widget>[
          Text(
            CatalogStrings.tr('customItemSubtitle'),
            style: CatalogTheme.bodySmall,
          ),
          const SizedBox(height: 14),
          TextFormField(
            controller: _nameEnController,
            style: CatalogTheme.body,
            textCapitalization: TextCapitalization.words,
            validator: _required,
            decoration: CatalogTheme.inputDecoration(
              hint: CatalogStrings.tr('itemNameEnHint'),
            ),
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _nameUrController,
            style: CatalogTheme.urduLarge,
            textDirection: TextDirection.rtl,
            decoration: CatalogTheme.inputDecoration(
              hint: CatalogStrings.tr('itemNameUr'),
            ),
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<String>(
            initialValue: _selectedCategory,
            dropdownColor: CatalogTheme.surface,
            style: CatalogTheme.body,
            validator: (value) =>
                value == null ? CatalogStrings.tr('requiredField') : null,
            decoration: CatalogTheme.inputDecoration(
              hint: CatalogStrings.tr('category'),
            ),
            items: <DropdownMenuItem<String>>[
              ..._categories.map(
                (c) => DropdownMenuItem<String>(value: c, child: Text(c)),
              ),
              DropdownMenuItem<String>(
                value: _newCategoryValue,
                child: Text(CatalogStrings.tr('newCategory')),
              ),
            ],
            onChanged: _onCategoryChanged,
          ),
          if (_selectedCategory == _newCategoryValue) ...<Widget>[
            const SizedBox(height: 12),
            TextFormField(
              controller: _newCategoryController,
              style: CatalogTheme.body,
              validator: _required,
              decoration: CatalogTheme.inputDecoration(
                hint: CatalogStrings.tr('newCategoryName'),
              ),
            ),
          ],
          const SizedBox(height: 12),
          DropdownButtonFormField<String>(
            initialValue: _selectedBrand,
            dropdownColor: CatalogTheme.surface,
            style: CatalogTheme.body,
            validator: (value) =>
                value == null ? CatalogStrings.tr('requiredField') : null,
            decoration: CatalogTheme.inputDecoration(
              hint: CatalogStrings.tr('brand'),
            ),
            items: <DropdownMenuItem<String>>[
              ..._brands.map(
                (b) => DropdownMenuItem<String>(value: b, child: Text(b)),
              ),
              DropdownMenuItem<String>(
                value: _newBrandValue,
                child: Text(CatalogStrings.tr('newBrand')),
              ),
            ],
            onChanged: (value) => setState(() => _selectedBrand = value),
          ),
          if (_selectedBrand == _newBrandValue) ...<Widget>[
            const SizedBox(height: 12),
            TextFormField(
              controller: _newBrandController,
              style: CatalogTheme.body,
              validator: _required,
              decoration: CatalogTheme.inputDecoration(
                hint: CatalogStrings.tr('newBrandName'),
              ),
            ),
          ],
          const SizedBox(height: 12),
          Row(
            children: <Widget>[
              Expanded(
                child: TextFormField(
                  controller: _buyPriceController,
                  keyboardType: TextInputType.number,
                  style: CatalogTheme.mono,
                  validator: (value) => _wholeNumber(value, required: true),
                  decoration: CatalogTheme.inputDecoration(
                    hint: CatalogStrings.tr('buyPrice'),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: TextFormField(
                  controller: _salePriceController,
                  keyboardType: TextInputType.number,
                  style: CatalogTheme.mono,
                  validator: (value) => _wholeNumber(value, required: true),
                  decoration: CatalogTheme.inputDecoration(
                    hint: CatalogStrings.tr('salePrice'),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: <Widget>[
              Expanded(
                child: TextFormField(
                  controller: _minPriceController,
                  keyboardType: TextInputType.number,
                  style: CatalogTheme.mono,
                  validator: _wholeNumber,
                  decoration: CatalogTheme.inputDecoration(
                    hint:
                        '${CatalogStrings.tr('minPrice')} (${CatalogStrings.tr('optional')})',
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: DropdownButtonFormField<String>(
                  initialValue: _unit,
                  dropdownColor: CatalogTheme.surface,
                  style: CatalogTheme.body,
                  decoration: CatalogTheme.inputDecoration(
                    hint: CatalogStrings.tr('unit'),
                  ),
                  items: _units
                      .map(
                        (u) => DropdownMenuItem<String>(
                          value: u,
                          child: Text(_unitLabel(u)),
                        ),
                      )
                      .toList(),
                  onChanged: (value) {
                    if (value != null) setState(() => _unit = value);
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _thresholdController,
            keyboardType: TextInputType.number,
            style: CatalogTheme.mono,
            validator: _wholeNumber,
            decoration: CatalogTheme.inputDecoration(
              hint: CatalogStrings.tr('lowStockThreshold'),
            ),
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _colorsController,
            style: CatalogTheme.body,
            decoration: CatalogTheme.inputDecoration(
              hint: CatalogStrings.tr('colorsHint'),
            ),
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _variantsController,
            style: CatalogTheme.body,
            decoration: CatalogTheme.inputDecoration(
              hint: CatalogStrings.tr('variantsHint'),
            ),
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _modelsController,
            style: CatalogTheme.body,
            decoration: CatalogTheme.inputDecoration(
              hint: CatalogStrings.tr('modelCompatibilityHint'),
            ),
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _barcodeController,
            keyboardType: TextInputType.number,
            style: CatalogTheme.mono,
            decoration: CatalogTheme.inputDecoration(
              hint: CatalogStrings.tr('barcode'),
            ),
          ),
          const SizedBox(height: 20),
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
                  : Text(CatalogStrings.tr('createItem')),
            ),
          ),
        ],
      ),
    );
  }

  String _unitLabel(String unit) {
    switch (unit) {
      case 'box':
        return CatalogStrings.tr('unitBox');
      case 'pack':
        return CatalogStrings.tr('unitPack');
      case 'pair':
        return CatalogStrings.tr('unitPair');
      case 'set':
        return CatalogStrings.tr('unitSet');
      case 'meter':
        return CatalogStrings.tr('unitMeter');
      case 'pcs':
      default:
        return CatalogStrings.tr('unitPieces');
    }
  }

  Widget _buildSuccess() {
    final item = _createdItem!;
    return ListView(
      padding: const EdgeInsets.all(16),
      children: <Widget>[
        const Icon(Icons.check_circle, color: CatalogTheme.primary, size: 56),
        const SizedBox(height: 12),
        Text(
          CatalogStrings.tr('itemCreated'),
          style: CatalogTheme.heading,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 20),
        CatalogTheme.itemTile(item, onTap: () {}),
        const SizedBox(height: 20),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => QuickStockInScreen(
                    repository: widget.repository,
                    initialItem: item,
                  ),
                ),
              );
            },
            style: CatalogTheme.primaryButtonStyle,
            child: Text(CatalogStrings.tr('addStockNow')),
          ),
        ),
        const SizedBox(height: 10),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton(
            onPressed: _resetForm,
            style: CatalogTheme.ghostButtonStyle,
            child: Text(CatalogStrings.tr('addAnother')),
          ),
        ),
      ],
    );
  }
}
