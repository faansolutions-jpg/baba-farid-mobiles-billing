library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/config/constants.dart';
import '../../core/l10n/app_strings.dart';
import '../../core/theme/app_theme.dart';
import '../../core/theme/cyber_colors.dart';
import '../../core/theme/cyber_text_styles.dart';
import '../../core/theme/cyber_widgets.dart';
import '../../domain/models/imei_item.dart';
import '../../domain/models/product.dart';
import '../../domain/models/product_variant.dart';
import '../../domain/models/sale.dart';
import '../../domain/money.dart';
import '../auth/auth_state.dart';
import '../../core/providers/app_providers.dart';

/// IMEI search (route `/inventory/imei`).
///
/// Enter a 15-digit IMEI: shows the item, its product / variant,
/// condition / PTA, status, warranty state, and its sale history
/// (which sale, when, to whom). A sold IMEI shows a prominent SOLD
/// badge — it can never be re-sold unless its sale is returned.
class ImeiSearchScreen extends ConsumerStatefulWidget {
  const ImeiSearchScreen({super.key, this.initialImei});

  final String? initialImei;

  @override
  ConsumerState<ImeiSearchScreen> createState() => _ImeiSearchScreenState();
}

class _ImeiSearchScreenState extends ConsumerState<ImeiSearchScreen> {
  final TextEditingController _imeiController = TextEditingController();

  bool _searching = false;
  bool _hasSearched = false;
  String? _error;
  ImeiItem? _item;
  Product? _product;
  ProductVariant? _variant;
  Sale? _sale;
  int _returnCount = 0;

  @override
  void initState() {
    super.initState();
    if (widget.initialImei != null) {
      _imeiController.text = widget.initialImei!;
      _search();
    }
  }

  @override
  void dispose() {
    _imeiController.dispose();
    super.dispose();
  }

  bool get _canSeeCosts {
    final role = ref.read(authStateProvider).user?.role;
    return UserRoles.canSeeCosts.contains(role);
  }

  Future<void> _search() async {
    final lang = ref.read(languageProvider);
    String tr(String key) => AppStrings.tr(key, language: lang);
    final imei = _imeiController.text.trim();
    if (imei.isEmpty) return;
    setState(() {
      _searching = true;
      _hasSearched = true;
      _error = null;
      _item = null;
      _product = null;
      _variant = null;
      _sale = null;
      _returnCount = 0;
    });
    try {
      final productRepo = ref.read(productRepositoryProvider);
      final item = await productRepo.getImeiByNumber(imei);
      if (item == null) {
        if (!mounted) return;
        setState(() {
          _error = tr('imeiNotFound');
          _searching = false;
        });
        return;
      }
      final product = await productRepo.getProduct(item.productId);
      final variant = item.variantId == null
          ? null
          : await productRepo.getVariant(item.variantId!);
      Sale? sale;
      var returns = 0;
      if (item.soldSaleId != null) {
        sale = await ref
            .read(saleRepositoryProvider)
            .getSale(item.soldSaleId!);
        if (sale != null) {
          returns = (await ref
                  .read(saleRepositoryProvider)
                  .listSaleReturns(sale.id))
              .length;
        }
      }
      if (!mounted) return;
      setState(() {
        _item = item;
        _product = product;
        _variant = variant;
        _sale = sale;
        _returnCount = returns;
        _searching = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString();
        _searching = false;
      });
    }
  }

  String _warrantyLabel(ImeiItem item, String Function(String) tr) {
    if (item.warrantyEnd == null) return tr('warrantyNotSet');
    return DateTime.now().isBefore(item.warrantyEnd!)
        ? tr('warrantyActive')
        : tr('warrantyExpired');
  }

