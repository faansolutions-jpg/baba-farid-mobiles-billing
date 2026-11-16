/// Cash register — route `/cash`.
///
/// Today's register: opening cash (set once at day start), cash-in /
/// cash-out entries, expected cash (from [DaySummary]), counted cash
/// and the difference on close. Closing uses
/// [ExpenseRepository.closeRegister]; the day-end summary lives on
/// [DayEndScreen].
///
/// Expected cash comes from the repository's day summary
/// (opening + cash-in − cash-out − expenses). Sale takings reach the
/// register as cash movements written by the sale flow, so they are
/// not added again here.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/l10n/app_strings.dart';
import '../../core/theme/app_theme.dart';
import '../../core/theme/cyber_colors.dart';
import '../../core/theme/cyber_text_styles.dart';
import '../../core/theme/cyber_widgets.dart';
import '../../data/repositories/expense_repository.dart';
import '../../domain/models/cash_register.dart';
import '../../domain/money.dart';
import '../../features/auth/auth_state.dart';
import '../repairs/repair_common.dart';
import 'day_end_screen.dart';

class CashRegisterScreen extends ConsumerStatefulWidget {
  const CashRegisterScreen({super.key, required this.repository});

  final ExpenseRepository repository;

  @override
  ConsumerState<CashRegisterScreen> createState() =>
      _CashRegisterScreenState();
}

class _CashRegisterScreenState extends ConsumerState<CashRegisterScreen> {
  final _openingController = TextEditingController();
  final _countedController = TextEditingController();

  bool _loading = true;
  bool _busy = false;
  String? _error;
  CashRegister? _register;
  DaySummary? _summary;
  List<CashMovement> _movements = <CashMovement>[];

  @override
  void dispose() {
    _openingController.dispose();
    _countedController.dispose();
    super.dispose();
  }

