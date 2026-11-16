/// Purchase repository: supplier purchases, supplier payable ledger,
/// purchase payments and purchase returns.
///
/// `createPurchase` runs in ONE transaction: purchase + items + IMEI
/// items created as `available` + accessory stock added + supplier
/// payable ledger + payment + audit + outbox. A duplicate IMEI is
/// rejected before anything is written.
/// Money is integer whole PKR.
library;

import 'package:drift/drift.dart';

import '../../domain/models/ledger_entry.dart';
import '../../domain/models/purchase.dart';
import '../../domain/models/sale.dart' show Payment;
import '../database/app_database.dart' as db;
import 'product_repository.dart' show RepositoryException;

abstract class PurchaseRepository {
  /// Creates a purchase in one transaction (see file header).
  Future<Purchase> createPurchase(Purchase purchase, {String? userId});

  Future<Purchase?> getPurchase(String id);
  Future<List<Purchase>> listPurchases({
    String? supplierId,
    DateTime? from,
    DateTime? to,
    String? status,
    int limit = 100,
    int offset = 0,
  });

  /// Records a payment to the supplier against a purchase.
  Future<Payment> recordPurchasePayment({
    required String purchaseId,
    required int amount,
    required String method,
    String? reference,
    required String userId,
    String? notes,
  });

  /// Sends goods back to the supplier. For a phone IMEI the IMEI row is
  /// removed (it never entered a sale); for accessories the variant
  /// quantity is reduced. Reduces the supplier payable. A returned
  /// catalog accessory keeps its [PurchaseItem.catalogSku] on the
  /// [PurchaseReturn] row; the caller must then call
  /// `CatalogRepository.stockOut` for that SKU (the catalog lives in
  /// a separate database this repository cannot reach).
  Future<PurchaseReturn> returnPurchase({
    required String purchaseId,
    String? purchaseItemId,
    String? imeiItemId,
    int quantity = 1,
    String? reason,
    required String userId,
  });

  Future<List<PurchaseReturn>> listPurchaseReturns(String purchaseId);

  /// Current amount the shop owes a supplier.
  Future<int> supplierPayable(String supplierId);

  /// Supplier ledger entries, newest first.
  Future<List<LedgerEntry>> supplierLedger(
    String supplierId, {
    DateTime? from,
    DateTime? to,
    int limit = 200,
  });
}

class DriftPurchaseRepository implements PurchaseRepository {
  final db.AppDatabase database;

  DriftPurchaseRepository(this.database);

  PurchaseItem _item(db.PurchaseItem row) => PurchaseItem(
        id: row.id,
        purchaseId: row.purchaseId,
        productId: row.productId,
        variantId: row.variantId,
        imei1: row.imei1,
        imei2: row.imei2,
        catalogSku: row.catalogSku,
        quantity: row.quantity,
        unitCost: row.unitCost,
        total: row.total,
        createdAt: row.createdAt,
      );

  Purchase _purchase(db.Purchase row, [List<PurchaseItem> items = const []]) =>
      Purchase(
        id: row.id,
        supplierId: row.supplierId,
        branchId: row.branchId,
        userId: row.userId,
        supplierInvoiceNo: row.supplierInvoiceNo,
        purchaseDate: row.purchaseDate,
        subtotal: row.subtotal,
        discount: row.discount,
        grandTotal: row.grandTotal,
        paidAmount: row.paidAmount,
        balanceDue: row.balanceDue,
        status: row.status,
        notes: row.notes,
        clientUuid: row.clientUuid,
        items: items,
        createdAt: row.createdAt,
        updatedAt: row.updatedAt,
      );

  PurchaseReturn _purchaseReturn(db.PurchaseReturn row) => PurchaseReturn(
        id: row.id,
        purchaseId: row.purchaseId,
        imeiItemId: row.imeiItemId,
        productId: row.productId,
        variantId: row.variantId,
        catalogSku: row.catalogSku,
        quantity: row.quantity,
        reason: row.reason,
        refundAmount: row.refundAmount,
        userId: row.userId,
        createdAt: row.createdAt,
      );

  LedgerEntry _entry(db.LedgerEntry row) => LedgerEntry(
        id: row.id,
        side: row.side,
        customerId: row.customerId,
        supplierId: row.supplierId,
        referenceType: row.referenceType,
        referenceId: row.referenceId,
        debit: row.debit,
        credit: row.credit,
        balanceAfter: row.balanceAfter,
        entryDate: row.entryDate,
        userId: row.userId,
        notes: row.notes,
        createdAt: row.createdAt,
      );

