/// Add / edit expense — used by [ExpenseListScreen].
///
/// Category comes from the fixed list (Rent, Electricity, Salaries,
/// Transport, Misc, Other); choosing "Other" reveals a free-text field
/// for a custom category, which is then stored as-is and shows up in
/// the list filter. Amount (whole PKR), date and a note. Saves through
/// [ExpenseRepository.createExpense] / `updateExpense`.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/l10n/app_strings.dart';
import '../../core/theme/app_theme.dart';
import '../../core/theme/cyber_text_styles.dart';
import '../../core/theme/cyber_widgets.dart';
import '../../data/repositories/expense_repository.dart';
import '../../domain/models/expense.dart';
import '../../features/auth/auth_state.dart';
import '../repairs/repair_common.dart';
import 'expense_list_screen.dart' show expenseCategories;

class ExpenseFormScreen extends ConsumerStatefulWidget {
  const ExpenseFormScreen({
    super.key,
    required this.repository,
    this.expense,
  });

  final ExpenseRepository repository;

  /// Null = create a new expense; non-null = edit this one.
  final Expense? expense;

  @override
  ConsumerState<ExpenseFormScreen> createState() => _ExpenseFormScreenState();
}

class _ExpenseFormScreenState extends ConsumerState<ExpenseFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _amountController;
  late final TextEditingController _noteController;
  late final TextEditingController _customCategoryController;

  late String _category;
  late DateTime _date;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final expense = widget.expense;
    _amountController =
        TextEditingController(text: expense == null ? '' : expense.amount.toString());
    _noteController =
        TextEditingController(text: expense?.description ?? '');
    final isCustom = expense != null &&
        !expenseCategories.contains(expense.category);
    _category = expense == null
        ? 'misc'
        : isCustom
            ? 'other'
            : expense.category;
    _customCategoryController = TextEditingController(
      text: isCustom ? expense.category : '',
    );
    _date = expense?.expenseDate ?? DateTime.now();
  }

  @override
  void dispose() {
    _amountController.dispose();
    _noteController.dispose();
    _customCategoryController.dispose();
    super.dispose();
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
      default:
        return tr('categoryOther');
    }
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) setState(() => _date = picked);
  }

  Future<void> _save(String Function(String) tr) async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    final amount = parsePkr(_amountController.text) ?? 0;
    final category = _category == 'other' &&
            _customCategoryController.text.trim().isNotEmpty
        ? _customCategoryController.text.trim().toLowerCase()
        : _category;
    final userId = ref.read(authStateProvider).user?.id ?? 'local-user';
    setState(() => _saving = true);
    try {
      final existing = widget.expense;
      if (existing == null) {
        await widget.repository.createExpense(
          Expense(
            id: '',
            category: category,
            amount: amount,
            expenseDate: _date,
            description: _noteController.text.trim().isEmpty
                ? null
                : _noteController.text.trim(),
            userId: userId,
            createdAt: DateTime.now(),
          ),
          userId: userId,
        );
      } else {
        await widget.repository.updateExpense(
          existing.copyWith(
            category: category,
            amount: amount,
            expenseDate: _date,
            description: _noteController.text.trim().isEmpty
                ? null
                : _noteController.text.trim(),
          ),
          userId: userId,
        );
      }
      if (!mounted) return;
      showSnack(context, tr('saved'));
      Navigator.of(context).pop();
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
    final isEdit = widget.expense != null;

    return Scaffold(
      appBar: CyberAppBar(
        title: tr(isEdit ? 'editExpense' : 'newExpense'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
          children: [
            Text(tr('expenseCategory'),
                style: CyberTextStyles.label(c, size: 13)),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              initialValue: _category,
              decoration: InputDecoration(labelText: tr('expenseCategory')),
              items: expenseCategories
                  .map(
                    (category) => DropdownMenuItem<String>(
                      value: category,
                      child: Text(_categoryLabel(category, tr)),
                    ),
                  )
                  .toList(),
              onChanged: (v) {
                if (v != null) setState(() => _category = v);
              },
            ),
            if (_category == 'other') ...[
              const SizedBox(height: 12),
              CyberTextField(
                controller: _customCategoryController,
                label: tr('customCategory'),
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? tr('fieldRequired') : null,
              ),
            ],
            const SizedBox(height: 12),
            CyberTextField(
              controller: _amountController,
              label: tr('amount'),
              keyboardType: TextInputType.number,
              monospace: true,
              prefixIcon: Icons.payments,
              autofocus: !isEdit,
              validator: (v) {
                final amount = parsePkr(v ?? '');
                if (amount == null || amount <= 0) return tr('invalidAmount');
                return null;
              },
              textInputAction: TextInputAction.next,
            ),
            const SizedBox(height: 12),
            CyberTextField(
              controller: _noteController,
              label: tr('note'),
              prefixIcon: Icons.note_alt_outlined,
              textInputAction: TextInputAction.done,
            ),
            const SizedBox(height: 16),
            Text(tr('date'), style: CyberTextStyles.label(c, size: 13)),
            const SizedBox(height: 8),
            InkWell(
              onTap: _pickDate,
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
                        fmtDate(_date),
                        style: CyberTextStyles.mono(c, size: 15),
                      ),
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
}
