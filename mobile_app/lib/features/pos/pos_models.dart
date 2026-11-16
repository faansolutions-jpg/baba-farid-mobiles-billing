library;

import '../../domain/money.dart';

/// One line in the POS cart. Kept separate from [SaleItem] (the saved
/// bill line) because the cart is edited live: price, quantity and
/// discount change before the bill is saved. All money is whole PKR.
///
/// A phone line always carries an [imeiItemId] and has quantity 1;
/// an accessory line has no IMEI and quantity >= 1.
class CartLine {
  const CartLine({
    required this.productId,
    this.variantId,
    this.imeiItemId,
    required this.name,
    this.imei1,
    required this.unitPrice,
    this.costPrice = 0,
    this.minPrice = 0,
    this.quantity = 1,
    this.discountValue = 0,
    this.discountIsPercent = false,
  });

  final String productId;
  final String? variantId;
  final String? imeiItemId;
  final String name;
  final String? imei1;
  final int unitPrice;
  final int costPrice;
  final int minPrice;
  final int quantity;
  final int discountValue;
  final bool discountIsPercent;

  bool get isPhone => imeiItemId != null;

  /// True when this line sells below the variant's minimum price and
  /// therefore needs owner/manager approval (DECISIONS.md #13).
  bool get isBelowMinPrice => minPrice > 0 && unitPrice < minPrice;

  int get lineSubtotal => unitPrice * quantity;

  int get discountAmount {
    if (discountIsPercent) {
      return applyDiscount(lineSubtotal, discountValue, true);
    }
    final flat = discountValue.clamp(0, lineSubtotal);
    return flat;
  }

  int get total => lineSubtotal - discountAmount;

  /// Profit on this line (owner/manager only — never shown to a
  /// cashier). Discount reduces profit.
  int get profit => (unitPrice - costPrice) * quantity - discountAmount;

  CartLine copyWith({
    String? productId,
    String? variantId,
    String? imeiItemId,
    String? name,
    String? imei1,
    int? unitPrice,
    int? costPrice,
    int? minPrice,
    int? quantity,
    int? discountValue,
    bool? discountIsPercent,
  }) =>
      CartLine(
        productId: productId ?? this.productId,
        variantId: variantId ?? this.variantId,
        imeiItemId: imeiItemId ?? this.imeiItemId,
        name: name ?? this.name,
        imei1: imei1 ?? this.imei1,
        unitPrice: unitPrice ?? this.unitPrice,
        costPrice: costPrice ?? this.costPrice,
        minPrice: minPrice ?? this.minPrice,
        quantity: quantity ?? this.quantity,
        discountValue: discountValue ?? this.discountValue,
        discountIsPercent: discountIsPercent ?? this.discountIsPercent,
      );

  Map<String, dynamic> toJson() => {
        'productId': productId,
        'variantId': variantId,
        'imeiItemId': imeiItemId,
        'name': name,
        'imei1': imei1,
        'unitPrice': unitPrice,
        'costPrice': costPrice,
        'minPrice': minPrice,
        'quantity': quantity,
        'discountValue': discountValue,
        'discountIsPercent': discountIsPercent,
      };

  factory CartLine.fromJson(Map<String, dynamic> json) => CartLine(
        productId: json['productId'] as String? ?? '',
        variantId: json['variantId'] as String?,
        imeiItemId: json['imeiItemId'] as String?,
        name: json['name'] as String? ?? '',
        imei1: json['imei1'] as String?,
        unitPrice: (json['unitPrice'] as num?)?.toInt() ?? 0,
        costPrice: (json['costPrice'] as num?)?.toInt() ?? 0,
        minPrice: (json['minPrice'] as num?)?.toInt() ?? 0,
        quantity: (json['quantity'] as num?)?.toInt() ?? 1,
        discountValue: (json['discountValue'] as num?)?.toInt() ?? 0,
        discountIsPercent: json['discountIsPercent'] as bool? ?? false,
      );
}

/// What the payment sheet returns to the POS screen.
class PaymentChoice {
  const PaymentChoice({
    required this.method,
    required this.paidAmount,
    this.reference,
  });

  /// Server value: cash | jazzcash | easypaisa | bank_transfer |
  /// card | partial | udhaar.
  final String method;
  final int paidAmount;
  final String? reference;
}

/// Maps a server payment-method value to its display label key.
String paymentMethodLabelKey(String method) {
  switch (method) {
    case 'jazzcash':
      return 'jazzCash';
    case 'easypaisa':
      return 'easypaisa';
    case 'bank_transfer':
      return 'bank';
    case 'card':
      return 'card';
    case 'partial':
      return 'partial';
    case 'udhaar':
      return 'udhaar';
    case 'cash':
    default:
      return 'cash';
  }
}

/// All server payment-method values, in counter order.
const List<String> paymentMethodValues = <String>[
  'cash',
  'jazzcash',
  'easypaisa',
  'bank_transfer',
  'card',
  'partial',
  'udhaar',
];
