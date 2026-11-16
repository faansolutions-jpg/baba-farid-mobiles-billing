/// Customers list — route `/customers`.
///
/// Search by name/phone, sort by running udhaar balance (high/low) or
/// name. Each row shows the name, phone and running balance (red = owes,
/// green = settled, amber = advance). Tap opens the customer detail.
library;

import 'dart:async';

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
import 'customer_detail_screen.dart';
import 'customer_form_screen.dart';
import 'customer_helpers.dart';
import 'overdue_list_screen.dart';

enum _CustomerSort { balanceHigh, balanceLow, nameAz }

class CustomerListScreen extends ConsumerStatefulWidget {
  const CustomerListScreen({super.key, required this.repository});

  static const String routeName = '/customers';

  final CustomerRepository repository;

  @override
  ConsumerState<CustomerListScreen> createState() => _CustomerListScreenState();
}

class _CustomerListScreenState extends ConsumerState<CustomerListScreen> {
  final _searchController = TextEditingController();
  Timer? _debounce;

  List<Customer> _customers = [];
  bool _loading = true;
  String? _error;
  _CustomerSort _sort = _CustomerSort.balanceHigh;

  String get _lang => ref.read(languageProvider);

  String _t(String key) => AppStrings.tr(key, language: _lang);

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final query = _searchController.text.trim();
      final customers = await widget.repository.listCustomers(
        search: query.isEmpty ? null : query,
      );
      if (!mounted) return;
      setState(() {
        _customers = _sorted(customers);
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

  List<Customer> _sorted(List<Customer> customers) {
    final sorted = List<Customer>.from(customers);
    switch (_sort) {
      case _CustomerSort.balanceHigh:
        sorted.sort((a, b) => b.currentBalance.compareTo(a.currentBalance));
      case _CustomerSort.balanceLow:
        sorted.sort((a, b) => a.currentBalance.compareTo(b.currentBalance));
      case _CustomerSort.nameAz:
        sorted.sort(
          (a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()),
        );
    }
    return sorted;
  }

  void _onSearchChanged(String value) {
    _debounce?.cancel();
    _debounce = Timer(
      const Duration(milliseconds: AppConstants.searchDebounceMs),
      _load,
    );
  }

  void _openDetail(Customer customer) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => CustomerDetailScreen(
          repository: widget.repository,
          customerId: customer.id,
        ),
      ),
    ).then((_) => _load());
  }

  Future<void> _openAdd() async {
    final created = await Navigator.of(context).push<bool>(
      MaterialPageRoute<bool>(
        builder: (_) => CustomerFormScreen(repository: widget.repository),
      ),
    );
    if (created == true) _load();
  }

  void _openOverdue() {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => OverdueListScreen(repository: widget.repository),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final c = ref.watch(themeNotifierProvider).colors;
    final lang = ref.watch(languageProvider);
    return Scaffold(
      appBar: CyberAppBar(
        title: _t('customers'),
        actions: [
          IconButton(
            icon: const Icon(Icons.warning_amber_rounded),
            tooltip: _t('viewOverdue'),
            onPressed: _openOverdue,
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: _t('refresh'),
            onPressed: _load,
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _openAdd,
        icon: const Icon(Icons.person_add),
        label: Text(_t('addCustomer')),
      ),
      body: Padding(
        padding: const EdgeInsets.all(AppConstants.paddingMedium),
        child: Column(
          children: [
            CyberSearchBar(
              hint: _t('searchCustomersHint'),
              controller: _searchController,
              onChanged: _onSearchChanged,
              onSubmitted: (_) => _load(),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Text(_t('sortBy'), style: CyberTextStyles.label(c)),
                const SizedBox(width: 8),
                Expanded(
                  child: DropdownButton<_CustomerSort>(
                    value: _sort,
                    isExpanded: true,
                    underline: const SizedBox.shrink(),
                    items: [
                      DropdownMenuItem(
                        value: _CustomerSort.balanceHigh,
                        child: Text(_t('sortBalanceHigh'),
                            style: CyberTextStyles.body(c, size: 14)),
                      ),
                      DropdownMenuItem(
                        value: _CustomerSort.balanceLow,
                        child: Text(_t('sortBalanceLow'),
                            style: CyberTextStyles.body(c, size: 14)),
                      ),
                      DropdownMenuItem(
                        value: _CustomerSort.nameAz,
                        child: Text(_t('sortNameAZ'),
                            style: CyberTextStyles.body(c, size: 14)),
                      ),
                    ],
                    onChanged: (value) {
                      if (value == null) return;
                      setState(() {
                        _sort = value;
                        _customers = _sorted(_customers);
                      });
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Expanded(child: _buildBody(c, lang)),
          ],
        ),
      ),
    );
  }

  Widget _buildBody(CyberColors c, String lang) {
    if (_loading) return cyberLoading(c, _t('splashLoading'));
    if (_error != null) {
      return cyberError(c, _error!, _load, _t('tryAgain'));
    }
    if (_customers.isEmpty) {
      return cyberEmpty(
        c,
        _searchController.text.trim().isEmpty
            ? _t('noCustomers')
            : _t('noCustomersFound'),
        icon: Icons.people_outline,
      );
    }
    return RefreshIndicator(
      onRefresh: _load,
      color: c.primary,
      child: ListView.builder(
        itemCount: _customers.length,
        itemBuilder: (context, index) {
          final customer = _customers[index];
          return CyberCard(
            onTap: () => _openDetail(customer),
            child: Row(
              children: [
                CircleAvatar(
                  backgroundColor: c.primary.withValues(alpha: 0.15),
                  child: Text(
                    customer.name.isEmpty
                        ? '?'
                        : customer.name[0].toUpperCase(),
                    style: CyberTextStyles.title(c, size: 18)
                        .copyWith(color: c.primary),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        customer.name,
                        style: CyberTextStyles.subtitle(c),
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        customer.phone,
                        style: CyberTextStyles.mono(c, size: 13)
                            .copyWith(color: c.textSecondary),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      _t('udhaarBalance'),
                      style: CyberTextStyles.caption(c, size: 11),
                    ),
                    moneyText(
                      c,
                      customer.currentBalance,
                      size: 16,
                      color: balanceColor(c, customer.currentBalance),
                    ),
                  ],
                ),
                const SizedBox(width: 4),
                Icon(Icons.chevron_right, color: c.textSecondary),
              ],
            ),
          );
        },
      ),
    );
  }
}
