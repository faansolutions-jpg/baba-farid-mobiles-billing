/// ServiceSale model — mirrors the `service_sales` table in schema.sql.
/// Mobile load / recharge / bill-payment sales, with commission.
/// Money is integer whole PKR.
library;

DateTime? _dt(dynamic v) =>
    v == null ? null : (v is DateTime ? v : DateTime.tryParse(v.toString()));

int _int(dynamic v) => (v as num?)?.toInt() ?? 0;

/// A service sale (EasyLoad / recharge / bill payment).
class ServiceSale {
  final String id;

  /// `easyload` | `recharge` | `bill_payment` | `other`.
  final String serviceType;
  final String? customerPhone;
  final String? provider;
  final int amount;
  final int commission;
  final String userId;
  final DateTime saleDate;
  final DateTime createdAt;

  const ServiceSale({
    required this.id,
    required this.serviceType,
    this.customerPhone,
    this.provider,
    required this.amount,
    this.commission = 0,
    required this.userId,
    required this.saleDate,
    required this.createdAt,
  });

  factory ServiceSale.fromJson(Map<String, dynamic> json) => ServiceSale(
        id: json['id'] as String,
        serviceType: json['service_type'] as String,
        customerPhone: json['customer_phone'] as String?,
        provider: json['provider'] as String?,
        amount: _int(json['amount']),
        commission: _int(json['commission']),
        userId: json['user_id'] as String,
        saleDate: _dt(json['sale_date']) ?? DateTime.now(),
        createdAt: _dt(json['created_at']) ?? DateTime.now(),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'service_type': serviceType,
        'customer_phone': customerPhone,
        'provider': provider,
        'amount': amount,
        'commission': commission,
        'user_id': userId,
        'sale_date': saleDate.toIso8601String(),
        'created_at': createdAt.toIso8601String(),
      };

  ServiceSale copyWith({
    String? id,
    String? serviceType,
    String? customerPhone,
    String? provider,
    int? amount,
    int? commission,
    String? userId,
    DateTime? saleDate,
    DateTime? createdAt,
  }) =>
      ServiceSale(
        id: id ?? this.id,
        serviceType: serviceType ?? this.serviceType,
        customerPhone: customerPhone ?? this.customerPhone,
        provider: provider ?? this.provider,
        amount: amount ?? this.amount,
        commission: commission ?? this.commission,
        userId: userId ?? this.userId,
        saleDate: saleDate ?? this.saleDate,
        createdAt: createdAt ?? this.createdAt,
      );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ServiceSale &&
          other.id == id &&
          other.serviceType == serviceType &&
          other.amount == amount &&
          other.saleDate == saleDate;

  @override
  int get hashCode => Object.hash(id, serviceType, amount, saleDate);
}
