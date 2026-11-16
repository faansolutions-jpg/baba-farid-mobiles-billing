/// Offline sync engine (outbox pattern, DECISIONS.md rules 24).
///
/// REAL SERVER CONTRACT (verified against
/// `backend/src/modules/sync/{routes,service,schemas}.ts` — the client
/// adapts to the server, never the other way round):
/// * PUSH — `POST /api/v1/sync/push` with `{ deviceId, sales: [...] }`
///   (camelCase keys). Each sale is `{ clientUuid, customerId?,
///   customerName?, customerPhone?, items: [{ variantId, imei1?,
///   quantity, unitPrice, discount }], discountAmount, discountPercent,
///   taxAmount, paidAmount, paymentMethod, notes?, adminApprovedBy? }`.
///   Phones are identified by IMEI number, NOT by the server-side
///   `imei_item` UUID (the phone does not know it); the server resolves
///   the IMEI to its `imei_items` row. Response:
///   `{ accepted[], skipped[{ clientUuid, reason }], errors[{ clientUuid,
///   error }], serverTime }`. `accepted` rows are the created bills
///   (snake_case `client_uuid`); `skipped` means `already_synced`.
///   There is NO generic push endpoint: only sales push. Every other
///   outbox row (products, customers, purchases, ...) stays pending
///   (see [push]) and is documented in `docs/sync.md` §3.1.
/// * PULL — `GET /api/v1/sync/pull?since=...` returns
///   `{ serverTime, products[], variants[], customers[], suppliers[],
///   sales[], settings, catalog[] }` (per-table arrays, NOT a `changes`
///   list). `variants` maps to local table `product_variants`;
///   `settings` is a flat `{ key: value }` object; `catalog` is the
///   Accessories Master Catalog rows, applied to the separate local
///   catalog database via [CatalogRepository.applyCatalogUpdate].
/// * [push] sends queued rows in order; [pull] applies server changes:
///   **server-wins for master data** (products, variants, categories,
///   brands, customers, suppliers, settings), **append-only for money
///   records** (sales, payments, ledger entries — never overwritten,
///   only inserted if absent).
/// * IMEI conflict: if the server says an IMEI is already sold, the
///   local sale is flagged as conflicted in its notes (never silently
///   overwritten) and a `sync_logs` conflict row is written.
/// * [sync] runs push then pull and returns a [SyncResult].
library;

import 'dart:convert';

import 'package:drift/drift.dart';

import '../api/api_client.dart';
import '../database/app_database.dart' as db;
import '../../features/catalog/catalog_models.dart';
import '../../features/catalog/catalog_repository.dart';

/// Result of one [SyncEngine.sync] run.
class SyncResult {
  final int pushed;
  final int pulled;
  final int conflicts;
  final DateTime lastSyncAt;

  const SyncResult({
    this.pushed = 0,
    this.pulled = 0,
    this.conflicts = 0,
    required this.lastSyncAt,
  });
}

/// Tables the server wins on (master data). Everything else pulled is
/// append-only: inserted only when the id does not exist locally.
const Set<String> _masterTables = {
  'products',
  'product_variants',
  'categories',
  'brands',
  'customers',
  'suppliers',
  'settings',
};

