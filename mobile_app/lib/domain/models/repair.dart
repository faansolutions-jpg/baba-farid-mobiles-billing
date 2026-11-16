/// Repair + RepairPart models.
/// Mirrors `repairs` and `repair_parts` in schema.sql.
/// Money is integer whole PKR.
library;

DateTime? _dt(dynamic v) =>
    v == null ? null : (v is DateTime ? v : DateTime.tryParse(v.toString()));

int _int(dynamic v) => (v as num?)?.toInt() ?? 0;

/// One part used in a repair (`repair_parts` table).
class RepairPart {
  final String id;
  final String repairId;
  final String? productId;
  final String? variantId;
  final String name;
  final int quantity;
  final int unitPrice;
  final int total;
  final DateTime createdAt;

  const RepairPart({
    required this.id,
    required this.repairId,
    this.productId,
    this.variantId,
    required this.name,
    this.quantity = 1,
    required this.unitPrice,
    required this.total,
    required this.createdAt,
  });

  factory RepairPart.fromJson(Map<String, dynamic> json) => RepairPart(
        id: json['id'] as String,
        repairId: json['repair_id'] as String,
        productId: json['product_id'] as String?,
        variantId: json['variant_id'] as String?,
        name: json['name'] as String,
        quantity: _int(json['quantity']) == 0 ? 1 : _int(json['quantity']),
        unitPrice: _int(json['unit_price']),
        total: _int(json['total']),
        createdAt: _dt(json['created_at']) ?? DateTime.now(),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'repair_id': repairId,
        'product_id': productId,
        'variant_id': variantId,
        'name': name,
        'quantity': quantity,
        'unit_price': unitPrice,
        'total': total,
        'created_at': createdAt.toIso8601String(),
      };

  RepairPart copyWith({
    String? id,
    String? repairId,
    String? productId,
    String? variantId,
    String? name,
    int? quantity,
    int? unitPrice,
    int? total,
    DateTime? createdAt,
  }) =>
      RepairPart(
        id: id ?? this.id,
        repairId: repairId ?? this.repairId,
        productId: productId ?? this.productId,
        variantId: variantId ?? this.variantId,
        name: name ?? this.name,
        quantity: quantity ?? this.quantity,
        unitPrice: unitPrice ?? this.unitPrice,
        total: total ?? this.total,
        createdAt: createdAt ?? this.createdAt,
      );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RepairPart &&
          other.id == id &&
          other.repairId == repairId &&
          other.name == name &&
          other.total == total;

  @override
  int get hashCode => Object.hash(id, repairId, name, total);
}

/// A repair job card (`repairs` table).
///
/// Status flow: `received` -> `in_progress` -> `ready` -> `delivered`.
/// `cancelled` is allowed from any status except `delivered`.
class Repair {
  final String id;
  final String jobNo;
  final String? customerId;
  final String customerName;
  final String customerPhone;
  final String? deviceBrand;
  final String? deviceModel;
  final String? imei;
  final String faultDescription;
  final int estimatedCost;
  final int finalCost;
  final int advancePaid;
  final String status;
  final DateTime receivedDate;
  final DateTime? readyDate;
  final DateTime? deliveredDate;
  final String userId;
  final String? notes;
  final List<RepairPart> parts;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Repair({
    required this.id,
    required this.jobNo,
    this.customerId,
    required this.customerName,
    required this.customerPhone,
    this.deviceBrand,
    this.deviceModel,
    this.imei,
    required this.faultDescription,
    this.estimatedCost = 0,
    this.finalCost = 0,
    this.advancePaid = 0,
    this.status = 'received',
    required this.receivedDate,
    this.readyDate,
    this.deliveredDate,
    required this.userId,
    this.notes,
    this.parts = const [],
    required this.createdAt,
    required this.updatedAt,
  });

  /// Amount still owed by the customer (final cost minus advance).
  int get balanceDue {
    final value = finalCost - advancePaid;
    return value < 0 ? 0 : value;
  }

