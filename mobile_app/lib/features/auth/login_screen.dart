import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:local_auth/local_auth.dart';

import '../../core/config/app_config.dart';
import '../../core/config/constants.dart';
import '../../core/l10n/app_strings.dart';
import '../../core/theme/app_theme.dart';
import '../../core/theme/cyber_text_styles.dart';
import '../../core/theme/cyber_widgets.dart';
import 'auth_state.dart';

/// Terminal-style login screen.
///
/// Phone number + password/PIN fields, a login button, and a biometric
/// button (local_auth; falls back to the PIN field when biometrics are
/// unavailable or fail). Shows ACCESS GRANTED in green or ACCESS DENIED
/// in red (with a glitch-style red shadow) after an attempt.
///
/// The identifier is the user's phone number (the backend looks the
/// user up by `phone`); it is passed as the `username` argument of
/// [AuthService.login].
///
/// On success the session is saved by [AuthService] (via the auth
/// notifier) and the app navigates to `/dashboard`. That route is
/// registered by Round 2 — until then the navigation is guarded: if
/// the route does not exist yet, a clear message is shown instead of
/// a crash. Pass [onLoginSuccess] to override navigation (e.g. tests
/// or the Round 2 router).
class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key, this.onLoginSuccess});

  /// Called instead of `Navigator.pushNamed('/dashboard')` after a
  /// successful login, when provided.
  final VoidCallback? onLoginSuccess;

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _passwordFocus = FocusNode();
  final LocalAuthentication _localAuth = LocalAuthentication();

  bool _obscurePassword = true;
  bool _biometricBusy = false;
  bool _showGranted = false;
  bool _showDenied = false;

  @override
  void dispose() {
    _phoneController.dispose();
    _passwordController.dispose();
    _passwordFocus.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;
    FocusScope.of(context).unfocus();
    setState(() {
      _showGranted = false;
      _showDenied = false;
    });
    final ok = await ref.read(authStateProvider.notifier).login(
          _phoneController.text.trim(),
          _passwordController.text,
        );
    if (!mounted) return;
    if (ok) {
      setState(() => _showGranted = true);
      // Brief green flash so the user sees ACCESS GRANTED, then go.
      await Future<void>.delayed(const Duration(milliseconds: 700));
      if (mounted) _goToDashboard();
    } else {
      setState(() => _showDenied = true);
    }
  }

  void _goToDashboard() {
    if (widget.onLoginSuccess != null) {
      widget.onLoginSuccess!();
      return;
    }
    // go_router owns navigation: context.go replaces the login route
    // instead of pushing on top of it.
    if (!mounted) return;
    context.go(AppRoutes.dashboard);
  }

  /// Biometric login: fingerprint via local_auth. On success the saved
  /// session is restored; if there is no saved session (or biometrics
  /// are unavailable / fail) the user falls back to the PIN field.
  Future<void> _biometricLogin() async {
    if (_biometricBusy) return;
    setState(() => _biometricBusy = true);
    final lang = ref.read(languageProvider);
    try {
      final canCheck = await _localAuth.canCheckBiometrics;
      final available = canCheck || await _localAuth.isDeviceSupported();
      if (!available) {
        _showInfo(AppStrings.tr('biometricNotAvailable', language: lang));
        _passwordFocus.requestFocus();
        return;
      }
      final authenticated = await _localAuth.authenticate(
        localizedReason: AppStrings.tr('biometricLogin', language: lang),
        options: const AuthenticationOptions(
          biometricOnly: true,
          stickyAuth: true,
        ),
      );
      if (!authenticated) {
        _showInfo(AppStrings.tr('biometricFailed', language: lang));
        _passwordFocus.requestFocus();
        return;
      }
      final restored =
          await ref.read(authStateProvider.notifier).tryBiometricLogin();
      if (!mounted) return;
      if (restored) {
        setState(() => _showGranted = true);
        await Future<void>.delayed(const Duration(milliseconds: 500));
        if (mounted) _goToDashboard();
      } else {
        // Fingerprint OK but no saved session: fall back to PIN.
        _showInfo(AppStrings.tr('biometricNeedsPin', language: lang));
        _passwordFocus.requestFocus();
      }
    } on PlatformException {
      _showInfo(AppStrings.tr('biometricFailed', language: lang));
      _passwordFocus.requestFocus();
    } finally {
      if (mounted) setState(() => _biometricBusy = false);
    }
  }

  void _showInfo(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = ref.watch(themeNotifierProvider);
    final c = theme.colors;
    final lang = ref.watch(languageProvider);
    final auth = ref.watch(authStateProvider);

    // React to an error set by the notifier (e.g. a refresh in the
    // background) by showing the denied banner.
    ref.listen<AuthState>(authStateProvider, (previous, next) {
      if (next.error != null && mounted && !_showDenied) {
        setState(() => _showDenied = true);
      }
    });

    return Scaffold(
      backgroundColor: c.background,
      appBar: CyberAppBar(
        title: AppStrings.tr('loginTitle', language: lang),
        showBack: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.language),
            tooltip: AppStrings.tr('language', language: lang),
            onPressed: () {
              ref.read(languageProvider.notifier).state =
                  AppStrings.isUrdu(lang) ? 'en' : 'ur';
            },
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppConstants.paddingLarge),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 16),
                Image.asset(
                  'assets/logo.png',
                  width: 96,
                  height: 96,
                  fit: BoxFit.contain,
                  errorBuilder: (_, e, s) => Icon(
                    Icons.phone_android,
                    size: 80,
                    color: c.primary,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  AppConfig.shopName.toUpperCase(),
                  style: CyberTextStyles.headline(c, size: 22),
                  textAlign: TextAlign.center,
                ),
                Text(
                  AppStrings.tr('appTagline', language: lang),
                  style: CyberTextStyles.bodySecondary(c),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),
                // Feedback banner: ACCESS GRANTED / ACCESS DENIED.
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 250),
                  child: _showGranted
                      ? _FeedbackBanner(
                          key: const ValueKey('granted'),
                          text: AppStrings.tr('accessGranted', language: lang),
                          color: c.success,
                          glitch: false,
                        )
                      : _showDenied
                          ? _FeedbackBanner(
                              key: const ValueKey('denied'),
                              text:
                                  AppStrings.tr('accessDenied', language: lang),
                              color: c.error,
                              glitch: true,
                              subtext: auth.error ??
                                  AppStrings.tr(
                                    'invalidCredentials',
                                    language: lang,
                                  ),
                            )
                          : const SizedBox(key: ValueKey('none'), height: 8),
                ),
                const SizedBox(height: 16),
                CyberTextField(
                  controller: _phoneController,
                  label: AppStrings.tr('phoneNumber', language: lang),
                  hint: AppStrings.tr('phoneNumberHint', language: lang),
                  prefixIcon: Icons.phone_outlined,
                  keyboardType: TextInputType.phone,
                  textInputAction: TextInputAction.next,
                  onSubmitted: (_) => _passwordFocus.requestFocus(),
                  validator: (v) => (v == null || v.trim().isEmpty)
                      ? AppStrings.tr('requiredField', language: lang)
                      : null,
                ),
                const SizedBox(height: 16),
                CyberTextField(
                  controller: _passwordController,
                  label: AppStrings.tr('password', language: lang),
                  hint: AppStrings.tr('passwordHint', language: lang),
                  prefixIcon: Icons.lock_outline,
                  obscureText: _obscurePassword,
                  textInputAction: TextInputAction.done,
                  onSubmitted: (_) => _login(),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscurePassword
                          ? Icons.visibility_outlined
                          : Icons.visibility_off_outlined,
                      color: c.primary,
                    ),
                    onPressed: () => setState(
                      () => _obscurePassword = !_obscurePassword,
                    ),
                  ),
                  validator: (v) => (v == null || v.isEmpty)
                      ? AppStrings.tr('requiredField', language: lang)
                      : null,
                ),
                const SizedBox(height: 24),
                CyberButton(
                  label: AppStrings.tr('loginButton', language: lang),
                  icon: Icons.login,
                  isLoading: auth.isLoading,
                  onPressed: auth.isLoading ? null : _login,
                ),
                const SizedBox(height: 12),
                CyberButton(
                  label: AppStrings.tr('biometricLogin', language: lang),
                  icon: Icons.fingerprint,
                  variant: CyberButtonVariant.ghost,
                  isLoading: _biometricBusy,
                  onPressed: (_biometricBusy || auth.isLoading)
                      ? null
                      : _biometricLogin,
                ),
                const SizedBox(height: 24),
                Text(
                  '${AppConfig.shopAddress}\n${AppConfig.ownerName} '
                  '${AppConfig.ownerPhoneDisplay} · '
                  '${AppConfig.staffName} ${AppConfig.staffPhoneDisplay}',
                  style: CyberTextStyles.caption(c),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Green/red feedback banner. The denied banner uses a red offset
/// shadow stack for a glitch effect.
class _FeedbackBanner extends StatelessWidget {
  const _FeedbackBanner({
    super.key,
    required this.text,
    required this.color,
    required this.glitch,
    this.subtext,
  });

  final String text;
  final Color color;
  final bool glitch;
  final String? subtext;

  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (context, ref, _) {
        final c = ref.watch(themeNotifierProvider).colors;
        final titleStyle = CyberTextStyles.mono(c, size: 18).copyWith(
          fontWeight: FontWeight.w800,
          color: color,
          letterSpacing: 2,
          shadows: glitch
              ? [
                  Shadow(color: color.withValues(alpha: 0.7), offset: const Offset(2, 0)),
                  Shadow(color: c.secondary.withValues(alpha: 0.5), offset: const Offset(-2, 0)),
                ]
              : null,
        );
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.12),
            border: Border.all(color: color, width: 1.5),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Column(
            children: [
              Text(text, style: titleStyle, textAlign: TextAlign.center),
              if (subtext != null) ...[
                const SizedBox(height: 4),
                Text(
                  subtext!,
                  style: CyberTextStyles.bodySecondary(c, size: 13),
                  textAlign: TextAlign.center,
                ),
              ],
            ],
          ),
        );
      },
    );
  }
}
