/// Staff list — route `/expenses/staff`.
///
/// Each row shows name, phone, role, monthly salary and active state.
/// Add / edit through a dialog (name, phone, role, monthly salary,
/// active toggle). Tapping a row opens [SalaryScreen] for that staff
/// member (pay salary + salary history). All writes use
/// [ExpenseRepository] (`createStaff` / `updateStaff`).
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
import '../../domain/validation.dart';
import '../../features/auth/auth_state.dart';
import '../repairs/repair_common.dart';
import 'salary_screen.dart';

const List<String> _staffRoles = <String>[
  'Technician',
  'Salesman',
  'Cashier',
  'Manager',
  'Helper',
];

class StaffListScreen extends ConsumerStatefulWidget {
  const StaffListScreen({super.key, required this.repository});

  final ExpenseRepository repository;

  @override
  ConsumerState<StaffListScreen> createState() => _StaffListScreenState();
}

class _StaffListScreenState extends ConsumerState<StaffListScreen> {
  bool _loading = true;
  String? _error;
  List<Staff> _staff = <Staff>[];

  @override
  void initState() {
    super.initState();
    _load();
  }

  String _userId() => ref.read(authStateProvider).user?.id ?? 'local-user';

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final staff = await widget.repository.listStaff(onlyActive: false);
      if (!mounted) return;
      setState(() {
        _staff = staff;
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

  Future<void> _openSalary(Staff member) async {
    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => SalaryScreen(
          repository: widget.repository,
          staff: member,
        ),
      ),
    );
    if (mounted) _load();
  }

  Future<void> _staffDialog({
    Staff? existing,
    required String Function(String) tr,
  }) async {
    final nameController = TextEditingController(text: existing?.name ?? '');
    final phoneController =
        TextEditingController(text: existing?.phone ?? '');
    final salaryController = TextEditingController(
      text: existing == null ? '' : existing.salary.toString(),
    );
    String role = existing?.role ?? _staffRoles.first;
    bool isActive = existing?.isActive ?? true;
    final formKey = GlobalKey<FormState>();
    final saved = await showDialog<bool>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => CyberDialog(
          title: tr(existing == null ? 'newStaff' : 'editStaff'),
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
                  controller: nameController,
                  label: tr('customerName'),
                  validator: (v) => Validators.required(
                    v,
                    field: tr('customerName'),
                  ),
                ),
                const SizedBox(height: 12),
                CyberTextField(
                  controller: phoneController,
                  label: tr('customerPhone'),
                  hint: '03XX-XXXXXXX',
                  keyboardType: TextInputType.phone,
                  monospace: true,
                  validator: (v) => Validators.phone(v, required: false),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  initialValue:
                      _staffRoles.contains(role) ? role : _staffRoles.first,
                  decoration: InputDecoration(labelText: tr('staffRole')),
                  items: _staffRoles
                      .map(
                        (r) => DropdownMenuItem<String>(
                          value: r,
                          child: Text(r),
                        ),
                      )
                      .toList(),
                  onChanged: (v) {
                    if (v != null) setDialogState(() => role = v);
                  },
                ),
                const SizedBox(height: 12),
                CyberTextField(
                  controller: salaryController,
                  label: tr('monthlySalary'),
                  keyboardType: TextInputType.number,
                  monospace: true,
                  validator: (v) {
                    final amount = parsePkr(v ?? '');
                    if (amount == null || amount < 0) {
                      return tr('invalidAmount');
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 8),
                CyberToggle(
                  label: tr('active'),
                  value: isActive,
                  onChanged: (v) => setDialogState(() => isActive = v),
                ),
              ],
            ),
          ),
        ),
      ),
    );
    final name = nameController.text.trim();
    final phone = phoneController.text.trim();
    final salary = parsePkr(salaryController.text) ?? 0;
    nameController.dispose();
    phoneController.dispose();
    salaryController.dispose();
    if (saved != true || name.isEmpty) return;
    try {
      if (existing == null) {
        await widget.repository.createStaff(
          Staff(
            id: '',
            name: name,
            phone: phone.isEmpty
                ? null
                : normalizePkPhone(phone) ?? phone,
            role: role,
            salary: salary,
            isActive: isActive,
            createdAt: DateTime.now(),
          ),
          userId: _userId(),
        );
      } else {
        await widget.repository.updateStaff(
          existing.copyWith(
            name: name,
            phone: phone.isEmpty
                ? null
                : normalizePkPhone(phone) ?? phone,
            role: role,
            salary: salary,
            isActive: isActive,
          ),
          userId: _userId(),
        );
      }
      if (!mounted) return;
      showSnack(context, tr('saved'));
      await _load();
    } catch (e) {
      if (!mounted) return;
      showSnack(context, e.toString(), isError: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = ref.watch(themeNotifierProvider).colors;
    final lang = ref.watch(languageProvider);
    String tr(String key) => AppStrings.tr(key, language: lang);

    return Scaffold(
      appBar: CyberAppBar(title: tr('staffList')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _staffDialog(tr: tr),
        icon: const Icon(Icons.add),
        label: Text(tr('newStaff')),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? _errorView(c, tr)
              : _staff.isEmpty
                  ? _emptyView(c, tr)
                  : RefreshIndicator(
                      onRefresh: _load,
                      child: ListView.builder(
                        padding: const EdgeInsets.fromLTRB(16, 12, 16, 96),
                        itemCount: _staff.length,
                        itemBuilder: (context, index) {
                          final member = _staff[index];
                          return CyberCard(
                            onTap: () => _openSalary(member),
                            child: Row(
                              children: [
                                CircleAvatar(
                                  backgroundColor: c.surface,
                                  child: Text(
                                    member.name.isEmpty
                                        ? '?'
                                        : member.name[0].toUpperCase(),
                                    style: CyberTextStyles.subtitle(c),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Expanded(
                                            child: Text(
                                              member.name,
                                              style: CyberTextStyles.subtitle(
                                                c,
                                                size: 16,
                                              ),
                                            ),
                                          ),
                                          CyberBadge(
                                            label: tr(member.isActive
                                                ? 'active'
                                                : 'inactive'),
                                            color: member.isActive
                                                ? c.success
                                                : c.textSecondary,
                                          ),
                                        ],
                                      ),
                                      if ((member.phone ?? '').isNotEmpty)
                                        Text(
                                          member.phone!,
                                          style: CyberTextStyles.mono(
                                            c,
                                            size: 13,
                                          ),
                                        ),
                                      Text(
                                        member.role ?? '',
                                        style:
                                            CyberTextStyles.bodySecondary(c),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        '${tr('monthlySalary')}: '
                                        '${formatPkr(member.salary)}',
                                        style: CyberTextStyles.mono(c, size: 14)
                                            .copyWith(color: c.primary),
                                      ),
                                    ],
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.edit_outlined),
                                  tooltip: tr('edit'),
                                  onPressed: () =>
                                      _staffDialog(existing: member, tr: tr),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
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

  Widget _emptyView(CyberColors c, String Function(String) tr) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.people_outline, size: 48, color: c.textSecondary),
            const SizedBox(height: 12),
            Text(tr('noStaff'), style: CyberTextStyles.bodySecondary(c)),
            const SizedBox(height: 16),
            CyberButton(
              label: tr('newStaff'),
              onPressed: () => _staffDialog(tr: tr),
              fullWidth: false,
            ),
          ],
        ),
      ),
    );
  }
}
