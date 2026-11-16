import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/config/app_config.dart';
import '../../core/config/constants.dart';
import '../../core/l10n/app_strings.dart';
import '../../core/theme/app_theme.dart';
import '../../core/theme/cyber_text_styles.dart';
import 'auth_state.dart';

/// Boot splash: terminal-style typing animation, then the dashboard
/// (signed in) or the login screen (signed out).
///
/// Lines (from AppStrings, so they translate):
///   "Initializing database..." -> "Syncing..." -> "Access granted"
/// When animations are off in Settings, the animation is skipped and
/// navigation happens after a short delay.
///
/// Navigation is auth-aware and waits for the saved-session restore
/// ([authStateProvider]) to finish before choosing a destination, so
/// a signed-in user is never flashed through `/login`. It uses
/// `context.go` (go_router) — imperative `Navigator` calls crash
/// under go_router's page-based Navigator.
class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {
  final List<String> _shownLines = <String>[];
  String _currentTyping = '';
  bool _navigated = false;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    // Wait one frame so ref is usable, then start the boot sequence.
    WidgetsBinding.instance.addPostFrameCallback((_) => _startBoot());
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startBoot() {
    if (!mounted) return;
    final animationsEnabled =
        ref.read(themeNotifierProvider).animationsEnabled;
    final lang = ref.read(languageProvider);
    final lines = <String>[
      AppStrings.tr('splashInitializing', language: lang),
      AppStrings.tr('splashSyncing', language: lang),
      AppStrings.tr('splashAccessGranted', language: lang),
    ];

    if (!animationsEnabled) {
      // Animations off: show all lines at once, then move on quickly.
      setState(() {
        _shownLines.addAll(lines);
        _currentTyping = '';
      });
      _timer = Timer(const Duration(milliseconds: 500), _goToDestination);
      return;
    }

    var lineIndex = 0;
    var charIndex = 0;
    _timer = Timer.periodic(const Duration(milliseconds: 45), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      final line = lines[lineIndex];
      if (charIndex < line.length) {
        charIndex++;
        setState(() => _currentTyping = line.substring(0, charIndex));
      } else {
        setState(() {
          _shownLines.add(line);
          _currentTyping = '';
        });
        charIndex = 0;
        lineIndex++;
        if (lineIndex >= lines.length) {
          timer.cancel();
          _timer = Timer(
            const Duration(milliseconds: 600),
            _goToDestination,
          );
        } else {
          // Brief pause between lines.
          timer.cancel();
          _timer = Timer(
            const Duration(milliseconds: AppConstants.splashLineDelayMs),
            () {
              if (mounted) _startTypingFrom(lineIndex, lines);
            },
          );
        }
      }
    });
  }

  void _startTypingFrom(int lineIndex, List<String> lines) {
    var charIndex = 0;
    _timer = Timer.periodic(const Duration(milliseconds: 45), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      final line = lines[lineIndex];
      if (charIndex < line.length) {
        charIndex++;
        setState(() => _currentTyping = line.substring(0, charIndex));
      } else {
        setState(() {
          _shownLines.add(line);
          _currentTyping = '';
        });
        timer.cancel();
        if (lineIndex + 1 >= lines.length) {
          _timer = Timer(
            const Duration(milliseconds: 600),
            _goToDestination,
          );
        } else {
          _timer = Timer(
            const Duration(milliseconds: AppConstants.splashLineDelayMs),
            () {
              if (mounted) _startTypingFrom(lineIndex + 1, lines);
            },
          );
        }
      }
    });
  }

  /// Navigates once the boot animation has finished — but only after
  /// the saved-session restore has finished too, so the destination
  /// reflects the real auth state: signed in -> `/dashboard`, anything
  /// else -> `/login`. Safe if the widget unmounts while waiting.
  Future<void> _goToDestination() async {
    if (_navigated) return;
    // Wait for session restore to finish before choosing.
    var auth = ref.read(authStateProvider);
    while (auth.isLoading && mounted) {
      await Future<void>.delayed(const Duration(milliseconds: 200));
      if (!mounted) return;
      auth = ref.read(authStateProvider);
    }
    if (_navigated || !mounted) return;
    _navigated = true;
    context.go(auth.isAuthenticated ? '/dashboard' : '/login');
  }

  @override
  Widget build(BuildContext context) {
    final theme = ref.watch(themeNotifierProvider);
    final c = theme.colors;
    final lang = ref.watch(languageProvider);
    final isUrdu = AppStrings.isUrdu(lang);

    return Scaffold(
      backgroundColor: c.background,
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(AppConstants.paddingLarge),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(
                  'assets/logo.png',
                  width: 120,
                  height: 120,
                  fit: BoxFit.contain,
                  errorBuilder: (_, e, s) => Icon(
                    Icons.phone_android,
                    size: 96,
                    color: c.primary,
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  AppConfig.shopName.toUpperCase(),
                  style: CyberTextStyles.headline(c, size: 26),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 4),
                Text(
                  AppStrings.tr('appTagline', language: lang),
                  style: CyberTextStyles.bodySecondary(c),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 48),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: c.surface,
                    border: Border.all(color: c.border),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      for (final line in _shownLines)
                        Text(
                          '> $line',
                          style: CyberTextStyles.terminal(c, size: 14),
                        ),
                      if (_currentTyping.isNotEmpty)
                        Text(
                          '> $_currentTyping▌',
                          style: CyberTextStyles.terminal(c, size: 14),
                        ),
                      if (_shownLines.isEmpty && _currentTyping.isEmpty)
                        Text(
                          '> ▌',
                          style: CyberTextStyles.terminal(c, size: 14),
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  'v${AppConfig.version}',
                  style: CyberTextStyles.mono(c, size: 12)
                      .copyWith(color: c.textSecondary),
                ),
                if (isUrdu) ...[
                  const SizedBox(height: 8),
                  Text(
                    AppStrings.tr('appName', language: lang),
                    style: CyberTextStyles.urdu(c, size: 18),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
