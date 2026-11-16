import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/config/app_config.dart';
import 'core/l10n/app_strings.dart';
import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';
import 'features/auth/auth_state.dart';

/// Root widget. Watches the theme + language providers and builds the
/// [MaterialApp.router] with the active cyberpunk theme, EN/UR locales
/// and localisation delegates, using [appRouter] for navigation.
///
/// The auth state is mirrored into the router ([updateRouterAuth]) so
/// its redirect can send signed-out users to `/login` and signed-in
/// users to `/dashboard`. The mirror is defensive: `AuthService` is
/// not wired in `main.dart` yet, so reading `authStateProvider` throws
/// until then — the `onError` path treats that as signed out instead
/// of crashing the app, and the update is deferred to a microtask so
/// the router is never notified in the middle of this build.
///
/// The splash screen owns boot navigation itself (it `context.go`s to
/// `/dashboard` or `/login` once its animation finishes and the
/// session restore is done); the router leaves `/` alone, so there is
/// no grace timer here.
class App extends ConsumerStatefulWidget {
  const App({super.key});

  @override
  ConsumerState<App> createState() => _AppState();
}

class _AppState extends ConsumerState<App> {
  @override
  Widget build(BuildContext context) {
    final themeState = ref.watch(themeNotifierProvider);
    final language = ref.watch(languageProvider);

    try {
      ref.listen<AuthState>(
        authStateProvider,
        (previous, next) {
          Future.microtask(
            () => updateRouterAuth(
              isAuthenticated: next.isAuthenticated,
              isLoading: next.isLoading,
            ),
          );
        },
        onError: (error, stackTrace) {
          Future.microtask(
            () => updateRouterAuth(
              isAuthenticated: false,
              isLoading: false,
            ),
          );
        },
      );
    } catch (_) {
      // Auth providers unavailable: the router treats the user as
      // signed out (its redirect sends protected routes to /login).
      Future.microtask(
        () => updateRouterAuth(
          isAuthenticated: false,
          isLoading: false,
        ),
      );
    }

    return MaterialApp.router(
      title: AppConfig.appName,
      debugShowCheckedModeBanner: false,
      theme: CyberTheme.themeFor(themeState.mode),
      routerConfig: appRouter,
      locale: Locale(language),
      supportedLocales: const <Locale>[
        Locale('en'),
        Locale('ur'),
      ],
      localizationsDelegates: const <LocalizationsDelegate<dynamic>>[
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
    );
  }
}
