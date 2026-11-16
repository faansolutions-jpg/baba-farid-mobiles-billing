/// Service sales (EasyLoad / recharge / bill payment) — route
/// `/repairs/services` (also reachable from the repair list).
///
/// Provider chips (Jazz / Telenor / Zong / Ufone), mobile number,
/// amount, and commission auto-computed from the stored
/// `service_commission_rate` setting (default 2%). Saved through
/// [ExpenseRepository.createServiceSale]; today's sales are listed
/// below with the day's total commission.
///
/// Commission is shop earnings: it is shown only to owner/manager
/// roles — cashiers see amounts only, never commission/profit figures.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/l10n/app_strings.dart';
import '../../core/theme/app_theme.dart';
import '../../core/theme/cyber_colors.dart';
import '../../core/theme/cyber_text_styles.dart';
import '../../core/theme/cyber_widgets.dart';
import '../../data/repositories/expense_repository.dart';
import '../../data/repositories/settings_repository.dart';
import '../../domain/models/service_sale.dart';
import '../../domain/money.dart';
import '../../domain/validation.dart';
import '../../features/auth/auth_state.dart';
import 'repair_common.dart';

const List<String> _providers = <String>[
  'Jazz',
  'Telenor',
  'Zong',
  'Ufone',
];

const List<String> _serviceTypes = <String>[
  'easyload',
  'recharge',
  'bill_payment',
  'other',
];

class ServiceSaleScreen extends ConsumerStatefulWidget {
  const ServiceSaleScreen({
    super.key,
    required this.expenseRepository,
    this.settingsRepository,
  });

  final ExpenseRepository expenseRepository;

  /// When null, the default 2% commission rate is used.
  final SettingsRepository? settingsRepository;

  @override
  ConsumerState<ServiceSaleScreen> createState() => _ServiceSaleScreenState();
}

class _ServiceSaleScreenState extends ConsumerState<ServiceSaleScreen> {
  final _formKey = GlobalKey<FormState>();
  final _phoneController = TextEditingController();
  final _amountController = TextEditingController();

  String? _provider;
  String _serviceType = 'easyload';
  double _rate = defaultServiceCommissionRate;
  bool _loading = true;
  bool _saving = false;
  String? _error;
  List<ServiceSale> _today = <ServiceSale>[];

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _phoneController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  bool get _canSeeCommission {
    final role = ref.watch(authStateProvider).user?.role;
    return role != 'cashier';
  }

  int get _amount => parsePkr(_amountController.text) ?? 0;

  int get _todayTotal =>
      _today.fold<int>(0, (sum, s) => sum + s.amount);

