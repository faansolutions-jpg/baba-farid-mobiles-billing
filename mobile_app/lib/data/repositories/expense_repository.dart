/// Expense repository: expenses, staff + salaries, cash register
/// (open/close, movements, day summary) and service sales
/// (EasyLoad / recharge / bill payment).
///
/// Day-close math: expected cash = opening cash + cash movements in
/// - cash movements out - expenses of the day. Sale creation, sale
/// payments, installment payments and refunds all write cash movements,
/// so the register never double-counts them.
/// Money is integer whole PKR. Every mutation writes an audit row and
/// queues an outbox row.
library;

import 'package:drift/drift.dart';

import '../../domain/models/cash_register.dart';
import '../../domain/models/expense.dart';
import '../../domain/models/service_sale.dart';
import '../../domain/models/staff.dart';
import '../database/app_database.dart' as db;
import 'product_repository.dart' show RepositoryException;

/// Summary of one trading day.
class DaySummary {
  final DateTime date;
  final int totalSales;

  /// Sales paid in cash (`payment_method = 'cash'`).
  final int cashSales;

  /// Sales paid by any other method (JazzCash, EasyPaisa, bank, card…).
  /// `cashSales + otherMethodSales == totalSales` (same query scope).
  final int otherMethodSales;
  final int salesCount;
  final int totalExpenses;
  final int serviceSalesTotal;
  final int serviceCommission;
  final int cashIn;
  final int cashOut;
  final int openingCash;
  final int expectedCash;
  final int? closingCash;
  final int? difference;
  final String registerStatus;

  const DaySummary({
    required this.date,
    this.totalSales = 0,
    this.cashSales = 0,
    this.otherMethodSales = 0,
    this.salesCount = 0,
    this.totalExpenses = 0,
    this.serviceSalesTotal = 0,
    this.serviceCommission = 0,
    this.cashIn = 0,
    this.cashOut = 0,
    this.openingCash = 0,
    this.expectedCash = 0,
    this.closingCash,
    this.difference,
    this.registerStatus = 'open',
  });
}

abstract class ExpenseRepository {
  // -- Expenses --------------------------------------------------------------
  Future<Expense> createExpense(Expense expense, {String? userId});
  Future<List<Expense>> listExpenses({
    DateTime? from,
    DateTime? to,
    String? category,
    String? branchId,
    int limit = 200,
  });
  Future<Expense> updateExpense(Expense expense, {String? userId});
  Future<void> deleteExpense(String id, {String? userId});

  // -- Staff & salaries --------------------------------------------------------
  Future<Staff> createStaff(Staff staff, {String? userId});
  Future<List<Staff>> listStaff({bool onlyActive = true});
  Future<Staff> updateStaff(Staff staff, {String? userId});
  Future<SalaryPayment> paySalary(SalaryPayment payment, {String? userId});
  Future<List<SalaryPayment>> listSalaryPayments({
    String? staffId,
    String? month,
  });

  // -- Cash register -----------------------------------------------------------
  Future<CashRegister> openRegister({
    String? branchId,
    required int openingCash,
    required String openedBy,
    DateTime? date,
    String? notes,
  });
  Future<CashRegister?> getOpenRegister({String? branchId, DateTime? date});
  Future<CashRegister> closeRegister({
    required String registerId,
    required int closingCash,
    required String closedBy,
    String? notes,
  });
  Future<CashMovement> recordCashMovement({
    required String registerId,
    required String type,
    required int amount,
    String? reason,
    required String userId,
  });
  Future<List<CashMovement>> listCashMovements(String registerId);
  Future<DaySummary> daySummary({DateTime? date, String? branchId});

  // -- Service sales -------------------------------------------------------------
  Future<ServiceSale> createServiceSale(ServiceSale sale, {String? userId});
  Future<List<ServiceSale>> listServiceSales({
    DateTime? from,
    DateTime? to,
    int limit = 200,
  });
}

class DriftExpenseRepository implements ExpenseRepository {
  final db.AppDatabase database;

  DriftExpenseRepository(this.database);