/// Whitelisted columns per table for pull upserts. Server records may
/// carry extra joined fields (e.g. `brand_name`); only whitelisted
/// columns are written, so unknown keys can never reach SQL.
const Map<String, List<String>> _tableColumns = {
  'branches': ['id', 'name', 'address', 'phone', 'is_active', 'created_at', 'updated_at'],
  'roles': ['id', 'name', 'description', 'permissions', 'created_at'],
  'users': ['id', 'branch_id', 'role_id', 'name', 'phone', 'email', 'password_hash', 'is_active', 'last_login_at', 'created_at', 'updated_at'],
  'categories': ['id', 'name', 'type', 'parent_id', 'is_active', 'created_at'],
  'brands': ['id', 'name', 'is_active', 'created_at'],
  'products': ['id', 'brand_id', 'category_id', 'type', 'name', 'description', 'barcode', 'image_url', 'is_active', 'created_at', 'updated_at'],
  'product_variants': ['id', 'product_id', 'name', 'color', 'storage_gb', 'ram_gb', 'condition', 'pta_status', 'barcode', 'purchase_price', 'sale_price', 'min_price', 'warranty_months', 'quantity', 'low_stock_threshold', 'is_active', 'created_at', 'updated_at'],
  'imei_items': ['id', 'product_id', 'variant_id', 'imei1', 'imei2', 'status', 'purchase_id', 'purchase_price', 'sale_price', 'sold_sale_id', 'warranty_start', 'warranty_end', 'created_at', 'updated_at'],
  'customers': ['id', 'name', 'phone', 'cnic', 'address', 'opening_balance', 'loyalty_points', 'wallet_balance', 'is_active', 'created_at', 'updated_at'],
  'suppliers': ['id', 'name', 'phone', 'address', 'opening_payable', 'is_active', 'created_at', 'updated_at'],
  'sales': ['id', 'invoice_no', 'branch_id', 'customer_id', 'customer_name', 'customer_phone', 'user_id', 'sale_date', 'subtotal', 'discount_amount', 'discount_percent', 'tax_amount', 'grand_total', 'paid_amount', 'balance_due', 'payment_method', 'payment_status', 'status', 'notes', 'client_uuid', 'created_at', 'updated_at'],
  'sale_items': ['id', 'sale_id', 'product_id', 'variant_id', 'imei_item_id', 'name_snapshot', 'quantity', 'unit_price', 'purchase_cost', 'discount', 'total', 'profit', 'created_at'],
  'sale_returns': ['id', 'sale_id', 'sale_item_id', 'imei_item_id', 'quantity', 'reason', 'refund_amount', 'is_exchange', 'exchange_sale_id', 'user_id', 'created_at'],
  'held_bills': ['id', 'branch_id', 'user_id', 'customer_name', 'cart', 'created_at'],
  'purchases': ['id', 'supplier_id', 'branch_id', 'user_id', 'supplier_invoice_no', 'purchase_date', 'subtotal', 'discount', 'grand_total', 'paid_amount', 'balance_due', 'status', 'notes', 'client_uuid', 'created_at', 'updated_at'],
  'purchase_items': ['id', 'purchase_id', 'product_id', 'variant_id', 'imei1', 'imei2', 'quantity', 'unit_cost', 'total', 'created_at'],
  'purchase_returns': ['id', 'purchase_id', 'imei_item_id', 'product_id', 'variant_id', 'quantity', 'reason', 'refund_amount', 'user_id', 'created_at'],
  'payments': ['id', 'payment_type', 'sale_id', 'purchase_id', 'installment_id', 'repair_id', 'customer_id', 'supplier_id', 'method', 'amount', 'reference', 'payment_date', 'user_id', 'notes', 'client_uuid', 'created_at'],
  'ledger_entries': ['id', 'side', 'customer_id', 'supplier_id', 'reference_type', 'reference_id', 'debit', 'credit', 'balance_after', 'entry_date', 'user_id', 'notes', 'created_at'],
  'installments': ['id', 'sale_id', 'customer_id', 'total_amount', 'down_payment', 'installment_count', 'installment_amount', 'start_date', 'status', 'created_at', 'updated_at'],
  'installment_payments': ['id', 'installment_id', 'due_date', 'amount', 'paid_amount', 'paid_date', 'status', 'reminder_sent', 'created_at', 'updated_at'],
  'repairs': ['id', 'job_no', 'customer_id', 'customer_name', 'customer_phone', 'device_brand', 'device_model', 'imei', 'fault_description', 'estimated_cost', 'final_cost', 'advance_paid', 'status', 'received_date', 'ready_date', 'delivered_date', 'user_id', 'notes', 'created_at', 'updated_at'],
  'repair_parts': ['id', 'repair_id', 'product_id', 'variant_id', 'name', 'quantity', 'unit_price', 'total', 'created_at'],
  'service_sales': ['id', 'service_type', 'customer_phone', 'provider', 'amount', 'commission', 'user_id', 'sale_date', 'created_at'],
  'expenses': ['id', 'branch_id', 'category', 'amount', 'expense_date', 'description', 'user_id', 'created_at'],
  'staff': ['id', 'name', 'phone', 'role', 'salary', 'is_active', 'created_at'],
  'salary_payments': ['id', 'staff_id', 'month', 'amount', 'advance', 'paid_date', 'user_id', 'notes', 'created_at'],
  'cash_register': ['id', 'branch_id', 'register_date', 'opening_cash', 'closing_cash', 'expected_cash', 'difference', 'status', 'opened_by', 'closed_by', 'notes', 'created_at', 'updated_at'],
  'cash_movements': ['id', 'register_id', 'type', 'amount', 'reason', 'user_id', 'created_at'],
  'audit_logs': ['id', 'user_id', 'action', 'entity_type', 'entity_id', 'old_values', 'new_values', 'ip_address', 'device_info', 'created_at'],
  'settings': ['key', 'value', 'updated_at'],
  'counters': ['branch_id', 'name', 'prefix', 'last_value'],
};

