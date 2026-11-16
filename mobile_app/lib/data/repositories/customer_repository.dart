/// Customer repository: customers, their running-balance ledger,
/// udhaar recovery payments and installment plans.
///
/// Ledger convention (see LedgerEntry): customer balance =
/// prev + debit - credit (amount the customer owes the shop).
/// Money is integer whole PKR. Every mutation writes an audit row and
/// queues an outbox row.
library;

import 'package:drift/drift.dart';

import '../../domain/models/customer.dart';
import '../../domain/models/installment.dart';
import '../../domain/models/ledger_entry.dart';
import '../../domain/models/sale.dart' show Payment;
import '../../domain/rules.dart';
import '../database/app_database.dart' as db;
import 'product_repository.dart' show RepositoryException;

abstract class CustomerRepository {
  Future<Customer?> getCustomer(String id);
  Future<Customer?> getCustomerByPhone(String phone);
  Future<List<Customer>> listCustomers({
    String? search,
    bool onlyActive = true,
    int limit = 100,
    int offset = 0,
  });
  Future<Customer> createCustomer(Customer customer, {String? userId});
  Future<Customer> updateCustomer(Customer customer, {String? userId});
  Future<void> deleteCustomer(String id, {String? userId});

  /// Ledger entries for a customer, newest first.
  Future<List<LedgerEntry>> ledger(
    String customerId, {
    DateTime? from,
    DateTime? to,
    int limit = 200,
  });

  /// Current udhaar balance (amount the customer owes).
  Future<int> runningBalance(String customerId);

  /// Records an udhaar-recovery payment: payment row + ledger credit.
  Future<Payment> recordUdhaarPayment({
    required String customerId,
    required int amount,
    required String method,
    String? reference,
    required String userId,
    String? notes,
  });

  /// Creates an installment plan for a sale and generates its due rows
  /// (see `installmentSchedule` in domain/rules.dart).
  Future<Installment> createInstallment({
    required String saleId,
    required String customerId,
    required int totalAmount,
    required int downPayment,
    required int count,
    required DateTime startDate,
    String? userId,
  });

  Future<Installment?> getInstallment(String id);
  Future<List<Installment>> listInstallments(String customerId);
  Future<List<InstallmentPayment>> overdueInstallments();
  Future<InstallmentPayment> recordInstallmentPayment({
    required String installmentPaymentId,
    required int amount,
    required String method,
    String? reference,
    required String userId,
  });

  Future<int> loyaltyPoints(String customerId);
  Future<int> walletBalance(String customerId);
}

class DriftCustomerRepository implements CustomerRepository {
  final db.AppDatabase database;

  DriftCustomerRepository(this.database);

