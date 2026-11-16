library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/l10n/app_strings.dart';
import '../../core/theme/app_theme.dart';
import '../../core/theme/cyber_text_styles.dart';
import '../../core/theme/cyber_widgets.dart';
import '../auth/auth_state.dart';

/// Admin-approval dialog for a below-minimum-price sale
/// (DECISIONS.md #13).
///
/// The cashier enters an owner/manager username + password. Verification
/// goes through [AuthService.login] (the only credential check the auth
/// layer exposes) via [authServiceProvider]; the returned user's role
/// must be `owner` or `manager` — a cashier's own credentials are
/// rejected, and a cashier can never approve their own sale.
/// Returns the approving admin's username, or null when cancelled /
/// rejected.
Future<String?> showAdminApprovalDialog(
  BuildContext context, {
  required String reason,
}) async {
  final usernameController = TextEditingController();
  final passwordController = TextEditingController();
  final result = await showDialog<String>(
    context: context,
    barrierDismissible: false,
    builder: (context) => Consumer(
      builder: (context, ref, _) {
        final c = ref.watch(themeNotifierProvider).colors;
        final lang = ref.watch(languageProvider);
        String tr(String key) => AppStrings.tr(key, language: lang);
        var busy = false;
        String? error;
        return StatefulBuilder(
          builder: (context, setDialogState) => CyberDialog(
            title: tr('adminApproval'),
            actions: [
              TextButton(
                onPressed: busy ? null : () => Navigator.of(context).pop(),
                child: Text(tr('cancel')),
              ),
              CyberButton(
                label: tr('approve'),
                fullWidth: false,
                isLoading: busy,
                onPressed: () async {
                  final ok = await _verify(
                    ref,
                    usernameController.text.trim(),
                    passwordController.text,
                    (message) => setDialogState(() => error = message),
                    (value) => setDialogState(() => busy = value),
                    tr,
                  );
                  if (ok != null && context.mounted) {
                    Navigator.of(context).pop(ok);
                  }
                },
              ),
            ],
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(reason),
                const SizedBox(height: 8),
                Text(tr('adminRequired')),
                const SizedBox(height: 16),
                CyberTextField(
                  controller: usernameController,
                  label: tr('adminUsername'),
                  textInputAction: TextInputAction.next,
                  enabled: !busy,
                ),
                const SizedBox(height: 12),
                CyberTextField(
                  controller: passwordController,
                  label: tr('adminPassword'),
                  obscureText: true,
                  enabled: !busy,
                  onSubmitted: (_) async {
                    // Same verification as the Approve button.
                    final ok = await _verify(
                      ref,
                      usernameController.text.trim(),
                      passwordController.text,
                      (message) =>
                          setDialogState(() => error = message),
                      (value) =>
                          setDialogState(() => busy = value),
                      tr,
                    );
                    if (ok != null && context.mounted) {
                      Navigator.of(context).pop(ok);
                    }
                  },
                ),
                if (error != null) ...[
                  const SizedBox(height: 12),
                  Text(
                    error!,
                    style: CyberTextStyles.error(c),
                  ),
                ],
              ],
            ),
          ),
        );
      },
    ),
  );
  usernameController.dispose();
  passwordController.dispose();
  return result;
}

Future<String?> _verify(
  WidgetRef ref,
  String username,
  String password,
  void Function(String) setError,
  void Function(bool) setBusy,
  String Function(String) tr,
) async {
  if (username.isEmpty || password.isEmpty) {
    setError(tr('fieldRequired'));
    return null;
  }
  setBusy(true);
  try {
    final authService = ref.read(authServiceProvider);
    final user = await authService.login(username, password);
    if (user.role != 'owner' && user.role != 'manager') {
      setError(tr('notAuthorizedToApprove'));
      return null;
    }
    return user.username;
  } catch (_) {
    setError(tr('approvalFailed'));
    return null;
  } finally {
    setBusy(false);
  }
}
