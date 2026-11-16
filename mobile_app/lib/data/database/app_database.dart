/// Local SQLite database (drift) for Baba Farid Mobiles.
///
/// Tables mirror `database/schema.sql` exactly (same table and column
/// names) so sync is a straight mapping. Two deliberate local-only
/// extensions, both documented where they occur:
/// * `audit_logs` gains `prev_hash` / `hash` (hash-chained audit,
///   DECISIONS.md rule 10) — the Postgres schema has no such columns.
/// * `customers` gains `loyalty_points` / `wallet_balance`
///   (DECISIONS.md rule 23) — derived values kept on-device.
/// * Plus the `outbox` table (offline sync queue, not in schema.sql).
///
/// Run code generation after editing this file:
/// `flutter pub run build_runner build --delete-conflicting-outputs`
/// which produces `app_database.g.dart` (referenced by the `part`
/// directive below). Database file: `baba_farid_mobiles.db`.
library;

import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import '../../domain/models/audit_log.dart' show auditHash;

part 'app_database.g.dart';

/// Generates a random UUID v4 (used as the local primary key for every
/// row, matching the schema's `gen_random_uuid()` so offline-created
/// records never collide on sync).
String newUuid() {
  final random = Random.secure();
  final bytes = List<int>.generate(16, (_) => random.nextInt(256));
  bytes[6] = (bytes[6] & 0x0F) | 0x40; // version 4
  bytes[8] = (bytes[8] & 0x3F) | 0x80; // variant 10
  final hex =
      bytes.map((b) => b.toRadixString(16).padLeft(2, '0')).join();
  return '${hex.substring(0, 8)}-${hex.substring(8, 12)}-'
      '${hex.substring(12, 16)}-${hex.substring(16, 20)}-'
      '${hex.substring(20)}';
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dir = await getApplicationDocumentsDirectory();
    final file = File(p.join(dir.path, 'baba_farid_mobiles.db'));
    return NativeDatabase(file);
  });
}

// ---------------------------------------------------------------------------
// 1. Organisation, users & roles
// ---------------------------------------------------------------------------

class Branches extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();
  TextColumn get address => text().nullable()();
  TextColumn get phone => text().nullable()();
  BoolColumn get isActive => boolean().withDefault(const Constant(true))();
  DateTimeColumn get createdAt =>
      dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt =>
      dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {id};
}

class Roles extends Table {
  TextColumn get id => text()();
  TextColumn get name => text().unique()();
  TextColumn get description => text().nullable()();
  // JSON object, e.g. {"sales.create": true, "cost.view": false}.
  TextColumn get permissions => text().withDefault(const Constant('{}'))();
  DateTimeColumn get createdAt =>
      dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {id};
}

class Users extends Table {
  TextColumn get id => text()();
  TextColumn get branchId => text().nullable()();
  TextColumn get roleId => text()();
  TextColumn get name => text()();
  TextColumn get phone => text().unique()();
  TextColumn get email => text().nullable().unique()();
  TextColumn get passwordHash => text()();
  BoolColumn get isActive => boolean().withDefault(const Constant(true))();
  DateTimeColumn get lastLoginAt => dateTime().nullable()();
  DateTimeColumn get createdAt =>
      dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt =>
      dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {id};
}

// ---------------------------------------------------------------------------
// 2. Catalog
// ---------------------------------------------------------------------------

class Categories extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();
  TextColumn get type => text()(); // phone | accessory | service
  TextColumn get parentId => text().nullable()();
  BoolColumn get isActive => boolean().withDefault(const Constant(true))();
  DateTimeColumn get createdAt =>
      dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {id};
}

class Brands extends Table {
  TextColumn get id => text()();
  TextColumn get name => text().unique()();
  BoolColumn get isActive => boolean().withDefault(const Constant(true))();
  DateTimeColumn get createdAt =>
      dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {id};
}

