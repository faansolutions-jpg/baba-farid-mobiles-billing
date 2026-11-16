library;

/// Full-list detail for one report section (route `/reports/detail`,
/// opened from [ReportsScreen] with a [ReportDetailKind]).
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/l10n/app_strings.dart';
import '../../core/theme/app_theme.dart';
import '../../core/theme/cyber_colors.dart';
import '../../core/theme/cyber_text_styles.dart';
import '../../core/theme/cyber_widgets.dart';
import '../../data/repositories/report_repository.dart';
import '../auth/auth_state.dart';
import '../../core/providers/app_providers.dart';
import '../dashboard/shop_helpers.dart';

enum ReportDetailKind { bestSellers, deadStock, udhaar, payables }

class ReportDetailScreen extends ConsumerStatefulWidget {
  const ReportDetailScreen({super.key, required this.kind});

  final ReportDetailKind kind;

  @override
  ConsumerState<ReportDetailScreen> createState() =>
      _ReportDetailScreenState();
}

class _ReportDetailScreenState extends ConsumerState<ReportDetailScreen> {
  List<dynamic> _rows = const [];
  String? _error;
  bool _loading = true;

  String get _titleKey {
    return switch (widget.kind) {
      ReportDetailKind.bestSellers => 'bestSellers',
      ReportDetailKind.deadStock => 'deadStock',
      ReportDetailKind.udhaar => 'pendingUdhaar',
      ReportDetailKind.payables => 'supplierPayables',
    };
  }

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final repo = ref.read(reportRepositoryProvider);
      final rows = await switch (widget.kind) {
        ReportDetailKind.bestSellers =>
          repo.bestSellers(limit: 50),
        ReportDetailKind.deadStock => repo.deadStock(days: 60),
        ReportDetailKind.udhaar => repo.pendingUdhaar(),
        ReportDetailKind.payables => repo.supplierPayables(),
      };
      if (!mounted) return;
      setState(() {
        _rows = rows;
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

  @override
  Widget build(BuildContext context) {
    final lang = ref.watch(languageProvider);
    String t(String key) => AppStrings.tr(key, language: lang);
    final c = ref.watch(themeNotifierProvider).colors;
    final privacy = ref.watch(privacyModeProvider);
    final role = ref.watch(authStateProvider).user?.role ?? '';
    final canSeeCosts = role == 'owner' || role == 'manager';

    return Scaffold(
      appBar: CyberAppBar(title: t(_titleKey)),
      body: RefreshIndicator(
        onRefresh: _load,
        color: c.primary,
        child: _loading
            ? ListView(
                children: const [
                  SizedBox(height: 120),
                  Center(child: CircularProgressIndicator()),
                ],
              )
            : _error != null
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
                : _rows.isEmpty
                    ? ListView(
                        padding: const EdgeInsets.all(16),
                        children: [
                          CyberCard(
                            child: Text(t('noData'),
                                style: CyberTextStyles.bodySecondary(c)),
                          ),
                        ],
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: _rows.length,
                        itemBuilder: (context, i) =>
                            _rowTile(_rows[i], t, c, privacy, canSeeCosts),
                      ),
      ),
    );
  }

  Widget _rowTile(
    dynamic row,
    String Function(String) t,
    CyberColors c,
    bool privacy,
    bool canSeeCosts,
  ) {
    final String title;
    final String subtitle;
    final int? amount;
    if (row is BestSeller) {
      title = '${row.productName} ${row.variantName}'.trim();
      subtitle = '${row.quantity} ${t('salesCount')}';
      amount = row.revenue;
    } else if (row is DeadStockItem) {
      title = '${row.productName} ${row.variantName}'.trim();
      subtitle =
          '${row.daysUnsold} ${t('daysUnsold')}${row.imei1 == null ? '' : ' • ${row.imei1}'}';
      amount = null;
    } else if (row is PendingUdhaar) {
      title = row.customerName;
      subtitle = row.phone;
      amount = row.balance;
    } else if (row is SupplierPayable) {
      title = row.supplierName;
      subtitle = row.phone;
      amount = row.payable;
    } else {
      title = row.toString();
      subtitle = '';
      amount = null;
    }
    return CyberCard(
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: CyberTextStyles.body(c, size: 15)),
                if (subtitle.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(subtitle, style: CyberTextStyles.bodySecondary(c)),
                ],
              ],
            ),
          ),
          if (amount != null)
            Text(
              maybeHideAmount(amount, privacy),
              style: CyberTextStyles.amount(c, size: 16),
            ),
        ],
      ),
    );
  }
}
