library;

/// App router (go_router).
///
/// Every route the app uses, in one place. Screens that exist are wired
/// to their real widgets; the only remaining placeholder is
/// `/pos/returns` (no returns screen exists yet — see [ComingSoonScreen]).
///
/// Auth redirects (the router cannot read Riverpod providers directly,
/// and `authServiceProvider` is not wired in `main.dart` yet, so the
/// auth state is mirrored into [routerAuthState] by `App` in
/// `lib/app.dart` — see [updateRouterAuth]):
/// * `/` shows the boot splash; the splash navigates itself with
///   `context.go` once its animation finishes and the session restore
///   is done, so the redirect leaves `/` alone;
/// * while auth is still restoring (`isLoading`), no redirect;
/// * signed out + protected route -> `/login` (warranty lookup stays
///   public: a customer scans the invoice QR without logging in);
/// * signed in + `/login` -> `/dashboard`.
///   (`/login` also passes `onLoginSuccess` into [LoginScreen], the
///   seam that screen documents for the router — `Navigator.pushNamed`
///   does not work under go_router, which has no `onGenerateRoute`.)
///
/// Unknown routes show [_UnknownRouteScreen], which immediately
/// redirects to `/dashboard`.
///
/// Provider note: all repository providers live in one shared file,
/// `core/providers/app_providers.dart`, so every screen reads the same
/// single [AppDatabase] / [CatalogDatabase] instance.
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/l10n/app_strings.dart';
import '../../core/theme/app_theme.dart';
import '../../core/theme/cyber_text_styles.dart';
import '../../core/theme/cyber_widgets.dart';
import '../../features/auth/login_screen.dart';
import '../../features/auth/splash_screen.dart';
import '../../features/cash/cash_register_screen.dart';
import '../../features/cash/day_end_screen.dart';
import '../../features/catalog/screens/add_custom_item_screen.dart';
import '../../features/catalog/screens/bulk_stock_in_screen.dart';
import '../../features/catalog/screens/catalog_browser_screen.dart';
import '../../features/catalog/screens/opening_stock_screen.dart';
import '../../features/catalog/screens/quick_stock_in_screen.dart';
import '../../features/catalog/screens/reorder_list_screen.dart';
import '../../features/catalog/screens/stock_count_screen.dart';
import '../../features/customers/customer_detail_screen.dart';
import '../../features/customers/customer_form_screen.dart';
import '../../features/customers/customer_list_screen.dart';
import '../../features/customers/installment_plan_screen.dart';
import '../../features/customers/overdue_list_screen.dart';
import '../../features/dashboard/dashboard_screen.dart';
import '../providers/app_providers.dart';
import '../../features/expenses/expense_list_screen.dart';
import '../../features/expenses/staff_list_screen.dart';
import '../../features/inventory/imei_search_screen.dart';
import '../../features/inventory/inventory_list_screen.dart';
import '../../features/inventory/product_detail_screen.dart';
import '../../features/inventory/product_form_screen.dart';
import '../../features/inventory/stock_adjust_screen.dart';
import '../../features/invoice/invoice_screen.dart';
import '../../features/pos/pos_screen.dart';
import '../../features/pos/return_screen.dart';
import '../../features/purchases/purchase_detail_screen.dart';
import '../../features/purchases/purchase_entry_screen.dart';
import '../../features/purchases/purchase_helpers.dart';
import '../../features/purchases/purchase_list_screen.dart';
import '../../features/purchases/purchase_return_screen.dart';
import '../../features/purchases/supplier_detail_screen.dart';
import '../../features/purchases/supplier_list_screen.dart';
import '../../features/qr/qr_warranty_screen.dart';
import '../../features/qr/warranty_lookup_screen.dart';
import '../../features/repairs/repair_detail_screen.dart';
import '../../features/repairs/repair_form_screen.dart';
import '../../features/repairs/repair_list_screen.dart';
import '../../features/repairs/service_sale_screen.dart';
import '../../features/reports/imei_history_screen.dart';
import '../../features/reports/report_detail_screen.dart';
import '../../features/reports/reports_screen.dart';
import '../../features/settings/backup_screen.dart';
import '../../features/settings/settings_screen.dart';
import '../../features/command_palette/command_palette.dart';
import '../../features/ai/ai_assistant_screen.dart';

// ---------------------------------------------------------------------------
// Auth snapshot (mirrored in by App; see lib/app.dart)
// ---------------------------------------------------------------------------

