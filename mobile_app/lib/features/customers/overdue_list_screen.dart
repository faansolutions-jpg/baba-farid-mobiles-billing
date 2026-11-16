/// Overdue installments — route `/customers/overdue`.
///
/// All overdue installment rows across customers (newest-due first),
/// with the customer name/phone, due date, remaining amount, days
/// overdue and a WhatsApp reminder button per row. Tap a row to open
/// the customer's detail screen.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/config/constants.dart';
import '../../core/l10n/app_strings.dart';
import '../../core/theme/app_theme.dart';
import '../../core/theme/cyber_colors.dart';
import '../../core/theme/cyber_text_styles.dart';
import '../../core/theme/cyber_widgets.dart';
import '../../data/repositories/customer_repository.dart';
import '../../domain/models/customer.dart';
import '../../domain/models/installment.dart';
import 'customer_detail_screen.dart';
import 'customer_helpers.dart';

class _OverdueRow {
  const _OverdueRow({
    required this.payment,
    required this.customer,
  });

  final InstallmentPayment payment;
  final Customer customer;

  int get daysOverdue {
    final today = DateTime.now();
    final due = DateTime(
      payment.dueDate.year,
      payment.dueDate.month,
      payment.dueDate.day,
    );
    final now = DateTime(today.year, today.month, today.day);
    return now.difference(due).inDays;
  }
}

class OverdueListScreen extends ConsumerStatefulWidget {
  const OverdueListScreen({super.key, required this.repository});

  static const String routeName = '/customers/overdue';

  final CustomerRepository repository;

  @override
  ConsumerState<OverdueListScreen> createState() => _OverdueListScreenState();
}

class _OverdueListScreenState extends ConsumerState<OverdueListScreen> {
  List<_OverdueRow> _rows = [];
  bool _loading = true;
  String? _error;

  String get _lang => ref.read(languageProvider);

  String _t(String key) => AppStrings.tr(key, language: _lang);

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final overdue = await widget.repository.overdueInstallments();
      final customerCache = <String, Customer?>{};
      final rows = <_OverdueRow>[];
      for (final payment in overdue) {
        final plan =
            await widget.repository.getInstallment(payment.installmentId);
        if (plan == null) continue;
        Customer? customer;
        if (customerCache.containsKey(plan.customerId)) {
          customer = customerCache[plan.customerId];
        } else {
          customer = await widget.repository.getCustomer(plan.customerId);
          customerCache[plan.customerId] = customer;
        }
        if (customer == null) continue;
        rows.add(_OverdueRow(payment: payment, customer: customer));
      }
      if (!mounted) return;
      setState(() {
        _rows = rows;
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

  void _openCustomer(_OverdueRow row) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => CustomerDetailScreen(
          repository: widget.repository,
          customerId: row.customer.id,
        ),
      ),
    ).then((_) => _load());
  }

  void _remind(_OverdueRow row) {
    openWhatsApp(
      context,
      row.customer.phone,
      installmentReminderText(
        row.customer.name,
        row.payment.remaining,
        row.payment.dueDate,
        row.daysOverdue,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final c = ref.watch(themeNotifierProvider).colors;
    return Scaffold(
      appBar: CyberAppBar(
        title: _t('overdueInstallments'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: _t('refresh'),
            onPressed: _load,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(AppConstants.paddingMedium),
        child: _loading
            ? cyberLoading(c, _t('splashLoading'))
            : _error != null
                ? cyberError(c, _error!, _load, _t('tryAgain'))
                : _rows.isEmpty
                    ? cyberEmpty(c, _t('noOverdue'),
                        icon: Icons.check_circle_outline)
                    : RefreshIndicator(
                        onRefresh: _load,
                        color: c.primary,
                        child: ListView.builder(
                          itemCount: _rows.length,
                          itemBuilder: (context, index) =>
                              _rowCard(c, _rows[index]),
                        ),
                      ),
      ),
    );
  }

  Widget _rowCard(CyberColors c, _OverdueRow row) {
    return CyberCard(
      onTap: () => _openCustomer(row),
      borderColor: c.error,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  row.customer.name,
                  style: CyberTextStyles.subtitle(c),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              CyberBadge(
                label:
                    '${row.daysOverdue} ${_t('daysOverdue').toLowerCase()}',
                color: c.error,
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            row.customer.phone,
            style: CyberTextStyles.mono(c, size: 13)
                .copyWith(color: c.textSecondary),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(_t('dueDate'),
                        style: CyberTextStyles.caption(c, size: 11)),
                    Text(fmtDate(row.payment.dueDate),
                        style: CyberTextStyles.mono(c, size: 14)),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(_t('remainingAmount'),
                        style: CyberTextStyles.caption(c, size: 11)),
                    moneyText(c, row.payment.remaining,
                        size: 16, color: c.error),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          SizedBox(
            height: AppConstants.minTouchTarget,
            child: OutlinedButton.icon(
              onPressed: () => _remind(row),
              icon: const Icon(Icons.message, size: 20),
              label: Text(_t('whatsappReminder')),
              style: OutlinedButton.styleFrom(
                foregroundColor: c.primary,
                side: BorderSide(color: c.primary, width: 1.5),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
