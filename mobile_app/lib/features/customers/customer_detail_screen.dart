/// Customer detail — route `/customers/:id`.
///
/// Profile, running udhaar balance, full ledger (date, description,
/// debit/credit, running balance), installment plans summary, record an
/// udhaar payment (reduces the balance) and a WhatsApp reminder button
/// (wa.me link with a polite Urdu/English reminder + balance).
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/config/constants.dart';
import '../../core/l10n/app_strings.dart';
import '../../core/theme/app_theme.dart';
import '../../core/theme/cyber_colors.dart';
import '../../core/theme/cyber_text_styles.dart';
import '../../core/theme/cyber_widgets.dart';
import '../../data/repositories/customer_repository.dart';
import '../../data/repositories/sale_repository.dart';
import '../../domain/models/customer.dart';
import '../../domain/models/installment.dart';
import '../../domain/models/ledger_entry.dart';
import '../../domain/money.dart';
import '../auth/auth_state.dart';
import 'customer_form_screen.dart';
import 'customer_helpers.dart';
import 'installment_plan_screen.dart';

class CustomerDetailScreen extends ConsumerStatefulWidget {
  const CustomerDetailScreen({
    super.key,
    required this.repository,
    required this.customerId,
    this.saleRepository,
  });

  static const String routeName = '/customers/:id';

  final CustomerRepository repository;
  final String customerId;

  /// Passed through to the installment plan screen so a plan can be
  /// attached to one of the customer's sales (required by the schema).
  final SaleRepository? saleRepository;

  @override
  ConsumerState<CustomerDetailScreen> createState() =>
      _CustomerDetailScreenState();
}

