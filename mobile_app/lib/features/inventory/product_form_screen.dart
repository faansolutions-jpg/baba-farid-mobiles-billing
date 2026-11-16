library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/config/constants.dart';
import '../../core/l10n/app_strings.dart';
import '../../core/theme/app_theme.dart';
import '../../core/theme/cyber_colors.dart';
import '../../core/theme/cyber_text_styles.dart';
import '../../core/theme/cyber_widgets.dart';
import '../../domain/models/brand.dart';
import '../../domain/models/category.dart';
import '../../domain/models/imei_item.dart';
import '../../domain/models/product.dart';
import '../../domain/models/product_variant.dart';
import '../../domain/rules.dart';
import '../auth/auth_state.dart';
import '../../core/providers/app_providers.dart';

/// Editable state for one variant row in the form.
class _VariantDraft {
  _VariantDraft({ProductVariant? existing})
      : id = existing?.id,
        condition = existing?.condition ?? 'new',
        ptaStatus = existing?.ptaStatus ?? 'not_applicable',
        name = TextEditingController(text: existing?.name ?? ''),
        color = TextEditingController(text: existing?.color ?? ''),
        storageGb = TextEditingController(
          text: existing?.storageGb?.toString() ?? '',
        ),
        ramGb = TextEditingController(
          text: existing?.ramGb?.toString() ?? '',
        ),
        barcode = TextEditingController(text: existing?.barcode ?? ''),
        purchasePrice = TextEditingController(
          text: existing == null ? '' : '${existing.purchasePrice}',
        ),
        salePrice = TextEditingController(
          text: existing == null ? '' : '${existing.salePrice}',
        ),
        minPrice = TextEditingController(
          text: existing == null ? '' : '${existing.minPrice}',
        ),
        warrantyMonths = TextEditingController(
          text: existing == null
              ? ''
              : '${existing.warrantyMonths}',
        ),
        quantity = TextEditingController(
          text: existing == null ? '0' : '${existing.quantity}',
        ),
        lowStockThreshold = TextEditingController(
          text: existing == null
              ? '3'
              : '${existing.lowStockThreshold}',
        );

  final String? id;
  String condition;
  String ptaStatus;
  final TextEditingController name;
  final TextEditingController color;
  final TextEditingController storageGb;
  final TextEditingController ramGb;
  final TextEditingController barcode;
  final TextEditingController purchasePrice;
  final TextEditingController salePrice;
  final TextEditingController minPrice;
  final TextEditingController warrantyMonths;
  final TextEditingController quantity;
  final TextEditingController lowStockThreshold;

  int _int(TextEditingController c) => int.tryParse(c.text.trim()) ?? 0;

  ProductVariant toVariant(String productId, DateTime now) =>
      ProductVariant(
        id: id ?? '',
        productId: productId,
        name: name.text.trim(),
        color: color.text.trim().isEmpty ? null : color.text.trim(),
        storageGb: _int(storageGb) == 0 ? null : _int(storageGb),
        ramGb: _int(ramGb) == 0 ? null : _int(ramGb),
        condition: condition,
        ptaStatus: ptaStatus,
        barcode: barcode.text.trim().isEmpty ? null : barcode.text.trim(),
        purchasePrice: _int(purchasePrice),
        salePrice: _int(salePrice),
        minPrice: _int(minPrice),
        warrantyMonths: _int(warrantyMonths),
        quantity: _int(quantity),
        lowStockThreshold: _int(lowStockThreshold),
        createdAt: now,
        updatedAt: now,
      );

  void dispose() {
    name.dispose();
    color.dispose();
    storageGb.dispose();
    ramGb.dispose();
    barcode.dispose();
    purchasePrice.dispose();
    salePrice.dispose();
    minPrice.dispose();
    warrantyMonths.dispose();
    quantity.dispose();
    lowStockThreshold.dispose();
  }
}

/// Product form (routes `/inventory/new` and `/inventory/:id/edit`).
///
/// Creates / edits a product plus its variants. After the product is
/// saved, IMEI items can be added to a variant — single IMEI, or bulk
/// paste (one per line). A duplicate IMEI is rejected by the
/// repository and shown next to that IMEI instead of failing the
/// whole batch. Cost price is hidden from cashiers.
class ProductFormScreen extends ConsumerStatefulWidget {
  const ProductFormScreen({super.key, this.productId});

  /// Null = create mode; set = edit mode.
  final String? productId;

  @override
  ConsumerState<ProductFormScreen> createState() =>
      _ProductFormScreenState();
}

