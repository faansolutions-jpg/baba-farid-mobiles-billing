/// HeldBill model — mirrors the `held_bills` table in schema.sql.
/// A parked bill (cart JSON) that can be resumed later at the POS.
library;

DateTime? _dt(dynamic v) =>
    v == null ? null : (v is DateTime ? v : DateTime.tryParse(v.toString()));

/// One held (parked) bill. `cart` is the JSON list of cart lines
/// (product/variant/IMEI ids, quantities, prices, discounts).
class HeldBill {
  final String id;
  final String? branchId;
  final String userId;
  final String? customerName;
  final List<Map<String, dynamic>> cart;
  final DateTime createdAt;

  const HeldBill({
    required this.id,
    this.branchId,
    required this.userId,
    this.customerName,
    this.cart = const [],
    required this.createdAt,
  });

  factory HeldBill.fromJson(Map<String, dynamic> json) => HeldBill(
        id: json['id'] as String,
        branchId: json['branch_id'] as String?,
        userId: json['user_id'] as String,
        customerName: json['customer_name'] as String?,
        cart: (json['cart'] as List?)
                ?.map((e) => (e as Map).cast<String, dynamic>())
                .toList() ??
            const [],
        createdAt: _dt(json['created_at']) ?? DateTime.now(),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'branch_id': branchId,
        'user_id': userId,
        'customer_name': customerName,
        'cart': cart,
        'created_at': createdAt.toIso8601String(),
      };

  HeldBill copyWith({
    String? id,
    String? branchId,
    String? userId,
    String? customerName,
    List<Map<String, dynamic>>? cart,
    DateTime? createdAt,
  }) =>
      HeldBill(
        id: id ?? this.id,
        branchId: branchId ?? this.branchId,
        userId: userId ?? this.userId,
        customerName: customerName ?? this.customerName,
        cart: cart ?? this.cart,
        createdAt: createdAt ?? this.createdAt,
      );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is HeldBill && other.id == id && other.userId == userId;

  @override
  int get hashCode => Object.hash(id, userId);
}
