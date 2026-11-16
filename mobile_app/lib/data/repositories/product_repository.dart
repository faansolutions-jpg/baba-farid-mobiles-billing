/// Product / variant / IMEI / category / brand repository.
///
/// Screens use this interface, never drift directly. All money is
/// integer whole PKR. Every mutating method writes an `audit_logs` row
/// and queues an `outbox` row for sync.
library;


import 'package:drift/drift.dart';

import '../../domain/models/brand.dart';
import '../../domain/models/category.dart';
import '../../domain/models/imei_item.dart';
import '../../domain/models/product.dart';
import '../../domain/models/product_variant.dart';
import '../database/app_database.dart' as db;

/// Thrown when a repository operation cannot proceed (duplicate IMEI /
/// barcode, missing record, invalid stock change, ...).
class RepositoryException implements Exception {
  final String message;
  const RepositoryException(this.message);
  @override
  String toString() => 'RepositoryException: $message';
}

abstract class ProductRepository {
  // -- Products ------------------------------------------------------------
  Future<Product?> getProduct(String id);
  Future<List<Product>> listProducts({
    String? search,
    String? categoryId,
    String? brandId,
    String? type,
    bool onlyActive = true,
    int limit = 100,
    int offset = 0,
  });
  Future<List<Product>> searchProducts(String query, {int limit = 50});
  Future<Product> createProduct(Product product, {String? userId});
  Future<Product> updateProduct(Product product, {String? userId});
  Future<void> deleteProduct(String id, {String? userId});
  Future<Product?> getProductByBarcode(String barcode);

  // -- Variants ------------------------------------------------------------
  Future<ProductVariant?> getVariant(String id);
  Future<List<ProductVariant>> listVariants(String productId);
  Future<List<ProductVariant>> lowStockVariants();
  Future<ProductVariant> createVariant(ProductVariant variant,
      {String? userId});
  Future<ProductVariant> updateVariant(ProductVariant variant,
      {String? userId});
  Future<ProductVariant> adjustVariantQuantity(
    String variantId,
    int delta, {
    String? userId,
    String? reason,
  });

  // -- IMEI items ----------------------------------------------------------
  Future<ImeiItem?> getImeiItem(String id);
  Future<ImeiItem?> getImeiByNumber(String imei1);
  Future<List<ImeiItem>> listImeiItems({
    String? productId,
    String? variantId,
    String? status,
    int limit = 200,
    int offset = 0,
  });
  Future<ImeiItem> createImeiItem(ImeiItem item, {String? userId});
  Future<ImeiItem> updateImeiStatus(
    String id,
    String status, {
    String? userId,
    String? soldSaleId,
  });

  // -- Categories & brands ---------------------------------------------------
  Future<List<Category>> listCategories({String? type});
  Future<Category> createCategory(Category category, {String? userId});
  Future<List<Brand>> listBrands();
  Future<Brand> createBrand(Brand brand, {String? userId});
}

class DriftProductRepository implements ProductRepository {
  final db.AppDatabase database;

  DriftProductRepository(this.database);

  // -- Row mapping -----------------------------------------------------------

  Product _product(db.Product row) => Product(
        id: row.id,
        brandId: row.brandId,
        categoryId: row.categoryId,
        type: row.type,
        name: row.name,
        description: row.description,
        barcode: row.barcode,
        imageUrl: row.imageUrl,
        isActive: row.isActive,
        createdAt: row.createdAt,
        updatedAt: row.updatedAt,
      );

  ProductVariant _variant(db.ProductVariant row) => ProductVariant(
        id: row.id,
        productId: row.productId,
        name: row.name,
        color: row.color,
        storageGb: row.storageGb,
        ramGb: row.ramGb,
        condition: row.condition,
        ptaStatus: row.ptaStatus,
        barcode: row.barcode,
        purchasePrice: row.purchasePrice,
        salePrice: row.salePrice,
        minPrice: row.minPrice,
        warrantyMonths: row.warrantyMonths,
        quantity: row.quantity,
        lowStockThreshold: row.lowStockThreshold,
        isActive: row.isActive,
        createdAt: row.createdAt,
        updatedAt: row.updatedAt,
      );

