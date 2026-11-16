library;

/// Dashboard (route `/dashboard`): HUD hero fed with real shop data,
/// count-up stat cards, quick actions, recent sales and low-stock alerts.
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/config/constants.dart';
import '../../core/l10n/app_strings.dart';
import '../../core/theme/app_theme.dart';
import '../../core/theme/cyber_colors.dart';
import '../../core/theme/cyber_text_styles.dart';
import '../../core/theme/cyber_widgets.dart';
import '../../data/repositories/report_repository.dart';
import '../../domain/models/product_variant.dart';
import '../../domain/models/sale.dart';
import '../../domain/models/settings.dart';
import '../auth/auth_state.dart';
import '../hud/hud_dashboard_hero.dart';
import '../hud/hud_performance.dart';
import '../hud/hud_settings.dart';
import '../../core/providers/app_providers.dart';
import 'shop_helpers.dart';

/// Data loaded for the dashboard in one refresh.
class _DashboardData {
  const _DashboardData({
    required this.today,
    required this.lowStock,
    required this.udhaar,
    required this.recentSales,
    required this.cashDrawer,
    required this.pendingSync,
    required this.settings,
    required this.stockHealth,
    required this.salesTarget,
  });

  final DashboardTotals today;
  final List<ProductVariant> lowStock;
  final List<PendingUdhaar> udhaar;
  final List<Sale> recentSales;
  final int cashDrawer;
  final int pendingSync;
  final Settings settings;
  final double stockHealth;
  final int salesTarget;
}