/// Mutable auth snapshot read by the router redirect. Updated by
/// [App] via `ref.listen` on `authStateProvider` (and by its `onError`
/// path when `AuthService` is not wired yet — then the user counts as
/// signed out).
class RouterAuthState {
  bool isAuthenticated = false;

  /// True while the saved session is still being restored.
  bool isLoading = true;
}

final routerAuthState = RouterAuthState();

/// Notifies the router to re-evaluate its redirect. [App] calls
/// [updateRouterAuth]; nothing else should touch this.
class RouterAuthRefresh extends ChangeNotifier {
  void refresh() => notifyListeners();
}

final routerAuthRefresh = RouterAuthRefresh();

/// Updates [routerAuthState] and notifies the router when anything
/// changed. Safe to call from a `ref.listen` callback.
void updateRouterAuth({
  required bool isAuthenticated,
  required bool isLoading,
}) {
  final changed = routerAuthState.isAuthenticated != isAuthenticated ||
      routerAuthState.isLoading != isLoading;
  routerAuthState.isAuthenticated = isAuthenticated;
  routerAuthState.isLoading = isLoading;
  if (changed) routerAuthRefresh.refresh();
}

// ---------------------------------------------------------------------------
// Router
// ---------------------------------------------------------------------------

String? _redirect(BuildContext context, GoRouterState state) {
  final auth = routerAuthState;
  final path = state.uri.path;
  if (path == '/') {
    // Boot splash: it navigates itself (context.go) once its animation
    // finishes and the session restore is done, so the redirect never
    // moves the user away from `/`.
    return null;
  }
  if (auth.isLoading) return null; // Session restore still running.
  final isPublic = path == '/login' || path.startsWith('/warranty');
  if (!auth.isAuthenticated) {
    if (isPublic) return null;
    return '/login';
  }
  if (path == '/login') return '/dashboard';
  return null;
}

