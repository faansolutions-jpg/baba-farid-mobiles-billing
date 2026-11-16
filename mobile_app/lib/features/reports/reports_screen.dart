library;

/// Reports (route `/reports`): period selector, sales series + charts,
/// P&L, stock valuation, brand sales, best sellers, dead stock,
/// pending udhaar and supplier payables — all from [ReportRepository].
/// CSV / PDF export via the share sheet.
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:share_plus/share_plus.dart';

import '../../core/l10n/app_strings.dart';
import '../../core/theme/app_theme.dart';
import '../../core/theme/cyber_colors.dart';
import '../../core/theme/cyber_text_styles.dart';
import '../../core/theme/cyber_widgets.dart';
import '../../data/repositories/report_repository.dart';
import '../auth/auth_state.dart';
import '../../core/providers/app_providers.dart';
import '../dashboard/shop_helpers.dart';
import 'report_detail_screen.dart';

enum ReportPeriod { today, week, month, custom }

class _ReportData {
  const _ReportData({
    required this.totals,
    required this.series,
    required this.pl,
    required this.valuation,
    required this.brands,
    required this.bestSellers,
    required this.deadStock,
    required this.udhaar,
    required this.payables,
  });

  final DashboardTotals totals;
  final List<SalesSummary> series;
  final ProfitLoss pl;
  final StockValuation valuation;
  final List<BrandSales> brands;
  final List<BestSeller> bestSellers;
  final List<DeadStockItem> deadStock;
  final List<PendingUdhaar> udhaar;
  final List<SupplierPayable> payables;
}

class ReportsScreen extends ConsumerStatefulWidget {
  const ReportsScreen({super.key});

