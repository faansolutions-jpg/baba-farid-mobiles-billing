library;

/// Invoice screen (route `/invoice/:saleId`).
///
/// Loads the sale via [SaleRepository.getSale], resolves IMEI numbers
/// and warranty months through [SalePrintData], and shows the bill:
/// shop header, invoice no + date, customer, line items (product, IMEI
/// where applicable, warranty), totals, payment method + status +
/// balance due, and a QR code for the warranty lookup.
///
/// Actions: Print receipt (thermal, width from settings), Print
/// invoice (A4 PDF), Save / Share PDF (`share_plus`), Share on
/// WhatsApp (wa.me link), Done (back to `/dashboard`).
///
/// Only sale prices are shown — never cost or profit — so cashiers
/// cannot see costs here (README.md §2, DECISIONS.md #13).
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../../core/l10n/app_strings.dart';
import '../../core/theme/app_theme.dart';
import '../../core/theme/cyber_text_styles.dart';
import '../../core/theme/cyber_widgets.dart';
import '../../domain/models/settings.dart';
import '../../domain/money.dart';
import '../../core/providers/app_providers.dart';
import '../printing/print_service.dart';
import '../printing/receipt_builder.dart';
import '../printing/sale_print_data.dart';

class InvoiceScreen extends ConsumerStatefulWidget {
  const InvoiceScreen({super.key, required this.saleId});

  final String saleId;

  @override
  ConsumerState<InvoiceScreen> createState() => _InvoiceScreenState();
}

class _InvoiceScreenState extends ConsumerState<InvoiceScreen> {
  late final Future<SalePrintData?> _loadFuture;
  bool _printingReceipt = false;
  bool _printingInvoice = false;
  bool _sharingPdf = false;
  bool _sharingWhatsApp = false;

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

  String _tr(String key) =>
      AppStrings.tr(key, language: ref.read(languageProvider));

  void _snack(String message, {bool isError = false}) {
    if (!mounted) return;
    final c = ref.read(themeNotifierProvider).colors;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? c.error : c.card,
      ),
    );
  }

  Future<void> _printReceipt(SalePrintData data) async {
    if (_printingReceipt) return;
    setState(() => _printingReceipt = true);
    try {
      await PrintService.printReceipt(
        data,
        width: receiptWidthFromSettings(data.settings.printerWidth),
      );
    } catch (_) {
      _snack(_tr('printFailed'), isError: true);
    } finally {
      if (mounted) setState(() => _printingReceipt = false);
    }
  }

  Future<void> _printInvoice(SalePrintData data) async {
    if (_printingInvoice) return;
    setState(() => _printingInvoice = true);
    try {
      await PrintService.printInvoice(data);
    } catch (_) {
      _snack(_tr('printFailed'), isError: true);
    } finally {
      if (mounted) setState(() => _printingInvoice = false);
    }
  }

  Future<void> _sharePdf(SalePrintData data) async {
    if (_sharingPdf) return;
    setState(() => _sharingPdf = true);
    try {
      final ok = await PrintService.shareInvoicePdf(data);
      if (ok) {
        _snack(_tr('pdfReady'));
      } else {
        _snack(_tr('printFailed'), isError: true);
      }
    } finally {
      if (mounted) setState(() => _sharingPdf = false);
    }
  }

  Future<void> _shareWhatsApp(SalePrintData data) async {
    if (_sharingWhatsApp) return;
    setState(() => _sharingWhatsApp = true);
    try {
      final message = whatsappMessageFor(data.sale, data.settings);
      final ok = await PrintService.shareOnWhatsApp(
        phone: data.sale.customerPhone,
        message: message,
      );
      if (!ok) {
        _snack(_tr('whatsappFailed'), isError: true);
      }
    } finally {
      if (mounted) setState(() => _sharingWhatsApp = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = ref.watch(themeNotifierProvider).colors;
    final lang = ref.watch(languageProvider);
    String tr(String key) => AppStrings.tr(key, language: lang);

    return Scaffold(
      appBar: CyberAppBar(title: tr('invoice')),
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
                    Icon(Icons.receipt_long_outlined,
                        size: 56, color: c.error),
                    const SizedBox(height: 16),
                    Text(
                      snapshot.hasError
                          ? tr('somethingWentWrong')
                          : tr('invoiceNotFound'),
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
          return _InvoiceBody(
            data: snapshot.data!,
            onPrintReceipt: () => _printReceipt(snapshot.data!),
            onPrintInvoice: () => _printInvoice(snapshot.data!),
            onSharePdf: () => _sharePdf(snapshot.data!),
            onShareWhatsApp: () => _shareWhatsApp(snapshot.data!),
            printingReceipt: _printingReceipt,
            printingInvoice: _printingInvoice,
            sharingPdf: _sharingPdf,
            sharingWhatsApp: _sharingWhatsApp,
          );
        },
      ),
    );
  }
}

