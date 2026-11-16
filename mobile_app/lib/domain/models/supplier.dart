/// Supplier model — mirrors the `suppliers` table in schema.sql.
/// Money is integer whole PKR.
library;

DateTime? _dt(dynamic v) =>
    v == null ? null : (v is DateTime ? v : DateTime.tryParse(v.toString()));

int _int(dynamic v) => (v as num?)?.toInt() ?? 0;

class Supplier {
  final String id;
  final String name;
  final String? phone;
  final String? address;
  final int openingPayable;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;

  /// Current amount the shop owes this supplier, populated by the
  /// repository from the supplier ledger. Not a column; 0 when not loaded.
  final int payable;

  const Supplier({
    required this.id,
    required this.name,
    this.phone,
    this.address,
    this.openingPayable = 0,
    this.isActive = true,
    required this.createdAt,
    required this.updatedAt,
    this.payable = 0,
  });

  factory Supplier.fromJson(Map<String, dynamic> json) => Supplier(
        id: json['id'] as String,
        name: json['name'] as String,
        phone: json['phone'] as String?,
        address: json['address'] as String?,
        openingPayable: _int(json['opening_payable']),
        isActive: json['is_active'] as bool? ?? true,
        createdAt: _dt(json['created_at']) ?? DateTime.now(),
        updatedAt: _dt(json['updated_at']) ?? DateTime.now(),
        payable: _int(json['payable']),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'phone': phone,
        'address': address,
        'opening_payable': openingPayable,
        'is_active': isActive,
        'created_at': createdAt.toIso8601String(),
        'updated_at': updatedAt.toIso8601String(),
        'payable': payable,
      };

  Supplier copyWith({
    String? id,
    String? name,
    String? phone,
    String? address,
    int? openingPayable,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
    int? payable,
  }) =>
      Supplier(
        id: id ?? this.id,
        name: name ?? this.name,
        phone: phone ?? this.phone,
        address: address ?? this.address,
        openingPayable: openingPayable ?? this.openingPayable,
        isActive: isActive ?? this.isActive,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
        payable: payable ?? this.payable,
      );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Supplier &&
          other.id == id &&
          other.name == name &&
          other.phone == phone &&
          other.openingPayable == openingPayable &&
          other.isActive == isActive;

  @override
  int get hashCode =>
      Object.hash(id, name, phone, openingPayable, isActive);
}
