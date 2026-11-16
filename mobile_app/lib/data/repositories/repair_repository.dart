/// Repair repository: job cards, parts and status transitions.
///
/// Status flow: `received` -> `in_progress` -> `ready` -> `delivered`.
/// `cancelled` is allowed from any status except `delivered`.
/// Every mutation writes an audit row and queues an outbox row.
/// Money is integer whole PKR.
library;

import 'package:drift/drift.dart';

import '../../domain/models/repair.dart';
import '../../domain/models/sale.dart' show Payment;
import '../database/app_database.dart' as db;
import 'product_repository.dart' show RepositoryException;

/// Allowed next statuses for each repair status.
const Map<String, List<String>> repairTransitions = {
  'received': ['in_progress', 'cancelled'],
  'in_progress': ['ready', 'cancelled'],
  'ready': ['delivered', 'cancelled'],
  'delivered': [],
  'cancelled': [],
};

abstract class RepairRepository {
  /// Creates a job card; the job number (`REP-000123`) is allocated
  /// from the `repair_job` counter.
  Future<Repair> createRepair(Repair repair, {String? userId});
  Future<Repair?> getRepair(String id);
  Future<Repair?> getRepairByJobNo(String jobNo);
  Future<List<Repair>> listRepairs({
    String? status,
    String? search,
    int limit = 100,
    int offset = 0,
  });
  Future<Repair> updateRepair(Repair repair, {String? userId});

  /// Moves a job to [status], enforcing [repairTransitions].
  /// Sets `ready_date` / `delivered_date` automatically.
  Future<Repair> updateStatus(
    String repairId,
    String status, {
    String? userId,
  });

  Future<RepairPart> addPart(RepairPart part, {String? userId});
  Future<List<RepairPart>> listParts(String repairId);
  Future<void> removePart(String partId, {String? userId});

  /// Delivers the job and, when a balance is still owed by a known
  /// customer, posts that balance as an udhaar debit to the customer
  /// ledger — all in ONE transaction. Enforces [repairTransitions]
  /// (only `ready` -> `delivered`). When the balance is zero (or
  /// negative) or the repair has no [Repair.customerId], the job is
  /// simply delivered with no ledger entry.
  Future<Repair> deliverWithUdhaar(
    String repairId, {
    String? userId,
  });

  /// Records an advance / final payment: payment row + `advance_paid`.
  Future<Payment> recordRepairPayment({
    required String repairId,
    required int amount,
    required String method,
    String? reference,
    required String userId,
    String? notes,
  });
}

class DriftRepairRepository implements RepairRepository {
  final db.AppDatabase database;

  DriftRepairRepository(this.database);

  RepairPart _part(db.RepairPart row) => RepairPart(
        id: row.id,
        repairId: row.repairId,
        productId: row.productId,
        variantId: row.variantId,
        name: row.name,
        quantity: row.quantity,
        unitPrice: row.unitPrice,
        total: row.total,
        createdAt: row.createdAt,
      );

  Repair _repair(db.Repair row, [List<RepairPart> parts = const []]) =>
      Repair(
        id: row.id,
        jobNo: row.jobNo,
        customerId: row.customerId,
        customerName: row.customerName,
        customerPhone: row.customerPhone,
        deviceBrand: row.deviceBrand,
        deviceModel: row.deviceModel,
        imei: row.imei,
        faultDescription: row.faultDescription,
        estimatedCost: row.estimatedCost,
        finalCost: row.finalCost,
        advancePaid: row.advancePaid,
        status: row.status,
        receivedDate: row.receivedDate,
        readyDate: row.readyDate,
        deliveredDate: row.deliveredDate,
        userId: row.userId,
        notes: row.notes,
        parts: parts,
        createdAt: row.createdAt,
        updatedAt: row.updatedAt,
      );

  Future<List<RepairPart>> _partsOf(String repairId) async {
    final rows = await (database.select(database.repairParts)
          ..where((t) => t.repairId.equals(repairId)))
        .get();
    return rows.map(_part).toList();
  }

