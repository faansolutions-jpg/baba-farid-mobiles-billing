/// Installment plans — route `/customers/:id/installments`.
///
/// Lists the customer's plans with per-row status (paid / pending /
/// overdue) and lets the shopkeeper record an installment payment.
/// Creating a plan: pick one of the customer's sales (a plan is always
/// attached to a sale — `installments.sale_id` is NOT NULL), enter the
/// total, down payment, number of installments and first due date; the
/// schedule is previewed live with the same `installmentSchedule` rule
/// the repository uses, so the preview matches what gets saved.
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
import '../../data/repositories/sale_repository.dart';
import '../../domain/models/installment.dart';
import '../../domain/models/sale.dart';
import '../../domain/money.dart';
import '../../domain/rules.dart';
import '../auth/auth_state.dart';
import 'customer_helpers.dart';

class InstallmentPlanScreen extends ConsumerStatefulWidget {
  const InstallmentPlanScreen({
    super.key,
    required this.repository,
    required this.customerId,
    this.saleRepository,
    this.initialPlanId,
  });

  static const String routeName = '/customers/:id/installments';

  final CustomerRepository repository;
  final String customerId;

  /// Needed to pick the sale a new plan attaches to. When null, plan
  /// creation is disabled with an explanation (no sale = no plan).
  final SaleRepository? saleRepository;

  /// When set, this plan starts expanded.
  final String? initialPlanId;

  @override
  ConsumerState<InstallmentPlanScreen> createState() =>
      _InstallmentPlanScreenState();
}

class _InstallmentPlanScreenState extends ConsumerState<InstallmentPlanScreen> {
  List<Installment> _plans = [];
  List<Sale> _sales = [];
  bool _loading = true;
  String? _error;
  bool _showForm = false;
  bool _saving = false;

  Sale? _selectedSale;
  final _totalController = TextEditingController();
  final _downController = TextEditingController(text: '0');
  final _countController = TextEditingController(text: '3');
  DateTime _firstDue = DateTime.now().add(const Duration(days: 30));

  String get _lang => ref.read(languageProvider);