class SyncEngine {
  final db.AppDatabase database;
  final ApiClient apiClient;
  final String deviceId;

  /// The catalog repository (a separate Drift database). Optional so
  /// unit tests can construct a SyncEngine without a catalog DB; when
  /// present, [pull] also applies the server's catalog rows to it.
  final CatalogRepository? catalogRepository;

  SyncEngine({
    required this.database,
    required this.apiClient,
    required this.deviceId,
    this.catalogRepository,
  });

  /// Queues a local write for the next push. Used by code that writes
  /// to the database without going through a repository.
  Future<void> enqueue({
    required String tableName,
    required String operation,
    required Map<String, dynamic> payload,
    String? clientUuid,
  }) =>
      database.enqueueOutbox(
        tableName: tableName,
        operation: operation,
        payload: payload,
        clientUuid: clientUuid,
      );

  /// Number of operations still waiting to be pushed.
  Future<int> pendingCount() async {
    final row = await database.customSelect(
      'SELECT COUNT(*) AS cnt FROM outbox WHERE synced = 0',
    ).getSingle();
    return row.read<int>('cnt');
  }

  /// Pushes all unsynced outbox rows in creation order. Returns the
  /// number of sales the server accepted.
  ///
  /// ONLY sales push: the server's `POST /api/v1/sync/push` accepts
  /// `{ deviceId, sales: [...] }` and nothing else — there is no generic
  /// `{ device_id, operations }` endpoint (the old client shape was
  /// never implemented server-side). Convertible sales (`sales` table,
  /// `insert` operation, valid payload) are converted to the server's
  /// sale shape (see [_saleToSyncPayload]) and sent. Non-sale outbox
  /// rows (products, customers, purchases, repairs, expenses, ...) and
  /// non-`insert` sale rows (e.g. a cancel update) are LEFT PENDING —
  /// they are never marked synced, because the server has no endpoint
  /// that could have applied them; pretending otherwise would lose
  /// data. They sync when their normal online API call succeeds
  /// (see `docs/sync.md` §3.1).
  ///
  /// Response handling: `accepted` + `skipped` (`already_synced`) rows
  /// are marked synced; `errors` rows are logged via [_handleConflict]
  /// (which also marks them synced so a permanently rejected sale is
  /// not retried forever — the conflict is preserved in `sync_logs`
  /// and, for IMEI errors, flagged on the local sale's notes). A sale
  /// that was sent but appears in NONE of the three lists is left
  /// pending: its outcome is unknown, and retrying is safe because
  /// the server applies sales idempotently by `clientUuid`.
  Future<int> push() async {
    final rows = await (database.select(database.outbox)
          ..where((t) => t.synced.equals(false))
          ..orderBy([(t) => OrderingTerm.asc(t.createdAt)]))
        .get();
    if (rows.isEmpty) return 0;

    // Partition: convertible sales vs. everything else (stays pending).
    final saleRows = <db.OutboxData>[];
    var pendingNonSale = 0;
    for (final row in rows) {
      if (row.entityTable == 'sales' && row.operation == 'insert') {
        saleRows.add(row);
      } else {
        pendingNonSale++;
      }
    }

    // Convert each sale to the server's sale shape. Rows that cannot be
    // converted (bad payload, unknown IMEI, ...) are conflicts, not
    // retries: log + flag them and mark them synced so they do not
    // block the queue forever.
    final sales = <Map<String, dynamic>>[];
    final saleByClientUuid = <String, db.OutboxData>{};
    final unconvertible = <Map<String, dynamic>>[];
    for (final row in saleRows) {
      final converted = await _saleToSyncPayload(row);
      if (converted == null) {
        unconvertible.add({
          'client_uuid': row.clientUuid,
          'table_name': 'sales',
          'reason': _lastConversionError ??
              'Sale payload cannot be converted to the sync format',
        });
      } else {
        sales.add(converted);
        saleByClientUuid[_syncClientUuid(converted)] = row;
      }
    }
    if (unconvertible.isNotEmpty) {
      await database.transaction(() async {
        for (final conflict in unconvertible) {
          await _handleConflict(conflict, saleRows);
        }
      });
    }

    var accepted = 0;
    var skipped = 0;
    var errorCount = 0;
    if (sales.isNotEmpty) {
      final data = await apiClient.post('/api/v1/sync/push', data: {
        'deviceId': deviceId,
        'sales': sales,
      });
      final acceptedUuids = <String>{};
      final skippedUuids = <String>{};
      final errors = <Map<String, dynamic>>[];
      if (data is Map<String, dynamic>) {
        final acceptedRaw = data['accepted'];
        if (acceptedRaw is List) {
          for (final e in acceptedRaw) {
            if (e is Map) {
              final uuid = _syncClientUuid(e.cast<String, dynamic>());
              if (uuid.isNotEmpty) acceptedUuids.add(uuid);
            }
          }
        }
        final skippedRaw = data['skipped'];
        if (skippedRaw is List) {
          for (final e in skippedRaw) {
            if (e is Map) {
              final uuid = _syncClientUuid(e.cast<String, dynamic>());
              if (uuid.isNotEmpty) skippedUuids.add(uuid);
            }
          }
        }
        final errorsRaw = data['errors'];
        if (errorsRaw is List) {
          for (final e in errorsRaw) {
            if (e is Map) {
              final m = e.cast<String, dynamic>();
              errors.add({
                'client_uuid': _syncClientUuid(m),
                'table_name': 'sales',
                'reason': (m['error'] ?? m['reason'] ?? 'push failed')
                    .toString(),
              });
            }
          }
        }
      }
      await database.transaction(() async {
        for (final uuid in {...acceptedUuids, ...skippedUuids}) {
          final row = saleByClientUuid[uuid];
          if (row == null) continue;
          await (database.update(database.outbox)
                ..where((t) => t.id.equals(row.id)))
              .write(const db.OutboxCompanion(synced: Value(true)));
          if (acceptedUuids.contains(uuid)) accepted++;
          if (skippedUuids.contains(uuid)) skipped++;
        }
        for (final conflict in errors) {
          await _handleConflict(conflict, saleRows);
        }
        errorCount = errors.length;
      });
    }
    await _writeSyncLog(
      entityType: 'sync',
      action: 'push',
      detail: {
        'sent': sales.length,
        'accepted': accepted,
        'skipped': skipped,
        'errors': errorCount,
        'unconvertible': unconvertible.length,
        'pending_non_sale': pendingNonSale,
      },
    );
    return accepted;
  }