class Products extends Table {
  TextColumn get id => text()();
  TextColumn get brandId => text().nullable()();
  TextColumn get categoryId => text().nullable()();
  TextColumn get type => text()(); // phone | accessory
  TextColumn get name => text()();
  TextColumn get description => text().nullable()();
  TextColumn get barcode => text().nullable().unique()();
  TextColumn get imageUrl => text().nullable()();
  BoolColumn get isActive => boolean().withDefault(const Constant(true))();
  DateTimeColumn get createdAt =>
      dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt =>
      dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {id};
}

class ProductVariants extends Table {
  TextColumn get id => text()();
  TextColumn get productId => text()();
  TextColumn get name => text()();
  TextColumn get color => text().nullable()();
  IntColumn get storageGb => integer().nullable()();
  IntColumn get ramGb => integer().nullable()();
  TextColumn get condition =>
      text().withDefault(const Constant('new'))(); // new|used|open_box
  TextColumn get ptaStatus => text().withDefault(
      const Constant('not_applicable'))(); // approved|non_pta|not_applicable
  TextColumn get barcode => text().nullable().unique()();
  IntColumn get purchasePrice => integer().withDefault(const Constant(0))();
  IntColumn get salePrice => integer().withDefault(const Constant(0))();
  IntColumn get minPrice => integer().withDefault(const Constant(0))();
  IntColumn get warrantyMonths => integer().withDefault(const Constant(0))();
  // Quantity stock for accessories; phones use imei_items.
  IntColumn get quantity => integer().withDefault(const Constant(0))();
  IntColumn get lowStockThreshold =>
      integer().withDefault(const Constant(3))();
  BoolColumn get isActive => boolean().withDefault(const Constant(true))();
  DateTimeColumn get createdAt =>
      dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt =>
      dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {id};
}

// ---------------------------------------------------------------------------
// 3. IMEI-level stock
// ---------------------------------------------------------------------------

class ImeiItems extends Table {
  TextColumn get id => text()();
  TextColumn get productId => text()();
  TextColumn get variantId => text().nullable()();
  TextColumn get imei1 => text().unique()();
  TextColumn get imei2 => text().nullable().unique()();
  TextColumn get status =>
      text().withDefault(const Constant('available'))();
  TextColumn get purchaseId => text().nullable()();
  IntColumn get purchasePrice => integer().withDefault(const Constant(0))();
  IntColumn get salePrice => integer().withDefault(const Constant(0))();
  TextColumn get soldSaleId => text().nullable()();
  DateTimeColumn get warrantyStart => dateTime().nullable()();
  DateTimeColumn get warrantyEnd => dateTime().nullable()();
  DateTimeColumn get createdAt =>
      dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt =>
      dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {id};
}

// ---------------------------------------------------------------------------
// 4. Customers & suppliers
// ---------------------------------------------------------------------------

class Customers extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();
  TextColumn get phone => text()();
  TextColumn get cnic => text().nullable()();
  TextColumn get address => text().nullable()();
  IntColumn get openingBalance => integer().withDefault(const Constant(0))();
  // Local-only extensions (see file header): not in schema.sql.
  IntColumn get loyaltyPoints => integer().withDefault(const Constant(0))();
  IntColumn get walletBalance => integer().withDefault(const Constant(0))();
  BoolColumn get isActive => boolean().withDefault(const Constant(true))();
  DateTimeColumn get createdAt =>
      dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt =>
      dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {id};
}

class Suppliers extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();
  TextColumn get phone => text().nullable()();
  TextColumn get address => text().nullable()();
  IntColumn get openingPayable => integer().withDefault(const Constant(0))();
  BoolColumn get isActive => boolean().withDefault(const Constant(true))();
  DateTimeColumn get createdAt =>
      dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt =>
      dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {id};
}

// ---------------------------------------------------------------------------
// 5. Sales
// ---------------------------------------------------------------------------

