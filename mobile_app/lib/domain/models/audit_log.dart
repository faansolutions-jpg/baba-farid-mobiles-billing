/// AuditLog (+ SyncLog) models.
/// Mirrors `audit_logs` and `sync_logs` in schema.sql.
///
/// Hash chain (DECISIONS.md rule 10): each audit row stores `prevHash`
/// (the previous row's hash) and `hash` = SHA-256 of
/// `prevHash + action + entityType + entityId + newValues + createdAt`.
/// `prev_hash` / `hash` are **local-only columns** in the drift table —
/// the Postgres schema does not have them; they are dropped on sync.
library;

import 'dart:convert';
import 'package:crypto/crypto.dart';

DateTime? _dt(dynamic v) =>
    v == null ? null : (v is DateTime ? v : DateTime.tryParse(v.toString()));

/// Computes the hash-chain hash for an audit row.
String auditHash({
  required String prevHash,
  required String action,
  required String entityType,
  String? entityId,
  Map<String, dynamic>? newValues,
  required DateTime createdAt,
}) {
  final payload = [
    prevHash,
    action,
    entityType,
    entityId ?? '',
    newValues == null ? '' : jsonEncode(newValues),
    createdAt.toIso8601String(),
  ].join('|');
  return sha256.convert(utf8.encode(payload)).toString();
}

/// One append-only audit row.
class AuditLog {
  final String id;
  final String? userId;
  final String action;
  final String entityType;
  final String? entityId;
  final Map<String, dynamic>? oldValues;
  final Map<String, dynamic>? newValues;
  final String? ipAddress;
  final String? deviceInfo;
  final String prevHash;
  final String hash;
  final DateTime createdAt;

  const AuditLog({
    required this.id,
    this.userId,
    required this.action,
    required this.entityType,
    this.entityId,
    this.oldValues,
    this.newValues,
    this.ipAddress,
    this.deviceInfo,
    this.prevHash = '',
    required this.hash,
    required this.createdAt,
  });

  factory AuditLog.fromJson(Map<String, dynamic> json) => AuditLog(
        id: json['id'] as String,
        userId: json['user_id'] as String?,
        action: json['action'] as String,
        entityType: json['entity_type'] as String,
        entityId: json['entity_id'] as String?,
        oldValues: (json['old_values'] as Map?)?.cast<String, dynamic>(),
        newValues: (json['new_values'] as Map?)?.cast<String, dynamic>(),
        ipAddress: json['ip_address'] as String?,
        deviceInfo: json['device_info'] as String?,
        prevHash: json['prev_hash'] as String? ?? '',
        hash: json['hash'] as String? ?? '',
        createdAt: _dt(json['created_at']) ?? DateTime.now(),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'user_id': userId,
        'action': action,
        'entity_type': entityType,
        'entity_id': entityId,
        'old_values': oldValues,
        'new_values': newValues,
        'ip_address': ipAddress,
        'device_info': deviceInfo,
        'prev_hash': prevHash,
        'hash': hash,
        'created_at': createdAt.toIso8601String(),
      };

  AuditLog copyWith({
    String? id,
    String? userId,
    String? action,
    String? entityType,
    String? entityId,
    Map<String, dynamic>? oldValues,
    Map<String, dynamic>? newValues,
    String? ipAddress,
    String? deviceInfo,
    String? prevHash,
    String? hash,
    DateTime? createdAt,
  }) =>
      AuditLog(
        id: id ?? this.id,
        userId: userId ?? this.userId,
        action: action ?? this.action,
        entityType: entityType ?? this.entityType,
        entityId: entityId ?? this.entityId,
        oldValues: oldValues ?? this.oldValues,
        newValues: newValues ?? this.newValues,
        ipAddress: ipAddress ?? this.ipAddress,
        deviceInfo: deviceInfo ?? this.deviceInfo,
        prevHash: prevHash ?? this.prevHash,
        hash: hash ?? this.hash,
        createdAt: createdAt ?? this.createdAt,
      );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AuditLog &&
          other.id == id &&
          other.action == action &&
          other.entityType == entityType &&
          other.entityId == entityId &&
          other.hash == hash;

  @override
  int get hashCode => Object.hash(id, action, entityType, entityId, hash);
}

/// One sync event (`sync_logs` table): which device synced what, when.
class SyncLog {
  final String id;
  final String deviceId;
  final String? userId;
  final String entityType;
  final String? entityId;

  /// `push` | `pull` | `conflict`.
  final String action;
  final Map<String, dynamic>? detail;
  final DateTime createdAt;

  const SyncLog({
    required this.id,
    required this.deviceId,
    this.userId,
    required this.entityType,
    this.entityId,
    required this.action,
    this.detail,
    required this.createdAt,
  });

  factory SyncLog.fromJson(Map<String, dynamic> json) => SyncLog(
        id: json['id'] as String,
        deviceId: json['device_id'] as String,
        userId: json['user_id'] as String?,
        entityType: json['entity_type'] as String,
        entityId: json['entity_id'] as String?,
        action: json['action'] as String,
        detail: (json['detail'] as Map?)?.cast<String, dynamic>(),
        createdAt: _dt(json['created_at']) ?? DateTime.now(),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'device_id': deviceId,
        'user_id': userId,
        'entity_type': entityType,
        'entity_id': entityId,
        'action': action,
        'detail': detail,
        'created_at': createdAt.toIso8601String(),
      };

  SyncLog copyWith({
    String? id,
    String? deviceId,
    String? userId,
    String? entityType,
    String? entityId,
    String? action,
    Map<String, dynamic>? detail,
    DateTime? createdAt,
  }) =>
      SyncLog(
        id: id ?? this.id,
        deviceId: deviceId ?? this.deviceId,
        userId: userId ?? this.userId,
        entityType: entityType ?? this.entityType,
        entityId: entityId ?? this.entityId,
        action: action ?? this.action,
        detail: detail ?? this.detail,
        createdAt: createdAt ?? this.createdAt,
      );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SyncLog &&
          other.id == id &&
          other.deviceId == deviceId &&
          other.action == action;

  @override
  int get hashCode => Object.hash(id, deviceId, action);
}
