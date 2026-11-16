/// Expense list — route `/expenses`.
///
/// Filter by category (All + the fixed categories + any custom category
/// present in the data) and by date range (From / To, defaulting to the
/// current month). Each row shows category, note, amount and date.
/// Tap a row to edit; the delete icon removes it after confirmation.
/// Add / edit go through [ExpenseFormScreen]; all writes use
/// [ExpenseRepository].
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/l10n/app_strings.dart';
import '../../core/theme/app_theme.dart';
import '../../core/theme/cyber_colors.dart';
import '../../core/theme/cyber_text_styles.dart';
import '../../core/theme/cyber_widgets.dart';
import '../../data/repositories/expense_repository.dart';
import '../../domain/models/expense.dart';
import '../../domain/money.dart';
import '../../features/auth/auth_state.dart';
import '../repairs/repair_common.dart';
import 'expense_form_screen.dart';
import 'staff_list_screen.dart';

/// Fixed categories offered in the form. Anything else stored in the
/// data is treated as a custom category and still shows in the filter.
const List<String> expenseCategories = <String>[
  'rent',
  'electricity',
  'salary',
  'transport',
  'misc',
  'other',
];

class ExpenseListScreen extends ConsumerStatefulWidget {
  const ExpenseListScreen({super.key, required this.repository});

  final ExpenseRepository repository;

  @override
  ConsumerState<ExpenseListScreen> createState() => _ExpenseListScreenState();
}

class _ExpenseListScreenState extends ConsumerState<ExpenseListScreen> {
  String? _categoryFilter;
  late DateTime _from;
  late DateTime _to;
  bool _loading = true;
  String? _error;
  List<Expense> _expenses = <Expense>[];

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _from = DateTime(now.year, now.month, 1);
    _to = DateTime(now.year, now.month + 1, 1)
        .subtract(const Duration(days: 1));
    _load();
  }

  String _userId() => ref.read(authStateProvider).user?.id ?? 'local-user';

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final toEnd = DateTime(_to.year, _to.month, _to.day, 23, 59, 59);
      final expenses = await widget.repository.listExpenses(
        from: _from,
        to: toEnd,
        category: _categoryFilter,
      );
      if (!mounted) return;
      setState(() {
        _expenses = expenses;
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

  int get _total => _expenses.fold<int>(0, (sum, e) => sum + e.amount);

  List<String> get _filterCategories {
    final custom = _expenses
        .map((e) => e.category)
        .where((c) => !expenseCategories.contains(c))
        .toSet();
    return [...expenseCategories, ...custom];
  }

  String _categoryLabel(String category, String Function(String) tr) {
    switch (category) {
      case 'rent':
        return tr('categoryRent');
      case 'electricity':
        return tr('categoryElectricity');
      case 'salary':
        return tr('categorySalaries');
      case 'transport':
        return tr('categoryTransport');
      case 'misc':
        return tr('categoryMisc');
      case 'other':
        return tr('categoryOther');
      default:
        return category;
    }
  }

  Future<void> _pickDate(bool isFrom) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: isFrom ? _from : _to,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked == null) return;
    setState(() {
      if (isFrom) {
        _from = picked;
        if (_to.isBefore(_from)) _to = _from;
      } else {
        _to = picked;
        if (_from.isAfter(_to)) _from = _to;
      }
    });
    await _load();
  }

  Future<void> _openForm({Expense? expense}) async {
    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => ExpenseFormScreen(
          repository: widget.repository,
          expense: expense,
        ),
      ),
    );
    if (mounted) _load();
  }

  Future<void> _delete(Expense expense, String Function(String) tr) async {
    final confirmed = await showCyberDialog(
      context,
      title: tr('delete'),
      message:
          '${_categoryLabel(expense.category, tr)} — ${formatPkr(expense.amount)}',
      confirmLabel: tr('delete'),
      cancelLabel: tr('cancel'),
      danger: true,
    );
    if (!confirmed) return;
    try {
      await widget.repository.deleteExpense(expense.id, userId: _userId());
      if (!mounted) return;
      showSnack(context, tr('deleted'));
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
      appBar: CyberAppBar(
        title: tr('expenses'),
        actions: [
          IconButton(
            icon: const Icon(Icons.people_outline),
            tooltip: tr('staff'),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) =>
                      StaffListScreen(repository: widget.repository),
                ),
              );
            },
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openForm(),
        icon: const Icon(Icons.add),
        label: Text(tr('newExpense')),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
            child: Row(
              children: [
                Expanded(
                  child: _dateButton(c, tr('from'), _from, () => _pickDate(true)),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _dateButton(c, tr('to'), _to, () => _pickDate(false)),
                ),
              ],
            ),
          ),
          SizedBox(
            height: 48,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: CyberChip(
                    label: tr('all'),
                    selected: _categoryFilter == null,
                    onSelected: (_) {
                      setState(() => _categoryFilter = null);
                      _load();
                    },
                  ),
                ),
                ..._filterCategories.map(
                  (category) => Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: CyberChip(
                      label: _categoryLabel(category, tr),
                      selected: _categoryFilter == category,
                      onSelected: (_) {
                        setState(() => _categoryFilter = category);
                        _load();
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(tr('totalExpenses'),
                    style: CyberTextStyles.label(c, size: 13)),
                Text(
                  formatPkr(_total),
                  style: CyberTextStyles.amount(c, size: 18),
                ),
              ],
            ),
          ),
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : _error != null
                    ? _errorView(c, tr)
                    : _expenses.isEmpty
                        ? _emptyView(c, tr)
                        : _listView(c, tr),
          ),
        ],
      ),
    );
  }

  Widget _dateButton(
    CyberColors c,
    String label,
    DateTime date,
    VoidCallback onTap,
  ) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        height: 48,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          color: c.surface,
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: c.border),
        ),
        child: Row(
          children: [
            Text('$label: ', style: CyberTextStyles.bodySecondary(c)),
            Expanded(
              child: Text(
                fmtDate(date),
                style: CyberTextStyles.mono(c, size: 14),
              ),
            ),
            Icon(Icons.calendar_today, color: c.primary, size: 18),
          ],
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
            Icon(Icons.receipt_long_outlined,
                size: 48, color: c.textSecondary),
            const SizedBox(height: 12),
            Text(tr('noExpenses'), style: CyberTextStyles.bodySecondary(c)),
            const SizedBox(height: 16),
            CyberButton(
              label: tr('newExpense'),
              onPressed: () => _openForm(),
              fullWidth: false,
            ),
          ],
        ),
      ),
    );
  }

  Widget _listView(CyberColors c, String Function(String) tr) {
    return RefreshIndicator(
      onRefresh: _load,
      child: ListView.builder(
        padding: const EdgeInsets.fromLTRB(16, 4, 16, 96),
        itemCount: _expenses.length,
        itemBuilder: (context, index) {
          final expense = _expenses[index];
          return CyberCard(
            onTap: () => _openForm(expense: expense),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          CyberBadge(
                            label: _categoryLabel(expense.category, tr),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            fmtDate(expense.expenseDate),
                            style: CyberTextStyles.mono(c, size: 12),
                          ),
                        ],
                      ),
                      if ((expense.description ?? '').isNotEmpty) ...[
                        const SizedBox(height: 6),
                        Text(
                          expense.description!,
                          style: CyberTextStyles.body(c, size: 14),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  formatPkr(expense.amount),
                  style: CyberTextStyles.mono(c, size: 15),
                ),
                IconButton(
                  icon: Icon(Icons.delete_outline, color: c.error),
                  tooltip: tr('delete'),
                  onPressed: () => _delete(expense, tr),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
