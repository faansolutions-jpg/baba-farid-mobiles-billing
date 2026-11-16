/// Sale repository.
///
/// `createSale` runs in ONE drift transaction: sale + items + IMEI
/// status -> sold + accessory stock deduction + ledger + cash + audit +
/// outbox. Any failure rolls everything back.
///
/// Enforced rules (DECISIONS.md 12-15, domain/rules.dart):
/// * an IMEI item sells only when its status is `available`;
/// * a duplicate IMEI in one bill is rejected;
/// * a unit price below the variant's `min_price` needs
///   [adminApprovedBy] or the sale is rejected;
/// * all money is integer whole PKR.
library;

import 'dart:convert';

import 'package:drift/drift.dart';

import '../../domain/models/held_bill.dart';
import '../../domain/models/imei_item.dart';
import '../../domain/models/sale.dart';
import '../../domain/rules.dart';
import '../database/app_database.dart' as db;
import 'product_repository.dart' show RepositoryException;

abstract class SaleRepository {
  /// Creates a bill in one transaction. [sale] carries the bill header
  /// and its [Sale.items]. Throws [RepositoryException] when an IMEI is
  /// not available, is duplicated, stock is short, totals are invalid,
  /// or a below-minimum price lacks [adminApprovedBy].
  Future<Sale> createSale({
    required Sale sale,
    String? adminApprovedBy,
    String? userId,
  });

  Future<Sale?> getSale(String id);
  Future<List<Sale>> listSales({
    DateTime? from,
    DateTime? to,
    String? customerId,
    String? status,
    int limit = 100,
    int offset = 0,
  });

  /// Records an additional payment against a sale (partial / udhaar
  /// recovery). Updates paid / due amounts, the ledger and cash.
  Future<Payment> recordPayment({
    required String saleId,
    required int amount,
    required String method,
    String? reference,
    required String userId,
    String? customerId,
    String? notes,
  });

  /// Returns [quantity] of one sale line. Restores the IMEI to
  /// `available` (or the accessory quantity), credits the customer
  /// ledger and refunds cash when applicable.
  Future<Sale> returnSale({
    required String saleId,
    required String saleItemId,
    int quantity = 1,
    String? reason,
    required String userId,
    bool isExchange = false,
    String? exchangeSaleId,
  });

  Future<List<SaleReturn>> listSaleReturns(String saleId);
  Future<HeldBill> holdBill(HeldBill bill, {String? userId});
  Future<HeldBill?> resumeBill(String heldBillId, {String? userId});
  Future<List<HeldBill>> listHeldBills({String? branchId});
  Future<void> deleteHeldBill(String id, {String? userId});
  Future<Sale> cancelSale(String saleId, {required String userId, String? reason});
}

class DriftSaleRepository implements SaleRepository {
  final db.AppDatabase database;

  DriftSaleRepository(this.database);

  // -- Row mapping -----------------------------------------------------------

  SaleItem _item(db.SaleItem row) => SaleItem(
        id: row.id,
        saleId: row.saleId,
        productId: row.productId,
        variantId: row.variantId,
        imeiItemId: row.imeiItemId,
        nameSnapshot: row.nameSnapshot,
        quantity: row.quantity,
        unitPrice: row.unitPrice,
        purchaseCost: row.purchaseCost,
        discount: row.discount,
        total: row.total,
        profit: row.profit,
        createdAt: row.createdAt,
      );

  Sale _sale(db.Sale row, [List<SaleItem> items = const []]) => Sale(
        id: row.id,
        invoiceNo: row.invoiceNo,
        branchId: row.branchId,
        customerId: row.customerId,
        customerName: row.customerName,
        customerPhone: row.customerPhone,
        userId: row.userId,
        saleDate: row.saleDate,
        subtotal: row.subtotal,
        discountAmount: row.discountAmount,
        discountPercent: row.discountPercent,
        taxAmount: row.taxAmount,
        grandTotal: row.grandTotal,
        paidAmount: row.paidAmount,
        balanceDue: row.balanceDue,
        paymentMethod: row.paymentMethod,
        paymentStatus: row.paymentStatus,
        status: row.status,
        notes: row.notes,
        clientUuid: row.clientUuid,
        items: items,
        createdAt: row.createdAt,
        updatedAt: row.updatedAt,
      );

