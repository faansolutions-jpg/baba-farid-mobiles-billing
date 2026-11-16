// Worker R gap-fix tests.
//
// Run with:  flutter test test/worker_r_test.dart
// (from mobile_app/). Repositories run against in-memory drift
// databases, so no real files are touched.
import 'package:baba_farid_mobiles/data/database/app_database.dart'
    hide Customer, Purchase, PurchaseItem, Repair, RepairPart, Supplier;
import 'package:baba_farid_mobiles/data/database/catalog_database.dart';
import 'package:baba_farid_mobiles/data/repositories/customer_repository.dart';
import 'package:baba_farid_mobiles/data/repositories/expense_repository.dart';
import 'package:baba_farid_mobiles/data/repositories/purchase_repository.dart';
import 'package:baba_farid_mobiles/data/repositories/repair_repository.dart';
import 'package:baba_farid_mobiles/data/repositories/supplier_repository.dart';
import 'package:baba_farid_mobiles/domain/models/customer.dart';
import 'package:baba_farid_mobiles/domain/models/purchase.dart';
import 'package:baba_farid_mobiles/domain/models/repair.dart';
import 'package:baba_farid_mobiles/domain/models/supplier.dart';
import 'package:baba_farid_mobiles/features/catalog/catalog_models.dart';
import 'package:baba_farid_mobiles/features/catalog/catalog_repository.dart';
import 'package:drift/drift.dart' hide isNotNull, isNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

AppDatabase _inMemoryAppDb() =>
    AppDatabase.forTesting(NativeDatabase.memory());

Future<String> _seedVariant(AppDatabase db, {int qty = 3}) async {
  final productId = newUuid();
  await db.into(db.products).insert(ProductsCompanion.insert(
        id: productId,
        type: 'accessory',
        name: 'Test Cover',
      ));
  final variantId = newUuid();
  await db.into(db.productVariants).insert(ProductVariantsCompanion.insert(
        id: variantId,
        productId: productId,
        name: 'Black',
        quantity: Value(qty),
      ));
  return variantId;
}

Future<int> _variantQty(AppDatabase db, String variantId) async {
  final row = await (db.select(db.productVariants)
        ..where((t) => t.id.equals(variantId)))
      .getSingle();
  return row.quantity;
}

Repair _repair({
  String? customerId,
  int finalCost = 10000,
  int advancePaid = 4000,
  String status = 'ready',
}) {
  final now = DateTime.now();
  return Repair(
    id: newUuid(),
    jobNo: 'REP-TEST',
    customerId: customerId,
    customerName: 'Test Customer',
    customerPhone: '03001234567',
    faultDescription: 'Screen broken',
    estimatedCost: finalCost,
    finalCost: finalCost,
    advancePaid: advancePaid,
    status: status,
    receivedDate: now,
    userId: 'tester',
    createdAt: now,
    updatedAt: now,
  );
}

