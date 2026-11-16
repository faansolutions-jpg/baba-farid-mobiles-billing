/// ImeiItem model — mirrors the `imei_items` table in schema.sql.
/// Every phone is a unique IMEI-tracked item. A sold IMEI can never be
/// sold again unless its sale is returned (status back to `available`).
/// Money is integer whole PKR.
library;

DateTime? _dt(dynamic v) =>
    v == null ? null : (v is DateTime ? v : DateTime.tryParse(v.toString()));

int _int(dynamic v) => (v as num?)?.toInt() ?? 0;

/// IMEI status values (schema enum `imei_status`).
class ImeiStatus {
  static const available = 'available';
  static const sold = 'sold';
  static const returned = 'returned';
  static const reserved = 'reserved';
  static const defective = 'defective';
  static const values = [available, sold, returned, reserved, defective];
}

class ImeiItem {
  final String id;
  final String productId;
  final String? variantId;
  final String imei1;
  final String? imei2;

  /// `available` | `sold` | `returned` | `reserved` | `defective`.
  final String status;
  final String? purchaseId;
  final int purchasePrice;
  final int salePrice;
  final String? soldSaleId;
  final DateTime? warrantyStart;
  final DateTime? warrantyEnd;
  final DateTime createdAt;
  final DateTime updatedAt;

  /// Convenience copies of the variant's condition / PTA status
  /// (`new`|`used`|`open_box`, `approved`|`non_pta`|`not_applicable`).
  /// These live on `product_variants` in the schema; they are carried
  /// here denormalised for POS display and are not separate columns.
  final String? condition;
  final String? ptaStatus;

  const ImeiItem({
    required this.id,
    required this.productId,
    this.variantId,
    required this.imei1,
    this.imei2,
    this.status = ImeiStatus.available,
    this.purchaseId,
    this.purchasePrice = 0,
    this.salePrice = 0,
    this.soldSaleId,
    this.warrantyStart,
    this.warrantyEnd,
    required this.createdAt,
    required this.updatedAt,
    this.condition,
    this.ptaStatus,
  });

  factory ImeiItem.fromJson(Map<String, dynamic> json) => ImeiItem(
        id: json['id'] as String,
        productId: json['product_id'] as String,
        variantId: json['variant_id'] as String?,
        imei1: json['imei1'] as String,
        imei2: json['imei2'] as String?,
        status: json['status'] as String? ?? ImeiStatus.available,
        purchaseId: json['purchase_id'] as String?,
        purchasePrice: _int(json['purchase_price']),
        salePrice: _int(json['sale_price']),
        soldSaleId: json['sold_sale_id'] as String?,
        warrantyStart: _dt(json['warranty_start']),
        warrantyEnd: _dt(json['warranty_end']),
        createdAt: _dt(json['created_at']) ?? DateTime.now(),
        updatedAt: _dt(json['updated_at']) ?? DateTime.now(),
        condition: json['condition'] as String?,
        ptaStatus: json['pta_status'] as String?,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'product_id': productId,
        'variant_id': variantId,
        'imei1': imei1,
        'imei2': imei2,
        'status': status,
        'purchase_id': purchaseId,
        'purchase_price': purchasePrice,
        'sale_price': salePrice,
        'sold_sale_id': soldSaleId,
        'warranty_start': warrantyStart?.toIso8601String(),
        'warranty_end': warrantyEnd?.toIso8601String(),
        'created_at': createdAt.toIso8601String(),
        'updated_at': updatedAt.toIso8601String(),
        'condition': condition,
        'pta_status': ptaStatus,
      };

  ImeiItem copyWith({
    String? id,
    String? productId,
    String? variantId,
    String? imei1,
    String? imei2,
    String? status,
    String? purchaseId,
    int? purchasePrice,
    int? salePrice,
    String? soldSaleId,
    DateTime? warrantyStart,
    DateTime? warrantyEnd,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? condition,
    String? ptaStatus,
  }) =>
      ImeiItem(
        id: id ?? this.id,
        productId: productId ?? this.productId,
        variantId: variantId ?? this.variantId,
        imei1: imei1 ?? this.imei1,
        imei2: imei2 ?? this.imei2,
        status: status ?? this.status,
        purchaseId: purchaseId ?? this.purchaseId,
        purchasePrice: purchasePrice ?? this.purchasePrice,
        salePrice: salePrice ?? this.salePrice,
        soldSaleId: soldSaleId ?? this.soldSaleId,
        warrantyStart: warrantyStart ?? this.warrantyStart,
        warrantyEnd: warrantyEnd ?? this.warrantyEnd,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
        condition: condition ?? this.condition,
        ptaStatus: ptaStatus ?? this.ptaStatus,
      );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ImeiItem &&
          other.id == id &&
          other.imei1 == imei1 &&
          other.imei2 == imei2 &&
          other.status == status &&
          other.productId == productId &&
          other.variantId == variantId;

  @override
  int get hashCode =>
      Object.hash(id, imei1, imei2, status, productId, variantId);
}