  SaleReturn _saleReturn(db.SaleReturn row) => SaleReturn(
        id: row.id,
        saleId: row.saleId,
        saleItemId: row.saleItemId,
        imeiItemId: row.imeiItemId,
        quantity: row.quantity,
        reason: row.reason,
        refundAmount: row.refundAmount,
        isExchange: row.isExchange,
        exchangeSaleId: row.exchangeSaleId,
        userId: row.userId,
        createdAt: row.createdAt,
      );

  Future<List<SaleItem>> _itemsOf(String saleId) async {
    final rows = await (database.select(database.saleItems)
          ..where((t) => t.saleId.equals(saleId)))
        .get();
    return rows.map(_item).toList();
  }

  /// Current customer balance, as SUM(debit - credit) over the ledger
  /// (see [_balance] in customer_repository.dart — the "latest row"
  /// lookup breaks when two entries share an entryDate millisecond).
  Future<int> _customerBalance(String customerId) async {
    final row = await database.customSelect(
      'SELECT COALESCE(SUM(debit - credit), 0) AS total, COUNT(*) AS n '
      'FROM ledger_entries WHERE side = ? AND customer_id = ?',
      variables: [
        Variable.withString('customer'),
        Variable.withString(customerId),
      ],
    ).getSingle();
    if (row.read<int>('n') == 0) {
      final customer = await (database.select(database.customers)
            ..where((t) => t.id.equals(customerId)))
          .getSingleOrNull();
      return customer?.openingBalance ?? 0;
    }
    return row.read<int>('total');
  }

  Future<void> _customerLedger({
    required String customerId,
    required String referenceType,
    required String referenceId,
    required int debit,
    required int credit,
    String? userId,
    String? notes,
  }) async {
    final prev = await _customerBalance(customerId);
    final after = prev + debit - credit;
    await database.into(database.ledgerEntries).insert(
          db.LedgerEntriesCompanion.insert(
            id: db.newUuid(),
            side: 'customer',
            customerId: Value(customerId),
            referenceType: referenceType,
            referenceId: Value(referenceId),
            debit: Value(debit),
            credit: Value(credit),
            balanceAfter: Value(after),
            entryDate: Value(DateTime.now()),
            userId: Value(userId),
            notes: Value(notes),
          ),
        );
  }

  /// Adds a cash `in`/`out` movement to today's open register, if one
  /// exists. Silently skipped when no register is open (the sale itself
  /// must never fail because the register is closed).
  Future<void> _cashMovement({
    String? branchId,
    required String type,
    required int amount,
    required String reason,
    required String userId,
  }) async {
    if (amount <= 0) return;
    final today = DateTime.now();
    final day = DateTime(today.year, today.month, today.day);
    final register = await (database.select(database.cashRegisters)
          ..where((t) =>
              t.status.equals('open') & t.registerDate.equals(day))
          ..limit(1))
        .getSingleOrNull();
    if (register == null) return;
    await database.into(database.cashMovements).insert(
          db.CashMovementsCompanion.insert(
            id: db.newUuid(),
            registerId: register.id,
            type: type,
            amount: amount,
            reason: Value(reason),
            userId: userId,
          ),
        );
  }

  // -- Create ----------------------------------------------------------------

