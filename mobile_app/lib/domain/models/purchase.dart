/// Purchase + PurchaseItem (+ PurchaseReturn) models.
/// Mirrors `purchases`, `purchase_items` and `purchase_returns` in
/// schema.sql. Money is integer whole PKR.
library;

DateTime? _dt(dynamic v) =>
    v == null ? null : (v is DateTime ? v : DateTime.tryParse(v.toString()));

int _int(dynamic v) => (v as num?)?.toInt() ?? 0;

/// One line of a purchase. For phones there is one row per IMEI
/// ([imei1]/[imei2]); for accessories [quantity] is the count bought.
/// Catalog accessories have no product/variant in the main DB — they
/// carry [catalogSku] instead, which is how a later purchase return
/// knows to decrement catalog stock (see `CatalogRepository.stockOut`).
class PurchaseItem {
  final String id;
  final String purchaseId;
  final String? productId;
  final String? variantId;
  final String? imei1;
  final String? imei2;

  /// Catalog accessory SKU; null for phones and main-DB accessories.
  final String? catalogSku;
  final int quantity;
  final int unitCost;
  final int total;
  final DateTime createdAt;

  const PurchaseItem({
    required this.id,
    required this.purchaseId,
    this.productId,
    this.variantId,
    this.imei1,
    this.imei2,
    this.catalogSku,
    this.quantity = 1,
    required this.unitCost,
    required this.total,
    required this.createdAt,
  });

  factory PurchaseItem.fromJson(Map<String, dynamic> json) => PurchaseItem(
        id: json['id'] as String,
        purchaseId: json['purchase_id'] as String,
        productId: json['product_id'] as String?,
        variantId: json['variant_id'] as String?,
        imei1: json['imei1'] as String?,
        imei2: json['imei2'] as String?,
        catalogSku: json['catalog_sku'] as String?,
        quantity: _int(json['quantity']) == 0 ? 1 : _int(json['quantity']),
        unitCost: _int(json['unit_cost']),
        total: _int(json['total']),
        createdAt: _dt(json['created_at']) ?? DateTime.now(),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'purchase_id': purchaseId,
        'product_id': productId,
        'variant_id': variantId,
        'imei1': imei1,
        'imei2': imei2,
        'catalog_sku': catalogSku,
        'quantity': quantity,
        'unit_cost': unitCost,
        'total': total,
        'created_at': createdAt.toIso8601String(),
      };

  PurchaseItem copyWith({
    String? id,
    String? purchaseId,
    String? productId,
    String? variantId,
    String? imei1,
    String? imei2,
    String? catalogSku,
    int? quantity,
    int? unitCost,
    int? total,
    DateTime? createdAt,
  }) =>
      PurchaseItem(
        id: id ?? this.id,
        purchaseId: purchaseId ?? this.purchaseId,
        productId: productId ?? this.productId,
        variantId: variantId ?? this.variantId,
        imei1: imei1 ?? this.imei1,
        imei2: imei2 ?? this.imei2,
        catalogSku: catalogSku ?? this.catalogSku,
        quantity: quantity ?? this.quantity,
        unitCost: unitCost ?? this.unitCost,
        total: total ?? this.total,
        createdAt: createdAt ?? this.createdAt,
      );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PurchaseItem &&
          other.id == id &&
          other.purchaseId == purchaseId &&
          other.imei1 == imei1 &&
          other.total == total;

  @override
  int get hashCode => Object.hash(id, purchaseId, imei1, total);
}

/// A stock purchase from a supplier. `items` is the in-memory line list.
class Purchase {
  final String id;
  final String supplierId;
  final String? branchId;
  final String userId;
  final String? supplierInvoiceNo;
  final DateTime purchaseDate;
  final int subtotal;
  final int discount;
  final int grandTotal;
  final int paidAmount;
  final int balanceDue;

  /// `received` | `partially_returned` | `returned` | `cancelled`.
  final String status;
  final String? notes;
  final String? clientUuid;
  final List<PurchaseItem> items;
  final DateTime createdAt;
  final DateTime updatedAt;

  /// Denormalised supplier name for lists (not a column).
  final String? supplierName;

  const Purchase({
    required this.id,
    required this.supplierId,
    this.branchId,
    required this.userId,
    this.supplierInvoiceNo,
    required this.purchaseDate,
    this.subtotal = 0,
    this.discount = 0,
    required this.grandTotal,
    this.paidAmount = 0,
    this.balanceDue = 0,
    this.status = 'received',
    this.notes,
    this.clientUuid,
    this.items = const [],
    required this.createdAt,
    required this.updatedAt,
    this.supplierName,
  });