  /// Reads a server `clientUuid`/`client_uuid` value from either the
  /// camelCase shape (`skipped`/`errors` entries) or the snake_case
  /// shape (created-bill rows in `accepted`).
  String _syncClientUuid(Map<String, dynamic> entry) =>
      (entry['clientUuid'] ?? entry['client_uuid'] ?? '').toString();

  /// Last conversion failure from [_saleToSyncPayload], for the
  /// conflict log. Null when the last conversion succeeded.
  String? _lastConversionError;

  static const _uuidPattern =
      r'^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-'
      r'[0-9a-fA-F]{4}-[0-9a-fA-F]{12}$';

  static bool _isUuid(dynamic value) =>
      value is String && RegExp(_uuidPattern).hasMatch(value);

  /// Picks the first present key (snake_case first, then camelCase).
  static dynamic _pick(Map<String, dynamic> map, List<String> keys) {
    for (final key in keys) {
      if (map.containsKey(key) && map[key] != null) return map[key];
    }
    return null;
  }

  static int? _asInt(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    if (value is String) return int.tryParse(value);
    return null;
  }

  static const _paymentMethods = {
    'cash',
    'jazzcash',
    'easypaisa',
    'bank_transfer',
    'card',
    'partial',
    'udhaar',
  };

  /// Converts one outbox `sales`/`insert` row into the server's sync
  /// sale shape. Returns null (and sets [_lastConversionError]) when
  /// the row cannot be pushed as a sale at all. The outbox row's own
  /// `clientUuid` is NOT the sale's key — the sale's idempotency key
  /// is the `client_uuid` stored in the payload (`Sale.clientUuid`,
  /// set when the bill was created); the outbox key is only a
  /// fallback. Phone lines resolve their local `imei_item_id` to the
  /// IMEI number the server expects; an unresolvable IMEI fails the
  /// conversion (the sale is flagged, never sent with a guessed IMEI).
  Future<Map<String, dynamic>?> _saleToSyncPayload(
      db.OutboxData row) async {
    _lastConversionError = null;
    Map<String, dynamic> payload;
    try {
      payload = jsonDecode(row.payload) as Map<String, dynamic>;
    } catch (_) {
      _lastConversionError = 'Outbox payload is not valid JSON';
      return null;
    }
    final clientUuid = _pick(payload, ['client_uuid', 'clientUuid'])
        ?.toString();
    final effectiveUuid =
        _isUuid(clientUuid) ? clientUuid! : row.clientUuid;
    if (!_isUuid(effectiveUuid)) {
      _lastConversionError =
          'Sale has no valid client_uuid (idempotency key)';
      return null;
    }
    final itemsRaw = _pick(payload, ['items']);
    if (itemsRaw is! List || itemsRaw.isEmpty) {
      _lastConversionError = 'Sale has no items';
      return null;
    }
    final items = <Map<String, dynamic>>[];
    for (final raw in itemsRaw) {
      if (raw is! Map) {
        _lastConversionError = 'Sale has a malformed item';
        return null;
      }
      final item = raw.cast<String, dynamic>();
      final variantId =
          _pick(item, ['variant_id', 'variantId'])?.toString();
      if (!_isUuid(variantId)) {
        _lastConversionError =
            'Sale item has no valid variant_id (variant $variantId)';
        return null;
      }
      final quantity = _asInt(_pick(item, ['quantity'])) ?? 1;
      final unitPrice = _asInt(_pick(item, ['unit_price', 'unitPrice']));
      final discount =
          _asInt(_pick(item, ['discount'])) ?? 0;
      if (quantity < 1 || unitPrice == null || unitPrice < 0 || discount < 0) {
        _lastConversionError =
            'Sale item has invalid quantity/price/discount';
        return null;
      }
      String? imei1;
      final imeiItemId =
          _pick(item, ['imei_item_id', 'imeiItemId'])?.toString();
      if (imeiItemId != null && imeiItemId.isNotEmpty) {
        final imeiRow = await (database.select(database.imeiItems)
              ..where((t) => t.id.equals(imeiItemId)))
            .getSingleOrNull();
        if (imeiRow == null) {
          _lastConversionError =
              'IMEI item $imeiItemId not found locally; '
              'cannot push a phone sale without its IMEI number';
          return null;
        }
        imei1 = imeiRow.imei1;
      }
      items.add({
        'variantId': variantId,
        'imei1': imei1,
        'quantity': quantity,
        'unitPrice': unitPrice,
        'discount': discount,
      });
    }
    final paidAmount =
        _asInt(_pick(payload, ['paid_amount', 'paidAmount']));
    if (paidAmount == null || paidAmount < 0) {
      _lastConversionError = 'Sale has no valid paid_amount';
      return null;
    }
    final paymentMethod =
        _pick(payload, ['payment_method', 'paymentMethod'])?.toString() ??
            'cash';
    if (!_paymentMethods.contains(paymentMethod)) {
      _lastConversionError =
          'Sale has unknown payment_method "$paymentMethod"';
      return null;
    }
    final discountPercentRaw =
        _pick(payload, ['discount_percent', 'discountPercent']);
    final discountPercent = discountPercentRaw is num
        ? discountPercentRaw.toDouble()
        : double.tryParse(discountPercentRaw?.toString() ?? '') ?? 0;
    if (discountPercent < 0 || discountPercent > 100) {
      _lastConversionError = 'Sale discount_percent out of range 0–100';
      return null;
    }
    final customerId =
        _pick(payload, ['customer_id', 'customerId'])?.toString();
    final adminApprovedBy =
        _pick(payload, ['admin_approved_by', 'adminApprovedBy'])
            ?.toString();
    return {
      'clientUuid': effectiveUuid,
      'customerId': _isUuid(customerId) ? customerId : null,
      'customerName':
          _pick(payload, ['customer_name', 'customerName'])?.toString(),
      'customerPhone':
          _pick(payload, ['customer_phone', 'customerPhone'])?.toString(),
      'items': items,
      'discountAmount':
          _asInt(_pick(payload, ['discount_amount', 'discountAmount'])) ?? 0,
      'discountPercent': discountPercent,
      'taxAmount':
          _asInt(_pick(payload, ['tax_amount', 'taxAmount'])) ?? 0,
      'paidAmount': paidAmount,
      'paymentMethod': paymentMethod,
      'notes': _pick(payload, ['notes'])?.toString(),
      // A non-UUID value (e.g. an admin's name) is dropped rather
      // than 400ing the whole sale; a below-min-price sale then fails
      // with the server's MIN_PRICE_APPROVAL_REQUIRED error instead.
      'adminApprovedBy':
          _isUuid(adminApprovedBy) ? adminApprovedBy : null,
    };
  }