class Sales extends Table {
  TextColumn get id => text()();
  TextColumn get invoiceNo => text().unique()();
  TextColumn get branchId => text().nullable()();
  TextColumn get customerId => text().nullable()();
  TextColumn get customerName => text().nullable()();
  TextColumn get customerPhone => text().nullable()();
  TextColumn get userId => text()();
  DateTimeColumn get saleDate =>
      dateTime().withDefault(currentDateAndTime)();
  IntColumn get subtotal => integer().withDefault(const Constant(0))();
  IntColumn get discountAmount => integer().withDefault(const Constant(0))();
  RealColumn get discountPercent => real().withDefault(const Constant(0))();
  IntColumn get taxAmount => integer().withDefault(const Constant(0))();
  IntColumn get grandTotal => integer().withDefault(const Constant(0))();
  IntColumn get paidAmount => integer().withDefault(const Constant(0))();
  IntColumn get balanceDue => integer().withDefault(const Constant(0))();
  TextColumn get paymentMethod =>
      text().withDefault(const Constant('cash'))();
  TextColumn get paymentStatus =>
      text().withDefault(const Constant('paid'))();
  TextColumn get status => text().withDefault(const Constant('completed'))();
  TextColumn get notes => text().nullable()();
  TextColumn get clientUuid => text().nullable().unique()();
  DateTimeColumn get createdAt =>
      dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt =>
      dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {id};
}

class SaleItems extends Table {
  TextColumn get id => text()();
  TextColumn get saleId => text()();
  TextColumn get productId => text().nullable()();
  TextColumn get variantId => text().nullable()();
  TextColumn get imeiItemId => text().nullable()();
  TextColumn get nameSnapshot => text()();
  IntColumn get quantity => integer().withDefault(const Constant(1))();
  IntColumn get unitPrice => integer()();
  IntColumn get purchaseCost => integer().withDefault(const Constant(0))();
  IntColumn get discount => integer().withDefault(const Constant(0))();
  IntColumn get total => integer()();
  IntColumn get profit => integer().withDefault(const Constant(0))();
  DateTimeColumn get createdAt =>
      dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {id};
}

class SaleReturns extends Table {
  TextColumn get id => text()();
  TextColumn get saleId => text()();
  TextColumn get saleItemId => text().nullable()();
  TextColumn get imeiItemId => text().nullable()();
  IntColumn get quantity => integer().withDefault(const Constant(1))();
  TextColumn get reason => text().nullable()();
  IntColumn get refundAmount => integer().withDefault(const Constant(0))();
  BoolColumn get isExchange => boolean().withDefault(const Constant(false))();
  TextColumn get exchangeSaleId => text().nullable()();
  TextColumn get userId => text()();
  DateTimeColumn get createdAt =>
      dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {id};
}

class HeldBills extends Table {
  TextColumn get id => text()();
  TextColumn get branchId => text().nullable()();
  TextColumn get userId => text()();
  TextColumn get customerName => text().nullable()();
  TextColumn get cart => text().withDefault(const Constant('[]'))();
  DateTimeColumn get createdAt =>
      dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {id};
}

// ---------------------------------------------------------------------------
// 6. Purchases
// ---------------------------------------------------------------------------

class Purchases extends Table {
  TextColumn get id => text()();
  TextColumn get supplierId => text()();
  TextColumn get branchId => text().nullable()();
  TextColumn get userId => text()();
  TextColumn get supplierInvoiceNo => text().nullable()();
  DateTimeColumn get purchaseDate =>
      dateTime().withDefault(currentDateAndTime)();
  IntColumn get subtotal => integer().withDefault(const Constant(0))();
  IntColumn get discount => integer().withDefault(const Constant(0))();
  IntColumn get grandTotal => integer().withDefault(const Constant(0))();
  IntColumn get paidAmount => integer().withDefault(const Constant(0))();
  IntColumn get balanceDue => integer().withDefault(const Constant(0))();
  TextColumn get status => text().withDefault(const Constant('received'))();
  TextColumn get notes => text().nullable()();
  TextColumn get clientUuid => text().nullable().unique()();
  DateTimeColumn get createdAt =>
      dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt =>
      dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {id};
}

