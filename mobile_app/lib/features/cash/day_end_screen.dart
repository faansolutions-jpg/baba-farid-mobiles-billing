/// Day-end summary — route `/cash/day-end`.
///
/// The full day summary from [ExpenseRepository.daySummary]: total
/// sales, bills, service sales + commission, expenses, cash in/out,
/// opening cash, expected cash, counted (closing) cash and the
/// difference. Shareable on WhatsApp (wa.me share link with the
/// summary text) or through the system share sheet.
///
/// Notes:
/// * [DaySummary.totalSales] is the day's grand total across ALL
///   payment methods, split underneath it into [DaySummary.cashSales]
///   (cash) and [DaySummary.otherMethodSales] (JazzCash, EasyPaisa,
///   bank, card, …); the two add up to the total.
/// * There is no print/PDF flow in the app yet (owned by the Round 2
///   printing work); "Share Summary" sends the same text through the
///   system share sheet, from which the user can print or save as PDF.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_plus/share_plus.dart';

import '../../core/l10n/app_strings.dart';
import '../../core/theme/app_theme.dart';
import '../../core/theme/cyber_colors.dart';
import '../../core/theme/cyber_text_styles.dart';
import '../../core/theme/cyber_widgets.dart';
import '../../data/repositories/expense_repository.dart';
import '../../domain/money.dart';
import '../repairs/repair_common.dart';

class DayEndScreen extends ConsumerStatefulWidget {
  const DayEndScreen({super.key, required this.repository, this.date});

  final ExpenseRepository repository;

  /// Day to summarise; defaults to today.
  final DateTime? date;

  @override
  ConsumerState<DayEndScreen> createState() => _DayEndScreenState();
}

class _DayEndScreenState extends ConsumerState<DayEndScreen> {
  late DateTime _date;
  bool _loading = true;
  String? _error;
  DaySummary? _summary;

  @override
  void initState() {
    super.initState();
    final d = widget.date ?? DateTime.now();
    _date = DateTime(d.year, d.month, d.day);
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final summary = await widget.repository.daySummary(date: _date);
      if (!mounted) return;
      setState(() {
        _summary = summary;
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

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (picked == null) return;
    setState(
      () => _date = DateTime(picked.year, picked.month, picked.day),
    );
    await _load();
  }

  String _summaryText(String Function(String) tr) {
    final s = _summary;
    if (s == null) return '';
    final lines = <String>[
      '${tr('appName')} — ${tr('dayEndSummary')}',
      '${tr('date')}: ${fmtDate(s.date)}',
      '${tr('todaySales')}: ${formatPkr(s.totalSales)} '
          '(${s.salesCount} ${tr('salesCount')})',
      '${tr('cashSales')}: ${formatPkr(s.cashSales)}',
      '${tr('otherMethodSales')}: ${formatPkr(s.otherMethodSales)}',
      '${tr('serviceSalesTotal')}: ${formatPkr(s.serviceSalesTotal)}',
      '${tr('totalCommission')}: ${formatPkr(s.serviceCommission)}',
      '${tr('totalExpenses')}: ${formatPkr(s.totalExpenses)}',
      '${tr('cashIn')}: ${formatPkr(s.cashIn)}',
      '${tr('cashOut')}: ${formatPkr(s.cashOut)}',
      '${tr('openingCash')}: ${formatPkr(s.openingCash)}',
      '${tr('expectedCash')}: ${formatPkr(s.expectedCash)}',
      if (s.closingCash != null)
        '${tr('closingCash')}: ${formatPkr(s.closingCash!)}',
      if (s.difference != null)
        '${tr('difference')}: ${formatPkr(s.difference!)}',
      '${tr('registerOpen')}: ${s.registerStatus}',
    ];
    return lines.join('\n');
  }

  Future<void> _shareWhatsApp(String Function(String) tr) async {
    final ok = await openWhatsApp(message: _summaryText(tr));
    if (!mounted) return;
    if (!ok) showSnack(context, tr('whatsappNotAvailable'), isError: true);
  }

  Future<void> _shareText(String Function(String) tr) async {
    await Share.share(_summaryText(tr));
  }

  @override
  Widget build(BuildContext context) {
    final c = ref.watch(themeNotifierProvider).colors;
    final lang = ref.watch(languageProvider);
    String tr(String key) => AppStrings.tr(key, language: lang);
    final summary = _summary;

    return Scaffold(
      appBar: CyberAppBar(
        title: tr('dayEndSummary'),
        actions: [
          IconButton(
            icon: const Icon(Icons.calendar_today),
            tooltip: tr('selectDate'),
            onPressed: _pickDate,
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? _errorView(c, tr)
              : summary == null
                  ? _emptyView(c, tr)
                  : _body(c, tr, summary),
    );
  }

  Widget _errorView(CyberColors c, String Function(String) tr) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              _error ?? tr('somethingWentWrong'),
              style: CyberTextStyles.error(c),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            CyberButton(
              label: tr('tryAgain'),
              onPressed: _load,
              fullWidth: false,
            ),
          ],
        ),
      ),
    );
  }

