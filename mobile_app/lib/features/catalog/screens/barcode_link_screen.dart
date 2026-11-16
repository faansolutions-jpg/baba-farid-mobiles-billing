import 'dart:async';

import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import '../catalog_models.dart';
import '../catalog_repository.dart';
import '../catalog_search.dart';
import 'catalog_strings.dart';
import 'catalog_theme.dart';

enum _BarcodeStage { scanning, found, unknown }

/// Barcode Link + Stock-In.
///
/// Scans a barcode with the camera ([MobileScanner]). If the barcode is
/// known ([byBarcode] finds it), stock is added instantly after a quantity
/// prompt. If it is unknown, the screen asks "Which catalog item is this?"
/// with a search box; picking an item links it permanently ([linkBarcode])
/// and then proceeds to stock-in. A manual barcode entry is always
/// available (web / no camera / damaged camera).
class BarcodeLinkScreen extends StatefulWidget {
  const BarcodeLinkScreen({super.key, required this.repository});

  final CatalogRepository repository;

  @override
  State<BarcodeLinkScreen> createState() => _BarcodeLinkScreenState();
}

class _BarcodeLinkScreenState extends State<BarcodeLinkScreen> {
  final MobileScannerController _scanner = MobileScannerController(
    detectionSpeed: DetectionSpeed.normal,
  );
  final TextEditingController _manualController = TextEditingController();
  final TextEditingController _qtyController =
      TextEditingController(text: '1');
  final TextEditingController _linkSearchController = TextEditingController();
  Timer? _searchDebounce;

  _BarcodeStage _stage = _BarcodeStage.scanning;
  bool _handling = false;
  bool _saving = false;
  bool _torchOn = false;
  String? _code;
  String? _lookupError;
  CatalogItem? _foundItem;
  List<CatalogItem>? _linkResults;
  bool _searchingLink = false;

  // Full catalog, loaded lazily once, for the "which item is this?" search.
  List<CatalogItem> _allItems = <CatalogItem>[];
  bool _allItemsLoaded = false;

  @override
  void dispose() {
    _scanner.dispose();
    _manualController.dispose();
    _qtyController.dispose();
    _linkSearchController.dispose();
    _searchDebounce?.cancel();
    super.dispose();
  }

  void _onDetect(BarcodeCapture capture) {
    if (_handling || _stage != _BarcodeStage.scanning) return;
    String? code;
    for (final barcode in capture.barcodes) {
      final value = barcode.rawValue ?? barcode.displayValue;
      if (value != null && value.trim().isNotEmpty) {
        code = value.trim();
        break;
      }
    }
    if (code == null) return;
    unawaited(_handleCode(code));
  }

  Future<void> _handleCode(String code) async {
    if (_handling) return;
    _handling = true;
    await _scanner.stop();
    setState(() {
      _code = code;
      _lookupError = null;
      _foundItem = null;
    });
    try {
      final item = await widget.repository.byBarcode(code);
      if (!mounted) return;
      if (item != null) {
        setState(() => _stage = _BarcodeStage.found);
        _foundItem = item;
      } else {
        setState(() => _stage = _BarcodeStage.unknown);
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => _lookupError = e.toString());
      // Lookup failed (not "unknown barcode") — restart the camera so
      // the shopkeeper can scan again instead of being stuck.
      await _scanner.start();
    } finally {
      _handling = false;
    }
  }

  Future<void> _scanAgain() async {
    setState(() {
      _stage = _BarcodeStage.scanning;
      _code = null;
      _foundItem = null;
      _lookupError = null;
      _linkResults = null;
      _linkSearchController.clear();
      _qtyController.text = '1';
    });
    await _scanner.start();
  }

