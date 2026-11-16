/// Product model — mirrors the `products` table in schema.sql.
/// Money is integer whole PKR. Pricing lives on [ProductVariant].
library;

DateTime? _dt(dynamic v) =>
    v == null ? null : (v is DateTime ? v : DateTime.tryParse(v.toString()));

/// A sellable product (e.g. "Galaxy A15", "Fast Charger 25W").
/// `type` is `phone` or `accessory`.
class Product {
  final String id;
  final String? brandId;
  final String? categoryId;
  final String type;
  final String name;
  final String? description;
  final String? barcode;
  final String? imageUrl;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;

  /// Denormalised display names, populated by joins (not columns).
  final String? brandName;
  final String? categoryName;

  const Product({
    required this.id,
    this.brandId,
    this.categoryId,
    required this.type,
    required this.name,
    this.description,
    this.barcode,
    this.imageUrl,
    this.isActive = true,
    required this.createdAt,
    required this.updatedAt,
    this.brandName,
    this.categoryName,
  });

  factory Product.fromJson(Map<String, dynamic> json) => Product(
        id: json['id'] as String,
        brandId: json['brand_id'] as String?,
        categoryId: json['category_id'] as String?,
        type: json['type'] as String,
        name: json['name'] as String,
        description: json['description'] as String?,
        barcode: json['barcode'] as String?,
        imageUrl: json['image_url'] as String?,
        isActive: json['is_active'] as bool? ?? true,
        createdAt: _dt(json['created_at']) ?? DateTime.now(),
        updatedAt: _dt(json['updated_at']) ?? DateTime.now(),
        brandName: json['brand_name'] as String?,
        categoryName: json['category_name'] as String?,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'brand_id': brandId,
        'category_id': categoryId,
        'type': type,
        'name': name,
        'description': description,
        'barcode': barcode,
        'image_url': imageUrl,
        'is_active': isActive,
        'created_at': createdAt.toIso8601String(),
        'updated_at': updatedAt.toIso8601String(),
        'brand_name': brandName,
        'category_name': categoryName,
      };

  Product copyWith({
    String? id,
    String? brandId,
    String? categoryId,
    String? type,
    String? name,
    String? description,
    String? barcode,
    String? imageUrl,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? brandName,
    String? categoryName,
  }) =>
      Product(
        id: id ?? this.id,
        brandId: brandId ?? this.brandId,
        categoryId: categoryId ?? this.categoryId,
        type: type ?? this.type,
        name: name ?? this.name,
        description: description ?? this.description,
        barcode: barcode ?? this.barcode,
        imageUrl: imageUrl ?? this.imageUrl,
        isActive: isActive ?? this.isActive,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
        brandName: brandName ?? this.brandName,
        categoryName: categoryName ?? this.categoryName,
      );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Product &&
          other.id == id &&
          other.brandId == brandId &&
          other.categoryId == categoryId &&
          other.type == type &&
          other.name == name &&
          other.barcode == barcode &&
          other.isActive == isActive;

  @override
  int get hashCode =>
      Object.hash(id, brandId, categoryId, type, name, barcode, isActive);
}
