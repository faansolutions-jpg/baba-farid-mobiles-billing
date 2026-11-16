import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app.dart';
import 'core/config/app_config.dart';
import 'core/l10n/app_strings.dart';
import 'core/theme/app_theme.dart';
import 'core/theme/cyber_colors.dart';
import 'data/api/api_client.dart';
import 'data/services/api_auth_service.dart';
import 'data/storage/secure_storage.dart';
import 'features/auth/auth_state.dart';

/// Entry point.
///
/// Loads persisted settings (theme, language, animations) from
/// SharedPreferences before the first frame, then runs the app inside
/// a [ProviderScope] with those settings as provider overrides.
/// The [App] widget is the MaterialApp whose home is the splash screen.
///
/// The concrete [AuthService] is wired here: an [ApiClient] plus
/// [SecureStorage] back the [ApiAuthService], which is injected via an
/// override of `authServiceProvider` (see
/// `lib/features/auth/auth_state.dart`). The [ApiAuthService]
/// constructor sets `client.authService = itself`, so the client's JWT
/// interceptor can refresh tokens through it.
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final prefs = await SharedPreferences.getInstance();
  final themeMode = CyberThemeMode.fromString(
    prefs.getString(AppConfig.themeKey) ?? AppConfig.defaultTheme,
  );
  final animationsEnabled =
      prefs.getBool(AppConfig.animationsEnabledKey) ?? true;
  final language =
      prefs.getString(AppConfig.languageKey) ?? AppConfig.defaultLanguage;

  final apiClient = ApiClient();
  final authService = ApiAuthService(apiClient, SecureStorage());

  runApp(
    ProviderScope(
      overrides: [
        authServiceProvider.overrideWith((ref) => authService),
        themeNotifierProvider.overrideWith(
          (ref) => ThemeNotifier(
            initial: ThemeState(
              mode: themeMode,
              animationsEnabled: animationsEnabled,
            ),
          ),
        ),
        languageProvider.overrideWith((ref) => language),
      ],
      child: const App(),
    ),
  );
}