  Future<List<PurchaseItem>> _itemsOf(String purchaseId) async {
    final rows = await (database.select(database.purchaseItems)
          ..where((t) => t.purchaseId.equals(purchaseId)))
        .get();
    return rows.map(_item).toList();
  }

  /// Current supplier payable, as SUM(credit - debit) over the ledger
  /// (not the "latest" row — two entries sharing an entryDate
  /// millisecond made that lookup ambiguous).
  Future<int> _payable(String supplierId) async {
    final row = await database.customSelect(
      'SELECT COALESCE(SUM(credit - debit), 0) AS total, COUNT(*) AS n '
      'FROM ledger_entries WHERE side = ? AND supplier_id = ?',
      variables: [
        Variable.withString('supplier'),
        Variable.withString(supplierId),
      ],
    ).getSingle();
    if (row.read<int>('n') == 0) {
      final supplier = await (database.select(database.suppliers)
            ..where((t) => t.id.equals(supplierId)))
          .getSingleOrNull();
      return supplier?.openingPayable ?? 0;
    }
    return row.read<int>('total');
  }

  /// Supplier ledger: payable grows with credit (goods received) and
  /// shrinks with debit (payments / returns).
  Future<void> _supplierLedger({
    required String supplierId,
    required String referenceType,
    required String referenceId,
    required int debit,
    required int credit,
    String? userId,
    String? notes,
  }) async {
    final prev = await _payable(supplierId);
    await database.into(database.ledgerEntries).insert(
          db.LedgerEntriesCompanion.insert(
            id: db.newUuid(),
            side: 'supplier',
            supplierId: Value(supplierId),
            referenceType: referenceType,
            referenceId: Value(referenceId),
            debit: Value(debit),
            credit: Value(credit),
            balanceAfter: Value(prev + credit - debit),
            entryDate: Value(DateTime.now()),
            userId: Value(userId),
            notes: Value(notes),
          ),
        );
  }