/// The app-wide router. Created once; [App] passes it to
/// `MaterialApp.router` as `routerConfig`.
final GoRouter appRouter = GoRouter(
  initialLocation: '/',
  refreshListenable: routerAuthRefresh,
  redirect: _redirect,
  errorBuilder: (context, state) => const _UnknownRouteScreen(),
  routes: <RouteBase>[
    GoRoute(
      path: '/',
      builder: (context, state) => const SplashScreen(),
    ),
    GoRoute(
      path: '/login',
      builder: (context, state) => LoginScreen(
        onLoginSuccess: () => context.go('/dashboard'),
      ),
    ),
    GoRoute(
      path: '/dashboard',
      builder: (context, state) => const DashboardScreen(),
    ),
    // --- POS ---------------------------------------------------------------
    GoRoute(
      path: '/pos',
      builder: (context, state) => const PosScreen(),
    ),
    GoRoute(
      path: '/pos/returns',
      builder: (context, state) => const ReturnScreen(),
    ),
    // --- Inventory (static segments before :id) ----------------------------
    GoRoute(
      path: '/inventory',
      builder: (context, state) => const InventoryListScreen(),
    ),
    GoRoute(
      path: '/inventory/new',
      builder: (context, state) => const ProductFormScreen(),
    ),
    GoRoute(
      path: '/inventory/imei',
      builder: (context, state) => const ImeiSearchScreen(),
    ),
    GoRoute(
      path: '/inventory/adjust',
      builder: (context, state) => StockAdjustScreen(
        productId: state.uri.queryParameters['productId'],
      ),
    ),
    GoRoute(
      path: '/inventory/:id/edit',
      builder: (context, state) => ProductFormScreen(
        productId: state.pathParameters['id'],
      ),
    ),
    GoRoute(
      path: '/inventory/:id',
      builder: (context, state) => ProductDetailScreen(
        productId: state.pathParameters['id'] ?? '',
      ),
    ),
    // --- Customers -----------------------------------------------------------
    GoRoute(
      path: '/customers',
      builder: (context, state) => Consumer(
        builder: (context, ref, _) => CustomerListScreen(
          repository: ref.read(customerRepositoryProvider),
        ),
      ),
    ),
    GoRoute(
      path: '/customers/new',
      builder: (context, state) => Consumer(
        builder: (context, ref, _) => CustomerFormScreen(
          repository: ref.read(customerRepositoryProvider),
        ),
      ),
    ),
    GoRoute(
      path: '/customers/overdue',
      builder: (context, state) => Consumer(
        builder: (context, ref, _) => OverdueListScreen(
          repository: ref.read(customerRepositoryProvider),
        ),
      ),
    ),
    GoRoute(
      path: '/customers/:id/installments',
      builder: (context, state) => Consumer(
        builder: (context, ref, _) => InstallmentPlanScreen(
          repository: ref.read(customerRepositoryProvider),
          customerId: state.pathParameters['id'] ?? '',
          saleRepository: ref.read(saleRepositoryProvider),
        ),
      ),
    ),
    GoRoute(
      path: '/customers/:id',
      builder: (context, state) => Consumer(
        builder: (context, ref, _) => CustomerDetailScreen(
          repository: ref.read(customerRepositoryProvider),
          customerId: state.pathParameters['id'] ?? '',
          saleRepository: ref.read(saleRepositoryProvider),
        ),
      ),
    ),
    // --- Purchases / suppliers ----------------------------------------------
    GoRoute(
      path: '/purchases',
      builder: (context, state) => Consumer(
        builder: (context, ref, _) => PurchaseListScreen(
          purchaseRepository: ref.read(purchaseRepositoryProvider),
          reportRepository: ref.read(reportRepositoryProvider),
          productRepository: ref.read(productRepositoryProvider),
          catalogRepository:
              ref.read(catalogRepositoryProvider),
        ),
      ),
    ),
    GoRoute(
      path: '/purchases/new',
      builder: (context, state) => Consumer(
        builder: (context, ref, _) => PurchaseEntryScreen(
          purchaseRepository: ref.read(purchaseRepositoryProvider),
          reportRepository: ref.read(reportRepositoryProvider),
          productRepository: ref.read(productRepositoryProvider),
          catalogRepository:
              ref.read(catalogRepositoryProvider),
        ),
      ),
    ),
    GoRoute(
      path: '/purchases/:id/return',
      builder: (context, state) => Consumer(
        builder: (context, ref, _) => PurchaseReturnScreen(
          purchaseRepository: ref.read(purchaseRepositoryProvider),
          productRepository: ref.read(productRepositoryProvider),
          purchaseId: state.pathParameters['id'] ?? '',
        ),
      ),
    ),
    GoRoute(
      path: '/purchases/:id',
      builder: (context, state) => Consumer(
        builder: (context, ref, _) => PurchaseDetailScreen(
          purchaseRepository: ref.read(purchaseRepositoryProvider),
          reportRepository: ref.read(reportRepositoryProvider),
          productRepository: ref.read(productRepositoryProvider),
          purchaseId: state.pathParameters['id'] ?? '',
        ),
      ),
    ),
    GoRoute(
      path: '/suppliers',
      builder: (context, state) => Consumer(
        builder: (context, ref, _) => SupplierListScreen(
          purchaseRepository: ref.read(purchaseRepositoryProvider),
          reportRepository: ref.read(reportRepositoryProvider),
          productRepository: ref.read(productRepositoryProvider),
        ),
      ),
    ),
    GoRoute(
      path: '/suppliers/:id',
      builder: (context, state) => _SupplierDetailRoute(
        supplierId: state.pathParameters['id'] ?? '',
      ),
    ),
    // --- Repairs ---------------------------------------------------------------
    GoRoute(
      path: '/repairs',
      builder: (context, state) => Consumer(
        builder: (context, ref, _) => RepairListScreen(
          repository: ref.read(repairRepositoryProvider),
        ),
      ),
    ),
    GoRoute(
      path: '/repairs/new',
      builder: (context, state) => Consumer(
        builder: (context, ref, _) => RepairFormScreen(
          repository: ref.read(repairRepositoryProvider),
          customerRepository:
              ref.read(customerRepositoryProvider),
        ),
      ),
    ),
    GoRoute(
      path: '/repairs/services',
      builder: (context, state) => Consumer(
        builder: (context, ref, _) => ServiceSaleScreen(
          expenseRepository:
              ref.read(expenseRepositoryProvider),
          settingsRepository:
              ref.read(settingsRepositoryProvider),
        ),
      ),
    ),
    GoRoute(
      path: '/repairs/:id',
      builder: (context, state) => Consumer(
        builder: (context, ref, _) => RepairDetailScreen(
          repairId: state.pathParameters['id'] ?? '',
          repository: ref.read(repairRepositoryProvider),
          catalogRepository:
              ref.read(catalogRepositoryProvider),
          customerRepository:
              ref.read(customerRepositoryProvider),
        ),
      ),
    ),
    // --- Expenses / cash ------------------------------------------------------
    GoRoute(
      path: '/expenses',
      builder: (context, state) => Consumer(
        builder: (context, ref, _) => ExpenseListScreen(
          repository: ref.read(expenseRepositoryProvider),
        ),
      ),
    ),
    GoRoute(
      path: '/expenses/staff',
      builder: (context, state) => Consumer(
        builder: (context, ref, _) => StaffListScreen(
          repository: ref.read(expenseRepositoryProvider),
        ),
      ),
    ),
    GoRoute(
      path: '/cash',
      builder: (context, state) => Consumer(
        builder: (context, ref, _) => CashRegisterScreen(
          repository: ref.read(expenseRepositoryProvider),
        ),
      ),
    ),
    GoRoute(
      path: '/cash/day-end',
      builder: (context, state) => Consumer(
        builder: (context, ref, _) => DayEndScreen(
          repository: ref.read(expenseRepositoryProvider),
        ),
      ),
    ),
    // --- Reports ----------------------------------------------------------------
    GoRoute(
      path: '/reports',
      builder: (context, state) => const ReportsScreen(),
    ),
    GoRoute(
      path: '/reports/imei',
      builder: (context, state) => ImeiHistoryScreen(
        initialImei: state.uri.queryParameters['imei'],
      ),
    ),
    GoRoute(
      path: '/reports/detail/:kind',
      builder: (context, state) {
        final raw = state.pathParameters['kind'] ?? '';
        final kind = ReportDetailKind.values
            .where((k) => k.name == raw)
            .firstOrNull;
        if (kind == null) {
          return const ComingSoonScreen(title: 'Reports');
        }
        return ReportDetailScreen(kind: kind);
      },
    ),
    // --- Settings ---------------------------------------------------------------
    GoRoute(
      path: '/settings',
      builder: (context, state) => const SettingsScreen(),
    ),
    GoRoute(
      path: '/settings/backup',
      builder: (context, state) => const BackupScreen(),
    ),
    // --- Catalog ------------------------------------------------------------------
    GoRoute(
      path: '/catalog',
      builder: (context, state) => Consumer(
        builder: (context, ref, _) => CatalogBrowserScreen(
          repository: ref.read(catalogRepositoryProvider),
        ),
      ),
    ),
    GoRoute(
      path: '/catalog/stock-in',
      builder: (context, state) => Consumer(
        builder: (context, ref, _) => QuickStockInScreen(
          repository: ref.read(catalogRepositoryProvider),
        ),
      ),
    ),
    GoRoute(
      path: '/catalog/bulk',
      builder: (context, state) => Consumer(
        builder: (context, ref, _) => BulkStockInScreen(
          repository: ref.read(catalogRepositoryProvider),
        ),
      ),
    ),
    GoRoute(
      path: '/catalog/opening-stock',
      builder: (context, state) => Consumer(
        builder: (context, ref, _) => OpeningStockScreen(
          repository: ref.read(catalogRepositoryProvider),
        ),
      ),
    ),
    GoRoute(
      path: '/catalog/count',
      builder: (context, state) => Consumer(
        builder: (context, ref, _) => StockCountScreen(
          repository: ref.read(catalogRepositoryProvider),
        ),
      ),
    ),
    GoRoute(
      path: '/catalog/reorder',
      builder: (context, state) => Consumer(
        builder: (context, ref, _) => ReorderListScreen(
          repository: ref.read(catalogRepositoryProvider),
        ),
      ),
    ),
    GoRoute(
      path: '/catalog/add-custom',
      builder: (context, state) => Consumer(
        builder: (context, ref, _) => AddCustomItemScreen(
          repository: ref.read(catalogRepositoryProvider),
        ),
      ),
    ),
    // --- Invoice / QR warranty (M4, this agent) ------------------------------------
    GoRoute(
      path: '/invoice/:saleId',
      builder: (context, state) => InvoiceScreen(
        saleId: state.pathParameters['saleId'] ?? '',
      ),
    ),
    GoRoute(
      path: '/warranty/:saleId',
      builder: (context, state) => QrWarrantyScreen(
        saleId: state.pathParameters['saleId'] ?? '',
      ),
    ),
    GoRoute(
      path: '/warranty/imei/:imei',
      builder: (context, state) => WarrantyLookupScreen(
        imei: state.pathParameters['imei'] ?? '',
      ),
    ),
    // --- Command palette / AI -------------------------------------------------------
    GoRoute(
      path: '/command',
      builder: (context, state) => const CommandPaletteScreen(),
    ),
    GoRoute(
      path: '/ai',
      builder: (context, state) => const AiAssistantScreen(),
    ),
  ],
);

