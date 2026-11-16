// Accessories Master Catalog — unit tests.
//
// Run with:  flutter test test/catalog_test.dart
// (from mobile_app/). Pure logic tests — no widgets, no network, no
// real files. The repository tests run against an in-memory drift
// database (CatalogDatabase.memory()), so they need the generated
// catalog_database.g.dart — run `dart run build_runner build` first.
import 'package:baba_farid_mobiles/data/database/catalog_database.dart';
import 'package:baba_farid_mobiles/features/catalog/catalog_models.dart';
import 'package:baba_farid_mobiles/features/catalog/catalog_repository.dart';
import 'package:baba_farid_mobiles/features/catalog/catalog_search.dart';
import 'package:flutter_test/flutter_test.dart';

CatalogItem _item(
  String sku, {
  String category = 'Cables',
  String brand = 'Anker',
  String nameEn = 'Anker Type-C Cable 1m Fast Charge',
  String? modelCompatibility,
  int purchase = 300,
  int sale = 400,
  int min = 320,
  bool isCustom = false,
  int stockQty = 0,
  int lowStockThreshold = 5,
}) {
  return CatalogItem(
    sku: sku,
    category: category,
    brand: brand,
    nameEn: nameEn,
    nameUr: 'چارجر',
    modelCompatibility: modelCompatibility,
    purchasePriceEst: purchase,
    salePriceEst: sale,
    minPrice: min,
    isCustom: isCustom,
    stockQty: stockQty,
    lowStockThreshold: lowStockThreshold,
  );
}

List<CatalogItem> _seedItems() => [
      _item('ACC-CAB-ANK-TC10-001'),
      _item('ACC-CAB-ANK-TC15-001',
          nameEn: 'Anker Type-C Cable 1.5m Fast Charge'),
      _item('ACC-CHG-ANK-20W-001',
          category: 'Chargers',
          nameEn: 'Anker 20W Fast Wall Charger',
          purchase: 1800,
          sale: 2340,
          min: 1890),
      _item('ACC-PRT-GEN-SIL-001',
          category: 'Protection',
          brand: 'Generic',
          nameEn: 'Silicone Back Cover for Apple iPhone 15',
          modelCompatibility: 'Apple iPhone 15',
          purchase: 250,
          sale: 330,
          min: 260),
    ];

/// Minimal CSV import with the same matching rule as the backend:
/// match by SKU first, then by normalised name; matched rows stock in,
/// unmatched rows with a SKU + name become custom items.
Future<({int matched, int created, int skipped})> importCsvRows(
  CatalogRepository repo,
  String csv,
) async {
  final lines = csv.trim().split('\n');
  final header = lines.first.split(',').map((h) => h.trim()).toList();
  var matched = 0;
  var created = 0;
  var skipped = 0;
  for (final line in lines.skip(1)) {
    final cells = line.split(',').map((c) => c.trim()).toList();
    final row = <String, String>{
      for (var i = 0; i < header.length && i < cells.length; i++)
        header[i]: cells[i]
    };
    final sku = row['sku'] ?? '';
    final name = row['nameEn'] ?? '';
    final qty = int.tryParse(row['qty'] ?? '0') ?? 0;
    CatalogItem? hit;
    if (sku.isNotEmpty) {
      final bySku = await repo.search(sku);
      hit = bySku.where((i) => i.sku == sku).firstOrNull;
    }
    hit ??= (await repo.search(name))
        .where((i) => normalizeQuery(i.nameEn) == normalizeQuery(name))
        .firstOrNull;
    if (hit != null) {
      matched++;
      if (qty > 0) await repo.stockIn(hit.sku, qty);
    } else if (sku.isNotEmpty && name.isNotEmpty) {
      await repo.addCustomItem(_item(sku, nameEn: name, stockQty: qty));
      created++;
    } else {
      skipped++;
    }
  }
  return (matched: matched, created: created, skipped: skipped);
}