class PurchaseItems extends Table {
  TextColumn get id => text()();
  TextColumn get purchaseId => text()();
  TextColumn get productId => text().nullable()();
  TextColumn get variantId => text().nullable()();
  TextColumn get imei1 => text().nullable()();
  TextColumn get imei2 => text().nullable()();
  // Catalog accessory SKU (no product/variant row in the main DB).
  // Added in schema v2 so a purchase return can stockOut the right
  // catalog item; null for phones and main-DB accessories.
  TextColumn get catalogSku => text().nullable()();
  IntColumn get quantity => integer().withDefault(const Constant(1))();
  IntColumn get unitCost => integer()();
  IntColumn get total => integer()();
  DateTimeColumn get createdAt =>
      dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {id};
}

class PurchaseReturns extends Table {
  TextColumn get id => text()();
  TextColumn get purchaseId => text()();
  TextColumn get imeiItemId => text().nullable()();
  TextColumn get productId => text().nullable()();
  TextColumn get variantId => text().nullable()();
  // Catalog accessory SKU returned (mirrors purchase_items.catalog_sku).
  // Added in schema v2; used to track already-returned catalog qty.
  TextColumn get catalogSku => text().nullable()();
  IntColumn get quantity => integer().withDefault(const Constant(1))();
  TextColumn get reason => text().nullable()();
  IntColumn get refundAmount => integer().withDefault(const Constant(0))();
  TextColumn get userId => text()();
  DateTimeColumn get createdAt =>
      dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {id};
}

// ---------------------------------------------------------------------------
// 7. Payments, ledger & installments
// ---------------------------------------------------------------------------

class Payments extends Table {
  TextColumn get id => text()();
  TextColumn get paymentType => text()();
  TextColumn get saleId => text().nullable()();
  TextColumn get purchaseId => text().nullable()();
  TextColumn get installmentId => text().nullable()();
  TextColumn get repairId => text().nullable()();
  TextColumn get customerId => text().nullable()();
  TextColumn get supplierId => text().nullable()();
  TextColumn get method => text().withDefault(const Constant('cash'))();
  IntColumn get amount => integer()();
  TextColumn get reference => text().nullable()();
  DateTimeColumn get paymentDate =>
      dateTime().withDefault(currentDateAndTime)();
  TextColumn get userId => text()();
  TextColumn get notes => text().nullable()();
  TextColumn get clientUuid => text().nullable().unique()();
  DateTimeColumn get createdAt =>
      dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {id};
}

class LedgerEntries extends Table {
  TextColumn get id => text()();
  TextColumn get side => text()(); // customer | supplier
  TextColumn get customerId => text().nullable()();
  TextColumn get supplierId => text().nullable()();
  TextColumn get referenceType => text()();
  TextColumn get referenceId => text().nullable()();
  IntColumn get debit => integer().withDefault(const Constant(0))();
  IntColumn get credit => integer().withDefault(const Constant(0))();
  IntColumn get balanceAfter => integer().withDefault(const Constant(0))();
  DateTimeColumn get entryDate =>
      dateTime().withDefault(currentDateAndTime)();
  TextColumn get userId => text().nullable()();
  TextColumn get notes => text().nullable()();
  DateTimeColumn get createdAt =>
      dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {id};
}

class Installments extends Table {
  TextColumn get id => text()();
  TextColumn get saleId => text()();
  TextColumn get customerId => text()();
  IntColumn get totalAmount => integer()();
  IntColumn get downPayment => integer().withDefault(const Constant(0))();
  IntColumn get installmentCount => integer()();
  IntColumn get installmentAmount => integer()();
  DateTimeColumn get startDate => dateTime()();
  TextColumn get status => text().withDefault(const Constant('active'))();
  DateTimeColumn get createdAt =>
      dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt =>
      dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {id};
}

