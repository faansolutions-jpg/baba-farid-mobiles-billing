/// Pay salary + salary history for one staff member.
///
/// The pay form defaults to the current month (`YYYY-MM`) and the
/// staff member's monthly salary. An advance deduction is subtracted
/// to show the net payable; the gross amount and the advance are both
/// stored through [ExpenseRepository.paySalary] (which also books the
/// gross amount as a `salary` expense). History below lists every
/// payment for this staff member, newest first.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/l10n/app_strings.dart';
import '../../core/theme/app_theme.dart';
import '../../core/theme/cyber_colors.dart';
import '../../core/theme/cyber_text_styles.dart';
import '../../core/theme/cyber_widgets.dart';
import '../../data/repositories/expense_repository.dart';
import '../../domain/models/staff.dart';
import '../../domain/money.dart';
import '../../features/auth/auth_state.dart';
import '../repairs/repair_common.dart';

class SalaryScreen extends ConsumerStatefulWidget {
  const SalaryScreen({
    super.key,
    required this.repository,
    required this.staff,
  });

  final ExpenseRepository repository;
  final Staff staff;

  @override
  ConsumerState<SalaryScreen> createState() => _SalaryScreenState();
}

class _SalaryScreenState extends ConsumerState<SalaryScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _monthController;
  late final TextEditingController _amountController;
  final _advanceController = TextEditingController(text: '0');
  final _noteController = TextEditingController();

  bool _loading = true;
  bool _saving = false;
  String? _error;
  List<SalaryPayment> _history = <SalaryPayment>[];

  @override
  void initState() {
    super.initState();
    _monthController = TextEditingController(text: monthKey(DateTime.now()));
    _amountController =
        TextEditingController(text: widget.staff.salary.toString());
    _load();
  }

  @override
  void dispose() {
    _monthController.dispose();
    _amountController.dispose();
    _advanceController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  int get _gross => parsePkr(_amountController.text) ?? 0;

  int get _advance => parsePkr(_advanceController.text) ?? 0;

  int get _net {
    final value = _gross - _advance;
    return value < 0 ? 0 : value;
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final history = await widget.repository.listSalaryPayments(
        staffId: widget.staff.id,
      );
      if (!mounted) return;
      setState(() {
        _history = history;
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

  Future<void> _pay(String Function(String) tr) async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    if (_advance > _gross) {
      showSnack(context, tr('invalidAmount'), isError: true);
      return;
    }
    setState(() => _saving = true);
    try {
      final now = DateTime.now();
      await widget.repository.paySalary(
        SalaryPayment(
          id: '',
          staffId: widget.staff.id,
          month: _monthController.text.trim(),
          amount: _gross,
          advance: _advance,
          paidDate: now,
          userId: ref.read(authStateProvider).user?.id ?? 'local-user',
          notes: _noteController.text.trim().isEmpty
              ? null
              : _noteController.text.trim(),
          createdAt: now,
        ),
        userId: ref.read(authStateProvider).user?.id,
      );
      if (!mounted) return;
      _noteController.clear();
      _advanceController.text = '0';
      setState(() => _saving = false);
      showSnack(context, tr('salaryPaid'));
      await _load();
    } catch (e) {
      if (!mounted) return;
      setState(() => _saving = false);
      showSnack(context, e.toString(), isError: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = ref.watch(themeNotifierProvider).colors;
    final lang = ref.watch(languageProvider);
    String tr(String key) => AppStrings.tr(key, language: lang);
    final staff = widget.staff;

    return Scaffold(
      appBar: CyberAppBar(title: tr('paySalary')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? _errorView(c, tr)
              : _body(c, tr, staff),
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

  Widget _body(CyberColors c, String Function(String) tr, Staff staff) {
    return Form(
      key: _formKey,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
        children: [
          CyberCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(staff.name, style: CyberTextStyles.subtitle(c, size: 17)),
                if ((staff.phone ?? '').isNotEmpty)
                  Text(staff.phone!, style: CyberTextStyles.mono(c, size: 13)),
                Text(staff.role ?? '', style: CyberTextStyles.bodySecondary(c)),
                const SizedBox(height: 8),
                Text(
                  '${tr('monthlySalary')}: ${formatPkr(staff.salary)}',
                  style: CyberTextStyles.mono(c, size: 15)
                      .copyWith(color: c.primary),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          CyberTextField(
            controller: _monthController,
            label: tr('salaryMonth'),
            hint: tr('monthHint'),
            monospace: true,
            prefixIcon: Icons.calendar_month,
            validator: (v) => isValidMonthKey(v ?? '')
                ? null
                : tr('invalidMonth'),
          ),
          const SizedBox(height: 12),
          CyberTextField(
            controller: _amountController,
            label: tr('grossAmount'),
            keyboardType: TextInputType.number,
            monospace: true,
            prefixIcon: Icons.payments,
            validator: (v) {
              final amount = parsePkr(v ?? '');
              if (amount == null || amount < 0) return tr('invalidAmount');
              return null;
            },
            onChanged: (_) => setState(() {}),
          ),
          const SizedBox(height: 12),
          CyberTextField(
            controller: _advanceController,
            label: tr('advanceDeduction'),
            keyboardType: TextInputType.number,
            monospace: true,
            prefixIcon: Icons.remove_circle_outline,
            validator: (v) {
              final amount = parsePkr(v ?? '');
              if (amount == null || amount < 0) return tr('invalidAmount');
              return null;
            },
            onChanged: (_) => setState(() {}),
          ),
          const SizedBox(height: 12),
          CyberTextField(
            controller: _noteController,
            label: tr('note'),
            prefixIcon: Icons.note_alt_outlined,
          ),
          const SizedBox(height: 12),
          CyberCard(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(tr('netPayable'), style: CyberTextStyles.body(c)),
                Text(
                  formatPkr(_net),
                  style: CyberTextStyles.amount(c, size: 20),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          CyberButton(
            label: tr('paySalary'),
            icon: Icons.payments,
            isLoading: _saving,
            onPressed: _saving ? null : () => _pay(tr),
          ),
          const SizedBox(height: 24),
          Text(tr('salaryHistory'),
              style: CyberTextStyles.label(c, size: 13)),
          const SizedBox(height: 8),
          if (_history.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: Text(
                tr('noSalaryHistory'),
                style: CyberTextStyles.bodySecondary(c),
                textAlign: TextAlign.center,
              ),
            ),
          ..._history.map(
            (payment) => CyberCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        payment.month,
                        style: CyberTextStyles.mono(c, size: 15),
                      ),
                      Text(
                        formatPkr(payment.amount),
                        style: CyberTextStyles.mono(c, size: 15),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '${tr('advanceDeduction')}: ${formatPkr(payment.advance)}',
                        style: CyberTextStyles.bodySecondary(c),
                      ),
                      Text(
                        '${tr('paidDate')}: ${fmtDate(payment.paidDate)}',
                        style: CyberTextStyles.caption(c),
                      ),
                    ],
                  ),
                  if ((payment.notes ?? '').isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text(
                        payment.notes!,
                        style: CyberTextStyles.bodySecondary(c),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