  Future<void> _handleConflict(
    Map<String, dynamic> conflict,
    List<db.OutboxData> sentRows,
  ) async {
    final clientUuid = conflict['client_uuid']?.toString();
    final reason = conflict['reason']?.toString() ?? 'conflict';
    final tableName = conflict['table_name']?.toString() ?? '';
    db.OutboxData? row;
    if (clientUuid != null) {
      for (final r in sentRows) {
        // The server keys sales by the SALE's client_uuid (stored in
        // the payload), which differs from the outbox row's own
        // clientUuid (a separate key generated when the row was queued).
        // Match on either.
        if (r.clientUuid == clientUuid) {
          row = r;
          break;
        }
        try {
          final payload =
              jsonDecode(r.payload) as Map<String, dynamic>;
          if (payload['client_uuid']?.toString() == clientUuid ||
              payload['clientUuid']?.toString() == clientUuid) {
            row = r;
            break;
          }
        } catch (_) {
          // Unparseable payload: cannot match by sale key.
        }
      }
    }
    await _writeSyncLog(
      entityType: tableName.isEmpty ? 'sync' : tableName,
      action: 'conflict',
      detail: {'client_uuid': clientUuid, 'reason': reason},
    );
    // Mark the conflicted outbox row synced so it is not retried
    // forever; the conflict itself is preserved in sync_logs.
    if (row != null) {
      await (database.update(database.outbox)
            ..where((t) => t.id.equals(row!.id)))
          .write(const db.OutboxCompanion(synced: Value(true)));
    }
    // IMEI conflict on a sale: flag the local sale visibly. The sale
    // is never silently overwritten or deleted.
    if (tableName == 'sales' &&
        reason.toLowerCase().contains('imei') &&
        row != null) {
      try {
        final payload =
            jsonDecode(row.payload) as Map<String, dynamic>;
        final saleId = payload['id']?.toString();
        if (saleId != null) {
          final saleRow = await (database.select(database.sales)
                ..where((t) => t.id.equals(saleId)))
              .getSingleOrNull();
          if (saleRow != null &&
              !(saleRow.notes ?? '').contains('SYNC CONFLICT')) {
            await (database.update(database.sales)
                  ..where((t) => t.id.equals(saleId)))
                .write(db.SalesCompanion(
                  notes: Value(
                      '${saleRow.notes ?? ''} [SYNC CONFLICT: $reason]'
                          .trim()),
                  updatedAt: Value(DateTime.now()),
                ));
          }
        }
      } catch (_) {
        // Flagging is best-effort; the sync_logs row already records it.
      }
    }
  }

