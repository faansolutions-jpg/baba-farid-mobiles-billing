library;

/// Digital warranty card (route `/warranty/:saleId`).
///
/// The screen the invoice QR code opens: it shows the device(s) on the
/// bill, their IMEI numbers, purchase date, warranty months / valid
/// until / status, and the shop contact. Read-only — no cost or profit
/// figures are shown here either.
///
/// Warranty months come from the sold variant; the end date is the
/// IMEI record's stored end when present, otherwise purchase date +
/// warranty months (see [SalePrintData]).
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../core/l10n/app_strings.dart';
import '../../core/theme/app_theme.dart';
import '../../core/theme/cyber_text_styles.dart';
import '../../core/theme/cyber_widgets.dart';
import '../../domain/models/sale.dart';
import '../../domain/models/settings.dart';
import '../../core/providers/app_providers.dart';
import '../printing/sale_print_data.dart';

class QrWarrantyScreen extends ConsumerStatefulWidget {
  const QrWarrantyScreen({super.key, required this.saleId});

  final String saleId;

  @override
  ConsumerState<QrWarrantyScreen> createState() => _QrWarrantyScreenState();
}

class _QrWarrantyScreenState extends ConsumerState<QrWarrantyScreen> {
  late final Future<SalePrintData?> _loadFuture;

  @override
  void initState() {
    super.initState();
    _loadFuture = _load();
  }

  Future<SalePrintData?> _load() async {
    final sales = ref.read(saleRepositoryProvider);
    final products = ref.read(productRepositoryProvider);
    final settingsRepo = ref.read(settingsRepositoryProvider);
    final sale = await sales.getSale(widget.saleId);
    if (sale == null) return null;
    Settings settings;
    try {
      settings = await settingsRepo.getSettings();
    } catch (_) {
      settings = const Settings();
    }
    return resolveSalePrintData(
      sale: sale,
      settings: settings,
      products: products,
    );
  }

  @override
  Widget build(BuildContext context) {
    final c = ref.watch(themeNotifierProvider).colors;
    final lang = ref.watch(languageProvider);
    String tr(String key) => AppStrings.tr(key, language: lang);

    return Scaffold(
      appBar: CyberAppBar(title: tr('warrantyCard')),
      body: FutureBuilder<SalePrintData?>(
        future: _loadFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError || snapshot.data == null) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.verified_outlined, size: 56, color: c.error),
                    const SizedBox(height: 16),
                    Text(
                      tr('saleNotFound'),
                      style: CyberTextStyles.body(c),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),
                    CyberButton(
                      label: tr('done'),
                      onPressed: () => context.go('/dashboard'),
                    ),
                  ],
                ),
              ),
            );
          }
          return _WarrantyCard(data: snapshot.data!);
        },
      ),
    );
  }
}

class _WarrantyCard extends ConsumerWidget {
  const _WarrantyCard({required this.data});

  final SalePrintData data;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c = ref.watch(themeNotifierProvider).colors;
    final lang = ref.watch(languageProvider);
    String tr(String key) => AppStrings.tr(key, language: lang);
    final sale = data.sale;
    final settings = data.settings;
    final dateFmt = DateFormat('d MMM yyyy');
    final now = DateTime.now();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          CyberCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.verified, color: c.primary, size: 28),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        settings.shopName.toUpperCase(),
                        style: CyberTextStyles.title(c, size: 18),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  settings.shopAddress,
                  style: CyberTextStyles.bodySecondary(c),
                ),
                Text(
                  '${settings.shopPhone}  ·  ${settings.shopPhone2}',
                  style: CyberTextStyles.mono(c, size: 13),
                ),
                const SizedBox(height: 12),
                Text(
                  '${tr('invoiceNo')} ${sale.invoiceNo}',
                  style: CyberTextStyles.mono(c, size: 15),
                ),
                Text(
                  '${tr('purchaseDate')}: ${dateFmt.format(sale.saleDate)}',
                  style: CyberTextStyles.body(c),
                ),
                if (sale.customerName != null &&
                    sale.customerName!.isNotEmpty)
                  Text(
                    '${tr('customer')}: ${sale.customerName}',
                    style: CyberTextStyles.body(c),
                  ),
              ],
            ),
          ),
          for (final item in sale.items)
            _DeviceWarrantyTile(data: data, item: item, now: now),
          CyberCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(tr('warrantyTerms'), style: CyberTextStyles.caption(c)),
                const SizedBox(height: 12),
                CyberButton(
                  label: tr('viewInvoice'),
                  icon: Icons.receipt_long,
                  variant: CyberButtonVariant.ghost,
                  onPressed: () => context.push('/invoice/${sale.id}'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _DeviceWarrantyTile extends ConsumerWidget {
  const _DeviceWarrantyTile({
    required this.data,
    required this.item,
    required this.now,
  });

  final SalePrintData data;
  final SaleItem item;
  final DateTime now;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c = ref.watch(themeNotifierProvider).colors;
    final lang = ref.watch(languageProvider);
    String tr(String key) => AppStrings.tr(key, language: lang);
    final dateFmt = DateFormat('d MMM yyyy');
    final months = data.warrantyMonthsFor(item);
    final end = data.warrantyEndFor(item);
    final status = data.warrantyStatusForItem(item, now);
    final statusLabel = switch (status) {
      WarrantyStatus.active => tr('warrantyActive'),
      WarrantyStatus.expired => tr('warrantyExpired'),
      WarrantyStatus.none => tr('noWarranty'),
    };
    final statusColor = switch (status) {
      WarrantyStatus.active => c.success,
      WarrantyStatus.expired => c.error,
      WarrantyStatus.none => c.textSecondary,
    };

    return CyberCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  item.nameSnapshot,
                  style: CyberTextStyles.subtitle(c, size: 16),
                ),
              ),
              CyberBadge(label: statusLabel.toUpperCase(), color: statusColor),
            ],
          ),
          const SizedBox(height: 8),
          if (data.imeiFor(item) != null) ...[
            Text(tr('imei'), style: CyberTextStyles.label(c)),
            Text(
              data.imeiFor(item)!,
              style: CyberTextStyles.imei(c, size: 16),
            ),
            const SizedBox(height: 8),
          ],
          if (months > 0)
            Text(
              '${tr('warranty')}: $months ${tr('months')}',
              style: CyberTextStyles.body(c),
            ),
          if (end != null)
            Text(
              '${tr('warrantyValidUntil')}: ${dateFmt.format(end)}',
              style: CyberTextStyles.body(c),
            ),
        ],
      ),
    );
  }
}
