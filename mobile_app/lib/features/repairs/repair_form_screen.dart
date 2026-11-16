/// New repair job form — route `/repairs/new`.
///
/// Customer: pick an existing customer (search by name/phone) or type a
/// new one (created through [CustomerRepository] on save when one is
/// provided). Device brand/model, optional IMEI, fault description,
/// estimated cost, advance received, expected delivery date.
///
/// The [Repair] model has no expected-delivery column, so the chosen
/// date is recorded at the top of the job's notes
/// ("Expected delivery: 20 Nov 2026"). The final cost starts at the
/// estimated cost; parts and labour added later adjust it from the job
/// card. Saves through [RepairRepository.createRepair], which allocates
/// the job number (`REP-000123`).
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/l10n/app_strings.dart';
import '../../core/theme/app_theme.dart';
import '../../core/theme/cyber_colors.dart';
import '../../core/theme/cyber_text_styles.dart';
import '../../core/theme/cyber_widgets.dart';
import '../../data/repositories/customer_repository.dart';
import '../../data/repositories/repair_repository.dart';
import '../../domain/models/customer.dart';
import '../../domain/models/repair.dart';
import '../../domain/validation.dart';
import '../../features/auth/auth_state.dart';
import 'repair_common.dart';

class RepairFormScreen extends ConsumerStatefulWidget {
  const RepairFormScreen({
    super.key,
    required this.repository,
    this.customerRepository,
  });

  final RepairRepository repository;

  /// When null, customers are typed freehand (no lookup / creation).
  final CustomerRepository? customerRepository;

  @override
  ConsumerState<RepairFormScreen> createState() => _RepairFormScreenState();
}

