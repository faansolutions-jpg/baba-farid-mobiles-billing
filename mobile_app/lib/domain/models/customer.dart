/// Customer model — mirrors the `customers` table in schema.sql.
/// Money is integer whole PKR.
///
/// `loyaltyPoints` / `walletBalance` are local computed/stored values
/// (DECISIONS.md rule 23: 1 point per Rs 100 spent, 100 points = Rs 100
/// discount). They are kept as local-only columns in the drift table;
/// the Postgres schema carries `opening_balance` only.
library;

DateTime? _dt(dynamic v) =>
    v == null ? null : (v is DateTime ? v : DateTime.tryParse(v.toString()));

int _int(dynamic v) => (v as num?)?.toInt() ?? 0;

class Customer {
  final String id;
  final String name;
  final String phone;
  final String? cnic;
  final String? address;
  final int openingBalance;
  final int loyaltyPoints;
  final int walletBalance;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;

  /// Current udhaar balance (amount the customer owes), populated by
  /// the repository from the ledger. Not a column; 0 when not loaded.
  final int currentBalance;

  const Customer({
    required this.id,
    required this.name,
    required this.phone,
    this.cnic,
    this.address,
    this.openingBalance = 0,
    this.loyaltyPoints = 0,
    this.walletBalance = 0,
    this.isActive = true,
    required this.createdAt,
    required this.updatedAt,
    this.currentBalance = 0,
  });

  factory Customer.fromJson(Map<String, dynamic> json) => Customer(
        id: json['id'] as String,
        name: json['name'] as String,
        phone: json['phone'] as String,
        cnic: json['cnic'] as String?,
        address: json['address'] as String?,
        openingBalance: _int(json['opening_balance']),
        loyaltyPoints: _int(json['loyalty_points']),
        walletBalance: _int(json['wallet_balance']),
        isActive: json['is_active'] as bool? ?? true,
        createdAt: _dt(json['created_at']) ?? DateTime.now(),
        updatedAt: _dt(json['updated_at']) ?? DateTime.now(),
        currentBalance: _int(json['current_balance']),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'phone': phone,
        'cnic': cnic,
        'address': address,
        'opening_balance': openingBalance,
        'loyalty_points': loyaltyPoints,
        'wallet_balance': walletBalance,
        'is_active': isActive,
        'created_at': createdAt.toIso8601String(),
        'updated_at': updatedAt.toIso8601String(),
        'current_balance': currentBalance,
      };

  Customer copyWith({
    String? id,
    String? name,
    String? phone,
    String? cnic,
    String? address,
    int? openingBalance,
    int? loyaltyPoints,
    int? walletBalance,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
    int? currentBalance,
  }) =>
      Customer(
        id: id ?? this.id,
        name: name ?? this.name,
        phone: phone ?? this.phone,
        cnic: cnic ?? this.cnic,
        address: address ?? this.address,
        openingBalance: openingBalance ?? this.openingBalance,
        loyaltyPoints: loyaltyPoints ?? this.loyaltyPoints,
        walletBalance: walletBalance ?? this.walletBalance,
        isActive: isActive ?? this.isActive,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
        currentBalance: currentBalance ?? this.currentBalance,
      );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Customer &&
          other.id == id &&
          other.name == name &&
          other.phone == phone &&
          other.cnic == cnic &&
          other.openingBalance == openingBalance &&
          other.loyaltyPoints == loyaltyPoints &&
          other.walletBalance == walletBalance &&
          other.isActive == isActive;

  @override
  int get hashCode => Object.hash(
      id, name, phone, cnic, openingBalance, loyaltyPoints, walletBalance,
      isActive);
}
