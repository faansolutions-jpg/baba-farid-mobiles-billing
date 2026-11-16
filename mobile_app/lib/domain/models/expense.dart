/// Expense model — mirrors the `expenses` table in schema.sql.
/// Money is integer whole PKR.
library;

DateTime? _dt(dynamic v) =>
    v == null ? null : (v is DateTime ? v : DateTime.tryParse(v.toString()));

int _int(dynamic v) => (v as num?)?.toInt() ?? 0;

/// Expense categories used across the shop (free-form in the schema,
/// but these are the standard ones).
class ExpenseCategory {
  static const rent = 'rent';
  static const electricity = 'electricity';
  static const salary = 'salary';
  static const transport = 'transport';
  static const other = 'other';
  static const values = [rent, electricity, salary, transport, other];
}

class Expense {
  final String id;
  final String? branchId;
  final String category;
  final int amount;
  final DateTime expenseDate;
  final String? description;
  final String userId;
  final DateTime createdAt;

  const Expense({
    required this.id,
    this.branchId,
    required this.category,
    required this.amount,
    required this.expenseDate,
    this.description,
    required this.userId,
    required this.createdAt,
  });

  factory Expense.fromJson(Map<String, dynamic> json) => Expense(
        id: json['id'] as String,
        branchId: json['branch_id'] as String?,
        category: json['category'] as String,
        amount: _int(json['amount']),
        expenseDate: _dt(json['expense_date']) ?? DateTime.now(),
        description: json['description'] as String?,
        userId: json['user_id'] as String,
        createdAt: _dt(json['created_at']) ?? DateTime.now(),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'branch_id': branchId,
        'category': category,
        'amount': amount,
        'expense_date': expenseDate.toIso8601String(),
        'description': description,
        'user_id': userId,
        'created_at': createdAt.toIso8601String(),
      };

  Expense copyWith({
    String? id,
    String? branchId,
    String? category,
    int? amount,
    DateTime? expenseDate,
    String? description,
    String? userId,
    DateTime? createdAt,
  }) =>
      Expense(
        id: id ?? this.id,
        branchId: branchId ?? this.branchId,
        category: category ?? this.category,
        amount: amount ?? this.amount,
        expenseDate: expenseDate ?? this.expenseDate,
        description: description ?? this.description,
        userId: userId ?? this.userId,
        createdAt: createdAt ?? this.createdAt,
      );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Expense &&
          other.id == id &&
          other.category == category &&
          other.amount == amount &&
          other.expenseDate == expenseDate;

  @override
  int get hashCode => Object.hash(id, category, amount, expenseDate);
}