void main() {
  group('removePart restores stock', () {
    test('variant quantity returns to pre-addPart level', () async {
      final db = _inMemoryAppDb();
      addTearDown(db.close);
      final repo = DriftRepairRepository(db);
      final variantId = await _seedVariant(db, qty: 3);
      final repair = await repo.createRepair(_repair());
      final part = await repo.addPart(
        RepairPart(
          id: '',
          repairId: repair.id,
          variantId: variantId,
          name: 'Test Cover',
          quantity: 2,
          unitPrice: 500,
          total: 1000,
          createdAt: DateTime.now(),
        ),
      );
      expect(await _variantQty(db, variantId), 1);
      await repo.removePart(part.id);
      expect(await _variantQty(db, variantId), 3);
      expect(await repo.listParts(repair.id), isEmpty);
    });

    test('manual part without variant removes cleanly', () async {
      final db = _inMemoryAppDb();
      addTearDown(db.close);
      final repo = DriftRepairRepository(db);
      final repair = await repo.createRepair(_repair());
      final part = await repo.addPart(
        RepairPart(
          id: '',
          repairId: repair.id,
          name: 'Labour part',
          quantity: 1,
          unitPrice: 200,
          total: 200,
          createdAt: DateTime.now(),
        ),
      );
      await repo.removePart(part.id);
      expect(await repo.listParts(repair.id), isEmpty);
    });
  });

  group('deliverWithUdhaar', () {
    test('delivers and posts the balance as a customer ledger debit',
        () async {
      final db = _inMemoryAppDb();
      addTearDown(db.close);
      final customers = DriftCustomerRepository(db);
      final repairs = DriftRepairRepository(db);
      final customer = await customers.createCustomer(Customer(
        id: '',
        name: 'Udhaar Customer',
        phone: '03009998888',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ));
      final repair =
          await repairs.createRepair(_repair(customerId: customer.id));
      final delivered = await repairs.deliverWithUdhaar(repair.id);
      expect(delivered.status, 'delivered');
      expect(delivered.deliveredDate, isNotNull);
      final entries = await customers.ledger(customer.id);
      expect(entries, hasLength(1));
      expect(entries.first.debit, 6000);
      expect(entries.first.credit, 0);
      expect(entries.first.balanceAfter, 6000);
      expect(entries.first.referenceType, 'repair');
      expect(entries.first.referenceId, repair.id);
      expect(await customers.runningBalance(customer.id), 6000);
    });

    test('delivers with no ledger entry when balance is zero', () async {
      final db = _inMemoryAppDb();
      addTearDown(db.close);
      final customers = DriftCustomerRepository(db);
      final repairs = DriftRepairRepository(db);
      final customer = await customers.createCustomer(Customer(
        id: '',
        name: 'Paid Customer',
        phone: '03001112222',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ));
      final repair = await repairs.createRepair(_repair(
        customerId: customer.id,
        finalCost: 5000,
        advancePaid: 5000,
      ));
      final delivered = await repairs.deliverWithUdhaar(repair.id);
      expect(delivered.status, 'delivered');
      expect(await customers.ledger(customer.id), isEmpty);
    });

    test('delivers with no ledger entry when there is no customer',
        () async {
      final db = _inMemoryAppDb();
      addTearDown(db.close);
      final repairs = DriftRepairRepository(db);
      final repair = await repairs.createRepair(_repair());
      final delivered = await repairs.deliverWithUdhaar(repair.id);
      expect(delivered.status, 'delivered');
    });

    test('rejects delivery from a non-ready status', () async {
      final db = _inMemoryAppDb();
      addTearDown(db.close);
      final repairs = DriftRepairRepository(db);
      final repair =
          await repairs.createRepair(_repair(status: 'received'));
      expect(
        () => repairs.deliverWithUdhaar(repair.id),
        throwsA(isA<Exception>()),
      );
    });
  });

  group('SupplierRepository', () {
    test('lists all suppliers including zero-payable ones', () async {
      final db = _inMemoryAppDb();
      addTearDown(db.close);
      final repo = DriftSupplierRepository(db);
      final withPayable = await repo.createSupplier(Supplier(
        id: '',
        name: 'Owing Supplier',
        openingPayable: 7000,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ));
      final settled = await repo.createSupplier(Supplier(
        id: '',
        name: 'Settled Supplier',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ));
      expect(withPayable.payable, 7000);
      expect(settled.payable, 0);
      final all = await repo.listSuppliers();
      expect(all.map((s) => s.name),
          containsAll(['Owing Supplier', 'Settled Supplier']));
      expect(
        all.firstWhere((s) => s.id == withPayable.id).payable,
        7000,
      );
      expect(
        all.firstWhere((s) => s.id == settled.id).payable,
        0,
      );
      final fetched = await repo.getSupplier(settled.id);
      expect(fetched?.name, 'Settled Supplier');
    });
  });

  group('CatalogRepository.stockOut', () {
    CatalogItem item(String sku) => CatalogItem(
          sku: sku,
          category: 'Cables',
          brand: 'Anker',
          nameEn: 'Anker Type-C Cable 1m',
          nameUr: 'چارجر',
          purchasePriceEst: 300,
          salePriceEst: 400,
          minPrice: 320,
          stockQty: 5,
        );

    test('decrements stock and never goes below zero', () async {
      final db = CatalogDatabase.memory();
      addTearDown(db.close);
      final repo = CatalogRepositoryImpl(db);
      await repo.addCustomItem(item('ACC-CAB-ANK-TC10-001'));
      await repo.stockOut('ACC-CAB-ANK-TC10-001', 2);
      final after = await repo.byBarcode('ACC-CAB-ANK-TC10-001');
      // byBarcode needs a barcode link; use search instead.
      expect(after, isNull);
      final found = await repo.search('Type-C Cable');
      expect(found.single.stockQty, 3);
      expect(
        () => repo.stockOut('ACC-CAB-ANK-TC10-001', 4),
        throwsA(isA<StateError>()),
      );
      expect((await repo.search('Type-C Cable')).single.stockQty, 3);
      expect(
        () => repo.stockOut('ACC-DOES-NOT-EXIST', 1),
        throwsA(isA<StateError>()),
      );
    });
  });

  group('DaySummary cash/other split', () {
    Future<void> seedSale(
      AppDatabase db, {
      required String invoiceNo,
      required int total,
      required String method,
    }) async {
      await db.into(db.sales).insert(SalesCompanion.insert(
            id: newUuid(),
            invoiceNo: invoiceNo,
            userId: 'tester',
            grandTotal: Value(total),
            paidAmount: Value(total),
            paymentMethod: Value(method),
          ));
    }

    test('cash vs other-method sales add up to totalSales', () async {
      final db = _inMemoryAppDb();
      addTearDown(db.close);
      final repo = DriftExpenseRepository(db);
      await seedSale(db, invoiceNo: 'INV-1', total: 5000, method: 'cash');
      await seedSale(db,
          invoiceNo: 'INV-2', total: 3000, method: 'jazzcash');
      await seedSale(db, invoiceNo: 'INV-3', total: 2000, method: 'bank');
      final summary = await repo.daySummary();
      expect(summary.totalSales, 10000);
      expect(summary.cashSales, 5000);
      expect(summary.otherMethodSales, 5000);
      expect(summary.salesCount, 3);
    });
  });

  group('catalogSku survives purchase + return', () {
    test('createPurchase stores the SKU and returnPurchase keeps it',
        () async {
      final db = _inMemoryAppDb();
      addTearDown(db.close);
      final purchases = DriftPurchaseRepository(db);
      final suppliers = DriftSupplierRepository(db);
      final supplier = await suppliers.createSupplier(Supplier(
        id: '',
        name: 'Catalog Supplier',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ));
      final now = DateTime.now();
      final purchase = await purchases.createPurchase(
        Purchase(
          id: '',
          supplierId: supplier.id,
          userId: 'tester',
          purchaseDate: now,
          grandTotal: 800,
          items: [
            PurchaseItem(
              id: '',
              purchaseId: '',
              catalogSku: 'ACC-CAB-ANK-TC10-001',
              quantity: 4,
              unitCost: 200,
              total: 800,
              createdAt: now,
            ),
          ],
          createdAt: now,
          updatedAt: now,
        ),
      );
      expect(purchase.items.single.catalogSku, 'ACC-CAB-ANK-TC10-001');
      final ret = await purchases.returnPurchase(
        purchaseId: purchase.id,
        purchaseItemId: purchase.items.single.id,
        quantity: 2,
        userId: 'tester',
      );
      expect(ret.catalogSku, 'ACC-CAB-ANK-TC10-001');
      expect(ret.quantity, 2);
    });
  });
}
