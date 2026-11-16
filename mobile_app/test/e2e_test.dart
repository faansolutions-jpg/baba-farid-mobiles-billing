// End-to-end scenario test (Round 3 verification).
//
// Mirrors the live API scenario in scripts/e2e-live.mjs, against
// in-memory drift databases: purchase (2 phones + accessories + catalog
// goods) -> sale of one phone with partial payment -> return of the
// phone -> purchase return of catalog goods (stockOut) -> repair
// delivery with udhaar -> customer ledger -> reports.
//
// It also pins the Round 3 fixes: deliverWithUdhaar posts the balance
// as a customer ledger debit, removePart restores variant stock,
// stockOut on purchase return, and the return fixes (grand_total +
// profit reversal, ledger credit split so a fully returned partial
// bill ends at 0, double-return guard).
//
// Run with:  flutter test test/e2e_test.dart
// (from mobile_app/). No real files are touched.
import 'package:baba_farid_mobiles/data/database/app_database.dart'
    hide
        Customer,
        Purchase,
        PurchaseItem,
        Repair,
        RepairPart,
        Sale,
        SaleItem,
        Supplier;
import 'package:baba_farid_mobiles/data/database/catalog_database.dart';
import 'package:baba_farid_mobiles/data/repositories/customer_repository.dart';
import 'package:baba_farid_mobiles/data/repositories/purchase_repository.dart';
import 'package:baba_farid_mobiles/data/repositories/repair_repository.dart';
import 'package:baba_farid_mobiles/data/repositories/report_repository.dart';
import 'package:baba_farid_mobiles/data/repositories/sale_repository.dart';
import 'package:baba_farid_mobiles/data/repositories/supplier_repository.dart';
import 'package:baba_farid_mobiles/domain/models/customer.dart';
import 'package:baba_farid_mobiles/domain/models/purchase.dart';
import 'package:baba_farid_mobiles/domain/models/repair.dart';
import 'package:baba_farid_mobiles/domain/models/sale.dart';
import 'package:baba_farid_mobiles/domain/models/supplier.dart';
import 'package:baba_farid_mobiles/features/catalog/catalog_models.dart';
import 'package:baba_farid_mobiles/features/catalog/catalog_repository.dart';
import 'package:baba_farid_mobiles/features/purchases/purchase_helpers.dart';
import 'package:drift/drift.dart' hide isNotNull, isNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

AppDatabase _inMemoryAppDb() =>
    AppDatabase.forTesting(NativeDatabase.memory());

Future<(String, String)> _seedPhone(AppDatabase db) async {
  final productId = newUuid();
  await db.into(db.products).insert(ProductsCompanion.insert(
        id: productId,
        type: 'phone',
        name: 'Samsung Galaxy A16',
      ));
  final variantId = newUuid();
  await db.into(db.productVariants).insert(ProductVariantsCompanion.insert(
        id: variantId,
        productId: productId,
        name: '8GB / 128GB · Black',
        quantity: const Value(0),
        purchasePrice: const Value(48500),
        salePrice: const Value(54000),
        minPrice: const Value(52000),
      ));
  return (productId, variantId);
}

Future<(String, String)> _seedAccessory(AppDatabase db, {int qty = 10}) async {
  final productId = newUuid();
  await db.into(db.products).insert(ProductsCompanion.insert(
        id: productId,
        type: 'accessory',
        name: 'Oraimo Fast Charger 25W',
      ));
  final variantId = newUuid();
  await db.into(db.productVariants).insert(ProductVariantsCompanion.insert(
        id: variantId,
        productId: productId,
        name: '25W USB-C · Black',
        quantity: Value(qty),
        purchasePrice: const Value(1400),
        salePrice: const Value(2000),
        minPrice: const Value(1700),
      ));
  return (productId, variantId);
}

Future<int> _variantQty(AppDatabase db, String variantId) async {
  final row = await (db.select(db.productVariants)
        ..where((t) => t.id.equals(variantId)))
      .getSingle();
  return row.quantity;
}

Future<(String, String)> _imei(AppDatabase db, String imei1) async {
  final row = await (db.select(db.imeiItems)
        ..where((t) => t.imei1.equals(imei1)))
      .getSingle();
  return (row.id, row.status);
}

Future<int> _saleItemProfit(AppDatabase db, String saleItemId) async {
  final row = await (db.select(db.saleItems)
        ..where((t) => t.id.equals(saleItemId)))
      .getSingle();
  return row.profit;
}