class _CustomerDetailScreenState extends ConsumerState<CustomerDetailScreen> {
  Customer? _customer;
  int _balance = 0;
  List<LedgerEntry> _ledger = [];
  List<Installment> _plans = [];
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
      final customer = await widget.repository.getCustomer(widget.customerId);
      if (customer == null) {
        throw Exception(_t('customerNotFound'));
      }
      final balance =
          await widget.repository.runningBalance(widget.customerId);
      final ledger = await widget.repository.ledger(widget.customerId);
      final plans =
          await widget.repository.listInstallments(widget.customerId);
      if (!mounted) return;
      setState(() {
        _customer = customer;
        _balance = balance;
        _ledger = ledger;
        _plans = plans;
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

  Future<void> _recordPayment() async {
    final customer = _customer;
    if (customer == null) return;
    final input = await showPaymentDialog(
      context,
      title: _t('recordPayment'),
      defaultAmount: _balance > 0 ? _balance : null,
      language: _lang,
    );
    if (input == null) return;
    try {
      await widget.repository.recordUdhaarPayment(
        customerId: customer.id,
        amount: input.amount,
        method: input.method,
        userId: _userId(),
        notes: input.note,
      );
      if (!mounted) return;
      showSnack(context, _t('paymentRecorded'));
      _load();
    } catch (e) {
      if (!mounted) return;
      showSnack(context, e.toString(), isError: true);
    }
  }

  void _sendReminder() {
    final customer = _customer;
    if (customer == null) return;
    openWhatsApp(
      context,
      customer.phone,
      udhaarReminderText(customer.name, _balance),
    );
  }

  Future<void> _openEdit() async {
    final customer = _customer;
    if (customer == null) return;
    final saved = await Navigator.of(context).push<bool>(
      MaterialPageRoute<bool>(
        builder: (_) => CustomerFormScreen(
          repository: widget.repository,
          customer: customer,
        ),
      ),
    );
    if (saved == true) _load();
  }

  void _openPlans({String? initialPlanId}) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => InstallmentPlanScreen(
          repository: widget.repository,
          customerId: widget.customerId,
          saleRepository: widget.saleRepository,
          initialPlanId: initialPlanId,
        ),
      ),
    ).then((_) => _load());
  }

  Future<void> _callCustomer() async {
    final customer = _customer;
    if (customer == null) return;
    final uri = Uri.parse('tel:${customer.phone}');
    await launchUrl(uri);
  }

  String _planStatus(Installment plan) {
    if (plan.status == 'completed') return _t('paid');
    if (plan.payments.any(
      (p) => p.status == 'overdue',
    )) {
      return _t('overdue');
    }
    return _t('upcoming');
  }

  @override
  Widget build(BuildContext context) {
    final c = ref.watch(themeNotifierProvider).colors;
    return Scaffold(
      appBar: CyberAppBar(
        title: _t('customerDetails'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            tooltip: _t('editCustomer'),
            onPressed: _customer == null ? null : _openEdit,
          ),
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
              : _buildDetail(c),
    );
  }

  Widget _buildDetail(CyberColors c) {
    final customer = _customer!;
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppConstants.paddingMedium),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _profileCard(c, customer),
          const SizedBox(height: 12),
          _balanceCard(c),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: CyberButton(
                  label: _t('recordPayment'),
                  icon: Icons.payments,
                  onPressed: _recordPayment,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: CyberButton(
                  label: _t('whatsappReminder'),
                  variant: CyberButtonVariant.ghost,
                  icon: Icons.message,
                  onPressed: _sendReminder,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          _sectionTitle(c, _t('installmentPlans')),
          if (_plans.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Text(_t('noInstallments'),
                  style: CyberTextStyles.bodySecondary(c)),
            )
          else
            ..._plans.map((plan) => _planCard(c, plan)),
          CyberButton(
            label: _t('newInstallmentPlan'),
            variant: CyberButtonVariant.ghost,
            icon: Icons.add,
            onPressed: () => _openPlans(),
          ),
          const SizedBox(height: 20),
          _sectionTitle(c, _t('ledger')),
          if (_ledger.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Text(_t('ledgerEmpty'),
                  style: CyberTextStyles.bodySecondary(c)),
            )
          else
            CyberTable(
              headers: [
                _t('date'),
                _t('description'),
                _t('debit'),
                _t('credit'),
                _t('balance'),
              ],
              rows: _ledger.map((entry) {
                return [
                  fmtDate(entry.entryDate),
                  entry.notes?.isNotEmpty == true
                      ? entry.notes!
                      : entry.referenceType,
                  entry.debit == 0 ? '-' : formatPkr(entry.debit),
                  entry.credit == 0 ? '-' : formatPkr(entry.credit),
                  formatPkr(entry.balanceAfter),
                ];
              }).toList(),
              monospaceColumns: const {0, 2, 3, 4},
            ),
        ],
      ),
    );
  }

  Widget _sectionTitle(CyberColors c, String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(title, style: CyberTextStyles.title(c, size: 17)),
    );
  }

  Widget _profileCard(CyberColors c, Customer customer) {
    return CyberCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 26,
                backgroundColor: c.primary.withValues(alpha: 0.15),
                child: Text(
                  customer.name.isEmpty
                      ? '?'
                      : customer.name[0].toUpperCase(),
                  style: CyberTextStyles.title(c, size: 22)
                      .copyWith(color: c.primary),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(customer.name, style: CyberTextStyles.title(c)),
                    Text(customer.phone,
                        style: CyberTextStyles.mono(c, size: 14)
                            .copyWith(color: c.textSecondary)),
                  ],
                ),
              ),
              IconButton(
                icon: Icon(Icons.call, color: c.primary),
                tooltip: customer.phone,
                onPressed: _callCustomer,
              ),
            ],
          ),
          const SizedBox(height: 12),
          _infoRow(c, _t('customerCnic'), customer.cnic ?? '-'),
          _infoRow(c, _t('address'), customer.address ?? '-'),
          _infoRow(
            c,
            _t('loyaltyPoints'),
            customer.loyaltyPoints.toString(),
            mono: true,
          ),
          _infoRow(
            c,
            _t('walletBalance'),
            formatPkr(customer.walletBalance),
            mono: true,
          ),
        ],
      ),
    );
  }

  Widget _infoRow(CyberColors c, String label, String value,
      {bool mono = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 130,
            child: Text(label, style: CyberTextStyles.caption(c, size: 13)),
          ),
          Expanded(
            child: Text(
              value,
              style: mono
                  ? CyberTextStyles.mono(c, size: 14)
                  : CyberTextStyles.body(c, size: 14),
            ),
          ),
        ],
      ),
    );
  }

  Widget _balanceCard(CyberColors c) {
    return CyberCard(
      borderColor: balanceColor(c, _balance),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(_t('udhaarBalance'),
                    style: CyberTextStyles.label(c)),
                const SizedBox(height: 4),
                moneyText(
                  c,
                  _balance,
                  size: 28,
                  color: balanceColor(c, _balance),
                ),
              ],
            ),
          ),
          CyberBadge(
            label: _balance > 0
                ? _t('udhaar')
                : _balance < 0
                    ? _t('advance')
                    : _t('paid'),
            color: balanceColor(c, _balance),
          ),
        ],
      ),
    );
  }

  Widget _planCard(CyberColors c, Installment plan) {
    final status = _planStatus(plan);
    final statusColor = status == _t('paid')
        ? c.success
        : status == _t('overdue')
            ? c.error
            : c.warning;
    return CyberCard(
      onTap: () => _openPlans(initialPlanId: plan.id),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${_t('installment')} · ${formatPkr(plan.totalAmount)}',
                  style: CyberTextStyles.subtitle(c),
                ),
                const SizedBox(height: 2),
                Text(
                  '${_t('remainingAmount')}: ${formatPkr(plan.remainingAmount)}'
                  ' · ${_t('perInstallment')}: ${formatPkr(plan.installmentAmount)}',
                  style: CyberTextStyles.mono(c, size: 13)
                      .copyWith(color: c.textSecondary),
                ),
              ],
            ),
          ),
          CyberBadge(label: status, color: statusColor),
        ],
      ),
    );
  }
}