  @override
  Future<Repair> createRepair(Repair repair, {String? userId}) async {
    return database.transaction(() async {
      final now = DateTime.now();
      final jobNo = repair.jobNo.isEmpty
          ? await database.nextDocumentNumber(
              name: 'repair_job',
              prefix: 'REP',
            )
          : repair.jobNo;
      final created = repair.copyWith(
        id: repair.id.isEmpty ? db.newUuid() : repair.id,
        jobNo: jobNo,
        receivedDate: now,
        createdAt: now,
        updatedAt: now,
      );
      await database.into(database.repairs).insert(
            db.RepairsCompanion.insert(
              id: created.id,
              jobNo: jobNo,
              customerId: Value(created.customerId),
              customerName: created.customerName,
              customerPhone: created.customerPhone,
              deviceBrand: Value(created.deviceBrand),
              deviceModel: Value(created.deviceModel),
              imei: Value(created.imei),
              faultDescription: created.faultDescription,
              estimatedCost: Value(created.estimatedCost),
              finalCost: Value(created.finalCost),
              advancePaid: Value(created.advancePaid),
              status: Value(created.status),
              receivedDate: Value(now),
              userId: created.userId,
              notes: Value(created.notes),
              createdAt: Value(now),
              updatedAt: Value(now),
            ),
          );
      if (created.advancePaid > 0) {
        await database.into(database.payments).insert(
              db.PaymentsCompanion.insert(
                id: db.newUuid(),
                paymentType: 'repair',
                repairId: Value(created.id),
                customerId: Value(created.customerId),
                method: const Value('cash'),
                amount: created.advancePaid,
                paymentDate: Value(now),
                userId: created.userId,
                clientUuid: Value(db.newUuid()),
                createdAt: Value(now),
              ),
            );
      }
      await database.writeAudit(
        userId: userId,
        action: 'create',
        entityType: 'repair',
        entityId: created.id,
        newValues: created.toJson(),
      );
      await database.enqueueOutbox(
        tableName: 'repairs',
        operation: 'insert',
        payload: created.toJson(),
      );
      return created;
    });
  }

  @override
  Future<Repair?> getRepair(String id) async {
    final row = await (database.select(database.repairs)
          ..where((t) => t.id.equals(id)))
        .getSingleOrNull();
    if (row == null) return null;
    return _repair(row, await _partsOf(id));
  }

  @override
  Future<Repair?> getRepairByJobNo(String jobNo) async {
    final row = await (database.select(database.repairs)
          ..where((t) => t.jobNo.equals(jobNo)))
        .getSingleOrNull();
    if (row == null) return null;
    return _repair(row, await _partsOf(row.id));
  }

  @override
  Future<List<Repair>> listRepairs({
    String? status,
    String? search,
    int limit = 100,
    int offset = 0,
  }) async {
    final query = database.select(database.repairs);
    if (status != null) query.where((t) => t.status.equals(status));
    if (search != null && search.trim().isNotEmpty) {
      final q = '%${search.trim()}%';
      // imei is nullable: LIKE on it is not type-safe, use equals.
      query.where((t) =>
          t.jobNo.like(q) |
          t.customerName.like(q) |
          t.customerPhone.like(q) |
          t.imei.equals(search.trim()));
    }
    query.orderBy([(t) => OrderingTerm.desc(t.receivedDate)]);
    query.limit(limit, offset: offset);
    final rows = await query.get();
    final result = <Repair>[];
    for (final row in rows) {
      result.add(_repair(row, await _partsOf(row.id)));
    }
    return result;
  }

  @override
  Future<Repair> updateRepair(Repair repair, {String? userId}) async {
    final existing = await getRepair(repair.id);
    if (existing == null) {
      throw RepositoryException('Repair ${repair.id} not found');
    }
    final updated = repair.copyWith(updatedAt: DateTime.now());
    await database.transaction(() async {
      await (database.update(database.repairs)
            ..where((t) => t.id.equals(repair.id)))
          .write(db.RepairsCompanion(
            customerId: Value(updated.customerId),
            customerName: Value(updated.customerName),
            customerPhone: Value(updated.customerPhone),
            deviceBrand: Value(updated.deviceBrand),
            deviceModel: Value(updated.deviceModel),
            imei: Value(updated.imei),
            faultDescription: Value(updated.faultDescription),
            estimatedCost: Value(updated.estimatedCost),
            finalCost: Value(updated.finalCost),
            advancePaid: Value(updated.advancePaid),
            notes: Value(updated.notes),
            updatedAt: Value(updated.updatedAt),
          ));
      await database.writeAudit(
        userId: userId,
        action: 'update',
        entityType: 'repair',
        entityId: updated.id,
        oldValues: existing.toJson(),
        newValues: updated.toJson(),
      );
      await database.enqueueOutbox(
        tableName: 'repairs',
        operation: 'update',
        payload: updated.toJson(),
      );
    });
    return updated;
  }

