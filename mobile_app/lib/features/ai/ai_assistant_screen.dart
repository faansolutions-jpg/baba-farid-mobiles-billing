library;

/// AI assistant (route `/ai`): chat-style screen over the local
/// rule-based [AiQueryEngine]. Answers come only from real shop data;
/// unknown questions get the capabilities list, never a made-up number.
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/l10n/app_strings.dart';
import '../../core/theme/app_theme.dart';
import '../../core/theme/cyber_colors.dart';
import '../../core/theme/cyber_text_styles.dart';
import '../../core/theme/cyber_widgets.dart';
import '../auth/auth_state.dart';
import '../../core/providers/app_providers.dart';
import 'ai_query_engine.dart';

class _ChatMessage {
  const _ChatMessage({
    required this.text,
    required this.isUser,
    this.answer,
  });

  final String text;
  final bool isUser;
  final AiAnswer? answer;
}

class AiAssistantScreen extends ConsumerStatefulWidget {
  const AiAssistantScreen({super.key});

  @override
  ConsumerState<AiAssistantScreen> createState() => _AiAssistantScreenState();
}

class _AiAssistantScreenState extends ConsumerState<AiAssistantScreen> {
  final _controller = TextEditingController();
  final _scrollController = ScrollController();
  final _messages = <_ChatMessage>[];
  bool _thinking = false;

  bool get _canSeeCosts {
    final role = ref.read(authStateProvider).user?.role ?? '';
    return role == 'owner' || role == 'manager';
  }

  Future<void> _ask(String question) async {
    final q = question.trim();
    if (q.isEmpty || _thinking) return;
    _controller.clear();
    setState(() {
      _messages.add(_ChatMessage(text: q, isUser: true));
      _thinking = true;
    });
    _scrollToBottom();
    try {
      final engine = AiQueryEngine(
        reports: ref.read(reportRepositoryProvider),
        products: ref.read(productRepositoryProvider),
        customers: ref.read(customerRepositoryProvider),
        expenses: ref.read(expenseRepositoryProvider),
      );
      final answer =
          await engine.answer(q, canSeeCosts: _canSeeCosts);
      if (!mounted) return;
      setState(() {
        _messages.add(
          _ChatMessage(text: answer.title, isUser: false, answer: answer),
        );
        _thinking = false;
      });
    } catch (e) {
      if (!mounted) return;
      final lang = ref.read(languageProvider);
      setState(() {
        _messages.add(_ChatMessage(
          text: AppStrings.tr('somethingWentWrong', language: lang),
          isUser: false,
        ));
        _thinking = false;
      });
    }
    _scrollToBottom();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final lang = ref.watch(languageProvider);
    String t(String key) => AppStrings.tr(key, language: lang);
    final c = ref.watch(themeNotifierProvider).colors;
    final chips = <String>[
      t('aiSuggestProfit'),
      t('aiSuggestLowStock'),
      t('aiSuggestUdhaar'),
      t('aiSuggestUnsold'),
    ];

    return Scaffold(
      appBar: CyberAppBar(title: t('aiAssistant')),
      body: Column(
        children: [
          Expanded(
            child: _messages.isEmpty
                ? ListView(
                    padding: const EdgeInsets.all(16),
                    children: [
                      CyberCard(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              t('aiAssistant'),
                              style: CyberTextStyles.title(c, size: 18),
                            ),
                            const SizedBox(height: 8),
                            Text(t('aiCanAnswer'),
                                style: CyberTextStyles.bodySecondary(c)),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(t('suggestedQuestions'),
                          style: CyberTextStyles.title(c, size: 16)),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: chips
                            .map(
                              (chip) => ActionChip(
                                label: Text(chip),
                                onPressed: () => _ask(chip),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                              ),
                            )
                            .toList(),
                      ),
                    ],
                  )
                : ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.all(16),
                    itemCount: _messages.length + (_thinking ? 1 : 0),
                    itemBuilder: (context, i) {
                      if (_thinking && i == _messages.length) {
                        return Align(
                          alignment: Alignment.centerLeft,
                          child: Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const SizedBox(
                                  width: 18,
                                  height: 18,
                                  child: CircularProgressIndicator(
                                      strokeWidth: 2),
                                ),
                                const SizedBox(width: 8),
                                Text(t('loading'),
                                    style:
                                        CyberTextStyles.bodySecondary(c)),
                              ],
                            ),
                          ),
                        );
                      }
                      return _bubble(_messages[i], t, c);
                    },
                  ),
          ),
          if (_messages.isNotEmpty)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              alignment: Alignment.centerLeft,
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: chips
                      .map(
                        (chip) => Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: ActionChip(
                            label: Text(chip),
                            onPressed: () => _ask(chip),
                          ),
                        ),
                      )
                      .toList(),
                ),
              ),
            ),
          Container(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 20),
            decoration: BoxDecoration(
              color: c.surface,
              border: Border(top: BorderSide(color: c.border)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: CyberTextField(
                    controller: _controller,
                    hint: t('askQuestion'),
                    textInputAction: TextInputAction.send,
                    onSubmitted: _ask,
                  ),
                ),
                const SizedBox(width: 8),
                SizedBox(
                  width: 48,
                  height: 48,
                  child: IconButton(
                    icon: Icon(Icons.send, color: c.onPrimary),
                    style: IconButton.styleFrom(
                      backgroundColor: c.primary,
                    ),
                    tooltip: t('confirm'),
                    onPressed: _thinking ? null : () => _ask(_controller.text),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _bubble(
    _ChatMessage message,
    String Function(String) t,
    CyberColors c,
  ) {
    final answer = message.answer;
    final bubble = Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: message.isUser ? c.primary : c.card,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: message.isUser ? c.primary : c.border,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            message.text,
            style: message.isUser
                ? CyberTextStyles.body(c, size: 15)
                    .copyWith(color: c.onPrimary)
                : CyberTextStyles.subtitle(c, size: 15),
          ),
          if (answer != null) ...[
            const SizedBox(height: 6),
            Text(answer.body, style: CyberTextStyles.bodySecondary(c)),
            if (answer.lines.isNotEmpty) ...[
              const SizedBox(height: 8),
              ...answer.lines.map(
                (line) => Padding(
                  padding: const EdgeInsets.only(top: 2),
                  child: Text('• $line',
                      style: CyberTextStyles.body(c, size: 14)),
                ),
              ),
            ],
            if (answer.route != null) ...[
              const SizedBox(height: 10),
              CyberButton(
                label: '${t('openScreen')} • ${answer.routeLabel ?? t('reports')}',
                variant: CyberButtonVariant.ghost,
                fullWidth: false,
                onPressed: () => context.push(answer.route!),
              ),
            ],
          ],
        ],
      ),
    );
    return Align(
      alignment:
          message.isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.85,
        ),
        margin: const EdgeInsets.only(bottom: 12),
        child: bubble,
      ),
    );
  }
}
