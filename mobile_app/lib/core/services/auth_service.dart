import '../../features/auth/auth_models.dart';

/// Authentication contract. The concrete implementation (Dio + JWT,
/// token in flutter_secure_storage) is provided by the data-layer agent
/// (PLAN.md Round 1B) and injected through [authServiceProvider] in
/// `lib/features/auth/auth_state.dart`. Screens depend only on this
/// abstract class, never on the implementation.
abstract class AuthService {
  Future<AuthUser> login(String username, String password);
  Future<void> logout();
  Future<AuthUser?> currentUser();
  Future<String?> accessToken();
  Future<AuthUser> refreshToken();
  Stream<AuthUser?> get authStateChanges;
}