  Expense _expense(db.Expense row) => Expense(
        id: row.id,
        branchId: row.branchId,
        category: row.category,
        amount: row.amount,
        expenseDate: row.expenseDate,
        description: row.description,
        userId: row.userId,
        createdAt: row.createdAt,
      );

  Staff _staff(db.StaffData row) => Staff(
        id: row.id,
        name: row.name,
        phone: row.phone,
        role: row.role,
        salary: row.salary,
        isActive: row.isActive,
        createdAt: row.createdAt,
      );

  SalaryPayment _salary(db.SalaryPayment row) => SalaryPayment(
        id: row.id,
        staffId: row.staffId,
        month: row.month,
        amount: row.amount,
        advance: row.advance,
        paidDate: row.paidDate,
        userId: row.userId,
        notes: row.notes,
        createdAt: row.createdAt,
      );

  CashRegister _register(db.CashRegister row) => CashRegister(
        id: row.id,
        branchId: row.branchId,
        registerDate: row.registerDate,
        openingCash: row.openingCash,
        closingCash: row.closingCash,
        expectedCash: row.expectedCash,
        difference: row.difference,
        status: row.status,
        openedBy: row.openedBy,
        closedBy: row.closedBy,
        notes: row.notes,
        createdAt: row.createdAt,
        updatedAt: row.updatedAt,
      );

  CashMovement _movement(db.CashMovement row) => CashMovement(
        id: row.id,
        registerId: row.registerId,
        type: row.type,
        amount: row.amount,
        reason: row.reason,
        userId: row.userId,
        createdAt: row.createdAt,
      );

  ServiceSale _serviceSale(db.ServiceSale row) => ServiceSale(
        id: row.id,
        serviceType: row.serviceType,
        customerPhone: row.customerPhone,
        provider: row.provider,
        amount: row.amount,
        commission: row.commission,
        userId: row.userId,
        saleDate: row.saleDate,
        createdAt: row.createdAt,
      );

  static DateTime _day(DateTime d) => DateTime(d.year, d.month, d.day);

  // -- Expenses --------------------------------------------------------------

  @override
  Future<Expense> createExpense(Expense expense, {String? userId}) async {
    if (expense.amount <= 0) {
      throw const RepositoryException('Expense amount must be greater than 0');
    }
    final now = DateTime.now();
    final created = expense.copyWith(
      id: expense.id.isEmpty ? db.newUuid() : expense.id,
      createdAt: now,
    );
    await database.transaction(() async {
      await database.into(database.expenses).insert(
            db.ExpensesCompanion.insert(
              id: created.id,
              branchId: Value(created.branchId),
              category: created.category,
              amount: created.amount,
              expenseDate: Value(created.expenseDate),
              description: Value(created.description),
              userId: created.userId,
              createdAt: Value(now),
            ),
          );
      await database.writeAudit(
        userId: userId,
        action: 'create',
        entityType: 'expense',
        entityId: created.id,
        newValues: created.toJson(),
      );
      await database.enqueueOutbox(
        tableName: 'expenses',
        operation: 'insert',
        payload: created.toJson(),
      );
    });
    return created;
  }

  @override
  Future<List<Expense>> listExpenses({
    DateTime? from,
    DateTime? to,
    String? category,
    String? branchId,
    int limit = 200,
  }) async {
    final query = database.select(database.expenses);
    if (from != null) {
      query.where((t) => t.expenseDate.isBiggerOrEqualValue(from));
    }
    if (to != null) {
      query.where((t) => t.expenseDate.isSmallerOrEqualValue(to));
    }
    if (category != null) query.where((t) => t.category.equals(category));
    if (branchId != null) query.where((t) => t.branchId.equals(branchId));
    query.orderBy([(t) => OrderingTerm.desc(t.expenseDate)]);
    query.limit(limit);
    return (await query.get()).map(_expense).toList();
  }

