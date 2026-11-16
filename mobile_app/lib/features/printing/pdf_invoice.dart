library;

/// A4 PDF invoice (print-ready) for one sale.
///
/// Same content as the invoice screen — shop header with logo, invoice
/// no + date, customer, item table (product, IMEI, warranty), totals,
/// payment method + status + balance due, QR code image for the
/// warranty lookup, terms — built with the `pdf` package.
///
/// Returns the PDF bytes (`Uint8List`); callers print with
/// `Printing.layoutPdf` or share the bytes with `share_plus`.
///
/// Labels are English (see the note in `receipt_builder.dart`: the
/// `pdf` package's built-in fonts are Latin-only; bundle a TTF to
/// enable Urdu printing). Amounts are whole PKR, in monospace.
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/services.dart' show rootBundle;
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:qr_flutter/qr_flutter.dart';

import '../../core/l10n/app_strings.dart';
import '../../domain/money.dart';
import 'sale_print_data.dart';

/// Builds the A4 invoice PDF for [data] and returns its bytes.
Future<Uint8List> buildInvoicePdf(SalePrintData data) async {
  final sale = data.sale;
  final settings = data.settings;
  final dateFmt = DateFormat('d MMM yyyy, hh:mm a');
  final shortDateFmt = DateFormat('d MMM yyyy');
  String tr(String key) => AppStrings.tr(key);

  final base = pw.TextStyle(font: pw.Font.helvetica(), fontSize: 10);
  final baseBold = pw.TextStyle(font: pw.Font.helveticaBold(), fontSize: 10);
  final mono = pw.TextStyle(font: pw.Font.courier(), fontSize: 10);
  final monoBold = pw.TextStyle(font: pw.Font.courierBold(), fontSize: 10);
  final small = pw.TextStyle(font: pw.Font.helvetica(), fontSize: 9);
  final smallMono = pw.TextStyle(font: pw.Font.courier(), fontSize: 8);

  // Shop logo (assets/logo.png); the invoice still builds without it.
  pw.MemoryImage? logo;
  try {
    final bytes = await rootBundle.load('assets/logo.png');
    logo = pw.MemoryImage(bytes.buffer.asUint8List());
  } catch (_) {
    logo = null;
  }

  // QR code image for the warranty deep link.
  pw.MemoryImage? qrImage;
  try {
    final painter = QrPainter(
      data: warrantyDeepLinkForSale(sale.id),
      version: QrVersions.auto,
      errorCorrectionLevel: QrErrorCorrectLevel.M,
      eyeStyle: const QrEyeStyle(
        eyeShape: QrEyeShape.square,
        color: ui.Color(0xFF000000),
      ),
      dataModuleStyle: const QrDataModuleStyle(
        dataModuleShape: QrDataModuleShape.square,
        color: ui.Color(0xFF000000),
      ),
    );
    final qrBytes = await painter.toImageData(180);
    if (qrBytes != null) {
      qrImage = pw.MemoryImage(qrBytes.buffer.asUint8List());
    }
  } catch (_) {
    qrImage = null;
  }

  pw.Widget totalRow(String label, String value, {bool bold = false}) =>
      pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text(label, style: bold ? baseBold : base),
          pw.Text(value, style: bold ? monoBold : mono),
        ],
      );

  final doc = pw.Document();
  doc.addPage(
    pw.Page(
      pageFormat: PdfPageFormat.a4,
      margin: const pw.EdgeInsets.all(32),
      build: (pw.Context context) => pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.stretch,
        children: [
          // --- Header: logo + shop, invoice title + no/date ------------
          pw.Row(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              if (logo != null)
                pw.Container(
                  width: 64,
                  height: 64,
                  margin: const pw.EdgeInsets.only(right: 12),
                  child: pw.Image(logo),
                ),
              pw.Expanded(
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(
                      settings.shopName.toUpperCase(),
                      style: pw.TextStyle(
                        font: pw.Font.helveticaBold(),
                        fontSize: 18,
                      ),
                    ),
                    pw.Text(settings.shopAddress, style: small),
                    pw.Text(
                      '${settings.shopPhone}  ·  ${settings.shopPhone2}',
                      style: smallMono,
                    ),
                    pw.Text(settings.shopEmail, style: small),
                  ],
                ),
              ),
              pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.end,
                children: [
                  pw.Text(
                    tr('invoice').toUpperCase(),
                    style: pw.TextStyle(
                      font: pw.Font.helveticaBold(),
                      fontSize: 20,
                    ),
                  ),
                  pw.Text(
                    '${tr('invoiceNo')} ${sale.invoiceNo}',
                    style: monoBold,
                  ),
                  pw.Text(dateFmt.format(sale.saleDate), style: smallMono),
                ],
              ),
            ],
          ),
          pw.SizedBox(height: 16),
          pw.Divider(color: PdfColors.grey400),
          // --- Customer --------------------------------------------------
          pw.Row(
            children: [
              pw.Text('${tr('customer')}: ', style: baseBold),
              pw.Text(
                sale.customerName ?? tr('walkInCustomer'),
                style: base,
              ),
              if (sale.customerPhone != null &&
                  sale.customerPhone!.isNotEmpty) ...[
                pw.SizedBox(width: 16),
                pw.Text('${tr('customerPhone')}: ', style: baseBold),
                pw.Text(sale.customerPhone!, style: mono),
              ],
            ],
          ),
          pw.SizedBox(height: 16),
          // --- Items ------------------------------------------------------
          pw.Table(
            border: pw.TableBorder.all(color: PdfColors.grey400),
            columnWidths: const {
              0: pw.FlexColumnWidth(3),
              1: pw.FlexColumnWidth(2),
              2: pw.FlexColumnWidth(0.7),
              3: pw.FlexColumnWidth(1.3),
              4: pw.FlexColumnWidth(1.3),
            },
            children: [
              pw.TableRow(
                decoration:
                    const pw.BoxDecoration(color: PdfColors.grey200),
                children: [
                  for (final h in <String>[
                    tr('products'),
                    tr('imei'),
                    tr('qty'),
                    tr('unitPrice'),
                    tr('total'),
                  ])
                    pw.Padding(
                      padding: const pw.EdgeInsets.all(6),
                      child: pw.Text(h, style: baseBold),
                    ),
                ],
              ),
              for (final item in sale.items)
                pw.TableRow(
                  children: [
                    pw.Padding(
                      padding: const pw.EdgeInsets.all(6),
                      child: pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          pw.Text(item.nameSnapshot, style: base),
                          if (data.warrantyMonthsFor(item) > 0)
                            pw.Text(
                              '${tr('warranty')}: '
                              '${data.warrantyMonthsFor(item)} '
                              '${tr('months')}',
                              style: small,
                            ),
                        ],
                      ),
                    ),
                    pw.Padding(
                      padding: const pw.EdgeInsets.all(6),
                      child: pw.Text(
                        data.imeiFor(item) ?? '-',
                        style: smallMono,
                      ),
                    ),
                    pw.Padding(
                      padding: const pw.EdgeInsets.all(6),
                      child: pw.Text(
                        '${item.quantity}',
                        style: mono,
                        textAlign: pw.TextAlign.right,
                      ),
                    ),
                    pw.Padding(
                      padding: const pw.EdgeInsets.all(6),
                      child: pw.Text(
                        formatPkr(item.unitPrice),
                        style: mono,
                        textAlign: pw.TextAlign.right,
                      ),
                    ),
                    pw.Padding(
                      padding: const pw.EdgeInsets.all(6),
                      child: pw.Text(
                        formatPkr(item.total),
                        style: mono,
                        textAlign: pw.TextAlign.right,
                      ),
                    ),
                  ],
                ),
            ],
          ),
          pw.SizedBox(height: 12),
          // --- Totals ------------------------------------------------------
          pw.Row(
            children: [
              pw.Spacer(),
              pw.SizedBox(
                width: 240,
                child: pw.Column(
                  children: [
                    totalRow(tr('subtotal'), formatPkr(sale.subtotal)),
                    if (sale.discountAmount > 0)
                      totalRow(
                        tr('discount'),
                        '- ${formatPkr(sale.discountAmount)}',
                      ),
                    if (sale.taxAmount > 0)
                      totalRow(tr('tax'), formatPkr(sale.taxAmount)),
                    pw.Divider(color: PdfColors.grey400),
                    totalRow(
                      tr('grandTotal'),
                      formatPkr(sale.grandTotal),
                      bold: true,
                    ),
                    totalRow(tr('paid'), formatPkr(sale.paidAmount)),
                    if (sale.balanceDue > 0)
                      totalRow(
                        tr('balance'),
                        formatPkr(sale.balanceDue),
                        bold: true,
                      ),
                  ],
                ),
              ),
            ],
          ),
          pw.SizedBox(height: 12),
          // --- Payment -----------------------------------------------------
          pw.Text(
            '${tr('paymentMethod')}: '
            '${paymentMethodLabel(sale.paymentMethod, 'en')}  ·  '
            '${tr('repairStatus')}: '
            '${paymentStatusLabel(sale.paymentStatus, 'en')}',
            style: base,
          ),
          if (sale.balanceDue == 0)
            pw.Text(tr('paidInFull'), style: baseBold)
          else
            pw.Text(
              '${tr('amountDue')}: ${formatPkr(sale.balanceDue)}',
              style: monoBold,
            ),
          pw.SizedBox(height: 20),
          // --- QR warranty --------------------------------------------------
          pw.Row(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              if (qrImage != null)
                pw.Container(
                  width: 110,
                  height: 110,
                  margin: const pw.EdgeInsets.only(right: 16),
                  child: pw.Image(qrImage),
                ),
              pw.Expanded(
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(tr('warrantyCard'), style: baseBold),
                    pw.Text(tr('scanToVerify'), style: base),
                    pw.Text(
                      warrantyDeepLinkForSale(sale.id),
                      style: smallMono,
                    ),
                    pw.Text(
                      '${tr('saleId')}: ${sale.id}',
                      style: smallMono,
                    ),
                    if (sale.items.any(
                      (i) => data.warrantyMonthsFor(i) > 0,
                    ))
                      pw.Text(
                        '${tr('purchaseDate')}: '
                        '${shortDateFmt.format(sale.saleDate)}',
                        style: small,
                      ),
                  ],
                ),
              ),
            ],
          ),
          pw.Spacer(),
          pw.Divider(color: PdfColors.grey400),
          // --- Terms + footer ----------------------------------------------
          pw.Text(tr('warrantyTerms'), style: small),
          pw.SizedBox(height: 8),
          pw.Text(tr('thankYou'), style: baseBold),
          pw.Text(
            '${settings.shopName}  ·  ${settings.shopAddress}  ·  '
            '${settings.shopPhone}',
            style: small,
          ),
        ],
      ),
    ),
  );
  return doc.save();
}