void main() {
  test(
      'purchase -> partial sale -> return -> purchase return -> repair -> reports',
      () async {
    final db = _inMemoryAppDb();
    addTearDown(db.close);
    final catalogDb = CatalogDatabase.memory();
    addTearDown(catalogDb.close);
    final catalog = CatalogRepositoryImpl(catalogDb);
    final suppliers = DriftSupplierRepository(db);
    final customers = DriftCustomerRepository(db);
    final purchases = DriftPurchaseRepository(db);
    final sales = DriftSaleRepository(db);
    final repairs = DriftRepairRepository(db);
    final reports = DriftReportRepository(db);

    final now = DateTime.now();
    final supplier = await suppliers.createSupplier(Supplier(
      id: '',
      name: 'Hassan Mobile Traders',
      createdAt: now,
      updatedAt: now,
    ));
    final settled = await suppliers.createSupplier(Supplier(
      id: '',
      name: 'Settled Supplier',
      createdAt: now,
      updatedAt: now,
    ));
    final customer = await customers.createCustomer(Customer(
      id: '',
      name: 'Ahmed Raza',
      phone: '03012345678',
      createdAt: now,
      updatedAt: now,
    ));

    final (phoneProductId, phoneVariantId) = await _seedPhone(db);
    final (accProductId, accVariantId) = await _seedAccessory(db);
    await catalog.addCustomItem(CatalogItem(
      sku: 'ACC-CAB-ANK-TC10-001',
      category: 'Cables',
      brand: 'Anker',
      nameEn: 'Anker Type-C Cable 1m',
      nameUr: 'چارجر',
      purchasePriceEst: 200,
      salePriceEst: 400,
      minPrice: 320,
      stockQty: 0,
    ));

    // The supplier picker sees the zero-payable supplier too (Round 3
    // fix: pickers + detail route source from SupplierRepository).
    final summaries = await loadSupplierSummaries(suppliers: suppliers);
    expect(summaries.map((s) => s.name),
        containsAll(['Hassan Mobile Traders', 'Settled Supplier']));
    expect(summaries.firstWhere((s) => s.id == settled.id).payable, 0);

    // -- (a) Purchase: 2 phones + 5 accessories + 4 catalog cables ------
    final purchase = await purchases.createPurchase(
      Purchase(
        id: '',
        supplierId: supplier.id,
        userId: 'tester',
        supplierInvoiceNo: 'E2E-001',
        purchaseDate: now,
        grandTotal: 104800,
        items: [
          PurchaseItem(
            id: '',
            purchaseId: '',
            productId: phoneProductId,
            variantId: phoneVariantId,
            imei1: '869911234567890',
            quantity: 1,
            unitCost: 48500,
            total: 48500,
            createdAt: now,
          ),
          PurchaseItem(
            id: '',
            purchaseId: '',
            productId: phoneProductId,
            variantId: phoneVariantId,
            imei1: '869911234567907',
            quantity: 1,
            unitCost: 48500,
            total: 48500,
            createdAt: now,
          ),
          PurchaseItem(
            id: '',
            purchaseId: '',
            productId: accProductId,
            variantId: accVariantId,
            quantity: 5,
            unitCost: 1400,
            total: 7000,
            createdAt: now,
          ),
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
    expect(purchase.grandTotal, 104800);
    expect(purchase.balanceDue, 104800);
    // Catalog stock is added by the caller on save (purchase entry flow).
    await catalog.stockIn('ACC-CAB-ANK-TC10-001', 4);
    expect((await catalog.search('Type-C Cable')).single.stockQty, 4);
    expect(await _imei(db, '869911234567890'), isNotNull);
    expect((await _imei(db, '869911234567890')).$2, 'available');
    expect((await _imei(db, '869911234567907')).$2, 'available');
    // Phones are IMEI-tracked: variant quantity does not move.
    expect(await _variantQty(db, phoneVariantId), 0);
    expect(await _variantQty(db, accVariantId), 15);
    expect((await suppliers.getSupplier(supplier.id))?.payable, 104800);

    // -- (b) Sell one phone, partial payment (54000, paid 30000) ---------
    final imeiItemId = (await _imei(db, '869911234567890')).$1;
    final sale = await sales.createSale(
      sale: Sale(
        id: '',
        invoiceNo: '',
        customerId: customer.id,
        customerName: customer.name,
        customerPhone: customer.phone,
        userId: 'tester',
        saleDate: now,
        grandTotal: 54000,
        paidAmount: 30000,
        balanceDue: 24000,
        paymentMethod: 'partial',
        items: [
          SaleItem(
            id: '',
            saleId: '',
            productId: phoneProductId,
            variantId: phoneVariantId,
            imeiItemId: imeiItemId,
            nameSnapshot: 'Samsung Galaxy A16 — 8GB / 128GB · Black',
            quantity: 1,
            unitPrice: 54000,
            purchaseCost: 48500,
            total: 54000,
            profit: 5500,
            createdAt: now,
          ),
        ],
        createdAt: now,
        updatedAt: now,
      ),
    );
    expect(sale.grandTotal, 54000);
    expect(sale.paidAmount, 30000);
    expect(sale.balanceDue, 24000);
    expect(sale.paymentStatus, 'partial');
    expect((await _imei(db, '869911234567890')).$2, 'sold');
    expect(await _variantQty(db, phoneVariantId), 0);
    var ledger = await customers.ledger(customer.id);
    expect(ledger, hasLength(1));
    // Flutter posts the full bill as debit and the cash as credit
    // (the backend posts only the due as debit); the balance is the
    // same either way: 54000 - 30000 = 24000 owed.
    expect(ledger.first.debit, 54000);
    expect(ledger.first.credit, 30000);
    expect(ledger.first.balanceAfter, 24000);
    expect(await customers.runningBalance(customer.id), 24000);

    // -- (c) Return the sold phone ----------------------------------------
    final saleItemId = sale.items.single.id;
    final returned = await sales.returnSale(
      saleId: sale.id,
      saleItemId: saleItemId,
      quantity: 1,
      reason: 'E2E return check',
      userId: 'tester',
    );
    expect(returned.status, 'returned');
    expect(returned.grandTotal, 0);
    expect(returned.paidAmount, 0);
    expect(returned.balanceDue, 0);
    expect((await _imei(db, '869911234567890')).$2, 'available');
    expect(await _saleItemProfit(db, saleItemId), 0);
    ledger = await customers.ledger(customer.id);
    expect(ledger, hasLength(2));
    expect(ledger.last.referenceType, 'return');
    expect(ledger.last.credit, 24000);
    expect(await customers.runningBalance(customer.id), 0);
    // A second full return of the same line is rejected.
    expect(
      () => sales.returnSale(
        saleId: sale.id,
        saleItemId: saleItemId,
        quantity: 1,
        userId: 'tester',
      ),
      throwsA(isA<Exception>()),
    );

    // -- (d) Purchase return: 2 catalog cables back to the supplier -----
    final catalogLine =
        purchase.items.singleWhere((i) => i.catalogSku != null);
    final purchaseReturn = await purchases.returnPurchase(
      purchaseId: purchase.id,
      purchaseItemId: catalogLine.id,
      quantity: 2,
      userId: 'tester',
    );
    expect(purchaseReturn.catalogSku, 'ACC-CAB-ANK-TC10-001');
    expect(purchaseReturn.refundAmount, 400);
    // The caller stocks the returned catalog goods out (Round 3 fix).
    await catalog.stockOut('ACC-CAB-ANK-TC10-001', 2);
    expect((await catalog.search('Type-C Cable')).single.stockQty, 2);
    expect((await suppliers.getSupplier(supplier.id))?.payable, 104400);

    // -- (e) Repair: part stock restore + delivery with udhaar -----------
    final repair = await repairs.createRepair(Repair(
      id: '',
      jobNo: 'REP-E2E',
      customerId: customer.id,
      customerName: customer.name,
      customerPhone: customer.phone,
      faultDescription: 'Screen broken',
      estimatedCost: 10000,
      finalCost: 10000,
      advancePaid: 4000,
      status: 'ready',
      receivedDate: now,
      userId: 'tester',
      createdAt: now,
      updatedAt: now,
    ));
    final part = await repairs.addPart(RepairPart(
      id: '',
      repairId: repair.id,
      variantId: accVariantId,
      name: 'Oraimo Fast Charger 25W',
      quantity: 2,
      unitPrice: 500,
      total: 1000,
      createdAt: now,
    ));
    expect(await _variantQty(db, accVariantId), 13);
    await repairs.removePart(part.id);
    expect(await _variantQty(db, accVariantId), 15);
    final delivered = await repairs.deliverWithUdhaar(repair.id);
    expect(delivered.status, 'delivered');
    expect(await customers.runningBalance(customer.id), 6000);

    // -- (f) Reports: the returned sale counts for nothing ----------------
    final from = now.subtract(const Duration(days: 1));
    final to = now.add(const Duration(days: 1));
    final dashboard = await reports.dashboardTotals(from: from, to: to);
    expect(dashboard.totalRevenue, 0);
    expect(dashboard.totalProfit, 0);
    expect(dashboard.salesCount, 1);
    expect(dashboard.pendingUdhaar, 6000);
    expect(dashboard.supplierPayables, 104400);
    expect(dashboard.availablePhones, 2);
    final pl = await reports.profitAndLoss(from, to);
    expect(pl.revenue, 0);
    expect(pl.grossProfit, 0);
  });
}