void main() {
  late CatalogDatabase db;
  late CatalogRepository repo;

  setUp(() async {
    db = CatalogDatabase.memory();
    repo = CatalogRepositoryImpl(db);
    await repo.applyCatalogUpdate(_seedItems(), '1.0.0-test');
  });

  tearDown(() async {
    await db.close();
  });

  group('catalog seed / version update', () {
    test('idempotent seed: applying the same items twice creates no duplicates',
        () async {
      await repo.applyCatalogUpdate(_seedItems(), '1.0.0-test');
      await repo.applyCatalogUpdate(_seedItems(), '1.0.0-test');
      final all = await repo.search('');
      expect(all.length, _seedItems().length);
      final skus = all.map((i) => i.sku).toSet();
      expect(skus.length, all.length);
    });

    test('catalog update preserves stock and custom items', () async {
      // Stock in + a shopkeeper custom item with its own price.
      await repo.stockIn('ACC-CAB-ANK-TC10-001', 10,
          price: 280, supplier: 'Lahore Market');
      await repo.addCustomItem(_item('CUST-001',
          nameEn: 'Shopkeeper Special Cable', purchase: 999, sale: 1999));
      await repo.stockIn('CUST-001', 4);

      // New version: same SKU with a *different* estimated price, plus a
      // brand-new SKU. Custom item price must NOT change.
      final updated = [
        _item('ACC-CAB-ANK-TC10-001', purchase: 500, sale: 650, min: 525),
        _item('ACC-CAB-ANK-TC10-002',
            nameEn: 'Anker Type-C Cable 2m Fast Charge'),
        _item('CUST-001', purchase: 1, sale: 2, min: 1),
      ];
      await repo.applyCatalogUpdate(updated, '1.0.1-test');

      final cable = (await repo.search('ACC-CAB-ANK-TC10-001')).first;
      expect(cable.purchasePriceEst, 500); // estimated price refreshed
      expect(cable.stockQty, 10); // stock preserved
      final custom = (await repo.search('CUST-001')).first;
      expect(custom.purchasePriceEst, 999); // custom price untouched
      expect(custom.salePriceEst, 1999);
      expect(custom.stockQty, 4);
      expect((await repo.search('ACC-CAB-ANK-TC10-002')).length, 1);
    });

    test('catalogVersion returns the latest applied version', () async {
      expect(await repo.catalogVersion(), '1.0.0-test');
      await repo.applyCatalogUpdate(_seedItems(), '1.0.1-test');
      expect(await repo.catalogVersion(), '1.0.1-test');
    });
  });

  group('stock', () {
    test('stockIn updates quantity and lowStock reflects it', () async {
      // Stock 6 (above the default threshold of 5) so the item leaves
      // the low-stock list; stocking 3 would still be below threshold.
      await repo.stockIn('ACC-CAB-ANK-TC10-001', 6);
      final low = await repo.lowStock();
      expect(low.any((i) => i.sku == 'ACC-CAB-ANK-TC10-001'), isFalse);
      await repo.recordStockCount('ACC-CAB-ANK-TC10-001', 2, 'evening count');
      final item = (await repo.search('ACC-CAB-ANK-TC10-001')).first;
      expect(item.stockQty, 2);
    });

    test('bulk stock-in is atomic: one bad SKU rolls everything back',
        () async {
      await expectLater(
        repo.bulkStockIn({
          'ACC-CAB-ANK-TC10-001': 5,
          'ACC-DOES-NOT-EXIST': 5,
        }),
        throwsStateError,
      );
      final item = (await repo.search('ACC-CAB-ANK-TC10-001')).first;
      expect(item.stockQty, 0, reason: 'the good row must roll back too');
    });

    test('bulk stock-in applies all rows when every SKU exists', () async {
      await repo.bulkStockIn({
        'ACC-CAB-ANK-TC10-001': 5,
        'ACC-CHG-ANK-20W-001': 7,
      }, supplier: 'Hall Road');
      expect((await repo.search('ACC-CAB-ANK-TC10-001')).first.stockQty, 5);
      expect((await repo.search('ACC-CHG-ANK-20W-001')).first.stockQty, 7);
      final reorder = await repo.reorderListBySupplier();
      expect(reorder.containsKey('Hall Road'), isFalse,
          reason: 'stocked above threshold, so nothing to reorder');
    });

    test('zeroStock lists out-of-stock items', () async {
      await repo.stockIn('ACC-CAB-ANK-TC10-001', 2);
      final zero = await repo.zeroStock();
      expect(zero.any((i) => i.sku == 'ACC-CAB-ANK-TC10-001'), isFalse);
      expect(zero.any((i) => i.sku == 'ACC-CHG-ANK-20W-001'), isTrue);
    });
  });

  group('barcode', () {
    test('barcode link then lookup finds the item', () async {
      await repo.linkBarcode('8961234567890', 'ACC-CAB-ANK-TC10-001');
      final found = await repo.byBarcode('8961234567890');
      expect(found, isNotNull);
      expect(found!.sku, 'ACC-CAB-ANK-TC10-001');
      expect(await repo.byBarcode('0000000000000'), isNull);
    });

    test('linking the same barcode to another SKU is rejected', () async {
      await repo.linkBarcode('8961234567890', 'ACC-CAB-ANK-TC10-001');
      await expectLater(
        repo.linkBarcode('8961234567890', 'ACC-CHG-ANK-20W-001'),
        throwsStateError,
      );
    });
  });

  group('CSV import matching', () {
    test('matches by SKU, then by normalised name, creates the rest',
        () async {
      const csv = '''
sku,nameEn,qty
ACC-CAB-ANK-TC10-001,Anker Type-C Cable 1m Fast Charge,4
,anker type-c cable 1.5m fast charge,2
NEW-001,Brand New Gadget Cable,3
''';
      final result = await importCsvRows(repo, csv);
      expect(result.matched, 2);
      expect(result.created, 1);
      expect(result.skipped, 0);
      expect((await repo.search('ACC-CAB-ANK-TC10-001')).first.stockQty, 4);
      expect(
          (await repo.search('ACC-CAB-ANK-TC15-001')).first.stockQty, 2);
      expect((await repo.search('NEW-001')).first.isCustom, isTrue);
    });
  });

  group('search', () {
    test('"type c cabel" finds the Type-C cable', () {
      final items = _seedItems();
      final results = searchCatalog(items, 'type c cabel');
      expect(results, isNotEmpty);
      expect(results.first.sku, 'ACC-CAB-ANK-TC10-001');
    });

    test('roman-urdu synonyms: "carger" finds chargers', () {
      final items = _seedItems();
      final results = searchCatalog(items, 'carger');
      expect(results.map((i) => i.sku), contains('ACC-CHG-ANK-20W-001'));
    });

    test('search returns results in <300ms for 5000 items', () {
      final items = List<CatalogItem>.generate(
        5000,
        (i) => _item('ACC-T-$i',
            nameEn: 'Generic Accessory Item Number $i Type-C Cable'),
      );
      final stopwatch = Stopwatch()..start();
      final results = searchCatalog(items, 'type c cabel');
      stopwatch.stop();
      expect(results, isNotEmpty);
      expect(stopwatch.elapsedMilliseconds, lessThan(300),
          reason: 'search over 5000 items took '
              '${stopwatch.elapsedMilliseconds}ms');
    });

    test('model fromJson/toJson round-trips', () {
      final item = _seedItems().first;
      final restored = CatalogItem.fromJson(item.toJson());
      expect(restored.sku, item.sku);
      expect(restored.id, item.sku);
      expect(restored.nameEn, item.nameEn);
      expect(restored.purchasePriceEst, item.purchasePriceEst);
      expect(restored.copyWith(stockQty: 9).stockQty, 9);
    });
  });
}
