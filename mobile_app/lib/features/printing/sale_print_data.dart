library;

/// Data a receipt / PDF invoice / warranty card needs about one sale,
/// plus the resolver that fills it in from the repositories.
///
/// The invoice screen, the QR warranty screens, the thermal receipt
/// builder and the A4 PDF builder all share this type so the IMEI and
/// warranty shown on paper always match the screen.
///
/// Only *sale* prices are carried here — never purchase cost or profit —
/// so a cashier can never see costs through printing (DECISIONS.md #13,
/// README.md §2).
import '../../data/repositories/product_repository.dart';
import '../../core/l10n/app_strings.dart';
import '../../domain/models/sale.dart';
import '../../domain/models/settings.dart';

/// The in-app warranty deep link encoded in the invoice QR code
/// (DECISIONS.md #19 records the older `https://.../verify` form; the
/// M4 brief specifies this `baba-farid-mobiles://` route, which the
/// router opens on the `/warranty/:saleId` screen).
String warrantyDeepLinkForSale(String saleId) =>
    'baba-farid-mobiles://warranty/$saleId';

/// Adds [months] calendar months to [date], clamping the day to the
/// last day of the target month (e.g. 31 Jan + 1 month = 28 Feb).
DateTime addMonths(DateTime date, int months) {
  final total = (date.year * 12 + (date.month - 1)) + months;
  final year = total ~/ 12;
  final month = total % 12 + 1;
  final lastDay = DateTime(year, month + 1, 0).day;
  final day = date.day > lastDay ? lastDay : date.day;
  return DateTime(year, month, day, date.hour, date.minute);
}

/// Warranty state of one sold device, from its warranty end date.
enum WarrantyStatus { active, expired, none }

WarrantyStatus warrantyStatusFor(DateTime? warrantyEnd, DateTime now) {
  if (warrantyEnd == null) return WarrantyStatus.none;
  return warrantyEnd.isAfter(now)
      ? WarrantyStatus.active
      : WarrantyStatus.expired;
}

/// Everything the printers / warranty screens need about one sale.
class SalePrintData {
  const SalePrintData({
    required this.sale,
    required this.settings,
    this.imeiByItemId = const <String, String>{},
    this.warrantyMonthsByItemId = const <String, int>{},
    this.warrantyEndByItemId = const <String, DateTime?>{},
  });

  final Sale sale;
  final Settings settings;

  /// saleItemId -> IMEI number (only lines sold by IMEI have one).
  final Map<String, String> imeiByItemId;

  /// saleItemId -> warranty months from the sold variant (0 = none).
  final Map<String, int> warrantyMonthsByItemId;

  /// saleItemId -> warranty end date (IMEI record's end when stored,
  /// otherwise purchase date + warranty months).
  final Map<String, DateTime?> warrantyEndByItemId;

  String? imeiFor(SaleItem item) => imeiByItemId[item.id];

  int warrantyMonthsFor(SaleItem item) =>
      warrantyMonthsByItemId[item.id] ?? 0;

  DateTime? warrantyEndFor(SaleItem item) => warrantyEndByItemId[item.id];

  WarrantyStatus warrantyStatusForItem(SaleItem item, DateTime now) {
    final months = warrantyMonthsFor(item);
    final end = warrantyEndFor(item);
    if (months <= 0 && end == null) return WarrantyStatus.none;
    return warrantyStatusFor(end, now);
  }
}

/// Resolves IMEI numbers + warranty months/ends for every line of
/// [sale]. Never throws: a line whose IMEI/variant cannot be read
/// simply shows no IMEI/warranty detail instead of failing the bill.
Future<SalePrintData> resolveSalePrintData({
  required Sale sale,
  required Settings settings,
  required ProductRepository products,
}) async {
  final imeiByItemId = <String, String>{};
  final monthsByItemId = <String, int>{};
  final endByItemId = <String, DateTime?>{};
  for (final item in sale.items) {
    try {
      if (item.imeiItemId != null) {
        final imei = await products.getImeiItem(item.imeiItemId!);
        if (imei != null) {
          imeiByItemId[item.id] = imei.imei1;
          if (imei.warrantyEnd != null) {
            endByItemId[item.id] = imei.warrantyEnd;
          }
        }
      }
      if (item.variantId != null) {
        final variant = await products.getVariant(item.variantId!);
        if (variant != null && variant.warrantyMonths > 0) {
          monthsByItemId[item.id] = variant.warrantyMonths;
          endByItemId.putIfAbsent(
            item.id,
            () => addMonths(sale.saleDate, variant.warrantyMonths),
          );
        }
      }
    } catch (_) {
      // Leave the line without IMEI/warranty detail.
    }
  }
  return SalePrintData(
    sale: sale,
    settings: settings,
    imeiByItemId: imeiByItemId,
    warrantyMonthsByItemId: monthsByItemId,
    warrantyEndByItemId: endByItemId,
  );
}

/// Human label for a stored payment-method code, via [AppStrings].
String paymentMethodLabel(String method, String language) {
  switch (method) {
    case 'jazzcash':
      return AppStrings.tr('jazzCash', language: language);
    case 'easypaisa':
      return AppStrings.tr('easypaisa', language: language);
    case 'bank_transfer':
    case 'bank':
      return AppStrings.tr('bank', language: language);
    case 'card':
      return AppStrings.tr('card', language: language);
    case 'partial':
      return AppStrings.tr('partial', language: language);
    case 'udhaar':
      return AppStrings.tr('udhaar', language: language);
    case 'cash':
    default:
      return AppStrings.tr('cash', language: language);
  }
}

/// Human label for a stored payment-status code (`paid`/`partial`/
/// `unpaid`), via [AppStrings].
String paymentStatusLabel(String status, String language) {
  switch (status) {
    case 'partial':
      return AppStrings.tr('partial', language: language);
    case 'unpaid':
      return AppStrings.tr('udhaar', language: language);
    case 'paid':
    default:
      return AppStrings.tr('paid', language: language);
  }
}
