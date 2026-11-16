import 'dart:async';

import 'package:flutter/material.dart';

import '../catalog_models.dart';
import '../catalog_repository.dart';
import '../catalog_search.dart';
import 'catalog_strings.dart';
import 'catalog_theme.dart';

/// One line of the running stock-in list.
class _QuickLine {
  _QuickLine({required this.item, required this.qty});

  final CatalogItem item;
  int qty;
}

/// Quick Stock-In — "Bas quantity daalo".
///
/// Search/browse the catalog, tap an item, type a quantity, it joins a
/// running list. One Save persists everything in a single [bulkStockIn]
/// call. Optional per-save fields: buying price, supplier, date (defaults
/// to today; the item's estimated purchase price is shown as the hint).
/// "Same as last purchase" reuses the last saved price + supplier;
/// "Repeat last supplier invoice" reloads the last saved batch.
class QuickStockInScreen extends StatefulWidget {
  const QuickStockInScreen({
    super.key,
    required this.repository,
    this.initialItem,
  });

  final CatalogRepository repository;

  /// When given (e.g. tapped from the catalog browser), the quantity
  /// dialog opens for this item as soon as the screen appears.
  final CatalogItem? initialItem;

  @override
  State<QuickStockInScreen> createState() => _QuickStockInScreenState();
}

class _QuickStockInScreenState extends State<QuickStockInScreen> {
  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _supplierController = TextEditingController();
  Timer? _searchDebounce;

  // Running list, keyed by item id (= sku).
  final Map<String, _QuickLine> _lines = <String, _QuickLine>{};

  bool _searching = false;
  bool _saving = false;
  List<CatalogItem>? _searchResults;
  List<CatalogItem> _lowStock = <CatalogItem>[];
  bool _loadingSuggestions = true;

  DateTime _date = DateTime.now();

  // Last saved purchase, kept in memory for this session.
  int? _lastPrice;
  String? _lastSupplier;
  DateTime? _lastDate;
  Map<String, int> _lastBatch = <String, int>{};

  // Full catalog, loaded lazily once, so search runs over everything.
  List<CatalogItem> _allItems = <CatalogItem>[];
  bool _allItemsLoaded = false;

  // Every item this screen has ever seen (search results, suggestions,
  // initial item) — used to restore the last invoice without reloading
  // the whole catalog.
  final Map<String, CatalogItem> _knownItems = <String, CatalogItem>{};

  void _rememberItems(Iterable<CatalogItem> items) {
    for (final item in items) {
      _knownItems[item.id] = item;
    }
  }

