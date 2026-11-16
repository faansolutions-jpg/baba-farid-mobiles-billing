/// API-backed [AuthService]: login / refresh / logout against
/// `POST /api/v1/login`, `POST /api/v1/refresh`, `POST /api/v1/logout`,
/// with tokens in [SecureStorage].
///
/// The login identifier is the user's phone number, sent as `phone`.
/// The refresh endpoint returns only `{ accessToken, refreshToken }`
/// (no user object), so [refreshToken] re-attaches the stored user.
///
/// Passwords are never logged and never stored. The access token lives
/// in flutter_secure_storage; the cached user JSON lives there too.
/// Wire-up (composition root, `lib/main.dart`):
/// ```dart
/// final apiClient = ApiClient();
/// final authService = ApiAuthService(apiClient, SecureStorage());
/// apiClient.authService = authService;
/// ```
library;

import 'dart:async';
import 'dart:convert';

import '../../core/services/auth_service.dart';
import '../../features/auth/auth_models.dart';
import '../api/api_client.dart';
import '../storage/secure_storage.dart';

class ApiAuthService implements AuthService {
  final ApiClient _client;
  final SecureStorage _storage;
  final StreamController<AuthUser?> _controller =
      StreamController<AuthUser?>.broadcast();

  ApiAuthService(this._client, this._storage) {
    // The client needs this service for its JWT interceptor.
    _client.authService = this;
  }

  @override
  Stream<AuthUser?> get authStateChanges => _controller.stream;

  @override
  Future<AuthUser> login(String username, String password) async {
    // `username` is the phone number: the backend looks the user up
    // by `phone` exactly. Passwords are sent over HTTPS only and never
    // logged or stored.
    final data = await _client.post('/api/v1/login', data: {
      'phone': username,
      'password': password,
    });
    return _saveSession(data);
  }

  @override
  Future<AuthUser> refreshToken() async {
    final refresh = await _storage.readRefreshToken();
    if (refresh == null || refresh.isEmpty) {
      throw const ApiException('No refresh token — please log in again',
          statusCode: 401);
    }
    final data = await _client.post('/api/v1/refresh', data: {
      'refreshToken': refresh,
    });
    if (data is! Map<String, dynamic>) {
      throw const ApiException('Unexpected refresh response from server');
    }
    final token = (data['accessToken'] ?? data['token']) as String?;
    final newRefresh =
        (data['refreshToken'] ?? data['refresh_token']) as String?;
    if (token == null || token.isEmpty) {
      throw const ApiException('Refresh response has no access token');
    }
    // The refresh endpoint returns only tokens — no user object.
    // Save the new tokens first so any follow-up call (e.g. /me)
    // already carries the fresh access token, then re-attach the
    // currently stored user with the new tokens; if there is no
    // stored user, fetch it from GET /api/v1/me.
    await _storage.writeAccessToken(token);
    if (newRefresh != null && newRefresh.isNotEmpty) {
      await _storage.writeRefreshToken(newRefresh);
    }
    AuthUser? user;
    final userJson = data['user'];
    if (userJson is Map<String, dynamic>) {
      user = AuthUser.fromJson(userJson);
    } else {
      user = await currentUser();
      if (user == null) {
        final me = await _client.get('/api/v1/me');
        if (me is! Map<String, dynamic>) {
          throw const ApiException(
              'Could not restore the user after refresh');
        }
        user = AuthUser.fromJson(me);
      }
    }
    final refreshed = _withToken(user, token, newRefresh);
    final stored = refreshed.toJson();
    stored['token'] = token;
    if (newRefresh != null) stored['refresh_token'] = newRefresh;
    await _storage.writeAuthUser(jsonEncode(stored));
    _controller.add(refreshed);
    return refreshed;
  }

  @override
  Future<void> logout() async {
    try {
      await _client.post('/api/v1/logout');
    } catch (_) {
      // Logout is best-effort: local session is cleared regardless.
    }
    await _storage.deleteAccessToken();
    await _storage.deleteRefreshToken();
    await _storage.deleteAuthUser();
    _controller.add(null);
  }

  @override
  Future<AuthUser?> currentUser() async {
    final raw = await _storage.readAuthUser();
    if (raw == null || raw.isEmpty) return null;
    try {
      final user = AuthUser.fromJson(
          jsonDecode(raw) as Map<String, dynamic>);
      // Attach the stored tokens so callers get a usable user.
      final token = await _storage.readAccessToken();
      if (token == null) return user;
      final refresh = await _storage.readRefreshToken();
      return _withToken(user, token, refresh ?? user.refreshToken);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<String?> accessToken() => _storage.readAccessToken();

  AuthUser _withToken(AuthUser user, String token, [String? refreshToken]) {
    // AuthUser is owned by another agent; rebuild via JSON so this
    // file never assumes extra constructors. NOTE: AuthUser.toJson()
    // omits token/refresh_token, so both are re-added explicitly.
    final json = user.toJson();
    json['token'] = token;
    json['refresh_token'] = refreshToken ?? user.refreshToken;
    return AuthUser.fromJson(json);
  }

  Future<AuthUser> _saveSession(dynamic data) async {
    if (data is! Map<String, dynamic>) {
      throw const ApiException('Unexpected login response from server');
    }
    final userJson = data['user'];
    if (userJson is! Map<String, dynamic>) {
      throw const ApiException('Login response has no user');
    }
    final token = (data['token'] ?? data['accessToken']) as String?;
    final refresh =
        (data['refreshToken'] ?? data['refresh_token']) as String?;
    if (token == null || token.isEmpty) {
      throw const ApiException('Login response has no access token');
    }
    final user = _withToken(AuthUser.fromJson(userJson), token, refresh);
    await _storage.writeAccessToken(token);
    if (refresh != null && refresh.isNotEmpty) {
      await _storage.writeRefreshToken(refresh);
    }
    // Store the full session JSON (toJson() omits the tokens).
    final stored = user.toJson();
    stored['token'] = token;
    if (refresh != null) stored['refresh_token'] = refresh;
    await _storage.writeAuthUser(jsonEncode(stored));
    _controller.add(user);
    return user;
  }

  /// Closes the auth stream. Called by the composition root on dispose.
  void dispose() {
    _controller.close();
  }
}
