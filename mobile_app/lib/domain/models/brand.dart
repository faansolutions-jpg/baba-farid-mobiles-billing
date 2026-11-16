/// Brand model — mirrors the `brands` table in schema.sql.
library;

DateTime? _dt(dynamic v) =>
    v == null ? null : (v is DateTime ? v : DateTime.tryParse(v.toString()));

/// Product brand (Samsung, Infinix, Tecno, Apple, ...).
class Brand {
  final String id;
  final String name;
  final bool isActive;
  final DateTime createdAt;

  const Brand({
    required this.id,
    required this.name,
    this.isActive = true,
    required this.createdAt,
  });

  factory Brand.fromJson(Map<String, dynamic> json) => Brand(
        id: json['id'] as String,
        name: json['name'] as String,
        isActive: json['is_active'] as bool? ?? true,
        createdAt: _dt(json['created_at']) ?? DateTime.now(),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'is_active': isActive,
        'created_at': createdAt.toIso8601String(),
      };

  Brand copyWith({
    String? id,
    String? name,
    bool? isActive,
    DateTime? createdAt,
  }) =>
      Brand(
        id: id ?? this.id,
        name: name ?? this.name,
        isActive: isActive ?? this.isActive,
        createdAt: createdAt ?? this.createdAt,
      );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Brand &&
          other.id == id &&
          other.name == name &&
          other.isActive == isActive;

  @override
  int get hashCode => Object.hash(id, name, isActive);
}