  @override
  Widget build(BuildContext context) {
    final c = ref.watch(themeNotifierProvider).colors;
    final lang = ref.watch(languageProvider);
    String tr(String key) => AppStrings.tr(key, language: lang);
    final item = _item;
    final isSold = item?.status == ImeiStatus.sold;

    return Scaffold(
      appBar: CyberAppBar(title: tr('searchImei')),
      body: ListView(
        padding: const EdgeInsets.all(12),
        children: [
          Row(
            children: [
              Expanded(
                child: CyberTextField(
                  controller: _imeiController,
                  label: tr('imei'),
                  hint: tr('imeiHint'),
                  monospace: true,
                  keyboardType: TextInputType.number,
                  maxLength: 15,
                  textInputAction: TextInputAction.search,
                  onSubmitted: (_) => _search(),
                ),
              ),
              const SizedBox(width: 8),
              CyberButton(
                label: tr('search'),
                fullWidth: false,
                isLoading: _searching,
                onPressed: _search,
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (_error != null)
            CyberCard(
              borderColor: c.error,
              child: Text(_error!, style: CyberTextStyles.error(c)),
            )
          else if (!_hasSearched)
            Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 24),
                child: Text(
                  tr('enterImeiToSearch'),
                  style: CyberTextStyles.bodySecondary(c),
                ),
              ),
            )
          else if (item != null) ...[
            if (isSold)
              CyberCard(
                borderColor: c.error,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.block_outlined, color: c.error),
                        const SizedBox(width: 8),
                        CyberBadge(label: tr('sold'), color: c.error),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      tr('soldImeiWarning'),
                      style: CyberTextStyles.warning(c),
                    ),
                  ],
                ),
              )
            else
              CyberCard(
                borderColor: c.success,
                child: Row(
                  children: [
                    Icon(Icons.check_circle_outline, color: c.success),
                    const SizedBox(width: 8),
                    Text(
                      tr('imeiAvailable'),
                      style: CyberTextStyles.success(c),
                    ),
                  ],
                ),
              ),
            const SizedBox(height: 12),
            CyberCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.imei1,
                    style: CyberTextStyles.imei(c, size: 18),
                  ),
                  if (item.imei2 != null)
                    Text(
                      '${tr('imei2')}: ${item.imei2}',
                      style: CyberTextStyles.imei(c, size: 13),
                    ),
                  const SizedBox(height: 8),
                  Text(
                    _product?.name ?? '',
                    style: CyberTextStyles.title(c, size: 18),
                  ),
                  if (_variant != null)
                    Text(
                      [
                        _variant!.name,
                        if (_variant!.color != null) _variant!.color!,
                        _variant!.condition,
                        _variant!.ptaStatus,
                      ].join(' · '),
                      style: CyberTextStyles.bodySecondary(c),
                    ),
                  const SizedBox(height: 8),
                  _infoRow(
                    tr('status'),
                    item.status.toUpperCase(),
                    c,
                  ),
                  _infoRow(
                    tr('condition'),
                    item.condition ?? _variant?.condition ?? '—',
                    c,
                  ),
                  _infoRow(
                    tr('ptaStatus'),
                    item.ptaStatus ?? _variant?.ptaStatus ?? '—',
                    c,
                  ),
                  _infoRow(
                    tr('salePrice'),
                    formatPkr(item.salePrice),
                    c,
                    mono: true,
                  ),
                  if (_canSeeCosts)
                    _infoRow(
                      tr('purchasePrice'),
                      formatPkr(item.purchasePrice),
                      c,
                      mono: true,
                    ),
                  _infoRow(
                    tr('warrantyMonths'),
                    _variant == null
                        ? '—'
                        : '${_variant!.warrantyMonths}',
                    c,
                    mono: true,
                  ),
                  _infoRow(
                    tr('imeiHistory'),
                    _warrantyLabel(item, tr),
                    c,
                  ),
                  if (item.warrantyStart != null)
                    _infoRow(
                      'Warranty',
                      '${item.warrantyStart!.toString().substring(0, 10)} → ${item.warrantyEnd?.toString().substring(0, 10) ?? '—'}',
                      c,
                      mono: true,
                    ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Text(tr('saleHistory'), style: CyberTextStyles.subtitle(c)),
            const SizedBox(height: 8),
            if (_sale == null)
              CyberCard(
                child: Text(
                  tr('noData'),
                  style: CyberTextStyles.bodySecondary(c),
                ),
              )
            else
              CyberCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _infoRow(
                      tr('invoiceNo'),
                      _sale!.invoiceNo,
                      c,
                      mono: true,
                    ),
                    _infoRow(
                      tr('soldOn'),
                      _sale!.saleDate.toString().substring(0, 16),
                      c,
                    ),
                    _infoRow(
                      tr('soldTo'),
                      [
                        if (_sale!.customerName != null)
                          _sale!.customerName!,
                        if (_sale!.customerPhone != null)
                          _sale!.customerPhone!,
                      ].join(' · ').ifEmpty(tr('walkIn')),
                      c,
                    ),
                    _infoRow(
                      tr('grandTotal'),
                      formatPkr(_sale!.grandTotal),
                      c,
                      mono: true,
                    ),
                    _infoRow(tr('status'), _sale!.status, c),
                    if (_returnCount > 0)
                      _infoRow(
                        tr('returnItem'),
                        '$_returnCount',
                        c,
                        mono: true,
                      ),
                  ],
                ),
              ),
          ],
        ],
      ),
    );
  }

  Widget _infoRow(
    String label,
    String value,
    CyberColors c, {
    bool mono = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 130,
            child: Text(label, style: CyberTextStyles.caption(c)),
          ),
          Expanded(
            child: Text(
              value,
              style: mono
                  ? CyberTextStyles.mono(c, size: 14)
                  : CyberTextStyles.body(c, size: 14),
            ),
          ),
        ],
      ),
    );
  }
}

extension _IfEmpty on String {
  String ifEmpty(String fallback) => isEmpty ? fallback : this;
}