  ImeiItem _imei(db.ImeiItem row) => ImeiItem(
        id: row.id,
        productId: row.productId,
        variantId: row.variantId,
        imei1: row.imei1,
        imei2: row.imei2,
        status: row.status,
        purchaseId: row.purchaseId,
        purchasePrice: row.purchasePrice,
        salePrice: row.salePrice,
        soldSaleId: row.soldSaleId,
        warrantyStart: row.warrantyStart,
        warrantyEnd: row.warrantyEnd,
        createdAt: row.createdAt,
        updatedAt: row.updatedAt,
      );

  Category _category(db.Category row) => Category(
        id: row.id,
        name: row.name,
        type: row.type,
        parentId: row.parentId,
        isActive: row.isActive,
        createdAt: row.createdAt,
      );

  Brand _brand(db.Brand row) => Brand(
        id: row.id,
        name: row.name,
        isActive: row.isActive,
        createdAt: row.createdAt,
      );

  Future<void> _auditAndOutbox({
    String? userId,
    required String action,
    required String entityType,
    required String entityId,
    required Map<String, dynamic> payload,
  }) async {
    await database.writeAudit(
      userId: userId,
      action: action,
      entityType: entityType,
      entityId: entityId,
      newValues: payload,
    );
    const tableNames = {
      'product': 'products',
      'product_variant': 'product_variants',
      'imei_item': 'imei_items',
      'category': 'categories',
      'brand': 'brands',
    };
    await database.enqueueOutbox(
      tableName: tableNames[entityType] ?? '${entityType}s',
      operation: action == 'delete' ? 'delete' : 'insert',
      payload: payload,
    );
  }

  // -- Products ------------------------------------------------------------

  @override
  Future<Product?> getProduct(String id) async {
    final row = await (database.select(database.products)
          ..where((t) => t.id.equals(id)))
        .getSingleOrNull();
    return row == null ? null : _product(row);
  }

  @override
  Future<List<Product>> listProducts({
    String? search,
    String? categoryId,
    String? brandId,
    String? type,
    bool onlyActive = true,
    int limit = 100,
    int offset = 0,
  }) async {
    final query = database.select(database.products);
    if (onlyActive) query.where((t) => t.isActive.equals(true));
    if (categoryId != null) {
      query.where((t) => t.categoryId.equals(categoryId));
    }
    if (brandId != null) query.where((t) => t.brandId.equals(brandId));
    if (type != null) query.where((t) => t.type.equals(type));
    if (search != null && search.trim().isNotEmpty) {
      final q = '%${search.trim()}%';
      // barcode is nullable: LIKE on it is not type-safe, use equals.
      query.where((t) => t.name.like(q) | t.barcode.equals(search.trim()));
    }
    query.orderBy([(t) => OrderingTerm.asc(t.name)]);
    query.limit(limit, offset: offset);
    return (await query.get()).map(_product).toList();
  }

  @override
  Future<List<Product>> searchProducts(String query, {int limit = 50}) async {
    final q = query.trim();
    if (q.isEmpty) return <Product>[];
    final rows = await database
        .customSelect(
          'SELECT * FROM products WHERE is_active = 1 AND '
          '(name LIKE ? OR barcode = ?) ORDER BY name LIMIT ?',
          variables: [
            Variable.withString('%$q%'),
            Variable.withString(q),
            Variable.withInt(limit),
          ],
        )
        .get();
    return rows.map((r) => Product.fromJson(r.data)).toList();
  }

  @override
  Future<Product> createProduct(Product product, {String? userId}) async {
    final now = DateTime.now();
    final created = product.copyWith(
      id: product.id.isEmpty ? db.newUuid() : product.id,
      createdAt: now,
      updatedAt: now,
    );
    await database.transaction(() async {
      await database.into(database.products).insert(
            db.ProductsCompanion.insert(
              id: created.id,
              brandId: Value(created.brandId),
              categoryId: Value(created.categoryId),
              type: created.type,
              name: created.name,
              description: Value(created.description),
              barcode: Value(created.barcode),
              imageUrl: Value(created.imageUrl),
              isActive: Value(created.isActive),
              createdAt: Value(now),
              updatedAt: Value(now),
            ),
          );
      await _auditAndOutbox(
        userId: userId,
        action: 'create',
        entityType: 'product',
        entityId: created.id,
        payload: created.toJson(),
      );
    });
    return created;
  }