class InstallmentPayments extends Table {
  TextColumn get id => text()();
  TextColumn get installmentId => text()();
  DateTimeColumn get dueDate => dateTime()();
  IntColumn get amount => integer()();
  IntColumn get paidAmount => integer().withDefault(const Constant(0))();
  DateTimeColumn get paidDate => dateTime().nullable()();
  TextColumn get status => text().withDefault(const Constant('pending'))();
  BoolColumn get reminderSent =>
      boolean().withDefault(const Constant(false))();
  DateTimeColumn get createdAt =>
      dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt =>
      dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {id};
}

// ---------------------------------------------------------------------------
// 8. Repairs & services
// ---------------------------------------------------------------------------

class Repairs extends Table {
  TextColumn get id => text()();
  TextColumn get jobNo => text().unique()();
  TextColumn get customerId => text().nullable()();
  TextColumn get customerName => text()();
  TextColumn get customerPhone => text()();
  TextColumn get deviceBrand => text().nullable()();
  TextColumn get deviceModel => text().nullable()();
  TextColumn get imei => text().nullable()();
  TextColumn get faultDescription => text()();
  IntColumn get estimatedCost => integer().withDefault(const Constant(0))();
  IntColumn get finalCost => integer().withDefault(const Constant(0))();
  IntColumn get advancePaid => integer().withDefault(const Constant(0))();
  TextColumn get status => text().withDefault(const Constant('received'))();
  DateTimeColumn get receivedDate =>
      dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get readyDate => dateTime().nullable()();
  DateTimeColumn get deliveredDate => dateTime().nullable()();
  TextColumn get userId => text()();
  TextColumn get notes => text().nullable()();
  DateTimeColumn get createdAt =>
      dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt =>
      dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {id};
}

class RepairParts extends Table {
  TextColumn get id => text()();
  TextColumn get repairId => text()();
  TextColumn get productId => text().nullable()();
  TextColumn get variantId => text().nullable()();
  TextColumn get name => text()();
  IntColumn get quantity => integer().withDefault(const Constant(1))();
  IntColumn get unitPrice => integer()();
  IntColumn get total => integer()();
  DateTimeColumn get createdAt =>
      dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {id};
}

class ServiceSales extends Table {
  TextColumn get id => text()();
  TextColumn get serviceType => text()();
  TextColumn get customerPhone => text().nullable()();
  TextColumn get provider => text().nullable()();
  IntColumn get amount => integer()();
  IntColumn get commission => integer().withDefault(const Constant(0))();
  TextColumn get userId => text()();
  DateTimeColumn get saleDate =>
      dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get createdAt =>
      dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {id};
}

// ---------------------------------------------------------------------------
// 9. Expenses, staff & cash
// ---------------------------------------------------------------------------

class Expenses extends Table {
  TextColumn get id => text()();
  TextColumn get branchId => text().nullable()();
  TextColumn get category => text()();
  IntColumn get amount => integer()();
  DateTimeColumn get expenseDate =>
      dateTime().withDefault(currentDateAndTime)();
  TextColumn get description => text().nullable()();
  TextColumn get userId => text()();
  DateTimeColumn get createdAt =>
      dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {id};
}

class Staff extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();
  TextColumn get phone => text().nullable()();
  TextColumn get role => text().nullable()();
  IntColumn get salary => integer().withDefault(const Constant(0))();
  BoolColumn get isActive => boolean().withDefault(const Constant(true))();
  DateTimeColumn get createdAt =>
      dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {id};
}

class SalaryPayments extends Table {
  TextColumn get id => text()();
  TextColumn get staffId => text()();
  TextColumn get month => text()(); // YYYY-MM
  IntColumn get amount => integer()();
  IntColumn get advance => integer().withDefault(const Constant(0))();
  DateTimeColumn get paidDate =>
      dateTime().withDefault(currentDateAndTime)();
  TextColumn get userId => text()();
  TextColumn get notes => text().nullable()();
  DateTimeColumn get createdAt =>
      dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {id};
}

