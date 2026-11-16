/// Supplier repository: suppliers and their current payable.
///
/// The payable is NOT a column — it is derived from the supplier
/// ledger like [DriftPurchaseRepository._payable]: the latest
/// `ledger_entries` row for the supplier (side `supplier`), falling
/// back to the supplier's `opening_payable` when no ledger row
/// exists. Money is integer whole PKR. Every mutation writes an
/// audit row and queues an outbox row.
///
/// NOTE: [supplierRepositoryProvider] lives in the shared providers
/// file (`core/providers/app_providers.dart`) with the other
/// repository providers — screens read it by name, so nothing else
/// changes.
library;

import 'package:drift/drift.dart';

import '../../domain/models/supplier.dart';
import '../database/app_database.dart' as db;
import 'product_repository.dart' show RepositoryException;

abstract class SupplierRepository {
  /// All suppliers, active first by name, each with its current
  /// payable — including zero-payable suppliers.
  Future<List<Supplier>> listSuppliers({bool onlyActive = true});

  Future<Supplier?> getSupplier(String id);

  Future<Supplier> createSupplier(Supplier supplier, {String? userId});

  Future<Supplier> updateSupplier(Supplier supplier, {String? userId});
}

class DriftSupplierRepository implements SupplierRepository {
  final db.AppDatabase database;

  DriftSupplierRepository(this.database);

  Supplier _supplier(db.Supplier row, [int payable = 0]) => Supplier(
        id: row.id,
        name: row.name,
        phone: row.phone,
        address: row.address,
        openingPayable: row.openingPayable,
        isActive: row.isActive,
        createdAt: row.createdAt,
        updatedAt: row.updatedAt,
        payable: payable,
      );

  /// Current amount the shop owes a supplier, as SUM(credit - debit)
  /// over the supplier ledger rows (not the "latest" row — two entries
  /// sharing an entryDate millisecond made that lookup ambiguous).
  /// The opening entry (written at creation when the opening payable
  /// is non-zero) is already a ledger row, so the sum includes it;
  /// the opening-payable fallback only applies with no rows at all.
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

  @override
  Future<List<Supplier>> listSuppliers({bool onlyActive = true}) async {
    final query = database.select(database.suppliers);
    if (onlyActive) query.where((t) => t.isActive.equals(true));
    query.orderBy([(t) => OrderingTerm.asc(t.name)]);
    final rows = await query.get();
    final result = <Supplier>[];
    for (final row in rows) {
      result.add(_supplier(row, await _payable(row.id)));
    }
    return result;
  }

  @override
  Future<Supplier?> getSupplier(String id) async {
    final row = await (database.select(database.suppliers)
          ..where((t) => t.id.equals(id)))
        .getSingleOrNull();
    if (row == null) return null;
    return _supplier(row, await _payable(id));
  }

  @override
  Future<Supplier> createSupplier(Supplier supplier,
      {String? userId}) async {
    if (supplier.name.trim().isEmpty) {
      throw const RepositoryException('Supplier name is required');
    }
    final now = DateTime.now();
    final created = supplier.copyWith(
      id: supplier.id.isEmpty ? db.newUuid() : supplier.id,
      name: supplier.name.trim(),
      createdAt: now,
      updatedAt: now,
    );
    await database.transaction(() async {
      await database.into(database.suppliers).insert(
            db.SuppliersCompanion.insert(
              id: created.id,
              name: created.name,
              phone: Value(created.phone),
              address: Value(created.address),
              openingPayable: Value(created.openingPayable),
              isActive: Value(created.isActive),
              createdAt: Value(now),
              updatedAt: Value(now),
            ),
          );
      if (created.openingPayable != 0) {
        await database.into(database.ledgerEntries).insert(
              db.LedgerEntriesCompanion.insert(
                id: db.newUuid(),
                side: 'supplier',
                supplierId: Value(created.id),
                referenceType: 'opening',
                debit: const Value(0),
                credit: Value(created.openingPayable),
                balanceAfter: Value(created.openingPayable),
                entryDate: Value(now),
                userId: Value(userId),
              ),
            );
      }
      await database.writeAudit(
        userId: userId,
        action: 'create',
        entityType: 'supplier',
        entityId: created.id,
        newValues: created.toJson(),
      );
      await database.enqueueOutbox(
        tableName: 'suppliers',
        operation: 'insert',
        payload: created.toJson(),
      );
    });
    return created.copyWith(payable: created.openingPayable);
  }

  @override
  Future<Supplier> updateSupplier(Supplier supplier,
      {String? userId}) async {
    if (supplier.name.trim().isEmpty) {
      throw const RepositoryException('Supplier name is required');
    }
    final existing = await getSupplier(supplier.id);
    if (existing == null) {
      throw RepositoryException('Supplier ${supplier.id} not found');
    }
    final updated = supplier.copyWith(
      name: supplier.name.trim(),
      updatedAt: DateTime.now(),
    );
    await database.transaction(() async {
      await (database.update(database.suppliers)
            ..where((t) => t.id.equals(supplier.id)))
          .write(db.SuppliersCompanion(
            name: Value(updated.name),
            phone: Value(updated.phone),
            address: Value(updated.address),
            openingPayable: Value(updated.openingPayable),
            isActive: Value(updated.isActive),
            updatedAt: Value(updated.updatedAt),
          ));
      await database.writeAudit(
        userId: userId,
        action: 'update',
        entityType: 'supplier',
        entityId: updated.id,
        oldValues: existing.toJson(),
        newValues: updated.toJson(),
      );
      await database.enqueueOutbox(
        tableName: 'suppliers',
        operation: 'update',
        payload: updated.toJson(),
      );
    });
    return updated.copyWith(payable: existing.payable);
  }
}
