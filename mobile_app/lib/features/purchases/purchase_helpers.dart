/// Shared helpers for the Purchases / Suppliers screens (Round 2E).
///
/// Supplier data comes from [SupplierRepository.listSuppliers] —
/// every supplier, including zero-payable ones, each with its
/// current payable from the supplier ledger. Callers must pass the
/// repository; there is no payable-only fallback (the legacy path
/// that sourced only suppliers with an outstanding payable from
/// [ReportRepository.supplierPayables] was removed in Round 3 —
/// it hid zero-payable suppliers from pickers and the detail route).
library;

import '../../data/repositories/supplier_repository.dart';

/// One supplier row for lists, pickers and the detail screen.
class SupplierSummary {
  const SupplierSummary({
    required this.id,
    required this.name,
    required this.phone,
    required this.payable,
  });

  final String id;
  final String name;
  final String phone;
  final int payable;

  SupplierSummary copyWith({int? payable}) => SupplierSummary(
        id: id,
        name: name,
        phone: phone,
        payable: payable ?? this.payable,
      );
}

/// Loads every supplier with the exact current payable from the
/// supplier ledger, sourced from [SupplierRepository] so
/// zero-payable suppliers are included.
Future<List<SupplierSummary>> loadSupplierSummaries({
  required SupplierRepository suppliers,
}) async {
  final all = await suppliers.listSuppliers();
  final summaries = all
      .map((s) => SupplierSummary(
            id: s.id,
            name: s.name,
            phone: s.phone ?? '',
            payable: s.payable,
          ))
      .toList();
  summaries.sort((a, b) => b.payable.compareTo(a.payable));
  return summaries;
}

/// Kind of one in-memory purchase-entry line.
enum DraftLineKind { phone, accessory }

/// One line of the purchase being entered (not yet saved).
class DraftPurchaseLine {
  DraftPurchaseLine({
    required this.kind,
    required this.label,
    this.productId,
    this.variantId,
    this.catalogSku,
    this.imei1,
    this.imei2,
    this.quantity = 1,
    required this.unitCost,
  });

  final DraftLineKind kind;

  /// Display name, e.g. `Galaxy A15 · 8GB/128GB Black` or a catalog name.
  final String label;
  final String? productId;
  final String? variantId;

  /// Set for catalog accessories (no product/variant in the main DB).
  /// Stock for these lines is added via CatalogRepository.stockIn on save.
  final String? catalogSku;
  final String? imei1;
  final String? imei2;
  int quantity;
  int unitCost;

  int get total => unitCost * quantity;

  bool get isCatalog => catalogSku != null;
}