  @override
  Future<Product> updateProduct(Product product, {String? userId}) async {
    final existing = await getProduct(product.id);
    if (existing == null) {
      throw RepositoryException('Product ${product.id} not found');
    }
    final updated = product.copyWith(updatedAt: DateTime.now());
    await database.transaction(() async {
      await (database.update(database.products)
            ..where((t) => t.id.equals(product.id)))
          .write(db.ProductsCompanion(
            brandId: Value(updated.brandId),
            categoryId: Value(updated.categoryId),
            type: Value(updated.type),
            name: Value(updated.name),
            description: Value(updated.description),
            barcode: Value(updated.barcode),
            imageUrl: Value(updated.imageUrl),
            isActive: Value(updated.isActive),
            updatedAt: Value(updated.updatedAt),
          ));
      await database.writeAudit(
        userId: userId,
        action: 'update',
        entityType: 'product',
        entityId: updated.id,
        oldValues: existing.toJson(),
        newValues: updated.toJson(),
      );
      await database.enqueueOutbox(
        tableName: 'products',
        operation: 'update',
        payload: updated.toJson(),
      );
    });
    return updated;
  }

  @override
  Future<void> deleteProduct(String id, {String? userId}) async {
    // Soft delete: the product stays for historical bills.
    final existing = await getProduct(id);
    if (existing == null) {
      throw RepositoryException('Product $id not found');
    }
    await database.transaction(() async {
      await (database.update(database.products)
            ..where((t) => t.id.equals(id)))
          .write(db.ProductsCompanion(
            isActive: const Value(false),
            updatedAt: Value(DateTime.now()),
          ));
      await _auditAndOutbox(
        userId: userId,
        action: 'delete',
        entityType: 'product',
        entityId: id,
        payload: {'id': id, 'is_active': false},
      );
    });
  }

  @override
  Future<Product?> getProductByBarcode(String barcode) async {
    final row = await (database.select(database.products)
          ..where((t) => t.barcode.equals(barcode)))
        .getSingleOrNull();
    if (row != null) return _product(row);
    // Fall back to a variant-level barcode.
    final variant = await (database.select(database.productVariants)
          ..where((t) => t.barcode.equals(barcode)))
        .getSingleOrNull();
    if (variant == null) return null;
    return getProduct(variant.productId);
  }

  // -- Variants ------------------------------------------------------------

  @override
  Future<ProductVariant?> getVariant(String id) async {
    final row = await (database.select(database.productVariants)
          ..where((t) => t.id.equals(id)))
        .getSingleOrNull();
    return row == null ? null : _variant(row);
  }

  @override
  Future<List<ProductVariant>> listVariants(String productId) async {
    final rows = await (database.select(database.productVariants)
          ..where((t) => t.productId.equals(productId))
          ..orderBy([(t) => OrderingTerm.asc(t.name)]))
        .get();
    return rows.map(_variant).toList();
  }

  @override
  Future<List<ProductVariant>> lowStockVariants() async {
    final rows = await database
        .customSelect(
          'SELECT * FROM product_variants WHERE is_active = 1 AND '
          'quantity <= low_stock_threshold ORDER BY quantity ASC',
        )
        .get();
    return rows.map((r) => ProductVariant.fromJson(r.data)).toList();
  }

  @override
  Future<ProductVariant> createVariant(ProductVariant variant,
      {String? userId}) async {
    final now = DateTime.now();
    final created = variant.copyWith(
      id: variant.id.isEmpty ? db.newUuid() : variant.id,
      createdAt: now,
      updatedAt: now,
    );
    await database.transaction(() async {
      await database.into(database.productVariants).insert(
            db.ProductVariantsCompanion.insert(
              id: created.id,
              productId: created.productId,
              name: created.name,
              color: Value(created.color),
              storageGb: Value(created.storageGb),
              ramGb: Value(created.ramGb),
              condition: Value(created.condition),
              ptaStatus: Value(created.ptaStatus),
              barcode: Value(created.barcode),
              purchasePrice: Value(created.purchasePrice),
              salePrice: Value(created.salePrice),
              minPrice: Value(created.minPrice),
              warrantyMonths: Value(created.warrantyMonths),
              quantity: Value(created.quantity),
              lowStockThreshold: Value(created.lowStockThreshold),
              isActive: Value(created.isActive),
              createdAt: Value(now),
              updatedAt: Value(now),
            ),
          );
      await _auditAndOutbox(
        userId: userId,
        action: 'create',
        entityType: 'product_variant',
        entityId: created.id,
        payload: created.toJson(),
      );
    });
    return created;
  }

