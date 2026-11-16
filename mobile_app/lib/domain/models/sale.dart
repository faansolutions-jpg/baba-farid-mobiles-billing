/// Sale + SaleItem (+ Payment + SaleReturn) models.
/// Mirrors `sales`, `sale_items`, `payments` and `sale_returns` in
/// schema.sql. Money is integer whole PKR. Money records are append-only:
/// corrections are new rows (returns), never edits of the original sale.
library;

DateTime? _dt(dynamic v) =>
    v == null ? null : (v is DateTime ? v : DateTime.tryParse(v.toString()));

int _int(dynamic v) => (v as num?)?.toInt() ?? 0;

double _double(dynamic v) => (v as num?)?.toDouble() ?? 0;

/// One line of a bill.
class SaleItem {
  final String id;
  final String saleId;
  final String? productId;
  final String? variantId;
  final String? imeiItemId;
  final String nameSnapshot;
  final int quantity;
  final int unitPrice;
  final int purchaseCost;
  final int discount;
  final int total;

  /// Stored profit: total - (purchaseCost * quantity).
  final int profit;
  final DateTime createdAt;

  const SaleItem({
    required this.id,
    required this.saleId,
    this.productId,
    this.variantId,
    this.imeiItemId,
    required this.nameSnapshot,
    this.quantity = 1,
    required this.unitPrice,
    this.purchaseCost = 0,
    this.discount = 0,
    required this.total,
    this.profit = 0,
    required this.createdAt,
  });

  factory SaleItem.fromJson(Map<String, dynamic> json) => SaleItem(
        id: json['id'] as String,
        saleId: json['sale_id'] as String,
        productId: json['product_id'] as String?,
        variantId: json['variant_id'] as String?,
        imeiItemId: json['imei_item_id'] as String?,
        nameSnapshot: json['name_snapshot'] as String,
        quantity: _int(json['quantity']) == 0 ? 1 : _int(json['quantity']),
        unitPrice: _int(json['unit_price']),
        purchaseCost: _int(json['purchase_cost']),
        discount: _int(json['discount']),
        total: _int(json['total']),
        profit: _int(json['profit']),
        createdAt: _dt(json['created_at']) ?? DateTime.now(),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'sale_id': saleId,
        'product_id': productId,
        'variant_id': variantId,
        'imei_item_id': imeiItemId,
        'name_snapshot': nameSnapshot,
        'quantity': quantity,
        'unit_price': unitPrice,
        'purchase_cost': purchaseCost,
        'discount': discount,
        'total': total,
        'profit': profit,
        'created_at': createdAt.toIso8601String(),
      };

  SaleItem copyWith({
    String? id,
    String? saleId,
    String? productId,
    String? variantId,
    String? imeiItemId,
    String? nameSnapshot,
    int? quantity,
    int? unitPrice,
    int? purchaseCost,
    int? discount,
    int? total,
    int? profit,
    DateTime? createdAt,
  }) =>
      SaleItem(
        id: id ?? this.id,
        saleId: saleId ?? this.saleId,
        productId: productId ?? this.productId,
        variantId: variantId ?? this.variantId,
        imeiItemId: imeiItemId ?? this.imeiItemId,
        nameSnapshot: nameSnapshot ?? this.nameSnapshot,
        quantity: quantity ?? this.quantity,
        unitPrice: unitPrice ?? this.unitPrice,
        purchaseCost: purchaseCost ?? this.purchaseCost,
        discount: discount ?? this.discount,
        total: total ?? this.total,
        profit: profit ?? this.profit,
        createdAt: createdAt ?? this.createdAt,
      );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SaleItem &&
          other.id == id &&
          other.saleId == saleId &&
          other.imeiItemId == imeiItemId &&
          other.nameSnapshot == nameSnapshot &&
          other.quantity == quantity &&
          other.unitPrice == unitPrice &&
          other.total == total;

  @override
  int get hashCode => Object.hash(
      id, saleId, imeiItemId, nameSnapshot, quantity, unitPrice, total);
}

