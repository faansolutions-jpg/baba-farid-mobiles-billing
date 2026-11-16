library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/l10n/app_strings.dart';
import '../../core/theme/app_theme.dart';
import '../../core/theme/cyber_text_styles.dart';
import '../../core/theme/cyber_widgets.dart';
import '../../domain/models/customer.dart';
import '../auth/auth_state.dart';
import '../../core/providers/app_providers.dart';

/// Customer picker for the POS screen.
///
/// Searches existing customers (name / phone) and lets the cashier
/// create a new one on the fly (name + phone, optional CNIC). Returns
/// the picked [Customer], or null when dismissed. A walk-in sale simply
/// never opens this sheet.
Future<Customer?> showCustomerPickerSheet(BuildContext context) {
  return showModalBottomSheet<Customer>(
    context: context,
    isScrollControlled: true,
    builder: (context) => const CustomerPickerSheet(),
  );
}

class CustomerPickerSheet extends ConsumerStatefulWidget {
  const CustomerPickerSheet({super.key});

  @override
  ConsumerState<CustomerPickerSheet> createState() =>
      _CustomerPickerSheetState();
}

class _CustomerPickerSheetState extends ConsumerState<CustomerPickerSheet> {
  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _cnicController = TextEditingController();

  bool _loading = false;
  bool _creating = false;
  String? _error;
  List<Customer> _results = <Customer>[];
  bool _showCreateForm = false;

  @override
  void dispose() {
    _searchController.dispose();
    _nameController.dispose();
    _phoneController.dispose();
    _cnicController.dispose();
    super.dispose();
  }

  Future<void> _search(String query) async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final repo = ref.read(customerRepositoryProvider);
      final results = await repo.listCustomers(
        search: query.trim().isEmpty ? null : query.trim(),
        limit: 20,
      );
      if (!mounted) return;
      setState(() {
        _results = results;
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

  Future<void> _createCustomer() async {
    final lang = ref.read(languageProvider);
    String tr(String key) => AppStrings.tr(key, language: lang);
    final name = _nameController.text.trim();
    final phone = _phoneController.text.trim();
    if (name.isEmpty || phone.isEmpty) {
      setState(() => _error = tr('fieldRequired'));
      return;
    }
    setState(() {
      _creating = true;
      _error = null;
    });
    try {
      final repo = ref.read(customerRepositoryProvider);
      final userId = ref.read(authStateProvider).user?.id;
      final now = DateTime.now();
      final created = await repo.createCustomer(
        Customer(
          id: '',
          name: name,
          phone: phone,
          cnic: _cnicController.text.trim().isEmpty
              ? null
              : _cnicController.text.trim(),
          createdAt: now,
          updatedAt: now,
        ),
        userId: userId,
      );
      if (!mounted) return;
      Navigator.of(context).pop(created);
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString();
        _creating = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = ref.watch(themeNotifierProvider).colors;
    final lang = ref.watch(languageProvider);
    String tr(String key) => AppStrings.tr(key, language: lang);

    return Padding(
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        top: 16,
        bottom: MediaQuery.of(context).viewInsets.bottom + 16,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              tr('selectCustomer'),
              style: CyberTextStyles.title(c, size: 18),
            ),
            const SizedBox(height: 12),
            CyberSearchBar(
              hint: tr('searchHint'),
              controller: _searchController,
              onSubmitted: _search,
              onChanged: (value) {
                if (value.trim().length >= 2) _search(value);
              },
            ),
            const SizedBox(height: 8),
            if (_loading)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 16),
                child: Center(child: CircularProgressIndicator()),
              )
            else if (_error != null)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Text(_error!, style: CyberTextStyles.error(c)),
              )
            else if (_results.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Text(
                  tr('noCustomers'),
                  style: CyberTextStyles.bodySecondary(c),
                ),
              )
            else
              ..._results.map(
                (customer) => ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(customer.name),
                  subtitle: Text(
                    customer.phone,
                    style: CyberTextStyles.mono(c, size: 13),
                  ),
                  trailing: customer.currentBalance > 0
                      ? CyberBadge(
                          label:
                              '${tr('udhaarBalance')}: ${customer.currentBalance}',
                          color: c.warning,
                        )
                      : null,
                  onTap: () => Navigator.of(context).pop(customer),
                ),
              ),
            const SizedBox(height: 12),
            CyberButton(
              label: tr('newCustomer'),
              variant: CyberButtonVariant.ghost,
              icon: Icons.person_add_outlined,
              onPressed: () => setState(() => _showCreateForm = true),
            ),
            if (_showCreateForm) ...[
              const SizedBox(height: 12),
              CyberTextField(
                controller: _nameController,
                label: tr('customerName'),
                textInputAction: TextInputAction.next,
              ),
              const SizedBox(height: 12),
              CyberTextField(
                controller: _phoneController,
                label: tr('customerPhone'),
                keyboardType: TextInputType.phone,
                textInputAction: TextInputAction.next,
              ),
              const SizedBox(height: 12),
              CyberTextField(
                controller: _cnicController,
                label: tr('customerCnic'),
                keyboardType: TextInputType.number,
                maxLength: 13,
                textInputAction: TextInputAction.done,
              ),
              const SizedBox(height: 12),
              CyberButton(
                label: tr('save'),
                isLoading: _creating,
                onPressed: _createCustomer,
              ),
            ],
            const SizedBox(height: 8),
            CyberButton(
              label: tr('cancel'),
              variant: CyberButtonVariant.ghost,
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        ),
      ),
    );
  }
}
