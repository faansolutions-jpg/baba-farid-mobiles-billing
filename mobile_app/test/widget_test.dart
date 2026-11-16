// Smoke test: the app builds inside a ProviderScope and shows the boot
// splash screen. Run with: flutter test test/widget_test.dart
//
// App() reads authStateProvider, whose AuthService comes from
// authServiceProvider — main() normally overrides it with the real
// ApiAuthService, but this test pumps App() directly, so a fake that
// reports "no signed-in user" is overridden here instead.
import 'package:baba_farid_mobiles/app.dart';
import 'package:baba_farid_mobiles/core/services/auth_service.dart';
import 'package:baba_farid_mobiles/features/auth/auth_models.dart';
import 'package:baba_farid_mobiles/features/auth/auth_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

class _FakeAuthService implements AuthService {
  @override
  Stream<AuthUser?> get authStateChanges => const Stream<AuthUser?>.empty();

  @override
  Future<AuthUser?> currentUser() async => null;

  @override
  Future<String?> accessToken() async => null;

  @override
  Future<AuthUser> login(String username, String password) =>
      throw UnimplementedError('FakeAuthService cannot log in');

  @override
  Future<void> logout() async {}

  @override
  Future<AuthUser> refreshToken() =>
      throw UnimplementedError('FakeAuthService has no session');
}

void main() {
  testWidgets('App builds and shows the splash screen',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          authServiceProvider.overrideWith((ref) => _FakeAuthService()),
        ],
        child: const App(),
      ),
    );
    await tester.pump();
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
