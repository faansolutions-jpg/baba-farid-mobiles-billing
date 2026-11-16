/// Repair job list — route `/repairs`.
///
/// Filter chips by status (All / Received / In Progress / Ready /
/// Delivered / Cancelled), search by job no / customer / device, and a
/// row per job showing job no, customer, device + fault, status badge,
/// estimated cost, advance paid and balance. Tapping a row opens the
/// job card ([RepairDetailScreen]).
library;

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/l10n/app_strings.dart';
import '../../core/theme/app_theme.dart';
import '../../core/theme/cyber_colors.dart';
import '../../core/theme/cyber_text_styles.dart';
import '../../core/theme/cyber_widgets.dart';
import '../../data/repositories/repair_repository.dart';
import '../../domain/models/repair.dart';
import '../../domain/money.dart';
import '../../core/providers/app_providers.dart';
import 'repair_detail_screen.dart';
import 'repair_form_screen.dart';
import 'service_sale_screen.dart';

/// Statuses shown as filter chips. `null` means "All".
const List<String?> _statusFilters = <String?>[
  null,
  'received',
  'in_progress',
  'ready',
  'delivered',
  'cancelled',
];

class RepairListScreen extends ConsumerStatefulWidget {
  const RepairListScreen({super.key, required this.repository});

  final RepairRepository repository;

  @override
  ConsumerState<RepairListScreen> createState() => _RepairListScreenState();
}

class _RepairListScreenState extends ConsumerState<RepairListScreen> {
  final TextEditingController _searchController = TextEditingController();
  Timer? _debounce;

  String? _statusFilter;
  bool _loading = true;
  String? _error;
  List<Repair> _repairs = <Repair>[];

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  String _tr(String key) =>
      AppStrings.tr(key, language: ref.watch(languageProvider));

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final repairs = await widget.repository.listRepairs(
        status: _statusFilter,
        search: _searchController.text.trim().isEmpty
            ? null
            : _searchController.text.trim(),
      );
      if (!mounted) return;
      setState(() {
        _repairs = repairs;
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

  void _onSearchChanged(String value) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), _load);
  }

  String _statusLabel(String status) {
    switch (status) {
      case 'received':
        return _tr('received');
      case 'in_progress':
        return _tr('inProgress');
      case 'ready':
        return _tr('ready');
      case 'delivered':
        return _tr('delivered');
      case 'cancelled':
        return _tr('cancelled');
      default:
        return status;
    }
  }

  Color _statusColor(String status, BuildContext context) {
    final c = ref.watch(themeNotifierProvider).colors;
    switch (status) {
      case 'received':
        return c.secondary;
      case 'in_progress':
        return c.warning;
      case 'ready':
        return c.primary;
      case 'delivered':
        return c.success;
      case 'cancelled':
        return c.error;
      default:
        return c.textSecondary;
    }
  }

  Future<void> _openForm() async {
    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => RepairFormScreen(
          repository: widget.repository,
          customerRepository: ref.read(customerRepositoryProvider),
        ),
      ),
    );
    if (mounted) _load();
  }

  Future<void> _openDetail(Repair repair) async {
    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => RepairDetailScreen(
          repairId: repair.id,
          repository: widget.repository,
          catalogRepository: ref.read(catalogRepositoryProvider),
          customerRepository: ref.read(customerRepositoryProvider),
        ),
      ),
    );
    if (mounted) _load();
  }

  @override
  Widget build(BuildContext context) {
    final c = ref.watch(themeNotifierProvider).colors;
    final lang = ref.watch(languageProvider);
    String tr(String key) => AppStrings.tr(key, language: lang);

    return Scaffold(
      appBar: CyberAppBar(
        title: tr('repairs'),
        actions: [
          IconButton(
            icon: const Icon(Icons.build_circle_outlined),
            tooltip: tr('serviceSales'),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => ServiceSaleScreen(
                    expenseRepository: ref.read(expenseRepositoryProvider),
                    settingsRepository: ref.read(settingsRepositoryProvider),
                  ),
                ),
              );
            },
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _openForm,
        icon: const Icon(Icons.add),
        label: Text(tr('newRepair')),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
            child: CyberSearchBar(
              hint: tr('searchRepairs'),
              controller: _searchController,
              onChanged: _onSearchChanged,
              onSubmitted: (_) => _load(),
            ),
          ),
          SizedBox(
            height: 48,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              children: _statusFilters.map((status) {
                final selected = _statusFilter == status;
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: CyberChip(
                    label: status == null ? tr('all') : _statusLabel(status),
                    selected: selected,
                    onSelected: (_) {
                      setState(() => _statusFilter = status);
                      _load();
                    },
                  ),
                );
              }).toList(),
            ),
          ),
          Expanded(child: _buildBody(c, tr)),
        ],
      ),
    );
  }

  Widget _buildBody(
    CyberColors c,
    String Function(String) tr,
  ) {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                _error!,
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
    if (_repairs.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.build_outlined, size: 48, color: c.textSecondary),
              const SizedBox(height: 12),
              Text(tr('noRepairs'), style: CyberTextStyles.bodySecondary(c)),
              const SizedBox(height: 16),
              CyberButton(
                label: tr('newRepair'),
                onPressed: _openForm,
                fullWidth: false,
              ),
            ],
          ),
        ),
      );
    }
    return RefreshIndicator(
      onRefresh: _load,
      child: ListView.builder(
        padding: const EdgeInsets.fromLTRB(16, 4, 16, 96),
        itemCount: _repairs.length,
        itemBuilder: (context, index) {
          final repair = _repairs[index];
          final device = [
            if ((repair.deviceBrand ?? '').isNotEmpty) repair.deviceBrand!,
            if ((repair.deviceModel ?? '').isNotEmpty) repair.deviceModel!,
          ].join(' ');
          final balance = repair.balanceDue;
          return CyberCard(
            onTap: () => _openDetail(repair),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        repair.jobNo,
                        style: CyberTextStyles.mono(c, size: 15),
                      ),
                    ),
                    CyberBadge(
                      label: _statusLabel(repair.status),
                      color: _statusColor(repair.status, context),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  repair.customerName,
                  style: CyberTextStyles.subtitle(c, size: 16),
                ),
                Text(
                  repair.customerPhone,
                  style: CyberTextStyles.mono(c, size: 13),
                ),
                if (device.isNotEmpty || repair.faultDescription.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(
                      [
                        device,
                        repair.faultDescription,
                      ].where((s) => s.isNotEmpty).join(' — '),
                      style: CyberTextStyles.bodySecondary(c),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: _moneyCell(
                        c,
                        _tr('estimatedCost'),
                        formatPkr(repair.estimatedCost),
                      ),
                    ),
                    Expanded(
                      child: _moneyCell(
                        c,
                        _tr('advance'),
                        formatPkr(repair.advancePaid),
                      ),
                    ),
                    Expanded(
                      child: _moneyCell(
                        c,
                        _tr('balance'),
                        formatPkr(balance),
                        highlight: balance > 0,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _moneyCell(
    CyberColors c,
    String label,
    String value, {
    bool highlight = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: CyberTextStyles.label(c, size: 11)),
        const SizedBox(height: 2),
        Text(
          value,
          style: CyberTextStyles.mono(c, size: 14).copyWith(
            color: highlight ? c.warning : c.textPrimary,
            fontWeight: highlight ? FontWeight.w700 : FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
