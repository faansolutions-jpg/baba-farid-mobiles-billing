library;

/// Warranty lookup by IMEI (route `/warranty/imei/:imei`).
///
/// The public-style lookup a customer reaches by scanning a QR code or
/// typing an IMEI: it shows the device, its IMEI, purchase date (when
/// sold), warranty months / valid until / status, and the shop contact,
/// plus a field to check another IMEI.
///
/// This is NOT the reports IMEI-history screen (`/reports/imei`,
/// owned by the reports agent): that screen shows the full IMEI life
/// (purchase, sale, returns); this one is the customer-facing
/// warranty card only.
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../core/l10n/app_strings.dart';
import '../../core/theme/app_theme.dart';
import '../../core/theme/cyber_text_styles.dart';
import '../../core/theme/cyber_widgets.dart';
import '../../domain/models/imei_item.dart';
import '../../domain/models/product.dart';
import '../../domain/models/sale.dart';
import '../../core/providers/app_providers.dart';
import '../printing/sale_print_data.dart';

class WarrantyLookupScreen extends ConsumerStatefulWidget {
  const WarrantyLookupScreen({super.key, required this.imei});

  final String imei;

  @override
  ConsumerState<WarrantyLookupScreen> createState() =>
      _WarrantyLookupScreenState();
}

class _WarrantyLookupScreenState extends ConsumerState<WarrantyLookupScreen> {
  final _imeiController = TextEditingController();
  late Future<_LookupResult> _loadFuture;

  @override
  void initState() {
    super.initState();
    _loadFuture = _load(widget.imei);
    _imeiController.text = widget.imei;
  }