class _InvoiceBody extends ConsumerWidget {
  const _InvoiceBody({
    required this.data,
    required this.onPrintReceipt,
    required this.onPrintInvoice,
    required this.onSharePdf,
    required this.onShareWhatsApp,
    required this.printingReceipt,
    required this.printingInvoice,
    required this.sharingPdf,
    required this.sharingWhatsApp,
  });

  final SalePrintData data;
  final VoidCallback onPrintReceipt;
  final VoidCallback onPrintInvoice;
  final VoidCallback onSharePdf;
  final VoidCallback onShareWhatsApp;
  final bool printingReceipt;
  final bool printingInvoice;
  final bool sharingPdf;
  final bool sharingWhatsApp;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c = ref.watch(themeNotifierProvider).colors;
    final lang = ref.watch(languageProvider);
    String tr(String key) => AppStrings.tr(key, language: lang);
    final sale = data.sale;
    final settings = data.settings;
    final dateFmt = DateFormat('d MMM yyyy, hh:mm a');
    final isPaid = sale.balanceDue == 0;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // --- Shop header -------------------------------------------------
          CyberCard(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Image.asset(
                  'assets/logo.png',
                  width: 64,
                  height: 64,
                  fit: BoxFit.contain,
                  errorBuilder: (ctx, err, st) => Icon(
                    Icons.phone_android,
                    size: 56,
                    color: c.primary,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        settings.shopName.toUpperCase(),
                        style: CyberTextStyles.title(c, size: 18),
                      ),
                      Text(
                        settings.shopAddress,
                        style: CyberTextStyles.bodySecondary(c, size: 13),
                      ),
                      Text(
                        '${settings.shopPhone}  ·  ${settings.shopPhone2}',
                        style: CyberTextStyles.mono(c, size: 13),
                      ),
                      Text(
                        settings.shopEmail,
                        style: CyberTextStyles.bodySecondary(c, size: 13),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          // --- Invoice no / date / status ----------------------------------
          CyberCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${tr('invoiceNo')} ${sale.invoiceNo}',
                            style: CyberTextStyles.mono(c, size: 16),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            dateFmt.format(sale.saleDate),
                            style: CyberTextStyles.bodySecondary(c),
                          ),
                        ],
                      ),
                    ),
                    CyberBadge(
                      label: paymentStatusLabel(
                        sale.paymentStatus,
                        lang,
                      ).toUpperCase(),
                      color: isPaid ? c.success : c.warning,
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  '${tr('customer')}: '
                  '${sale.customerName ?? tr('walkInCustomer')}',
                  style: CyberTextStyles.body(c),
                ),
                if (sale.customerPhone != null &&
                    sale.customerPhone!.isNotEmpty)
                  Text(
                    '${tr('customerPhone')}: ${sale.customerPhone}',
                    style: CyberTextStyles.mono(c, size: 14),
                  ),
              ],
            ),
          ),
          // --- Line items ----------------------------------------------------
          CyberCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                for (final item in sale.items) ...[
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item.nameSnapshot,
                              style: CyberTextStyles.body(c),
                            ),
                            if (data.imeiFor(item) != null)
                              Text(
                                '${tr('imei')}: ${data.imeiFor(item)}',
                                style: CyberTextStyles.imei(c, size: 13),
                              ),
                            if (data.warrantyMonthsFor(item) > 0)
                              Text(
                                '${tr('warranty')}: '
                                '${data.warrantyMonthsFor(item)} '
                                '${tr('months')}',
                                style: CyberTextStyles.bodySecondary(c,
                                    size: 13),
                              ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '${item.quantity} x ${formatPkr(item.unitPrice)}',
                        style: CyberTextStyles.mono(c, size: 13),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        formatPkr(item.total),
                        style: CyberTextStyles.mono(c, size: 14),
                      ),
                    ],
                  ),
                  if (item != sale.items.last)
                    Divider(color: c.border, height: 20),
                ],
              ],
            ),
          ),
          // --- Totals ---------------------------------------------------------
          CyberCard(
            child: Column(
              children: [
                _TotalRow(
                  label: tr('subtotal'),
                  value: formatPkr(sale.subtotal),
                ),
                if (sale.discountAmount > 0)
                  _TotalRow(
                    label: tr('discount'),
                    value: '- ${formatPkr(sale.discountAmount)}',
                  ),
                if (sale.taxAmount > 0)
                  _TotalRow(
                    label: tr('tax'),
                    value: formatPkr(sale.taxAmount),
                  ),
                Divider(color: c.border),
                _TotalRow(
                  label: tr('grandTotal'),
                  value: formatPkr(sale.grandTotal),
                  bold: true,
                ),
                _TotalRow(
                  label: tr('paid'),
                  value: formatPkr(sale.paidAmount),
                ),
                if (sale.balanceDue > 0)
                  _TotalRow(
                    label: tr('balance'),
                    value: formatPkr(sale.balanceDue),
                    bold: true,
                    highlight: true,
                  ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        '${tr('paymentMethod')}: '
                        '${paymentMethodLabel(sale.paymentMethod, lang)}',
                        style: CyberTextStyles.body(c),
                      ),
                    ),
                  ],
                ),
                if (isPaid)
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text(
                        tr('paidInFull'),
                        style: CyberTextStyles.success(c),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          // --- QR warranty -----------------------------------------------------
          CyberCard(
            child: Column(
              children: [
                Text(
                  tr('scanToVerify'),
                  style: CyberTextStyles.label(c, size: 13),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                Container(
                  color: Colors.white,
                  padding: const EdgeInsets.all(12),
                  child: QrImageView(
                    data: warrantyDeepLinkForSale(sale.id),
                    version: QrVersions.auto,
                    size: 180,
                    backgroundColor: Colors.white,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  sale.id,
                  style: CyberTextStyles.mono(c, size: 12)
                      .copyWith(color: c.textSecondary),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          // --- Actions ---------------------------------------------------------
          CyberButton(
            label: tr('printReceipt'),
            icon: Icons.receipt_long,
            isLoading: printingReceipt,
            onPressed: printingReceipt ? null : onPrintReceipt,
          ),
          const SizedBox(height: 12),
          CyberButton(
            label: tr('printInvoiceA4'),
            icon: Icons.print_outlined,
            variant: CyberButtonVariant.ghost,
            isLoading: printingInvoice,
            onPressed: printingInvoice ? null : onPrintInvoice,
          ),
          const SizedBox(height: 12),
          CyberButton(
            label: tr('saveSharePdf'),
            icon: Icons.picture_as_pdf_outlined,
            variant: CyberButtonVariant.ghost,
            isLoading: sharingPdf,
            onPressed: sharingPdf ? null : onSharePdf,
          ),
          const SizedBox(height: 12),
          CyberButton(
            label: tr('whatsappShare'),
            icon: Icons.chat_outlined,
            variant: CyberButtonVariant.ghost,
            isLoading: sharingWhatsApp,
            onPressed: sharingWhatsApp ? null : onShareWhatsApp,
          ),
          const SizedBox(height: 12),
          CyberButton(
            label: tr('done'),
            icon: Icons.check,
            onPressed: () => context.go('/dashboard'),
          ),
          const SizedBox(height: 8),
          Text(
            tr('warrantyTerms'),
            style: CyberTextStyles.caption(c),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _TotalRow extends ConsumerWidget {
  const _TotalRow({
    required this.label,
    required this.value,
    this.bold = false,
    this.highlight = false,
  });

  final String label;
  final String value;
  final bool bold;
  final bool highlight;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c = ref.watch(themeNotifierProvider).colors;
    final labelStyle = bold
        ? CyberTextStyles.subtitle(c, size: 15)
        : CyberTextStyles.body(c);
    final valueStyle = (bold
            ? CyberTextStyles.amount(c, size: 17)
            : CyberTextStyles.mono(c, size: 15))
        .copyWith(color: highlight ? c.warning : null);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: labelStyle),
          Text(value, style: valueStyle),
        ],
      ),
    );
  }
}
