// Accessories Master Catalog — drift table definitions.
//
// These tables mirror database/migrations/001_accessories_catalog.sql
// (same table/column names) so the local catalog.db maps 1:1 to the
// server schema. They live in their own SQLite file (catalog.db, see
// catalog_database.dart), separate from the main app database, so a
// catalog update can never risk the shop's transactional data.
//
// Colors / variants are stored as JSON-encoded TEXT (drift has no JSONB);
// use jsonEncode/jsonDecode when reading/writing (see catalog_repository).
//
// NOTE: run `dart run build_runner build` to regenerate
// catalog_database.g.dart after changing these tables.
import 'package:drift/drift.dart';

@DataClassName('CatalogVersionRow')
class CatalogVersions extends Table {
  TextColumn get version => text()();

  DateTimeColumn get appliedAt => dateTime().withDefault(currentDateAndTime)();

  IntColumn get itemCount => integer().withDefault(const Constant(0))();

  TextColumn get notes => text().nullable()();

  @override
  Set<Column> get primaryKey => {version};
}

@DataClassName('CatalogCategoryRow')
class CatalogCategories extends Table {
  IntColumn get id => integer().autoIncrement()();

  TextColumn get nameEn => text().unique()();

  TextColumn get nameUr => text().withDefault(const Constant(''))();

  IntColumn get sortOrder => integer().withDefault(const Constant(0))();
}

@DataClassName('CatalogItemRow')
class CatalogItems extends Table {
  TextColumn get sku => text()();

  TextColumn get category => text()();

  TextColumn get brand => text()();

  TextColumn get nameEn => text()();

  TextColumn get nameUr => text().withDefault(const Constant(''))();

  TextColumn get modelCompatibility => text().nullable()();

  /// JSON-encoded list of colour names.
  TextColumn get colors => text().withDefault(const Constant('[]'))();

  /// JSON-encoded list of variant labels.
  TextColumn get variants => text().withDefault(const Constant('[]'))();

  /// ESTIMATED purchase price (whole PKR). Never a live market rate.
  IntColumn get purchasePriceEst => integer().withDefault(const Constant(0))();

  /// ESTIMATED sale price (whole PKR).
  IntColumn get salePriceEst => integer().withDefault(const Constant(0))();

  IntColumn get minPrice => integer().withDefault(const Constant(0))();

  TextColumn get unit => text().withDefault(const Constant('piece'))();

  TextColumn get barcode => text().nullable().unique()();

  BoolColumn get isCustom => boolean().withDefault(const Constant(false))();

  BoolColumn get estimated => boolean().withDefault(const Constant(true))();

  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();

  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {sku};
}

@DataClassName('CatalogItemModelRow')
class CatalogItemModels extends Table {
  TextColumn get sku => text().references(CatalogItems, #sku)();

  TextColumn get deviceBrand => text()();

  TextColumn get deviceModel => text()();

  @override
  Set<Column> get primaryKey => {sku, deviceBrand, deviceModel};
}

@DataClassName('BarcodeLinkRow')
class BarcodeLinks extends Table {
  TextColumn get barcode => text()();

  TextColumn get sku => text().references(CatalogItems, #sku)();

  DateTimeColumn get linkedAt => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {barcode};
}

@DataClassName('CatalogStockRow')
class CatalogStock extends Table {
  TextColumn get sku => text().references(CatalogItems, #sku)();

  IntColumn get quantity => integer().withDefault(const Constant(0))();

  IntColumn get lastPurchasePrice => integer().nullable()();

  TextColumn get lastSupplier => text().nullable()();

  DateTimeColumn get lastStockDate => dateTime().nullable()();

  IntColumn get lowStockThreshold => integer().withDefault(const Constant(5))();

  @override
  Set<Column> get primaryKey => {sku};
}

@DataClassName('StockCountRow')
class StockCounts extends Table {
  IntColumn get id => integer().autoIncrement()();

  TextColumn get sku => text().references(CatalogItems, #sku)();

  IntColumn get countedQty => integer()();

  IntColumn get systemQty => integer()();

  IntColumn get difference => integer()();

  TextColumn get note => text().nullable()();

  TextColumn get countedBy => text().nullable()();

  DateTimeColumn get countedAt => dateTime().withDefault(currentDateAndTime)();
}