class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  _DashboardData? _data;
  String? _error;
  bool _loading = true;

  /// Periodic background sync while the dashboard is open, so stock /
  /// catalog / customers added on another device (or the web software)
  /// show up without a manual refresh. Cancelled in [dispose].
  Timer? _syncTimer;

  @override
  void initState() {
    super.initState();
    _load();
    _syncTimer = Timer.periodic(const Duration(minutes: 15), (_) {
      _syncInBackground();
    });
  }

  @override
  void dispose() {
    _syncTimer?.cancel();
    super.dispose();
  }

  /// Best-effort background sync. Never throws and never touches the
  /// loading state: a failed sync just means this refresh uses the
  /// local data it already has.
  Future<void> _syncInBackground() async {
    try {
      await ref.read(syncEngineProvider).sync();
    } catch (_) {
      // Offline or server error: ignore; the next refresh retries.
    }
  }

  Future<void> _load() async {
    if (mounted) setState(() => _loading = true);
    // Sync first (push local sales, pull server products/variants/
    // customers/catalog) so the data read below already includes what
    // the server has. A failed sync must not block the dashboard:
    // it just falls back to the local data.
    await _syncInBackground();
    try {
      final reports = ref.read(reportRepositoryProvider);
      final products = ref.read(productRepositoryProvider);
      final sales = ref.read(saleRepositoryProvider);
      final expenses = ref.read(expenseRepositoryProvider);
      final settingsRepo = ref.read(settingsRepositoryProvider);
      final sync = ref.read(syncEngineProvider);
      final prefs = await SharedPreferences.getInstance();

      final now = DateTime.now();
      final today = await reports.dashboardTotals(
        from: startOfDay(now),
        to: now,
      );
      final lowStock = await products.lowStockVariants();
      final udhaar = await reports.pendingUdhaar();
      final recent = await sales.listSales(limit: 5);
      final daySummary = await expenses.daySummary(date: now);
      final settings = await settingsRepo.getSettings();
      final pendingSync = await sync.pendingCount();
      final valuation = await reports.stockValuation();
      final target =
          prefs.getInt(dailySalesTargetKey) ?? defaultDailySalesTarget;

      // Stock health: share of stocked units that are NOT in a
      // low-stock variant. Units come from the valuation; low-stock
      // units are summed from the flagged variants.
      final totalUnits = valuation.phoneCount + valuation.accessoryUnits;
      final lowUnits =
          lowStock.fold<int>(0, (sum, v) => sum + v.quantity);
      final health = totalUnits <= 0
          ? 1.0
          : (1 - lowUnits / totalUnits).clamp(0.0, 1.0);

      // Apply the stored HUD animation level + battery-saver rule.
      final hud = await HudSettings.load();
      HudPerformanceManager.instance.setLevel(hud.level);
      HudPerformanceManager.instance
          .setBatterySaver(hud.batterySaverAutoOff && _batterySaverOn());

      if (!mounted) return;
      ref.read(privacyModeProvider.notifier).state = settings.privacyMode;
      setState(() {
        _data = _DashboardData(
          today: today,
          lowStock: lowStock,
          udhaar: udhaar,
          recentSales: recent,
          cashDrawer: daySummary.expectedCash,
          pendingSync: pendingSync,
          settings: settings,
          stockHealth: health,
          salesTarget: target,
        );
        _error = null;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  /// Battery saver state is not exposed by a plugin here; the HUD
  /// manager already pauses when the app is backgrounded, and the
  /// stored auto-off flag is honoured by the manager itself. This
  /// hook returns false until a battery-state plugin is wired in.
  bool _batterySaverOn() => false;

  bool get _canSeeCosts {
    final role = ref.watch(authStateProvider).user?.role ?? '';
    return UserRoles.canSeeCosts.contains(role);
  }

  @override
  Widget build(BuildContext context) {
    final lang = ref.watch(languageProvider);
    String t(String key) => AppStrings.tr(key, language: lang);
    final theme = ref.watch(themeNotifierProvider);
    final c = theme.colors;
    final privacy = ref.watch(privacyModeProvider);
    final user = ref.watch(authStateProvider).user;

    return Scaffold(
      appBar: CyberAppBar(
        title: t('dashboard'),
        showBack: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.terminal),
            tooltip: t('commandPalette'),
            onPressed: () => context.push('/command'),
          ),
          IconButton(
            icon: const Icon(Icons.smart_toy_outlined),
            tooltip: t('aiAssistant'),
            onPressed: () => context.push('/ai'),
          ),
          IconButton(
            icon: const Icon(Icons.settings),
            tooltip: t('settings'),
            onPressed: () => context.push('/settings'),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _load,
        color: c.primary,
        child: _loading && _data == null
            ? ListView(
                children: [
                  const SizedBox(height: 120),
                  Center(
                    child: Column(
                      children: [
                        const CircularProgressIndicator(),
                        const SizedBox(height: 16),
                        Text(t('loading'),
                            style: CyberTextStyles.bodySecondary(c)),
                      ],
                    ),
                  ),
                ],
              )
            : _error != null && _data == null
                ? ListView(
                    padding: const EdgeInsets.all(16),
                    children: [
                      CyberCard(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(t('error'),
                                style: CyberTextStyles.title(c, size: 18)),
                            const SizedBox(height: 8),
                            Text(_error!,
                                style: CyberTextStyles.bodySecondary(c)),
                            const SizedBox(height: 16),
                            CyberButton(
                              label: t('tryAgain'),
                              onPressed: _load,
                            ),
                          ],
                        ),
                      ),
                    ],
                  )
                : _buildBody(context, t, c, privacy, user?.displayName ?? ''),
      ),
    );
  }

  Widget _buildBody(
    BuildContext context,
    String Function(String) t,
    CyberColors c,
    bool privacy,
    String displayName,
  ) {
    final data = _data!;
    final theme = ref.watch(themeNotifierProvider);
    final canSeeCosts = _canSeeCosts;
    final hud = HudPerformanceManager.instance;
    final animate = theme.animationsEnabled && hud.shouldAnimate;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text(
          '${t('welcome')}, $displayName',
          style: CyberTextStyles.title(c, size: 20),
        ),
        const SizedBox(height: 4),
        Text(
          formatShortDate(DateTime.now()),
          style: CyberTextStyles.bodySecondary(c),
        ),
        const SizedBox(height: 16),
        AnimatedBuilder(
          animation: hud,
          builder: (context, _) => HudDashboardHero(
            salesToday: data.today.totalRevenue,
            salesTarget: data.salesTarget,
            stockHealth: data.stockHealth,
            cashDrawer: data.cashDrawer,
            pendingUdhaarAmount: data.today.pendingUdhaar,
            pendingUdhaarCount: data.udhaar.length,
            lowStockAlerts: data.lowStock.length,
            syncStatus: data.pendingSync == 0
                ? t('synced').toUpperCase()
                : '${data.pendingSync} ${t('pendingSync').toUpperCase()}',
            isSynced: data.pendingSync == 0,
            isAnimating: animate,
            particleBudget: hud.particleBudget,
            frameSkip: hud.frameSkip,
          ),
        ),
        const SizedBox(height: 16),
        _statGrid(data, t, c, privacy, canSeeCosts),
        const SizedBox(height: 16),
        Text(t('quickActions'), style: CyberTextStyles.title(c, size: 18)),
        const SizedBox(height: 8),
        _quickActions(t, c),
        const SizedBox(height: 16),
        if (data.lowStock.isNotEmpty) ...[
          _lowStockStrip(data, t, c),
          const SizedBox(height: 16),
        ],
        Text(t('recentSales'), style: CyberTextStyles.title(c, size: 18)),
        const SizedBox(height: 8),
        if (data.recentSales.isEmpty)
          CyberCard(
            child: Text(t('noRecentSales'),
                style: CyberTextStyles.bodySecondary(c)),
          )
        else
          ...data.recentSales.map((sale) => _saleTile(sale, t, c, privacy)),
        const SizedBox(height: 8),
        CyberButton(
          label: t('viewReports'),
          variant: CyberButtonVariant.ghost,
          icon: Icons.bar_chart,
          onPressed: () => context.push('/reports'),
        ),
      ],
    );
  }

  Widget _statGrid(
    _DashboardData data,
    String Function(String) t,
    CyberColors c,
    bool privacy,
    bool canSeeCosts,
  ) {
    final cards = <Widget>[
      CyberStatCard(
        label: t('todaySales'),
        value: privacy ? 0 : data.today.totalRevenue,
        prefix: privacy ? '' : 'Rs ',
        icon: Icons.point_of_sale,
      ),
      if (canSeeCosts)
        CyberStatCard(
          label: t('todayProfit'),
          value: privacy ? 0 : data.today.totalProfit,
          prefix: privacy ? '' : 'Rs ',
          icon: Icons.trending_up,
        ),
      CyberStatCard(
        label: t('pendingUdhaar'),
        value: privacy ? 0 : data.today.pendingUdhaar,
        prefix: privacy ? '' : 'Rs ',
        icon: Icons.account_balance_wallet,
        onTap: () => context.push('/customers'),
      ),
      CyberStatCard(
        label: t('lowStock'),
        value: data.lowStock.length,
        icon: Icons.warning_amber_rounded,
        valueColor: data.lowStock.isEmpty ? null : c.warning,
        onTap: () => context.push('/inventory'),
      ),
      CyberStatCard(
        label: t('billsToday'),
        value: data.today.salesCount,
        icon: Icons.receipt_long,
      ),
      CyberStatCard(
        label: t('openRepairs'),
        value: data.today.openRepairs,
        icon: Icons.build,
        onTap: () => context.push('/repairs'),
      ),
    ];
    // Privacy mode: show **** instead of the counted-up amounts.
    if (privacy) {
      return GridView.count(
        crossAxisCount: 2,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        mainAxisSpacing: 8,
        crossAxisSpacing: 8,
        childAspectRatio: 1.6,
        children: [
          _maskedCard(t('todaySales'), Icons.point_of_sale, c),
          if (canSeeCosts)
            _maskedCard(t('todayProfit'), Icons.trending_up, c),
          _maskedCard(t('pendingUdhaar'), Icons.account_balance_wallet, c),
          CyberStatCard(
            label: t('lowStock'),
            value: data.lowStock.length,
            icon: Icons.warning_amber_rounded,
            onTap: () => context.push('/inventory'),
          ),
          CyberStatCard(
            label: t('billsToday'),
            value: data.today.salesCount,
            icon: Icons.receipt_long,
          ),
          CyberStatCard(
            label: t('openRepairs'),
            value: data.today.openRepairs,
            icon: Icons.build,
            onTap: () => context.push('/repairs'),
          ),
        ],
      );
    }
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 8,
      crossAxisSpacing: 8,
      childAspectRatio: 1.6,
      children: cards,
    );
  }

  Widget _maskedCard(String label, IconData icon, CyberColors c) {
    return CyberCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: c.primary, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(label,
                    style: CyberTextStyles.label(c),
                    overflow: TextOverflow.ellipsis),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text('****', style: CyberTextStyles.amount(c, size: 26)),
        ],
      ),
    );
  }

  Widget _quickActions(String Function(String) t, CyberColors c) {
    final actions = <({IconData icon, String label, String route})>[
      (icon: Icons.point_of_sale, label: t('newBill'), route: '/pos'),
      (
        icon: Icons.inventory_2,
        label: t('importStock'),
        route: '/catalog/stock-in'
      ),
      (icon: Icons.shopping_bag, label: t('newPurchase'), route: '/purchases/new'),
      (icon: Icons.build, label: t('newRepair'), route: '/repairs/new'),
      (icon: Icons.people, label: t('customers'), route: '/customers'),
      (icon: Icons.bar_chart, label: t('reports'), route: '/reports'),
    ];
    return GridView.count(
      crossAxisCount: 3,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 8,
      crossAxisSpacing: 8,
      childAspectRatio: 1.1,
      children: actions
          .map(
            (a) => InkWell(
              onTap: () => context.push(a.route),
              borderRadius: BorderRadius.circular(8),
              child: CyberCard(
                padding: const EdgeInsets.all(8),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(a.icon, color: c.primary, size: 26),
                    const SizedBox(height: 6),
                    Text(
                      a.label,
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: CyberTextStyles.label(c, size: 11),
                    ),
                  ],
                ),
              ),
            ),
          )
          .toList(),
    );
  }

  Widget _lowStockStrip(_DashboardData data, String Function(String) t, CyberColors c) {
    return CyberCard(
      borderColor: c.warning,
      onTap: () => context.push('/inventory'),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.warning_amber_rounded, color: c.warning),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  '${t('lowStock')}: ${data.lowStock.length}',
                  style: CyberTextStyles.title(c, size: 16),
                ),
              ),
              Icon(Icons.chevron_right, color: c.primary),
            ],
          ),
          const SizedBox(height: 8),
          ...data.lowStock.take(3).map(
                (v) => Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text(
                    '${v.name} — ${v.quantity} ${t('stock')}',
                    style: CyberTextStyles.bodySecondary(c),
                  ),
                ),
              ),
        ],
      ),
    );
  }

  Widget _saleTile(
    Sale sale,
    String Function(String) t,
    CyberColors c,
    bool privacy,
  ) {
    return CyberCard(
      onTap: () => context.push('/invoice/${sale.id}'),
      child: Row(
        children: [
          Icon(Icons.receipt_long, color: c.primary),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  sale.invoiceNo,
                  style: CyberTextStyles.mono(c, size: 15),
                ),
                const SizedBox(height: 2),
                Text(
                  '${sale.customerName ?? t('cash')} • '
                  '${formatShortDateTime(sale.saleDate)}',
                  style: CyberTextStyles.bodySecondary(c, size: 13),
                ),
              ],
            ),
          ),
          Text(
            maybeHideAmount(sale.grandTotal, privacy),
            style: CyberTextStyles.amount(c, size: 18),
          ),
          const SizedBox(width: 4),
          Icon(Icons.chevron_right, color: c.textSecondary),
        ],
      ),
    );
  }
}
