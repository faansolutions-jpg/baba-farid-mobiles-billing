/// Staff + SalaryPayment models.
/// Mirrors `staff` and `salary_payments` in schema.sql.
/// Money is integer whole PKR.
library;

DateTime? _dt(dynamic v) =>
    v == null ? null : (v is DateTime ? v : DateTime.tryParse(v.toString()));

int _int(dynamic v) => (v as num?)?.toInt() ?? 0;

class Staff {
  final String id;
  final String name;
  final String? phone;
  final String? role;
  final int salary;
  final bool isActive;
  final DateTime createdAt;

  const Staff({
    required this.id,
    required this.name,
    this.phone,
    this.role,
    this.salary = 0,
    this.isActive = true,
    required this.createdAt,
  });

  factory Staff.fromJson(Map<String, dynamic> json) => Staff(
        id: json['id'] as String,
        name: json['name'] as String,
        phone: json['phone'] as String?,
        role: json['role'] as String?,
        salary: _int(json['salary']),
        isActive: json['is_active'] as bool? ?? true,
        createdAt: _dt(json['created_at']) ?? DateTime.now(),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'phone': phone,
        'role': role,
        'salary': salary,
        'is_active': isActive,
        'created_at': createdAt.toIso8601String(),
      };

  Staff copyWith({
    String? id,
    String? name,
    String? phone,
    String? role,
    int? salary,
    bool? isActive,
    DateTime? createdAt,
  }) =>
      Staff(
        id: id ?? this.id,
        name: name ?? this.name,
        phone: phone ?? this.phone,
        role: role ?? this.role,
        salary: salary ?? this.salary,
        isActive: isActive ?? this.isActive,
        createdAt: createdAt ?? this.createdAt,
      );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Staff &&
          other.id == id &&
          other.name == name &&
          other.phone == phone &&
          other.salary == salary &&
          other.isActive == isActive;

  @override
  int get hashCode => Object.hash(id, name, phone, salary, isActive);
}

/// One salary / advance payment (`salary_payments` table).
/// `month` is `YYYY-MM` (e.g. `2026-11`).
class SalaryPayment {
  final String id;
  final String staffId;
  final String month;
  final int amount;
  final int advance;
  final DateTime paidDate;
  final String userId;
  final String? notes;
  final DateTime createdAt;

  const SalaryPayment({
    required this.id,
    required this.staffId,
    required this.month,
    required this.amount,
    this.advance = 0,
    required this.paidDate,
    required this.userId,
    this.notes,
    required this.createdAt,
  });

  factory SalaryPayment.fromJson(Map<String, dynamic> json) =>
      SalaryPayment(
        id: json['id'] as String,
        staffId: json['staff_id'] as String,
        month: json['month'] as String,
        amount: _int(json['amount']),
        advance: _int(json['advance']),
        paidDate: _dt(json['paid_date']) ?? DateTime.now(),
        userId: json['user_id'] as String,
        notes: json['notes'] as String?,
        createdAt: _dt(json['created_at']) ?? DateTime.now(),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'staff_id': staffId,
        'month': month,
        'amount': amount,
        'advance': advance,
        'paid_date': paidDate.toIso8601String(),
        'user_id': userId,
        'notes': notes,
        'created_at': createdAt.toIso8601String(),
      };

  SalaryPayment copyWith({
    String? id,
    String? staffId,
    String? month,
    int? amount,
    int? advance,
    DateTime? paidDate,
    String? userId,
    String? notes,
    DateTime? createdAt,
  }) =>
      SalaryPayment(
        id: id ?? this.id,
        staffId: staffId ?? this.staffId,
        month: month ?? this.month,
        amount: amount ?? this.amount,
        advance: advance ?? this.advance,
        paidDate: paidDate ?? this.paidDate,
        userId: userId ?? this.userId,
        notes: notes ?? this.notes,
        createdAt: createdAt ?? this.createdAt,
      );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SalaryPayment &&
          other.id == id &&
          other.staffId == staffId &&
          other.month == month &&
          other.amount == amount;

  @override
  int get hashCode => Object.hash(id, staffId, month, amount);
}