  @override
  Future<Sale> createSale({
    required Sale sale,
    String? adminApprovedBy,
    String? userId,
  }) async {
    if (sale.items.isEmpty) {
      throw const RepositoryException('A sale needs at least one item');
    }
    if (sale.paidAmount < 0) {
      throw const RepositoryException('Paid amount cannot be negative');
    }
    // Duplicate IMEI inside one bill is rejected outright.
    final imeiIds = sale.items
        .where((i) => i.imeiItemId != null)
        .map((i) => i.imeiItemId!)
        .toList();
    if (imeiIds.toSet().length != imeiIds.length) {
      throw const RepositoryException('Duplicate IMEI in the same bill');
    }
    // Recompute totals from the lines so a tampered header cannot pass.
    final subtotal =
        sale.items.fold<int>(0, (sum, i) => sum + i.total);
    if (sale.discountAmount < 0 || sale.discountAmount > subtotal) {
      throw const RepositoryException('Discount must be between 0 and subtotal');
    }
    final grandTotal = subtotal - sale.discountAmount + sale.taxAmount;
    if (grandTotal < 0) {
      throw const RepositoryException('Grand total cannot be negative');
    }
    if (sale.paidAmount > grandTotal) {
      throw const RepositoryException('Paid amount cannot exceed grand total');
    }
    final balanceDue = grandTotal - sale.paidAmount;
    final paymentStatus =
        balanceDue == 0 ? 'paid' : (sale.paidAmount > 0 ? 'partial' : 'unpaid');

    return database.transaction(() async {
      final now = DateTime.now();
      final saleId =
          sale.id.isEmpty ? db.newUuid() : sale.id;
      final invoiceNo = sale.invoiceNo.isEmpty
          ? await database.nextDocumentNumber(
              branchId: sale.branchId,
              name: 'sale_invoice',
              prefix: 'INV',
            )
          : sale.invoiceNo;

      // Validate every line BEFORE writing anything.
      for (final item in sale.items) {
        if (item.quantity <= 0) {
          throw const RepositoryException('Quantity must be at least 1');
        }
        if (item.unitPrice < 0 || item.total < 0) {
          throw const RepositoryException('Prices cannot be negative');
        }
        if (item.imeiItemId != null) {
          final row = await (database.select(database.imeiItems)
                ..where((t) => t.id.equals(item.imeiItemId!)))
              .getSingleOrNull();
          if (row == null) {
            throw RepositoryException(
                'IMEI item ${item.imeiItemId} not found');
          }
          final imeiItem = ImeiItem(
            id: row.id,
            productId: row.productId,
            variantId: row.variantId,
            imei1: row.imei1,
            imei2: row.imei2,
            status: row.status,
            purchasePrice: row.purchasePrice,
            salePrice: row.salePrice,
            soldSaleId: row.soldSaleId,
            createdAt: row.createdAt,
            updatedAt: row.updatedAt,
          );
          if (!canSellImei(imeiItem)) {
            throw RepositoryException(
                'IMEI ${imeiItem.imei1} is not available '
                '(status: ${imeiItem.status}) and cannot be sold');
          }
        }
        if (item.variantId != null) {
          final variant = await (database.select(database.productVariants)
                ..where((t) => t.id.equals(item.variantId!)))
              .getSingleOrNull();
          if (variant == null) {
            throw RepositoryException(
                'Variant ${item.variantId} not found');
          }
          if (minPriceCheck(item.unitPrice, variant.minPrice) &&
              (adminApprovedBy == null || adminApprovedBy.isEmpty)) {
            throw RepositoryException(
                'Price Rs ${item.unitPrice} for ${item.nameSnapshot} is '
                'below the minimum price Rs ${variant.minPrice}. '
                'Admin approval is required.');
          }
          if (item.imeiItemId == null &&
              variant.quantity < item.quantity) {
            throw RepositoryException(
                'Not enough stock for ${item.nameSnapshot} '
                '(have ${variant.quantity}, need ${item.quantity})');
          }
        }
      }

      // Sale header.
      await database.into(database.sales).insert(
            db.SalesCompanion.insert(
              id: saleId,
              invoiceNo: invoiceNo,
              branchId: Value(sale.branchId),
              customerId: Value(sale.customerId),
              customerName: Value(sale.customerName),
              customerPhone: Value(sale.customerPhone),
              userId: sale.userId,
              saleDate: Value(sale.saleDate),
              subtotal: Value(subtotal),
              discountAmount: Value(sale.discountAmount),
              discountPercent: Value(sale.discountPercent),
              taxAmount: Value(sale.taxAmount),
              grandTotal: Value(grandTotal),
              paidAmount: Value(sale.paidAmount),
              balanceDue: Value(balanceDue),
              paymentMethod: Value(sale.paymentMethod),
              paymentStatus: Value(paymentStatus),
              status: Value(sale.status),
              notes: Value(sale.notes),
              clientUuid: Value(sale.clientUuid ?? db.newUuid()),
              createdAt: Value(now),
              updatedAt: Value(now),
            ),
          );

      // Lines + stock effects.
      final savedItems = <SaleItem>[];
      for (final item in sale.items) {
        final itemId = item.id.isEmpty ? db.newUuid() : item.id;
        final profit =
            item.total - (item.purchaseCost * item.quantity);
        await database.into(database.saleItems).insert(
              db.SaleItemsCompanion.insert(
                id: itemId,
                saleId: saleId,
                productId: Value(item.productId),
                variantId: Value(item.variantId),
                imeiItemId: Value(item.imeiItemId),
                nameSnapshot: item.nameSnapshot,
                quantity: Value(item.quantity),
                unitPrice: item.unitPrice,
                purchaseCost: Value(item.purchaseCost),
                discount: Value(item.discount),
                total: item.total,
                profit: Value(profit),
                createdAt: Value(now),
              ),
            );
        savedItems.add(item.copyWith(
            id: itemId, saleId: saleId, profit: profit, createdAt: now));
        if (item.imeiItemId != null) {
          await (database.update(database.imeiItems)
                ..where((t) => t.id.equals(item.imeiItemId!)))
              .write(db.ImeiItemsCompanion(
                status: const Value('sold'),
                soldSaleId: Value(saleId),
                updatedAt: Value(now),
              ));
        } else if (item.variantId != null) {
          await database.customStatement(
            'UPDATE product_variants SET quantity = quantity - ?, '
            'updated_at = ? WHERE id = ?',
            [item.quantity, now.millisecondsSinceEpoch, item.variantId],
          );
        }
      }

      // Payment row for money received now.
      if (sale.paidAmount > 0) {
        await database.into(database.payments).insert(
              db.PaymentsCompanion.insert(
                id: db.newUuid(),
                paymentType: 'sale',
                saleId: Value(saleId),
                customerId: Value(sale.customerId),
                method: Value(sale.paymentMethod),
                amount: sale.paidAmount,
                paymentDate: Value(now),
                userId: sale.userId,
                clientUuid: Value(db.newUuid()),
                createdAt: Value(now),
              ),
            );
      }

      // Customer ledger (udhaar) + loyalty points.
      if (sale.customerId != null) {
        await _customerLedger(
          customerId: sale.customerId!,
          referenceType: 'sale',
          referenceId: saleId,
          debit: grandTotal,
          credit: sale.paidAmount,
          userId: userId,
          notes: 'Sale $invoiceNo',
        );
        final points = loyaltyPointsForSpend(grandTotal);
        if (points > 0) {
          await database.customStatement(
            'UPDATE customers SET loyalty_points = loyalty_points + ? '
            'WHERE id = ?',
            [points, sale.customerId],
          );
        }
      }

      // Cash register (cash sales only).
      if (sale.paidAmount > 0 && sale.paymentMethod == 'cash') {
        await _cashMovement(
          branchId: sale.branchId,
          type: 'in',
          amount: sale.paidAmount,
          reason: 'Sale $invoiceNo',
          userId: sale.userId,
        );
      }

      final saved = sale.copyWith(
        id: saleId,
        invoiceNo: invoiceNo,
        subtotal: subtotal,
        grandTotal: grandTotal,
        paidAmount: sale.paidAmount,
        balanceDue: balanceDue,
        paymentStatus: paymentStatus,
        items: savedItems,
        createdAt: now,
        updatedAt: now,
        adminApprovedBy: adminApprovedBy,
      );
      await database.writeAudit(
        userId: userId,
        action: 'create',
        entityType: 'sale',
        entityId: saleId,
        newValues: {
          ...saved.toJson(),
          'admin_approved_by': adminApprovedBy,
        },
      );
      await database.enqueueOutbox(
        tableName: 'sales',
        operation: 'insert',
        payload: saved.toJson(),
      );
      return saved;
    });
  }

