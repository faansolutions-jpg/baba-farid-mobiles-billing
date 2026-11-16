// Accessories Master Catalog — repository.
//
// The abstract class below is the contract the catalog screens (Cat-2)
// program against — copy it verbatim, do not change signatures.
// [CatalogRepositoryImpl] is the drift implementation over
// [CatalogDatabase] (catalog.db, separate from the main app database).
//
// Rules:
//  - [bulkStockIn] is ONE transaction: all rows apply or none do.
//  - [stockIn] updates catalog_stock AND last_purchase_price /
//    last_supplier / last_stock_date.
//  - [applyCatalogUpdate] inserts new SKUs and updates ESTIMATED prices
//    only; it never touches catalog_stock or is_custom items.
//  - [recordStockCount] writes a stock_counts row and adjusts
//    catalog_stock to the counted quantity.
//  - [search] delegates to the fuzzy / Roman-Urdu helper in
//    catalog_search.dart.
import 'dart:convert';

import 'package:drift/drift.dart';

import '../../data/database/catalog_database.dart';
import 'catalog_models.dart';
import 'catalog_search.dart';

abstract class CatalogRepository {
  Future<List<CatalogItem>> search(String query);
  Future<List<CatalogItem>> byCategory(String category);
  Future<List<CatalogItem>> byBrand(String category, String brand);
  Future<List<String>> categories();
  Future<List<String>> brands(String category);
  Future<void> stockIn(String itemId, int qty, {int? price, String? supplier, DateTime? date});
  Future<void> bulkStockIn(Map<String, int> quantities, {int? price, String? supplier, DateTime? date});
  /// Decrements catalog_stock for [itemId] by [qty] (the reverse of
  /// [stockIn] — used when catalog goods are returned to a supplier).
  /// Throws a clear error when the item does not exist or there is
  /// not enough stock; stock is never driven below zero.
  Future<void> stockOut(String itemId, int qty);
  Future<void> linkBarcode(String barcode, String itemId);
  Future<CatalogItem?> byBarcode(String barcode);
  Future<void> addCustomItem(CatalogItem item);
  Future<List<CatalogItem>> lowStock();
  Future<Map<String, List<CatalogItem>>> reorderListBySupplier();
  Future<void> recordStockCount(String itemId, int countedQty, String note);
  Future<List<CatalogItem>> zeroStock({bool includeZero = false});
  Future<void> applyCatalogUpdate(List<CatalogItem> items, String version);
  Future<String> catalogVersion();
}

class CatalogRepositoryImpl implements CatalogRepository {
  final CatalogDatabase db;

  CatalogRepositoryImpl(this.db);

  // ---- mapping ----

  List<String> _decodeList(String json) {
    try {
      final decoded = jsonDecode(json);
      if (decoded is List) return decoded.map((e) => e.toString()).toList();
    } catch (_) {
      // A plain (non-JSON) value is treated as a single entry.
      if (json.isNotEmpty) return [json];
    }
    return const [];
  }

  CatalogItem _toModel(CatalogItemRow row, CatalogStockRow? stock) {
    return CatalogItem(
      sku: row.sku,
      category: row.category,
      brand: row.brand,
      nameEn: row.nameEn,
      nameUr: row.nameUr,
      modelCompatibility: row.modelCompatibility,
      colors: _decodeList(row.colors),
      variants: _decodeList(row.variants),
      purchasePriceEst: row.purchasePriceEst,
      salePriceEst: row.salePriceEst,
      minPrice: row.minPrice,
      unit: row.unit,
      barcode: row.barcode,
      isCustom: row.isCustom,
      estimated: row.estimated,
      stockQty: stock?.quantity ?? 0,
      lowStockThreshold: stock?.lowStockThreshold ?? 5,
    );
  }

  /// Load stock rows for the given SKUs in one query.
  Future<Map<String, CatalogStockRow>> _stockBySku(Iterable<String> skus) async {
    final list = skus.toSet().toList();
    if (list.isEmpty) return {};
    final rows = await (db.select(db.catalogStock)
          ..where((t) => t.sku.isIn(list)))
        .get();
    return {for (final r in rows) r.sku: r};
  }

  Future<List<CatalogItem>> _withStock(List<CatalogItemRow> rows) async {
    final stock = await _stockBySku(rows.map((r) => r.sku));
    return rows.map((r) => _toModel(r, stock[r.sku])).toList();
  }

  Future<CatalogItemRow?> _rowBySku(String sku) async {
    return (db.select(db.catalogItems)..where((t) => t.sku.equals(sku)))
        .getSingleOrNull();
  }

  // ---- reads ----

