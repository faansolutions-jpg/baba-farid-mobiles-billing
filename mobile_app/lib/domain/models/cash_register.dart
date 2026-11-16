/// CashRegister + CashMovement models.
/// Mirrors `cash_register` and `cash_movements` in schema.sql.
/// Money is integer whole PKR.
///
/// Day close: expected = opening + cash sales - expenses - refunds
/// + cash-in - cash-out; `difference` = actual counted - expected.
library;

DateTime? _dt(dynamic v) =>
    v == null ? null : (v is DateTime ? v : DateTime.tryParse(v.toString()));

DateTime? _dateOnly(dynamic v) {
  final d = _dt(v);
  return d == null ? null : DateTime(d.year, d.month, d.day);
}

int _int(dynamic v) => (v as num?)?.toInt() ?? 0;

/// One day's cash register (`cash_register` table).
class CashRegister {
  final String id;
  final String? branchId;
  final DateTime registerDate;
  final int openingCash;
  final int? closingCash;
  final int? expectedCash;
  final int? difference;

  /// `open` | `closed`.
  final String status;
  final String? openedBy;
  final String? closedBy;
  final String? notes;
  final DateTime createdAt;
  final DateTime updatedAt;

  const CashRegister({
    required this.id,
    this.branchId,
    required this.registerDate,
    this.openingCash = 0,
    this.closingCash,
    this.expectedCash,
    this.difference,
    this.status = 'open',
    this.openedBy,
    this.closedBy,
    this.notes,
    required this.createdAt,
    required this.updatedAt,
  });

  factory CashRegister.fromJson(Map<String, dynamic> json) => CashRegister(
        id: json['id'] as String,
        branchId: json['branch_id'] as String?,
        registerDate: _dateOnly(json['register_date']) ?? DateTime.now(),
        openingCash: _int(json['opening_cash']),
        closingCash: (json['closing_cash'] as num?)?.toInt(),
        expectedCash: (json['expected_cash'] as num?)?.toInt(),
        difference: (json['difference'] as num?)?.toInt(),
        status: json['status'] as String? ?? 'open',
        openedBy: json['opened_by'] as String?,
        closedBy: json['closed_by'] as String?,
        notes: json['notes'] as String?,
        createdAt: _dt(json['created_at']) ?? DateTime.now(),
        updatedAt: _dt(json['updated_at']) ?? DateTime.now(),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'branch_id': branchId,
        'register_date': registerDate.toIso8601String(),
        'opening_cash': openingCash,
        'closing_cash': closingCash,
        'expected_cash': expectedCash,
        'difference': difference,
        'status': status,
        'opened_by': openedBy,
        'closed_by': closedBy,
        'notes': notes,
        'created_at': createdAt.toIso8601String(),
        'updated_at': updatedAt.toIso8601String(),
      };

  CashRegister copyWith({
    String? id,
    String? branchId,
    DateTime? registerDate,
    int? openingCash,
    int? closingCash,
    int? expectedCash,
    int? difference,
    String? status,
    String? openedBy,
    String? closedBy,
    String? notes,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) =>
      CashRegister(
        id: id ?? this.id,
        branchId: branchId ?? this.branchId,
        registerDate: registerDate ?? this.registerDate,
        openingCash: openingCash ?? this.openingCash,
        closingCash: closingCash ?? this.closingCash,
        expectedCash: expectedCash ?? this.expectedCash,
        difference: difference ?? this.difference,
        status: status ?? this.status,
        openedBy: openedBy ?? this.openedBy,
        closedBy: closedBy ?? this.closedBy,
        notes: notes ?? this.notes,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
      );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CashRegister &&
          other.id == id &&
          other.registerDate == registerDate &&
          other.openingCash == openingCash &&
          other.status == status;

  @override
  int get hashCode => Object.hash(id, registerDate, openingCash, status);
}

/// A manual cash in/out movement against an open register.
class CashMovement {
  final String id;
  final String registerId;

  /// `in` (cash added) or `out` (cash taken).
  final String type;
  final int amount;
  final String? reason;
  final String userId;
  final DateTime createdAt;

  const CashMovement({
    required this.id,
    required this.registerId,
    required this.type,
    required this.amount,
    this.reason,
    required this.userId,
    required this.createdAt,
  });

  factory CashMovement.fromJson(Map<String, dynamic> json) => CashMovement(
        id: json['id'] as String,
        registerId: json['register_id'] as String,
        type: json['type'] as String,
        amount: _int(json['amount']),
        reason: json['reason'] as String?,
        userId: json['user_id'] as String,
        createdAt: _dt(json['created_at']) ?? DateTime.now(),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'register_id': registerId,
        'type': type,
        'amount': amount,
        'reason': reason,
        'user_id': userId,
        'created_at': createdAt.toIso8601String(),
      };

  CashMovement copyWith({
    String? id,
    String? registerId,
    String? type,
    int? amount,
    String? reason,
    String? userId,
    DateTime? createdAt,
  }) =>
      CashMovement(
        id: id ?? this.id,
        registerId: registerId ?? this.registerId,
        type: type ?? this.type,
        amount: amount ?? this.amount,
        reason: reason ?? this.reason,
        userId: userId ?? this.userId,
        createdAt: createdAt ?? this.createdAt,
      );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CashMovement &&
          other.id == id &&
          other.registerId == registerId &&
          other.type == type &&
          other.amount == amount;

  @override
  int get hashCode => Object.hash(id, registerId, type, amount);
}
