/// Category model — mirrors the `categories` table in schema.sql.
library;

DateTime? _dt(dynamic v) =>
    v == null ? null : (v is DateTime ? v : DateTime.tryParse(v.toString()));

/// Product category. `type` is one of `phone`, `accessory`, `service`.
class Category {
  final String id;
  final String name;
  final String type;
  final String? parentId;
  final bool isActive;
  final DateTime createdAt;

  const Category({
    required this.id,
    required this.name,
    required this.type,
    this.parentId,
    this.isActive = true,
    required this.createdAt,
  });

  factory Category.fromJson(Map<String, dynamic> json) => Category(
        id: json['id'] as String,
        name: json['name'] as String,
        type: json['type'] as String,
        parentId: json['parent_id'] as String?,
        isActive: json['is_active'] as bool? ?? true,
        createdAt: _dt(json['created_at']) ?? DateTime.now(),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'type': type,
        'parent_id': parentId,
        'is_active': isActive,
        'created_at': createdAt.toIso8601String(),
      };

  Category copyWith({
    String? id,
    String? name,
    String? type,
    String? parentId,
    bool? isActive,
    DateTime? createdAt,
  }) =>
      Category(
        id: id ?? this.id,
        name: name ?? this.name,
        type: type ?? this.type,
        parentId: parentId ?? this.parentId,
        isActive: isActive ?? this.isActive,
        createdAt: createdAt ?? this.createdAt,
      );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Category &&
          other.id == id &&
          other.name == name &&
          other.type == type &&
          other.parentId == parentId &&
          other.isActive == isActive;

  @override
  int get hashCode => Object.hash(id, name, type, parentId, isActive);
}