  @override
  Future<Expense> updateExpense(Expense expense, {String? userId}) async {
    final existing = await (database.select(database.expenses)
          ..where((t) => t.id.equals(expense.id)))
        .getSingleOrNull();
    if (existing == null) {
      throw RepositoryException('Expense ${expense.id} not found');
    }
    await database.transaction(() async {
      await (database.update(database.expenses)
            ..where((t) => t.id.equals(expense.id)))
          .write(db.ExpensesCompanion(
            category: Value(expense.category),
            amount: Value(expense.amount),
            expenseDate: Value(expense.expenseDate),
            description: Value(expense.description),
          ));
      await database.writeAudit(
        userId: userId,
        action: 'update',
        entityType: 'expense',
        entityId: expense.id,
        oldValues: _expense(existing).toJson(),
        newValues: expense.toJson(),
      );
      await database.enqueueOutbox(
        tableName: 'expenses',
        operation: 'update',
        payload: expense.toJson(),
      );
    });
    return expense;
  }

  @override
  Future<void> deleteExpense(String id, {String? userId}) async {
    await database.transaction(() async {
      await (database.delete(database.expenses)
            ..where((t) => t.id.equals(id)))
          .go();
      await database.writeAudit(
        userId: userId,
        action: 'delete',
        entityType: 'expense',
        entityId: id,
      );
      await database.enqueueOutbox(
        tableName: 'expenses',
        operation: 'delete',
        payload: {'id': id},
      );
    });
  }

  // -- Staff & salaries ------------------------------------------------------

  @override
  Future<Staff> createStaff(Staff staff, {String? userId}) async {
    final created = staff.copyWith(
      id: staff.id.isEmpty ? db.newUuid() : staff.id,
      createdAt: DateTime.now(),
    );
    await database.transaction(() async {
      await database.into(database.staff).insert(
            db.StaffCompanion.insert(
              id: created.id,
              name: created.name,
              phone: Value(created.phone),
              role: Value(created.role),
              salary: Value(created.salary),
              isActive: Value(created.isActive),
              createdAt: Value(created.createdAt),
            ),
          );
      await database.writeAudit(
        userId: userId,
        action: 'create',
        entityType: 'staff',
        entityId: created.id,
        newValues: created.toJson(),
      );
      await database.enqueueOutbox(
        tableName: 'staff',
        operation: 'insert',
        payload: created.toJson(),
      );
    });
    return created;
  }

  @override
  Future<List<Staff>> listStaff({bool onlyActive = true}) async {
    final query = database.select(database.staff);
    if (onlyActive) query.where((t) => t.isActive.equals(true));
    query.orderBy([(t) => OrderingTerm.asc(t.name)]);
    return (await query.get()).map(_staff).toList();
  }

  @override
  Future<Staff> updateStaff(Staff staff, {String? userId}) async {
    final existing = await (database.select(database.staff)
          ..where((t) => t.id.equals(staff.id)))
        .getSingleOrNull();
    if (existing == null) {
      throw RepositoryException('Staff ${staff.id} not found');
    }
    await database.transaction(() async {
      await (database.update(database.staff)
            ..where((t) => t.id.equals(staff.id)))
          .write(db.StaffCompanion(
            name: Value(staff.name),
            phone: Value(staff.phone),
            role: Value(staff.role),
            salary: Value(staff.salary),
            isActive: Value(staff.isActive),
          ));
      await database.writeAudit(
        userId: userId,
        action: 'update',
        entityType: 'staff',
        entityId: staff.id,
        oldValues: _staff(existing).toJson(),
        newValues: staff.toJson(),
      );
      await database.enqueueOutbox(
        tableName: 'staff',
        operation: 'update',
        payload: staff.toJson(),
      );
    });
    return staff;
  }

  @override
  Future<SalaryPayment> paySalary(SalaryPayment payment,
      {String? userId}) async {
    if (payment.amount < 0) {
      throw const RepositoryException('Salary amount cannot be negative');
    }
    final now = DateTime.now();
    final created = payment.copyWith(
      id: payment.id.isEmpty ? db.newUuid() : payment.id,
      paidDate: now,
      createdAt: now,
    );
    await database.transaction(() async {
      await database.into(database.salaryPayments).insert(
            db.SalaryPaymentsCompanion.insert(
              id: created.id,
              staffId: created.staffId,
              month: created.month,
              amount: created.amount,
              advance: Value(created.advance),
              paidDate: Value(now),
              userId: created.userId,
              notes: Value(created.notes),
              createdAt: Value(now),
            ),
          );
      // Salary is also an expense (category `salary`).
      await database.into(database.expenses).insert(
            db.ExpensesCompanion.insert(
              id: db.newUuid(),
              category: 'salary',
              amount: created.amount,
              expenseDate: Value(now),
              description: Value(
                  'Salary ${created.month} (staff ${created.staffId})'),
              userId: created.userId,
              createdAt: Value(now),
            ),
          );
      await database.writeAudit(
        userId: userId,
        action: 'create',
        entityType: 'salary_payment',
        entityId: created.id,
        newValues: created.toJson(),
      );
      await database.enqueueOutbox(
        tableName: 'salary_payments',
        operation: 'insert',
        payload: created.toJson(),
      );
    });
    return created;
  }

