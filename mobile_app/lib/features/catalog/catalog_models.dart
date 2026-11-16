// Accessories Master Catalog — domain model.
//
// Pure Dart (no Flutter / drift imports) so it can be used from screens,
// repositories and unit tests alike. `id` is always the SKU.
//
// Prices are ESTIMATED Punjab-market prices in whole PKR (see
// docs/catalog.md) — never live market rates. `estimated` is true for
// every catalog item; custom items created by the shopkeeper are also
// marked estimated (their prices are the shopkeeper's own estimate).
class CatalogItem {
  /// Primary key — always equal to [sku].
  final String id;
  final String sku;
  final String category;
  final String brand;
  final String nameEn;
  final String nameUr;

  /// e.g. "Apple iPhone 15" for covers / glass / repair parts, else null.
  final String? modelCompatibility;
  final List<String> colors;
  final List<String> variants;

  /// ESTIMATED purchase price, whole PKR. Hidden from cashiers in the API.
  final int purchasePriceEst;

  /// ESTIMATED sale price, whole PKR.
  final int salePriceEst;

  /// Minimum sale price, whole PKR.
  final int minPrice;

  /// "piece", "pack", "meter", ...
  final String unit;

  /// Linked barcode, null until scanned/linked.
  final String? barcode;
  final bool isCustom;
  final bool estimated;

  /// Current on-hand quantity (from catalog_stock; 0 when never stocked).
  final int stockQty;

  /// Per-item low-stock threshold (from catalog_stock; default 5).
  final int lowStockThreshold;

  CatalogItem({
    required this.sku,
    required this.category,
    required this.brand,
    required this.nameEn,
    required this.nameUr,
    this.modelCompatibility,
    this.colors = const [],
    this.variants = const [],
    required this.purchasePriceEst,
    required this.salePriceEst,
    required this.minPrice,
    this.unit = 'piece',
    this.barcode,
    this.isCustom = false,
    this.estimated = true,
    this.stockQty = 0,
    this.lowStockThreshold = 5,
  }) : id = sku;

  /// Profit per item at the estimated prices (whole PKR).
  int get estimatedProfit => salePriceEst - purchasePriceEst;

  // Low stock = STRICTLY below the threshold. At exactly the threshold
  // the item is at its reorder point but not yet below it.
  bool get isLowStock => stockQty < lowStockThreshold;

  bool get isOutOfStock => stockQty <= 0;

  factory CatalogItem.fromJson(Map<String, dynamic> json) {
    List<String> asStringList(dynamic value) {
      if (value == null) return const [];
      if (value is List) return value.map((e) => e.toString()).toList();
      if (value is String) return [value];
      return const [];
    }

    int asInt(dynamic value, [int fallback = 0]) {
      if (value is int) return value;
      if (value is num) return value.toInt();
      if (value is String) return int.tryParse(value) ?? fallback;
      return fallback;
    }

    final sku = (json['sku'] ?? json['id'] ?? '').toString();
    return CatalogItem(
      sku: sku,
      category: (json['category'] ?? '').toString(),
      brand: (json['brand'] ?? '').toString(),
      nameEn: (json['name_en'] ?? json['nameEn'] ?? '').toString(),
      nameUr: (json['name_ur'] ?? json['nameUr'] ?? '').toString(),
      modelCompatibility: (json['model_compatibility'] ?? json['modelCompatibility'])
          as String?,
      colors: asStringList(json['colors']),
      variants: asStringList(json['variants']),
      purchasePriceEst:
          asInt(json['purchase_price_est'] ?? json['purchasePriceEst']),
      salePriceEst: asInt(json['sale_price_est'] ?? json['salePriceEst']),
      minPrice: asInt(json['min_price'] ?? json['minPrice']),
      unit: (json['unit'] ?? 'piece').toString(),
      barcode: json['barcode'] as String?,
      isCustom: json['is_custom'] ?? json['isCustom'] ?? false,
      estimated: json['estimated'] ?? true,
      stockQty: asInt(json['stockQty'] ?? json['stock_qty'] ?? json['quantity']),
      lowStockThreshold:
          asInt(json['lowStockThreshold'] ?? json['low_stock_threshold'], 5),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'sku': sku,
      'category': category,
      'brand': brand,
      'name_en': nameEn,
      'name_ur': nameUr,
      'model_compatibility': modelCompatibility,
      'colors': colors,
      'variants': variants,
      'purchase_price_est': purchasePriceEst,
      'sale_price_est': salePriceEst,
      'min_price': minPrice,
      'unit': unit,
      'barcode': barcode,
      'is_custom': isCustom,
      'estimated': estimated,
      'stockQty': stockQty,
      'lowStockThreshold': lowStockThreshold,
    };
  }

  CatalogItem copyWith({
    String? sku,
    String? category,
    String? brand,
    String? nameEn,
    String? nameUr,
    String? modelCompatibility,
    List<String>? colors,
    List<String>? variants,
    int? purchasePriceEst,
    int? salePriceEst,
    int? minPrice,
    String? unit,
    String? barcode,
    bool? isCustom,
    bool? estimated,
    int? stockQty,
    int? lowStockThreshold,
  }) {
    return CatalogItem(
      sku: sku ?? this.sku,
      category: category ?? this.category,
      brand: brand ?? this.brand,
      nameEn: nameEn ?? this.nameEn,
      nameUr: nameUr ?? this.nameUr,
      modelCompatibility: modelCompatibility ?? this.modelCompatibility,
      colors: colors ?? this.colors,
      variants: variants ?? this.variants,
      purchasePriceEst: purchasePriceEst ?? this.purchasePriceEst,
      salePriceEst: salePriceEst ?? this.salePriceEst,
      minPrice: minPrice ?? this.minPrice,
      unit: unit ?? this.unit,
      barcode: barcode ?? this.barcode,
      isCustom: isCustom ?? this.isCustom,
      estimated: estimated ?? this.estimated,
      stockQty: stockQty ?? this.stockQty,
      lowStockThreshold: lowStockThreshold ?? this.lowStockThreshold,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CatalogItem &&
          runtimeType == other.runtimeType &&
          sku == other.sku;

  @override
  int get hashCode => sku.hashCode;

  @override
  String toString() =>
      'CatalogItem(sku: $sku, nameEn: $nameEn, stockQty: $stockQty)';
}
