import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/providers/app_providers.dart';
import '../../core/services/auth_service.dart';
import '../../data/sync/sync_engine.dart';
import 'auth_models.dart';

/// Auth state held by [AuthStateNotifier].
class AuthState {
  const AuthState({
    this.user,
    this.isLoading = false,
    this.error,
  });

  final AuthUser? user;
  final bool isLoading;
  final String? error;

  bool get isAuthenticated => user != null;

  AuthState copyWith({AuthUser? user, bool? isLoading, String? error}) =>
      AuthState(
        user: user ?? this.user,
        isLoading: isLoading ?? this.isLoading,
        error: error,
      );

  /// Clears only the error, keeping the user / loading state.
  AuthState clearError() => AuthState(user: user, isLoading: isLoading);

  /// Clears the user (logged out), keeping the error field empty.
  AuthState loggedOut() => const AuthState();
}

/// Riverpod StateNotifier for auth. Delegates every operation to the
/// injected [AuthService]; this class holds no credentials and performs
/// no network calls itself.
///
/// [syncEngine] is optional (tests may omit it). When present, a
/// successful login triggers a background sync so the app's local
/// database is populated from the server (products, variants,
/// customers, catalog) before the user starts working — otherwise
/// the local SQLite stays empty and POS finds nothing to sell.
class AuthStateNotifier extends StateNotifier<AuthState> {
  AuthStateNotifier(this._authService, [this._syncEngine])
      : super(const AuthState()) {
    _restoreSession();
  }

  final AuthService _authService;
  final SyncEngine? _syncEngine;

  Future<void> _restoreSession() async {
    state = state.copyWith(isLoading: true);
    try {
      final user = await _authService.currentUser();
      state = AuthState(user: user, isLoading: false);
    } catch (e) {
      state = AuthState(isLoading: false, error: e.toString());
    }
  }

  /// Logs in with username + password/PIN. On success the user is set;
  /// on failure [AuthState.error] is set and the login screen shows
  /// ACCESS DENIED.
  Future<bool> login(String username, String password) async {
    // Build the loading state directly (not via copyWith) so a previous
    // error is cleared: copyWith cannot set a field back to null.
    state = AuthState(user: state.user, isLoading: true);
    try {
      final user = await _authService.login(username, password);
      state = AuthState(user: user, isLoading: false);
      // Pull the server's master data (products, variants, customers,
      // catalog) into the local database now, so POS / stock / catalog
      // are populated. Fire-and-forget: a failed or slow sync must
      // never block or fail the login; the dashboard also syncs on
      // load and pull-to-refresh, and Settings has a Sync now button.
      _syncAfterLogin();
      return true;
    } catch (e) {
      state = AuthState(isLoading: false, error: _friendlyError(e));
      return false;
    }
  }

  /// Best-effort background sync after a successful login. Swallows
  /// every error: sync is never allowed to fail a login.
  void _syncAfterLogin() {
    final engine = _syncEngine;
    if (engine == null) return;
    engine.sync().then((_) {}).catchError((_) {});
  }

  /// Logs out: clears the server session/token and the local state.
  Future<void> logout() async {
    state = state.copyWith(isLoading: true);
    try {
      await _authService.logout();
    } catch (_) {
      // Logout is best-effort: even if the server call fails, the
      // local session must be cleared so the user is signed out.
    }
    state = const AuthState();
  }

  /// Biometric login: after local_auth confirms the fingerprint, the
  /// saved session (if any) is restored. Returns true when a session
  /// was restored; false means the user must enter their PIN/password.
  Future<bool> tryBiometricLogin() async {
    state = state.copyWith(isLoading: true);
    try {
      final user = await _authService.currentUser();
      if (user == null) {
        state = const AuthState();
        return false;
      }
      state = AuthState(user: user, isLoading: false);
      return true;
    } catch (e) {
      state = AuthState(isLoading: false, error: _friendlyError(e));
      return false;
    }
  }

  /// Refreshes the access token via the service. Returns true on success.
  Future<bool> refreshSession() async {
    try {
      final user = await _authService.refreshToken();
      state = AuthState(user: user, isLoading: false);
      return true;
    } catch (e) {
      state = AuthState(isLoading: false, error: _friendlyError(e));
      return false;
    }
  }

  void clearError() {
    if (state.error != null) state = state.clearError();
  }

  String _friendlyError(Object e) {
    final message = e.toString();
    // Dio / HTTP errors carry the server message after the colon; keep
    // the readable part and drop the exception class prefix.
    final cleaned = message.replaceFirst(RegExp(r'^[^:]+Exception:\s*'), '');
    return cleaned.isEmpty ? message : cleaned;
  }
}

/// Dependency-injection seam for [AuthService].
///
/// The data-layer agent (PLAN.md Round 1B) provides the concrete
/// Dio/JWT implementation and overrides this provider in the app's
/// ProviderScope. If it has not been overridden yet, reading it throws
/// a clear error naming the missing piece instead of failing silently.
final authServiceProvider = Provider<AuthService>((ref) {
  throw UnimplementedError(
    'AuthService has not been provided yet. The data-layer agent '
    '(PLAN.md Round 1B) must override authServiceProvider with the '
    'concrete Dio/JWT implementation.',
  );
});

final authStateProvider =
    StateNotifierProvider<AuthStateNotifier, AuthState>(
  (ref) => AuthStateNotifier(
    ref.watch(authServiceProvider),
    ref.watch(syncEngineProvider),
  ),
);