  @override
  Future<List<CatalogItem>> search(String query) async {
    final all = await _withStock(await db.select(db.catalogItems).get());
    return searchCatalog(all, query);
  }

  @override
  Future<List<CatalogItem>> byCategory(String category) async {
    final rows = await (db.select(db.catalogItems)
          ..where((t) => t.category.equals(category))
          ..orderBy([(t) => OrderingTerm(expression: t.nameEn)]))
        .get();
    return _withStock(rows);
  }

  @override
  Future<List<CatalogItem>> byBrand(String category, String brand) async {
    final rows = await (db.select(db.catalogItems)
          ..where((t) => t.category.equals(category) & t.brand.equals(brand))
          ..orderBy([(t) => OrderingTerm(expression: t.nameEn)]))
        .get();
    return _withStock(rows);
  }

  @override
  Future<List<String>> categories() async {
    final rows = await (db.select(db.catalogCategories)
          ..orderBy([(t) => OrderingTerm(expression: t.sortOrder)]))
        .get();
    if (rows.isNotEmpty) return rows.map((r) => r.nameEn).toList();
    // Fallback when the categories table was never seeded: distinct
    // categories actually present in the items.
    final items = await db.select(db.catalogItems).get();
    return items.map((r) => r.category).toSet().toList()..sort();
  }

  @override
  Future<List<String>> brands(String category) async {
    final rows = await (db.select(db.catalogItems)
          ..where((t) => t.category.equals(category)))
        .get();
    return rows.map((r) => r.brand).toSet().toList()..sort();
  }

  // ---- stock-in ----

  Future<void> _applyStockIn(
    String itemId,
    int qty, {
    int? price,
    String? supplier,
    DateTime? date,
  }) async {
    final row = await _rowBySku(itemId);
    if (row == null) throw StateError('Catalog item $itemId not found');
    final existing = await (db.select(db.catalogStock)
          ..where((t) => t.sku.equals(itemId)))
        .getSingleOrNull();
    final now = date ?? DateTime.now();
    await db.into(db.catalogStock).insert(
          CatalogStockCompanion.insert(
            sku: itemId,
            quantity: Value((existing?.quantity ?? 0) + qty),
            lastPurchasePrice: Value(price ?? existing?.lastPurchasePrice),
            lastSupplier: Value(supplier ?? existing?.lastSupplier),
            lastStockDate: Value(now),
            lowStockThreshold:
                Value(existing?.lowStockThreshold ?? 5),
          ),
          mode: InsertMode.insertOrReplace,
        );
  }

  @override
  Future<void> stockIn(String itemId, int qty,
      {int? price, String? supplier, DateTime? date}) async {
    if (qty <= 0) throw ArgumentError.value(qty, 'qty', 'must be positive');
    await db.transaction(() async {
      await _applyStockIn(itemId, qty,
          price: price, supplier: supplier, date: date);
    });
  }

  @override
  Future<void> stockOut(String itemId, int qty) async {
    if (qty <= 0) throw ArgumentError.value(qty, 'qty', 'must be positive');
    await db.transaction(() async {
      final row = await _rowBySku(itemId);
      if (row == null) throw StateError('Catalog item $itemId not found');
      final existing = await (db.select(db.catalogStock)
            ..where((t) => t.sku.equals(itemId)))
          .getSingleOrNull();
      final current = existing?.quantity ?? 0;
      if (current < qty) {
        throw StateError(
            'Not enough stock for $itemId: only $current available, '
            'cannot remove $qty');
      }
      await db.into(db.catalogStock).insert(
            CatalogStockCompanion.insert(
              sku: itemId,
              quantity: Value(current - qty),
              lastPurchasePrice: Value(existing?.lastPurchasePrice),
              lastSupplier: Value(existing?.lastSupplier),
              lastStockDate: Value(existing?.lastStockDate),
              lowStockThreshold:
                  Value(existing?.lowStockThreshold ?? 5),
            ),
            mode: InsertMode.insertOrReplace,
          );
    });
  }

  @override
  Future<void> bulkStockIn(Map<String, int> quantities,
      {int? price, String? supplier, DateTime? date}) async {
    if (quantities.isEmpty) return;
    for (final qty in quantities.values) {
      if (qty <= 0) {
        throw ArgumentError.value(qty, 'qty', 'all quantities must be positive');
      }
    }
    // One transaction: validate every SKU first, then apply all.
    // Any failure rolls the whole batch back (all or nothing).
    await db.transaction(() async {
      for (final sku in quantities.keys) {
        if (await _rowBySku(sku) == null) {
          throw StateError('Catalog item $sku not found — bulk stock-in aborted');
        }
      }
      for (final entry in quantities.entries) {
        await _applyStockIn(entry.key, entry.value,
            price: price, supplier: supplier, date: date);
      }
    });
  }