  /// Pulls server changes since the last pull (or all changes on the
  /// first pull) and applies them. Returns the number of records applied.
  ///
  /// The server returns per-table arrays, NOT a `changes` list:
  /// `{ serverTime, products[], variants[], customers[], suppliers[],
  /// sales[], settings, catalog[] }`. `variants` maps to the local
  /// `product_variants` table; `settings` is a flat `{ key: value }`
  /// object (each value is JSON-encoded into the local `settings`
  /// table, whose `value` column holds JSON text). `catalog` is the
  /// Accessories Master Catalog, applied to the separate local catalog
  /// database. Master data is applied server-wins (INSERT OR REPLACE);
  /// sales are append-only (INSERT OR IGNORE — a pulled sale never
  /// overwrites a local one). The IMEI safety rule in [_applyChange]
  /// still applies: a locally-sold IMEI is never reverted to
  /// `available` by a pull.
  Future<int> pull() async {
    final since = await _lastPullAt();
    final query = <String, dynamic>{};
    if (since != null) query['since'] = since.toIso8601String();
    final data = await apiClient.get('/api/v1/sync/pull',
        queryParameters: query);
    final changes = <Map<String, dynamic>>[];
    var serverTime = DateTime.now();
    var received = 0;
    // Catalog rows are applied directly (not via `changes`), so their
    // count is tracked separately and folded into `applied` below.
    var catalogApplied = 0;
    if (data is Map<String, dynamic>) {
      // Real backend shape: one array per table.
      const tableArrays = {
        'products': 'products',
        'variants': 'product_variants',
        'customers': 'customers',
        'suppliers': 'suppliers',
        'sales': 'sales',
      };
      for (final entry in tableArrays.entries) {
        final raw = data[entry.key];
        if (raw is List) {
          received += raw.length;
          for (final record in raw) {
            if (record is Map) {
              changes.add({
                'table_name': entry.value,
                'operation': 'upsert',
                'record': record.cast<String, dynamic>(),
              });
            }
          }
        }
      }
      final settingsRaw = data['settings'];
      if (settingsRaw is Map) {
        received += settingsRaw.length;
        for (final setting in settingsRaw.entries) {
          changes.add({
            'table_name': 'settings',
            'operation': 'upsert',
            // Local settings values are JSON-encoded text.
            'record': {
              'key': setting.key.toString(),
              'value': jsonEncode(setting.value),
            },
          });
        }
      }
      // Accessories Master Catalog: it lives in a separate local
      // database (CatalogDatabase), so it is NOT routed through the
      // main `_applyChange` loop. Apply it here via the catalog
      // repository — new SKUs are inserted, existing non-custom items
      // get their estimated prices refreshed, local stock and custom
      // items are never touched.
      final catalogRaw = data['catalog'];
      if (catalogRaw is List && catalogRaw.isNotEmpty) {
        final repo = catalogRepository;
        if (repo != null) {
          final items = catalogRaw
              .whereType<Map>()
              .map((e) =>
                  CatalogItem.fromJson(e.cast<String, dynamic>()))
              .where((item) => item.sku.isNotEmpty)
              .toList();
          if (items.isNotEmpty) {
            received += items.length;
            final st0 = data['server_time'] ?? data['serverTime'];
            final version = st0 is String
                ? 'sync-$st0'
                : 'sync-${DateTime.now().toIso8601String()}';
            await repo.applyCatalogUpdate(items, version);
            catalogApplied += items.length;
          }
        }
      }
      final st = data['server_time'] ?? data['serverTime'];
      if (st is String) {
        serverTime = DateTime.tryParse(st) ?? serverTime;
      }
    } else if (data is List) {
      // Defensive: a `changes`-style list, if a future server sends one.
      changes.addAll(data
          .whereType<Map>()
          .map((e) => e.cast<String, dynamic>()));
      received = changes.length;
    }
    var applied = 0;
    applied += catalogApplied;
    await database.transaction(() async {
      for (final change in changes) {
        final appliedOne = await _applyChange(change);
        if (appliedOne) applied++;
      }
      await _setLastPullAt(serverTime);
      await _writeSyncLog(
        entityType: 'sync',
        action: 'pull',
        detail: {'received': received, 'applied': applied},
      );
    });
    return applied;
  }

