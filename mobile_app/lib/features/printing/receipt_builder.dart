library;

/// Thermal receipt layout (58mm and 80mm) built as a `pdf` document so
/// it works with the `printing` package (`Printing.layoutPdf`).
///
/// No fake printer SDK is used: the receipt is a real PDF with a narrow
/// page width, which any ESC/POS driver, the system print dialog, or a
/// "save as PDF" flow can print. Monospace throughout, whole PKR only.
///
/// Layout: shop header, invoice no + date, items (name, qty x price,
/// IMEI lines), totals, payment method + status, warranty note, the
/// warranty link as text (printers that cannot do graphics still give
/// the customer a way to verify the warranty), "Thank you" footer.
import 'dart:typed_data';

import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import '../../core/l10n/app_strings.dart';
import '../../domain/money.dart';
import 'sale_print_data.dart';

/// Thermal paper width. 58mm is the small counter printer, 80mm the
/// standard one (DECISIONS.md #16).
enum ReceiptWidth { mm58, mm80 }

extension ReceiptWidthPoints on ReceiptWidth {
  /// Page width in PDF points (1 inch = 72pt).
  double get points => this == ReceiptWidth.mm58 ? 58 * 72 / 25.4 : 80 * 72 / 25.4;

  String get label => this == ReceiptWidth.mm58 ? '58mm' : '80mm';
}

/// Parses the stored printer width (`printer.width` setting: `58mm` /
/// `80mm`); anything else falls back to 80mm.
ReceiptWidth receiptWidthFromSettings(String value) =>
    value == '58mm' ? ReceiptWidth.mm58 : ReceiptWidth.mm80;

/// Builds the thermal receipt PDF for [data] at [width].
/// Returns the PDF bytes (pass them to `Printing.layoutPdf`).
///
/// Labels come from [AppStrings] (English): the `pdf` package's
/// built-in fonts are Latin-only, so Urdu labels would print as boxes
/// until a TTF font (e.g. Noto Nastaliq Urdu) is bundled under
/// `assets/fonts/` and wired into the builders. The on-screen invoice
/// and warranty screens are fully bilingual; only the printed output
/// is English-only for now.
Future<Uint8List> buildReceiptPdf(
  SalePrintData data, {
  ReceiptWidth width = ReceiptWidth.mm80,
}) async {
  final sale = data.sale;
  final settings = data.settings;
  final dateFmt = DateFormat('d MMM yyyy, hh:mm a');
  String tr(String key) => AppStrings.tr(key);

  final mono = pw.TextStyle(font: pw.Font.courier(), fontSize: 9);
  final monoBold = pw.TextStyle(font: pw.Font.courierBold(), fontSize: 9);
  final monoLarge = pw.TextStyle(font: pw.Font.courierBold(), fontSize: 12);
  final monoSmall = pw.TextStyle(font: pw.Font.courier(), fontSize: 8);

  // Characters per divider line: courier at 9pt is ~5.4pt per char.
  final chars = ((width.points - 12) / 5.4).floor();
  final divider = '-' * chars;

  pw.Widget text(String value, [pw.TextStyle? style]) => pw.Text(
        value,
        style: style ?? mono,
        softWrap: true,
      );

  pw.Widget centered(String value, [pw.TextStyle? style]) => pw.Text(
        value,
        style: style ?? mono,
        textAlign: pw.TextAlign.center,
        softWrap: true,
      );

  pw.Widget pair(String left, String right, [pw.TextStyle? style]) =>
      pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Expanded(child: pw.Text(left, style: style ?? mono)),
          pw.Text(right, style: style ?? mono),
        ],
      );

  final children = <pw.Widget>[
    centered(settings.shopName.toUpperCase(), monoLarge),
    centered(settings.shopAddress, monoSmall),
    centered('${settings.shopPhone}  ${settings.shopPhone2}', monoSmall),
    centered(settings.shopEmail, monoSmall),
    text(divider),
    pair('${tr('invoiceNo')} ${sale.invoiceNo}', dateFmt.format(sale.saleDate)),
    if (sale.customerName != null && sale.customerName!.isNotEmpty)
      text('${tr('customerName')}: ${sale.customerName}'),
    if (sale.customerPhone != null && sale.customerPhone!.isNotEmpty)
      text('${tr('customerPhone')}: ${sale.customerPhone}'),
    text(divider),
    for (final item in sale.items) ...[
      text(item.nameSnapshot),
      pair(
        '  ${item.quantity} x ${formatPkr(item.unitPrice)}',
        formatPkr(item.total),
      ),
      if (data.imeiFor(item) != null) text('  ${tr('imei')}: ${data.imeiFor(item)}'),
      if (item.discount > 0)
        pair('  ${tr('discount')}', '- ${formatPkr(item.discount)}'),
    ],
    text(divider),
    pair(tr('subtotal'), formatPkr(sale.subtotal)),
    if (sale.discountAmount > 0)
      pair(tr('discount'), '- ${formatPkr(sale.discountAmount)}'),
    if (sale.taxAmount > 0) pair(tr('tax'), formatPkr(sale.taxAmount)),
    pair(tr('grandTotal').toUpperCase(), formatPkr(sale.grandTotal), monoBold),
    pair(tr('paid'), formatPkr(sale.paidAmount)),
    if (sale.balanceDue > 0)
      pair(tr('balance'), formatPkr(sale.balanceDue), monoBold),
    text(divider),
    text('${tr('paymentMethod')}: '
        '${paymentMethodLabel(sale.paymentMethod, 'en')}'),
    text('${tr('repairStatus')}: '
        '${paymentStatusLabel(sale.paymentStatus, 'en')}'),
    if (sale.balanceDue == 0) text(tr('paidInFull')),
    for (final item in sale.items)
      if (data.warrantyMonthsFor(item) > 0)
        text(
          '${tr('warranty')}: ${item.nameSnapshot} - '
          '${data.warrantyMonthsFor(item)} ${tr('months')}',
          monoSmall,
        ),
    text(divider),
    // QR as text: printers without graphics still give the customer a
    // working warranty link (task brief; DECISIONS.md #16 fallback).
    centered('${tr('scanToVerify')}:', monoSmall),
    centered(warrantyDeepLinkForSale(sale.id), monoSmall),
    centered('${tr('saleId')}: ${sale.id}', monoSmall),
    text(divider),
    centered(tr('thankYou')),
    centered(settings.shopName),
  ];

  final doc = pw.Document();
  doc.addPage(
    pw.Page(
      pageFormat: PdfPageFormat(
        width.points,
        double.infinity,
        marginAll: 6,
      ),
      build: (pw.Context context) => pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.stretch,
        children: children,
      ),
    ),
  );
  return doc.save();
}