  Customer _customer(db.Customer row, [int currentBalance = 0]) => Customer(
        id: row.id,
        name: row.name,
        phone: row.phone,
        cnic: row.cnic,
        address: row.address,
        openingBalance: row.openingBalance,
        loyaltyPoints: row.loyaltyPoints,
        walletBalance: row.walletBalance,
        isActive: row.isActive,
        createdAt: row.createdAt,
        updatedAt: row.updatedAt,
        currentBalance: currentBalance,
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

  InstallmentPayment _instPayment(db.InstallmentPayment row) =>
      InstallmentPayment(
        id: row.id,
        installmentId: row.installmentId,
        dueDate: row.dueDate,
        amount: row.amount,
        paidAmount: row.paidAmount,
        paidDate: row.paidDate,
        status: row.status,
        reminderSent: row.reminderSent,
        createdAt: row.createdAt,
        updatedAt: row.updatedAt,
      );

  /// Current udhaar balance (amount the customer owes).
  ///
  /// Computed as SUM(debit - credit) over the customer's ledger rows,
  /// not from the "latest" row: two entries written in the same
  /// millisecond share an entryDate, so ORDER BY entryDate DESC LIMIT 1
  /// could return the older one (a sale + immediate return once read
  /// 24000 instead of 0). The opening entry (written at creation when
  /// the opening balance is non-zero) is already a ledger row, so the
  /// sum includes it; the opening-balance fallback only applies when
  /// there are no rows at all.
  Future<int> _balance(String customerId) async {
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

  Future<void> _ledgerCredit({
    required String customerId,
    required String referenceType,
    required String referenceId,
    required int amount,
    String? userId,
    String? notes,
  }) async {
    final prev = await _balance(customerId);
    await database.into(database.ledgerEntries).insert(
          db.LedgerEntriesCompanion.insert(
            id: db.newUuid(),
            side: 'customer',
            customerId: Value(customerId),
            referenceType: referenceType,
            referenceId: Value(referenceId),
            debit: const Value(0),
            credit: Value(amount),
            balanceAfter: Value(prev - amount),
            entryDate: Value(DateTime.now()),
            userId: Value(userId),
            notes: Value(notes),
          ),
        );
  }

  // -- Customers -------------------------------------------------------------

  @override
  Future<Customer?> getCustomer(String id) async {
    final row = await (database.select(database.customers)
          ..where((t) => t.id.equals(id)))
        .getSingleOrNull();
    if (row == null) return null;
    return _customer(row, await _balance(id));
  }

  @override
  Future<Customer?> getCustomerByPhone(String phone) async {
    final row = await (database.select(database.customers)
          ..where((t) => t.phone.equals(phone)))
        .getSingleOrNull();
    if (row == null) return null;
    return _customer(row, await _balance(row.id));
  }

  @override
  Future<List<Customer>> listCustomers({
    String? search,
    bool onlyActive = true,
    int limit = 100,
    int offset = 0,
  }) async {
    final query = database.select(database.customers);
    if (onlyActive) query.where((t) => t.isActive.equals(true));
    if (search != null && search.trim().isNotEmpty) {
      final q = '%${search.trim()}%';
      // cnic is nullable: LIKE on it is not type-safe, use equals.
      query.where((t) =>
          t.name.like(q) | t.phone.like(q) | t.cnic.equals(search.trim()));
    }
    query.orderBy([(t) => OrderingTerm.asc(t.name)]);
    query.limit(limit, offset: offset);
    final rows = await query.get();
    final result = <Customer>[];
    for (final row in rows) {
      result.add(_customer(row, await _balance(row.id)));
    }
    return result;
  }

  @override
  Future<Customer> createCustomer(Customer customer, {String? userId}) async {
    final now = DateTime.now();
    final created = customer.copyWith(
      id: customer.id.isEmpty ? db.newUuid() : customer.id,
      createdAt: now,
      updatedAt: now,
    );
    await database.transaction(() async {
      await database.into(database.customers).insert(
            db.CustomersCompanion.insert(
              id: created.id,
              name: created.name,
              phone: created.phone,
              cnic: Value(created.cnic),
              address: Value(created.address),
              openingBalance: Value(created.openingBalance),
              loyaltyPoints: Value(created.loyaltyPoints),
              walletBalance: Value(created.walletBalance),
              isActive: Value(created.isActive),
              createdAt: Value(now),
              updatedAt: Value(now),
            ),
          );
      if (created.openingBalance != 0) {
        await database.into(database.ledgerEntries).insert(
              db.LedgerEntriesCompanion.insert(
                id: db.newUuid(),
                side: 'customer',
                customerId: Value(created.id),
                referenceType: 'opening',
                debit: Value(
                    created.openingBalance > 0 ? created.openingBalance : 0),
                credit: Value(
                    created.openingBalance < 0 ? -created.openingBalance : 0),
                balanceAfter: Value(created.openingBalance),
                entryDate: Value(now),
                userId: Value(userId),
              ),
            );
      }
      await database.writeAudit(
        userId: userId,
        action: 'create',
        entityType: 'customer',
        entityId: created.id,
        newValues: created.toJson(),
      );
      await database.enqueueOutbox(
        tableName: 'customers',
        operation: 'insert',
        payload: created.toJson(),
      );
    });
    return created;
  }

  @override
  Future<Customer> updateCustomer(Customer customer, {String? userId}) async {
    final existing = await getCustomer(customer.id);
    if (existing == null) {
      throw RepositoryException('Customer ${customer.id} not found');
    }
    final updated = customer.copyWith(updatedAt: DateTime.now());
    await database.transaction(() async {
      await (database.update(database.customers)
            ..where((t) => t.id.equals(customer.id)))
          .write(db.CustomersCompanion(
            name: Value(updated.name),
            phone: Value(updated.phone),
            cnic: Value(updated.cnic),
            address: Value(updated.address),
            openingBalance: Value(updated.openingBalance),
            loyaltyPoints: Value(updated.loyaltyPoints),
            walletBalance: Value(updated.walletBalance),
            isActive: Value(updated.isActive),
            updatedAt: Value(updated.updatedAt),
          ));
      await database.writeAudit(
        userId: userId,
        action: 'update',
        entityType: 'customer',
        entityId: updated.id,
        oldValues: existing.toJson(),
        newValues: updated.toJson(),
      );
      await database.enqueueOutbox(
        tableName: 'customers',
        operation: 'update',
        payload: updated.toJson(),
      );
    });
    return updated;
  }

  @override
  Future<void> deleteCustomer(String id, {String? userId}) async {
    final existing = await getCustomer(id);
    if (existing == null) {
      throw RepositoryException('Customer $id not found');
    }
    await database.transaction(() async {
      await (database.update(database.customers)
            ..where((t) => t.id.equals(id)))
          .write(db.CustomersCompanion(
            isActive: const Value(false),
            updatedAt: Value(DateTime.now()),
          ));
      await database.writeAudit(
        userId: userId,
        action: 'delete',
        entityType: 'customer',
        entityId: id,
        newValues: {'id': id, 'is_active': false},
      );
      await database.enqueueOutbox(
        tableName: 'customers',
        operation: 'update',
        payload: {'id': id, 'is_active': false},
      );
    });
  }

  // -- Ledger ----------------------------------------------------------------

  @override
  Future<List<LedgerEntry>> ledger(
    String customerId, {
    DateTime? from,
    DateTime? to,
    int limit = 200,
  }) async {
    final query = database.select(database.ledgerEntries);
    query.where((t) =>
        t.side.equals('customer') & t.customerId.equals(customerId));
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

  @override
  Future<int> runningBalance(String customerId) => _balance(customerId);

  @override
  Future<Payment> recordUdhaarPayment({
    required String customerId,
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
      final customer = await getCustomer(customerId);
      if (customer == null) {
        throw RepositoryException('Customer $customerId not found');
      }
      final now = DateTime.now();
      final payment = Payment(
        id: db.newUuid(),
        paymentType: 'udhaar_recovery',
        customerId: customerId,
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
              paymentType: 'udhaar_recovery',
              customerId: Value(customerId),
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
      await _ledgerCredit(
        customerId: customerId,
        referenceType: 'payment',
        referenceId: payment.id,
        amount: amount,
        userId: userId,
        notes: notes ?? 'Udhaar recovery',
      );
      await database.writeAudit(
        userId: userId,
        action: 'payment',
        entityType: 'customer',
        entityId: customerId,
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

  // -- Installments ----------------------------------------------------------

  @override
  Future<Installment> createInstallment({
    required String saleId,
    required String customerId,
    required int totalAmount,
    required int downPayment,
    required int count,
    required DateTime startDate,
    String? userId,
  }) async {
    final schedule =
        installmentSchedule(totalAmount, downPayment, count, startDate);
    if (schedule.isEmpty) {
      throw const RepositoryException(
          'Down payment covers the full amount; nothing to install');
    }
    final now = DateTime.now();
    final installmentAmount =
        schedule.isEmpty ? 0 : schedule.first['amount'] as int;
    return database.transaction(() async {
      final installment = Installment(
        id: db.newUuid(),
        saleId: saleId,
        customerId: customerId,
        totalAmount: totalAmount,
        downPayment: downPayment,
        installmentCount: count,
        installmentAmount: installmentAmount,
        startDate: startDate,
        createdAt: now,
        updatedAt: now,
      );
      await database.into(database.installments).insert(
            db.InstallmentsCompanion.insert(
              id: installment.id,
              saleId: saleId,
              customerId: customerId,
              totalAmount: totalAmount,
              downPayment: Value(downPayment),
              installmentCount: count,
              installmentAmount: installmentAmount,
              startDate: startDate,
              createdAt: Value(now),
              updatedAt: Value(now),
            ),
          );
      final payments = <InstallmentPayment>[];
      for (final row in schedule) {
        final paymentRow = InstallmentPayment(
          id: db.newUuid(),
          installmentId: installment.id,
          dueDate: row['dueDate'] as DateTime,
          amount: row['amount'] as int,
          createdAt: now,
          updatedAt: now,
        );
        await database.into(database.installmentPayments).insert(
              db.InstallmentPaymentsCompanion.insert(
                id: paymentRow.id,
                installmentId: installment.id,
                dueDate: paymentRow.dueDate,
                amount: paymentRow.amount,
                createdAt: Value(now),
                updatedAt: Value(now),
              ),
            );
        payments.add(paymentRow);
      }
      await database.writeAudit(
        userId: userId,
        action: 'create',
        entityType: 'installment',
        entityId: installment.id,
        newValues: installment.copyWith(payments: payments).toJson(),
      );
      await database.enqueueOutbox(
        tableName: 'installments',
        operation: 'insert',
        payload: installment.copyWith(payments: payments).toJson(),
      );
      return installment.copyWith(payments: payments);
    });
  }

  Future<List<InstallmentPayment>> _paymentsOf(String installmentId) async {
    final rows = await (database.select(database.installmentPayments)
          ..where((t) => t.installmentId.equals(installmentId))
          ..orderBy([(t) => OrderingTerm.asc(t.dueDate)]))
        .get();
    return rows.map(_instPayment).toList();
  }

  @override
  Future<Installment?> getInstallment(String id) async {
    final row = await (database.select(database.installments)
          ..where((t) => t.id.equals(id)))
        .getSingleOrNull();
    if (row == null) return null;
    return Installment(
      id: row.id,
      saleId: row.saleId,
      customerId: row.customerId,
      totalAmount: row.totalAmount,
      downPayment: row.downPayment,
      installmentCount: row.installmentCount,
      installmentAmount: row.installmentAmount,
      startDate: row.startDate,
      status: row.status,
      createdAt: row.createdAt,
      updatedAt: row.updatedAt,
      payments: await _paymentsOf(id),
    );
  }

  @override
  Future<List<Installment>> listInstallments(String customerId) async {
    final rows = await (database.select(database.installments)
          ..where((t) => t.customerId.equals(customerId))
          ..orderBy([(t) => OrderingTerm.desc(t.createdAt)]))
        .get();
    final result = <Installment>[];
    for (final row in rows) {
      result.add(Installment(
        id: row.id,
        saleId: row.saleId,
        customerId: row.customerId,
        totalAmount: row.totalAmount,
        downPayment: row.downPayment,
        installmentCount: row.installmentCount,
        installmentAmount: row.installmentAmount,
        startDate: row.startDate,
        status: row.status,
        createdAt: row.createdAt,
        updatedAt: row.updatedAt,
        payments: await _paymentsOf(row.id),
      ));
    }
    return result;
  }

  @override
  Future<List<InstallmentPayment>> overdueInstallments() async {
    return database.transaction(() async {
      final today = DateTime.now();
      final todayStart = DateTime(today.year, today.month, today.day);
      // Mark newly-overdue rows, then list all overdue rows.
      await database.customStatement(
        "UPDATE installment_payments SET status = 'overdue', "
        'updated_at = ? WHERE due_date < ? AND status IN '
        "('pending', 'partial')",
        [today.millisecondsSinceEpoch, todayStart.millisecondsSinceEpoch],
      );
      final rows = await (database.select(database.installmentPayments)
            ..where((t) => t.status.equals('overdue'))
            ..orderBy([(t) => OrderingTerm.asc(t.dueDate)]))
          .get();
      return rows.map(_instPayment).toList();
    });
  }

  @override
  Future<InstallmentPayment> recordInstallmentPayment({
    required String installmentPaymentId,
    required int amount,
    required String method,
    String? reference,
    required String userId,
  }) async {
    if (amount <= 0) {
      throw const RepositoryException('Payment amount must be greater than 0');
    }
    return database.transaction(() async {
      final row = await (database.select(database.installmentPayments)
            ..where((t) => t.id.equals(installmentPaymentId)))
          .getSingleOrNull();
      if (row == null) {
        throw RepositoryException(
            'Installment payment $installmentPaymentId not found');
      }
      if (amount > row.amount - row.paidAmount) {
        throw RepositoryException(
            'Payment exceeds the remaining Rs ${row.amount - row.paidAmount}');
      }
      final now = DateTime.now();
      final newPaid = row.paidAmount + amount;
      final newStatus = newPaid >= row.amount
          ? 'paid'
          : (newPaid > 0 ? 'partial' : row.status);
      await (database.update(database.installmentPayments)
            ..where((t) => t.id.equals(installmentPaymentId)))
          .write(db.InstallmentPaymentsCompanion(
            paidAmount: Value(newPaid),
            paidDate: Value(newStatus == 'paid' ? now : row.paidDate),
            status: Value(newStatus),
            updatedAt: Value(now),
          ));
      final installment = await (database.select(database.installments)
            ..where((t) => t.id.equals(row.installmentId)))
          .getSingleOrNull();
      if (installment != null) {
        await database.into(database.payments).insert(
              db.PaymentsCompanion.insert(
                id: db.newUuid(),
                paymentType: 'installment',
                installmentId: Value(row.installmentId),
                customerId: Value(installment.customerId),
                method: Value(method),
                amount: amount,
                reference: Value(reference),
                paymentDate: Value(now),
                userId: userId,
                clientUuid: Value(db.newUuid()),
                createdAt: Value(now),
              ),
            );
        await _ledgerCredit(
          customerId: installment.customerId,
          referenceType: 'installment',
          referenceId: row.installmentId,
          amount: amount,
          userId: userId,
          notes: 'Installment payment',
        );
        // Close the plan when every row is paid.
        final remaining = await database.customSelect(
          'SELECT COUNT(*) AS c FROM installment_payments '
          "WHERE installment_id = ? AND status != 'paid'",
          variables: [Variable.withString(row.installmentId)],
        ).getSingle();
        if (remaining.read<int>('c') == 0) {
          await (database.update(database.installments)
                ..where((t) => t.id.equals(row.installmentId)))
              .write(db.InstallmentsCompanion(
                status: const Value('completed'),
                updatedAt: Value(now),
              ));
        }
      }
      await database.writeAudit(
        userId: userId,
        action: 'payment',
        entityType: 'installment_payment',
        entityId: installmentPaymentId,
        oldValues: {'paid_amount': row.paidAmount, 'status': row.status},
        newValues: {'paid_amount': newPaid, 'status': newStatus},
      );
      await database.enqueueOutbox(
        tableName: 'installment_payments',
        operation: 'update',
        payload: {
          'id': installmentPaymentId,
          'paid_amount': newPaid,
          'status': newStatus,
        },
      );
      return _instPayment(row).copyWith(
        paidAmount: newPaid,
        paidDate: newStatus == 'paid' ? now : row.paidDate,
        status: newStatus,
        updatedAt: now,
      );
    });
  }

  @override
  Future<int> loyaltyPoints(String customerId) async {
    final row = await (database.select(database.customers)
          ..where((t) => t.id.equals(customerId)))
        .getSingleOrNull();
    return row?.loyaltyPoints ?? 0;
  }

  @override
  Future<int> walletBalance(String customerId) async {
    final row = await (database.select(database.customers)
          ..where((t) => t.id.equals(customerId)))
        .getSingleOrNull();
    return row?.walletBalance ?? 0;
  }
}