  String _userId() => ref.read(authStateProvider).user?.id ?? 'local-user';

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
      final register = await widget.repository.getOpenRegister();
      final summary = await widget.repository.daySummary();
      final movements = register == null
          ? <CashMovement>[]
          : await widget.repository.listCashMovements(register.id);
      if (!mounted) return;
      setState(() {
        _register = register;
        _summary = summary;
        _movements = movements;
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

  Future<void> _openRegister(String Function(String) tr) async {
    final opening = parsePkr(_openingController.text);
    if (opening == null || opening < 0) {
      showSnack(context, tr('invalidAmount'), isError: true);
      return;
    }
    setState(() => _busy = true);
    try {
      await widget.repository.openRegister(
        openingCash: opening,
        openedBy: _userId(),
      );
      if (!mounted) return;
      showSnack(context, tr('registerOpened'));
      await _load();
    } catch (e) {
      if (!mounted) return;
      showSnack(context, e.toString(), isError: true);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _addMovement(
    String type,
    String Function(String) tr,
  ) async {
    final register = _register;
    if (register == null) return;
    final amountController = TextEditingController();
    final reasonController = TextEditingController();
    final formKey = GlobalKey<FormState>();
    final saved = await showDialog<bool>(
      context: context,
      builder: (context) => CyberDialog(
        title: tr(type == 'in' ? 'addCashIn' : 'addCashOut'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(tr('cancel')),
          ),
          CyberButton(
            label: tr('save'),
            fullWidth: false,
            onPressed: () {
              if (formKey.currentState?.validate() ?? false) {
                Navigator.of(context).pop(true);
              }
            },
          ),
        ],
        child: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CyberTextField(
                controller: amountController,
                label: tr('amount'),
                keyboardType: TextInputType.number,
                monospace: true,
                autofocus: true,
                validator: (v) {
                  final amount = parsePkr(v ?? '');
                  if (amount == null || amount <= 0) {
                    return tr('invalidAmount');
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),
              CyberTextField(
                controller: reasonController,
                label: tr('reason'),
              ),
            ],
          ),
        ),
      ),
    );
    final amount = parsePkr(amountController.text) ?? 0;
    final reason = reasonController.text.trim();
    amountController.dispose();
    reasonController.dispose();
    if (saved != true || amount <= 0) return;
    setState(() => _busy = true);
    try {
      await widget.repository.recordCashMovement(
        registerId: register.id,
        type: type,
        amount: amount,
        reason: reason.isEmpty ? null : reason,
        userId: _userId(),
      );
      if (!mounted) return;
      showSnack(context, tr('saved'));
      await _load();
    } catch (e) {
      if (!mounted) return;
      showSnack(context, e.toString(), isError: true);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _closeRegister(String Function(String) tr) async {
    final register = _register;
    if (register == null) return;
    final counted = parsePkr(_countedController.text);
    if (counted == null || counted < 0) {
      showSnack(context, tr('invalidAmount'), isError: true);
      return;
    }
    final confirmed = await showCyberDialog(
      context,
      title: tr('closeRegister'),
      message: tr('closeRegisterConfirm'),
      confirmLabel: tr('confirm'),
      cancelLabel: tr('cancel'),
    );
    if (!confirmed) return;
    setState(() => _busy = true);
    try {
      await widget.repository.closeRegister(
        registerId: register.id,
        closingCash: counted,
        closedBy: _userId(),
      );
      if (!mounted) return;
      showSnack(context, tr('registerClosedMsg'));
      await Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (_) => DayEndScreen(repository: widget.repository),
        ),
      );
      if (mounted) _load();
    } catch (e) {
      if (!mounted) return;
      showSnack(context, e.toString(), isError: true);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  void _openDayEnd() {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => DayEndScreen(repository: widget.repository),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final c = ref.watch(themeNotifierProvider).colors;
    final lang = ref.watch(languageProvider);
    String tr(String key) => AppStrings.tr(key, language: lang);

    return Scaffold(
      appBar: CyberAppBar(
        title: tr('cashRegister'),
        actions: [
          IconButton(
            icon: const Icon(Icons.summarize_outlined),
            tooltip: tr('dayEndSummary'),
            onPressed: _openDayEnd,
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? _errorView(c, tr)
              : _register == null
                  ? _openForm(c, tr)
                  : _registerView(c, tr),
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

  Widget _openForm(CyberColors c, String Function(String) tr) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 24),
      children: [
        CyberCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(tr('noRegisterOpen'),
                  style: CyberTextStyles.bodySecondary(c)),
              const SizedBox(height: 16),
              CyberTextField(
                controller: _openingController,
                label: tr('openingCash'),
                keyboardType: TextInputType.number,
                monospace: true,
                prefixIcon: Icons.account_balance_wallet,
                autofocus: true,
              ),
              const SizedBox(height: 16),
              CyberButton(
                label: tr('openRegister'),
                icon: Icons.lock_open,
                isLoading: _busy,
                onPressed: _busy ? null : () => _openRegister(tr),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        CyberButton(
          label: tr('dayEndSummary'),
          variant: CyberButtonVariant.ghost,
          onPressed: _openDayEnd,
        ),
      ],
    );
  }

  Widget _registerView(CyberColors c, String Function(String) tr) {
    final register = _register!;
    final summary = _summary;
    final expected = summary?.expectedCash ?? register.openingCash;

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
      children: [
        Row(
          children: [
            Expanded(
              child: CyberStatCard(
                label: tr('openingCash'),
                value: register.openingCash,
                prefix: 'Rs ',
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: CyberStatCard(
                label: tr('expectedCash'),
                value: expected,
                prefix: 'Rs ',
              ),
            ),
          ],
        ),
        Row(
          children: [
            Expanded(
              child: CyberStatCard(
                label: tr('cashIn'),
                value: summary?.cashIn ?? 0,
                prefix: 'Rs ',
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: CyberStatCard(
                label: tr('cashOut'),
                value: summary?.cashOut ?? 0,
                prefix: 'Rs ',
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: CyberButton(
                label: tr('addCashIn'),
                icon: Icons.add_circle_outline,
                variant: CyberButtonVariant.ghost,
                isLoading: _busy,
                onPressed: _busy ? null : () => _addMovement('in', tr),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: CyberButton(
                label: tr('addCashOut'),
                icon: Icons.remove_circle_outline,
                variant: CyberButtonVariant.ghost,
                isLoading: _busy,
                onPressed: _busy ? null : () => _addMovement('out', tr),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Text(tr('movements'), style: CyberTextStyles.label(c, size: 13)),
        const SizedBox(height: 8),
        if (_movements.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Text(
              tr('noData'),
              style: CyberTextStyles.bodySecondary(c),
              textAlign: TextAlign.center,
            ),
          ),
        ..._movements.map(
          (movement) => CyberCard(
            child: Row(
              children: [
                Icon(
                  movement.type == 'in'
                      ? Icons.arrow_downward
                      : Icons.arrow_upward,
                  color: movement.type == 'in' ? c.success : c.error,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        movement.reason ?? tr(movement.type == 'in'
                            ? 'cashIn'
                            : 'cashOut'),
                        style: CyberTextStyles.body(c, size: 14),
                      ),
                      Text(
                        fmtDateTime(movement.createdAt),
                        style: CyberTextStyles.caption(c),
                      ),
                    ],
                  ),
                ),
                Text(
                  '${movement.type == 'in' ? '+' : '-'}'
                  '${formatPkr(movement.amount)}',
                  style: CyberTextStyles.mono(c, size: 15).copyWith(
                    color: movement.type == 'in' ? c.success : c.error,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        CyberTextField(
          controller: _countedController,
          label: tr('countedCash'),
          keyboardType: TextInputType.number,
          monospace: true,
          prefixIcon: Icons.calculate,
        ),
        const SizedBox(height: 12),
        CyberButton(
          label: tr('closeRegister'),
          icon: Icons.lock,
          isLoading: _busy,
          onPressed: _busy ? null : () => _closeRegister(tr),
        ),
        const SizedBox(height: 8),
        CyberButton(
          label: tr('dayEndSummary'),
          variant: CyberButtonVariant.ghost,
          onPressed: _openDayEnd,
        ),
      ],
    );
  }
}