  /// Push then pull. This is the normal sync entry point.
  ///
  /// Guarded against overlapping runs: login, dashboard load and the
  /// Settings "Sync now" button can all trigger a sync close together
  /// (and a periodic timer may fire while one is in flight). A second
  /// concurrent sync returns a neutral result instead of running a
  /// second overlapping push/pull, which could double-apply changes.
  bool _isSyncing = false;

  Future<SyncResult> sync() async {
    if (_isSyncing) {
      return SyncResult(lastSyncAt: DateTime.now());
    }
    _isSyncing = true;
    try {
      final pushed = await push();
      final pulled = await pull();
      final conflictsRow = await database.customSelect(
        'SELECT COUNT(*) AS cnt FROM sync_logs WHERE action = ? '
        'AND created_at >= ?',
        variables: [
          Variable.withString('conflict'),
          Variable.withDateTime(
              DateTime.now().subtract(const Duration(hours: 1))),
        ],
      ).getSingle();
      return SyncResult(
        pushed: pushed,
        pulled: pulled,
        conflicts: conflictsRow.read<int>('cnt'),
        lastSyncAt: DateTime.now(),
      );
    } finally {
      _isSyncing = false;
    }
  }

  // -- Pull application ------------------------------------------------------

  Future<bool> _applyChange(Map<String, dynamic> change) async {
    final table = change['table_name']?.toString() ??
        change['table']?.toString() ??
        '';
    final operation = (change['operation']?.toString() ?? 'upsert')
        .toLowerCase();
    final recordRaw = change['record'];
    if (table.isEmpty || !_tableColumns.containsKey(table)) return false;
    if (operation == 'delete') {
      final id = (recordRaw is Map ? recordRaw['id'] : null)?.toString() ??
          change['id']?.toString();
      if (id == null || !_masterTables.contains(table)) return false;
      await database.customStatement('DELETE FROM $table WHERE id = ?', [id]);
      return true;
    }
    if (recordRaw is! Map) return false;
    final record = recordRaw.cast<String, dynamic>();
    // IMEI safety: a locally-sold IMEI is never reverted to available
    // by a pull; the first sale wins and the conflict surfaces on push.
    if (table == 'imei_items') {
      final id = record['id']?.toString();
      final serverStatus = record['status']?.toString();
      if (id != null && serverStatus == 'available') {
        final local = await (database.select(database.imeiItems)
              ..where((t) => t.id.equals(id)))
            .getSingleOrNull();
        if (local != null && local.status == 'sold') return false;
      }
    }
    final columns = _tableColumns[table]!;
    final names = <String>[];
    final values = <Object?>[];
    for (final column in columns) {
      if (!record.containsKey(column)) continue;
      names.add(column);
      values.add(_toSqlValue(record[column]));
    }
    if (names.isEmpty) return false;
    final placeholders = List.filled(names.length, '?').join(', ');
    final verb = _masterTables.contains(table)
        ? 'INSERT OR REPLACE'
        : 'INSERT OR IGNORE';
    await database.customStatement(
      '$verb INTO $table (${names.join(', ')}) VALUES ($placeholders)',
      values,
    );
    return true;
  }

