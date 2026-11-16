/// Add / edit customer — route `/customers/new`.
///
/// Fields: name (required), phone (required, Pakistani mobile),
/// optional CNIC (`xxxxx-xxxxxxx-x`), address, opening balance.
/// In edit mode the opening balance is shown read-only: changing it
/// would need a ledger adjustment entry, which the repository does not
/// expose, so it can only be set when the customer is created.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/config/constants.dart';
import '../../core/l10n/app_strings.dart';
import '../../core/theme/cyber_widgets.dart';
import '../../data/repositories/customer_repository.dart';
import '../../domain/models/customer.dart';
import '../../domain/validation.dart';
import '../auth/auth_state.dart';
import 'customer_helpers.dart';

class CustomerFormScreen extends ConsumerStatefulWidget {
  const CustomerFormScreen({
    super.key,
    required this.repository,
    this.customer,
  });

  static const String routeName = '/customers/new';

  final CustomerRepository repository;

  /// When set, the form edits this customer instead of creating one.
  final Customer? customer;

  @override
  ConsumerState<CustomerFormScreen> createState() => _CustomerFormScreenState();
}

class _CustomerFormScreenState extends ConsumerState<CustomerFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _cnicController = TextEditingController();
  final _addressController = TextEditingController();
  final _openingBalanceController = TextEditingController(text: '0');

  bool _saving = false;

  bool get _isEdit => widget.customer != null;

  String get _lang => ref.read(languageProvider);

  String _t(String key) => AppStrings.tr(key, language: _lang);

  @override
  void initState() {
    super.initState();
    final customer = widget.customer;
    if (customer != null) {
      _nameController.text = customer.name;
      _phoneController.text = customer.phone;
      _cnicController.text = customer.cnic ?? '';
      _addressController.text = customer.address ?? '';
      _openingBalanceController.text = customer.openingBalance.toString();
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _cnicController.dispose();
    _addressController.dispose();
    _openingBalanceController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    final userId = ref.read(authStateProvider).user?.id ?? 'system';
    setState(() => _saving = true);
    try {
      final now = DateTime.now();
      if (_isEdit) {
        final updated = widget.customer!.copyWith(
          name: _nameController.text.trim(),
          phone: _phoneController.text.trim(),
          cnic: _cnicController.text.trim().isEmpty
              ? null
              : _cnicController.text.trim(),
          address: _addressController.text.trim().isEmpty
              ? null
              : _addressController.text.trim(),
          updatedAt: now,
        );
        await widget.repository.updateCustomer(updated, userId: userId);
      } else {
        final created = Customer(
          id: '',
          name: _nameController.text.trim(),
          phone: _phoneController.text.trim(),
          cnic: _cnicController.text.trim().isEmpty
              ? null
              : _cnicController.text.trim(),
          address: _addressController.text.trim().isEmpty
              ? null
              : _addressController.text.trim(),
          openingBalance:
              int.tryParse(_openingBalanceController.text.trim()) ?? 0,
          createdAt: now,
          updatedAt: now,
        );
        await widget.repository.createCustomer(created, userId: userId);
      }
      if (!mounted) return;
      showSnack(context, _t('saved'));
      Navigator.of(context).pop(true);
    } catch (e) {
      if (!mounted) return;
      showSnack(context, e.toString(), isError: true);
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CyberAppBar(
        title: _isEdit ? _t('editCustomer') : _t('addCustomer'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppConstants.paddingMedium),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              CyberTextField(
                controller: _nameController,
                label: _t('customerName'),
                textInputAction: TextInputAction.next,
                validator: (value) =>
                    Validators.required(value, field: _t('customerName')),
              ),
              const SizedBox(height: 12),
              CyberTextField(
                controller: _phoneController,
                label: _t('customerPhone'),
                hint: '03XX-XXXXXXX',
                monospace: true,
                keyboardType: TextInputType.phone,
                textInputAction: TextInputAction.next,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return _t('requiredField');
                  }
                  if (!isValidPhone(value.trim())) {
                    return _t('invalidPhoneNumber');
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),
              CyberTextField(
                controller: _cnicController,
                label: _t('customerCnic'),
                hint: 'xxxxx-xxxxxxx-x',
                monospace: true,
                keyboardType: TextInputType.number,
                textInputAction: TextInputAction.next,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) return null;
                  if (!isValidCnic(value.trim())) {
                    return _t('invalidCnicFormat');
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),
              CyberTextField(
                controller: _addressController,
                label: _t('address'),
                textInputAction: TextInputAction.next,
              ),
              const SizedBox(height: 12),
              CyberTextField(
                controller: _openingBalanceController,
                label: _t('openingBalance'),
                hint: '0',
                monospace: true,
                keyboardType: TextInputType.number,
                readOnly: _isEdit,
                validator: (value) {
                  final amount = int.tryParse((value ?? '').trim());
                  if (amount == null) return _t('invalidAmount');
                  return null;
                },
              ),
              const SizedBox(height: 24),
              CyberButton(
                label: _t('save'),
                icon: Icons.save,
                isLoading: _saving,
                onPressed: _saving ? null : _save,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