  @override
  Future<ProductVariant> updateVariant(ProductVariant variant,
      {String? userId}) async {
    final existing = await getVariant(variant.id);
    if (existing == null) {
      throw RepositoryException('Variant ${variant.id} not found');
    }
    final updated = variant.copyWith(updatedAt: DateTime.now());
    await database.transaction(() async {
      await (database.update(database.productVariants)
            ..where((t) => t.id.equals(variant.id)))
          .write(db.ProductVariantsCompanion(
            name: Value(updated.name),
            color: Value(updated.color),
            storageGb: Value(updated.storageGb),
            ramGb: Value(updated.ramGb),
            condition: Value(updated.condition),
            ptaStatus: Value(updated.ptaStatus),
            barcode: Value(updated.barcode),
            purchasePrice: Value(updated.purchasePrice),
            salePrice: Value(updated.salePrice),
            minPrice: Value(updated.minPrice),
            warrantyMonths: Value(updated.warrantyMonths),
            quantity: Value(updated.quantity),
            lowStockThreshold: Value(updated.lowStockThreshold),
            isActive: Value(updated.isActive),
            updatedAt: Value(updated.updatedAt),
          ));
      await database.writeAudit(
        userId: userId,
        action: 'update',
        entityType: 'product_variant',
        entityId: updated.id,
        oldValues: existing.toJson(),
        newValues: updated.toJson(),
      );
      await database.enqueueOutbox(
        tableName: 'product_variants',
        operation: 'update',
        payload: updated.toJson(),
      );
    });
    return updated;
  }

  @override
  Future<ProductVariant> adjustVariantQuantity(
    String variantId,
    int delta, {
    String? userId,
    String? reason,
  }) async {
    return database.transaction(() async {
      final row = await (database.select(database.productVariants)
            ..where((t) => t.id.equals(variantId)))
          .getSingleOrNull();
      if (row == null) {
        throw RepositoryException('Variant $variantId not found');
      }
      final next = row.quantity + delta;
      if (next < 0) {
        throw RepositoryException(
            'Not enough stock for variant $variantId '
            '(have ${row.quantity}, need ${-delta})');
      }
      await (database.update(database.productVariants)
            ..where((t) => t.id.equals(variantId)))
          .write(db.ProductVariantsCompanion(
            quantity: Value(next),
            updatedAt: Value(DateTime.now()),
          ));
      final updated = _variant(row).copyWith(quantity: next);
      await database.writeAudit(
        userId: userId,
        action: 'stock_adjust',
        entityType: 'product_variant',
        entityId: variantId,
        oldValues: {'quantity': row.quantity},
        newValues: {'quantity': next, 'reason': reason},
      );
      await database.enqueueOutbox(
        tableName: 'product_variants',
        operation: 'update',
        payload: updated.toJson(),
      );
      return updated;
    });
  }

  // -- IMEI items ----------------------------------------------------------

  @override
  Future<ImeiItem?> getImeiItem(String id) async {
    final row = await (database.select(database.imeiItems)
          ..where((t) => t.id.equals(id)))
        .getSingleOrNull();
    return row == null ? null : _imei(row);
  }

  @override
  Future<ImeiItem?> getImeiByNumber(String imei1) async {
    final row = await (database.select(database.imeiItems)
          ..where((t) => t.imei1.equals(imei1)))
        .getSingleOrNull();
    return row == null ? null : _imei(row);
  }

  @override
  Future<List<ImeiItem>> listImeiItems({
    String? productId,
    String? variantId,
    String? status,
    int limit = 200,
    int offset = 0,
  }) async {
    final query = database.select(database.imeiItems);
    if (productId != null) {
      query.where((t) => t.productId.equals(productId));
    }
    if (variantId != null) {
      query.where((t) => t.variantId.equals(variantId));
    }
    if (status != null) query.where((t) => t.status.equals(status));
    query.orderBy([(t) => OrderingTerm.desc(t.createdAt)]);
    query.limit(limit, offset: offset);
    return (await query.get()).map(_imei).toList();
  }