  @override
  ConsumerState<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends ConsumerState<ReportsScreen> {
  ReportPeriod _period = ReportPeriod.today;
  DateTimeRange? _customRange;
  _ReportData? _data;
  String? _error;
  bool _loading = true;
  bool _exporting = false;

  DateTime get _from {
    final now = DateTime.now();
    return switch (_period) {
      ReportPeriod.today => startOfDay(now),
      ReportPeriod.week => startOfDay(now.subtract(const Duration(days: 6))),
      ReportPeriod.month => startOfDay(now.subtract(const Duration(days: 29))),
      ReportPeriod.custom =>
        _customRange == null ? startOfDay(now) : startOfDay(_customRange!.start),
    };
  }

  DateTime get _to {
    final now = DateTime.now();
    return switch (_period) {
      ReportPeriod.custom =>
        _customRange == null ? now : endOfDay(_customRange!.end),
      _ => now,
    };
  }

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    if (mounted) setState(() => _loading = true);
    try {
      final repo = ref.read(reportRepositoryProvider);
      final from = _from;
      final to = _to;
      final results = await Future.wait([
        repo.dashboardTotals(from: from, to: to),
        repo.dailySales(from, to),
        repo.profitAndLoss(from, to),
        repo.stockValuation(),
        repo.brandSales(from, to),
        repo.bestSellers(from: from, to: to, limit: 10),
        repo.deadStock(days: 60),
        repo.pendingUdhaar(),
        repo.supplierPayables(),
      ]);
      if (!mounted) return;
      setState(() {
        _data = _ReportData(
          totals: results[0] as DashboardTotals,
          series: results[1] as List<SalesSummary>,
          pl: results[2] as ProfitLoss,
          valuation: results[3] as StockValuation,
          brands: results[4] as List<BrandSales>,
          bestSellers: results[5] as List<BestSeller>,
          deadStock: results[6] as List<DeadStockItem>,
          udhaar: results[7] as List<PendingUdhaar>,
          payables: results[8] as List<SupplierPayable>,
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

  bool get _canSeeCosts {
    final role = ref.watch(authStateProvider).user?.role ?? '';
    return (role == 'owner' || role == 'manager');
  }

  Future<void> _pickCustomRange() async {
    final now = DateTime.now();
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(now.year - 2),
      lastDate: now,
      initialDateRange: _customRange ??
          DateTimeRange(
            start: now.subtract(const Duration(days: 6)),
            end: now,
          ),
    );
    if (picked == null) return;
    setState(() {
      _customRange = picked;
      _period = ReportPeriod.custom;
    });
    await _load();
  }

  String _csvCell(String value) {
    if (value.contains(',') || value.contains('"') || value.contains('\n')) {
      return '"${value.replaceAll('"', '""')}"';
    }
    return value;
  }

  String _buildCsv() {
    final d = _data!;
    final rows = <List<String>>[
      ['Baba Farid Mobiles — Report', '${formatShortDate(_from)} to ${formatShortDate(_to)}'],
      [],
      ['Section', 'Item', 'Quantity', 'Amount (PKR)'],
      ['Sales', 'Revenue', '${d.totals.salesCount}', '${d.totals.totalRevenue}'],
      ['Sales', 'Profit', '', '${d.totals.totalProfit}'],
      ['Sales', 'Expenses', '', '${d.totals.totalExpenses}'],
      ['P&L', 'Revenue', '', '${d.pl.revenue}'],
      ['P&L', 'Cost of goods', '', '${d.pl.costOfGoods}'],
      ['P&L', 'Gross profit', '', '${d.pl.grossProfit}'],
      ['P&L', 'Net profit', '', '${d.pl.netProfit}'],
      ['Stock', 'Phones (cost value)', '${d.valuation.phoneCount}', '${d.valuation.phoneCostValue}'],
      ['Stock', 'Accessories (cost value)', '${d.valuation.accessoryUnits}', '${d.valuation.accessoryCostValue}'],
      for (final b in d.brands)
        ['Brand', b.brandName, '${b.quantity}', '${b.revenue}'],
      for (final s in d.bestSellers)
        ['Best seller', '${s.productName} ${s.variantName}'.trim(), '${s.quantity}', '${s.revenue}'],
      for (final u in d.udhaar)
        ['Udhaar', u.customerName, '', '${u.balance}'],
      for (final p in d.payables)
        ['Payable', p.supplierName, '', '${p.payable}'],
      for (final s in d.series)
        ['Daily', formatShortDate(s.date), '${s.salesCount}', '${s.revenue}'],
    ];
    return rows.map((r) => r.map(_csvCell).join(',')).join('\n');
  }

  Future<void> _exportCsv() async {
    if (_data == null) return;
    setState(() => _exporting = true);
    try {
      final csv = _buildCsv();
      final fileName =
          'baba-farid-report-${DateTime.now().toIso8601String().substring(0, 10)}.csv';
      await Share.share(
        csv,
        subject: fileName,
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(_t('csvExported'))),
        );
      }
    } finally {
      if (mounted) setState(() => _exporting = false);
    }
  }

  Future<void> _exportPdf() async {
    if (_data == null) return;
    setState(() => _exporting = true);
    try {
      final d = _data!;
      final doc = pw.Document();
      pw.Widget row(String label, String value) => pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Text(label),
              pw.Text(value, style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
            ],
          );
      doc.addPage(
        pw.MultiPage(
          pageFormat: PdfPageFormat.a4,
          build: (context) => [
            pw.Header(
              level: 0,
              child: pw.Text('Baba Farid Mobiles — Report',
                  style: pw.TextStyle(fontSize: 20, fontWeight: pw.FontWeight.bold)),
            ),
            pw.Text('${formatShortDate(_from)} to ${formatShortDate(_to)}'),
            pw.SizedBox(height: 16),
            pw.Text('Sales', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 16)),
            row('Revenue', formatPkr(d.totals.totalRevenue)),
            row('Bills', '${d.totals.salesCount}'),
            if (_canSeeCosts) row('Profit', formatPkr(d.totals.totalProfit)),
            row('Expenses', formatPkr(d.totals.totalExpenses)),
            pw.SizedBox(height: 12),
            pw.Text('Profit & Loss', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 16)),
            row('Revenue', formatPkr(d.pl.revenue)),
            row('Cost of goods', formatPkr(d.pl.costOfGoods)),
            row('Gross profit', formatPkr(d.pl.grossProfit)),
            row('Net profit', formatPkr(d.pl.netProfit)),
            pw.SizedBox(height: 12),
            pw.Text('Stock valuation', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 16)),
            row('Phones in stock', '${d.valuation.phoneCount}'),
            row('Phone cost value', formatPkr(d.valuation.phoneCostValue)),
            row('Accessory units', '${d.valuation.accessoryUnits}'),
            row('Accessory cost value', formatPkr(d.valuation.accessoryCostValue)),
            pw.SizedBox(height: 12),
            pw.Text('Best sellers', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 16)),
            for (final s in d.bestSellers)
              row('${s.productName} ${s.variantName}'.trim(), '${s.quantity} × ${formatPkr(s.revenue)}'),
            pw.SizedBox(height: 12),
            pw.Text('Pending udhaar', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 16)),
            row('Total pending', formatPkr(d.udhaar.fold<int>(0, (sum, u) => sum + u.balance))),
            for (final u in d.udhaar.take(10))
              row(u.customerName, formatPkr(u.balance)),
          ],
        ),
      );
      final bytes = await doc.save();
      await Printing.sharePdf(
        bytes: bytes,
        filename:
            'baba-farid-report-${DateTime.now().toIso8601String().substring(0, 10)}.pdf',
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(_t('pdfExported'))),
        );
      }
    } finally {
      if (mounted) setState(() => _exporting = false);
    }
  }

  String _t(String key) {
    final lang = ref.read(languageProvider);
    return AppStrings.tr(key, language: lang);
  }

  @override
  Widget build(BuildContext context) {
    final lang = ref.watch(languageProvider);
    String t(String key) => AppStrings.tr(key, language: lang);
    final c = ref.watch(themeNotifierProvider).colors;
    final privacy = ref.watch(privacyModeProvider);
    final canSeeCosts = _canSeeCosts;

    return Scaffold(
      appBar: CyberAppBar(
        title: t('reports'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            tooltip: t('imeiHistory'),
            onPressed: () => context.push('/reports/imei'),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _load,
        color: c.primary,
        child: _loading && _data == null
            ? ListView(
                children: const [
                  SizedBox(height: 120),
                  Center(child: CircularProgressIndicator()),
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
                : _buildBody(t, c, privacy, canSeeCosts),
      ),
    );
  }

  Widget _buildBody(
    String Function(String) t,
    CyberColors c,
    bool privacy,
    bool canSeeCosts,
  ) {
    final d = _data!;
    final udhaarTotal = d.udhaar.fold<int>(0, (sum, u) => sum + u.balance);
    final payablesTotal =
        d.payables.fold<int>(0, (sum, p) => sum + p.payable);

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _periodSelector(t, c),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: CyberButton(
                label: t('exportCsv'),
                icon: Icons.table_chart,
                variant: CyberButtonVariant.ghost,
                isLoading: _exporting,
                onPressed: _exporting ? null : _exportCsv,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: CyberButton(
                label: t('exportPdf'),
                icon: Icons.picture_as_pdf,
                variant: CyberButtonVariant.ghost,
                isLoading: _exporting,
                onPressed: _exporting ? null : _exportPdf,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        _sectionTitle(t('dailySales'), c),
        CyberCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CyberChart(
                values: d.series.map((s) => s.revenue.toDouble()).toList(),
                labels: d.series
                    .map((s) => '${s.date.day}/${s.date.month}')
                    .toList(),
                type: CyberChartType.line,
              ),
              const SizedBox(height: 8),
              Text(
                '${t('total')}: ${maybeHideAmount(d.totals.totalRevenue, privacy)}'
                ' • ${d.totals.salesCount} ${t('salesCount')}',
                style: CyberTextStyles.mono(c, size: 14),
              ),
            ],
          ),
        ),
        _sectionTitle(t('profitLoss'), c),
        CyberCard(
          child: Column(
            children: [
              _moneyRow(t('total'), d.pl.revenue, c, privacy),
              if (canSeeCosts) ...[
                _moneyRow(t('costOfGoods'), d.pl.costOfGoods, c, privacy),
                _moneyRow(t('grossProfit'), d.pl.grossProfit, c, privacy),
              ],
              _moneyRow(t('totalExpenses'), d.pl.expenses, c, privacy),
              _moneyRow(t('serviceCommission'), d.pl.serviceCommission, c, privacy),
              const Divider(),
              _moneyRow(t('netProfit'), d.pl.netProfit, c, privacy,
                  bold: true),
            ],
          ),
        ),
        _sectionTitle(t('stockValuation'), c),
        CyberCard(
          child: Column(
            children: [
              _moneyRow(
                '${t('availablePhones')} (${d.valuation.phoneCount})',
                d.valuation.phoneCostValue,
                c,
                privacy,
              ),
              _moneyRow(
                '${t('products')} (${d.valuation.accessoryUnits})',
                d.valuation.accessoryCostValue,
                c,
                privacy,
              ),
              const Divider(),
              _moneyRow(t('totalStockValue'), d.valuation.totalCostValue, c,
                  privacy,
                  bold: true),
            ],
          ),
        ),
        _sectionTitle(t('brandSales'), c),
        CyberCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (d.brands.isEmpty)
                Text(t('noData'), style: CyberTextStyles.bodySecondary(c))
              else ...[
                CyberChart(
                  values: d.brands.map((b) => b.revenue.toDouble()).toList(),
                  labels: d.brands
                      .map((b) => b.brandName.length > 6
                          ? b.brandName.substring(0, 6)
                          : b.brandName)
                      .toList(),
                  type: CyberChartType.bar,
                ),
                const SizedBox(height: 8),
                ...d.brands.map(
                  (b) => ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(b.brandName,
                        style: CyberTextStyles.body(c)),
                    subtitle: Text(
                      '${b.quantity} ${t('salesCount')}',
                      style: CyberTextStyles.bodySecondary(c),
                    ),
                    trailing: Text(
                      maybeHideAmount(b.revenue, privacy),
                      style: CyberTextStyles.mono(c, size: 14),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
        _sectionTitle(t('bestSellers'), c),
        _listCard(
          d.bestSellers.map((s) => _ReportRow(
                title: '${s.productName} ${s.variantName}'.trim(),
                subtitle: '${s.quantity} ${t('salesCount')}',
                amount: s.revenue,
              )),
          t,
          c,
          privacy,
          detail: ReportDetailKind.bestSellers,
        ),
        _sectionTitle(t('deadStock'), c),
        _listCard(
          d.deadStock.take(10).map((s) => _ReportRow(
                title: '${s.productName} ${s.variantName}'.trim(),
                subtitle:
                    '${s.daysUnsold} ${t('daysUnsold')}${s.imei1 == null ? '' : ' • ${s.imei1}'}',
                amount: null,
              )),
          t,
          c,
          privacy,
          detail: ReportDetailKind.deadStock,
        ),
        _sectionTitle(t('pendingUdhaar'), c),
        CyberCard(
          onTap: () => _openDetail(ReportDetailKind.udhaar),
          child: Column(
            children: [
              _moneyRow(t('pendingUdhaar'), udhaarTotal, c, privacy,
                  bold: true),
              const SizedBox(height: 8),
              ...d.udhaar.take(5).map(
                    (u) => ListTile(
                      contentPadding: EdgeInsets.zero,
                      title: Text(u.customerName,
                          style: CyberTextStyles.body(c)),
                      subtitle: Text(u.phone,
                          style: CyberTextStyles.bodySecondary(c)),
                      trailing: Text(
                        maybeHideAmount(u.balance, privacy),
                        style: CyberTextStyles.mono(c, size: 14),
                      ),
                    ),
                  ),
              if (d.udhaar.isEmpty)
                Text(t('noData'), style: CyberTextStyles.bodySecondary(c)),
            ],
          ),
        ),
        _sectionTitle(t('supplierPayables'), c),
        CyberCard(
          onTap: () => _openDetail(ReportDetailKind.payables),
          child: Column(
            children: [
              _moneyRow(t('supplierPayables'), payablesTotal, c, privacy,
                  bold: true),
              const SizedBox(height: 8),
              ...d.payables.take(5).map(
                    (p) => ListTile(
                      contentPadding: EdgeInsets.zero,
                      title: Text(p.supplierName,
                          style: CyberTextStyles.body(c)),
                      subtitle: Text(p.phone,
                          style: CyberTextStyles.bodySecondary(c)),
                      trailing: Text(
                        maybeHideAmount(p.payable, privacy),
                        style: CyberTextStyles.mono(c, size: 14),
                      ),
                    ),
                  ),
              if (d.payables.isEmpty)
                Text(t('noData'), style: CyberTextStyles.bodySecondary(c)),
            ],
          ),
        ),
        const SizedBox(height: 16),
        CyberButton(
          label: t('imeiHistory'),
          icon: Icons.history,
          variant: CyberButtonVariant.ghost,
          onPressed: () => context.push('/reports/imei'),
        ),
      ],
    );
  }

  void _openDetail(ReportDetailKind kind) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => ReportDetailScreen(kind: kind),
      ),
    );
  }

  Widget _periodSelector(String Function(String) t, CyberColors c) {
    final chips = <(ReportPeriod, String)>[
      (ReportPeriod.today, t('today')),
      (ReportPeriod.week, t('thisWeek')),
      (ReportPeriod.month, t('thisMonth')),
      (ReportPeriod.custom, t('customRange')),
    ];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(t('period'), style: CyberTextStyles.title(c, size: 18)),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: chips
              .map(
                (chip) => CyberChip(
                  label: chip.$2,
                  selected: _period == chip.$1,
                  onSelected: (_) async {
                    if (chip.$1 == ReportPeriod.custom) {
                      await _pickCustomRange();
                    } else {
                      setState(() => _period = chip.$1);
                      await _load();
                    }
                  },
                ),
              )
              .toList(),
        ),
        if (_period == ReportPeriod.custom && _customRange != null)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text(
              '${formatShortDate(_customRange!.start)} — ${formatShortDate(_customRange!.end)}',
              style: CyberTextStyles.mono(c, size: 13),
            ),
          ),
      ],
    );
  }

  Widget _sectionTitle(String title, CyberColors c) {
    return Padding(
      padding: const EdgeInsets.only(top: 16, bottom: 8),
      child: Text(title, style: CyberTextStyles.title(c, size: 18)),
    );
  }

  Widget _moneyRow(
    String label,
    int value,
    CyberColors c,
    bool privacy, {
    bool bold = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              label,
              style: bold
                  ? CyberTextStyles.subtitle(c, size: 15)
                  : CyberTextStyles.body(c),
            ),
          ),
          Text(
            maybeHideAmount(value, privacy),
            style: CyberTextStyles.amount(c, size: bold ? 18 : 15),
          ),
        ],
      ),
    );
  }

  Widget _listCard(
    Iterable<_ReportRow> rows,
    String Function(String) t,
    CyberColors c,
    bool privacy, {
    required ReportDetailKind detail,
  }) {
    final list = rows.toList();
    return CyberCard(
      onTap: () => _openDetail(detail),
      child: Column(
        children: [
          if (list.isEmpty)
            Text(t('noData'), style: CyberTextStyles.bodySecondary(c))
          else
            ...list.map(
              (r) => ListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(r.title, style: CyberTextStyles.body(c)),
                subtitle:
                    Text(r.subtitle, style: CyberTextStyles.bodySecondary(c)),
                trailing: r.amount == null
                    ? null
                    : Text(
                        maybeHideAmount(r.amount!, privacy),
                        style: CyberTextStyles.mono(c, size: 14),
                      ),
              ),
            ),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Text(t('reportDetail'),
                  style: CyberTextStyles.label(c)),
              Icon(Icons.chevron_right, color: c.primary, size: 18),
            ],
          ),
        ],
      ),
    );
  }
}

class _ReportRow {
  const _ReportRow({
    required this.title,
    required this.subtitle,
    this.amount,
  });

  final String title;
  final String subtitle;
  final int? amount;
}