  // -- Reads -----------------------------------------------------------------

  @override
  Future<Sale?> getSale(String id) async {
    final row = await (database.select(database.sales)
          ..where((t) => t.id.equals(id)))
        .getSingleOrNull();
    if (row == null) return null;
    return _sale(row, await _itemsOf(id));
  }

  @override
  Future<List<Sale>> listSales({
    DateTime? from,
    DateTime? to,
    String? customerId,
    String? status,
    int limit = 100,
    int offset = 0,
  }) async {
    final query = database.select(database.sales);
    if (from != null) query.where((t) => t.saleDate.isBiggerOrEqualValue(from));
    if (to != null) query.where((t) => t.saleDate.isSmallerOrEqualValue(to));
    if (customerId != null) {
      query.where((t) => t.customerId.equals(customerId));
    }
    if (status != null) query.where((t) => t.status.equals(status));
    query.orderBy([(t) => OrderingTerm.desc(t.saleDate)]);
    query.limit(limit, offset: offset);
    final rows = await query.get();
    final result = <Sale>[];
    for (final row in rows) {
      result.add(_sale(row, await _itemsOf(row.id)));
    }
    return result;
  }

  // -- Payments --------------------------------------------------------------

  @override
  Future<Payment> recordPayment({
    required String saleId,
    required int amount,
    required String method,
    String? reference,
    required String userId,
    String? customerId,
    String? notes,
  }) async {
    if (amount <= 0) {
      throw const RepositoryException('Payment amount must be greater than 0');
    }
    return database.transaction(() async {
      final saleRow = await (database.select(database.sales)
            ..where((t) => t.id.equals(saleId)))
          .getSingleOrNull();
      if (saleRow == null) {
        throw RepositoryException('Sale $saleId not found');
      }
      if (amount > saleRow.balanceDue) {
        throw RepositoryException(
            'Payment Rs $amount exceeds the due amount '
            'Rs ${saleRow.balanceDue}');
      }
      final now = DateTime.now();
      final payment = Payment(
        id: db.newUuid(),
        paymentType: 'sale',
        saleId: saleId,
        customerId: customerId ?? saleRow.customerId,
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
              paymentType: 'sale',
              saleId: Value(saleId),
              customerId: Value(payment.customerId),
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
      final newPaid = saleRow.paidAmount + amount;
      final newDue = saleRow.balanceDue - amount;
      final newStatus =
          newDue == 0 ? 'paid' : 'partial';
      await (database.update(database.sales)
            ..where((t) => t.id.equals(saleId)))
          .write(db.SalesCompanion(
            paidAmount: Value(newPaid),
            balanceDue: Value(newDue),
            paymentStatus: Value(newStatus),
            updatedAt: Value(now),
          ));
      final effectiveCustomer = payment.customerId;
      if (effectiveCustomer != null) {
        await _customerLedger(
          customerId: effectiveCustomer,
          referenceType: 'payment',
          referenceId: payment.id,
          debit: 0,
          credit: amount,
          userId: userId,
          notes: notes ?? 'Payment for ${saleRow.invoiceNo}',
        );
      }
      if (method == 'cash') {
        await _cashMovement(
          branchId: saleRow.branchId,
          type: 'in',
          amount: amount,
          reason: 'Payment ${saleRow.invoiceNo}',
          userId: userId,
        );
      }
      await database.writeAudit(
        userId: userId,
        action: 'payment',
        entityType: 'sale',
        entityId: saleId,
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

  // -- Returns / cancel ------------------------------------------------------

  @override
  Future<Sale> returnSale({
    required String saleId,
    required String saleItemId,
    int quantity = 1,
    String? reason,
    required String userId,
    bool isExchange = false,
    String? exchangeSaleId,
  }) async {
    if (quantity <= 0) {
      throw const RepositoryException('Return quantity must be at least 1');
    }
    return database.transaction(() async {
      final saleRow = await (database.select(database.sales)
            ..where((t) => t.id.equals(saleId)))
          .getSingleOrNull();
      if (saleRow == null) {
        throw RepositoryException('Sale $saleId not found');
      }
      if (saleRow.status == 'cancelled') {
        throw const RepositoryException('Cannot return items of a cancelled sale');
      }
      final itemRow = await (database.select(database.saleItems)
            ..where((t) => t.id.equals(saleItemId)))
          .getSingleOrNull();
      if (itemRow == null || itemRow.saleId != saleId) {
        throw RepositoryException('Sale item $saleItemId not found');
      }
      // A line can only be returned as many times as it was sold: count
      // what was already returned for this line (the backend enforces
      // the same cap — without it a second full return double-refunds).
      final alreadyReturnedRow = await database.customSelect(
        'SELECT COALESCE(SUM(quantity), 0) AS q FROM sale_returns '
        'WHERE sale_item_id = ?',
        variables: [Variable.withString(saleItemId)],
      ).getSingle();
      final remaining =
          itemRow.quantity - alreadyReturnedRow.read<int>('q');
      if (quantity > remaining) {
        throw RepositoryException(
            'Cannot return $quantity; only $remaining left to return');
      }
      final now = DateTime.now();
      final refundAmount =
          (itemRow.unitPrice * quantity) - (itemRow.discount * quantity ~/ itemRow.quantity);
      final returnRow = SaleReturn(
        id: db.newUuid(),
        saleId: saleId,
        saleItemId: saleItemId,
        imeiItemId: itemRow.imeiItemId,
        quantity: quantity,
        reason: reason,
        refundAmount: refundAmount,
        isExchange: isExchange,
        exchangeSaleId: exchangeSaleId,
        userId: userId,
        createdAt: now,
      );
      await database.into(database.saleReturns).insert(
            db.SaleReturnsCompanion.insert(
              id: returnRow.id,
              saleId: saleId,
              saleItemId: Value(saleItemId),
              imeiItemId: Value(itemRow.imeiItemId),
              quantity: Value(quantity),
              reason: Value(reason),
              refundAmount: Value(refundAmount),
              isExchange: Value(isExchange),
              exchangeSaleId: Value(exchangeSaleId),
              userId: userId,
              createdAt: Value(now),
            ),
          );
      // Restore IMEI / accessory stock.
      if (itemRow.imeiItemId != null) {
        await (database.update(database.imeiItems)
              ..where((t) => t.id.equals(itemRow.imeiItemId!)))
            .write(db.ImeiItemsCompanion(
              status: const Value('available'),
              soldSaleId: const Value(null),
              updatedAt: Value(now),
            ));
      } else if (itemRow.variantId != null) {
        await database.customStatement(
          'UPDATE product_variants SET quantity = quantity + ?, '
          'updated_at = ? WHERE id = ?',
          [quantity, now.millisecondsSinceEpoch, itemRow.variantId],
        );
      }
      // The returned goods are no longer profit: shrink the line's
      // profit pro-rata, so reports (which sum sale_items.profit for
      // non-cancelled sales) stop counting returned goods. Mirrors the
      // backend's applyReturn.
      final profitReduction =
          (itemRow.profit * quantity / itemRow.quantity).round();
      if (profitReduction != 0) {
        await database.customStatement(
          'UPDATE sale_items SET profit = MAX(0, profit - ?) WHERE id = ?',
          [profitReduction, saleItemId],
        );
      }
      // Adjust the bill: refund comes out of what was paid first.
      final newGrandTotal = saleRow.grandTotal - refundAmount;
      final newPaidRaw = saleRow.paidAmount - refundAmount;
      final newPaid = newPaidRaw < 0 ? 0 : newPaidRaw;
      final newDueRaw = newGrandTotal - newPaid;
      final newDue = newDueRaw < 0 ? 0 : newDueRaw;
      // Is the whole bill returned now?
      final returnedQty = await database.customSelect(
        'SELECT COALESCE(SUM(quantity), 0) AS q FROM sale_returns '
        'WHERE sale_id = ?',
        variables: [Variable.withString(saleId)],
      ).getSingle();
      final totalQty = await database.customSelect(
        'SELECT COALESCE(SUM(quantity), 0) AS q FROM sale_items '
        'WHERE sale_id = ?',
        variables: [Variable.withString(saleId)],
      ).getSingle();
      final fullyReturned =
          returnedQty.read<int>('q') >= totalQty.read<int>('q');
      final newSaleStatus =
          fullyReturned ? 'returned' : 'partially_returned';
      await (database.update(database.sales)
            ..where((t) => t.id.equals(saleId)))
          .write(db.SalesCompanion(
            grandTotal: Value(newGrandTotal),
            paidAmount: Value(newPaid),
            balanceDue: Value(newDue),
            paymentStatus: Value(newDue == 0 ? 'paid' : 'partial'),
            status: Value(newSaleStatus),
            updatedAt: Value(now),
          ));
      // Split the refund like the backend: the part that was paid is
      // cash out of the register; only the part that was still owed is
      // credited to the customer ledger. Crediting the full refund
      // overstated what the shop owes the customer — a fully returned
      // partial bill ended at -paid instead of 0.
      final refundFromPaid = refundAmount < saleRow.paidAmount
          ? refundAmount
          : saleRow.paidAmount;
      final refundFromBalance = refundAmount - refundFromPaid;
      if (saleRow.customerId != null && refundFromBalance > 0) {
        await _customerLedger(
          customerId: saleRow.customerId!,
          referenceType: 'return',
          referenceId: returnRow.id,
          debit: 0,
          credit: refundFromBalance,
          userId: userId,
          notes: reason ?? 'Return on ${saleRow.invoiceNo}',
        );
      }
      if (saleRow.paymentMethod == 'cash' && refundAmount > 0) {
        await _cashMovement(
          branchId: saleRow.branchId,
          type: 'out',
          amount: refundAmount,
          reason: 'Refund ${saleRow.invoiceNo}',
          userId: userId,
        );
      }
      await database.writeAudit(
        userId: userId,
        action: 'return',
        entityType: 'sale',
        entityId: saleId,
        newValues: returnRow.toJson(),
      );
      await database.enqueueOutbox(
        tableName: 'sale_returns',
        operation: 'insert',
        payload: returnRow.toJson(),
      );
      final updated = await getSale(saleId);
      return updated!;
    });
  }

  @override
  Future<List<SaleReturn>> listSaleReturns(String saleId) async {
    final rows = await (database.select(database.saleReturns)
          ..where((t) => t.saleId.equals(saleId))
          ..orderBy([(t) => OrderingTerm.desc(t.createdAt)]))
        .get();
    return rows.map(_saleReturn).toList();
  }

  // -- Held bills ------------------------------------------------------------

  @override
  Future<HeldBill> holdBill(HeldBill bill, {String? userId}) async {
    final now = DateTime.now();
    final saved = bill.copyWith(
      id: bill.id.isEmpty ? db.newUuid() : bill.id,
      createdAt: now,
    );
    await database.transaction(() async {
      await database.into(database.heldBills).insert(
            db.HeldBillsCompanion.insert(
              id: saved.id,
              branchId: Value(saved.branchId),
              userId: saved.userId,
              customerName: Value(saved.customerName),
              cart: Value(_cartJson(saved)),
              createdAt: Value(now),
            ),
          );
      await database.writeAudit(
        userId: userId,
        action: 'hold',
        entityType: 'held_bill',
        entityId: saved.id,
        newValues: saved.toJson(),
      );
    });
    return saved;
  }

  String _cartJson(HeldBill bill) => jsonEncode(bill.cart);

  @override
  Future<HeldBill?> resumeBill(String heldBillId, {String? userId}) async {
    return database.transaction(() async {
      final row = await (database.select(database.heldBills)
            ..where((t) => t.id.equals(heldBillId)))
          .getSingleOrNull();
      if (row == null) return null;
      final cart = _decodeCart(row.cart);
      final bill = HeldBill(
        id: row.id,
        branchId: row.branchId,
        userId: row.userId,
        customerName: row.customerName,
        cart: cart,
        createdAt: row.createdAt,
      );
      await (database.delete(database.heldBills)
            ..where((t) => t.id.equals(heldBillId)))
          .go();
      await database.writeAudit(
        userId: userId,
        action: 'resume',
        entityType: 'held_bill',
        entityId: heldBillId,
      );
      return bill;
    });
  }

  List<Map<String, dynamic>> _decodeCart(String raw) {
    final decoded = jsonDecode(raw);
    if (decoded is! List) return const [];
    return decoded
        .map((e) => (e as Map).cast<String, dynamic>())
        .toList();
  }

  @override
  Future<List<HeldBill>> listHeldBills({String? branchId}) async {
    final query = database.select(database.heldBills);
    if (branchId != null) {
      query.where((t) => t.branchId.equals(branchId));
    }
    query.orderBy([(t) => OrderingTerm.desc(t.createdAt)]);
    final rows = await query.get();
    return rows
        .map((r) => HeldBill(
              id: r.id,
              branchId: r.branchId,
              userId: r.userId,
              customerName: r.customerName,
              cart: _decodeCart(r.cart),
              createdAt: r.createdAt,
            ))
        .toList();
  }

  @override
  Future<void> deleteHeldBill(String id, {String? userId}) async {
    await database.transaction(() async {
      await (database.delete(database.heldBills)
            ..where((t) => t.id.equals(id)))
          .go();
      await database.writeAudit(
        userId: userId,
        action: 'delete',
        entityType: 'held_bill',
        entityId: id,
      );
    });
  }

  // -- Cancel ----------------------------------------------------------------

  @override
  Future<Sale> cancelSale(String saleId,
      {required String userId, String? reason}) async {
    return database.transaction(() async {
      final saleRow = await (database.select(database.sales)
            ..where((t) => t.id.equals(saleId)))
          .getSingleOrNull();
      if (saleRow == null) {
        throw RepositoryException('Sale $saleId not found');
      }
      if (saleRow.status == 'cancelled') {
        throw const RepositoryException('Sale is already cancelled');
      }
      if (saleRow.status == 'returned') {
        throw const RepositoryException('A fully returned sale cannot be cancelled');
      }
      final now = DateTime.now();
      final items = await _itemsOf(saleId);
      for (final item in items) {
        if (item.imeiItemId != null) {
          await (database.update(database.imeiItems)
                ..where((t) => t.id.equals(item.imeiItemId!)))
              .write(db.ImeiItemsCompanion(
                status: const Value('available'),
                soldSaleId: const Value(null),
                updatedAt: Value(now),
              ));
        } else if (item.variantId != null) {
          await database.customStatement(
            'UPDATE product_variants SET quantity = quantity + ?, '
            'updated_at = ? WHERE id = ?',
            [item.quantity, now.millisecondsSinceEpoch, item.variantId],
          );
        }
      }
      if (saleRow.customerId != null && saleRow.balanceDue > 0) {
        await _customerLedger(
          customerId: saleRow.customerId!,
          referenceType: 'return',
          referenceId: saleId,
          debit: 0,
          credit: saleRow.balanceDue,
          userId: userId,
          notes: reason ?? 'Sale ${saleRow.invoiceNo} cancelled',
        );
      }
      await (database.update(database.sales)
            ..where((t) => t.id.equals(saleId)))
          .write(db.SalesCompanion(
            status: const Value('cancelled'),
            notes: Value(reason),
            updatedAt: Value(now),
          ));
      await database.writeAudit(
        userId: userId,
        action: 'cancel',
        entityType: 'sale',
        entityId: saleId,
        oldValues: {'status': saleRow.status},
        newValues: {'status': 'cancelled', 'reason': reason},
      );
      await database.enqueueOutbox(
        tableName: 'sales',
        operation: 'update',
        payload: {'id': saleId, 'status': 'cancelled'},
      );
      final updated = await getSale(saleId);
      return updated!;
    });
  }
}