  @override
  Future<Purchase> createPurchase(Purchase purchase, {String? userId}) async {
    if (purchase.items.isEmpty) {
      throw const RepositoryException('A purchase needs at least one item');
    }
    final imeis = purchase.items
        .where((i) => i.imei1 != null && i.imei1!.isNotEmpty)
        .map((i) => i.imei1!)
        .toList();
    if (imeis.toSet().length != imeis.length) {
      throw const RepositoryException('Duplicate IMEI in the same purchase');
    }
    final subtotal =
        purchase.items.fold<int>(0, (sum, i) => sum + i.total);
    if (purchase.discount < 0 || purchase.discount > subtotal) {
      throw const RepositoryException('Discount must be between 0 and subtotal');
    }
    final grandTotal = subtotal - purchase.discount;
    if (purchase.paidAmount < 0 || purchase.paidAmount > grandTotal) {
      throw const RepositoryException('Paid amount must be between 0 and total');
    }
    final balanceDue = grandTotal - purchase.paidAmount;

    return database.transaction(() async {
      final now = DateTime.now();
      final purchaseId =
          purchase.id.isEmpty ? db.newUuid() : purchase.id;
      final supplier = await (database.select(database.suppliers)
            ..where((t) => t.id.equals(purchase.supplierId)))
          .getSingleOrNull();
      if (supplier == null) {
        throw RepositoryException(
            'Supplier ${purchase.supplierId} not found');
      }
      // Reject any IMEI that already exists in the shop.
      for (final imei in imeis) {
        final existing = await (database.select(database.imeiItems)
              ..where((t) => t.imei1.equals(imei)))
            .getSingleOrNull();
        if (existing != null) {
          throw RepositoryException(
              'IMEI $imei already exists in stock and cannot be '
              'purchased again');
        }
      }
      await database.into(database.purchases).insert(
            db.PurchasesCompanion.insert(
              id: purchaseId,
              supplierId: purchase.supplierId,
              branchId: Value(purchase.branchId),
              userId: purchase.userId,
              supplierInvoiceNo: Value(purchase.supplierInvoiceNo),
              purchaseDate: Value(purchase.purchaseDate),
              subtotal: Value(subtotal),
              discount: Value(purchase.discount),
              grandTotal: Value(grandTotal),
              paidAmount: Value(purchase.paidAmount),
              balanceDue: Value(balanceDue),
              status: Value(purchase.status),
              notes: Value(purchase.notes),
              clientUuid: Value(purchase.clientUuid ?? db.newUuid()),
              createdAt: Value(now),
              updatedAt: Value(now),
            ),
          );
      final savedItems = <PurchaseItem>[];
      for (final item in purchase.items) {
        final itemId = item.id.isEmpty ? db.newUuid() : item.id;
        await database.into(database.purchaseItems).insert(
              db.PurchaseItemsCompanion.insert(
                id: itemId,
                purchaseId: purchaseId,
                productId: Value(item.productId),
                variantId: Value(item.variantId),
                imei1: Value(item.imei1),
                imei2: Value(item.imei2),
                catalogSku: Value(item.catalogSku),
                quantity: Value(item.quantity),
                unitCost: item.unitCost,
                total: item.total,
                createdAt: Value(now),
              ),
            );
        savedItems.add(item.copyWith(
            id: itemId, purchaseId: purchaseId, createdAt: now));
        if (item.imei1 != null && item.imei1!.isNotEmpty) {
          // One IMEI row per phone, available for sale.
          int salePrice = item.unitCost;
          if (item.variantId != null) {
            final variant =
                await (database.select(database.productVariants)
                      ..where((t) => t.id.equals(item.variantId!)))
                    .getSingleOrNull();
            if (variant != null && variant.salePrice > 0) {
              salePrice = variant.salePrice;
            }
          }
          await database.into(database.imeiItems).insert(
                db.ImeiItemsCompanion.insert(
                  id: db.newUuid(),
                  productId: item.productId ?? '',
                  variantId: Value(item.variantId),
                  imei1: item.imei1!,
                  imei2: Value(item.imei2),
                  status: const Value('available'),
                  purchaseId: Value(purchaseId),
                  purchasePrice: Value(item.unitCost),
                  salePrice: Value(salePrice),
                  createdAt: Value(now),
                  updatedAt: Value(now),
                ),
              );
        } else if (item.variantId != null) {
          // Accessory: add to variant quantity.
          await database.customStatement(
            'UPDATE product_variants SET quantity = quantity + ?, '
            'updated_at = ? WHERE id = ?',
            [item.quantity, now.millisecondsSinceEpoch, item.variantId],
          );
        }
      }
      if (purchase.paidAmount > 0) {
        await database.into(database.payments).insert(
              db.PaymentsCompanion.insert(
                id: db.newUuid(),
                paymentType: 'purchase',
                purchaseId: Value(purchaseId),
                supplierId: Value(purchase.supplierId),
                method: const Value('cash'),
                amount: purchase.paidAmount,
                paymentDate: Value(now),
                userId: purchase.userId,
                clientUuid: Value(db.newUuid()),
                createdAt: Value(now),
              ),
            );
      }
      await _supplierLedger(
        supplierId: purchase.supplierId,
        referenceType: 'purchase',
        referenceId: purchaseId,
        debit: purchase.paidAmount,
        credit: grandTotal,
        userId: userId,
        notes: 'Purchase ${purchase.supplierInvoiceNo ?? purchaseId}',
      );
      final saved = purchase.copyWith(
        id: purchaseId,
        subtotal: subtotal,
        grandTotal: grandTotal,
        paidAmount: purchase.paidAmount,
        balanceDue: balanceDue,
        items: savedItems,
        createdAt: now,
        updatedAt: now,
        supplierName: supplier.name,
      );
      await database.writeAudit(
        userId: userId,
        action: 'create',
        entityType: 'purchase',
        entityId: purchaseId,
        newValues: saved.toJson(),
      );
      await database.enqueueOutbox(
        tableName: 'purchases',
        operation: 'insert',
        payload: saved.toJson(),
      );
      return saved;
    });
  }

  @override
  Future<Purchase?> getPurchase(String id) async {
    final row = await (database.select(database.purchases)
          ..where((t) => t.id.equals(id)))
        .getSingleOrNull();
    if (row == null) return null;
    return _purchase(row, await _itemsOf(id));
  }