  @override
  Future<List<SalaryPayment>> listSalaryPayments({
    String? staffId,
    String? month,
  }) async {
    final query = database.select(database.salaryPayments);
    if (staffId != null) query.where((t) => t.staffId.equals(staffId));
    if (month != null) query.where((t) => t.month.equals(month));
    query.orderBy([(t) => OrderingTerm.desc(t.paidDate)]);
    return (await query.get()).map(_salary).toList();
  }

  // -- Cash register ---------------------------------------------------------

  @override
  Future<CashRegister> openRegister({
    String? branchId,
    required int openingCash,
    required String openedBy,
    DateTime? date,
    String? notes,
  }) async {
    if (openingCash < 0) {
      throw const RepositoryException('Opening cash cannot be negative');
    }
    final day = _day(date ?? DateTime.now());
    return database.transaction(() async {
      final existing = await getOpenRegister(branchId: branchId, date: day);
      if (existing != null) {
        throw RepositoryException(
            'A register is already open for ${day.toIso8601String().substring(0, 10)}');
      }
      final now = DateTime.now();
      final register = CashRegister(
        id: db.newUuid(),
        branchId: branchId,
        registerDate: day,
        openingCash: openingCash,
        status: 'open',
        openedBy: openedBy,
        notes: notes,
        createdAt: now,
        updatedAt: now,
      );
      await database.into(database.cashRegisters).insert(
            db.CashRegistersCompanion.insert(
              id: register.id,
              branchId: Value(branchId),
              registerDate: day,
              openingCash: Value(openingCash),
              status: const Value('open'),
              openedBy: Value(openedBy),
              notes: Value(notes),
              createdAt: Value(now),
              updatedAt: Value(now),
            ),
          );
      await database.writeAudit(
        userId: openedBy,
        action: 'open',
        entityType: 'cash_register',
        entityId: register.id,
        newValues: register.toJson(),
      );
      return register;
    });
  }

  @override
  Future<CashRegister?> getOpenRegister(
      {String? branchId, DateTime? date}) async {
    final day = _day(date ?? DateTime.now());
    final query = database.select(database.cashRegisters);
    query.where((t) =>
        t.status.equals('open') & t.registerDate.equals(day));
    if (branchId != null) {
      query.where((t) => t.branchId.equals(branchId));
    }
    final row = await query.getSingleOrNull();
    return row == null ? null : _register(row);
  }

  Future<int> _movementSum(String registerId, String type) async {
    final row = await database.customSelect(
      'SELECT COALESCE(SUM(amount), 0) AS total FROM cash_movements '
      'WHERE register_id = ? AND type = ?',
      variables: [
        Variable.withString(registerId),
        Variable.withString(type),
      ],
    ).getSingle();
    return row.read<int>('total');
  }

  Future<int> _expensesSum(DateTime dayStart, DateTime dayEnd,
      {String? branchId}) async {
    final whereBranch =
        branchId == null ? '' : ' AND branch_id = ?';
    final variables = <Variable>[
      Variable.withDateTime(dayStart),
      Variable.withDateTime(dayEnd),
    ];
    if (branchId != null) variables.add(Variable.withString(branchId));
    final row = await database.customSelect(
      'SELECT COALESCE(SUM(amount), 0) AS total FROM expenses '
      'WHERE expense_date >= ? AND expense_date < ?$whereBranch',
      variables: variables,
    ).getSingle();
    return row.read<int>('total');
  }

