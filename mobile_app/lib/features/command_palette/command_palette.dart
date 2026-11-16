library;

/// Command palette (route `/command`, also opened from the dashboard
/// app-bar terminal icon): terminal-style input with a `> ` prompt,
/// autocomplete from the command list + persisted history, up/down
/// history recall, and execution via [CommandParser].
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/l10n/app_strings.dart';
import '../../core/theme/app_theme.dart';
import '../../core/theme/cyber_text_styles.dart';
import '../../core/theme/cyber_widgets.dart';
import '../../domain/models/expense.dart';
import '../auth/auth_state.dart';
import '../../core/providers/app_providers.dart';
import '../dashboard/shop_helpers.dart';
import 'command_parser.dart';

const String _historyKey = 'command_history';
const int _maxHistory = 20;

class CommandPaletteScreen extends ConsumerStatefulWidget {
  const CommandPaletteScreen({super.key});

  @override
  ConsumerState<CommandPaletteScreen> createState() =>
      _CommandPaletteScreenState();
}

class _CommandPaletteScreenState extends ConsumerState<CommandPaletteScreen> {
  final _controller = TextEditingController();
  final _focusNode = FocusNode();
  final _output = <String>[];
  List<String> _history = [];
  int _historyIndex = -1;
  String _draft = '';

  @override
  void initState() {
    super.initState();
    _loadHistory();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  Future<void> _loadHistory() async {
    final prefs = await SharedPreferences.getInstance();
    if (!mounted) return;
    setState(() {
      _history = prefs.getStringList(_historyKey) ?? [];
    });
  }

  Future<void> _saveHistory(String command) async {
    final prefs = await SharedPreferences.getInstance();
    final updated = <String>[command, ..._history.where((h) => h != command)]
        .take(_maxHistory)
        .toList();
    await prefs.setStringList(_historyKey, updated);
    if (mounted) setState(() => _history = updated);
  }

  void _print(String line) {
    setState(() => _output.add(line));
  }

  Future<void> _execute(String rawInput) async {
    final input = rawInput.trim();
    if (input.isEmpty) return;
    _print('> $input');
    await _saveHistory(input);
    _historyIndex = -1;
    _draft = '';
    _controller.clear();

    final parsed = CommandParser.parse(input);
    final lang = ref.read(languageProvider);
    String t(String key) => AppStrings.tr(key, language: lang);

    switch (parsed.kind) {
      case CommandKind.empty:
        break;
      case CommandKind.help:
        _print(t('commandHelp'));
        for (final line in CommandParser.commandList) {
          _print('  $line');
        }
      case CommandKind.unknown:
        _print(t('unknownCommand'));
      case CommandKind.expense:
        await _createExpense(parsed, t);
      case CommandKind.sell:
      case CommandKind.findImei:
      case CommandKind.ledger:
      case CommandKind.stock:
      case CommandKind.reportToday:
        final route = parsed.route;
        if (route != null && mounted) context.push(route);
    }
  }

  Future<void> _createExpense(
    ParsedCommand parsed,
    String Function(String) t,
  ) async {
    try {
      final repo = ref.read(expenseRepositoryProvider);
      final userId = ref.read(authStateProvider).user?.id ?? 'unknown';
      final now = DateTime.now();
      await repo.createExpense(
        Expense(
          id: '',
          category: ExpenseCategory.other,
          amount: parsed.amount!,
          expenseDate: now,
          description: parsed.note.isEmpty ? null : parsed.note,
          userId: userId,
          createdAt: now,
        ),
        userId: userId,
      );
      _print('${t('expenseAdded')} ${formatPkr(parsed.amount!)}'
          '${parsed.note.isEmpty ? '' : ' — ${parsed.note}'}');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(t('expenseAdded'))),
        );
      }
    } catch (e) {
      _print('${t('error')}: $e');
    }
  }

  KeyEventResult _onKey(FocusNode node, KeyEvent event) {
    if (event is! KeyDownEvent) return KeyEventResult.ignored;
    if (event.logicalKey == LogicalKeyboardKey.arrowUp) {
      if (_history.isEmpty) return KeyEventResult.handled;
      if (_historyIndex == -1) _draft = _controller.text;
      if (_historyIndex < _history.length - 1) {
        _historyIndex++;
        _controller.text = _history[_historyIndex];
        _controller.selection = TextSelection.fromPosition(
          TextPosition(offset: _controller.text.length),
        );
        setState(() {});
      }
      return KeyEventResult.handled;
    }
    if (event.logicalKey == LogicalKeyboardKey.arrowDown) {
      if (_historyIndex > 0) {
        _historyIndex--;
        _controller.text = _history[_historyIndex];
      } else if (_historyIndex == 0) {
        _historyIndex = -1;
        _controller.text = _draft;
      }
      _controller.selection = TextSelection.fromPosition(
        TextPosition(offset: _controller.text.length),
      );
      setState(() {});
      return KeyEventResult.handled;
    }
    return KeyEventResult.ignored;
  }

  @override
  Widget build(BuildContext context) {
    final lang = ref.watch(languageProvider);
    String t(String key) => AppStrings.tr(key, language: lang);
    final c = ref.watch(themeNotifierProvider).colors;
    final suggestions =
        CommandParser.suggestions(_controller.text, _history);

    return Scaffold(
      appBar: CyberAppBar(title: t('commandPalette')),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _output.length,
              itemBuilder: (context, i) => Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Text(
                  _output[i],
                  style: CyberTextStyles.mono(c, size: 14),
                ),
              ),
            ),
          ),
          if (suggestions.isNotEmpty)
            Container(
              decoration: BoxDecoration(
                color: c.surface,
                border: Border(top: BorderSide(color: c.border)),
              ),
              constraints: const BoxConstraints(maxHeight: 180),
              child: ListView(
                shrinkWrap: true,
                children: suggestions
                    .map(
                      (s) => ListTile(
                        dense: true,
                        minTileHeight: 48,
                        title: Text(s,
                            style: CyberTextStyles.mono(c, size: 14)),
                        onTap: () {
                          _controller.text = s;
                          _controller.selection = TextSelection.fromPosition(
                            TextPosition(offset: s.length),
                          );
                          _focusNode.requestFocus();
                          setState(() {});
                        },
                      ),
                    )
                    .toList(),
              ),
            ),
          Container(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
            decoration: BoxDecoration(
              color: c.surface,
              border: Border(top: BorderSide(color: c.primary)),
            ),
            child: Focus(
              onKeyEvent: _onKey,
              child: Row(
                children: [
                  Text('> ', style: CyberTextStyles.mono(c, size: 18)
                      .copyWith(color: c.primary)),
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      focusNode: _focusNode,
                      autofocus: true,
                      cursorColor: c.primary,
                      style: CyberTextStyles.mono(c, size: 16),
                      textInputAction: TextInputAction.done,
                      decoration: InputDecoration(
                        hintText: t('typeCommand'),
                        border: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        focusedBorder: InputBorder.none,
                      ),
                      onChanged: (_) => setState(() {}),
                      onSubmitted: _execute,
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.send, color: c.primary),
                    tooltip: t('confirm'),
                    onPressed: () => _execute(_controller.text),
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