  // ---- barcodes ----

  @override
  Future<void> linkBarcode(String barcode, String itemId) async {
    final clean = barcode.trim();
    if (clean.isEmpty) throw ArgumentError('barcode must not be empty');
    await db.transaction(() async {
      final row = await _rowBySku(itemId);
      if (row == null) throw StateError('Catalog item $itemId not found');
      final existing = await (db.select(db.barcodeLinks)
            ..where((t) => t.barcode.equals(clean)))
          .getSingleOrNull();
      if (existing != null && existing.sku != itemId) {
        throw StateError(
            'Barcode $clean is already linked to ${existing.sku}');
      }
      await db.into(db.barcodeLinks).insert(
            BarcodeLinksCompanion.insert(barcode: clean, sku: itemId),
            mode: InsertMode.insertOrIgnore,
          );
      await (db.update(db.catalogItems)..where((t) => t.sku.equals(itemId)))
          .write(CatalogItemsCompanion(barcode: Value(clean)));
    });
  }

  @override
  Future<CatalogItem?> byBarcode(String barcode) async {
    final clean = barcode.trim();
    final link = await (db.select(db.barcodeLinks)
          ..where((t) => t.barcode.equals(clean)))
        .getSingleOrNull();
    CatalogItemRow? row;
    if (link != null) {
      row = await _rowBySku(link.sku);
    } else {
      row = await (db.select(db.catalogItems)
            ..where((t) => t.barcode.equals(clean)))
          .getSingleOrNull();
    }
    if (row == null) return null;
    final stock = await _stockBySku([row.sku]);
    return _toModel(row, stock[row.sku]);
  }

  // ---- custom items ----

  @override
  Future<void> addCustomItem(CatalogItem item) async {
    await db.transaction(() async {
      if (await _rowBySku(item.sku) != null) {
        throw StateError('Catalog item ${item.sku} already exists');
      }
      await db.into(db.catalogItems).insert(
            CatalogItemsCompanion.insert(
              sku: item.sku,
              category: item.category,
              brand: item.brand,
              nameEn: item.nameEn,
              nameUr: Value(item.nameUr),
              modelCompatibility: Value(item.modelCompatibility),
              colors: Value(jsonEncode(item.colors)),
              variants: Value(jsonEncode(item.variants)),
              purchasePriceEst: Value(item.purchasePriceEst),
              salePriceEst: Value(item.salePriceEst),
              minPrice: Value(item.minPrice),
              unit: Value(item.unit),
              barcode: Value(item.barcode),
              isCustom: const Value(true),
              estimated: Value(item.estimated),
            ),
          );
      await db.into(db.catalogStock).insert(
            CatalogStockCompanion.insert(
              sku: item.sku,
              quantity: Value(item.stockQty),
              lowStockThreshold: Value(item.lowStockThreshold),
            ),
            mode: InsertMode.insertOrIgnore,
          );
    });
  }

  // ---- low stock / reorder ----

  @override
  Future<List<CatalogItem>> lowStock() async {
    final stocks = await (db.select(db.catalogStock)
          ..where((t) => t.quantity.isSmallerThan(t.lowStockThreshold))
          ..orderBy([(t) => OrderingTerm(expression: t.quantity)]))
        .get();
    if (stocks.isEmpty) return const [];
    final rows = await (db.select(db.catalogItems)
          ..where((t) => t.sku.isIn(stocks.map((s) => s.sku))))
        .get();
    final bySku = {for (final r in rows) r.sku: r};
    return stocks
        .where((s) => bySku.containsKey(s.sku))
        .map((s) => _toModel(bySku[s.sku]!, s))
        .toList();
  }

  @override
  Future<Map<String, List<CatalogItem>>> reorderListBySupplier() async {
    final stocks = await (db.select(db.catalogStock)
          ..where((t) => t.quantity.isSmallerThan(t.lowStockThreshold)))
        .get();
    if (stocks.isEmpty) return {};
    final rows = await (db.select(db.catalogItems)
          ..where((t) => t.sku.isIn(stocks.map((s) => s.sku))))
        .get();
    final bySku = {for (final r in rows) r.sku: r};
    final grouped = <String, List<CatalogItem>>{};
    for (final s in stocks) {
      final row = bySku[s.sku];
      if (row == null) continue;
      final supplier = (s.lastSupplier == null || s.lastSupplier!.isEmpty)
          ? 'Unknown supplier'
          : s.lastSupplier!;
      (grouped[supplier] ??= []).add(_toModel(row, s));
    }
    return grouped;
  }