  @override
  Future<CashRegister> closeRegister({
    required String registerId,
    required int closingCash,
    required String closedBy,
    String? notes,
  }) async {
    if (closingCash < 0) {
      throw const RepositoryException('Closing cash cannot be negative');
    }
    return database.transaction(() async {
      final row = await (database.select(database.cashRegisters)
            ..where((t) => t.id.equals(registerId)))
          .getSingleOrNull();
      if (row == null) {
        throw RepositoryException('Register $registerId not found');
      }
      if (row.status != 'open') {
        throw const RepositoryException('Register is already closed');
      }
      final dayStart = _day(row.registerDate);
      final dayEnd = dayStart.add(const Duration(days: 1));
      final cashIn = await _movementSum(registerId, 'in');
      final cashOut = await _movementSum(registerId, 'out');
      final expenses = await _expensesSum(dayStart, dayEnd,
          branchId: row.branchId);
      final expected = row.openingCash + cashIn - cashOut - expenses;
      final difference = closingCash - expected;
      final now = DateTime.now();
      await (database.update(database.cashRegisters)
            ..where((t) => t.id.equals(registerId)))
          .write(db.CashRegistersCompanion(
            closingCash: Value(closingCash),
            expectedCash: Value(expected),
            difference: Value(difference),
            status: const Value('closed'),
            closedBy: Value(closedBy),
            notes: Value(notes ?? row.notes),
            updatedAt: Value(now),
          ));
      final closed = _register(row).copyWith(
        closingCash: closingCash,
        expectedCash: expected,
        difference: difference,
        status: 'closed',
        closedBy: closedBy,
        notes: notes ?? row.notes,
        updatedAt: now,
      );
      await database.writeAudit(
        userId: closedBy,
        action: 'close',
        entityType: 'cash_register',
        entityId: registerId,
        oldValues: {'status': 'open'},
        newValues: closed.toJson(),
      );
      await database.enqueueOutbox(
        tableName: 'cash_register',
        operation: 'update',
        payload: closed.toJson(),
      );
      return closed;
    });
  }

  @override
  Future<CashMovement> recordCashMovement({
    required String registerId,
    required String type,
    required int amount,
    String? reason,
    required String userId,
  }) async {
    if (amount <= 0) {
      throw const RepositoryException('Movement amount must be greater than 0');
    }
    if (type != 'in' && type != 'out') {
      throw const RepositoryException('Movement type must be in or out');
    }
    return database.transaction(() async {
      final register = await (database.select(database.cashRegisters)
            ..where((t) => t.id.equals(registerId)))
          .getSingleOrNull();
      if (register == null) {
        throw RepositoryException('Register $registerId not found');
      }
      if (register.status != 'open') {
        throw const RepositoryException('Cannot move cash on a closed register');
      }
      final now = DateTime.now();
      final movement = CashMovement(
        id: db.newUuid(),
        registerId: registerId,
        type: type,
        amount: amount,
        reason: reason,
        userId: userId,
        createdAt: now,
      );
      await database.into(database.cashMovements).insert(
            db.CashMovementsCompanion.insert(
              id: movement.id,
              registerId: registerId,
              type: type,
              amount: amount,
              reason: Value(reason),
              userId: userId,
              createdAt: Value(now),
            ),
          );
      await database.writeAudit(
        userId: userId,
        action: 'cash_move',
        entityType: 'cash_register',
        entityId: registerId,
        newValues: movement.toJson(),
      );
      return movement;
    });
  }

  @override
  Future<List<CashMovement>> listCashMovements(String registerId) async {
    final rows = await (database.select(database.cashMovements)
          ..where((t) => t.registerId.equals(registerId))
          ..orderBy([(t) => OrderingTerm.asc(t.createdAt)]))
        .get();
    return rows.map(_movement).toList();
  }

