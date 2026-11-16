/// Logged-in user, as returned by the backend auth endpoints.
/// Real backend shape (`POST /api/v1/login`, `GET /api/v1/me`):
/// `{ id, name, phone, role, branchId }` plus top-level
/// `accessToken` / `refreshToken`. (`/me` returns the raw user row, so
/// `role_name` / `branch_id` snake_case variants are accepted too.)
///
/// Locally the user is stored via [toJson] as
/// `{ id, username, display_name, role, branch_id }` where `username`
/// holds the phone number (the login identifier), plus `token` /
/// `refresh_token` added by the auth service — [fromJson] accepts
/// both shapes so a stored session round-trips.
class AuthUser {
  final String id;
  final String username;
  final String displayName;
  final String role;
  final String branchId;
  final String? token;
  final String? refreshToken;
  const AuthUser({required this.id, required this.username, required this.displayName, required this.role, required this.branchId, this.token, this.refreshToken});
  factory AuthUser.fromJson(Map<String, dynamic> json) => AuthUser(
        id: json['id'] as String? ?? '',
        // Login identifier is the phone number; stored sessions keep
        // it under `username`.
        username: json['phone'] as String? ?? json['username'] as String? ?? '',
        displayName: json['name'] as String? ??
            json['display_name'] as String? ??
            json['phone'] as String? ??
            json['username'] as String? ??
            '',
        role: json['role'] as String? ?? json['role_name'] as String? ?? '',
        branchId: json['branchId'] as String? ??
            json['branch_id'] as String? ??
            'main',
        token: json['token'] as String? ?? json['accessToken'] as String?,
        refreshToken:
            json['refresh_token'] as String? ?? json['refreshToken'] as String?,
      );
  Map<String, dynamic> toJson() => {'id': id, 'username': username, 'display_name': displayName, 'role': role, 'branch_id': branchId};
}