  // ---- stock count (audit) ----

  @override
  Future<void> recordStockCount(
      String itemId, int countedQty, String note) async {
    if (countedQty < 0) {
      throw ArgumentError.value(countedQty, 'countedQty', 'must be >= 0');
    }
    await db.transaction(() async {
      final row = await _rowBySku(itemId);
      if (row == null) throw StateError('Catalog item $itemId not found');
      final stock = await (db.select(db.catalogStock)
            ..where((t) => t.sku.equals(itemId)))
          .getSingleOrNull();
      final systemQty = stock?.quantity ?? 0;
      await db.into(db.stockCounts).insert(
            StockCountsCompanion.insert(
              sku: itemId,
              countedQty: countedQty,
              systemQty: systemQty,
              difference: countedQty - systemQty,
              note: Value(note.isEmpty ? null : note),
            ),
          );
      await db.into(db.catalogStock).insert(
            CatalogStockCompanion.insert(
              sku: itemId,
              quantity: Value(countedQty),
              lowStockThreshold:
                  Value(stock?.lowStockThreshold ?? 5),
              lastPurchasePrice: Value(stock?.lastPurchasePrice),
              lastSupplier: Value(stock?.lastSupplier),
              lastStockDate: Value(stock?.lastStockDate),
            ),
            mode: InsertMode.insertOrReplace,
          );
    });
  }

  @override
  Future<List<CatalogItem>> zeroStock({bool includeZero = false}) async {
    final stocks = await db.select(db.catalogStock).get();
    final rows = await db.select(db.catalogItems).get();
    final out = <CatalogItem>[];
    final stockBySku = {for (final s in stocks) s.sku: s};
    for (final row in rows) {
      final stock = stockBySku[row.sku];
      if (stock != null && stock.quantity == 0) {
        out.add(_toModel(row, stock));
      } else if (includeZero && stock == null) {
        // Never stocked: no catalog_stock row at all — also zero.
        out.add(_toModel(row, null));
      }
    }
    return out;
  }

  // ---- catalog version update ----

  @override
  Future<void> applyCatalogUpdate(
      List<CatalogItem> items, String version) async {
    await db.transaction(() async {
      for (final item in items) {
        final existing = await _rowBySku(item.sku);
        if (existing == null) {
          // New SKU: insert the item and an empty stock row.
          await db.into(db.catalogItems).insert(
                CatalogItemsCompanion.insert(
                  sku: item.sku,
                  category: item.category,
                  brand: item.brand,
                  nameEn: item.nameEn,
                  nameUr: Value(item.nameUr),
                  modelCompatibility: Value(item.modelCompatibility),
                  colors: Value(jsonEncode(item.colors)),
                  variants: Value(jsonEncode(item.variants)),
                  purchasePriceEst: Value(item.purchasePriceEst),
                  salePriceEst: Value(item.salePriceEst),
                  minPrice: Value(item.minPrice),
                  unit: Value(item.unit),
                  barcode: Value(item.barcode),
                  isCustom: const Value(false),
                  estimated: Value(item.estimated),
                ),
              );
          await db.into(db.catalogStock).insert(
                CatalogStockCompanion.insert(
                  sku: item.sku,
                  lowStockThreshold: Value(item.lowStockThreshold),
                ),
                mode: InsertMode.insertOrIgnore,
              );
        } else if (!existing.isCustom) {
          // Existing, non-custom item: refresh ESTIMATED prices only.
          // Name / stock / barcode / custom flags are never overwritten.
          await (db.update(db.catalogItems)
                ..where((t) => t.sku.equals(item.sku)))
              .write(CatalogItemsCompanion(
                purchasePriceEst: Value(item.purchasePriceEst),
                salePriceEst: Value(item.salePriceEst),
                minPrice: Value(item.minPrice),
                updatedAt: Value(DateTime.now()),
              ));
        }
        // is_custom items are skipped entirely — the shopkeeper owns them.
      }
      await db.into(db.catalogVersions).insert(
            CatalogVersionsCompanion.insert(
              version: version,
              itemCount: Value(items.length),
            ),
            mode: InsertMode.insertOrIgnore,
          );
    });
  }

  @override
  Future<String> catalogVersion() async {
    final row = await (db.select(db.catalogVersions)
          ..orderBy([
            (t) => OrderingTerm(expression: t.appliedAt, mode: OrderingMode.desc),
            // Tie-break: two versions applied in the same second.
            (t) => OrderingTerm(expression: t.version, mode: OrderingMode.desc),
          ])
          ..limit(1))
        .getSingleOrNull();
    return row?.version ?? '';
  }
}