  Future<void> _toggleTorch() async {
    await _scanner.toggleTorch();
    setState(() => _torchOn = !_torchOn);
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

  void _onLinkSearchChanged(String value) {
    _searchDebounce?.cancel();
    _searchDebounce = Timer(const Duration(milliseconds: 300), () {
      _runLinkSearch(value);
    });
  }

  Future<void> _runLinkSearch(String rawQuery) async {
    final query = normalizeQuery(rawQuery).trim();
    if (query.length < 2) {
      setState(() => _linkResults = null);
      return;
    }
    setState(() => _searchingLink = true);
    try {
      await _ensureAllItems();
      final results = searchCatalog(_allItems, query);
      if (!mounted) return;
      setState(() {
        _linkResults = results;
        _searchingLink = false;
      });
    } catch (_) {
      try {
        final results = await widget.repository.search(query);
        if (!mounted) return;
        setState(() {
          _linkResults = results;
          _searchingLink = false;
        });
      } catch (e) {
        if (!mounted) return;
        setState(() => _searchingLink = false);
        _showMessage(CatalogStrings.tr('searchFailed'), isError: true);
      }
    }
  }

  Future<void> _linkToItem(CatalogItem item) async {
    final code = _code;
    if (code == null) return;
    setState(() => _saving = true);
    try {
      // Permanent link: later scans of this barcode add stock instantly.
      await widget.repository.linkBarcode(code, item.id);
      if (!mounted) return;
      setState(() {
        _foundItem = item;
        _stage = _BarcodeStage.found;
        _saving = false;
      });
      _showMessage(CatalogStrings.tr('linkedSuccess'));
    } catch (e) {
      if (!mounted) return;
      setState(() => _saving = false);
      _showMessage('${CatalogStrings.tr('somethingWentWrong')} ($e)',
          isError: true);
    }
  }

  Future<void> _addStock() async {
    final item = _foundItem;
    if (item == null) return;
    final qty = int.tryParse(_qtyController.text.trim()) ?? 0;
    if (qty <= 0) {
      _showMessage(CatalogStrings.tr('invalidNumber'), isError: true);
      return;
    }
    setState(() => _saving = true);
    try {
      await widget.repository.stockIn(item.id, qty);
      if (!mounted) return;
      setState(() => _saving = false);
      _showMessage(CatalogStrings.tr('stockAdded'));
      await _scanAgain();
    } catch (e) {
      if (!mounted) return;
      setState(() => _saving = false);
      _showMessage('${CatalogStrings.tr('somethingWentWrong')} ($e)',
          isError: true);
    }
  }

  void _submitManualCode() {
    final code = _manualController.text.trim();
    if (code.isEmpty) {
      _showMessage(CatalogStrings.tr('barcodeEmpty'), isError: true);
      return;
    }
    unawaited(_handleCode(code));
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
      appBar: CatalogTheme.appBar(
        CatalogStrings.tr('barcodeLink'),
        actions: <Widget>[
          IconButton(
            icon: Icon(
              _torchOn ? Icons.flash_on : Icons.flash_off,
              color: CatalogTheme.text,
            ),
            tooltip: CatalogStrings.tr('torch'),
            onPressed: _toggleTorch,
          ),
          IconButton(
            icon: const Icon(Icons.cameraswitch, color: CatalogTheme.text),
            tooltip: CatalogStrings.tr('switchCamera'),
            onPressed: () => unawaited(_scanner.switchCamera()),
          ),
        ],
      ),
      body: Column(
        children: <Widget>[
          Expanded(child: _buildStage()),
          _buildManualEntry(),
        ],
      ),
    );
  }

  Widget _buildStage() {
    switch (_stage) {
      case _BarcodeStage.scanning:
        return _buildScanner();
      case _BarcodeStage.found:
        return _buildFound();
      case _BarcodeStage.unknown:
        return _buildUnknown();
    }
  }