  @override
  Future<ImeiItem> createImeiItem(ImeiItem item, {String? userId}) async {
    final existing = await getImeiByNumber(item.imei1);
    if (existing != null) {
      throw RepositoryException('IMEI ${item.imei1} already exists');
    }
    final now = DateTime.now();
    final created = item.copyWith(
      id: item.id.isEmpty ? db.newUuid() : item.id,
      createdAt: now,
      updatedAt: now,
    );
    await database.transaction(() async {
      await database.into(database.imeiItems).insert(
            db.ImeiItemsCompanion.insert(
              id: created.id,
              productId: created.productId,
              variantId: Value(created.variantId),
              imei1: created.imei1,
              imei2: Value(created.imei2),
              status: Value(created.status),
              purchaseId: Value(created.purchaseId),
              purchasePrice: Value(created.purchasePrice),
              salePrice: Value(created.salePrice),
              soldSaleId: Value(created.soldSaleId),
              warrantyStart: Value(created.warrantyStart),
              warrantyEnd: Value(created.warrantyEnd),
              createdAt: Value(now),
              updatedAt: Value(now),
            ),
          );
      await _auditAndOutbox(
        userId: userId,
        action: 'create',
        entityType: 'imei_item',
        entityId: created.id,
        payload: created.toJson(),
      );
    });
    return created;
  }

  @override
  Future<ImeiItem> updateImeiStatus(
    String id,
    String status, {
    String? userId,
    String? soldSaleId,
  }) async {
    final existing = await getImeiItem(id);
    if (existing == null) {
      throw RepositoryException('IMEI item $id not found');
    }
    final updated = existing.copyWith(
      status: status,
      soldSaleId: soldSaleId ?? existing.soldSaleId,
      updatedAt: DateTime.now(),
    );
    await database.transaction(() async {
      await (database.update(database.imeiItems)
            ..where((t) => t.id.equals(id)))
          .write(db.ImeiItemsCompanion(
            status: Value(status),
            soldSaleId: Value(updated.soldSaleId),
            updatedAt: Value(updated.updatedAt),
          ));
      await database.writeAudit(
        userId: userId,
        action: 'imei_status',
        entityType: 'imei_item',
        entityId: id,
        oldValues: {'status': existing.status},
        newValues: {'status': status, 'sold_sale_id': updated.soldSaleId},
      );
      await database.enqueueOutbox(
        tableName: 'imei_items',
        operation: 'update',
        payload: updated.toJson(),
      );
    });
    return updated;
  }

  // -- Categories & brands ---------------------------------------------------

  @override
  Future<List<Category>> listCategories({String? type}) async {
    final query = database.select(database.categories);
    query.where((t) => t.isActive.equals(true));
    if (type != null) query.where((t) => t.type.equals(type));
    query.orderBy([(t) => OrderingTerm.asc(t.name)]);
    return (await query.get()).map(_category).toList();
  }

  @override
  Future<Category> createCategory(Category category,
      {String? userId}) async {
    final created = category.copyWith(
      id: category.id.isEmpty ? db.newUuid() : category.id,
      createdAt: DateTime.now(),
    );
    await database.transaction(() async {
      await database.into(database.categories).insert(
            db.CategoriesCompanion.insert(
              id: created.id,
              name: created.name,
              type: created.type,
              parentId: Value(created.parentId),
              isActive: Value(created.isActive),
              createdAt: Value(created.createdAt),
            ),
          );
      await _auditAndOutbox(
        userId: userId,
        action: 'create',
        entityType: 'category',
        entityId: created.id,
        payload: created.toJson(),
      );
    });
    return created;
  }

  @override
  Future<List<Brand>> listBrands() async {
    final rows = await (database.select(database.brands)
          ..where((t) => t.isActive.equals(true))
          ..orderBy([(t) => OrderingTerm.asc(t.name)]))
        .get();
    return rows.map(_brand).toList();
  }

  @override
  Future<Brand> createBrand(Brand brand, {String? userId}) async {
    final created = brand.copyWith(
      id: brand.id.isEmpty ? db.newUuid() : brand.id,
      createdAt: DateTime.now(),
    );
    await database.transaction(() async {
      await database.into(database.brands).insert(
            db.BrandsCompanion.insert(
              id: created.id,
              name: created.name,
              isActive: Value(created.isActive),
              createdAt: Value(created.createdAt),
            ),
          );
      await _auditAndOutbox(
        userId: userId,
        action: 'create',
        entityType: 'brand',
        entityId: created.id,
        payload: created.toJson(),
      );
    });
    return created;
  }
}