/// A bill. `items` is the in-memory line list (not a column).
/// `total` = [grandTotal], `paid` = [paidAmount], `due` = [balanceDue].
class Sale {
  final String id;
  final String invoiceNo;
  final String? branchId;
  final String? customerId;
  final String? customerName;
  final String? customerPhone;
  final String userId; // cashier who made the bill (salesman)
  final DateTime saleDate;
  final int subtotal;
  final int discountAmount;
  final double discountPercent;
  final int taxAmount;
  final int grandTotal;
  final int paidAmount;
  final int balanceDue;

  /// `cash` | `jazzcash` | `easypaisa` | `bank_transfer` | `card` |
  /// `partial` | `udhaar`.
  final String paymentMethod;

  /// `paid` | `partial` | `unpaid`.
  final String paymentStatus;

  /// `completed` | `returned` | `partially_returned` | `cancelled` | `held`.
  final String status;
  final String? notes;
  final String? clientUuid;
  final List<SaleItem> items;
  final DateTime createdAt;
  final DateTime updatedAt;

  /// Username of the admin who approved a below-min-price sale, if any.
  final String? adminApprovedBy;

  const Sale({
    required this.id,
    required this.invoiceNo,
    this.branchId,
    this.customerId,
    this.customerName,
    this.customerPhone,
    required this.userId,
    required this.saleDate,
    this.subtotal = 0,
    this.discountAmount = 0,
    this.discountPercent = 0,
    this.taxAmount = 0,
    required this.grandTotal,
    this.paidAmount = 0,
    this.balanceDue = 0,
    this.paymentMethod = 'cash',
    this.paymentStatus = 'paid',
    this.status = 'completed',
    this.notes,
    this.clientUuid,
    this.items = const [],
    required this.createdAt,
    required this.updatedAt,
    this.adminApprovedBy,
  });

  /// Convenience aliases matching the task wording.
  int get total => grandTotal;
  int get paid => paidAmount;
  int get due => balanceDue;
  int get discount => discountAmount;
  int get tax => taxAmount;
  String get salesman => userId;

  factory Sale.fromJson(Map<String, dynamic> json) => Sale(
        id: json['id'] as String,
        invoiceNo: json['invoice_no'] as String,
        branchId: json['branch_id'] as String?,
        customerId: json['customer_id'] as String?,
        customerName: json['customer_name'] as String?,
        customerPhone: json['customer_phone'] as String?,
        userId: json['user_id'] as String,
        saleDate: _dt(json['sale_date']) ?? DateTime.now(),
        subtotal: _int(json['subtotal']),
        discountAmount: _int(json['discount_amount']),
        discountPercent: _double(json['discount_percent']),
        taxAmount: _int(json['tax_amount']),
        grandTotal: _int(json['grand_total']),
        paidAmount: _int(json['paid_amount']),
        balanceDue: _int(json['balance_due']),
        paymentMethod: json['payment_method'] as String? ?? 'cash',
        paymentStatus: json['payment_status'] as String? ?? 'paid',
        status: json['status'] as String? ?? 'completed',
        notes: json['notes'] as String?,
        clientUuid: json['client_uuid'] as String?,
        items: (json['items'] as List?)
                ?.map((e) => SaleItem.fromJson(e as Map<String, dynamic>))
                .toList() ??
            const [],
        createdAt: _dt(json['created_at']) ?? DateTime.now(),
        updatedAt: _dt(json['updated_at']) ?? DateTime.now(),
        adminApprovedBy: json['admin_approved_by'] as String?,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'invoice_no': invoiceNo,
        'branch_id': branchId,
        'customer_id': customerId,
        'customer_name': customerName,
        'customer_phone': customerPhone,
        'user_id': userId,
        'sale_date': saleDate.toIso8601String(),
        'subtotal': subtotal,
        'discount_amount': discountAmount,
        'discount_percent': discountPercent,
        'tax_amount': taxAmount,
        'grand_total': grandTotal,
        'paid_amount': paidAmount,
        'balance_due': balanceDue,
        'payment_method': paymentMethod,
        'payment_status': paymentStatus,
        'status': status,
        'notes': notes,
        'client_uuid': clientUuid,
        'items': items.map((e) => e.toJson()).toList(),
        'created_at': createdAt.toIso8601String(),
        'updated_at': updatedAt.toIso8601String(),
        'admin_approved_by': adminApprovedBy,
      };