  @override
  void initState() {
    super.initState();
    _loadSuggestions();
    final initial = widget.initialItem;
    if (initial != null) {
      _rememberItems(<CatalogItem>[initial]);
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _showQtyDialog(initial);
      });
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    _priceController.dispose();
    _supplierController.dispose();
    _searchDebounce?.cancel();
    super.dispose();
  }

  Future<void> _loadSuggestions() async {
    try {
      final low = await widget.repository.lowStock();
      if (!mounted) return;
      _rememberItems(low);
      setState(() {
        _lowStock = low.take(10).toList();
        _loadingSuggestions = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _loadingSuggestions = false);
    }
  }

  Future<void> _ensureAllItems() async {
    if (_allItemsLoaded) return;
    final categories = await widget.repository.categories();
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
      _rememberItems(results);
      setState(() {
        _searchResults = results;
        _searching = false;
      });
    } catch (_) {
      try {
        final results = await widget.repository.search(query);
        if (!mounted) return;
        _rememberItems(results);
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

  /// Effective per-piece buying price for [item]: the batch price typed
  /// in the form, otherwise the item's last known (estimated) price.
  int _effectivePrice(CatalogItem item) {
    final typed = int.tryParse(_priceController.text.trim());
    if (typed != null && typed > 0) return typed;
    return item.purchasePriceEst;
  }

  int get _totalQty =>
      _lines.values.fold<int>(0, (sum, line) => sum + line.qty);

  int get _totalValue => _lines.values.fold<int>(
        0,
        (sum, line) => sum + line.qty * _effectivePrice(line.item),
      );

  void _addToList(CatalogItem item, int qty) {
    if (qty <= 0) return;
    _rememberItems(<CatalogItem>[item]);
    setState(() {
      final existing = _lines[item.id];
      if (existing != null) {
        existing.qty += qty;
      } else {
        _lines[item.id] = _QuickLine(item: item, qty: qty);
      }
      _searchController.clear();
      _searchResults = null;
    });
  }

  void _changeQty(String itemId, int delta) {
    setState(() {
      final line = _lines[itemId];
      if (line == null) return;
      line.qty += delta;
      if (line.qty <= 0) _lines.remove(itemId);
    });
  }

  Future<void> _showQtyDialog(CatalogItem item) async {
    final controller = TextEditingController(text: '1');
    final existing = _lines[item.id];
    final qty = await showDialog<int>(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: CatalogTheme.surface,
          title: Text(item.nameEn, style: CatalogTheme.heading),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                '${item.brand}  •  ${item.sku}',
                style: CatalogTheme.monoSmall,
              ),
              const SizedBox(height: 6),
              Text(
                '${CatalogStrings.tr('lastPrice')}: '
                '${CatalogTheme.formatPkr(item.purchasePriceEst)} '
                '(${CatalogStrings.tr('estimated')})',
                style: CatalogTheme.bodySmall,
              ),
              if (existing != null) ...<Widget>[
                const SizedBox(height: 6),
                Text(
                  '${CatalogStrings.tr('quantity')}: ${existing.qty} '
                  '(${CatalogStrings.tr('runningList')})',
                  style: CatalogTheme.bodySmall.copyWith(color: CatalogTheme.amber),
                ),
              ],
              const SizedBox(height: 14),
              TextField(
                controller: controller,
                autofocus: true,
                keyboardType: TextInputType.number,
                style: CatalogTheme.mono,
                decoration: CatalogTheme.inputDecoration(
                  hint: CatalogStrings.tr('enterQuantity'),
                ),
              ),
            ],
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                CatalogStrings.tr('cancel'),
                style: const TextStyle(color: CatalogTheme.muted),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                final value = int.tryParse(controller.text.trim());
                Navigator.of(context).pop(value);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: CatalogTheme.primary,
                foregroundColor: CatalogTheme.onPrimary,
              ),
              child: Text(CatalogStrings.tr('addToList')),
            ),
          ],
        );
      },
    );
    controller.dispose();
    if (qty != null && qty > 0) _addToList(item, qty);
  }

  void _applySameAsLastPurchase() {
    if (_lastPrice == null && _lastSupplier == null) {
      _showMessage(CatalogStrings.tr('noLastPurchase'));
      return;
    }
    setState(() {
      if (_lastPrice != null) _priceController.text = _lastPrice.toString();
      if (_lastSupplier != null) _supplierController.text = _lastSupplier!;
      if (_lastDate != null) _date = _lastDate!;
    });
    _showMessage(CatalogStrings.tr('sameAsLastPurchase'));
  }

  void _repeatLastInvoice() {
    if (_lastBatch.isEmpty) {
      _showMessage(CatalogStrings.tr('noLastInvoice'));
      return;
    }
    setState(() {
      for (final entry in _lastBatch.entries) {
        final existing = _lines[entry.key];
        if (existing != null) {
          existing.qty = entry.value;
        }
      }
      // Items from the last batch that are no longer in the list need
      // their full item record; restore them from items seen earlier
      // (search results, suggestions, or the running list itself).
      for (final entry in _lastBatch.entries) {
        if (_lines.containsKey(entry.key)) continue;
        final match = _knownItems[entry.key];
        if (match != null) {
          _lines[entry.key] = _QuickLine(item: match, qty: entry.value);
        }
      }
      if (_lastPrice != null) _priceController.text = _lastPrice.toString();
      if (_lastSupplier != null) _supplierController.text = _lastSupplier!;
      if (_lastDate != null) _date = _lastDate!;
    });
    _showMessage(CatalogStrings.tr('repeatLastInvoice'));
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(2024, 1, 1),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) setState(() => _date = picked);
  }

  Future<void> _save() async {
    if (_lines.isEmpty) {
      _showMessage(CatalogStrings.tr('nothingToSave'), isError: true);
      return;
    }
    final price = int.tryParse(_priceController.text.trim());
    if (price != null && price < 0) {
      _showMessage(CatalogStrings.tr('invalidNumber'), isError: true);
      return;
    }
    final supplier = _supplierController.text.trim();
    final quantities = <String, int>{
      for (final line in _lines.values) line.item.id: line.qty,
    };
    setState(() => _saving = true);
    try {
      await widget.repository.bulkStockIn(
        quantities,
        price: price,
        supplier: supplier.isEmpty ? null : supplier,
        date: _date,
      );
      if (!mounted) return;
      final count = _lines.length;
      // Remember this batch for "same as last" / "repeat invoice".
      _lastBatch = Map<String, int>.from(quantities);
      _lastPrice = price;
      _lastSupplier = supplier.isEmpty ? null : supplier;
      _lastDate = _date;
      setState(() {
        _lines.clear();
        _saving = false;
      });
      _showMessage(CatalogStrings.trArgs('stockInSaved', {'count': count}));
      await _loadSuggestions();
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

  bool get _isSearching =>
      normalizeQuery(_searchController.text).trim().length >= 2;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: CatalogTheme.background,
      appBar: CatalogTheme.appBar(CatalogStrings.tr('quickStockIn')),
      body: Column(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 12, 12, 4),
            child: Text(
              CatalogStrings.tr('quickStockInSubtitle'),
              style: CatalogTheme.bodySmall,
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12),
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
          ),
          Expanded(child: _buildMiddle()),
          _buildBottomBar(),
        ],
      ),
    );
  }

  Widget _buildMiddle() {
    if (_isSearching) {
      if (_searching) return CatalogTheme.loadingView();
      final results = _searchResults ?? <CatalogItem>[];
      if (results.isEmpty) {
        return CatalogTheme.emptyView(
          CatalogStrings.tr('noItemsFound'),
          CatalogStrings.tr('tryDifferentSearch'),
        );
      }
      return ListView.builder(
        itemCount: results.length,
        itemBuilder: (context, index) {
          final item = results[index];
          final inList = _lines[item.id];
          return CatalogTheme.itemTile(
            item,
            onTap: () => _showQtyDialog(item),
            trailing: inList == null
                ? CatalogTheme.stockChip(item)
                : Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: CatalogTheme.primary.withValues(alpha: 0.14),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: CatalogTheme.primary),
                    ),
                    child: Text(
                      '×${inList.qty}',
                      style: CatalogTheme.mono.copyWith(
                        fontSize: 13,
                        color: CatalogTheme.primary,
                      ),
                    ),
                  ),
          );
        },
      );
    }
    // Idle state: running list on top, low-stock suggestions below.
    return ListView(
      padding: const EdgeInsets.only(bottom: 8),
      children: <Widget>[
        CatalogTheme.sectionHeader(CatalogStrings.tr('runningList')),
        if (_lines.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Text(
              CatalogStrings.tr('emptyRunningList'),
              style: CatalogTheme.bodySmall,
            ),
          )
        else
          ..._lines.values.map(_buildLineRow),
        if (!_loadingSuggestions && _lowStock.isNotEmpty) ...<Widget>[
          CatalogTheme.sectionHeader(
            CatalogStrings.tr('needStock'),
            subtitle: CatalogStrings.tr('searchToAdd'),
          ),
          ..._lowStock.map(
            (item) => CatalogTheme.itemTile(
              item,
              onTap: () => _showQtyDialog(item),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildLineRow(_QuickLine line) {
    final item = line.item;
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: CatalogTheme.cardDecoration(
        borderColor: CatalogTheme.primary.withValues(alpha: 0.6),
        glow: true,
      ),
      child: Row(
        children: <Widget>[
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(item.nameEn,
                    style: CatalogTheme.body.copyWith(fontWeight: FontWeight.w600)),
                const SizedBox(height: 2),
                Text('${item.brand}  •  ${item.sku}', style: CatalogTheme.monoSmall),
                const SizedBox(height: 4),
                Text(
                  CatalogTheme.formatPkr(_effectivePrice(item) * line.qty),
                  style: CatalogTheme.price,
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.remove_circle_outline, color: CatalogTheme.amber),
            iconSize: 28,
            onPressed: () => _changeQty(item.id, -1),
          ),
          SizedBox(
            width: 44,
            child: Text(
              '${line.qty}',
              style: CatalogTheme.monoLarge,
              textAlign: TextAlign.center,
            ),
          ),
          IconButton(
            icon: const Icon(Icons.add_circle_outline, color: CatalogTheme.primary),
            iconSize: 28,
            onPressed: () => _changeQty(item.id, 1),
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline, color: CatalogTheme.red),
            onPressed: () => setState(() => _lines.remove(item.id)),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomBar() {
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
                  onChanged: (_) => setState(() {}),
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
              const SizedBox(width: 8),
              OutlinedButton(
                onPressed: _pickDate,
                style: OutlinedButton.styleFrom(
                  foregroundColor: CatalogTheme.text,
                  minimumSize: const Size(0, 52),
                  side: const BorderSide(color: CatalogTheme.border),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: Text(
                  CatalogTheme.formatDate(_date),
                  style: CatalogTheme.monoSmall.copyWith(color: CatalogTheme.text),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: <Widget>[
              Expanded(
                child: OutlinedButton(
                  onPressed: _applySameAsLastPurchase,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: CatalogTheme.cyan,
                    minimumSize: const Size(0, 44),
                    side: const BorderSide(color: CatalogTheme.cyan),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: Text(
                    CatalogStrings.tr('sameAsLastPurchase'),
                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: OutlinedButton(
                  onPressed: _repeatLastInvoice,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: CatalogTheme.cyan,
                    minimumSize: const Size(0, 44),
                    side: const BorderSide(color: CatalogTheme.cyan),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: Text(
                    CatalogStrings.tr('repeatLastInvoice'),
                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Text(
                '${_lines.length} ${CatalogStrings.tr('items')}  •  '
                '${CatalogStrings.tr('totalQty')}: $_totalQty',
                style: CatalogTheme.monoSmall,
              ),
              Text(
                CatalogTheme.formatPkr(_totalValue),
                style: CatalogTheme.monoLarge,
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
                      '${CatalogStrings.tr('save')}  •  '
                      '${CatalogTheme.formatPkr(_totalValue)}',
                    ),
            ),
          ),
        ],
      ),
    );
  }
}
