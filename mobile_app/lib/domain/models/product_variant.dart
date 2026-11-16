/// ProductVariant model — mirrors `product_variants` in schema.sql.
/// All money is integer whole PKR. `quantity` is accessory stock;
/// phone stock is the count of available [ImeiItem] rows.
library;

DateTime? _dt(dynamic v) =>
    v == null ? null : (v is DateTime ? v : DateTime.tryParse(v.toString()));

int _int(dynamic v) => (v as num?)?.toInt() ?? 0;

/// One purchasable variant of a product, e.g. "8GB / 128GB · Black".
class ProductVariant {
  final String id;
  final String productId;
  final String name;
  final String? color;
  final int? storageGb;
  final int? ramGb;

  /// `new` | `used` | `open_box`.
  final String condition;

  /// `approved` | `non_pta` | `not_applicable`.
  final String ptaStatus;
  final String? barcode;
  final int purchasePrice;
  final int salePrice;

  /// Selling below this needs admin approval (see domain/rules.dart).
  final int minPrice;
  final int warrantyMonths;

  /// Accessory quantity stock. Phones use IMEI rows instead.
  final int quantity;
  final int lowStockThreshold;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;

  const ProductVariant({
    required this.id,
    required this.productId,
    required this.name,
    this.color,
    this.storageGb,
    this.ramGb,
    this.condition = 'new',
    this.ptaStatus = 'not_applicable',
    this.barcode,
    this.purchasePrice = 0,
    this.salePrice = 0,
    this.minPrice = 0,
    this.warrantyMonths = 0,
    this.quantity = 0,
    this.lowStockThreshold = 3,
    this.isActive = true,
    required this.createdAt,
    required this.updatedAt,
  });

  factory ProductVariant.fromJson(Map<String, dynamic> json) =>
      ProductVariant(
        id: json['id'] as String,
        productId: json['product_id'] as String,
        name: json['name'] as String,
        color: json['color'] as String?,
        storageGb: (json['storage_gb'] as num?)?.toInt(),
        ramGb: (json['ram_gb'] as num?)?.toInt(),
        condition: json['condition'] as String? ?? 'new',
        ptaStatus: json['pta_status'] as String? ?? 'not_applicable',
        barcode: json['barcode'] as String?,
        purchasePrice: _int(json['purchase_price']),
        salePrice: _int(json['sale_price']),
        minPrice: _int(json['min_price']),
        warrantyMonths: _int(json['warranty_months']),
        quantity: _int(json['quantity']),
        lowStockThreshold: _int(json['low_stock_threshold']),
        isActive: json['is_active'] as bool? ?? true,
        createdAt: _dt(json['created_at']) ?? DateTime.now(),
        updatedAt: _dt(json['updated_at']) ?? DateTime.now(),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'product_id': productId,
        'name': name,
        'color': color,
        'storage_gb': storageGb,
        'ram_gb': ramGb,
        'condition': condition,
        'pta_status': ptaStatus,
        'barcode': barcode,
        'purchase_price': purchasePrice,
        'sale_price': salePrice,
        'min_price': minPrice,
        'warranty_months': warrantyMonths,
        'quantity': quantity,
        'low_stock_threshold': lowStockThreshold,
        'is_active': isActive,
        'created_at': createdAt.toIso8601String(),
        'updated_at': updatedAt.toIso8601String(),
      };

  ProductVariant copyWith({
    String? id,
    String? productId,
    String? name,
    String? color,
    int? storageGb,
    int? ramGb,
    String? condition,
    String? ptaStatus,
    String? barcode,
    int? purchasePrice,
    int? salePrice,
    int? minPrice,
    int? warrantyMonths,
    int? quantity,
    int? lowStockThreshold,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) =>
      ProductVariant(
        id: id ?? this.id,
        productId: productId ?? this.productId,
        name: name ?? this.name,
        color: color ?? this.color,
        storageGb: storageGb ?? this.storageGb,
        ramGb: ramGb ?? this.ramGb,
        condition: condition ?? this.condition,
        ptaStatus: ptaStatus ?? this.ptaStatus,
        barcode: barcode ?? this.barcode,
        purchasePrice: purchasePrice ?? this.purchasePrice,
        salePrice: salePrice ?? this.salePrice,
        minPrice: minPrice ?? this.minPrice,
        warrantyMonths: warrantyMonths ?? this.warrantyMonths,
        quantity: quantity ?? this.quantity,
        lowStockThreshold: lowStockThreshold ?? this.lowStockThreshold,
        isActive: isActive ?? this.isActive,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
      );

  /// True when accessory stock is at or below the low-stock threshold.
  bool get isLowStock => quantity <= lowStockThreshold;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ProductVariant &&
          other.id == id &&
          other.productId == productId &&
          other.name == name &&
          other.barcode == barcode &&
          other.salePrice == salePrice &&
          other.quantity == quantity &&
          other.isActive == isActive;

  @override
  int get hashCode => Object.hash(
      id, productId, name, barcode, salePrice, quantity, isActive);
}
