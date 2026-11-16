/// Single shared Riverpod providers file for the whole app.
///
/// Consolidates the provider definitions that used to live in three
/// files with the same names, each opening its own [AppDatabase]
/// instance on one file:
/// * `features/dashboard/repository_providers.dart`
/// * `features/pos/pos_providers.dart`
/// * `features/repairs/repair_common.dart` (providers only — its
///   helpers/routes/WhatsApp code stay in that file)
///
/// Every provider name is unchanged, so screens keep reading the same
/// names. There is exactly ONE [AppDatabase] and ONE [CatalogDatabase]
/// per ProviderScope; the composition root (main.dart) may override
/// [appDatabaseProvider] with a shared instance.
///
/// [authServiceProvider] is intentionally NOT defined here — it lives
/// in `features/auth/auth_state.dart` and is overridden in main.dart.
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/api/api_client.dart';
import '../../data/database/app_database.dart';
import '../../data/database/catalog_database.dart';
import '../../data/repositories/customer_repository.dart';
import '../../data/repositories/expense_repository.dart';
import '../../data/repositories/product_repository.dart';
import '../../data/repositories/purchase_repository.dart';
import '../../data/repositories/repair_repository.dart';
import '../../data/repositories/report_repository.dart';
import '../../data/repositories/sale_repository.dart';
import '../../data/repositories/settings_repository.dart';
import '../../data/repositories/supplier_repository.dart';
import '../../data/sync/sync_engine.dart';
import '../../features/catalog/catalog_repository.dart';

/// Single shared local database for the whole app.
final appDatabaseProvider = Provider<AppDatabase>((ref) {
  final db = AppDatabase();
  ref.onDispose(db.close);
  return db;
});

/// The separate catalog database (catalog.db).
final catalogDatabaseProvider = Provider<CatalogDatabase>((ref) {
  final db = CatalogDatabase();
  ref.onDispose(() async {
    await db.close();
  });
  return db;
});

/// Single shared API client for the whole app (used by the sync engine).
final apiClientProvider = Provider<ApiClient>((ref) => ApiClient());

final reportRepositoryProvider = Provider<ReportRepository>(
  (ref) => DriftReportRepository(ref.watch(appDatabaseProvider)),
);

final saleRepositoryProvider = Provider<SaleRepository>(
  (ref) => DriftSaleRepository(ref.watch(appDatabaseProvider)),
);

final productRepositoryProvider = Provider<ProductRepository>(
  (ref) => DriftProductRepository(ref.watch(appDatabaseProvider)),
);

final customerRepositoryProvider = Provider<CustomerRepository>(
  (ref) => DriftCustomerRepository(ref.watch(appDatabaseProvider)),
);

final settingsRepositoryProvider = Provider<SettingsRepository>(
  (ref) => DriftSettingsRepository(ref.watch(appDatabaseProvider)),
);

final expenseRepositoryProvider = Provider<ExpenseRepository>(
  (ref) => DriftExpenseRepository(ref.watch(appDatabaseProvider)),
);

final repairRepositoryProvider = Provider<RepairRepository>(
  (ref) => DriftRepairRepository(ref.watch(appDatabaseProvider)),
);

final purchaseRepositoryProvider = Provider<PurchaseRepository>(
  (ref) => DriftPurchaseRepository(ref.watch(appDatabaseProvider)),
);

final supplierRepositoryProvider = Provider<SupplierRepository>(
  (ref) => DriftSupplierRepository(ref.watch(appDatabaseProvider)),
);

final catalogRepositoryProvider = Provider<CatalogRepository>(
  (ref) => CatalogRepositoryImpl(ref.watch(catalogDatabaseProvider)),
);

/// Sync engine used only for the pending-outbox count shown on the
/// dashboard hero. It never pushes here; push/pull stays in Module 7.
final syncEngineProvider = Provider<SyncEngine>(
  (ref) => SyncEngine(
    database: ref.watch(appDatabaseProvider),
    apiClient: ref.watch(apiClientProvider),
    deviceId: 'app',
  ),
);

/// Privacy mode (hide money amounts). Loaded from Settings on the
/// dashboard / settings screens and toggled from Settings.
final privacyModeProvider = StateProvider<bool>((ref) => false);

/// Daily sales target in whole PKR (SharedPreferences key
/// `daily_sales_target`, default 200000). Editable in Settings.
const String dailySalesTargetKey = 'daily_sales_target';
const int defaultDailySalesTarget = 200000;