  @override
  Future<DaySummary> daySummary({DateTime? date, String? branchId}) async {
    final day = _day(date ?? DateTime.now());
    final next = day.add(const Duration(days: 1));
    final salesRow = await database.customSelect(
      'SELECT COALESCE(SUM(grand_total), 0) AS revenue, '
      'COUNT(*) AS cnt, '
      "COALESCE(SUM(CASE WHEN COALESCE(payment_method, 'cash') = 'cash' "
      'THEN grand_total ELSE 0 END), 0) AS cash_revenue, '
      "COALESCE(SUM(CASE WHEN COALESCE(payment_method, 'cash') != 'cash' "
      'THEN grand_total ELSE 0 END), 0) AS other_revenue '
      'FROM sales WHERE sale_date >= ? AND '
      "sale_date < ? AND status != 'cancelled'",
      variables: [
        Variable.withDateTime(day),
        Variable.withDateTime(next),
      ],
    ).getSingle();
    final expenses = await _expensesSum(day, next, branchId: branchId);
    final serviceRow = await database.customSelect(
      'SELECT COALESCE(SUM(amount), 0) AS total, '
      'COALESCE(SUM(commission), 0) AS comm FROM service_sales '
      'WHERE sale_date >= ? AND sale_date < ?',
      variables: [
        Variable.withDateTime(day),
        Variable.withDateTime(next),
      ],
    ).getSingle();
    final register = await getOpenRegister(branchId: branchId, date: day);
    CashRegister? closedRegister;
    if (register == null) {
      final closed = await (database.select(database.cashRegisters)
            ..where((t) => t.registerDate.equals(day))
            ..orderBy([(t) => OrderingTerm.desc(t.createdAt)])
            ..limit(1))
          .getSingleOrNull();
      if (closed != null) closedRegister = _register(closed);
    }
    final active = register ?? closedRegister;
    var cashIn = 0;
    var cashOut = 0;
    if (active != null) {
      cashIn = await _movementSum(active.id, 'in');
      cashOut = await _movementSum(active.id, 'out');
    }
    final opening = active?.openingCash ?? 0;
    return DaySummary(
      date: day,
      totalSales: salesRow.read<int>('revenue'),
      cashSales: salesRow.read<int>('cash_revenue'),
      otherMethodSales: salesRow.read<int>('other_revenue'),
      salesCount: salesRow.read<int>('cnt'),
      totalExpenses: expenses,
      serviceSalesTotal: serviceRow.read<int>('total'),
      serviceCommission: serviceRow.read<int>('comm'),
      cashIn: cashIn,
      cashOut: cashOut,
      openingCash: opening,
      expectedCash: opening + cashIn - cashOut - expenses,
      closingCash: active?.closingCash,
      difference: active?.difference,
      registerStatus: active?.status ?? 'closed',
    );
  }

  // -- Service sales ---------------------------------------------------------

  @override
  Future<ServiceSale> createServiceSale(ServiceSale sale,
      {String? userId}) async {
    if (sale.amount <= 0) {
      throw const RepositoryException('Service amount must be greater than 0');
    }
    final now = DateTime.now();
    final created = sale.copyWith(
      id: sale.id.isEmpty ? db.newUuid() : sale.id,
      saleDate: now,
      createdAt: now,
    );
    await database.transaction(() async {
      await database.into(database.serviceSales).insert(
            db.ServiceSalesCompanion.insert(
              id: created.id,
              serviceType: created.serviceType,
              customerPhone: Value(created.customerPhone),
              provider: Value(created.provider),
              amount: created.amount,
              commission: Value(created.commission),
              userId: created.userId,
              saleDate: Value(now),
              createdAt: Value(now),
            ),
          );
      await database.writeAudit(
        userId: userId,
        action: 'create',
        entityType: 'service_sale',
        entityId: created.id,
        newValues: created.toJson(),
      );
      await database.enqueueOutbox(
        tableName: 'service_sales',
        operation: 'insert',
        payload: created.toJson(),
      );
    });
    return created;
  }

  @override
  Future<List<ServiceSale>> listServiceSales({
    DateTime? from,
    DateTime? to,
    int limit = 200,
  }) async {
    final query = database.select(database.serviceSales);
    if (from != null) {
      query.where((t) => t.saleDate.isBiggerOrEqualValue(from));
    }
    if (to != null) {
      query.where((t) => t.saleDate.isSmallerOrEqualValue(to));
    }
    query.orderBy([(t) => OrderingTerm.desc(t.saleDate)]);
    query.limit(limit);
    return (await query.get()).map(_serviceSale).toList();
  }
}
