/// Domain models mirroring `database/schema.sql` tables `users`, `roles`
/// and `branches`. Money is integer whole PKR. JSON keys use the
/// schema's snake_case column names.
library;

DateTime? _dt(dynamic v) =>
    v == null ? null : (v is DateTime ? v : DateTime.tryParse(v.toString()));

/// A shop user (cashier / manager / owner). Mirrors the `users` table.
///
/// NOTE: this is the stored user record, not the login session. The login
/// session type is [AuthUser] in `lib/features/auth/auth_models.dart`
/// (owned by another agent) and is deliberately not redefined here.
class User {
  final String id;
  final String? branchId;
  final String roleId;

  /// Human-readable role name denormalised from `roles` (e.g. `owner`,
  /// `manager`, `cashier`). Null when not joined.
  final String? roleName;
  final String name;
  final String phone;
  final String? email;

  /// bcrypt hash. Never sent to the UI and never logged.
  final String? passwordHash;
  final bool isActive;
  final DateTime? lastLoginAt;
  final DateTime createdAt;
  final DateTime updatedAt;

  const User({
    required this.id,
    this.branchId,
    required this.roleId,
    this.roleName,
    required this.name,
    required this.phone,
    this.email,
    this.passwordHash,
    this.isActive = true,
    this.lastLoginAt,
    required this.createdAt,
    required this.updatedAt,
  });

  factory User.fromJson(Map<String, dynamic> json) => User(
        id: json['id'] as String,
        branchId: json['branch_id'] as String?,
        roleId: json['role_id'] as String,
        roleName: json['role_name'] as String?,
        name: json['name'] as String,
        phone: json['phone'] as String,
        email: json['email'] as String?,
        passwordHash: json['password_hash'] as String?,
        isActive: json['is_active'] as bool? ?? true,
        lastLoginAt: _dt(json['last_login_at']),
        createdAt: _dt(json['created_at']) ?? DateTime.now(),
        updatedAt: _dt(json['updated_at']) ?? DateTime.now(),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'branch_id': branchId,
        'role_id': roleId,
        'role_name': roleName,
        'name': name,
        'phone': phone,
        'email': email,
        'is_active': isActive,
        'last_login_at': lastLoginAt?.toIso8601String(),
        'created_at': createdAt.toIso8601String(),
        'updated_at': updatedAt.toIso8601String(),
      };

  User copyWith({
    String? id,
    String? branchId,
    String? roleId,
    String? roleName,
    String? name,
    String? phone,
    String? email,
    String? passwordHash,
    bool? isActive,
    DateTime? lastLoginAt,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) =>
      User(
        id: id ?? this.id,
        branchId: branchId ?? this.branchId,
        roleId: roleId ?? this.roleId,
        roleName: roleName ?? this.roleName,
        name: name ?? this.name,
        phone: phone ?? this.phone,
        email: email ?? this.email,
        passwordHash: passwordHash ?? this.passwordHash,
        isActive: isActive ?? this.isActive,
        lastLoginAt: lastLoginAt ?? this.lastLoginAt,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
      );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is User &&
          other.id == id &&
          other.branchId == branchId &&
          other.roleId == roleId &&
          other.name == name &&
          other.phone == phone &&
          other.email == email &&
          other.isActive == isActive;

  @override
  int get hashCode =>
      Object.hash(id, branchId, roleId, name, phone, email, isActive);
}

/// A role (`roles` table). Permissions are a JSON map such as
/// `{"sales.create": true, "cost.view": false}`.
class Role {
  final String id;
  final String name; // owner | manager | cashier
  final String? description;
  final Map<String, dynamic> permissions;
  final DateTime createdAt;

  const Role({
    required this.id,
    required this.name,
    this.description,
    this.permissions = const {},
    required this.createdAt,
  });

  factory Role.fromJson(Map<String, dynamic> json) => Role(
        id: json['id'] as String,
        name: json['name'] as String,
        description: json['description'] as String?,
        permissions: (json['permissions'] as Map?)?.cast<String, dynamic>() ?? {},
        createdAt: _dt(json['created_at']) ?? DateTime.now(),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'description': description,
        'permissions': permissions,
        'created_at': createdAt.toIso8601String(),
      };

  Role copyWith({
    String? id,
    String? name,
    String? description,
    Map<String, dynamic>? permissions,
    DateTime? createdAt,
  }) =>
      Role(
        id: id ?? this.id,
        name: name ?? this.name,
        description: description ?? this.description,
        permissions: permissions ?? this.permissions,
        createdAt: createdAt ?? this.createdAt,
      );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Role && other.id == id && other.name == name;

  @override
  int get hashCode => Object.hash(id, name);

  /// Convenience: does this role grant [permission]?
  bool can(String permission) => permissions[permission] == true;
}

/// A shop branch (`branches` table).
class Branch {
  final String id;
  final String name;
  final String? address;
  final String? phone;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Branch({
    required this.id,
    required this.name,
    this.address,
    this.phone,
    this.isActive = true,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Branch.fromJson(Map<String, dynamic> json) => Branch(
        id: json['id'] as String,
        name: json['name'] as String,
        address: json['address'] as String?,
        phone: json['phone'] as String?,
        isActive: json['is_active'] as bool? ?? true,
        createdAt: _dt(json['created_at']) ?? DateTime.now(),
        updatedAt: _dt(json['updated_at']) ?? DateTime.now(),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'address': address,
        'phone': phone,
        'is_active': isActive,
        'created_at': createdAt.toIso8601String(),
        'updated_at': updatedAt.toIso8601String(),
      };

  Branch copyWith({
    String? id,
    String? name,
    String? address,
    String? phone,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) =>
      Branch(
        id: id ?? this.id,
        name: name ?? this.name,
        address: address ?? this.address,
        phone: phone ?? this.phone,
        isActive: isActive ?? this.isActive,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
      );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Branch && other.id == id && other.name == name;

  @override
  int get hashCode => Object.hash(id, name);
}