class CashRegisters extends Table {
  TextColumn get id => text()();
  TextColumn get branchId => text().nullable()();
  DateTimeColumn get registerDate => dateTime()();
  IntColumn get openingCash => integer().withDefault(const Constant(0))();
  IntColumn get closingCash => integer().nullable()();
  IntColumn get expectedCash => integer().nullable()();
  IntColumn get difference => integer().nullable()();
  TextColumn get status => text().withDefault(const Constant('open'))();
  TextColumn get openedBy => text().nullable()();
  TextColumn get closedBy => text().nullable()();
  TextColumn get notes => text().nullable()();
  DateTimeColumn get createdAt =>
      dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt =>
      dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {id};
}

class CashMovements extends Table {
  TextColumn get id => text()();
  TextColumn get registerId => text()();
  TextColumn get type => text()(); // in | out
  IntColumn get amount => integer()();
  TextColumn get reason => text().nullable()();
  TextColumn get userId => text()();
  DateTimeColumn get createdAt =>
      dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {id};
}

// ---------------------------------------------------------------------------
// 10. Audit, settings, sync, counters
// ---------------------------------------------------------------------------

class AuditLogs extends Table {
  TextColumn get id => text()();
  TextColumn get userId => text().nullable()();
  TextColumn get action => text()();
  TextColumn get entityType => text()();
  TextColumn get entityId => text().nullable()();
  TextColumn get oldValues => text().nullable()(); // JSON
  TextColumn get newValues => text().nullable()(); // JSON
  TextColumn get ipAddress => text().nullable()();
  TextColumn get deviceInfo => text().nullable()();
  // Local-only hash-chain columns (see file header).
  TextColumn get prevHash => text().withDefault(const Constant(''))();
  TextColumn get hash => text().withDefault(const Constant(''))();
  DateTimeColumn get createdAt =>
      dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {id};
}

class AppSettings extends Table {
  @override
  String get tableName => 'settings';

  TextColumn get key => text()();
  TextColumn get value => text()(); // JSON-encoded value
  DateTimeColumn get updatedAt =>
      dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {key};
}

class Counters extends Table {
  TextColumn get branchId => text().nullable()();
  TextColumn get name => text()(); // sale_invoice | repair_job | purchase
  TextColumn get prefix => text()(); // INV | REP | PUR
  IntColumn get lastValue => integer().withDefault(const Constant(0))();

  @override
  Set<Column> get primaryKey => {branchId, name};
}

class SyncLogs extends Table {
  TextColumn get id => text()();
  TextColumn get deviceId => text()();
  TextColumn get userId => text().nullable()();
  TextColumn get entityType => text()();
  TextColumn get entityId => text().nullable()();
  TextColumn get action => text()(); // push | pull | conflict
  TextColumn get detail => text().nullable()(); // JSON
  DateTimeColumn get createdAt =>
      dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {id};
}

// ---------------------------------------------------------------------------
// 11. Outbox (offline sync queue — local only, not in schema.sql)
// ---------------------------------------------------------------------------

class Outbox extends Table {
  TextColumn get id => text()();
  TextColumn get clientUuid => text().unique()();
  // Named `entityTable` in Dart (not `tableName`) because drift's
  // Table already has a `tableName` getter; the SQLite column stays
  // `table_name` so the sync payload is unchanged.
  TextColumn get entityTable => text().named('table_name')();
  TextColumn get operation => text()(); // insert | update | delete
  TextColumn get payload => text()(); // JSON
  BoolColumn get synced => boolean().withDefault(const Constant(false))();
  DateTimeColumn get createdAt =>
      dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {id};
}

// ---------------------------------------------------------------------------
// Database
// ---------------------------------------------------------------------------