class _RepairFormScreenState extends ConsumerState<RepairFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _brandController = TextEditingController();
  final _modelController = TextEditingController();
  final _imeiController = TextEditingController();
  final _faultController = TextEditingController();
  final _estimatedController = TextEditingController();
  final _advanceController = TextEditingController();
  final _customerSearchController = TextEditingController();

  String? _customerId;
  DateTime? _expectedDelivery;
  List<Customer> _customerMatches = <Customer>[];
  bool _searchingCustomers = false;
  bool _saving = false;

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _brandController.dispose();
    _modelController.dispose();
    _imeiController.dispose();
    _faultController.dispose();
    _estimatedController.dispose();
    _advanceController.dispose();
    _customerSearchController.dispose();
    super.dispose();
  }

  String _userId() =>
      ref.read(authStateProvider).user?.id ?? 'local-user';

  Future<void> _searchCustomers(String query) async {
    final repo = widget.customerRepository;
    if (repo == null || query.trim().length < 2) {
      if (mounted) setState(() => _customerMatches = <Customer>[]);
      return;
    }
    setState(() => _searchingCustomers = true);
    try {
      final matches = await repo.listCustomers(search: query.trim());
      if (!mounted) return;
      setState(() {
        _customerMatches = matches;
        _searchingCustomers = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _searchingCustomers = false);
    }
  }

  void _pickCustomer(Customer customer) {
    setState(() {
      _customerId = customer.id;
      _nameController.text = customer.name;
      _phoneController.text = customer.phone;
      _customerMatches = <Customer>[];
      _customerSearchController.clear();
    });
  }

  Future<void> _pickDeliveryDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _expectedDelivery ?? now.add(const Duration(days: 3)),
      firstDate: now,
      lastDate: now.add(const Duration(days: 365)),
    );
    if (picked != null) setState(() => _expectedDelivery = picked);
  }

  Future<void> _save(String Function(String) tr) async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    final estimated = parsePkr(_estimatedController.text) ?? 0;
    final advance = parsePkr(_advanceController.text) ?? 0;
    if (advance > estimated) {
      showSnack(context, tr('invalidAmount'), isError: true);
      return;
    }
    setState(() => _saving = true);
    try {
      var customerId = _customerId;
      final repo = widget.customerRepository;
      if (customerId == null && repo != null) {
        final existing = await repo.getCustomerByPhone(
          normalizePkPhone(_phoneController.text.trim()) ??
              _phoneController.text.trim(),
        );
        if (existing != null) {
          customerId = existing.id;
        } else {
          final created = await repo.createCustomer(
            Customer(
              id: '',
              name: _nameController.text.trim(),
              phone: normalizePkPhone(_phoneController.text.trim()) ??
                  _phoneController.text.trim(),
              isActive: true,
              createdAt: DateTime.now(),
              updatedAt: DateTime.now(),
            ),
            userId: _userId(),
          );
          customerId = created.id;
        }
      }
      final now = DateTime.now();
      final notes = _expectedDelivery == null
          ? null
          : 'Expected delivery: ${fmtDate(_expectedDelivery!)}';
      final created = await widget.repository.createRepair(
        Repair(
          id: '',
          jobNo: '',
          customerId: customerId,
          customerName: _nameController.text.trim(),
          customerPhone: normalizePkPhone(_phoneController.text.trim()) ??
              _phoneController.text.trim(),
          deviceBrand: _brandController.text.trim().isEmpty
              ? null
              : _brandController.text.trim(),
          deviceModel: _modelController.text.trim().isEmpty
              ? null
              : _modelController.text.trim(),
          imei: _imeiController.text.trim().isEmpty
              ? null
              : _imeiController.text.trim(),
          faultDescription: _faultController.text.trim(),
          estimatedCost: estimated,
          finalCost: estimated,
          advancePaid: advance,
          status: 'received',
          receivedDate: now,
          userId: _userId(),
          notes: notes,
          createdAt: now,
          updatedAt: now,
        ),
        userId: _userId(),
      );
      if (!mounted) return;
      showSnack(context, '${tr('saved')} — ${created.jobNo}');
      Navigator.of(context).pop(created);
    } catch (e) {
      if (!mounted) return;
      showSnack(context, e.toString(), isError: true);
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = ref.watch(themeNotifierProvider).colors;
    final lang = ref.watch(languageProvider);
    String tr(String key) => AppStrings.tr(key, language: lang);

    return Scaffold(
      appBar: CyberAppBar(title: tr('newRepair')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
          children: [
            _sectionTitle(c, tr('selectCustomer')),
            if (widget.customerRepository != null) ...[
              CyberTextField(
                controller: _customerSearchController,
                label: tr('search'),
                hint: tr('searchHint'),
                prefixIcon: Icons.person_search,
                onChanged: _searchCustomers,
              ),
              if (_searchingCustomers)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 8),
                  child: LinearProgressIndicator(),
                ),
              ..._customerMatches.map(
                (customer) => ListTile(
                  leading: Icon(Icons.person, color: c.primary),
                  title: Text(customer.name),
                  subtitle: Text(
                    customer.phone,
                    style: CyberTextStyles.mono(c, size: 13),
                  ),
                  trailing: customer.currentBalance > 0
                      ? Text(
                          'Udhaar: ${customer.currentBalance}',
                          style: CyberTextStyles.mono(c, size: 12)
                              .copyWith(color: c.warning),
                        )
                      : null,
                  onTap: () => _pickCustomer(customer),
                ),
              ),
              const SizedBox(height: 8),
            ],
            CyberTextField(
              controller: _nameController,
              label: tr('customerName'),
              prefixIcon: Icons.person,
              validator: (v) => Validators.required(
                v,
                field: tr('customerName'),
              ),
              textInputAction: TextInputAction.next,
            ),
            const SizedBox(height: 12),
            CyberTextField(
              controller: _phoneController,
              label: tr('customerPhone'),
              hint: '03XX-XXXXXXX',
              prefixIcon: Icons.phone,
              keyboardType: TextInputType.phone,
              monospace: true,
              validator: (v) => Validators.phone(v, required: true),
              textInputAction: TextInputAction.next,
              onChanged: (_) {
                if (_customerId != null) {
                  setState(() => _customerId = null);
                }
              },
            ),
            const SizedBox(height: 16),
            _sectionTitle(c, tr('device')),
            CyberTextField(
              controller: _brandController,
              label: tr('brand'),
              prefixIcon: Icons.phone_android,
              textInputAction: TextInputAction.next,
            ),
            const SizedBox(height: 12),
            CyberTextField(
              controller: _modelController,
              label: tr('model'),
              prefixIcon: Icons.smartphone,
              textInputAction: TextInputAction.next,
            ),
            const SizedBox(height: 12),
            CyberTextField(
              controller: _imeiController,
              label: tr('imei'),
              hint: tr('imeiHint'),
              prefixIcon: Icons.qr_code,
              keyboardType: TextInputType.number,
              monospace: true,
              maxLength: 15,
              validator: (v) => Validators.imei(v, required: false),
              textInputAction: TextInputAction.next,
            ),
            const SizedBox(height: 12),
            CyberTextField(
              controller: _faultController,
              label: tr('fault'),
              hint: tr('fault'),
              prefixIcon: Icons.build,
              validator: (v) => Validators.required(
                v,
                field: tr('fault'),
              ),
              textInputAction: TextInputAction.next,
            ),
            const SizedBox(height: 16),
            _sectionTitle(c, tr('repairCost')),
            CyberTextField(
              controller: _estimatedController,
              label: tr('estimatedCost'),
              keyboardType: TextInputType.number,
              monospace: true,
              prefixIcon: Icons.payments,
              validator: (v) {
                final amount = parsePkr(v ?? '');
                if (amount == null || amount <= 0) {
                  return tr('invalidAmount');
                }
                return null;
              },
              textInputAction: TextInputAction.next,
            ),
            const SizedBox(height: 12),
            CyberTextField(
              controller: _advanceController,
              label: tr('advance'),
              keyboardType: TextInputType.number,
              monospace: true,
              prefixIcon: Icons.account_balance_wallet,
              validator: (v) {
                final amount = parsePkr(v ?? '');
                if (amount == null || amount < 0) {
                  return tr('invalidAmount');
                }
                return null;
              },
              textInputAction: TextInputAction.done,
            ),
            const SizedBox(height: 16),
            _sectionTitle(c, tr('expectedDelivery')),
            InkWell(
              onTap: _pickDeliveryDate,
              borderRadius: BorderRadius.circular(8),
              child: Container(
                height: 48,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: c.surface,
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: c.border),
                ),
                child: Row(
                  children: [
                    Icon(Icons.calendar_today, color: c.primary, size: 20),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        _expectedDelivery == null
                            ? tr('selectDate')
                            : fmtDate(_expectedDelivery!),
                        style: _expectedDelivery == null
                            ? CyberTextStyles.bodySecondary(c)
                            : CyberTextStyles.body(c),
                      ),
                    ),
                    if (_expectedDelivery != null)
                      IconButton(
                        icon: const Icon(Icons.clear, size: 20),
                        onPressed: () =>
                            setState(() => _expectedDelivery = null),
                      ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            CyberButton(
              label: tr('save'),
              icon: Icons.save,
              isLoading: _saving,
              onPressed: _saving ? null : () => _save(tr),
            ),
          ],
        ),
      ),
    );
  }

  Widget _sectionTitle(CyberColors c, String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(title, style: CyberTextStyles.label(c, size: 13)),
    );
  }
}
