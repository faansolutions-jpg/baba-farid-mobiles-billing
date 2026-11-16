/// Settings repository: shop profile, tax, printer and app preferences.
///
/// Settings live as key/value rows in the `settings` table
/// (`shop.name`, `tax.rate`, ...); the repository converts them to and
/// from the [Settings] aggregate. Every write is audit-logged and
/// queued in the outbox.
library;

import 'dart:convert';

import 'package:drift/drift.dart';

import '../../domain/models/settings.dart';
import '../database/app_database.dart' as db;

abstract class SettingsRepository {
  /// The full settings aggregate (defaults where no row exists yet).
  Future<Settings> getSettings();

  /// Saves the whole aggregate (upserts every key).
  Future<Settings> saveSettings(Settings settings, {String? userId});

  /// One raw setting value (decoded JSON), or null when unset.
  Future<dynamic> getValue(String key);

  /// Sets one setting key.
  Future<void> setValue(String key, dynamic value, {String? userId});
}

class DriftSettingsRepository implements SettingsRepository {
  final db.AppDatabase database;

  DriftSettingsRepository(this.database);

  Future<Map<String, dynamic>> _allValues() async {
    final rows = await database.select(database.appSettings).get();
    final values = <String, dynamic>{};
    for (final row in rows) {
      try {
        values[row.key] = jsonDecode(row.value);
      } catch (_) {
        values[row.key] = row.value;
      }
    }
    return values;
  }

  @override
  Future<Settings> getSettings() async {
    return Settings.fromKeyValues(await _allValues());
  }

  @override
  Future<Settings> saveSettings(Settings settings,
      {String? userId}) async {
    final values = settings.toKeyValues();
    await database.transaction(() async {
      for (final entry in values.entries) {
        await _upsert(entry.key, entry.value);
      }
      await database.writeAudit(
        userId: userId,
        action: 'update',
        entityType: 'settings',
        newValues: values,
      );
      await database.enqueueOutbox(
        tableName: 'settings',
        operation: 'update',
        payload: values,
      );
    });
    return settings;
  }

  @override
  Future<dynamic> getValue(String key) async {
    final row = await (database.select(database.appSettings)
          ..where((t) => t.key.equals(key)))
        .getSingleOrNull();
    if (row == null) return null;
    try {
      return jsonDecode(row.value);
    } catch (_) {
      return row.value;
    }
  }

  @override
  Future<void> setValue(String key, dynamic value, {String? userId}) async {
    await database.transaction(() async {
      await _upsert(key, value);
      await database.writeAudit(
        userId: userId,
        action: 'update',
        entityType: 'settings',
        entityId: key,
        newValues: {key: value},
      );
      await database.enqueueOutbox(
        tableName: 'settings',
        operation: 'update',
        payload: {key: value},
      );
    });
  }

  Future<void> _upsert(String key, dynamic value) async {
    final encoded = jsonEncode(value);
    final existing = await (database.select(database.appSettings)
          ..where((t) => t.key.equals(key)))
        .getSingleOrNull();
    if (existing == null) {
      await database.into(database.appSettings).insert(
            db.AppSettingsCompanion.insert(
              key: key,
              value: encoded,
              updatedAt: Value(DateTime.now()),
            ),
          );
    } else {
      await (database.update(database.appSettings)
            ..where((t) => t.key.equals(key)))
          .write(db.AppSettingsCompanion(
            value: Value(encoded),
            updatedAt: Value(DateTime.now()),
          ));
    }
  }
}