// ---------------------------------------------------------------------------
// Supplier detail route: loads the SupplierSummary for an id first
// ---------------------------------------------------------------------------

/// `/suppliers/:id` needs a [SupplierSummary]. It is loaded straight
/// from [SupplierRepository.getSupplier], so a supplier with a zero
/// payable still resolves (the old payable-only summary list hid
/// them); an unknown id shows a plain not-found state instead of
/// crashing.
class _SupplierDetailRoute extends ConsumerStatefulWidget {
  const _SupplierDetailRoute({required this.supplierId});

  final String supplierId;

  @override
  ConsumerState<_SupplierDetailRoute> createState() =>
      _SupplierDetailRouteState();
}

class _SupplierDetailRouteState
    extends ConsumerState<_SupplierDetailRoute> {
  late final Future<SupplierSummary?> _loadFuture;

  @override
  void initState() {
    super.initState();
    _loadFuture = _load();
  }

  Future<SupplierSummary?> _load() async {
    final supplier = await ref
        .read(supplierRepositoryProvider)
        .getSupplier(widget.supplierId);
    if (supplier == null) return null;
    return SupplierSummary(
      id: supplier.id,
      name: supplier.name,
      phone: supplier.phone ?? '',
      payable: supplier.payable,
    );
  }

  @override
  Widget build(BuildContext context) {
    final c = ref.watch(themeNotifierProvider).colors;
    final lang = ref.watch(languageProvider);
    String tr(String key) => AppStrings.tr(key, language: lang);
    return FutureBuilder<SupplierSummary?>(
      future: _loadFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        final supplier = snapshot.data;
        if (snapshot.hasError || supplier == null) {
          return Scaffold(
            appBar: CyberAppBar(title: tr('suppliers')),
            body: Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.store_outlined, size: 56, color: c.error),
                    const SizedBox(height: 16),
                    Text(
                      tr('noData'),
                      style: CyberTextStyles.body(c),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),
                    CyberButton(
                      label: tr('done'),
                      onPressed: () => context.go('/suppliers'),
                    ),
                  ],
                ),
              ),
            ),
          );
        }
        return Consumer(
          builder: (context, ref, _) => SupplierDetailScreen(
            purchaseRepository: ref.read(purchaseRepositoryProvider),
            reportRepository: ref.read(reportRepositoryProvider),
            productRepository: ref.read(productRepositoryProvider),
            supplier: supplier,
          ),
        );
      },
    );
  }
}