  factory Purchase.fromJson(Map<String, dynamic> json) => Purchase(
        id: json['id'] as String,
        supplierId: json['supplier_id'] as String,
        branchId: json['branch_id'] as String?,
        userId: json['user_id'] as String,
        supplierInvoiceNo: json['supplier_invoice_no'] as String?,
        purchaseDate: _dt(json['purchase_date']) ?? DateTime.now(),
        subtotal: _int(json['subtotal']),
        discount: _int(json['discount']),
        grandTotal: _int(json['grand_total']),
        paidAmount: _int(json['paid_amount']),
        balanceDue: _int(json['balance_due']),
        status: json['status'] as String? ?? 'received',
        notes: json['notes'] as String?,
        clientUuid: json['client_uuid'] as String?,
        items: (json['items'] as List?)
                ?.map((e) => PurchaseItem.fromJson(e as Map<String, dynamic>))
                .toList() ??
            const [],
        createdAt: _dt(json['created_at']) ?? DateTime.now(),
        updatedAt: _dt(json['updated_at']) ?? DateTime.now(),
        supplierName: json['supplier_name'] as String?,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'supplier_id': supplierId,
        'branch_id': branchId,
        'user_id': userId,
        'supplier_invoice_no': supplierInvoiceNo,
        'purchase_date': purchaseDate.toIso8601String(),
        'subtotal': subtotal,
        'discount': discount,
        'grand_total': grandTotal,
        'paid_amount': paidAmount,
        'balance_due': balanceDue,
        'status': status,
        'notes': notes,
        'client_uuid': clientUuid,
        'items': items.map((e) => e.toJson()).toList(),
        'created_at': createdAt.toIso8601String(),
        'updated_at': updatedAt.toIso8601String(),
        'supplier_name': supplierName,
      };

  Purchase copyWith({
    String? id,
    String? supplierId,
    String? branchId,
    String? userId,
    String? supplierInvoiceNo,
    DateTime? purchaseDate,
    int? subtotal,
    int? discount,
    int? grandTotal,
    int? paidAmount,
    int? balanceDue,
    String? status,
    String? notes,
    String? clientUuid,
    List<PurchaseItem>? items,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? supplierName,
  }) =>
      Purchase(
        id: id ?? this.id,
        supplierId: supplierId ?? this.supplierId,
        branchId: branchId ?? this.branchId,
        userId: userId ?? this.userId,
        supplierInvoiceNo: supplierInvoiceNo ?? this.supplierInvoiceNo,
        purchaseDate: purchaseDate ?? this.purchaseDate,
        subtotal: subtotal ?? this.subtotal,
        discount: discount ?? this.discount,
        grandTotal: grandTotal ?? this.grandTotal,
        paidAmount: paidAmount ?? this.paidAmount,
        balanceDue: balanceDue ?? this.balanceDue,
        status: status ?? this.status,
        notes: notes ?? this.notes,
        clientUuid: clientUuid ?? this.clientUuid,
        items: items ?? this.items,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
        supplierName: supplierName ?? this.supplierName,
      );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Purchase &&
          other.id == id &&
          other.supplierId == supplierId &&
          other.grandTotal == grandTotal &&
          other.status == status;

  @override
  int get hashCode => Object.hash(id, supplierId, grandTotal, status);
}

/// Goods sent back to a supplier (`purchase_returns` table). Append-only.
class PurchaseReturn {
  final String id;
  final String purchaseId;
  final String? imeiItemId;
  final String? productId;
  final String? variantId;

  /// Catalog accessory SKU returned; null for phones / main-DB items.
  final String? catalogSku;
  final int quantity;
  final String? reason;
  final int refundAmount;
  final String userId;
  final DateTime createdAt;

  const PurchaseReturn({
    required this.id,
    required this.purchaseId,
    this.imeiItemId,
    this.productId,
    this.variantId,
    this.catalogSku,
    this.quantity = 1,
    this.reason,
    this.refundAmount = 0,
    required this.userId,
    required this.createdAt,
  });

  factory PurchaseReturn.fromJson(Map<String, dynamic> json) =>
      PurchaseReturn(
        id: json['id'] as String,
        purchaseId: json['purchase_id'] as String,
        imeiItemId: json['imei_item_id'] as String?,
        productId: json['product_id'] as String?,
        variantId: json['variant_id'] as String?,
        catalogSku: json['catalog_sku'] as String?,
        quantity: _int(json['quantity']) == 0 ? 1 : _int(json['quantity']),
        reason: json['reason'] as String?,
        refundAmount: _int(json['refund_amount']),
        userId: json['user_id'] as String,
        createdAt: _dt(json['created_at']) ?? DateTime.now(),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'purchase_id': purchaseId,
        'imei_item_id': imeiItemId,
        'product_id': productId,
        'variant_id': variantId,
        'catalog_sku': catalogSku,
        'quantity': quantity,
        'reason': reason,
        'refund_amount': refundAmount,
        'user_id': userId,
        'created_at': createdAt.toIso8601String(),
      };

  PurchaseReturn copyWith({
    String? id,
    String? purchaseId,
    String? imeiItemId,
    String? productId,
    String? variantId,
    String? catalogSku,
    int? quantity,
    String? reason,
    int? refundAmount,
    String? userId,
    DateTime? createdAt,
  }) =>
      PurchaseReturn(
        id: id ?? this.id,
        purchaseId: purchaseId ?? this.purchaseId,
        imeiItemId: imeiItemId ?? this.imeiItemId,
        productId: productId ?? this.productId,
        variantId: variantId ?? this.variantId,
        catalogSku: catalogSku ?? this.catalogSku,
        quantity: quantity ?? this.quantity,
        reason: reason ?? this.reason,
        refundAmount: refundAmount ?? this.refundAmount,
        userId: userId ?? this.userId,
        createdAt: createdAt ?? this.createdAt,
      );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PurchaseReturn &&
          other.id == id &&
          other.purchaseId == purchaseId &&
          other.refundAmount == refundAmount;

  @override
  int get hashCode => Object.hash(id, purchaseId, refundAmount);
}