  String _t(String key) => AppStrings.tr(key, language: _lang);

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _totalController.dispose();
    _downController.dispose();
    _countController.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final plans =
          await widget.repository.listInstallments(widget.customerId);
      final sales = widget.saleRepository == null
          ? <Sale>[]
          : await widget.saleRepository!
              .listSales(customerId: widget.customerId);
      if (!mounted) return;
      setState(() {
        _plans = plans;
        _sales = sales;
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

  String _userId() => ref.read(authStateProvider).user?.id ?? 'system';

  void _pickSale(Sale? sale) {
    setState(() {
      _selectedSale = sale;
      if (sale != null) {
        final due = sale.balanceDue > 0 ? sale.balanceDue : sale.grandTotal;
        _totalController.text = due.toString();
      }
    });
  }

  List<InstallmentRow> _preview() {
    final total = int.tryParse(_totalController.text.trim()) ?? 0;
    final down = int.tryParse(_downController.text.trim()) ?? 0;
    final count = int.tryParse(_countController.text.trim()) ?? 0;
    try {
      return installmentSchedule(total, down, count, _firstDue);
    } catch (_) {
      return const [];
    }
  }

  Future<void> _pickFirstDue() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _firstDue,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365 * 3)),
    );
    if (picked != null) setState(() => _firstDue = picked);
  }

  Future<void> _createPlan() async {
    final sale = _selectedSale;
    final total = int.tryParse(_totalController.text.trim()) ?? 0;
    final down = int.tryParse(_downController.text.trim()) ?? 0;
    final count = int.tryParse(_countController.text.trim()) ?? 0;
    if (sale == null || total <= 0 || count <= 0 || down < 0 || down > total) {
      showSnack(context, _t('fieldRequired'), isError: true);
      return;
    }
    setState(() => _saving = true);
    try {
      await widget.repository.createInstallment(
        saleId: sale.id,
        customerId: widget.customerId,
        totalAmount: total,
        downPayment: down,
        count: count,
        startDate: _firstDue,
        userId: _userId(),
      );
      if (!mounted) return;
      showSnack(context, _t('saved'));
      setState(() {
        _showForm = false;
        _selectedSale = null;
        _totalController.clear();
        _downController.text = '0';
        _countController.text = '3';
      });
      _load();
    } catch (e) {
      if (!mounted) return;
      showSnack(context, e.toString(), isError: true);
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _payRow(InstallmentPayment row) async {
    final input = await showPaymentDialog(
      context,
      title: _t('payInstallment'),
      maxAmount: row.remaining,
      defaultAmount: row.remaining,
      language: _lang,
    );
    if (input == null) return;
    try {
      await widget.repository.recordInstallmentPayment(
        installmentPaymentId: row.id,
        amount: input.amount,
        method: input.method,
        userId: _userId(),
      );
      if (!mounted) return;
      showSnack(context, _t('paymentRecorded'));
      _load();
    } catch (e) {
      if (!mounted) return;
      showSnack(context, e.toString(), isError: true);
    }
  }

  String _rowStatus(InstallmentPayment row) {
    if (row.status == 'paid') return _t('paid');
    if (row.status == 'partial') return _t('partial');
    if (isOverdue(row.dueDate)) return _t('overdue');
    return _t('upcoming');
  }

  Color _rowStatusColor(CyberColors c, InstallmentPayment row) {
    final status = _rowStatus(row);
    if (status == _t('paid')) return c.success;
    if (status == _t('overdue')) return c.error;
    return c.warning;
  }

  @override
  Widget build(BuildContext context) {
    final c = ref.watch(themeNotifierProvider).colors;
    return Scaffold(
      appBar: CyberAppBar(
        title: _t('installmentPlans'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: _t('refresh'),
            onPressed: _load,
          ),
        ],
      ),
      body: _loading
          ? cyberLoading(c, _t('splashLoading'))
          : _error != null
              ? cyberError(c, _error!, _load, _t('tryAgain'))
              : _buildBody(c),
    );
  }

  Widget _buildBody(CyberColors c) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppConstants.paddingMedium),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          CyberButton(
            label: _showForm ? _t('cancel') : _t('newInstallmentPlan'),
            variant:
                _showForm ? CyberButtonVariant.ghost : CyberButtonVariant.primary,
            icon: _showForm ? Icons.close : Icons.add,
            onPressed: () => setState(() => _showForm = !_showForm),
          ),
          if (_showForm) ...[
            const SizedBox(height: 12),
            _createForm(c),
          ],
          const SizedBox(height: 16),
          if (_plans.isEmpty)
            cyberEmpty(c, _t('noInstallments'), icon: Icons.calendar_month)
          else
            ..._plans.map((plan) => _planCard(c, plan)),
        ],
      ),
    );
  }

  Widget _createForm(CyberColors c) {
    if (widget.saleRepository == null || _sales.isEmpty) {
      return CyberCard(
        child: Text(_t('noSaleForPlan'),
            style: CyberTextStyles.bodySecondary(c)),
      );
    }
    final preview = _preview();
    return CyberCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          DropdownButtonFormField<Sale>(
            initialValue: _selectedSale,
            isExpanded: true,
            decoration: InputDecoration(labelText: _t('selectSale')),
            items: _sales.map((sale) {
              return DropdownMenuItem<Sale>(
                value: sale,
                child: Text(
                  '${sale.invoiceNo} · ${formatPkr(sale.grandTotal)} · ${fmtDate(sale.saleDate)}',
                  style: CyberTextStyles.body(c, size: 14),
                  overflow: TextOverflow.ellipsis,
                ),
              );
            }).toList(),
            onChanged: _pickSale,
          ),
          const SizedBox(height: 12),
          CyberTextField(
            controller: _totalController,
            label: _t('totalAmount'),
            monospace: true,
            keyboardType: TextInputType.number,
            onChanged: (_) => setState(() {}),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: CyberTextField(
                  controller: _downController,
                  label: _t('downPayment'),
                  monospace: true,
                  keyboardType: TextInputType.number,
                  onChanged: (_) => setState(() {}),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: CyberTextField(
                  controller: _countController,
                  label: _t('installmentCount'),
                  monospace: true,
                  keyboardType: TextInputType.number,
                  onChanged: (_) => setState(() {}),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ListTile(
            contentPadding: EdgeInsets.zero,
            title: Text(_t('firstDueDate'),
                style: CyberTextStyles.body(c, size: 14)),
            subtitle: Text(fmtDate(_firstDue),
                style: CyberTextStyles.mono(c, size: 14)),
            trailing: Icon(Icons.calendar_today, color: c.primary),
            onTap: _pickFirstDue,
          ),
          if (preview.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(_t('schedulePreview'),
                style: CyberTextStyles.label(c)),
            const SizedBox(height: 4),
            ...preview.asMap().entries.map((entry) {
              final row = entry.value;
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 2),
                child: Row(
                  children: [
                    Text('${entry.key + 1}.',
                        style: CyberTextStyles.mono(c, size: 13)),
                    const SizedBox(width: 8),
                    Text(fmtDate(row['dueDate'] as DateTime),
                        style: CyberTextStyles.mono(c, size: 13)),
                    const Spacer(),
                    moneyText(c, row['amount'] as int, size: 14),
                  ],
                ),
              );
            }),
          ],
          const SizedBox(height: 16),
          CyberButton(
            label: _t('save'),
            icon: Icons.save,
            isLoading: _saving,
            onPressed: _saving ? null : _createPlan,
          ),
        ],
      ),
    );
  }

  Widget _planCard(CyberColors c, Installment plan) {
    final initiallyOpen = widget.initialPlanId == plan.id;
    final planBadge = plan.status == 'completed'
        ? _t('paid')
        : plan.payments.any((p) => _rowStatus(p) == _t('overdue'))
            ? _t('overdue')
            : _t('upcoming');
    final badgeColor = planBadge == _t('paid')
        ? c.success
        : planBadge == _t('overdue')
            ? c.error
            : c.warning;
    return CyberCard(
      child: ExpansionTile(
        initiallyExpanded: initiallyOpen,
        tilePadding: EdgeInsets.zero,
        title: Text(
          '${_t('installment')} · ${formatPkr(plan.totalAmount)}',
          style: CyberTextStyles.subtitle(c),
        ),
        subtitle: Text(
          '${_t('remainingAmount')}: ${formatPkr(plan.remainingAmount)}'
          ' · ${_t('downPayment')}: ${formatPkr(plan.downPayment)}',
          style: CyberTextStyles.mono(c, size: 13)
              .copyWith(color: c.textSecondary),
        ),
        trailing: CyberBadge(label: planBadge, color: badgeColor),
        children: plan.payments.map((row) => _paymentRow(c, row)).toList(),
      ),
    );
  }

  Widget _paymentRow(CyberColors c, InstallmentPayment row) {
    final status = _rowStatus(row);
    final daysLate = isOverdue(row.dueDate)
        ? DateTime.now().difference(DateTime(
              row.dueDate.year,
              row.dueDate.month,
              row.dueDate.day,
            )).inDays
        : 0;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(fmtDate(row.dueDate),
                    style: CyberTextStyles.mono(c, size: 14)),
                Text(
                  '${formatPkr(row.amount)}'
                  '${row.paidAmount > 0 ? ' · ${_t('paid')} ${formatPkr(row.paidAmount)}' : ''}'
                  '${daysLate > 0 && row.status != 'paid' ? ' · $daysLate ${_t('daysOverdue').toLowerCase()}' : ''}',
                  style: CyberTextStyles.bodySecondary(c, size: 13),
                ),
              ],
            ),
          ),
          CyberBadge(label: status, color: _rowStatusColor(c, row)),
          const SizedBox(width: 8),
          if (row.remaining > 0)
            SizedBox(
              height: AppConstants.minTouchTarget,
              child: OutlinedButton(
                onPressed: () => _payRow(row),
                child: Text(_t('pay')),
              ),
            ),
        ],
      ),
    );
  }
}