class _ProductFormScreenState extends ConsumerState<ProductFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _barcodeController = TextEditingController();
  final TextEditingController _descriptionController =
      TextEditingController();
  final TextEditingController _singleImeiController =
      TextEditingController();
  final TextEditingController _bulkImeiController = TextEditingController();
  final TextEditingController _imei2Controller = TextEditingController();

  bool _loading = true;
  bool _saving = false;
  bool _addingImei = false;
  String? _error;
  String? _savedProductId;
  List<Brand> _brands = <Brand>[];
  List<Category> _categories = <Category>[];
  String _type = 'phone';
  String? _brandId;
  String? _categoryId;
  List<_VariantDraft> _variants = <_VariantDraft>[];
  List<ProductVariant> _savedVariants = <ProductVariant>[];
  String? _imeiVariantId;
  final List<String> _imeiResults = <String>[];

  bool get _isEdit => widget.productId != null;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _barcodeController.dispose();
    _descriptionController.dispose();
    _singleImeiController.dispose();
    _bulkImeiController.dispose();
    _imei2Controller.dispose();
    for (final draft in _variants) {
      draft.dispose();
    }
    super.dispose();
  }

  bool get _canSeeCosts {
    final role = ref.read(authStateProvider).user?.role;
    return UserRoles.canSeeCosts.contains(role);
  }

  String get _userId => ref.read(authStateProvider).user?.id ?? '';

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final repo = ref.read(productRepositoryProvider);
      final brands = await repo.listBrands();
      final categories = await repo.listCategories();
      Product? product;
      List<ProductVariant> variants = <ProductVariant>[];
      if (_isEdit) {
        product = await repo.getProduct(widget.productId!);
        if (product == null) throw Exception('Product not found');
        variants = await repo.listVariants(product.id);
      }
      if (!mounted) return;
      setState(() {
        _brands = brands;
        _categories = categories;
        if (product != null) {
          _savedProductId = product.id;
          _nameController.text = product.name;
          _barcodeController.text = product.barcode ?? '';
          _descriptionController.text = product.description ?? '';
          _type = product.type;
          _brandId = product.brandId;
          _categoryId = product.categoryId;
          _variants = variants.map((v) => _VariantDraft(existing: v)).toList();
          _savedVariants = variants;
          if (variants.isNotEmpty) _imeiVariantId = variants.first.id;
        } else {
          _variants = <_VariantDraft>[_VariantDraft()];
        }
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

  Future<void> _addBrand() async {
    final lang = ref.read(languageProvider);
    String tr(String key) => AppStrings.tr(key, language: lang);
    final controller = TextEditingController();
    final name = await showDialog<String>(
      context: context,
      builder: (context) => CyberDialog(
        title: tr('addNewBrand'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(tr('cancel')),
          ),
          CyberButton(
            label: tr('save'),
            fullWidth: false,
            onPressed: () =>
                Navigator.of(context).pop(controller.text.trim()),
          ),
        ],
        child: CyberTextField(
          controller: controller,
          label: tr('brandName'),
          autofocus: true,
        ),
      ),
    );
    controller.dispose();
    if (name == null || name.isEmpty) return;
    try {
      final created = await ref.read(productRepositoryProvider).createBrand(
            Brand(id: '', name: name, createdAt: DateTime.now()),
            userId: _userId,
          );
      setState(() {
        _brands = [..._brands, created];
        _brandId = created.id;
      });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    }
  }

  Future<void> _addCategory() async {
    final lang = ref.read(languageProvider);
    String tr(String key) => AppStrings.tr(key, language: lang);
    final controller = TextEditingController();
    final name = await showDialog<String>(
      context: context,
      builder: (context) => CyberDialog(
        title: tr('addNewCategory'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(tr('cancel')),
          ),
          CyberButton(
            label: tr('save'),
            fullWidth: false,
            onPressed: () =>
                Navigator.of(context).pop(controller.text.trim()),
          ),
        ],
        child: CyberTextField(
          controller: controller,
          label: tr('categoryName'),
          autofocus: true,
        ),
      ),
    );
    controller.dispose();
    if (name == null || name.isEmpty) return;
    try {
      final created =
          await ref.read(productRepositoryProvider).createCategory(
                Category(
                  id: '',
                  name: name,
                  type: _type,
                  createdAt: DateTime.now(),
                ),
                userId: _userId,
              );
      setState(() {
        _categories = [..._categories, created];
        _categoryId = created.id;
      });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    }
  }

  Future<void> _save() async {
    final lang = ref.read(languageProvider);
    String tr(String key) => AppStrings.tr(key, language: lang);
    if (!_formKey.currentState!.validate()) return;
    if (_variants.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(tr('noVariants'))),
      );
      return;
    }
    for (final draft in _variants) {
      if (draft.name.text.trim().isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(tr('fieldRequired'))),
        );
        return;
      }
    }
    setState(() {
      _saving = true;
      _error = null;
    });
    try {
      final repo = ref.read(productRepositoryProvider);
      final now = DateTime.now();
      Product product;
      if (_isEdit) {
        final existing = await repo.getProduct(widget.productId!);
        product = await repo.updateProduct(
          Product(
            id: widget.productId!,
            brandId: _brandId,
            categoryId: _categoryId,
            type: _type,
            name: _nameController.text.trim(),
            description: _descriptionController.text.trim().isEmpty
                ? null
                : _descriptionController.text.trim(),
            barcode: _barcodeController.text.trim().isEmpty
                ? null
                : _barcodeController.text.trim(),
            createdAt: existing?.createdAt ?? now,
            updatedAt: now,
          ),
          userId: _userId,
        );
      } else {
        product = await repo.createProduct(
          Product(
            id: '',
            brandId: _brandId,
            categoryId: _categoryId,
            type: _type,
            name: _nameController.text.trim(),
            description: _descriptionController.text.trim().isEmpty
                ? null
                : _descriptionController.text.trim(),
            barcode: _barcodeController.text.trim().isEmpty
                ? null
                : _barcodeController.text.trim(),
            createdAt: now,
            updatedAt: now,
          ),
          userId: _userId,
        );
      }
      final savedVariants = <ProductVariant>[];
      for (final draft in _variants) {
        final variant = draft.toVariant(product.id, now);
        if (draft.id == null) {
          savedVariants.add(
            await repo.createVariant(variant, userId: _userId),
          );
        } else {
          savedVariants.add(
            await repo.updateVariant(variant, userId: _userId),
          );
        }
      }
      if (!mounted) return;
      setState(() {
        _savedProductId = product.id;
        _savedVariants = savedVariants;
        _imeiVariantId ??=
            savedVariants.isNotEmpty ? savedVariants.first.id : null;
        // Refresh drafts so new variants carry their ids.
        for (final draft in _variants) {
          draft.dispose();
        }
        _variants = savedVariants
            .map((v) => _VariantDraft(existing: v))
            .toList();
        _saving = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(tr('productSaved'))),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString();
        _saving = false;
      });
    }
  }

  Future<void> _addImeis(List<String> rawImeis) async {
    final lang = ref.read(languageProvider);
    String tr(String key) => AppStrings.tr(key, language: lang);
    final variantId = _imeiVariantId;
    final productId = _savedProductId;
    if (variantId == null || productId == null) return;
    final variant =
        _savedVariants.where((v) => v.id == variantId).firstOrNull;
    setState(() {
      _addingImei = true;
      _imeiResults.clear();
    });
    final repo = ref.read(productRepositoryProvider);
    for (final raw in rawImeis) {
      final imei = raw.trim();
      if (imei.isEmpty) continue;
      if (!validateImei(imei)) {
        setState(() {
          _imeiResults.add('$imei — ${tr('imeiInvalidShown')}');
        });
        continue;
      }
      try {
        final now = DateTime.now();
        await repo.createImeiItem(
          ImeiItem(
            id: '',
            productId: productId,
            variantId: variantId,
            imei1: imei,
            imei2: _imei2Controller.text.trim().isEmpty
                ? null
                : _imei2Controller.text.trim(),
            status: ImeiStatus.available,
            purchasePrice: variant?.purchasePrice ?? 0,
            salePrice: variant?.salePrice ?? 0,
            createdAt: now,
            updatedAt: now,
          ),
          userId: _userId,
        );
        setState(() {
          _imeiResults.add('$imei — ${tr('imeiAdded')}');
        });
      } catch (e) {
        // The repository rejects duplicates (409-style error); show it
        // next to that IMEI and keep going with the rest of the batch.
        setState(() {
          _imeiResults.add('$imei — ${e.toString()}');
        });
      }
    }
    if (!mounted) return;
    setState(() {
      _addingImei = false;
      _singleImeiController.clear();
      _bulkImeiController.clear();
      _imei2Controller.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    final c = ref.watch(themeNotifierProvider).colors;
    final lang = ref.watch(languageProvider);
    String tr(String key) => AppStrings.tr(key, language: lang);
    final canSeeCosts = _canSeeCosts;

    return Scaffold(
      appBar: CyberAppBar(
        title: _isEdit ? tr('edit') : tr('addProduct'),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : Form(
              key: _formKey,
              child: ListView(
                padding: const EdgeInsets.all(12),
                children: [
                  if (_error != null)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Text(
                        _error!,
                        style: CyberTextStyles.error(c),
                      ),
                    ),
                  CyberTextField(
                    controller: _nameController,
                    label: tr('productName'),
                    validator: (value) =>
                        value == null || value.trim().isEmpty
                            ? tr('requiredField')
                            : null,
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          initialValue: _type,
                          decoration: InputDecoration(labelText: tr('type')),
                          items: [
                            DropdownMenuItem(
                              value: 'phone',
                              child: Text(tr('phone')),
                            ),
                            DropdownMenuItem(
                              value: 'accessory',
                              child: Text(tr('accessory')),
                            ),
                          ],
                          onChanged: (value) {
                            if (value != null) {
                              setState(() => _type = value);
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: DropdownButtonFormField<String?>(
                          initialValue: _brandId,
                          decoration:
                              InputDecoration(labelText: tr('brand')),
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
                          onChanged: (value) =>
                              setState(() => _brandId = value),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.add),
                        tooltip: tr('addNewBrand'),
                        constraints: const BoxConstraints(
                          minWidth: 48,
                          minHeight: 48,
                        ),
                        onPressed: _addBrand,
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: DropdownButtonFormField<String?>(
                          initialValue: _categoryId,
                          decoration:
                              InputDecoration(labelText: tr('category')),
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
                          onChanged: (value) =>
                              setState(() => _categoryId = value),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.add),
                        tooltip: tr('addNewCategory'),
                        constraints: const BoxConstraints(
                          minWidth: 48,
                          minHeight: 48,
                        ),
                        onPressed: _addCategory,
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  CyberTextField(
                    controller: _barcodeController,
                    label: tr('barcode'),
                    monospace: true,
                  ),
                  const SizedBox(height: 12),
                  CyberTextField(
                    controller: _descriptionController,
                    label: tr('description'),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          tr('variants'),
                          style: CyberTextStyles.subtitle(c),
                        ),
                      ),
                      CyberButton(
                        label: tr('addVariant'),
                        fullWidth: false,
                        variant: CyberButtonVariant.ghost,
                        onPressed: () => setState(
                          () => _variants.add(_VariantDraft()),
                        ),
                      ),
                    ],
                  ),
                  if (_variants.isEmpty)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Text(
                        tr('noVariants'),
                        style: CyberTextStyles.bodySecondary(c),
                      ),
                    ),
                  for (var i = 0; i < _variants.length; i++)
                    _variantCard(_variants[i], i, tr, c, canSeeCosts),
                  const SizedBox(height: 16),
                  CyberButton(
                    label: tr('saveProduct'),
                    icon: Icons.save_outlined,
                    isLoading: _saving,
                    onPressed: _save,
                  ),
                  if (_savedProductId != null) ...[
                    const SizedBox(height: 24),
                    Text(
                      tr('addImei'),
                      style: CyberTextStyles.subtitle(c),
                    ),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<String?>(
                      initialValue: _imeiVariantId,
                      decoration: InputDecoration(
                        labelText: tr('selectVariant'),
                      ),
                      items: [
                        for (final variant in _savedVariants)
                          DropdownMenuItem<String?>(
                            value: variant.id,
                            child: Text(variant.name),
                          ),
                      ],
                      onChanged: (value) =>
                          setState(() => _imeiVariantId = value),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: CyberTextField(
                            controller: _singleImeiController,
                            label: tr('imei'),
                            hint: tr('imeiHint'),
                            monospace: true,
                            keyboardType: TextInputType.number,
                            maxLength: 15,
                          ),
                        ),
                        const SizedBox(width: 8),
                        CyberButton(
                          label: tr('add'),
                          fullWidth: false,
                          isLoading: _addingImei,
                          onPressed: () {
                            final imei =
                                _singleImeiController.text.trim();
                            if (imei.isNotEmpty) _addImeis([imei]);
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    CyberTextField(
                      controller: _imei2Controller,
                      label: tr('imei2'),
                      hint: tr('imeiHint'),
                      monospace: true,
                      keyboardType: TextInputType.number,
                      maxLength: 15,
                    ),
                    const SizedBox(height: 12),
                    CyberTextField(
                      controller: _bulkImeiController,
                      label: tr('bulkImei'),
                      hint: tr('bulkImeiHint'),
                      monospace: true,
                      keyboardType: TextInputType.multiline,
                    ),
                    const SizedBox(height: 12),
                    CyberButton(
                      label: tr('bulkImei'),
                      variant: CyberButtonVariant.ghost,
                      isLoading: _addingImei,
                      onPressed: () {
                        final lines = _bulkImeiController.text
                            .split(RegExp(r'[\n,;]+'))
                            .where((line) => line.trim().isNotEmpty)
                            .toList();
                        if (lines.isNotEmpty) _addImeis(lines);
                      },
                    ),
                    if (_imeiResults.isNotEmpty) ...[
                      const SizedBox(height: 12),
                      for (final result in _imeiResults)
                        Padding(
                          padding:
                              const EdgeInsets.symmetric(vertical: 2),
                          child: Text(
                            result,
                            style: CyberTextStyles.mono(c, size: 13),
                          ),
                        ),
                    ],
                  ],
                  const SizedBox(height: 24),
                ],
              ),
            ),
    );
  }

  Widget _variantCard(
    _VariantDraft draft,
    int index,
    String Function(String) tr,
    CyberColors c,
    bool canSeeCosts,
  ) {
    return CyberCard(
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  '${tr('variants')} ${index + 1}',
                  style: CyberTextStyles.subtitle(c),
                ),
              ),
              if (_variants.length > 1)
                IconButton(
                  icon: const Icon(Icons.delete_outline),
                  color: c.error,
                  constraints: const BoxConstraints(
                    minWidth: 48,
                    minHeight: 48,
                  ),
                  onPressed: () => setState(() {
                    draft.dispose();
                    _variants.removeAt(index);
                  }),
                ),
            ],
          ),
          CyberTextField(
            controller: draft.name,
            label: tr('variantName'),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: CyberTextField(
                  controller: draft.color,
                  label: tr('color'),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: CyberTextField(
                  controller: draft.storageGb,
                  label: tr('storage'),
                  keyboardType: TextInputType.number,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: CyberTextField(
                  controller: draft.ramGb,
                  label: tr('ram'),
                  keyboardType: TextInputType.number,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: DropdownButtonFormField<String>(
                  initialValue: draft.condition,
                  decoration:
                      InputDecoration(labelText: tr('condition')),
                  items: [
                    DropdownMenuItem(
                      value: 'new',
                      child: Text(tr('newCondition')),
                    ),
                    DropdownMenuItem(
                      value: 'used',
                      child: Text(tr('usedCondition')),
                    ),
                    DropdownMenuItem(
                      value: 'open_box',
                      child: Text(tr('openBoxCondition')),
                    ),
                  ],
                  onChanged: (value) {
                    if (value != null) {
                      setState(() => draft.condition = value);
                    }
                  },
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: DropdownButtonFormField<String>(
                  initialValue: draft.ptaStatus,
                  decoration:
                      InputDecoration(labelText: tr('ptaStatus')),
                  items: [
                    DropdownMenuItem(
                      value: 'approved',
                      child: Text(tr('ptaApproved')),
                    ),
                    DropdownMenuItem(
                      value: 'non_pta',
                      child: Text(tr('ptaNotApproved')),
                    ),
                    const DropdownMenuItem(
                      value: 'not_applicable',
                      child: Text('N/A'),
                    ),
                  ],
                  onChanged: (value) {
                    if (value != null) {
                      setState(() => draft.ptaStatus = value);
                    }
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          CyberTextField(
            controller: draft.barcode,
            label: tr('barcode'),
            monospace: true,
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              if (canSeeCosts)
                Expanded(
                  child: CyberTextField(
                    controller: draft.purchasePrice,
                    label: tr('costPrice'),
                    monospace: true,
                    keyboardType: TextInputType.number,
                  ),
                ),
              if (canSeeCosts) const SizedBox(width: 8),
              Expanded(
                child: CyberTextField(
                  controller: draft.salePrice,
                  label: tr('salePrice'),
                  monospace: true,
                  keyboardType: TextInputType.number,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: CyberTextField(
                  controller: draft.minPrice,
                  label: tr('minPrice'),
                  monospace: true,
                  keyboardType: TextInputType.number,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: CyberTextField(
                  controller: draft.warrantyMonths,
                  label: tr('warrantyMonths'),
                  keyboardType: TextInputType.number,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: CyberTextField(
                  controller: draft.quantity,
                  label: tr('quantity'),
                  keyboardType: TextInputType.number,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: CyberTextField(
                  controller: draft.lowStockThreshold,
                  label: tr('lowStockThreshold'),
                  keyboardType: TextInputType.number,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