  Sale copyWith({
    String? id,
    String? invoiceNo,
    String? branchId,
    String? customerId,
    String? customerName,
    String? customerPhone,
    String? userId,
    DateTime? saleDate,
    int? subtotal,
    int? discountAmount,
    double? discountPercent,
    int? taxAmount,
    int? grandTotal,
    int? paidAmount,
    int? balanceDue,
    String? paymentMethod,
    String? paymentStatus,
    String? status,
    String? notes,
    String? clientUuid,
    List<SaleItem>? items,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? adminApprovedBy,
  }) =>
      Sale(
        id: id ?? this.id,
        invoiceNo: invoiceNo ?? this.invoiceNo,
        branchId: branchId ?? this.branchId,
        customerId: customerId ?? this.customerId,
        customerName: customerName ?? this.customerName,
        customerPhone: customerPhone ?? this.customerPhone,
        userId: userId ?? this.userId,
        saleDate: saleDate ?? this.saleDate,
        subtotal: subtotal ?? this.subtotal,
        discountAmount: discountAmount ?? this.discountAmount,
        discountPercent: discountPercent ?? this.discountPercent,
        taxAmount: taxAmount ?? this.taxAmount,
        grandTotal: grandTotal ?? this.grandTotal,
        paidAmount: paidAmount ?? this.paidAmount,
        balanceDue: balanceDue ?? this.balanceDue,
        paymentMethod: paymentMethod ?? this.paymentMethod,
        paymentStatus: paymentStatus ?? this.paymentStatus,
        status: status ?? this.status,
        notes: notes ?? this.notes,
        clientUuid: clientUuid ?? this.clientUuid,
        items: items ?? this.items,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
        adminApprovedBy: adminApprovedBy ?? this.adminApprovedBy,
      );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Sale &&
          other.id == id &&
          other.invoiceNo == invoiceNo &&
          other.grandTotal == grandTotal &&
          other.paidAmount == paidAmount &&
          other.balanceDue == balanceDue &&
          other.status == status;

  @override
  int get hashCode => Object.hash(
      id, invoiceNo, grandTotal, paidAmount, balanceDue, status);
}

/// A money movement (`payments` table): sale / purchase / installment /
/// udhaar-recovery / repair / other payment. Append-only.
class Payment {
  final String id;

  /// `sale` | `purchase` | `installment` | `udhaar_recovery` |
  /// `repair` | `other`.
  final String paymentType;
  final String? saleId;
  final String? purchaseId;
  final String? installmentId;
  final String? repairId;
  final String? customerId;
  final String? supplierId;
  final String method;
  final int amount;
  final String? reference;
  final DateTime paymentDate;
  final String userId;
  final String? notes;
  final String? clientUuid;
  final DateTime createdAt;

  const Payment({
    required this.id,
    required this.paymentType,
    this.saleId,
    this.purchaseId,
    this.installmentId,
    this.repairId,
    this.customerId,
    this.supplierId,
    this.method = 'cash',
    required this.amount,
    this.reference,
    required this.paymentDate,
    required this.userId,
    this.notes,
    this.clientUuid,
    required this.createdAt,
  });

  factory Payment.fromJson(Map<String, dynamic> json) => Payment(
        id: json['id'] as String,
        paymentType: json['payment_type'] as String,
        saleId: json['sale_id'] as String?,
        purchaseId: json['purchase_id'] as String?,
        installmentId: json['installment_id'] as String?,
        repairId: json['repair_id'] as String?,
        customerId: json['customer_id'] as String?,
        supplierId: json['supplier_id'] as String?,
        method: json['method'] as String? ?? 'cash',
        amount: _int(json['amount']),
        reference: json['reference'] as String?,
        paymentDate: _dt(json['payment_date']) ?? DateTime.now(),
        userId: json['user_id'] as String,
        notes: json['notes'] as String?,
        clientUuid: json['client_uuid'] as String?,
        createdAt: _dt(json['created_at']) ?? DateTime.now(),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'payment_type': paymentType,
        'sale_id': saleId,
        'purchase_id': purchaseId,
        'installment_id': installmentId,
        'repair_id': repairId,
        'customer_id': customerId,
        'supplier_id': supplierId,
        'method': method,
        'amount': amount,
        'reference': reference,
        'payment_date': paymentDate.toIso8601String(),
        'user_id': userId,
        'notes': notes,
        'client_uuid': clientUuid,
        'created_at': createdAt.toIso8601String(),
      };

