/// LedgerEntry model — mirrors the `ledger_entries` table in schema.sql.
/// Running-balance ledger: `balanceAfter` is the balance immediately
/// after this entry, which makes statements fast and auditable.
/// Money is integer whole PKR.
///
/// Convention used by the repositories:
/// * Customer side: `balanceAfter = prevBalance + debit - credit`
///   (amount the customer owes the shop).
/// * Supplier side: `balanceAfter = prevBalance + credit - debit`
///   (amount the shop owes the supplier).
library;

DateTime? _dt(dynamic v) =>
    v == null ? null : (v is DateTime ? v : DateTime.tryParse(v.toString()));

int _int(dynamic v) => (v as num?)?.toInt() ?? 0;

class LedgerEntry {
  final String id;

  /// `customer` (udhaar) or `supplier` (payable).
  final String side;
  final String? customerId;
  final String? supplierId;

  /// `sale` | `purchase` | `payment` | `return` | `installment` | `opening`.
  final String referenceType;
  final String? referenceId;
  final int debit;
  final int credit;

  /// Running balance after this entry.
  final int balanceAfter;
  final DateTime entryDate;
  final String? userId;
  final String? notes;
  final DateTime createdAt;

  const LedgerEntry({
    required this.id,
    required this.side,
    this.customerId,
    this.supplierId,
    required this.referenceType,
    this.referenceId,
    this.debit = 0,
    this.credit = 0,
    required this.balanceAfter,
    required this.entryDate,
    this.userId,
    this.notes,
    required this.createdAt,
  });

  factory LedgerEntry.fromJson(Map<String, dynamic> json) => LedgerEntry(
        id: json['id'] as String,
        side: json['side'] as String,
        customerId: json['customer_id'] as String?,
        supplierId: json['supplier_id'] as String?,
        referenceType: json['reference_type'] as String,
        referenceId: json['reference_id'] as String?,
        debit: _int(json['debit']),
        credit: _int(json['credit']),
        balanceAfter: _int(json['balance_after']),
        entryDate: _dt(json['entry_date']) ?? DateTime.now(),
        userId: json['user_id'] as String?,
        notes: json['notes'] as String?,
        createdAt: _dt(json['created_at']) ?? DateTime.now(),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'side': side,
        'customer_id': customerId,
        'supplier_id': supplierId,
        'reference_type': referenceType,
        'reference_id': referenceId,
        'debit': debit,
        'credit': credit,
        'balance_after': balanceAfter,
        'entry_date': entryDate.toIso8601String(),
        'user_id': userId,
        'notes': notes,
        'created_at': createdAt.toIso8601String(),
      };

  LedgerEntry copyWith({
    String? id,
    String? side,
    String? customerId,
    String? supplierId,
    String? referenceType,
    String? referenceId,
    int? debit,
    int? credit,
    int? balanceAfter,
    DateTime? entryDate,
    String? userId,
    String? notes,
    DateTime? createdAt,
  }) =>
      LedgerEntry(
        id: id ?? this.id,
        side: side ?? this.side,
        customerId: customerId ?? this.customerId,
        supplierId: supplierId ?? this.supplierId,
        referenceType: referenceType ?? this.referenceType,
        referenceId: referenceId ?? this.referenceId,
        debit: debit ?? this.debit,
        credit: credit ?? this.credit,
        balanceAfter: balanceAfter ?? this.balanceAfter,
        entryDate: entryDate ?? this.entryDate,
        userId: userId ?? this.userId,
        notes: notes ?? this.notes,
        createdAt: createdAt ?? this.createdAt,
      );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is LedgerEntry &&
          other.id == id &&
          other.side == side &&
          other.debit == debit &&
          other.credit == credit &&
          other.balanceAfter == balanceAfter;

  @override
  int get hashCode => Object.hash(id, side, debit, credit, balanceAfter);
}
