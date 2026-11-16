library;

/// Print + share actions for invoices and receipts.
///
/// * Thermal receipt and A4 invoice go through the `printing` package
///   (`Printing.layoutPdf`) — no fake printer SDK, no vendor app.
/// * The invoice PDF is shared with `share_plus` (`Share.shareXFiles`)
///   so the user can pick WhatsApp (or any app) from the system sheet.
/// * WhatsApp is a **wa.me share link by design** (DECISIONS.md #17):
///   there is no WhatsApp Business API here and this file never claims
///   to send a WhatsApp message directly — it opens a prefilled chat
///   (or the wa.me share page when no customer number is on the bill).
import 'dart:io';

import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:printing/printing.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/l10n/app_strings.dart';
import '../../domain/models/sale.dart';
import '../../domain/models/settings.dart';
import '../../domain/money.dart';
import 'pdf_invoice.dart';
import 'receipt_builder.dart';
import 'sale_print_data.dart';

/// Prefilled WhatsApp message for one bill (labels via [AppStrings]).
String whatsappMessageFor(Sale sale, Settings settings) {
  final lines = <String>[
    settings.shopName,
    '${AppStrings.tr('invoiceNo')} ${sale.invoiceNo}',
    '${AppStrings.tr('grandTotal')}: ${formatPkr(sale.grandTotal)}',
    '${AppStrings.tr('paid')}: ${formatPkr(sale.paidAmount)}',
  ];
  if (sale.balanceDue > 0) {
    lines.add(
      '${AppStrings.tr('balance')}: ${formatPkr(sale.balanceDue)}',
    );
  }
  lines.add(
    '${AppStrings.tr('paymentMethod')}: '
    '${paymentMethodLabel(sale.paymentMethod, 'en')}',
  );
  lines.add(AppStrings.tr('thankYou'));
  lines.add(settings.shopAddress);
  return lines.join('\n');
}

/// Normalises a Pakistani mobile to the international digits wa.me
/// needs (`92` + 10 digits), or null when the number is not a valid
/// Pakistani mobile. Accepts `03XX-XXXXXXX`, `+92 3XX XXXXXXX`,
/// `923XXXXXXXXX`. (Same rule as `phoneToWa` in Repairs; duplicated
/// here so printing does not depend on the Repairs feature.)
String? phoneToWa(String value) {
  final cleaned = value.replaceAll(RegExp(r'[\s-]'), '');
  final match = RegExp(r'^(\+92|92|0)?(3\d{9})$').firstMatch(cleaned);
  if (match == null) return null;
  return '92${match.group(2)!}';
}

/// Print + share actions. All methods are static; nothing here holds
/// state, and nothing here touches the database directly.
class PrintService {
  const PrintService._();

  /// Sends the thermal receipt for [data] to the system print dialog
  /// (or the connected thermal printer). [width] comes from the
  /// `printer.width` setting.
  static Future<void> printReceipt(
    SalePrintData data, {
    ReceiptWidth width = ReceiptWidth.mm80,
  }) async {
    await Printing.layoutPdf(
      name: 'Receipt ${data.sale.invoiceNo}',
      onLayout: (_) => buildReceiptPdf(data, width: width),
    );
  }

  /// Sends the A4 invoice PDF for [data] to the system print dialog.
  static Future<void> printInvoice(SalePrintData data) async {
    await Printing.layoutPdf(
      name: 'Invoice ${data.sale.invoiceNo}',
      format: PdfPageFormat.a4,
      onLayout: (_) => buildInvoicePdf(data),
    );
  }

  /// Writes the A4 invoice PDF to a temp file and opens the system
  /// share sheet (`share_plus`); the user picks WhatsApp or any app.
  /// Returns false only when the PDF could not be written/shared.
  static Future<bool> shareInvoicePdf(SalePrintData data) async {
    try {
      final bytes = await buildInvoicePdf(data);
      final dir = await getTemporaryDirectory();
      final safeNo =
          data.sale.invoiceNo.replaceAll(RegExp(r'[^A-Za-z0-9_-]'), '_');
      final file = File('${dir.path}/invoice-$safeNo.pdf');
      await file.writeAsBytes(bytes);
      await Share.shareXFiles(
        <XFile>[
          XFile(
            file.path,
            mimeType: 'application/pdf',
            name: 'invoice-$safeNo.pdf',
          ),
        ],
        text:
            '${data.settings.shopName} — ${AppStrings.tr('invoiceNo')} '
            '${data.sale.invoiceNo}',
        subject: '${AppStrings.tr('invoice')} ${data.sale.invoiceNo}',
      );
      return true;
    } catch (_) {
      return false;
    }
  }

  /// Opens WhatsApp with the prefilled bill message for [sale].
  ///
  /// When the bill has a valid customer phone, the chat opens with
  /// that number; otherwise the wa.me share page opens so the user
  /// picks the contact. Returns false when the link could not be
  /// opened (caller shows a message). This is a share link, not a
  /// WhatsApp Business API send.
  static Future<bool> shareOnWhatsApp({
    String? phone,
    required String message,
  }) async {
    final encoded = Uri.encodeComponent(message);
    final waPhone = phone == null ? null : phoneToWa(phone);
    final uri = waPhone != null
        ? Uri.parse('https://wa.me/$waPhone?text=$encoded')
        : Uri.parse('https://wa.me/?text=$encoded');
    try {
      return await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (_) {
      return false;
    }
  }
}
