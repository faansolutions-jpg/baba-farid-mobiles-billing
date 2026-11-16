// Accessories Master Catalog — drift database (separate SQLite file).
//
// The catalog lives in its OWN file, catalog.db, apart from the main app
// database. A catalog version update (new items / refreshed estimated
// prices) therefore can never touch the shop's sales, ledger or IMEI data.
//
// Usage:
//   final db = CatalogDatabase();            // file-based, production
//   final db = CatalogDatabase.memory();     // in-memory, tests
//   final db = CatalogDatabase.forTesting(executor); // injected executor
//
// After changing catalog_tables.dart, regenerate the part file with:
//   dart run build_runner build
import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import 'catalog_tables.dart';

part 'catalog_database.g.dart';

@DriftDatabase(tables: [
  CatalogVersions,
  CatalogCategories,
  CatalogItems,
  CatalogItemModels,
  BarcodeLinks,
  CatalogStock,
  StockCounts,
])
class CatalogDatabase extends _$CatalogDatabase {
  CatalogDatabase() : super(_openConnection());

  /// In-memory database (unit / widget tests).
  CatalogDatabase.memory() : super(NativeDatabase.memory());

  /// Database over an injected executor (tests / custom storage).
  CatalogDatabase.forTesting(super.executor);

  @override
  int get schemaVersion => 1;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onCreate: (m) async {
          await m.createAll();
        },
        onUpgrade: (m, from, to) async {
          // v1 is the first catalog schema; later versions add migrations
          // here. Catalog data itself is versioned through
          // CatalogRepository.applyCatalogUpdate, not schema upgrades.
        },
      );
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dir = await getApplicationDocumentsDirectory();
    final file = File(p.join(dir.path, 'catalog.db'));
    return NativeDatabase(file);
  });
}