// ---------------------------------------------------------------------------
// Temporary "coming soon" shim
// ---------------------------------------------------------------------------

/// Temporary placeholder for a route whose screen another Round 2
/// agent has not finished yet. Shows a "coming soon" message and a way
/// back to the dashboard. Every use is listed in the M4 report; delete
/// the route's shim when the real screen lands.
class ComingSoonScreen extends ConsumerWidget {
  const ComingSoonScreen({super.key, required this.title});

  final String title;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c = ref.watch(themeNotifierProvider).colors;
    final lang = ref.watch(languageProvider);
    String tr(String key) => AppStrings.tr(key, language: lang);
    return Scaffold(
      appBar: CyberAppBar(title: title),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.construction_outlined, size: 56, color: c.warning),
              const SizedBox(height: 16),
              Text(
                title,
                style: CyberTextStyles.title(c, size: 20),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                tr('comingSoon'),
                style: CyberTextStyles.body(c),
                textAlign: TextAlign.center,
              ),
              Text(
                tr('screenNotReady'),
                style: CyberTextStyles.bodySecondary(c),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              CyberButton(
                label: tr('dashboard'),
                icon: Icons.home_outlined,
                onPressed: () => context.go('/dashboard'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Unknown route: send the user to the dashboard (redirect rules still
/// apply, so a signed-out user lands on `/login` instead).
class _UnknownRouteScreen extends StatelessWidget {
  const _UnknownRouteScreen();

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (context.mounted) context.go('/dashboard');
    });
    return const Scaffold(
      body: Center(child: CircularProgressIndicator()),
    );
  }
}