@DriftDatabase(tables: [
  Branches,
  Roles,
  Users,
  Categories,
  Brands,
  Products,
  ProductVariants,
  ImeiItems,
  Customers,
  Suppliers,
  Sales,
  SaleItems,
  SaleReturns,
  HeldBills,
  Purchases,
  PurchaseItems,
  PurchaseReturns,
  Payments,
  LedgerEntries,
  Installments,
  InstallmentPayments,
  Repairs,
  RepairParts,
  ServiceSales,
  Expenses,
  Staff,
  SalaryPayments,
  CashRegisters,
  CashMovements,
  AuditLogs,
  AppSettings,
  Counters,
  SyncLogs,
  Outbox,
])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  /// Test / in-memory constructor.
  AppDatabase.forTesting(super.executor);

  @override
  int get schemaVersion => 2;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onCreate: (Migrator m) async {
          await m.createAll();
        },
        onUpgrade: (Migrator m, int from, int to) async {
          // v2: catalog SKU on purchase items + purchase returns, so a
          // return can stockOut the right catalog item (Worker R).
          // Nullable columns: existing rows stay valid (null = not a
          // catalog item).
          if (from < 2) {
            await m.addColumn(purchaseItems, purchaseItems.catalogSku);
            await m.addColumn(purchaseReturns, purchaseReturns.catalogSku);
          }
        },
      );

  // -- Shared helpers used by every repository -----------------------------

  /// Appends a hash-chained audit row. Safe to call inside a transaction
  /// (it uses this same database connection). The hash is
  /// SHA-256(prevHash + action + entityType + entityId + newValues +
  /// createdAt); the first row chains from the empty string.
  Future<void> writeAudit({
    String? userId,
    required String action,
    required String entityType,
    String? entityId,
    Map<String, dynamic>? oldValues,
    Map<String, dynamic>? newValues,
    String? deviceInfo,
  }) async {
    final now = DateTime.now();
    final last = await (select(auditLogs)
          ..orderBy([(t) => OrderingTerm.desc(t.createdAt)])
          ..limit(1))
        .getSingleOrNull();
    final prevHash = last?.hash ?? '';
    final hash = auditHash(
      prevHash: prevHash,
      action: action,
      entityType: entityType,
      entityId: entityId,
      newValues: newValues,
      createdAt: now,
    );
    await into(auditLogs).insert(AuditLogsCompanion.insert(
      id: newUuid(),
      userId: Value(userId),
      action: action,
      entityType: entityType,
      entityId: Value(entityId),
      oldValues: Value(
          oldValues == null ? null : jsonEncode(oldValues)),
      newValues: Value(
          newValues == null ? null : jsonEncode(newValues)),
      deviceInfo: Value(deviceInfo),
      prevHash: Value(prevHash),
      hash: Value(hash),
      createdAt: Value(now),
    ));
  }

  /// Queues a local write for sync. [payload] must be JSON-encodable and
  /// must include the record's `id`. Safe to call inside a transaction.
  Future<void> enqueueOutbox({
    required String tableName,
    required String operation,
    required Map<String, dynamic> payload,
    String? clientUuid,
  }) async {
    await into(outbox).insert(OutboxCompanion.insert(
      id: newUuid(),
      clientUuid: clientUuid ?? newUuid(),
      entityTable: tableName,
      operation: operation,
      payload: jsonEncode(payload),
    ));
  }

  /// Next document number for [name] (`sale_invoice` / `repair_job` /
  /// `purchase`) in [branchId], e.g. `INV-000124`. Advances the counter
  /// row. Must be called inside the caller's transaction when the number
  /// belongs to a record created in that transaction.
  Future<String> nextDocumentNumber({
    String? branchId,
    required String name,
    required String prefix,
  }) async {
    final existing = await (select(counters)
          ..where((t) =>
              t.name.equals(name) &
              (branchId == null
                  ? t.branchId.isNull()
                  : t.branchId.equals(branchId))))
        .getSingleOrNull();
    final next = (existing?.lastValue ?? 0) + 1;
    if (existing == null) {
      await into(counters).insert(CountersCompanion.insert(
        branchId: Value(branchId),
        name: name,
        prefix: prefix,
        lastValue: Value(next),
      ));
    } else {
      await (update(counters)
            ..where((t) =>
                t.name.equals(name) &
                (branchId == null
                    ? t.branchId.isNull()
                    : t.branchId.equals(branchId))))
          .write(CountersCompanion(lastValue: Value(next)));
    }
    return '$prefix-${next.toString().padLeft(6, '0')}';
  }
}