  Object? _toSqlValue(dynamic value) {
    if (value == null) return null;
    if (value is bool) return value ? 1 : 0;
    if (value is DateTime) return value.millisecondsSinceEpoch;
    if (value is String) {
      final parsed = DateTime.tryParse(value);
      // ISO date strings become epoch millis; other strings pass through.
      if (parsed != null &&
          RegExp(r'^\d{4}-\d{2}-\d{2}').hasMatch(value)) {
        return parsed.millisecondsSinceEpoch;
      }
      return value;
    }
    if (value is Map || value is List) return jsonEncode(value);
    if (value is num) return value;
    return value.toString();
  }

  // -- Bookkeeping -----------------------------------------------------------

  Future<DateTime?> _lastPullAt() async {
    final row = await (database.select(database.appSettings)
          ..where((t) => t.key.equals('sync.last_pull_at')))
        .getSingleOrNull();
    if (row == null) return null;
    try {
      final decoded = jsonDecode(row.value);
      if (decoded is String) return DateTime.tryParse(decoded);
    } catch (_) {
      return null;
    }
    return null;
  }

  Future<void> _setLastPullAt(DateTime when) async {
    final encoded = jsonEncode(when.toIso8601String());
    final existing = await (database.select(database.appSettings)
          ..where((t) => t.key.equals('sync.last_pull_at')))
        .getSingleOrNull();
    if (existing == null) {
      await database.into(database.appSettings).insert(
            db.AppSettingsCompanion.insert(
              key: 'sync.last_pull_at',
              value: encoded,
              updatedAt: Value(when),
            ),
          );
    } else {
      await (database.update(database.appSettings)
            ..where((t) => t.key.equals('sync.last_pull_at')))
          .write(db.AppSettingsCompanion(
            value: Value(encoded),
            updatedAt: Value(when),
          ));
    }
  }

  Future<void> _writeSyncLog({
    required String entityType,
    String? entityId,
    required String action,
    Map<String, dynamic>? detail,
  }) async {
    await database.into(database.syncLogs).insert(
          db.SyncLogsCompanion.insert(
            id: db.newUuid(),
            deviceId: deviceId,
            entityType: entityType,
            entityId: Value(entityId),
            action: action,
            detail: Value(detail == null ? null : jsonEncode(detail)),
            createdAt: Value(DateTime.now()),
          ),
        );
  }
}