  @override
  void didUpdateWidget(WarrantyLookupScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.imei != widget.imei) {
      _imeiController.text = widget.imei;
      setState(() => _loadFuture = _load(widget.imei));
    }
  }

  @override
  void dispose() {
    _imeiController.dispose();
    super.dispose();
  }

  Future<_LookupResult> _load(String imei) async {
    final products = ref.read(productRepositoryProvider);
    final sales = ref.read(saleRepositoryProvider);
    final item = await products.getImeiByNumber(imei.trim());
    if (item == null) return const _LookupResult.notFound();
    Product? product;
    Sale? sale;
    int warrantyMonths = 0;
    try {
      product = await products.getProduct(item.productId);
    } catch (_) {
      product = null;
    }
    if (item.variantId != null) {
      try {
        final variant = await products.getVariant(item.variantId!);
        warrantyMonths = variant?.warrantyMonths ?? 0;
      } catch (_) {
        warrantyMonths = 0;
      }
    }
    if (item.soldSaleId != null) {
      try {
        sale = await sales.getSale(item.soldSaleId!);
      } catch (_) {
        sale = null;
      }
    }
    final end = item.warrantyEnd ??
        (sale != null && warrantyMonths > 0
            ? addMonths(sale.saleDate, warrantyMonths)
            : null);
    return _LookupResult.found(
      item: item,
      product: product,
      sale: sale,
      warrantyMonths: warrantyMonths,
      warrantyEnd: end,
    );
  }

  void _check() {
    final imei = _imeiController.text.trim();
    if (imei.isEmpty) return;
    if (imei == widget.imei) {
      setState(() => _loadFuture = _load(imei));
    } else {
      context.push('/warranty/imei/$imei');
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = ref.watch(themeNotifierProvider).colors;
    final lang = ref.watch(languageProvider);
    String tr(String key) => AppStrings.tr(key, language: lang);

    return Scaffold(
      appBar: CyberAppBar(title: tr('warrantyLookup')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              tr('enterImeiToCheck'),
              style: CyberTextStyles.body(c),
            ),
            const SizedBox(height: 12),
            CyberTextField(
              controller: _imeiController,
              label: tr('imei'),
              hint: tr('imeiHint'),
              monospace: true,
              keyboardType: TextInputType.number,
              maxLength: 15,
              textInputAction: TextInputAction.search,
              onSubmitted: (_) => _check(),
            ),
            const SizedBox(height: 12),
            CyberButton(
              label: tr('checkWarranty'),
              icon: Icons.verified_outlined,
              onPressed: _check,
            ),
            const SizedBox(height: 16),
            FutureBuilder<_LookupResult>(
              future: _loadFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.all(24),
                      child: CircularProgressIndicator(),
                    ),
                  );
                }
                if (snapshot.hasError) {
                  return Center(
                    child: Text(
                      tr('somethingWentWrong'),
                      style: CyberTextStyles.body(c),
                    ),
                  );
                }
                final result = snapshot.data;
                if (result == null || !result.found) {
                  return CyberCard(
                    child: Column(
                      children: [
                        Icon(Icons.search_off, size: 48, color: c.warning),
                        const SizedBox(height: 12),
                        Text(
                          tr('imeiNotFound'),
                          style: CyberTextStyles.body(c),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          widget.imei,
                          style: CyberTextStyles.imei(c, size: 15),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  );
                }
                return _FoundCard(result: result);
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _LookupResult {
  const _LookupResult.found({
    required this.item,
    required this.product,
    required this.sale,
    required this.warrantyMonths,
    required this.warrantyEnd,
  }) : found = true;

  const _LookupResult.notFound()
      : found = false,
        item = null,
        product = null,
        sale = null,
        warrantyMonths = 0,
        warrantyEnd = null;

  final bool found;
  final ImeiItem? item;
  final Product? product;
  final Sale? sale;
  final int warrantyMonths;
  final DateTime? warrantyEnd;
}

class _FoundCard extends ConsumerWidget {
  const _FoundCard({required this.result});

  final _LookupResult result;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c = ref.watch(themeNotifierProvider).colors;
    final lang = ref.watch(languageProvider);
    String tr(String key) => AppStrings.tr(key, language: lang);
    final dateFmt = DateFormat('d MMM yyyy');
    final item = result.item!;
    final now = DateTime.now();
    final status = warrantyStatusFor(result.warrantyEnd, now);
    final isSold = item.status == ImeiStatus.sold;
    final statusLabel = !isSold
        ? tr('availableInStock')
        : switch (status) {
            WarrantyStatus.active => tr('warrantyActive'),
            WarrantyStatus.expired => tr('warrantyExpired'),
            WarrantyStatus.none => tr('noWarranty'),
          };
    final statusColor = !isSold
        ? c.secondary
        : switch (status) {
            WarrantyStatus.active => c.success,
            WarrantyStatus.expired => c.error,
            WarrantyStatus.none => c.textSecondary,
          };

    // Device name: the sold bill's line snapshot when available,
    // otherwise the product name.
    String deviceName = result.product?.name ?? tr('unknownDevice');
    if (result.sale != null) {
      final line = result.sale!.items
          .where((i) => i.imeiItemId == item.id)
          .firstOrNull;
      if (line != null) deviceName = line.nameSnapshot;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        CyberCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      deviceName,
                      style: CyberTextStyles.subtitle(c, size: 16),
                    ),
                  ),
                  CyberBadge(
                    label: statusLabel.toUpperCase(),
                    color: statusColor,
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(tr('imei'), style: CyberTextStyles.label(c)),
              Text(item.imei1, style: CyberTextStyles.imei(c, size: 16)),
              if (item.imei2 != null && item.imei2!.isNotEmpty) ...[
                const SizedBox(height: 8),
                Text('${tr('imei')} 2', style: CyberTextStyles.label(c)),
                Text(item.imei2!, style: CyberTextStyles.imei(c, size: 15)),
              ],
              const SizedBox(height: 12),
              if (result.sale != null) ...[
                Text(
                  '${tr('purchaseDate')}: '
                  '${dateFmt.format(result.sale!.saleDate)}',
                  style: CyberTextStyles.body(c),
                ),
                Text(
                  '${tr('invoiceNo')} ${result.sale!.invoiceNo}',
                  style: CyberTextStyles.mono(c, size: 14),
                ),
                if (result.sale!.customerName != null &&
                    result.sale!.customerName!.isNotEmpty)
                  Text(
                    '${tr('customer')}: ${result.sale!.customerName}',
                    style: CyberTextStyles.body(c),
                  ),
              ],
              if (result.warrantyMonths > 0)
                Text(
                  '${tr('warranty')}: ${result.warrantyMonths} '
                  '${tr('months')}',
                  style: CyberTextStyles.body(c),
                ),
              if (result.warrantyEnd != null)
                Text(
                  '${tr('warrantyValidUntil')}: '
                  '${dateFmt.format(result.warrantyEnd!)}',
                  style: CyberTextStyles.body(c),
                ),
              if (isSold && result.warrantyMonths <= 0)
                Text(tr('noWarranty'), style: CyberTextStyles.body(c)),
            ],
          ),
        ),
        if (result.sale != null) ...[
          const SizedBox(height: 4),
          CyberButton(
            label: tr('viewInvoice'),
            icon: Icons.receipt_long,
            variant: CyberButtonVariant.ghost,
            onPressed: () => context.push('/invoice/${result.sale!.id}'),
          ),
        ],
      ],
    );
  }
}