  int get _todayCommission =>
      _today.fold<int>(0, (sum, s) => sum + s.commission);

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      double rate = defaultServiceCommissionRate;
      final settings = widget.settingsRepository;
      if (settings != null) {
        rate = commissionRateFromSetting(
          await settings.getValue('service_commission_rate'),
        );
      }
      final now = DateTime.now();
      final dayStart = DateTime(now.year, now.month, now.day);
      final sales = await widget.expenseRepository.listServiceSales(
        from: dayStart,
        to: now,
      );
      if (!mounted) return;
      setState(() {
        _rate = rate;
        _today = sales;
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

  String _typeLabel(String type, String Function(String) tr) {
    switch (type) {
      case 'easyload':
        return tr('easyload');
      case 'recharge':
        return tr('recharge');
      case 'bill_payment':
        return tr('billPayment');
      default:
        return tr('other');
    }
  }

  Future<void> _save(String Function(String) tr) async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    if (_provider == null) {
      showSnack(context, tr('selectProvider'), isError: true);
      return;
    }
    final amount = _amount;
    final commission = commissionFor(amount, _rate);
    setState(() => _saving = true);
    try {
      final now = DateTime.now();
      await widget.expenseRepository.createServiceSale(
        ServiceSale(
          id: '',
          serviceType: _serviceType,
          customerPhone: normalizePkPhone(_phoneController.text.trim()),
          provider: _provider,
          amount: amount,
          commission: commission,
          userId: ref.read(authStateProvider).user?.id ?? 'local-user',
          saleDate: now,
          createdAt: now,
        ),
        userId: ref.read(authStateProvider).user?.id,
      );
      if (!mounted) return;
      _phoneController.clear();
      _amountController.clear();
      setState(() {
        _saving = false;
        _provider = null;
      });
      showSnack(context, tr('saved'));
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

    return Scaffold(
      appBar: CyberAppBar(title: tr('serviceSales')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? _errorView(c, tr)
              : _body(c, tr),
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

  Widget _body(CyberColors c, String Function(String) tr) {
    return Form(
      key: _formKey,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
        children: [
          Text(tr('serviceType'), style: CyberTextStyles.label(c, size: 13)),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: _serviceTypes
                .map(
                  (type) => CyberChip(
                    label: _typeLabel(type, tr),
                    selected: _serviceType == type,
                    onSelected: (_) =>
                        setState(() => _serviceType = type),
                  ),
                )
                .toList(),
          ),
          const SizedBox(height: 16),
          Text(tr('provider'), style: CyberTextStyles.label(c, size: 13)),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: _providers
                .map(
                  (provider) => CyberChip(
                    label: provider,
                    selected: _provider == provider,
                    onSelected: (_) =>
                        setState(() => _provider = provider),
                  ),
                )
                .toList(),
          ),
          const SizedBox(height: 16),
          CyberTextField(
            controller: _phoneController,
            label: tr('mobileNumber'),
            hint: '03XX-XXXXXXX',
            prefixIcon: Icons.phone,
            keyboardType: TextInputType.phone,
            monospace: true,
            validator: (v) => Validators.phone(v, required: true),
            textInputAction: TextInputAction.next,
          ),
          const SizedBox(height: 12),
          CyberTextField(
            controller: _amountController,
            label: tr('amount'),
            keyboardType: TextInputType.number,
            monospace: true,
            prefixIcon: Icons.payments,
            validator: (v) {
              final amount = parsePkr(v ?? '');
              if (amount == null || amount <= 0) return tr('invalidAmount');
              return null;
            },
            onChanged: (_) => setState(() {}),
            textInputAction: TextInputAction.done,
          ),
          const SizedBox(height: 12),
          CyberCard(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${tr('commission')} (${_rate.toStringAsFixed(_rate.truncateToDouble() == _rate ? 0 : 1)}%)',
                  style: CyberTextStyles.body(c),
                ),
                Text(
                  _canSeeCommission
                      ? formatPkr(commissionFor(_amount, _rate))
                      : '****',
                  style: CyberTextStyles.amount(c, size: 18),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          CyberButton(
            label: tr('save'),
            icon: Icons.save,
            isLoading: _saving,
            onPressed: _saving ? null : () => _save(tr),
          ),
          const SizedBox(height: 24),
          Text(tr('todayServiceSales'),
              style: CyberTextStyles.label(c, size: 13)),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: CyberStatCard(
                  label: tr('serviceSalesTotal'),
                  value: _todayTotal,
                  prefix: 'Rs ',
                ),
              ),
              const SizedBox(width: 12),
              if (_canSeeCommission)
                Expanded(
                  child: CyberStatCard(
                    label: tr('totalCommission'),
                    value: _todayCommission,
                    prefix: 'Rs ',
                  ),
                ),
            ],
          ),
          const SizedBox(height: 8),
          if (_today.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: Text(tr('noServiceSales'),
                  style: CyberTextStyles.bodySecondary(c),
                  textAlign: TextAlign.center),
            ),
          ..._today.map(
            (sale) => CyberCard(
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${sale.provider ?? ''} · ${_typeLabel(sale.serviceType, tr)}',
                          style: CyberTextStyles.subtitle(c, size: 15),
                        ),
                        Text(
                          sale.customerPhone ?? '',
                          style: CyberTextStyles.mono(c, size: 13),
                        ),
                        Text(
                          fmtDateTime(sale.saleDate),
                          style: CyberTextStyles.caption(c),
                        ),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        formatPkr(sale.amount),
                        style: CyberTextStyles.mono(c, size: 15),
                      ),
                      if (_canSeeCommission)
                        Text(
                          '+${formatPkr(sale.commission)}',
                          style: CyberTextStyles.mono(c, size: 12)
                              .copyWith(color: c.primary),
                        ),
                    ],
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