  @override
  Future<List<Purchase>> listPurchases({
    String? supplierId,
    DateTime? from,
    DateTime? to,
    String? status,
    int limit = 100,
    int offset = 0,
  }) async {
    final query = database.select(database.purchases);
    if (supplierId != null) {
      query.where((t) => t.supplierId.equals(supplierId));
    }
    if (from != null) {
      query.where((t) => t.purchaseDate.isBiggerOrEqualValue(from));
    }
    if (to != null) {
      query.where((t) => t.purchaseDate.isSmallerOrEqualValue(to));
    }
    if (status != null) query.where((t) => t.status.equals(status));
    query.orderBy([(t) => OrderingTerm.desc(t.purchaseDate)]);
    query.limit(limit, offset: offset);
    final rows = await query.get();
    final result = <Purchase>[];
    for (final row in rows) {
      result.add(_purchase(row, await _itemsOf(row.id)));
    }
    return result;
  }

  @override
  Future<Payment> recordPurchasePayment({
    required String purchaseId,
    required int amount,
    required String method,
    String? reference,
    required String userId,
    String? notes,
  }) async {
    if (amount <= 0) {
      throw const RepositoryException('Payment amount must be greater than 0');
    }
    return database.transaction(() async {
      final row = await (database.select(database.purchases)
            ..where((t) => t.id.equals(purchaseId)))
          .getSingleOrNull();
      if (row == null) {
        throw RepositoryException('Purchase $purchaseId not found');
      }
      if (amount > row.balanceDue) {
        throw RepositoryException(
            'Payment exceeds the due amount Rs ${row.balanceDue}');
      }
      final now = DateTime.now();
      final payment = Payment(
        id: db.newUuid(),
        paymentType: 'purchase',
        purchaseId: purchaseId,
        supplierId: row.supplierId,
        method: method,
        amount: amount,
        reference: reference,
        paymentDate: now,
        userId: userId,
        notes: notes,
        createdAt: now,
      );
      await database.into(database.payments).insert(
            db.PaymentsCompanion.insert(
              id: payment.id,
              paymentType: 'purchase',
              purchaseId: Value(purchaseId),
              supplierId: Value(row.supplierId),
              method: Value(method),
              amount: amount,
              reference: Value(reference),
              paymentDate: Value(now),
              userId: userId,
              notes: Value(notes),
              clientUuid: Value(db.newUuid()),
              createdAt: Value(now),
            ),
          );
      await (database.update(database.purchases)
            ..where((t) => t.id.equals(purchaseId)))
          .write(db.PurchasesCompanion(
            paidAmount: Value(row.paidAmount + amount),
            balanceDue: Value(row.balanceDue - amount),
            updatedAt: Value(now),
          ));
      await _supplierLedger(
        supplierId: row.supplierId,
        referenceType: 'payment',
        referenceId: payment.id,
        debit: amount,
        credit: 0,
        userId: userId,
        notes: notes ?? 'Payment to supplier',
      );
      await database.writeAudit(
        userId: userId,
        action: 'payment',
        entityType: 'purchase',
        entityId: purchaseId,
        newValues: payment.toJson(),
      );
      await database.enqueueOutbox(
        tableName: 'payments',
        operation: 'insert',
        payload: payment.toJson(),
      );
      return payment;
    });
  }

