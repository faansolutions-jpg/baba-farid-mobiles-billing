// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'catalog_database.dart';

// ignore_for_file: type=lint
class $CatalogVersionsTable extends CatalogVersions
    with TableInfo<$CatalogVersionsTable, CatalogVersionRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CatalogVersionsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _versionMeta =
      const VerificationMeta('version');
  @override
  late final GeneratedColumn<String> version = GeneratedColumn<String>(
      'version', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _appliedAtMeta =
      const VerificationMeta('appliedAt');
  @override
  late final GeneratedColumn<DateTime> appliedAt = GeneratedColumn<DateTime>(
      'applied_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  static const VerificationMeta _itemCountMeta =
      const VerificationMeta('itemCount');
  @override
  late final GeneratedColumn<int> itemCount = GeneratedColumn<int>(
      'item_count', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _notesMeta = const VerificationMeta('notes');
  @override
  late final GeneratedColumn<String> notes = GeneratedColumn<String>(
      'notes', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns => [version, appliedAt, itemCount, notes];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'catalog_versions';
  @override
  VerificationContext validateIntegrity(Insertable<CatalogVersionRow> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('version')) {
      context.handle(_versionMeta,
          version.isAcceptableOrUnknown(data['version']!, _versionMeta));
    } else if (isInserting) {
      context.missing(_versionMeta);
    }
    if (data.containsKey('applied_at')) {
      context.handle(_appliedAtMeta,
          appliedAt.isAcceptableOrUnknown(data['applied_at']!, _appliedAtMeta));
    }
    if (data.containsKey('item_count')) {
      context.handle(_itemCountMeta,
          itemCount.isAcceptableOrUnknown(data['item_count']!, _itemCountMeta));
    }
    if (data.containsKey('notes')) {
      context.handle(
          _notesMeta, notes.isAcceptableOrUnknown(data['notes']!, _notesMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {version};
  @override
  CatalogVersionRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CatalogVersionRow(
      version: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}version'])!,
      appliedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}applied_at'])!,
      itemCount: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}item_count'])!,
      notes: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}notes']),
    );
  }

  @override
  $CatalogVersionsTable createAlias(String alias) {
    return $CatalogVersionsTable(attachedDatabase, alias);
  }
}

class CatalogVersionRow extends DataClass
    implements Insertable<CatalogVersionRow> {
  final String version;
  final DateTime appliedAt;
  final int itemCount;
  final String? notes;
  const CatalogVersionRow(
      {required this.version,
      required this.appliedAt,
      required this.itemCount,
      this.notes});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['version'] = Variable<String>(version);
    map['applied_at'] = Variable<DateTime>(appliedAt);
    map['item_count'] = Variable<int>(itemCount);
    if (!nullToAbsent || notes != null) {
      map['notes'] = Variable<String>(notes);
    }
    return map;
  }

  CatalogVersionsCompanion toCompanion(bool nullToAbsent) {
    return CatalogVersionsCompanion(
      version: Value(version),
      appliedAt: Value(appliedAt),
      itemCount: Value(itemCount),
      notes:
          notes == null && nullToAbsent ? const Value.absent() : Value(notes),
    );
  }

  factory CatalogVersionRow.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CatalogVersionRow(
      version: serializer.fromJson<String>(json['version']),
      appliedAt: serializer.fromJson<DateTime>(json['appliedAt']),
      itemCount: serializer.fromJson<int>(json['itemCount']),
      notes: serializer.fromJson<String?>(json['notes']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'version': serializer.toJson<String>(version),
      'appliedAt': serializer.toJson<DateTime>(appliedAt),
      'itemCount': serializer.toJson<int>(itemCount),
      'notes': serializer.toJson<String?>(notes),
    };
  }

  CatalogVersionRow copyWith(
          {String? version,
          DateTime? appliedAt,
          int? itemCount,
          Value<String?> notes = const Value.absent()}) =>
      CatalogVersionRow(
        version: version ?? this.version,
        appliedAt: appliedAt ?? this.appliedAt,
        itemCount: itemCount ?? this.itemCount,
        notes: notes.present ? notes.value : this.notes,
      );
  CatalogVersionRow copyWithCompanion(CatalogVersionsCompanion data) {
    return CatalogVersionRow(
      version: data.version.present ? data.version.value : this.version,
      appliedAt: data.appliedAt.present ? data.appliedAt.value : this.appliedAt,
      itemCount: data.itemCount.present ? data.itemCount.value : this.itemCount,
      notes: data.notes.present ? data.notes.value : this.notes,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CatalogVersionRow(')
          ..write('version: $version, ')
          ..write('appliedAt: $appliedAt, ')
          ..write('itemCount: $itemCount, ')
          ..write('notes: $notes')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(version, appliedAt, itemCount, notes);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CatalogVersionRow &&
          other.version == this.version &&
          other.appliedAt == this.appliedAt &&
          other.itemCount == this.itemCount &&
          other.notes == this.notes);
}

class CatalogVersionsCompanion extends UpdateCompanion<CatalogVersionRow> {
  final Value<String> version;
  final Value<DateTime> appliedAt;
  final Value<int> itemCount;
  final Value<String?> notes;
  final Value<int> rowid;
  const CatalogVersionsCompanion({
    this.version = const Value.absent(),
    this.appliedAt = const Value.absent(),
    this.itemCount = const Value.absent(),
    this.notes = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  CatalogVersionsCompanion.insert({
    required String version,
    this.appliedAt = const Value.absent(),
    this.itemCount = const Value.absent(),
    this.notes = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : version = Value(version);
  static Insertable<CatalogVersionRow> custom({
    Expression<String>? version,
    Expression<DateTime>? appliedAt,
    Expression<int>? itemCount,
    Expression<String>? notes,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (version != null) 'version': version,
      if (appliedAt != null) 'applied_at': appliedAt,
      if (itemCount != null) 'item_count': itemCount,
      if (notes != null) 'notes': notes,
      if (rowid != null) 'rowid': rowid,
    });
  }

  CatalogVersionsCompanion copyWith(
      {Value<String>? version,
      Value<DateTime>? appliedAt,
      Value<int>? itemCount,
      Value<String?>? notes,
      Value<int>? rowid}) {
    return CatalogVersionsCompanion(
      version: version ?? this.version,
      appliedAt: appliedAt ?? this.appliedAt,
      itemCount: itemCount ?? this.itemCount,
      notes: notes ?? this.notes,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (version.present) {
      map['version'] = Variable<String>(version.value);
    }
    if (appliedAt.present) {
      map['applied_at'] = Variable<DateTime>(appliedAt.value);
    }
    if (itemCount.present) {
      map['item_count'] = Variable<int>(itemCount.value);
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CatalogVersionsCompanion(')
          ..write('version: $version, ')
          ..write('appliedAt: $appliedAt, ')
          ..write('itemCount: $itemCount, ')
          ..write('notes: $notes, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $CatalogCategoriesTable extends CatalogCategories
    with TableInfo<$CatalogCategoriesTable, CatalogCategoryRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CatalogCategoriesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _nameEnMeta = const VerificationMeta('nameEn');
  @override
  late final GeneratedColumn<String> nameEn = GeneratedColumn<String>(
      'name_en', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'));
  static const VerificationMeta _nameUrMeta = const VerificationMeta('nameUr');
  @override
  late final GeneratedColumn<String> nameUr = GeneratedColumn<String>(
      'name_ur', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant(''));
  static const VerificationMeta _sortOrderMeta =
      const VerificationMeta('sortOrder');
  @override
  late final GeneratedColumn<int> sortOrder = GeneratedColumn<int>(
      'sort_order', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  @override
  List<GeneratedColumn> get $columns => [id, nameEn, nameUr, sortOrder];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'catalog_categories';
  @override
  VerificationContext validateIntegrity(Insertable<CatalogCategoryRow> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('name_en')) {
      context.handle(_nameEnMeta,
          nameEn.isAcceptableOrUnknown(data['name_en']!, _nameEnMeta));
    } else if (isInserting) {
      context.missing(_nameEnMeta);
    }
    if (data.containsKey('name_ur')) {
      context.handle(_nameUrMeta,
          nameUr.isAcceptableOrUnknown(data['name_ur']!, _nameUrMeta));
    }
    if (data.containsKey('sort_order')) {
      context.handle(_sortOrderMeta,
          sortOrder.isAcceptableOrUnknown(data['sort_order']!, _sortOrderMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  CatalogCategoryRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CatalogCategoryRow(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      nameEn: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}name_en'])!,
      nameUr: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}name_ur'])!,
      sortOrder: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}sort_order'])!,
    );
  }

  @override
  $CatalogCategoriesTable createAlias(String alias) {
    return $CatalogCategoriesTable(attachedDatabase, alias);
  }
}

class CatalogCategoryRow extends DataClass
    implements Insertable<CatalogCategoryRow> {
  final int id;
  final String nameEn;
  final String nameUr;
  final int sortOrder;
  const CatalogCategoryRow(
      {required this.id,
      required this.nameEn,
      required this.nameUr,
      required this.sortOrder});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['name_en'] = Variable<String>(nameEn);
    map['name_ur'] = Variable<String>(nameUr);
    map['sort_order'] = Variable<int>(sortOrder);
    return map;
  }

  CatalogCategoriesCompanion toCompanion(bool nullToAbsent) {
    return CatalogCategoriesCompanion(
      id: Value(id),
      nameEn: Value(nameEn),
      nameUr: Value(nameUr),
      sortOrder: Value(sortOrder),
    );
  }

  factory CatalogCategoryRow.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CatalogCategoryRow(
      id: serializer.fromJson<int>(json['id']),
      nameEn: serializer.fromJson<String>(json['nameEn']),
      nameUr: serializer.fromJson<String>(json['nameUr']),
      sortOrder: serializer.fromJson<int>(json['sortOrder']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'nameEn': serializer.toJson<String>(nameEn),
      'nameUr': serializer.toJson<String>(nameUr),
      'sortOrder': serializer.toJson<int>(sortOrder),
    };
  }

  CatalogCategoryRow copyWith(
          {int? id, String? nameEn, String? nameUr, int? sortOrder}) =>
      CatalogCategoryRow(
        id: id ?? this.id,
        nameEn: nameEn ?? this.nameEn,
        nameUr: nameUr ?? this.nameUr,
        sortOrder: sortOrder ?? this.sortOrder,
      );
  CatalogCategoryRow copyWithCompanion(CatalogCategoriesCompanion data) {
    return CatalogCategoryRow(
      id: data.id.present ? data.id.value : this.id,
      nameEn: data.nameEn.present ? data.nameEn.value : this.nameEn,
      nameUr: data.nameUr.present ? data.nameUr.value : this.nameUr,
      sortOrder: data.sortOrder.present ? data.sortOrder.value : this.sortOrder,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CatalogCategoryRow(')
          ..write('id: $id, ')
          ..write('nameEn: $nameEn, ')
          ..write('nameUr: $nameUr, ')
          ..write('sortOrder: $sortOrder')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, nameEn, nameUr, sortOrder);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CatalogCategoryRow &&
          other.id == this.id &&
          other.nameEn == this.nameEn &&
          other.nameUr == this.nameUr &&
          other.sortOrder == this.sortOrder);
}

class CatalogCategoriesCompanion extends UpdateCompanion<CatalogCategoryRow> {
  final Value<int> id;
  final Value<String> nameEn;
  final Value<String> nameUr;
  final Value<int> sortOrder;
  const CatalogCategoriesCompanion({
    this.id = const Value.absent(),
    this.nameEn = const Value.absent(),
    this.nameUr = const Value.absent(),
    this.sortOrder = const Value.absent(),
  });
  CatalogCategoriesCompanion.insert({
    this.id = const Value.absent(),
    required String nameEn,
    this.nameUr = const Value.absent(),
    this.sortOrder = const Value.absent(),
  }) : nameEn = Value(nameEn);
  static Insertable<CatalogCategoryRow> custom({
    Expression<int>? id,
    Expression<String>? nameEn,
    Expression<String>? nameUr,
    Expression<int>? sortOrder,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (nameEn != null) 'name_en': nameEn,
      if (nameUr != null) 'name_ur': nameUr,
      if (sortOrder != null) 'sort_order': sortOrder,
    });
  }

  CatalogCategoriesCompanion copyWith(
      {Value<int>? id,
      Value<String>? nameEn,
      Value<String>? nameUr,
      Value<int>? sortOrder}) {
    return CatalogCategoriesCompanion(
      id: id ?? this.id,
      nameEn: nameEn ?? this.nameEn,
      nameUr: nameUr ?? this.nameUr,
      sortOrder: sortOrder ?? this.sortOrder,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (nameEn.present) {
      map['name_en'] = Variable<String>(nameEn.value);
    }
    if (nameUr.present) {
      map['name_ur'] = Variable<String>(nameUr.value);
    }
    if (sortOrder.present) {
      map['sort_order'] = Variable<int>(sortOrder.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CatalogCategoriesCompanion(')
          ..write('id: $id, ')
          ..write('nameEn: $nameEn, ')
          ..write('nameUr: $nameUr, ')
          ..write('sortOrder: $sortOrder')
          ..write(')'))
        .toString();
  }
}

class $CatalogItemsTable extends CatalogItems
    with TableInfo<$CatalogItemsTable, CatalogItemRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CatalogItemsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _skuMeta = const VerificationMeta('sku');
  @override
  late final GeneratedColumn<String> sku = GeneratedColumn<String>(
      'sku', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _categoryMeta =
      const VerificationMeta('category');
  @override
  late final GeneratedColumn<String> category = GeneratedColumn<String>(
      'category', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _brandMeta = const VerificationMeta('brand');
  @override
  late final GeneratedColumn<String> brand = GeneratedColumn<String>(
      'brand', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _nameEnMeta = const VerificationMeta('nameEn');
  @override
  late final GeneratedColumn<String> nameEn = GeneratedColumn<String>(
      'name_en', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _nameUrMeta = const VerificationMeta('nameUr');
  @override
  late final GeneratedColumn<String> nameUr = GeneratedColumn<String>(
      'name_ur', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant(''));
  static const VerificationMeta _modelCompatibilityMeta =
      const VerificationMeta('modelCompatibility');
  @override
  late final GeneratedColumn<String> modelCompatibility =
      GeneratedColumn<String>('model_compatibility', aliasedName, true,
          type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _colorsMeta = const VerificationMeta('colors');
  @override
  late final GeneratedColumn<String> colors = GeneratedColumn<String>(
      'colors', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('[]'));
  static const VerificationMeta _variantsMeta =
      const VerificationMeta('variants');
  @override
  late final GeneratedColumn<String> variants = GeneratedColumn<String>(
      'variants', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('[]'));
  static const VerificationMeta _purchasePriceEstMeta =
      const VerificationMeta('purchasePriceEst');
  @override
  late final GeneratedColumn<int> purchasePriceEst = GeneratedColumn<int>(
      'purchase_price_est', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _salePriceEstMeta =
      const VerificationMeta('salePriceEst');
  @override
  late final GeneratedColumn<int> salePriceEst = GeneratedColumn<int>(
      'sale_price_est', aliasedName, false,
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
  static const VerificationMeta _unitMeta = const VerificationMeta('unit');
  @override
  late final GeneratedColumn<String> unit = GeneratedColumn<String>(
      'unit', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('piece'));
  static const VerificationMeta _barcodeMeta =
      const VerificationMeta('barcode');
  @override
  late final GeneratedColumn<String> barcode = GeneratedColumn<String>(
      'barcode', aliasedName, true,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'));
  static const VerificationMeta _isCustomMeta =
      const VerificationMeta('isCustom');
  @override
  late final GeneratedColumn<bool> isCustom = GeneratedColumn<bool>(
      'is_custom', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("is_custom" IN (0, 1))'),
      defaultValue: const Constant(false));
  static const VerificationMeta _estimatedMeta =
      const VerificationMeta('estimated');
  @override
  late final GeneratedColumn<bool> estimated = GeneratedColumn<bool>(
      'estimated', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("estimated" IN (0, 1))'),
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
        sku,
        category,
        brand,
        nameEn,
        nameUr,
        modelCompatibility,
        colors,
        variants,
        purchasePriceEst,
        salePriceEst,
        minPrice,
        unit,
        barcode,
        isCustom,
        estimated,
        createdAt,
        updatedAt
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'catalog_items';
  @override
  VerificationContext validateIntegrity(Insertable<CatalogItemRow> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('sku')) {
      context.handle(
          _skuMeta, sku.isAcceptableOrUnknown(data['sku']!, _skuMeta));
    } else if (isInserting) {
      context.missing(_skuMeta);
    }
    if (data.containsKey('category')) {
      context.handle(_categoryMeta,
          category.isAcceptableOrUnknown(data['category']!, _categoryMeta));
    } else if (isInserting) {
      context.missing(_categoryMeta);
    }
    if (data.containsKey('brand')) {
      context.handle(
          _brandMeta, brand.isAcceptableOrUnknown(data['brand']!, _brandMeta));
    } else if (isInserting) {
      context.missing(_brandMeta);
    }
    if (data.containsKey('name_en')) {
      context.handle(_nameEnMeta,
          nameEn.isAcceptableOrUnknown(data['name_en']!, _nameEnMeta));
    } else if (isInserting) {
      context.missing(_nameEnMeta);
    }
    if (data.containsKey('name_ur')) {
      context.handle(_nameUrMeta,
          nameUr.isAcceptableOrUnknown(data['name_ur']!, _nameUrMeta));
    }
    if (data.containsKey('model_compatibility')) {
      context.handle(
          _modelCompatibilityMeta,
          modelCompatibility.isAcceptableOrUnknown(
              data['model_compatibility']!, _modelCompatibilityMeta));
    }
    if (data.containsKey('colors')) {
      context.handle(_colorsMeta,
          colors.isAcceptableOrUnknown(data['colors']!, _colorsMeta));
    }
    if (data.containsKey('variants')) {
      context.handle(_variantsMeta,
          variants.isAcceptableOrUnknown(data['variants']!, _variantsMeta));
    }
    if (data.containsKey('purchase_price_est')) {
      context.handle(
          _purchasePriceEstMeta,
          purchasePriceEst.isAcceptableOrUnknown(
              data['purchase_price_est']!, _purchasePriceEstMeta));
    }
    if (data.containsKey('sale_price_est')) {
      context.handle(
          _salePriceEstMeta,
          salePriceEst.isAcceptableOrUnknown(
              data['sale_price_est']!, _salePriceEstMeta));
    }
    if (data.containsKey('min_price')) {
      context.handle(_minPriceMeta,
          minPrice.isAcceptableOrUnknown(data['min_price']!, _minPriceMeta));
    }
    if (data.containsKey('unit')) {
      context.handle(
          _unitMeta, unit.isAcceptableOrUnknown(data['unit']!, _unitMeta));
    }
    if (data.containsKey('barcode')) {
      context.handle(_barcodeMeta,
          barcode.isAcceptableOrUnknown(data['barcode']!, _barcodeMeta));
    }
    if (data.containsKey('is_custom')) {
      context.handle(_isCustomMeta,
          isCustom.isAcceptableOrUnknown(data['is_custom']!, _isCustomMeta));
    }
    if (data.containsKey('estimated')) {
      context.handle(_estimatedMeta,
          estimated.isAcceptableOrUnknown(data['estimated']!, _estimatedMeta));
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
  Set<GeneratedColumn> get $primaryKey => {sku};
  @override
  CatalogItemRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CatalogItemRow(
      sku: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}sku'])!,
      category: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}category'])!,
      brand: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}brand'])!,
      nameEn: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}name_en'])!,
      nameUr: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}name_ur'])!,
      modelCompatibility: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}model_compatibility']),
      colors: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}colors'])!,
      variants: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}variants'])!,
      purchasePriceEst: attachedDatabase.typeMapping.read(
          DriftSqlType.int, data['${effectivePrefix}purchase_price_est'])!,
      salePriceEst: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}sale_price_est'])!,
      minPrice: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}min_price'])!,
      unit: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}unit'])!,
      barcode: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}barcode']),
      isCustom: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_custom'])!,
      estimated: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}estimated'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}updated_at'])!,
    );
  }

  @override
  $CatalogItemsTable createAlias(String alias) {
    return $CatalogItemsTable(attachedDatabase, alias);
  }
}

class CatalogItemRow extends DataClass implements Insertable<CatalogItemRow> {
  final String sku;
  final String category;
  final String brand;
  final String nameEn;
  final String nameUr;
  final String? modelCompatibility;

  /// JSON-encoded list of colour names.
  final String colors;

  /// JSON-encoded list of variant labels.
  final String variants;

  /// ESTIMATED purchase price (whole PKR). Never a live market rate.
  final int purchasePriceEst;

  /// ESTIMATED sale price (whole PKR).
  final int salePriceEst;
  final int minPrice;
  final String unit;
  final String? barcode;
  final bool isCustom;
  final bool estimated;
  final DateTime createdAt;
  final DateTime updatedAt;
  const CatalogItemRow(
      {required this.sku,
      required this.category,
      required this.brand,
      required this.nameEn,
      required this.nameUr,
      this.modelCompatibility,
      required this.colors,
      required this.variants,
      required this.purchasePriceEst,
      required this.salePriceEst,
      required this.minPrice,
      required this.unit,
      this.barcode,
      required this.isCustom,
      required this.estimated,
      required this.createdAt,
      required this.updatedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['sku'] = Variable<String>(sku);
    map['category'] = Variable<String>(category);
    map['brand'] = Variable<String>(brand);
    map['name_en'] = Variable<String>(nameEn);
    map['name_ur'] = Variable<String>(nameUr);
    if (!nullToAbsent || modelCompatibility != null) {
      map['model_compatibility'] = Variable<String>(modelCompatibility);
    }
    map['colors'] = Variable<String>(colors);
    map['variants'] = Variable<String>(variants);
    map['purchase_price_est'] = Variable<int>(purchasePriceEst);
    map['sale_price_est'] = Variable<int>(salePriceEst);
    map['min_price'] = Variable<int>(minPrice);
    map['unit'] = Variable<String>(unit);
    if (!nullToAbsent || barcode != null) {
      map['barcode'] = Variable<String>(barcode);
    }
    map['is_custom'] = Variable<bool>(isCustom);
    map['estimated'] = Variable<bool>(estimated);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  CatalogItemsCompanion toCompanion(bool nullToAbsent) {
    return CatalogItemsCompanion(
      sku: Value(sku),
      category: Value(category),
      brand: Value(brand),
      nameEn: Value(nameEn),
      nameUr: Value(nameUr),
      modelCompatibility: modelCompatibility == null && nullToAbsent
          ? const Value.absent()
          : Value(modelCompatibility),
      colors: Value(colors),
      variants: Value(variants),
      purchasePriceEst: Value(purchasePriceEst),
      salePriceEst: Value(salePriceEst),
      minPrice: Value(minPrice),
      unit: Value(unit),
      barcode: barcode == null && nullToAbsent
          ? const Value.absent()
          : Value(barcode),
      isCustom: Value(isCustom),
      estimated: Value(estimated),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory CatalogItemRow.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CatalogItemRow(
      sku: serializer.fromJson<String>(json['sku']),
      category: serializer.fromJson<String>(json['category']),
      brand: serializer.fromJson<String>(json['brand']),
      nameEn: serializer.fromJson<String>(json['nameEn']),
      nameUr: serializer.fromJson<String>(json['nameUr']),
      modelCompatibility:
          serializer.fromJson<String?>(json['modelCompatibility']),
      colors: serializer.fromJson<String>(json['colors']),
      variants: serializer.fromJson<String>(json['variants']),
      purchasePriceEst: serializer.fromJson<int>(json['purchasePriceEst']),
      salePriceEst: serializer.fromJson<int>(json['salePriceEst']),
      minPrice: serializer.fromJson<int>(json['minPrice']),
      unit: serializer.fromJson<String>(json['unit']),
      barcode: serializer.fromJson<String?>(json['barcode']),
      isCustom: serializer.fromJson<bool>(json['isCustom']),
      estimated: serializer.fromJson<bool>(json['estimated']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'sku': serializer.toJson<String>(sku),
      'category': serializer.toJson<String>(category),
      'brand': serializer.toJson<String>(brand),
      'nameEn': serializer.toJson<String>(nameEn),
      'nameUr': serializer.toJson<String>(nameUr),
      'modelCompatibility': serializer.toJson<String?>(modelCompatibility),
      'colors': serializer.toJson<String>(colors),
      'variants': serializer.toJson<String>(variants),
      'purchasePriceEst': serializer.toJson<int>(purchasePriceEst),
      'salePriceEst': serializer.toJson<int>(salePriceEst),
      'minPrice': serializer.toJson<int>(minPrice),
      'unit': serializer.toJson<String>(unit),
      'barcode': serializer.toJson<String?>(barcode),
      'isCustom': serializer.toJson<bool>(isCustom),
      'estimated': serializer.toJson<bool>(estimated),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  CatalogItemRow copyWith(
          {String? sku,
          String? category,
          String? brand,
          String? nameEn,
          String? nameUr,
          Value<String?> modelCompatibility = const Value.absent(),
          String? colors,
          String? variants,
          int? purchasePriceEst,
          int? salePriceEst,
          int? minPrice,
          String? unit,
          Value<String?> barcode = const Value.absent(),
          bool? isCustom,
          bool? estimated,
          DateTime? createdAt,
          DateTime? updatedAt}) =>
      CatalogItemRow(
        sku: sku ?? this.sku,
        category: category ?? this.category,
        brand: brand ?? this.brand,
        nameEn: nameEn ?? this.nameEn,
        nameUr: nameUr ?? this.nameUr,
        modelCompatibility: modelCompatibility.present
            ? modelCompatibility.value
            : this.modelCompatibility,
        colors: colors ?? this.colors,
        variants: variants ?? this.variants,
        purchasePriceEst: purchasePriceEst ?? this.purchasePriceEst,
        salePriceEst: salePriceEst ?? this.salePriceEst,
        minPrice: minPrice ?? this.minPrice,
        unit: unit ?? this.unit,
        barcode: barcode.present ? barcode.value : this.barcode,
        isCustom: isCustom ?? this.isCustom,
        estimated: estimated ?? this.estimated,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
      );
  CatalogItemRow copyWithCompanion(CatalogItemsCompanion data) {
    return CatalogItemRow(
      sku: data.sku.present ? data.sku.value : this.sku,
      category: data.category.present ? data.category.value : this.category,
      brand: data.brand.present ? data.brand.value : this.brand,
      nameEn: data.nameEn.present ? data.nameEn.value : this.nameEn,
      nameUr: data.nameUr.present ? data.nameUr.value : this.nameUr,
      modelCompatibility: data.modelCompatibility.present
          ? data.modelCompatibility.value
          : this.modelCompatibility,
      colors: data.colors.present ? data.colors.value : this.colors,
      variants: data.variants.present ? data.variants.value : this.variants,
      purchasePriceEst: data.purchasePriceEst.present
          ? data.purchasePriceEst.value
          : this.purchasePriceEst,
      salePriceEst: data.salePriceEst.present
          ? data.salePriceEst.value
          : this.salePriceEst,
      minPrice: data.minPrice.present ? data.minPrice.value : this.minPrice,
      unit: data.unit.present ? data.unit.value : this.unit,
      barcode: data.barcode.present ? data.barcode.value : this.barcode,
      isCustom: data.isCustom.present ? data.isCustom.value : this.isCustom,
      estimated: data.estimated.present ? data.estimated.value : this.estimated,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CatalogItemRow(')
          ..write('sku: $sku, ')
          ..write('category: $category, ')
          ..write('brand: $brand, ')
          ..write('nameEn: $nameEn, ')
          ..write('nameUr: $nameUr, ')
          ..write('modelCompatibility: $modelCompatibility, ')
          ..write('colors: $colors, ')
          ..write('variants: $variants, ')
          ..write('purchasePriceEst: $purchasePriceEst, ')
          ..write('salePriceEst: $salePriceEst, ')
          ..write('minPrice: $minPrice, ')
          ..write('unit: $unit, ')
          ..write('barcode: $barcode, ')
          ..write('isCustom: $isCustom, ')
          ..write('estimated: $estimated, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      sku,
      category,
      brand,
      nameEn,
      nameUr,
      modelCompatibility,
      colors,
      variants,
      purchasePriceEst,
      salePriceEst,
      minPrice,
      unit,
      barcode,
      isCustom,
      estimated,
      createdAt,
      updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CatalogItemRow &&
          other.sku == this.sku &&
          other.category == this.category &&
          other.brand == this.brand &&
          other.nameEn == this.nameEn &&
          other.nameUr == this.nameUr &&
          other.modelCompatibility == this.modelCompatibility &&
          other.colors == this.colors &&
          other.variants == this.variants &&
          other.purchasePriceEst == this.purchasePriceEst &&
          other.salePriceEst == this.salePriceEst &&
          other.minPrice == this.minPrice &&
          other.unit == this.unit &&
          other.barcode == this.barcode &&
          other.isCustom == this.isCustom &&
          other.estimated == this.estimated &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class CatalogItemsCompanion extends UpdateCompanion<CatalogItemRow> {
  final Value<String> sku;
  final Value<String> category;
  final Value<String> brand;
  final Value<String> nameEn;
  final Value<String> nameUr;
  final Value<String?> modelCompatibility;
  final Value<String> colors;
  final Value<String> variants;
  final Value<int> purchasePriceEst;
  final Value<int> salePriceEst;
  final Value<int> minPrice;
  final Value<String> unit;
  final Value<String?> barcode;
  final Value<bool> isCustom;
  final Value<bool> estimated;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const CatalogItemsCompanion({
    this.sku = const Value.absent(),
    this.category = const Value.absent(),
    this.brand = const Value.absent(),
    this.nameEn = const Value.absent(),
    this.nameUr = const Value.absent(),
    this.modelCompatibility = const Value.absent(),
    this.colors = const Value.absent(),
    this.variants = const Value.absent(),
    this.purchasePriceEst = const Value.absent(),
    this.salePriceEst = const Value.absent(),
    this.minPrice = const Value.absent(),
    this.unit = const Value.absent(),
    this.barcode = const Value.absent(),
    this.isCustom = const Value.absent(),
    this.estimated = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  CatalogItemsCompanion.insert({
    required String sku,
    required String category,
    required String brand,
    required String nameEn,
    this.nameUr = const Value.absent(),
    this.modelCompatibility = const Value.absent(),
    this.colors = const Value.absent(),
    this.variants = const Value.absent(),
    this.purchasePriceEst = const Value.absent(),
    this.salePriceEst = const Value.absent(),
    this.minPrice = const Value.absent(),
    this.unit = const Value.absent(),
    this.barcode = const Value.absent(),
    this.isCustom = const Value.absent(),
    this.estimated = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : sku = Value(sku),
        category = Value(category),
        brand = Value(brand),
        nameEn = Value(nameEn);
  static Insertable<CatalogItemRow> custom({
    Expression<String>? sku,
    Expression<String>? category,
    Expression<String>? brand,
    Expression<String>? nameEn,
    Expression<String>? nameUr,
    Expression<String>? modelCompatibility,
    Expression<String>? colors,
    Expression<String>? variants,
    Expression<int>? purchasePriceEst,
    Expression<int>? salePriceEst,
    Expression<int>? minPrice,
    Expression<String>? unit,
    Expression<String>? barcode,
    Expression<bool>? isCustom,
    Expression<bool>? estimated,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (sku != null) 'sku': sku,
      if (category != null) 'category': category,
      if (brand != null) 'brand': brand,
      if (nameEn != null) 'name_en': nameEn,
      if (nameUr != null) 'name_ur': nameUr,
      if (modelCompatibility != null) 'model_compatibility': modelCompatibility,
      if (colors != null) 'colors': colors,
      if (variants != null) 'variants': variants,
      if (purchasePriceEst != null) 'purchase_price_est': purchasePriceEst,
      if (salePriceEst != null) 'sale_price_est': salePriceEst,
      if (minPrice != null) 'min_price': minPrice,
      if (unit != null) 'unit': unit,
      if (barcode != null) 'barcode': barcode,
      if (isCustom != null) 'is_custom': isCustom,
      if (estimated != null) 'estimated': estimated,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  CatalogItemsCompanion copyWith(
      {Value<String>? sku,
      Value<String>? category,
      Value<String>? brand,
      Value<String>? nameEn,
      Value<String>? nameUr,
      Value<String?>? modelCompatibility,
      Value<String>? colors,
      Value<String>? variants,
      Value<int>? purchasePriceEst,
      Value<int>? salePriceEst,
      Value<int>? minPrice,
      Value<String>? unit,
      Value<String?>? barcode,
      Value<bool>? isCustom,
      Value<bool>? estimated,
      Value<DateTime>? createdAt,
      Value<DateTime>? updatedAt,
      Value<int>? rowid}) {
    return CatalogItemsCompanion(
      sku: sku ?? this.sku,
      category: category ?? this.category,
      brand: brand ?? this.brand,
      nameEn: nameEn ?? this.nameEn,
      nameUr: nameUr ?? this.nameUr,
      modelCompatibility: modelCompatibility ?? this.modelCompatibility,
      colors: colors ?? this.colors,
      variants: variants ?? this.variants,
      purchasePriceEst: purchasePriceEst ?? this.purchasePriceEst,
      salePriceEst: salePriceEst ?? this.salePriceEst,
      minPrice: minPrice ?? this.minPrice,
      unit: unit ?? this.unit,
      barcode: barcode ?? this.barcode,
      isCustom: isCustom ?? this.isCustom,
      estimated: estimated ?? this.estimated,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (sku.present) {
      map['sku'] = Variable<String>(sku.value);
    }
    if (category.present) {
      map['category'] = Variable<String>(category.value);
    }
    if (brand.present) {
      map['brand'] = Variable<String>(brand.value);
    }
    if (nameEn.present) {
      map['name_en'] = Variable<String>(nameEn.value);
    }
    if (nameUr.present) {
      map['name_ur'] = Variable<String>(nameUr.value);
    }
    if (modelCompatibility.present) {
      map['model_compatibility'] = Variable<String>(modelCompatibility.value);
    }
    if (colors.present) {
      map['colors'] = Variable<String>(colors.value);
    }
    if (variants.present) {
      map['variants'] = Variable<String>(variants.value);
    }
    if (purchasePriceEst.present) {
      map['purchase_price_est'] = Variable<int>(purchasePriceEst.value);
    }
    if (salePriceEst.present) {
      map['sale_price_est'] = Variable<int>(salePriceEst.value);
    }
    if (minPrice.present) {
      map['min_price'] = Variable<int>(minPrice.value);
    }
    if (unit.present) {
      map['unit'] = Variable<String>(unit.value);
    }
    if (barcode.present) {
      map['barcode'] = Variable<String>(barcode.value);
    }
    if (isCustom.present) {
      map['is_custom'] = Variable<bool>(isCustom.value);
    }
    if (estimated.present) {
      map['estimated'] = Variable<bool>(estimated.value);
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
    return (StringBuffer('CatalogItemsCompanion(')
          ..write('sku: $sku, ')
          ..write('category: $category, ')
          ..write('brand: $brand, ')
          ..write('nameEn: $nameEn, ')
          ..write('nameUr: $nameUr, ')
          ..write('modelCompatibility: $modelCompatibility, ')
          ..write('colors: $colors, ')
          ..write('variants: $variants, ')
          ..write('purchasePriceEst: $purchasePriceEst, ')
          ..write('salePriceEst: $salePriceEst, ')
          ..write('minPrice: $minPrice, ')
          ..write('unit: $unit, ')
          ..write('barcode: $barcode, ')
          ..write('isCustom: $isCustom, ')
          ..write('estimated: $estimated, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $CatalogItemModelsTable extends CatalogItemModels
    with TableInfo<$CatalogItemModelsTable, CatalogItemModelRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CatalogItemModelsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _skuMeta = const VerificationMeta('sku');
  @override
  late final GeneratedColumn<String> sku = GeneratedColumn<String>(
      'sku', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('REFERENCES catalog_items (sku)'));
  static const VerificationMeta _deviceBrandMeta =
      const VerificationMeta('deviceBrand');
  @override
  late final GeneratedColumn<String> deviceBrand = GeneratedColumn<String>(
      'device_brand', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _deviceModelMeta =
      const VerificationMeta('deviceModel');
  @override
  late final GeneratedColumn<String> deviceModel = GeneratedColumn<String>(
      'device_model', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [sku, deviceBrand, deviceModel];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'catalog_item_models';
  @override
  VerificationContext validateIntegrity(
      Insertable<CatalogItemModelRow> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('sku')) {
      context.handle(
          _skuMeta, sku.isAcceptableOrUnknown(data['sku']!, _skuMeta));
    } else if (isInserting) {
      context.missing(_skuMeta);
    }
    if (data.containsKey('device_brand')) {
      context.handle(
          _deviceBrandMeta,
          deviceBrand.isAcceptableOrUnknown(
              data['device_brand']!, _deviceBrandMeta));
    } else if (isInserting) {
      context.missing(_deviceBrandMeta);
    }
    if (data.containsKey('device_model')) {
      context.handle(
          _deviceModelMeta,
          deviceModel.isAcceptableOrUnknown(
              data['device_model']!, _deviceModelMeta));
    } else if (isInserting) {
      context.missing(_deviceModelMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {sku, deviceBrand, deviceModel};
  @override
  CatalogItemModelRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CatalogItemModelRow(
      sku: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}sku'])!,
      deviceBrand: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}device_brand'])!,
      deviceModel: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}device_model'])!,
    );
  }

  @override
  $CatalogItemModelsTable createAlias(String alias) {
    return $CatalogItemModelsTable(attachedDatabase, alias);
  }
}

class CatalogItemModelRow extends DataClass
    implements Insertable<CatalogItemModelRow> {
  final String sku;
  final String deviceBrand;
  final String deviceModel;
  const CatalogItemModelRow(
      {required this.sku,
      required this.deviceBrand,
      required this.deviceModel});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['sku'] = Variable<String>(sku);
    map['device_brand'] = Variable<String>(deviceBrand);
    map['device_model'] = Variable<String>(deviceModel);
    return map;
  }

  CatalogItemModelsCompanion toCompanion(bool nullToAbsent) {
    return CatalogItemModelsCompanion(
      sku: Value(sku),
      deviceBrand: Value(deviceBrand),
      deviceModel: Value(deviceModel),
    );
  }

  factory CatalogItemModelRow.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CatalogItemModelRow(
      sku: serializer.fromJson<String>(json['sku']),
      deviceBrand: serializer.fromJson<String>(json['deviceBrand']),
      deviceModel: serializer.fromJson<String>(json['deviceModel']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'sku': serializer.toJson<String>(sku),
      'deviceBrand': serializer.toJson<String>(deviceBrand),
      'deviceModel': serializer.toJson<String>(deviceModel),
    };
  }

  CatalogItemModelRow copyWith(
          {String? sku, String? deviceBrand, String? deviceModel}) =>
      CatalogItemModelRow(
        sku: sku ?? this.sku,
        deviceBrand: deviceBrand ?? this.deviceBrand,
        deviceModel: deviceModel ?? this.deviceModel,
      );
  CatalogItemModelRow copyWithCompanion(CatalogItemModelsCompanion data) {
    return CatalogItemModelRow(
      sku: data.sku.present ? data.sku.value : this.sku,
      deviceBrand:
          data.deviceBrand.present ? data.deviceBrand.value : this.deviceBrand,
      deviceModel:
          data.deviceModel.present ? data.deviceModel.value : this.deviceModel,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CatalogItemModelRow(')
          ..write('sku: $sku, ')
          ..write('deviceBrand: $deviceBrand, ')
          ..write('deviceModel: $deviceModel')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(sku, deviceBrand, deviceModel);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CatalogItemModelRow &&
          other.sku == this.sku &&
          other.deviceBrand == this.deviceBrand &&
          other.deviceModel == this.deviceModel);
}

class CatalogItemModelsCompanion extends UpdateCompanion<CatalogItemModelRow> {
  final Value<String> sku;
  final Value<String> deviceBrand;
  final Value<String> deviceModel;
  final Value<int> rowid;
  const CatalogItemModelsCompanion({
    this.sku = const Value.absent(),
    this.deviceBrand = const Value.absent(),
    this.deviceModel = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  CatalogItemModelsCompanion.insert({
    required String sku,
    required String deviceBrand,
    required String deviceModel,
    this.rowid = const Value.absent(),
  })  : sku = Value(sku),
        deviceBrand = Value(deviceBrand),
        deviceModel = Value(deviceModel);
  static Insertable<CatalogItemModelRow> custom({
    Expression<String>? sku,
    Expression<String>? deviceBrand,
    Expression<String>? deviceModel,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (sku != null) 'sku': sku,
      if (deviceBrand != null) 'device_brand': deviceBrand,
      if (deviceModel != null) 'device_model': deviceModel,
      if (rowid != null) 'rowid': rowid,
    });
  }

  CatalogItemModelsCompanion copyWith(
      {Value<String>? sku,
      Value<String>? deviceBrand,
      Value<String>? deviceModel,
      Value<int>? rowid}) {
    return CatalogItemModelsCompanion(
      sku: sku ?? this.sku,
      deviceBrand: deviceBrand ?? this.deviceBrand,
      deviceModel: deviceModel ?? this.deviceModel,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (sku.present) {
      map['sku'] = Variable<String>(sku.value);
    }
    if (deviceBrand.present) {
      map['device_brand'] = Variable<String>(deviceBrand.value);
    }
    if (deviceModel.present) {
      map['device_model'] = Variable<String>(deviceModel.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CatalogItemModelsCompanion(')
          ..write('sku: $sku, ')
          ..write('deviceBrand: $deviceBrand, ')
          ..write('deviceModel: $deviceModel, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $BarcodeLinksTable extends BarcodeLinks
    with TableInfo<$BarcodeLinksTable, BarcodeLinkRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $BarcodeLinksTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _barcodeMeta =
      const VerificationMeta('barcode');
  @override
  late final GeneratedColumn<String> barcode = GeneratedColumn<String>(
      'barcode', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _skuMeta = const VerificationMeta('sku');
  @override
  late final GeneratedColumn<String> sku = GeneratedColumn<String>(
      'sku', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('REFERENCES catalog_items (sku)'));
  static const VerificationMeta _linkedAtMeta =
      const VerificationMeta('linkedAt');
  @override
  late final GeneratedColumn<DateTime> linkedAt = GeneratedColumn<DateTime>(
      'linked_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  @override
  List<GeneratedColumn> get $columns => [barcode, sku, linkedAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'barcode_links';
  @override
  VerificationContext validateIntegrity(Insertable<BarcodeLinkRow> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('barcode')) {
      context.handle(_barcodeMeta,
          barcode.isAcceptableOrUnknown(data['barcode']!, _barcodeMeta));
    } else if (isInserting) {
      context.missing(_barcodeMeta);
    }
    if (data.containsKey('sku')) {
      context.handle(
          _skuMeta, sku.isAcceptableOrUnknown(data['sku']!, _skuMeta));
    } else if (isInserting) {
      context.missing(_skuMeta);
    }
    if (data.containsKey('linked_at')) {
      context.handle(_linkedAtMeta,
          linkedAt.isAcceptableOrUnknown(data['linked_at']!, _linkedAtMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {barcode};
  @override
  BarcodeLinkRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return BarcodeLinkRow(
      barcode: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}barcode'])!,
      sku: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}sku'])!,
      linkedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}linked_at'])!,
    );
  }

  @override
  $BarcodeLinksTable createAlias(String alias) {
    return $BarcodeLinksTable(attachedDatabase, alias);
  }
}

class BarcodeLinkRow extends DataClass implements Insertable<BarcodeLinkRow> {
  final String barcode;
  final String sku;
  final DateTime linkedAt;
  const BarcodeLinkRow(
      {required this.barcode, required this.sku, required this.linkedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['barcode'] = Variable<String>(barcode);
    map['sku'] = Variable<String>(sku);
    map['linked_at'] = Variable<DateTime>(linkedAt);
    return map;
  }

  BarcodeLinksCompanion toCompanion(bool nullToAbsent) {
    return BarcodeLinksCompanion(
      barcode: Value(barcode),
      sku: Value(sku),
      linkedAt: Value(linkedAt),
    );
  }

  factory BarcodeLinkRow.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return BarcodeLinkRow(
      barcode: serializer.fromJson<String>(json['barcode']),
      sku: serializer.fromJson<String>(json['sku']),
      linkedAt: serializer.fromJson<DateTime>(json['linkedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'barcode': serializer.toJson<String>(barcode),
      'sku': serializer.toJson<String>(sku),
      'linkedAt': serializer.toJson<DateTime>(linkedAt),
    };
  }

  BarcodeLinkRow copyWith({String? barcode, String? sku, DateTime? linkedAt}) =>
      BarcodeLinkRow(
        barcode: barcode ?? this.barcode,
        sku: sku ?? this.sku,
        linkedAt: linkedAt ?? this.linkedAt,
      );
  BarcodeLinkRow copyWithCompanion(BarcodeLinksCompanion data) {
    return BarcodeLinkRow(
      barcode: data.barcode.present ? data.barcode.value : this.barcode,
      sku: data.sku.present ? data.sku.value : this.sku,
      linkedAt: data.linkedAt.present ? data.linkedAt.value : this.linkedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('BarcodeLinkRow(')
          ..write('barcode: $barcode, ')
          ..write('sku: $sku, ')
          ..write('linkedAt: $linkedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(barcode, sku, linkedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is BarcodeLinkRow &&
          other.barcode == this.barcode &&
          other.sku == this.sku &&
          other.linkedAt == this.linkedAt);
}

class BarcodeLinksCompanion extends UpdateCompanion<BarcodeLinkRow> {
  final Value<String> barcode;
  final Value<String> sku;
  final Value<DateTime> linkedAt;
  final Value<int> rowid;
  const BarcodeLinksCompanion({
    this.barcode = const Value.absent(),
    this.sku = const Value.absent(),
    this.linkedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  BarcodeLinksCompanion.insert({
    required String barcode,
    required String sku,
    this.linkedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : barcode = Value(barcode),
        sku = Value(sku);
  static Insertable<BarcodeLinkRow> custom({
    Expression<String>? barcode,
    Expression<String>? sku,
    Expression<DateTime>? linkedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (barcode != null) 'barcode': barcode,
      if (sku != null) 'sku': sku,
      if (linkedAt != null) 'linked_at': linkedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  BarcodeLinksCompanion copyWith(
      {Value<String>? barcode,
      Value<String>? sku,
      Value<DateTime>? linkedAt,
      Value<int>? rowid}) {
    return BarcodeLinksCompanion(
      barcode: barcode ?? this.barcode,
      sku: sku ?? this.sku,
      linkedAt: linkedAt ?? this.linkedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (barcode.present) {
      map['barcode'] = Variable<String>(barcode.value);
    }
    if (sku.present) {
      map['sku'] = Variable<String>(sku.value);
    }
    if (linkedAt.present) {
      map['linked_at'] = Variable<DateTime>(linkedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('BarcodeLinksCompanion(')
          ..write('barcode: $barcode, ')
          ..write('sku: $sku, ')
          ..write('linkedAt: $linkedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $CatalogStockTable extends CatalogStock
    with TableInfo<$CatalogStockTable, CatalogStockRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CatalogStockTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _skuMeta = const VerificationMeta('sku');
  @override
  late final GeneratedColumn<String> sku = GeneratedColumn<String>(
      'sku', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('REFERENCES catalog_items (sku)'));
  static const VerificationMeta _quantityMeta =
      const VerificationMeta('quantity');
  @override
  late final GeneratedColumn<int> quantity = GeneratedColumn<int>(
      'quantity', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _lastPurchasePriceMeta =
      const VerificationMeta('lastPurchasePrice');
  @override
  late final GeneratedColumn<int> lastPurchasePrice = GeneratedColumn<int>(
      'last_purchase_price', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _lastSupplierMeta =
      const VerificationMeta('lastSupplier');
  @override
  late final GeneratedColumn<String> lastSupplier = GeneratedColumn<String>(
      'last_supplier', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _lastStockDateMeta =
      const VerificationMeta('lastStockDate');
  @override
  late final GeneratedColumn<DateTime> lastStockDate =
      GeneratedColumn<DateTime>('last_stock_date', aliasedName, true,
          type: DriftSqlType.dateTime, requiredDuringInsert: false);
  static const VerificationMeta _lowStockThresholdMeta =
      const VerificationMeta('lowStockThreshold');
  @override
  late final GeneratedColumn<int> lowStockThreshold = GeneratedColumn<int>(
      'low_stock_threshold', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(5));
  @override
  List<GeneratedColumn> get $columns => [
        sku,
        quantity,
        lastPurchasePrice,
        lastSupplier,
        lastStockDate,
        lowStockThreshold
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'catalog_stock';
  @override
  VerificationContext validateIntegrity(Insertable<CatalogStockRow> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('sku')) {
      context.handle(
          _skuMeta, sku.isAcceptableOrUnknown(data['sku']!, _skuMeta));
    } else if (isInserting) {
      context.missing(_skuMeta);
    }
    if (data.containsKey('quantity')) {
      context.handle(_quantityMeta,
          quantity.isAcceptableOrUnknown(data['quantity']!, _quantityMeta));
    }
    if (data.containsKey('last_purchase_price')) {
      context.handle(
          _lastPurchasePriceMeta,
          lastPurchasePrice.isAcceptableOrUnknown(
              data['last_purchase_price']!, _lastPurchasePriceMeta));
    }
    if (data.containsKey('last_supplier')) {
      context.handle(
          _lastSupplierMeta,
          lastSupplier.isAcceptableOrUnknown(
              data['last_supplier']!, _lastSupplierMeta));
    }
    if (data.containsKey('last_stock_date')) {
      context.handle(
          _lastStockDateMeta,
          lastStockDate.isAcceptableOrUnknown(
              data['last_stock_date']!, _lastStockDateMeta));
    }
    if (data.containsKey('low_stock_threshold')) {
      context.handle(
          _lowStockThresholdMeta,
          lowStockThreshold.isAcceptableOrUnknown(
              data['low_stock_threshold']!, _lowStockThresholdMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {sku};
  @override
  CatalogStockRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CatalogStockRow(
      sku: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}sku'])!,
      quantity: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}quantity'])!,
      lastPurchasePrice: attachedDatabase.typeMapping.read(
          DriftSqlType.int, data['${effectivePrefix}last_purchase_price']),
      lastSupplier: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}last_supplier']),
      lastStockDate: attachedDatabase.typeMapping.read(
          DriftSqlType.dateTime, data['${effectivePrefix}last_stock_date']),
      lowStockThreshold: attachedDatabase.typeMapping.read(
          DriftSqlType.int, data['${effectivePrefix}low_stock_threshold'])!,
    );
  }

  @override
  $CatalogStockTable createAlias(String alias) {
    return $CatalogStockTable(attachedDatabase, alias);
  }
}

class CatalogStockRow extends DataClass implements Insertable<CatalogStockRow> {
  final String sku;
  final int quantity;
  final int? lastPurchasePrice;
  final String? lastSupplier;
  final DateTime? lastStockDate;
  final int lowStockThreshold;
  const CatalogStockRow(
      {required this.sku,
      required this.quantity,
      this.lastPurchasePrice,
      this.lastSupplier,
      this.lastStockDate,
      required this.lowStockThreshold});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['sku'] = Variable<String>(sku);
    map['quantity'] = Variable<int>(quantity);
    if (!nullToAbsent || lastPurchasePrice != null) {
      map['last_purchase_price'] = Variable<int>(lastPurchasePrice);
    }
    if (!nullToAbsent || lastSupplier != null) {
      map['last_supplier'] = Variable<String>(lastSupplier);
    }
    if (!nullToAbsent || lastStockDate != null) {
      map['last_stock_date'] = Variable<DateTime>(lastStockDate);
    }
    map['low_stock_threshold'] = Variable<int>(lowStockThreshold);
    return map;
  }

  CatalogStockCompanion toCompanion(bool nullToAbsent) {
    return CatalogStockCompanion(
      sku: Value(sku),
      quantity: Value(quantity),
      lastPurchasePrice: lastPurchasePrice == null && nullToAbsent
          ? const Value.absent()
          : Value(lastPurchasePrice),
      lastSupplier: lastSupplier == null && nullToAbsent
          ? const Value.absent()
          : Value(lastSupplier),
      lastStockDate: lastStockDate == null && nullToAbsent
          ? const Value.absent()
          : Value(lastStockDate),
      lowStockThreshold: Value(lowStockThreshold),
    );
  }

  factory CatalogStockRow.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CatalogStockRow(
      sku: serializer.fromJson<String>(json['sku']),
      quantity: serializer.fromJson<int>(json['quantity']),
      lastPurchasePrice: serializer.fromJson<int?>(json['lastPurchasePrice']),
      lastSupplier: serializer.fromJson<String?>(json['lastSupplier']),
      lastStockDate: serializer.fromJson<DateTime?>(json['lastStockDate']),
      lowStockThreshold: serializer.fromJson<int>(json['lowStockThreshold']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'sku': serializer.toJson<String>(sku),
      'quantity': serializer.toJson<int>(quantity),
      'lastPurchasePrice': serializer.toJson<int?>(lastPurchasePrice),
      'lastSupplier': serializer.toJson<String?>(lastSupplier),
      'lastStockDate': serializer.toJson<DateTime?>(lastStockDate),
      'lowStockThreshold': serializer.toJson<int>(lowStockThreshold),
    };
  }

  CatalogStockRow copyWith(
          {String? sku,
          int? quantity,
          Value<int?> lastPurchasePrice = const Value.absent(),
          Value<String?> lastSupplier = const Value.absent(),
          Value<DateTime?> lastStockDate = const Value.absent(),
          int? lowStockThreshold}) =>
      CatalogStockRow(
        sku: sku ?? this.sku,
        quantity: quantity ?? this.quantity,
        lastPurchasePrice: lastPurchasePrice.present
            ? lastPurchasePrice.value
            : this.lastPurchasePrice,
        lastSupplier:
            lastSupplier.present ? lastSupplier.value : this.lastSupplier,
        lastStockDate:
            lastStockDate.present ? lastStockDate.value : this.lastStockDate,
        lowStockThreshold: lowStockThreshold ?? this.lowStockThreshold,
      );
  CatalogStockRow copyWithCompanion(CatalogStockCompanion data) {
    return CatalogStockRow(
      sku: data.sku.present ? data.sku.value : this.sku,
      quantity: data.quantity.present ? data.quantity.value : this.quantity,
      lastPurchasePrice: data.lastPurchasePrice.present
          ? data.lastPurchasePrice.value
          : this.lastPurchasePrice,
      lastSupplier: data.lastSupplier.present
          ? data.lastSupplier.value
          : this.lastSupplier,
      lastStockDate: data.lastStockDate.present
          ? data.lastStockDate.value
          : this.lastStockDate,
      lowStockThreshold: data.lowStockThreshold.present
          ? data.lowStockThreshold.value
          : this.lowStockThreshold,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CatalogStockRow(')
          ..write('sku: $sku, ')
          ..write('quantity: $quantity, ')
          ..write('lastPurchasePrice: $lastPurchasePrice, ')
          ..write('lastSupplier: $lastSupplier, ')
          ..write('lastStockDate: $lastStockDate, ')
          ..write('lowStockThreshold: $lowStockThreshold')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(sku, quantity, lastPurchasePrice,
      lastSupplier, lastStockDate, lowStockThreshold);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CatalogStockRow &&
          other.sku == this.sku &&
          other.quantity == this.quantity &&
          other.lastPurchasePrice == this.lastPurchasePrice &&
          other.lastSupplier == this.lastSupplier &&
          other.lastStockDate == this.lastStockDate &&
          other.lowStockThreshold == this.lowStockThreshold);
}

class CatalogStockCompanion extends UpdateCompanion<CatalogStockRow> {
  final Value<String> sku;
  final Value<int> quantity;
  final Value<int?> lastPurchasePrice;
  final Value<String?> lastSupplier;
  final Value<DateTime?> lastStockDate;
  final Value<int> lowStockThreshold;
  final Value<int> rowid;
  const CatalogStockCompanion({
    this.sku = const Value.absent(),
    this.quantity = const Value.absent(),
    this.lastPurchasePrice = const Value.absent(),
    this.lastSupplier = const Value.absent(),
    this.lastStockDate = const Value.absent(),
    this.lowStockThreshold = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  CatalogStockCompanion.insert({
    required String sku,
    this.quantity = const Value.absent(),
    this.lastPurchasePrice = const Value.absent(),
    this.lastSupplier = const Value.absent(),
    this.lastStockDate = const Value.absent(),
    this.lowStockThreshold = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : sku = Value(sku);
  static Insertable<CatalogStockRow> custom({
    Expression<String>? sku,
    Expression<int>? quantity,
    Expression<int>? lastPurchasePrice,
    Expression<String>? lastSupplier,
    Expression<DateTime>? lastStockDate,
    Expression<int>? lowStockThreshold,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (sku != null) 'sku': sku,
      if (quantity != null) 'quantity': quantity,
      if (lastPurchasePrice != null) 'last_purchase_price': lastPurchasePrice,
      if (lastSupplier != null) 'last_supplier': lastSupplier,
      if (lastStockDate != null) 'last_stock_date': lastStockDate,
      if (lowStockThreshold != null) 'low_stock_threshold': lowStockThreshold,
      if (rowid != null) 'rowid': rowid,
    });
  }

  CatalogStockCompanion copyWith(
      {Value<String>? sku,
      Value<int>? quantity,
      Value<int?>? lastPurchasePrice,
      Value<String?>? lastSupplier,
      Value<DateTime?>? lastStockDate,
      Value<int>? lowStockThreshold,
      Value<int>? rowid}) {
    return CatalogStockCompanion(
      sku: sku ?? this.sku,
      quantity: quantity ?? this.quantity,
      lastPurchasePrice: lastPurchasePrice ?? this.lastPurchasePrice,
      lastSupplier: lastSupplier ?? this.lastSupplier,
      lastStockDate: lastStockDate ?? this.lastStockDate,
      lowStockThreshold: lowStockThreshold ?? this.lowStockThreshold,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (sku.present) {
      map['sku'] = Variable<String>(sku.value);
    }
    if (quantity.present) {
      map['quantity'] = Variable<int>(quantity.value);
    }
    if (lastPurchasePrice.present) {
      map['last_purchase_price'] = Variable<int>(lastPurchasePrice.value);
    }
    if (lastSupplier.present) {
      map['last_supplier'] = Variable<String>(lastSupplier.value);
    }
    if (lastStockDate.present) {
      map['last_stock_date'] = Variable<DateTime>(lastStockDate.value);
    }
    if (lowStockThreshold.present) {
      map['low_stock_threshold'] = Variable<int>(lowStockThreshold.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CatalogStockCompanion(')
          ..write('sku: $sku, ')
          ..write('quantity: $quantity, ')
          ..write('lastPurchasePrice: $lastPurchasePrice, ')
          ..write('lastSupplier: $lastSupplier, ')
          ..write('lastStockDate: $lastStockDate, ')
          ..write('lowStockThreshold: $lowStockThreshold, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $StockCountsTable extends StockCounts
    with TableInfo<$StockCountsTable, StockCountRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $StockCountsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _skuMeta = const VerificationMeta('sku');
  @override
  late final GeneratedColumn<String> sku = GeneratedColumn<String>(
      'sku', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('REFERENCES catalog_items (sku)'));
  static const VerificationMeta _countedQtyMeta =
      const VerificationMeta('countedQty');
  @override
  late final GeneratedColumn<int> countedQty = GeneratedColumn<int>(
      'counted_qty', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _systemQtyMeta =
      const VerificationMeta('systemQty');
  @override
  late final GeneratedColumn<int> systemQty = GeneratedColumn<int>(
      'system_qty', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _differenceMeta =
      const VerificationMeta('difference');
  @override
  late final GeneratedColumn<int> difference = GeneratedColumn<int>(
      'difference', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _noteMeta = const VerificationMeta('note');
  @override
  late final GeneratedColumn<String> note = GeneratedColumn<String>(
      'note', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _countedByMeta =
      const VerificationMeta('countedBy');
  @override
  late final GeneratedColumn<String> countedBy = GeneratedColumn<String>(
      'counted_by', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _countedAtMeta =
      const VerificationMeta('countedAt');
  @override
  late final GeneratedColumn<DateTime> countedAt = GeneratedColumn<DateTime>(
      'counted_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  @override
  List<GeneratedColumn> get $columns =>
      [id, sku, countedQty, systemQty, difference, note, countedBy, countedAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'stock_counts';
  @override
  VerificationContext validateIntegrity(Insertable<StockCountRow> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('sku')) {
      context.handle(
          _skuMeta, sku.isAcceptableOrUnknown(data['sku']!, _skuMeta));
    } else if (isInserting) {
      context.missing(_skuMeta);
    }
    if (data.containsKey('counted_qty')) {
      context.handle(
          _countedQtyMeta,
          countedQty.isAcceptableOrUnknown(
              data['counted_qty']!, _countedQtyMeta));
    } else if (isInserting) {
      context.missing(_countedQtyMeta);
    }
    if (data.containsKey('system_qty')) {
      context.handle(_systemQtyMeta,
          systemQty.isAcceptableOrUnknown(data['system_qty']!, _systemQtyMeta));
    } else if (isInserting) {
      context.missing(_systemQtyMeta);
    }
    if (data.containsKey('difference')) {
      context.handle(
          _differenceMeta,
          difference.isAcceptableOrUnknown(
              data['difference']!, _differenceMeta));
    } else if (isInserting) {
      context.missing(_differenceMeta);
    }
    if (data.containsKey('note')) {
      context.handle(
          _noteMeta, note.isAcceptableOrUnknown(data['note']!, _noteMeta));
    }
    if (data.containsKey('counted_by')) {
      context.handle(_countedByMeta,
          countedBy.isAcceptableOrUnknown(data['counted_by']!, _countedByMeta));
    }
    if (data.containsKey('counted_at')) {
      context.handle(_countedAtMeta,
          countedAt.isAcceptableOrUnknown(data['counted_at']!, _countedAtMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  StockCountRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return StockCountRow(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      sku: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}sku'])!,
      countedQty: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}counted_qty'])!,
      systemQty: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}system_qty'])!,
      difference: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}difference'])!,
      note: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}note']),
      countedBy: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}counted_by']),
      countedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}counted_at'])!,
    );
  }

  @override
  $StockCountsTable createAlias(String alias) {
    return $StockCountsTable(attachedDatabase, alias);
  }
}

class StockCountRow extends DataClass implements Insertable<StockCountRow> {
  final int id;
  final String sku;
  final int countedQty;
  final int systemQty;
  final int difference;
  final String? note;
  final String? countedBy;
  final DateTime countedAt;
  const StockCountRow(
      {required this.id,
      required this.sku,
      required this.countedQty,
      required this.systemQty,
      required this.difference,
      this.note,
      this.countedBy,
      required this.countedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['sku'] = Variable<String>(sku);
    map['counted_qty'] = Variable<int>(countedQty);
    map['system_qty'] = Variable<int>(systemQty);
    map['difference'] = Variable<int>(difference);
    if (!nullToAbsent || note != null) {
      map['note'] = Variable<String>(note);
    }
    if (!nullToAbsent || countedBy != null) {
      map['counted_by'] = Variable<String>(countedBy);
    }
    map['counted_at'] = Variable<DateTime>(countedAt);
    return map;
  }

  StockCountsCompanion toCompanion(bool nullToAbsent) {
    return StockCountsCompanion(
      id: Value(id),
      sku: Value(sku),
      countedQty: Value(countedQty),
      systemQty: Value(systemQty),
      difference: Value(difference),
      note: note == null && nullToAbsent ? const Value.absent() : Value(note),
      countedBy: countedBy == null && nullToAbsent
          ? const Value.absent()
          : Value(countedBy),
      countedAt: Value(countedAt),
    );
  }

  factory StockCountRow.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return StockCountRow(
      id: serializer.fromJson<int>(json['id']),
      sku: serializer.fromJson<String>(json['sku']),
      countedQty: serializer.fromJson<int>(json['countedQty']),
      systemQty: serializer.fromJson<int>(json['systemQty']),
      difference: serializer.fromJson<int>(json['difference']),
      note: serializer.fromJson<String?>(json['note']),
      countedBy: serializer.fromJson<String?>(json['countedBy']),
      countedAt: serializer.fromJson<DateTime>(json['countedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'sku': serializer.toJson<String>(sku),
      'countedQty': serializer.toJson<int>(countedQty),
      'systemQty': serializer.toJson<int>(systemQty),
      'difference': serializer.toJson<int>(difference),
      'note': serializer.toJson<String?>(note),
      'countedBy': serializer.toJson<String?>(countedBy),
      'countedAt': serializer.toJson<DateTime>(countedAt),
    };
  }

  StockCountRow copyWith(
          {int? id,
          String? sku,
          int? countedQty,
          int? systemQty,
          int? difference,
          Value<String?> note = const Value.absent(),
          Value<String?> countedBy = const Value.absent(),
          DateTime? countedAt}) =>
      StockCountRow(
        id: id ?? this.id,
        sku: sku ?? this.sku,
        countedQty: countedQty ?? this.countedQty,
        systemQty: systemQty ?? this.systemQty,
        difference: difference ?? this.difference,
        note: note.present ? note.value : this.note,
        countedBy: countedBy.present ? countedBy.value : this.countedBy,
        countedAt: countedAt ?? this.countedAt,
      );
  StockCountRow copyWithCompanion(StockCountsCompanion data) {
    return StockCountRow(
      id: data.id.present ? data.id.value : this.id,
      sku: data.sku.present ? data.sku.value : this.sku,
      countedQty:
          data.countedQty.present ? data.countedQty.value : this.countedQty,
      systemQty: data.systemQty.present ? data.systemQty.value : this.systemQty,
      difference:
          data.difference.present ? data.difference.value : this.difference,
      note: data.note.present ? data.note.value : this.note,
      countedBy: data.countedBy.present ? data.countedBy.value : this.countedBy,
      countedAt: data.countedAt.present ? data.countedAt.value : this.countedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('StockCountRow(')
          ..write('id: $id, ')
          ..write('sku: $sku, ')
          ..write('countedQty: $countedQty, ')
          ..write('systemQty: $systemQty, ')
          ..write('difference: $difference, ')
          ..write('note: $note, ')
          ..write('countedBy: $countedBy, ')
          ..write('countedAt: $countedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id, sku, countedQty, systemQty, difference, note, countedBy, countedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is StockCountRow &&
          other.id == this.id &&
          other.sku == this.sku &&
          other.countedQty == this.countedQty &&
          other.systemQty == this.systemQty &&
          other.difference == this.difference &&
          other.note == this.note &&
          other.countedBy == this.countedBy &&
          other.countedAt == this.countedAt);
}

class StockCountsCompanion extends UpdateCompanion<StockCountRow> {
  final Value<int> id;
  final Value<String> sku;
  final Value<int> countedQty;
  final Value<int> systemQty;
  final Value<int> difference;
  final Value<String?> note;
  final Value<String?> countedBy;
  final Value<DateTime> countedAt;
  const StockCountsCompanion({
    this.id = const Value.absent(),
    this.sku = const Value.absent(),
    this.countedQty = const Value.absent(),
    this.systemQty = const Value.absent(),
    this.difference = const Value.absent(),
    this.note = const Value.absent(),
    this.countedBy = const Value.absent(),
    this.countedAt = const Value.absent(),
  });
  StockCountsCompanion.insert({
    this.id = const Value.absent(),
    required String sku,
    required int countedQty,
    required int systemQty,
    required int difference,
    this.note = const Value.absent(),
    this.countedBy = const Value.absent(),
    this.countedAt = const Value.absent(),
  })  : sku = Value(sku),
        countedQty = Value(countedQty),
        systemQty = Value(systemQty),
        difference = Value(difference);
  static Insertable<StockCountRow> custom({
    Expression<int>? id,
    Expression<String>? sku,
    Expression<int>? countedQty,
    Expression<int>? systemQty,
    Expression<int>? difference,
    Expression<String>? note,
    Expression<String>? countedBy,
    Expression<DateTime>? countedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (sku != null) 'sku': sku,
      if (countedQty != null) 'counted_qty': countedQty,
      if (systemQty != null) 'system_qty': systemQty,
      if (difference != null) 'difference': difference,
      if (note != null) 'note': note,
      if (countedBy != null) 'counted_by': countedBy,
      if (countedAt != null) 'counted_at': countedAt,
    });
  }

  StockCountsCompanion copyWith(
      {Value<int>? id,
      Value<String>? sku,
      Value<int>? countedQty,
      Value<int>? systemQty,
      Value<int>? difference,
      Value<String?>? note,
      Value<String?>? countedBy,
      Value<DateTime>? countedAt}) {
    return StockCountsCompanion(
      id: id ?? this.id,
      sku: sku ?? this.sku,
      countedQty: countedQty ?? this.countedQty,
      systemQty: systemQty ?? this.systemQty,
      difference: difference ?? this.difference,
      note: note ?? this.note,
      countedBy: countedBy ?? this.countedBy,
      countedAt: countedAt ?? this.countedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (sku.present) {
      map['sku'] = Variable<String>(sku.value);
    }
    if (countedQty.present) {
      map['counted_qty'] = Variable<int>(countedQty.value);
    }
    if (systemQty.present) {
      map['system_qty'] = Variable<int>(systemQty.value);
    }
    if (difference.present) {
      map['difference'] = Variable<int>(difference.value);
    }
    if (note.present) {
      map['note'] = Variable<String>(note.value);
    }
    if (countedBy.present) {
      map['counted_by'] = Variable<String>(countedBy.value);
    }
    if (countedAt.present) {
      map['counted_at'] = Variable<DateTime>(countedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('StockCountsCompanion(')
          ..write('id: $id, ')
          ..write('sku: $sku, ')
          ..write('countedQty: $countedQty, ')
          ..write('systemQty: $systemQty, ')
          ..write('difference: $difference, ')
          ..write('note: $note, ')
          ..write('countedBy: $countedBy, ')
          ..write('countedAt: $countedAt')
          ..write(')'))
        .toString();
  }
}

abstract class _$CatalogDatabase extends GeneratedDatabase {
  _$CatalogDatabase(QueryExecutor e) : super(e);
  $CatalogDatabaseManager get managers => $CatalogDatabaseManager(this);
  late final $CatalogVersionsTable catalogVersions =
      $CatalogVersionsTable(this);
  late final $CatalogCategoriesTable catalogCategories =
      $CatalogCategoriesTable(this);
  late final $CatalogItemsTable catalogItems = $CatalogItemsTable(this);
  late final $CatalogItemModelsTable catalogItemModels =
      $CatalogItemModelsTable(this);
  late final $BarcodeLinksTable barcodeLinks = $BarcodeLinksTable(this);
  late final $CatalogStockTable catalogStock = $CatalogStockTable(this);
  late final $StockCountsTable stockCounts = $StockCountsTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
        catalogVersions,
        catalogCategories,
        catalogItems,
        catalogItemModels,
        barcodeLinks,
        catalogStock,
        stockCounts
      ];
}

typedef $$CatalogVersionsTableCreateCompanionBuilder = CatalogVersionsCompanion
    Function({
  required String version,
  Value<DateTime> appliedAt,
  Value<int> itemCount,
  Value<String?> notes,
  Value<int> rowid,
});
typedef $$CatalogVersionsTableUpdateCompanionBuilder = CatalogVersionsCompanion
    Function({
  Value<String> version,
  Value<DateTime> appliedAt,
  Value<int> itemCount,
  Value<String?> notes,
  Value<int> rowid,
});

class $$CatalogVersionsTableFilterComposer
    extends Composer<_$CatalogDatabase, $CatalogVersionsTable> {
  $$CatalogVersionsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get version => $composableBuilder(
      column: $table.version, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get appliedAt => $composableBuilder(
      column: $table.appliedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get itemCount => $composableBuilder(
      column: $table.itemCount, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get notes => $composableBuilder(
      column: $table.notes, builder: (column) => ColumnFilters(column));
}

class $$CatalogVersionsTableOrderingComposer
    extends Composer<_$CatalogDatabase, $CatalogVersionsTable> {
  $$CatalogVersionsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get version => $composableBuilder(
      column: $table.version, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get appliedAt => $composableBuilder(
      column: $table.appliedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get itemCount => $composableBuilder(
      column: $table.itemCount, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get notes => $composableBuilder(
      column: $table.notes, builder: (column) => ColumnOrderings(column));
}

class $$CatalogVersionsTableAnnotationComposer
    extends Composer<_$CatalogDatabase, $CatalogVersionsTable> {
  $$CatalogVersionsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get version =>
      $composableBuilder(column: $table.version, builder: (column) => column);

  GeneratedColumn<DateTime> get appliedAt =>
      $composableBuilder(column: $table.appliedAt, builder: (column) => column);

  GeneratedColumn<int> get itemCount =>
      $composableBuilder(column: $table.itemCount, builder: (column) => column);

  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);
}

class $$CatalogVersionsTableTableManager extends RootTableManager<
    _$CatalogDatabase,
    $CatalogVersionsTable,
    CatalogVersionRow,
    $$CatalogVersionsTableFilterComposer,
    $$CatalogVersionsTableOrderingComposer,
    $$CatalogVersionsTableAnnotationComposer,
    $$CatalogVersionsTableCreateCompanionBuilder,
    $$CatalogVersionsTableUpdateCompanionBuilder,
    (
      CatalogVersionRow,
      BaseReferences<_$CatalogDatabase, $CatalogVersionsTable,
          CatalogVersionRow>
    ),
    CatalogVersionRow,
    PrefetchHooks Function()> {
  $$CatalogVersionsTableTableManager(
      _$CatalogDatabase db, $CatalogVersionsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CatalogVersionsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CatalogVersionsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CatalogVersionsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> version = const Value.absent(),
            Value<DateTime> appliedAt = const Value.absent(),
            Value<int> itemCount = const Value.absent(),
            Value<String?> notes = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              CatalogVersionsCompanion(
            version: version,
            appliedAt: appliedAt,
            itemCount: itemCount,
            notes: notes,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String version,
            Value<DateTime> appliedAt = const Value.absent(),
            Value<int> itemCount = const Value.absent(),
            Value<String?> notes = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              CatalogVersionsCompanion.insert(
            version: version,
            appliedAt: appliedAt,
            itemCount: itemCount,
            notes: notes,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$CatalogVersionsTableProcessedTableManager = ProcessedTableManager<
    _$CatalogDatabase,
    $CatalogVersionsTable,
    CatalogVersionRow,
    $$CatalogVersionsTableFilterComposer,
    $$CatalogVersionsTableOrderingComposer,
    $$CatalogVersionsTableAnnotationComposer,
    $$CatalogVersionsTableCreateCompanionBuilder,
    $$CatalogVersionsTableUpdateCompanionBuilder,
    (
      CatalogVersionRow,
      BaseReferences<_$CatalogDatabase, $CatalogVersionsTable,
          CatalogVersionRow>
    ),
    CatalogVersionRow,
    PrefetchHooks Function()>;
typedef $$CatalogCategoriesTableCreateCompanionBuilder
    = CatalogCategoriesCompanion Function({
  Value<int> id,
  required String nameEn,
  Value<String> nameUr,
  Value<int> sortOrder,
});
typedef $$CatalogCategoriesTableUpdateCompanionBuilder
    = CatalogCategoriesCompanion Function({
  Value<int> id,
  Value<String> nameEn,
  Value<String> nameUr,
  Value<int> sortOrder,
});

class $$CatalogCategoriesTableFilterComposer
    extends Composer<_$CatalogDatabase, $CatalogCategoriesTable> {
  $$CatalogCategoriesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get nameEn => $composableBuilder(
      column: $table.nameEn, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get nameUr => $composableBuilder(
      column: $table.nameUr, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get sortOrder => $composableBuilder(
      column: $table.sortOrder, builder: (column) => ColumnFilters(column));
}

class $$CatalogCategoriesTableOrderingComposer
    extends Composer<_$CatalogDatabase, $CatalogCategoriesTable> {
  $$CatalogCategoriesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get nameEn => $composableBuilder(
      column: $table.nameEn, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get nameUr => $composableBuilder(
      column: $table.nameUr, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get sortOrder => $composableBuilder(
      column: $table.sortOrder, builder: (column) => ColumnOrderings(column));
}

class $$CatalogCategoriesTableAnnotationComposer
    extends Composer<_$CatalogDatabase, $CatalogCategoriesTable> {
  $$CatalogCategoriesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get nameEn =>
      $composableBuilder(column: $table.nameEn, builder: (column) => column);

  GeneratedColumn<String> get nameUr =>
      $composableBuilder(column: $table.nameUr, builder: (column) => column);

  GeneratedColumn<int> get sortOrder =>
      $composableBuilder(column: $table.sortOrder, builder: (column) => column);
}

class $$CatalogCategoriesTableTableManager extends RootTableManager<
    _$CatalogDatabase,
    $CatalogCategoriesTable,
    CatalogCategoryRow,
    $$CatalogCategoriesTableFilterComposer,
    $$CatalogCategoriesTableOrderingComposer,
    $$CatalogCategoriesTableAnnotationComposer,
    $$CatalogCategoriesTableCreateCompanionBuilder,
    $$CatalogCategoriesTableUpdateCompanionBuilder,
    (
      CatalogCategoryRow,
      BaseReferences<_$CatalogDatabase, $CatalogCategoriesTable,
          CatalogCategoryRow>
    ),
    CatalogCategoryRow,
    PrefetchHooks Function()> {
  $$CatalogCategoriesTableTableManager(
      _$CatalogDatabase db, $CatalogCategoriesTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CatalogCategoriesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CatalogCategoriesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CatalogCategoriesTableAnnotationComposer(
                  $db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<String> nameEn = const Value.absent(),
            Value<String> nameUr = const Value.absent(),
            Value<int> sortOrder = const Value.absent(),
          }) =>
              CatalogCategoriesCompanion(
            id: id,
            nameEn: nameEn,
            nameUr: nameUr,
            sortOrder: sortOrder,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required String nameEn,
            Value<String> nameUr = const Value.absent(),
            Value<int> sortOrder = const Value.absent(),
          }) =>
              CatalogCategoriesCompanion.insert(
            id: id,
            nameEn: nameEn,
            nameUr: nameUr,
            sortOrder: sortOrder,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$CatalogCategoriesTableProcessedTableManager = ProcessedTableManager<
    _$CatalogDatabase,
    $CatalogCategoriesTable,
    CatalogCategoryRow,
    $$CatalogCategoriesTableFilterComposer,
    $$CatalogCategoriesTableOrderingComposer,
    $$CatalogCategoriesTableAnnotationComposer,
    $$CatalogCategoriesTableCreateCompanionBuilder,
    $$CatalogCategoriesTableUpdateCompanionBuilder,
    (
      CatalogCategoryRow,
      BaseReferences<_$CatalogDatabase, $CatalogCategoriesTable,
          CatalogCategoryRow>
    ),
    CatalogCategoryRow,
    PrefetchHooks Function()>;
typedef $$CatalogItemsTableCreateCompanionBuilder = CatalogItemsCompanion
    Function({
  required String sku,
  required String category,
  required String brand,
  required String nameEn,
  Value<String> nameUr,
  Value<String?> modelCompatibility,
  Value<String> colors,
  Value<String> variants,
  Value<int> purchasePriceEst,
  Value<int> salePriceEst,
  Value<int> minPrice,
  Value<String> unit,
  Value<String?> barcode,
  Value<bool> isCustom,
  Value<bool> estimated,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
  Value<int> rowid,
});
typedef $$CatalogItemsTableUpdateCompanionBuilder = CatalogItemsCompanion
    Function({
  Value<String> sku,
  Value<String> category,
  Value<String> brand,
  Value<String> nameEn,
  Value<String> nameUr,
  Value<String?> modelCompatibility,
  Value<String> colors,
  Value<String> variants,
  Value<int> purchasePriceEst,
  Value<int> salePriceEst,
  Value<int> minPrice,
  Value<String> unit,
  Value<String?> barcode,
  Value<bool> isCustom,
  Value<bool> estimated,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
  Value<int> rowid,
});

final class $$CatalogItemsTableReferences extends BaseReferences<
    _$CatalogDatabase, $CatalogItemsTable, CatalogItemRow> {
  $$CatalogItemsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$CatalogItemModelsTable, List<CatalogItemModelRow>>
      _catalogItemModelsRefsTable(_$CatalogDatabase db) =>
          MultiTypedResultKey.fromTable(db.catalogItemModels,
              aliasName: $_aliasNameGenerator(
                  db.catalogItems.sku, db.catalogItemModels.sku));

  $$CatalogItemModelsTableProcessedTableManager get catalogItemModelsRefs {
    final manager =
        $$CatalogItemModelsTableTableManager($_db, $_db.catalogItemModels)
            .filter((f) => f.sku.sku.sqlEquals($_itemColumn<String>('sku')!));

    final cache =
        $_typedResult.readTableOrNull(_catalogItemModelsRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }

  static MultiTypedResultKey<$BarcodeLinksTable, List<BarcodeLinkRow>>
      _barcodeLinksRefsTable(_$CatalogDatabase db) =>
          MultiTypedResultKey.fromTable(db.barcodeLinks,
              aliasName: $_aliasNameGenerator(
                  db.catalogItems.sku, db.barcodeLinks.sku));

  $$BarcodeLinksTableProcessedTableManager get barcodeLinksRefs {
    final manager = $$BarcodeLinksTableTableManager($_db, $_db.barcodeLinks)
        .filter((f) => f.sku.sku.sqlEquals($_itemColumn<String>('sku')!));

    final cache = $_typedResult.readTableOrNull(_barcodeLinksRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }

  static MultiTypedResultKey<$CatalogStockTable, List<CatalogStockRow>>
      _catalogStockRefsTable(_$CatalogDatabase db) =>
          MultiTypedResultKey.fromTable(db.catalogStock,
              aliasName: $_aliasNameGenerator(
                  db.catalogItems.sku, db.catalogStock.sku));

  $$CatalogStockTableProcessedTableManager get catalogStockRefs {
    final manager = $$CatalogStockTableTableManager($_db, $_db.catalogStock)
        .filter((f) => f.sku.sku.sqlEquals($_itemColumn<String>('sku')!));

    final cache = $_typedResult.readTableOrNull(_catalogStockRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }

  static MultiTypedResultKey<$StockCountsTable, List<StockCountRow>>
      _stockCountsRefsTable(_$CatalogDatabase db) =>
          MultiTypedResultKey.fromTable(db.stockCounts,
              aliasName: $_aliasNameGenerator(
                  db.catalogItems.sku, db.stockCounts.sku));

  $$StockCountsTableProcessedTableManager get stockCountsRefs {
    final manager = $$StockCountsTableTableManager($_db, $_db.stockCounts)
        .filter((f) => f.sku.sku.sqlEquals($_itemColumn<String>('sku')!));

    final cache = $_typedResult.readTableOrNull(_stockCountsRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }
}

class $$CatalogItemsTableFilterComposer
    extends Composer<_$CatalogDatabase, $CatalogItemsTable> {
  $$CatalogItemsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get sku => $composableBuilder(
      column: $table.sku, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get category => $composableBuilder(
      column: $table.category, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get brand => $composableBuilder(
      column: $table.brand, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get nameEn => $composableBuilder(
      column: $table.nameEn, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get nameUr => $composableBuilder(
      column: $table.nameUr, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get modelCompatibility => $composableBuilder(
      column: $table.modelCompatibility,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get colors => $composableBuilder(
      column: $table.colors, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get variants => $composableBuilder(
      column: $table.variants, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get purchasePriceEst => $composableBuilder(
      column: $table.purchasePriceEst,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get salePriceEst => $composableBuilder(
      column: $table.salePriceEst, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get minPrice => $composableBuilder(
      column: $table.minPrice, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get unit => $composableBuilder(
      column: $table.unit, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get barcode => $composableBuilder(
      column: $table.barcode, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isCustom => $composableBuilder(
      column: $table.isCustom, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get estimated => $composableBuilder(
      column: $table.estimated, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnFilters(column));

  Expression<bool> catalogItemModelsRefs(
      Expression<bool> Function($$CatalogItemModelsTableFilterComposer f) f) {
    final $$CatalogItemModelsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.sku,
        referencedTable: $db.catalogItemModels,
        getReferencedColumn: (t) => t.sku,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$CatalogItemModelsTableFilterComposer(
              $db: $db,
              $table: $db.catalogItemModels,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }

  Expression<bool> barcodeLinksRefs(
      Expression<bool> Function($$BarcodeLinksTableFilterComposer f) f) {
    final $$BarcodeLinksTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.sku,
        referencedTable: $db.barcodeLinks,
        getReferencedColumn: (t) => t.sku,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$BarcodeLinksTableFilterComposer(
              $db: $db,
              $table: $db.barcodeLinks,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }

  Expression<bool> catalogStockRefs(
      Expression<bool> Function($$CatalogStockTableFilterComposer f) f) {
    final $$CatalogStockTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.sku,
        referencedTable: $db.catalogStock,
        getReferencedColumn: (t) => t.sku,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$CatalogStockTableFilterComposer(
              $db: $db,
              $table: $db.catalogStock,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }

  Expression<bool> stockCountsRefs(
      Expression<bool> Function($$StockCountsTableFilterComposer f) f) {
    final $$StockCountsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.sku,
        referencedTable: $db.stockCounts,
        getReferencedColumn: (t) => t.sku,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$StockCountsTableFilterComposer(
              $db: $db,
              $table: $db.stockCounts,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }
}

class $$CatalogItemsTableOrderingComposer
    extends Composer<_$CatalogDatabase, $CatalogItemsTable> {
  $$CatalogItemsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get sku => $composableBuilder(
      column: $table.sku, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get category => $composableBuilder(
      column: $table.category, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get brand => $composableBuilder(
      column: $table.brand, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get nameEn => $composableBuilder(
      column: $table.nameEn, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get nameUr => $composableBuilder(
      column: $table.nameUr, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get modelCompatibility => $composableBuilder(
      column: $table.modelCompatibility,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get colors => $composableBuilder(
      column: $table.colors, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get variants => $composableBuilder(
      column: $table.variants, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get purchasePriceEst => $composableBuilder(
      column: $table.purchasePriceEst,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get salePriceEst => $composableBuilder(
      column: $table.salePriceEst,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get minPrice => $composableBuilder(
      column: $table.minPrice, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get unit => $composableBuilder(
      column: $table.unit, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get barcode => $composableBuilder(
      column: $table.barcode, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isCustom => $composableBuilder(
      column: $table.isCustom, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get estimated => $composableBuilder(
      column: $table.estimated, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnOrderings(column));
}

class $$CatalogItemsTableAnnotationComposer
    extends Composer<_$CatalogDatabase, $CatalogItemsTable> {
  $$CatalogItemsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get sku =>
      $composableBuilder(column: $table.sku, builder: (column) => column);

  GeneratedColumn<String> get category =>
      $composableBuilder(column: $table.category, builder: (column) => column);

  GeneratedColumn<String> get brand =>
      $composableBuilder(column: $table.brand, builder: (column) => column);

  GeneratedColumn<String> get nameEn =>
      $composableBuilder(column: $table.nameEn, builder: (column) => column);

  GeneratedColumn<String> get nameUr =>
      $composableBuilder(column: $table.nameUr, builder: (column) => column);

  GeneratedColumn<String> get modelCompatibility => $composableBuilder(
      column: $table.modelCompatibility, builder: (column) => column);

  GeneratedColumn<String> get colors =>
      $composableBuilder(column: $table.colors, builder: (column) => column);

  GeneratedColumn<String> get variants =>
      $composableBuilder(column: $table.variants, builder: (column) => column);

  GeneratedColumn<int> get purchasePriceEst => $composableBuilder(
      column: $table.purchasePriceEst, builder: (column) => column);

  GeneratedColumn<int> get salePriceEst => $composableBuilder(
      column: $table.salePriceEst, builder: (column) => column);

  GeneratedColumn<int> get minPrice =>
      $composableBuilder(column: $table.minPrice, builder: (column) => column);

  GeneratedColumn<String> get unit =>
      $composableBuilder(column: $table.unit, builder: (column) => column);

  GeneratedColumn<String> get barcode =>
      $composableBuilder(column: $table.barcode, builder: (column) => column);

  GeneratedColumn<bool> get isCustom =>
      $composableBuilder(column: $table.isCustom, builder: (column) => column);

  GeneratedColumn<bool> get estimated =>
      $composableBuilder(column: $table.estimated, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  Expression<T> catalogItemModelsRefs<T extends Object>(
      Expression<T> Function($$CatalogItemModelsTableAnnotationComposer a) f) {
    final $$CatalogItemModelsTableAnnotationComposer composer =
        $composerBuilder(
            composer: this,
            getCurrentColumn: (t) => t.sku,
            referencedTable: $db.catalogItemModels,
            getReferencedColumn: (t) => t.sku,
            builder: (joinBuilder,
                    {$addJoinBuilderToRootComposer,
                    $removeJoinBuilderFromRootComposer}) =>
                $$CatalogItemModelsTableAnnotationComposer(
                  $db: $db,
                  $table: $db.catalogItemModels,
                  $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                  joinBuilder: joinBuilder,
                  $removeJoinBuilderFromRootComposer:
                      $removeJoinBuilderFromRootComposer,
                ));
    return f(composer);
  }

  Expression<T> barcodeLinksRefs<T extends Object>(
      Expression<T> Function($$BarcodeLinksTableAnnotationComposer a) f) {
    final $$BarcodeLinksTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.sku,
        referencedTable: $db.barcodeLinks,
        getReferencedColumn: (t) => t.sku,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$BarcodeLinksTableAnnotationComposer(
              $db: $db,
              $table: $db.barcodeLinks,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }

  Expression<T> catalogStockRefs<T extends Object>(
      Expression<T> Function($$CatalogStockTableAnnotationComposer a) f) {
    final $$CatalogStockTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.sku,
        referencedTable: $db.catalogStock,
        getReferencedColumn: (t) => t.sku,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$CatalogStockTableAnnotationComposer(
              $db: $db,
              $table: $db.catalogStock,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }

  Expression<T> stockCountsRefs<T extends Object>(
      Expression<T> Function($$StockCountsTableAnnotationComposer a) f) {
    final $$StockCountsTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.sku,
        referencedTable: $db.stockCounts,
        getReferencedColumn: (t) => t.sku,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$StockCountsTableAnnotationComposer(
              $db: $db,
              $table: $db.stockCounts,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }
}

class $$CatalogItemsTableTableManager extends RootTableManager<
    _$CatalogDatabase,
    $CatalogItemsTable,
    CatalogItemRow,
    $$CatalogItemsTableFilterComposer,
    $$CatalogItemsTableOrderingComposer,
    $$CatalogItemsTableAnnotationComposer,
    $$CatalogItemsTableCreateCompanionBuilder,
    $$CatalogItemsTableUpdateCompanionBuilder,
    (CatalogItemRow, $$CatalogItemsTableReferences),
    CatalogItemRow,
    PrefetchHooks Function(
        {bool catalogItemModelsRefs,
        bool barcodeLinksRefs,
        bool catalogStockRefs,
        bool stockCountsRefs})> {
  $$CatalogItemsTableTableManager(
      _$CatalogDatabase db, $CatalogItemsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CatalogItemsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CatalogItemsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CatalogItemsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> sku = const Value.absent(),
            Value<String> category = const Value.absent(),
            Value<String> brand = const Value.absent(),
            Value<String> nameEn = const Value.absent(),
            Value<String> nameUr = const Value.absent(),
            Value<String?> modelCompatibility = const Value.absent(),
            Value<String> colors = const Value.absent(),
            Value<String> variants = const Value.absent(),
            Value<int> purchasePriceEst = const Value.absent(),
            Value<int> salePriceEst = const Value.absent(),
            Value<int> minPrice = const Value.absent(),
            Value<String> unit = const Value.absent(),
            Value<String?> barcode = const Value.absent(),
            Value<bool> isCustom = const Value.absent(),
            Value<bool> estimated = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              CatalogItemsCompanion(
            sku: sku,
            category: category,
            brand: brand,
            nameEn: nameEn,
            nameUr: nameUr,
            modelCompatibility: modelCompatibility,
            colors: colors,
            variants: variants,
            purchasePriceEst: purchasePriceEst,
            salePriceEst: salePriceEst,
            minPrice: minPrice,
            unit: unit,
            barcode: barcode,
            isCustom: isCustom,
            estimated: estimated,
            createdAt: createdAt,
            updatedAt: updatedAt,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String sku,
            required String category,
            required String brand,
            required String nameEn,
            Value<String> nameUr = const Value.absent(),
            Value<String?> modelCompatibility = const Value.absent(),
            Value<String> colors = const Value.absent(),
            Value<String> variants = const Value.absent(),
            Value<int> purchasePriceEst = const Value.absent(),
            Value<int> salePriceEst = const Value.absent(),
            Value<int> minPrice = const Value.absent(),
            Value<String> unit = const Value.absent(),
            Value<String?> barcode = const Value.absent(),
            Value<bool> isCustom = const Value.absent(),
            Value<bool> estimated = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              CatalogItemsCompanion.insert(
            sku: sku,
            category: category,
            brand: brand,
            nameEn: nameEn,
            nameUr: nameUr,
            modelCompatibility: modelCompatibility,
            colors: colors,
            variants: variants,
            purchasePriceEst: purchasePriceEst,
            salePriceEst: salePriceEst,
            minPrice: minPrice,
            unit: unit,
            barcode: barcode,
            isCustom: isCustom,
            estimated: estimated,
            createdAt: createdAt,
            updatedAt: updatedAt,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable(table),
                    $$CatalogItemsTableReferences(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: (
              {catalogItemModelsRefs = false,
              barcodeLinksRefs = false,
              catalogStockRefs = false,
              stockCountsRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [
                if (catalogItemModelsRefs) db.catalogItemModels,
                if (barcodeLinksRefs) db.barcodeLinks,
                if (catalogStockRefs) db.catalogStock,
                if (stockCountsRefs) db.stockCounts
              ],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (catalogItemModelsRefs)
                    await $_getPrefetchedData<CatalogItemRow,
                            $CatalogItemsTable, CatalogItemModelRow>(
                        currentTable: table,
                        referencedTable: $$CatalogItemsTableReferences
                            ._catalogItemModelsRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$CatalogItemsTableReferences(db, table, p0)
                                .catalogItemModelsRefs,
                        referencedItemsForCurrentItem:
                            (item, referencedItems) =>
                                referencedItems.where((e) => e.sku == item.sku),
                        typedResults: items),
                  if (barcodeLinksRefs)
                    await $_getPrefetchedData<CatalogItemRow,
                            $CatalogItemsTable, BarcodeLinkRow>(
                        currentTable: table,
                        referencedTable: $$CatalogItemsTableReferences
                            ._barcodeLinksRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$CatalogItemsTableReferences(db, table, p0)
                                .barcodeLinksRefs,
                        referencedItemsForCurrentItem:
                            (item, referencedItems) =>
                                referencedItems.where((e) => e.sku == item.sku),
                        typedResults: items),
                  if (catalogStockRefs)
                    await $_getPrefetchedData<CatalogItemRow,
                            $CatalogItemsTable, CatalogStockRow>(
                        currentTable: table,
                        referencedTable: $$CatalogItemsTableReferences
                            ._catalogStockRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$CatalogItemsTableReferences(db, table, p0)
                                .catalogStockRefs,
                        referencedItemsForCurrentItem:
                            (item, referencedItems) =>
                                referencedItems.where((e) => e.sku == item.sku),
                        typedResults: items),
                  if (stockCountsRefs)
                    await $_getPrefetchedData<CatalogItemRow, $CatalogItemsTable,
                            StockCountRow>(
                        currentTable: table,
                        referencedTable: $$CatalogItemsTableReferences
                            ._stockCountsRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$CatalogItemsTableReferences(db, table, p0)
                                .stockCountsRefs,
                        referencedItemsForCurrentItem:
                            (item, referencedItems) =>
                                referencedItems.where((e) => e.sku == item.sku),
                        typedResults: items)
                ];
              },
            );
          },
        ));
}

typedef $$CatalogItemsTableProcessedTableManager = ProcessedTableManager<
    _$CatalogDatabase,
    $CatalogItemsTable,
    CatalogItemRow,
    $$CatalogItemsTableFilterComposer,
    $$CatalogItemsTableOrderingComposer,
    $$CatalogItemsTableAnnotationComposer,
    $$CatalogItemsTableCreateCompanionBuilder,
    $$CatalogItemsTableUpdateCompanionBuilder,
    (CatalogItemRow, $$CatalogItemsTableReferences),
    CatalogItemRow,
    PrefetchHooks Function(
        {bool catalogItemModelsRefs,
        bool barcodeLinksRefs,
        bool catalogStockRefs,
        bool stockCountsRefs})>;
typedef $$CatalogItemModelsTableCreateCompanionBuilder
    = CatalogItemModelsCompanion Function({
  required String sku,
  required String deviceBrand,
  required String deviceModel,
  Value<int> rowid,
});
typedef $$CatalogItemModelsTableUpdateCompanionBuilder
    = CatalogItemModelsCompanion Function({
  Value<String> sku,
  Value<String> deviceBrand,
  Value<String> deviceModel,
  Value<int> rowid,
});

final class $$CatalogItemModelsTableReferences extends BaseReferences<
    _$CatalogDatabase, $CatalogItemModelsTable, CatalogItemModelRow> {
  $$CatalogItemModelsTableReferences(
      super.$_db, super.$_table, super.$_typedResult);

  static $CatalogItemsTable _skuTable(_$CatalogDatabase db) =>
      db.catalogItems.createAlias(
          $_aliasNameGenerator(db.catalogItemModels.sku, db.catalogItems.sku));

  $$CatalogItemsTableProcessedTableManager get sku {
    final $_column = $_itemColumn<String>('sku')!;

    final manager = $$CatalogItemsTableTableManager($_db, $_db.catalogItems)
        .filter((f) => f.sku.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_skuTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }
}

class $$CatalogItemModelsTableFilterComposer
    extends Composer<_$CatalogDatabase, $CatalogItemModelsTable> {
  $$CatalogItemModelsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get deviceBrand => $composableBuilder(
      column: $table.deviceBrand, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get deviceModel => $composableBuilder(
      column: $table.deviceModel, builder: (column) => ColumnFilters(column));

  $$CatalogItemsTableFilterComposer get sku {
    final $$CatalogItemsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.sku,
        referencedTable: $db.catalogItems,
        getReferencedColumn: (t) => t.sku,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$CatalogItemsTableFilterComposer(
              $db: $db,
              $table: $db.catalogItems,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$CatalogItemModelsTableOrderingComposer
    extends Composer<_$CatalogDatabase, $CatalogItemModelsTable> {
  $$CatalogItemModelsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get deviceBrand => $composableBuilder(
      column: $table.deviceBrand, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get deviceModel => $composableBuilder(
      column: $table.deviceModel, builder: (column) => ColumnOrderings(column));

  $$CatalogItemsTableOrderingComposer get sku {
    final $$CatalogItemsTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.sku,
        referencedTable: $db.catalogItems,
        getReferencedColumn: (t) => t.sku,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$CatalogItemsTableOrderingComposer(
              $db: $db,
              $table: $db.catalogItems,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$CatalogItemModelsTableAnnotationComposer
    extends Composer<_$CatalogDatabase, $CatalogItemModelsTable> {
  $$CatalogItemModelsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get deviceBrand => $composableBuilder(
      column: $table.deviceBrand, builder: (column) => column);

  GeneratedColumn<String> get deviceModel => $composableBuilder(
      column: $table.deviceModel, builder: (column) => column);

  $$CatalogItemsTableAnnotationComposer get sku {
    final $$CatalogItemsTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.sku,
        referencedTable: $db.catalogItems,
        getReferencedColumn: (t) => t.sku,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$CatalogItemsTableAnnotationComposer(
              $db: $db,
              $table: $db.catalogItems,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$CatalogItemModelsTableTableManager extends RootTableManager<
    _$CatalogDatabase,
    $CatalogItemModelsTable,
    CatalogItemModelRow,
    $$CatalogItemModelsTableFilterComposer,
    $$CatalogItemModelsTableOrderingComposer,
    $$CatalogItemModelsTableAnnotationComposer,
    $$CatalogItemModelsTableCreateCompanionBuilder,
    $$CatalogItemModelsTableUpdateCompanionBuilder,
    (CatalogItemModelRow, $$CatalogItemModelsTableReferences),
    CatalogItemModelRow,
    PrefetchHooks Function({bool sku})> {
  $$CatalogItemModelsTableTableManager(
      _$CatalogDatabase db, $CatalogItemModelsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CatalogItemModelsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CatalogItemModelsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CatalogItemModelsTableAnnotationComposer(
                  $db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> sku = const Value.absent(),
            Value<String> deviceBrand = const Value.absent(),
            Value<String> deviceModel = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              CatalogItemModelsCompanion(
            sku: sku,
            deviceBrand: deviceBrand,
            deviceModel: deviceModel,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String sku,
            required String deviceBrand,
            required String deviceModel,
            Value<int> rowid = const Value.absent(),
          }) =>
              CatalogItemModelsCompanion.insert(
            sku: sku,
            deviceBrand: deviceBrand,
            deviceModel: deviceModel,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable(table),
                    $$CatalogItemModelsTableReferences(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: ({sku = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins: <
                  T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic>>(state) {
                if (sku) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.sku,
                    referencedTable:
                        $$CatalogItemModelsTableReferences._skuTable(db),
                    referencedColumn:
                        $$CatalogItemModelsTableReferences._skuTable(db).sku,
                  ) as T;
                }

                return state;
              },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ));
}

typedef $$CatalogItemModelsTableProcessedTableManager = ProcessedTableManager<
    _$CatalogDatabase,
    $CatalogItemModelsTable,
    CatalogItemModelRow,
    $$CatalogItemModelsTableFilterComposer,
    $$CatalogItemModelsTableOrderingComposer,
    $$CatalogItemModelsTableAnnotationComposer,
    $$CatalogItemModelsTableCreateCompanionBuilder,
    $$CatalogItemModelsTableUpdateCompanionBuilder,
    (CatalogItemModelRow, $$CatalogItemModelsTableReferences),
    CatalogItemModelRow,
    PrefetchHooks Function({bool sku})>;
typedef $$BarcodeLinksTableCreateCompanionBuilder = BarcodeLinksCompanion
    Function({
  required String barcode,
  required String sku,
  Value<DateTime> linkedAt,
  Value<int> rowid,
});
typedef $$BarcodeLinksTableUpdateCompanionBuilder = BarcodeLinksCompanion
    Function({
  Value<String> barcode,
  Value<String> sku,
  Value<DateTime> linkedAt,
  Value<int> rowid,
});

final class $$BarcodeLinksTableReferences extends BaseReferences<
    _$CatalogDatabase, $BarcodeLinksTable, BarcodeLinkRow> {
  $$BarcodeLinksTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $CatalogItemsTable _skuTable(_$CatalogDatabase db) =>
      db.catalogItems.createAlias(
          $_aliasNameGenerator(db.barcodeLinks.sku, db.catalogItems.sku));

  $$CatalogItemsTableProcessedTableManager get sku {
    final $_column = $_itemColumn<String>('sku')!;

    final manager = $$CatalogItemsTableTableManager($_db, $_db.catalogItems)
        .filter((f) => f.sku.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_skuTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }
}

class $$BarcodeLinksTableFilterComposer
    extends Composer<_$CatalogDatabase, $BarcodeLinksTable> {
  $$BarcodeLinksTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get barcode => $composableBuilder(
      column: $table.barcode, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get linkedAt => $composableBuilder(
      column: $table.linkedAt, builder: (column) => ColumnFilters(column));

  $$CatalogItemsTableFilterComposer get sku {
    final $$CatalogItemsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.sku,
        referencedTable: $db.catalogItems,
        getReferencedColumn: (t) => t.sku,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$CatalogItemsTableFilterComposer(
              $db: $db,
              $table: $db.catalogItems,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$BarcodeLinksTableOrderingComposer
    extends Composer<_$CatalogDatabase, $BarcodeLinksTable> {
  $$BarcodeLinksTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get barcode => $composableBuilder(
      column: $table.barcode, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get linkedAt => $composableBuilder(
      column: $table.linkedAt, builder: (column) => ColumnOrderings(column));

  $$CatalogItemsTableOrderingComposer get sku {
    final $$CatalogItemsTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.sku,
        referencedTable: $db.catalogItems,
        getReferencedColumn: (t) => t.sku,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$CatalogItemsTableOrderingComposer(
              $db: $db,
              $table: $db.catalogItems,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$BarcodeLinksTableAnnotationComposer
    extends Composer<_$CatalogDatabase, $BarcodeLinksTable> {
  $$BarcodeLinksTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get barcode =>
      $composableBuilder(column: $table.barcode, builder: (column) => column);

  GeneratedColumn<DateTime> get linkedAt =>
      $composableBuilder(column: $table.linkedAt, builder: (column) => column);

  $$CatalogItemsTableAnnotationComposer get sku {
    final $$CatalogItemsTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.sku,
        referencedTable: $db.catalogItems,
        getReferencedColumn: (t) => t.sku,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$CatalogItemsTableAnnotationComposer(
              $db: $db,
              $table: $db.catalogItems,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$BarcodeLinksTableTableManager extends RootTableManager<
    _$CatalogDatabase,
    $BarcodeLinksTable,
    BarcodeLinkRow,
    $$BarcodeLinksTableFilterComposer,
    $$BarcodeLinksTableOrderingComposer,
    $$BarcodeLinksTableAnnotationComposer,
    $$BarcodeLinksTableCreateCompanionBuilder,
    $$BarcodeLinksTableUpdateCompanionBuilder,
    (BarcodeLinkRow, $$BarcodeLinksTableReferences),
    BarcodeLinkRow,
    PrefetchHooks Function({bool sku})> {
  $$BarcodeLinksTableTableManager(
      _$CatalogDatabase db, $BarcodeLinksTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$BarcodeLinksTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$BarcodeLinksTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$BarcodeLinksTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> barcode = const Value.absent(),
            Value<String> sku = const Value.absent(),
            Value<DateTime> linkedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              BarcodeLinksCompanion(
            barcode: barcode,
            sku: sku,
            linkedAt: linkedAt,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String barcode,
            required String sku,
            Value<DateTime> linkedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              BarcodeLinksCompanion.insert(
            barcode: barcode,
            sku: sku,
            linkedAt: linkedAt,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable(table),
                    $$BarcodeLinksTableReferences(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: ({sku = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins: <
                  T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic>>(state) {
                if (sku) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.sku,
                    referencedTable:
                        $$BarcodeLinksTableReferences._skuTable(db),
                    referencedColumn:
                        $$BarcodeLinksTableReferences._skuTable(db).sku,
                  ) as T;
                }

                return state;
              },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ));
}

typedef $$BarcodeLinksTableProcessedTableManager = ProcessedTableManager<
    _$CatalogDatabase,
    $BarcodeLinksTable,
    BarcodeLinkRow,
    $$BarcodeLinksTableFilterComposer,
    $$BarcodeLinksTableOrderingComposer,
    $$BarcodeLinksTableAnnotationComposer,
    $$BarcodeLinksTableCreateCompanionBuilder,
    $$BarcodeLinksTableUpdateCompanionBuilder,
    (BarcodeLinkRow, $$BarcodeLinksTableReferences),
    BarcodeLinkRow,
    PrefetchHooks Function({bool sku})>;
typedef $$CatalogStockTableCreateCompanionBuilder = CatalogStockCompanion
    Function({
  required String sku,
  Value<int> quantity,
  Value<int?> lastPurchasePrice,
  Value<String?> lastSupplier,
  Value<DateTime?> lastStockDate,
  Value<int> lowStockThreshold,
  Value<int> rowid,
});
typedef $$CatalogStockTableUpdateCompanionBuilder = CatalogStockCompanion
    Function({
  Value<String> sku,
  Value<int> quantity,
  Value<int?> lastPurchasePrice,
  Value<String?> lastSupplier,
  Value<DateTime?> lastStockDate,
  Value<int> lowStockThreshold,
  Value<int> rowid,
});

final class $$CatalogStockTableReferences extends BaseReferences<
    _$CatalogDatabase, $CatalogStockTable, CatalogStockRow> {
  $$CatalogStockTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $CatalogItemsTable _skuTable(_$CatalogDatabase db) =>
      db.catalogItems.createAlias(
          $_aliasNameGenerator(db.catalogStock.sku, db.catalogItems.sku));

  $$CatalogItemsTableProcessedTableManager get sku {
    final $_column = $_itemColumn<String>('sku')!;

    final manager = $$CatalogItemsTableTableManager($_db, $_db.catalogItems)
        .filter((f) => f.sku.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_skuTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }
}

class $$CatalogStockTableFilterComposer
    extends Composer<_$CatalogDatabase, $CatalogStockTable> {
  $$CatalogStockTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get quantity => $composableBuilder(
      column: $table.quantity, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get lastPurchasePrice => $composableBuilder(
      column: $table.lastPurchasePrice,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get lastSupplier => $composableBuilder(
      column: $table.lastSupplier, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get lastStockDate => $composableBuilder(
      column: $table.lastStockDate, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get lowStockThreshold => $composableBuilder(
      column: $table.lowStockThreshold,
      builder: (column) => ColumnFilters(column));

  $$CatalogItemsTableFilterComposer get sku {
    final $$CatalogItemsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.sku,
        referencedTable: $db.catalogItems,
        getReferencedColumn: (t) => t.sku,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$CatalogItemsTableFilterComposer(
              $db: $db,
              $table: $db.catalogItems,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$CatalogStockTableOrderingComposer
    extends Composer<_$CatalogDatabase, $CatalogStockTable> {
  $$CatalogStockTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get quantity => $composableBuilder(
      column: $table.quantity, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get lastPurchasePrice => $composableBuilder(
      column: $table.lastPurchasePrice,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get lastSupplier => $composableBuilder(
      column: $table.lastSupplier,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get lastStockDate => $composableBuilder(
      column: $table.lastStockDate,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get lowStockThreshold => $composableBuilder(
      column: $table.lowStockThreshold,
      builder: (column) => ColumnOrderings(column));

  $$CatalogItemsTableOrderingComposer get sku {
    final $$CatalogItemsTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.sku,
        referencedTable: $db.catalogItems,
        getReferencedColumn: (t) => t.sku,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$CatalogItemsTableOrderingComposer(
              $db: $db,
              $table: $db.catalogItems,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$CatalogStockTableAnnotationComposer
    extends Composer<_$CatalogDatabase, $CatalogStockTable> {
  $$CatalogStockTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get quantity =>
      $composableBuilder(column: $table.quantity, builder: (column) => column);

  GeneratedColumn<int> get lastPurchasePrice => $composableBuilder(
      column: $table.lastPurchasePrice, builder: (column) => column);

  GeneratedColumn<String> get lastSupplier => $composableBuilder(
      column: $table.lastSupplier, builder: (column) => column);

  GeneratedColumn<DateTime> get lastStockDate => $composableBuilder(
      column: $table.lastStockDate, builder: (column) => column);

  GeneratedColumn<int> get lowStockThreshold => $composableBuilder(
      column: $table.lowStockThreshold, builder: (column) => column);

  $$CatalogItemsTableAnnotationComposer get sku {
    final $$CatalogItemsTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.sku,
        referencedTable: $db.catalogItems,
        getReferencedColumn: (t) => t.sku,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$CatalogItemsTableAnnotationComposer(
              $db: $db,
              $table: $db.catalogItems,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$CatalogStockTableTableManager extends RootTableManager<
    _$CatalogDatabase,
    $CatalogStockTable,
    CatalogStockRow,
    $$CatalogStockTableFilterComposer,
    $$CatalogStockTableOrderingComposer,
    $$CatalogStockTableAnnotationComposer,
    $$CatalogStockTableCreateCompanionBuilder,
    $$CatalogStockTableUpdateCompanionBuilder,
    (CatalogStockRow, $$CatalogStockTableReferences),
    CatalogStockRow,
    PrefetchHooks Function({bool sku})> {
  $$CatalogStockTableTableManager(
      _$CatalogDatabase db, $CatalogStockTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CatalogStockTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CatalogStockTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CatalogStockTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> sku = const Value.absent(),
            Value<int> quantity = const Value.absent(),
            Value<int?> lastPurchasePrice = const Value.absent(),
            Value<String?> lastSupplier = const Value.absent(),
            Value<DateTime?> lastStockDate = const Value.absent(),
            Value<int> lowStockThreshold = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              CatalogStockCompanion(
            sku: sku,
            quantity: quantity,
            lastPurchasePrice: lastPurchasePrice,
            lastSupplier: lastSupplier,
            lastStockDate: lastStockDate,
            lowStockThreshold: lowStockThreshold,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String sku,
            Value<int> quantity = const Value.absent(),
            Value<int?> lastPurchasePrice = const Value.absent(),
            Value<String?> lastSupplier = const Value.absent(),
            Value<DateTime?> lastStockDate = const Value.absent(),
            Value<int> lowStockThreshold = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              CatalogStockCompanion.insert(
            sku: sku,
            quantity: quantity,
            lastPurchasePrice: lastPurchasePrice,
            lastSupplier: lastSupplier,
            lastStockDate: lastStockDate,
            lowStockThreshold: lowStockThreshold,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable(table),
                    $$CatalogStockTableReferences(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: ({sku = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins: <
                  T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic>>(state) {
                if (sku) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.sku,
                    referencedTable:
                        $$CatalogStockTableReferences._skuTable(db),
                    referencedColumn:
                        $$CatalogStockTableReferences._skuTable(db).sku,
                  ) as T;
                }

                return state;
              },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ));
}

typedef $$CatalogStockTableProcessedTableManager = ProcessedTableManager<
    _$CatalogDatabase,
    $CatalogStockTable,
    CatalogStockRow,
    $$CatalogStockTableFilterComposer,
    $$CatalogStockTableOrderingComposer,
    $$CatalogStockTableAnnotationComposer,
    $$CatalogStockTableCreateCompanionBuilder,
    $$CatalogStockTableUpdateCompanionBuilder,
    (CatalogStockRow, $$CatalogStockTableReferences),
    CatalogStockRow,
    PrefetchHooks Function({bool sku})>;
typedef $$StockCountsTableCreateCompanionBuilder = StockCountsCompanion
    Function({
  Value<int> id,
  required String sku,
  required int countedQty,
  required int systemQty,
  required int difference,
  Value<String?> note,
  Value<String?> countedBy,
  Value<DateTime> countedAt,
});
typedef $$StockCountsTableUpdateCompanionBuilder = StockCountsCompanion
    Function({
  Value<int> id,
  Value<String> sku,
  Value<int> countedQty,
  Value<int> systemQty,
  Value<int> difference,
  Value<String?> note,
  Value<String?> countedBy,
  Value<DateTime> countedAt,
});

final class $$StockCountsTableReferences extends BaseReferences<
    _$CatalogDatabase, $StockCountsTable, StockCountRow> {
  $$StockCountsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $CatalogItemsTable _skuTable(_$CatalogDatabase db) =>
      db.catalogItems.createAlias(
          $_aliasNameGenerator(db.stockCounts.sku, db.catalogItems.sku));

  $$CatalogItemsTableProcessedTableManager get sku {
    final $_column = $_itemColumn<String>('sku')!;

    final manager = $$CatalogItemsTableTableManager($_db, $_db.catalogItems)
        .filter((f) => f.sku.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_skuTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }
}

class $$StockCountsTableFilterComposer
    extends Composer<_$CatalogDatabase, $StockCountsTable> {
  $$StockCountsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get countedQty => $composableBuilder(
      column: $table.countedQty, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get systemQty => $composableBuilder(
      column: $table.systemQty, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get difference => $composableBuilder(
      column: $table.difference, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get note => $composableBuilder(
      column: $table.note, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get countedBy => $composableBuilder(
      column: $table.countedBy, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get countedAt => $composableBuilder(
      column: $table.countedAt, builder: (column) => ColumnFilters(column));

  $$CatalogItemsTableFilterComposer get sku {
    final $$CatalogItemsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.sku,
        referencedTable: $db.catalogItems,
        getReferencedColumn: (t) => t.sku,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$CatalogItemsTableFilterComposer(
              $db: $db,
              $table: $db.catalogItems,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$StockCountsTableOrderingComposer
    extends Composer<_$CatalogDatabase, $StockCountsTable> {
  $$StockCountsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get countedQty => $composableBuilder(
      column: $table.countedQty, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get systemQty => $composableBuilder(
      column: $table.systemQty, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get difference => $composableBuilder(
      column: $table.difference, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get note => $composableBuilder(
      column: $table.note, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get countedBy => $composableBuilder(
      column: $table.countedBy, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get countedAt => $composableBuilder(
      column: $table.countedAt, builder: (column) => ColumnOrderings(column));

  $$CatalogItemsTableOrderingComposer get sku {
    final $$CatalogItemsTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.sku,
        referencedTable: $db.catalogItems,
        getReferencedColumn: (t) => t.sku,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$CatalogItemsTableOrderingComposer(
              $db: $db,
              $table: $db.catalogItems,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$StockCountsTableAnnotationComposer
    extends Composer<_$CatalogDatabase, $StockCountsTable> {
  $$StockCountsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get countedQty => $composableBuilder(
      column: $table.countedQty, builder: (column) => column);

  GeneratedColumn<int> get systemQty =>
      $composableBuilder(column: $table.systemQty, builder: (column) => column);

  GeneratedColumn<int> get difference => $composableBuilder(
      column: $table.difference, builder: (column) => column);

  GeneratedColumn<String> get note =>
      $composableBuilder(column: $table.note, builder: (column) => column);

  GeneratedColumn<String> get countedBy =>
      $composableBuilder(column: $table.countedBy, builder: (column) => column);

  GeneratedColumn<DateTime> get countedAt =>
      $composableBuilder(column: $table.countedAt, builder: (column) => column);

  $$CatalogItemsTableAnnotationComposer get sku {
    final $$CatalogItemsTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.sku,
        referencedTable: $db.catalogItems,
        getReferencedColumn: (t) => t.sku,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$CatalogItemsTableAnnotationComposer(
              $db: $db,
              $table: $db.catalogItems,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$StockCountsTableTableManager extends RootTableManager<
    _$CatalogDatabase,
    $StockCountsTable,
    StockCountRow,
    $$StockCountsTableFilterComposer,
    $$StockCountsTableOrderingComposer,
    $$StockCountsTableAnnotationComposer,
    $$StockCountsTableCreateCompanionBuilder,
    $$StockCountsTableUpdateCompanionBuilder,
    (StockCountRow, $$StockCountsTableReferences),
    StockCountRow,
    PrefetchHooks Function({bool sku})> {
  $$StockCountsTableTableManager(_$CatalogDatabase db, $StockCountsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$StockCountsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$StockCountsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$StockCountsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<String> sku = const Value.absent(),
            Value<int> countedQty = const Value.absent(),
            Value<int> systemQty = const Value.absent(),
            Value<int> difference = const Value.absent(),
            Value<String?> note = const Value.absent(),
            Value<String?> countedBy = const Value.absent(),
            Value<DateTime> countedAt = const Value.absent(),
          }) =>
              StockCountsCompanion(
            id: id,
            sku: sku,
            countedQty: countedQty,
            systemQty: systemQty,
            difference: difference,
            note: note,
            countedBy: countedBy,
            countedAt: countedAt,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required String sku,
            required int countedQty,
            required int systemQty,
            required int difference,
            Value<String?> note = const Value.absent(),
            Value<String?> countedBy = const Value.absent(),
            Value<DateTime> countedAt = const Value.absent(),
          }) =>
              StockCountsCompanion.insert(
            id: id,
            sku: sku,
            countedQty: countedQty,
            systemQty: systemQty,
            difference: difference,
            note: note,
            countedBy: countedBy,
            countedAt: countedAt,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable(table),
                    $$StockCountsTableReferences(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: ({sku = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins: <
                  T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic>>(state) {
                if (sku) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.sku,
                    referencedTable: $$StockCountsTableReferences._skuTable(db),
                    referencedColumn:
                        $$StockCountsTableReferences._skuTable(db).sku,
                  ) as T;
                }

                return state;
              },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ));
}

typedef $$StockCountsTableProcessedTableManager = ProcessedTableManager<
    _$CatalogDatabase,
    $StockCountsTable,
    StockCountRow,
    $$StockCountsTableFilterComposer,
    $$StockCountsTableOrderingComposer,
    $$StockCountsTableAnnotationComposer,
    $$StockCountsTableCreateCompanionBuilder,
    $$StockCountsTableUpdateCompanionBuilder,
    (StockCountRow, $$StockCountsTableReferences),
    StockCountRow,
    PrefetchHooks Function({bool sku})>;

class $CatalogDatabaseManager {
  final _$CatalogDatabase _db;
  $CatalogDatabaseManager(this._db);
  $$CatalogVersionsTableTableManager get catalogVersions =>
      $$CatalogVersionsTableTableManager(_db, _db.catalogVersions);
  $$CatalogCategoriesTableTableManager get catalogCategories =>
      $$CatalogCategoriesTableTableManager(_db, _db.catalogCategories);
  $$CatalogItemsTableTableManager get catalogItems =>
      $$CatalogItemsTableTableManager(_db, _db.catalogItems);
  $$CatalogItemModelsTableTableManager get catalogItemModels =>
      $$CatalogItemModelsTableTableManager(_db, _db.catalogItemModels);
  $$BarcodeLinksTableTableManager get barcodeLinks =>
      $$BarcodeLinksTableTableManager(_db, _db.barcodeLinks);
  $$CatalogStockTableTableManager get catalogStock =>
      $$CatalogStockTableTableManager(_db, _db.catalogStock);
  $$StockCountsTableTableManager get stockCounts =>
      $$StockCountsTableTableManager(_db, _db.stockCounts);
}