  Widget _emptyView(CyberColors c, String Function(String) tr) {
    return Center(
      child: Text(tr('noData'), style: CyberTextStyles.bodySecondary(c)),
    );
  }

  Widget _body(CyberColors c, String Function(String) tr, DaySummary s) {
    final difference = s.difference;
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
      children: [
        CyberCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(fmtDate(s.date), style: CyberTextStyles.mono(c, size: 16)),
                  CyberBadge(
                    label: tr(s.registerStatus == 'open'
                        ? 'registerOpen'
                        : 'registerClosed'),
                    color: s.registerStatus == 'open' ? c.success : c.warning,
                  ),
                ],
              ),
              const SizedBox(height: 12),
              _row(c, tr('todaySales'), formatPkr(s.totalSales)),
              _row(c, tr('cashSales'), formatPkr(s.cashSales)),
              _row(c, tr('otherMethodSales'),
                  formatPkr(s.otherMethodSales)),
              _row(c, tr('salesCount'), '${s.salesCount}'),
              _row(c, tr('serviceSalesTotal'), formatPkr(s.serviceSalesTotal)),
              _row(c, tr('totalCommission'), formatPkr(s.serviceCommission)),
              _row(c, tr('totalExpenses'), formatPkr(s.totalExpenses)),
              const Divider(),
              _row(c, tr('cashIn'), formatPkr(s.cashIn)),
              _row(c, tr('cashOut'), formatPkr(s.cashOut)),
              _row(c, tr('openingCash'), formatPkr(s.openingCash)),
              _row(c, tr('expectedCash'), formatPkr(s.expectedCash), big: true),
              if (s.closingCash != null)
                _row(c, tr('closingCash'), formatPkr(s.closingCash!), big: true),
              if (difference != null)
                _row(
                  c,
                  tr('difference'),
                  formatPkr(difference),
                  big: true,
                  color: difference == 0
                      ? c.success
                      : difference > 0
                          ? c.warning
                          : c.error,
                ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        CyberButton(
          label: tr('shareOnWhatsApp'),
          icon: Icons.chat,
          onPressed: () => _shareWhatsApp(tr),
        ),
        const SizedBox(height: 8),
        CyberButton(
          label: tr('shareSummary'),
          icon: Icons.share,
          variant: CyberButtonVariant.ghost,
          onPressed: () => _shareText(tr),
        ),
      ],
    );
  }

  Widget _row(
    CyberColors c,
    String label,
    String value, {
    bool big = false,
    Color? color,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: big
                ? CyberTextStyles.subtitle(c, size: 15)
                : CyberTextStyles.body(c),
          ),
          Text(
            value,
            style: CyberTextStyles.mono(c, size: big ? 17 : 15).copyWith(
              color: color ?? c.textPrimary,
              fontWeight: big ? FontWeight.w700 : FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