  @override
  Future<PurchaseReturn> returnPurchase({
    required String purchaseId,
    String? purchaseItemId,
    String? imeiItemId,
    int quantity = 1,
    String? reason,
    required String userId,
  }) async {
    if (quantity <= 0) {
      throw const RepositoryException('Return quantity must be at least 1');
    }
    return database.transaction(() async {
      final purchaseRow = await (database.select(database.purchases)
            ..where((t) => t.id.equals(purchaseId)))
          .getSingleOrNull();
      if (purchaseRow == null) {
        throw RepositoryException('Purchase $purchaseId not found');
      }
      String? productId;
      String? variantId;
      String? catalogSku;
      int refundAmount = 0;
      if (imeiItemId != null) {
        final imeiRow = await (database.select(database.imeiItems)
              ..where((t) => t.id.equals(imeiItemId)))
            .getSingleOrNull();
        if (imeiRow == null) {
          throw RepositoryException('IMEI item $imeiItemId not found');
        }
        if (imeiRow.status == 'sold') {
          throw RepositoryException(
              'IMEI ${imeiRow.imei1} is already sold and cannot be '
              'returned to the supplier');
        }
        productId = imeiRow.productId;
        variantId = imeiRow.variantId;
        refundAmount = imeiRow.purchasePrice;
        // The phone leaves the shop: remove its IMEI row.
        await (database.delete(database.imeiItems)
              ..where((t) => t.id.equals(imeiItemId)))
            .go();
      } else if (purchaseItemId != null) {
        final itemRow = await (database.select(database.purchaseItems)
              ..where((t) => t.id.equals(purchaseItemId)))
            .getSingleOrNull();
        if (itemRow == null || itemRow.purchaseId != purchaseId) {
          throw RepositoryException(
              'Purchase item $purchaseItemId not found');
        }
        if (quantity > itemRow.quantity) {
          throw RepositoryException(
              'Cannot return $quantity; only ${itemRow.quantity} purchased');
        }
        productId = itemRow.productId;
        variantId = itemRow.variantId;
        catalogSku = itemRow.catalogSku;
        refundAmount = itemRow.unitCost * quantity;
        if (variantId != null) {
          final now = DateTime.now();
          await database.customStatement(
            'UPDATE product_variants SET quantity = quantity - ?, '
            'updated_at = ? WHERE id = ? AND quantity >= ?',
            [
              quantity,
              now.millisecondsSinceEpoch,
              variantId,
              quantity,
            ],
          );
        }
      } else {
        throw const RepositoryException(
            'Provide purchaseItemId or imeiItemId to return');
      }
      final now = DateTime.now();
      final ret = PurchaseReturn(
        id: db.newUuid(),
        purchaseId: purchaseId,
        imeiItemId: imeiItemId,
        productId: productId,
        variantId: variantId,
        catalogSku: catalogSku,
        quantity: quantity,
        reason: reason,
        refundAmount: refundAmount,
        userId: userId,
        createdAt: now,
      );
      await database.into(database.purchaseReturns).insert(
            db.PurchaseReturnsCompanion.insert(
              id: ret.id,
              purchaseId: purchaseId,
              imeiItemId: Value(imeiItemId),
              productId: Value(productId),
              variantId: Value(variantId),
              catalogSku: Value(catalogSku),
              quantity: Value(quantity),
              reason: Value(reason),
              refundAmount: Value(refundAmount),
              userId: userId,
              createdAt: Value(now),
            ),
          );
      await _supplierLedger(
        supplierId: purchaseRow.supplierId,
        referenceType: 'return',
        referenceId: ret.id,
        debit: refundAmount,
        credit: 0,
        userId: userId,
        notes: reason ?? 'Purchase return',
      );
      await (database.update(database.purchases)
            ..where((t) => t.id.equals(purchaseId)))
          .write(db.PurchasesCompanion(
            status: const Value('partially_returned'),
            updatedAt: Value(now),
          ));
      await database.writeAudit(
        userId: userId,
        action: 'return',
        entityType: 'purchase',
        entityId: purchaseId,
        newValues: ret.toJson(),
      );
      await database.enqueueOutbox(
        tableName: 'purchase_returns',
        operation: 'insert',
        payload: ret.toJson(),
      );
      return ret;
    });
  }

  @override
  Future<List<PurchaseReturn>> listPurchaseReturns(String purchaseId) async {
    final rows = await (database.select(database.purchaseReturns)
          ..where((t) => t.purchaseId.equals(purchaseId))
          ..orderBy([(t) => OrderingTerm.desc(t.createdAt)]))
        .get();
    return rows.map(_purchaseReturn).toList();
  }

  @override
  Future<int> supplierPayable(String supplierId) => _payable(supplierId);

  @override
  Future<List<LedgerEntry>> supplierLedger(
    String supplierId, {
    DateTime? from,
    DateTime? to,
    int limit = 200,
  }) async {
    final query = database.select(database.ledgerEntries);
    query.where((t) =>
        t.side.equals('supplier') & t.supplierId.equals(supplierId));
    if (from != null) {
      query.where((t) => t.entryDate.isBiggerOrEqualValue(from));
    }
    if (to != null) {
      query.where((t) => t.entryDate.isSmallerOrEqualValue(to));
    }
    query.orderBy([(t) => OrderingTerm.desc(t.entryDate)]);
    query.limit(limit);
    return (await query.get()).map(_entry).toList();
  }
}