  @override
  Future<Repair> updateStatus(
    String repairId,
    String status, {
    String? userId,
  }) async {
    final existing = await getRepair(repairId);
    if (existing == null) {
      throw RepositoryException('Repair $repairId not found');
    }
    final allowed = repairTransitions[existing.status] ?? const [];
    if (!allowed.contains(status)) {
      throw RepositoryException(
          'Cannot move a repair from ${existing.status} to $status');
    }
    final now = DateTime.now();
    final updated = existing.copyWith(
      status: status,
      readyDate: status == 'ready' ? now : existing.readyDate,
      deliveredDate:
          status == 'delivered' ? now : existing.deliveredDate,
      updatedAt: now,
    );
    await database.transaction(() async {
      await (database.update(database.repairs)
            ..where((t) => t.id.equals(repairId)))
          .write(db.RepairsCompanion(
            status: Value(status),
            readyDate: Value(updated.readyDate),
            deliveredDate: Value(updated.deliveredDate),
            updatedAt: Value(now),
          ));
      await database.writeAudit(
        userId: userId,
        action: 'status',
        entityType: 'repair',
        entityId: repairId,
        oldValues: {'status': existing.status},
        newValues: {'status': status},
      );
      await database.enqueueOutbox(
        tableName: 'repairs',
        operation: 'update',
        payload: {'id': repairId, 'status': status},
      );
    });
    return updated;
  }

  @override
  Future<RepairPart> addPart(RepairPart part, {String? userId}) async {
    final repair = await getRepair(part.repairId);
    if (repair == null) {
      throw RepositoryException('Repair ${part.repairId} not found');
    }
    if (repair.status == 'delivered' || repair.status == 'cancelled') {
      throw RepositoryException(
          'Cannot add parts to a ${repair.status} repair');
    }
    final now = DateTime.now();
    final created = part.copyWith(
      id: part.id.isEmpty ? db.newUuid() : part.id,
      total: part.unitPrice * part.quantity,
      createdAt: now,
    );
    await database.transaction(() async {
      await database.into(database.repairParts).insert(
            db.RepairPartsCompanion.insert(
              id: created.id,
              repairId: created.repairId,
              productId: Value(created.productId),
              variantId: Value(created.variantId),
              name: created.name,
              quantity: Value(created.quantity),
              unitPrice: created.unitPrice,
              total: created.total,
              createdAt: Value(now),
            ),
          );
      // Deduct accessory stock when the part comes from a variant.
      if (created.variantId != null) {
        final variant = await (database.select(database.productVariants)
              ..where((t) => t.id.equals(created.variantId!)))
            .getSingleOrNull();
        if (variant != null) {
          if (variant.quantity < created.quantity) {
            throw RepositoryException(
                'Not enough stock for part ${created.name}');
          }
          await database.customStatement(
            'UPDATE product_variants SET quantity = quantity - ?, '
            'updated_at = ? WHERE id = ?',
            [created.quantity, now.millisecondsSinceEpoch, created.variantId],
          );
        }
      }
      await database.writeAudit(
        userId: userId,
        action: 'create',
        entityType: 'repair_part',
        entityId: created.id,
        newValues: created.toJson(),
      );
      await database.enqueueOutbox(
        tableName: 'repair_parts',
        operation: 'insert',
        payload: created.toJson(),
      );
    });
    return created;
  }

  @override
  Future<List<RepairPart>> listParts(String repairId) => _partsOf(repairId);

