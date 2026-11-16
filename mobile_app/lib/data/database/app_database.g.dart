// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $BranchesTable extends Branches with TableInfo<$BranchesTable, Branche> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $BranchesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
      'name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _addressMeta =
      const VerificationMeta('address');
  @override
  late final GeneratedColumn<String> address = GeneratedColumn<String>(
      'address', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _phoneMeta = const VerificationMeta('phone');
  @override
  late final GeneratedColumn<String> phone = GeneratedColumn<String>(
      'phone', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _isActiveMeta =
      const VerificationMeta('isActive');
  @override
  late final GeneratedColumn<bool> isActive = GeneratedColumn<bool>(
      'is_active', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("is_active" IN (0, 1))'),
      defaultValue: const Constant(true));
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  static const VerificationMeta _updatedAtMeta =
      const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
      'updated_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  @override
  List<GeneratedColumn> get $columns =>
      [id, name, address, phone, isActive, createdAt, updatedAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'branches';
  @override
  VerificationContext validateIntegrity(Insertable<Branche> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
          _nameMeta, name.isAcceptableOrUnknown(data['name']!, _nameMeta));
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('address')) {
      context.handle(_addressMeta,
          address.isAcceptableOrUnknown(data['address']!, _addressMeta));
    }
    if (data.containsKey('phone')) {
      context.handle(
          _phoneMeta, phone.isAcceptableOrUnknown(data['phone']!, _phoneMeta));
    }
    if (data.containsKey('is_active')) {
      context.handle(_isActiveMeta,
          isActive.isAcceptableOrUnknown(data['is_active']!, _isActiveMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    }
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta,
          updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Branche map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Branche(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      name: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}name'])!,
      address: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}address']),
      phone: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}phone']),
      isActive: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_active'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}updated_at'])!,
    );
  }

  @override
  $BranchesTable createAlias(String alias) {
    return $BranchesTable(attachedDatabase, alias);
  }
}

class Branche extends DataClass implements Insertable<Branche> {
  final String id;
  final String name;
  final String? address;
  final String? phone;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;
  const Branche(
      {required this.id,
      required this.name,
      this.address,
      this.phone,
      required this.isActive,
      required this.createdAt,
      required this.updatedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    if (!nullToAbsent || address != null) {
      map['address'] = Variable<String>(address);
    }
    if (!nullToAbsent || phone != null) {
      map['phone'] = Variable<String>(phone);
    }
    map['is_active'] = Variable<bool>(isActive);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  BranchesCompanion toCompanion(bool nullToAbsent) {
    return BranchesCompanion(
      id: Value(id),
      name: Value(name),
      address: address == null && nullToAbsent
          ? const Value.absent()
          : Value(address),
      phone:
          phone == null && nullToAbsent ? const Value.absent() : Value(phone),
      isActive: Value(isActive),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory Branche.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Branche(
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      address: serializer.fromJson<String?>(json['address']),
      phone: serializer.fromJson<String?>(json['phone']),
      isActive: serializer.fromJson<bool>(json['isActive']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
      'address': serializer.toJson<String?>(address),
      'phone': serializer.toJson<String?>(phone),
      'isActive': serializer.toJson<bool>(isActive),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  Branche copyWith(
          {String? id,
          String? name,
          Value<String?> address = const Value.absent(),
          Value<String?> phone = const Value.absent(),
          bool? isActive,
          DateTime? createdAt,
          DateTime? updatedAt}) =>
      Branche(
        id: id ?? this.id,
        name: name ?? this.name,
        address: address.present ? address.value : this.address,
        phone: phone.present ? phone.value : this.phone,
        isActive: isActive ?? this.isActive,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
      );
  Branche copyWithCompanion(BranchesCompanion data) {
    return Branche(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      address: data.address.present ? data.address.value : this.address,
      phone: data.phone.present ? data.phone.value : this.phone,
      isActive: data.isActive.present ? data.isActive.value : this.isActive,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Branche(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('address: $address, ')
          ..write('phone: $phone, ')
          ..write('isActive: $isActive, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, name, address, phone, isActive, createdAt, updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Branche &&
          other.id == this.id &&
          other.name == this.name &&
          other.address == this.address &&
          other.phone == this.phone &&
          other.isActive == this.isActive &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class BranchesCompanion extends UpdateCompanion<Branche> {
  final Value<String> id;
  final Value<String> name;
  final Value<String?> address;
  final Value<String?> phone;
  final Value<bool> isActive;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const BranchesCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.address = const Value.absent(),
    this.phone = const Value.absent(),
    this.isActive = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  BranchesCompanion.insert({
    required String id,
    required String name,
    this.address = const Value.absent(),
    this.phone = const Value.absent(),
    this.isActive = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        name = Value(name);
  static Insertable<Branche> custom({
    Expression<String>? id,
    Expression<String>? name,
    Expression<String>? address,
    Expression<String>? phone,
    Expression<bool>? isActive,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (address != null) 'address': address,
      if (phone != null) 'phone': phone,
      if (isActive != null) 'is_active': isActive,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  BranchesCompanion copyWith(
      {Value<String>? id,
      Value<String>? name,
      Value<String?>? address,
      Value<String?>? phone,
      Value<bool>? isActive,
      Value<DateTime>? createdAt,
      Value<DateTime>? updatedAt,
      Value<int>? rowid}) {
    return BranchesCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      address: address ?? this.address,
      phone: phone ?? this.phone,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (address.present) {
      map['address'] = Variable<String>(address.value);
    }
    if (phone.present) {
      map['phone'] = Variable<String>(phone.value);
    }
    if (isActive.present) {
      map['is_active'] = Variable<bool>(isActive.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('BranchesCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('address: $address, ')
          ..write('phone: $phone, ')
          ..write('isActive: $isActive, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $RolesTable extends Roles with TableInfo<$RolesTable, Role> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $RolesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
      'name', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'));
  static const VerificationMeta _descriptionMeta =
      const VerificationMeta('description');
  @override
  late final GeneratedColumn<String> description = GeneratedColumn<String>(
      'description', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _permissionsMeta =
      const VerificationMeta('permissions');
  @override
  late final GeneratedColumn<String> permissions = GeneratedColumn<String>(
      'permissions', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('{}'));
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  @override
  List<GeneratedColumn> get $columns =>
      [id, name, description, permissions, createdAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'roles';
  @override
  VerificationContext validateIntegrity(Insertable<Role> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
          _nameMeta, name.isAcceptableOrUnknown(data['name']!, _nameMeta));
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('description')) {
      context.handle(
          _descriptionMeta,
          description.isAcceptableOrUnknown(
              data['description']!, _descriptionMeta));
    }
    if (data.containsKey('permissions')) {
      context.handle(
          _permissionsMeta,
          permissions.isAcceptableOrUnknown(
              data['permissions']!, _permissionsMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Role map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Role(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      name: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}name'])!,
      description: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}description']),
      permissions: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}permissions'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
    );
  }

  @override
  $RolesTable createAlias(String alias) {
    return $RolesTable(attachedDatabase, alias);
  }
}

class Role extends DataClass implements Insertable<Role> {
  final String id;
  final String name;
  final String? description;
  final String permissions;
  final DateTime createdAt;
  const Role(
      {required this.id,
      required this.name,
      this.description,
      required this.permissions,
      required this.createdAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    if (!nullToAbsent || description != null) {
      map['description'] = Variable<String>(description);
    }
    map['permissions'] = Variable<String>(permissions);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  RolesCompanion toCompanion(bool nullToAbsent) {
    return RolesCompanion(
      id: Value(id),
      name: Value(name),
      description: description == null && nullToAbsent
          ? const Value.absent()
          : Value(description),
      permissions: Value(permissions),
      createdAt: Value(createdAt),
    );
  }

  factory Role.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Role(
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      description: serializer.fromJson<String?>(json['description']),
      permissions: serializer.fromJson<String>(json['permissions']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
      'description': serializer.toJson<String?>(description),
      'permissions': serializer.toJson<String>(permissions),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  Role copyWith(
          {String? id,
          String? name,
          Value<String?> description = const Value.absent(),
          String? permissions,
          DateTime? createdAt}) =>
      Role(
        id: id ?? this.id,
        name: name ?? this.name,
        description: description.present ? description.value : this.description,
        permissions: permissions ?? this.permissions,
        createdAt: createdAt ?? this.createdAt,
      );
  Role copyWithCompanion(RolesCompanion data) {
    return Role(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      description:
          data.description.present ? data.description.value : this.description,
      permissions:
          data.permissions.present ? data.permissions.value : this.permissions,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Role(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('description: $description, ')
          ..write('permissions: $permissions, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, name, description, permissions, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Role &&
          other.id == this.id &&
          other.name == this.name &&
          other.description == this.description &&
          other.permissions == this.permissions &&
          other.createdAt == this.createdAt);
}

class RolesCompanion extends UpdateCompanion<Role> {
  final Value<String> id;
  final Value<String> name;
  final Value<String?> description;
  final Value<String> permissions;
  final Value<DateTime> createdAt;
  final Value<int> rowid;
  const RolesCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.description = const Value.absent(),
    this.permissions = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  RolesCompanion.insert({
    required String id,
    required String name,
    this.description = const Value.absent(),
    this.permissions = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        name = Value(name);
  static Insertable<Role> custom({
    Expression<String>? id,
    Expression<String>? name,
    Expression<String>? description,
    Expression<String>? permissions,
    Expression<DateTime>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (description != null) 'description': description,
      if (permissions != null) 'permissions': permissions,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  RolesCompanion copyWith(
      {Value<String>? id,
      Value<String>? name,
      Value<String?>? description,
      Value<String>? permissions,
      Value<DateTime>? createdAt,
      Value<int>? rowid}) {
    return RolesCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      permissions: permissions ?? this.permissions,
      createdAt: createdAt ?? this.createdAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (description.present) {
      map['description'] = Variable<String>(description.value);
    }
    if (permissions.present) {
      map['permissions'] = Variable<String>(permissions.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('RolesCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('description: $description, ')
          ..write('permissions: $permissions, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $UsersTable extends Users with TableInfo<$UsersTable, User> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $UsersTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _branchIdMeta =
      const VerificationMeta('branchId');
  @override
  late final GeneratedColumn<String> branchId = GeneratedColumn<String>(
      'branch_id', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _roleIdMeta = const VerificationMeta('roleId');
  @override
  late final GeneratedColumn<String> roleId = GeneratedColumn<String>(
      'role_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
      'name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _phoneMeta = const VerificationMeta('phone');
  @override
  late final GeneratedColumn<String> phone = GeneratedColumn<String>(
      'phone', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'));
  static const VerificationMeta _emailMeta = const VerificationMeta('email');
  @override
  late final GeneratedColumn<String> email = GeneratedColumn<String>(
      'email', aliasedName, true,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'));
  static const VerificationMeta _passwordHashMeta =
      const VerificationMeta('passwordHash');
  @override
  late final GeneratedColumn<String> passwordHash = GeneratedColumn<String>(
      'password_hash', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _isActiveMeta =
      const VerificationMeta('isActive');
  @override
  late final GeneratedColumn<bool> isActive = GeneratedColumn<bool>(
      'is_active', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("is_active" IN (0, 1))'),
      defaultValue: const Constant(true));
  static const VerificationMeta _lastLoginAtMeta =
      const VerificationMeta('lastLoginAt');
  @override
  late final GeneratedColumn<DateTime> lastLoginAt = GeneratedColumn<DateTime>(
      'last_login_at', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  static const VerificationMeta _updatedAtMeta =
      const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
      'updated_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        branchId,
        roleId,
        name,
        phone,
        email,
        passwordHash,
        isActive,
        lastLoginAt,
        createdAt,
        updatedAt
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'users';
  @override
  VerificationContext validateIntegrity(Insertable<User> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('branch_id')) {
      context.handle(_branchIdMeta,
          branchId.isAcceptableOrUnknown(data['branch_id']!, _branchIdMeta));
    }
    if (data.containsKey('role_id')) {
      context.handle(_roleIdMeta,
          roleId.isAcceptableOrUnknown(data['role_id']!, _roleIdMeta));
    } else if (isInserting) {
      context.missing(_roleIdMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
          _nameMeta, name.isAcceptableOrUnknown(data['name']!, _nameMeta));
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('phone')) {
      context.handle(
          _phoneMeta, phone.isAcceptableOrUnknown(data['phone']!, _phoneMeta));
    } else if (isInserting) {
      context.missing(_phoneMeta);
    }
    if (data.containsKey('email')) {
      context.handle(
          _emailMeta, email.isAcceptableOrUnknown(data['email']!, _emailMeta));
    }
    if (data.containsKey('password_hash')) {
      context.handle(
          _passwordHashMeta,
          passwordHash.isAcceptableOrUnknown(
              data['password_hash']!, _passwordHashMeta));
    } else if (isInserting) {
      context.missing(_passwordHashMeta);
    }
    if (data.containsKey('is_active')) {
      context.handle(_isActiveMeta,
          isActive.isAcceptableOrUnknown(data['is_active']!, _isActiveMeta));
    }
    if (data.containsKey('last_login_at')) {
      context.handle(
          _lastLoginAtMeta,
          lastLoginAt.isAcceptableOrUnknown(
              data['last_login_at']!, _lastLoginAtMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    }
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta,
          updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  User map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return User(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      branchId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}branch_id']),
      roleId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}role_id'])!,
      name: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}name'])!,
      phone: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}phone'])!,
      email: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}email']),
      passwordHash: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}password_hash'])!,
      isActive: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_active'])!,
      lastLoginAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}last_login_at']),
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}updated_at'])!,
    );
  }

  @override
  $UsersTable createAlias(String alias) {
    return $UsersTable(attachedDatabase, alias);
  }
}

class User extends DataClass implements Insertable<User> {
  final String id;
  final String? branchId;
  final String roleId;
  final String name;
  final String phone;
  final String? email;
  final String passwordHash;
  final bool isActive;
  final DateTime? lastLoginAt;
  final DateTime createdAt;
  final DateTime updatedAt;
  const User(
      {required this.id,
      this.branchId,
      required this.roleId,
      required this.name,
      required this.phone,
      this.email,
      required this.passwordHash,
      required this.isActive,
      this.lastLoginAt,
      required this.createdAt,
      required this.updatedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    if (!nullToAbsent || branchId != null) {
      map['branch_id'] = Variable<String>(branchId);
    }
    map['role_id'] = Variable<String>(roleId);
    map['name'] = Variable<String>(name);
    map['phone'] = Variable<String>(phone);
    if (!nullToAbsent || email != null) {
      map['email'] = Variable<String>(email);
    }
    map['password_hash'] = Variable<String>(passwordHash);
    map['is_active'] = Variable<bool>(isActive);
    if (!nullToAbsent || lastLoginAt != null) {
      map['last_login_at'] = Variable<DateTime>(lastLoginAt);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  UsersCompanion toCompanion(bool nullToAbsent) {
    return UsersCompanion(
      id: Value(id),
      branchId: branchId == null && nullToAbsent
          ? const Value.absent()
          : Value(branchId),
      roleId: Value(roleId),
      name: Value(name),
      phone: Value(phone),
      email:
          email == null && nullToAbsent ? const Value.absent() : Value(email),
      passwordHash: Value(passwordHash),
      isActive: Value(isActive),
      lastLoginAt: lastLoginAt == null && nullToAbsent
          ? const Value.absent()
          : Value(lastLoginAt),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory User.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return User(
      id: serializer.fromJson<String>(json['id']),
      branchId: serializer.fromJson<String?>(json['branchId']),
      roleId: serializer.fromJson<String>(json['roleId']),
      name: serializer.fromJson<String>(json['name']),
      phone: serializer.fromJson<String>(json['phone']),
      email: serializer.fromJson<String?>(json['email']),
      passwordHash: serializer.fromJson<String>(json['passwordHash']),
      isActive: serializer.fromJson<bool>(json['isActive']),
      lastLoginAt: serializer.fromJson<DateTime?>(json['lastLoginAt']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'branchId': serializer.toJson<String?>(branchId),
      'roleId': serializer.toJson<String>(roleId),
      'name': serializer.toJson<String>(name),
      'phone': serializer.toJson<String>(phone),
      'email': serializer.toJson<String?>(email),
      'passwordHash': serializer.toJson<String>(passwordHash),
      'isActive': serializer.toJson<bool>(isActive),
      'lastLoginAt': serializer.toJson<DateTime?>(lastLoginAt),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  User copyWith(
          {String? id,
          Value<String?> branchId = const Value.absent(),
          String? roleId,
          String? name,
          String? phone,
          Value<String?> email = const Value.absent(),
          String? passwordHash,
          bool? isActive,
          Value<DateTime?> lastLoginAt = const Value.absent(),
          DateTime? createdAt,
          DateTime? updatedAt}) =>
      User(
        id: id ?? this.id,
        branchId: branchId.present ? branchId.value : this.branchId,
        roleId: roleId ?? this.roleId,
        name: name ?? this.name,
        phone: phone ?? this.phone,
        email: email.present ? email.value : this.email,
        passwordHash: passwordHash ?? this.passwordHash,
        isActive: isActive ?? this.isActive,
        lastLoginAt: lastLoginAt.present ? lastLoginAt.value : this.lastLoginAt,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
      );
  User copyWithCompanion(UsersCompanion data) {
    return User(
      id: data.id.present ? data.id.value : this.id,
      branchId: data.branchId.present ? data.branchId.value : this.branchId,
      roleId: data.roleId.present ? data.roleId.value : this.roleId,
      name: data.name.present ? data.name.value : this.name,
      phone: data.phone.present ? data.phone.value : this.phone,
      email: data.email.present ? data.email.value : this.email,
      passwordHash: data.passwordHash.present
          ? data.passwordHash.value
          : this.passwordHash,
      isActive: data.isActive.present ? data.isActive.value : this.isActive,
      lastLoginAt:
          data.lastLoginAt.present ? data.lastLoginAt.value : this.lastLoginAt,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('User(')
          ..write('id: $id, ')
          ..write('branchId: $branchId, ')
          ..write('roleId: $roleId, ')
          ..write('name: $name, ')
          ..write('phone: $phone, ')
          ..write('email: $email, ')
          ..write('passwordHash: $passwordHash, ')
          ..write('isActive: $isActive, ')
          ..write('lastLoginAt: $lastLoginAt, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, branchId, roleId, name, phone, email,
      passwordHash, isActive, lastLoginAt, createdAt, updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is User &&
          other.id == this.id &&
          other.branchId == this.branchId &&
          other.roleId == this.roleId &&
          other.name == this.name &&
          other.phone == this.phone &&
          other.email == this.email &&
          other.passwordHash == this.passwordHash &&
          other.isActive == this.isActive &&
          other.lastLoginAt == this.lastLoginAt &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class UsersCompanion extends UpdateCompanion<User> {
  final Value<String> id;
  final Value<String?> branchId;
  final Value<String> roleId;
  final Value<String> name;
  final Value<String> phone;
  final Value<String?> email;
  final Value<String> passwordHash;
  final Value<bool> isActive;
  final Value<DateTime?> lastLoginAt;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const UsersCompanion({
    this.id = const Value.absent(),
    this.branchId = const Value.absent(),
    this.roleId = const Value.absent(),
    this.name = const Value.absent(),
    this.phone = const Value.absent(),
    this.email = const Value.absent(),
    this.passwordHash = const Value.absent(),
    this.isActive = const Value.absent(),
    this.lastLoginAt = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  UsersCompanion.insert({
    required String id,
    this.branchId = const Value.absent(),
    required String roleId,
    required String name,
    required String phone,
    this.email = const Value.absent(),
    required String passwordHash,
    this.isActive = const Value.absent(),
    this.lastLoginAt = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        roleId = Value(roleId),
        name = Value(name),
        phone = Value(phone),
        passwordHash = Value(passwordHash);
  static Insertable<User> custom({
    Expression<String>? id,
    Expression<String>? branchId,
    Expression<String>? roleId,
    Expression<String>? name,
    Expression<String>? phone,
    Expression<String>? email,
    Expression<String>? passwordHash,
    Expression<bool>? isActive,
    Expression<DateTime>? lastLoginAt,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (branchId != null) 'branch_id': branchId,
      if (roleId != null) 'role_id': roleId,
      if (name != null) 'name': name,
      if (phone != null) 'phone': phone,
      if (email != null) 'email': email,
      if (passwordHash != null) 'password_hash': passwordHash,
      if (isActive != null) 'is_active': isActive,
      if (lastLoginAt != null) 'last_login_at': lastLoginAt,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  UsersCompanion copyWith(
      {Value<String>? id,
      Value<String?>? branchId,
      Value<String>? roleId,
      Value<String>? name,
      Value<String>? phone,
      Value<String?>? email,
      Value<String>? passwordHash,
      Value<bool>? isActive,
      Value<DateTime?>? lastLoginAt,
      Value<DateTime>? createdAt,
      Value<DateTime>? updatedAt,
      Value<int>? rowid}) {
    return UsersCompanion(
      id: id ?? this.id,
      branchId: branchId ?? this.branchId,
      roleId: roleId ?? this.roleId,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      passwordHash: passwordHash ?? this.passwordHash,
      isActive: isActive ?? this.isActive,
      lastLoginAt: lastLoginAt ?? this.lastLoginAt,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (branchId.present) {
      map['branch_id'] = Variable<String>(branchId.value);
    }
    if (roleId.present) {
      map['role_id'] = Variable<String>(roleId.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (phone.present) {
      map['phone'] = Variable<String>(phone.value);
    }
    if (email.present) {
      map['email'] = Variable<String>(email.value);
    }
    if (passwordHash.present) {
      map['password_hash'] = Variable<String>(passwordHash.value);
    }
    if (isActive.present) {
      map['is_active'] = Variable<bool>(isActive.value);
    }
    if (lastLoginAt.present) {
      map['last_login_at'] = Variable<DateTime>(lastLoginAt.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('UsersCompanion(')
          ..write('id: $id, ')
          ..write('branchId: $branchId, ')
          ..write('roleId: $roleId, ')
          ..write('name: $name, ')
          ..write('phone: $phone, ')
          ..write('email: $email, ')
          ..write('passwordHash: $passwordHash, ')
          ..write('isActive: $isActive, ')
          ..write('lastLoginAt: $lastLoginAt, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $CategoriesTable extends Categories
    with TableInfo<$CategoriesTable, Category> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CategoriesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
      'name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _typeMeta = const VerificationMeta('type');
  @override
  late final GeneratedColumn<String> type = GeneratedColumn<String>(
      'type', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _parentIdMeta =
      const VerificationMeta('parentId');
  @override
  late final GeneratedColumn<String> parentId = GeneratedColumn<String>(
      'parent_id', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _isActiveMeta =
      const VerificationMeta('isActive');
  @override
  late final GeneratedColumn<bool> isActive = GeneratedColumn<bool>(
      'is_active', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("is_active" IN (0, 1))'),
      defaultValue: const Constant(true));
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  @override
  List<GeneratedColumn> get $columns =>
      [id, name, type, parentId, isActive, createdAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'categories';
  @override
  VerificationContext validateIntegrity(Insertable<Category> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
          _nameMeta, name.isAcceptableOrUnknown(data['name']!, _nameMeta));
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('type')) {
      context.handle(
          _typeMeta, type.isAcceptableOrUnknown(data['type']!, _typeMeta));
    } else if (isInserting) {
      context.missing(_typeMeta);
    }
    if (data.containsKey('parent_id')) {
      context.handle(_parentIdMeta,
          parentId.isAcceptableOrUnknown(data['parent_id']!, _parentIdMeta));
    }
    if (data.containsKey('is_active')) {
      context.handle(_isActiveMeta,
          isActive.isAcceptableOrUnknown(data['is_active']!, _isActiveMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Category map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Category(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      name: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}name'])!,
      type: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}type'])!,
      parentId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}parent_id']),
      isActive: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_active'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
    );
  }

  @override
  $CategoriesTable createAlias(String alias) {
    return $CategoriesTable(attachedDatabase, alias);
  }
}

class Category extends DataClass implements Insertable<Category> {
  final String id;
  final String name;
  final String type;
  final String? parentId;
  final bool isActive;
  final DateTime createdAt;
  const Category(
      {required this.id,
      required this.name,
      required this.type,
      this.parentId,
      required this.isActive,
      required this.createdAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    map['type'] = Variable<String>(type);
    if (!nullToAbsent || parentId != null) {
      map['parent_id'] = Variable<String>(parentId);
    }
    map['is_active'] = Variable<bool>(isActive);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  CategoriesCompanion toCompanion(bool nullToAbsent) {
    return CategoriesCompanion(
      id: Value(id),
      name: Value(name),
      type: Value(type),
      parentId: parentId == null && nullToAbsent
          ? const Value.absent()
          : Value(parentId),
      isActive: Value(isActive),
      createdAt: Value(createdAt),
    );
  }

  factory Category.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Category(
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      type: serializer.fromJson<String>(json['type']),
      parentId: serializer.fromJson<String?>(json['parentId']),
      isActive: serializer.fromJson<bool>(json['isActive']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
      'type': serializer.toJson<String>(type),
      'parentId': serializer.toJson<String?>(parentId),
      'isActive': serializer.toJson<bool>(isActive),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  Category copyWith(
          {String? id,
          String? name,
          String? type,
          Value<String?> parentId = const Value.absent(),
          bool? isActive,
          DateTime? createdAt}) =>
      Category(
        id: id ?? this.id,
        name: name ?? this.name,
        type: type ?? this.type,
        parentId: parentId.present ? parentId.value : this.parentId,
        isActive: isActive ?? this.isActive,
        createdAt: createdAt ?? this.createdAt,
      );
  Category copyWithCompanion(CategoriesCompanion data) {
    return Category(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      type: data.type.present ? data.type.value : this.type,
      parentId: data.parentId.present ? data.parentId.value : this.parentId,
      isActive: data.isActive.present ? data.isActive.value : this.isActive,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Category(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('type: $type, ')
          ..write('parentId: $parentId, ')
          ..write('isActive: $isActive, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, name, type, parentId, isActive, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Category &&
          other.id == this.id &&
          other.name == this.name &&
          other.type == this.type &&
          other.parentId == this.parentId &&
          other.isActive == this.isActive &&
          other.createdAt == this.createdAt);
}

class CategoriesCompanion extends UpdateCompanion<Category> {
  final Value<String> id;
  final Value<String> name;
  final Value<String> type;
  final Value<String?> parentId;
  final Value<bool> isActive;
  final Value<DateTime> createdAt;
  final Value<int> rowid;
  const CategoriesCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.type = const Value.absent(),
    this.parentId = const Value.absent(),
    this.isActive = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  CategoriesCompanion.insert({
    required String id,
    required String name,
    required String type,
    this.parentId = const Value.absent(),
    this.isActive = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        name = Value(name),
        type = Value(type);
  static Insertable<Category> custom({
    Expression<String>? id,
    Expression<String>? name,
    Expression<String>? type,
    Expression<String>? parentId,
    Expression<bool>? isActive,
    Expression<DateTime>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (type != null) 'type': type,
      if (parentId != null) 'parent_id': parentId,
      if (isActive != null) 'is_active': isActive,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  CategoriesCompanion copyWith(
      {Value<String>? id,
      Value<String>? name,
      Value<String>? type,
      Value<String?>? parentId,
      Value<bool>? isActive,
      Value<DateTime>? createdAt,
      Value<int>? rowid}) {
    return CategoriesCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      type: type ?? this.type,
      parentId: parentId ?? this.parentId,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (type.present) {
      map['type'] = Variable<String>(type.value);
    }
    if (parentId.present) {
      map['parent_id'] = Variable<String>(parentId.value);
    }
    if (isActive.present) {
      map['is_active'] = Variable<bool>(isActive.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CategoriesCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('type: $type, ')
          ..write('parentId: $parentId, ')
          ..write('isActive: $isActive, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $BrandsTable extends Brands with TableInfo<$BrandsTable, Brand> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $BrandsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
      'name', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'));
  static const VerificationMeta _isActiveMeta =
      const VerificationMeta('isActive');
  @override
  late final GeneratedColumn<bool> isActive = GeneratedColumn<bool>(
      'is_active', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("is_active" IN (0, 1))'),
      defaultValue: const Constant(true));
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  @override
  List<GeneratedColumn> get $columns => [id, name, isActive, createdAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'brands';
  @override
  VerificationContext validateIntegrity(Insertable<Brand> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
          _nameMeta, name.isAcceptableOrUnknown(data['name']!, _nameMeta));
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('is_active')) {
      context.handle(_isActiveMeta,
          isActive.isAcceptableOrUnknown(data['is_active']!, _isActiveMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Brand map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Brand(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      name: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}name'])!,
      isActive: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_active'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
    );
  }

  @override
  $BrandsTable createAlias(String alias) {
    return $BrandsTable(attachedDatabase, alias);
  }
}

class Brand extends DataClass implements Insertable<Brand> {
  final String id;
  final String name;
  final bool isActive;
  final DateTime createdAt;
  const Brand(
      {required this.id,
      required this.name,
      required this.isActive,
      required this.createdAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    map['is_active'] = Variable<bool>(isActive);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  BrandsCompanion toCompanion(bool nullToAbsent) {
    return BrandsCompanion(
      id: Value(id),
      name: Value(name),
      isActive: Value(isActive),
      createdAt: Value(createdAt),
    );
  }

  factory Brand.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Brand(
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      isActive: serializer.fromJson<bool>(json['isActive']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
      'isActive': serializer.toJson<bool>(isActive),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  Brand copyWith(
          {String? id, String? name, bool? isActive, DateTime? createdAt}) =>
      Brand(
        id: id ?? this.id,
        name: name ?? this.name,
        isActive: isActive ?? this.isActive,
        createdAt: createdAt ?? this.createdAt,
      );
  Brand copyWithCompanion(BrandsCompanion data) {
    return Brand(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      isActive: data.isActive.present ? data.isActive.value : this.isActive,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Brand(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('isActive: $isActive, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, name, isActive, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Brand &&
          other.id == this.id &&
          other.name == this.name &&
          other.isActive == this.isActive &&
          other.createdAt == this.createdAt);
}

class BrandsCompanion extends UpdateCompanion<Brand> {
  final Value<String> id;
  final Value<String> name;
  final Value<bool> isActive;
  final Value<DateTime> createdAt;
  final Value<int> rowid;
  const BrandsCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.isActive = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  BrandsCompanion.insert({
    required String id,
    required String name,
    this.isActive = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        name = Value(name);
  static Insertable<Brand> custom({
    Expression<String>? id,
    Expression<String>? name,
    Expression<bool>? isActive,
    Expression<DateTime>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (isActive != null) 'is_active': isActive,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  BrandsCompanion copyWith(
      {Value<String>? id,
      Value<String>? name,
      Value<bool>? isActive,
      Value<DateTime>? createdAt,
      Value<int>? rowid}) {
    return BrandsCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (isActive.present) {
      map['is_active'] = Variable<bool>(isActive.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('BrandsCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('isActive: $isActive, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ProductsTable extends Products with TableInfo<$ProductsTable, Product> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ProductsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _brandIdMeta =
      const VerificationMeta('brandId');
  @override
  late final GeneratedColumn<String> brandId = GeneratedColumn<String>(
      'brand_id', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _categoryIdMeta =
      const VerificationMeta('categoryId');
  @override
  late final GeneratedColumn<String> categoryId = GeneratedColumn<String>(
      'category_id', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _typeMeta = const VerificationMeta('type');
  @override
  late final GeneratedColumn<String> type = GeneratedColumn<String>(
      'type', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
      'name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _descriptionMeta =
      const VerificationMeta('description');
  @override
  late final GeneratedColumn<String> description = GeneratedColumn<String>(
      'description', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _barcodeMeta =
      const VerificationMeta('barcode');
  @override
  late final GeneratedColumn<String> barcode = GeneratedColumn<String>(
      'barcode', aliasedName, true,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'));
  static const VerificationMeta _imageUrlMeta =
      const VerificationMeta('imageUrl');
  @override
  late final GeneratedColumn<String> imageUrl = GeneratedColumn<String>(
      'image_url', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _isActiveMeta =
      const VerificationMeta('isActive');
  @override
  late final GeneratedColumn<bool> isActive = GeneratedColumn<bool>(
      'is_active', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("is_active" IN (0, 1))'),
      defaultValue: const Constant(true));
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  static const VerificationMeta _updatedAtMeta =
      const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
      'updated_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        brandId,
        categoryId,
        type,
        name,
        description,
        barcode,
        imageUrl,
        isActive,
        createdAt,
        updatedAt
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'products';
  @override
  VerificationContext validateIntegrity(Insertable<Product> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('brand_id')) {
      context.handle(_brandIdMeta,
          brandId.isAcceptableOrUnknown(data['brand_id']!, _brandIdMeta));
    }
    if (data.containsKey('category_id')) {
      context.handle(
          _categoryIdMeta,
          categoryId.isAcceptableOrUnknown(
              data['category_id']!, _categoryIdMeta));
    }
    if (data.containsKey('type')) {
      context.handle(
          _typeMeta, type.isAcceptableOrUnknown(data['type']!, _typeMeta));
    } else if (isInserting) {
      context.missing(_typeMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
          _nameMeta, name.isAcceptableOrUnknown(data['name']!, _nameMeta));
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('description')) {
      context.handle(
          _descriptionMeta,
          description.isAcceptableOrUnknown(
              data['description']!, _descriptionMeta));
    }
    if (data.containsKey('barcode')) {
      context.handle(_barcodeMeta,
          barcode.isAcceptableOrUnknown(data['barcode']!, _barcodeMeta));
    }
    if (data.containsKey('image_url')) {
      context.handle(_imageUrlMeta,
          imageUrl.isAcceptableOrUnknown(data['image_url']!, _imageUrlMeta));
    }
    if (data.containsKey('is_active')) {
      context.handle(_isActiveMeta,
          isActive.isAcceptableOrUnknown(data['is_active']!, _isActiveMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    }
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta,
          updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Product map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Product(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      brandId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}brand_id']),
      categoryId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}category_id']),
      type: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}type'])!,
      name: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}name'])!,
      description: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}description']),
      barcode: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}barcode']),
      imageUrl: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}image_url']),
      isActive: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_active'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}updated_at'])!,
    );
  }

  @override
  $ProductsTable createAlias(String alias) {
    return $ProductsTable(attachedDatabase, alias);
  }
}

class Product extends DataClass implements Insertable<Product> {
  final String id;
  final String? brandId;
  final String? categoryId;
  final String type;
  final String name;
  final String? description;
  final String? barcode;
  final String? imageUrl;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;
  const Product(
      {required this.id,
      this.brandId,
      this.categoryId,
      required this.type,
      required this.name,
      this.description,
      this.barcode,
      this.imageUrl,
      required this.isActive,
      required this.createdAt,
      required this.updatedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    if (!nullToAbsent || brandId != null) {
      map['brand_id'] = Variable<String>(brandId);
    }
    if (!nullToAbsent || categoryId != null) {
      map['category_id'] = Variable<String>(categoryId);
    }
    map['type'] = Variable<String>(type);
    map['name'] = Variable<String>(name);
    if (!nullToAbsent || description != null) {
      map['description'] = Variable<String>(description);
    }
    if (!nullToAbsent || barcode != null) {
      map['barcode'] = Variable<String>(barcode);
    }
    if (!nullToAbsent || imageUrl != null) {
      map['image_url'] = Variable<String>(imageUrl);
    }
    map['is_active'] = Variable<bool>(isActive);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  ProductsCompanion toCompanion(bool nullToAbsent) {
    return ProductsCompanion(
      id: Value(id),
      brandId: brandId == null && nullToAbsent
          ? const Value.absent()
          : Value(brandId),
      categoryId: categoryId == null && nullToAbsent
          ? const Value.absent()
          : Value(categoryId),
      type: Value(type),
      name: Value(name),
      description: description == null && nullToAbsent
          ? const Value.absent()
          : Value(description),
      barcode: barcode == null && nullToAbsent
          ? const Value.absent()
          : Value(barcode),
      imageUrl: imageUrl == null && nullToAbsent
          ? const Value.absent()
          : Value(imageUrl),
      isActive: Value(isActive),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory Product.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Product(
      id: serializer.fromJson<String>(json['id']),
      brandId: serializer.fromJson<String?>(json['brandId']),
      categoryId: serializer.fromJson<String?>(json['categoryId']),
      type: serializer.fromJson<String>(json['type']),
      name: serializer.fromJson<String>(json['name']),
      description: serializer.fromJson<String?>(json['description']),
      barcode: serializer.fromJson<String?>(json['barcode']),
      imageUrl: serializer.fromJson<String?>(json['imageUrl']),
      isActive: serializer.fromJson<bool>(json['isActive']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'brandId': serializer.toJson<String?>(brandId),
      'categoryId': serializer.toJson<String?>(categoryId),
      'type': serializer.toJson<String>(type),
      'name': serializer.toJson<String>(name),
      'description': serializer.toJson<String?>(description),
      'barcode': serializer.toJson<String?>(barcode),
      'imageUrl': serializer.toJson<String?>(imageUrl),
      'isActive': serializer.toJson<bool>(isActive),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  Product copyWith(
          {String? id,
          Value<String?> brandId = const Value.absent(),
          Value<String?> categoryId = const Value.absent(),
          String? type,
          String? name,
          Value<String?> description = const Value.absent(),
          Value<String?> barcode = const Value.absent(),
          Value<String?> imageUrl = const Value.absent(),
          bool? isActive,
          DateTime? createdAt,
          DateTime? updatedAt}) =>
      Product(
        id: id ?? this.id,
        brandId: brandId.present ? brandId.value : this.brandId,
        categoryId: categoryId.present ? categoryId.value : this.categoryId,
        type: type ?? this.type,
        name: name ?? this.name,
        description: description.present ? description.value : this.description,
        barcode: barcode.present ? barcode.value : this.barcode,
        imageUrl: imageUrl.present ? imageUrl.value : this.imageUrl,
        isActive: isActive ?? this.isActive,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
      );
  Product copyWithCompanion(ProductsCompanion data) {
    return Product(
      id: data.id.present ? data.id.value : this.id,
      brandId: data.brandId.present ? data.brandId.value : this.brandId,
      categoryId:
          data.categoryId.present ? data.categoryId.value : this.categoryId,
      type: data.type.present ? data.type.value : this.type,
      name: data.name.present ? data.name.value : this.name,
      description:
          data.description.present ? data.description.value : this.description,
      barcode: data.barcode.present ? data.barcode.value : this.barcode,
      imageUrl: data.imageUrl.present ? data.imageUrl.value : this.imageUrl,
      isActive: data.isActive.present ? data.isActive.value : this.isActive,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Product(')
          ..write('id: $id, ')
          ..write('brandId: $brandId, ')
          ..write('categoryId: $categoryId, ')
          ..write('type: $type, ')
          ..write('name: $name, ')
          ..write('description: $description, ')
          ..write('barcode: $barcode, ')
          ..write('imageUrl: $imageUrl, ')
          ..write('isActive: $isActive, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, brandId, categoryId, type, name,
      description, barcode, imageUrl, isActive, createdAt, updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Product &&
          other.id == this.id &&
          other.brandId == this.brandId &&
          other.categoryId == this.categoryId &&
          other.type == this.type &&
          other.name == this.name &&
          other.description == this.description &&
          other.barcode == this.barcode &&
          other.imageUrl == this.imageUrl &&
          other.isActive == this.isActive &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class ProductsCompanion extends UpdateCompanion<Product> {
  final Value<String> id;
  final Value<String?> brandId;
  final Value<String?> categoryId;
  final Value<String> type;
  final Value<String> name;
  final Value<String?> description;
  final Value<String?> barcode;
  final Value<String?> imageUrl;
  final Value<bool> isActive;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const ProductsCompanion({
    this.id = const Value.absent(),
    this.brandId = const Value.absent(),
    this.categoryId = const Value.absent(),
    this.type = const Value.absent(),
    this.name = const Value.absent(),
    this.description = const Value.absent(),
    this.barcode = const Value.absent(),
    this.imageUrl = const Value.absent(),
    this.isActive = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ProductsCompanion.insert({
    required String id,
    this.brandId = const Value.absent(),
    this.categoryId = const Value.absent(),
    required String type,
    required String name,
    this.description = const Value.absent(),
    this.barcode = const Value.absent(),
    this.imageUrl = const Value.absent(),
    this.isActive = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        type = Value(type),
        name = Value(name);
  static Insertable<Product> custom({
    Expression<String>? id,
    Expression<String>? brandId,
    Expression<String>? categoryId,
    Expression<String>? type,
    Expression<String>? name,
    Expression<String>? description,
    Expression<String>? barcode,
    Expression<String>? imageUrl,
    Expression<bool>? isActive,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (brandId != null) 'brand_id': brandId,
      if (categoryId != null) 'category_id': categoryId,
      if (type != null) 'type': type,
      if (name != null) 'name': name,
      if (description != null) 'description': description,
      if (barcode != null) 'barcode': barcode,
      if (imageUrl != null) 'image_url': imageUrl,
      if (isActive != null) 'is_active': isActive,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ProductsCompanion copyWith(
      {Value<String>? id,
      Value<String?>? brandId,
      Value<String?>? categoryId,
      Value<String>? type,
      Value<String>? name,
      Value<String?>? description,
      Value<String?>? barcode,
      Value<String?>? imageUrl,
      Value<bool>? isActive,
      Value<DateTime>? createdAt,
      Value<DateTime>? updatedAt,
      Value<int>? rowid}) {
    return ProductsCompanion(
      id: id ?? this.id,
      brandId: brandId ?? this.brandId,
      categoryId: categoryId ?? this.categoryId,
      type: type ?? this.type,
      name: name ?? this.name,
      description: description ?? this.description,
      barcode: barcode ?? this.barcode,
      imageUrl: imageUrl ?? this.imageUrl,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (brandId.present) {
      map['brand_id'] = Variable<String>(brandId.value);
    }
    if (categoryId.present) {
      map['category_id'] = Variable<String>(categoryId.value);
    }
    if (type.present) {
      map['type'] = Variable<String>(type.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (description.present) {
      map['description'] = Variable<String>(description.value);
    }
    if (barcode.present) {
      map['barcode'] = Variable<String>(barcode.value);
    }
    if (imageUrl.present) {
      map['image_url'] = Variable<String>(imageUrl.value);
    }
    if (isActive.present) {
      map['is_active'] = Variable<bool>(isActive.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ProductsCompanion(')
          ..write('id: $id, ')
          ..write('brandId: $brandId, ')
          ..write('categoryId: $categoryId, ')
          ..write('type: $type, ')
          ..write('name: $name, ')
          ..write('description: $description, ')
          ..write('barcode: $barcode, ')
          ..write('imageUrl: $imageUrl, ')
          ..write('isActive: $isActive, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ProductVariantsTable extends ProductVariants
    with TableInfo<$ProductVariantsTable, ProductVariant> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ProductVariantsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _productIdMeta =
      const VerificationMeta('productId');
  @override
  late final GeneratedColumn<String> productId = GeneratedColumn<String>(
      'product_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
      'name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _colorMeta = const VerificationMeta('color');
  @override
  late final GeneratedColumn<String> color = GeneratedColumn<String>(
      'color', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _storageGbMeta =
      const VerificationMeta('storageGb');
  @override
  late final GeneratedColumn<int> storageGb = GeneratedColumn<int>(
      'storage_gb', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _ramGbMeta = const VerificationMeta('ramGb');
  @override
  late final GeneratedColumn<int> ramGb = GeneratedColumn<int>(
      'ram_gb', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _conditionMeta =
      const VerificationMeta('condition');
  @override
  late final GeneratedColumn<String> condition = GeneratedColumn<String>(
      'condition', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('new'));
  static const VerificationMeta _ptaStatusMeta =
      const VerificationMeta('ptaStatus');
  @override
  late final GeneratedColumn<String> ptaStatus = GeneratedColumn<String>(
      'pta_status', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('not_applicable'));
  static const VerificationMeta _barcodeMeta =
      const VerificationMeta('barcode');
  @override
  late final GeneratedColumn<String> barcode = GeneratedColumn<String>(
      'barcode', aliasedName, true,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'));
  static const VerificationMeta _purchasePriceMeta =
      const VerificationMeta('purchasePrice');
  @override
  late final GeneratedColumn<int> purchasePrice = GeneratedColumn<int>(
      'purchase_price', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _salePriceMeta =
      const VerificationMeta('salePrice');
  @override
  late final GeneratedColumn<int> salePrice = GeneratedColumn<int>(
      'sale_price', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _minPriceMeta =
      const VerificationMeta('minPrice');
  @override
  late final GeneratedColumn<int> minPrice = GeneratedColumn<int>(
      'min_price', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _warrantyMonthsMeta =
      const VerificationMeta('warrantyMonths');
  @override
  late final GeneratedColumn<int> warrantyMonths = GeneratedColumn<int>(
      'warranty_months', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _quantityMeta =
      const VerificationMeta('quantity');
  @override
  late final GeneratedColumn<int> quantity = GeneratedColumn<int>(
      'quantity', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _lowStockThresholdMeta =
      const VerificationMeta('lowStockThreshold');
  @override
  late final GeneratedColumn<int> lowStockThreshold = GeneratedColumn<int>(
      'low_stock_threshold', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(3));
  static const VerificationMeta _isActiveMeta =
      const VerificationMeta('isActive');
  @override
  late final GeneratedColumn<bool> isActive = GeneratedColumn<bool>(
      'is_active', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("is_active" IN (0, 1))'),
      defaultValue: const Constant(true));
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  static const VerificationMeta _updatedAtMeta =
      const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
      'updated_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        productId,
        name,
        color,
        storageGb,
        ramGb,
        condition,
        ptaStatus,
        barcode,
        purchasePrice,
        salePrice,
        minPrice,
        warrantyMonths,
        quantity,
        lowStockThreshold,
        isActive,
        createdAt,
        updatedAt
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'product_variants';
  @override
  VerificationContext validateIntegrity(Insertable<ProductVariant> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('product_id')) {
      context.handle(_productIdMeta,
          productId.isAcceptableOrUnknown(data['product_id']!, _productIdMeta));
    } else if (isInserting) {
      context.missing(_productIdMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
          _nameMeta, name.isAcceptableOrUnknown(data['name']!, _nameMeta));
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('color')) {
      context.handle(
          _colorMeta, color.isAcceptableOrUnknown(data['color']!, _colorMeta));
    }
    if (data.containsKey('storage_gb')) {
      context.handle(_storageGbMeta,
          storageGb.isAcceptableOrUnknown(data['storage_gb']!, _storageGbMeta));
    }
    if (data.containsKey('ram_gb')) {
      context.handle(
          _ramGbMeta, ramGb.isAcceptableOrUnknown(data['ram_gb']!, _ramGbMeta));
    }
    if (data.containsKey('condition')) {
      context.handle(_conditionMeta,
          condition.isAcceptableOrUnknown(data['condition']!, _conditionMeta));
    }
    if (data.containsKey('pta_status')) {
      context.handle(_ptaStatusMeta,
          ptaStatus.isAcceptableOrUnknown(data['pta_status']!, _ptaStatusMeta));
    }
    if (data.containsKey('barcode')) {
      context.handle(_barcodeMeta,
          barcode.isAcceptableOrUnknown(data['barcode']!, _barcodeMeta));
    }
    if (data.containsKey('purchase_price')) {
      context.handle(
          _purchasePriceMeta,
          purchasePrice.isAcceptableOrUnknown(
              data['purchase_price']!, _purchasePriceMeta));
    }
    if (data.containsKey('sale_price')) {
      context.handle(_salePriceMeta,
          salePrice.isAcceptableOrUnknown(data['sale_price']!, _salePriceMeta));
    }
    if (data.containsKey('min_price')) {
      context.handle(_minPriceMeta,
          minPrice.isAcceptableOrUnknown(data['min_price']!, _minPriceMeta));
    }
    if (data.containsKey('warranty_months')) {
      context.handle(
          _warrantyMonthsMeta,
          warrantyMonths.isAcceptableOrUnknown(
              data['warranty_months']!, _warrantyMonthsMeta));
    }
    if (data.containsKey('quantity')) {
      context.handle(_quantityMeta,
          quantity.isAcceptableOrUnknown(data['quantity']!, _quantityMeta));
    }
    if (data.containsKey('low_stock_threshold')) {
      context.handle(
          _lowStockThresholdMeta,
          lowStockThreshold.isAcceptableOrUnknown(
              data['low_stock_threshold']!, _lowStockThresholdMeta));
    }
    if (data.containsKey('is_active')) {
      context.handle(_isActiveMeta,
          isActive.isAcceptableOrUnknown(data['is_active']!, _isActiveMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    }
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta,
          updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ProductVariant map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ProductVariant(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      productId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}product_id'])!,
      name: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}name'])!,
      color: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}color']),
      storageGb: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}storage_gb']),
      ramGb: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}ram_gb']),
      condition: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}condition'])!,
      ptaStatus: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}pta_status'])!,
      barcode: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}barcode']),
      purchasePrice: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}purchase_price'])!,
      salePrice: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}sale_price'])!,
      minPrice: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}min_price'])!,
      warrantyMonths: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}warranty_months'])!,
      quantity: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}quantity'])!,
      lowStockThreshold: attachedDatabase.typeMapping.read(
          DriftSqlType.int, data['${effectivePrefix}low_stock_threshold'])!,
      isActive: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_active'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}updated_at'])!,
    );
  }

  @override
  $ProductVariantsTable createAlias(String alias) {
    return $ProductVariantsTable(attachedDatabase, alias);
  }
}

class ProductVariant extends DataClass implements Insertable<ProductVariant> {
  final String id;
  final String productId;
  final String name;
  final String? color;
  final int? storageGb;
  final int? ramGb;
  final String condition;
  final String ptaStatus;
  final String? barcode;
  final int purchasePrice;
  final int salePrice;
  final int minPrice;
  final int warrantyMonths;
  final int quantity;
  final int lowStockThreshold;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;
  const ProductVariant(
      {required this.id,
      required this.productId,
      required this.name,
      this.color,
      this.storageGb,
      this.ramGb,
      required this.condition,
      required this.ptaStatus,
      this.barcode,
      required this.purchasePrice,
      required this.salePrice,
      required this.minPrice,
      required this.warrantyMonths,
      required this.quantity,
      required this.lowStockThreshold,
      required this.isActive,
      required this.createdAt,
      required this.updatedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['product_id'] = Variable<String>(productId);
    map['name'] = Variable<String>(name);
    if (!nullToAbsent || color != null) {
      map['color'] = Variable<String>(color);
    }
    if (!nullToAbsent || storageGb != null) {
      map['storage_gb'] = Variable<int>(storageGb);
    }
    if (!nullToAbsent || ramGb != null) {
      map['ram_gb'] = Variable<int>(ramGb);
    }
    map['condition'] = Variable<String>(condition);
    map['pta_status'] = Variable<String>(ptaStatus);
    if (!nullToAbsent || barcode != null) {
      map['barcode'] = Variable<String>(barcode);
    }
    map['purchase_price'] = Variable<int>(purchasePrice);
    map['sale_price'] = Variable<int>(salePrice);
    map['min_price'] = Variable<int>(minPrice);
    map['warranty_months'] = Variable<int>(warrantyMonths);
    map['quantity'] = Variable<int>(quantity);
    map['low_stock_threshold'] = Variable<int>(lowStockThreshold);
    map['is_active'] = Variable<bool>(isActive);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  ProductVariantsCompanion toCompanion(bool nullToAbsent) {
    return ProductVariantsCompanion(
      id: Value(id),
      productId: Value(productId),
      name: Value(name),
      color:
          color == null && nullToAbsent ? const Value.absent() : Value(color),
      storageGb: storageGb == null && nullToAbsent
          ? const Value.absent()
          : Value(storageGb),
      ramGb:
          ramGb == null && nullToAbsent ? const Value.absent() : Value(ramGb),
      condition: Value(condition),
      ptaStatus: Value(ptaStatus),
      barcode: barcode == null && nullToAbsent
          ? const Value.absent()
          : Value(barcode),
      purchasePrice: Value(purchasePrice),
      salePrice: Value(salePrice),
      minPrice: Value(minPrice),
      warrantyMonths: Value(warrantyMonths),
      quantity: Value(quantity),
      lowStockThreshold: Value(lowStockThreshold),
      isActive: Value(isActive),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory ProductVariant.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ProductVariant(
      id: serializer.fromJson<String>(json['id']),
      productId: serializer.fromJson<String>(json['productId']),
      name: serializer.fromJson<String>(json['name']),
      color: serializer.fromJson<String?>(json['color']),
      storageGb: serializer.fromJson<int?>(json['storageGb']),
      ramGb: serializer.fromJson<int?>(json['ramGb']),
      condition: serializer.fromJson<String>(json['condition']),
      ptaStatus: serializer.fromJson<String>(json['ptaStatus']),
      barcode: serializer.fromJson<String?>(json['barcode']),
      purchasePrice: serializer.fromJson<int>(json['purchasePrice']),
      salePrice: serializer.fromJson<int>(json['salePrice']),
      minPrice: serializer.fromJson<int>(json['minPrice']),
      warrantyMonths: serializer.fromJson<int>(json['warrantyMonths']),
      quantity: serializer.fromJson<int>(json['quantity']),
      lowStockThreshold: serializer.fromJson<int>(json['lowStockThreshold']),
      isActive: serializer.fromJson<bool>(json['isActive']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'productId': serializer.toJson<String>(productId),
      'name': serializer.toJson<String>(name),
      'color': serializer.toJson<String?>(color),
      'storageGb': serializer.toJson<int?>(storageGb),
      'ramGb': serializer.toJson<int?>(ramGb),
      'condition': serializer.toJson<String>(condition),
      'ptaStatus': serializer.toJson<String>(ptaStatus),
      'barcode': serializer.toJson<String?>(barcode),
      'purchasePrice': serializer.toJson<int>(purchasePrice),
      'salePrice': serializer.toJson<int>(salePrice),
      'minPrice': serializer.toJson<int>(minPrice),
      'warrantyMonths': serializer.toJson<int>(warrantyMonths),
      'quantity': serializer.toJson<int>(quantity),
      'lowStockThreshold': serializer.toJson<int>(lowStockThreshold),
      'isActive': serializer.toJson<bool>(isActive),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  ProductVariant copyWith(
          {String? id,
          String? productId,
          String? name,
          Value<String?> color = const Value.absent(),
          Value<int?> storageGb = const Value.absent(),
          Value<int?> ramGb = const Value.absent(),
          String? condition,
          String? ptaStatus,
          Value<String?> barcode = const Value.absent(),
          int? purchasePrice,
          int? salePrice,
          int? minPrice,
          int? warrantyMonths,
          int? quantity,
          int? lowStockThreshold,
          bool? isActive,
          DateTime? createdAt,
          DateTime? updatedAt}) =>
      ProductVariant(
        id: id ?? this.id,
        productId: productId ?? this.productId,
        name: name ?? this.name,
        color: color.present ? color.value : this.color,
        storageGb: storageGb.present ? storageGb.value : this.storageGb,
        ramGb: ramGb.present ? ramGb.value : this.ramGb,
        condition: condition ?? this.condition,
        ptaStatus: ptaStatus ?? this.ptaStatus,
        barcode: barcode.present ? barcode.value : this.barcode,
        purchasePrice: purchasePrice ?? this.purchasePrice,
        salePrice: salePrice ?? this.salePrice,
        minPrice: minPrice ?? this.minPrice,
        warrantyMonths: warrantyMonths ?? this.warrantyMonths,
        quantity: quantity ?? this.quantity,
        lowStockThreshold: lowStockThreshold ?? this.lowStockThreshold,
        isActive: isActive ?? this.isActive,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
      );
  ProductVariant copyWithCompanion(ProductVariantsCompanion data) {
    return ProductVariant(
      id: data.id.present ? data.id.value : this.id,
      productId: data.productId.present ? data.productId.value : this.productId,
      name: data.name.present ? data.name.value : this.name,
      color: data.color.present ? data.color.value : this.color,
      storageGb: data.storageGb.present ? data.storageGb.value : this.storageGb,
      ramGb: data.ramGb.present ? data.ramGb.value : this.ramGb,
      condition: data.condition.present ? data.condition.value : this.condition,
      ptaStatus: data.ptaStatus.present ? data.ptaStatus.value : this.ptaStatus,
      barcode: data.barcode.present ? data.barcode.value : this.barcode,
      purchasePrice: data.purchasePrice.present
          ? data.purchasePrice.value
          : this.purchasePrice,
      salePrice: data.salePrice.present ? data.salePrice.value : this.salePrice,
      minPrice: data.minPrice.present ? data.minPrice.value : this.minPrice,
      warrantyMonths: data.warrantyMonths.present
          ? data.warrantyMonths.value
          : this.warrantyMonths,
      quantity: data.quantity.present ? data.quantity.value : this.quantity,
      lowStockThreshold: data.lowStockThreshold.present
          ? data.lowStockThreshold.value
          : this.lowStockThreshold,
      isActive: data.isActive.present ? data.isActive.value : this.isActive,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ProductVariant(')
          ..write('id: $id, ')
          ..write('productId: $productId, ')
          ..write('name: $name, ')
          ..write('color: $color, ')
          ..write('storageGb: $storageGb, ')
          ..write('ramGb: $ramGb, ')
          ..write('condition: $condition, ')
          ..write('ptaStatus: $ptaStatus, ')
          ..write('barcode: $barcode, ')
          ..write('purchasePrice: $purchasePrice, ')
          ..write('salePrice: $salePrice, ')
          ..write('minPrice: $minPrice, ')
          ..write('warrantyMonths: $warrantyMonths, ')
          ..write('quantity: $quantity, ')
          ..write('lowStockThreshold: $lowStockThreshold, ')
          ..write('isActive: $isActive, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id,
      productId,
      name,
      color,
      storageGb,
      ramGb,
      condition,
      ptaStatus,
      barcode,
      purchasePrice,
      salePrice,
      minPrice,
      warrantyMonths,
      quantity,
      lowStockThreshold,
      isActive,
      createdAt,
      updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ProductVariant &&
          other.id == this.id &&
          other.productId == this.productId &&
          other.name == this.name &&
          other.color == this.color &&
          other.storageGb == this.storageGb &&
          other.ramGb == this.ramGb &&
          other.condition == this.condition &&
          other.ptaStatus == this.ptaStatus &&
          other.barcode == this.barcode &&
          other.purchasePrice == this.purchasePrice &&
          other.salePrice == this.salePrice &&
          other.minPrice == this.minPrice &&
          other.warrantyMonths == this.warrantyMonths &&
          other.quantity == this.quantity &&
          other.lowStockThreshold == this.lowStockThreshold &&
          other.isActive == this.isActive &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class ProductVariantsCompanion extends UpdateCompanion<ProductVariant> {
  final Value<String> id;
  final Value<String> productId;
  final Value<String> name;
  final Value<String?> color;
  final Value<int?> storageGb;
  final Value<int?> ramGb;
  final Value<String> condition;
  final Value<String> ptaStatus;
  final Value<String?> barcode;
  final Value<int> purchasePrice;
  final Value<int> salePrice;
  final Value<int> minPrice;
  final Value<int> warrantyMonths;
  final Value<int> quantity;
  final Value<int> lowStockThreshold;
  final Value<bool> isActive;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const ProductVariantsCompanion({
    this.id = const Value.absent(),
    this.productId = const Value.absent(),
    this.name = const Value.absent(),
    this.color = const Value.absent(),
    this.storageGb = const Value.absent(),
    this.ramGb = const Value.absent(),
    this.condition = const Value.absent(),
    this.ptaStatus = const Value.absent(),
    this.barcode = const Value.absent(),
    this.purchasePrice = const Value.absent(),
    this.salePrice = const Value.absent(),
    this.minPrice = const Value.absent(),
    this.warrantyMonths = const Value.absent(),
    this.quantity = const Value.absent(),
    this.lowStockThreshold = const Value.absent(),
    this.isActive = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ProductVariantsCompanion.insert({
    required String id,
    required String productId,
    required String name,
    this.color = const Value.absent(),
    this.storageGb = const Value.absent(),
    this.ramGb = const Value.absent(),
    this.condition = const Value.absent(),
    this.ptaStatus = const Value.absent(),
    this.barcode = const Value.absent(),
    this.purchasePrice = const Value.absent(),
    this.salePrice = const Value.absent(),
    this.minPrice = const Value.absent(),
    this.warrantyMonths = const Value.absent(),
    this.quantity = const Value.absent(),
    this.lowStockThreshold = const Value.absent(),
    this.isActive = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        productId = Value(productId),
        name = Value(name);
  static Insertable<ProductVariant> custom({
    Expression<String>? id,
    Expression<String>? productId,
    Expression<String>? name,
    Expression<String>? color,
    Expression<int>? storageGb,
    Expression<int>? ramGb,
    Expression<String>? condition,
    Expression<String>? ptaStatus,
    Expression<String>? barcode,
    Expression<int>? purchasePrice,
    Expression<int>? salePrice,
    Expression<int>? minPrice,
    Expression<int>? warrantyMonths,
    Expression<int>? quantity,
    Expression<int>? lowStockThreshold,
    Expression<bool>? isActive,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (productId != null) 'product_id': productId,
      if (name != null) 'name': name,
      if (color != null) 'color': color,
      if (storageGb != null) 'storage_gb': storageGb,
      if (ramGb != null) 'ram_gb': ramGb,
      if (condition != null) 'condition': condition,
      if (ptaStatus != null) 'pta_status': ptaStatus,
      if (barcode != null) 'barcode': barcode,
      if (purchasePrice != null) 'purchase_price': purchasePrice,
      if (salePrice != null) 'sale_price': salePrice,
      if (minPrice != null) 'min_price': minPrice,
      if (warrantyMonths != null) 'warranty_months': warrantyMonths,
      if (quantity != null) 'quantity': quantity,
      if (lowStockThreshold != null) 'low_stock_threshold': lowStockThreshold,
      if (isActive != null) 'is_active': isActive,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ProductVariantsCompanion copyWith(
      {Value<String>? id,
      Value<String>? productId,
      Value<String>? name,
      Value<String?>? color,
      Value<int?>? storageGb,
      Value<int?>? ramGb,
      Value<String>? condition,
      Value<String>? ptaStatus,
      Value<String?>? barcode,
      Value<int>? purchasePrice,
      Value<int>? salePrice,
      Value<int>? minPrice,
      Value<int>? warrantyMonths,
      Value<int>? quantity,
      Value<int>? lowStockThreshold,
      Value<bool>? isActive,
      Value<DateTime>? createdAt,
      Value<DateTime>? updatedAt,
      Value<int>? rowid}) {
    return ProductVariantsCompanion(
      id: id ?? this.id,
      productId: productId ?? this.productId,
      name: name ?? this.name,
      color: color ?? this.color,
      storageGb: storageGb ?? this.storageGb,
      ramGb: ramGb ?? this.ramGb,
      condition: condition ?? this.condition,
      ptaStatus: ptaStatus ?? this.ptaStatus,
      barcode: barcode ?? this.barcode,
      purchasePrice: purchasePrice ?? this.purchasePrice,
      salePrice: salePrice ?? this.salePrice,
      minPrice: minPrice ?? this.minPrice,
      warrantyMonths: warrantyMonths ?? this.warrantyMonths,
      quantity: quantity ?? this.quantity,
      lowStockThreshold: lowStockThreshold ?? this.lowStockThreshold,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (productId.present) {
      map['product_id'] = Variable<String>(productId.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (color.present) {
      map['color'] = Variable<String>(color.value);
    }
    if (storageGb.present) {
      map['storage_gb'] = Variable<int>(storageGb.value);
    }
    if (ramGb.present) {
      map['ram_gb'] = Variable<int>(ramGb.value);
    }
    if (condition.present) {
      map['condition'] = Variable<String>(condition.value);
    }
    if (ptaStatus.present) {
      map['pta_status'] = Variable<String>(ptaStatus.value);
    }
    if (barcode.present) {
      map['barcode'] = Variable<String>(barcode.value);
    }
    if (purchasePrice.present) {
      map['purchase_price'] = Variable<int>(purchasePrice.value);
    }
    if (salePrice.present) {
      map['sale_price'] = Variable<int>(salePrice.value);
    }
    if (minPrice.present) {
      map['min_price'] = Variable<int>(minPrice.value);
    }
    if (warrantyMonths.present) {
      map['warranty_months'] = Variable<int>(warrantyMonths.value);
    }
    if (quantity.present) {
      map['quantity'] = Variable<int>(quantity.value);
    }
    if (lowStockThreshold.present) {
      map['low_stock_threshold'] = Variable<int>(lowStockThreshold.value);
    }
    if (isActive.present) {
      map['is_active'] = Variable<bool>(isActive.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ProductVariantsCompanion(')
          ..write('id: $id, ')
          ..write('productId: $productId, ')
          ..write('name: $name, ')
          ..write('color: $color, ')
          ..write('storageGb: $storageGb, ')
          ..write('ramGb: $ramGb, ')
          ..write('condition: $condition, ')
          ..write('ptaStatus: $ptaStatus, ')
          ..write('barcode: $barcode, ')
          ..write('purchasePrice: $purchasePrice, ')
          ..write('salePrice: $salePrice, ')
          ..write('minPrice: $minPrice, ')
          ..write('warrantyMonths: $warrantyMonths, ')
          ..write('quantity: $quantity, ')
          ..write('lowStockThreshold: $lowStockThreshold, ')
          ..write('isActive: $isActive, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ImeiItemsTable extends ImeiItems
    with TableInfo<$ImeiItemsTable, ImeiItem> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ImeiItemsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _productIdMeta =
      const VerificationMeta('productId');
  @override
  late final GeneratedColumn<String> productId = GeneratedColumn<String>(
      'product_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _variantIdMeta =
      const VerificationMeta('variantId');
  @override
  late final GeneratedColumn<String> variantId = GeneratedColumn<String>(
      'variant_id', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _imei1Meta = const VerificationMeta('imei1');
  @override
  late final GeneratedColumn<String> imei1 = GeneratedColumn<String>(
      'imei1', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'));
  static const VerificationMeta _imei2Meta = const VerificationMeta('imei2');
  @override
  late final GeneratedColumn<String> imei2 = GeneratedColumn<String>(
      'imei2', aliasedName, true,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'));
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
      'status', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('available'));
  static const VerificationMeta _purchaseIdMeta =
      const VerificationMeta('purchaseId');
  @override
  late final GeneratedColumn<String> purchaseId = GeneratedColumn<String>(
      'purchase_id', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _purchasePriceMeta =
      const VerificationMeta('purchasePrice');
  @override
  late final GeneratedColumn<int> purchasePrice = GeneratedColumn<int>(
      'purchase_price', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _salePriceMeta =
      const VerificationMeta('salePrice');
  @override
  late final GeneratedColumn<int> salePrice = GeneratedColumn<int>(
      'sale_price', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _soldSaleIdMeta =
      const VerificationMeta('soldSaleId');
  @override
  late final GeneratedColumn<String> soldSaleId = GeneratedColumn<String>(
      'sold_sale_id', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _warrantyStartMeta =
      const VerificationMeta('warrantyStart');
  @override
  late final GeneratedColumn<DateTime> warrantyStart =
      GeneratedColumn<DateTime>('warranty_start', aliasedName, true,
          type: DriftSqlType.dateTime, requiredDuringInsert: false);
  static const VerificationMeta _warrantyEndMeta =
      const VerificationMeta('warrantyEnd');
  @override
  late final GeneratedColumn<DateTime> warrantyEnd = GeneratedColumn<DateTime>(
      'warranty_end', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  static const VerificationMeta _updatedAtMeta =
      const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
      'updated_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        productId,
        variantId,
        imei1,
        imei2,
        status,
        purchaseId,
        purchasePrice,
        salePrice,
        soldSaleId,
        warrantyStart,
        warrantyEnd,
        createdAt,
        updatedAt
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'imei_items';
  @override
  VerificationContext validateIntegrity(Insertable<ImeiItem> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('product_id')) {
      context.handle(_productIdMeta,
          productId.isAcceptableOrUnknown(data['product_id']!, _productIdMeta));
    } else if (isInserting) {
      context.missing(_productIdMeta);
    }
    if (data.containsKey('variant_id')) {
      context.handle(_variantIdMeta,
          variantId.isAcceptableOrUnknown(data['variant_id']!, _variantIdMeta));
    }
    if (data.containsKey('imei1')) {
      context.handle(
          _imei1Meta, imei1.isAcceptableOrUnknown(data['imei1']!, _imei1Meta));
    } else if (isInserting) {
      context.missing(_imei1Meta);
    }
    if (data.containsKey('imei2')) {
      context.handle(
          _imei2Meta, imei2.isAcceptableOrUnknown(data['imei2']!, _imei2Meta));
    }
    if (data.containsKey('status')) {
      context.handle(_statusMeta,
          status.isAcceptableOrUnknown(data['status']!, _statusMeta));
    }
    if (data.containsKey('purchase_id')) {
      context.handle(
          _purchaseIdMeta,
          purchaseId.isAcceptableOrUnknown(
              data['purchase_id']!, _purchaseIdMeta));
    }
    if (data.containsKey('purchase_price')) {
      context.handle(
          _purchasePriceMeta,
          purchasePrice.isAcceptableOrUnknown(
              data['purchase_price']!, _purchasePriceMeta));
    }
    if (data.containsKey('sale_price')) {
      context.handle(_salePriceMeta,
          salePrice.isAcceptableOrUnknown(data['sale_price']!, _salePriceMeta));
    }
    if (data.containsKey('sold_sale_id')) {
      context.handle(
          _soldSaleIdMeta,
          soldSaleId.isAcceptableOrUnknown(
              data['sold_sale_id']!, _soldSaleIdMeta));
    }
    if (data.containsKey('warranty_start')) {
      context.handle(
          _warrantyStartMeta,
          warrantyStart.isAcceptableOrUnknown(
              data['warranty_start']!, _warrantyStartMeta));
    }
    if (data.containsKey('warranty_end')) {
      context.handle(
          _warrantyEndMeta,
          warrantyEnd.isAcceptableOrUnknown(
              data['warranty_end']!, _warrantyEndMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    }
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta,
          updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ImeiItem map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ImeiItem(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      productId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}product_id'])!,
      variantId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}variant_id']),
      imei1: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}imei1'])!,
      imei2: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}imei2']),
      status: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}status'])!,
      purchaseId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}purchase_id']),
      purchasePrice: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}purchase_price'])!,
      salePrice: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}sale_price'])!,
      soldSaleId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}sold_sale_id']),
      warrantyStart: attachedDatabase.typeMapping.read(
          DriftSqlType.dateTime, data['${effectivePrefix}warranty_start']),
      warrantyEnd: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}warranty_end']),
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}updated_at'])!,
    );
  }

  @override
  $ImeiItemsTable createAlias(String alias) {
    return $ImeiItemsTable(attachedDatabase, alias);
  }
}

class ImeiItem extends DataClass implements Insertable<ImeiItem> {
  final String id;
  final String productId;
  final String? variantId;
  final String imei1;
  final String? imei2;
  final String status;
  final String? purchaseId;
  final int purchasePrice;
  final int salePrice;
  final String? soldSaleId;
  final DateTime? warrantyStart;
  final DateTime? warrantyEnd;
  final DateTime createdAt;
  final DateTime updatedAt;
  const ImeiItem(
      {required this.id,
      required this.productId,
      this.variantId,
      required this.imei1,
      this.imei2,
      required this.status,
      this.purchaseId,
      required this.purchasePrice,
      required this.salePrice,
      this.soldSaleId,
      this.warrantyStart,
      this.warrantyEnd,
      required this.createdAt,
      required this.updatedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['product_id'] = Variable<String>(productId);
    if (!nullToAbsent || variantId != null) {
      map['variant_id'] = Variable<String>(variantId);
    }
    map['imei1'] = Variable<String>(imei1);
    if (!nullToAbsent || imei2 != null) {
      map['imei2'] = Variable<String>(imei2);
    }
    map['status'] = Variable<String>(status);
    if (!nullToAbsent || purchaseId != null) {
      map['purchase_id'] = Variable<String>(purchaseId);
    }
    map['purchase_price'] = Variable<int>(purchasePrice);
    map['sale_price'] = Variable<int>(salePrice);
    if (!nullToAbsent || soldSaleId != null) {
      map['sold_sale_id'] = Variable<String>(soldSaleId);
    }
    if (!nullToAbsent || warrantyStart != null) {
      map['warranty_start'] = Variable<DateTime>(warrantyStart);
    }
    if (!nullToAbsent || warrantyEnd != null) {
      map['warranty_end'] = Variable<DateTime>(warrantyEnd);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  ImeiItemsCompanion toCompanion(bool nullToAbsent) {
    return ImeiItemsCompanion(
      id: Value(id),
      productId: Value(productId),
      variantId: variantId == null && nullToAbsent
          ? const Value.absent()
          : Value(variantId),
      imei1: Value(imei1),
      imei2:
          imei2 == null && nullToAbsent ? const Value.absent() : Value(imei2),
      status: Value(status),
      purchaseId: purchaseId == null && nullToAbsent
          ? const Value.absent()
          : Value(purchaseId),
      purchasePrice: Value(purchasePrice),
      salePrice: Value(salePrice),
      soldSaleId: soldSaleId == null && nullToAbsent
          ? const Value.absent()
          : Value(soldSaleId),
      warrantyStart: warrantyStart == null && nullToAbsent
          ? const Value.absent()
          : Value(warrantyStart),
      warrantyEnd: warrantyEnd == null && nullToAbsent
          ? const Value.absent()
          : Value(warrantyEnd),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory ImeiItem.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ImeiItem(
      id: serializer.fromJson<String>(json['id']),
      productId: serializer.fromJson<String>(json['productId']),
      variantId: serializer.fromJson<String?>(json['variantId']),
      imei1: serializer.fromJson<String>(json['imei1']),
      imei2: serializer.fromJson<String?>(json['imei2']),
      status: serializer.fromJson<String>(json['status']),
      purchaseId: serializer.fromJson<String?>(json['purchaseId']),
      purchasePrice: serializer.fromJson<int>(json['purchasePrice']),
      salePrice: serializer.fromJson<int>(json['salePrice']),
      soldSaleId: serializer.fromJson<String?>(json['soldSaleId']),
      warrantyStart: serializer.fromJson<DateTime?>(json['warrantyStart']),
      warrantyEnd: serializer.fromJson<DateTime?>(json['warrantyEnd']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'productId': serializer.toJson<String>(productId),
      'variantId': serializer.toJson<String?>(variantId),
      'imei1': serializer.toJson<String>(imei1),
      'imei2': serializer.toJson<String?>(imei2),
      'status': serializer.toJson<String>(status),
      'purchaseId': serializer.toJson<String?>(purchaseId),
      'purchasePrice': serializer.toJson<int>(purchasePrice),
      'salePrice': serializer.toJson<int>(salePrice),
      'soldSaleId': serializer.toJson<String?>(soldSaleId),
      'warrantyStart': serializer.toJson<DateTime?>(warrantyStart),
      'warrantyEnd': serializer.toJson<DateTime?>(warrantyEnd),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  ImeiItem copyWith(
          {String? id,
          String? productId,
          Value<String?> variantId = const Value.absent(),
          String? imei1,
          Value<String?> imei2 = const Value.absent(),
          String? status,
          Value<String?> purchaseId = const Value.absent(),
          int? purchasePrice,
          int? salePrice,
          Value<String?> soldSaleId = const Value.absent(),
          Value<DateTime?> warrantyStart = const Value.absent(),
          Value<DateTime?> warrantyEnd = const Value.absent(),
          DateTime? createdAt,
          DateTime? updatedAt}) =>
      ImeiItem(
        id: id ?? this.id,
        productId: productId ?? this.productId,
        variantId: variantId.present ? variantId.value : this.variantId,
        imei1: imei1 ?? this.imei1,
        imei2: imei2.present ? imei2.value : this.imei2,
        status: status ?? this.status,
        purchaseId: purchaseId.present ? purchaseId.value : this.purchaseId,
        purchasePrice: purchasePrice ?? this.purchasePrice,
        salePrice: salePrice ?? this.salePrice,
        soldSaleId: soldSaleId.present ? soldSaleId.value : this.soldSaleId,
        warrantyStart:
            warrantyStart.present ? warrantyStart.value : this.warrantyStart,
        warrantyEnd: warrantyEnd.present ? warrantyEnd.value : this.warrantyEnd,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
      );
  ImeiItem copyWithCompanion(ImeiItemsCompanion data) {
    return ImeiItem(
      id: data.id.present ? data.id.value : this.id,
      productId: data.productId.present ? data.productId.value : this.productId,
      variantId: data.variantId.present ? data.variantId.value : this.variantId,
      imei1: data.imei1.present ? data.imei1.value : this.imei1,
      imei2: data.imei2.present ? data.imei2.value : this.imei2,
      status: data.status.present ? data.status.value : this.status,
      purchaseId:
          data.purchaseId.present ? data.purchaseId.value : this.purchaseId,
      purchasePrice: data.purchasePrice.present
          ? data.purchasePrice.value
          : this.purchasePrice,
      salePrice: data.salePrice.present ? data.salePrice.value : this.salePrice,
      soldSaleId:
          data.soldSaleId.present ? data.soldSaleId.value : this.soldSaleId,
      warrantyStart: data.warrantyStart.present
          ? data.warrantyStart.value
          : this.warrantyStart,
      warrantyEnd:
          data.warrantyEnd.present ? data.warrantyEnd.value : this.warrantyEnd,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ImeiItem(')
          ..write('id: $id, ')
          ..write('productId: $productId, ')
          ..write('variantId: $variantId, ')
          ..write('imei1: $imei1, ')
          ..write('imei2: $imei2, ')
          ..write('status: $status, ')
          ..write('purchaseId: $purchaseId, ')
          ..write('purchasePrice: $purchasePrice, ')
          ..write('salePrice: $salePrice, ')
          ..write('soldSaleId: $soldSaleId, ')
          ..write('warrantyStart: $warrantyStart, ')
          ..write('warrantyEnd: $warrantyEnd, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id,
      productId,
      variantId,
      imei1,
      imei2,
      status,
      purchaseId,
      purchasePrice,
      salePrice,
      soldSaleId,
      warrantyStart,
      warrantyEnd,
      createdAt,
      updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ImeiItem &&
          other.id == this.id &&
          other.productId == this.productId &&
          other.variantId == this.variantId &&
          other.imei1 == this.imei1 &&
          other.imei2 == this.imei2 &&
          other.status == this.status &&
          other.purchaseId == this.purchaseId &&
          other.purchasePrice == this.purchasePrice &&
          other.salePrice == this.salePrice &&
          other.soldSaleId == this.soldSaleId &&
          other.warrantyStart == this.warrantyStart &&
          other.warrantyEnd == this.warrantyEnd &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class ImeiItemsCompanion extends UpdateCompanion<ImeiItem> {
  final Value<String> id;
  final Value<String> productId;
  final Value<String?> variantId;
  final Value<String> imei1;
  final Value<String?> imei2;
  final Value<String> status;
  final Value<String?> purchaseId;
  final Value<int> purchasePrice;
  final Value<int> salePrice;
  final Value<String?> soldSaleId;
  final Value<DateTime?> warrantyStart;
  final Value<DateTime?> warrantyEnd;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const ImeiItemsCompanion({
    this.id = const Value.absent(),
    this.productId = const Value.absent(),
    this.variantId = const Value.absent(),
    this.imei1 = const Value.absent(),
    this.imei2 = const Value.absent(),
    this.status = const Value.absent(),
    this.purchaseId = const Value.absent(),
    this.purchasePrice = const Value.absent(),
    this.salePrice = const Value.absent(),
    this.soldSaleId = const Value.absent(),
    this.warrantyStart = const Value.absent(),
    this.warrantyEnd = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ImeiItemsCompanion.insert({
    required String id,
    required String productId,
    this.variantId = const Value.absent(),
    required String imei1,
    this.imei2 = const Value.absent(),
    this.status = const Value.absent(),
    this.purchaseId = const Value.absent(),
    this.purchasePrice = const Value.absent(),
    this.salePrice = const Value.absent(),
    this.soldSaleId = const Value.absent(),
    this.warrantyStart = const Value.absent(),
    this.warrantyEnd = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        productId = Value(productId),
        imei1 = Value(imei1);
  static Insertable<ImeiItem> custom({
    Expression<String>? id,
    Expression<String>? productId,
    Expression<String>? variantId,
    Expression<String>? imei1,
    Expression<String>? imei2,
    Expression<String>? status,
    Expression<String>? purchaseId,
    Expression<int>? purchasePrice,
    Expression<int>? salePrice,
    Expression<String>? soldSaleId,
    Expression<DateTime>? warrantyStart,
    Expression<DateTime>? warrantyEnd,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (productId != null) 'product_id': productId,
      if (variantId != null) 'variant_id': variantId,
      if (imei1 != null) 'imei1': imei1,
      if (imei2 != null) 'imei2': imei2,
      if (status != null) 'status': status,
      if (purchaseId != null) 'purchase_id': purchaseId,
      if (purchasePrice != null) 'purchase_price': purchasePrice,
      if (salePrice != null) 'sale_price': salePrice,
      if (soldSaleId != null) 'sold_sale_id': soldSaleId,
      if (warrantyStart != null) 'warranty_start': warrantyStart,
      if (warrantyEnd != null) 'warranty_end': warrantyEnd,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ImeiItemsCompanion copyWith(
      {Value<String>? id,
      Value<String>? productId,
      Value<String?>? variantId,
      Value<String>? imei1,
      Value<String?>? imei2,
      Value<String>? status,
      Value<String?>? purchaseId,
      Value<int>? purchasePrice,
      Value<int>? salePrice,
      Value<String?>? soldSaleId,
      Value<DateTime?>? warrantyStart,
      Value<DateTime?>? warrantyEnd,
      Value<DateTime>? createdAt,
      Value<DateTime>? updatedAt,
      Value<int>? rowid}) {
    return ImeiItemsCompanion(
      id: id ?? this.id,
      productId: productId ?? this.productId,
      variantId: variantId ?? this.variantId,
      imei1: imei1 ?? this.imei1,
      imei2: imei2 ?? this.imei2,
      status: status ?? this.status,
      purchaseId: purchaseId ?? this.purchaseId,
      purchasePrice: purchasePrice ?? this.purchasePrice,
      salePrice: salePrice ?? this.salePrice,
      soldSaleId: soldSaleId ?? this.soldSaleId,
      warrantyStart: warrantyStart ?? this.warrantyStart,
      warrantyEnd: warrantyEnd ?? this.warrantyEnd,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (productId.present) {
      map['product_id'] = Variable<String>(productId.value);
    }
    if (variantId.present) {
      map['variant_id'] = Variable<String>(variantId.value);
    }
    if (imei1.present) {
      map['imei1'] = Variable<String>(imei1.value);
    }
    if (imei2.present) {
      map['imei2'] = Variable<String>(imei2.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (purchaseId.present) {
      map['purchase_id'] = Variable<String>(purchaseId.value);
    }
    if (purchasePrice.present) {
      map['purchase_price'] = Variable<int>(purchasePrice.value);
    }
    if (salePrice.present) {
      map['sale_price'] = Variable<int>(salePrice.value);
    }
    if (soldSaleId.present) {
      map['sold_sale_id'] = Variable<String>(soldSaleId.value);
    }
    if (warrantyStart.present) {
      map['warranty_start'] = Variable<DateTime>(warrantyStart.value);
    }
    if (warrantyEnd.present) {
      map['warranty_end'] = Variable<DateTime>(warrantyEnd.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ImeiItemsCompanion(')
          ..write('id: $id, ')
          ..write('productId: $productId, ')
          ..write('variantId: $variantId, ')
          ..write('imei1: $imei1, ')
          ..write('imei2: $imei2, ')
          ..write('status: $status, ')
          ..write('purchaseId: $purchaseId, ')
          ..write('purchasePrice: $purchasePrice, ')
          ..write('salePrice: $salePrice, ')
          ..write('soldSaleId: $soldSaleId, ')
          ..write('warrantyStart: $warrantyStart, ')
          ..write('warrantyEnd: $warrantyEnd, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $CustomersTable extends Customers
    with TableInfo<$CustomersTable, Customer> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CustomersTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
      'name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _phoneMeta = const VerificationMeta('phone');
  @override
  late final GeneratedColumn<String> phone = GeneratedColumn<String>(
      'phone', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _cnicMeta = const VerificationMeta('cnic');
  @override
  late final GeneratedColumn<String> cnic = GeneratedColumn<String>(
      'cnic', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _addressMeta =
      const VerificationMeta('address');
  @override
  late final GeneratedColumn<String> address = GeneratedColumn<String>(
      'address', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _openingBalanceMeta =
      const VerificationMeta('openingBalance');
  @override
  late final GeneratedColumn<int> openingBalance = GeneratedColumn<int>(
      'opening_balance', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _loyaltyPointsMeta =
      const VerificationMeta('loyaltyPoints');
  @override
  late final GeneratedColumn<int> loyaltyPoints = GeneratedColumn<int>(
      'loyalty_points', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _walletBalanceMeta =
      const VerificationMeta('walletBalance');
  @override
  late final GeneratedColumn<int> walletBalance = GeneratedColumn<int>(
      'wallet_balance', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _isActiveMeta =
      const VerificationMeta('isActive');
  @override
  late final GeneratedColumn<bool> isActive = GeneratedColumn<bool>(
      'is_active', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("is_active" IN (0, 1))'),
      defaultValue: const Constant(true));
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  static const VerificationMeta _updatedAtMeta =
      const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
      'updated_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        name,
        phone,
        cnic,
        address,
        openingBalance,
        loyaltyPoints,
        walletBalance,
        isActive,
        createdAt,
        updatedAt
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'customers';
  @override
  VerificationContext validateIntegrity(Insertable<Customer> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
          _nameMeta, name.isAcceptableOrUnknown(data['name']!, _nameMeta));
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('phone')) {
      context.handle(
          _phoneMeta, phone.isAcceptableOrUnknown(data['phone']!, _phoneMeta));
    } else if (isInserting) {
      context.missing(_phoneMeta);
    }
    if (data.containsKey('cnic')) {
      context.handle(
          _cnicMeta, cnic.isAcceptableOrUnknown(data['cnic']!, _cnicMeta));
    }
    if (data.containsKey('address')) {
      context.handle(_addressMeta,
          address.isAcceptableOrUnknown(data['address']!, _addressMeta));
    }
    if (data.containsKey('opening_balance')) {
      context.handle(
          _openingBalanceMeta,
          openingBalance.isAcceptableOrUnknown(
              data['opening_balance']!, _openingBalanceMeta));
    }
    if (data.containsKey('loyalty_points')) {
      context.handle(
          _loyaltyPointsMeta,
          loyaltyPoints.isAcceptableOrUnknown(
              data['loyalty_points']!, _loyaltyPointsMeta));
    }
    if (data.containsKey('wallet_balance')) {
      context.handle(
          _walletBalanceMeta,
          walletBalance.isAcceptableOrUnknown(
              data['wallet_balance']!, _walletBalanceMeta));
    }
    if (data.containsKey('is_active')) {
      context.handle(_isActiveMeta,
          isActive.isAcceptableOrUnknown(data['is_active']!, _isActiveMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    }
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta,
          updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Customer map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Customer(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      name: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}name'])!,
      phone: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}phone'])!,
      cnic: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}cnic']),
      address: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}address']),
      openingBalance: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}opening_balance'])!,
      loyaltyPoints: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}loyalty_points'])!,
      walletBalance: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}wallet_balance'])!,
      isActive: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_active'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}updated_at'])!,
    );
  }

  @override
  $CustomersTable createAlias(String alias) {
    return $CustomersTable(attachedDatabase, alias);
  }
}

class Customer extends DataClass implements Insertable<Customer> {
  final String id;
  final String name;
  final String phone;
  final String? cnic;
  final String? address;
  final int openingBalance;
  final int loyaltyPoints;
  final int walletBalance;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;
  const Customer(
      {required this.id,
      required this.name,
      required this.phone,
      this.cnic,
      this.address,
      required this.openingBalance,
      required this.loyaltyPoints,
      required this.walletBalance,
      required this.isActive,
      required this.createdAt,
      required this.updatedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    map['phone'] = Variable<String>(phone);
    if (!nullToAbsent || cnic != null) {
      map['cnic'] = Variable<String>(cnic);
    }
    if (!nullToAbsent || address != null) {
      map['address'] = Variable<String>(address);
    }
    map['opening_balance'] = Variable<int>(openingBalance);
    map['loyalty_points'] = Variable<int>(loyaltyPoints);
    map['wallet_balance'] = Variable<int>(walletBalance);
    map['is_active'] = Variable<bool>(isActive);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  CustomersCompanion toCompanion(bool nullToAbsent) {
    return CustomersCompanion(
      id: Value(id),
      name: Value(name),
      phone: Value(phone),
      cnic: cnic == null && nullToAbsent ? const Value.absent() : Value(cnic),
      address: address == null && nullToAbsent
          ? const Value.absent()
          : Value(address),
      openingBalance: Value(openingBalance),
      loyaltyPoints: Value(loyaltyPoints),
      walletBalance: Value(walletBalance),
      isActive: Value(isActive),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory Customer.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Customer(
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      phone: serializer.fromJson<String>(json['phone']),
      cnic: serializer.fromJson<String?>(json['cnic']),
      address: serializer.fromJson<String?>(json['address']),
      openingBalance: serializer.fromJson<int>(json['openingBalance']),
      loyaltyPoints: serializer.fromJson<int>(json['loyaltyPoints']),
      walletBalance: serializer.fromJson<int>(json['walletBalance']),
      isActive: serializer.fromJson<bool>(json['isActive']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
      'phone': serializer.toJson<String>(phone),
      'cnic': serializer.toJson<String?>(cnic),
      'address': serializer.toJson<String?>(address),
      'openingBalance': serializer.toJson<int>(openingBalance),
      'loyaltyPoints': serializer.toJson<int>(loyaltyPoints),
      'walletBalance': serializer.toJson<int>(walletBalance),
      'isActive': serializer.toJson<bool>(isActive),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  Customer copyWith(
          {String? id,
          String? name,
          String? phone,
          Value<String?> cnic = const Value.absent(),
          Value<String?> address = const Value.absent(),
          int? openingBalance,
          int? loyaltyPoints,
          int? walletBalance,
          bool? isActive,
          DateTime? createdAt,
          DateTime? updatedAt}) =>
      Customer(
        id: id ?? this.id,
        name: name ?? this.name,
        phone: phone ?? this.phone,
        cnic: cnic.present ? cnic.value : this.cnic,
        address: address.present ? address.value : this.address,
        openingBalance: openingBalance ?? this.openingBalance,
        loyaltyPoints: loyaltyPoints ?? this.loyaltyPoints,
        walletBalance: walletBalance ?? this.walletBalance,
        isActive: isActive ?? this.isActive,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
      );
  Customer copyWithCompanion(CustomersCompanion data) {
    return Customer(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      phone: data.phone.present ? data.phone.value : this.phone,
      cnic: data.cnic.present ? data.cnic.value : this.cnic,
      address: data.address.present ? data.address.value : this.address,
      openingBalance: data.openingBalance.present
          ? data.openingBalance.value
          : this.openingBalance,
      loyaltyPoints: data.loyaltyPoints.present
          ? data.loyaltyPoints.value
          : this.loyaltyPoints,
      walletBalance: data.walletBalance.present
          ? data.walletBalance.value
          : this.walletBalance,
      isActive: data.isActive.present ? data.isActive.value : this.isActive,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Customer(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('phone: $phone, ')
          ..write('cnic: $cnic, ')
          ..write('address: $address, ')
          ..write('openingBalance: $openingBalance, ')
          ..write('loyaltyPoints: $loyaltyPoints, ')
          ..write('walletBalance: $walletBalance, ')
          ..write('isActive: $isActive, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id,
      name,
      phone,
      cnic,
      address,
      openingBalance,
      loyaltyPoints,
      walletBalance,
      isActive,
      createdAt,
      updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Customer &&
          other.id == this.id &&
          other.name == this.name &&
          other.phone == this.phone &&
          other.cnic == this.cnic &&
          other.address == this.address &&
          other.openingBalance == this.openingBalance &&
          other.loyaltyPoints == this.loyaltyPoints &&
          other.walletBalance == this.walletBalance &&
          other.isActive == this.isActive &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class CustomersCompanion extends UpdateCompanion<Customer> {
  final Value<String> id;
  final Value<String> name;
  final Value<String> phone;
  final Value<String?> cnic;
  final Value<String?> address;
  final Value<int> openingBalance;
  final Value<int> loyaltyPoints;
  final Value<int> walletBalance;
  final Value<bool> isActive;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const CustomersCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.phone = const Value.absent(),
    this.cnic = const Value.absent(),
    this.address = const Value.absent(),
    this.openingBalance = const Value.absent(),
    this.loyaltyPoints = const Value.absent(),
    this.walletBalance = const Value.absent(),
    this.isActive = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  CustomersCompanion.insert({
    required String id,
    required String name,
    required String phone,
    this.cnic = const Value.absent(),
    this.address = const Value.absent(),
    this.openingBalance = const Value.absent(),
    this.loyaltyPoints = const Value.absent(),
    this.walletBalance = const Value.absent(),
    this.isActive = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        name = Value(name),
        phone = Value(phone);
  static Insertable<Customer> custom({
    Expression<String>? id,
    Expression<String>? name,
    Expression<String>? phone,
    Expression<String>? cnic,
    Expression<String>? address,
    Expression<int>? openingBalance,
    Expression<int>? loyaltyPoints,
    Expression<int>? walletBalance,
    Expression<bool>? isActive,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (phone != null) 'phone': phone,
      if (cnic != null) 'cnic': cnic,
      if (address != null) 'address': address,
      if (openingBalance != null) 'opening_balance': openingBalance,
      if (loyaltyPoints != null) 'loyalty_points': loyaltyPoints,
      if (walletBalance != null) 'wallet_balance': walletBalance,
      if (isActive != null) 'is_active': isActive,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  CustomersCompanion copyWith(
      {Value<String>? id,
      Value<String>? name,
      Value<String>? phone,
      Value<String?>? cnic,
      Value<String?>? address,
      Value<int>? openingBalance,
      Value<int>? loyaltyPoints,
      Value<int>? walletBalance,
      Value<bool>? isActive,
      Value<DateTime>? createdAt,
      Value<DateTime>? updatedAt,
      Value<int>? rowid}) {
    return CustomersCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      cnic: cnic ?? this.cnic,
      address: address ?? this.address,
      openingBalance: openingBalance ?? this.openingBalance,
      loyaltyPoints: loyaltyPoints ?? this.loyaltyPoints,
      walletBalance: walletBalance ?? this.walletBalance,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (phone.present) {
      map['phone'] = Variable<String>(phone.value);
    }
    if (cnic.present) {
      map['cnic'] = Variable<String>(cnic.value);
    }
    if (address.present) {
      map['address'] = Variable<String>(address.value);
    }
    if (openingBalance.present) {
      map['opening_balance'] = Variable<int>(openingBalance.value);
    }
    if (loyaltyPoints.present) {
      map['loyalty_points'] = Variable<int>(loyaltyPoints.value);
    }
    if (walletBalance.present) {
      map['wallet_balance'] = Variable<int>(walletBalance.value);
    }
    if (isActive.present) {
      map['is_active'] = Variable<bool>(isActive.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CustomersCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('phone: $phone, ')
          ..write('cnic: $cnic, ')
          ..write('address: $address, ')
          ..write('openingBalance: $openingBalance, ')
          ..write('loyaltyPoints: $loyaltyPoints, ')
          ..write('walletBalance: $walletBalance, ')
          ..write('isActive: $isActive, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $SuppliersTable extends Suppliers
    with TableInfo<$SuppliersTable, Supplier> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SuppliersTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
      'name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _phoneMeta = const VerificationMeta('phone');
  @override
  late final GeneratedColumn<String> phone = GeneratedColumn<String>(
      'phone', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _addressMeta =
      const VerificationMeta('address');
  @override
  late final GeneratedColumn<String> address = GeneratedColumn<String>(
      'address', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _openingPayableMeta =
      const VerificationMeta('openingPayable');
  @override
  late final GeneratedColumn<int> openingPayable = GeneratedColumn<int>(
      'opening_payable', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _isActiveMeta =
      const VerificationMeta('isActive');
  @override
  late final GeneratedColumn<bool> isActive = GeneratedColumn<bool>(
      'is_active', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("is_active" IN (0, 1))'),
      defaultValue: const Constant(true));
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  static const VerificationMeta _updatedAtMeta =
      const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
      'updated_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        name,
        phone,
        address,
        openingPayable,
        isActive,
        createdAt,
        updatedAt
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'suppliers';
  @override
  VerificationContext validateIntegrity(Insertable<Supplier> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
          _nameMeta, name.isAcceptableOrUnknown(data['name']!, _nameMeta));
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('phone')) {
      context.handle(
          _phoneMeta, phone.isAcceptableOrUnknown(data['phone']!, _phoneMeta));
    }
    if (data.containsKey('address')) {
      context.handle(_addressMeta,
          address.isAcceptableOrUnknown(data['address']!, _addressMeta));
    }
    if (data.containsKey('opening_payable')) {
      context.handle(
          _openingPayableMeta,
          openingPayable.isAcceptableOrUnknown(
              data['opening_payable']!, _openingPayableMeta));
    }
    if (data.containsKey('is_active')) {
      context.handle(_isActiveMeta,
          isActive.isAcceptableOrUnknown(data['is_active']!, _isActiveMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    }
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta,
          updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Supplier map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Supplier(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      name: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}name'])!,
      phone: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}phone']),
      address: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}address']),
      openingPayable: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}opening_payable'])!,
      isActive: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_active'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}updated_at'])!,
    );
  }

  @override
  $SuppliersTable createAlias(String alias) {
    return $SuppliersTable(attachedDatabase, alias);
  }
}

class Supplier extends DataClass implements Insertable<Supplier> {
  final String id;
  final String name;
  final String? phone;
  final String? address;
  final int openingPayable;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;
  const Supplier(
      {required this.id,
      required this.name,
      this.phone,
      this.address,
      required this.openingPayable,
      required this.isActive,
      required this.createdAt,
      required this.updatedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    if (!nullToAbsent || phone != null) {
      map['phone'] = Variable<String>(phone);
    }
    if (!nullToAbsent || address != null) {
      map['address'] = Variable<String>(address);
    }
    map['opening_payable'] = Variable<int>(openingPayable);
    map['is_active'] = Variable<bool>(isActive);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  SuppliersCompanion toCompanion(bool nullToAbsent) {
    return SuppliersCompanion(
      id: Value(id),
      name: Value(name),
      phone:
          phone == null && nullToAbsent ? const Value.absent() : Value(phone),
      address: address == null && nullToAbsent
          ? const Value.absent()
          : Value(address),
      openingPayable: Value(openingPayable),
      isActive: Value(isActive),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory Supplier.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Supplier(
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      phone: serializer.fromJson<String?>(json['phone']),
      address: serializer.fromJson<String?>(json['address']),
      openingPayable: serializer.fromJson<int>(json['openingPayable']),
      isActive: serializer.fromJson<bool>(json['isActive']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
      'phone': serializer.toJson<String?>(phone),
      'address': serializer.toJson<String?>(address),
      'openingPayable': serializer.toJson<int>(openingPayable),
      'isActive': serializer.toJson<bool>(isActive),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  Supplier copyWith(
          {String? id,
          String? name,
          Value<String?> phone = const Value.absent(),
          Value<String?> address = const Value.absent(),
          int? openingPayable,
          bool? isActive,
          DateTime? createdAt,
          DateTime? updatedAt}) =>
      Supplier(
        id: id ?? this.id,
        name: name ?? this.name,
        phone: phone.present ? phone.value : this.phone,
        address: address.present ? address.value : this.address,
        openingPayable: openingPayable ?? this.openingPayable,
        isActive: isActive ?? this.isActive,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
      );
  Supplier copyWithCompanion(SuppliersCompanion data) {
    return Supplier(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      phone: data.phone.present ? data.phone.value : this.phone,
      address: data.address.present ? data.address.value : this.address,
      openingPayable: data.openingPayable.present
          ? data.openingPayable.value
          : this.openingPayable,
      isActive: data.isActive.present ? data.isActive.value : this.isActive,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Supplier(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('phone: $phone, ')
          ..write('address: $address, ')
          ..write('openingPayable: $openingPayable, ')
          ..write('isActive: $isActive, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id, name, phone, address, openingPayable, isActive, createdAt, updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Supplier &&
          other.id == this.id &&
          other.name == this.name &&
          other.phone == this.phone &&
          other.address == this.address &&
          other.openingPayable == this.openingPayable &&
          other.isActive == this.isActive &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class SuppliersCompanion extends UpdateCompanion<Supplier> {
  final Value<String> id;
  final Value<String> name;
  final Value<String?> phone;
  final Value<String?> address;
  final Value<int> openingPayable;
  final Value<bool> isActive;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const SuppliersCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.phone = const Value.absent(),
    this.address = const Value.absent(),
    this.openingPayable = const Value.absent(),
    this.isActive = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SuppliersCompanion.insert({
    required String id,
    required String name,
    this.phone = const Value.absent(),
    this.address = const Value.absent(),
    this.openingPayable = const Value.absent(),
    this.isActive = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        name = Value(name);
  static Insertable<Supplier> custom({
    Expression<String>? id,
    Expression<String>? name,
    Expression<String>? phone,
    Expression<String>? address,
    Expression<int>? openingPayable,
    Expression<bool>? isActive,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (phone != null) 'phone': phone,
      if (address != null) 'address': address,
      if (openingPayable != null) 'opening_payable': openingPayable,
      if (isActive != null) 'is_active': isActive,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  SuppliersCompanion copyWith(
      {Value<String>? id,
      Value<String>? name,
      Value<String?>? phone,
      Value<String?>? address,
      Value<int>? openingPayable,
      Value<bool>? isActive,
      Value<DateTime>? createdAt,
      Value<DateTime>? updatedAt,
      Value<int>? rowid}) {
    return SuppliersCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      address: address ?? this.address,
      openingPayable: openingPayable ?? this.openingPayable,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (phone.present) {
      map['phone'] = Variable<String>(phone.value);
    }
    if (address.present) {
      map['address'] = Variable<String>(address.value);
    }
    if (openingPayable.present) {
      map['opening_payable'] = Variable<int>(openingPayable.value);
    }
    if (isActive.present) {
      map['is_active'] = Variable<bool>(isActive.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SuppliersCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('phone: $phone, ')
          ..write('address: $address, ')
          ..write('openingPayable: $openingPayable, ')
          ..write('isActive: $isActive, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $SalesTable extends Sales with TableInfo<$SalesTable, Sale> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SalesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _invoiceNoMeta =
      const VerificationMeta('invoiceNo');
  @override
  late final GeneratedColumn<String> invoiceNo = GeneratedColumn<String>(
      'invoice_no', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'));
  static const VerificationMeta _branchIdMeta =
      const VerificationMeta('branchId');
  @override
  late final GeneratedColumn<String> branchId = GeneratedColumn<String>(
      'branch_id', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _customerIdMeta =
      const VerificationMeta('customerId');
  @override
  late final GeneratedColumn<String> customerId = GeneratedColumn<String>(
      'customer_id', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _customerNameMeta =
      const VerificationMeta('customerName');
  @override
  late final GeneratedColumn<String> customerName = GeneratedColumn<String>(
      'customer_name', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _customerPhoneMeta =
      const VerificationMeta('customerPhone');
  @override
  late final GeneratedColumn<String> customerPhone = GeneratedColumn<String>(
      'customer_phone', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _userIdMeta = const VerificationMeta('userId');
  @override
  late final GeneratedColumn<String> userId = GeneratedColumn<String>(
      'user_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _saleDateMeta =
      const VerificationMeta('saleDate');
  @override
  late final GeneratedColumn<DateTime> saleDate = GeneratedColumn<DateTime>(
      'sale_date', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  static const VerificationMeta _subtotalMeta =
      const VerificationMeta('subtotal');
  @override
  late final GeneratedColumn<int> subtotal = GeneratedColumn<int>(
      'subtotal', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _discountAmountMeta =
      const VerificationMeta('discountAmount');
  @override
  late final GeneratedColumn<int> discountAmount = GeneratedColumn<int>(
      'discount_amount', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _discountPercentMeta =
      const VerificationMeta('discountPercent');
  @override
  late final GeneratedColumn<double> discountPercent = GeneratedColumn<double>(
      'discount_percent', aliasedName, false,
      type: DriftSqlType.double,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _taxAmountMeta =
      const VerificationMeta('taxAmount');
  @override
  late final GeneratedColumn<int> taxAmount = GeneratedColumn<int>(
      'tax_amount', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _grandTotalMeta =
      const VerificationMeta('grandTotal');
  @override
  late final GeneratedColumn<int> grandTotal = GeneratedColumn<int>(
      'grand_total', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _paidAmountMeta =
      const VerificationMeta('paidAmount');
  @override
  late final GeneratedColumn<int> paidAmount = GeneratedColumn<int>(
      'paid_amount', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _balanceDueMeta =
      const VerificationMeta('balanceDue');
  @override
  late final GeneratedColumn<int> balanceDue = GeneratedColumn<int>(
      'balance_due', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _paymentMethodMeta =
      const VerificationMeta('paymentMethod');
  @override
  late final GeneratedColumn<String> paymentMethod = GeneratedColumn<String>(
      'payment_method', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('cash'));
  static const VerificationMeta _paymentStatusMeta =
      const VerificationMeta('paymentStatus');
  @override
  late final GeneratedColumn<String> paymentStatus = GeneratedColumn<String>(
      'payment_status', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('paid'));
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
      'status', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('completed'));
  static const VerificationMeta _notesMeta = const VerificationMeta('notes');
  @override
  late final GeneratedColumn<String> notes = GeneratedColumn<String>(
      'notes', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _clientUuidMeta =
      const VerificationMeta('clientUuid');
  @override
  late final GeneratedColumn<String> clientUuid = GeneratedColumn<String>(
      'client_uuid', aliasedName, true,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'));
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  static const VerificationMeta _updatedAtMeta =
      const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
      'updated_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        invoiceNo,
        branchId,
        customerId,
        customerName,
        customerPhone,
        userId,
        saleDate,
        subtotal,
        discountAmount,
        discountPercent,
        taxAmount,
        grandTotal,
        paidAmount,
        balanceDue,
        paymentMethod,
        paymentStatus,
        status,
        notes,
        clientUuid,
        createdAt,
        updatedAt
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'sales';
  @override
  VerificationContext validateIntegrity(Insertable<Sale> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('invoice_no')) {
      context.handle(_invoiceNoMeta,
          invoiceNo.isAcceptableOrUnknown(data['invoice_no']!, _invoiceNoMeta));
    } else if (isInserting) {
      context.missing(_invoiceNoMeta);
    }
    if (data.containsKey('branch_id')) {
      context.handle(_branchIdMeta,
          branchId.isAcceptableOrUnknown(data['branch_id']!, _branchIdMeta));
    }
    if (data.containsKey('customer_id')) {
      context.handle(
          _customerIdMeta,
          customerId.isAcceptableOrUnknown(
              data['customer_id']!, _customerIdMeta));
    }
    if (data.containsKey('customer_name')) {
      context.handle(
          _customerNameMeta,
          customerName.isAcceptableOrUnknown(
              data['customer_name']!, _customerNameMeta));
    }
    if (data.containsKey('customer_phone')) {
      context.handle(
          _customerPhoneMeta,
          customerPhone.isAcceptableOrUnknown(
              data['customer_phone']!, _customerPhoneMeta));
    }
    if (data.containsKey('user_id')) {
      context.handle(_userIdMeta,
          userId.isAcceptableOrUnknown(data['user_id']!, _userIdMeta));
    } else if (isInserting) {
      context.missing(_userIdMeta);
    }
    if (data.containsKey('sale_date')) {
      context.handle(_saleDateMeta,
          saleDate.isAcceptableOrUnknown(data['sale_date']!, _saleDateMeta));
    }
    if (data.containsKey('subtotal')) {
      context.handle(_subtotalMeta,
          subtotal.isAcceptableOrUnknown(data['subtotal']!, _subtotalMeta));
    }
    if (data.containsKey('discount_amount')) {
      context.handle(
          _discountAmountMeta,
          discountAmount.isAcceptableOrUnknown(
              data['discount_amount']!, _discountAmountMeta));
    }
    if (data.containsKey('discount_percent')) {
      context.handle(
          _discountPercentMeta,
          discountPercent.isAcceptableOrUnknown(
              data['discount_percent']!, _discountPercentMeta));
    }
    if (data.containsKey('tax_amount')) {
      context.handle(_taxAmountMeta,
          taxAmount.isAcceptableOrUnknown(data['tax_amount']!, _taxAmountMeta));
    }
    if (data.containsKey('grand_total')) {
      context.handle(
          _grandTotalMeta,
          grandTotal.isAcceptableOrUnknown(
              data['grand_total']!, _grandTotalMeta));
    }
    if (data.containsKey('paid_amount')) {
      context.handle(
          _paidAmountMeta,
          paidAmount.isAcceptableOrUnknown(
              data['paid_amount']!, _paidAmountMeta));
    }
    if (data.containsKey('balance_due')) {
      context.handle(
          _balanceDueMeta,
          balanceDue.isAcceptableOrUnknown(
              data['balance_due']!, _balanceDueMeta));
    }
    if (data.containsKey('payment_method')) {
      context.handle(
          _paymentMethodMeta,
          paymentMethod.isAcceptableOrUnknown(
              data['payment_method']!, _paymentMethodMeta));
    }
    if (data.containsKey('payment_status')) {
      context.handle(
          _paymentStatusMeta,
          paymentStatus.isAcceptableOrUnknown(
              data['payment_status']!, _paymentStatusMeta));
    }
    if (data.containsKey('status')) {
      context.handle(_statusMeta,
          status.isAcceptableOrUnknown(data['status']!, _statusMeta));
    }
    if (data.containsKey('notes')) {
      context.handle(
          _notesMeta, notes.isAcceptableOrUnknown(data['notes']!, _notesMeta));
    }
    if (data.containsKey('client_uuid')) {
      context.handle(
          _clientUuidMeta,
          clientUuid.isAcceptableOrUnknown(
              data['client_uuid']!, _clientUuidMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    }
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta,
          updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Sale map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Sale(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      invoiceNo: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}invoice_no'])!,
      branchId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}branch_id']),
      customerId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}customer_id']),
      customerName: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}customer_name']),
      customerPhone: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}customer_phone']),
      userId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}user_id'])!,
      saleDate: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}sale_date'])!,
      subtotal: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}subtotal'])!,
      discountAmount: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}discount_amount'])!,
      discountPercent: attachedDatabase.typeMapping.read(
          DriftSqlType.double, data['${effectivePrefix}discount_percent'])!,
      taxAmount: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}tax_amount'])!,
      grandTotal: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}grand_total'])!,
      paidAmount: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}paid_amount'])!,
      balanceDue: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}balance_due'])!,
      paymentMethod: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}payment_method'])!,
      paymentStatus: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}payment_status'])!,
      status: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}status'])!,
      notes: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}notes']),
      clientUuid: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}client_uuid']),
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}updated_at'])!,
    );
  }

  @override
  $SalesTable createAlias(String alias) {
    return $SalesTable(attachedDatabase, alias);
  }
}

class Sale extends DataClass implements Insertable<Sale> {
  final String id;
  final String invoiceNo;
  final String? branchId;
  final String? customerId;
  final String? customerName;
  final String? customerPhone;
  final String userId;
  final DateTime saleDate;
  final int subtotal;
  final int discountAmount;
  final double discountPercent;
  final int taxAmount;
  final int grandTotal;
  final int paidAmount;
  final int balanceDue;
  final String paymentMethod;
  final String paymentStatus;
  final String status;
  final String? notes;
  final String? clientUuid;
  final DateTime createdAt;
  final DateTime updatedAt;
  const Sale(
      {required this.id,
      required this.invoiceNo,
      this.branchId,
      this.customerId,
      this.customerName,
      this.customerPhone,
      required this.userId,
      required this.saleDate,
      required this.subtotal,
      required this.discountAmount,
      required this.discountPercent,
      required this.taxAmount,
      required this.grandTotal,
      required this.paidAmount,
      required this.balanceDue,
      required this.paymentMethod,
      required this.paymentStatus,
      required this.status,
      this.notes,
      this.clientUuid,
      required this.createdAt,
      required this.updatedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['invoice_no'] = Variable<String>(invoiceNo);
    if (!nullToAbsent || branchId != null) {
      map['branch_id'] = Variable<String>(branchId);
    }
    if (!nullToAbsent || customerId != null) {
      map['customer_id'] = Variable<String>(customerId);
    }
    if (!nullToAbsent || customerName != null) {
      map['customer_name'] = Variable<String>(customerName);
    }
    if (!nullToAbsent || customerPhone != null) {
      map['customer_phone'] = Variable<String>(customerPhone);
    }
    map['user_id'] = Variable<String>(userId);
    map['sale_date'] = Variable<DateTime>(saleDate);
    map['subtotal'] = Variable<int>(subtotal);
    map['discount_amount'] = Variable<int>(discountAmount);
    map['discount_percent'] = Variable<double>(discountPercent);
    map['tax_amount'] = Variable<int>(taxAmount);
    map['grand_total'] = Variable<int>(grandTotal);
    map['paid_amount'] = Variable<int>(paidAmount);
    map['balance_due'] = Variable<int>(balanceDue);
    map['payment_method'] = Variable<String>(paymentMethod);
    map['payment_status'] = Variable<String>(paymentStatus);
    map['status'] = Variable<String>(status);
    if (!nullToAbsent || notes != null) {
      map['notes'] = Variable<String>(notes);
    }
    if (!nullToAbsent || clientUuid != null) {
      map['client_uuid'] = Variable<String>(clientUuid);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  SalesCompanion toCompanion(bool nullToAbsent) {
    return SalesCompanion(
      id: Value(id),
      invoiceNo: Value(invoiceNo),
      branchId: branchId == null && nullToAbsent
          ? const Value.absent()
          : Value(branchId),
      customerId: customerId == null && nullToAbsent
          ? const Value.absent()
          : Value(customerId),
      customerName: customerName == null && nullToAbsent
          ? const Value.absent()
          : Value(customerName),
      customerPhone: customerPhone == null && nullToAbsent
          ? const Value.absent()
          : Value(customerPhone),
      userId: Value(userId),
      saleDate: Value(saleDate),
      subtotal: Value(subtotal),
      discountAmount: Value(discountAmount),
      discountPercent: Value(discountPercent),
      taxAmount: Value(taxAmount),
      grandTotal: Value(grandTotal),
      paidAmount: Value(paidAmount),
      balanceDue: Value(balanceDue),
      paymentMethod: Value(paymentMethod),
      paymentStatus: Value(paymentStatus),
      status: Value(status),
      notes:
          notes == null && nullToAbsent ? const Value.absent() : Value(notes),
      clientUuid: clientUuid == null && nullToAbsent
          ? const Value.absent()
          : Value(clientUuid),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory Sale.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Sale(
      id: serializer.fromJson<String>(json['id']),
      invoiceNo: serializer.fromJson<String>(json['invoiceNo']),
      branchId: serializer.fromJson<String?>(json['branchId']),
      customerId: serializer.fromJson<String?>(json['customerId']),
      customerName: serializer.fromJson<String?>(json['customerName']),
      customerPhone: serializer.fromJson<String?>(json['customerPhone']),
      userId: serializer.fromJson<String>(json['userId']),
      saleDate: serializer.fromJson<DateTime>(json['saleDate']),
      subtotal: serializer.fromJson<int>(json['subtotal']),
      discountAmount: serializer.fromJson<int>(json['discountAmount']),
      discountPercent: serializer.fromJson<double>(json['discountPercent']),
      taxAmount: serializer.fromJson<int>(json['taxAmount']),
      grandTotal: serializer.fromJson<int>(json['grandTotal']),
      paidAmount: serializer.fromJson<int>(json['paidAmount']),
      balanceDue: serializer.fromJson<int>(json['balanceDue']),
      paymentMethod: serializer.fromJson<String>(json['paymentMethod']),
      paymentStatus: serializer.fromJson<String>(json['paymentStatus']),
      status: serializer.fromJson<String>(json['status']),
      notes: serializer.fromJson<String?>(json['notes']),
      clientUuid: serializer.fromJson<String?>(json['clientUuid']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'invoiceNo': serializer.toJson<String>(invoiceNo),
      'branchId': serializer.toJson<String?>(branchId),
      'customerId': serializer.toJson<String?>(customerId),
      'customerName': serializer.toJson<String?>(customerName),
      'customerPhone': serializer.toJson<String?>(customerPhone),
      'userId': serializer.toJson<String>(userId),
      'saleDate': serializer.toJson<DateTime>(saleDate),
      'subtotal': serializer.toJson<int>(subtotal),
      'discountAmount': serializer.toJson<int>(discountAmount),
      'discountPercent': serializer.toJson<double>(discountPercent),
      'taxAmount': serializer.toJson<int>(taxAmount),
      'grandTotal': serializer.toJson<int>(grandTotal),
      'paidAmount': serializer.toJson<int>(paidAmount),
      'balanceDue': serializer.toJson<int>(balanceDue),
      'paymentMethod': serializer.toJson<String>(paymentMethod),
      'paymentStatus': serializer.toJson<String>(paymentStatus),
      'status': serializer.toJson<String>(status),
      'notes': serializer.toJson<String?>(notes),
      'clientUuid': serializer.toJson<String?>(clientUuid),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  Sale copyWith(
          {String? id,
          String? invoiceNo,
          Value<String?> branchId = const Value.absent(),
          Value<String?> customerId = const Value.absent(),
          Value<String?> customerName = const Value.absent(),
          Value<String?> customerPhone = const Value.absent(),
          String? userId,
          DateTime? saleDate,
          int? subtotal,
          int? discountAmount,
          double? discountPercent,
          int? taxAmount,
          int? grandTotal,
          int? paidAmount,
          int? balanceDue,
          String? paymentMethod,
          String? paymentStatus,
          String? status,
          Value<String?> notes = const Value.absent(),
          Value<String?> clientUuid = const Value.absent(),
          DateTime? createdAt,
          DateTime? updatedAt}) =>
      Sale(
        id: id ?? this.id,
        invoiceNo: invoiceNo ?? this.invoiceNo,
        branchId: branchId.present ? branchId.value : this.branchId,
        customerId: customerId.present ? customerId.value : this.customerId,
        customerName:
            customerName.present ? customerName.value : this.customerName,
        customerPhone:
            customerPhone.present ? customerPhone.value : this.customerPhone,
        userId: userId ?? this.userId,
        saleDate: saleDate ?? this.saleDate,
        subtotal: subtotal ?? this.subtotal,
        discountAmount: discountAmount ?? this.discountAmount,
        discountPercent: discountPercent ?? this.discountPercent,
        taxAmount: taxAmount ?? this.taxAmount,
        grandTotal: grandTotal ?? this.grandTotal,
        paidAmount: paidAmount ?? this.paidAmount,
        balanceDue: balanceDue ?? this.balanceDue,
        paymentMethod: paymentMethod ?? this.paymentMethod,
        paymentStatus: paymentStatus ?? this.paymentStatus,
        status: status ?? this.status,
        notes: notes.present ? notes.value : this.notes,
        clientUuid: clientUuid.present ? clientUuid.value : this.clientUuid,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
      );
  Sale copyWithCompanion(SalesCompanion data) {
    return Sale(
      id: data.id.present ? data.id.value : this.id,
      invoiceNo: data.invoiceNo.present ? data.invoiceNo.value : this.invoiceNo,
      branchId: data.branchId.present ? data.branchId.value : this.branchId,
      customerId:
          data.customerId.present ? data.customerId.value : this.customerId,
      customerName: data.customerName.present
          ? data.customerName.value
          : this.customerName,
      customerPhone: data.customerPhone.present
          ? data.customerPhone.value
          : this.customerPhone,
      userId: data.userId.present ? data.userId.value : this.userId,
      saleDate: data.saleDate.present ? data.saleDate.value : this.saleDate,
      subtotal: data.subtotal.present ? data.subtotal.value : this.subtotal,
      discountAmount: data.discountAmount.present
          ? data.discountAmount.value
          : this.discountAmount,
      discountPercent: data.discountPercent.present
          ? data.discountPercent.value
          : this.discountPercent,
      taxAmount: data.taxAmount.present ? data.taxAmount.value : this.taxAmount,
      grandTotal:
          data.grandTotal.present ? data.grandTotal.value : this.grandTotal,
      paidAmount:
          data.paidAmount.present ? data.paidAmount.value : this.paidAmount,
      balanceDue:
          data.balanceDue.present ? data.balanceDue.value : this.balanceDue,
      paymentMethod: data.paymentMethod.present
          ? data.paymentMethod.value
          : this.paymentMethod,
      paymentStatus: data.paymentStatus.present
          ? data.paymentStatus.value
          : this.paymentStatus,
      status: data.status.present ? data.status.value : this.status,
      notes: data.notes.present ? data.notes.value : this.notes,
      clientUuid:
          data.clientUuid.present ? data.clientUuid.value : this.clientUuid,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Sale(')
          ..write('id: $id, ')
          ..write('invoiceNo: $invoiceNo, ')
          ..write('branchId: $branchId, ')
          ..write('customerId: $customerId, ')
          ..write('customerName: $customerName, ')
          ..write('customerPhone: $customerPhone, ')
          ..write('userId: $userId, ')
          ..write('saleDate: $saleDate, ')
          ..write('subtotal: $subtotal, ')
          ..write('discountAmount: $discountAmount, ')
          ..write('discountPercent: $discountPercent, ')
          ..write('taxAmount: $taxAmount, ')
          ..write('grandTotal: $grandTotal, ')
          ..write('paidAmount: $paidAmount, ')
          ..write('balanceDue: $balanceDue, ')
          ..write('paymentMethod: $paymentMethod, ')
          ..write('paymentStatus: $paymentStatus, ')
          ..write('status: $status, ')
          ..write('notes: $notes, ')
          ..write('clientUuid: $clientUuid, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hashAll([
        id,
        invoiceNo,
        branchId,
        customerId,
        customerName,
        customerPhone,
        userId,
        saleDate,
        subtotal,
        discountAmount,
        discountPercent,
        taxAmount,
        grandTotal,
        paidAmount,
        balanceDue,
        paymentMethod,
        paymentStatus,
        status,
        notes,
        clientUuid,
        createdAt,
        updatedAt
      ]);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Sale &&
          other.id == this.id &&
          other.invoiceNo == this.invoiceNo &&
          other.branchId == this.branchId &&
          other.customerId == this.customerId &&
          other.customerName == this.customerName &&
          other.customerPhone == this.customerPhone &&
          other.userId == this.userId &&
          other.saleDate == this.saleDate &&
          other.subtotal == this.subtotal &&
          other.discountAmount == this.discountAmount &&
          other.discountPercent == this.discountPercent &&
          other.taxAmount == this.taxAmount &&
          other.grandTotal == this.grandTotal &&
          other.paidAmount == this.paidAmount &&
          other.balanceDue == this.balanceDue &&
          other.paymentMethod == this.paymentMethod &&
          other.paymentStatus == this.paymentStatus &&
          other.status == this.status &&
          other.notes == this.notes &&
          other.clientUuid == this.clientUuid &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class SalesCompanion extends UpdateCompanion<Sale> {
  final Value<String> id;
  final Value<String> invoiceNo;
  final Value<String?> branchId;
  final Value<String?> customerId;
  final Value<String?> customerName;
  final Value<String?> customerPhone;
  final Value<String> userId;
  final Value<DateTime> saleDate;
  final Value<int> subtotal;
  final Value<int> discountAmount;
  final Value<double> discountPercent;
  final Value<int> taxAmount;
  final Value<int> grandTotal;
  final Value<int> paidAmount;
  final Value<int> balanceDue;
  final Value<String> paymentMethod;
  final Value<String> paymentStatus;
  final Value<String> status;
  final Value<String?> notes;
  final Value<String?> clientUuid;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const SalesCompanion({
    this.id = const Value.absent(),
    this.invoiceNo = const Value.absent(),
    this.branchId = const Value.absent(),
    this.customerId = const Value.absent(),
    this.customerName = const Value.absent(),
    this.customerPhone = const Value.absent(),
    this.userId = const Value.absent(),
    this.saleDate = const Value.absent(),
    this.subtotal = const Value.absent(),
    this.discountAmount = const Value.absent(),
    this.discountPercent = const Value.absent(),
    this.taxAmount = const Value.absent(),
    this.grandTotal = const Value.absent(),
    this.paidAmount = const Value.absent(),
    this.balanceDue = const Value.absent(),
    this.paymentMethod = const Value.absent(),
    this.paymentStatus = const Value.absent(),
    this.status = const Value.absent(),
    this.notes = const Value.absent(),
    this.clientUuid = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SalesCompanion.insert({
    required String id,
    required String invoiceNo,
    this.branchId = const Value.absent(),
    this.customerId = const Value.absent(),
    this.customerName = const Value.absent(),
    this.customerPhone = const Value.absent(),
    required String userId,
    this.saleDate = const Value.absent(),
    this.subtotal = const Value.absent(),
    this.discountAmount = const Value.absent(),
    this.discountPercent = const Value.absent(),
    this.taxAmount = const Value.absent(),
    this.grandTotal = const Value.absent(),
    this.paidAmount = const Value.absent(),
    this.balanceDue = const Value.absent(),
    this.paymentMethod = const Value.absent(),
    this.paymentStatus = const Value.absent(),
    this.status = const Value.absent(),
    this.notes = const Value.absent(),
    this.clientUuid = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        invoiceNo = Value(invoiceNo),
        userId = Value(userId);
  static Insertable<Sale> custom({
    Expression<String>? id,
    Expression<String>? invoiceNo,
    Expression<String>? branchId,
    Expression<String>? customerId,
    Expression<String>? customerName,
    Expression<String>? customerPhone,
    Expression<String>? userId,
    Expression<DateTime>? saleDate,
    Expression<int>? subtotal,
    Expression<int>? discountAmount,
    Expression<double>? discountPercent,
    Expression<int>? taxAmount,
    Expression<int>? grandTotal,
    Expression<int>? paidAmount,
    Expression<int>? balanceDue,
    Expression<String>? paymentMethod,
    Expression<String>? paymentStatus,
    Expression<String>? status,
    Expression<String>? notes,
    Expression<String>? clientUuid,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (invoiceNo != null) 'invoice_no': invoiceNo,
      if (branchId != null) 'branch_id': branchId,
      if (customerId != null) 'customer_id': customerId,
      if (customerName != null) 'customer_name': customerName,
      if (customerPhone != null) 'customer_phone': customerPhone,
      if (userId != null) 'user_id': userId,
      if (saleDate != null) 'sale_date': saleDate,
      if (subtotal != null) 'subtotal': subtotal,
      if (discountAmount != null) 'discount_amount': discountAmount,
      if (discountPercent != null) 'discount_percent': discountPercent,
      if (taxAmount != null) 'tax_amount': taxAmount,
      if (grandTotal != null) 'grand_total': grandTotal,
      if (paidAmount != null) 'paid_amount': paidAmount,
      if (balanceDue != null) 'balance_due': balanceDue,
      if (paymentMethod != null) 'payment_method': paymentMethod,
      if (paymentStatus != null) 'payment_status': paymentStatus,
      if (status != null) 'status': status,
      if (notes != null) 'notes': notes,
      if (clientUuid != null) 'client_uuid': clientUuid,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  SalesCompanion copyWith(
      {Value<String>? id,
      Value<String>? invoiceNo,
      Value<String?>? branchId,
      Value<String?>? customerId,
      Value<String?>? customerName,
      Value<String?>? customerPhone,
      Value<String>? userId,
      Value<DateTime>? saleDate,
      Value<int>? subtotal,
      Value<int>? discountAmount,
      Value<double>? discountPercent,
      Value<int>? taxAmount,
      Value<int>? grandTotal,
      Value<int>? paidAmount,
      Value<int>? balanceDue,
      Value<String>? paymentMethod,
      Value<String>? paymentStatus,
      Value<String>? status,
      Value<String?>? notes,
      Value<String?>? clientUuid,
      Value<DateTime>? createdAt,
      Value<DateTime>? updatedAt,
      Value<int>? rowid}) {
    return SalesCompanion(
      id: id ?? this.id,
      invoiceNo: invoiceNo ?? this.invoiceNo,
      branchId: branchId ?? this.branchId,
      customerId: customerId ?? this.customerId,
      customerName: customerName ?? this.customerName,
      customerPhone: customerPhone ?? this.customerPhone,
      userId: userId ?? this.userId,
      saleDate: saleDate ?? this.saleDate,
      subtotal: subtotal ?? this.subtotal,
      discountAmount: discountAmount ?? this.discountAmount,
      discountPercent: discountPercent ?? this.discountPercent,
      taxAmount: taxAmount ?? this.taxAmount,
      grandTotal: grandTotal ?? this.grandTotal,
      paidAmount: paidAmount ?? this.paidAmount,
      balanceDue: balanceDue ?? this.balanceDue,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      paymentStatus: paymentStatus ?? this.paymentStatus,
      status: status ?? this.status,
      notes: notes ?? this.notes,
      clientUuid: clientUuid ?? this.clientUuid,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (invoiceNo.present) {
      map['invoice_no'] = Variable<String>(invoiceNo.value);
    }
    if (branchId.present) {
      map['branch_id'] = Variable<String>(branchId.value);
    }
    if (customerId.present) {
      map['customer_id'] = Variable<String>(customerId.value);
    }
    if (customerName.present) {
      map['customer_name'] = Variable<String>(customerName.value);
    }
    if (customerPhone.present) {
      map['customer_phone'] = Variable<String>(customerPhone.value);
    }
    if (userId.present) {
      map['user_id'] = Variable<String>(userId.value);
    }
    if (saleDate.present) {
      map['sale_date'] = Variable<DateTime>(saleDate.value);
    }
    if (subtotal.present) {
      map['subtotal'] = Variable<int>(subtotal.value);
    }
    if (discountAmount.present) {
      map['discount_amount'] = Variable<int>(discountAmount.value);
    }
    if (discountPercent.present) {
      map['discount_percent'] = Variable<double>(discountPercent.value);
    }
    if (taxAmount.present) {
      map['tax_amount'] = Variable<int>(taxAmount.value);
    }
    if (grandTotal.present) {
      map['grand_total'] = Variable<int>(grandTotal.value);
    }
    if (paidAmount.present) {
      map['paid_amount'] = Variable<int>(paidAmount.value);
    }
    if (balanceDue.present) {
      map['balance_due'] = Variable<int>(balanceDue.value);
    }
    if (paymentMethod.present) {
      map['payment_method'] = Variable<String>(paymentMethod.value);
    }
    if (paymentStatus.present) {
      map['payment_status'] = Variable<String>(paymentStatus.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    if (clientUuid.present) {
      map['client_uuid'] = Variable<String>(clientUuid.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SalesCompanion(')
          ..write('id: $id, ')
          ..write('invoiceNo: $invoiceNo, ')
          ..write('branchId: $branchId, ')
          ..write('customerId: $customerId, ')
          ..write('customerName: $customerName, ')
          ..write('customerPhone: $customerPhone, ')
          ..write('userId: $userId, ')
          ..write('saleDate: $saleDate, ')
          ..write('subtotal: $subtotal, ')
          ..write('discountAmount: $discountAmount, ')
          ..write('discountPercent: $discountPercent, ')
          ..write('taxAmount: $taxAmount, ')
          ..write('grandTotal: $grandTotal, ')
          ..write('paidAmount: $paidAmount, ')
          ..write('balanceDue: $balanceDue, ')
          ..write('paymentMethod: $paymentMethod, ')
          ..write('paymentStatus: $paymentStatus, ')
          ..write('status: $status, ')
          ..write('notes: $notes, ')
          ..write('clientUuid: $clientUuid, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $SaleItemsTable extends SaleItems
    with TableInfo<$SaleItemsTable, SaleItem> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SaleItemsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _saleIdMeta = const VerificationMeta('saleId');
  @override
  late final GeneratedColumn<String> saleId = GeneratedColumn<String>(
      'sale_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _productIdMeta =
      const VerificationMeta('productId');
  @override
  late final GeneratedColumn<String> productId = GeneratedColumn<String>(
      'product_id', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _variantIdMeta =
      const VerificationMeta('variantId');
  @override
  late final GeneratedColumn<String> variantId = GeneratedColumn<String>(
      'variant_id', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _imeiItemIdMeta =
      const VerificationMeta('imeiItemId');
  @override
  late final GeneratedColumn<String> imeiItemId = GeneratedColumn<String>(
      'imei_item_id', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _nameSnapshotMeta =
      const VerificationMeta('nameSnapshot');
  @override
  late final GeneratedColumn<String> nameSnapshot = GeneratedColumn<String>(
      'name_snapshot', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _quantityMeta =
      const VerificationMeta('quantity');
  @override
  late final GeneratedColumn<int> quantity = GeneratedColumn<int>(
      'quantity', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(1));
  static const VerificationMeta _unitPriceMeta =
      const VerificationMeta('unitPrice');
  @override
  late final GeneratedColumn<int> unitPrice = GeneratedColumn<int>(
      'unit_price', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _purchaseCostMeta =
      const VerificationMeta('purchaseCost');
  @override
  late final GeneratedColumn<int> purchaseCost = GeneratedColumn<int>(
      'purchase_cost', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _discountMeta =
      const VerificationMeta('discount');
  @override
  late final GeneratedColumn<int> discount = GeneratedColumn<int>(
      'discount', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _totalMeta = const VerificationMeta('total');
  @override
  late final GeneratedColumn<int> total = GeneratedColumn<int>(
      'total', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _profitMeta = const VerificationMeta('profit');
  @override
  late final GeneratedColumn<int> profit = GeneratedColumn<int>(
      'profit', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        saleId,
        productId,
        variantId,
        imeiItemId,
        nameSnapshot,
        quantity,
        unitPrice,
        purchaseCost,
        discount,
        total,
        profit,
        createdAt
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'sale_items';
  @override
  VerificationContext validateIntegrity(Insertable<SaleItem> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('sale_id')) {
      context.handle(_saleIdMeta,
          saleId.isAcceptableOrUnknown(data['sale_id']!, _saleIdMeta));
    } else if (isInserting) {
      context.missing(_saleIdMeta);
    }
    if (data.containsKey('product_id')) {
      context.handle(_productIdMeta,
          productId.isAcceptableOrUnknown(data['product_id']!, _productIdMeta));
    }
    if (data.containsKey('variant_id')) {
      context.handle(_variantIdMeta,
          variantId.isAcceptableOrUnknown(data['variant_id']!, _variantIdMeta));
    }
    if (data.containsKey('imei_item_id')) {
      context.handle(
          _imeiItemIdMeta,
          imeiItemId.isAcceptableOrUnknown(
              data['imei_item_id']!, _imeiItemIdMeta));
    }
    if (data.containsKey('name_snapshot')) {
      context.handle(
          _nameSnapshotMeta,
          nameSnapshot.isAcceptableOrUnknown(
              data['name_snapshot']!, _nameSnapshotMeta));
    } else if (isInserting) {
      context.missing(_nameSnapshotMeta);
    }
    if (data.containsKey('quantity')) {
      context.handle(_quantityMeta,
          quantity.isAcceptableOrUnknown(data['quantity']!, _quantityMeta));
    }
    if (data.containsKey('unit_price')) {
      context.handle(_unitPriceMeta,
          unitPrice.isAcceptableOrUnknown(data['unit_price']!, _unitPriceMeta));
    } else if (isInserting) {
      context.missing(_unitPriceMeta);
    }
    if (data.containsKey('purchase_cost')) {
      context.handle(
          _purchaseCostMeta,
          purchaseCost.isAcceptableOrUnknown(
              data['purchase_cost']!, _purchaseCostMeta));
    }
    if (data.containsKey('discount')) {
      context.handle(_discountMeta,
          discount.isAcceptableOrUnknown(data['discount']!, _discountMeta));
    }
    if (data.containsKey('total')) {
      context.handle(
          _totalMeta, total.isAcceptableOrUnknown(data['total']!, _totalMeta));
    } else if (isInserting) {
      context.missing(_totalMeta);
    }
    if (data.containsKey('profit')) {
      context.handle(_profitMeta,
          profit.isAcceptableOrUnknown(data['profit']!, _profitMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  SaleItem map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SaleItem(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      saleId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}sale_id'])!,
      productId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}product_id']),
      variantId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}variant_id']),
      imeiItemId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}imei_item_id']),
      nameSnapshot: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}name_snapshot'])!,
      quantity: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}quantity'])!,
      unitPrice: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}unit_price'])!,
      purchaseCost: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}purchase_cost'])!,
      discount: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}discount'])!,
      total: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}total'])!,
      profit: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}profit'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
    );
  }

  @override
  $SaleItemsTable createAlias(String alias) {
    return $SaleItemsTable(attachedDatabase, alias);
  }
}

class SaleItem extends DataClass implements Insertable<SaleItem> {
  final String id;
  final String saleId;
  final String? productId;
  final String? variantId;
  final String? imeiItemId;
  final String nameSnapshot;
  final int quantity;
  final int unitPrice;
  final int purchaseCost;
  final int discount;
  final int total;
  final int profit;
  final DateTime createdAt;
  const SaleItem(
      {required this.id,
      required this.saleId,
      this.productId,
      this.variantId,
      this.imeiItemId,
      required this.nameSnapshot,
      required this.quantity,
      required this.unitPrice,
      required this.purchaseCost,
      required this.discount,
      required this.total,
      required this.profit,
      required this.createdAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['sale_id'] = Variable<String>(saleId);
    if (!nullToAbsent || productId != null) {
      map['product_id'] = Variable<String>(productId);
    }
    if (!nullToAbsent || variantId != null) {
      map['variant_id'] = Variable<String>(variantId);
    }
    if (!nullToAbsent || imeiItemId != null) {
      map['imei_item_id'] = Variable<String>(imeiItemId);
    }
    map['name_snapshot'] = Variable<String>(nameSnapshot);
    map['quantity'] = Variable<int>(quantity);
    map['unit_price'] = Variable<int>(unitPrice);
    map['purchase_cost'] = Variable<int>(purchaseCost);
    map['discount'] = Variable<int>(discount);
    map['total'] = Variable<int>(total);
    map['profit'] = Variable<int>(profit);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  SaleItemsCompanion toCompanion(bool nullToAbsent) {
    return SaleItemsCompanion(
      id: Value(id),
      saleId: Value(saleId),
      productId: productId == null && nullToAbsent
          ? const Value.absent()
          : Value(productId),
      variantId: variantId == null && nullToAbsent
          ? const Value.absent()
          : Value(variantId),
      imeiItemId: imeiItemId == null && nullToAbsent
          ? const Value.absent()
          : Value(imeiItemId),
      nameSnapshot: Value(nameSnapshot),
      quantity: Value(quantity),
      unitPrice: Value(unitPrice),
      purchaseCost: Value(purchaseCost),
      discount: Value(discount),
      total: Value(total),
      profit: Value(profit),
      createdAt: Value(createdAt),
    );
  }

  factory SaleItem.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SaleItem(
      id: serializer.fromJson<String>(json['id']),
      saleId: serializer.fromJson<String>(json['saleId']),
      productId: serializer.fromJson<String?>(json['productId']),
      variantId: serializer.fromJson<String?>(json['variantId']),
      imeiItemId: serializer.fromJson<String?>(json['imeiItemId']),
      nameSnapshot: serializer.fromJson<String>(json['nameSnapshot']),
      quantity: serializer.fromJson<int>(json['quantity']),
      unitPrice: serializer.fromJson<int>(json['unitPrice']),
      purchaseCost: serializer.fromJson<int>(json['purchaseCost']),
      discount: serializer.fromJson<int>(json['discount']),
      total: serializer.fromJson<int>(json['total']),
      profit: serializer.fromJson<int>(json['profit']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'saleId': serializer.toJson<String>(saleId),
      'productId': serializer.toJson<String?>(productId),
      'variantId': serializer.toJson<String?>(variantId),
      'imeiItemId': serializer.toJson<String?>(imeiItemId),
      'nameSnapshot': serializer.toJson<String>(nameSnapshot),
      'quantity': serializer.toJson<int>(quantity),
      'unitPrice': serializer.toJson<int>(unitPrice),
      'purchaseCost': serializer.toJson<int>(purchaseCost),
      'discount': serializer.toJson<int>(discount),
      'total': serializer.toJson<int>(total),
      'profit': serializer.toJson<int>(profit),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  SaleItem copyWith(
          {String? id,
          String? saleId,
          Value<String?> productId = const Value.absent(),
          Value<String?> variantId = const Value.absent(),
          Value<String?> imeiItemId = const Value.absent(),
          String? nameSnapshot,
          int? quantity,
          int? unitPrice,
          int? purchaseCost,
          int? discount,
          int? total,
          int? profit,
          DateTime? createdAt}) =>
      SaleItem(
        id: id ?? this.id,
        saleId: saleId ?? this.saleId,
        productId: productId.present ? productId.value : this.productId,
        variantId: variantId.present ? variantId.value : this.variantId,
        imeiItemId: imeiItemId.present ? imeiItemId.value : this.imeiItemId,
        nameSnapshot: nameSnapshot ?? this.nameSnapshot,
        quantity: quantity ?? this.quantity,
        unitPrice: unitPrice ?? this.unitPrice,
        purchaseCost: purchaseCost ?? this.purchaseCost,
        discount: discount ?? this.discount,
        total: total ?? this.total,
        profit: profit ?? this.profit,
        createdAt: createdAt ?? this.createdAt,
      );
  SaleItem copyWithCompanion(SaleItemsCompanion data) {
    return SaleItem(
      id: data.id.present ? data.id.value : this.id,
      saleId: data.saleId.present ? data.saleId.value : this.saleId,
      productId: data.productId.present ? data.productId.value : this.productId,
      variantId: data.variantId.present ? data.variantId.value : this.variantId,
      imeiItemId:
          data.imeiItemId.present ? data.imeiItemId.value : this.imeiItemId,
      nameSnapshot: data.nameSnapshot.present
          ? data.nameSnapshot.value
          : this.nameSnapshot,
      quantity: data.quantity.present ? data.quantity.value : this.quantity,
      unitPrice: data.unitPrice.present ? data.unitPrice.value : this.unitPrice,
      purchaseCost: data.purchaseCost.present
          ? data.purchaseCost.value
          : this.purchaseCost,
      discount: data.discount.present ? data.discount.value : this.discount,
      total: data.total.present ? data.total.value : this.total,
      profit: data.profit.present ? data.profit.value : this.profit,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SaleItem(')
          ..write('id: $id, ')
          ..write('saleId: $saleId, ')
          ..write('productId: $productId, ')
          ..write('variantId: $variantId, ')
          ..write('imeiItemId: $imeiItemId, ')
          ..write('nameSnapshot: $nameSnapshot, ')
          ..write('quantity: $quantity, ')
          ..write('unitPrice: $unitPrice, ')
          ..write('purchaseCost: $purchaseCost, ')
          ..write('discount: $discount, ')
          ..write('total: $total, ')
          ..write('profit: $profit, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id,
      saleId,
      productId,
      variantId,
      imeiItemId,
      nameSnapshot,
      quantity,
      unitPrice,
      purchaseCost,
      discount,
      total,
      profit,
      createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SaleItem &&
          other.id == this.id &&
          other.saleId == this.saleId &&
          other.productId == this.productId &&
          other.variantId == this.variantId &&
          other.imeiItemId == this.imeiItemId &&
          other.nameSnapshot == this.nameSnapshot &&
          other.quantity == this.quantity &&
          other.unitPrice == this.unitPrice &&
          other.purchaseCost == this.purchaseCost &&
          other.discount == this.discount &&
          other.total == this.total &&
          other.profit == this.profit &&
          other.createdAt == this.createdAt);
}

class SaleItemsCompanion extends UpdateCompanion<SaleItem> {
  final Value<String> id;
  final Value<String> saleId;
  final Value<String?> productId;
  final Value<String?> variantId;
  final Value<String?> imeiItemId;
  final Value<String> nameSnapshot;
  final Value<int> quantity;
  final Value<int> unitPrice;
  final Value<int> purchaseCost;
  final Value<int> discount;
  final Value<int> total;
  final Value<int> profit;
  final Value<DateTime> createdAt;
  final Value<int> rowid;
  const SaleItemsCompanion({
    this.id = const Value.absent(),
    this.saleId = const Value.absent(),
    this.productId = const Value.absent(),
    this.variantId = const Value.absent(),
    this.imeiItemId = const Value.absent(),
    this.nameSnapshot = const Value.absent(),
    this.quantity = const Value.absent(),
    this.unitPrice = const Value.absent(),
    this.purchaseCost = const Value.absent(),
    this.discount = const Value.absent(),
    this.total = const Value.absent(),
    this.profit = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SaleItemsCompanion.insert({
    required String id,
    required String saleId,
    this.productId = const Value.absent(),
    this.variantId = const Value.absent(),
    this.imeiItemId = const Value.absent(),
    required String nameSnapshot,
    this.quantity = const Value.absent(),
    required int unitPrice,
    this.purchaseCost = const Value.absent(),
    this.discount = const Value.absent(),
    required int total,
    this.profit = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        saleId = Value(saleId),
        nameSnapshot = Value(nameSnapshot),
        unitPrice = Value(unitPrice),
        total = Value(total);
  static Insertable<SaleItem> custom({
    Expression<String>? id,
    Expression<String>? saleId,
    Expression<String>? productId,
    Expression<String>? variantId,
    Expression<String>? imeiItemId,
    Expression<String>? nameSnapshot,
    Expression<int>? quantity,
    Expression<int>? unitPrice,
    Expression<int>? purchaseCost,
    Expression<int>? discount,
    Expression<int>? total,
    Expression<int>? profit,
    Expression<DateTime>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (saleId != null) 'sale_id': saleId,
      if (productId != null) 'product_id': productId,
      if (variantId != null) 'variant_id': variantId,
      if (imeiItemId != null) 'imei_item_id': imeiItemId,
      if (nameSnapshot != null) 'name_snapshot': nameSnapshot,
      if (quantity != null) 'quantity': quantity,
      if (unitPrice != null) 'unit_price': unitPrice,
      if (purchaseCost != null) 'purchase_cost': purchaseCost,
      if (discount != null) 'discount': discount,
      if (total != null) 'total': total,
      if (profit != null) 'profit': profit,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  SaleItemsCompanion copyWith(
      {Value<String>? id,
      Value<String>? saleId,
      Value<String?>? productId,
      Value<String?>? variantId,
      Value<String?>? imeiItemId,
      Value<String>? nameSnapshot,
      Value<int>? quantity,
      Value<int>? unitPrice,
      Value<int>? purchaseCost,
      Value<int>? discount,
      Value<int>? total,
      Value<int>? profit,
      Value<DateTime>? createdAt,
      Value<int>? rowid}) {
    return SaleItemsCompanion(
      id: id ?? this.id,
      saleId: saleId ?? this.saleId,
      productId: productId ?? this.productId,
      variantId: variantId ?? this.variantId,
      imeiItemId: imeiItemId ?? this.imeiItemId,
      nameSnapshot: nameSnapshot ?? this.nameSnapshot,
      quantity: quantity ?? this.quantity,
      unitPrice: unitPrice ?? this.unitPrice,
      purchaseCost: purchaseCost ?? this.purchaseCost,
      discount: discount ?? this.discount,
      total: total ?? this.total,
      profit: profit ?? this.profit,
      createdAt: createdAt ?? this.createdAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (saleId.present) {
      map['sale_id'] = Variable<String>(saleId.value);
    }
    if (productId.present) {
      map['product_id'] = Variable<String>(productId.value);
    }
    if (variantId.present) {
      map['variant_id'] = Variable<String>(variantId.value);
    }
    if (imeiItemId.present) {
      map['imei_item_id'] = Variable<String>(imeiItemId.value);
    }
    if (nameSnapshot.present) {
      map['name_snapshot'] = Variable<String>(nameSnapshot.value);
    }
    if (quantity.present) {
      map['quantity'] = Variable<int>(quantity.value);
    }
    if (unitPrice.present) {
      map['unit_price'] = Variable<int>(unitPrice.value);
    }
    if (purchaseCost.present) {
      map['purchase_cost'] = Variable<int>(purchaseCost.value);
    }
    if (discount.present) {
      map['discount'] = Variable<int>(discount.value);
    }
    if (total.present) {
      map['total'] = Variable<int>(total.value);
    }
    if (profit.present) {
      map['profit'] = Variable<int>(profit.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SaleItemsCompanion(')
          ..write('id: $id, ')
          ..write('saleId: $saleId, ')
          ..write('productId: $productId, ')
          ..write('variantId: $variantId, ')
          ..write('imeiItemId: $imeiItemId, ')
          ..write('nameSnapshot: $nameSnapshot, ')
          ..write('quantity: $quantity, ')
          ..write('unitPrice: $unitPrice, ')
          ..write('purchaseCost: $purchaseCost, ')
          ..write('discount: $discount, ')
          ..write('total: $total, ')
          ..write('profit: $profit, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $SaleReturnsTable extends SaleReturns
    with TableInfo<$SaleReturnsTable, SaleReturn> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SaleReturnsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _saleIdMeta = const VerificationMeta('saleId');
  @override
  late final GeneratedColumn<String> saleId = GeneratedColumn<String>(
      'sale_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _saleItemIdMeta =
      const VerificationMeta('saleItemId');
  @override
  late final GeneratedColumn<String> saleItemId = GeneratedColumn<String>(
      'sale_item_id', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _imeiItemIdMeta =
      const VerificationMeta('imeiItemId');
  @override
  late final GeneratedColumn<String> imeiItemId = GeneratedColumn<String>(
      'imei_item_id', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _quantityMeta =
      const VerificationMeta('quantity');
  @override
  late final GeneratedColumn<int> quantity = GeneratedColumn<int>(
      'quantity', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(1));
  static const VerificationMeta _reasonMeta = const VerificationMeta('reason');
  @override
  late final GeneratedColumn<String> reason = GeneratedColumn<String>(
      'reason', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _refundAmountMeta =
      const VerificationMeta('refundAmount');
  @override
  late final GeneratedColumn<int> refundAmount = GeneratedColumn<int>(
      'refund_amount', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _isExchangeMeta =
      const VerificationMeta('isExchange');
  @override
  late final GeneratedColumn<bool> isExchange = GeneratedColumn<bool>(
      'is_exchange', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("is_exchange" IN (0, 1))'),
      defaultValue: const Constant(false));
  static const VerificationMeta _exchangeSaleIdMeta =
      const VerificationMeta('exchangeSaleId');
  @override
  late final GeneratedColumn<String> exchangeSaleId = GeneratedColumn<String>(
      'exchange_sale_id', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _userIdMeta = const VerificationMeta('userId');
  @override
  late final GeneratedColumn<String> userId = GeneratedColumn<String>(
      'user_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        saleId,
        saleItemId,
        imeiItemId,
        quantity,
        reason,
        refundAmount,
        isExchange,
        exchangeSaleId,
        userId,
        createdAt
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'sale_returns';
  @override
  VerificationContext validateIntegrity(Insertable<SaleReturn> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('sale_id')) {
      context.handle(_saleIdMeta,
          saleId.isAcceptableOrUnknown(data['sale_id']!, _saleIdMeta));
    } else if (isInserting) {
      context.missing(_saleIdMeta);
    }
    if (data.containsKey('sale_item_id')) {
      context.handle(
          _saleItemIdMeta,
          saleItemId.isAcceptableOrUnknown(
              data['sale_item_id']!, _saleItemIdMeta));
    }
    if (data.containsKey('imei_item_id')) {
      context.handle(
          _imeiItemIdMeta,
          imeiItemId.isAcceptableOrUnknown(
              data['imei_item_id']!, _imeiItemIdMeta));
    }
    if (data.containsKey('quantity')) {
      context.handle(_quantityMeta,
          quantity.isAcceptableOrUnknown(data['quantity']!, _quantityMeta));
    }
    if (data.containsKey('reason')) {
      context.handle(_reasonMeta,
          reason.isAcceptableOrUnknown(data['reason']!, _reasonMeta));
    }
    if (data.containsKey('refund_amount')) {
      context.handle(
          _refundAmountMeta,
          refundAmount.isAcceptableOrUnknown(
              data['refund_amount']!, _refundAmountMeta));
    }
    if (data.containsKey('is_exchange')) {
      context.handle(
          _isExchangeMeta,
          isExchange.isAcceptableOrUnknown(
              data['is_exchange']!, _isExchangeMeta));
    }
    if (data.containsKey('exchange_sale_id')) {
      context.handle(
          _exchangeSaleIdMeta,
          exchangeSaleId.isAcceptableOrUnknown(
              data['exchange_sale_id']!, _exchangeSaleIdMeta));
    }
    if (data.containsKey('user_id')) {
      context.handle(_userIdMeta,
          userId.isAcceptableOrUnknown(data['user_id']!, _userIdMeta));
    } else if (isInserting) {
      context.missing(_userIdMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  SaleReturn map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SaleReturn(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      saleId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}sale_id'])!,
      saleItemId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}sale_item_id']),
      imeiItemId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}imei_item_id']),
      quantity: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}quantity'])!,
      reason: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}reason']),
      refundAmount: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}refund_amount'])!,
      isExchange: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_exchange'])!,
      exchangeSaleId: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}exchange_sale_id']),
      userId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}user_id'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
    );
  }

  @override
  $SaleReturnsTable createAlias(String alias) {
    return $SaleReturnsTable(attachedDatabase, alias);
  }
}

class SaleReturn extends DataClass implements Insertable<SaleReturn> {
  final String id;
  final String saleId;
  final String? saleItemId;
  final String? imeiItemId;
  final int quantity;
  final String? reason;
  final int refundAmount;
  final bool isExchange;
  final String? exchangeSaleId;
  final String userId;
  final DateTime createdAt;
  const SaleReturn(
      {required this.id,
      required this.saleId,
      this.saleItemId,
      this.imeiItemId,
      required this.quantity,
      this.reason,
      required this.refundAmount,
      required this.isExchange,
      this.exchangeSaleId,
      required this.userId,
      required this.createdAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['sale_id'] = Variable<String>(saleId);
    if (!nullToAbsent || saleItemId != null) {
      map['sale_item_id'] = Variable<String>(saleItemId);
    }
    if (!nullToAbsent || imeiItemId != null) {
      map['imei_item_id'] = Variable<String>(imeiItemId);
    }
    map['quantity'] = Variable<int>(quantity);
    if (!nullToAbsent || reason != null) {
      map['reason'] = Variable<String>(reason);
    }
    map['refund_amount'] = Variable<int>(refundAmount);
    map['is_exchange'] = Variable<bool>(isExchange);
    if (!nullToAbsent || exchangeSaleId != null) {
      map['exchange_sale_id'] = Variable<String>(exchangeSaleId);
    }
    map['user_id'] = Variable<String>(userId);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  SaleReturnsCompanion toCompanion(bool nullToAbsent) {
    return SaleReturnsCompanion(
      id: Value(id),
      saleId: Value(saleId),
      saleItemId: saleItemId == null && nullToAbsent
          ? const Value.absent()
          : Value(saleItemId),
      imeiItemId: imeiItemId == null && nullToAbsent
          ? const Value.absent()
          : Value(imeiItemId),
      quantity: Value(quantity),
      reason:
          reason == null && nullToAbsent ? const Value.absent() : Value(reason),
      refundAmount: Value(refundAmount),
      isExchange: Value(isExchange),
      exchangeSaleId: exchangeSaleId == null && nullToAbsent
          ? const Value.absent()
          : Value(exchangeSaleId),
      userId: Value(userId),
      createdAt: Value(createdAt),
    );
  }

  factory SaleReturn.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SaleReturn(
      id: serializer.fromJson<String>(json['id']),
      saleId: serializer.fromJson<String>(json['saleId']),
      saleItemId: serializer.fromJson<String?>(json['saleItemId']),
      imeiItemId: serializer.fromJson<String?>(json['imeiItemId']),
      quantity: serializer.fromJson<int>(json['quantity']),
      reason: serializer.fromJson<String?>(json['reason']),
      refundAmount: serializer.fromJson<int>(json['refundAmount']),
      isExchange: serializer.fromJson<bool>(json['isExchange']),
      exchangeSaleId: serializer.fromJson<String?>(json['exchangeSaleId']),
      userId: serializer.fromJson<String>(json['userId']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'saleId': serializer.toJson<String>(saleId),
      'saleItemId': serializer.toJson<String?>(saleItemId),
      'imeiItemId': serializer.toJson<String?>(imeiItemId),
      'quantity': serializer.toJson<int>(quantity),
      'reason': serializer.toJson<String?>(reason),
      'refundAmount': serializer.toJson<int>(refundAmount),
      'isExchange': serializer.toJson<bool>(isExchange),
      'exchangeSaleId': serializer.toJson<String?>(exchangeSaleId),
      'userId': serializer.toJson<String>(userId),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  SaleReturn copyWith(
          {String? id,
          String? saleId,
          Value<String?> saleItemId = const Value.absent(),
          Value<String?> imeiItemId = const Value.absent(),
          int? quantity,
          Value<String?> reason = const Value.absent(),
          int? refundAmount,
          bool? isExchange,
          Value<String?> exchangeSaleId = const Value.absent(),
          String? userId,
          DateTime? createdAt}) =>
      SaleReturn(
        id: id ?? this.id,
        saleId: saleId ?? this.saleId,
        saleItemId: saleItemId.present ? saleItemId.value : this.saleItemId,
        imeiItemId: imeiItemId.present ? imeiItemId.value : this.imeiItemId,
        quantity: quantity ?? this.quantity,
        reason: reason.present ? reason.value : this.reason,
        refundAmount: refundAmount ?? this.refundAmount,
        isExchange: isExchange ?? this.isExchange,
        exchangeSaleId:
            exchangeSaleId.present ? exchangeSaleId.value : this.exchangeSaleId,
        userId: userId ?? this.userId,
        createdAt: createdAt ?? this.createdAt,
      );
  SaleReturn copyWithCompanion(SaleReturnsCompanion data) {
    return SaleReturn(
      id: data.id.present ? data.id.value : this.id,
      saleId: data.saleId.present ? data.saleId.value : this.saleId,
      saleItemId:
          data.saleItemId.present ? data.saleItemId.value : this.saleItemId,
      imeiItemId:
          data.imeiItemId.present ? data.imeiItemId.value : this.imeiItemId,
      quantity: data.quantity.present ? data.quantity.value : this.quantity,
      reason: data.reason.present ? data.reason.value : this.reason,
      refundAmount: data.refundAmount.present
          ? data.refundAmount.value
          : this.refundAmount,
      isExchange:
          data.isExchange.present ? data.isExchange.value : this.isExchange,
      exchangeSaleId: data.exchangeSaleId.present
          ? data.exchangeSaleId.value
          : this.exchangeSaleId,
      userId: data.userId.present ? data.userId.value : this.userId,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SaleReturn(')
          ..write('id: $id, ')
          ..write('saleId: $saleId, ')
          ..write('saleItemId: $saleItemId, ')
          ..write('imeiItemId: $imeiItemId, ')
          ..write('quantity: $quantity, ')
          ..write('reason: $reason, ')
          ..write('refundAmount: $refundAmount, ')
          ..write('isExchange: $isExchange, ')
          ..write('exchangeSaleId: $exchangeSaleId, ')
          ..write('userId: $userId, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, saleId, saleItemId, imeiItemId, quantity,
      reason, refundAmount, isExchange, exchangeSaleId, userId, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SaleReturn &&
          other.id == this.id &&
          other.saleId == this.saleId &&
          other.saleItemId == this.saleItemId &&
          other.imeiItemId == this.imeiItemId &&
          other.quantity == this.quantity &&
          other.reason == this.reason &&
          other.refundAmount == this.refundAmount &&
          other.isExchange == this.isExchange &&
          other.exchangeSaleId == this.exchangeSaleId &&
          other.userId == this.userId &&
          other.createdAt == this.createdAt);
}

class SaleReturnsCompanion extends UpdateCompanion<SaleReturn> {
  final Value<String> id;
  final Value<String> saleId;
  final Value<String?> saleItemId;
  final Value<String?> imeiItemId;
  final Value<int> quantity;
  final Value<String?> reason;
  final Value<int> refundAmount;
  final Value<bool> isExchange;
  final Value<String?> exchangeSaleId;
  final Value<String> userId;
  final Value<DateTime> createdAt;
  final Value<int> rowid;
  const SaleReturnsCompanion({
    this.id = const Value.absent(),
    this.saleId = const Value.absent(),
    this.saleItemId = const Value.absent(),
    this.imeiItemId = const Value.absent(),
    this.quantity = const Value.absent(),
    this.reason = const Value.absent(),
    this.refundAmount = const Value.absent(),
    this.isExchange = const Value.absent(),
    this.exchangeSaleId = const Value.absent(),
    this.userId = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SaleReturnsCompanion.insert({
    required String id,
    required String saleId,
    this.saleItemId = const Value.absent(),
    this.imeiItemId = const Value.absent(),
    this.quantity = const Value.absent(),
    this.reason = const Value.absent(),
    this.refundAmount = const Value.absent(),
    this.isExchange = const Value.absent(),
    this.exchangeSaleId = const Value.absent(),
    required String userId,
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        saleId = Value(saleId),
        userId = Value(userId);
  static Insertable<SaleReturn> custom({
    Expression<String>? id,
    Expression<String>? saleId,
    Expression<String>? saleItemId,
    Expression<String>? imeiItemId,
    Expression<int>? quantity,
    Expression<String>? reason,
    Expression<int>? refundAmount,
    Expression<bool>? isExchange,
    Expression<String>? exchangeSaleId,
    Expression<String>? userId,
    Expression<DateTime>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (saleId != null) 'sale_id': saleId,
      if (saleItemId != null) 'sale_item_id': saleItemId,
      if (imeiItemId != null) 'imei_item_id': imeiItemId,
      if (quantity != null) 'quantity': quantity,
      if (reason != null) 'reason': reason,
      if (refundAmount != null) 'refund_amount': refundAmount,
      if (isExchange != null) 'is_exchange': isExchange,
      if (exchangeSaleId != null) 'exchange_sale_id': exchangeSaleId,
      if (userId != null) 'user_id': userId,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  SaleReturnsCompanion copyWith(
      {Value<String>? id,
      Value<String>? saleId,
      Value<String?>? saleItemId,
      Value<String?>? imeiItemId,
      Value<int>? quantity,
      Value<String?>? reason,
      Value<int>? refundAmount,
      Value<bool>? isExchange,
      Value<String?>? exchangeSaleId,
      Value<String>? userId,
      Value<DateTime>? createdAt,
      Value<int>? rowid}) {
    return SaleReturnsCompanion(
      id: id ?? this.id,
      saleId: saleId ?? this.saleId,
      saleItemId: saleItemId ?? this.saleItemId,
      imeiItemId: imeiItemId ?? this.imeiItemId,
      quantity: quantity ?? this.quantity,
      reason: reason ?? this.reason,
      refundAmount: refundAmount ?? this.refundAmount,
      isExchange: isExchange ?? this.isExchange,
      exchangeSaleId: exchangeSaleId ?? this.exchangeSaleId,
      userId: userId ?? this.userId,
      createdAt: createdAt ?? this.createdAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (saleId.present) {
      map['sale_id'] = Variable<String>(saleId.value);
    }
    if (saleItemId.present) {
      map['sale_item_id'] = Variable<String>(saleItemId.value);
    }
    if (imeiItemId.present) {
      map['imei_item_id'] = Variable<String>(imeiItemId.value);
    }
    if (quantity.present) {
      map['quantity'] = Variable<int>(quantity.value);
    }
    if (reason.present) {
      map['reason'] = Variable<String>(reason.value);
    }
    if (refundAmount.present) {
      map['refund_amount'] = Variable<int>(refundAmount.value);
    }
    if (isExchange.present) {
      map['is_exchange'] = Variable<bool>(isExchange.value);
    }
    if (exchangeSaleId.present) {
      map['exchange_sale_id'] = Variable<String>(exchangeSaleId.value);
    }
    if (userId.present) {
      map['user_id'] = Variable<String>(userId.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SaleReturnsCompanion(')
          ..write('id: $id, ')
          ..write('saleId: $saleId, ')
          ..write('saleItemId: $saleItemId, ')
          ..write('imeiItemId: $imeiItemId, ')
          ..write('quantity: $quantity, ')
          ..write('reason: $reason, ')
          ..write('refundAmount: $refundAmount, ')
          ..write('isExchange: $isExchange, ')
          ..write('exchangeSaleId: $exchangeSaleId, ')
          ..write('userId: $userId, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $HeldBillsTable extends HeldBills
    with TableInfo<$HeldBillsTable, HeldBill> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $HeldBillsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _branchIdMeta =
      const VerificationMeta('branchId');
  @override
  late final GeneratedColumn<String> branchId = GeneratedColumn<String>(
      'branch_id', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _userIdMeta = const VerificationMeta('userId');
  @override
  late final GeneratedColumn<String> userId = GeneratedColumn<String>(
      'user_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _customerNameMeta =
      const VerificationMeta('customerName');
  @override
  late final GeneratedColumn<String> customerName = GeneratedColumn<String>(
      'customer_name', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _cartMeta = const VerificationMeta('cart');
  @override
  late final GeneratedColumn<String> cart = GeneratedColumn<String>(
      'cart', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('[]'));
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  @override
  List<GeneratedColumn> get $columns =>
      [id, branchId, userId, customerName, cart, createdAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'held_bills';
  @override
  VerificationContext validateIntegrity(Insertable<HeldBill> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('branch_id')) {
      context.handle(_branchIdMeta,
          branchId.isAcceptableOrUnknown(data['branch_id']!, _branchIdMeta));
    }
    if (data.containsKey('user_id')) {
      context.handle(_userIdMeta,
          userId.isAcceptableOrUnknown(data['user_id']!, _userIdMeta));
    } else if (isInserting) {
      context.missing(_userIdMeta);
    }
    if (data.containsKey('customer_name')) {
      context.handle(
          _customerNameMeta,
          customerName.isAcceptableOrUnknown(
              data['customer_name']!, _customerNameMeta));
    }
    if (data.containsKey('cart')) {
      context.handle(
          _cartMeta, cart.isAcceptableOrUnknown(data['cart']!, _cartMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  HeldBill map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return HeldBill(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      branchId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}branch_id']),
      userId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}user_id'])!,
      customerName: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}customer_name']),
      cart: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}cart'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
    );
  }

  @override
  $HeldBillsTable createAlias(String alias) {
    return $HeldBillsTable(attachedDatabase, alias);
  }
}

class HeldBill extends DataClass implements Insertable<HeldBill> {
  final String id;
  final String? branchId;
  final String userId;
  final String? customerName;
  final String cart;
  final DateTime createdAt;
  const HeldBill(
      {required this.id,
      this.branchId,
      required this.userId,
      this.customerName,
      required this.cart,
      required this.createdAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    if (!nullToAbsent || branchId != null) {
      map['branch_id'] = Variable<String>(branchId);
    }
    map['user_id'] = Variable<String>(userId);
    if (!nullToAbsent || customerName != null) {
      map['customer_name'] = Variable<String>(customerName);
    }
    map['cart'] = Variable<String>(cart);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  HeldBillsCompanion toCompanion(bool nullToAbsent) {
    return HeldBillsCompanion(
      id: Value(id),
      branchId: branchId == null && nullToAbsent
          ? const Value.absent()
          : Value(branchId),
      userId: Value(userId),
      customerName: customerName == null && nullToAbsent
          ? const Value.absent()
          : Value(customerName),
      cart: Value(cart),
      createdAt: Value(createdAt),
    );
  }

  factory HeldBill.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return HeldBill(
      id: serializer.fromJson<String>(json['id']),
      branchId: serializer.fromJson<String?>(json['branchId']),
      userId: serializer.fromJson<String>(json['userId']),
      customerName: serializer.fromJson<String?>(json['customerName']),
      cart: serializer.fromJson<String>(json['cart']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'branchId': serializer.toJson<String?>(branchId),
      'userId': serializer.toJson<String>(userId),
      'customerName': serializer.toJson<String?>(customerName),
      'cart': serializer.toJson<String>(cart),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  HeldBill copyWith(
          {String? id,
          Value<String?> branchId = const Value.absent(),
          String? userId,
          Value<String?> customerName = const Value.absent(),
          String? cart,
          DateTime? createdAt}) =>
      HeldBill(
        id: id ?? this.id,
        branchId: branchId.present ? branchId.value : this.branchId,
        userId: userId ?? this.userId,
        customerName:
            customerName.present ? customerName.value : this.customerName,
        cart: cart ?? this.cart,
        createdAt: createdAt ?? this.createdAt,
      );
  HeldBill copyWithCompanion(HeldBillsCompanion data) {
    return HeldBill(
      id: data.id.present ? data.id.value : this.id,
      branchId: data.branchId.present ? data.branchId.value : this.branchId,
      userId: data.userId.present ? data.userId.value : this.userId,
      customerName: data.customerName.present
          ? data.customerName.value
          : this.customerName,
      cart: data.cart.present ? data.cart.value : this.cart,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('HeldBill(')
          ..write('id: $id, ')
          ..write('branchId: $branchId, ')
          ..write('userId: $userId, ')
          ..write('customerName: $customerName, ')
          ..write('cart: $cart, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, branchId, userId, customerName, cart, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is HeldBill &&
          other.id == this.id &&
          other.branchId == this.branchId &&
          other.userId == this.userId &&
          other.customerName == this.customerName &&
          other.cart == this.cart &&
          other.createdAt == this.createdAt);
}

class HeldBillsCompanion extends UpdateCompanion<HeldBill> {
  final Value<String> id;
  final Value<String?> branchId;
  final Value<String> userId;
  final Value<String?> customerName;
  final Value<String> cart;
  final Value<DateTime> createdAt;
  final Value<int> rowid;
  const HeldBillsCompanion({
    this.id = const Value.absent(),
    this.branchId = const Value.absent(),
    this.userId = const Value.absent(),
    this.customerName = const Value.absent(),
    this.cart = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  HeldBillsCompanion.insert({
    required String id,
    this.branchId = const Value.absent(),
    required String userId,
    this.customerName = const Value.absent(),
    this.cart = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        userId = Value(userId);
  static Insertable<HeldBill> custom({
    Expression<String>? id,
    Expression<String>? branchId,
    Expression<String>? userId,
    Expression<String>? customerName,
    Expression<String>? cart,
    Expression<DateTime>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (branchId != null) 'branch_id': branchId,
      if (userId != null) 'user_id': userId,
      if (customerName != null) 'customer_name': customerName,
      if (cart != null) 'cart': cart,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  HeldBillsCompanion copyWith(
      {Value<String>? id,
      Value<String?>? branchId,
      Value<String>? userId,
      Value<String?>? customerName,
      Value<String>? cart,
      Value<DateTime>? createdAt,
      Value<int>? rowid}) {
    return HeldBillsCompanion(
      id: id ?? this.id,
      branchId: branchId ?? this.branchId,
      userId: userId ?? this.userId,
      customerName: customerName ?? this.customerName,
      cart: cart ?? this.cart,
      createdAt: createdAt ?? this.createdAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (branchId.present) {
      map['branch_id'] = Variable<String>(branchId.value);
    }
    if (userId.present) {
      map['user_id'] = Variable<String>(userId.value);
    }
    if (customerName.present) {
      map['customer_name'] = Variable<String>(customerName.value);
    }
    if (cart.present) {
      map['cart'] = Variable<String>(cart.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('HeldBillsCompanion(')
          ..write('id: $id, ')
          ..write('branchId: $branchId, ')
          ..write('userId: $userId, ')
          ..write('customerName: $customerName, ')
          ..write('cart: $cart, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $PurchasesTable extends Purchases
    with TableInfo<$PurchasesTable, Purchase> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PurchasesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _supplierIdMeta =
      const VerificationMeta('supplierId');
  @override
  late final GeneratedColumn<String> supplierId = GeneratedColumn<String>(
      'supplier_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _branchIdMeta =
      const VerificationMeta('branchId');
  @override
  late final GeneratedColumn<String> branchId = GeneratedColumn<String>(
      'branch_id', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _userIdMeta = const VerificationMeta('userId');
  @override
  late final GeneratedColumn<String> userId = GeneratedColumn<String>(
      'user_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _supplierInvoiceNoMeta =
      const VerificationMeta('supplierInvoiceNo');
  @override
  late final GeneratedColumn<String> supplierInvoiceNo =
      GeneratedColumn<String>('supplier_invoice_no', aliasedName, true,
          type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _purchaseDateMeta =
      const VerificationMeta('purchaseDate');
  @override
  late final GeneratedColumn<DateTime> purchaseDate = GeneratedColumn<DateTime>(
      'purchase_date', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  static const VerificationMeta _subtotalMeta =
      const VerificationMeta('subtotal');
  @override
  late final GeneratedColumn<int> subtotal = GeneratedColumn<int>(
      'subtotal', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _discountMeta =
      const VerificationMeta('discount');
  @override
  late final GeneratedColumn<int> discount = GeneratedColumn<int>(
      'discount', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _grandTotalMeta =
      const VerificationMeta('grandTotal');
  @override
  late final GeneratedColumn<int> grandTotal = GeneratedColumn<int>(
      'grand_total', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _paidAmountMeta =
      const VerificationMeta('paidAmount');
  @override
  late final GeneratedColumn<int> paidAmount = GeneratedColumn<int>(
      'paid_amount', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _balanceDueMeta =
      const VerificationMeta('balanceDue');
  @override
  late final GeneratedColumn<int> balanceDue = GeneratedColumn<int>(
      'balance_due', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
      'status', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('received'));
  static const VerificationMeta _notesMeta = const VerificationMeta('notes');
  @override
  late final GeneratedColumn<String> notes = GeneratedColumn<String>(
      'notes', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _clientUuidMeta =
      const VerificationMeta('clientUuid');
  @override
  late final GeneratedColumn<String> clientUuid = GeneratedColumn<String>(
      'client_uuid', aliasedName, true,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'));
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  static const VerificationMeta _updatedAtMeta =
      const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
      'updated_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        supplierId,
        branchId,
        userId,
        supplierInvoiceNo,
        purchaseDate,
        subtotal,
        discount,
        grandTotal,
        paidAmount,
        balanceDue,
        status,
        notes,
        clientUuid,
        createdAt,
        updatedAt
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'purchases';
  @override
  VerificationContext validateIntegrity(Insertable<Purchase> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('supplier_id')) {
      context.handle(
          _supplierIdMeta,
          supplierId.isAcceptableOrUnknown(
              data['supplier_id']!, _supplierIdMeta));
    } else if (isInserting) {
      context.missing(_supplierIdMeta);
    }
    if (data.containsKey('branch_id')) {
      context.handle(_branchIdMeta,
          branchId.isAcceptableOrUnknown(data['branch_id']!, _branchIdMeta));
    }
    if (data.containsKey('user_id')) {
      context.handle(_userIdMeta,
          userId.isAcceptableOrUnknown(data['user_id']!, _userIdMeta));
    } else if (isInserting) {
      context.missing(_userIdMeta);
    }
    if (data.containsKey('supplier_invoice_no')) {
      context.handle(
          _supplierInvoiceNoMeta,
          supplierInvoiceNo.isAcceptableOrUnknown(
              data['supplier_invoice_no']!, _supplierInvoiceNoMeta));
    }
    if (data.containsKey('purchase_date')) {
      context.handle(
          _purchaseDateMeta,
          purchaseDate.isAcceptableOrUnknown(
              data['purchase_date']!, _purchaseDateMeta));
    }
    if (data.containsKey('subtotal')) {
      context.handle(_subtotalMeta,
          subtotal.isAcceptableOrUnknown(data['subtotal']!, _subtotalMeta));
    }
    if (data.containsKey('discount')) {
      context.handle(_discountMeta,
          discount.isAcceptableOrUnknown(data['discount']!, _discountMeta));
    }
    if (data.containsKey('grand_total')) {
      context.handle(
          _grandTotalMeta,
          grandTotal.isAcceptableOrUnknown(
              data['grand_total']!, _grandTotalMeta));
    }
    if (data.containsKey('paid_amount')) {
      context.handle(
          _paidAmountMeta,
          paidAmount.isAcceptableOrUnknown(
              data['paid_amount']!, _paidAmountMeta));
    }
    if (data.containsKey('balance_due')) {
      context.handle(
          _balanceDueMeta,
          balanceDue.isAcceptableOrUnknown(
              data['balance_due']!, _balanceDueMeta));
    }
    if (data.containsKey('status')) {
      context.handle(_statusMeta,
          status.isAcceptableOrUnknown(data['status']!, _statusMeta));
    }
    if (data.containsKey('notes')) {
      context.handle(
          _notesMeta, notes.isAcceptableOrUnknown(data['notes']!, _notesMeta));
    }
    if (data.containsKey('client_uuid')) {
      context.handle(
          _clientUuidMeta,
          clientUuid.isAcceptableOrUnknown(
              data['client_uuid']!, _clientUuidMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    }
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta,
          updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Purchase map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Purchase(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      supplierId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}supplier_id'])!,
      branchId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}branch_id']),
      userId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}user_id'])!,
      supplierInvoiceNo: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}supplier_invoice_no']),
      purchaseDate: attachedDatabase.typeMapping.read(
          DriftSqlType.dateTime, data['${effectivePrefix}purchase_date'])!,
      subtotal: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}subtotal'])!,
      discount: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}discount'])!,
      grandTotal: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}grand_total'])!,
      paidAmount: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}paid_amount'])!,
      balanceDue: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}balance_due'])!,
      status: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}status'])!,
      notes: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}notes']),
      clientUuid: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}client_uuid']),
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}updated_at'])!,
    );
  }

  @override
  $PurchasesTable createAlias(String alias) {
    return $PurchasesTable(attachedDatabase, alias);
  }
}

class Purchase extends DataClass implements Insertable<Purchase> {
  final String id;
  final String supplierId;
  final String? branchId;
  final String userId;
  final String? supplierInvoiceNo;
  final DateTime purchaseDate;
  final int subtotal;
  final int discount;
  final int grandTotal;
  final int paidAmount;
  final int balanceDue;
  final String status;
  final String? notes;
  final String? clientUuid;
  final DateTime createdAt;
  final DateTime updatedAt;
  const Purchase(
      {required this.id,
      required this.supplierId,
      this.branchId,
      required this.userId,
      this.supplierInvoiceNo,
      required this.purchaseDate,
      required this.subtotal,
      required this.discount,
      required this.grandTotal,
      required this.paidAmount,
      required this.balanceDue,
      required this.status,
      this.notes,
      this.clientUuid,
      required this.createdAt,
      required this.updatedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['supplier_id'] = Variable<String>(supplierId);
    if (!nullToAbsent || branchId != null) {
      map['branch_id'] = Variable<String>(branchId);
    }
    map['user_id'] = Variable<String>(userId);
    if (!nullToAbsent || supplierInvoiceNo != null) {
      map['supplier_invoice_no'] = Variable<String>(supplierInvoiceNo);
    }
    map['purchase_date'] = Variable<DateTime>(purchaseDate);
    map['subtotal'] = Variable<int>(subtotal);
    map['discount'] = Variable<int>(discount);
    map['grand_total'] = Variable<int>(grandTotal);
    map['paid_amount'] = Variable<int>(paidAmount);
    map['balance_due'] = Variable<int>(balanceDue);
    map['status'] = Variable<String>(status);
    if (!nullToAbsent || notes != null) {
      map['notes'] = Variable<String>(notes);
    }
    if (!nullToAbsent || clientUuid != null) {
      map['client_uuid'] = Variable<String>(clientUuid);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  PurchasesCompanion toCompanion(bool nullToAbsent) {
    return PurchasesCompanion(
      id: Value(id),
      supplierId: Value(supplierId),
      branchId: branchId == null && nullToAbsent
          ? const Value.absent()
          : Value(branchId),
      userId: Value(userId),
      supplierInvoiceNo: supplierInvoiceNo == null && nullToAbsent
          ? const Value.absent()
          : Value(supplierInvoiceNo),
      purchaseDate: Value(purchaseDate),
      subtotal: Value(subtotal),
      discount: Value(discount),
      grandTotal: Value(grandTotal),
      paidAmount: Value(paidAmount),
      balanceDue: Value(balanceDue),
      status: Value(status),
      notes:
          notes == null && nullToAbsent ? const Value.absent() : Value(notes),
      clientUuid: clientUuid == null && nullToAbsent
          ? const Value.absent()
          : Value(clientUuid),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory Purchase.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Purchase(
      id: serializer.fromJson<String>(json['id']),
      supplierId: serializer.fromJson<String>(json['supplierId']),
      branchId: serializer.fromJson<String?>(json['branchId']),
      userId: serializer.fromJson<String>(json['userId']),
      supplierInvoiceNo:
          serializer.fromJson<String?>(json['supplierInvoiceNo']),
      purchaseDate: serializer.fromJson<DateTime>(json['purchaseDate']),
      subtotal: serializer.fromJson<int>(json['subtotal']),
      discount: serializer.fromJson<int>(json['discount']),
      grandTotal: serializer.fromJson<int>(json['grandTotal']),
      paidAmount: serializer.fromJson<int>(json['paidAmount']),
      balanceDue: serializer.fromJson<int>(json['balanceDue']),
      status: serializer.fromJson<String>(json['status']),
      notes: serializer.fromJson<String?>(json['notes']),
      clientUuid: serializer.fromJson<String?>(json['clientUuid']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'supplierId': serializer.toJson<String>(supplierId),
      'branchId': serializer.toJson<String?>(branchId),
      'userId': serializer.toJson<String>(userId),
      'supplierInvoiceNo': serializer.toJson<String?>(supplierInvoiceNo),
      'purchaseDate': serializer.toJson<DateTime>(purchaseDate),
      'subtotal': serializer.toJson<int>(subtotal),
      'discount': serializer.toJson<int>(discount),
      'grandTotal': serializer.toJson<int>(grandTotal),
      'paidAmount': serializer.toJson<int>(paidAmount),
      'balanceDue': serializer.toJson<int>(balanceDue),
      'status': serializer.toJson<String>(status),
      'notes': serializer.toJson<String?>(notes),
      'clientUuid': serializer.toJson<String?>(clientUuid),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  Purchase copyWith(
          {String? id,
          String? supplierId,
          Value<String?> branchId = const Value.absent(),
          String? userId,
          Value<String?> supplierInvoiceNo = const Value.absent(),
          DateTime? purchaseDate,
          int? subtotal,
          int? discount,
          int? grandTotal,
          int? paidAmount,
          int? balanceDue,
          String? status,
          Value<String?> notes = const Value.absent(),
          Value<String?> clientUuid = const Value.absent(),
          DateTime? createdAt,
          DateTime? updatedAt}) =>
      Purchase(
        id: id ?? this.id,
        supplierId: supplierId ?? this.supplierId,
        branchId: branchId.present ? branchId.value : this.branchId,
        userId: userId ?? this.userId,
        supplierInvoiceNo: supplierInvoiceNo.present
            ? supplierInvoiceNo.value
            : this.supplierInvoiceNo,
        purchaseDate: purchaseDate ?? this.purchaseDate,
        subtotal: subtotal ?? this.subtotal,
        discount: discount ?? this.discount,
        grandTotal: grandTotal ?? this.grandTotal,
        paidAmount: paidAmount ?? this.paidAmount,
        balanceDue: balanceDue ?? this.balanceDue,
        status: status ?? this.status,
        notes: notes.present ? notes.value : this.notes,
        clientUuid: clientUuid.present ? clientUuid.value : this.clientUuid,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
      );
  Purchase copyWithCompanion(PurchasesCompanion data) {
    return Purchase(
      id: data.id.present ? data.id.value : this.id,
      supplierId:
          data.supplierId.present ? data.supplierId.value : this.supplierId,
      branchId: data.branchId.present ? data.branchId.value : this.branchId,
      userId: data.userId.present ? data.userId.value : this.userId,
      supplierInvoiceNo: data.supplierInvoiceNo.present
          ? data.supplierInvoiceNo.value
          : this.supplierInvoiceNo,
      purchaseDate: data.purchaseDate.present
          ? data.purchaseDate.value
          : this.purchaseDate,
      subtotal: data.subtotal.present ? data.subtotal.value : this.subtotal,
      discount: data.discount.present ? data.discount.value : this.discount,
      grandTotal:
          data.grandTotal.present ? data.grandTotal.value : this.grandTotal,
      paidAmount:
          data.paidAmount.present ? data.paidAmount.value : this.paidAmount,
      balanceDue:
          data.balanceDue.present ? data.balanceDue.value : this.balanceDue,
      status: data.status.present ? data.status.value : this.status,
      notes: data.notes.present ? data.notes.value : this.notes,
      clientUuid:
          data.clientUuid.present ? data.clientUuid.value : this.clientUuid,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Purchase(')
          ..write('id: $id, ')
          ..write('supplierId: $supplierId, ')
          ..write('branchId: $branchId, ')
          ..write('userId: $userId, ')
          ..write('supplierInvoiceNo: $supplierInvoiceNo, ')
          ..write('purchaseDate: $purchaseDate, ')
          ..write('subtotal: $subtotal, ')
          ..write('discount: $discount, ')
          ..write('grandTotal: $grandTotal, ')
          ..write('paidAmount: $paidAmount, ')
          ..write('balanceDue: $balanceDue, ')
          ..write('status: $status, ')
          ..write('notes: $notes, ')
          ..write('clientUuid: $clientUuid, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id,
      supplierId,
      branchId,
      userId,
      supplierInvoiceNo,
      purchaseDate,
      subtotal,
      discount,
      grandTotal,
      paidAmount,
      balanceDue,
      status,
      notes,
      clientUuid,
      createdAt,
      updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Purchase &&
          other.id == this.id &&
          other.supplierId == this.supplierId &&
          other.branchId == this.branchId &&
          other.userId == this.userId &&
          other.supplierInvoiceNo == this.supplierInvoiceNo &&
          other.purchaseDate == this.purchaseDate &&
          other.subtotal == this.subtotal &&
          other.discount == this.discount &&
          other.grandTotal == this.grandTotal &&
          other.paidAmount == this.paidAmount &&
          other.balanceDue == this.balanceDue &&
          other.status == this.status &&
          other.notes == this.notes &&
          other.clientUuid == this.clientUuid &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class PurchasesCompanion extends UpdateCompanion<Purchase> {
  final Value<String> id;
  final Value<String> supplierId;
  final Value<String?> branchId;
  final Value<String> userId;
  final Value<String?> supplierInvoiceNo;
  final Value<DateTime> purchaseDate;
  final Value<int> subtotal;
  final Value<int> discount;
  final Value<int> grandTotal;
  final Value<int> paidAmount;
  final Value<int> balanceDue;
  final Value<String> status;
  final Value<String?> notes;
  final Value<String?> clientUuid;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const PurchasesCompanion({
    this.id = const Value.absent(),
    this.supplierId = const Value.absent(),
    this.branchId = const Value.absent(),
    this.userId = const Value.absent(),
    this.supplierInvoiceNo = const Value.absent(),
    this.purchaseDate = const Value.absent(),
    this.subtotal = const Value.absent(),
    this.discount = const Value.absent(),
    this.grandTotal = const Value.absent(),
    this.paidAmount = const Value.absent(),
    this.balanceDue = const Value.absent(),
    this.status = const Value.absent(),
    this.notes = const Value.absent(),
    this.clientUuid = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  PurchasesCompanion.insert({
    required String id,
    required String supplierId,
    this.branchId = const Value.absent(),
    required String userId,
    this.supplierInvoiceNo = const Value.absent(),
    this.purchaseDate = const Value.absent(),
    this.subtotal = const Value.absent(),
    this.discount = const Value.absent(),
    this.grandTotal = const Value.absent(),
    this.paidAmount = const Value.absent(),
    this.balanceDue = const Value.absent(),
    this.status = const Value.absent(),
    this.notes = const Value.absent(),
    this.clientUuid = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        supplierId = Value(supplierId),
        userId = Value(userId);
  static Insertable<Purchase> custom({
    Expression<String>? id,
    Expression<String>? supplierId,
    Expression<String>? branchId,
    Expression<String>? userId,
    Expression<String>? supplierInvoiceNo,
    Expression<DateTime>? purchaseDate,
    Expression<int>? subtotal,
    Expression<int>? discount,
    Expression<int>? grandTotal,
    Expression<int>? paidAmount,
    Expression<int>? balanceDue,
    Expression<String>? status,
    Expression<String>? notes,
    Expression<String>? clientUuid,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (supplierId != null) 'supplier_id': supplierId,
      if (branchId != null) 'branch_id': branchId,
      if (userId != null) 'user_id': userId,
      if (supplierInvoiceNo != null) 'supplier_invoice_no': supplierInvoiceNo,
      if (purchaseDate != null) 'purchase_date': purchaseDate,
      if (subtotal != null) 'subtotal': subtotal,
      if (discount != null) 'discount': discount,
      if (grandTotal != null) 'grand_total': grandTotal,
      if (paidAmount != null) 'paid_amount': paidAmount,
      if (balanceDue != null) 'balance_due': balanceDue,
      if (status != null) 'status': status,
      if (notes != null) 'notes': notes,
      if (clientUuid != null) 'client_uuid': clientUuid,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  PurchasesCompanion copyWith(
      {Value<String>? id,
      Value<String>? supplierId,
      Value<String?>? branchId,
      Value<String>? userId,
      Value<String?>? supplierInvoiceNo,
      Value<DateTime>? purchaseDate,
      Value<int>? subtotal,
      Value<int>? discount,
      Value<int>? grandTotal,
      Value<int>? paidAmount,
      Value<int>? balanceDue,
      Value<String>? status,
      Value<String?>? notes,
      Value<String?>? clientUuid,
      Value<DateTime>? createdAt,
      Value<DateTime>? updatedAt,
      Value<int>? rowid}) {
    return PurchasesCompanion(
      id: id ?? this.id,
      supplierId: supplierId ?? this.supplierId,
      branchId: branchId ?? this.branchId,
      userId: userId ?? this.userId,
      supplierInvoiceNo: supplierInvoiceNo ?? this.supplierInvoiceNo,
      purchaseDate: purchaseDate ?? this.purchaseDate,
      subtotal: subtotal ?? this.subtotal,
      discount: discount ?? this.discount,
      grandTotal: grandTotal ?? this.grandTotal,
      paidAmount: paidAmount ?? this.paidAmount,
      balanceDue: balanceDue ?? this.balanceDue,
      status: status ?? this.status,
      notes: notes ?? this.notes,
      clientUuid: clientUuid ?? this.clientUuid,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (supplierId.present) {
      map['supplier_id'] = Variable<String>(supplierId.value);
    }
    if (branchId.present) {
      map['branch_id'] = Variable<String>(branchId.value);
    }
    if (userId.present) {
      map['user_id'] = Variable<String>(userId.value);
    }
    if (supplierInvoiceNo.present) {
      map['supplier_invoice_no'] = Variable<String>(supplierInvoiceNo.value);
    }
    if (purchaseDate.present) {
      map['purchase_date'] = Variable<DateTime>(purchaseDate.value);
    }
    if (subtotal.present) {
      map['subtotal'] = Variable<int>(subtotal.value);
    }
    if (discount.present) {
      map['discount'] = Variable<int>(discount.value);
    }
    if (grandTotal.present) {
      map['grand_total'] = Variable<int>(grandTotal.value);
    }
    if (paidAmount.present) {
      map['paid_amount'] = Variable<int>(paidAmount.value);
    }
    if (balanceDue.present) {
      map['balance_due'] = Variable<int>(balanceDue.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    if (clientUuid.present) {
      map['client_uuid'] = Variable<String>(clientUuid.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PurchasesCompanion(')
          ..write('id: $id, ')
          ..write('supplierId: $supplierId, ')
          ..write('branchId: $branchId, ')
          ..write('userId: $userId, ')
          ..write('supplierInvoiceNo: $supplierInvoiceNo, ')
          ..write('purchaseDate: $purchaseDate, ')
          ..write('subtotal: $subtotal, ')
          ..write('discount: $discount, ')
          ..write('grandTotal: $grandTotal, ')
          ..write('paidAmount: $paidAmount, ')
          ..write('balanceDue: $balanceDue, ')
          ..write('status: $status, ')
          ..write('notes: $notes, ')
          ..write('clientUuid: $clientUuid, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $PurchaseItemsTable extends PurchaseItems
    with TableInfo<$PurchaseItemsTable, PurchaseItem> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PurchaseItemsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _purchaseIdMeta =
      const VerificationMeta('purchaseId');
  @override
  late final GeneratedColumn<String> purchaseId = GeneratedColumn<String>(
      'purchase_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _productIdMeta =
      const VerificationMeta('productId');
  @override
  late final GeneratedColumn<String> productId = GeneratedColumn<String>(
      'product_id', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _variantIdMeta =
      const VerificationMeta('variantId');
  @override
  late final GeneratedColumn<String> variantId = GeneratedColumn<String>(
      'variant_id', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _imei1Meta = const VerificationMeta('imei1');
  @override
  late final GeneratedColumn<String> imei1 = GeneratedColumn<String>(
      'imei1', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _imei2Meta = const VerificationMeta('imei2');
  @override
  late final GeneratedColumn<String> imei2 = GeneratedColumn<String>(
      'imei2', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _catalogSkuMeta =
      const VerificationMeta('catalogSku');
  @override
  late final GeneratedColumn<String> catalogSku = GeneratedColumn<String>(
      'catalog_sku', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _quantityMeta =
      const VerificationMeta('quantity');
  @override
  late final GeneratedColumn<int> quantity = GeneratedColumn<int>(
      'quantity', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(1));
  static const VerificationMeta _unitCostMeta =
      const VerificationMeta('unitCost');
  @override
  late final GeneratedColumn<int> unitCost = GeneratedColumn<int>(
      'unit_cost', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _totalMeta = const VerificationMeta('total');
  @override
  late final GeneratedColumn<int> total = GeneratedColumn<int>(
      'total', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        purchaseId,
        productId,
        variantId,
        imei1,
        imei2,
        catalogSku,
        quantity,
        unitCost,
        total,
        createdAt
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'purchase_items';
  @override
  VerificationContext validateIntegrity(Insertable<PurchaseItem> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('purchase_id')) {
      context.handle(
          _purchaseIdMeta,
          purchaseId.isAcceptableOrUnknown(
              data['purchase_id']!, _purchaseIdMeta));
    } else if (isInserting) {
      context.missing(_purchaseIdMeta);
    }
    if (data.containsKey('product_id')) {
      context.handle(_productIdMeta,
          productId.isAcceptableOrUnknown(data['product_id']!, _productIdMeta));
    }
    if (data.containsKey('variant_id')) {
      context.handle(_variantIdMeta,
          variantId.isAcceptableOrUnknown(data['variant_id']!, _variantIdMeta));
    }
    if (data.containsKey('imei1')) {
      context.handle(
          _imei1Meta, imei1.isAcceptableOrUnknown(data['imei1']!, _imei1Meta));
    }
    if (data.containsKey('imei2')) {
      context.handle(
          _imei2Meta, imei2.isAcceptableOrUnknown(data['imei2']!, _imei2Meta));
    }
    if (data.containsKey('catalog_sku')) {
      context.handle(
          _catalogSkuMeta,
          catalogSku.isAcceptableOrUnknown(
              data['catalog_sku']!, _catalogSkuMeta));
    }
    if (data.containsKey('quantity')) {
      context.handle(_quantityMeta,
          quantity.isAcceptableOrUnknown(data['quantity']!, _quantityMeta));
    }
    if (data.containsKey('unit_cost')) {
      context.handle(_unitCostMeta,
          unitCost.isAcceptableOrUnknown(data['unit_cost']!, _unitCostMeta));
    } else if (isInserting) {
      context.missing(_unitCostMeta);
    }
    if (data.containsKey('total')) {
      context.handle(
          _totalMeta, total.isAcceptableOrUnknown(data['total']!, _totalMeta));
    } else if (isInserting) {
      context.missing(_totalMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  PurchaseItem map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return PurchaseItem(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      purchaseId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}purchase_id'])!,
      productId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}product_id']),
      variantId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}variant_id']),
      imei1: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}imei1']),
      imei2: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}imei2']),
      catalogSku: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}catalog_sku']),
      quantity: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}quantity'])!,
      unitCost: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}unit_cost'])!,
      total: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}total'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
    );
  }

  @override
  $PurchaseItemsTable createAlias(String alias) {
    return $PurchaseItemsTable(attachedDatabase, alias);
  }
}

class PurchaseItem extends DataClass implements Insertable<PurchaseItem> {
  final String id;
  final String purchaseId;
  final String? productId;
  final String? variantId;
  final String? imei1;
  final String? imei2;
  final String? catalogSku;
  final int quantity;
  final int unitCost;
  final int total;
  final DateTime createdAt;
  const PurchaseItem(
      {required this.id,
      required this.purchaseId,
      this.productId,
      this.variantId,
      this.imei1,
      this.imei2,
      this.catalogSku,
      required this.quantity,
      required this.unitCost,
      required this.total,
      required this.createdAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['purchase_id'] = Variable<String>(purchaseId);
    if (!nullToAbsent || productId != null) {
      map['product_id'] = Variable<String>(productId);
    }
    if (!nullToAbsent || variantId != null) {
      map['variant_id'] = Variable<String>(variantId);
    }
    if (!nullToAbsent || imei1 != null) {
      map['imei1'] = Variable<String>(imei1);
    }
    if (!nullToAbsent || imei2 != null) {
      map['imei2'] = Variable<String>(imei2);
    }
    if (!nullToAbsent || catalogSku != null) {
      map['catalog_sku'] = Variable<String>(catalogSku);
    }
    map['quantity'] = Variable<int>(quantity);
    map['unit_cost'] = Variable<int>(unitCost);
    map['total'] = Variable<int>(total);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  PurchaseItemsCompanion toCompanion(bool nullToAbsent) {
    return PurchaseItemsCompanion(
      id: Value(id),
      purchaseId: Value(purchaseId),
      productId: productId == null && nullToAbsent
          ? const Value.absent()
          : Value(productId),
      variantId: variantId == null && nullToAbsent
          ? const Value.absent()
          : Value(variantId),
      imei1:
          imei1 == null && nullToAbsent ? const Value.absent() : Value(imei1),
      imei2:
          imei2 == null && nullToAbsent ? const Value.absent() : Value(imei2),
      catalogSku: catalogSku == null && nullToAbsent
          ? const Value.absent()
          : Value(catalogSku),
      quantity: Value(quantity),
      unitCost: Value(unitCost),
      total: Value(total),
      createdAt: Value(createdAt),
    );
  }

  factory PurchaseItem.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return PurchaseItem(
      id: serializer.fromJson<String>(json['id']),
      purchaseId: serializer.fromJson<String>(json['purchaseId']),
      productId: serializer.fromJson<String?>(json['productId']),
      variantId: serializer.fromJson<String?>(json['variantId']),
      imei1: serializer.fromJson<String?>(json['imei1']),
      imei2: serializer.fromJson<String?>(json['imei2']),
      catalogSku: serializer.fromJson<String?>(json['catalogSku']),
      quantity: serializer.fromJson<int>(json['quantity']),
      unitCost: serializer.fromJson<int>(json['unitCost']),
      total: serializer.fromJson<int>(json['total']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'purchaseId': serializer.toJson<String>(purchaseId),
      'productId': serializer.toJson<String?>(productId),
      'variantId': serializer.toJson<String?>(variantId),
      'imei1': serializer.toJson<String?>(imei1),
      'imei2': serializer.toJson<String?>(imei2),
      'catalogSku': serializer.toJson<String?>(catalogSku),
      'quantity': serializer.toJson<int>(quantity),
      'unitCost': serializer.toJson<int>(unitCost),
      'total': serializer.toJson<int>(total),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  PurchaseItem copyWith(
          {String? id,
          String? purchaseId,
          Value<String?> productId = const Value.absent(),
          Value<String?> variantId = const Value.absent(),
          Value<String?> imei1 = const Value.absent(),
          Value<String?> imei2 = const Value.absent(),
          Value<String?> catalogSku = const Value.absent(),
          int? quantity,
          int? unitCost,
          int? total,
          DateTime? createdAt}) =>
      PurchaseItem(
        id: id ?? this.id,
        purchaseId: purchaseId ?? this.purchaseId,
        productId: productId.present ? productId.value : this.productId,
        variantId: variantId.present ? variantId.value : this.variantId,
        imei1: imei1.present ? imei1.value : this.imei1,
        imei2: imei2.present ? imei2.value : this.imei2,
        catalogSku: catalogSku.present ? catalogSku.value : this.catalogSku,
        quantity: quantity ?? this.quantity,
        unitCost: unitCost ?? this.unitCost,
        total: total ?? this.total,
        createdAt: createdAt ?? this.createdAt,
      );
  PurchaseItem copyWithCompanion(PurchaseItemsCompanion data) {
    return PurchaseItem(
      id: data.id.present ? data.id.value : this.id,
      purchaseId:
          data.purchaseId.present ? data.purchaseId.value : this.purchaseId,
      productId: data.productId.present ? data.productId.value : this.productId,
      variantId: data.variantId.present ? data.variantId.value : this.variantId,
      imei1: data.imei1.present ? data.imei1.value : this.imei1,
      imei2: data.imei2.present ? data.imei2.value : this.imei2,
      catalogSku:
          data.catalogSku.present ? data.catalogSku.value : this.catalogSku,
      quantity: data.quantity.present ? data.quantity.value : this.quantity,
      unitCost: data.unitCost.present ? data.unitCost.value : this.unitCost,
      total: data.total.present ? data.total.value : this.total,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('PurchaseItem(')
          ..write('id: $id, ')
          ..write('purchaseId: $purchaseId, ')
          ..write('productId: $productId, ')
          ..write('variantId: $variantId, ')
          ..write('imei1: $imei1, ')
          ..write('imei2: $imei2, ')
          ..write('catalogSku: $catalogSku, ')
          ..write('quantity: $quantity, ')
          ..write('unitCost: $unitCost, ')
          ..write('total: $total, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, purchaseId, productId, variantId, imei1,
      imei2, catalogSku, quantity, unitCost, total, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is PurchaseItem &&
          other.id == this.id &&
          other.purchaseId == this.purchaseId &&
          other.productId == this.productId &&
          other.variantId == this.variantId &&
          other.imei1 == this.imei1 &&
          other.imei2 == this.imei2 &&
          other.catalogSku == this.catalogSku &&
          other.quantity == this.quantity &&
          other.unitCost == this.unitCost &&
          other.total == this.total &&
          other.createdAt == this.createdAt);
}

class PurchaseItemsCompanion extends UpdateCompanion<PurchaseItem> {
  final Value<String> id;
  final Value<String> purchaseId;
  final Value<String?> productId;
  final Value<String?> variantId;
  final Value<String?> imei1;
  final Value<String?> imei2;
  final Value<String?> catalogSku;
  final Value<int> quantity;
  final Value<int> unitCost;
  final Value<int> total;
  final Value<DateTime> createdAt;
  final Value<int> rowid;
  const PurchaseItemsCompanion({
    this.id = const Value.absent(),
    this.purchaseId = const Value.absent(),
    this.productId = const Value.absent(),
    this.variantId = const Value.absent(),
    this.imei1 = const Value.absent(),
    this.imei2 = const Value.absent(),
    this.catalogSku = const Value.absent(),
    this.quantity = const Value.absent(),
    this.unitCost = const Value.absent(),
    this.total = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  PurchaseItemsCompanion.insert({
    required String id,
    required String purchaseId,
    this.productId = const Value.absent(),
    this.variantId = const Value.absent(),
    this.imei1 = const Value.absent(),
    this.imei2 = const Value.absent(),
    this.catalogSku = const Value.absent(),
    this.quantity = const Value.absent(),
    required int unitCost,
    required int total,
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        purchaseId = Value(purchaseId),
        unitCost = Value(unitCost),
        total = Value(total);
  static Insertable<PurchaseItem> custom({
    Expression<String>? id,
    Expression<String>? purchaseId,
    Expression<String>? productId,
    Expression<String>? variantId,
    Expression<String>? imei1,
    Expression<String>? imei2,
    Expression<String>? catalogSku,
    Expression<int>? quantity,
    Expression<int>? unitCost,
    Expression<int>? total,
    Expression<DateTime>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (purchaseId != null) 'purchase_id': purchaseId,
      if (productId != null) 'product_id': productId,
      if (variantId != null) 'variant_id': variantId,
      if (imei1 != null) 'imei1': imei1,
      if (imei2 != null) 'imei2': imei2,
      if (catalogSku != null) 'catalog_sku': catalogSku,
      if (quantity != null) 'quantity': quantity,
      if (unitCost != null) 'unit_cost': unitCost,
      if (total != null) 'total': total,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  PurchaseItemsCompanion copyWith(
      {Value<String>? id,
      Value<String>? purchaseId,
      Value<String?>? productId,
      Value<String?>? variantId,
      Value<String?>? imei1,
      Value<String?>? imei2,
      Value<String?>? catalogSku,
      Value<int>? quantity,
      Value<int>? unitCost,
      Value<int>? total,
      Value<DateTime>? createdAt,
      Value<int>? rowid}) {
    return PurchaseItemsCompanion(
      id: id ?? this.id,
      purchaseId: purchaseId ?? this.purchaseId,
      productId: productId ?? this.productId,
      variantId: variantId ?? this.variantId,
      imei1: imei1 ?? this.imei1,
      imei2: imei2 ?? this.imei2,
      catalogSku: catalogSku ?? this.catalogSku,
      quantity: quantity ?? this.quantity,
      unitCost: unitCost ?? this.unitCost,
      total: total ?? this.total,
      createdAt: createdAt ?? this.createdAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (purchaseId.present) {
      map['purchase_id'] = Variable<String>(purchaseId.value);
    }
    if (productId.present) {
      map['product_id'] = Variable<String>(productId.value);
    }
    if (variantId.present) {
      map['variant_id'] = Variable<String>(variantId.value);
    }
    if (imei1.present) {
      map['imei1'] = Variable<String>(imei1.value);
    }
    if (imei2.present) {
      map['imei2'] = Variable<String>(imei2.value);
    }
    if (catalogSku.present) {
      map['catalog_sku'] = Variable<String>(catalogSku.value);
    }
    if (quantity.present) {
      map['quantity'] = Variable<int>(quantity.value);
    }
    if (unitCost.present) {
      map['unit_cost'] = Variable<int>(unitCost.value);
    }
    if (total.present) {
      map['total'] = Variable<int>(total.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PurchaseItemsCompanion(')
          ..write('id: $id, ')
          ..write('purchaseId: $purchaseId, ')
          ..write('productId: $productId, ')
          ..write('variantId: $variantId, ')
          ..write('imei1: $imei1, ')
          ..write('imei2: $imei2, ')
          ..write('catalogSku: $catalogSku, ')
          ..write('quantity: $quantity, ')
          ..write('unitCost: $unitCost, ')
          ..write('total: $total, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $PurchaseReturnsTable extends PurchaseReturns
    with TableInfo<$PurchaseReturnsTable, PurchaseReturn> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PurchaseReturnsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _purchaseIdMeta =
      const VerificationMeta('purchaseId');
  @override
  late final GeneratedColumn<String> purchaseId = GeneratedColumn<String>(
      'purchase_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _imeiItemIdMeta =
      const VerificationMeta('imeiItemId');
  @override
  late final GeneratedColumn<String> imeiItemId = GeneratedColumn<String>(
      'imei_item_id', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _productIdMeta =
      const VerificationMeta('productId');
  @override
  late final GeneratedColumn<String> productId = GeneratedColumn<String>(
      'product_id', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _variantIdMeta =
      const VerificationMeta('variantId');
  @override
  late final GeneratedColumn<String> variantId = GeneratedColumn<String>(
      'variant_id', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _catalogSkuMeta =
      const VerificationMeta('catalogSku');
  @override
  late final GeneratedColumn<String> catalogSku = GeneratedColumn<String>(
      'catalog_sku', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _quantityMeta =
      const VerificationMeta('quantity');
  @override
  late final GeneratedColumn<int> quantity = GeneratedColumn<int>(
      'quantity', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(1));
  static const VerificationMeta _reasonMeta = const VerificationMeta('reason');
  @override
  late final GeneratedColumn<String> reason = GeneratedColumn<String>(
      'reason', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _refundAmountMeta =
      const VerificationMeta('refundAmount');
  @override
  late final GeneratedColumn<int> refundAmount = GeneratedColumn<int>(
      'refund_amount', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _userIdMeta = const VerificationMeta('userId');
  @override
  late final GeneratedColumn<String> userId = GeneratedColumn<String>(
      'user_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        purchaseId,
        imeiItemId,
        productId,
        variantId,
        catalogSku,
        quantity,
        reason,
        refundAmount,
        userId,
        createdAt
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'purchase_returns';
  @override
  VerificationContext validateIntegrity(Insertable<PurchaseReturn> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('purchase_id')) {
      context.handle(
          _purchaseIdMeta,
          purchaseId.isAcceptableOrUnknown(
              data['purchase_id']!, _purchaseIdMeta));
    } else if (isInserting) {
      context.missing(_purchaseIdMeta);
    }
    if (data.containsKey('imei_item_id')) {
      context.handle(
          _imeiItemIdMeta,
          imeiItemId.isAcceptableOrUnknown(
              data['imei_item_id']!, _imeiItemIdMeta));
    }
    if (data.containsKey('product_id')) {
      context.handle(_productIdMeta,
          productId.isAcceptableOrUnknown(data['product_id']!, _productIdMeta));
    }
    if (data.containsKey('variant_id')) {
      context.handle(_variantIdMeta,
          variantId.isAcceptableOrUnknown(data['variant_id']!, _variantIdMeta));
    }
    if (data.containsKey('catalog_sku')) {
      context.handle(
          _catalogSkuMeta,
          catalogSku.isAcceptableOrUnknown(
              data['catalog_sku']!, _catalogSkuMeta));
    }
    if (data.containsKey('quantity')) {
      context.handle(_quantityMeta,
          quantity.isAcceptableOrUnknown(data['quantity']!, _quantityMeta));
    }
    if (data.containsKey('reason')) {
      context.handle(_reasonMeta,
          reason.isAcceptableOrUnknown(data['reason']!, _reasonMeta));
    }
    if (data.containsKey('refund_amount')) {
      context.handle(
          _refundAmountMeta,
          refundAmount.isAcceptableOrUnknown(
              data['refund_amount']!, _refundAmountMeta));
    }
    if (data.containsKey('user_id')) {
      context.handle(_userIdMeta,
          userId.isAcceptableOrUnknown(data['user_id']!, _userIdMeta));
    } else if (isInserting) {
      context.missing(_userIdMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  PurchaseReturn map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return PurchaseReturn(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      purchaseId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}purchase_id'])!,
      imeiItemId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}imei_item_id']),
      productId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}product_id']),
      variantId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}variant_id']),
      catalogSku: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}catalog_sku']),
      quantity: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}quantity'])!,
      reason: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}reason']),
      refundAmount: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}refund_amount'])!,
      userId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}user_id'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
    );
  }

  @override
  $PurchaseReturnsTable createAlias(String alias) {
    return $PurchaseReturnsTable(attachedDatabase, alias);
  }
}

class PurchaseReturn extends DataClass implements Insertable<PurchaseReturn> {
  final String id;
  final String purchaseId;
  final String? imeiItemId;
  final String? productId;
  final String? variantId;
  final String? catalogSku;
  final int quantity;
  final String? reason;
  final int refundAmount;
  final String userId;
  final DateTime createdAt;
  const PurchaseReturn(
      {required this.id,
      required this.purchaseId,
      this.imeiItemId,
      this.productId,
      this.variantId,
      this.catalogSku,
      required this.quantity,
      this.reason,
      required this.refundAmount,
      required this.userId,
      required this.createdAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['purchase_id'] = Variable<String>(purchaseId);
    if (!nullToAbsent || imeiItemId != null) {
      map['imei_item_id'] = Variable<String>(imeiItemId);
    }
    if (!nullToAbsent || productId != null) {
      map['product_id'] = Variable<String>(productId);
    }
    if (!nullToAbsent || variantId != null) {
      map['variant_id'] = Variable<String>(variantId);
    }
    if (!nullToAbsent || catalogSku != null) {
      map['catalog_sku'] = Variable<String>(catalogSku);
    }
    map['quantity'] = Variable<int>(quantity);
    if (!nullToAbsent || reason != null) {
      map['reason'] = Variable<String>(reason);
    }
    map['refund_amount'] = Variable<int>(refundAmount);
    map['user_id'] = Variable<String>(userId);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  PurchaseReturnsCompanion toCompanion(bool nullToAbsent) {
    return PurchaseReturnsCompanion(
      id: Value(id),
      purchaseId: Value(purchaseId),
      imeiItemId: imeiItemId == null && nullToAbsent
          ? const Value.absent()
          : Value(imeiItemId),
      productId: productId == null && nullToAbsent
          ? const Value.absent()
          : Value(productId),
      variantId: variantId == null && nullToAbsent
          ? const Value.absent()
          : Value(variantId),
      catalogSku: catalogSku == null && nullToAbsent
          ? const Value.absent()
          : Value(catalogSku),
      quantity: Value(quantity),
      reason:
          reason == null && nullToAbsent ? const Value.absent() : Value(reason),
      refundAmount: Value(refundAmount),
      userId: Value(userId),
      createdAt: Value(createdAt),
    );
  }

  factory PurchaseReturn.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return PurchaseReturn(
      id: serializer.fromJson<String>(json['id']),
      purchaseId: serializer.fromJson<String>(json['purchaseId']),
      imeiItemId: serializer.fromJson<String?>(json['imeiItemId']),
      productId: serializer.fromJson<String?>(json['productId']),
      variantId: serializer.fromJson<String?>(json['variantId']),
      catalogSku: serializer.fromJson<String?>(json['catalogSku']),
      quantity: serializer.fromJson<int>(json['quantity']),
      reason: serializer.fromJson<String?>(json['reason']),
      refundAmount: serializer.fromJson<int>(json['refundAmount']),
      userId: serializer.fromJson<String>(json['userId']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'purchaseId': serializer.toJson<String>(purchaseId),
      'imeiItemId': serializer.toJson<String?>(imeiItemId),
      'productId': serializer.toJson<String?>(productId),
      'variantId': serializer.toJson<String?>(variantId),
      'catalogSku': serializer.toJson<String?>(catalogSku),
      'quantity': serializer.toJson<int>(quantity),
      'reason': serializer.toJson<String?>(reason),
      'refundAmount': serializer.toJson<int>(refundAmount),
      'userId': serializer.toJson<String>(userId),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  PurchaseReturn copyWith(
          {String? id,
          String? purchaseId,
          Value<String?> imeiItemId = const Value.absent(),
          Value<String?> productId = const Value.absent(),
          Value<String?> variantId = const Value.absent(),
          Value<String?> catalogSku = const Value.absent(),
          int? quantity,
          Value<String?> reason = const Value.absent(),
          int? refundAmount,
          String? userId,
          DateTime? createdAt}) =>
      PurchaseReturn(
        id: id ?? this.id,
        purchaseId: purchaseId ?? this.purchaseId,
        imeiItemId: imeiItemId.present ? imeiItemId.value : this.imeiItemId,
        productId: productId.present ? productId.value : this.productId,
        variantId: variantId.present ? variantId.value : this.variantId,
        catalogSku: catalogSku.present ? catalogSku.value : this.catalogSku,
        quantity: quantity ?? this.quantity,
        reason: reason.present ? reason.value : this.reason,
        refundAmount: refundAmount ?? this.refundAmount,
        userId: userId ?? this.userId,
        createdAt: createdAt ?? this.createdAt,
      );
  PurchaseReturn copyWithCompanion(PurchaseReturnsCompanion data) {
    return PurchaseReturn(
      id: data.id.present ? data.id.value : this.id,
      purchaseId:
          data.purchaseId.present ? data.purchaseId.value : this.purchaseId,
      imeiItemId:
          data.imeiItemId.present ? data.imeiItemId.value : this.imeiItemId,
      productId: data.productId.present ? data.productId.value : this.productId,
      variantId: data.variantId.present ? data.variantId.value : this.variantId,
      catalogSku:
          data.catalogSku.present ? data.catalogSku.value : this.catalogSku,
      quantity: data.quantity.present ? data.quantity.value : this.quantity,
      reason: data.reason.present ? data.reason.value : this.reason,
      refundAmount: data.refundAmount.present
          ? data.refundAmount.value
          : this.refundAmount,
      userId: data.userId.present ? data.userId.value : this.userId,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('PurchaseReturn(')
          ..write('id: $id, ')
          ..write('purchaseId: $purchaseId, ')
          ..write('imeiItemId: $imeiItemId, ')
          ..write('productId: $productId, ')
          ..write('variantId: $variantId, ')
          ..write('catalogSku: $catalogSku, ')
          ..write('quantity: $quantity, ')
          ..write('reason: $reason, ')
          ..write('refundAmount: $refundAmount, ')
          ..write('userId: $userId, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, purchaseId, imeiItemId, productId,
      variantId, catalogSku, quantity, reason, refundAmount, userId, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is PurchaseReturn &&
          other.id == this.id &&
          other.purchaseId == this.purchaseId &&
          other.imeiItemId == this.imeiItemId &&
          other.productId == this.productId &&
          other.variantId == this.variantId &&
          other.catalogSku == this.catalogSku &&
          other.quantity == this.quantity &&
          other.reason == this.reason &&
          other.refundAmount == this.refundAmount &&
          other.userId == this.userId &&
          other.createdAt == this.createdAt);
}

class PurchaseReturnsCompanion extends UpdateCompanion<PurchaseReturn> {
  final Value<String> id;
  final Value<String> purchaseId;
  final Value<String?> imeiItemId;
  final Value<String?> productId;
  final Value<String?> variantId;
  final Value<String?> catalogSku;
  final Value<int> quantity;
  final Value<String?> reason;
  final Value<int> refundAmount;
  final Value<String> userId;
  final Value<DateTime> createdAt;
  final Value<int> rowid;
  const PurchaseReturnsCompanion({
    this.id = const Value.absent(),
    this.purchaseId = const Value.absent(),
    this.imeiItemId = const Value.absent(),
    this.productId = const Value.absent(),
    this.variantId = const Value.absent(),
    this.catalogSku = const Value.absent(),
    this.quantity = const Value.absent(),
    this.reason = const Value.absent(),
    this.refundAmount = const Value.absent(),
    this.userId = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  PurchaseReturnsCompanion.insert({
    required String id,
    required String purchaseId,
    this.imeiItemId = const Value.absent(),
    this.productId = const Value.absent(),
    this.variantId = const Value.absent(),
    this.catalogSku = const Value.absent(),
    this.quantity = const Value.absent(),
    this.reason = const Value.absent(),
    this.refundAmount = const Value.absent(),
    required String userId,
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        purchaseId = Value(purchaseId),
        userId = Value(userId);
  static Insertable<PurchaseReturn> custom({
    Expression<String>? id,
    Expression<String>? purchaseId,
    Expression<String>? imeiItemId,
    Expression<String>? productId,
    Expression<String>? variantId,
    Expression<String>? catalogSku,
    Expression<int>? quantity,
    Expression<String>? reason,
    Expression<int>? refundAmount,
    Expression<String>? userId,
    Expression<DateTime>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (purchaseId != null) 'purchase_id': purchaseId,
      if (imeiItemId != null) 'imei_item_id': imeiItemId,
      if (productId != null) 'product_id': productId,
      if (variantId != null) 'variant_id': variantId,
      if (catalogSku != null) 'catalog_sku': catalogSku,
      if (quantity != null) 'quantity': quantity,
      if (reason != null) 'reason': reason,
      if (refundAmount != null) 'refund_amount': refundAmount,
      if (userId != null) 'user_id': userId,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  PurchaseReturnsCompanion copyWith(
      {Value<String>? id,
      Value<String>? purchaseId,
      Value<String?>? imeiItemId,
      Value<String?>? productId,
      Value<String?>? variantId,
      Value<String?>? catalogSku,
      Value<int>? quantity,
      Value<String?>? reason,
      Value<int>? refundAmount,
      Value<String>? userId,
      Value<DateTime>? createdAt,
      Value<int>? rowid}) {
    return PurchaseReturnsCompanion(
      id: id ?? this.id,
      purchaseId: purchaseId ?? this.purchaseId,
      imeiItemId: imeiItemId ?? this.imeiItemId,
      productId: productId ?? this.productId,
      variantId: variantId ?? this.variantId,
      catalogSku: catalogSku ?? this.catalogSku,
      quantity: quantity ?? this.quantity,
      reason: reason ?? this.reason,
      refundAmount: refundAmount ?? this.refundAmount,
      userId: userId ?? this.userId,
      createdAt: createdAt ?? this.createdAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (purchaseId.present) {
      map['purchase_id'] = Variable<String>(purchaseId.value);
    }
    if (imeiItemId.present) {
      map['imei_item_id'] = Variable<String>(imeiItemId.value);
    }
    if (productId.present) {
      map['product_id'] = Variable<String>(productId.value);
    }
    if (variantId.present) {
      map['variant_id'] = Variable<String>(variantId.value);
    }
    if (catalogSku.present) {
      map['catalog_sku'] = Variable<String>(catalogSku.value);
    }
    if (quantity.present) {
      map['quantity'] = Variable<int>(quantity.value);
    }
    if (reason.present) {
      map['reason'] = Variable<String>(reason.value);
    }
    if (refundAmount.present) {
      map['refund_amount'] = Variable<int>(refundAmount.value);
    }
    if (userId.present) {
      map['user_id'] = Variable<String>(userId.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PurchaseReturnsCompanion(')
          ..write('id: $id, ')
          ..write('purchaseId: $purchaseId, ')
          ..write('imeiItemId: $imeiItemId, ')
          ..write('productId: $productId, ')
          ..write('variantId: $variantId, ')
          ..write('catalogSku: $catalogSku, ')
          ..write('quantity: $quantity, ')
          ..write('reason: $reason, ')
          ..write('refundAmount: $refundAmount, ')
          ..write('userId: $userId, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $PaymentsTable extends Payments with TableInfo<$PaymentsTable, Payment> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PaymentsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _paymentTypeMeta =
      const VerificationMeta('paymentType');
  @override
  late final GeneratedColumn<String> paymentType = GeneratedColumn<String>(
      'payment_type', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _saleIdMeta = const VerificationMeta('saleId');
  @override
  late final GeneratedColumn<String> saleId = GeneratedColumn<String>(
      'sale_id', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _purchaseIdMeta =
      const VerificationMeta('purchaseId');
  @override
  late final GeneratedColumn<String> purchaseId = GeneratedColumn<String>(
      'purchase_id', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _installmentIdMeta =
      const VerificationMeta('installmentId');
  @override
  late final GeneratedColumn<String> installmentId = GeneratedColumn<String>(
      'installment_id', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _repairIdMeta =
      const VerificationMeta('repairId');
  @override
  late final GeneratedColumn<String> repairId = GeneratedColumn<String>(
      'repair_id', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _customerIdMeta =
      const VerificationMeta('customerId');
  @override
  late final GeneratedColumn<String> customerId = GeneratedColumn<String>(
      'customer_id', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _supplierIdMeta =
      const VerificationMeta('supplierId');
  @override
  late final GeneratedColumn<String> supplierId = GeneratedColumn<String>(
      'supplier_id', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _methodMeta = const VerificationMeta('method');
  @override
  late final GeneratedColumn<String> method = GeneratedColumn<String>(
      'method', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('cash'));
  static const VerificationMeta _amountMeta = const VerificationMeta('amount');
  @override
  late final GeneratedColumn<int> amount = GeneratedColumn<int>(
      'amount', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _referenceMeta =
      const VerificationMeta('reference');
  @override
  late final GeneratedColumn<String> reference = GeneratedColumn<String>(
      'reference', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _paymentDateMeta =
      const VerificationMeta('paymentDate');
  @override
  late final GeneratedColumn<DateTime> paymentDate = GeneratedColumn<DateTime>(
      'payment_date', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  static const VerificationMeta _userIdMeta = const VerificationMeta('userId');
  @override
  late final GeneratedColumn<String> userId = GeneratedColumn<String>(
      'user_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _notesMeta = const VerificationMeta('notes');
  @override
  late final GeneratedColumn<String> notes = GeneratedColumn<String>(
      'notes', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _clientUuidMeta =
      const VerificationMeta('clientUuid');
  @override
  late final GeneratedColumn<String> clientUuid = GeneratedColumn<String>(
      'client_uuid', aliasedName, true,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'));
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        paymentType,
        saleId,
        purchaseId,
        installmentId,
        repairId,
        customerId,
        supplierId,
        method,
        amount,
        reference,
        paymentDate,
        userId,
        notes,
        clientUuid,
        createdAt
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'payments';
  @override
  VerificationContext validateIntegrity(Insertable<Payment> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('payment_type')) {
      context.handle(
          _paymentTypeMeta,
          paymentType.isAcceptableOrUnknown(
              data['payment_type']!, _paymentTypeMeta));
    } else if (isInserting) {
      context.missing(_paymentTypeMeta);
    }
    if (data.containsKey('sale_id')) {
      context.handle(_saleIdMeta,
          saleId.isAcceptableOrUnknown(data['sale_id']!, _saleIdMeta));
    }
    if (data.containsKey('purchase_id')) {
      context.handle(
          _purchaseIdMeta,
          purchaseId.isAcceptableOrUnknown(
              data['purchase_id']!, _purchaseIdMeta));
    }
    if (data.containsKey('installment_id')) {
      context.handle(
          _installmentIdMeta,
          installmentId.isAcceptableOrUnknown(
              data['installment_id']!, _installmentIdMeta));
    }
    if (data.containsKey('repair_id')) {
      context.handle(_repairIdMeta,
          repairId.isAcceptableOrUnknown(data['repair_id']!, _repairIdMeta));
    }
    if (data.containsKey('customer_id')) {
      context.handle(
          _customerIdMeta,
          customerId.isAcceptableOrUnknown(
              data['customer_id']!, _customerIdMeta));
    }
    if (data.containsKey('supplier_id')) {
      context.handle(
          _supplierIdMeta,
          supplierId.isAcceptableOrUnknown(
              data['supplier_id']!, _supplierIdMeta));
    }
    if (data.containsKey('method')) {
      context.handle(_methodMeta,
          method.isAcceptableOrUnknown(data['method']!, _methodMeta));
    }
    if (data.containsKey('amount')) {
      context.handle(_amountMeta,
          amount.isAcceptableOrUnknown(data['amount']!, _amountMeta));
    } else if (isInserting) {
      context.missing(_amountMeta);
    }
    if (data.containsKey('reference')) {
      context.handle(_referenceMeta,
          reference.isAcceptableOrUnknown(data['reference']!, _referenceMeta));
    }
    if (data.containsKey('payment_date')) {
      context.handle(
          _paymentDateMeta,
          paymentDate.isAcceptableOrUnknown(
              data['payment_date']!, _paymentDateMeta));
    }
    if (data.containsKey('user_id')) {
      context.handle(_userIdMeta,
          userId.isAcceptableOrUnknown(data['user_id']!, _userIdMeta));
    } else if (isInserting) {
      context.missing(_userIdMeta);
    }
    if (data.containsKey('notes')) {
      context.handle(
          _notesMeta, notes.isAcceptableOrUnknown(data['notes']!, _notesMeta));
    }
    if (data.containsKey('client_uuid')) {
      context.handle(
          _clientUuidMeta,
          clientUuid.isAcceptableOrUnknown(
              data['client_uuid']!, _clientUuidMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Payment map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Payment(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      paymentType: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}payment_type'])!,
      saleId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}sale_id']),
      purchaseId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}purchase_id']),
      installmentId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}installment_id']),
      repairId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}repair_id']),
      customerId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}customer_id']),
      supplierId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}supplier_id']),
      method: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}method'])!,
      amount: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}amount'])!,
      reference: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}reference']),
      paymentDate: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}payment_date'])!,
      userId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}user_id'])!,
      notes: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}notes']),
      clientUuid: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}client_uuid']),
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
    );
  }

  @override
  $PaymentsTable createAlias(String alias) {
    return $PaymentsTable(attachedDatabase, alias);
  }
}

class Payment extends DataClass implements Insertable<Payment> {
  final String id;
  final String paymentType;
  final String? saleId;
  final String? purchaseId;
  final String? installmentId;
  final String? repairId;
  final String? customerId;
  final String? supplierId;
  final String method;
  final int amount;
  final String? reference;
  final DateTime paymentDate;
  final String userId;
  final String? notes;
  final String? clientUuid;
  final DateTime createdAt;
  const Payment(
      {required this.id,
      required this.paymentType,
      this.saleId,
      this.purchaseId,
      this.installmentId,
      this.repairId,
      this.customerId,
      this.supplierId,
      required this.method,
      required this.amount,
      this.reference,
      required this.paymentDate,
      required this.userId,
      this.notes,
      this.clientUuid,
      required this.createdAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['payment_type'] = Variable<String>(paymentType);
    if (!nullToAbsent || saleId != null) {
      map['sale_id'] = Variable<String>(saleId);
    }
    if (!nullToAbsent || purchaseId != null) {
      map['purchase_id'] = Variable<String>(purchaseId);
    }
    if (!nullToAbsent || installmentId != null) {
      map['installment_id'] = Variable<String>(installmentId);
    }
    if (!nullToAbsent || repairId != null) {
      map['repair_id'] = Variable<String>(repairId);
    }
    if (!nullToAbsent || customerId != null) {
      map['customer_id'] = Variable<String>(customerId);
    }
    if (!nullToAbsent || supplierId != null) {
      map['supplier_id'] = Variable<String>(supplierId);
    }
    map['method'] = Variable<String>(method);
    map['amount'] = Variable<int>(amount);
    if (!nullToAbsent || reference != null) {
      map['reference'] = Variable<String>(reference);
    }
    map['payment_date'] = Variable<DateTime>(paymentDate);
    map['user_id'] = Variable<String>(userId);
    if (!nullToAbsent || notes != null) {
      map['notes'] = Variable<String>(notes);
    }
    if (!nullToAbsent || clientUuid != null) {
      map['client_uuid'] = Variable<String>(clientUuid);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  PaymentsCompanion toCompanion(bool nullToAbsent) {
    return PaymentsCompanion(
      id: Value(id),
      paymentType: Value(paymentType),
      saleId:
          saleId == null && nullToAbsent ? const Value.absent() : Value(saleId),
      purchaseId: purchaseId == null && nullToAbsent
          ? const Value.absent()
          : Value(purchaseId),
      installmentId: installmentId == null && nullToAbsent
          ? const Value.absent()
          : Value(installmentId),
      repairId: repairId == null && nullToAbsent
          ? const Value.absent()
          : Value(repairId),
      customerId: customerId == null && nullToAbsent
          ? const Value.absent()
          : Value(customerId),
      supplierId: supplierId == null && nullToAbsent
          ? const Value.absent()
          : Value(supplierId),
      method: Value(method),
      amount: Value(amount),
      reference: reference == null && nullToAbsent
          ? const Value.absent()
          : Value(reference),
      paymentDate: Value(paymentDate),
      userId: Value(userId),
      notes:
          notes == null && nullToAbsent ? const Value.absent() : Value(notes),
      clientUuid: clientUuid == null && nullToAbsent
          ? const Value.absent()
          : Value(clientUuid),
      createdAt: Value(createdAt),
    );
  }

  factory Payment.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Payment(
      id: serializer.fromJson<String>(json['id']),
      paymentType: serializer.fromJson<String>(json['paymentType']),
      saleId: serializer.fromJson<String?>(json['saleId']),
      purchaseId: serializer.fromJson<String?>(json['purchaseId']),
      installmentId: serializer.fromJson<String?>(json['installmentId']),
      repairId: serializer.fromJson<String?>(json['repairId']),
      customerId: serializer.fromJson<String?>(json['customerId']),
      supplierId: serializer.fromJson<String?>(json['supplierId']),
      method: serializer.fromJson<String>(json['method']),
      amount: serializer.fromJson<int>(json['amount']),
      reference: serializer.fromJson<String?>(json['reference']),
      paymentDate: serializer.fromJson<DateTime>(json['paymentDate']),
      userId: serializer.fromJson<String>(json['userId']),
      notes: serializer.fromJson<String?>(json['notes']),
      clientUuid: serializer.fromJson<String?>(json['clientUuid']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'paymentType': serializer.toJson<String>(paymentType),
      'saleId': serializer.toJson<String?>(saleId),
      'purchaseId': serializer.toJson<String?>(purchaseId),
      'installmentId': serializer.toJson<String?>(installmentId),
      'repairId': serializer.toJson<String?>(repairId),
      'customerId': serializer.toJson<String?>(customerId),
      'supplierId': serializer.toJson<String?>(supplierId),
      'method': serializer.toJson<String>(method),
      'amount': serializer.toJson<int>(amount),
      'reference': serializer.toJson<String?>(reference),
      'paymentDate': serializer.toJson<DateTime>(paymentDate),
      'userId': serializer.toJson<String>(userId),
      'notes': serializer.toJson<String?>(notes),
      'clientUuid': serializer.toJson<String?>(clientUuid),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  Payment copyWith(
          {String? id,
          String? paymentType,
          Value<String?> saleId = const Value.absent(),
          Value<String?> purchaseId = const Value.absent(),
          Value<String?> installmentId = const Value.absent(),
          Value<String?> repairId = const Value.absent(),
          Value<String?> customerId = const Value.absent(),
          Value<String?> supplierId = const Value.absent(),
          String? method,
          int? amount,
          Value<String?> reference = const Value.absent(),
          DateTime? paymentDate,
          String? userId,
          Value<String?> notes = const Value.absent(),
          Value<String?> clientUuid = const Value.absent(),
          DateTime? createdAt}) =>
      Payment(
        id: id ?? this.id,
        paymentType: paymentType ?? this.paymentType,
        saleId: saleId.present ? saleId.value : this.saleId,
        purchaseId: purchaseId.present ? purchaseId.value : this.purchaseId,
        installmentId:
            installmentId.present ? installmentId.value : this.installmentId,
        repairId: repairId.present ? repairId.value : this.repairId,
        customerId: customerId.present ? customerId.value : this.customerId,
        supplierId: supplierId.present ? supplierId.value : this.supplierId,
        method: method ?? this.method,
        amount: amount ?? this.amount,
        reference: reference.present ? reference.value : this.reference,
        paymentDate: paymentDate ?? this.paymentDate,
        userId: userId ?? this.userId,
        notes: notes.present ? notes.value : this.notes,
        clientUuid: clientUuid.present ? clientUuid.value : this.clientUuid,
        createdAt: createdAt ?? this.createdAt,
      );
  Payment copyWithCompanion(PaymentsCompanion data) {
    return Payment(
      id: data.id.present ? data.id.value : this.id,
      paymentType:
          data.paymentType.present ? data.paymentType.value : this.paymentType,
      saleId: data.saleId.present ? data.saleId.value : this.saleId,
      purchaseId:
          data.purchaseId.present ? data.purchaseId.value : this.purchaseId,
      installmentId: data.installmentId.present
          ? data.installmentId.value
          : this.installmentId,
      repairId: data.repairId.present ? data.repairId.value : this.repairId,
      customerId:
          data.customerId.present ? data.customerId.value : this.customerId,
      supplierId:
          data.supplierId.present ? data.supplierId.value : this.supplierId,
      method: data.method.present ? data.method.value : this.method,
      amount: data.amount.present ? data.amount.value : this.amount,
      reference: data.reference.present ? data.reference.value : this.reference,
      paymentDate:
          data.paymentDate.present ? data.paymentDate.value : this.paymentDate,
      userId: data.userId.present ? data.userId.value : this.userId,
      notes: data.notes.present ? data.notes.value : this.notes,
      clientUuid:
          data.clientUuid.present ? data.clientUuid.value : this.clientUuid,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Payment(')
          ..write('id: $id, ')
          ..write('paymentType: $paymentType, ')
          ..write('saleId: $saleId, ')
          ..write('purchaseId: $purchaseId, ')
          ..write('installmentId: $installmentId, ')
          ..write('repairId: $repairId, ')
          ..write('customerId: $customerId, ')
          ..write('supplierId: $supplierId, ')
          ..write('method: $method, ')
          ..write('amount: $amount, ')
          ..write('reference: $reference, ')
          ..write('paymentDate: $paymentDate, ')
          ..write('userId: $userId, ')
          ..write('notes: $notes, ')
          ..write('clientUuid: $clientUuid, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id,
      paymentType,
      saleId,
      purchaseId,
      installmentId,
      repairId,
      customerId,
      supplierId,
      method,
      amount,
      reference,
      paymentDate,
      userId,
      notes,
      clientUuid,
      createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Payment &&
          other.id == this.id &&
          other.paymentType == this.paymentType &&
          other.saleId == this.saleId &&
          other.purchaseId == this.purchaseId &&
          other.installmentId == this.installmentId &&
          other.repairId == this.repairId &&
          other.customerId == this.customerId &&
          other.supplierId == this.supplierId &&
          other.method == this.method &&
          other.amount == this.amount &&
          other.reference == this.reference &&
          other.paymentDate == this.paymentDate &&
          other.userId == this.userId &&
          other.notes == this.notes &&
          other.clientUuid == this.clientUuid &&
          other.createdAt == this.createdAt);
}

class PaymentsCompanion extends UpdateCompanion<Payment> {
  final Value<String> id;
  final Value<String> paymentType;
  final Value<String?> saleId;
  final Value<String?> purchaseId;
  final Value<String?> installmentId;
  final Value<String?> repairId;
  final Value<String?> customerId;
  final Value<String?> supplierId;
  final Value<String> method;
  final Value<int> amount;
  final Value<String?> reference;
  final Value<DateTime> paymentDate;
  final Value<String> userId;
  final Value<String?> notes;
  final Value<String?> clientUuid;
  final Value<DateTime> createdAt;
  final Value<int> rowid;
  const PaymentsCompanion({
    this.id = const Value.absent(),
    this.paymentType = const Value.absent(),
    this.saleId = const Value.absent(),
    this.purchaseId = const Value.absent(),
    this.installmentId = const Value.absent(),
    this.repairId = const Value.absent(),
    this.customerId = const Value.absent(),
    this.supplierId = const Value.absent(),
    this.method = const Value.absent(),
    this.amount = const Value.absent(),
    this.reference = const Value.absent(),
    this.paymentDate = const Value.absent(),
    this.userId = const Value.absent(),
    this.notes = const Value.absent(),
    this.clientUuid = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  PaymentsCompanion.insert({
    required String id,
    required String paymentType,
    this.saleId = const Value.absent(),
    this.purchaseId = const Value.absent(),
    this.installmentId = const Value.absent(),
    this.repairId = const Value.absent(),
    this.customerId = const Value.absent(),
    this.supplierId = const Value.absent(),
    this.method = const Value.absent(),
    required int amount,
    this.reference = const Value.absent(),
    this.paymentDate = const Value.absent(),
    required String userId,
    this.notes = const Value.absent(),
    this.clientUuid = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        paymentType = Value(paymentType),
        amount = Value(amount),
        userId = Value(userId);
  static Insertable<Payment> custom({
    Expression<String>? id,
    Expression<String>? paymentType,
    Expression<String>? saleId,
    Expression<String>? purchaseId,
    Expression<String>? installmentId,
    Expression<String>? repairId,
    Expression<String>? customerId,
    Expression<String>? supplierId,
    Expression<String>? method,
    Expression<int>? amount,
    Expression<String>? reference,
    Expression<DateTime>? paymentDate,
    Expression<String>? userId,
    Expression<String>? notes,
    Expression<String>? clientUuid,
    Expression<DateTime>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (paymentType != null) 'payment_type': paymentType,
      if (saleId != null) 'sale_id': saleId,
      if (purchaseId != null) 'purchase_id': purchaseId,
      if (installmentId != null) 'installment_id': installmentId,
      if (repairId != null) 'repair_id': repairId,
      if (customerId != null) 'customer_id': customerId,
      if (supplierId != null) 'supplier_id': supplierId,
      if (method != null) 'method': method,
      if (amount != null) 'amount': amount,
      if (reference != null) 'reference': reference,
      if (paymentDate != null) 'payment_date': paymentDate,
      if (userId != null) 'user_id': userId,
      if (notes != null) 'notes': notes,
      if (clientUuid != null) 'client_uuid': clientUuid,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  PaymentsCompanion copyWith(
      {Value<String>? id,
      Value<String>? paymentType,
      Value<String?>? saleId,
      Value<String?>? purchaseId,
      Value<String?>? installmentId,
      Value<String?>? repairId,
      Value<String?>? customerId,
      Value<String?>? supplierId,
      Value<String>? method,
      Value<int>? amount,
      Value<String?>? reference,
      Value<DateTime>? paymentDate,
      Value<String>? userId,
      Value<String?>? notes,
      Value<String?>? clientUuid,
      Value<DateTime>? createdAt,
      Value<int>? rowid}) {
    return PaymentsCompanion(
      id: id ?? this.id,
      paymentType: paymentType ?? this.paymentType,
      saleId: saleId ?? this.saleId,
      purchaseId: purchaseId ?? this.purchaseId,
      installmentId: installmentId ?? this.installmentId,
      repairId: repairId ?? this.repairId,
      customerId: customerId ?? this.customerId,
      supplierId: supplierId ?? this.supplierId,
      method: method ?? this.method,
      amount: amount ?? this.amount,
      reference: reference ?? this.reference,
      paymentDate: paymentDate ?? this.paymentDate,
      userId: userId ?? this.userId,
      notes: notes ?? this.notes,
      clientUuid: clientUuid ?? this.clientUuid,
      createdAt: createdAt ?? this.createdAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (paymentType.present) {
      map['payment_type'] = Variable<String>(paymentType.value);
    }
    if (saleId.present) {
      map['sale_id'] = Variable<String>(saleId.value);
    }
    if (purchaseId.present) {
      map['purchase_id'] = Variable<String>(purchaseId.value);
    }
    if (installmentId.present) {
      map['installment_id'] = Variable<String>(installmentId.value);
    }
    if (repairId.present) {
      map['repair_id'] = Variable<String>(repairId.value);
    }
    if (customerId.present) {
      map['customer_id'] = Variable<String>(customerId.value);
    }
    if (supplierId.present) {
      map['supplier_id'] = Variable<String>(supplierId.value);
    }
    if (method.present) {
      map['method'] = Variable<String>(method.value);
    }
    if (amount.present) {
      map['amount'] = Variable<int>(amount.value);
    }
    if (reference.present) {
      map['reference'] = Variable<String>(reference.value);
    }
    if (paymentDate.present) {
      map['payment_date'] = Variable<DateTime>(paymentDate.value);
    }
    if (userId.present) {
      map['user_id'] = Variable<String>(userId.value);
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    if (clientUuid.present) {
      map['client_uuid'] = Variable<String>(clientUuid.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PaymentsCompanion(')
          ..write('id: $id, ')
          ..write('paymentType: $paymentType, ')
          ..write('saleId: $saleId, ')
          ..write('purchaseId: $purchaseId, ')
          ..write('installmentId: $installmentId, ')
          ..write('repairId: $repairId, ')
          ..write('customerId: $customerId, ')
          ..write('supplierId: $supplierId, ')
          ..write('method: $method, ')
          ..write('amount: $amount, ')
          ..write('reference: $reference, ')
          ..write('paymentDate: $paymentDate, ')
          ..write('userId: $userId, ')
          ..write('notes: $notes, ')
          ..write('clientUuid: $clientUuid, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $LedgerEntriesTable extends LedgerEntries
    with TableInfo<$LedgerEntriesTable, LedgerEntry> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $LedgerEntriesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _sideMeta = const VerificationMeta('side');
  @override
  late final GeneratedColumn<String> side = GeneratedColumn<String>(
      'side', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _customerIdMeta =
      const VerificationMeta('customerId');
  @override
  late final GeneratedColumn<String> customerId = GeneratedColumn<String>(
      'customer_id', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _supplierIdMeta =
      const VerificationMeta('supplierId');
  @override
  late final GeneratedColumn<String> supplierId = GeneratedColumn<String>(
      'supplier_id', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _referenceTypeMeta =
      const VerificationMeta('referenceType');
  @override
  late final GeneratedColumn<String> referenceType = GeneratedColumn<String>(
      'reference_type', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _referenceIdMeta =
      const VerificationMeta('referenceId');
  @override
  late final GeneratedColumn<String> referenceId = GeneratedColumn<String>(
      'reference_id', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _debitMeta = const VerificationMeta('debit');
  @override
  late final GeneratedColumn<int> debit = GeneratedColumn<int>(
      'debit', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _creditMeta = const VerificationMeta('credit');
  @override
  late final GeneratedColumn<int> credit = GeneratedColumn<int>(
      'credit', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _balanceAfterMeta =
      const VerificationMeta('balanceAfter');
  @override
  late final GeneratedColumn<int> balanceAfter = GeneratedColumn<int>(
      'balance_after', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _entryDateMeta =
      const VerificationMeta('entryDate');
  @override
  late final GeneratedColumn<DateTime> entryDate = GeneratedColumn<DateTime>(
      'entry_date', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  static const VerificationMeta _userIdMeta = const VerificationMeta('userId');
  @override
  late final GeneratedColumn<String> userId = GeneratedColumn<String>(
      'user_id', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _notesMeta = const VerificationMeta('notes');
  @override
  late final GeneratedColumn<String> notes = GeneratedColumn<String>(
      'notes', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        side,
        customerId,
        supplierId,
        referenceType,
        referenceId,
        debit,
        credit,
        balanceAfter,
        entryDate,
        userId,
        notes,
        createdAt
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'ledger_entries';
  @override
  VerificationContext validateIntegrity(Insertable<LedgerEntry> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('side')) {
      context.handle(
          _sideMeta, side.isAcceptableOrUnknown(data['side']!, _sideMeta));
    } else if (isInserting) {
      context.missing(_sideMeta);
    }
    if (data.containsKey('customer_id')) {
      context.handle(
          _customerIdMeta,
          customerId.isAcceptableOrUnknown(
              data['customer_id']!, _customerIdMeta));
    }
    if (data.containsKey('supplier_id')) {
      context.handle(
          _supplierIdMeta,
          supplierId.isAcceptableOrUnknown(
              data['supplier_id']!, _supplierIdMeta));
    }
    if (data.containsKey('reference_type')) {
      context.handle(
          _referenceTypeMeta,
          referenceType.isAcceptableOrUnknown(
              data['reference_type']!, _referenceTypeMeta));
    } else if (isInserting) {
      context.missing(_referenceTypeMeta);
    }
    if (data.containsKey('reference_id')) {
      context.handle(
          _referenceIdMeta,
          referenceId.isAcceptableOrUnknown(
              data['reference_id']!, _referenceIdMeta));
    }
    if (data.containsKey('debit')) {
      context.handle(
          _debitMeta, debit.isAcceptableOrUnknown(data['debit']!, _debitMeta));
    }
    if (data.containsKey('credit')) {
      context.handle(_creditMeta,
          credit.isAcceptableOrUnknown(data['credit']!, _creditMeta));
    }
    if (data.containsKey('balance_after')) {
      context.handle(
          _balanceAfterMeta,
          balanceAfter.isAcceptableOrUnknown(
              data['balance_after']!, _balanceAfterMeta));
    }
    if (data.containsKey('entry_date')) {
      context.handle(_entryDateMeta,
          entryDate.isAcceptableOrUnknown(data['entry_date']!, _entryDateMeta));
    }
    if (data.containsKey('user_id')) {
      context.handle(_userIdMeta,
          userId.isAcceptableOrUnknown(data['user_id']!, _userIdMeta));
    }
    if (data.containsKey('notes')) {
      context.handle(
          _notesMeta, notes.isAcceptableOrUnknown(data['notes']!, _notesMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  LedgerEntry map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return LedgerEntry(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      side: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}side'])!,
      customerId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}customer_id']),
      supplierId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}supplier_id']),
      referenceType: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}reference_type'])!,
      referenceId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}reference_id']),
      debit: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}debit'])!,
      credit: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}credit'])!,
      balanceAfter: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}balance_after'])!,
      entryDate: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}entry_date'])!,
      userId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}user_id']),
      notes: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}notes']),
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
    );
  }

  @override
  $LedgerEntriesTable createAlias(String alias) {
    return $LedgerEntriesTable(attachedDatabase, alias);
  }
}

class LedgerEntry extends DataClass implements Insertable<LedgerEntry> {
  final String id;
  final String side;
  final String? customerId;
  final String? supplierId;
  final String referenceType;
  final String? referenceId;
  final int debit;
  final int credit;
  final int balanceAfter;
  final DateTime entryDate;
  final String? userId;
  final String? notes;
  final DateTime createdAt;
  const LedgerEntry(
      {required this.id,
      required this.side,
      this.customerId,
      this.supplierId,
      required this.referenceType,
      this.referenceId,
      required this.debit,
      required this.credit,
      required this.balanceAfter,
      required this.entryDate,
      this.userId,
      this.notes,
      required this.createdAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['side'] = Variable<String>(side);
    if (!nullToAbsent || customerId != null) {
      map['customer_id'] = Variable<String>(customerId);
    }
    if (!nullToAbsent || supplierId != null) {
      map['supplier_id'] = Variable<String>(supplierId);
    }
    map['reference_type'] = Variable<String>(referenceType);
    if (!nullToAbsent || referenceId != null) {
      map['reference_id'] = Variable<String>(referenceId);
    }
    map['debit'] = Variable<int>(debit);
    map['credit'] = Variable<int>(credit);
    map['balance_after'] = Variable<int>(balanceAfter);
    map['entry_date'] = Variable<DateTime>(entryDate);
    if (!nullToAbsent || userId != null) {
      map['user_id'] = Variable<String>(userId);
    }
    if (!nullToAbsent || notes != null) {
      map['notes'] = Variable<String>(notes);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  LedgerEntriesCompanion toCompanion(bool nullToAbsent) {
    return LedgerEntriesCompanion(
      id: Value(id),
      side: Value(side),
      customerId: customerId == null && nullToAbsent
          ? const Value.absent()
          : Value(customerId),
      supplierId: supplierId == null && nullToAbsent
          ? const Value.absent()
          : Value(supplierId),
      referenceType: Value(referenceType),
      referenceId: referenceId == null && nullToAbsent
          ? const Value.absent()
          : Value(referenceId),
      debit: Value(debit),
      credit: Value(credit),
      balanceAfter: Value(balanceAfter),
      entryDate: Value(entryDate),
      userId:
          userId == null && nullToAbsent ? const Value.absent() : Value(userId),
      notes:
          notes == null && nullToAbsent ? const Value.absent() : Value(notes),
      createdAt: Value(createdAt),
    );
  }

  factory LedgerEntry.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return LedgerEntry(
      id: serializer.fromJson<String>(json['id']),
      side: serializer.fromJson<String>(json['side']),
      customerId: serializer.fromJson<String?>(json['customerId']),
      supplierId: serializer.fromJson<String?>(json['supplierId']),
      referenceType: serializer.fromJson<String>(json['referenceType']),
      referenceId: serializer.fromJson<String?>(json['referenceId']),
      debit: serializer.fromJson<int>(json['debit']),
      credit: serializer.fromJson<int>(json['credit']),
      balanceAfter: serializer.fromJson<int>(json['balanceAfter']),
      entryDate: serializer.fromJson<DateTime>(json['entryDate']),
      userId: serializer.fromJson<String?>(json['userId']),
      notes: serializer.fromJson<String?>(json['notes']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'side': serializer.toJson<String>(side),
      'customerId': serializer.toJson<String?>(customerId),
      'supplierId': serializer.toJson<String?>(supplierId),
      'referenceType': serializer.toJson<String>(referenceType),
      'referenceId': serializer.toJson<String?>(referenceId),
      'debit': serializer.toJson<int>(debit),
      'credit': serializer.toJson<int>(credit),
      'balanceAfter': serializer.toJson<int>(balanceAfter),
      'entryDate': serializer.toJson<DateTime>(entryDate),
      'userId': serializer.toJson<String?>(userId),
      'notes': serializer.toJson<String?>(notes),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  LedgerEntry copyWith(
          {String? id,
          String? side,
          Value<String?> customerId = const Value.absent(),
          Value<String?> supplierId = const Value.absent(),
          String? referenceType,
          Value<String?> referenceId = const Value.absent(),
          int? debit,
          int? credit,
          int? balanceAfter,
          DateTime? entryDate,
          Value<String?> userId = const Value.absent(),
          Value<String?> notes = const Value.absent(),
          DateTime? createdAt}) =>
      LedgerEntry(
        id: id ?? this.id,
        side: side ?? this.side,
        customerId: customerId.present ? customerId.value : this.customerId,
        supplierId: supplierId.present ? supplierId.value : this.supplierId,
        referenceType: referenceType ?? this.referenceType,
        referenceId: referenceId.present ? referenceId.value : this.referenceId,
        debit: debit ?? this.debit,
        credit: credit ?? this.credit,
        balanceAfter: balanceAfter ?? this.balanceAfter,
        entryDate: entryDate ?? this.entryDate,
        userId: userId.present ? userId.value : this.userId,
        notes: notes.present ? notes.value : this.notes,
        createdAt: createdAt ?? this.createdAt,
      );
  LedgerEntry copyWithCompanion(LedgerEntriesCompanion data) {
    return LedgerEntry(
      id: data.id.present ? data.id.value : this.id,
      side: data.side.present ? data.side.value : this.side,
      customerId:
          data.customerId.present ? data.customerId.value : this.customerId,
      supplierId:
          data.supplierId.present ? data.supplierId.value : this.supplierId,
      referenceType: data.referenceType.present
          ? data.referenceType.value
          : this.referenceType,
      referenceId:
          data.referenceId.present ? data.referenceId.value : this.referenceId,
      debit: data.debit.present ? data.debit.value : this.debit,
      credit: data.credit.present ? data.credit.value : this.credit,
      balanceAfter: data.balanceAfter.present
          ? data.balanceAfter.value
          : this.balanceAfter,
      entryDate: data.entryDate.present ? data.entryDate.value : this.entryDate,
      userId: data.userId.present ? data.userId.value : this.userId,
      notes: data.notes.present ? data.notes.value : this.notes,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('LedgerEntry(')
          ..write('id: $id, ')
          ..write('side: $side, ')
          ..write('customerId: $customerId, ')
          ..write('supplierId: $supplierId, ')
          ..write('referenceType: $referenceType, ')
          ..write('referenceId: $referenceId, ')
          ..write('debit: $debit, ')
          ..write('credit: $credit, ')
          ..write('balanceAfter: $balanceAfter, ')
          ..write('entryDate: $entryDate, ')
          ..write('userId: $userId, ')
          ..write('notes: $notes, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id,
      side,
      customerId,
      supplierId,
      referenceType,
      referenceId,
      debit,
      credit,
      balanceAfter,
      entryDate,
      userId,
      notes,
      createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is LedgerEntry &&
          other.id == this.id &&
          other.side == this.side &&
          other.customerId == this.customerId &&
          other.supplierId == this.supplierId &&
          other.referenceType == this.referenceType &&
          other.referenceId == this.referenceId &&
          other.debit == this.debit &&
          other.credit == this.credit &&
          other.balanceAfter == this.balanceAfter &&
          other.entryDate == this.entryDate &&
          other.userId == this.userId &&
          other.notes == this.notes &&
          other.createdAt == this.createdAt);
}

class LedgerEntriesCompanion extends UpdateCompanion<LedgerEntry> {
  final Value<String> id;
  final Value<String> side;
  final Value<String?> customerId;
  final Value<String?> supplierId;
  final Value<String> referenceType;
  final Value<String?> referenceId;
  final Value<int> debit;
  final Value<int> credit;
  final Value<int> balanceAfter;
  final Value<DateTime> entryDate;
  final Value<String?> userId;
  final Value<String?> notes;
  final Value<DateTime> createdAt;
  final Value<int> rowid;
  const LedgerEntriesCompanion({
    this.id = const Value.absent(),
    this.side = const Value.absent(),
    this.customerId = const Value.absent(),
    this.supplierId = const Value.absent(),
    this.referenceType = const Value.absent(),
    this.referenceId = const Value.absent(),
    this.debit = const Value.absent(),
    this.credit = const Value.absent(),
    this.balanceAfter = const Value.absent(),
    this.entryDate = const Value.absent(),
    this.userId = const Value.absent(),
    this.notes = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  LedgerEntriesCompanion.insert({
    required String id,
    required String side,
    this.customerId = const Value.absent(),
    this.supplierId = const Value.absent(),
    required String referenceType,
    this.referenceId = const Value.absent(),
    this.debit = const Value.absent(),
    this.credit = const Value.absent(),
    this.balanceAfter = const Value.absent(),
    this.entryDate = const Value.absent(),
    this.userId = const Value.absent(),
    this.notes = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        side = Value(side),
        referenceType = Value(referenceType);
  static Insertable<LedgerEntry> custom({
    Expression<String>? id,
    Expression<String>? side,
    Expression<String>? customerId,
    Expression<String>? supplierId,
    Expression<String>? referenceType,
    Expression<String>? referenceId,
    Expression<int>? debit,
    Expression<int>? credit,
    Expression<int>? balanceAfter,
    Expression<DateTime>? entryDate,
    Expression<String>? userId,
    Expression<String>? notes,
    Expression<DateTime>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (side != null) 'side': side,
      if (customerId != null) 'customer_id': customerId,
      if (supplierId != null) 'supplier_id': supplierId,
      if (referenceType != null) 'reference_type': referenceType,
      if (referenceId != null) 'reference_id': referenceId,
      if (debit != null) 'debit': debit,
      if (credit != null) 'credit': credit,
      if (balanceAfter != null) 'balance_after': balanceAfter,
      if (entryDate != null) 'entry_date': entryDate,
      if (userId != null) 'user_id': userId,
      if (notes != null) 'notes': notes,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  LedgerEntriesCompanion copyWith(
      {Value<String>? id,
      Value<String>? side,
      Value<String?>? customerId,
      Value<String?>? supplierId,
      Value<String>? referenceType,
      Value<String?>? referenceId,
      Value<int>? debit,
      Value<int>? credit,
      Value<int>? balanceAfter,
      Value<DateTime>? entryDate,
      Value<String?>? userId,
      Value<String?>? notes,
      Value<DateTime>? createdAt,
      Value<int>? rowid}) {
    return LedgerEntriesCompanion(
      id: id ?? this.id,
      side: side ?? this.side,
      customerId: customerId ?? this.customerId,
      supplierId: supplierId ?? this.supplierId,
      referenceType: referenceType ?? this.referenceType,
      referenceId: referenceId ?? this.referenceId,
      debit: debit ?? this.debit,
      credit: credit ?? this.credit,
      balanceAfter: balanceAfter ?? this.balanceAfter,
      entryDate: entryDate ?? this.entryDate,
      userId: userId ?? this.userId,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (side.present) {
      map['side'] = Variable<String>(side.value);
    }
    if (customerId.present) {
      map['customer_id'] = Variable<String>(customerId.value);
    }
    if (supplierId.present) {
      map['supplier_id'] = Variable<String>(supplierId.value);
    }
    if (referenceType.present) {
      map['reference_type'] = Variable<String>(referenceType.value);
    }
    if (referenceId.present) {
      map['reference_id'] = Variable<String>(referenceId.value);
    }
    if (debit.present) {
      map['debit'] = Variable<int>(debit.value);
    }
    if (credit.present) {
      map['credit'] = Variable<int>(credit.value);
    }
    if (balanceAfter.present) {
      map['balance_after'] = Variable<int>(balanceAfter.value);
    }
    if (entryDate.present) {
      map['entry_date'] = Variable<DateTime>(entryDate.value);
    }
    if (userId.present) {
      map['user_id'] = Variable<String>(userId.value);
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('LedgerEntriesCompanion(')
          ..write('id: $id, ')
          ..write('side: $side, ')
          ..write('customerId: $customerId, ')
          ..write('supplierId: $supplierId, ')
          ..write('referenceType: $referenceType, ')
          ..write('referenceId: $referenceId, ')
          ..write('debit: $debit, ')
          ..write('credit: $credit, ')
          ..write('balanceAfter: $balanceAfter, ')
          ..write('entryDate: $entryDate, ')
          ..write('userId: $userId, ')
          ..write('notes: $notes, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $InstallmentsTable extends Installments
    with TableInfo<$InstallmentsTable, Installment> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $InstallmentsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _saleIdMeta = const VerificationMeta('saleId');
  @override
  late final GeneratedColumn<String> saleId = GeneratedColumn<String>(
      'sale_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _customerIdMeta =
      const VerificationMeta('customerId');
  @override
  late final GeneratedColumn<String> customerId = GeneratedColumn<String>(
      'customer_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _totalAmountMeta =
      const VerificationMeta('totalAmount');
  @override
  late final GeneratedColumn<int> totalAmount = GeneratedColumn<int>(
      'total_amount', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _downPaymentMeta =
      const VerificationMeta('downPayment');
  @override
  late final GeneratedColumn<int> downPayment = GeneratedColumn<int>(
      'down_payment', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _installmentCountMeta =
      const VerificationMeta('installmentCount');
  @override
  late final GeneratedColumn<int> installmentCount = GeneratedColumn<int>(
      'installment_count', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _installmentAmountMeta =
      const VerificationMeta('installmentAmount');
  @override
  late final GeneratedColumn<int> installmentAmount = GeneratedColumn<int>(
      'installment_amount', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _startDateMeta =
      const VerificationMeta('startDate');
  @override
  late final GeneratedColumn<DateTime> startDate = GeneratedColumn<DateTime>(
      'start_date', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
      'status', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('active'));
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  static const VerificationMeta _updatedAtMeta =
      const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
      'updated_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        saleId,
        customerId,
        totalAmount,
        downPayment,
        installmentCount,
        installmentAmount,
        startDate,
        status,
        createdAt,
        updatedAt
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'installments';
  @override
  VerificationContext validateIntegrity(Insertable<Installment> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('sale_id')) {
      context.handle(_saleIdMeta,
          saleId.isAcceptableOrUnknown(data['sale_id']!, _saleIdMeta));
    } else if (isInserting) {
      context.missing(_saleIdMeta);
    }
    if (data.containsKey('customer_id')) {
      context.handle(
          _customerIdMeta,
          customerId.isAcceptableOrUnknown(
              data['customer_id']!, _customerIdMeta));
    } else if (isInserting) {
      context.missing(_customerIdMeta);
    }
    if (data.containsKey('total_amount')) {
      context.handle(
          _totalAmountMeta,
          totalAmount.isAcceptableOrUnknown(
              data['total_amount']!, _totalAmountMeta));
    } else if (isInserting) {
      context.missing(_totalAmountMeta);
    }
    if (data.containsKey('down_payment')) {
      context.handle(
          _downPaymentMeta,
          downPayment.isAcceptableOrUnknown(
              data['down_payment']!, _downPaymentMeta));
    }
    if (data.containsKey('installment_count')) {
      context.handle(
          _installmentCountMeta,
          installmentCount.isAcceptableOrUnknown(
              data['installment_count']!, _installmentCountMeta));
    } else if (isInserting) {
      context.missing(_installmentCountMeta);
    }
    if (data.containsKey('installment_amount')) {
      context.handle(
          _installmentAmountMeta,
          installmentAmount.isAcceptableOrUnknown(
              data['installment_amount']!, _installmentAmountMeta));
    } else if (isInserting) {
      context.missing(_installmentAmountMeta);
    }
    if (data.containsKey('start_date')) {
      context.handle(_startDateMeta,
          startDate.isAcceptableOrUnknown(data['start_date']!, _startDateMeta));
    } else if (isInserting) {
      context.missing(_startDateMeta);
    }
    if (data.containsKey('status')) {
      context.handle(_statusMeta,
          status.isAcceptableOrUnknown(data['status']!, _statusMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    }
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta,
          updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Installment map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Installment(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      saleId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}sale_id'])!,
      customerId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}customer_id'])!,
      totalAmount: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}total_amount'])!,
      downPayment: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}down_payment'])!,
      installmentCount: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}installment_count'])!,
      installmentAmount: attachedDatabase.typeMapping.read(
          DriftSqlType.int, data['${effectivePrefix}installment_amount'])!,
      startDate: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}start_date'])!,
      status: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}status'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}updated_at'])!,
    );
  }

  @override
  $InstallmentsTable createAlias(String alias) {
    return $InstallmentsTable(attachedDatabase, alias);
  }
}

class Installment extends DataClass implements Insertable<Installment> {
  final String id;
  final String saleId;
  final String customerId;
  final int totalAmount;
  final int downPayment;
  final int installmentCount;
  final int installmentAmount;
  final DateTime startDate;
  final String status;
  final DateTime createdAt;
  final DateTime updatedAt;
  const Installment(
      {required this.id,
      required this.saleId,
      required this.customerId,
      required this.totalAmount,
      required this.downPayment,
      required this.installmentCount,
      required this.installmentAmount,
      required this.startDate,
      required this.status,
      required this.createdAt,
      required this.updatedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['sale_id'] = Variable<String>(saleId);
    map['customer_id'] = Variable<String>(customerId);
    map['total_amount'] = Variable<int>(totalAmount);
    map['down_payment'] = Variable<int>(downPayment);
    map['installment_count'] = Variable<int>(installmentCount);
    map['installment_amount'] = Variable<int>(installmentAmount);
    map['start_date'] = Variable<DateTime>(startDate);
    map['status'] = Variable<String>(status);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  InstallmentsCompanion toCompanion(bool nullToAbsent) {
    return InstallmentsCompanion(
      id: Value(id),
      saleId: Value(saleId),
      customerId: Value(customerId),
      totalAmount: Value(totalAmount),
      downPayment: Value(downPayment),
      installmentCount: Value(installmentCount),
      installmentAmount: Value(installmentAmount),
      startDate: Value(startDate),
      status: Value(status),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory Installment.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Installment(
      id: serializer.fromJson<String>(json['id']),
      saleId: serializer.fromJson<String>(json['saleId']),
      customerId: serializer.fromJson<String>(json['customerId']),
      totalAmount: serializer.fromJson<int>(json['totalAmount']),
      downPayment: serializer.fromJson<int>(json['downPayment']),
      installmentCount: serializer.fromJson<int>(json['installmentCount']),
      installmentAmount: serializer.fromJson<int>(json['installmentAmount']),
      startDate: serializer.fromJson<DateTime>(json['startDate']),
      status: serializer.fromJson<String>(json['status']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'saleId': serializer.toJson<String>(saleId),
      'customerId': serializer.toJson<String>(customerId),
      'totalAmount': serializer.toJson<int>(totalAmount),
      'downPayment': serializer.toJson<int>(downPayment),
      'installmentCount': serializer.toJson<int>(installmentCount),
      'installmentAmount': serializer.toJson<int>(installmentAmount),
      'startDate': serializer.toJson<DateTime>(startDate),
      'status': serializer.toJson<String>(status),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  Installment copyWith(
          {String? id,
          String? saleId,
          String? customerId,
          int? totalAmount,
          int? downPayment,
          int? installmentCount,
          int? installmentAmount,
          DateTime? startDate,
          String? status,
          DateTime? createdAt,
          DateTime? updatedAt}) =>
      Installment(
        id: id ?? this.id,
        saleId: saleId ?? this.saleId,
        customerId: customerId ?? this.customerId,
        totalAmount: totalAmount ?? this.totalAmount,
        downPayment: downPayment ?? this.downPayment,
        installmentCount: installmentCount ?? this.installmentCount,
        installmentAmount: installmentAmount ?? this.installmentAmount,
        startDate: startDate ?? this.startDate,
        status: status ?? this.status,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
      );
  Installment copyWithCompanion(InstallmentsCompanion data) {
    return Installment(
      id: data.id.present ? data.id.value : this.id,
      saleId: data.saleId.present ? data.saleId.value : this.saleId,
      customerId:
          data.customerId.present ? data.customerId.value : this.customerId,
      totalAmount:
          data.totalAmount.present ? data.totalAmount.value : this.totalAmount,
      downPayment:
          data.downPayment.present ? data.downPayment.value : this.downPayment,
      installmentCount: data.installmentCount.present
          ? data.installmentCount.value
          : this.installmentCount,
      installmentAmount: data.installmentAmount.present
          ? data.installmentAmount.value
          : this.installmentAmount,
      startDate: data.startDate.present ? data.startDate.value : this.startDate,
      status: data.status.present ? data.status.value : this.status,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Installment(')
          ..write('id: $id, ')
          ..write('saleId: $saleId, ')
          ..write('customerId: $customerId, ')
          ..write('totalAmount: $totalAmount, ')
          ..write('downPayment: $downPayment, ')
          ..write('installmentCount: $installmentCount, ')
          ..write('installmentAmount: $installmentAmount, ')
          ..write('startDate: $startDate, ')
          ..write('status: $status, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id,
      saleId,
      customerId,
      totalAmount,
      downPayment,
      installmentCount,
      installmentAmount,
      startDate,
      status,
      createdAt,
      updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Installment &&
          other.id == this.id &&
          other.saleId == this.saleId &&
          other.customerId == this.customerId &&
          other.totalAmount == this.totalAmount &&
          other.downPayment == this.downPayment &&
          other.installmentCount == this.installmentCount &&
          other.installmentAmount == this.installmentAmount &&
          other.startDate == this.startDate &&
          other.status == this.status &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class InstallmentsCompanion extends UpdateCompanion<Installment> {
  final Value<String> id;
  final Value<String> saleId;
  final Value<String> customerId;
  final Value<int> totalAmount;
  final Value<int> downPayment;
  final Value<int> installmentCount;
  final Value<int> installmentAmount;
  final Value<DateTime> startDate;
  final Value<String> status;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const InstallmentsCompanion({
    this.id = const Value.absent(),
    this.saleId = const Value.absent(),
    this.customerId = const Value.absent(),
    this.totalAmount = const Value.absent(),
    this.downPayment = const Value.absent(),
    this.installmentCount = const Value.absent(),
    this.installmentAmount = const Value.absent(),
    this.startDate = const Value.absent(),
    this.status = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  InstallmentsCompanion.insert({
    required String id,
    required String saleId,
    required String customerId,
    required int totalAmount,
    this.downPayment = const Value.absent(),
    required int installmentCount,
    required int installmentAmount,
    required DateTime startDate,
    this.status = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        saleId = Value(saleId),
        customerId = Value(customerId),
        totalAmount = Value(totalAmount),
        installmentCount = Value(installmentCount),
        installmentAmount = Value(installmentAmount),
        startDate = Value(startDate);
  static Insertable<Installment> custom({
    Expression<String>? id,
    Expression<String>? saleId,
    Expression<String>? customerId,
    Expression<int>? totalAmount,
    Expression<int>? downPayment,
    Expression<int>? installmentCount,
    Expression<int>? installmentAmount,
    Expression<DateTime>? startDate,
    Expression<String>? status,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (saleId != null) 'sale_id': saleId,
      if (customerId != null) 'customer_id': customerId,
      if (totalAmount != null) 'total_amount': totalAmount,
      if (downPayment != null) 'down_payment': downPayment,
      if (installmentCount != null) 'installment_count': installmentCount,
      if (installmentAmount != null) 'installment_amount': installmentAmount,
      if (startDate != null) 'start_date': startDate,
      if (status != null) 'status': status,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  InstallmentsCompanion copyWith(
      {Value<String>? id,
      Value<String>? saleId,
      Value<String>? customerId,
      Value<int>? totalAmount,
      Value<int>? downPayment,
      Value<int>? installmentCount,
      Value<int>? installmentAmount,
      Value<DateTime>? startDate,
      Value<String>? status,
      Value<DateTime>? createdAt,
      Value<DateTime>? updatedAt,
      Value<int>? rowid}) {
    return InstallmentsCompanion(
      id: id ?? this.id,
      saleId: saleId ?? this.saleId,
      customerId: customerId ?? this.customerId,
      totalAmount: totalAmount ?? this.totalAmount,
      downPayment: downPayment ?? this.downPayment,
      installmentCount: installmentCount ?? this.installmentCount,
      installmentAmount: installmentAmount ?? this.installmentAmount,
      startDate: startDate ?? this.startDate,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (saleId.present) {
      map['sale_id'] = Variable<String>(saleId.value);
    }
    if (customerId.present) {
      map['customer_id'] = Variable<String>(customerId.value);
    }
    if (totalAmount.present) {
      map['total_amount'] = Variable<int>(totalAmount.value);
    }
    if (downPayment.present) {
      map['down_payment'] = Variable<int>(downPayment.value);
    }
    if (installmentCount.present) {
      map['installment_count'] = Variable<int>(installmentCount.value);
    }
    if (installmentAmount.present) {
      map['installment_amount'] = Variable<int>(installmentAmount.value);
    }
    if (startDate.present) {
      map['start_date'] = Variable<DateTime>(startDate.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('InstallmentsCompanion(')
          ..write('id: $id, ')
          ..write('saleId: $saleId, ')
          ..write('customerId: $customerId, ')
          ..write('totalAmount: $totalAmount, ')
          ..write('downPayment: $downPayment, ')
          ..write('installmentCount: $installmentCount, ')
          ..write('installmentAmount: $installmentAmount, ')
          ..write('startDate: $startDate, ')
          ..write('status: $status, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $InstallmentPaymentsTable extends InstallmentPayments
    with TableInfo<$InstallmentPaymentsTable, InstallmentPayment> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $InstallmentPaymentsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _installmentIdMeta =
      const VerificationMeta('installmentId');
  @override
  late final GeneratedColumn<String> installmentId = GeneratedColumn<String>(
      'installment_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _dueDateMeta =
      const VerificationMeta('dueDate');
  @override
  late final GeneratedColumn<DateTime> dueDate = GeneratedColumn<DateTime>(
      'due_date', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _amountMeta = const VerificationMeta('amount');
  @override
  late final GeneratedColumn<int> amount = GeneratedColumn<int>(
      'amount', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _paidAmountMeta =
      const VerificationMeta('paidAmount');
  @override
  late final GeneratedColumn<int> paidAmount = GeneratedColumn<int>(
      'paid_amount', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _paidDateMeta =
      const VerificationMeta('paidDate');
  @override
  late final GeneratedColumn<DateTime> paidDate = GeneratedColumn<DateTime>(
      'paid_date', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
      'status', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('pending'));
  static const VerificationMeta _reminderSentMeta =
      const VerificationMeta('reminderSent');
  @override
  late final GeneratedColumn<bool> reminderSent = GeneratedColumn<bool>(
      'reminder_sent', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'CHECK ("reminder_sent" IN (0, 1))'),
      defaultValue: const Constant(false));
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  static const VerificationMeta _updatedAtMeta =
      const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
      'updated_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        installmentId,
        dueDate,
        amount,
        paidAmount,
        paidDate,
        status,
        reminderSent,
        createdAt,
        updatedAt
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'installment_payments';
  @override
  VerificationContext validateIntegrity(Insertable<InstallmentPayment> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('installment_id')) {
      context.handle(
          _installmentIdMeta,
          installmentId.isAcceptableOrUnknown(
              data['installment_id']!, _installmentIdMeta));
    } else if (isInserting) {
      context.missing(_installmentIdMeta);
    }
    if (data.containsKey('due_date')) {
      context.handle(_dueDateMeta,
          dueDate.isAcceptableOrUnknown(data['due_date']!, _dueDateMeta));
    } else if (isInserting) {
      context.missing(_dueDateMeta);
    }
    if (data.containsKey('amount')) {
      context.handle(_amountMeta,
          amount.isAcceptableOrUnknown(data['amount']!, _amountMeta));
    } else if (isInserting) {
      context.missing(_amountMeta);
    }
    if (data.containsKey('paid_amount')) {
      context.handle(
          _paidAmountMeta,
          paidAmount.isAcceptableOrUnknown(
              data['paid_amount']!, _paidAmountMeta));
    }
    if (data.containsKey('paid_date')) {
      context.handle(_paidDateMeta,
          paidDate.isAcceptableOrUnknown(data['paid_date']!, _paidDateMeta));
    }
    if (data.containsKey('status')) {
      context.handle(_statusMeta,
          status.isAcceptableOrUnknown(data['status']!, _statusMeta));
    }
    if (data.containsKey('reminder_sent')) {
      context.handle(
          _reminderSentMeta,
          reminderSent.isAcceptableOrUnknown(
              data['reminder_sent']!, _reminderSentMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    }
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta,
          updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  InstallmentPayment map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return InstallmentPayment(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      installmentId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}installment_id'])!,
      dueDate: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}due_date'])!,
      amount: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}amount'])!,
      paidAmount: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}paid_amount'])!,
      paidDate: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}paid_date']),
      status: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}status'])!,
      reminderSent: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}reminder_sent'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}updated_at'])!,
    );
  }

  @override
  $InstallmentPaymentsTable createAlias(String alias) {
    return $InstallmentPaymentsTable(attachedDatabase, alias);
  }
}

class InstallmentPayment extends DataClass
    implements Insertable<InstallmentPayment> {
  final String id;
  final String installmentId;
  final DateTime dueDate;
  final int amount;
  final int paidAmount;
  final DateTime? paidDate;
  final String status;
  final bool reminderSent;
  final DateTime createdAt;
  final DateTime updatedAt;
  const InstallmentPayment(
      {required this.id,
      required this.installmentId,
      required this.dueDate,
      required this.amount,
      required this.paidAmount,
      this.paidDate,
      required this.status,
      required this.reminderSent,
      required this.createdAt,
      required this.updatedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['installment_id'] = Variable<String>(installmentId);
    map['due_date'] = Variable<DateTime>(dueDate);
    map['amount'] = Variable<int>(amount);
    map['paid_amount'] = Variable<int>(paidAmount);
    if (!nullToAbsent || paidDate != null) {
      map['paid_date'] = Variable<DateTime>(paidDate);
    }
    map['status'] = Variable<String>(status);
    map['reminder_sent'] = Variable<bool>(reminderSent);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  InstallmentPaymentsCompanion toCompanion(bool nullToAbsent) {
    return InstallmentPaymentsCompanion(
      id: Value(id),
      installmentId: Value(installmentId),
      dueDate: Value(dueDate),
      amount: Value(amount),
      paidAmount: Value(paidAmount),
      paidDate: paidDate == null && nullToAbsent
          ? const Value.absent()
          : Value(paidDate),
      status: Value(status),
      reminderSent: Value(reminderSent),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory InstallmentPayment.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return InstallmentPayment(
      id: serializer.fromJson<String>(json['id']),
      installmentId: serializer.fromJson<String>(json['installmentId']),
      dueDate: serializer.fromJson<DateTime>(json['dueDate']),
      amount: serializer.fromJson<int>(json['amount']),
      paidAmount: serializer.fromJson<int>(json['paidAmount']),
      paidDate: serializer.fromJson<DateTime?>(json['paidDate']),
      status: serializer.fromJson<String>(json['status']),
      reminderSent: serializer.fromJson<bool>(json['reminderSent']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'installmentId': serializer.toJson<String>(installmentId),
      'dueDate': serializer.toJson<DateTime>(dueDate),
      'amount': serializer.toJson<int>(amount),
      'paidAmount': serializer.toJson<int>(paidAmount),
      'paidDate': serializer.toJson<DateTime?>(paidDate),
      'status': serializer.toJson<String>(status),
      'reminderSent': serializer.toJson<bool>(reminderSent),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  InstallmentPayment copyWith(
          {String? id,
          String? installmentId,
          DateTime? dueDate,
          int? amount,
          int? paidAmount,
          Value<DateTime?> paidDate = const Value.absent(),
          String? status,
          bool? reminderSent,
          DateTime? createdAt,
          DateTime? updatedAt}) =>
      InstallmentPayment(
        id: id ?? this.id,
        installmentId: installmentId ?? this.installmentId,
        dueDate: dueDate ?? this.dueDate,
        amount: amount ?? this.amount,
        paidAmount: paidAmount ?? this.paidAmount,
        paidDate: paidDate.present ? paidDate.value : this.paidDate,
        status: status ?? this.status,
        reminderSent: reminderSent ?? this.reminderSent,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
      );
  InstallmentPayment copyWithCompanion(InstallmentPaymentsCompanion data) {
    return InstallmentPayment(
      id: data.id.present ? data.id.value : this.id,
      installmentId: data.installmentId.present
          ? data.installmentId.value
          : this.installmentId,
      dueDate: data.dueDate.present ? data.dueDate.value : this.dueDate,
      amount: data.amount.present ? data.amount.value : this.amount,
      paidAmount:
          data.paidAmount.present ? data.paidAmount.value : this.paidAmount,
      paidDate: data.paidDate.present ? data.paidDate.value : this.paidDate,
      status: data.status.present ? data.status.value : this.status,
      reminderSent: data.reminderSent.present
          ? data.reminderSent.value
          : this.reminderSent,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('InstallmentPayment(')
          ..write('id: $id, ')
          ..write('installmentId: $installmentId, ')
          ..write('dueDate: $dueDate, ')
          ..write('amount: $amount, ')
          ..write('paidAmount: $paidAmount, ')
          ..write('paidDate: $paidDate, ')
          ..write('status: $status, ')
          ..write('reminderSent: $reminderSent, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, installmentId, dueDate, amount,
      paidAmount, paidDate, status, reminderSent, createdAt, updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is InstallmentPayment &&
          other.id == this.id &&
          other.installmentId == this.installmentId &&
          other.dueDate == this.dueDate &&
          other.amount == this.amount &&
          other.paidAmount == this.paidAmount &&
          other.paidDate == this.paidDate &&
          other.status == this.status &&
          other.reminderSent == this.reminderSent &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class InstallmentPaymentsCompanion extends UpdateCompanion<InstallmentPayment> {
  final Value<String> id;
  final Value<String> installmentId;
  final Value<DateTime> dueDate;
  final Value<int> amount;
  final Value<int> paidAmount;
  final Value<DateTime?> paidDate;
  final Value<String> status;
  final Value<bool> reminderSent;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const InstallmentPaymentsCompanion({
    this.id = const Value.absent(),
    this.installmentId = const Value.absent(),
    this.dueDate = const Value.absent(),
    this.amount = const Value.absent(),
    this.paidAmount = const Value.absent(),
    this.paidDate = const Value.absent(),
    this.status = const Value.absent(),
    this.reminderSent = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  InstallmentPaymentsCompanion.insert({
    required String id,
    required String installmentId,
    required DateTime dueDate,
    required int amount,
    this.paidAmount = const Value.absent(),
    this.paidDate = const Value.absent(),
    this.status = const Value.absent(),
    this.reminderSent = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        installmentId = Value(installmentId),
        dueDate = Value(dueDate),
        amount = Value(amount);
  static Insertable<InstallmentPayment> custom({
    Expression<String>? id,
    Expression<String>? installmentId,
    Expression<DateTime>? dueDate,
    Expression<int>? amount,
    Expression<int>? paidAmount,
    Expression<DateTime>? paidDate,
    Expression<String>? status,
    Expression<bool>? reminderSent,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (installmentId != null) 'installment_id': installmentId,
      if (dueDate != null) 'due_date': dueDate,
      if (amount != null) 'amount': amount,
      if (paidAmount != null) 'paid_amount': paidAmount,
      if (paidDate != null) 'paid_date': paidDate,
      if (status != null) 'status': status,
      if (reminderSent != null) 'reminder_sent': reminderSent,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  InstallmentPaymentsCompanion copyWith(
      {Value<String>? id,
      Value<String>? installmentId,
      Value<DateTime>? dueDate,
      Value<int>? amount,
      Value<int>? paidAmount,
      Value<DateTime?>? paidDate,
      Value<String>? status,
      Value<bool>? reminderSent,
      Value<DateTime>? createdAt,
      Value<DateTime>? updatedAt,
      Value<int>? rowid}) {
    return InstallmentPaymentsCompanion(
      id: id ?? this.id,
      installmentId: installmentId ?? this.installmentId,
      dueDate: dueDate ?? this.dueDate,
      amount: amount ?? this.amount,
      paidAmount: paidAmount ?? this.paidAmount,
      paidDate: paidDate ?? this.paidDate,
      status: status ?? this.status,
      reminderSent: reminderSent ?? this.reminderSent,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (installmentId.present) {
      map['installment_id'] = Variable<String>(installmentId.value);
    }
    if (dueDate.present) {
      map['due_date'] = Variable<DateTime>(dueDate.value);
    }
    if (amount.present) {
      map['amount'] = Variable<int>(amount.value);
    }
    if (paidAmount.present) {
      map['paid_amount'] = Variable<int>(paidAmount.value);
    }
    if (paidDate.present) {
      map['paid_date'] = Variable<DateTime>(paidDate.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (reminderSent.present) {
      map['reminder_sent'] = Variable<bool>(reminderSent.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('InstallmentPaymentsCompanion(')
          ..write('id: $id, ')
          ..write('installmentId: $installmentId, ')
          ..write('dueDate: $dueDate, ')
          ..write('amount: $amount, ')
          ..write('paidAmount: $paidAmount, ')
          ..write('paidDate: $paidDate, ')
          ..write('status: $status, ')
          ..write('reminderSent: $reminderSent, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $RepairsTable extends Repairs with TableInfo<$RepairsTable, Repair> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $RepairsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _jobNoMeta = const VerificationMeta('jobNo');
  @override
  late final GeneratedColumn<String> jobNo = GeneratedColumn<String>(
      'job_no', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'));
  static const VerificationMeta _customerIdMeta =
      const VerificationMeta('customerId');
  @override
  late final GeneratedColumn<String> customerId = GeneratedColumn<String>(
      'customer_id', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _customerNameMeta =
      const VerificationMeta('customerName');
  @override
  late final GeneratedColumn<String> customerName = GeneratedColumn<String>(
      'customer_name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _customerPhoneMeta =
      const VerificationMeta('customerPhone');
  @override
  late final GeneratedColumn<String> customerPhone = GeneratedColumn<String>(
      'customer_phone', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _deviceBrandMeta =
      const VerificationMeta('deviceBrand');
  @override
  late final GeneratedColumn<String> deviceBrand = GeneratedColumn<String>(
      'device_brand', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _deviceModelMeta =
      const VerificationMeta('deviceModel');
  @override
  late final GeneratedColumn<String> deviceModel = GeneratedColumn<String>(
      'device_model', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _imeiMeta = const VerificationMeta('imei');
  @override
  late final GeneratedColumn<String> imei = GeneratedColumn<String>(
      'imei', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _faultDescriptionMeta =
      const VerificationMeta('faultDescription');
  @override
  late final GeneratedColumn<String> faultDescription = GeneratedColumn<String>(
      'fault_description', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _estimatedCostMeta =
      const VerificationMeta('estimatedCost');
  @override
  late final GeneratedColumn<int> estimatedCost = GeneratedColumn<int>(
      'estimated_cost', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _finalCostMeta =
      const VerificationMeta('finalCost');
  @override
  late final GeneratedColumn<int> finalCost = GeneratedColumn<int>(
      'final_cost', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _advancePaidMeta =
      const VerificationMeta('advancePaid');
  @override
  late final GeneratedColumn<int> advancePaid = GeneratedColumn<int>(
      'advance_paid', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
      'status', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('received'));
  static const VerificationMeta _receivedDateMeta =
      const VerificationMeta('receivedDate');
  @override
  late final GeneratedColumn<DateTime> receivedDate = GeneratedColumn<DateTime>(
      'received_date', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  static const VerificationMeta _readyDateMeta =
      const VerificationMeta('readyDate');
  @override
  late final GeneratedColumn<DateTime> readyDate = GeneratedColumn<DateTime>(
      'ready_date', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  static const VerificationMeta _deliveredDateMeta =
      const VerificationMeta('deliveredDate');
  @override
  late final GeneratedColumn<DateTime> deliveredDate =
      GeneratedColumn<DateTime>('delivered_date', aliasedName, true,
          type: DriftSqlType.dateTime, requiredDuringInsert: false);
  static const VerificationMeta _userIdMeta = const VerificationMeta('userId');
  @override
  late final GeneratedColumn<String> userId = GeneratedColumn<String>(
      'user_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _notesMeta = const VerificationMeta('notes');
  @override
  late final GeneratedColumn<String> notes = GeneratedColumn<String>(
      'notes', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  static const VerificationMeta _updatedAtMeta =
      const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
      'updated_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        jobNo,
        customerId,
        customerName,
        customerPhone,
        deviceBrand,
        deviceModel,
        imei,
        faultDescription,
        estimatedCost,
        finalCost,
        advancePaid,
        status,
        receivedDate,
        readyDate,
        deliveredDate,
        userId,
        notes,
        createdAt,
        updatedAt
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'repairs';
  @override
  VerificationContext validateIntegrity(Insertable<Repair> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('job_no')) {
      context.handle(
          _jobNoMeta, jobNo.isAcceptableOrUnknown(data['job_no']!, _jobNoMeta));
    } else if (isInserting) {
      context.missing(_jobNoMeta);
    }
    if (data.containsKey('customer_id')) {
      context.handle(
          _customerIdMeta,
          customerId.isAcceptableOrUnknown(
              data['customer_id']!, _customerIdMeta));
    }
    if (data.containsKey('customer_name')) {
      context.handle(
          _customerNameMeta,
          customerName.isAcceptableOrUnknown(
              data['customer_name']!, _customerNameMeta));
    } else if (isInserting) {
      context.missing(_customerNameMeta);
    }
    if (data.containsKey('customer_phone')) {
      context.handle(
          _customerPhoneMeta,
          customerPhone.isAcceptableOrUnknown(
              data['customer_phone']!, _customerPhoneMeta));
    } else if (isInserting) {
      context.missing(_customerPhoneMeta);
    }
    if (data.containsKey('device_brand')) {
      context.handle(
          _deviceBrandMeta,
          deviceBrand.isAcceptableOrUnknown(
              data['device_brand']!, _deviceBrandMeta));
    }
    if (data.containsKey('device_model')) {
      context.handle(
          _deviceModelMeta,
          deviceModel.isAcceptableOrUnknown(
              data['device_model']!, _deviceModelMeta));
    }
    if (data.containsKey('imei')) {
      context.handle(
          _imeiMeta, imei.isAcceptableOrUnknown(data['imei']!, _imeiMeta));
    }
    if (data.containsKey('fault_description')) {
      context.handle(
          _faultDescriptionMeta,
          faultDescription.isAcceptableOrUnknown(
              data['fault_description']!, _faultDescriptionMeta));
    } else if (isInserting) {
      context.missing(_faultDescriptionMeta);
    }
    if (data.containsKey('estimated_cost')) {
      context.handle(
          _estimatedCostMeta,
          estimatedCost.isAcceptableOrUnknown(
              data['estimated_cost']!, _estimatedCostMeta));
    }
    if (data.containsKey('final_cost')) {
      context.handle(_finalCostMeta,
          finalCost.isAcceptableOrUnknown(data['final_cost']!, _finalCostMeta));
    }
    if (data.containsKey('advance_paid')) {
      context.handle(
          _advancePaidMeta,
          advancePaid.isAcceptableOrUnknown(
              data['advance_paid']!, _advancePaidMeta));
    }
    if (data.containsKey('status')) {
      context.handle(_statusMeta,
          status.isAcceptableOrUnknown(data['status']!, _statusMeta));
    }
    if (data.containsKey('received_date')) {
      context.handle(
          _receivedDateMeta,
          receivedDate.isAcceptableOrUnknown(
              data['received_date']!, _receivedDateMeta));
    }
    if (data.containsKey('ready_date')) {
      context.handle(_readyDateMeta,
          readyDate.isAcceptableOrUnknown(data['ready_date']!, _readyDateMeta));
    }
    if (data.containsKey('delivered_date')) {
      context.handle(
          _deliveredDateMeta,
          deliveredDate.isAcceptableOrUnknown(
              data['delivered_date']!, _deliveredDateMeta));
    }
    if (data.containsKey('user_id')) {
      context.handle(_userIdMeta,
          userId.isAcceptableOrUnknown(data['user_id']!, _userIdMeta));
    } else if (isInserting) {
      context.missing(_userIdMeta);
    }
    if (data.containsKey('notes')) {
      context.handle(
          _notesMeta, notes.isAcceptableOrUnknown(data['notes']!, _notesMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    }
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta,
          updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Repair map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Repair(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      jobNo: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}job_no'])!,
      customerId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}customer_id']),
      customerName: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}customer_name'])!,
      customerPhone: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}customer_phone'])!,
      deviceBrand: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}device_brand']),
      deviceModel: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}device_model']),
      imei: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}imei']),
      faultDescription: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}fault_description'])!,
      estimatedCost: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}estimated_cost'])!,
      finalCost: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}final_cost'])!,
      advancePaid: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}advance_paid'])!,
      status: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}status'])!,
      receivedDate: attachedDatabase.typeMapping.read(
          DriftSqlType.dateTime, data['${effectivePrefix}received_date'])!,
      readyDate: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}ready_date']),
      deliveredDate: attachedDatabase.typeMapping.read(
          DriftSqlType.dateTime, data['${effectivePrefix}delivered_date']),
      userId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}user_id'])!,
      notes: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}notes']),
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}updated_at'])!,
    );
  }

  @override
  $RepairsTable createAlias(String alias) {
    return $RepairsTable(attachedDatabase, alias);
  }
}

class Repair extends DataClass implements Insertable<Repair> {
  final String id;
  final String jobNo;
  final String? customerId;
  final String customerName;
  final String customerPhone;
  final String? deviceBrand;
  final String? deviceModel;
  final String? imei;
  final String faultDescription;
  final int estimatedCost;
  final int finalCost;
  final int advancePaid;
  final String status;
  final DateTime receivedDate;
  final DateTime? readyDate;
  final DateTime? deliveredDate;
  final String userId;
  final String? notes;
  final DateTime createdAt;
  final DateTime updatedAt;
  const Repair(
      {required this.id,
      required this.jobNo,
      this.customerId,
      required this.customerName,
      required this.customerPhone,
      this.deviceBrand,
      this.deviceModel,
      this.imei,
      required this.faultDescription,
      required this.estimatedCost,
      required this.finalCost,
      required this.advancePaid,
      required this.status,
      required this.receivedDate,
      this.readyDate,
      this.deliveredDate,
      required this.userId,
      this.notes,
      required this.createdAt,
      required this.updatedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['job_no'] = Variable<String>(jobNo);
    if (!nullToAbsent || customerId != null) {
      map['customer_id'] = Variable<String>(customerId);
    }
    map['customer_name'] = Variable<String>(customerName);
    map['customer_phone'] = Variable<String>(customerPhone);
    if (!nullToAbsent || deviceBrand != null) {
      map['device_brand'] = Variable<String>(deviceBrand);
    }
    if (!nullToAbsent || deviceModel != null) {
      map['device_model'] = Variable<String>(deviceModel);
    }
    if (!nullToAbsent || imei != null) {
      map['imei'] = Variable<String>(imei);
    }
    map['fault_description'] = Variable<String>(faultDescription);
    map['estimated_cost'] = Variable<int>(estimatedCost);
    map['final_cost'] = Variable<int>(finalCost);
    map['advance_paid'] = Variable<int>(advancePaid);
    map['status'] = Variable<String>(status);
    map['received_date'] = Variable<DateTime>(receivedDate);
    if (!nullToAbsent || readyDate != null) {
      map['ready_date'] = Variable<DateTime>(readyDate);
    }
    if (!nullToAbsent || deliveredDate != null) {
      map['delivered_date'] = Variable<DateTime>(deliveredDate);
    }
    map['user_id'] = Variable<String>(userId);
    if (!nullToAbsent || notes != null) {
      map['notes'] = Variable<String>(notes);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  RepairsCompanion toCompanion(bool nullToAbsent) {
    return RepairsCompanion(
      id: Value(id),
      jobNo: Value(jobNo),
      customerId: customerId == null && nullToAbsent
          ? const Value.absent()
          : Value(customerId),
      customerName: Value(customerName),
      customerPhone: Value(customerPhone),
      deviceBrand: deviceBrand == null && nullToAbsent
          ? const Value.absent()
          : Value(deviceBrand),
      deviceModel: deviceModel == null && nullToAbsent
          ? const Value.absent()
          : Value(deviceModel),
      imei: imei == null && nullToAbsent ? const Value.absent() : Value(imei),
      faultDescription: Value(faultDescription),
      estimatedCost: Value(estimatedCost),
      finalCost: Value(finalCost),
      advancePaid: Value(advancePaid),
      status: Value(status),
      receivedDate: Value(receivedDate),
      readyDate: readyDate == null && nullToAbsent
          ? const Value.absent()
          : Value(readyDate),
      deliveredDate: deliveredDate == null && nullToAbsent
          ? const Value.absent()
          : Value(deliveredDate),
      userId: Value(userId),
      notes:
          notes == null && nullToAbsent ? const Value.absent() : Value(notes),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory Repair.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Repair(
      id: serializer.fromJson<String>(json['id']),
      jobNo: serializer.fromJson<String>(json['jobNo']),
      customerId: serializer.fromJson<String?>(json['customerId']),
      customerName: serializer.fromJson<String>(json['customerName']),
      customerPhone: serializer.fromJson<String>(json['customerPhone']),
      deviceBrand: serializer.fromJson<String?>(json['deviceBrand']),
      deviceModel: serializer.fromJson<String?>(json['deviceModel']),
      imei: serializer.fromJson<String?>(json['imei']),
      faultDescription: serializer.fromJson<String>(json['faultDescription']),
      estimatedCost: serializer.fromJson<int>(json['estimatedCost']),
      finalCost: serializer.fromJson<int>(json['finalCost']),
      advancePaid: serializer.fromJson<int>(json['advancePaid']),
      status: serializer.fromJson<String>(json['status']),
      receivedDate: serializer.fromJson<DateTime>(json['receivedDate']),
      readyDate: serializer.fromJson<DateTime?>(json['readyDate']),
      deliveredDate: serializer.fromJson<DateTime?>(json['deliveredDate']),
      userId: serializer.fromJson<String>(json['userId']),
      notes: serializer.fromJson<String?>(json['notes']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'jobNo': serializer.toJson<String>(jobNo),
      'customerId': serializer.toJson<String?>(customerId),
      'customerName': serializer.toJson<String>(customerName),
      'customerPhone': serializer.toJson<String>(customerPhone),
      'deviceBrand': serializer.toJson<String?>(deviceBrand),
      'deviceModel': serializer.toJson<String?>(deviceModel),
      'imei': serializer.toJson<String?>(imei),
      'faultDescription': serializer.toJson<String>(faultDescription),
      'estimatedCost': serializer.toJson<int>(estimatedCost),
      'finalCost': serializer.toJson<int>(finalCost),
      'advancePaid': serializer.toJson<int>(advancePaid),
      'status': serializer.toJson<String>(status),
      'receivedDate': serializer.toJson<DateTime>(receivedDate),
      'readyDate': serializer.toJson<DateTime?>(readyDate),
      'deliveredDate': serializer.toJson<DateTime?>(deliveredDate),
      'userId': serializer.toJson<String>(userId),
      'notes': serializer.toJson<String?>(notes),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  Repair copyWith(
          {String? id,
          String? jobNo,
          Value<String?> customerId = const Value.absent(),
          String? customerName,
          String? customerPhone,
          Value<String?> deviceBrand = const Value.absent(),
          Value<String?> deviceModel = const Value.absent(),
          Value<String?> imei = const Value.absent(),
          String? faultDescription,
          int? estimatedCost,
          int? finalCost,
          int? advancePaid,
          String? status,
          DateTime? receivedDate,
          Value<DateTime?> readyDate = const Value.absent(),
          Value<DateTime?> deliveredDate = const Value.absent(),
          String? userId,
          Value<String?> notes = const Value.absent(),
          DateTime? createdAt,
          DateTime? updatedAt}) =>
      Repair(
        id: id ?? this.id,
        jobNo: jobNo ?? this.jobNo,
        customerId: customerId.present ? customerId.value : this.customerId,
        customerName: customerName ?? this.customerName,
        customerPhone: customerPhone ?? this.customerPhone,
        deviceBrand: deviceBrand.present ? deviceBrand.value : this.deviceBrand,
        deviceModel: deviceModel.present ? deviceModel.value : this.deviceModel,
        imei: imei.present ? imei.value : this.imei,
        faultDescription: faultDescription ?? this.faultDescription,
        estimatedCost: estimatedCost ?? this.estimatedCost,
        finalCost: finalCost ?? this.finalCost,
        advancePaid: advancePaid ?? this.advancePaid,
        status: status ?? this.status,
        receivedDate: receivedDate ?? this.receivedDate,
        readyDate: readyDate.present ? readyDate.value : this.readyDate,
        deliveredDate:
            deliveredDate.present ? deliveredDate.value : this.deliveredDate,
        userId: userId ?? this.userId,
        notes: notes.present ? notes.value : this.notes,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
      );
  Repair copyWithCompanion(RepairsCompanion data) {
    return Repair(
      id: data.id.present ? data.id.value : this.id,
      jobNo: data.jobNo.present ? data.jobNo.value : this.jobNo,
      customerId:
          data.customerId.present ? data.customerId.value : this.customerId,
      customerName: data.customerName.present
          ? data.customerName.value
          : this.customerName,
      customerPhone: data.customerPhone.present
          ? data.customerPhone.value
          : this.customerPhone,
      deviceBrand:
          data.deviceBrand.present ? data.deviceBrand.value : this.deviceBrand,
      deviceModel:
          data.deviceModel.present ? data.deviceModel.value : this.deviceModel,
      imei: data.imei.present ? data.imei.value : this.imei,
      faultDescription: data.faultDescription.present
          ? data.faultDescription.value
          : this.faultDescription,
      estimatedCost: data.estimatedCost.present
          ? data.estimatedCost.value
          : this.estimatedCost,
      finalCost: data.finalCost.present ? data.finalCost.value : this.finalCost,
      advancePaid:
          data.advancePaid.present ? data.advancePaid.value : this.advancePaid,
      status: data.status.present ? data.status.value : this.status,
      receivedDate: data.receivedDate.present
          ? data.receivedDate.value
          : this.receivedDate,
      readyDate: data.readyDate.present ? data.readyDate.value : this.readyDate,
      deliveredDate: data.deliveredDate.present
          ? data.deliveredDate.value
          : this.deliveredDate,
      userId: data.userId.present ? data.userId.value : this.userId,
      notes: data.notes.present ? data.notes.value : this.notes,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Repair(')
          ..write('id: $id, ')
          ..write('jobNo: $jobNo, ')
          ..write('customerId: $customerId, ')
          ..write('customerName: $customerName, ')
          ..write('customerPhone: $customerPhone, ')
          ..write('deviceBrand: $deviceBrand, ')
          ..write('deviceModel: $deviceModel, ')
          ..write('imei: $imei, ')
          ..write('faultDescription: $faultDescription, ')
          ..write('estimatedCost: $estimatedCost, ')
          ..write('finalCost: $finalCost, ')
          ..write('advancePaid: $advancePaid, ')
          ..write('status: $status, ')
          ..write('receivedDate: $receivedDate, ')
          ..write('readyDate: $readyDate, ')
          ..write('deliveredDate: $deliveredDate, ')
          ..write('userId: $userId, ')
          ..write('notes: $notes, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id,
      jobNo,
      customerId,
      customerName,
      customerPhone,
      deviceBrand,
      deviceModel,
      imei,
      faultDescription,
      estimatedCost,
      finalCost,
      advancePaid,
      status,
      receivedDate,
      readyDate,
      deliveredDate,
      userId,
      notes,
      createdAt,
      updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Repair &&
          other.id == this.id &&
          other.jobNo == this.jobNo &&
          other.customerId == this.customerId &&
          other.customerName == this.customerName &&
          other.customerPhone == this.customerPhone &&
          other.deviceBrand == this.deviceBrand &&
          other.deviceModel == this.deviceModel &&
          other.imei == this.imei &&
          other.faultDescription == this.faultDescription &&
          other.estimatedCost == this.estimatedCost &&
          other.finalCost == this.finalCost &&
          other.advancePaid == this.advancePaid &&
          other.status == this.status &&
          other.receivedDate == this.receivedDate &&
          other.readyDate == this.readyDate &&
          other.deliveredDate == this.deliveredDate &&
          other.userId == this.userId &&
          other.notes == this.notes &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class RepairsCompanion extends UpdateCompanion<Repair> {
  final Value<String> id;
  final Value<String> jobNo;
  final Value<String?> customerId;
  final Value<String> customerName;
  final Value<String> customerPhone;
  final Value<String?> deviceBrand;
  final Value<String?> deviceModel;
  final Value<String?> imei;
  final Value<String> faultDescription;
  final Value<int> estimatedCost;
  final Value<int> finalCost;
  final Value<int> advancePaid;
  final Value<String> status;
  final Value<DateTime> receivedDate;
  final Value<DateTime?> readyDate;
  final Value<DateTime?> deliveredDate;
  final Value<String> userId;
  final Value<String?> notes;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const RepairsCompanion({
    this.id = const Value.absent(),
    this.jobNo = const Value.absent(),
    this.customerId = const Value.absent(),
    this.customerName = const Value.absent(),
    this.customerPhone = const Value.absent(),
    this.deviceBrand = const Value.absent(),
    this.deviceModel = const Value.absent(),
    this.imei = const Value.absent(),
    this.faultDescription = const Value.absent(),
    this.estimatedCost = const Value.absent(),
    this.finalCost = const Value.absent(),
    this.advancePaid = const Value.absent(),
    this.status = const Value.absent(),
    this.receivedDate = const Value.absent(),
    this.readyDate = const Value.absent(),
    this.deliveredDate = const Value.absent(),
    this.userId = const Value.absent(),
    this.notes = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  RepairsCompanion.insert({
    required String id,
    required String jobNo,
    this.customerId = const Value.absent(),
    required String customerName,
    required String customerPhone,
    this.deviceBrand = const Value.absent(),
    this.deviceModel = const Value.absent(),
    this.imei = const Value.absent(),
    required String faultDescription,
    this.estimatedCost = const Value.absent(),
    this.finalCost = const Value.absent(),
    this.advancePaid = const Value.absent(),
    this.status = const Value.absent(),
    this.receivedDate = const Value.absent(),
    this.readyDate = const Value.absent(),
    this.deliveredDate = const Value.absent(),
    required String userId,
    this.notes = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        jobNo = Value(jobNo),
        customerName = Value(customerName),
        customerPhone = Value(customerPhone),
        faultDescription = Value(faultDescription),
        userId = Value(userId);
  static Insertable<Repair> custom({
    Expression<String>? id,
    Expression<String>? jobNo,
    Expression<String>? customerId,
    Expression<String>? customerName,
    Expression<String>? customerPhone,
    Expression<String>? deviceBrand,
    Expression<String>? deviceModel,
    Expression<String>? imei,
    Expression<String>? faultDescription,
    Expression<int>? estimatedCost,
    Expression<int>? finalCost,
    Expression<int>? advancePaid,
    Expression<String>? status,
    Expression<DateTime>? receivedDate,
    Expression<DateTime>? readyDate,
    Expression<DateTime>? deliveredDate,
    Expression<String>? userId,
    Expression<String>? notes,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (jobNo != null) 'job_no': jobNo,
      if (customerId != null) 'customer_id': customerId,
      if (customerName != null) 'customer_name': customerName,
      if (customerPhone != null) 'customer_phone': customerPhone,
      if (deviceBrand != null) 'device_brand': deviceBrand,
      if (deviceModel != null) 'device_model': deviceModel,
      if (imei != null) 'imei': imei,
      if (faultDescription != null) 'fault_description': faultDescription,
      if (estimatedCost != null) 'estimated_cost': estimatedCost,
      if (finalCost != null) 'final_cost': finalCost,
      if (advancePaid != null) 'advance_paid': advancePaid,
      if (status != null) 'status': status,
      if (receivedDate != null) 'received_date': receivedDate,
      if (readyDate != null) 'ready_date': readyDate,
      if (deliveredDate != null) 'delivered_date': deliveredDate,
      if (userId != null) 'user_id': userId,
      if (notes != null) 'notes': notes,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  RepairsCompanion copyWith(
      {Value<String>? id,
      Value<String>? jobNo,
      Value<String?>? customerId,
      Value<String>? customerName,
      Value<String>? customerPhone,
      Value<String?>? deviceBrand,
      Value<String?>? deviceModel,
      Value<String?>? imei,
      Value<String>? faultDescription,
      Value<int>? estimatedCost,
      Value<int>? finalCost,
      Value<int>? advancePaid,
      Value<String>? status,
      Value<DateTime>? receivedDate,
      Value<DateTime?>? readyDate,
      Value<DateTime?>? deliveredDate,
      Value<String>? userId,
      Value<String?>? notes,
      Value<DateTime>? createdAt,
      Value<DateTime>? updatedAt,
      Value<int>? rowid}) {
    return RepairsCompanion(
      id: id ?? this.id,
      jobNo: jobNo ?? this.jobNo,
      customerId: customerId ?? this.customerId,
      customerName: customerName ?? this.customerName,
      customerPhone: customerPhone ?? this.customerPhone,
      deviceBrand: deviceBrand ?? this.deviceBrand,
      deviceModel: deviceModel ?? this.deviceModel,
      imei: imei ?? this.imei,
      faultDescription: faultDescription ?? this.faultDescription,
      estimatedCost: estimatedCost ?? this.estimatedCost,
      finalCost: finalCost ?? this.finalCost,
      advancePaid: advancePaid ?? this.advancePaid,
      status: status ?? this.status,
      receivedDate: receivedDate ?? this.receivedDate,
      readyDate: readyDate ?? this.readyDate,
      deliveredDate: deliveredDate ?? this.deliveredDate,
      userId: userId ?? this.userId,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (jobNo.present) {
      map['job_no'] = Variable<String>(jobNo.value);
    }
    if (customerId.present) {
      map['customer_id'] = Variable<String>(customerId.value);
    }
    if (customerName.present) {
      map['customer_name'] = Variable<String>(customerName.value);
    }
    if (customerPhone.present) {
      map['customer_phone'] = Variable<String>(customerPhone.value);
    }
    if (deviceBrand.present) {
      map['device_brand'] = Variable<String>(deviceBrand.value);
    }
    if (deviceModel.present) {
      map['device_model'] = Variable<String>(deviceModel.value);
    }
    if (imei.present) {
      map['imei'] = Variable<String>(imei.value);
    }
    if (faultDescription.present) {
      map['fault_description'] = Variable<String>(faultDescription.value);
    }
    if (estimatedCost.present) {
      map['estimated_cost'] = Variable<int>(estimatedCost.value);
    }
    if (finalCost.present) {
      map['final_cost'] = Variable<int>(finalCost.value);
    }
    if (advancePaid.present) {
      map['advance_paid'] = Variable<int>(advancePaid.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (receivedDate.present) {
      map['received_date'] = Variable<DateTime>(receivedDate.value);
    }
    if (readyDate.present) {
      map['ready_date'] = Variable<DateTime>(readyDate.value);
    }
    if (deliveredDate.present) {
      map['delivered_date'] = Variable<DateTime>(deliveredDate.value);
    }
    if (userId.present) {
      map['user_id'] = Variable<String>(userId.value);
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('RepairsCompanion(')
          ..write('id: $id, ')
          ..write('jobNo: $jobNo, ')
          ..write('customerId: $customerId, ')
          ..write('customerName: $customerName, ')
          ..write('customerPhone: $customerPhone, ')
          ..write('deviceBrand: $deviceBrand, ')
          ..write('deviceModel: $deviceModel, ')
          ..write('imei: $imei, ')
          ..write('faultDescription: $faultDescription, ')
          ..write('estimatedCost: $estimatedCost, ')
          ..write('finalCost: $finalCost, ')
          ..write('advancePaid: $advancePaid, ')
          ..write('status: $status, ')
          ..write('receivedDate: $receivedDate, ')
          ..write('readyDate: $readyDate, ')
          ..write('deliveredDate: $deliveredDate, ')
          ..write('userId: $userId, ')
          ..write('notes: $notes, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $RepairPartsTable extends RepairParts
    with TableInfo<$RepairPartsTable, RepairPart> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $RepairPartsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _repairIdMeta =
      const VerificationMeta('repairId');
  @override
  late final GeneratedColumn<String> repairId = GeneratedColumn<String>(
      'repair_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _productIdMeta =
      const VerificationMeta('productId');
  @override
  late final GeneratedColumn<String> productId = GeneratedColumn<String>(
      'product_id', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _variantIdMeta =
      const VerificationMeta('variantId');
  @override
  late final GeneratedColumn<String> variantId = GeneratedColumn<String>(
      'variant_id', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
      'name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _quantityMeta =
      const VerificationMeta('quantity');
  @override
  late final GeneratedColumn<int> quantity = GeneratedColumn<int>(
      'quantity', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(1));
  static const VerificationMeta _unitPriceMeta =
      const VerificationMeta('unitPrice');
  @override
  late final GeneratedColumn<int> unitPrice = GeneratedColumn<int>(
      'unit_price', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _totalMeta = const VerificationMeta('total');
  @override
  late final GeneratedColumn<int> total = GeneratedColumn<int>(
      'total', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        repairId,
        productId,
        variantId,
        name,
        quantity,
        unitPrice,
        total,
        createdAt
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'repair_parts';
  @override
  VerificationContext validateIntegrity(Insertable<RepairPart> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('repair_id')) {
      context.handle(_repairIdMeta,
          repairId.isAcceptableOrUnknown(data['repair_id']!, _repairIdMeta));
    } else if (isInserting) {
      context.missing(_repairIdMeta);
    }
    if (data.containsKey('product_id')) {
      context.handle(_productIdMeta,
          productId.isAcceptableOrUnknown(data['product_id']!, _productIdMeta));
    }
    if (data.containsKey('variant_id')) {
      context.handle(_variantIdMeta,
          variantId.isAcceptableOrUnknown(data['variant_id']!, _variantIdMeta));
    }
    if (data.containsKey('name')) {
      context.handle(
          _nameMeta, name.isAcceptableOrUnknown(data['name']!, _nameMeta));
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('quantity')) {
      context.handle(_quantityMeta,
          quantity.isAcceptableOrUnknown(data['quantity']!, _quantityMeta));
    }
    if (data.containsKey('unit_price')) {
      context.handle(_unitPriceMeta,
          unitPrice.isAcceptableOrUnknown(data['unit_price']!, _unitPriceMeta));
    } else if (isInserting) {
      context.missing(_unitPriceMeta);
    }
    if (data.containsKey('total')) {
      context.handle(
          _totalMeta, total.isAcceptableOrUnknown(data['total']!, _totalMeta));
    } else if (isInserting) {
      context.missing(_totalMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  RepairPart map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return RepairPart(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      repairId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}repair_id'])!,
      productId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}product_id']),
      variantId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}variant_id']),
      name: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}name'])!,
      quantity: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}quantity'])!,
      unitPrice: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}unit_price'])!,
      total: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}total'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
    );
  }

  @override
  $RepairPartsTable createAlias(String alias) {
    return $RepairPartsTable(attachedDatabase, alias);
  }
}

class RepairPart extends DataClass implements Insertable<RepairPart> {
  final String id;
  final String repairId;
  final String? productId;
  final String? variantId;
  final String name;
  final int quantity;
  final int unitPrice;
  final int total;
  final DateTime createdAt;
  const RepairPart(
      {required this.id,
      required this.repairId,
      this.productId,
      this.variantId,
      required this.name,
      required this.quantity,
      required this.unitPrice,
      required this.total,
      required this.createdAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['repair_id'] = Variable<String>(repairId);
    if (!nullToAbsent || productId != null) {
      map['product_id'] = Variable<String>(productId);
    }
    if (!nullToAbsent || variantId != null) {
      map['variant_id'] = Variable<String>(variantId);
    }
    map['name'] = Variable<String>(name);
    map['quantity'] = Variable<int>(quantity);
    map['unit_price'] = Variable<int>(unitPrice);
    map['total'] = Variable<int>(total);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  RepairPartsCompanion toCompanion(bool nullToAbsent) {
    return RepairPartsCompanion(
      id: Value(id),
      repairId: Value(repairId),
      productId: productId == null && nullToAbsent
          ? const Value.absent()
          : Value(productId),
      variantId: variantId == null && nullToAbsent
          ? const Value.absent()
          : Value(variantId),
      name: Value(name),
      quantity: Value(quantity),
      unitPrice: Value(unitPrice),
      total: Value(total),
      createdAt: Value(createdAt),
    );
  }

  factory RepairPart.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return RepairPart(
      id: serializer.fromJson<String>(json['id']),
      repairId: serializer.fromJson<String>(json['repairId']),
      productId: serializer.fromJson<String?>(json['productId']),
      variantId: serializer.fromJson<String?>(json['variantId']),
      name: serializer.fromJson<String>(json['name']),
      quantity: serializer.fromJson<int>(json['quantity']),
      unitPrice: serializer.fromJson<int>(json['unitPrice']),
      total: serializer.fromJson<int>(json['total']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'repairId': serializer.toJson<String>(repairId),
      'productId': serializer.toJson<String?>(productId),
      'variantId': serializer.toJson<String?>(variantId),
      'name': serializer.toJson<String>(name),
      'quantity': serializer.toJson<int>(quantity),
      'unitPrice': serializer.toJson<int>(unitPrice),
      'total': serializer.toJson<int>(total),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  RepairPart copyWith(
          {String? id,
          String? repairId,
          Value<String?> productId = const Value.absent(),
          Value<String?> variantId = const Value.absent(),
          String? name,
          int? quantity,
          int? unitPrice,
          int? total,
          DateTime? createdAt}) =>
      RepairPart(
        id: id ?? this.id,
        repairId: repairId ?? this.repairId,
        productId: productId.present ? productId.value : this.productId,
        variantId: variantId.present ? variantId.value : this.variantId,
        name: name ?? this.name,
        quantity: quantity ?? this.quantity,
        unitPrice: unitPrice ?? this.unitPrice,
        total: total ?? this.total,
        createdAt: createdAt ?? this.createdAt,
      );
  RepairPart copyWithCompanion(RepairPartsCompanion data) {
    return RepairPart(
      id: data.id.present ? data.id.value : this.id,
      repairId: data.repairId.present ? data.repairId.value : this.repairId,
      productId: data.productId.present ? data.productId.value : this.productId,
      variantId: data.variantId.present ? data.variantId.value : this.variantId,
      name: data.name.present ? data.name.value : this.name,
      quantity: data.quantity.present ? data.quantity.value : this.quantity,
      unitPrice: data.unitPrice.present ? data.unitPrice.value : this.unitPrice,
      total: data.total.present ? data.total.value : this.total,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('RepairPart(')
          ..write('id: $id, ')
          ..write('repairId: $repairId, ')
          ..write('productId: $productId, ')
          ..write('variantId: $variantId, ')
          ..write('name: $name, ')
          ..write('quantity: $quantity, ')
          ..write('unitPrice: $unitPrice, ')
          ..write('total: $total, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, repairId, productId, variantId, name,
      quantity, unitPrice, total, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is RepairPart &&
          other.id == this.id &&
          other.repairId == this.repairId &&
          other.productId == this.productId &&
          other.variantId == this.variantId &&
          other.name == this.name &&
          other.quantity == this.quantity &&
          other.unitPrice == this.unitPrice &&
          other.total == this.total &&
          other.createdAt == this.createdAt);
}

class RepairPartsCompanion extends UpdateCompanion<RepairPart> {
  final Value<String> id;
  final Value<String> repairId;
  final Value<String?> productId;
  final Value<String?> variantId;
  final Value<String> name;
  final Value<int> quantity;
  final Value<int> unitPrice;
  final Value<int> total;
  final Value<DateTime> createdAt;
  final Value<int> rowid;
  const RepairPartsCompanion({
    this.id = const Value.absent(),
    this.repairId = const Value.absent(),
    this.productId = const Value.absent(),
    this.variantId = const Value.absent(),
    this.name = const Value.absent(),
    this.quantity = const Value.absent(),
    this.unitPrice = const Value.absent(),
    this.total = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  RepairPartsCompanion.insert({
    required String id,
    required String repairId,
    this.productId = const Value.absent(),
    this.variantId = const Value.absent(),
    required String name,
    this.quantity = const Value.absent(),
    required int unitPrice,
    required int total,
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        repairId = Value(repairId),
        name = Value(name),
        unitPrice = Value(unitPrice),
        total = Value(total);
  static Insertable<RepairPart> custom({
    Expression<String>? id,
    Expression<String>? repairId,
    Expression<String>? productId,
    Expression<String>? variantId,
    Expression<String>? name,
    Expression<int>? quantity,
    Expression<int>? unitPrice,
    Expression<int>? total,
    Expression<DateTime>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (repairId != null) 'repair_id': repairId,
      if (productId != null) 'product_id': productId,
      if (variantId != null) 'variant_id': variantId,
      if (name != null) 'name': name,
      if (quantity != null) 'quantity': quantity,
      if (unitPrice != null) 'unit_price': unitPrice,
      if (total != null) 'total': total,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  RepairPartsCompanion copyWith(
      {Value<String>? id,
      Value<String>? repairId,
      Value<String?>? productId,
      Value<String?>? variantId,
      Value<String>? name,
      Value<int>? quantity,
      Value<int>? unitPrice,
      Value<int>? total,
      Value<DateTime>? createdAt,
      Value<int>? rowid}) {
    return RepairPartsCompanion(
      id: id ?? this.id,
      repairId: repairId ?? this.repairId,
      productId: productId ?? this.productId,
      variantId: variantId ?? this.variantId,
      name: name ?? this.name,
      quantity: quantity ?? this.quantity,
      unitPrice: unitPrice ?? this.unitPrice,
      total: total ?? this.total,
      createdAt: createdAt ?? this.createdAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (repairId.present) {
      map['repair_id'] = Variable<String>(repairId.value);
    }
    if (productId.present) {
      map['product_id'] = Variable<String>(productId.value);
    }
    if (variantId.present) {
      map['variant_id'] = Variable<String>(variantId.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (quantity.present) {
      map['quantity'] = Variable<int>(quantity.value);
    }
    if (unitPrice.present) {
      map['unit_price'] = Variable<int>(unitPrice.value);
    }
    if (total.present) {
      map['total'] = Variable<int>(total.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('RepairPartsCompanion(')
          ..write('id: $id, ')
          ..write('repairId: $repairId, ')
          ..write('productId: $productId, ')
          ..write('variantId: $variantId, ')
          ..write('name: $name, ')
          ..write('quantity: $quantity, ')
          ..write('unitPrice: $unitPrice, ')
          ..write('total: $total, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ServiceSalesTable extends ServiceSales
    with TableInfo<$ServiceSalesTable, ServiceSale> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ServiceSalesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _serviceTypeMeta =
      const VerificationMeta('serviceType');
  @override
  late final GeneratedColumn<String> serviceType = GeneratedColumn<String>(
      'service_type', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _customerPhoneMeta =
      const VerificationMeta('customerPhone');
  @override
  late final GeneratedColumn<String> customerPhone = GeneratedColumn<String>(
      'customer_phone', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _providerMeta =
      const VerificationMeta('provider');
  @override
  late final GeneratedColumn<String> provider = GeneratedColumn<String>(
      'provider', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _amountMeta = const VerificationMeta('amount');
  @override
  late final GeneratedColumn<int> amount = GeneratedColumn<int>(
      'amount', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _commissionMeta =
      const VerificationMeta('commission');
  @override
  late final GeneratedColumn<int> commission = GeneratedColumn<int>(
      'commission', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _userIdMeta = const VerificationMeta('userId');
  @override
  late final GeneratedColumn<String> userId = GeneratedColumn<String>(
      'user_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _saleDateMeta =
      const VerificationMeta('saleDate');
  @override
  late final GeneratedColumn<DateTime> saleDate = GeneratedColumn<DateTime>(
      'sale_date', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        serviceType,
        customerPhone,
        provider,
        amount,
        commission,
        userId,
        saleDate,
        createdAt
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'service_sales';
  @override
  VerificationContext validateIntegrity(Insertable<ServiceSale> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('service_type')) {
      context.handle(
          _serviceTypeMeta,
          serviceType.isAcceptableOrUnknown(
              data['service_type']!, _serviceTypeMeta));
    } else if (isInserting) {
      context.missing(_serviceTypeMeta);
    }
    if (data.containsKey('customer_phone')) {
      context.handle(
          _customerPhoneMeta,
          customerPhone.isAcceptableOrUnknown(
              data['customer_phone']!, _customerPhoneMeta));
    }
    if (data.containsKey('provider')) {
      context.handle(_providerMeta,
          provider.isAcceptableOrUnknown(data['provider']!, _providerMeta));
    }
    if (data.containsKey('amount')) {
      context.handle(_amountMeta,
          amount.isAcceptableOrUnknown(data['amount']!, _amountMeta));
    } else if (isInserting) {
      context.missing(_amountMeta);
    }
    if (data.containsKey('commission')) {
      context.handle(
          _commissionMeta,
          commission.isAcceptableOrUnknown(
              data['commission']!, _commissionMeta));
    }
    if (data.containsKey('user_id')) {
      context.handle(_userIdMeta,
          userId.isAcceptableOrUnknown(data['user_id']!, _userIdMeta));
    } else if (isInserting) {
      context.missing(_userIdMeta);
    }
    if (data.containsKey('sale_date')) {
      context.handle(_saleDateMeta,
          saleDate.isAcceptableOrUnknown(data['sale_date']!, _saleDateMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ServiceSale map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ServiceSale(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      serviceType: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}service_type'])!,
      customerPhone: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}customer_phone']),
      provider: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}provider']),
      amount: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}amount'])!,
      commission: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}commission'])!,
      userId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}user_id'])!,
      saleDate: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}sale_date'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
    );
  }

  @override
  $ServiceSalesTable createAlias(String alias) {
    return $ServiceSalesTable(attachedDatabase, alias);
  }
}

class ServiceSale extends DataClass implements Insertable<ServiceSale> {
  final String id;
  final String serviceType;
  final String? customerPhone;
  final String? provider;
  final int amount;
  final int commission;
  final String userId;
  final DateTime saleDate;
  final DateTime createdAt;
  const ServiceSale(
      {required this.id,
      required this.serviceType,
      this.customerPhone,
      this.provider,
      required this.amount,
      required this.commission,
      required this.userId,
      required this.saleDate,
      required this.createdAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['service_type'] = Variable<String>(serviceType);
    if (!nullToAbsent || customerPhone != null) {
      map['customer_phone'] = Variable<String>(customerPhone);
    }
    if (!nullToAbsent || provider != null) {
      map['provider'] = Variable<String>(provider);
    }
    map['amount'] = Variable<int>(amount);
    map['commission'] = Variable<int>(commission);
    map['user_id'] = Variable<String>(userId);
    map['sale_date'] = Variable<DateTime>(saleDate);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  ServiceSalesCompanion toCompanion(bool nullToAbsent) {
    return ServiceSalesCompanion(
      id: Value(id),
      serviceType: Value(serviceType),
      customerPhone: customerPhone == null && nullToAbsent
          ? const Value.absent()
          : Value(customerPhone),
      provider: provider == null && nullToAbsent
          ? const Value.absent()
          : Value(provider),
      amount: Value(amount),
      commission: Value(commission),
      userId: Value(userId),
      saleDate: Value(saleDate),
      createdAt: Value(createdAt),
    );
  }

  factory ServiceSale.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ServiceSale(
      id: serializer.fromJson<String>(json['id']),
      serviceType: serializer.fromJson<String>(json['serviceType']),
      customerPhone: serializer.fromJson<String?>(json['customerPhone']),
      provider: serializer.fromJson<String?>(json['provider']),
      amount: serializer.fromJson<int>(json['amount']),
      commission: serializer.fromJson<int>(json['commission']),
      userId: serializer.fromJson<String>(json['userId']),
      saleDate: serializer.fromJson<DateTime>(json['saleDate']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'serviceType': serializer.toJson<String>(serviceType),
      'customerPhone': serializer.toJson<String?>(customerPhone),
      'provider': serializer.toJson<String?>(provider),
      'amount': serializer.toJson<int>(amount),
      'commission': serializer.toJson<int>(commission),
      'userId': serializer.toJson<String>(userId),
      'saleDate': serializer.toJson<DateTime>(saleDate),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  ServiceSale copyWith(
          {String? id,
          String? serviceType,
          Value<String?> customerPhone = const Value.absent(),
          Value<String?> provider = const Value.absent(),
          int? amount,
          int? commission,
          String? userId,
          DateTime? saleDate,
          DateTime? createdAt}) =>
      ServiceSale(
        id: id ?? this.id,
        serviceType: serviceType ?? this.serviceType,
        customerPhone:
            customerPhone.present ? customerPhone.value : this.customerPhone,
        provider: provider.present ? provider.value : this.provider,
        amount: amount ?? this.amount,
        commission: commission ?? this.commission,
        userId: userId ?? this.userId,
        saleDate: saleDate ?? this.saleDate,
        createdAt: createdAt ?? this.createdAt,
      );
  ServiceSale copyWithCompanion(ServiceSalesCompanion data) {
    return ServiceSale(
      id: data.id.present ? data.id.value : this.id,
      serviceType:
          data.serviceType.present ? data.serviceType.value : this.serviceType,
      customerPhone: data.customerPhone.present
          ? data.customerPhone.value
          : this.customerPhone,
      provider: data.provider.present ? data.provider.value : this.provider,
      amount: data.amount.present ? data.amount.value : this.amount,
      commission:
          data.commission.present ? data.commission.value : this.commission,
      userId: data.userId.present ? data.userId.value : this.userId,
      saleDate: data.saleDate.present ? data.saleDate.value : this.saleDate,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ServiceSale(')
          ..write('id: $id, ')
          ..write('serviceType: $serviceType, ')
          ..write('customerPhone: $customerPhone, ')
          ..write('provider: $provider, ')
          ..write('amount: $amount, ')
          ..write('commission: $commission, ')
          ..write('userId: $userId, ')
          ..write('saleDate: $saleDate, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, serviceType, customerPhone, provider,
      amount, commission, userId, saleDate, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ServiceSale &&
          other.id == this.id &&
          other.serviceType == this.serviceType &&
          other.customerPhone == this.customerPhone &&
          other.provider == this.provider &&
          other.amount == this.amount &&
          other.commission == this.commission &&
          other.userId == this.userId &&
          other.saleDate == this.saleDate &&
          other.createdAt == this.createdAt);
}

class ServiceSalesCompanion extends UpdateCompanion<ServiceSale> {
  final Value<String> id;
  final Value<String> serviceType;
  final Value<String?> customerPhone;
  final Value<String?> provider;
  final Value<int> amount;
  final Value<int> commission;
  final Value<String> userId;
  final Value<DateTime> saleDate;
  final Value<DateTime> createdAt;
  final Value<int> rowid;
  const ServiceSalesCompanion({
    this.id = const Value.absent(),
    this.serviceType = const Value.absent(),
    this.customerPhone = const Value.absent(),
    this.provider = const Value.absent(),
    this.amount = const Value.absent(),
    this.commission = const Value.absent(),
    this.userId = const Value.absent(),
    this.saleDate = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ServiceSalesCompanion.insert({
    required String id,
    required String serviceType,
    this.customerPhone = const Value.absent(),
    this.provider = const Value.absent(),
    required int amount,
    this.commission = const Value.absent(),
    required String userId,
    this.saleDate = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        serviceType = Value(serviceType),
        amount = Value(amount),
        userId = Value(userId);
  static Insertable<ServiceSale> custom({
    Expression<String>? id,
    Expression<String>? serviceType,
    Expression<String>? customerPhone,
    Expression<String>? provider,
    Expression<int>? amount,
    Expression<int>? commission,
    Expression<String>? userId,
    Expression<DateTime>? saleDate,
    Expression<DateTime>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (serviceType != null) 'service_type': serviceType,
      if (customerPhone != null) 'customer_phone': customerPhone,
      if (provider != null) 'provider': provider,
      if (amount != null) 'amount': amount,
      if (commission != null) 'commission': commission,
      if (userId != null) 'user_id': userId,
      if (saleDate != null) 'sale_date': saleDate,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ServiceSalesCompanion copyWith(
      {Value<String>? id,
      Value<String>? serviceType,
      Value<String?>? customerPhone,
      Value<String?>? provider,
      Value<int>? amount,
      Value<int>? commission,
      Value<String>? userId,
      Value<DateTime>? saleDate,
      Value<DateTime>? createdAt,
      Value<int>? rowid}) {
    return ServiceSalesCompanion(
      id: id ?? this.id,
      serviceType: serviceType ?? this.serviceType,
      customerPhone: customerPhone ?? this.customerPhone,
      provider: provider ?? this.provider,
      amount: amount ?? this.amount,
      commission: commission ?? this.commission,
      userId: userId ?? this.userId,
      saleDate: saleDate ?? this.saleDate,
      createdAt: createdAt ?? this.createdAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (serviceType.present) {
      map['service_type'] = Variable<String>(serviceType.value);
    }
    if (customerPhone.present) {
      map['customer_phone'] = Variable<String>(customerPhone.value);
    }
    if (provider.present) {
      map['provider'] = Variable<String>(provider.value);
    }
    if (amount.present) {
      map['amount'] = Variable<int>(amount.value);
    }
    if (commission.present) {
      map['commission'] = Variable<int>(commission.value);
    }
    if (userId.present) {
      map['user_id'] = Variable<String>(userId.value);
    }
    if (saleDate.present) {
      map['sale_date'] = Variable<DateTime>(saleDate.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ServiceSalesCompanion(')
          ..write('id: $id, ')
          ..write('serviceType: $serviceType, ')
          ..write('customerPhone: $customerPhone, ')
          ..write('provider: $provider, ')
          ..write('amount: $amount, ')
          ..write('commission: $commission, ')
          ..write('userId: $userId, ')
          ..write('saleDate: $saleDate, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ExpensesTable extends Expenses with TableInfo<$ExpensesTable, Expense> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ExpensesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _branchIdMeta =
      const VerificationMeta('branchId');
  @override
  late final GeneratedColumn<String> branchId = GeneratedColumn<String>(
      'branch_id', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _categoryMeta =
      const VerificationMeta('category');
  @override
  late final GeneratedColumn<String> category = GeneratedColumn<String>(
      'category', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _amountMeta = const VerificationMeta('amount');
  @override
  late final GeneratedColumn<int> amount = GeneratedColumn<int>(
      'amount', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _expenseDateMeta =
      const VerificationMeta('expenseDate');
  @override
  late final GeneratedColumn<DateTime> expenseDate = GeneratedColumn<DateTime>(
      'expense_date', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  static const VerificationMeta _descriptionMeta =
      const VerificationMeta('description');
  @override
  late final GeneratedColumn<String> description = GeneratedColumn<String>(
      'description', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _userIdMeta = const VerificationMeta('userId');
  @override
  late final GeneratedColumn<String> userId = GeneratedColumn<String>(
      'user_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        branchId,
        category,
        amount,
        expenseDate,
        description,
        userId,
        createdAt
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'expenses';
  @override
  VerificationContext validateIntegrity(Insertable<Expense> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('branch_id')) {
      context.handle(_branchIdMeta,
          branchId.isAcceptableOrUnknown(data['branch_id']!, _branchIdMeta));
    }
    if (data.containsKey('category')) {
      context.handle(_categoryMeta,
          category.isAcceptableOrUnknown(data['category']!, _categoryMeta));
    } else if (isInserting) {
      context.missing(_categoryMeta);
    }
    if (data.containsKey('amount')) {
      context.handle(_amountMeta,
          amount.isAcceptableOrUnknown(data['amount']!, _amountMeta));
    } else if (isInserting) {
      context.missing(_amountMeta);
    }
    if (data.containsKey('expense_date')) {
      context.handle(
          _expenseDateMeta,
          expenseDate.isAcceptableOrUnknown(
              data['expense_date']!, _expenseDateMeta));
    }
    if (data.containsKey('description')) {
      context.handle(
          _descriptionMeta,
          description.isAcceptableOrUnknown(
              data['description']!, _descriptionMeta));
    }
    if (data.containsKey('user_id')) {
      context.handle(_userIdMeta,
          userId.isAcceptableOrUnknown(data['user_id']!, _userIdMeta));
    } else if (isInserting) {
      context.missing(_userIdMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Expense map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Expense(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      branchId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}branch_id']),
      category: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}category'])!,
      amount: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}amount'])!,
      expenseDate: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}expense_date'])!,
      description: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}description']),
      userId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}user_id'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
    );
  }

  @override
  $ExpensesTable createAlias(String alias) {
    return $ExpensesTable(attachedDatabase, alias);
  }
}

class Expense extends DataClass implements Insertable<Expense> {
  final String id;
  final String? branchId;
  final String category;
  final int amount;
  final DateTime expenseDate;
  final String? description;
  final String userId;
  final DateTime createdAt;
  const Expense(
      {required this.id,
      this.branchId,
      required this.category,
      required this.amount,
      required this.expenseDate,
      this.description,
      required this.userId,
      required this.createdAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    if (!nullToAbsent || branchId != null) {
      map['branch_id'] = Variable<String>(branchId);
    }
    map['category'] = Variable<String>(category);
    map['amount'] = Variable<int>(amount);
    map['expense_date'] = Variable<DateTime>(expenseDate);
    if (!nullToAbsent || description != null) {
      map['description'] = Variable<String>(description);
    }
    map['user_id'] = Variable<String>(userId);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  ExpensesCompanion toCompanion(bool nullToAbsent) {
    return ExpensesCompanion(
      id: Value(id),
      branchId: branchId == null && nullToAbsent
          ? const Value.absent()
          : Value(branchId),
      category: Value(category),
      amount: Value(amount),
      expenseDate: Value(expenseDate),
      description: description == null && nullToAbsent
          ? const Value.absent()
          : Value(description),
      userId: Value(userId),
      createdAt: Value(createdAt),
    );
  }

  factory Expense.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Expense(
      id: serializer.fromJson<String>(json['id']),
      branchId: serializer.fromJson<String?>(json['branchId']),
      category: serializer.fromJson<String>(json['category']),
      amount: serializer.fromJson<int>(json['amount']),
      expenseDate: serializer.fromJson<DateTime>(json['expenseDate']),
      description: serializer.fromJson<String?>(json['description']),
      userId: serializer.fromJson<String>(json['userId']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'branchId': serializer.toJson<String?>(branchId),
      'category': serializer.toJson<String>(category),
      'amount': serializer.toJson<int>(amount),
      'expenseDate': serializer.toJson<DateTime>(expenseDate),
      'description': serializer.toJson<String?>(description),
      'userId': serializer.toJson<String>(userId),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  Expense copyWith(
          {String? id,
          Value<String?> branchId = const Value.absent(),
          String? category,
          int? amount,
          DateTime? expenseDate,
          Value<String?> description = const Value.absent(),
          String? userId,
          DateTime? createdAt}) =>
      Expense(
        id: id ?? this.id,
        branchId: branchId.present ? branchId.value : this.branchId,
        category: category ?? this.category,
        amount: amount ?? this.amount,
        expenseDate: expenseDate ?? this.expenseDate,
        description: description.present ? description.value : this.description,
        userId: userId ?? this.userId,
        createdAt: createdAt ?? this.createdAt,
      );
  Expense copyWithCompanion(ExpensesCompanion data) {
    return Expense(
      id: data.id.present ? data.id.value : this.id,
      branchId: data.branchId.present ? data.branchId.value : this.branchId,
      category: data.category.present ? data.category.value : this.category,
      amount: data.amount.present ? data.amount.value : this.amount,
      expenseDate:
          data.expenseDate.present ? data.expenseDate.value : this.expenseDate,
      description:
          data.description.present ? data.description.value : this.description,
      userId: data.userId.present ? data.userId.value : this.userId,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Expense(')
          ..write('id: $id, ')
          ..write('branchId: $branchId, ')
          ..write('category: $category, ')
          ..write('amount: $amount, ')
          ..write('expenseDate: $expenseDate, ')
          ..write('description: $description, ')
          ..write('userId: $userId, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, branchId, category, amount, expenseDate,
      description, userId, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Expense &&
          other.id == this.id &&
          other.branchId == this.branchId &&
          other.category == this.category &&
          other.amount == this.amount &&
          other.expenseDate == this.expenseDate &&
          other.description == this.description &&
          other.userId == this.userId &&
          other.createdAt == this.createdAt);
}

class ExpensesCompanion extends UpdateCompanion<Expense> {
  final Value<String> id;
  final Value<String?> branchId;
  final Value<String> category;
  final Value<int> amount;
  final Value<DateTime> expenseDate;
  final Value<String?> description;
  final Value<String> userId;
  final Value<DateTime> createdAt;
  final Value<int> rowid;
  const ExpensesCompanion({
    this.id = const Value.absent(),
    this.branchId = const Value.absent(),
    this.category = const Value.absent(),
    this.amount = const Value.absent(),
    this.expenseDate = const Value.absent(),
    this.description = const Value.absent(),
    this.userId = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ExpensesCompanion.insert({
    required String id,
    this.branchId = const Value.absent(),
    required String category,
    required int amount,
    this.expenseDate = const Value.absent(),
    this.description = const Value.absent(),
    required String userId,
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        category = Value(category),
        amount = Value(amount),
        userId = Value(userId);
  static Insertable<Expense> custom({
    Expression<String>? id,
    Expression<String>? branchId,
    Expression<String>? category,
    Expression<int>? amount,
    Expression<DateTime>? expenseDate,
    Expression<String>? description,
    Expression<String>? userId,
    Expression<DateTime>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (branchId != null) 'branch_id': branchId,
      if (category != null) 'category': category,
      if (amount != null) 'amount': amount,
      if (expenseDate != null) 'expense_date': expenseDate,
      if (description != null) 'description': description,
      if (userId != null) 'user_id': userId,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ExpensesCompanion copyWith(
      {Value<String>? id,
      Value<String?>? branchId,
      Value<String>? category,
      Value<int>? amount,
      Value<DateTime>? expenseDate,
      Value<String?>? description,
      Value<String>? userId,
      Value<DateTime>? createdAt,
      Value<int>? rowid}) {
    return ExpensesCompanion(
      id: id ?? this.id,
      branchId: branchId ?? this.branchId,
      category: category ?? this.category,
      amount: amount ?? this.amount,
      expenseDate: expenseDate ?? this.expenseDate,
      description: description ?? this.description,
      userId: userId ?? this.userId,
      createdAt: createdAt ?? this.createdAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (branchId.present) {
      map['branch_id'] = Variable<String>(branchId.value);
    }
    if (category.present) {
      map['category'] = Variable<String>(category.value);
    }
    if (amount.present) {
      map['amount'] = Variable<int>(amount.value);
    }
    if (expenseDate.present) {
      map['expense_date'] = Variable<DateTime>(expenseDate.value);
    }
    if (description.present) {
      map['description'] = Variable<String>(description.value);
    }
    if (userId.present) {
      map['user_id'] = Variable<String>(userId.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ExpensesCompanion(')
          ..write('id: $id, ')
          ..write('branchId: $branchId, ')
          ..write('category: $category, ')
          ..write('amount: $amount, ')
          ..write('expenseDate: $expenseDate, ')
          ..write('description: $description, ')
          ..write('userId: $userId, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $StaffTable extends Staff with TableInfo<$StaffTable, StaffData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $StaffTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
      'name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _phoneMeta = const VerificationMeta('phone');
  @override
  late final GeneratedColumn<String> phone = GeneratedColumn<String>(
      'phone', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _roleMeta = const VerificationMeta('role');
  @override
  late final GeneratedColumn<String> role = GeneratedColumn<String>(
      'role', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _salaryMeta = const VerificationMeta('salary');
  @override
  late final GeneratedColumn<int> salary = GeneratedColumn<int>(
      'salary', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _isActiveMeta =
      const VerificationMeta('isActive');
  @override
  late final GeneratedColumn<bool> isActive = GeneratedColumn<bool>(
      'is_active', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("is_active" IN (0, 1))'),
      defaultValue: const Constant(true));
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  @override
  List<GeneratedColumn> get $columns =>
      [id, name, phone, role, salary, isActive, createdAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'staff';
  @override
  VerificationContext validateIntegrity(Insertable<StaffData> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
          _nameMeta, name.isAcceptableOrUnknown(data['name']!, _nameMeta));
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('phone')) {
      context.handle(
          _phoneMeta, phone.isAcceptableOrUnknown(data['phone']!, _phoneMeta));
    }
    if (data.containsKey('role')) {
      context.handle(
          _roleMeta, role.isAcceptableOrUnknown(data['role']!, _roleMeta));
    }
    if (data.containsKey('salary')) {
      context.handle(_salaryMeta,
          salary.isAcceptableOrUnknown(data['salary']!, _salaryMeta));
    }
    if (data.containsKey('is_active')) {
      context.handle(_isActiveMeta,
          isActive.isAcceptableOrUnknown(data['is_active']!, _isActiveMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  StaffData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return StaffData(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      name: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}name'])!,
      phone: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}phone']),
      role: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}role']),
      salary: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}salary'])!,
      isActive: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_active'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
    );
  }

  @override
  $StaffTable createAlias(String alias) {
    return $StaffTable(attachedDatabase, alias);
  }
}

class StaffData extends DataClass implements Insertable<StaffData> {
  final String id;
  final String name;
  final String? phone;
  final String? role;
  final int salary;
  final bool isActive;
  final DateTime createdAt;
  const StaffData(
      {required this.id,
      required this.name,
      this.phone,
      this.role,
      required this.salary,
      required this.isActive,
      required this.createdAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    if (!nullToAbsent || phone != null) {
      map['phone'] = Variable<String>(phone);
    }
    if (!nullToAbsent || role != null) {
      map['role'] = Variable<String>(role);
    }
    map['salary'] = Variable<int>(salary);
    map['is_active'] = Variable<bool>(isActive);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  StaffCompanion toCompanion(bool nullToAbsent) {
    return StaffCompanion(
      id: Value(id),
      name: Value(name),
      phone:
          phone == null && nullToAbsent ? const Value.absent() : Value(phone),
      role: role == null && nullToAbsent ? const Value.absent() : Value(role),
      salary: Value(salary),
      isActive: Value(isActive),
      createdAt: Value(createdAt),
    );
  }

  factory StaffData.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return StaffData(
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      phone: serializer.fromJson<String?>(json['phone']),
      role: serializer.fromJson<String?>(json['role']),
      salary: serializer.fromJson<int>(json['salary']),
      isActive: serializer.fromJson<bool>(json['isActive']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
      'phone': serializer.toJson<String?>(phone),
      'role': serializer.toJson<String?>(role),
      'salary': serializer.toJson<int>(salary),
      'isActive': serializer.toJson<bool>(isActive),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  StaffData copyWith(
          {String? id,
          String? name,
          Value<String?> phone = const Value.absent(),
          Value<String?> role = const Value.absent(),
          int? salary,
          bool? isActive,
          DateTime? createdAt}) =>
      StaffData(
        id: id ?? this.id,
        name: name ?? this.name,
        phone: phone.present ? phone.value : this.phone,
        role: role.present ? role.value : this.role,
        salary: salary ?? this.salary,
        isActive: isActive ?? this.isActive,
        createdAt: createdAt ?? this.createdAt,
      );
  StaffData copyWithCompanion(StaffCompanion data) {
    return StaffData(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      phone: data.phone.present ? data.phone.value : this.phone,
      role: data.role.present ? data.role.value : this.role,
      salary: data.salary.present ? data.salary.value : this.salary,
      isActive: data.isActive.present ? data.isActive.value : this.isActive,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('StaffData(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('phone: $phone, ')
          ..write('role: $role, ')
          ..write('salary: $salary, ')
          ..write('isActive: $isActive, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, name, phone, role, salary, isActive, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is StaffData &&
          other.id == this.id &&
          other.name == this.name &&
          other.phone == this.phone &&
          other.role == this.role &&
          other.salary == this.salary &&
          other.isActive == this.isActive &&
          other.createdAt == this.createdAt);
}

class StaffCompanion extends UpdateCompanion<StaffData> {
  final Value<String> id;
  final Value<String> name;
  final Value<String?> phone;
  final Value<String?> role;
  final Value<int> salary;
  final Value<bool> isActive;
  final Value<DateTime> createdAt;
  final Value<int> rowid;
  const StaffCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.phone = const Value.absent(),
    this.role = const Value.absent(),
    this.salary = const Value.absent(),
    this.isActive = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  StaffCompanion.insert({
    required String id,
    required String name,
    this.phone = const Value.absent(),
    this.role = const Value.absent(),
    this.salary = const Value.absent(),
    this.isActive = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        name = Value(name);
  static Insertable<StaffData> custom({
    Expression<String>? id,
    Expression<String>? name,
    Expression<String>? phone,
    Expression<String>? role,
    Expression<int>? salary,
    Expression<bool>? isActive,
    Expression<DateTime>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (phone != null) 'phone': phone,
      if (role != null) 'role': role,
      if (salary != null) 'salary': salary,
      if (isActive != null) 'is_active': isActive,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  StaffCompanion copyWith(
      {Value<String>? id,
      Value<String>? name,
      Value<String?>? phone,
      Value<String?>? role,
      Value<int>? salary,
      Value<bool>? isActive,
      Value<DateTime>? createdAt,
      Value<int>? rowid}) {
    return StaffCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      role: role ?? this.role,
      salary: salary ?? this.salary,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (phone.present) {
      map['phone'] = Variable<String>(phone.value);
    }
    if (role.present) {
      map['role'] = Variable<String>(role.value);
    }
    if (salary.present) {
      map['salary'] = Variable<int>(salary.value);
    }
    if (isActive.present) {
      map['is_active'] = Variable<bool>(isActive.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('StaffCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('phone: $phone, ')
          ..write('role: $role, ')
          ..write('salary: $salary, ')
          ..write('isActive: $isActive, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $SalaryPaymentsTable extends SalaryPayments
    with TableInfo<$SalaryPaymentsTable, SalaryPayment> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SalaryPaymentsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _staffIdMeta =
      const VerificationMeta('staffId');
  @override
  late final GeneratedColumn<String> staffId = GeneratedColumn<String>(
      'staff_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _monthMeta = const VerificationMeta('month');
  @override
  late final GeneratedColumn<String> month = GeneratedColumn<String>(
      'month', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _amountMeta = const VerificationMeta('amount');
  @override
  late final GeneratedColumn<int> amount = GeneratedColumn<int>(
      'amount', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _advanceMeta =
      const VerificationMeta('advance');
  @override
  late final GeneratedColumn<int> advance = GeneratedColumn<int>(
      'advance', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _paidDateMeta =
      const VerificationMeta('paidDate');
  @override
  late final GeneratedColumn<DateTime> paidDate = GeneratedColumn<DateTime>(
      'paid_date', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  static const VerificationMeta _userIdMeta = const VerificationMeta('userId');
  @override
  late final GeneratedColumn<String> userId = GeneratedColumn<String>(
      'user_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _notesMeta = const VerificationMeta('notes');
  @override
  late final GeneratedColumn<String> notes = GeneratedColumn<String>(
      'notes', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  @override
  List<GeneratedColumn> get $columns =>
      [id, staffId, month, amount, advance, paidDate, userId, notes, createdAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'salary_payments';
  @override
  VerificationContext validateIntegrity(Insertable<SalaryPayment> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('staff_id')) {
      context.handle(_staffIdMeta,
          staffId.isAcceptableOrUnknown(data['staff_id']!, _staffIdMeta));
    } else if (isInserting) {
      context.missing(_staffIdMeta);
    }
    if (data.containsKey('month')) {
      context.handle(
          _monthMeta, month.isAcceptableOrUnknown(data['month']!, _monthMeta));
    } else if (isInserting) {
      context.missing(_monthMeta);
    }
    if (data.containsKey('amount')) {
      context.handle(_amountMeta,
          amount.isAcceptableOrUnknown(data['amount']!, _amountMeta));
    } else if (isInserting) {
      context.missing(_amountMeta);
    }
    if (data.containsKey('advance')) {
      context.handle(_advanceMeta,
          advance.isAcceptableOrUnknown(data['advance']!, _advanceMeta));
    }
    if (data.containsKey('paid_date')) {
      context.handle(_paidDateMeta,
          paidDate.isAcceptableOrUnknown(data['paid_date']!, _paidDateMeta));
    }
    if (data.containsKey('user_id')) {
      context.handle(_userIdMeta,
          userId.isAcceptableOrUnknown(data['user_id']!, _userIdMeta));
    } else if (isInserting) {
      context.missing(_userIdMeta);
    }
    if (data.containsKey('notes')) {
      context.handle(
          _notesMeta, notes.isAcceptableOrUnknown(data['notes']!, _notesMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  SalaryPayment map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SalaryPayment(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      staffId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}staff_id'])!,
      month: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}month'])!,
      amount: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}amount'])!,
      advance: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}advance'])!,
      paidDate: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}paid_date'])!,
      userId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}user_id'])!,
      notes: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}notes']),
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
    );
  }

  @override
  $SalaryPaymentsTable createAlias(String alias) {
    return $SalaryPaymentsTable(attachedDatabase, alias);
  }
}

class SalaryPayment extends DataClass implements Insertable<SalaryPayment> {
  final String id;
  final String staffId;
  final String month;
  final int amount;
  final int advance;
  final DateTime paidDate;
  final String userId;
  final String? notes;
  final DateTime createdAt;
  const SalaryPayment(
      {required this.id,
      required this.staffId,
      required this.month,
      required this.amount,
      required this.advance,
      required this.paidDate,
      required this.userId,
      this.notes,
      required this.createdAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['staff_id'] = Variable<String>(staffId);
    map['month'] = Variable<String>(month);
    map['amount'] = Variable<int>(amount);
    map['advance'] = Variable<int>(advance);
    map['paid_date'] = Variable<DateTime>(paidDate);
    map['user_id'] = Variable<String>(userId);
    if (!nullToAbsent || notes != null) {
      map['notes'] = Variable<String>(notes);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  SalaryPaymentsCompanion toCompanion(bool nullToAbsent) {
    return SalaryPaymentsCompanion(
      id: Value(id),
      staffId: Value(staffId),
      month: Value(month),
      amount: Value(amount),
      advance: Value(advance),
      paidDate: Value(paidDate),
      userId: Value(userId),
      notes:
          notes == null && nullToAbsent ? const Value.absent() : Value(notes),
      createdAt: Value(createdAt),
    );
  }

  factory SalaryPayment.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SalaryPayment(
      id: serializer.fromJson<String>(json['id']),
      staffId: serializer.fromJson<String>(json['staffId']),
      month: serializer.fromJson<String>(json['month']),
      amount: serializer.fromJson<int>(json['amount']),
      advance: serializer.fromJson<int>(json['advance']),
      paidDate: serializer.fromJson<DateTime>(json['paidDate']),
      userId: serializer.fromJson<String>(json['userId']),
      notes: serializer.fromJson<String?>(json['notes']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'staffId': serializer.toJson<String>(staffId),
      'month': serializer.toJson<String>(month),
      'amount': serializer.toJson<int>(amount),
      'advance': serializer.toJson<int>(advance),
      'paidDate': serializer.toJson<DateTime>(paidDate),
      'userId': serializer.toJson<String>(userId),
      'notes': serializer.toJson<String?>(notes),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  SalaryPayment copyWith(
          {String? id,
          String? staffId,
          String? month,
          int? amount,
          int? advance,
          DateTime? paidDate,
          String? userId,
          Value<String?> notes = const Value.absent(),
          DateTime? createdAt}) =>
      SalaryPayment(
        id: id ?? this.id,
        staffId: staffId ?? this.staffId,
        month: month ?? this.month,
        amount: amount ?? this.amount,
        advance: advance ?? this.advance,
        paidDate: paidDate ?? this.paidDate,
        userId: userId ?? this.userId,
        notes: notes.present ? notes.value : this.notes,
        createdAt: createdAt ?? this.createdAt,
      );
  SalaryPayment copyWithCompanion(SalaryPaymentsCompanion data) {
    return SalaryPayment(
      id: data.id.present ? data.id.value : this.id,
      staffId: data.staffId.present ? data.staffId.value : this.staffId,
      month: data.month.present ? data.month.value : this.month,
      amount: data.amount.present ? data.amount.value : this.amount,
      advance: data.advance.present ? data.advance.value : this.advance,
      paidDate: data.paidDate.present ? data.paidDate.value : this.paidDate,
      userId: data.userId.present ? data.userId.value : this.userId,
      notes: data.notes.present ? data.notes.value : this.notes,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SalaryPayment(')
          ..write('id: $id, ')
          ..write('staffId: $staffId, ')
          ..write('month: $month, ')
          ..write('amount: $amount, ')
          ..write('advance: $advance, ')
          ..write('paidDate: $paidDate, ')
          ..write('userId: $userId, ')
          ..write('notes: $notes, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id, staffId, month, amount, advance, paidDate, userId, notes, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SalaryPayment &&
          other.id == this.id &&
          other.staffId == this.staffId &&
          other.month == this.month &&
          other.amount == this.amount &&
          other.advance == this.advance &&
          other.paidDate == this.paidDate &&
          other.userId == this.userId &&
          other.notes == this.notes &&
          other.createdAt == this.createdAt);
}

class SalaryPaymentsCompanion extends UpdateCompanion<SalaryPayment> {
  final Value<String> id;
  final Value<String> staffId;
  final Value<String> month;
  final Value<int> amount;
  final Value<int> advance;
  final Value<DateTime> paidDate;
  final Value<String> userId;
  final Value<String?> notes;
  final Value<DateTime> createdAt;
  final Value<int> rowid;
  const SalaryPaymentsCompanion({
    this.id = const Value.absent(),
    this.staffId = const Value.absent(),
    this.month = const Value.absent(),
    this.amount = const Value.absent(),
    this.advance = const Value.absent(),
    this.paidDate = const Value.absent(),
    this.userId = const Value.absent(),
    this.notes = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SalaryPaymentsCompanion.insert({
    required String id,
    required String staffId,
    required String month,
    required int amount,
    this.advance = const Value.absent(),
    this.paidDate = const Value.absent(),
    required String userId,
    this.notes = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        staffId = Value(staffId),
        month = Value(month),
        amount = Value(amount),
        userId = Value(userId);
  static Insertable<SalaryPayment> custom({
    Expression<String>? id,
    Expression<String>? staffId,
    Expression<String>? month,
    Expression<int>? amount,
    Expression<int>? advance,
    Expression<DateTime>? paidDate,
    Expression<String>? userId,
    Expression<String>? notes,
    Expression<DateTime>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (staffId != null) 'staff_id': staffId,
      if (month != null) 'month': month,
      if (amount != null) 'amount': amount,
      if (advance != null) 'advance': advance,
      if (paidDate != null) 'paid_date': paidDate,
      if (userId != null) 'user_id': userId,
      if (notes != null) 'notes': notes,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  SalaryPaymentsCompanion copyWith(
      {Value<String>? id,
      Value<String>? staffId,
      Value<String>? month,
      Value<int>? amount,
      Value<int>? advance,
      Value<DateTime>? paidDate,
      Value<String>? userId,
      Value<String?>? notes,
      Value<DateTime>? createdAt,
      Value<int>? rowid}) {
    return SalaryPaymentsCompanion(
      id: id ?? this.id,
      staffId: staffId ?? this.staffId,
      month: month ?? this.month,
      amount: amount ?? this.amount,
      advance: advance ?? this.advance,
      paidDate: paidDate ?? this.paidDate,
      userId: userId ?? this.userId,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (staffId.present) {
      map['staff_id'] = Variable<String>(staffId.value);
    }
    if (month.present) {
      map['month'] = Variable<String>(month.value);
    }
    if (amount.present) {
      map['amount'] = Variable<int>(amount.value);
    }
    if (advance.present) {
      map['advance'] = Variable<int>(advance.value);
    }
    if (paidDate.present) {
      map['paid_date'] = Variable<DateTime>(paidDate.value);
    }
    if (userId.present) {
      map['user_id'] = Variable<String>(userId.value);
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SalaryPaymentsCompanion(')
          ..write('id: $id, ')
          ..write('staffId: $staffId, ')
          ..write('month: $month, ')
          ..write('amount: $amount, ')
          ..write('advance: $advance, ')
          ..write('paidDate: $paidDate, ')
          ..write('userId: $userId, ')
          ..write('notes: $notes, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $CashRegistersTable extends CashRegisters
    with TableInfo<$CashRegistersTable, CashRegister> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CashRegistersTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _branchIdMeta =
      const VerificationMeta('branchId');
  @override
  late final GeneratedColumn<String> branchId = GeneratedColumn<String>(
      'branch_id', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _registerDateMeta =
      const VerificationMeta('registerDate');
  @override
  late final GeneratedColumn<DateTime> registerDate = GeneratedColumn<DateTime>(
      'register_date', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _openingCashMeta =
      const VerificationMeta('openingCash');
  @override
  late final GeneratedColumn<int> openingCash = GeneratedColumn<int>(
      'opening_cash', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _closingCashMeta =
      const VerificationMeta('closingCash');
  @override
  late final GeneratedColumn<int> closingCash = GeneratedColumn<int>(
      'closing_cash', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _expectedCashMeta =
      const VerificationMeta('expectedCash');
  @override
  late final GeneratedColumn<int> expectedCash = GeneratedColumn<int>(
      'expected_cash', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _differenceMeta =
      const VerificationMeta('difference');
  @override
  late final GeneratedColumn<int> difference = GeneratedColumn<int>(
      'difference', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
      'status', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('open'));
  static const VerificationMeta _openedByMeta =
      const VerificationMeta('openedBy');
  @override
  late final GeneratedColumn<String> openedBy = GeneratedColumn<String>(
      'opened_by', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _closedByMeta =
      const VerificationMeta('closedBy');
  @override
  late final GeneratedColumn<String> closedBy = GeneratedColumn<String>(
      'closed_by', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _notesMeta = const VerificationMeta('notes');
  @override
  late final GeneratedColumn<String> notes = GeneratedColumn<String>(
      'notes', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  static const VerificationMeta _updatedAtMeta =
      const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
      'updated_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        branchId,
        registerDate,
        openingCash,
        closingCash,
        expectedCash,
        difference,
        status,
        openedBy,
        closedBy,
        notes,
        createdAt,
        updatedAt
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'cash_registers';
  @override
  VerificationContext validateIntegrity(Insertable<CashRegister> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('branch_id')) {
      context.handle(_branchIdMeta,
          branchId.isAcceptableOrUnknown(data['branch_id']!, _branchIdMeta));
    }
    if (data.containsKey('register_date')) {
      context.handle(
          _registerDateMeta,
          registerDate.isAcceptableOrUnknown(
              data['register_date']!, _registerDateMeta));
    } else if (isInserting) {
      context.missing(_registerDateMeta);
    }
    if (data.containsKey('opening_cash')) {
      context.handle(
          _openingCashMeta,
          openingCash.isAcceptableOrUnknown(
              data['opening_cash']!, _openingCashMeta));
    }
    if (data.containsKey('closing_cash')) {
      context.handle(
          _closingCashMeta,
          closingCash.isAcceptableOrUnknown(
              data['closing_cash']!, _closingCashMeta));
    }
    if (data.containsKey('expected_cash')) {
      context.handle(
          _expectedCashMeta,
          expectedCash.isAcceptableOrUnknown(
              data['expected_cash']!, _expectedCashMeta));
    }
    if (data.containsKey('difference')) {
      context.handle(
          _differenceMeta,
          difference.isAcceptableOrUnknown(
              data['difference']!, _differenceMeta));
    }
    if (data.containsKey('status')) {
      context.handle(_statusMeta,
          status.isAcceptableOrUnknown(data['status']!, _statusMeta));
    }
    if (data.containsKey('opened_by')) {
      context.handle(_openedByMeta,
          openedBy.isAcceptableOrUnknown(data['opened_by']!, _openedByMeta));
    }
    if (data.containsKey('closed_by')) {
      context.handle(_closedByMeta,
          closedBy.isAcceptableOrUnknown(data['closed_by']!, _closedByMeta));
    }
    if (data.containsKey('notes')) {
      context.handle(
          _notesMeta, notes.isAcceptableOrUnknown(data['notes']!, _notesMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    }
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta,
          updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  CashRegister map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CashRegister(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      branchId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}branch_id']),
      registerDate: attachedDatabase.typeMapping.read(
          DriftSqlType.dateTime, data['${effectivePrefix}register_date'])!,
      openingCash: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}opening_cash'])!,
      closingCash: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}closing_cash']),
      expectedCash: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}expected_cash']),
      difference: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}difference']),
      status: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}status'])!,
      openedBy: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}opened_by']),
      closedBy: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}closed_by']),
      notes: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}notes']),
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}updated_at'])!,
    );
  }

  @override
  $CashRegistersTable createAlias(String alias) {
    return $CashRegistersTable(attachedDatabase, alias);
  }
}

class CashRegister extends DataClass implements Insertable<CashRegister> {
  final String id;
  final String? branchId;
  final DateTime registerDate;
  final int openingCash;
  final int? closingCash;
  final int? expectedCash;
  final int? difference;
  final String status;
  final String? openedBy;
  final String? closedBy;
  final String? notes;
  final DateTime createdAt;
  final DateTime updatedAt;
  const CashRegister(
      {required this.id,
      this.branchId,
      required this.registerDate,
      required this.openingCash,
      this.closingCash,
      this.expectedCash,
      this.difference,
      required this.status,
      this.openedBy,
      this.closedBy,
      this.notes,
      required this.createdAt,
      required this.updatedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    if (!nullToAbsent || branchId != null) {
      map['branch_id'] = Variable<String>(branchId);
    }
    map['register_date'] = Variable<DateTime>(registerDate);
    map['opening_cash'] = Variable<int>(openingCash);
    if (!nullToAbsent || closingCash != null) {
      map['closing_cash'] = Variable<int>(closingCash);
    }
    if (!nullToAbsent || expectedCash != null) {
      map['expected_cash'] = Variable<int>(expectedCash);
    }
    if (!nullToAbsent || difference != null) {
      map['difference'] = Variable<int>(difference);
    }
    map['status'] = Variable<String>(status);
    if (!nullToAbsent || openedBy != null) {
      map['opened_by'] = Variable<String>(openedBy);
    }
    if (!nullToAbsent || closedBy != null) {
      map['closed_by'] = Variable<String>(closedBy);
    }
    if (!nullToAbsent || notes != null) {
      map['notes'] = Variable<String>(notes);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  CashRegistersCompanion toCompanion(bool nullToAbsent) {
    return CashRegistersCompanion(
      id: Value(id),
      branchId: branchId == null && nullToAbsent
          ? const Value.absent()
          : Value(branchId),
      registerDate: Value(registerDate),
      openingCash: Value(openingCash),
      closingCash: closingCash == null && nullToAbsent
          ? const Value.absent()
          : Value(closingCash),
      expectedCash: expectedCash == null && nullToAbsent
          ? const Value.absent()
          : Value(expectedCash),
      difference: difference == null && nullToAbsent
          ? const Value.absent()
          : Value(difference),
      status: Value(status),
      openedBy: openedBy == null && nullToAbsent
          ? const Value.absent()
          : Value(openedBy),
      closedBy: closedBy == null && nullToAbsent
          ? const Value.absent()
          : Value(closedBy),
      notes:
          notes == null && nullToAbsent ? const Value.absent() : Value(notes),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory CashRegister.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CashRegister(
      id: serializer.fromJson<String>(json['id']),
      branchId: serializer.fromJson<String?>(json['branchId']),
      registerDate: serializer.fromJson<DateTime>(json['registerDate']),
      openingCash: serializer.fromJson<int>(json['openingCash']),
      closingCash: serializer.fromJson<int?>(json['closingCash']),
      expectedCash: serializer.fromJson<int?>(json['expectedCash']),
      difference: serializer.fromJson<int?>(json['difference']),
      status: serializer.fromJson<String>(json['status']),
      openedBy: serializer.fromJson<String?>(json['openedBy']),
      closedBy: serializer.fromJson<String?>(json['closedBy']),
      notes: serializer.fromJson<String?>(json['notes']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'branchId': serializer.toJson<String?>(branchId),
      'registerDate': serializer.toJson<DateTime>(registerDate),
      'openingCash': serializer.toJson<int>(openingCash),
      'closingCash': serializer.toJson<int?>(closingCash),
      'expectedCash': serializer.toJson<int?>(expectedCash),
      'difference': serializer.toJson<int?>(difference),
      'status': serializer.toJson<String>(status),
      'openedBy': serializer.toJson<String?>(openedBy),
      'closedBy': serializer.toJson<String?>(closedBy),
      'notes': serializer.toJson<String?>(notes),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  CashRegister copyWith(
          {String? id,
          Value<String?> branchId = const Value.absent(),
          DateTime? registerDate,
          int? openingCash,
          Value<int?> closingCash = const Value.absent(),
          Value<int?> expectedCash = const Value.absent(),
          Value<int?> difference = const Value.absent(),
          String? status,
          Value<String?> openedBy = const Value.absent(),
          Value<String?> closedBy = const Value.absent(),
          Value<String?> notes = const Value.absent(),
          DateTime? createdAt,
          DateTime? updatedAt}) =>
      CashRegister(
        id: id ?? this.id,
        branchId: branchId.present ? branchId.value : this.branchId,
        registerDate: registerDate ?? this.registerDate,
        openingCash: openingCash ?? this.openingCash,
        closingCash: closingCash.present ? closingCash.value : this.closingCash,
        expectedCash:
            expectedCash.present ? expectedCash.value : this.expectedCash,
        difference: difference.present ? difference.value : this.difference,
        status: status ?? this.status,
        openedBy: openedBy.present ? openedBy.value : this.openedBy,
        closedBy: closedBy.present ? closedBy.value : this.closedBy,
        notes: notes.present ? notes.value : this.notes,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
      );
  CashRegister copyWithCompanion(CashRegistersCompanion data) {
    return CashRegister(
      id: data.id.present ? data.id.value : this.id,
      branchId: data.branchId.present ? data.branchId.value : this.branchId,
      registerDate: data.registerDate.present
          ? data.registerDate.value
          : this.registerDate,
      openingCash:
          data.openingCash.present ? data.openingCash.value : this.openingCash,
      closingCash:
          data.closingCash.present ? data.closingCash.value : this.closingCash,
      expectedCash: data.expectedCash.present
          ? data.expectedCash.value
          : this.expectedCash,
      difference:
          data.difference.present ? data.difference.value : this.difference,
      status: data.status.present ? data.status.value : this.status,
      openedBy: data.openedBy.present ? data.openedBy.value : this.openedBy,
      closedBy: data.closedBy.present ? data.closedBy.value : this.closedBy,
      notes: data.notes.present ? data.notes.value : this.notes,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CashRegister(')
          ..write('id: $id, ')
          ..write('branchId: $branchId, ')
          ..write('registerDate: $registerDate, ')
          ..write('openingCash: $openingCash, ')
          ..write('closingCash: $closingCash, ')
          ..write('expectedCash: $expectedCash, ')
          ..write('difference: $difference, ')
          ..write('status: $status, ')
          ..write('openedBy: $openedBy, ')
          ..write('closedBy: $closedBy, ')
          ..write('notes: $notes, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id,
      branchId,
      registerDate,
      openingCash,
      closingCash,
      expectedCash,
      difference,
      status,
      openedBy,
      closedBy,
      notes,
      createdAt,
      updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CashRegister &&
          other.id == this.id &&
          other.branchId == this.branchId &&
          other.registerDate == this.registerDate &&
          other.openingCash == this.openingCash &&
          other.closingCash == this.closingCash &&
          other.expectedCash == this.expectedCash &&
          other.difference == this.difference &&
          other.status == this.status &&
          other.openedBy == this.openedBy &&
          other.closedBy == this.closedBy &&
          other.notes == this.notes &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class CashRegistersCompanion extends UpdateCompanion<CashRegister> {
  final Value<String> id;
  final Value<String?> branchId;
  final Value<DateTime> registerDate;
  final Value<int> openingCash;
  final Value<int?> closingCash;
  final Value<int?> expectedCash;
  final Value<int?> difference;
  final Value<String> status;
  final Value<String?> openedBy;
  final Value<String?> closedBy;
  final Value<String?> notes;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const CashRegistersCompanion({
    this.id = const Value.absent(),
    this.branchId = const Value.absent(),
    this.registerDate = const Value.absent(),
    this.openingCash = const Value.absent(),
    this.closingCash = const Value.absent(),
    this.expectedCash = const Value.absent(),
    this.difference = const Value.absent(),
    this.status = const Value.absent(),
    this.openedBy = const Value.absent(),
    this.closedBy = const Value.absent(),
    this.notes = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  CashRegistersCompanion.insert({
    required String id,
    this.branchId = const Value.absent(),
    required DateTime registerDate,
    this.openingCash = const Value.absent(),
    this.closingCash = const Value.absent(),
    this.expectedCash = const Value.absent(),
    this.difference = const Value.absent(),
    this.status = const Value.absent(),
    this.openedBy = const Value.absent(),
    this.closedBy = const Value.absent(),
    this.notes = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        registerDate = Value(registerDate);
  static Insertable<CashRegister> custom({
    Expression<String>? id,
    Expression<String>? branchId,
    Expression<DateTime>? registerDate,
    Expression<int>? openingCash,
    Expression<int>? closingCash,
    Expression<int>? expectedCash,
    Expression<int>? difference,
    Expression<String>? status,
    Expression<String>? openedBy,
    Expression<String>? closedBy,
    Expression<String>? notes,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (branchId != null) 'branch_id': branchId,
      if (registerDate != null) 'register_date': registerDate,
      if (openingCash != null) 'opening_cash': openingCash,
      if (closingCash != null) 'closing_cash': closingCash,
      if (expectedCash != null) 'expected_cash': expectedCash,
      if (difference != null) 'difference': difference,
      if (status != null) 'status': status,
      if (openedBy != null) 'opened_by': openedBy,
      if (closedBy != null) 'closed_by': closedBy,
      if (notes != null) 'notes': notes,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  CashRegistersCompanion copyWith(
      {Value<String>? id,
      Value<String?>? branchId,
      Value<DateTime>? registerDate,
      Value<int>? openingCash,
      Value<int?>? closingCash,
      Value<int?>? expectedCash,
      Value<int?>? difference,
      Value<String>? status,
      Value<String?>? openedBy,
      Value<String?>? closedBy,
      Value<String?>? notes,
      Value<DateTime>? createdAt,
      Value<DateTime>? updatedAt,
      Value<int>? rowid}) {
    return CashRegistersCompanion(
      id: id ?? this.id,
      branchId: branchId ?? this.branchId,
      registerDate: registerDate ?? this.registerDate,
      openingCash: openingCash ?? this.openingCash,
      closingCash: closingCash ?? this.closingCash,
      expectedCash: expectedCash ?? this.expectedCash,
      difference: difference ?? this.difference,
      status: status ?? this.status,
      openedBy: openedBy ?? this.openedBy,
      closedBy: closedBy ?? this.closedBy,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (branchId.present) {
      map['branch_id'] = Variable<String>(branchId.value);
    }
    if (registerDate.present) {
      map['register_date'] = Variable<DateTime>(registerDate.value);
    }
    if (openingCash.present) {
      map['opening_cash'] = Variable<int>(openingCash.value);
    }
    if (closingCash.present) {
      map['closing_cash'] = Variable<int>(closingCash.value);
    }
    if (expectedCash.present) {
      map['expected_cash'] = Variable<int>(expectedCash.value);
    }
    if (difference.present) {
      map['difference'] = Variable<int>(difference.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (openedBy.present) {
      map['opened_by'] = Variable<String>(openedBy.value);
    }
    if (closedBy.present) {
      map['closed_by'] = Variable<String>(closedBy.value);
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CashRegistersCompanion(')
          ..write('id: $id, ')
          ..write('branchId: $branchId, ')
          ..write('registerDate: $registerDate, ')
          ..write('openingCash: $openingCash, ')
          ..write('closingCash: $closingCash, ')
          ..write('expectedCash: $expectedCash, ')
          ..write('difference: $difference, ')
          ..write('status: $status, ')
          ..write('openedBy: $openedBy, ')
          ..write('closedBy: $closedBy, ')
          ..write('notes: $notes, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $CashMovementsTable extends CashMovements
    with TableInfo<$CashMovementsTable, CashMovement> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CashMovementsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _registerIdMeta =
      const VerificationMeta('registerId');
  @override
  late final GeneratedColumn<String> registerId = GeneratedColumn<String>(
      'register_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _typeMeta = const VerificationMeta('type');
  @override
  late final GeneratedColumn<String> type = GeneratedColumn<String>(
      'type', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _amountMeta = const VerificationMeta('amount');
  @override
  late final GeneratedColumn<int> amount = GeneratedColumn<int>(
      'amount', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _reasonMeta = const VerificationMeta('reason');
  @override
  late final GeneratedColumn<String> reason = GeneratedColumn<String>(
      'reason', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _userIdMeta = const VerificationMeta('userId');
  @override
  late final GeneratedColumn<String> userId = GeneratedColumn<String>(
      'user_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  @override
  List<GeneratedColumn> get $columns =>
      [id, registerId, type, amount, reason, userId, createdAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'cash_movements';
  @override
  VerificationContext validateIntegrity(Insertable<CashMovement> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('register_id')) {
      context.handle(
          _registerIdMeta,
          registerId.isAcceptableOrUnknown(
              data['register_id']!, _registerIdMeta));
    } else if (isInserting) {
      context.missing(_registerIdMeta);
    }
    if (data.containsKey('type')) {
      context.handle(
          _typeMeta, type.isAcceptableOrUnknown(data['type']!, _typeMeta));
    } else if (isInserting) {
      context.missing(_typeMeta);
    }
    if (data.containsKey('amount')) {
      context.handle(_amountMeta,
          amount.isAcceptableOrUnknown(data['amount']!, _amountMeta));
    } else if (isInserting) {
      context.missing(_amountMeta);
    }
    if (data.containsKey('reason')) {
      context.handle(_reasonMeta,
          reason.isAcceptableOrUnknown(data['reason']!, _reasonMeta));
    }
    if (data.containsKey('user_id')) {
      context.handle(_userIdMeta,
          userId.isAcceptableOrUnknown(data['user_id']!, _userIdMeta));
    } else if (isInserting) {
      context.missing(_userIdMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  CashMovement map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CashMovement(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      registerId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}register_id'])!,
      type: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}type'])!,
      amount: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}amount'])!,
      reason: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}reason']),
      userId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}user_id'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
    );
  }

  @override
  $CashMovementsTable createAlias(String alias) {
    return $CashMovementsTable(attachedDatabase, alias);
  }
}

class CashMovement extends DataClass implements Insertable<CashMovement> {
  final String id;
  final String registerId;
  final String type;
  final int amount;
  final String? reason;
  final String userId;
  final DateTime createdAt;
  const CashMovement(
      {required this.id,
      required this.registerId,
      required this.type,
      required this.amount,
      this.reason,
      required this.userId,
      required this.createdAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['register_id'] = Variable<String>(registerId);
    map['type'] = Variable<String>(type);
    map['amount'] = Variable<int>(amount);
    if (!nullToAbsent || reason != null) {
      map['reason'] = Variable<String>(reason);
    }
    map['user_id'] = Variable<String>(userId);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  CashMovementsCompanion toCompanion(bool nullToAbsent) {
    return CashMovementsCompanion(
      id: Value(id),
      registerId: Value(registerId),
      type: Value(type),
      amount: Value(amount),
      reason:
          reason == null && nullToAbsent ? const Value.absent() : Value(reason),
      userId: Value(userId),
      createdAt: Value(createdAt),
    );
  }

  factory CashMovement.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CashMovement(
      id: serializer.fromJson<String>(json['id']),
      registerId: serializer.fromJson<String>(json['registerId']),
      type: serializer.fromJson<String>(json['type']),
      amount: serializer.fromJson<int>(json['amount']),
      reason: serializer.fromJson<String?>(json['reason']),
      userId: serializer.fromJson<String>(json['userId']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'registerId': serializer.toJson<String>(registerId),
      'type': serializer.toJson<String>(type),
      'amount': serializer.toJson<int>(amount),
      'reason': serializer.toJson<String?>(reason),
      'userId': serializer.toJson<String>(userId),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  CashMovement copyWith(
          {String? id,
          String? registerId,
          String? type,
          int? amount,
          Value<String?> reason = const Value.absent(),
          String? userId,
          DateTime? createdAt}) =>
      CashMovement(
        id: id ?? this.id,
        registerId: registerId ?? this.registerId,
        type: type ?? this.type,
        amount: amount ?? this.amount,
        reason: reason.present ? reason.value : this.reason,
        userId: userId ?? this.userId,
        createdAt: createdAt ?? this.createdAt,
      );
  CashMovement copyWithCompanion(CashMovementsCompanion data) {
    return CashMovement(
      id: data.id.present ? data.id.value : this.id,
      registerId:
          data.registerId.present ? data.registerId.value : this.registerId,
      type: data.type.present ? data.type.value : this.type,
      amount: data.amount.present ? data.amount.value : this.amount,
      reason: data.reason.present ? data.reason.value : this.reason,
      userId: data.userId.present ? data.userId.value : this.userId,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CashMovement(')
          ..write('id: $id, ')
          ..write('registerId: $registerId, ')
          ..write('type: $type, ')
          ..write('amount: $amount, ')
          ..write('reason: $reason, ')
          ..write('userId: $userId, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, registerId, type, amount, reason, userId, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CashMovement &&
          other.id == this.id &&
          other.registerId == this.registerId &&
          other.type == this.type &&
          other.amount == this.amount &&
          other.reason == this.reason &&
          other.userId == this.userId &&
          other.createdAt == this.createdAt);
}

class CashMovementsCompanion extends UpdateCompanion<CashMovement> {
  final Value<String> id;
  final Value<String> registerId;
  final Value<String> type;
  final Value<int> amount;
  final Value<String?> reason;
  final Value<String> userId;
  final Value<DateTime> createdAt;
  final Value<int> rowid;
  const CashMovementsCompanion({
    this.id = const Value.absent(),
    this.registerId = const Value.absent(),
    this.type = const Value.absent(),
    this.amount = const Value.absent(),
    this.reason = const Value.absent(),
    this.userId = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  CashMovementsCompanion.insert({
    required String id,
    required String registerId,
    required String type,
    required int amount,
    this.reason = const Value.absent(),
    required String userId,
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        registerId = Value(registerId),
        type = Value(type),
        amount = Value(amount),
        userId = Value(userId);
  static Insertable<CashMovement> custom({
    Expression<String>? id,
    Expression<String>? registerId,
    Expression<String>? type,
    Expression<int>? amount,
    Expression<String>? reason,
    Expression<String>? userId,
    Expression<DateTime>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (registerId != null) 'register_id': registerId,
      if (type != null) 'type': type,
      if (amount != null) 'amount': amount,
      if (reason != null) 'reason': reason,
      if (userId != null) 'user_id': userId,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  CashMovementsCompanion copyWith(
      {Value<String>? id,
      Value<String>? registerId,
      Value<String>? type,
      Value<int>? amount,
      Value<String?>? reason,
      Value<String>? userId,
      Value<DateTime>? createdAt,
      Value<int>? rowid}) {
    return CashMovementsCompanion(
      id: id ?? this.id,
      registerId: registerId ?? this.registerId,
      type: type ?? this.type,
      amount: amount ?? this.amount,
      reason: reason ?? this.reason,
      userId: userId ?? this.userId,
      createdAt: createdAt ?? this.createdAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (registerId.present) {
      map['register_id'] = Variable<String>(registerId.value);
    }
    if (type.present) {
      map['type'] = Variable<String>(type.value);
    }
    if (amount.present) {
      map['amount'] = Variable<int>(amount.value);
    }
    if (reason.present) {
      map['reason'] = Variable<String>(reason.value);
    }
    if (userId.present) {
      map['user_id'] = Variable<String>(userId.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CashMovementsCompanion(')
          ..write('id: $id, ')
          ..write('registerId: $registerId, ')
          ..write('type: $type, ')
          ..write('amount: $amount, ')
          ..write('reason: $reason, ')
          ..write('userId: $userId, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $AuditLogsTable extends AuditLogs
    with TableInfo<$AuditLogsTable, AuditLog> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AuditLogsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _userIdMeta = const VerificationMeta('userId');
  @override
  late final GeneratedColumn<String> userId = GeneratedColumn<String>(
      'user_id', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _actionMeta = const VerificationMeta('action');
  @override
  late final GeneratedColumn<String> action = GeneratedColumn<String>(
      'action', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _entityTypeMeta =
      const VerificationMeta('entityType');
  @override
  late final GeneratedColumn<String> entityType = GeneratedColumn<String>(
      'entity_type', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _entityIdMeta =
      const VerificationMeta('entityId');
  @override
  late final GeneratedColumn<String> entityId = GeneratedColumn<String>(
      'entity_id', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _oldValuesMeta =
      const VerificationMeta('oldValues');
  @override
  late final GeneratedColumn<String> oldValues = GeneratedColumn<String>(
      'old_values', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _newValuesMeta =
      const VerificationMeta('newValues');
  @override
  late final GeneratedColumn<String> newValues = GeneratedColumn<String>(
      'new_values', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _ipAddressMeta =
      const VerificationMeta('ipAddress');
  @override
  late final GeneratedColumn<String> ipAddress = GeneratedColumn<String>(
      'ip_address', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _deviceInfoMeta =
      const VerificationMeta('deviceInfo');
  @override
  late final GeneratedColumn<String> deviceInfo = GeneratedColumn<String>(
      'device_info', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _prevHashMeta =
      const VerificationMeta('prevHash');
  @override
  late final GeneratedColumn<String> prevHash = GeneratedColumn<String>(
      'prev_hash', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant(''));
  static const VerificationMeta _hashMeta = const VerificationMeta('hash');
  @override
  late final GeneratedColumn<String> hash = GeneratedColumn<String>(
      'hash', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant(''));
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        userId,
        action,
        entityType,
        entityId,
        oldValues,
        newValues,
        ipAddress,
        deviceInfo,
        prevHash,
        hash,
        createdAt
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'audit_logs';
  @override
  VerificationContext validateIntegrity(Insertable<AuditLog> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('user_id')) {
      context.handle(_userIdMeta,
          userId.isAcceptableOrUnknown(data['user_id']!, _userIdMeta));
    }
    if (data.containsKey('action')) {
      context.handle(_actionMeta,
          action.isAcceptableOrUnknown(data['action']!, _actionMeta));
    } else if (isInserting) {
      context.missing(_actionMeta);
    }
    if (data.containsKey('entity_type')) {
      context.handle(
          _entityTypeMeta,
          entityType.isAcceptableOrUnknown(
              data['entity_type']!, _entityTypeMeta));
    } else if (isInserting) {
      context.missing(_entityTypeMeta);
    }
    if (data.containsKey('entity_id')) {
      context.handle(_entityIdMeta,
          entityId.isAcceptableOrUnknown(data['entity_id']!, _entityIdMeta));
    }
    if (data.containsKey('old_values')) {
      context.handle(_oldValuesMeta,
          oldValues.isAcceptableOrUnknown(data['old_values']!, _oldValuesMeta));
    }
    if (data.containsKey('new_values')) {
      context.handle(_newValuesMeta,
          newValues.isAcceptableOrUnknown(data['new_values']!, _newValuesMeta));
    }
    if (data.containsKey('ip_address')) {
      context.handle(_ipAddressMeta,
          ipAddress.isAcceptableOrUnknown(data['ip_address']!, _ipAddressMeta));
    }
    if (data.containsKey('device_info')) {
      context.handle(
          _deviceInfoMeta,
          deviceInfo.isAcceptableOrUnknown(
              data['device_info']!, _deviceInfoMeta));
    }
    if (data.containsKey('prev_hash')) {
      context.handle(_prevHashMeta,
          prevHash.isAcceptableOrUnknown(data['prev_hash']!, _prevHashMeta));
    }
    if (data.containsKey('hash')) {
      context.handle(
          _hashMeta, hash.isAcceptableOrUnknown(data['hash']!, _hashMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  AuditLog map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return AuditLog(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      userId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}user_id']),
      action: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}action'])!,
      entityType: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}entity_type'])!,
      entityId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}entity_id']),
      oldValues: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}old_values']),
      newValues: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}new_values']),
      ipAddress: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}ip_address']),
      deviceInfo: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}device_info']),
      prevHash: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}prev_hash'])!,
      hash: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}hash'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
    );
  }

  @override
  $AuditLogsTable createAlias(String alias) {
    return $AuditLogsTable(attachedDatabase, alias);
  }
}

class AuditLog extends DataClass implements Insertable<AuditLog> {
  final String id;
  final String? userId;
  final String action;
  final String entityType;
  final String? entityId;
  final String? oldValues;
  final String? newValues;
  final String? ipAddress;
  final String? deviceInfo;
  final String prevHash;
  final String hash;
  final DateTime createdAt;
  const AuditLog(
      {required this.id,
      this.userId,
      required this.action,
      required this.entityType,
      this.entityId,
      this.oldValues,
      this.newValues,
      this.ipAddress,
      this.deviceInfo,
      required this.prevHash,
      required this.hash,
      required this.createdAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    if (!nullToAbsent || userId != null) {
      map['user_id'] = Variable<String>(userId);
    }
    map['action'] = Variable<String>(action);
    map['entity_type'] = Variable<String>(entityType);
    if (!nullToAbsent || entityId != null) {
      map['entity_id'] = Variable<String>(entityId);
    }
    if (!nullToAbsent || oldValues != null) {
      map['old_values'] = Variable<String>(oldValues);
    }
    if (!nullToAbsent || newValues != null) {
      map['new_values'] = Variable<String>(newValues);
    }
    if (!nullToAbsent || ipAddress != null) {
      map['ip_address'] = Variable<String>(ipAddress);
    }
    if (!nullToAbsent || deviceInfo != null) {
      map['device_info'] = Variable<String>(deviceInfo);
    }
    map['prev_hash'] = Variable<String>(prevHash);
    map['hash'] = Variable<String>(hash);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  AuditLogsCompanion toCompanion(bool nullToAbsent) {
    return AuditLogsCompanion(
      id: Value(id),
      userId:
          userId == null && nullToAbsent ? const Value.absent() : Value(userId),
      action: Value(action),
      entityType: Value(entityType),
      entityId: entityId == null && nullToAbsent
          ? const Value.absent()
          : Value(entityId),
      oldValues: oldValues == null && nullToAbsent
          ? const Value.absent()
          : Value(oldValues),
      newValues: newValues == null && nullToAbsent
          ? const Value.absent()
          : Value(newValues),
      ipAddress: ipAddress == null && nullToAbsent
          ? const Value.absent()
          : Value(ipAddress),
      deviceInfo: deviceInfo == null && nullToAbsent
          ? const Value.absent()
          : Value(deviceInfo),
      prevHash: Value(prevHash),
      hash: Value(hash),
      createdAt: Value(createdAt),
    );
  }

  factory AuditLog.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return AuditLog(
      id: serializer.fromJson<String>(json['id']),
      userId: serializer.fromJson<String?>(json['userId']),
      action: serializer.fromJson<String>(json['action']),
      entityType: serializer.fromJson<String>(json['entityType']),
      entityId: serializer.fromJson<String?>(json['entityId']),
      oldValues: serializer.fromJson<String?>(json['oldValues']),
      newValues: serializer.fromJson<String?>(json['newValues']),
      ipAddress: serializer.fromJson<String?>(json['ipAddress']),
      deviceInfo: serializer.fromJson<String?>(json['deviceInfo']),
      prevHash: serializer.fromJson<String>(json['prevHash']),
      hash: serializer.fromJson<String>(json['hash']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'userId': serializer.toJson<String?>(userId),
      'action': serializer.toJson<String>(action),
      'entityType': serializer.toJson<String>(entityType),
      'entityId': serializer.toJson<String?>(entityId),
      'oldValues': serializer.toJson<String?>(oldValues),
      'newValues': serializer.toJson<String?>(newValues),
      'ipAddress': serializer.toJson<String?>(ipAddress),
      'deviceInfo': serializer.toJson<String?>(deviceInfo),
      'prevHash': serializer.toJson<String>(prevHash),
      'hash': serializer.toJson<String>(hash),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  AuditLog copyWith(
          {String? id,
          Value<String?> userId = const Value.absent(),
          String? action,
          String? entityType,
          Value<String?> entityId = const Value.absent(),
          Value<String?> oldValues = const Value.absent(),
          Value<String?> newValues = const Value.absent(),
          Value<String?> ipAddress = const Value.absent(),
          Value<String?> deviceInfo = const Value.absent(),
          String? prevHash,
          String? hash,
          DateTime? createdAt}) =>
      AuditLog(
        id: id ?? this.id,
        userId: userId.present ? userId.value : this.userId,
        action: action ?? this.action,
        entityType: entityType ?? this.entityType,
        entityId: entityId.present ? entityId.value : this.entityId,
        oldValues: oldValues.present ? oldValues.value : this.oldValues,
        newValues: newValues.present ? newValues.value : this.newValues,
        ipAddress: ipAddress.present ? ipAddress.value : this.ipAddress,
        deviceInfo: deviceInfo.present ? deviceInfo.value : this.deviceInfo,
        prevHash: prevHash ?? this.prevHash,
        hash: hash ?? this.hash,
        createdAt: createdAt ?? this.createdAt,
      );
  AuditLog copyWithCompanion(AuditLogsCompanion data) {
    return AuditLog(
      id: data.id.present ? data.id.value : this.id,
      userId: data.userId.present ? data.userId.value : this.userId,
      action: data.action.present ? data.action.value : this.action,
      entityType:
          data.entityType.present ? data.entityType.value : this.entityType,
      entityId: data.entityId.present ? data.entityId.value : this.entityId,
      oldValues: data.oldValues.present ? data.oldValues.value : this.oldValues,
      newValues: data.newValues.present ? data.newValues.value : this.newValues,
      ipAddress: data.ipAddress.present ? data.ipAddress.value : this.ipAddress,
      deviceInfo:
          data.deviceInfo.present ? data.deviceInfo.value : this.deviceInfo,
      prevHash: data.prevHash.present ? data.prevHash.value : this.prevHash,
      hash: data.hash.present ? data.hash.value : this.hash,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('AuditLog(')
          ..write('id: $id, ')
          ..write('userId: $userId, ')
          ..write('action: $action, ')
          ..write('entityType: $entityType, ')
          ..write('entityId: $entityId, ')
          ..write('oldValues: $oldValues, ')
          ..write('newValues: $newValues, ')
          ..write('ipAddress: $ipAddress, ')
          ..write('deviceInfo: $deviceInfo, ')
          ..write('prevHash: $prevHash, ')
          ..write('hash: $hash, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, userId, action, entityType, entityId,
      oldValues, newValues, ipAddress, deviceInfo, prevHash, hash, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is AuditLog &&
          other.id == this.id &&
          other.userId == this.userId &&
          other.action == this.action &&
          other.entityType == this.entityType &&
          other.entityId == this.entityId &&
          other.oldValues == this.oldValues &&
          other.newValues == this.newValues &&
          other.ipAddress == this.ipAddress &&
          other.deviceInfo == this.deviceInfo &&
          other.prevHash == this.prevHash &&
          other.hash == this.hash &&
          other.createdAt == this.createdAt);
}

class AuditLogsCompanion extends UpdateCompanion<AuditLog> {
  final Value<String> id;
  final Value<String?> userId;
  final Value<String> action;
  final Value<String> entityType;
  final Value<String?> entityId;
  final Value<String?> oldValues;
  final Value<String?> newValues;
  final Value<String?> ipAddress;
  final Value<String?> deviceInfo;
  final Value<String> prevHash;
  final Value<String> hash;
  final Value<DateTime> createdAt;
  final Value<int> rowid;
  const AuditLogsCompanion({
    this.id = const Value.absent(),
    this.userId = const Value.absent(),
    this.action = const Value.absent(),
    this.entityType = const Value.absent(),
    this.entityId = const Value.absent(),
    this.oldValues = const Value.absent(),
    this.newValues = const Value.absent(),
    this.ipAddress = const Value.absent(),
    this.deviceInfo = const Value.absent(),
    this.prevHash = const Value.absent(),
    this.hash = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  AuditLogsCompanion.insert({
    required String id,
    this.userId = const Value.absent(),
    required String action,
    required String entityType,
    this.entityId = const Value.absent(),
    this.oldValues = const Value.absent(),
    this.newValues = const Value.absent(),
    this.ipAddress = const Value.absent(),
    this.deviceInfo = const Value.absent(),
    this.prevHash = const Value.absent(),
    this.hash = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        action = Value(action),
        entityType = Value(entityType);
  static Insertable<AuditLog> custom({
    Expression<String>? id,
    Expression<String>? userId,
    Expression<String>? action,
    Expression<String>? entityType,
    Expression<String>? entityId,
    Expression<String>? oldValues,
    Expression<String>? newValues,
    Expression<String>? ipAddress,
    Expression<String>? deviceInfo,
    Expression<String>? prevHash,
    Expression<String>? hash,
    Expression<DateTime>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (userId != null) 'user_id': userId,
      if (action != null) 'action': action,
      if (entityType != null) 'entity_type': entityType,
      if (entityId != null) 'entity_id': entityId,
      if (oldValues != null) 'old_values': oldValues,
      if (newValues != null) 'new_values': newValues,
      if (ipAddress != null) 'ip_address': ipAddress,
      if (deviceInfo != null) 'device_info': deviceInfo,
      if (prevHash != null) 'prev_hash': prevHash,
      if (hash != null) 'hash': hash,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  AuditLogsCompanion copyWith(
      {Value<String>? id,
      Value<String?>? userId,
      Value<String>? action,
      Value<String>? entityType,
      Value<String?>? entityId,
      Value<String?>? oldValues,
      Value<String?>? newValues,
      Value<String?>? ipAddress,
      Value<String?>? deviceInfo,
      Value<String>? prevHash,
      Value<String>? hash,
      Value<DateTime>? createdAt,
      Value<int>? rowid}) {
    return AuditLogsCompanion(
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
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (userId.present) {
      map['user_id'] = Variable<String>(userId.value);
    }
    if (action.present) {
      map['action'] = Variable<String>(action.value);
    }
    if (entityType.present) {
      map['entity_type'] = Variable<String>(entityType.value);
    }
    if (entityId.present) {
      map['entity_id'] = Variable<String>(entityId.value);
    }
    if (oldValues.present) {
      map['old_values'] = Variable<String>(oldValues.value);
    }
    if (newValues.present) {
      map['new_values'] = Variable<String>(newValues.value);
    }
    if (ipAddress.present) {
      map['ip_address'] = Variable<String>(ipAddress.value);
    }
    if (deviceInfo.present) {
      map['device_info'] = Variable<String>(deviceInfo.value);
    }
    if (prevHash.present) {
      map['prev_hash'] = Variable<String>(prevHash.value);
    }
    if (hash.present) {
      map['hash'] = Variable<String>(hash.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AuditLogsCompanion(')
          ..write('id: $id, ')
          ..write('userId: $userId, ')
          ..write('action: $action, ')
          ..write('entityType: $entityType, ')
          ..write('entityId: $entityId, ')
          ..write('oldValues: $oldValues, ')
          ..write('newValues: $newValues, ')
          ..write('ipAddress: $ipAddress, ')
          ..write('deviceInfo: $deviceInfo, ')
          ..write('prevHash: $prevHash, ')
          ..write('hash: $hash, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $AppSettingsTable extends AppSettings
    with TableInfo<$AppSettingsTable, AppSetting> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AppSettingsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _keyMeta = const VerificationMeta('key');
  @override
  late final GeneratedColumn<String> key = GeneratedColumn<String>(
      'key', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _valueMeta = const VerificationMeta('value');
  @override
  late final GeneratedColumn<String> value = GeneratedColumn<String>(
      'value', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _updatedAtMeta =
      const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
      'updated_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  @override
  List<GeneratedColumn> get $columns => [key, value, updatedAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'settings';
  @override
  VerificationContext validateIntegrity(Insertable<AppSetting> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('key')) {
      context.handle(
          _keyMeta, key.isAcceptableOrUnknown(data['key']!, _keyMeta));
    } else if (isInserting) {
      context.missing(_keyMeta);
    }
    if (data.containsKey('value')) {
      context.handle(
          _valueMeta, value.isAcceptableOrUnknown(data['value']!, _valueMeta));
    } else if (isInserting) {
      context.missing(_valueMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta,
          updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {key};
  @override
  AppSetting map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return AppSetting(
      key: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}key'])!,
      value: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}value'])!,
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}updated_at'])!,
    );
  }

  @override
  $AppSettingsTable createAlias(String alias) {
    return $AppSettingsTable(attachedDatabase, alias);
  }
}

class AppSetting extends DataClass implements Insertable<AppSetting> {
  final String key;
  final String value;
  final DateTime updatedAt;
  const AppSetting(
      {required this.key, required this.value, required this.updatedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['key'] = Variable<String>(key);
    map['value'] = Variable<String>(value);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  AppSettingsCompanion toCompanion(bool nullToAbsent) {
    return AppSettingsCompanion(
      key: Value(key),
      value: Value(value),
      updatedAt: Value(updatedAt),
    );
  }

  factory AppSetting.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return AppSetting(
      key: serializer.fromJson<String>(json['key']),
      value: serializer.fromJson<String>(json['value']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'key': serializer.toJson<String>(key),
      'value': serializer.toJson<String>(value),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  AppSetting copyWith({String? key, String? value, DateTime? updatedAt}) =>
      AppSetting(
        key: key ?? this.key,
        value: value ?? this.value,
        updatedAt: updatedAt ?? this.updatedAt,
      );
  AppSetting copyWithCompanion(AppSettingsCompanion data) {
    return AppSetting(
      key: data.key.present ? data.key.value : this.key,
      value: data.value.present ? data.value.value : this.value,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('AppSetting(')
          ..write('key: $key, ')
          ..write('value: $value, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(key, value, updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is AppSetting &&
          other.key == this.key &&
          other.value == this.value &&
          other.updatedAt == this.updatedAt);
}

class AppSettingsCompanion extends UpdateCompanion<AppSetting> {
  final Value<String> key;
  final Value<String> value;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const AppSettingsCompanion({
    this.key = const Value.absent(),
    this.value = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  AppSettingsCompanion.insert({
    required String key,
    required String value,
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : key = Value(key),
        value = Value(value);
  static Insertable<AppSetting> custom({
    Expression<String>? key,
    Expression<String>? value,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (key != null) 'key': key,
      if (value != null) 'value': value,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  AppSettingsCompanion copyWith(
      {Value<String>? key,
      Value<String>? value,
      Value<DateTime>? updatedAt,
      Value<int>? rowid}) {
    return AppSettingsCompanion(
      key: key ?? this.key,
      value: value ?? this.value,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (key.present) {
      map['key'] = Variable<String>(key.value);
    }
    if (value.present) {
      map['value'] = Variable<String>(value.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AppSettingsCompanion(')
          ..write('key: $key, ')
          ..write('value: $value, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $CountersTable extends Counters with TableInfo<$CountersTable, Counter> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CountersTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _branchIdMeta =
      const VerificationMeta('branchId');
  @override
  late final GeneratedColumn<String> branchId = GeneratedColumn<String>(
      'branch_id', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
      'name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _prefixMeta = const VerificationMeta('prefix');
  @override
  late final GeneratedColumn<String> prefix = GeneratedColumn<String>(
      'prefix', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _lastValueMeta =
      const VerificationMeta('lastValue');
  @override
  late final GeneratedColumn<int> lastValue = GeneratedColumn<int>(
      'last_value', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  @override
  List<GeneratedColumn> get $columns => [branchId, name, prefix, lastValue];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'counters';
  @override
  VerificationContext validateIntegrity(Insertable<Counter> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('branch_id')) {
      context.handle(_branchIdMeta,
          branchId.isAcceptableOrUnknown(data['branch_id']!, _branchIdMeta));
    }
    if (data.containsKey('name')) {
      context.handle(
          _nameMeta, name.isAcceptableOrUnknown(data['name']!, _nameMeta));
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('prefix')) {
      context.handle(_prefixMeta,
          prefix.isAcceptableOrUnknown(data['prefix']!, _prefixMeta));
    } else if (isInserting) {
      context.missing(_prefixMeta);
    }
    if (data.containsKey('last_value')) {
      context.handle(_lastValueMeta,
          lastValue.isAcceptableOrUnknown(data['last_value']!, _lastValueMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {branchId, name};
  @override
  Counter map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Counter(
      branchId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}branch_id']),
      name: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}name'])!,
      prefix: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}prefix'])!,
      lastValue: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}last_value'])!,
    );
  }

  @override
  $CountersTable createAlias(String alias) {
    return $CountersTable(attachedDatabase, alias);
  }
}

class Counter extends DataClass implements Insertable<Counter> {
  final String? branchId;
  final String name;
  final String prefix;
  final int lastValue;
  const Counter(
      {this.branchId,
      required this.name,
      required this.prefix,
      required this.lastValue});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (!nullToAbsent || branchId != null) {
      map['branch_id'] = Variable<String>(branchId);
    }
    map['name'] = Variable<String>(name);
    map['prefix'] = Variable<String>(prefix);
    map['last_value'] = Variable<int>(lastValue);
    return map;
  }

  CountersCompanion toCompanion(bool nullToAbsent) {
    return CountersCompanion(
      branchId: branchId == null && nullToAbsent
          ? const Value.absent()
          : Value(branchId),
      name: Value(name),
      prefix: Value(prefix),
      lastValue: Value(lastValue),
    );
  }

  factory Counter.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Counter(
      branchId: serializer.fromJson<String?>(json['branchId']),
      name: serializer.fromJson<String>(json['name']),
      prefix: serializer.fromJson<String>(json['prefix']),
      lastValue: serializer.fromJson<int>(json['lastValue']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'branchId': serializer.toJson<String?>(branchId),
      'name': serializer.toJson<String>(name),
      'prefix': serializer.toJson<String>(prefix),
      'lastValue': serializer.toJson<int>(lastValue),
    };
  }

  Counter copyWith(
          {Value<String?> branchId = const Value.absent(),
          String? name,
          String? prefix,
          int? lastValue}) =>
      Counter(
        branchId: branchId.present ? branchId.value : this.branchId,
        name: name ?? this.name,
        prefix: prefix ?? this.prefix,
        lastValue: lastValue ?? this.lastValue,
      );
  Counter copyWithCompanion(CountersCompanion data) {
    return Counter(
      branchId: data.branchId.present ? data.branchId.value : this.branchId,
      name: data.name.present ? data.name.value : this.name,
      prefix: data.prefix.present ? data.prefix.value : this.prefix,
      lastValue: data.lastValue.present ? data.lastValue.value : this.lastValue,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Counter(')
          ..write('branchId: $branchId, ')
          ..write('name: $name, ')
          ..write('prefix: $prefix, ')
          ..write('lastValue: $lastValue')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(branchId, name, prefix, lastValue);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Counter &&
          other.branchId == this.branchId &&
          other.name == this.name &&
          other.prefix == this.prefix &&
          other.lastValue == this.lastValue);
}

class CountersCompanion extends UpdateCompanion<Counter> {
  final Value<String?> branchId;
  final Value<String> name;
  final Value<String> prefix;
  final Value<int> lastValue;
  final Value<int> rowid;
  const CountersCompanion({
    this.branchId = const Value.absent(),
    this.name = const Value.absent(),
    this.prefix = const Value.absent(),
    this.lastValue = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  CountersCompanion.insert({
    this.branchId = const Value.absent(),
    required String name,
    required String prefix,
    this.lastValue = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : name = Value(name),
        prefix = Value(prefix);
  static Insertable<Counter> custom({
    Expression<String>? branchId,
    Expression<String>? name,
    Expression<String>? prefix,
    Expression<int>? lastValue,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (branchId != null) 'branch_id': branchId,
      if (name != null) 'name': name,
      if (prefix != null) 'prefix': prefix,
      if (lastValue != null) 'last_value': lastValue,
      if (rowid != null) 'rowid': rowid,
    });
  }

  CountersCompanion copyWith(
      {Value<String?>? branchId,
      Value<String>? name,
      Value<String>? prefix,
      Value<int>? lastValue,
      Value<int>? rowid}) {
    return CountersCompanion(
      branchId: branchId ?? this.branchId,
      name: name ?? this.name,
      prefix: prefix ?? this.prefix,
      lastValue: lastValue ?? this.lastValue,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (branchId.present) {
      map['branch_id'] = Variable<String>(branchId.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (prefix.present) {
      map['prefix'] = Variable<String>(prefix.value);
    }
    if (lastValue.present) {
      map['last_value'] = Variable<int>(lastValue.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CountersCompanion(')
          ..write('branchId: $branchId, ')
          ..write('name: $name, ')
          ..write('prefix: $prefix, ')
          ..write('lastValue: $lastValue, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $SyncLogsTable extends SyncLogs with TableInfo<$SyncLogsTable, SyncLog> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SyncLogsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _deviceIdMeta =
      const VerificationMeta('deviceId');
  @override
  late final GeneratedColumn<String> deviceId = GeneratedColumn<String>(
      'device_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _userIdMeta = const VerificationMeta('userId');
  @override
  late final GeneratedColumn<String> userId = GeneratedColumn<String>(
      'user_id', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _entityTypeMeta =
      const VerificationMeta('entityType');
  @override
  late final GeneratedColumn<String> entityType = GeneratedColumn<String>(
      'entity_type', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _entityIdMeta =
      const VerificationMeta('entityId');
  @override
  late final GeneratedColumn<String> entityId = GeneratedColumn<String>(
      'entity_id', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _actionMeta = const VerificationMeta('action');
  @override
  late final GeneratedColumn<String> action = GeneratedColumn<String>(
      'action', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _detailMeta = const VerificationMeta('detail');
  @override
  late final GeneratedColumn<String> detail = GeneratedColumn<String>(
      'detail', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  @override
  List<GeneratedColumn> get $columns =>
      [id, deviceId, userId, entityType, entityId, action, detail, createdAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'sync_logs';
  @override
  VerificationContext validateIntegrity(Insertable<SyncLog> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('device_id')) {
      context.handle(_deviceIdMeta,
          deviceId.isAcceptableOrUnknown(data['device_id']!, _deviceIdMeta));
    } else if (isInserting) {
      context.missing(_deviceIdMeta);
    }
    if (data.containsKey('user_id')) {
      context.handle(_userIdMeta,
          userId.isAcceptableOrUnknown(data['user_id']!, _userIdMeta));
    }
    if (data.containsKey('entity_type')) {
      context.handle(
          _entityTypeMeta,
          entityType.isAcceptableOrUnknown(
              data['entity_type']!, _entityTypeMeta));
    } else if (isInserting) {
      context.missing(_entityTypeMeta);
    }
    if (data.containsKey('entity_id')) {
      context.handle(_entityIdMeta,
          entityId.isAcceptableOrUnknown(data['entity_id']!, _entityIdMeta));
    }
    if (data.containsKey('action')) {
      context.handle(_actionMeta,
          action.isAcceptableOrUnknown(data['action']!, _actionMeta));
    } else if (isInserting) {
      context.missing(_actionMeta);
    }
    if (data.containsKey('detail')) {
      context.handle(_detailMeta,
          detail.isAcceptableOrUnknown(data['detail']!, _detailMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  SyncLog map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SyncLog(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      deviceId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}device_id'])!,
      userId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}user_id']),
      entityType: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}entity_type'])!,
      entityId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}entity_id']),
      action: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}action'])!,
      detail: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}detail']),
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
    );
  }

  @override
  $SyncLogsTable createAlias(String alias) {
    return $SyncLogsTable(attachedDatabase, alias);
  }
}

class SyncLog extends DataClass implements Insertable<SyncLog> {
  final String id;
  final String deviceId;
  final String? userId;
  final String entityType;
  final String? entityId;
  final String action;
  final String? detail;
  final DateTime createdAt;
  const SyncLog(
      {required this.id,
      required this.deviceId,
      this.userId,
      required this.entityType,
      this.entityId,
      required this.action,
      this.detail,
      required this.createdAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['device_id'] = Variable<String>(deviceId);
    if (!nullToAbsent || userId != null) {
      map['user_id'] = Variable<String>(userId);
    }
    map['entity_type'] = Variable<String>(entityType);
    if (!nullToAbsent || entityId != null) {
      map['entity_id'] = Variable<String>(entityId);
    }
    map['action'] = Variable<String>(action);
    if (!nullToAbsent || detail != null) {
      map['detail'] = Variable<String>(detail);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  SyncLogsCompanion toCompanion(bool nullToAbsent) {
    return SyncLogsCompanion(
      id: Value(id),
      deviceId: Value(deviceId),
      userId:
          userId == null && nullToAbsent ? const Value.absent() : Value(userId),
      entityType: Value(entityType),
      entityId: entityId == null && nullToAbsent
          ? const Value.absent()
          : Value(entityId),
      action: Value(action),
      detail:
          detail == null && nullToAbsent ? const Value.absent() : Value(detail),
      createdAt: Value(createdAt),
    );
  }

  factory SyncLog.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SyncLog(
      id: serializer.fromJson<String>(json['id']),
      deviceId: serializer.fromJson<String>(json['deviceId']),
      userId: serializer.fromJson<String?>(json['userId']),
      entityType: serializer.fromJson<String>(json['entityType']),
      entityId: serializer.fromJson<String?>(json['entityId']),
      action: serializer.fromJson<String>(json['action']),
      detail: serializer.fromJson<String?>(json['detail']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'deviceId': serializer.toJson<String>(deviceId),
      'userId': serializer.toJson<String?>(userId),
      'entityType': serializer.toJson<String>(entityType),
      'entityId': serializer.toJson<String?>(entityId),
      'action': serializer.toJson<String>(action),
      'detail': serializer.toJson<String?>(detail),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  SyncLog copyWith(
          {String? id,
          String? deviceId,
          Value<String?> userId = const Value.absent(),
          String? entityType,
          Value<String?> entityId = const Value.absent(),
          String? action,
          Value<String?> detail = const Value.absent(),
          DateTime? createdAt}) =>
      SyncLog(
        id: id ?? this.id,
        deviceId: deviceId ?? this.deviceId,
        userId: userId.present ? userId.value : this.userId,
        entityType: entityType ?? this.entityType,
        entityId: entityId.present ? entityId.value : this.entityId,
        action: action ?? this.action,
        detail: detail.present ? detail.value : this.detail,
        createdAt: createdAt ?? this.createdAt,
      );
  SyncLog copyWithCompanion(SyncLogsCompanion data) {
    return SyncLog(
      id: data.id.present ? data.id.value : this.id,
      deviceId: data.deviceId.present ? data.deviceId.value : this.deviceId,
      userId: data.userId.present ? data.userId.value : this.userId,
      entityType:
          data.entityType.present ? data.entityType.value : this.entityType,
      entityId: data.entityId.present ? data.entityId.value : this.entityId,
      action: data.action.present ? data.action.value : this.action,
      detail: data.detail.present ? data.detail.value : this.detail,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SyncLog(')
          ..write('id: $id, ')
          ..write('deviceId: $deviceId, ')
          ..write('userId: $userId, ')
          ..write('entityType: $entityType, ')
          ..write('entityId: $entityId, ')
          ..write('action: $action, ')
          ..write('detail: $detail, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id, deviceId, userId, entityType, entityId, action, detail, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SyncLog &&
          other.id == this.id &&
          other.deviceId == this.deviceId &&
          other.userId == this.userId &&
          other.entityType == this.entityType &&
          other.entityId == this.entityId &&
          other.action == this.action &&
          other.detail == this.detail &&
          other.createdAt == this.createdAt);
}

class SyncLogsCompanion extends UpdateCompanion<SyncLog> {
  final Value<String> id;
  final Value<String> deviceId;
  final Value<String?> userId;
  final Value<String> entityType;
  final Value<String?> entityId;
  final Value<String> action;
  final Value<String?> detail;
  final Value<DateTime> createdAt;
  final Value<int> rowid;
  const SyncLogsCompanion({
    this.id = const Value.absent(),
    this.deviceId = const Value.absent(),
    this.userId = const Value.absent(),
    this.entityType = const Value.absent(),
    this.entityId = const Value.absent(),
    this.action = const Value.absent(),
    this.detail = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SyncLogsCompanion.insert({
    required String id,
    required String deviceId,
    this.userId = const Value.absent(),
    required String entityType,
    this.entityId = const Value.absent(),
    required String action,
    this.detail = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        deviceId = Value(deviceId),
        entityType = Value(entityType),
        action = Value(action);
  static Insertable<SyncLog> custom({
    Expression<String>? id,
    Expression<String>? deviceId,
    Expression<String>? userId,
    Expression<String>? entityType,
    Expression<String>? entityId,
    Expression<String>? action,
    Expression<String>? detail,
    Expression<DateTime>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (deviceId != null) 'device_id': deviceId,
      if (userId != null) 'user_id': userId,
      if (entityType != null) 'entity_type': entityType,
      if (entityId != null) 'entity_id': entityId,
      if (action != null) 'action': action,
      if (detail != null) 'detail': detail,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  SyncLogsCompanion copyWith(
      {Value<String>? id,
      Value<String>? deviceId,
      Value<String?>? userId,
      Value<String>? entityType,
      Value<String?>? entityId,
      Value<String>? action,
      Value<String?>? detail,
      Value<DateTime>? createdAt,
      Value<int>? rowid}) {
    return SyncLogsCompanion(
      id: id ?? this.id,
      deviceId: deviceId ?? this.deviceId,
      userId: userId ?? this.userId,
      entityType: entityType ?? this.entityType,
      entityId: entityId ?? this.entityId,
      action: action ?? this.action,
      detail: detail ?? this.detail,
      createdAt: createdAt ?? this.createdAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (deviceId.present) {
      map['device_id'] = Variable<String>(deviceId.value);
    }
    if (userId.present) {
      map['user_id'] = Variable<String>(userId.value);
    }
    if (entityType.present) {
      map['entity_type'] = Variable<String>(entityType.value);
    }
    if (entityId.present) {
      map['entity_id'] = Variable<String>(entityId.value);
    }
    if (action.present) {
      map['action'] = Variable<String>(action.value);
    }
    if (detail.present) {
      map['detail'] = Variable<String>(detail.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SyncLogsCompanion(')
          ..write('id: $id, ')
          ..write('deviceId: $deviceId, ')
          ..write('userId: $userId, ')
          ..write('entityType: $entityType, ')
          ..write('entityId: $entityId, ')
          ..write('action: $action, ')
          ..write('detail: $detail, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $OutboxTable extends Outbox with TableInfo<$OutboxTable, OutboxData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $OutboxTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _clientUuidMeta =
      const VerificationMeta('clientUuid');
  @override
  late final GeneratedColumn<String> clientUuid = GeneratedColumn<String>(
      'client_uuid', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'));
  static const VerificationMeta _entityTableMeta =
      const VerificationMeta('entityTable');
  @override
  late final GeneratedColumn<String> entityTable = GeneratedColumn<String>(
      'table_name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _operationMeta =
      const VerificationMeta('operation');
  @override
  late final GeneratedColumn<String> operation = GeneratedColumn<String>(
      'operation', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _payloadMeta =
      const VerificationMeta('payload');
  @override
  late final GeneratedColumn<String> payload = GeneratedColumn<String>(
      'payload', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _syncedMeta = const VerificationMeta('synced');
  @override
  late final GeneratedColumn<bool> synced = GeneratedColumn<bool>(
      'synced', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("synced" IN (0, 1))'),
      defaultValue: const Constant(false));
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  @override
  List<GeneratedColumn> get $columns =>
      [id, clientUuid, entityTable, operation, payload, synced, createdAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'outbox';
  @override
  VerificationContext validateIntegrity(Insertable<OutboxData> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('client_uuid')) {
      context.handle(
          _clientUuidMeta,
          clientUuid.isAcceptableOrUnknown(
              data['client_uuid']!, _clientUuidMeta));
    } else if (isInserting) {
      context.missing(_clientUuidMeta);
    }
    if (data.containsKey('table_name')) {
      context.handle(
          _entityTableMeta,
          entityTable.isAcceptableOrUnknown(
              data['table_name']!, _entityTableMeta));
    } else if (isInserting) {
      context.missing(_entityTableMeta);
    }
    if (data.containsKey('operation')) {
      context.handle(_operationMeta,
          operation.isAcceptableOrUnknown(data['operation']!, _operationMeta));
    } else if (isInserting) {
      context.missing(_operationMeta);
    }
    if (data.containsKey('payload')) {
      context.handle(_payloadMeta,
          payload.isAcceptableOrUnknown(data['payload']!, _payloadMeta));
    } else if (isInserting) {
      context.missing(_payloadMeta);
    }
    if (data.containsKey('synced')) {
      context.handle(_syncedMeta,
          synced.isAcceptableOrUnknown(data['synced']!, _syncedMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  OutboxData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return OutboxData(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      clientUuid: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}client_uuid'])!,
      entityTable: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}table_name'])!,
      operation: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}operation'])!,
      payload: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}payload'])!,
      synced: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}synced'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
    );
  }

  @override
  $OutboxTable createAlias(String alias) {
    return $OutboxTable(attachedDatabase, alias);
  }
}

class OutboxData extends DataClass implements Insertable<OutboxData> {
  final String id;
  final String clientUuid;
  final String entityTable;
  final String operation;
  final String payload;
  final bool synced;
  final DateTime createdAt;
  const OutboxData(
      {required this.id,
      required this.clientUuid,
      required this.entityTable,
      required this.operation,
      required this.payload,
      required this.synced,
      required this.createdAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['client_uuid'] = Variable<String>(clientUuid);
    map['table_name'] = Variable<String>(entityTable);
    map['operation'] = Variable<String>(operation);
    map['payload'] = Variable<String>(payload);
    map['synced'] = Variable<bool>(synced);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  OutboxCompanion toCompanion(bool nullToAbsent) {
    return OutboxCompanion(
      id: Value(id),
      clientUuid: Value(clientUuid),
      entityTable: Value(entityTable),
      operation: Value(operation),
      payload: Value(payload),
      synced: Value(synced),
      createdAt: Value(createdAt),
    );
  }

  factory OutboxData.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return OutboxData(
      id: serializer.fromJson<String>(json['id']),
      clientUuid: serializer.fromJson<String>(json['clientUuid']),
      entityTable: serializer.fromJson<String>(json['entityTable']),
      operation: serializer.fromJson<String>(json['operation']),
      payload: serializer.fromJson<String>(json['payload']),
      synced: serializer.fromJson<bool>(json['synced']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'clientUuid': serializer.toJson<String>(clientUuid),
      'entityTable': serializer.toJson<String>(entityTable),
      'operation': serializer.toJson<String>(operation),
      'payload': serializer.toJson<String>(payload),
      'synced': serializer.toJson<bool>(synced),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  OutboxData copyWith(
          {String? id,
          String? clientUuid,
          String? entityTable,
          String? operation,
          String? payload,
          bool? synced,
          DateTime? createdAt}) =>
      OutboxData(
        id: id ?? this.id,
        clientUuid: clientUuid ?? this.clientUuid,
        entityTable: entityTable ?? this.entityTable,
        operation: operation ?? this.operation,
        payload: payload ?? this.payload,
        synced: synced ?? this.synced,
        createdAt: createdAt ?? this.createdAt,
      );
  OutboxData copyWithCompanion(OutboxCompanion data) {
    return OutboxData(
      id: data.id.present ? data.id.value : this.id,
      clientUuid:
          data.clientUuid.present ? data.clientUuid.value : this.clientUuid,
      entityTable:
          data.entityTable.present ? data.entityTable.value : this.entityTable,
      operation: data.operation.present ? data.operation.value : this.operation,
      payload: data.payload.present ? data.payload.value : this.payload,
      synced: data.synced.present ? data.synced.value : this.synced,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('OutboxData(')
          ..write('id: $id, ')
          ..write('clientUuid: $clientUuid, ')
          ..write('entityTable: $entityTable, ')
          ..write('operation: $operation, ')
          ..write('payload: $payload, ')
          ..write('synced: $synced, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id, clientUuid, entityTable, operation, payload, synced, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is OutboxData &&
          other.id == this.id &&
          other.clientUuid == this.clientUuid &&
          other.entityTable == this.entityTable &&
          other.operation == this.operation &&
          other.payload == this.payload &&
          other.synced == this.synced &&
          other.createdAt == this.createdAt);
}

class OutboxCompanion extends UpdateCompanion<OutboxData> {
  final Value<String> id;
  final Value<String> clientUuid;
  final Value<String> entityTable;
  final Value<String> operation;
  final Value<String> payload;
  final Value<bool> synced;
  final Value<DateTime> createdAt;
  final Value<int> rowid;
  const OutboxCompanion({
    this.id = const Value.absent(),
    this.clientUuid = const Value.absent(),
    this.entityTable = const Value.absent(),
    this.operation = const Value.absent(),
    this.payload = const Value.absent(),
    this.synced = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  OutboxCompanion.insert({
    required String id,
    required String clientUuid,
    required String entityTable,
    required String operation,
    required String payload,
    this.synced = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        clientUuid = Value(clientUuid),
        entityTable = Value(entityTable),
        operation = Value(operation),
        payload = Value(payload);
  static Insertable<OutboxData> custom({
    Expression<String>? id,
    Expression<String>? clientUuid,
    Expression<String>? entityTable,
    Expression<String>? operation,
    Expression<String>? payload,
    Expression<bool>? synced,
    Expression<DateTime>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (clientUuid != null) 'client_uuid': clientUuid,
      if (entityTable != null) 'table_name': entityTable,
      if (operation != null) 'operation': operation,
      if (payload != null) 'payload': payload,
      if (synced != null) 'synced': synced,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  OutboxCompanion copyWith(
      {Value<String>? id,
      Value<String>? clientUuid,
      Value<String>? entityTable,
      Value<String>? operation,
      Value<String>? payload,
      Value<bool>? synced,
      Value<DateTime>? createdAt,
      Value<int>? rowid}) {
    return OutboxCompanion(
      id: id ?? this.id,
      clientUuid: clientUuid ?? this.clientUuid,
      entityTable: entityTable ?? this.entityTable,
      operation: operation ?? this.operation,
      payload: payload ?? this.payload,
      synced: synced ?? this.synced,
      createdAt: createdAt ?? this.createdAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (clientUuid.present) {
      map['client_uuid'] = Variable<String>(clientUuid.value);
    }
    if (entityTable.present) {
      map['table_name'] = Variable<String>(entityTable.value);
    }
    if (operation.present) {
      map['operation'] = Variable<String>(operation.value);
    }
    if (payload.present) {
      map['payload'] = Variable<String>(payload.value);
    }
    if (synced.present) {
      map['synced'] = Variable<bool>(synced.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('OutboxCompanion(')
          ..write('id: $id, ')
          ..write('clientUuid: $clientUuid, ')
          ..write('entityTable: $entityTable, ')
          ..write('operation: $operation, ')
          ..write('payload: $payload, ')
          ..write('synced: $synced, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $BranchesTable branches = $BranchesTable(this);
  late final $RolesTable roles = $RolesTable(this);
  late final $UsersTable users = $UsersTable(this);
  late final $CategoriesTable categories = $CategoriesTable(this);
  late final $BrandsTable brands = $BrandsTable(this);
  late final $ProductsTable products = $ProductsTable(this);
  late final $ProductVariantsTable productVariants =
      $ProductVariantsTable(this);
  late final $ImeiItemsTable imeiItems = $ImeiItemsTable(this);
  late final $CustomersTable customers = $CustomersTable(this);
  late final $SuppliersTable suppliers = $SuppliersTable(this);
  late final $SalesTable sales = $SalesTable(this);
  late final $SaleItemsTable saleItems = $SaleItemsTable(this);
  late final $SaleReturnsTable saleReturns = $SaleReturnsTable(this);
  late final $HeldBillsTable heldBills = $HeldBillsTable(this);
  late final $PurchasesTable purchases = $PurchasesTable(this);
  late final $PurchaseItemsTable purchaseItems = $PurchaseItemsTable(this);
  late final $PurchaseReturnsTable purchaseReturns =
      $PurchaseReturnsTable(this);
  late final $PaymentsTable payments = $PaymentsTable(this);
  late final $LedgerEntriesTable ledgerEntries = $LedgerEntriesTable(this);
  late final $InstallmentsTable installments = $InstallmentsTable(this);
  late final $InstallmentPaymentsTable installmentPayments =
      $InstallmentPaymentsTable(this);
  late final $RepairsTable repairs = $RepairsTable(this);
  late final $RepairPartsTable repairParts = $RepairPartsTable(this);
  late final $ServiceSalesTable serviceSales = $ServiceSalesTable(this);
  late final $ExpensesTable expenses = $ExpensesTable(this);
  late final $StaffTable staff = $StaffTable(this);
  late final $SalaryPaymentsTable salaryPayments = $SalaryPaymentsTable(this);
  late final $CashRegistersTable cashRegisters = $CashRegistersTable(this);
  late final $CashMovementsTable cashMovements = $CashMovementsTable(this);
  late final $AuditLogsTable auditLogs = $AuditLogsTable(this);
  late final $AppSettingsTable appSettings = $AppSettingsTable(this);
  late final $CountersTable counters = $CountersTable(this);
  late final $SyncLogsTable syncLogs = $SyncLogsTable(this);
  late final $OutboxTable outbox = $OutboxTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
        branches,
        roles,
        users,
        categories,
        brands,
        products,
        productVariants,
        imeiItems,
        customers,
        suppliers,
        sales,
        saleItems,
        saleReturns,
        heldBills,
        purchases,
        purchaseItems,
        purchaseReturns,
        payments,
        ledgerEntries,
        installments,
        installmentPayments,
        repairs,
        repairParts,
        serviceSales,
        expenses,
        staff,
        salaryPayments,
        cashRegisters,
        cashMovements,
        auditLogs,
        appSettings,
        counters,
        syncLogs,
        outbox
      ];
}

typedef $$BranchesTableCreateCompanionBuilder = BranchesCompanion Function({
  required String id,
  required String name,
  Value<String?> address,
  Value<String?> phone,
  Value<bool> isActive,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
  Value<int> rowid,
});
typedef $$BranchesTableUpdateCompanionBuilder = BranchesCompanion Function({
  Value<String> id,
  Value<String> name,
  Value<String?> address,
  Value<String?> phone,
  Value<bool> isActive,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
  Value<int> rowid,
});

class $$BranchesTableFilterComposer
    extends Composer<_$AppDatabase, $BranchesTable> {
  $$BranchesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get address => $composableBuilder(
      column: $table.address, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get phone => $composableBuilder(
      column: $table.phone, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isActive => $composableBuilder(
      column: $table.isActive, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnFilters(column));
}

class $$BranchesTableOrderingComposer
    extends Composer<_$AppDatabase, $BranchesTable> {
  $$BranchesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get address => $composableBuilder(
      column: $table.address, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get phone => $composableBuilder(
      column: $table.phone, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isActive => $composableBuilder(
      column: $table.isActive, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnOrderings(column));
}

class $$BranchesTableAnnotationComposer
    extends Composer<_$AppDatabase, $BranchesTable> {
  $$BranchesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get address =>
      $composableBuilder(column: $table.address, builder: (column) => column);

  GeneratedColumn<String> get phone =>
      $composableBuilder(column: $table.phone, builder: (column) => column);

  GeneratedColumn<bool> get isActive =>
      $composableBuilder(column: $table.isActive, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$BranchesTableTableManager extends RootTableManager<
    _$AppDatabase,
    $BranchesTable,
    Branche,
    $$BranchesTableFilterComposer,
    $$BranchesTableOrderingComposer,
    $$BranchesTableAnnotationComposer,
    $$BranchesTableCreateCompanionBuilder,
    $$BranchesTableUpdateCompanionBuilder,
    (Branche, BaseReferences<_$AppDatabase, $BranchesTable, Branche>),
    Branche,
    PrefetchHooks Function()> {
  $$BranchesTableTableManager(_$AppDatabase db, $BranchesTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$BranchesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$BranchesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$BranchesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> name = const Value.absent(),
            Value<String?> address = const Value.absent(),
            Value<String?> phone = const Value.absent(),
            Value<bool> isActive = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              BranchesCompanion(
            id: id,
            name: name,
            address: address,
            phone: phone,
            isActive: isActive,
            createdAt: createdAt,
            updatedAt: updatedAt,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String name,
            Value<String?> address = const Value.absent(),
            Value<String?> phone = const Value.absent(),
            Value<bool> isActive = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              BranchesCompanion.insert(
            id: id,
            name: name,
            address: address,
            phone: phone,
            isActive: isActive,
            createdAt: createdAt,
            updatedAt: updatedAt,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$BranchesTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $BranchesTable,
    Branche,
    $$BranchesTableFilterComposer,
    $$BranchesTableOrderingComposer,
    $$BranchesTableAnnotationComposer,
    $$BranchesTableCreateCompanionBuilder,
    $$BranchesTableUpdateCompanionBuilder,
    (Branche, BaseReferences<_$AppDatabase, $BranchesTable, Branche>),
    Branche,
    PrefetchHooks Function()>;
typedef $$RolesTableCreateCompanionBuilder = RolesCompanion Function({
  required String id,
  required String name,
  Value<String?> description,
  Value<String> permissions,
  Value<DateTime> createdAt,
  Value<int> rowid,
});
typedef $$RolesTableUpdateCompanionBuilder = RolesCompanion Function({
  Value<String> id,
  Value<String> name,
  Value<String?> description,
  Value<String> permissions,
  Value<DateTime> createdAt,
  Value<int> rowid,
});

class $$RolesTableFilterComposer extends Composer<_$AppDatabase, $RolesTable> {
  $$RolesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get description => $composableBuilder(
      column: $table.description, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get permissions => $composableBuilder(
      column: $table.permissions, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));
}

class $$RolesTableOrderingComposer
    extends Composer<_$AppDatabase, $RolesTable> {
  $$RolesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get description => $composableBuilder(
      column: $table.description, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get permissions => $composableBuilder(
      column: $table.permissions, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));
}

class $$RolesTableAnnotationComposer
    extends Composer<_$AppDatabase, $RolesTable> {
  $$RolesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get description => $composableBuilder(
      column: $table.description, builder: (column) => column);

  GeneratedColumn<String> get permissions => $composableBuilder(
      column: $table.permissions, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$RolesTableTableManager extends RootTableManager<
    _$AppDatabase,
    $RolesTable,
    Role,
    $$RolesTableFilterComposer,
    $$RolesTableOrderingComposer,
    $$RolesTableAnnotationComposer,
    $$RolesTableCreateCompanionBuilder,
    $$RolesTableUpdateCompanionBuilder,
    (Role, BaseReferences<_$AppDatabase, $RolesTable, Role>),
    Role,
    PrefetchHooks Function()> {
  $$RolesTableTableManager(_$AppDatabase db, $RolesTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$RolesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$RolesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$RolesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> name = const Value.absent(),
            Value<String?> description = const Value.absent(),
            Value<String> permissions = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              RolesCompanion(
            id: id,
            name: name,
            description: description,
            permissions: permissions,
            createdAt: createdAt,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String name,
            Value<String?> description = const Value.absent(),
            Value<String> permissions = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              RolesCompanion.insert(
            id: id,
            name: name,
            description: description,
            permissions: permissions,
            createdAt: createdAt,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$RolesTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $RolesTable,
    Role,
    $$RolesTableFilterComposer,
    $$RolesTableOrderingComposer,
    $$RolesTableAnnotationComposer,
    $$RolesTableCreateCompanionBuilder,
    $$RolesTableUpdateCompanionBuilder,
    (Role, BaseReferences<_$AppDatabase, $RolesTable, Role>),
    Role,
    PrefetchHooks Function()>;
typedef $$UsersTableCreateCompanionBuilder = UsersCompanion Function({
  required String id,
  Value<String?> branchId,
  required String roleId,
  required String name,
  required String phone,
  Value<String?> email,
  required String passwordHash,
  Value<bool> isActive,
  Value<DateTime?> lastLoginAt,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
  Value<int> rowid,
});
typedef $$UsersTableUpdateCompanionBuilder = UsersCompanion Function({
  Value<String> id,
  Value<String?> branchId,
  Value<String> roleId,
  Value<String> name,
  Value<String> phone,
  Value<String?> email,
  Value<String> passwordHash,
  Value<bool> isActive,
  Value<DateTime?> lastLoginAt,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
  Value<int> rowid,
});

class $$UsersTableFilterComposer extends Composer<_$AppDatabase, $UsersTable> {
  $$UsersTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get branchId => $composableBuilder(
      column: $table.branchId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get roleId => $composableBuilder(
      column: $table.roleId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get phone => $composableBuilder(
      column: $table.phone, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get email => $composableBuilder(
      column: $table.email, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get passwordHash => $composableBuilder(
      column: $table.passwordHash, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isActive => $composableBuilder(
      column: $table.isActive, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get lastLoginAt => $composableBuilder(
      column: $table.lastLoginAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnFilters(column));
}

class $$UsersTableOrderingComposer
    extends Composer<_$AppDatabase, $UsersTable> {
  $$UsersTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get branchId => $composableBuilder(
      column: $table.branchId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get roleId => $composableBuilder(
      column: $table.roleId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get phone => $composableBuilder(
      column: $table.phone, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get email => $composableBuilder(
      column: $table.email, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get passwordHash => $composableBuilder(
      column: $table.passwordHash,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isActive => $composableBuilder(
      column: $table.isActive, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get lastLoginAt => $composableBuilder(
      column: $table.lastLoginAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnOrderings(column));
}

class $$UsersTableAnnotationComposer
    extends Composer<_$AppDatabase, $UsersTable> {
  $$UsersTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get branchId =>
      $composableBuilder(column: $table.branchId, builder: (column) => column);

  GeneratedColumn<String> get roleId =>
      $composableBuilder(column: $table.roleId, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get phone =>
      $composableBuilder(column: $table.phone, builder: (column) => column);

  GeneratedColumn<String> get email =>
      $composableBuilder(column: $table.email, builder: (column) => column);

  GeneratedColumn<String> get passwordHash => $composableBuilder(
      column: $table.passwordHash, builder: (column) => column);

  GeneratedColumn<bool> get isActive =>
      $composableBuilder(column: $table.isActive, builder: (column) => column);

  GeneratedColumn<DateTime> get lastLoginAt => $composableBuilder(
      column: $table.lastLoginAt, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$UsersTableTableManager extends RootTableManager<
    _$AppDatabase,
    $UsersTable,
    User,
    $$UsersTableFilterComposer,
    $$UsersTableOrderingComposer,
    $$UsersTableAnnotationComposer,
    $$UsersTableCreateCompanionBuilder,
    $$UsersTableUpdateCompanionBuilder,
    (User, BaseReferences<_$AppDatabase, $UsersTable, User>),
    User,
    PrefetchHooks Function()> {
  $$UsersTableTableManager(_$AppDatabase db, $UsersTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$UsersTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$UsersTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$UsersTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String?> branchId = const Value.absent(),
            Value<String> roleId = const Value.absent(),
            Value<String> name = const Value.absent(),
            Value<String> phone = const Value.absent(),
            Value<String?> email = const Value.absent(),
            Value<String> passwordHash = const Value.absent(),
            Value<bool> isActive = const Value.absent(),
            Value<DateTime?> lastLoginAt = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              UsersCompanion(
            id: id,
            branchId: branchId,
            roleId: roleId,
            name: name,
            phone: phone,
            email: email,
            passwordHash: passwordHash,
            isActive: isActive,
            lastLoginAt: lastLoginAt,
            createdAt: createdAt,
            updatedAt: updatedAt,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            Value<String?> branchId = const Value.absent(),
            required String roleId,
            required String name,
            required String phone,
            Value<String?> email = const Value.absent(),
            required String passwordHash,
            Value<bool> isActive = const Value.absent(),
            Value<DateTime?> lastLoginAt = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              UsersCompanion.insert(
            id: id,
            branchId: branchId,
            roleId: roleId,
            name: name,
            phone: phone,
            email: email,
            passwordHash: passwordHash,
            isActive: isActive,
            lastLoginAt: lastLoginAt,
            createdAt: createdAt,
            updatedAt: updatedAt,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$UsersTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $UsersTable,
    User,
    $$UsersTableFilterComposer,
    $$UsersTableOrderingComposer,
    $$UsersTableAnnotationComposer,
    $$UsersTableCreateCompanionBuilder,
    $$UsersTableUpdateCompanionBuilder,
    (User, BaseReferences<_$AppDatabase, $UsersTable, User>),
    User,
    PrefetchHooks Function()>;
typedef $$CategoriesTableCreateCompanionBuilder = CategoriesCompanion Function({
  required String id,
  required String name,
  required String type,
  Value<String?> parentId,
  Value<bool> isActive,
  Value<DateTime> createdAt,
  Value<int> rowid,
});
typedef $$CategoriesTableUpdateCompanionBuilder = CategoriesCompanion Function({
  Value<String> id,
  Value<String> name,
  Value<String> type,
  Value<String?> parentId,
  Value<bool> isActive,
  Value<DateTime> createdAt,
  Value<int> rowid,
});

class $$CategoriesTableFilterComposer
    extends Composer<_$AppDatabase, $CategoriesTable> {
  $$CategoriesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get type => $composableBuilder(
      column: $table.type, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get parentId => $composableBuilder(
      column: $table.parentId, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isActive => $composableBuilder(
      column: $table.isActive, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));
}

class $$CategoriesTableOrderingComposer
    extends Composer<_$AppDatabase, $CategoriesTable> {
  $$CategoriesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get type => $composableBuilder(
      column: $table.type, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get parentId => $composableBuilder(
      column: $table.parentId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isActive => $composableBuilder(
      column: $table.isActive, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));
}

class $$CategoriesTableAnnotationComposer
    extends Composer<_$AppDatabase, $CategoriesTable> {
  $$CategoriesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get type =>
      $composableBuilder(column: $table.type, builder: (column) => column);

  GeneratedColumn<String> get parentId =>
      $composableBuilder(column: $table.parentId, builder: (column) => column);

  GeneratedColumn<bool> get isActive =>
      $composableBuilder(column: $table.isActive, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$CategoriesTableTableManager extends RootTableManager<
    _$AppDatabase,
    $CategoriesTable,
    Category,
    $$CategoriesTableFilterComposer,
    $$CategoriesTableOrderingComposer,
    $$CategoriesTableAnnotationComposer,
    $$CategoriesTableCreateCompanionBuilder,
    $$CategoriesTableUpdateCompanionBuilder,
    (Category, BaseReferences<_$AppDatabase, $CategoriesTable, Category>),
    Category,
    PrefetchHooks Function()> {
  $$CategoriesTableTableManager(_$AppDatabase db, $CategoriesTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CategoriesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CategoriesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CategoriesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> name = const Value.absent(),
            Value<String> type = const Value.absent(),
            Value<String?> parentId = const Value.absent(),
            Value<bool> isActive = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              CategoriesCompanion(
            id: id,
            name: name,
            type: type,
            parentId: parentId,
            isActive: isActive,
            createdAt: createdAt,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String name,
            required String type,
            Value<String?> parentId = const Value.absent(),
            Value<bool> isActive = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              CategoriesCompanion.insert(
            id: id,
            name: name,
            type: type,
            parentId: parentId,
            isActive: isActive,
            createdAt: createdAt,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$CategoriesTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $CategoriesTable,
    Category,
    $$CategoriesTableFilterComposer,
    $$CategoriesTableOrderingComposer,
    $$CategoriesTableAnnotationComposer,
    $$CategoriesTableCreateCompanionBuilder,
    $$CategoriesTableUpdateCompanionBuilder,
    (Category, BaseReferences<_$AppDatabase, $CategoriesTable, Category>),
    Category,
    PrefetchHooks Function()>;
typedef $$BrandsTableCreateCompanionBuilder = BrandsCompanion Function({
  required String id,
  required String name,
  Value<bool> isActive,
  Value<DateTime> createdAt,
  Value<int> rowid,
});
typedef $$BrandsTableUpdateCompanionBuilder = BrandsCompanion Function({
  Value<String> id,
  Value<String> name,
  Value<bool> isActive,
  Value<DateTime> createdAt,
  Value<int> rowid,
});

class $$BrandsTableFilterComposer
    extends Composer<_$AppDatabase, $BrandsTable> {
  $$BrandsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isActive => $composableBuilder(
      column: $table.isActive, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));
}

class $$BrandsTableOrderingComposer
    extends Composer<_$AppDatabase, $BrandsTable> {
  $$BrandsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isActive => $composableBuilder(
      column: $table.isActive, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));
}

class $$BrandsTableAnnotationComposer
    extends Composer<_$AppDatabase, $BrandsTable> {
  $$BrandsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<bool> get isActive =>
      $composableBuilder(column: $table.isActive, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$BrandsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $BrandsTable,
    Brand,
    $$BrandsTableFilterComposer,
    $$BrandsTableOrderingComposer,
    $$BrandsTableAnnotationComposer,
    $$BrandsTableCreateCompanionBuilder,
    $$BrandsTableUpdateCompanionBuilder,
    (Brand, BaseReferences<_$AppDatabase, $BrandsTable, Brand>),
    Brand,
    PrefetchHooks Function()> {
  $$BrandsTableTableManager(_$AppDatabase db, $BrandsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$BrandsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$BrandsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$BrandsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> name = const Value.absent(),
            Value<bool> isActive = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              BrandsCompanion(
            id: id,
            name: name,
            isActive: isActive,
            createdAt: createdAt,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String name,
            Value<bool> isActive = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              BrandsCompanion.insert(
            id: id,
            name: name,
            isActive: isActive,
            createdAt: createdAt,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$BrandsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $BrandsTable,
    Brand,
    $$BrandsTableFilterComposer,
    $$BrandsTableOrderingComposer,
    $$BrandsTableAnnotationComposer,
    $$BrandsTableCreateCompanionBuilder,
    $$BrandsTableUpdateCompanionBuilder,
    (Brand, BaseReferences<_$AppDatabase, $BrandsTable, Brand>),
    Brand,
    PrefetchHooks Function()>;
typedef $$ProductsTableCreateCompanionBuilder = ProductsCompanion Function({
  required String id,
  Value<String?> brandId,
  Value<String?> categoryId,
  required String type,
  required String name,
  Value<String?> description,
  Value<String?> barcode,
  Value<String?> imageUrl,
  Value<bool> isActive,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
  Value<int> rowid,
});
typedef $$ProductsTableUpdateCompanionBuilder = ProductsCompanion Function({
  Value<String> id,
  Value<String?> brandId,
  Value<String?> categoryId,
  Value<String> type,
  Value<String> name,
  Value<String?> description,
  Value<String?> barcode,
  Value<String?> imageUrl,
  Value<bool> isActive,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
  Value<int> rowid,
});

class $$ProductsTableFilterComposer
    extends Composer<_$AppDatabase, $ProductsTable> {
  $$ProductsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get brandId => $composableBuilder(
      column: $table.brandId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get categoryId => $composableBuilder(
      column: $table.categoryId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get type => $composableBuilder(
      column: $table.type, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get description => $composableBuilder(
      column: $table.description, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get barcode => $composableBuilder(
      column: $table.barcode, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get imageUrl => $composableBuilder(
      column: $table.imageUrl, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isActive => $composableBuilder(
      column: $table.isActive, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnFilters(column));
}

class $$ProductsTableOrderingComposer
    extends Composer<_$AppDatabase, $ProductsTable> {
  $$ProductsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get brandId => $composableBuilder(
      column: $table.brandId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get categoryId => $composableBuilder(
      column: $table.categoryId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get type => $composableBuilder(
      column: $table.type, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get description => $composableBuilder(
      column: $table.description, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get barcode => $composableBuilder(
      column: $table.barcode, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get imageUrl => $composableBuilder(
      column: $table.imageUrl, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isActive => $composableBuilder(
      column: $table.isActive, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnOrderings(column));
}

class $$ProductsTableAnnotationComposer
    extends Composer<_$AppDatabase, $ProductsTable> {
  $$ProductsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get brandId =>
      $composableBuilder(column: $table.brandId, builder: (column) => column);

  GeneratedColumn<String> get categoryId => $composableBuilder(
      column: $table.categoryId, builder: (column) => column);

  GeneratedColumn<String> get type =>
      $composableBuilder(column: $table.type, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get description => $composableBuilder(
      column: $table.description, builder: (column) => column);

  GeneratedColumn<String> get barcode =>
      $composableBuilder(column: $table.barcode, builder: (column) => column);

  GeneratedColumn<String> get imageUrl =>
      $composableBuilder(column: $table.imageUrl, builder: (column) => column);

  GeneratedColumn<bool> get isActive =>
      $composableBuilder(column: $table.isActive, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$ProductsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $ProductsTable,
    Product,
    $$ProductsTableFilterComposer,
    $$ProductsTableOrderingComposer,
    $$ProductsTableAnnotationComposer,
    $$ProductsTableCreateCompanionBuilder,
    $$ProductsTableUpdateCompanionBuilder,
    (Product, BaseReferences<_$AppDatabase, $ProductsTable, Product>),
    Product,
    PrefetchHooks Function()> {
  $$ProductsTableTableManager(_$AppDatabase db, $ProductsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ProductsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ProductsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ProductsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String?> brandId = const Value.absent(),
            Value<String?> categoryId = const Value.absent(),
            Value<String> type = const Value.absent(),
            Value<String> name = const Value.absent(),
            Value<String?> description = const Value.absent(),
            Value<String?> barcode = const Value.absent(),
            Value<String?> imageUrl = const Value.absent(),
            Value<bool> isActive = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              ProductsCompanion(
            id: id,
            brandId: brandId,
            categoryId: categoryId,
            type: type,
            name: name,
            description: description,
            barcode: barcode,
            imageUrl: imageUrl,
            isActive: isActive,
            createdAt: createdAt,
            updatedAt: updatedAt,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            Value<String?> brandId = const Value.absent(),
            Value<String?> categoryId = const Value.absent(),
            required String type,
            required String name,
            Value<String?> description = const Value.absent(),
            Value<String?> barcode = const Value.absent(),
            Value<String?> imageUrl = const Value.absent(),
            Value<bool> isActive = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              ProductsCompanion.insert(
            id: id,
            brandId: brandId,
            categoryId: categoryId,
            type: type,
            name: name,
            description: description,
            barcode: barcode,
            imageUrl: imageUrl,
            isActive: isActive,
            createdAt: createdAt,
            updatedAt: updatedAt,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$ProductsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $ProductsTable,
    Product,
    $$ProductsTableFilterComposer,
    $$ProductsTableOrderingComposer,
    $$ProductsTableAnnotationComposer,
    $$ProductsTableCreateCompanionBuilder,
    $$ProductsTableUpdateCompanionBuilder,
    (Product, BaseReferences<_$AppDatabase, $ProductsTable, Product>),
    Product,
    PrefetchHooks Function()>;
typedef $$ProductVariantsTableCreateCompanionBuilder = ProductVariantsCompanion
    Function({
  required String id,
  required String productId,
  required String name,
  Value<String?> color,
  Value<int?> storageGb,
  Value<int?> ramGb,
  Value<String> condition,
  Value<String> ptaStatus,
  Value<String?> barcode,
  Value<int> purchasePrice,
  Value<int> salePrice,
  Value<int> minPrice,
  Value<int> warrantyMonths,
  Value<int> quantity,
  Value<int> lowStockThreshold,
  Value<bool> isActive,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
  Value<int> rowid,
});
typedef $$ProductVariantsTableUpdateCompanionBuilder = ProductVariantsCompanion
    Function({
  Value<String> id,
  Value<String> productId,
  Value<String> name,
  Value<String?> color,
  Value<int?> storageGb,
  Value<int?> ramGb,
  Value<String> condition,
  Value<String> ptaStatus,
  Value<String?> barcode,
  Value<int> purchasePrice,
  Value<int> salePrice,
  Value<int> minPrice,
  Value<int> warrantyMonths,
  Value<int> quantity,
  Value<int> lowStockThreshold,
  Value<bool> isActive,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
  Value<int> rowid,
});

class $$ProductVariantsTableFilterComposer
    extends Composer<_$AppDatabase, $ProductVariantsTable> {
  $$ProductVariantsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get productId => $composableBuilder(
      column: $table.productId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get color => $composableBuilder(
      column: $table.color, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get storageGb => $composableBuilder(
      column: $table.storageGb, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get ramGb => $composableBuilder(
      column: $table.ramGb, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get condition => $composableBuilder(
      column: $table.condition, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get ptaStatus => $composableBuilder(
      column: $table.ptaStatus, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get barcode => $composableBuilder(
      column: $table.barcode, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get purchasePrice => $composableBuilder(
      column: $table.purchasePrice, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get salePrice => $composableBuilder(
      column: $table.salePrice, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get minPrice => $composableBuilder(
      column: $table.minPrice, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get warrantyMonths => $composableBuilder(
      column: $table.warrantyMonths,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get quantity => $composableBuilder(
      column: $table.quantity, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get lowStockThreshold => $composableBuilder(
      column: $table.lowStockThreshold,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isActive => $composableBuilder(
      column: $table.isActive, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnFilters(column));
}

class $$ProductVariantsTableOrderingComposer
    extends Composer<_$AppDatabase, $ProductVariantsTable> {
  $$ProductVariantsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get productId => $composableBuilder(
      column: $table.productId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get color => $composableBuilder(
      column: $table.color, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get storageGb => $composableBuilder(
      column: $table.storageGb, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get ramGb => $composableBuilder(
      column: $table.ramGb, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get condition => $composableBuilder(
      column: $table.condition, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get ptaStatus => $composableBuilder(
      column: $table.ptaStatus, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get barcode => $composableBuilder(
      column: $table.barcode, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get purchasePrice => $composableBuilder(
      column: $table.purchasePrice,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get salePrice => $composableBuilder(
      column: $table.salePrice, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get minPrice => $composableBuilder(
      column: $table.minPrice, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get warrantyMonths => $composableBuilder(
      column: $table.warrantyMonths,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get quantity => $composableBuilder(
      column: $table.quantity, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get lowStockThreshold => $composableBuilder(
      column: $table.lowStockThreshold,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isActive => $composableBuilder(
      column: $table.isActive, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnOrderings(column));
}

class $$ProductVariantsTableAnnotationComposer
    extends Composer<_$AppDatabase, $ProductVariantsTable> {
  $$ProductVariantsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get productId =>
      $composableBuilder(column: $table.productId, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get color =>
      $composableBuilder(column: $table.color, builder: (column) => column);

  GeneratedColumn<int> get storageGb =>
      $composableBuilder(column: $table.storageGb, builder: (column) => column);

  GeneratedColumn<int> get ramGb =>
      $composableBuilder(column: $table.ramGb, builder: (column) => column);

  GeneratedColumn<String> get condition =>
      $composableBuilder(column: $table.condition, builder: (column) => column);

  GeneratedColumn<String> get ptaStatus =>
      $composableBuilder(column: $table.ptaStatus, builder: (column) => column);

  GeneratedColumn<String> get barcode =>
      $composableBuilder(column: $table.barcode, builder: (column) => column);

  GeneratedColumn<int> get purchasePrice => $composableBuilder(
      column: $table.purchasePrice, builder: (column) => column);

  GeneratedColumn<int> get salePrice =>
      $composableBuilder(column: $table.salePrice, builder: (column) => column);

  GeneratedColumn<int> get minPrice =>
      $composableBuilder(column: $table.minPrice, builder: (column) => column);

  GeneratedColumn<int> get warrantyMonths => $composableBuilder(
      column: $table.warrantyMonths, builder: (column) => column);

  GeneratedColumn<int> get quantity =>
      $composableBuilder(column: $table.quantity, builder: (column) => column);

  GeneratedColumn<int> get lowStockThreshold => $composableBuilder(
      column: $table.lowStockThreshold, builder: (column) => column);

  GeneratedColumn<bool> get isActive =>
      $composableBuilder(column: $table.isActive, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$ProductVariantsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $ProductVariantsTable,
    ProductVariant,
    $$ProductVariantsTableFilterComposer,
    $$ProductVariantsTableOrderingComposer,
    $$ProductVariantsTableAnnotationComposer,
    $$ProductVariantsTableCreateCompanionBuilder,
    $$ProductVariantsTableUpdateCompanionBuilder,
    (
      ProductVariant,
      BaseReferences<_$AppDatabase, $ProductVariantsTable, ProductVariant>
    ),
    ProductVariant,
    PrefetchHooks Function()> {
  $$ProductVariantsTableTableManager(
      _$AppDatabase db, $ProductVariantsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ProductVariantsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ProductVariantsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ProductVariantsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> productId = const Value.absent(),
            Value<String> name = const Value.absent(),
            Value<String?> color = const Value.absent(),
            Value<int?> storageGb = const Value.absent(),
            Value<int?> ramGb = const Value.absent(),
            Value<String> condition = const Value.absent(),
            Value<String> ptaStatus = const Value.absent(),
            Value<String?> barcode = const Value.absent(),
            Value<int> purchasePrice = const Value.absent(),
            Value<int> salePrice = const Value.absent(),
            Value<int> minPrice = const Value.absent(),
            Value<int> warrantyMonths = const Value.absent(),
            Value<int> quantity = const Value.absent(),
            Value<int> lowStockThreshold = const Value.absent(),
            Value<bool> isActive = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              ProductVariantsCompanion(
            id: id,
            productId: productId,
            name: name,
            color: color,
            storageGb: storageGb,
            ramGb: ramGb,
            condition: condition,
            ptaStatus: ptaStatus,
            barcode: barcode,
            purchasePrice: purchasePrice,
            salePrice: salePrice,
            minPrice: minPrice,
            warrantyMonths: warrantyMonths,
            quantity: quantity,
            lowStockThreshold: lowStockThreshold,
            isActive: isActive,
            createdAt: createdAt,
            updatedAt: updatedAt,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String productId,
            required String name,
            Value<String?> color = const Value.absent(),
            Value<int?> storageGb = const Value.absent(),
            Value<int?> ramGb = const Value.absent(),
            Value<String> condition = const Value.absent(),
            Value<String> ptaStatus = const Value.absent(),
            Value<String?> barcode = const Value.absent(),
            Value<int> purchasePrice = const Value.absent(),
            Value<int> salePrice = const Value.absent(),
            Value<int> minPrice = const Value.absent(),
            Value<int> warrantyMonths = const Value.absent(),
            Value<int> quantity = const Value.absent(),
            Value<int> lowStockThreshold = const Value.absent(),
            Value<bool> isActive = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              ProductVariantsCompanion.insert(
            id: id,
            productId: productId,
            name: name,
            color: color,
            storageGb: storageGb,
            ramGb: ramGb,
            condition: condition,
            ptaStatus: ptaStatus,
            barcode: barcode,
            purchasePrice: purchasePrice,
            salePrice: salePrice,
            minPrice: minPrice,
            warrantyMonths: warrantyMonths,
            quantity: quantity,
            lowStockThreshold: lowStockThreshold,
            isActive: isActive,
            createdAt: createdAt,
            updatedAt: updatedAt,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$ProductVariantsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $ProductVariantsTable,
    ProductVariant,
    $$ProductVariantsTableFilterComposer,
    $$ProductVariantsTableOrderingComposer,
    $$ProductVariantsTableAnnotationComposer,
    $$ProductVariantsTableCreateCompanionBuilder,
    $$ProductVariantsTableUpdateCompanionBuilder,
    (
      ProductVariant,
      BaseReferences<_$AppDatabase, $ProductVariantsTable, ProductVariant>
    ),
    ProductVariant,
    PrefetchHooks Function()>;
typedef $$ImeiItemsTableCreateCompanionBuilder = ImeiItemsCompanion Function({
  required String id,
  required String productId,
  Value<String?> variantId,
  required String imei1,
  Value<String?> imei2,
  Value<String> status,
  Value<String?> purchaseId,
  Value<int> purchasePrice,
  Value<int> salePrice,
  Value<String?> soldSaleId,
  Value<DateTime?> warrantyStart,
  Value<DateTime?> warrantyEnd,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
  Value<int> rowid,
});
typedef $$ImeiItemsTableUpdateCompanionBuilder = ImeiItemsCompanion Function({
  Value<String> id,
  Value<String> productId,
  Value<String?> variantId,
  Value<String> imei1,
  Value<String?> imei2,
  Value<String> status,
  Value<String?> purchaseId,
  Value<int> purchasePrice,
  Value<int> salePrice,
  Value<String?> soldSaleId,
  Value<DateTime?> warrantyStart,
  Value<DateTime?> warrantyEnd,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
  Value<int> rowid,
});

class $$ImeiItemsTableFilterComposer
    extends Composer<_$AppDatabase, $ImeiItemsTable> {
  $$ImeiItemsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get productId => $composableBuilder(
      column: $table.productId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get variantId => $composableBuilder(
      column: $table.variantId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get imei1 => $composableBuilder(
      column: $table.imei1, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get imei2 => $composableBuilder(
      column: $table.imei2, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get status => $composableBuilder(
      column: $table.status, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get purchaseId => $composableBuilder(
      column: $table.purchaseId, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get purchasePrice => $composableBuilder(
      column: $table.purchasePrice, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get salePrice => $composableBuilder(
      column: $table.salePrice, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get soldSaleId => $composableBuilder(
      column: $table.soldSaleId, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get warrantyStart => $composableBuilder(
      column: $table.warrantyStart, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get warrantyEnd => $composableBuilder(
      column: $table.warrantyEnd, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnFilters(column));
}

class $$ImeiItemsTableOrderingComposer
    extends Composer<_$AppDatabase, $ImeiItemsTable> {
  $$ImeiItemsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get productId => $composableBuilder(
      column: $table.productId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get variantId => $composableBuilder(
      column: $table.variantId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get imei1 => $composableBuilder(
      column: $table.imei1, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get imei2 => $composableBuilder(
      column: $table.imei2, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get status => $composableBuilder(
      column: $table.status, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get purchaseId => $composableBuilder(
      column: $table.purchaseId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get purchasePrice => $composableBuilder(
      column: $table.purchasePrice,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get salePrice => $composableBuilder(
      column: $table.salePrice, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get soldSaleId => $composableBuilder(
      column: $table.soldSaleId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get warrantyStart => $composableBuilder(
      column: $table.warrantyStart,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get warrantyEnd => $composableBuilder(
      column: $table.warrantyEnd, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnOrderings(column));
}

class $$ImeiItemsTableAnnotationComposer
    extends Composer<_$AppDatabase, $ImeiItemsTable> {
  $$ImeiItemsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get productId =>
      $composableBuilder(column: $table.productId, builder: (column) => column);

  GeneratedColumn<String> get variantId =>
      $composableBuilder(column: $table.variantId, builder: (column) => column);

  GeneratedColumn<String> get imei1 =>
      $composableBuilder(column: $table.imei1, builder: (column) => column);

  GeneratedColumn<String> get imei2 =>
      $composableBuilder(column: $table.imei2, builder: (column) => column);

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<String> get purchaseId => $composableBuilder(
      column: $table.purchaseId, builder: (column) => column);

  GeneratedColumn<int> get purchasePrice => $composableBuilder(
      column: $table.purchasePrice, builder: (column) => column);

  GeneratedColumn<int> get salePrice =>
      $composableBuilder(column: $table.salePrice, builder: (column) => column);

  GeneratedColumn<String> get soldSaleId => $composableBuilder(
      column: $table.soldSaleId, builder: (column) => column);

  GeneratedColumn<DateTime> get warrantyStart => $composableBuilder(
      column: $table.warrantyStart, builder: (column) => column);

  GeneratedColumn<DateTime> get warrantyEnd => $composableBuilder(
      column: $table.warrantyEnd, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$ImeiItemsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $ImeiItemsTable,
    ImeiItem,
    $$ImeiItemsTableFilterComposer,
    $$ImeiItemsTableOrderingComposer,
    $$ImeiItemsTableAnnotationComposer,
    $$ImeiItemsTableCreateCompanionBuilder,
    $$ImeiItemsTableUpdateCompanionBuilder,
    (ImeiItem, BaseReferences<_$AppDatabase, $ImeiItemsTable, ImeiItem>),
    ImeiItem,
    PrefetchHooks Function()> {
  $$ImeiItemsTableTableManager(_$AppDatabase db, $ImeiItemsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ImeiItemsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ImeiItemsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ImeiItemsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> productId = const Value.absent(),
            Value<String?> variantId = const Value.absent(),
            Value<String> imei1 = const Value.absent(),
            Value<String?> imei2 = const Value.absent(),
            Value<String> status = const Value.absent(),
            Value<String?> purchaseId = const Value.absent(),
            Value<int> purchasePrice = const Value.absent(),
            Value<int> salePrice = const Value.absent(),
            Value<String?> soldSaleId = const Value.absent(),
            Value<DateTime?> warrantyStart = const Value.absent(),
            Value<DateTime?> warrantyEnd = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              ImeiItemsCompanion(
            id: id,
            productId: productId,
            variantId: variantId,
            imei1: imei1,
            imei2: imei2,
            status: status,
            purchaseId: purchaseId,
            purchasePrice: purchasePrice,
            salePrice: salePrice,
            soldSaleId: soldSaleId,
            warrantyStart: warrantyStart,
            warrantyEnd: warrantyEnd,
            createdAt: createdAt,
            updatedAt: updatedAt,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String productId,
            Value<String?> variantId = const Value.absent(),
            required String imei1,
            Value<String?> imei2 = const Value.absent(),
            Value<String> status = const Value.absent(),
            Value<String?> purchaseId = const Value.absent(),
            Value<int> purchasePrice = const Value.absent(),
            Value<int> salePrice = const Value.absent(),
            Value<String?> soldSaleId = const Value.absent(),
            Value<DateTime?> warrantyStart = const Value.absent(),
            Value<DateTime?> warrantyEnd = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              ImeiItemsCompanion.insert(
            id: id,
            productId: productId,
            variantId: variantId,
            imei1: imei1,
            imei2: imei2,
            status: status,
            purchaseId: purchaseId,
            purchasePrice: purchasePrice,
            salePrice: salePrice,
            soldSaleId: soldSaleId,
            warrantyStart: warrantyStart,
            warrantyEnd: warrantyEnd,
            createdAt: createdAt,
            updatedAt: updatedAt,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$ImeiItemsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $ImeiItemsTable,
    ImeiItem,
    $$ImeiItemsTableFilterComposer,
    $$ImeiItemsTableOrderingComposer,
    $$ImeiItemsTableAnnotationComposer,
    $$ImeiItemsTableCreateCompanionBuilder,
    $$ImeiItemsTableUpdateCompanionBuilder,
    (ImeiItem, BaseReferences<_$AppDatabase, $ImeiItemsTable, ImeiItem>),
    ImeiItem,
    PrefetchHooks Function()>;
typedef $$CustomersTableCreateCompanionBuilder = CustomersCompanion Function({
  required String id,
  required String name,
  required String phone,
  Value<String?> cnic,
  Value<String?> address,
  Value<int> openingBalance,
  Value<int> loyaltyPoints,
  Value<int> walletBalance,
  Value<bool> isActive,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
  Value<int> rowid,
});
typedef $$CustomersTableUpdateCompanionBuilder = CustomersCompanion Function({
  Value<String> id,
  Value<String> name,
  Value<String> phone,
  Value<String?> cnic,
  Value<String?> address,
  Value<int> openingBalance,
  Value<int> loyaltyPoints,
  Value<int> walletBalance,
  Value<bool> isActive,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
  Value<int> rowid,
});

class $$CustomersTableFilterComposer
    extends Composer<_$AppDatabase, $CustomersTable> {
  $$CustomersTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get phone => $composableBuilder(
      column: $table.phone, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get cnic => $composableBuilder(
      column: $table.cnic, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get address => $composableBuilder(
      column: $table.address, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get openingBalance => $composableBuilder(
      column: $table.openingBalance,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get loyaltyPoints => $composableBuilder(
      column: $table.loyaltyPoints, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get walletBalance => $composableBuilder(
      column: $table.walletBalance, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isActive => $composableBuilder(
      column: $table.isActive, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnFilters(column));
}

class $$CustomersTableOrderingComposer
    extends Composer<_$AppDatabase, $CustomersTable> {
  $$CustomersTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get phone => $composableBuilder(
      column: $table.phone, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get cnic => $composableBuilder(
      column: $table.cnic, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get address => $composableBuilder(
      column: $table.address, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get openingBalance => $composableBuilder(
      column: $table.openingBalance,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get loyaltyPoints => $composableBuilder(
      column: $table.loyaltyPoints,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get walletBalance => $composableBuilder(
      column: $table.walletBalance,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isActive => $composableBuilder(
      column: $table.isActive, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnOrderings(column));
}

class $$CustomersTableAnnotationComposer
    extends Composer<_$AppDatabase, $CustomersTable> {
  $$CustomersTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get phone =>
      $composableBuilder(column: $table.phone, builder: (column) => column);

  GeneratedColumn<String> get cnic =>
      $composableBuilder(column: $table.cnic, builder: (column) => column);

  GeneratedColumn<String> get address =>
      $composableBuilder(column: $table.address, builder: (column) => column);

  GeneratedColumn<int> get openingBalance => $composableBuilder(
      column: $table.openingBalance, builder: (column) => column);

  GeneratedColumn<int> get loyaltyPoints => $composableBuilder(
      column: $table.loyaltyPoints, builder: (column) => column);

  GeneratedColumn<int> get walletBalance => $composableBuilder(
      column: $table.walletBalance, builder: (column) => column);

  GeneratedColumn<bool> get isActive =>
      $composableBuilder(column: $table.isActive, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$CustomersTableTableManager extends RootTableManager<
    _$AppDatabase,
    $CustomersTable,
    Customer,
    $$CustomersTableFilterComposer,
    $$CustomersTableOrderingComposer,
    $$CustomersTableAnnotationComposer,
    $$CustomersTableCreateCompanionBuilder,
    $$CustomersTableUpdateCompanionBuilder,
    (Customer, BaseReferences<_$AppDatabase, $CustomersTable, Customer>),
    Customer,
    PrefetchHooks Function()> {
  $$CustomersTableTableManager(_$AppDatabase db, $CustomersTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CustomersTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CustomersTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CustomersTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> name = const Value.absent(),
            Value<String> phone = const Value.absent(),
            Value<String?> cnic = const Value.absent(),
            Value<String?> address = const Value.absent(),
            Value<int> openingBalance = const Value.absent(),
            Value<int> loyaltyPoints = const Value.absent(),
            Value<int> walletBalance = const Value.absent(),
            Value<bool> isActive = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              CustomersCompanion(
            id: id,
            name: name,
            phone: phone,
            cnic: cnic,
            address: address,
            openingBalance: openingBalance,
            loyaltyPoints: loyaltyPoints,
            walletBalance: walletBalance,
            isActive: isActive,
            createdAt: createdAt,
            updatedAt: updatedAt,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String name,
            required String phone,
            Value<String?> cnic = const Value.absent(),
            Value<String?> address = const Value.absent(),
            Value<int> openingBalance = const Value.absent(),
            Value<int> loyaltyPoints = const Value.absent(),
            Value<int> walletBalance = const Value.absent(),
            Value<bool> isActive = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              CustomersCompanion.insert(
            id: id,
            name: name,
            phone: phone,
            cnic: cnic,
            address: address,
            openingBalance: openingBalance,
            loyaltyPoints: loyaltyPoints,
            walletBalance: walletBalance,
            isActive: isActive,
            createdAt: createdAt,
            updatedAt: updatedAt,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$CustomersTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $CustomersTable,
    Customer,
    $$CustomersTableFilterComposer,
    $$CustomersTableOrderingComposer,
    $$CustomersTableAnnotationComposer,
    $$CustomersTableCreateCompanionBuilder,
    $$CustomersTableUpdateCompanionBuilder,
    (Customer, BaseReferences<_$AppDatabase, $CustomersTable, Customer>),
    Customer,
    PrefetchHooks Function()>;
typedef $$SuppliersTableCreateCompanionBuilder = SuppliersCompanion Function({
  required String id,
  required String name,
  Value<String?> phone,
  Value<String?> address,
  Value<int> openingPayable,
  Value<bool> isActive,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
  Value<int> rowid,
});
typedef $$SuppliersTableUpdateCompanionBuilder = SuppliersCompanion Function({
  Value<String> id,
  Value<String> name,
  Value<String?> phone,
  Value<String?> address,
  Value<int> openingPayable,
  Value<bool> isActive,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
  Value<int> rowid,
});

class $$SuppliersTableFilterComposer
    extends Composer<_$AppDatabase, $SuppliersTable> {
  $$SuppliersTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get phone => $composableBuilder(
      column: $table.phone, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get address => $composableBuilder(
      column: $table.address, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get openingPayable => $composableBuilder(
      column: $table.openingPayable,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isActive => $composableBuilder(
      column: $table.isActive, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnFilters(column));
}

class $$SuppliersTableOrderingComposer
    extends Composer<_$AppDatabase, $SuppliersTable> {
  $$SuppliersTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get phone => $composableBuilder(
      column: $table.phone, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get address => $composableBuilder(
      column: $table.address, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get openingPayable => $composableBuilder(
      column: $table.openingPayable,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isActive => $composableBuilder(
      column: $table.isActive, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnOrderings(column));
}

class $$SuppliersTableAnnotationComposer
    extends Composer<_$AppDatabase, $SuppliersTable> {
  $$SuppliersTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get phone =>
      $composableBuilder(column: $table.phone, builder: (column) => column);

  GeneratedColumn<String> get address =>
      $composableBuilder(column: $table.address, builder: (column) => column);

  GeneratedColumn<int> get openingPayable => $composableBuilder(
      column: $table.openingPayable, builder: (column) => column);

  GeneratedColumn<bool> get isActive =>
      $composableBuilder(column: $table.isActive, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$SuppliersTableTableManager extends RootTableManager<
    _$AppDatabase,
    $SuppliersTable,
    Supplier,
    $$SuppliersTableFilterComposer,
    $$SuppliersTableOrderingComposer,
    $$SuppliersTableAnnotationComposer,
    $$SuppliersTableCreateCompanionBuilder,
    $$SuppliersTableUpdateCompanionBuilder,
    (Supplier, BaseReferences<_$AppDatabase, $SuppliersTable, Supplier>),
    Supplier,
    PrefetchHooks Function()> {
  $$SuppliersTableTableManager(_$AppDatabase db, $SuppliersTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SuppliersTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SuppliersTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SuppliersTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> name = const Value.absent(),
            Value<String?> phone = const Value.absent(),
            Value<String?> address = const Value.absent(),
            Value<int> openingPayable = const Value.absent(),
            Value<bool> isActive = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              SuppliersCompanion(
            id: id,
            name: name,
            phone: phone,
            address: address,
            openingPayable: openingPayable,
            isActive: isActive,
            createdAt: createdAt,
            updatedAt: updatedAt,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String name,
            Value<String?> phone = const Value.absent(),
            Value<String?> address = const Value.absent(),
            Value<int> openingPayable = const Value.absent(),
            Value<bool> isActive = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              SuppliersCompanion.insert(
            id: id,
            name: name,
            phone: phone,
            address: address,
            openingPayable: openingPayable,
            isActive: isActive,
            createdAt: createdAt,
            updatedAt: updatedAt,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$SuppliersTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $SuppliersTable,
    Supplier,
    $$SuppliersTableFilterComposer,
    $$SuppliersTableOrderingComposer,
    $$SuppliersTableAnnotationComposer,
    $$SuppliersTableCreateCompanionBuilder,
    $$SuppliersTableUpdateCompanionBuilder,
    (Supplier, BaseReferences<_$AppDatabase, $SuppliersTable, Supplier>),
    Supplier,
    PrefetchHooks Function()>;
typedef $$SalesTableCreateCompanionBuilder = SalesCompanion Function({
  required String id,
  required String invoiceNo,
  Value<String?> branchId,
  Value<String?> customerId,
  Value<String?> customerName,
  Value<String?> customerPhone,
  required String userId,
  Value<DateTime> saleDate,
  Value<int> subtotal,
  Value<int> discountAmount,
  Value<double> discountPercent,
  Value<int> taxAmount,
  Value<int> grandTotal,
  Value<int> paidAmount,
  Value<int> balanceDue,
  Value<String> paymentMethod,
  Value<String> paymentStatus,
  Value<String> status,
  Value<String?> notes,
  Value<String?> clientUuid,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
  Value<int> rowid,
});
typedef $$SalesTableUpdateCompanionBuilder = SalesCompanion Function({
  Value<String> id,
  Value<String> invoiceNo,
  Value<String?> branchId,
  Value<String?> customerId,
  Value<String?> customerName,
  Value<String?> customerPhone,
  Value<String> userId,
  Value<DateTime> saleDate,
  Value<int> subtotal,
  Value<int> discountAmount,
  Value<double> discountPercent,
  Value<int> taxAmount,
  Value<int> grandTotal,
  Value<int> paidAmount,
  Value<int> balanceDue,
  Value<String> paymentMethod,
  Value<String> paymentStatus,
  Value<String> status,
  Value<String?> notes,
  Value<String?> clientUuid,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
  Value<int> rowid,
});

class $$SalesTableFilterComposer extends Composer<_$AppDatabase, $SalesTable> {
  $$SalesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get invoiceNo => $composableBuilder(
      column: $table.invoiceNo, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get branchId => $composableBuilder(
      column: $table.branchId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get customerId => $composableBuilder(
      column: $table.customerId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get customerName => $composableBuilder(
      column: $table.customerName, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get customerPhone => $composableBuilder(
      column: $table.customerPhone, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get userId => $composableBuilder(
      column: $table.userId, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get saleDate => $composableBuilder(
      column: $table.saleDate, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get subtotal => $composableBuilder(
      column: $table.subtotal, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get discountAmount => $composableBuilder(
      column: $table.discountAmount,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get discountPercent => $composableBuilder(
      column: $table.discountPercent,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get taxAmount => $composableBuilder(
      column: $table.taxAmount, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get grandTotal => $composableBuilder(
      column: $table.grandTotal, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get paidAmount => $composableBuilder(
      column: $table.paidAmount, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get balanceDue => $composableBuilder(
      column: $table.balanceDue, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get paymentMethod => $composableBuilder(
      column: $table.paymentMethod, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get paymentStatus => $composableBuilder(
      column: $table.paymentStatus, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get status => $composableBuilder(
      column: $table.status, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get notes => $composableBuilder(
      column: $table.notes, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get clientUuid => $composableBuilder(
      column: $table.clientUuid, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnFilters(column));
}

class $$SalesTableOrderingComposer
    extends Composer<_$AppDatabase, $SalesTable> {
  $$SalesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get invoiceNo => $composableBuilder(
      column: $table.invoiceNo, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get branchId => $composableBuilder(
      column: $table.branchId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get customerId => $composableBuilder(
      column: $table.customerId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get customerName => $composableBuilder(
      column: $table.customerName,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get customerPhone => $composableBuilder(
      column: $table.customerPhone,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get userId => $composableBuilder(
      column: $table.userId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get saleDate => $composableBuilder(
      column: $table.saleDate, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get subtotal => $composableBuilder(
      column: $table.subtotal, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get discountAmount => $composableBuilder(
      column: $table.discountAmount,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get discountPercent => $composableBuilder(
      column: $table.discountPercent,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get taxAmount => $composableBuilder(
      column: $table.taxAmount, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get grandTotal => $composableBuilder(
      column: $table.grandTotal, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get paidAmount => $composableBuilder(
      column: $table.paidAmount, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get balanceDue => $composableBuilder(
      column: $table.balanceDue, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get paymentMethod => $composableBuilder(
      column: $table.paymentMethod,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get paymentStatus => $composableBuilder(
      column: $table.paymentStatus,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get status => $composableBuilder(
      column: $table.status, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get notes => $composableBuilder(
      column: $table.notes, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get clientUuid => $composableBuilder(
      column: $table.clientUuid, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnOrderings(column));
}

class $$SalesTableAnnotationComposer
    extends Composer<_$AppDatabase, $SalesTable> {
  $$SalesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get invoiceNo =>
      $composableBuilder(column: $table.invoiceNo, builder: (column) => column);

  GeneratedColumn<String> get branchId =>
      $composableBuilder(column: $table.branchId, builder: (column) => column);

  GeneratedColumn<String> get customerId => $composableBuilder(
      column: $table.customerId, builder: (column) => column);

  GeneratedColumn<String> get customerName => $composableBuilder(
      column: $table.customerName, builder: (column) => column);

  GeneratedColumn<String> get customerPhone => $composableBuilder(
      column: $table.customerPhone, builder: (column) => column);

  GeneratedColumn<String> get userId =>
      $composableBuilder(column: $table.userId, builder: (column) => column);

  GeneratedColumn<DateTime> get saleDate =>
      $composableBuilder(column: $table.saleDate, builder: (column) => column);

  GeneratedColumn<int> get subtotal =>
      $composableBuilder(column: $table.subtotal, builder: (column) => column);

  GeneratedColumn<int> get discountAmount => $composableBuilder(
      column: $table.discountAmount, builder: (column) => column);

  GeneratedColumn<double> get discountPercent => $composableBuilder(
      column: $table.discountPercent, builder: (column) => column);

  GeneratedColumn<int> get taxAmount =>
      $composableBuilder(column: $table.taxAmount, builder: (column) => column);

  GeneratedColumn<int> get grandTotal => $composableBuilder(
      column: $table.grandTotal, builder: (column) => column);

  GeneratedColumn<int> get paidAmount => $composableBuilder(
      column: $table.paidAmount, builder: (column) => column);

  GeneratedColumn<int> get balanceDue => $composableBuilder(
      column: $table.balanceDue, builder: (column) => column);

  GeneratedColumn<String> get paymentMethod => $composableBuilder(
      column: $table.paymentMethod, builder: (column) => column);

  GeneratedColumn<String> get paymentStatus => $composableBuilder(
      column: $table.paymentStatus, builder: (column) => column);

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);

  GeneratedColumn<String> get clientUuid => $composableBuilder(
      column: $table.clientUuid, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$SalesTableTableManager extends RootTableManager<
    _$AppDatabase,
    $SalesTable,
    Sale,
    $$SalesTableFilterComposer,
    $$SalesTableOrderingComposer,
    $$SalesTableAnnotationComposer,
    $$SalesTableCreateCompanionBuilder,
    $$SalesTableUpdateCompanionBuilder,
    (Sale, BaseReferences<_$AppDatabase, $SalesTable, Sale>),
    Sale,
    PrefetchHooks Function()> {
  $$SalesTableTableManager(_$AppDatabase db, $SalesTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SalesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SalesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SalesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> invoiceNo = const Value.absent(),
            Value<String?> branchId = const Value.absent(),
            Value<String?> customerId = const Value.absent(),
            Value<String?> customerName = const Value.absent(),
            Value<String?> customerPhone = const Value.absent(),
            Value<String> userId = const Value.absent(),
            Value<DateTime> saleDate = const Value.absent(),
            Value<int> subtotal = const Value.absent(),
            Value<int> discountAmount = const Value.absent(),
            Value<double> discountPercent = const Value.absent(),
            Value<int> taxAmount = const Value.absent(),
            Value<int> grandTotal = const Value.absent(),
            Value<int> paidAmount = const Value.absent(),
            Value<int> balanceDue = const Value.absent(),
            Value<String> paymentMethod = const Value.absent(),
            Value<String> paymentStatus = const Value.absent(),
            Value<String> status = const Value.absent(),
            Value<String?> notes = const Value.absent(),
            Value<String?> clientUuid = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              SalesCompanion(
            id: id,
            invoiceNo: invoiceNo,
            branchId: branchId,
            customerId: customerId,
            customerName: customerName,
            customerPhone: customerPhone,
            userId: userId,
            saleDate: saleDate,
            subtotal: subtotal,
            discountAmount: discountAmount,
            discountPercent: discountPercent,
            taxAmount: taxAmount,
            grandTotal: grandTotal,
            paidAmount: paidAmount,
            balanceDue: balanceDue,
            paymentMethod: paymentMethod,
            paymentStatus: paymentStatus,
            status: status,
            notes: notes,
            clientUuid: clientUuid,
            createdAt: createdAt,
            updatedAt: updatedAt,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String invoiceNo,
            Value<String?> branchId = const Value.absent(),
            Value<String?> customerId = const Value.absent(),
            Value<String?> customerName = const Value.absent(),
            Value<String?> customerPhone = const Value.absent(),
            required String userId,
            Value<DateTime> saleDate = const Value.absent(),
            Value<int> subtotal = const Value.absent(),
            Value<int> discountAmount = const Value.absent(),
            Value<double> discountPercent = const Value.absent(),
            Value<int> taxAmount = const Value.absent(),
            Value<int> grandTotal = const Value.absent(),
            Value<int> paidAmount = const Value.absent(),
            Value<int> balanceDue = const Value.absent(),
            Value<String> paymentMethod = const Value.absent(),
            Value<String> paymentStatus = const Value.absent(),
            Value<String> status = const Value.absent(),
            Value<String?> notes = const Value.absent(),
            Value<String?> clientUuid = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              SalesCompanion.insert(
            id: id,
            invoiceNo: invoiceNo,
            branchId: branchId,
            customerId: customerId,
            customerName: customerName,
            customerPhone: customerPhone,
            userId: userId,
            saleDate: saleDate,
            subtotal: subtotal,
            discountAmount: discountAmount,
            discountPercent: discountPercent,
            taxAmount: taxAmount,
            grandTotal: grandTotal,
            paidAmount: paidAmount,
            balanceDue: balanceDue,
            paymentMethod: paymentMethod,
            paymentStatus: paymentStatus,
            status: status,
            notes: notes,
            clientUuid: clientUuid,
            createdAt: createdAt,
            updatedAt: updatedAt,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$SalesTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $SalesTable,
    Sale,
    $$SalesTableFilterComposer,
    $$SalesTableOrderingComposer,
    $$SalesTableAnnotationComposer,
    $$SalesTableCreateCompanionBuilder,
    $$SalesTableUpdateCompanionBuilder,
    (Sale, BaseReferences<_$AppDatabase, $SalesTable, Sale>),
    Sale,
    PrefetchHooks Function()>;
typedef $$SaleItemsTableCreateCompanionBuilder = SaleItemsCompanion Function({
  required String id,
  required String saleId,
  Value<String?> productId,
  Value<String?> variantId,
  Value<String?> imeiItemId,
  required String nameSnapshot,
  Value<int> quantity,
  required int unitPrice,
  Value<int> purchaseCost,
  Value<int> discount,
  required int total,
  Value<int> profit,
  Value<DateTime> createdAt,
  Value<int> rowid,
});
typedef $$SaleItemsTableUpdateCompanionBuilder = SaleItemsCompanion Function({
  Value<String> id,
  Value<String> saleId,
  Value<String?> productId,
  Value<String?> variantId,
  Value<String?> imeiItemId,
  Value<String> nameSnapshot,
  Value<int> quantity,
  Value<int> unitPrice,
  Value<int> purchaseCost,
  Value<int> discount,
  Value<int> total,
  Value<int> profit,
  Value<DateTime> createdAt,
  Value<int> rowid,
});

class $$SaleItemsTableFilterComposer
    extends Composer<_$AppDatabase, $SaleItemsTable> {
  $$SaleItemsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get saleId => $composableBuilder(
      column: $table.saleId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get productId => $composableBuilder(
      column: $table.productId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get variantId => $composableBuilder(
      column: $table.variantId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get imeiItemId => $composableBuilder(
      column: $table.imeiItemId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get nameSnapshot => $composableBuilder(
      column: $table.nameSnapshot, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get quantity => $composableBuilder(
      column: $table.quantity, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get unitPrice => $composableBuilder(
      column: $table.unitPrice, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get purchaseCost => $composableBuilder(
      column: $table.purchaseCost, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get discount => $composableBuilder(
      column: $table.discount, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get total => $composableBuilder(
      column: $table.total, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get profit => $composableBuilder(
      column: $table.profit, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));
}

class $$SaleItemsTableOrderingComposer
    extends Composer<_$AppDatabase, $SaleItemsTable> {
  $$SaleItemsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get saleId => $composableBuilder(
      column: $table.saleId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get productId => $composableBuilder(
      column: $table.productId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get variantId => $composableBuilder(
      column: $table.variantId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get imeiItemId => $composableBuilder(
      column: $table.imeiItemId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get nameSnapshot => $composableBuilder(
      column: $table.nameSnapshot,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get quantity => $composableBuilder(
      column: $table.quantity, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get unitPrice => $composableBuilder(
      column: $table.unitPrice, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get purchaseCost => $composableBuilder(
      column: $table.purchaseCost,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get discount => $composableBuilder(
      column: $table.discount, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get total => $composableBuilder(
      column: $table.total, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get profit => $composableBuilder(
      column: $table.profit, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));
}

class $$SaleItemsTableAnnotationComposer
    extends Composer<_$AppDatabase, $SaleItemsTable> {
  $$SaleItemsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get saleId =>
      $composableBuilder(column: $table.saleId, builder: (column) => column);

  GeneratedColumn<String> get productId =>
      $composableBuilder(column: $table.productId, builder: (column) => column);

  GeneratedColumn<String> get variantId =>
      $composableBuilder(column: $table.variantId, builder: (column) => column);

  GeneratedColumn<String> get imeiItemId => $composableBuilder(
      column: $table.imeiItemId, builder: (column) => column);

  GeneratedColumn<String> get nameSnapshot => $composableBuilder(
      column: $table.nameSnapshot, builder: (column) => column);

  GeneratedColumn<int> get quantity =>
      $composableBuilder(column: $table.quantity, builder: (column) => column);

  GeneratedColumn<int> get unitPrice =>
      $composableBuilder(column: $table.unitPrice, builder: (column) => column);

  GeneratedColumn<int> get purchaseCost => $composableBuilder(
      column: $table.purchaseCost, builder: (column) => column);

  GeneratedColumn<int> get discount =>
      $composableBuilder(column: $table.discount, builder: (column) => column);

  GeneratedColumn<int> get total =>
      $composableBuilder(column: $table.total, builder: (column) => column);

  GeneratedColumn<int> get profit =>
      $composableBuilder(column: $table.profit, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$SaleItemsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $SaleItemsTable,
    SaleItem,
    $$SaleItemsTableFilterComposer,
    $$SaleItemsTableOrderingComposer,
    $$SaleItemsTableAnnotationComposer,
    $$SaleItemsTableCreateCompanionBuilder,
    $$SaleItemsTableUpdateCompanionBuilder,
    (SaleItem, BaseReferences<_$AppDatabase, $SaleItemsTable, SaleItem>),
    SaleItem,
    PrefetchHooks Function()> {
  $$SaleItemsTableTableManager(_$AppDatabase db, $SaleItemsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SaleItemsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SaleItemsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SaleItemsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> saleId = const Value.absent(),
            Value<String?> productId = const Value.absent(),
            Value<String?> variantId = const Value.absent(),
            Value<String?> imeiItemId = const Value.absent(),
            Value<String> nameSnapshot = const Value.absent(),
            Value<int> quantity = const Value.absent(),
            Value<int> unitPrice = const Value.absent(),
            Value<int> purchaseCost = const Value.absent(),
            Value<int> discount = const Value.absent(),
            Value<int> total = const Value.absent(),
            Value<int> profit = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              SaleItemsCompanion(
            id: id,
            saleId: saleId,
            productId: productId,
            variantId: variantId,
            imeiItemId: imeiItemId,
            nameSnapshot: nameSnapshot,
            quantity: quantity,
            unitPrice: unitPrice,
            purchaseCost: purchaseCost,
            discount: discount,
            total: total,
            profit: profit,
            createdAt: createdAt,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String saleId,
            Value<String?> productId = const Value.absent(),
            Value<String?> variantId = const Value.absent(),
            Value<String?> imeiItemId = const Value.absent(),
            required String nameSnapshot,
            Value<int> quantity = const Value.absent(),
            required int unitPrice,
            Value<int> purchaseCost = const Value.absent(),
            Value<int> discount = const Value.absent(),
            required int total,
            Value<int> profit = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              SaleItemsCompanion.insert(
            id: id,
            saleId: saleId,
            productId: productId,
            variantId: variantId,
            imeiItemId: imeiItemId,
            nameSnapshot: nameSnapshot,
            quantity: quantity,
            unitPrice: unitPrice,
            purchaseCost: purchaseCost,
            discount: discount,
            total: total,
            profit: profit,
            createdAt: createdAt,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$SaleItemsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $SaleItemsTable,
    SaleItem,
    $$SaleItemsTableFilterComposer,
    $$SaleItemsTableOrderingComposer,
    $$SaleItemsTableAnnotationComposer,
    $$SaleItemsTableCreateCompanionBuilder,
    $$SaleItemsTableUpdateCompanionBuilder,
    (SaleItem, BaseReferences<_$AppDatabase, $SaleItemsTable, SaleItem>),
    SaleItem,
    PrefetchHooks Function()>;
typedef $$SaleReturnsTableCreateCompanionBuilder = SaleReturnsCompanion
    Function({
  required String id,
  required String saleId,
  Value<String?> saleItemId,
  Value<String?> imeiItemId,
  Value<int> quantity,
  Value<String?> reason,
  Value<int> refundAmount,
  Value<bool> isExchange,
  Value<String?> exchangeSaleId,
  required String userId,
  Value<DateTime> createdAt,
  Value<int> rowid,
});
typedef $$SaleReturnsTableUpdateCompanionBuilder = SaleReturnsCompanion
    Function({
  Value<String> id,
  Value<String> saleId,
  Value<String?> saleItemId,
  Value<String?> imeiItemId,
  Value<int> quantity,
  Value<String?> reason,
  Value<int> refundAmount,
  Value<bool> isExchange,
  Value<String?> exchangeSaleId,
  Value<String> userId,
  Value<DateTime> createdAt,
  Value<int> rowid,
});

class $$SaleReturnsTableFilterComposer
    extends Composer<_$AppDatabase, $SaleReturnsTable> {
  $$SaleReturnsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get saleId => $composableBuilder(
      column: $table.saleId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get saleItemId => $composableBuilder(
      column: $table.saleItemId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get imeiItemId => $composableBuilder(
      column: $table.imeiItemId, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get quantity => $composableBuilder(
      column: $table.quantity, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get reason => $composableBuilder(
      column: $table.reason, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get refundAmount => $composableBuilder(
      column: $table.refundAmount, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isExchange => $composableBuilder(
      column: $table.isExchange, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get exchangeSaleId => $composableBuilder(
      column: $table.exchangeSaleId,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get userId => $composableBuilder(
      column: $table.userId, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));
}

class $$SaleReturnsTableOrderingComposer
    extends Composer<_$AppDatabase, $SaleReturnsTable> {
  $$SaleReturnsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get saleId => $composableBuilder(
      column: $table.saleId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get saleItemId => $composableBuilder(
      column: $table.saleItemId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get imeiItemId => $composableBuilder(
      column: $table.imeiItemId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get quantity => $composableBuilder(
      column: $table.quantity, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get reason => $composableBuilder(
      column: $table.reason, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get refundAmount => $composableBuilder(
      column: $table.refundAmount,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isExchange => $composableBuilder(
      column: $table.isExchange, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get exchangeSaleId => $composableBuilder(
      column: $table.exchangeSaleId,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get userId => $composableBuilder(
      column: $table.userId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));
}

class $$SaleReturnsTableAnnotationComposer
    extends Composer<_$AppDatabase, $SaleReturnsTable> {
  $$SaleReturnsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get saleId =>
      $composableBuilder(column: $table.saleId, builder: (column) => column);

  GeneratedColumn<String> get saleItemId => $composableBuilder(
      column: $table.saleItemId, builder: (column) => column);

  GeneratedColumn<String> get imeiItemId => $composableBuilder(
      column: $table.imeiItemId, builder: (column) => column);

  GeneratedColumn<int> get quantity =>
      $composableBuilder(column: $table.quantity, builder: (column) => column);

  GeneratedColumn<String> get reason =>
      $composableBuilder(column: $table.reason, builder: (column) => column);

  GeneratedColumn<int> get refundAmount => $composableBuilder(
      column: $table.refundAmount, builder: (column) => column);

  GeneratedColumn<bool> get isExchange => $composableBuilder(
      column: $table.isExchange, builder: (column) => column);

  GeneratedColumn<String> get exchangeSaleId => $composableBuilder(
      column: $table.exchangeSaleId, builder: (column) => column);

  GeneratedColumn<String> get userId =>
      $composableBuilder(column: $table.userId, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$SaleReturnsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $SaleReturnsTable,
    SaleReturn,
    $$SaleReturnsTableFilterComposer,
    $$SaleReturnsTableOrderingComposer,
    $$SaleReturnsTableAnnotationComposer,
    $$SaleReturnsTableCreateCompanionBuilder,
    $$SaleReturnsTableUpdateCompanionBuilder,
    (SaleReturn, BaseReferences<_$AppDatabase, $SaleReturnsTable, SaleReturn>),
    SaleReturn,
    PrefetchHooks Function()> {
  $$SaleReturnsTableTableManager(_$AppDatabase db, $SaleReturnsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SaleReturnsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SaleReturnsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SaleReturnsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> saleId = const Value.absent(),
            Value<String?> saleItemId = const Value.absent(),
            Value<String?> imeiItemId = const Value.absent(),
            Value<int> quantity = const Value.absent(),
            Value<String?> reason = const Value.absent(),
            Value<int> refundAmount = const Value.absent(),
            Value<bool> isExchange = const Value.absent(),
            Value<String?> exchangeSaleId = const Value.absent(),
            Value<String> userId = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              SaleReturnsCompanion(
            id: id,
            saleId: saleId,
            saleItemId: saleItemId,
            imeiItemId: imeiItemId,
            quantity: quantity,
            reason: reason,
            refundAmount: refundAmount,
            isExchange: isExchange,
            exchangeSaleId: exchangeSaleId,
            userId: userId,
            createdAt: createdAt,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String saleId,
            Value<String?> saleItemId = const Value.absent(),
            Value<String?> imeiItemId = const Value.absent(),
            Value<int> quantity = const Value.absent(),
            Value<String?> reason = const Value.absent(),
            Value<int> refundAmount = const Value.absent(),
            Value<bool> isExchange = const Value.absent(),
            Value<String?> exchangeSaleId = const Value.absent(),
            required String userId,
            Value<DateTime> createdAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              SaleReturnsCompanion.insert(
            id: id,
            saleId: saleId,
            saleItemId: saleItemId,
            imeiItemId: imeiItemId,
            quantity: quantity,
            reason: reason,
            refundAmount: refundAmount,
            isExchange: isExchange,
            exchangeSaleId: exchangeSaleId,
            userId: userId,
            createdAt: createdAt,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$SaleReturnsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $SaleReturnsTable,
    SaleReturn,
    $$SaleReturnsTableFilterComposer,
    $$SaleReturnsTableOrderingComposer,
    $$SaleReturnsTableAnnotationComposer,
    $$SaleReturnsTableCreateCompanionBuilder,
    $$SaleReturnsTableUpdateCompanionBuilder,
    (SaleReturn, BaseReferences<_$AppDatabase, $SaleReturnsTable, SaleReturn>),
    SaleReturn,
    PrefetchHooks Function()>;
typedef $$HeldBillsTableCreateCompanionBuilder = HeldBillsCompanion Function({
  required String id,
  Value<String?> branchId,
  required String userId,
  Value<String?> customerName,
  Value<String> cart,
  Value<DateTime> createdAt,
  Value<int> rowid,
});
typedef $$HeldBillsTableUpdateCompanionBuilder = HeldBillsCompanion Function({
  Value<String> id,
  Value<String?> branchId,
  Value<String> userId,
  Value<String?> customerName,
  Value<String> cart,
  Value<DateTime> createdAt,
  Value<int> rowid,
});

class $$HeldBillsTableFilterComposer
    extends Composer<_$AppDatabase, $HeldBillsTable> {
  $$HeldBillsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get branchId => $composableBuilder(
      column: $table.branchId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get userId => $composableBuilder(
      column: $table.userId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get customerName => $composableBuilder(
      column: $table.customerName, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get cart => $composableBuilder(
      column: $table.cart, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));
}

class $$HeldBillsTableOrderingComposer
    extends Composer<_$AppDatabase, $HeldBillsTable> {
  $$HeldBillsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get branchId => $composableBuilder(
      column: $table.branchId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get userId => $composableBuilder(
      column: $table.userId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get customerName => $composableBuilder(
      column: $table.customerName,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get cart => $composableBuilder(
      column: $table.cart, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));
}

class $$HeldBillsTableAnnotationComposer
    extends Composer<_$AppDatabase, $HeldBillsTable> {
  $$HeldBillsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get branchId =>
      $composableBuilder(column: $table.branchId, builder: (column) => column);

  GeneratedColumn<String> get userId =>
      $composableBuilder(column: $table.userId, builder: (column) => column);

  GeneratedColumn<String> get customerName => $composableBuilder(
      column: $table.customerName, builder: (column) => column);

  GeneratedColumn<String> get cart =>
      $composableBuilder(column: $table.cart, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$HeldBillsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $HeldBillsTable,
    HeldBill,
    $$HeldBillsTableFilterComposer,
    $$HeldBillsTableOrderingComposer,
    $$HeldBillsTableAnnotationComposer,
    $$HeldBillsTableCreateCompanionBuilder,
    $$HeldBillsTableUpdateCompanionBuilder,
    (HeldBill, BaseReferences<_$AppDatabase, $HeldBillsTable, HeldBill>),
    HeldBill,
    PrefetchHooks Function()> {
  $$HeldBillsTableTableManager(_$AppDatabase db, $HeldBillsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$HeldBillsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$HeldBillsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$HeldBillsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String?> branchId = const Value.absent(),
            Value<String> userId = const Value.absent(),
            Value<String?> customerName = const Value.absent(),
            Value<String> cart = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              HeldBillsCompanion(
            id: id,
            branchId: branchId,
            userId: userId,
            customerName: customerName,
            cart: cart,
            createdAt: createdAt,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            Value<String?> branchId = const Value.absent(),
            required String userId,
            Value<String?> customerName = const Value.absent(),
            Value<String> cart = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              HeldBillsCompanion.insert(
            id: id,
            branchId: branchId,
            userId: userId,
            customerName: customerName,
            cart: cart,
            createdAt: createdAt,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$HeldBillsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $HeldBillsTable,
    HeldBill,
    $$HeldBillsTableFilterComposer,
    $$HeldBillsTableOrderingComposer,
    $$HeldBillsTableAnnotationComposer,
    $$HeldBillsTableCreateCompanionBuilder,
    $$HeldBillsTableUpdateCompanionBuilder,
    (HeldBill, BaseReferences<_$AppDatabase, $HeldBillsTable, HeldBill>),
    HeldBill,
    PrefetchHooks Function()>;
typedef $$PurchasesTableCreateCompanionBuilder = PurchasesCompanion Function({
  required String id,
  required String supplierId,
  Value<String?> branchId,
  required String userId,
  Value<String?> supplierInvoiceNo,
  Value<DateTime> purchaseDate,
  Value<int> subtotal,
  Value<int> discount,
  Value<int> grandTotal,
  Value<int> paidAmount,
  Value<int> balanceDue,
  Value<String> status,
  Value<String?> notes,
  Value<String?> clientUuid,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
  Value<int> rowid,
});
typedef $$PurchasesTableUpdateCompanionBuilder = PurchasesCompanion Function({
  Value<String> id,
  Value<String> supplierId,
  Value<String?> branchId,
  Value<String> userId,
  Value<String?> supplierInvoiceNo,
  Value<DateTime> purchaseDate,
  Value<int> subtotal,
  Value<int> discount,
  Value<int> grandTotal,
  Value<int> paidAmount,
  Value<int> balanceDue,
  Value<String> status,
  Value<String?> notes,
  Value<String?> clientUuid,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
  Value<int> rowid,
});

class $$PurchasesTableFilterComposer
    extends Composer<_$AppDatabase, $PurchasesTable> {
  $$PurchasesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get supplierId => $composableBuilder(
      column: $table.supplierId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get branchId => $composableBuilder(
      column: $table.branchId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get userId => $composableBuilder(
      column: $table.userId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get supplierInvoiceNo => $composableBuilder(
      column: $table.supplierInvoiceNo,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get purchaseDate => $composableBuilder(
      column: $table.purchaseDate, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get subtotal => $composableBuilder(
      column: $table.subtotal, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get discount => $composableBuilder(
      column: $table.discount, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get grandTotal => $composableBuilder(
      column: $table.grandTotal, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get paidAmount => $composableBuilder(
      column: $table.paidAmount, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get balanceDue => $composableBuilder(
      column: $table.balanceDue, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get status => $composableBuilder(
      column: $table.status, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get notes => $composableBuilder(
      column: $table.notes, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get clientUuid => $composableBuilder(
      column: $table.clientUuid, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnFilters(column));
}

class $$PurchasesTableOrderingComposer
    extends Composer<_$AppDatabase, $PurchasesTable> {
  $$PurchasesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get supplierId => $composableBuilder(
      column: $table.supplierId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get branchId => $composableBuilder(
      column: $table.branchId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get userId => $composableBuilder(
      column: $table.userId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get supplierInvoiceNo => $composableBuilder(
      column: $table.supplierInvoiceNo,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get purchaseDate => $composableBuilder(
      column: $table.purchaseDate,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get subtotal => $composableBuilder(
      column: $table.subtotal, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get discount => $composableBuilder(
      column: $table.discount, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get grandTotal => $composableBuilder(
      column: $table.grandTotal, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get paidAmount => $composableBuilder(
      column: $table.paidAmount, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get balanceDue => $composableBuilder(
      column: $table.balanceDue, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get status => $composableBuilder(
      column: $table.status, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get notes => $composableBuilder(
      column: $table.notes, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get clientUuid => $composableBuilder(
      column: $table.clientUuid, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnOrderings(column));
}

class $$PurchasesTableAnnotationComposer
    extends Composer<_$AppDatabase, $PurchasesTable> {
  $$PurchasesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get supplierId => $composableBuilder(
      column: $table.supplierId, builder: (column) => column);

  GeneratedColumn<String> get branchId =>
      $composableBuilder(column: $table.branchId, builder: (column) => column);

  GeneratedColumn<String> get userId =>
      $composableBuilder(column: $table.userId, builder: (column) => column);

  GeneratedColumn<String> get supplierInvoiceNo => $composableBuilder(
      column: $table.supplierInvoiceNo, builder: (column) => column);

  GeneratedColumn<DateTime> get purchaseDate => $composableBuilder(
      column: $table.purchaseDate, builder: (column) => column);

  GeneratedColumn<int> get subtotal =>
      $composableBuilder(column: $table.subtotal, builder: (column) => column);

  GeneratedColumn<int> get discount =>
      $composableBuilder(column: $table.discount, builder: (column) => column);

  GeneratedColumn<int> get grandTotal => $composableBuilder(
      column: $table.grandTotal, builder: (column) => column);

  GeneratedColumn<int> get paidAmount => $composableBuilder(
      column: $table.paidAmount, builder: (column) => column);

  GeneratedColumn<int> get balanceDue => $composableBuilder(
      column: $table.balanceDue, builder: (column) => column);

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);

  GeneratedColumn<String> get clientUuid => $composableBuilder(
      column: $table.clientUuid, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$PurchasesTableTableManager extends RootTableManager<
    _$AppDatabase,
    $PurchasesTable,
    Purchase,
    $$PurchasesTableFilterComposer,
    $$PurchasesTableOrderingComposer,
    $$PurchasesTableAnnotationComposer,
    $$PurchasesTableCreateCompanionBuilder,
    $$PurchasesTableUpdateCompanionBuilder,
    (Purchase, BaseReferences<_$AppDatabase, $PurchasesTable, Purchase>),
    Purchase,
    PrefetchHooks Function()> {
  $$PurchasesTableTableManager(_$AppDatabase db, $PurchasesTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PurchasesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PurchasesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$PurchasesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> supplierId = const Value.absent(),
            Value<String?> branchId = const Value.absent(),
            Value<String> userId = const Value.absent(),
            Value<String?> supplierInvoiceNo = const Value.absent(),
            Value<DateTime> purchaseDate = const Value.absent(),
            Value<int> subtotal = const Value.absent(),
            Value<int> discount = const Value.absent(),
            Value<int> grandTotal = const Value.absent(),
            Value<int> paidAmount = const Value.absent(),
            Value<int> balanceDue = const Value.absent(),
            Value<String> status = const Value.absent(),
            Value<String?> notes = const Value.absent(),
            Value<String?> clientUuid = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              PurchasesCompanion(
            id: id,
            supplierId: supplierId,
            branchId: branchId,
            userId: userId,
            supplierInvoiceNo: supplierInvoiceNo,
            purchaseDate: purchaseDate,
            subtotal: subtotal,
            discount: discount,
            grandTotal: grandTotal,
            paidAmount: paidAmount,
            balanceDue: balanceDue,
            status: status,
            notes: notes,
            clientUuid: clientUuid,
            createdAt: createdAt,
            updatedAt: updatedAt,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String supplierId,
            Value<String?> branchId = const Value.absent(),
            required String userId,
            Value<String?> supplierInvoiceNo = const Value.absent(),
            Value<DateTime> purchaseDate = const Value.absent(),
            Value<int> subtotal = const Value.absent(),
            Value<int> discount = const Value.absent(),
            Value<int> grandTotal = const Value.absent(),
            Value<int> paidAmount = const Value.absent(),
            Value<int> balanceDue = const Value.absent(),
            Value<String> status = const Value.absent(),
            Value<String?> notes = const Value.absent(),
            Value<String?> clientUuid = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              PurchasesCompanion.insert(
            id: id,
            supplierId: supplierId,
            branchId: branchId,
            userId: userId,
            supplierInvoiceNo: supplierInvoiceNo,
            purchaseDate: purchaseDate,
            subtotal: subtotal,
            discount: discount,
            grandTotal: grandTotal,
            paidAmount: paidAmount,
            balanceDue: balanceDue,
            status: status,
            notes: notes,
            clientUuid: clientUuid,
            createdAt: createdAt,
            updatedAt: updatedAt,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$PurchasesTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $PurchasesTable,
    Purchase,
    $$PurchasesTableFilterComposer,
    $$PurchasesTableOrderingComposer,
    $$PurchasesTableAnnotationComposer,
    $$PurchasesTableCreateCompanionBuilder,
    $$PurchasesTableUpdateCompanionBuilder,
    (Purchase, BaseReferences<_$AppDatabase, $PurchasesTable, Purchase>),
    Purchase,
    PrefetchHooks Function()>;
typedef $$PurchaseItemsTableCreateCompanionBuilder = PurchaseItemsCompanion
    Function({
  required String id,
  required String purchaseId,
  Value<String?> productId,
  Value<String?> variantId,
  Value<String?> imei1,
  Value<String?> imei2,
  Value<String?> catalogSku,
  Value<int> quantity,
  required int unitCost,
  required int total,
  Value<DateTime> createdAt,
  Value<int> rowid,
});
typedef $$PurchaseItemsTableUpdateCompanionBuilder = PurchaseItemsCompanion
    Function({
  Value<String> id,
  Value<String> purchaseId,
  Value<String?> productId,
  Value<String?> variantId,
  Value<String?> imei1,
  Value<String?> imei2,
  Value<String?> catalogSku,
  Value<int> quantity,
  Value<int> unitCost,
  Value<int> total,
  Value<DateTime> createdAt,
  Value<int> rowid,
});

class $$PurchaseItemsTableFilterComposer
    extends Composer<_$AppDatabase, $PurchaseItemsTable> {
  $$PurchaseItemsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get purchaseId => $composableBuilder(
      column: $table.purchaseId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get productId => $composableBuilder(
      column: $table.productId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get variantId => $composableBuilder(
      column: $table.variantId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get imei1 => $composableBuilder(
      column: $table.imei1, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get imei2 => $composableBuilder(
      column: $table.imei2, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get catalogSku => $composableBuilder(
      column: $table.catalogSku, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get quantity => $composableBuilder(
      column: $table.quantity, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get unitCost => $composableBuilder(
      column: $table.unitCost, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get total => $composableBuilder(
      column: $table.total, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));
}

class $$PurchaseItemsTableOrderingComposer
    extends Composer<_$AppDatabase, $PurchaseItemsTable> {
  $$PurchaseItemsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get purchaseId => $composableBuilder(
      column: $table.purchaseId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get productId => $composableBuilder(
      column: $table.productId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get variantId => $composableBuilder(
      column: $table.variantId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get imei1 => $composableBuilder(
      column: $table.imei1, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get imei2 => $composableBuilder(
      column: $table.imei2, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get catalogSku => $composableBuilder(
      column: $table.catalogSku, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get quantity => $composableBuilder(
      column: $table.quantity, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get unitCost => $composableBuilder(
      column: $table.unitCost, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get total => $composableBuilder(
      column: $table.total, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));
}

class $$PurchaseItemsTableAnnotationComposer
    extends Composer<_$AppDatabase, $PurchaseItemsTable> {
  $$PurchaseItemsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get purchaseId => $composableBuilder(
      column: $table.purchaseId, builder: (column) => column);

  GeneratedColumn<String> get productId =>
      $composableBuilder(column: $table.productId, builder: (column) => column);

  GeneratedColumn<String> get variantId =>
      $composableBuilder(column: $table.variantId, builder: (column) => column);

  GeneratedColumn<String> get imei1 =>
      $composableBuilder(column: $table.imei1, builder: (column) => column);

  GeneratedColumn<String> get imei2 =>
      $composableBuilder(column: $table.imei2, builder: (column) => column);

  GeneratedColumn<String> get catalogSku => $composableBuilder(
      column: $table.catalogSku, builder: (column) => column);

  GeneratedColumn<int> get quantity =>
      $composableBuilder(column: $table.quantity, builder: (column) => column);

  GeneratedColumn<int> get unitCost =>
      $composableBuilder(column: $table.unitCost, builder: (column) => column);

  GeneratedColumn<int> get total =>
      $composableBuilder(column: $table.total, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$PurchaseItemsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $PurchaseItemsTable,
    PurchaseItem,
    $$PurchaseItemsTableFilterComposer,
    $$PurchaseItemsTableOrderingComposer,
    $$PurchaseItemsTableAnnotationComposer,
    $$PurchaseItemsTableCreateCompanionBuilder,
    $$PurchaseItemsTableUpdateCompanionBuilder,
    (
      PurchaseItem,
      BaseReferences<_$AppDatabase, $PurchaseItemsTable, PurchaseItem>
    ),
    PurchaseItem,
    PrefetchHooks Function()> {
  $$PurchaseItemsTableTableManager(_$AppDatabase db, $PurchaseItemsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PurchaseItemsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PurchaseItemsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$PurchaseItemsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> purchaseId = const Value.absent(),
            Value<String?> productId = const Value.absent(),
            Value<String?> variantId = const Value.absent(),
            Value<String?> imei1 = const Value.absent(),
            Value<String?> imei2 = const Value.absent(),
            Value<String?> catalogSku = const Value.absent(),
            Value<int> quantity = const Value.absent(),
            Value<int> unitCost = const Value.absent(),
            Value<int> total = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              PurchaseItemsCompanion(
            id: id,
            purchaseId: purchaseId,
            productId: productId,
            variantId: variantId,
            imei1: imei1,
            imei2: imei2,
            catalogSku: catalogSku,
            quantity: quantity,
            unitCost: unitCost,
            total: total,
            createdAt: createdAt,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String purchaseId,
            Value<String?> productId = const Value.absent(),
            Value<String?> variantId = const Value.absent(),
            Value<String?> imei1 = const Value.absent(),
            Value<String?> imei2 = const Value.absent(),
            Value<String?> catalogSku = const Value.absent(),
            Value<int> quantity = const Value.absent(),
            required int unitCost,
            required int total,
            Value<DateTime> createdAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              PurchaseItemsCompanion.insert(
            id: id,
            purchaseId: purchaseId,
            productId: productId,
            variantId: variantId,
            imei1: imei1,
            imei2: imei2,
            catalogSku: catalogSku,
            quantity: quantity,
            unitCost: unitCost,
            total: total,
            createdAt: createdAt,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$PurchaseItemsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $PurchaseItemsTable,
    PurchaseItem,
    $$PurchaseItemsTableFilterComposer,
    $$PurchaseItemsTableOrderingComposer,
    $$PurchaseItemsTableAnnotationComposer,
    $$PurchaseItemsTableCreateCompanionBuilder,
    $$PurchaseItemsTableUpdateCompanionBuilder,
    (
      PurchaseItem,
      BaseReferences<_$AppDatabase, $PurchaseItemsTable, PurchaseItem>
    ),
    PurchaseItem,
    PrefetchHooks Function()>;
typedef $$PurchaseReturnsTableCreateCompanionBuilder = PurchaseReturnsCompanion
    Function({
  required String id,
  required String purchaseId,
  Value<String?> imeiItemId,
  Value<String?> productId,
  Value<String?> variantId,
  Value<String?> catalogSku,
  Value<int> quantity,
  Value<String?> reason,
  Value<int> refundAmount,
  required String userId,
  Value<DateTime> createdAt,
  Value<int> rowid,
});
typedef $$PurchaseReturnsTableUpdateCompanionBuilder = PurchaseReturnsCompanion
    Function({
  Value<String> id,
  Value<String> purchaseId,
  Value<String?> imeiItemId,
  Value<String?> productId,
  Value<String?> variantId,
  Value<String?> catalogSku,
  Value<int> quantity,
  Value<String?> reason,
  Value<int> refundAmount,
  Value<String> userId,
  Value<DateTime> createdAt,
  Value<int> rowid,
});

class $$PurchaseReturnsTableFilterComposer
    extends Composer<_$AppDatabase, $PurchaseReturnsTable> {
  $$PurchaseReturnsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get purchaseId => $composableBuilder(
      column: $table.purchaseId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get imeiItemId => $composableBuilder(
      column: $table.imeiItemId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get productId => $composableBuilder(
      column: $table.productId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get variantId => $composableBuilder(
      column: $table.variantId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get catalogSku => $composableBuilder(
      column: $table.catalogSku, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get quantity => $composableBuilder(
      column: $table.quantity, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get reason => $composableBuilder(
      column: $table.reason, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get refundAmount => $composableBuilder(
      column: $table.refundAmount, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get userId => $composableBuilder(
      column: $table.userId, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));
}

class $$PurchaseReturnsTableOrderingComposer
    extends Composer<_$AppDatabase, $PurchaseReturnsTable> {
  $$PurchaseReturnsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get purchaseId => $composableBuilder(
      column: $table.purchaseId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get imeiItemId => $composableBuilder(
      column: $table.imeiItemId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get productId => $composableBuilder(
      column: $table.productId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get variantId => $composableBuilder(
      column: $table.variantId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get catalogSku => $composableBuilder(
      column: $table.catalogSku, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get quantity => $composableBuilder(
      column: $table.quantity, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get reason => $composableBuilder(
      column: $table.reason, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get refundAmount => $composableBuilder(
      column: $table.refundAmount,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get userId => $composableBuilder(
      column: $table.userId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));
}

class $$PurchaseReturnsTableAnnotationComposer
    extends Composer<_$AppDatabase, $PurchaseReturnsTable> {
  $$PurchaseReturnsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get purchaseId => $composableBuilder(
      column: $table.purchaseId, builder: (column) => column);

  GeneratedColumn<String> get imeiItemId => $composableBuilder(
      column: $table.imeiItemId, builder: (column) => column);

  GeneratedColumn<String> get productId =>
      $composableBuilder(column: $table.productId, builder: (column) => column);

  GeneratedColumn<String> get variantId =>
      $composableBuilder(column: $table.variantId, builder: (column) => column);

  GeneratedColumn<String> get catalogSku => $composableBuilder(
      column: $table.catalogSku, builder: (column) => column);

  GeneratedColumn<int> get quantity =>
      $composableBuilder(column: $table.quantity, builder: (column) => column);

  GeneratedColumn<String> get reason =>
      $composableBuilder(column: $table.reason, builder: (column) => column);

  GeneratedColumn<int> get refundAmount => $composableBuilder(
      column: $table.refundAmount, builder: (column) => column);

  GeneratedColumn<String> get userId =>
      $composableBuilder(column: $table.userId, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$PurchaseReturnsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $PurchaseReturnsTable,
    PurchaseReturn,
    $$PurchaseReturnsTableFilterComposer,
    $$PurchaseReturnsTableOrderingComposer,
    $$PurchaseReturnsTableAnnotationComposer,
    $$PurchaseReturnsTableCreateCompanionBuilder,
    $$PurchaseReturnsTableUpdateCompanionBuilder,
    (
      PurchaseReturn,
      BaseReferences<_$AppDatabase, $PurchaseReturnsTable, PurchaseReturn>
    ),
    PurchaseReturn,
    PrefetchHooks Function()> {
  $$PurchaseReturnsTableTableManager(
      _$AppDatabase db, $PurchaseReturnsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PurchaseReturnsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PurchaseReturnsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$PurchaseReturnsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> purchaseId = const Value.absent(),
            Value<String?> imeiItemId = const Value.absent(),
            Value<String?> productId = const Value.absent(),
            Value<String?> variantId = const Value.absent(),
            Value<String?> catalogSku = const Value.absent(),
            Value<int> quantity = const Value.absent(),
            Value<String?> reason = const Value.absent(),
            Value<int> refundAmount = const Value.absent(),
            Value<String> userId = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              PurchaseReturnsCompanion(
            id: id,
            purchaseId: purchaseId,
            imeiItemId: imeiItemId,
            productId: productId,
            variantId: variantId,
            catalogSku: catalogSku,
            quantity: quantity,
            reason: reason,
            refundAmount: refundAmount,
            userId: userId,
            createdAt: createdAt,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String purchaseId,
            Value<String?> imeiItemId = const Value.absent(),
            Value<String?> productId = const Value.absent(),
            Value<String?> variantId = const Value.absent(),
            Value<String?> catalogSku = const Value.absent(),
            Value<int> quantity = const Value.absent(),
            Value<String?> reason = const Value.absent(),
            Value<int> refundAmount = const Value.absent(),
            required String userId,
            Value<DateTime> createdAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              PurchaseReturnsCompanion.insert(
            id: id,
            purchaseId: purchaseId,
            imeiItemId: imeiItemId,
            productId: productId,
            variantId: variantId,
            catalogSku: catalogSku,
            quantity: quantity,
            reason: reason,
            refundAmount: refundAmount,
            userId: userId,
            createdAt: createdAt,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$PurchaseReturnsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $PurchaseReturnsTable,
    PurchaseReturn,
    $$PurchaseReturnsTableFilterComposer,
    $$PurchaseReturnsTableOrderingComposer,
    $$PurchaseReturnsTableAnnotationComposer,
    $$PurchaseReturnsTableCreateCompanionBuilder,
    $$PurchaseReturnsTableUpdateCompanionBuilder,
    (
      PurchaseReturn,
      BaseReferences<_$AppDatabase, $PurchaseReturnsTable, PurchaseReturn>
    ),
    PurchaseReturn,
    PrefetchHooks Function()>;
typedef $$PaymentsTableCreateCompanionBuilder = PaymentsCompanion Function({
  required String id,
  required String paymentType,
  Value<String?> saleId,
  Value<String?> purchaseId,
  Value<String?> installmentId,
  Value<String?> repairId,
  Value<String?> customerId,
  Value<String?> supplierId,
  Value<String> method,
  required int amount,
  Value<String?> reference,
  Value<DateTime> paymentDate,
  required String userId,
  Value<String?> notes,
  Value<String?> clientUuid,
  Value<DateTime> createdAt,
  Value<int> rowid,
});
typedef $$PaymentsTableUpdateCompanionBuilder = PaymentsCompanion Function({
  Value<String> id,
  Value<String> paymentType,
  Value<String?> saleId,
  Value<String?> purchaseId,
  Value<String?> installmentId,
  Value<String?> repairId,
  Value<String?> customerId,
  Value<String?> supplierId,
  Value<String> method,
  Value<int> amount,
  Value<String?> reference,
  Value<DateTime> paymentDate,
  Value<String> userId,
  Value<String?> notes,
  Value<String?> clientUuid,
  Value<DateTime> createdAt,
  Value<int> rowid,
});

class $$PaymentsTableFilterComposer
    extends Composer<_$AppDatabase, $PaymentsTable> {
  $$PaymentsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get paymentType => $composableBuilder(
      column: $table.paymentType, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get saleId => $composableBuilder(
      column: $table.saleId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get purchaseId => $composableBuilder(
      column: $table.purchaseId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get installmentId => $composableBuilder(
      column: $table.installmentId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get repairId => $composableBuilder(
      column: $table.repairId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get customerId => $composableBuilder(
      column: $table.customerId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get supplierId => $composableBuilder(
      column: $table.supplierId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get method => $composableBuilder(
      column: $table.method, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get amount => $composableBuilder(
      column: $table.amount, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get reference => $composableBuilder(
      column: $table.reference, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get paymentDate => $composableBuilder(
      column: $table.paymentDate, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get userId => $composableBuilder(
      column: $table.userId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get notes => $composableBuilder(
      column: $table.notes, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get clientUuid => $composableBuilder(
      column: $table.clientUuid, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));
}

class $$PaymentsTableOrderingComposer
    extends Composer<_$AppDatabase, $PaymentsTable> {
  $$PaymentsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get paymentType => $composableBuilder(
      column: $table.paymentType, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get saleId => $composableBuilder(
      column: $table.saleId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get purchaseId => $composableBuilder(
      column: $table.purchaseId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get installmentId => $composableBuilder(
      column: $table.installmentId,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get repairId => $composableBuilder(
      column: $table.repairId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get customerId => $composableBuilder(
      column: $table.customerId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get supplierId => $composableBuilder(
      column: $table.supplierId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get method => $composableBuilder(
      column: $table.method, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get amount => $composableBuilder(
      column: $table.amount, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get reference => $composableBuilder(
      column: $table.reference, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get paymentDate => $composableBuilder(
      column: $table.paymentDate, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get userId => $composableBuilder(
      column: $table.userId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get notes => $composableBuilder(
      column: $table.notes, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get clientUuid => $composableBuilder(
      column: $table.clientUuid, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));
}

class $$PaymentsTableAnnotationComposer
    extends Composer<_$AppDatabase, $PaymentsTable> {
  $$PaymentsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get paymentType => $composableBuilder(
      column: $table.paymentType, builder: (column) => column);

  GeneratedColumn<String> get saleId =>
      $composableBuilder(column: $table.saleId, builder: (column) => column);

  GeneratedColumn<String> get purchaseId => $composableBuilder(
      column: $table.purchaseId, builder: (column) => column);

  GeneratedColumn<String> get installmentId => $composableBuilder(
      column: $table.installmentId, builder: (column) => column);

  GeneratedColumn<String> get repairId =>
      $composableBuilder(column: $table.repairId, builder: (column) => column);

  GeneratedColumn<String> get customerId => $composableBuilder(
      column: $table.customerId, builder: (column) => column);

  GeneratedColumn<String> get supplierId => $composableBuilder(
      column: $table.supplierId, builder: (column) => column);

  GeneratedColumn<String> get method =>
      $composableBuilder(column: $table.method, builder: (column) => column);

  GeneratedColumn<int> get amount =>
      $composableBuilder(column: $table.amount, builder: (column) => column);

  GeneratedColumn<String> get reference =>
      $composableBuilder(column: $table.reference, builder: (column) => column);

  GeneratedColumn<DateTime> get paymentDate => $composableBuilder(
      column: $table.paymentDate, builder: (column) => column);

  GeneratedColumn<String> get userId =>
      $composableBuilder(column: $table.userId, builder: (column) => column);

  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);

  GeneratedColumn<String> get clientUuid => $composableBuilder(
      column: $table.clientUuid, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$PaymentsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $PaymentsTable,
    Payment,
    $$PaymentsTableFilterComposer,
    $$PaymentsTableOrderingComposer,
    $$PaymentsTableAnnotationComposer,
    $$PaymentsTableCreateCompanionBuilder,
    $$PaymentsTableUpdateCompanionBuilder,
    (Payment, BaseReferences<_$AppDatabase, $PaymentsTable, Payment>),
    Payment,
    PrefetchHooks Function()> {
  $$PaymentsTableTableManager(_$AppDatabase db, $PaymentsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PaymentsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PaymentsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$PaymentsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> paymentType = const Value.absent(),
            Value<String?> saleId = const Value.absent(),
            Value<String?> purchaseId = const Value.absent(),
            Value<String?> installmentId = const Value.absent(),
            Value<String?> repairId = const Value.absent(),
            Value<String?> customerId = const Value.absent(),
            Value<String?> supplierId = const Value.absent(),
            Value<String> method = const Value.absent(),
            Value<int> amount = const Value.absent(),
            Value<String?> reference = const Value.absent(),
            Value<DateTime> paymentDate = const Value.absent(),
            Value<String> userId = const Value.absent(),
            Value<String?> notes = const Value.absent(),
            Value<String?> clientUuid = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              PaymentsCompanion(
            id: id,
            paymentType: paymentType,
            saleId: saleId,
            purchaseId: purchaseId,
            installmentId: installmentId,
            repairId: repairId,
            customerId: customerId,
            supplierId: supplierId,
            method: method,
            amount: amount,
            reference: reference,
            paymentDate: paymentDate,
            userId: userId,
            notes: notes,
            clientUuid: clientUuid,
            createdAt: createdAt,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String paymentType,
            Value<String?> saleId = const Value.absent(),
            Value<String?> purchaseId = const Value.absent(),
            Value<String?> installmentId = const Value.absent(),
            Value<String?> repairId = const Value.absent(),
            Value<String?> customerId = const Value.absent(),
            Value<String?> supplierId = const Value.absent(),
            Value<String> method = const Value.absent(),
            required int amount,
            Value<String?> reference = const Value.absent(),
            Value<DateTime> paymentDate = const Value.absent(),
            required String userId,
            Value<String?> notes = const Value.absent(),
            Value<String?> clientUuid = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              PaymentsCompanion.insert(
            id: id,
            paymentType: paymentType,
            saleId: saleId,
            purchaseId: purchaseId,
            installmentId: installmentId,
            repairId: repairId,
            customerId: customerId,
            supplierId: supplierId,
            method: method,
            amount: amount,
            reference: reference,
            paymentDate: paymentDate,
            userId: userId,
            notes: notes,
            clientUuid: clientUuid,
            createdAt: createdAt,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$PaymentsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $PaymentsTable,
    Payment,
    $$PaymentsTableFilterComposer,
    $$PaymentsTableOrderingComposer,
    $$PaymentsTableAnnotationComposer,
    $$PaymentsTableCreateCompanionBuilder,
    $$PaymentsTableUpdateCompanionBuilder,
    (Payment, BaseReferences<_$AppDatabase, $PaymentsTable, Payment>),
    Payment,
    PrefetchHooks Function()>;
typedef $$LedgerEntriesTableCreateCompanionBuilder = LedgerEntriesCompanion
    Function({
  required String id,
  required String side,
  Value<String?> customerId,
  Value<String?> supplierId,
  required String referenceType,
  Value<String?> referenceId,
  Value<int> debit,
  Value<int> credit,
  Value<int> balanceAfter,
  Value<DateTime> entryDate,
  Value<String?> userId,
  Value<String?> notes,
  Value<DateTime> createdAt,
  Value<int> rowid,
});
typedef $$LedgerEntriesTableUpdateCompanionBuilder = LedgerEntriesCompanion
    Function({
  Value<String> id,
  Value<String> side,
  Value<String?> customerId,
  Value<String?> supplierId,
  Value<String> referenceType,
  Value<String?> referenceId,
  Value<int> debit,
  Value<int> credit,
  Value<int> balanceAfter,
  Value<DateTime> entryDate,
  Value<String?> userId,
  Value<String?> notes,
  Value<DateTime> createdAt,
  Value<int> rowid,
});

class $$LedgerEntriesTableFilterComposer
    extends Composer<_$AppDatabase, $LedgerEntriesTable> {
  $$LedgerEntriesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get side => $composableBuilder(
      column: $table.side, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get customerId => $composableBuilder(
      column: $table.customerId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get supplierId => $composableBuilder(
      column: $table.supplierId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get referenceType => $composableBuilder(
      column: $table.referenceType, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get referenceId => $composableBuilder(
      column: $table.referenceId, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get debit => $composableBuilder(
      column: $table.debit, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get credit => $composableBuilder(
      column: $table.credit, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get balanceAfter => $composableBuilder(
      column: $table.balanceAfter, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get entryDate => $composableBuilder(
      column: $table.entryDate, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get userId => $composableBuilder(
      column: $table.userId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get notes => $composableBuilder(
      column: $table.notes, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));
}

class $$LedgerEntriesTableOrderingComposer
    extends Composer<_$AppDatabase, $LedgerEntriesTable> {
  $$LedgerEntriesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get side => $composableBuilder(
      column: $table.side, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get customerId => $composableBuilder(
      column: $table.customerId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get supplierId => $composableBuilder(
      column: $table.supplierId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get referenceType => $composableBuilder(
      column: $table.referenceType,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get referenceId => $composableBuilder(
      column: $table.referenceId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get debit => $composableBuilder(
      column: $table.debit, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get credit => $composableBuilder(
      column: $table.credit, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get balanceAfter => $composableBuilder(
      column: $table.balanceAfter,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get entryDate => $composableBuilder(
      column: $table.entryDate, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get userId => $composableBuilder(
      column: $table.userId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get notes => $composableBuilder(
      column: $table.notes, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));
}

class $$LedgerEntriesTableAnnotationComposer
    extends Composer<_$AppDatabase, $LedgerEntriesTable> {
  $$LedgerEntriesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get side =>
      $composableBuilder(column: $table.side, builder: (column) => column);

  GeneratedColumn<String> get customerId => $composableBuilder(
      column: $table.customerId, builder: (column) => column);

  GeneratedColumn<String> get supplierId => $composableBuilder(
      column: $table.supplierId, builder: (column) => column);

  GeneratedColumn<String> get referenceType => $composableBuilder(
      column: $table.referenceType, builder: (column) => column);

  GeneratedColumn<String> get referenceId => $composableBuilder(
      column: $table.referenceId, builder: (column) => column);

  GeneratedColumn<int> get debit =>
      $composableBuilder(column: $table.debit, builder: (column) => column);

  GeneratedColumn<int> get credit =>
      $composableBuilder(column: $table.credit, builder: (column) => column);

  GeneratedColumn<int> get balanceAfter => $composableBuilder(
      column: $table.balanceAfter, builder: (column) => column);

  GeneratedColumn<DateTime> get entryDate =>
      $composableBuilder(column: $table.entryDate, builder: (column) => column);

  GeneratedColumn<String> get userId =>
      $composableBuilder(column: $table.userId, builder: (column) => column);

  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$LedgerEntriesTableTableManager extends RootTableManager<
    _$AppDatabase,
    $LedgerEntriesTable,
    LedgerEntry,
    $$LedgerEntriesTableFilterComposer,
    $$LedgerEntriesTableOrderingComposer,
    $$LedgerEntriesTableAnnotationComposer,
    $$LedgerEntriesTableCreateCompanionBuilder,
    $$LedgerEntriesTableUpdateCompanionBuilder,
    (
      LedgerEntry,
      BaseReferences<_$AppDatabase, $LedgerEntriesTable, LedgerEntry>
    ),
    LedgerEntry,
    PrefetchHooks Function()> {
  $$LedgerEntriesTableTableManager(_$AppDatabase db, $LedgerEntriesTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$LedgerEntriesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$LedgerEntriesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$LedgerEntriesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> side = const Value.absent(),
            Value<String?> customerId = const Value.absent(),
            Value<String?> supplierId = const Value.absent(),
            Value<String> referenceType = const Value.absent(),
            Value<String?> referenceId = const Value.absent(),
            Value<int> debit = const Value.absent(),
            Value<int> credit = const Value.absent(),
            Value<int> balanceAfter = const Value.absent(),
            Value<DateTime> entryDate = const Value.absent(),
            Value<String?> userId = const Value.absent(),
            Value<String?> notes = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              LedgerEntriesCompanion(
            id: id,
            side: side,
            customerId: customerId,
            supplierId: supplierId,
            referenceType: referenceType,
            referenceId: referenceId,
            debit: debit,
            credit: credit,
            balanceAfter: balanceAfter,
            entryDate: entryDate,
            userId: userId,
            notes: notes,
            createdAt: createdAt,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String side,
            Value<String?> customerId = const Value.absent(),
            Value<String?> supplierId = const Value.absent(),
            required String referenceType,
            Value<String?> referenceId = const Value.absent(),
            Value<int> debit = const Value.absent(),
            Value<int> credit = const Value.absent(),
            Value<int> balanceAfter = const Value.absent(),
            Value<DateTime> entryDate = const Value.absent(),
            Value<String?> userId = const Value.absent(),
            Value<String?> notes = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              LedgerEntriesCompanion.insert(
            id: id,
            side: side,
            customerId: customerId,
            supplierId: supplierId,
            referenceType: referenceType,
            referenceId: referenceId,
            debit: debit,
            credit: credit,
            balanceAfter: balanceAfter,
            entryDate: entryDate,
            userId: userId,
            notes: notes,
            createdAt: createdAt,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$LedgerEntriesTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $LedgerEntriesTable,
    LedgerEntry,
    $$LedgerEntriesTableFilterComposer,
    $$LedgerEntriesTableOrderingComposer,
    $$LedgerEntriesTableAnnotationComposer,
    $$LedgerEntriesTableCreateCompanionBuilder,
    $$LedgerEntriesTableUpdateCompanionBuilder,
    (
      LedgerEntry,
      BaseReferences<_$AppDatabase, $LedgerEntriesTable, LedgerEntry>
    ),
    LedgerEntry,
    PrefetchHooks Function()>;
typedef $$InstallmentsTableCreateCompanionBuilder = InstallmentsCompanion
    Function({
  required String id,
  required String saleId,
  required String customerId,
  required int totalAmount,
  Value<int> downPayment,
  required int installmentCount,
  required int installmentAmount,
  required DateTime startDate,
  Value<String> status,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
  Value<int> rowid,
});
typedef $$InstallmentsTableUpdateCompanionBuilder = InstallmentsCompanion
    Function({
  Value<String> id,
  Value<String> saleId,
  Value<String> customerId,
  Value<int> totalAmount,
  Value<int> downPayment,
  Value<int> installmentCount,
  Value<int> installmentAmount,
  Value<DateTime> startDate,
  Value<String> status,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
  Value<int> rowid,
});

class $$InstallmentsTableFilterComposer
    extends Composer<_$AppDatabase, $InstallmentsTable> {
  $$InstallmentsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get saleId => $composableBuilder(
      column: $table.saleId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get customerId => $composableBuilder(
      column: $table.customerId, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get totalAmount => $composableBuilder(
      column: $table.totalAmount, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get downPayment => $composableBuilder(
      column: $table.downPayment, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get installmentCount => $composableBuilder(
      column: $table.installmentCount,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get installmentAmount => $composableBuilder(
      column: $table.installmentAmount,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get startDate => $composableBuilder(
      column: $table.startDate, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get status => $composableBuilder(
      column: $table.status, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnFilters(column));
}

class $$InstallmentsTableOrderingComposer
    extends Composer<_$AppDatabase, $InstallmentsTable> {
  $$InstallmentsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get saleId => $composableBuilder(
      column: $table.saleId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get customerId => $composableBuilder(
      column: $table.customerId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get totalAmount => $composableBuilder(
      column: $table.totalAmount, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get downPayment => $composableBuilder(
      column: $table.downPayment, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get installmentCount => $composableBuilder(
      column: $table.installmentCount,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get installmentAmount => $composableBuilder(
      column: $table.installmentAmount,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get startDate => $composableBuilder(
      column: $table.startDate, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get status => $composableBuilder(
      column: $table.status, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnOrderings(column));
}

class $$InstallmentsTableAnnotationComposer
    extends Composer<_$AppDatabase, $InstallmentsTable> {
  $$InstallmentsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get saleId =>
      $composableBuilder(column: $table.saleId, builder: (column) => column);

  GeneratedColumn<String> get customerId => $composableBuilder(
      column: $table.customerId, builder: (column) => column);

  GeneratedColumn<int> get totalAmount => $composableBuilder(
      column: $table.totalAmount, builder: (column) => column);

  GeneratedColumn<int> get downPayment => $composableBuilder(
      column: $table.downPayment, builder: (column) => column);

  GeneratedColumn<int> get installmentCount => $composableBuilder(
      column: $table.installmentCount, builder: (column) => column);

  GeneratedColumn<int> get installmentAmount => $composableBuilder(
      column: $table.installmentAmount, builder: (column) => column);

  GeneratedColumn<DateTime> get startDate =>
      $composableBuilder(column: $table.startDate, builder: (column) => column);

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$InstallmentsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $InstallmentsTable,
    Installment,
    $$InstallmentsTableFilterComposer,
    $$InstallmentsTableOrderingComposer,
    $$InstallmentsTableAnnotationComposer,
    $$InstallmentsTableCreateCompanionBuilder,
    $$InstallmentsTableUpdateCompanionBuilder,
    (
      Installment,
      BaseReferences<_$AppDatabase, $InstallmentsTable, Installment>
    ),
    Installment,
    PrefetchHooks Function()> {
  $$InstallmentsTableTableManager(_$AppDatabase db, $InstallmentsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$InstallmentsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$InstallmentsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$InstallmentsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> saleId = const Value.absent(),
            Value<String> customerId = const Value.absent(),
            Value<int> totalAmount = const Value.absent(),
            Value<int> downPayment = const Value.absent(),
            Value<int> installmentCount = const Value.absent(),
            Value<int> installmentAmount = const Value.absent(),
            Value<DateTime> startDate = const Value.absent(),
            Value<String> status = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              InstallmentsCompanion(
            id: id,
            saleId: saleId,
            customerId: customerId,
            totalAmount: totalAmount,
            downPayment: downPayment,
            installmentCount: installmentCount,
            installmentAmount: installmentAmount,
            startDate: startDate,
            status: status,
            createdAt: createdAt,
            updatedAt: updatedAt,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String saleId,
            required String customerId,
            required int totalAmount,
            Value<int> downPayment = const Value.absent(),
            required int installmentCount,
            required int installmentAmount,
            required DateTime startDate,
            Value<String> status = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              InstallmentsCompanion.insert(
            id: id,
            saleId: saleId,
            customerId: customerId,
            totalAmount: totalAmount,
            downPayment: downPayment,
            installmentCount: installmentCount,
            installmentAmount: installmentAmount,
            startDate: startDate,
            status: status,
            createdAt: createdAt,
            updatedAt: updatedAt,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$InstallmentsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $InstallmentsTable,
    Installment,
    $$InstallmentsTableFilterComposer,
    $$InstallmentsTableOrderingComposer,
    $$InstallmentsTableAnnotationComposer,
    $$InstallmentsTableCreateCompanionBuilder,
    $$InstallmentsTableUpdateCompanionBuilder,
    (
      Installment,
      BaseReferences<_$AppDatabase, $InstallmentsTable, Installment>
    ),
    Installment,
    PrefetchHooks Function()>;
typedef $$InstallmentPaymentsTableCreateCompanionBuilder
    = InstallmentPaymentsCompanion Function({
  required String id,
  required String installmentId,
  required DateTime dueDate,
  required int amount,
  Value<int> paidAmount,
  Value<DateTime?> paidDate,
  Value<String> status,
  Value<bool> reminderSent,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
  Value<int> rowid,
});
typedef $$InstallmentPaymentsTableUpdateCompanionBuilder
    = InstallmentPaymentsCompanion Function({
  Value<String> id,
  Value<String> installmentId,
  Value<DateTime> dueDate,
  Value<int> amount,
  Value<int> paidAmount,
  Value<DateTime?> paidDate,
  Value<String> status,
  Value<bool> reminderSent,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
  Value<int> rowid,
});

class $$InstallmentPaymentsTableFilterComposer
    extends Composer<_$AppDatabase, $InstallmentPaymentsTable> {
  $$InstallmentPaymentsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get installmentId => $composableBuilder(
      column: $table.installmentId, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get dueDate => $composableBuilder(
      column: $table.dueDate, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get amount => $composableBuilder(
      column: $table.amount, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get paidAmount => $composableBuilder(
      column: $table.paidAmount, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get paidDate => $composableBuilder(
      column: $table.paidDate, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get status => $composableBuilder(
      column: $table.status, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get reminderSent => $composableBuilder(
      column: $table.reminderSent, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnFilters(column));
}

class $$InstallmentPaymentsTableOrderingComposer
    extends Composer<_$AppDatabase, $InstallmentPaymentsTable> {
  $$InstallmentPaymentsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get installmentId => $composableBuilder(
      column: $table.installmentId,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get dueDate => $composableBuilder(
      column: $table.dueDate, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get amount => $composableBuilder(
      column: $table.amount, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get paidAmount => $composableBuilder(
      column: $table.paidAmount, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get paidDate => $composableBuilder(
      column: $table.paidDate, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get status => $composableBuilder(
      column: $table.status, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get reminderSent => $composableBuilder(
      column: $table.reminderSent,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnOrderings(column));
}

class $$InstallmentPaymentsTableAnnotationComposer
    extends Composer<_$AppDatabase, $InstallmentPaymentsTable> {
  $$InstallmentPaymentsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get installmentId => $composableBuilder(
      column: $table.installmentId, builder: (column) => column);

  GeneratedColumn<DateTime> get dueDate =>
      $composableBuilder(column: $table.dueDate, builder: (column) => column);

  GeneratedColumn<int> get amount =>
      $composableBuilder(column: $table.amount, builder: (column) => column);

  GeneratedColumn<int> get paidAmount => $composableBuilder(
      column: $table.paidAmount, builder: (column) => column);

  GeneratedColumn<DateTime> get paidDate =>
      $composableBuilder(column: $table.paidDate, builder: (column) => column);

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<bool> get reminderSent => $composableBuilder(
      column: $table.reminderSent, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$InstallmentPaymentsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $InstallmentPaymentsTable,
    InstallmentPayment,
    $$InstallmentPaymentsTableFilterComposer,
    $$InstallmentPaymentsTableOrderingComposer,
    $$InstallmentPaymentsTableAnnotationComposer,
    $$InstallmentPaymentsTableCreateCompanionBuilder,
    $$InstallmentPaymentsTableUpdateCompanionBuilder,
    (
      InstallmentPayment,
      BaseReferences<_$AppDatabase, $InstallmentPaymentsTable,
          InstallmentPayment>
    ),
    InstallmentPayment,
    PrefetchHooks Function()> {
  $$InstallmentPaymentsTableTableManager(
      _$AppDatabase db, $InstallmentPaymentsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$InstallmentPaymentsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$InstallmentPaymentsTableOrderingComposer(
                  $db: db, $table: table),
          createComputedFieldComposer: () =>
              $$InstallmentPaymentsTableAnnotationComposer(
                  $db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> installmentId = const Value.absent(),
            Value<DateTime> dueDate = const Value.absent(),
            Value<int> amount = const Value.absent(),
            Value<int> paidAmount = const Value.absent(),
            Value<DateTime?> paidDate = const Value.absent(),
            Value<String> status = const Value.absent(),
            Value<bool> reminderSent = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              InstallmentPaymentsCompanion(
            id: id,
            installmentId: installmentId,
            dueDate: dueDate,
            amount: amount,
            paidAmount: paidAmount,
            paidDate: paidDate,
            status: status,
            reminderSent: reminderSent,
            createdAt: createdAt,
            updatedAt: updatedAt,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String installmentId,
            required DateTime dueDate,
            required int amount,
            Value<int> paidAmount = const Value.absent(),
            Value<DateTime?> paidDate = const Value.absent(),
            Value<String> status = const Value.absent(),
            Value<bool> reminderSent = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              InstallmentPaymentsCompanion.insert(
            id: id,
            installmentId: installmentId,
            dueDate: dueDate,
            amount: amount,
            paidAmount: paidAmount,
            paidDate: paidDate,
            status: status,
            reminderSent: reminderSent,
            createdAt: createdAt,
            updatedAt: updatedAt,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$InstallmentPaymentsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $InstallmentPaymentsTable,
    InstallmentPayment,
    $$InstallmentPaymentsTableFilterComposer,
    $$InstallmentPaymentsTableOrderingComposer,
    $$InstallmentPaymentsTableAnnotationComposer,
    $$InstallmentPaymentsTableCreateCompanionBuilder,
    $$InstallmentPaymentsTableUpdateCompanionBuilder,
    (
      InstallmentPayment,
      BaseReferences<_$AppDatabase, $InstallmentPaymentsTable,
          InstallmentPayment>
    ),
    InstallmentPayment,
    PrefetchHooks Function()>;
typedef $$RepairsTableCreateCompanionBuilder = RepairsCompanion Function({
  required String id,
  required String jobNo,
  Value<String?> customerId,
  required String customerName,
  required String customerPhone,
  Value<String?> deviceBrand,
  Value<String?> deviceModel,
  Value<String?> imei,
  required String faultDescription,
  Value<int> estimatedCost,
  Value<int> finalCost,
  Value<int> advancePaid,
  Value<String> status,
  Value<DateTime> receivedDate,
  Value<DateTime?> readyDate,
  Value<DateTime?> deliveredDate,
  required String userId,
  Value<String?> notes,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
  Value<int> rowid,
});
typedef $$RepairsTableUpdateCompanionBuilder = RepairsCompanion Function({
  Value<String> id,
  Value<String> jobNo,
  Value<String?> customerId,
  Value<String> customerName,
  Value<String> customerPhone,
  Value<String?> deviceBrand,
  Value<String?> deviceModel,
  Value<String?> imei,
  Value<String> faultDescription,
  Value<int> estimatedCost,
  Value<int> finalCost,
  Value<int> advancePaid,
  Value<String> status,
  Value<DateTime> receivedDate,
  Value<DateTime?> readyDate,
  Value<DateTime?> deliveredDate,
  Value<String> userId,
  Value<String?> notes,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
  Value<int> rowid,
});

class $$RepairsTableFilterComposer
    extends Composer<_$AppDatabase, $RepairsTable> {
  $$RepairsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get jobNo => $composableBuilder(
      column: $table.jobNo, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get customerId => $composableBuilder(
      column: $table.customerId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get customerName => $composableBuilder(
      column: $table.customerName, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get customerPhone => $composableBuilder(
      column: $table.customerPhone, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get deviceBrand => $composableBuilder(
      column: $table.deviceBrand, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get deviceModel => $composableBuilder(
      column: $table.deviceModel, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get imei => $composableBuilder(
      column: $table.imei, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get faultDescription => $composableBuilder(
      column: $table.faultDescription,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get estimatedCost => $composableBuilder(
      column: $table.estimatedCost, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get finalCost => $composableBuilder(
      column: $table.finalCost, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get advancePaid => $composableBuilder(
      column: $table.advancePaid, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get status => $composableBuilder(
      column: $table.status, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get receivedDate => $composableBuilder(
      column: $table.receivedDate, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get readyDate => $composableBuilder(
      column: $table.readyDate, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get deliveredDate => $composableBuilder(
      column: $table.deliveredDate, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get userId => $composableBuilder(
      column: $table.userId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get notes => $composableBuilder(
      column: $table.notes, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnFilters(column));
}

class $$RepairsTableOrderingComposer
    extends Composer<_$AppDatabase, $RepairsTable> {
  $$RepairsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get jobNo => $composableBuilder(
      column: $table.jobNo, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get customerId => $composableBuilder(
      column: $table.customerId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get customerName => $composableBuilder(
      column: $table.customerName,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get customerPhone => $composableBuilder(
      column: $table.customerPhone,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get deviceBrand => $composableBuilder(
      column: $table.deviceBrand, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get deviceModel => $composableBuilder(
      column: $table.deviceModel, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get imei => $composableBuilder(
      column: $table.imei, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get faultDescription => $composableBuilder(
      column: $table.faultDescription,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get estimatedCost => $composableBuilder(
      column: $table.estimatedCost,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get finalCost => $composableBuilder(
      column: $table.finalCost, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get advancePaid => $composableBuilder(
      column: $table.advancePaid, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get status => $composableBuilder(
      column: $table.status, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get receivedDate => $composableBuilder(
      column: $table.receivedDate,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get readyDate => $composableBuilder(
      column: $table.readyDate, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get deliveredDate => $composableBuilder(
      column: $table.deliveredDate,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get userId => $composableBuilder(
      column: $table.userId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get notes => $composableBuilder(
      column: $table.notes, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnOrderings(column));
}

class $$RepairsTableAnnotationComposer
    extends Composer<_$AppDatabase, $RepairsTable> {
  $$RepairsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get jobNo =>
      $composableBuilder(column: $table.jobNo, builder: (column) => column);

  GeneratedColumn<String> get customerId => $composableBuilder(
      column: $table.customerId, builder: (column) => column);

  GeneratedColumn<String> get customerName => $composableBuilder(
      column: $table.customerName, builder: (column) => column);

  GeneratedColumn<String> get customerPhone => $composableBuilder(
      column: $table.customerPhone, builder: (column) => column);

  GeneratedColumn<String> get deviceBrand => $composableBuilder(
      column: $table.deviceBrand, builder: (column) => column);

  GeneratedColumn<String> get deviceModel => $composableBuilder(
      column: $table.deviceModel, builder: (column) => column);

  GeneratedColumn<String> get imei =>
      $composableBuilder(column: $table.imei, builder: (column) => column);

  GeneratedColumn<String> get faultDescription => $composableBuilder(
      column: $table.faultDescription, builder: (column) => column);

  GeneratedColumn<int> get estimatedCost => $composableBuilder(
      column: $table.estimatedCost, builder: (column) => column);

  GeneratedColumn<int> get finalCost =>
      $composableBuilder(column: $table.finalCost, builder: (column) => column);

  GeneratedColumn<int> get advancePaid => $composableBuilder(
      column: $table.advancePaid, builder: (column) => column);

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<DateTime> get receivedDate => $composableBuilder(
      column: $table.receivedDate, builder: (column) => column);

  GeneratedColumn<DateTime> get readyDate =>
      $composableBuilder(column: $table.readyDate, builder: (column) => column);

  GeneratedColumn<DateTime> get deliveredDate => $composableBuilder(
      column: $table.deliveredDate, builder: (column) => column);

  GeneratedColumn<String> get userId =>
      $composableBuilder(column: $table.userId, builder: (column) => column);

  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$RepairsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $RepairsTable,
    Repair,
    $$RepairsTableFilterComposer,
    $$RepairsTableOrderingComposer,
    $$RepairsTableAnnotationComposer,
    $$RepairsTableCreateCompanionBuilder,
    $$RepairsTableUpdateCompanionBuilder,
    (Repair, BaseReferences<_$AppDatabase, $RepairsTable, Repair>),
    Repair,
    PrefetchHooks Function()> {
  $$RepairsTableTableManager(_$AppDatabase db, $RepairsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$RepairsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$RepairsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$RepairsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> jobNo = const Value.absent(),
            Value<String?> customerId = const Value.absent(),
            Value<String> customerName = const Value.absent(),
            Value<String> customerPhone = const Value.absent(),
            Value<String?> deviceBrand = const Value.absent(),
            Value<String?> deviceModel = const Value.absent(),
            Value<String?> imei = const Value.absent(),
            Value<String> faultDescription = const Value.absent(),
            Value<int> estimatedCost = const Value.absent(),
            Value<int> finalCost = const Value.absent(),
            Value<int> advancePaid = const Value.absent(),
            Value<String> status = const Value.absent(),
            Value<DateTime> receivedDate = const Value.absent(),
            Value<DateTime?> readyDate = const Value.absent(),
            Value<DateTime?> deliveredDate = const Value.absent(),
            Value<String> userId = const Value.absent(),
            Value<String?> notes = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              RepairsCompanion(
            id: id,
            jobNo: jobNo,
            customerId: customerId,
            customerName: customerName,
            customerPhone: customerPhone,
            deviceBrand: deviceBrand,
            deviceModel: deviceModel,
            imei: imei,
            faultDescription: faultDescription,
            estimatedCost: estimatedCost,
            finalCost: finalCost,
            advancePaid: advancePaid,
            status: status,
            receivedDate: receivedDate,
            readyDate: readyDate,
            deliveredDate: deliveredDate,
            userId: userId,
            notes: notes,
            createdAt: createdAt,
            updatedAt: updatedAt,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String jobNo,
            Value<String?> customerId = const Value.absent(),
            required String customerName,
            required String customerPhone,
            Value<String?> deviceBrand = const Value.absent(),
            Value<String?> deviceModel = const Value.absent(),
            Value<String?> imei = const Value.absent(),
            required String faultDescription,
            Value<int> estimatedCost = const Value.absent(),
            Value<int> finalCost = const Value.absent(),
            Value<int> advancePaid = const Value.absent(),
            Value<String> status = const Value.absent(),
            Value<DateTime> receivedDate = const Value.absent(),
            Value<DateTime?> readyDate = const Value.absent(),
            Value<DateTime?> deliveredDate = const Value.absent(),
            required String userId,
            Value<String?> notes = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              RepairsCompanion.insert(
            id: id,
            jobNo: jobNo,
            customerId: customerId,
            customerName: customerName,
            customerPhone: customerPhone,
            deviceBrand: deviceBrand,
            deviceModel: deviceModel,
            imei: imei,
            faultDescription: faultDescription,
            estimatedCost: estimatedCost,
            finalCost: finalCost,
            advancePaid: advancePaid,
            status: status,
            receivedDate: receivedDate,
            readyDate: readyDate,
            deliveredDate: deliveredDate,
            userId: userId,
            notes: notes,
            createdAt: createdAt,
            updatedAt: updatedAt,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$RepairsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $RepairsTable,
    Repair,
    $$RepairsTableFilterComposer,
    $$RepairsTableOrderingComposer,
    $$RepairsTableAnnotationComposer,
    $$RepairsTableCreateCompanionBuilder,
    $$RepairsTableUpdateCompanionBuilder,
    (Repair, BaseReferences<_$AppDatabase, $RepairsTable, Repair>),
    Repair,
    PrefetchHooks Function()>;
typedef $$RepairPartsTableCreateCompanionBuilder = RepairPartsCompanion
    Function({
  required String id,
  required String repairId,
  Value<String?> productId,
  Value<String?> variantId,
  required String name,
  Value<int> quantity,
  required int unitPrice,
  required int total,
  Value<DateTime> createdAt,
  Value<int> rowid,
});
typedef $$RepairPartsTableUpdateCompanionBuilder = RepairPartsCompanion
    Function({
  Value<String> id,
  Value<String> repairId,
  Value<String?> productId,
  Value<String?> variantId,
  Value<String> name,
  Value<int> quantity,
  Value<int> unitPrice,
  Value<int> total,
  Value<DateTime> createdAt,
  Value<int> rowid,
});

class $$RepairPartsTableFilterComposer
    extends Composer<_$AppDatabase, $RepairPartsTable> {
  $$RepairPartsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get repairId => $composableBuilder(
      column: $table.repairId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get productId => $composableBuilder(
      column: $table.productId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get variantId => $composableBuilder(
      column: $table.variantId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get quantity => $composableBuilder(
      column: $table.quantity, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get unitPrice => $composableBuilder(
      column: $table.unitPrice, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get total => $composableBuilder(
      column: $table.total, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));
}

class $$RepairPartsTableOrderingComposer
    extends Composer<_$AppDatabase, $RepairPartsTable> {
  $$RepairPartsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get repairId => $composableBuilder(
      column: $table.repairId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get productId => $composableBuilder(
      column: $table.productId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get variantId => $composableBuilder(
      column: $table.variantId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get quantity => $composableBuilder(
      column: $table.quantity, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get unitPrice => $composableBuilder(
      column: $table.unitPrice, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get total => $composableBuilder(
      column: $table.total, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));
}

class $$RepairPartsTableAnnotationComposer
    extends Composer<_$AppDatabase, $RepairPartsTable> {
  $$RepairPartsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get repairId =>
      $composableBuilder(column: $table.repairId, builder: (column) => column);

  GeneratedColumn<String> get productId =>
      $composableBuilder(column: $table.productId, builder: (column) => column);

  GeneratedColumn<String> get variantId =>
      $composableBuilder(column: $table.variantId, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<int> get quantity =>
      $composableBuilder(column: $table.quantity, builder: (column) => column);

  GeneratedColumn<int> get unitPrice =>
      $composableBuilder(column: $table.unitPrice, builder: (column) => column);

  GeneratedColumn<int> get total =>
      $composableBuilder(column: $table.total, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$RepairPartsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $RepairPartsTable,
    RepairPart,
    $$RepairPartsTableFilterComposer,
    $$RepairPartsTableOrderingComposer,
    $$RepairPartsTableAnnotationComposer,
    $$RepairPartsTableCreateCompanionBuilder,
    $$RepairPartsTableUpdateCompanionBuilder,
    (RepairPart, BaseReferences<_$AppDatabase, $RepairPartsTable, RepairPart>),
    RepairPart,
    PrefetchHooks Function()> {
  $$RepairPartsTableTableManager(_$AppDatabase db, $RepairPartsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$RepairPartsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$RepairPartsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$RepairPartsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> repairId = const Value.absent(),
            Value<String?> productId = const Value.absent(),
            Value<String?> variantId = const Value.absent(),
            Value<String> name = const Value.absent(),
            Value<int> quantity = const Value.absent(),
            Value<int> unitPrice = const Value.absent(),
            Value<int> total = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              RepairPartsCompanion(
            id: id,
            repairId: repairId,
            productId: productId,
            variantId: variantId,
            name: name,
            quantity: quantity,
            unitPrice: unitPrice,
            total: total,
            createdAt: createdAt,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String repairId,
            Value<String?> productId = const Value.absent(),
            Value<String?> variantId = const Value.absent(),
            required String name,
            Value<int> quantity = const Value.absent(),
            required int unitPrice,
            required int total,
            Value<DateTime> createdAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              RepairPartsCompanion.insert(
            id: id,
            repairId: repairId,
            productId: productId,
            variantId: variantId,
            name: name,
            quantity: quantity,
            unitPrice: unitPrice,
            total: total,
            createdAt: createdAt,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$RepairPartsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $RepairPartsTable,
    RepairPart,
    $$RepairPartsTableFilterComposer,
    $$RepairPartsTableOrderingComposer,
    $$RepairPartsTableAnnotationComposer,
    $$RepairPartsTableCreateCompanionBuilder,
    $$RepairPartsTableUpdateCompanionBuilder,
    (RepairPart, BaseReferences<_$AppDatabase, $RepairPartsTable, RepairPart>),
    RepairPart,
    PrefetchHooks Function()>;
typedef $$ServiceSalesTableCreateCompanionBuilder = ServiceSalesCompanion
    Function({
  required String id,
  required String serviceType,
  Value<String?> customerPhone,
  Value<String?> provider,
  required int amount,
  Value<int> commission,
  required String userId,
  Value<DateTime> saleDate,
  Value<DateTime> createdAt,
  Value<int> rowid,
});
typedef $$ServiceSalesTableUpdateCompanionBuilder = ServiceSalesCompanion
    Function({
  Value<String> id,
  Value<String> serviceType,
  Value<String?> customerPhone,
  Value<String?> provider,
  Value<int> amount,
  Value<int> commission,
  Value<String> userId,
  Value<DateTime> saleDate,
  Value<DateTime> createdAt,
  Value<int> rowid,
});

class $$ServiceSalesTableFilterComposer
    extends Composer<_$AppDatabase, $ServiceSalesTable> {
  $$ServiceSalesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get serviceType => $composableBuilder(
      column: $table.serviceType, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get customerPhone => $composableBuilder(
      column: $table.customerPhone, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get provider => $composableBuilder(
      column: $table.provider, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get amount => $composableBuilder(
      column: $table.amount, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get commission => $composableBuilder(
      column: $table.commission, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get userId => $composableBuilder(
      column: $table.userId, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get saleDate => $composableBuilder(
      column: $table.saleDate, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));
}

class $$ServiceSalesTableOrderingComposer
    extends Composer<_$AppDatabase, $ServiceSalesTable> {
  $$ServiceSalesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get serviceType => $composableBuilder(
      column: $table.serviceType, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get customerPhone => $composableBuilder(
      column: $table.customerPhone,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get provider => $composableBuilder(
      column: $table.provider, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get amount => $composableBuilder(
      column: $table.amount, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get commission => $composableBuilder(
      column: $table.commission, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get userId => $composableBuilder(
      column: $table.userId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get saleDate => $composableBuilder(
      column: $table.saleDate, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));
}

class $$ServiceSalesTableAnnotationComposer
    extends Composer<_$AppDatabase, $ServiceSalesTable> {
  $$ServiceSalesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get serviceType => $composableBuilder(
      column: $table.serviceType, builder: (column) => column);

  GeneratedColumn<String> get customerPhone => $composableBuilder(
      column: $table.customerPhone, builder: (column) => column);

  GeneratedColumn<String> get provider =>
      $composableBuilder(column: $table.provider, builder: (column) => column);

  GeneratedColumn<int> get amount =>
      $composableBuilder(column: $table.amount, builder: (column) => column);

  GeneratedColumn<int> get commission => $composableBuilder(
      column: $table.commission, builder: (column) => column);

  GeneratedColumn<String> get userId =>
      $composableBuilder(column: $table.userId, builder: (column) => column);

  GeneratedColumn<DateTime> get saleDate =>
      $composableBuilder(column: $table.saleDate, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$ServiceSalesTableTableManager extends RootTableManager<
    _$AppDatabase,
    $ServiceSalesTable,
    ServiceSale,
    $$ServiceSalesTableFilterComposer,
    $$ServiceSalesTableOrderingComposer,
    $$ServiceSalesTableAnnotationComposer,
    $$ServiceSalesTableCreateCompanionBuilder,
    $$ServiceSalesTableUpdateCompanionBuilder,
    (
      ServiceSale,
      BaseReferences<_$AppDatabase, $ServiceSalesTable, ServiceSale>
    ),
    ServiceSale,
    PrefetchHooks Function()> {
  $$ServiceSalesTableTableManager(_$AppDatabase db, $ServiceSalesTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ServiceSalesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ServiceSalesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ServiceSalesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> serviceType = const Value.absent(),
            Value<String?> customerPhone = const Value.absent(),
            Value<String?> provider = const Value.absent(),
            Value<int> amount = const Value.absent(),
            Value<int> commission = const Value.absent(),
            Value<String> userId = const Value.absent(),
            Value<DateTime> saleDate = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              ServiceSalesCompanion(
            id: id,
            serviceType: serviceType,
            customerPhone: customerPhone,
            provider: provider,
            amount: amount,
            commission: commission,
            userId: userId,
            saleDate: saleDate,
            createdAt: createdAt,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String serviceType,
            Value<String?> customerPhone = const Value.absent(),
            Value<String?> provider = const Value.absent(),
            required int amount,
            Value<int> commission = const Value.absent(),
            required String userId,
            Value<DateTime> saleDate = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              ServiceSalesCompanion.insert(
            id: id,
            serviceType: serviceType,
            customerPhone: customerPhone,
            provider: provider,
            amount: amount,
            commission: commission,
            userId: userId,
            saleDate: saleDate,
            createdAt: createdAt,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$ServiceSalesTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $ServiceSalesTable,
    ServiceSale,
    $$ServiceSalesTableFilterComposer,
    $$ServiceSalesTableOrderingComposer,
    $$ServiceSalesTableAnnotationComposer,
    $$ServiceSalesTableCreateCompanionBuilder,
    $$ServiceSalesTableUpdateCompanionBuilder,
    (
      ServiceSale,
      BaseReferences<_$AppDatabase, $ServiceSalesTable, ServiceSale>
    ),
    ServiceSale,
    PrefetchHooks Function()>;
typedef $$ExpensesTableCreateCompanionBuilder = ExpensesCompanion Function({
  required String id,
  Value<String?> branchId,
  required String category,
  required int amount,
  Value<DateTime> expenseDate,
  Value<String?> description,
  required String userId,
  Value<DateTime> createdAt,
  Value<int> rowid,
});
typedef $$ExpensesTableUpdateCompanionBuilder = ExpensesCompanion Function({
  Value<String> id,
  Value<String?> branchId,
  Value<String> category,
  Value<int> amount,
  Value<DateTime> expenseDate,
  Value<String?> description,
  Value<String> userId,
  Value<DateTime> createdAt,
  Value<int> rowid,
});

class $$ExpensesTableFilterComposer
    extends Composer<_$AppDatabase, $ExpensesTable> {
  $$ExpensesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get branchId => $composableBuilder(
      column: $table.branchId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get category => $composableBuilder(
      column: $table.category, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get amount => $composableBuilder(
      column: $table.amount, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get expenseDate => $composableBuilder(
      column: $table.expenseDate, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get description => $composableBuilder(
      column: $table.description, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get userId => $composableBuilder(
      column: $table.userId, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));
}

class $$ExpensesTableOrderingComposer
    extends Composer<_$AppDatabase, $ExpensesTable> {
  $$ExpensesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get branchId => $composableBuilder(
      column: $table.branchId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get category => $composableBuilder(
      column: $table.category, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get amount => $composableBuilder(
      column: $table.amount, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get expenseDate => $composableBuilder(
      column: $table.expenseDate, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get description => $composableBuilder(
      column: $table.description, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get userId => $composableBuilder(
      column: $table.userId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));
}

class $$ExpensesTableAnnotationComposer
    extends Composer<_$AppDatabase, $ExpensesTable> {
  $$ExpensesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get branchId =>
      $composableBuilder(column: $table.branchId, builder: (column) => column);

  GeneratedColumn<String> get category =>
      $composableBuilder(column: $table.category, builder: (column) => column);

  GeneratedColumn<int> get amount =>
      $composableBuilder(column: $table.amount, builder: (column) => column);

  GeneratedColumn<DateTime> get expenseDate => $composableBuilder(
      column: $table.expenseDate, builder: (column) => column);

  GeneratedColumn<String> get description => $composableBuilder(
      column: $table.description, builder: (column) => column);

  GeneratedColumn<String> get userId =>
      $composableBuilder(column: $table.userId, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$ExpensesTableTableManager extends RootTableManager<
    _$AppDatabase,
    $ExpensesTable,
    Expense,
    $$ExpensesTableFilterComposer,
    $$ExpensesTableOrderingComposer,
    $$ExpensesTableAnnotationComposer,
    $$ExpensesTableCreateCompanionBuilder,
    $$ExpensesTableUpdateCompanionBuilder,
    (Expense, BaseReferences<_$AppDatabase, $ExpensesTable, Expense>),
    Expense,
    PrefetchHooks Function()> {
  $$ExpensesTableTableManager(_$AppDatabase db, $ExpensesTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ExpensesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ExpensesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ExpensesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String?> branchId = const Value.absent(),
            Value<String> category = const Value.absent(),
            Value<int> amount = const Value.absent(),
            Value<DateTime> expenseDate = const Value.absent(),
            Value<String?> description = const Value.absent(),
            Value<String> userId = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              ExpensesCompanion(
            id: id,
            branchId: branchId,
            category: category,
            amount: amount,
            expenseDate: expenseDate,
            description: description,
            userId: userId,
            createdAt: createdAt,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            Value<String?> branchId = const Value.absent(),
            required String category,
            required int amount,
            Value<DateTime> expenseDate = const Value.absent(),
            Value<String?> description = const Value.absent(),
            required String userId,
            Value<DateTime> createdAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              ExpensesCompanion.insert(
            id: id,
            branchId: branchId,
            category: category,
            amount: amount,
            expenseDate: expenseDate,
            description: description,
            userId: userId,
            createdAt: createdAt,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$ExpensesTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $ExpensesTable,
    Expense,
    $$ExpensesTableFilterComposer,
    $$ExpensesTableOrderingComposer,
    $$ExpensesTableAnnotationComposer,
    $$ExpensesTableCreateCompanionBuilder,
    $$ExpensesTableUpdateCompanionBuilder,
    (Expense, BaseReferences<_$AppDatabase, $ExpensesTable, Expense>),
    Expense,
    PrefetchHooks Function()>;
typedef $$StaffTableCreateCompanionBuilder = StaffCompanion Function({
  required String id,
  required String name,
  Value<String?> phone,
  Value<String?> role,
  Value<int> salary,
  Value<bool> isActive,
  Value<DateTime> createdAt,
  Value<int> rowid,
});
typedef $$StaffTableUpdateCompanionBuilder = StaffCompanion Function({
  Value<String> id,
  Value<String> name,
  Value<String?> phone,
  Value<String?> role,
  Value<int> salary,
  Value<bool> isActive,
  Value<DateTime> createdAt,
  Value<int> rowid,
});

class $$StaffTableFilterComposer extends Composer<_$AppDatabase, $StaffTable> {
  $$StaffTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get phone => $composableBuilder(
      column: $table.phone, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get role => $composableBuilder(
      column: $table.role, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get salary => $composableBuilder(
      column: $table.salary, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isActive => $composableBuilder(
      column: $table.isActive, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));
}

class $$StaffTableOrderingComposer
    extends Composer<_$AppDatabase, $StaffTable> {
  $$StaffTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get phone => $composableBuilder(
      column: $table.phone, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get role => $composableBuilder(
      column: $table.role, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get salary => $composableBuilder(
      column: $table.salary, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isActive => $composableBuilder(
      column: $table.isActive, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));
}

class $$StaffTableAnnotationComposer
    extends Composer<_$AppDatabase, $StaffTable> {
  $$StaffTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get phone =>
      $composableBuilder(column: $table.phone, builder: (column) => column);

  GeneratedColumn<String> get role =>
      $composableBuilder(column: $table.role, builder: (column) => column);

  GeneratedColumn<int> get salary =>
      $composableBuilder(column: $table.salary, builder: (column) => column);

  GeneratedColumn<bool> get isActive =>
      $composableBuilder(column: $table.isActive, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$StaffTableTableManager extends RootTableManager<
    _$AppDatabase,
    $StaffTable,
    StaffData,
    $$StaffTableFilterComposer,
    $$StaffTableOrderingComposer,
    $$StaffTableAnnotationComposer,
    $$StaffTableCreateCompanionBuilder,
    $$StaffTableUpdateCompanionBuilder,
    (StaffData, BaseReferences<_$AppDatabase, $StaffTable, StaffData>),
    StaffData,
    PrefetchHooks Function()> {
  $$StaffTableTableManager(_$AppDatabase db, $StaffTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$StaffTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$StaffTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$StaffTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> name = const Value.absent(),
            Value<String?> phone = const Value.absent(),
            Value<String?> role = const Value.absent(),
            Value<int> salary = const Value.absent(),
            Value<bool> isActive = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              StaffCompanion(
            id: id,
            name: name,
            phone: phone,
            role: role,
            salary: salary,
            isActive: isActive,
            createdAt: createdAt,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String name,
            Value<String?> phone = const Value.absent(),
            Value<String?> role = const Value.absent(),
            Value<int> salary = const Value.absent(),
            Value<bool> isActive = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              StaffCompanion.insert(
            id: id,
            name: name,
            phone: phone,
            role: role,
            salary: salary,
            isActive: isActive,
            createdAt: createdAt,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$StaffTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $StaffTable,
    StaffData,
    $$StaffTableFilterComposer,
    $$StaffTableOrderingComposer,
    $$StaffTableAnnotationComposer,
    $$StaffTableCreateCompanionBuilder,
    $$StaffTableUpdateCompanionBuilder,
    (StaffData, BaseReferences<_$AppDatabase, $StaffTable, StaffData>),
    StaffData,
    PrefetchHooks Function()>;
typedef $$SalaryPaymentsTableCreateCompanionBuilder = SalaryPaymentsCompanion
    Function({
  required String id,
  required String staffId,
  required String month,
  required int amount,
  Value<int> advance,
  Value<DateTime> paidDate,
  required String userId,
  Value<String?> notes,
  Value<DateTime> createdAt,
  Value<int> rowid,
});
typedef $$SalaryPaymentsTableUpdateCompanionBuilder = SalaryPaymentsCompanion
    Function({
  Value<String> id,
  Value<String> staffId,
  Value<String> month,
  Value<int> amount,
  Value<int> advance,
  Value<DateTime> paidDate,
  Value<String> userId,
  Value<String?> notes,
  Value<DateTime> createdAt,
  Value<int> rowid,
});

class $$SalaryPaymentsTableFilterComposer
    extends Composer<_$AppDatabase, $SalaryPaymentsTable> {
  $$SalaryPaymentsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get staffId => $composableBuilder(
      column: $table.staffId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get month => $composableBuilder(
      column: $table.month, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get amount => $composableBuilder(
      column: $table.amount, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get advance => $composableBuilder(
      column: $table.advance, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get paidDate => $composableBuilder(
      column: $table.paidDate, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get userId => $composableBuilder(
      column: $table.userId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get notes => $composableBuilder(
      column: $table.notes, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));
}

class $$SalaryPaymentsTableOrderingComposer
    extends Composer<_$AppDatabase, $SalaryPaymentsTable> {
  $$SalaryPaymentsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get staffId => $composableBuilder(
      column: $table.staffId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get month => $composableBuilder(
      column: $table.month, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get amount => $composableBuilder(
      column: $table.amount, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get advance => $composableBuilder(
      column: $table.advance, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get paidDate => $composableBuilder(
      column: $table.paidDate, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get userId => $composableBuilder(
      column: $table.userId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get notes => $composableBuilder(
      column: $table.notes, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));
}

class $$SalaryPaymentsTableAnnotationComposer
    extends Composer<_$AppDatabase, $SalaryPaymentsTable> {
  $$SalaryPaymentsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get staffId =>
      $composableBuilder(column: $table.staffId, builder: (column) => column);

  GeneratedColumn<String> get month =>
      $composableBuilder(column: $table.month, builder: (column) => column);

  GeneratedColumn<int> get amount =>
      $composableBuilder(column: $table.amount, builder: (column) => column);

  GeneratedColumn<int> get advance =>
      $composableBuilder(column: $table.advance, builder: (column) => column);

  GeneratedColumn<DateTime> get paidDate =>
      $composableBuilder(column: $table.paidDate, builder: (column) => column);

  GeneratedColumn<String> get userId =>
      $composableBuilder(column: $table.userId, builder: (column) => column);

  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$SalaryPaymentsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $SalaryPaymentsTable,
    SalaryPayment,
    $$SalaryPaymentsTableFilterComposer,
    $$SalaryPaymentsTableOrderingComposer,
    $$SalaryPaymentsTableAnnotationComposer,
    $$SalaryPaymentsTableCreateCompanionBuilder,
    $$SalaryPaymentsTableUpdateCompanionBuilder,
    (
      SalaryPayment,
      BaseReferences<_$AppDatabase, $SalaryPaymentsTable, SalaryPayment>
    ),
    SalaryPayment,
    PrefetchHooks Function()> {
  $$SalaryPaymentsTableTableManager(
      _$AppDatabase db, $SalaryPaymentsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SalaryPaymentsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SalaryPaymentsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SalaryPaymentsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> staffId = const Value.absent(),
            Value<String> month = const Value.absent(),
            Value<int> amount = const Value.absent(),
            Value<int> advance = const Value.absent(),
            Value<DateTime> paidDate = const Value.absent(),
            Value<String> userId = const Value.absent(),
            Value<String?> notes = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              SalaryPaymentsCompanion(
            id: id,
            staffId: staffId,
            month: month,
            amount: amount,
            advance: advance,
            paidDate: paidDate,
            userId: userId,
            notes: notes,
            createdAt: createdAt,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String staffId,
            required String month,
            required int amount,
            Value<int> advance = const Value.absent(),
            Value<DateTime> paidDate = const Value.absent(),
            required String userId,
            Value<String?> notes = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              SalaryPaymentsCompanion.insert(
            id: id,
            staffId: staffId,
            month: month,
            amount: amount,
            advance: advance,
            paidDate: paidDate,
            userId: userId,
            notes: notes,
            createdAt: createdAt,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$SalaryPaymentsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $SalaryPaymentsTable,
    SalaryPayment,
    $$SalaryPaymentsTableFilterComposer,
    $$SalaryPaymentsTableOrderingComposer,
    $$SalaryPaymentsTableAnnotationComposer,
    $$SalaryPaymentsTableCreateCompanionBuilder,
    $$SalaryPaymentsTableUpdateCompanionBuilder,
    (
      SalaryPayment,
      BaseReferences<_$AppDatabase, $SalaryPaymentsTable, SalaryPayment>
    ),
    SalaryPayment,
    PrefetchHooks Function()>;
typedef $$CashRegistersTableCreateCompanionBuilder = CashRegistersCompanion
    Function({
  required String id,
  Value<String?> branchId,
  required DateTime registerDate,
  Value<int> openingCash,
  Value<int?> closingCash,
  Value<int?> expectedCash,
  Value<int?> difference,
  Value<String> status,
  Value<String?> openedBy,
  Value<String?> closedBy,
  Value<String?> notes,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
  Value<int> rowid,
});
typedef $$CashRegistersTableUpdateCompanionBuilder = CashRegistersCompanion
    Function({
  Value<String> id,
  Value<String?> branchId,
  Value<DateTime> registerDate,
  Value<int> openingCash,
  Value<int?> closingCash,
  Value<int?> expectedCash,
  Value<int?> difference,
  Value<String> status,
  Value<String?> openedBy,
  Value<String?> closedBy,
  Value<String?> notes,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
  Value<int> rowid,
});

class $$CashRegistersTableFilterComposer
    extends Composer<_$AppDatabase, $CashRegistersTable> {
  $$CashRegistersTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get branchId => $composableBuilder(
      column: $table.branchId, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get registerDate => $composableBuilder(
      column: $table.registerDate, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get openingCash => $composableBuilder(
      column: $table.openingCash, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get closingCash => $composableBuilder(
      column: $table.closingCash, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get expectedCash => $composableBuilder(
      column: $table.expectedCash, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get difference => $composableBuilder(
      column: $table.difference, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get status => $composableBuilder(
      column: $table.status, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get openedBy => $composableBuilder(
      column: $table.openedBy, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get closedBy => $composableBuilder(
      column: $table.closedBy, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get notes => $composableBuilder(
      column: $table.notes, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnFilters(column));
}

class $$CashRegistersTableOrderingComposer
    extends Composer<_$AppDatabase, $CashRegistersTable> {
  $$CashRegistersTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get branchId => $composableBuilder(
      column: $table.branchId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get registerDate => $composableBuilder(
      column: $table.registerDate,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get openingCash => $composableBuilder(
      column: $table.openingCash, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get closingCash => $composableBuilder(
      column: $table.closingCash, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get expectedCash => $composableBuilder(
      column: $table.expectedCash,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get difference => $composableBuilder(
      column: $table.difference, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get status => $composableBuilder(
      column: $table.status, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get openedBy => $composableBuilder(
      column: $table.openedBy, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get closedBy => $composableBuilder(
      column: $table.closedBy, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get notes => $composableBuilder(
      column: $table.notes, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnOrderings(column));
}

class $$CashRegistersTableAnnotationComposer
    extends Composer<_$AppDatabase, $CashRegistersTable> {
  $$CashRegistersTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get branchId =>
      $composableBuilder(column: $table.branchId, builder: (column) => column);

  GeneratedColumn<DateTime> get registerDate => $composableBuilder(
      column: $table.registerDate, builder: (column) => column);

  GeneratedColumn<int> get openingCash => $composableBuilder(
      column: $table.openingCash, builder: (column) => column);

  GeneratedColumn<int> get closingCash => $composableBuilder(
      column: $table.closingCash, builder: (column) => column);

  GeneratedColumn<int> get expectedCash => $composableBuilder(
      column: $table.expectedCash, builder: (column) => column);

  GeneratedColumn<int> get difference => $composableBuilder(
      column: $table.difference, builder: (column) => column);

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<String> get openedBy =>
      $composableBuilder(column: $table.openedBy, builder: (column) => column);

  GeneratedColumn<String> get closedBy =>
      $composableBuilder(column: $table.closedBy, builder: (column) => column);

  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$CashRegistersTableTableManager extends RootTableManager<
    _$AppDatabase,
    $CashRegistersTable,
    CashRegister,
    $$CashRegistersTableFilterComposer,
    $$CashRegistersTableOrderingComposer,
    $$CashRegistersTableAnnotationComposer,
    $$CashRegistersTableCreateCompanionBuilder,
    $$CashRegistersTableUpdateCompanionBuilder,
    (
      CashRegister,
      BaseReferences<_$AppDatabase, $CashRegistersTable, CashRegister>
    ),
    CashRegister,
    PrefetchHooks Function()> {
  $$CashRegistersTableTableManager(_$AppDatabase db, $CashRegistersTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CashRegistersTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CashRegistersTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CashRegistersTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String?> branchId = const Value.absent(),
            Value<DateTime> registerDate = const Value.absent(),
            Value<int> openingCash = const Value.absent(),
            Value<int?> closingCash = const Value.absent(),
            Value<int?> expectedCash = const Value.absent(),
            Value<int?> difference = const Value.absent(),
            Value<String> status = const Value.absent(),
            Value<String?> openedBy = const Value.absent(),
            Value<String?> closedBy = const Value.absent(),
            Value<String?> notes = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              CashRegistersCompanion(
            id: id,
            branchId: branchId,
            registerDate: registerDate,
            openingCash: openingCash,
            closingCash: closingCash,
            expectedCash: expectedCash,
            difference: difference,
            status: status,
            openedBy: openedBy,
            closedBy: closedBy,
            notes: notes,
            createdAt: createdAt,
            updatedAt: updatedAt,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            Value<String?> branchId = const Value.absent(),
            required DateTime registerDate,
            Value<int> openingCash = const Value.absent(),
            Value<int?> closingCash = const Value.absent(),
            Value<int?> expectedCash = const Value.absent(),
            Value<int?> difference = const Value.absent(),
            Value<String> status = const Value.absent(),
            Value<String?> openedBy = const Value.absent(),
            Value<String?> closedBy = const Value.absent(),
            Value<String?> notes = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              CashRegistersCompanion.insert(
            id: id,
            branchId: branchId,
            registerDate: registerDate,
            openingCash: openingCash,
            closingCash: closingCash,
            expectedCash: expectedCash,
            difference: difference,
            status: status,
            openedBy: openedBy,
            closedBy: closedBy,
            notes: notes,
            createdAt: createdAt,
            updatedAt: updatedAt,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$CashRegistersTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $CashRegistersTable,
    CashRegister,
    $$CashRegistersTableFilterComposer,
    $$CashRegistersTableOrderingComposer,
    $$CashRegistersTableAnnotationComposer,
    $$CashRegistersTableCreateCompanionBuilder,
    $$CashRegistersTableUpdateCompanionBuilder,
    (
      CashRegister,
      BaseReferences<_$AppDatabase, $CashRegistersTable, CashRegister>
    ),
    CashRegister,
    PrefetchHooks Function()>;
typedef $$CashMovementsTableCreateCompanionBuilder = CashMovementsCompanion
    Function({
  required String id,
  required String registerId,
  required String type,
  required int amount,
  Value<String?> reason,
  required String userId,
  Value<DateTime> createdAt,
  Value<int> rowid,
});
typedef $$CashMovementsTableUpdateCompanionBuilder = CashMovementsCompanion
    Function({
  Value<String> id,
  Value<String> registerId,
  Value<String> type,
  Value<int> amount,
  Value<String?> reason,
  Value<String> userId,
  Value<DateTime> createdAt,
  Value<int> rowid,
});

class $$CashMovementsTableFilterComposer
    extends Composer<_$AppDatabase, $CashMovementsTable> {
  $$CashMovementsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get registerId => $composableBuilder(
      column: $table.registerId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get type => $composableBuilder(
      column: $table.type, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get amount => $composableBuilder(
      column: $table.amount, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get reason => $composableBuilder(
      column: $table.reason, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get userId => $composableBuilder(
      column: $table.userId, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));
}

class $$CashMovementsTableOrderingComposer
    extends Composer<_$AppDatabase, $CashMovementsTable> {
  $$CashMovementsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get registerId => $composableBuilder(
      column: $table.registerId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get type => $composableBuilder(
      column: $table.type, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get amount => $composableBuilder(
      column: $table.amount, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get reason => $composableBuilder(
      column: $table.reason, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get userId => $composableBuilder(
      column: $table.userId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));
}

class $$CashMovementsTableAnnotationComposer
    extends Composer<_$AppDatabase, $CashMovementsTable> {
  $$CashMovementsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get registerId => $composableBuilder(
      column: $table.registerId, builder: (column) => column);

  GeneratedColumn<String> get type =>
      $composableBuilder(column: $table.type, builder: (column) => column);

  GeneratedColumn<int> get amount =>
      $composableBuilder(column: $table.amount, builder: (column) => column);

  GeneratedColumn<String> get reason =>
      $composableBuilder(column: $table.reason, builder: (column) => column);

  GeneratedColumn<String> get userId =>
      $composableBuilder(column: $table.userId, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$CashMovementsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $CashMovementsTable,
    CashMovement,
    $$CashMovementsTableFilterComposer,
    $$CashMovementsTableOrderingComposer,
    $$CashMovementsTableAnnotationComposer,
    $$CashMovementsTableCreateCompanionBuilder,
    $$CashMovementsTableUpdateCompanionBuilder,
    (
      CashMovement,
      BaseReferences<_$AppDatabase, $CashMovementsTable, CashMovement>
    ),
    CashMovement,
    PrefetchHooks Function()> {
  $$CashMovementsTableTableManager(_$AppDatabase db, $CashMovementsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CashMovementsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CashMovementsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CashMovementsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> registerId = const Value.absent(),
            Value<String> type = const Value.absent(),
            Value<int> amount = const Value.absent(),
            Value<String?> reason = const Value.absent(),
            Value<String> userId = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              CashMovementsCompanion(
            id: id,
            registerId: registerId,
            type: type,
            amount: amount,
            reason: reason,
            userId: userId,
            createdAt: createdAt,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String registerId,
            required String type,
            required int amount,
            Value<String?> reason = const Value.absent(),
            required String userId,
            Value<DateTime> createdAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              CashMovementsCompanion.insert(
            id: id,
            registerId: registerId,
            type: type,
            amount: amount,
            reason: reason,
            userId: userId,
            createdAt: createdAt,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$CashMovementsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $CashMovementsTable,
    CashMovement,
    $$CashMovementsTableFilterComposer,
    $$CashMovementsTableOrderingComposer,
    $$CashMovementsTableAnnotationComposer,
    $$CashMovementsTableCreateCompanionBuilder,
    $$CashMovementsTableUpdateCompanionBuilder,
    (
      CashMovement,
      BaseReferences<_$AppDatabase, $CashMovementsTable, CashMovement>
    ),
    CashMovement,
    PrefetchHooks Function()>;
typedef $$AuditLogsTableCreateCompanionBuilder = AuditLogsCompanion Function({
  required String id,
  Value<String?> userId,
  required String action,
  required String entityType,
  Value<String?> entityId,
  Value<String?> oldValues,
  Value<String?> newValues,
  Value<String?> ipAddress,
  Value<String?> deviceInfo,
  Value<String> prevHash,
  Value<String> hash,
  Value<DateTime> createdAt,
  Value<int> rowid,
});
typedef $$AuditLogsTableUpdateCompanionBuilder = AuditLogsCompanion Function({
  Value<String> id,
  Value<String?> userId,
  Value<String> action,
  Value<String> entityType,
  Value<String?> entityId,
  Value<String?> oldValues,
  Value<String?> newValues,
  Value<String?> ipAddress,
  Value<String?> deviceInfo,
  Value<String> prevHash,
  Value<String> hash,
  Value<DateTime> createdAt,
  Value<int> rowid,
});

class $$AuditLogsTableFilterComposer
    extends Composer<_$AppDatabase, $AuditLogsTable> {
  $$AuditLogsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get userId => $composableBuilder(
      column: $table.userId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get action => $composableBuilder(
      column: $table.action, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get entityType => $composableBuilder(
      column: $table.entityType, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get entityId => $composableBuilder(
      column: $table.entityId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get oldValues => $composableBuilder(
      column: $table.oldValues, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get newValues => $composableBuilder(
      column: $table.newValues, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get ipAddress => $composableBuilder(
      column: $table.ipAddress, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get deviceInfo => $composableBuilder(
      column: $table.deviceInfo, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get prevHash => $composableBuilder(
      column: $table.prevHash, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get hash => $composableBuilder(
      column: $table.hash, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));
}

class $$AuditLogsTableOrderingComposer
    extends Composer<_$AppDatabase, $AuditLogsTable> {
  $$AuditLogsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get userId => $composableBuilder(
      column: $table.userId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get action => $composableBuilder(
      column: $table.action, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get entityType => $composableBuilder(
      column: $table.entityType, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get entityId => $composableBuilder(
      column: $table.entityId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get oldValues => $composableBuilder(
      column: $table.oldValues, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get newValues => $composableBuilder(
      column: $table.newValues, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get ipAddress => $composableBuilder(
      column: $table.ipAddress, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get deviceInfo => $composableBuilder(
      column: $table.deviceInfo, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get prevHash => $composableBuilder(
      column: $table.prevHash, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get hash => $composableBuilder(
      column: $table.hash, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));
}

class $$AuditLogsTableAnnotationComposer
    extends Composer<_$AppDatabase, $AuditLogsTable> {
  $$AuditLogsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get userId =>
      $composableBuilder(column: $table.userId, builder: (column) => column);

  GeneratedColumn<String> get action =>
      $composableBuilder(column: $table.action, builder: (column) => column);

  GeneratedColumn<String> get entityType => $composableBuilder(
      column: $table.entityType, builder: (column) => column);

  GeneratedColumn<String> get entityId =>
      $composableBuilder(column: $table.entityId, builder: (column) => column);

  GeneratedColumn<String> get oldValues =>
      $composableBuilder(column: $table.oldValues, builder: (column) => column);

  GeneratedColumn<String> get newValues =>
      $composableBuilder(column: $table.newValues, builder: (column) => column);

  GeneratedColumn<String> get ipAddress =>
      $composableBuilder(column: $table.ipAddress, builder: (column) => column);

  GeneratedColumn<String> get deviceInfo => $composableBuilder(
      column: $table.deviceInfo, builder: (column) => column);

  GeneratedColumn<String> get prevHash =>
      $composableBuilder(column: $table.prevHash, builder: (column) => column);

  GeneratedColumn<String> get hash =>
      $composableBuilder(column: $table.hash, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$AuditLogsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $AuditLogsTable,
    AuditLog,
    $$AuditLogsTableFilterComposer,
    $$AuditLogsTableOrderingComposer,
    $$AuditLogsTableAnnotationComposer,
    $$AuditLogsTableCreateCompanionBuilder,
    $$AuditLogsTableUpdateCompanionBuilder,
    (AuditLog, BaseReferences<_$AppDatabase, $AuditLogsTable, AuditLog>),
    AuditLog,
    PrefetchHooks Function()> {
  $$AuditLogsTableTableManager(_$AppDatabase db, $AuditLogsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$AuditLogsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$AuditLogsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$AuditLogsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String?> userId = const Value.absent(),
            Value<String> action = const Value.absent(),
            Value<String> entityType = const Value.absent(),
            Value<String?> entityId = const Value.absent(),
            Value<String?> oldValues = const Value.absent(),
            Value<String?> newValues = const Value.absent(),
            Value<String?> ipAddress = const Value.absent(),
            Value<String?> deviceInfo = const Value.absent(),
            Value<String> prevHash = const Value.absent(),
            Value<String> hash = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              AuditLogsCompanion(
            id: id,
            userId: userId,
            action: action,
            entityType: entityType,
            entityId: entityId,
            oldValues: oldValues,
            newValues: newValues,
            ipAddress: ipAddress,
            deviceInfo: deviceInfo,
            prevHash: prevHash,
            hash: hash,
            createdAt: createdAt,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            Value<String?> userId = const Value.absent(),
            required String action,
            required String entityType,
            Value<String?> entityId = const Value.absent(),
            Value<String?> oldValues = const Value.absent(),
            Value<String?> newValues = const Value.absent(),
            Value<String?> ipAddress = const Value.absent(),
            Value<String?> deviceInfo = const Value.absent(),
            Value<String> prevHash = const Value.absent(),
            Value<String> hash = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              AuditLogsCompanion.insert(
            id: id,
            userId: userId,
            action: action,
            entityType: entityType,
            entityId: entityId,
            oldValues: oldValues,
            newValues: newValues,
            ipAddress: ipAddress,
            deviceInfo: deviceInfo,
            prevHash: prevHash,
            hash: hash,
            createdAt: createdAt,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$AuditLogsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $AuditLogsTable,
    AuditLog,
    $$AuditLogsTableFilterComposer,
    $$AuditLogsTableOrderingComposer,
    $$AuditLogsTableAnnotationComposer,
    $$AuditLogsTableCreateCompanionBuilder,
    $$AuditLogsTableUpdateCompanionBuilder,
    (AuditLog, BaseReferences<_$AppDatabase, $AuditLogsTable, AuditLog>),
    AuditLog,
    PrefetchHooks Function()>;
typedef $$AppSettingsTableCreateCompanionBuilder = AppSettingsCompanion
    Function({
  required String key,
  required String value,
  Value<DateTime> updatedAt,
  Value<int> rowid,
});
typedef $$AppSettingsTableUpdateCompanionBuilder = AppSettingsCompanion
    Function({
  Value<String> key,
  Value<String> value,
  Value<DateTime> updatedAt,
  Value<int> rowid,
});

class $$AppSettingsTableFilterComposer
    extends Composer<_$AppDatabase, $AppSettingsTable> {
  $$AppSettingsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get key => $composableBuilder(
      column: $table.key, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get value => $composableBuilder(
      column: $table.value, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnFilters(column));
}

class $$AppSettingsTableOrderingComposer
    extends Composer<_$AppDatabase, $AppSettingsTable> {
  $$AppSettingsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get key => $composableBuilder(
      column: $table.key, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get value => $composableBuilder(
      column: $table.value, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnOrderings(column));
}

class $$AppSettingsTableAnnotationComposer
    extends Composer<_$AppDatabase, $AppSettingsTable> {
  $$AppSettingsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get key =>
      $composableBuilder(column: $table.key, builder: (column) => column);

  GeneratedColumn<String> get value =>
      $composableBuilder(column: $table.value, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$AppSettingsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $AppSettingsTable,
    AppSetting,
    $$AppSettingsTableFilterComposer,
    $$AppSettingsTableOrderingComposer,
    $$AppSettingsTableAnnotationComposer,
    $$AppSettingsTableCreateCompanionBuilder,
    $$AppSettingsTableUpdateCompanionBuilder,
    (AppSetting, BaseReferences<_$AppDatabase, $AppSettingsTable, AppSetting>),
    AppSetting,
    PrefetchHooks Function()> {
  $$AppSettingsTableTableManager(_$AppDatabase db, $AppSettingsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$AppSettingsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$AppSettingsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$AppSettingsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> key = const Value.absent(),
            Value<String> value = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              AppSettingsCompanion(
            key: key,
            value: value,
            updatedAt: updatedAt,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String key,
            required String value,
            Value<DateTime> updatedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              AppSettingsCompanion.insert(
            key: key,
            value: value,
            updatedAt: updatedAt,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$AppSettingsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $AppSettingsTable,
    AppSetting,
    $$AppSettingsTableFilterComposer,
    $$AppSettingsTableOrderingComposer,
    $$AppSettingsTableAnnotationComposer,
    $$AppSettingsTableCreateCompanionBuilder,
    $$AppSettingsTableUpdateCompanionBuilder,
    (AppSetting, BaseReferences<_$AppDatabase, $AppSettingsTable, AppSetting>),
    AppSetting,
    PrefetchHooks Function()>;
typedef $$CountersTableCreateCompanionBuilder = CountersCompanion Function({
  Value<String?> branchId,
  required String name,
  required String prefix,
  Value<int> lastValue,
  Value<int> rowid,
});
typedef $$CountersTableUpdateCompanionBuilder = CountersCompanion Function({
  Value<String?> branchId,
  Value<String> name,
  Value<String> prefix,
  Value<int> lastValue,
  Value<int> rowid,
});

class $$CountersTableFilterComposer
    extends Composer<_$AppDatabase, $CountersTable> {
  $$CountersTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get branchId => $composableBuilder(
      column: $table.branchId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get prefix => $composableBuilder(
      column: $table.prefix, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get lastValue => $composableBuilder(
      column: $table.lastValue, builder: (column) => ColumnFilters(column));
}

class $$CountersTableOrderingComposer
    extends Composer<_$AppDatabase, $CountersTable> {
  $$CountersTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get branchId => $composableBuilder(
      column: $table.branchId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get prefix => $composableBuilder(
      column: $table.prefix, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get lastValue => $composableBuilder(
      column: $table.lastValue, builder: (column) => ColumnOrderings(column));
}

class $$CountersTableAnnotationComposer
    extends Composer<_$AppDatabase, $CountersTable> {
  $$CountersTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get branchId =>
      $composableBuilder(column: $table.branchId, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get prefix =>
      $composableBuilder(column: $table.prefix, builder: (column) => column);

  GeneratedColumn<int> get lastValue =>
      $composableBuilder(column: $table.lastValue, builder: (column) => column);
}

class $$CountersTableTableManager extends RootTableManager<
    _$AppDatabase,
    $CountersTable,
    Counter,
    $$CountersTableFilterComposer,
    $$CountersTableOrderingComposer,
    $$CountersTableAnnotationComposer,
    $$CountersTableCreateCompanionBuilder,
    $$CountersTableUpdateCompanionBuilder,
    (Counter, BaseReferences<_$AppDatabase, $CountersTable, Counter>),
    Counter,
    PrefetchHooks Function()> {
  $$CountersTableTableManager(_$AppDatabase db, $CountersTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CountersTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CountersTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CountersTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String?> branchId = const Value.absent(),
            Value<String> name = const Value.absent(),
            Value<String> prefix = const Value.absent(),
            Value<int> lastValue = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              CountersCompanion(
            branchId: branchId,
            name: name,
            prefix: prefix,
            lastValue: lastValue,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            Value<String?> branchId = const Value.absent(),
            required String name,
            required String prefix,
            Value<int> lastValue = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              CountersCompanion.insert(
            branchId: branchId,
            name: name,
            prefix: prefix,
            lastValue: lastValue,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$CountersTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $CountersTable,
    Counter,
    $$CountersTableFilterComposer,
    $$CountersTableOrderingComposer,
    $$CountersTableAnnotationComposer,
    $$CountersTableCreateCompanionBuilder,
    $$CountersTableUpdateCompanionBuilder,
    (Counter, BaseReferences<_$AppDatabase, $CountersTable, Counter>),
    Counter,
    PrefetchHooks Function()>;
typedef $$SyncLogsTableCreateCompanionBuilder = SyncLogsCompanion Function({
  required String id,
  required String deviceId,
  Value<String?> userId,
  required String entityType,
  Value<String?> entityId,
  required String action,
  Value<String?> detail,
  Value<DateTime> createdAt,
  Value<int> rowid,
});
typedef $$SyncLogsTableUpdateCompanionBuilder = SyncLogsCompanion Function({
  Value<String> id,
  Value<String> deviceId,
  Value<String?> userId,
  Value<String> entityType,
  Value<String?> entityId,
  Value<String> action,
  Value<String?> detail,
  Value<DateTime> createdAt,
  Value<int> rowid,
});

class $$SyncLogsTableFilterComposer
    extends Composer<_$AppDatabase, $SyncLogsTable> {
  $$SyncLogsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get deviceId => $composableBuilder(
      column: $table.deviceId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get userId => $composableBuilder(
      column: $table.userId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get entityType => $composableBuilder(
      column: $table.entityType, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get entityId => $composableBuilder(
      column: $table.entityId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get action => $composableBuilder(
      column: $table.action, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get detail => $composableBuilder(
      column: $table.detail, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));
}

class $$SyncLogsTableOrderingComposer
    extends Composer<_$AppDatabase, $SyncLogsTable> {
  $$SyncLogsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get deviceId => $composableBuilder(
      column: $table.deviceId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get userId => $composableBuilder(
      column: $table.userId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get entityType => $composableBuilder(
      column: $table.entityType, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get entityId => $composableBuilder(
      column: $table.entityId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get action => $composableBuilder(
      column: $table.action, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get detail => $composableBuilder(
      column: $table.detail, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));
}

class $$SyncLogsTableAnnotationComposer
    extends Composer<_$AppDatabase, $SyncLogsTable> {
  $$SyncLogsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get deviceId =>
      $composableBuilder(column: $table.deviceId, builder: (column) => column);

  GeneratedColumn<String> get userId =>
      $composableBuilder(column: $table.userId, builder: (column) => column);

  GeneratedColumn<String> get entityType => $composableBuilder(
      column: $table.entityType, builder: (column) => column);

  GeneratedColumn<String> get entityId =>
      $composableBuilder(column: $table.entityId, builder: (column) => column);

  GeneratedColumn<String> get action =>
      $composableBuilder(column: $table.action, builder: (column) => column);

  GeneratedColumn<String> get detail =>
      $composableBuilder(column: $table.detail, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$SyncLogsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $SyncLogsTable,
    SyncLog,
    $$SyncLogsTableFilterComposer,
    $$SyncLogsTableOrderingComposer,
    $$SyncLogsTableAnnotationComposer,
    $$SyncLogsTableCreateCompanionBuilder,
    $$SyncLogsTableUpdateCompanionBuilder,
    (SyncLog, BaseReferences<_$AppDatabase, $SyncLogsTable, SyncLog>),
    SyncLog,
    PrefetchHooks Function()> {
  $$SyncLogsTableTableManager(_$AppDatabase db, $SyncLogsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SyncLogsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SyncLogsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SyncLogsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> deviceId = const Value.absent(),
            Value<String?> userId = const Value.absent(),
            Value<String> entityType = const Value.absent(),
            Value<String?> entityId = const Value.absent(),
            Value<String> action = const Value.absent(),
            Value<String?> detail = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              SyncLogsCompanion(
            id: id,
            deviceId: deviceId,
            userId: userId,
            entityType: entityType,
            entityId: entityId,
            action: action,
            detail: detail,
            createdAt: createdAt,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String deviceId,
            Value<String?> userId = const Value.absent(),
            required String entityType,
            Value<String?> entityId = const Value.absent(),
            required String action,
            Value<String?> detail = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              SyncLogsCompanion.insert(
            id: id,
            deviceId: deviceId,
            userId: userId,
            entityType: entityType,
            entityId: entityId,
            action: action,
            detail: detail,
            createdAt: createdAt,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$SyncLogsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $SyncLogsTable,
    SyncLog,
    $$SyncLogsTableFilterComposer,
    $$SyncLogsTableOrderingComposer,
    $$SyncLogsTableAnnotationComposer,
    $$SyncLogsTableCreateCompanionBuilder,
    $$SyncLogsTableUpdateCompanionBuilder,
    (SyncLog, BaseReferences<_$AppDatabase, $SyncLogsTable, SyncLog>),
    SyncLog,
    PrefetchHooks Function()>;
typedef $$OutboxTableCreateCompanionBuilder = OutboxCompanion Function({
  required String id,
  required String clientUuid,
  required String entityTable,
  required String operation,
  required String payload,
  Value<bool> synced,
  Value<DateTime> createdAt,
  Value<int> rowid,
});
typedef $$OutboxTableUpdateCompanionBuilder = OutboxCompanion Function({
  Value<String> id,
  Value<String> clientUuid,
  Value<String> entityTable,
  Value<String> operation,
  Value<String> payload,
  Value<bool> synced,
  Value<DateTime> createdAt,
  Value<int> rowid,
});

class $$OutboxTableFilterComposer
    extends Composer<_$AppDatabase, $OutboxTable> {
  $$OutboxTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get clientUuid => $composableBuilder(
      column: $table.clientUuid, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get entityTable => $composableBuilder(
      column: $table.entityTable, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get operation => $composableBuilder(
      column: $table.operation, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get payload => $composableBuilder(
      column: $table.payload, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get synced => $composableBuilder(
      column: $table.synced, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));
}

class $$OutboxTableOrderingComposer
    extends Composer<_$AppDatabase, $OutboxTable> {
  $$OutboxTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get clientUuid => $composableBuilder(
      column: $table.clientUuid, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get entityTable => $composableBuilder(
      column: $table.entityTable, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get operation => $composableBuilder(
      column: $table.operation, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get payload => $composableBuilder(
      column: $table.payload, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get synced => $composableBuilder(
      column: $table.synced, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));
}

class $$OutboxTableAnnotationComposer
    extends Composer<_$AppDatabase, $OutboxTable> {
  $$OutboxTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get clientUuid => $composableBuilder(
      column: $table.clientUuid, builder: (column) => column);

  GeneratedColumn<String> get entityTable => $composableBuilder(
      column: $table.entityTable, builder: (column) => column);

  GeneratedColumn<String> get operation =>
      $composableBuilder(column: $table.operation, builder: (column) => column);

  GeneratedColumn<String> get payload =>
      $composableBuilder(column: $table.payload, builder: (column) => column);

  GeneratedColumn<bool> get synced =>
      $composableBuilder(column: $table.synced, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$OutboxTableTableManager extends RootTableManager<
    _$AppDatabase,
    $OutboxTable,
    OutboxData,
    $$OutboxTableFilterComposer,
    $$OutboxTableOrderingComposer,
    $$OutboxTableAnnotationComposer,
    $$OutboxTableCreateCompanionBuilder,
    $$OutboxTableUpdateCompanionBuilder,
    (OutboxData, BaseReferences<_$AppDatabase, $OutboxTable, OutboxData>),
    OutboxData,
    PrefetchHooks Function()> {
  $$OutboxTableTableManager(_$AppDatabase db, $OutboxTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$OutboxTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$OutboxTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$OutboxTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> clientUuid = const Value.absent(),
            Value<String> entityTable = const Value.absent(),
            Value<String> operation = const Value.absent(),
            Value<String> payload = const Value.absent(),
            Value<bool> synced = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              OutboxCompanion(
            id: id,
            clientUuid: clientUuid,
            entityTable: entityTable,
            operation: operation,
            payload: payload,
            synced: synced,
            createdAt: createdAt,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String clientUuid,
            required String entityTable,
            required String operation,
            required String payload,
            Value<bool> synced = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              OutboxCompanion.insert(
            id: id,
            clientUuid: clientUuid,
            entityTable: entityTable,
            operation: operation,
            payload: payload,
            synced: synced,
            createdAt: createdAt,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$OutboxTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $OutboxTable,
    OutboxData,
    $$OutboxTableFilterComposer,
    $$OutboxTableOrderingComposer,
    $$OutboxTableAnnotationComposer,
    $$OutboxTableCreateCompanionBuilder,
    $$OutboxTableUpdateCompanionBuilder,
    (OutboxData, BaseReferences<_$AppDatabase, $OutboxTable, OutboxData>),
    OutboxData,
    PrefetchHooks Function()>;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$BranchesTableTableManager get branches =>
      $$BranchesTableTableManager(_db, _db.branches);
  $$RolesTableTableManager get roles =>
      $$RolesTableTableManager(_db, _db.roles);
  $$UsersTableTableManager get users =>
      $$UsersTableTableManager(_db, _db.users);
  $$CategoriesTableTableManager get categories =>
      $$CategoriesTableTableManager(_db, _db.categories);
  $$BrandsTableTableManager get brands =>
      $$BrandsTableTableManager(_db, _db.brands);
  $$ProductsTableTableManager get products =>
      $$ProductsTableTableManager(_db, _db.products);
  $$ProductVariantsTableTableManager get productVariants =>
      $$ProductVariantsTableTableManager(_db, _db.productVariants);
  $$ImeiItemsTableTableManager get imeiItems =>
      $$ImeiItemsTableTableManager(_db, _db.imeiItems);
  $$CustomersTableTableManager get customers =>
      $$CustomersTableTableManager(_db, _db.customers);
  $$SuppliersTableTableManager get suppliers =>
      $$SuppliersTableTableManager(_db, _db.suppliers);
  $$SalesTableTableManager get sales =>
      $$SalesTableTableManager(_db, _db.sales);
  $$SaleItemsTableTableManager get saleItems =>
      $$SaleItemsTableTableManager(_db, _db.saleItems);
  $$SaleReturnsTableTableManager get saleReturns =>
      $$SaleReturnsTableTableManager(_db, _db.saleReturns);
  $$HeldBillsTableTableManager get heldBills =>
      $$HeldBillsTableTableManager(_db, _db.heldBills);
  $$PurchasesTableTableManager get purchases =>
      $$PurchasesTableTableManager(_db, _db.purchases);
  $$PurchaseItemsTableTableManager get purchaseItems =>
      $$PurchaseItemsTableTableManager(_db, _db.purchaseItems);
  $$PurchaseReturnsTableTableManager get purchaseReturns =>
      $$PurchaseReturnsTableTableManager(_db, _db.purchaseReturns);
  $$PaymentsTableTableManager get payments =>
      $$PaymentsTableTableManager(_db, _db.payments);
  $$LedgerEntriesTableTableManager get ledgerEntries =>
      $$LedgerEntriesTableTableManager(_db, _db.ledgerEntries);
  $$InstallmentsTableTableManager get installments =>
      $$InstallmentsTableTableManager(_db, _db.installments);
  $$InstallmentPaymentsTableTableManager get installmentPayments =>
      $$InstallmentPaymentsTableTableManager(_db, _db.installmentPayments);
  $$RepairsTableTableManager get repairs =>
      $$RepairsTableTableManager(_db, _db.repairs);
  $$RepairPartsTableTableManager get repairParts =>
      $$RepairPartsTableTableManager(_db, _db.repairParts);
  $$ServiceSalesTableTableManager get serviceSales =>
      $$ServiceSalesTableTableManager(_db, _db.serviceSales);
  $$ExpensesTableTableManager get expenses =>
      $$ExpensesTableTableManager(_db, _db.expenses);
  $$StaffTableTableManager get staff =>
      $$StaffTableTableManager(_db, _db.staff);
  $$SalaryPaymentsTableTableManager get salaryPayments =>
      $$SalaryPaymentsTableTableManager(_db, _db.salaryPayments);
  $$CashRegistersTableTableManager get cashRegisters =>
      $$CashRegistersTableTableManager(_db, _db.cashRegisters);
  $$CashMovementsTableTableManager get cashMovements =>
      $$CashMovementsTableTableManager(_db, _db.cashMovements);
  $$AuditLogsTableTableManager get auditLogs =>
      $$AuditLogsTableTableManager(_db, _db.auditLogs);
  $$AppSettingsTableTableManager get appSettings =>
      $$AppSettingsTableTableManager(_db, _db.appSettings);
  $$CountersTableTableManager get counters =>
      $$CountersTableTableManager(_db, _db.counters);
  $$SyncLogsTableTableManager get syncLogs =>
      $$SyncLogsTableTableManager(_db, _db.syncLogs);
  $$OutboxTableTableManager get outbox =>
      $$OutboxTableTableManager(_db, _db.outbox);
}