  Widget _buildScanner() {
    return Column(
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.all(12),
          child: Text(
            CatalogStrings.tr('scanHint'),
            style: CatalogTheme.bodySmall,
            textAlign: TextAlign.center,
          ),
        ),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Stack(
                fit: StackFit.expand,
                children: <Widget>[
                  MobileScanner(
                    controller: _scanner,
                    onDetect: _onDetect,
                    errorBuilder: (context, error, child) {
                      return Container(
                        color: CatalogTheme.surface,
                        alignment: Alignment.center,
                        child: Padding(
                          padding: const EdgeInsets.all(24),
                          child: Text(
                            CatalogStrings.tr('cameraError'),
                            style: CatalogTheme.body,
                            textAlign: TextAlign.center,
                          ),
                        ),
                      );
                    },
                  ),
                  // Scan-frame overlay (visual guide only).
                  Center(
                    child: Container(
                      width: 240,
                      height: 140,
                      decoration: BoxDecoration(
                        border: Border.all(color: CatalogTheme.primary, width: 2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                  if (_handling)
                    Container(
                      color: CatalogTheme.background.withValues(alpha: 0.6),
                      alignment: Alignment.center,
                      child: const CircularProgressIndicator(
                        color: CatalogTheme.primary,
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
        if (_lookupError != null)
          Padding(
            padding: const EdgeInsets.all(12),
            child: Text(
              _lookupError!,
              style: CatalogTheme.bodySmall.copyWith(color: CatalogTheme.red),
              textAlign: TextAlign.center,
            ),
          ),
        const SizedBox(height: 12),
      ],
    );
  }

  Widget _buildFound() {
    final item = _foundItem;
    if (item == null) return CatalogTheme.emptyView(CatalogStrings.tr('noItemsFound'));
    return ListView(
      padding: const EdgeInsets.all(16),
      children: <Widget>[
        Row(
          children: <Widget>[
            const Icon(Icons.check_circle, color: CatalogTheme.primary, size: 28),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                CatalogStrings.tr('barcodeKnown'),
                style: CatalogTheme.heading,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Text(
          '${CatalogStrings.tr('barcode')}: ${_code ?? ''}',
          style: CatalogTheme.monoSmall,
        ),
        const SizedBox(height: 14),
        Container(
          padding: const EdgeInsets.all(14),
          decoration: CatalogTheme.cardDecoration(
            borderColor: CatalogTheme.primary.withValues(alpha: 0.6),
            glow: true,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(item.nameEn,
                  style: CatalogTheme.body.copyWith(fontWeight: FontWeight.w700)),
              if (item.nameUr.isNotEmpty) ...<Widget>[
                const SizedBox(height: 2),
                Text(item.nameUr, style: CatalogTheme.urdu),
              ],
              const SizedBox(height: 6),
              Text('${item.brand}  •  ${item.sku}', style: CatalogTheme.monoSmall),
              const SizedBox(height: 6),
              Row(
                children: <Widget>[
                  Text(
                    CatalogTheme.formatPkr(item.salePriceEst),
                    style: CatalogTheme.price,
                  ),
                  const SizedBox(width: 12),
                  CatalogTheme.stockChip(item),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Text(CatalogStrings.tr('enterQuantity'), style: CatalogTheme.bodySmall),
        const SizedBox(height: 6),
        TextField(
          controller: _qtyController,
          keyboardType: TextInputType.number,
          style: CatalogTheme.monoLarge,
          decoration: CatalogTheme.inputDecoration(hint: '1'),
        ),
        const SizedBox(height: 16),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: _saving ? null : _addStock,
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
                : Text(CatalogStrings.tr('addStock')),
          ),
        ),
        const SizedBox(height: 10),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton(
            onPressed: _scanAgain,
            style: CatalogTheme.ghostButtonStyle,
            child: Text(CatalogStrings.tr('scanAgain')),
          ),
        ),
      ],
    );
  }

  Widget _buildUnknown() {
    final results = _linkResults ?? <CatalogItem>[];
    final isSearching =
        normalizeQuery(_linkSearchController.text).trim().length >= 2;
    return Column(
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Row(
                children: <Widget>[
                  const Icon(Icons.help_outline, color: CatalogTheme.amber, size: 28),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      CatalogStrings.tr('barcodeUnknown'),
                      style: CatalogTheme.heading,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                '${CatalogStrings.tr('barcode')}: ${_code ?? ''}',
                style: CatalogTheme.monoSmall,
              ),
              const SizedBox(height: 12),
              Text(
                CatalogStrings.tr('whichItemIsThis'),
                style: CatalogTheme.body,
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _linkSearchController,
                onChanged: _onLinkSearchChanged,
                style: CatalogTheme.body,
                decoration: CatalogTheme.inputDecoration(
                  hint: CatalogStrings.tr('searchCatalogHint'),
                  prefixIcon: const Icon(Icons.search, color: CatalogTheme.muted),
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: !isSearching
              ? CatalogTheme.emptyView(
                  CatalogStrings.tr('searchCatalogHint'),
                )
              : _searchingLink
                  ? CatalogTheme.loadingView()
                  : results.isEmpty
                      ? CatalogTheme.emptyView(
                          CatalogStrings.tr('noItemsFound'),
                          CatalogStrings.tr('tryDifferentSearch'),
                        )
                      : ListView.builder(
                          itemCount: results.length,
                          itemBuilder: (context, index) {
                            final item = results[index];
                            return CatalogTheme.itemTile(
                              item,
                              onTap: _saving ? () {} : () => _linkToItem(item),
                              trailing: const Icon(
                                Icons.link,
                                color: CatalogTheme.cyan,
                              ),
                            );
                          },
                        ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
          child: SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: _scanAgain,
              style: CatalogTheme.ghostButtonStyle,
              child: Text(CatalogStrings.tr('scanAgain')),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildManualEntry() {
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 16),
      decoration: const BoxDecoration(
        color: CatalogTheme.surface,
        border: Border(top: BorderSide(color: CatalogTheme.border)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            CatalogStrings.tr('manualBarcode'),
            style: CatalogTheme.bodySmall,
          ),
          const SizedBox(height: 8),
          Row(
            children: <Widget>[
              Expanded(
                child: TextField(
                  controller: _manualController,
                  keyboardType: TextInputType.number,
                  style: CatalogTheme.mono,
                  onSubmitted: (_) => _submitManualCode(),
                  decoration: CatalogTheme.inputDecoration(
                    hint: CatalogStrings.tr('enterBarcode'),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              SizedBox(
                height: 52,
                child: ElevatedButton(
                  onPressed: _submitManualCode,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: CatalogTheme.primary,
                    foregroundColor: CatalogTheme.onPrimary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: Text(CatalogStrings.tr('search')),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