  @override
  Future<Repair> deliverWithUdhaar(
    String repairId, {
    String? userId,
  }) async {
    final existing = await getRepair(repairId);
    if (existing == null) {
      throw RepositoryException('Repair $repairId not found');
    }
    final allowed = repairTransitions[existing.status] ?? const [];
    if (!allowed.contains('delivered')) {
      throw RepositoryException(
          'Cannot move a repair from ${existing.status} to delivered');
    }
    final now = DateTime.now();
    final balanceDue = existing.balanceDue;
    final updated = existing.copyWith(
      status: 'delivered',
      deliveredDate: now,
      updatedAt: now,
    );
    await database.transaction(() async {
      await (database.update(database.repairs)
            ..where((t) => t.id.equals(repairId)))
          .write(db.RepairsCompanion(
            status: const Value('delivered'),
            deliveredDate: Value(now),
            updatedAt: Value(now),
          ));
      // Post the unpaid balance as an udhaar debit, following the
      // ledgerEntries convention in customer_repository.dart: customer
      // side, balanceAfter = prev + debit - credit.
      if (balanceDue > 0 && existing.customerId != null) {
        final customerId = existing.customerId!;
        // Previous balance as SUM(debit - credit) (not the "latest"
        // row — same-millisecond entries made that lookup ambiguous).
        final prevRow = await database.customSelect(
          'SELECT COALESCE(SUM(debit - credit), 0) AS total, COUNT(*) AS n '
          'FROM ledger_entries WHERE side = ? AND customer_id = ?',
          variables: [
            Variable.withString('customer'),
            Variable.withString(customerId),
          ],
        ).getSingle();
        int prev = prevRow.read<int>('total');
        if (prevRow.read<int>('n') == 0) {
          final customer = await (database.select(database.customers)
                ..where((t) => t.id.equals(customerId)))
              .getSingleOrNull();
          prev = customer?.openingBalance ?? 0;
        }
        await database.into(database.ledgerEntries).insert(
              db.LedgerEntriesCompanion.insert(
                id: db.newUuid(),
                side: 'customer',
                customerId: Value(customerId),
                referenceType: 'repair',
                referenceId: Value(repairId),
                debit: Value(balanceDue),
                credit: const Value(0),
                balanceAfter: Value(prev + balanceDue),
                entryDate: Value(now),
                userId: Value(userId),
                notes: Value(
                    'Repair ${existing.jobNo} balance as udhaar'),
              ),
            );
      }
      await database.writeAudit(
        userId: userId,
        action: 'status',
        entityType: 'repair',
        entityId: repairId,
        oldValues: {'status': existing.status},
        newValues: {
          'status': 'delivered',
          if (balanceDue > 0) 'udhaar': balanceDue,
        },
      );
      await database.enqueueOutbox(
        tableName: 'repairs',
        operation: 'update',
        payload: {'id': repairId, 'status': 'delivered'},
      );
    });
    return updated;
  }

  @override
  Future<void> removePart(String partId, {String? userId}) async {
    await database.transaction(() async {
      final row = await (database.select(database.repairParts)
            ..where((t) => t.id.equals(partId)))
          .getSingleOrNull();
      if (row == null) {
        throw RepositoryException('Repair part $partId not found');
      }
      await (database.delete(database.repairParts)
            ..where((t) => t.id.equals(partId)))
          .go();
      // Restore the stock addPart deducted, in the same transaction.
      if (row.variantId != null) {
        await database.customStatement(
          'UPDATE product_variants SET quantity = quantity + ?, '
          'updated_at = ? WHERE id = ?',
          [
            row.quantity,
            DateTime.now().millisecondsSinceEpoch,
            row.variantId,
          ],
        );
      }
      await database.writeAudit(
        userId: userId,
        action: 'delete',
        entityType: 'repair_part',
        entityId: partId,
      );
      await database.enqueueOutbox(
        tableName: 'repair_parts',
        operation: 'delete',
        payload: {'id': partId},
      );
    });
  }

  @override
  Future<Payment> recordRepairPayment({
    required String repairId,
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
      final row = await (database.select(database.repairs)
            ..where((t) => t.id.equals(repairId)))
          .getSingleOrNull();
      if (row == null) {
        throw RepositoryException('Repair $repairId not found');
      }
      final now = DateTime.now();
      final payment = Payment(
        id: db.newUuid(),
        paymentType: 'repair',
        repairId: repairId,
        customerId: row.customerId,
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
              paymentType: 'repair',
              repairId: Value(repairId),
              customerId: Value(row.customerId),
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
      await (database.update(database.repairs)
            ..where((t) => t.id.equals(repairId)))
          .write(db.RepairsCompanion(
            advancePaid: Value(row.advancePaid + amount),
            updatedAt: Value(now),
          ));
      await database.writeAudit(
        userId: userId,
        action: 'payment',
        entityType: 'repair',
        entityId: repairId,
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
}