  /// Cost of parts used so far.
  int get partsTotal => parts.fold<int>(0, (sum, p) => sum + p.total);

  factory Repair.fromJson(Map<String, dynamic> json) => Repair(
        id: json['id'] as String,
        jobNo: json['job_no'] as String,
        customerId: json['customer_id'] as String?,
        customerName: json['customer_name'] as String,
        customerPhone: json['customer_phone'] as String,
        deviceBrand: json['device_brand'] as String?,
        deviceModel: json['device_model'] as String?,
        imei: json['imei'] as String?,
        faultDescription: json['fault_description'] as String,
        estimatedCost: _int(json['estimated_cost']),
        finalCost: _int(json['final_cost']),
        advancePaid: _int(json['advance_paid']),
        status: json['status'] as String? ?? 'received',
        receivedDate: _dt(json['received_date']) ?? DateTime.now(),
        readyDate: _dt(json['ready_date']),
        deliveredDate: _dt(json['delivered_date']),
        userId: json['user_id'] as String,
        notes: json['notes'] as String?,
        parts: (json['parts'] as List?)
                ?.map((e) => RepairPart.fromJson(e as Map<String, dynamic>))
                .toList() ??
            const [],
        createdAt: _dt(json['created_at']) ?? DateTime.now(),
        updatedAt: _dt(json['updated_at']) ?? DateTime.now(),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'job_no': jobNo,
        'customer_id': customerId,
        'customer_name': customerName,
        'customer_phone': customerPhone,
        'device_brand': deviceBrand,
        'device_model': deviceModel,
        'imei': imei,
        'fault_description': faultDescription,
        'estimated_cost': estimatedCost,
        'final_cost': finalCost,
        'advance_paid': advancePaid,
        'status': status,
        'received_date': receivedDate.toIso8601String(),
        'ready_date': readyDate?.toIso8601String(),
        'delivered_date': deliveredDate?.toIso8601String(),
        'user_id': userId,
        'notes': notes,
        'parts': parts.map((e) => e.toJson()).toList(),
        'created_at': createdAt.toIso8601String(),
        'updated_at': updatedAt.toIso8601String(),
      };

  Repair copyWith({
    String? id,
    String? jobNo,
    String? customerId,
    String? customerName,
    String? customerPhone,
    String? deviceBrand,
    String? deviceModel,
    String? imei,
    String? faultDescription,
    int? estimatedCost,
    int? finalCost,
    int? advancePaid,
    String? status,
    DateTime? receivedDate,
    DateTime? readyDate,
    DateTime? deliveredDate,
    String? userId,
    String? notes,
    List<RepairPart>? parts,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) =>
      Repair(
        id: id ?? this.id,
        jobNo: jobNo ?? this.jobNo,
        customerId: customerId ?? this.customerId,
        customerName: customerName ?? this.customerName,
        customerPhone: customerPhone ?? this.customerPhone,
        deviceBrand: deviceBrand ?? this.deviceBrand,
        deviceModel: deviceModel ?? this.deviceModel,
        imei: imei ?? this.imei,
        faultDescription: faultDescription ?? this.faultDescription,
        estimatedCost: estimatedCost ?? this.estimatedCost,
        finalCost: finalCost ?? this.finalCost,
        advancePaid: advancePaid ?? this.advancePaid,
        status: status ?? this.status,
        receivedDate: receivedDate ?? this.receivedDate,
        readyDate: readyDate ?? this.readyDate,
        deliveredDate: deliveredDate ?? this.deliveredDate,
        userId: userId ?? this.userId,
        notes: notes ?? this.notes,
        parts: parts ?? this.parts,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
      );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Repair &&
          other.id == id &&
          other.jobNo == jobNo &&
          other.customerPhone == customerPhone &&
          other.status == status &&
          other.finalCost == finalCost;

  @override
  int get hashCode =>
      Object.hash(id, jobNo, customerPhone, status, finalCost);
}