  Payment copyWith({
    String? id,
    String? paymentType,
    String? saleId,
    String? purchaseId,
    String? installmentId,
    String? repairId,
    String? customerId,
    String? supplierId,
    String? method,
    int? amount,
    String? reference,
    DateTime? paymentDate,
    String? userId,
    String? notes,
    String? clientUuid,
    DateTime? createdAt,
  }) =>
      Payment(
        id: id ?? this.id,
        paymentType: paymentType ?? this.paymentType,
        saleId: saleId ?? this.saleId,
        purchaseId: purchaseId ?? this.purchaseId,
        installmentId: installmentId ?? this.installmentId,
        repairId: repairId ?? this.repairId,
        customerId: customerId ?? this.customerId,
        supplierId: supplierId ?? this.supplierId,
        method: method ?? this.method,
        amount: amount ?? this.amount,
        reference: reference ?? this.reference,
        paymentDate: paymentDate ?? this.paymentDate,
        userId: userId ?? this.userId,
        notes: notes ?? this.notes,
        clientUuid: clientUuid ?? this.clientUuid,
        createdAt: createdAt ?? this.createdAt,
      );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Payment &&
          other.id == id &&
          other.paymentType == paymentType &&
          other.amount == amount &&
          other.method == method;

  @override
  int get hashCode => Object.hash(id, paymentType, amount, method);
}

/// A sale return / exchange (`sale_returns` table). Append-only.
class SaleReturn {
  final String id;
  final String saleId;
  final String? saleItemId;
  final String? imeiItemId;
  final int quantity;
  final String? reason;
  final int refundAmount;
  final bool isExchange;
  final String? exchangeSaleId;
  final String userId;
  final DateTime createdAt;

  const SaleReturn({
    required this.id,
    required this.saleId,
    this.saleItemId,
    this.imeiItemId,
    this.quantity = 1,
    this.reason,
    this.refundAmount = 0,
    this.isExchange = false,
    this.exchangeSaleId,
    required this.userId,
    required this.createdAt,
  });

  factory SaleReturn.fromJson(Map<String, dynamic> json) => SaleReturn(
        id: json['id'] as String,
        saleId: json['sale_id'] as String,
        saleItemId: json['sale_item_id'] as String?,
        imeiItemId: json['imei_item_id'] as String?,
        quantity: _int(json['quantity']) == 0 ? 1 : _int(json['quantity']),
        reason: json['reason'] as String?,
        refundAmount: _int(json['refund_amount']),
        isExchange: json['is_exchange'] as bool? ?? false,
        exchangeSaleId: json['exchange_sale_id'] as String?,
        userId: json['user_id'] as String,
        createdAt: _dt(json['created_at']) ?? DateTime.now(),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'sale_id': saleId,
        'sale_item_id': saleItemId,
        'imei_item_id': imeiItemId,
        'quantity': quantity,
        'reason': reason,
        'refund_amount': refundAmount,
        'is_exchange': isExchange,
        'exchange_sale_id': exchangeSaleId,
        'user_id': userId,
        'created_at': createdAt.toIso8601String(),
      };

  SaleReturn copyWith({
    String? id,
    String? saleId,
    String? saleItemId,
    String? imeiItemId,
    int? quantity,
    String? reason,
    int? refundAmount,
    bool? isExchange,
    String? exchangeSaleId,
    String? userId,
    DateTime? createdAt,
  }) =>
      SaleReturn(
        id: id ?? this.id,
        saleId: saleId ?? this.saleId,
        saleItemId: saleItemId ?? this.saleItemId,
        imeiItemId: imeiItemId ?? this.imeiItemId,
        quantity: quantity ?? this.quantity,
        reason: reason ?? this.reason,
        refundAmount: refundAmount ?? this.refundAmount,
        isExchange: isExchange ?? this.isExchange,
        exchangeSaleId: exchangeSaleId ?? this.exchangeSaleId,
        userId: userId ?? this.userId,
        createdAt: createdAt ?? this.createdAt,
      );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SaleReturn &&
          other.id == id &&
          other.saleId == saleId &&
          other.refundAmount == refundAmount;

  @override
  int get hashCode => Object.hash(id, saleId, refundAmount);
}
