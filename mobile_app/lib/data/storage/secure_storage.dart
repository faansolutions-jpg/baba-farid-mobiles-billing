/// Secure storage wrappers.
///
/// [SecureStorage] wraps `flutter_secure_storage` for secrets:
/// access/refresh tokens, the cached login user and the database
/// encryption key. [SettingsStorage] wraps `shared_preferences` for
/// non-secret device preferences (theme, language, animations,
/// printer). Secrets never go into shared_preferences.
library;

import 'dart:convert';
import 'dart:math';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SecureStorage {
  static const String keyAccessToken = 'access_token';
  static const String keyRefreshToken = 'refresh_token';
  static const String keyAuthUser = 'auth_user';
  static const String keyDbEncryptionKey = 'db_encryption_key';

  final FlutterSecureStorage _storage;

  SecureStorage({FlutterSecureStorage? storage})
      : _storage = storage ?? const FlutterSecureStorage();

  Future<String?> read(String key) => _storage.read(key: key);
  Future<void> write(String key, String value) =>
      _storage.write(key: key, value: value);
  Future<void> delete(String key) => _storage.delete(key: key);
  Future<void> deleteAll() => _storage.deleteAll();

  Future<String?> readAccessToken() => read(keyAccessToken);
  Future<void> writeAccessToken(String token) =>
      write(keyAccessToken, token);
  Future<void> deleteAccessToken() => delete(keyAccessToken);

  Future<String?> readRefreshToken() => read(keyRefreshToken);
  Future<void> writeRefreshToken(String token) =>
      write(keyRefreshToken, token);
  Future<void> deleteRefreshToken() => delete(keyRefreshToken);

  Future<String?> readAuthUser() => read(keyAuthUser);
  Future<void> writeAuthUser(String json) => write(keyAuthUser, json);
  Future<void> deleteAuthUser() => delete(keyAuthUser);

  /// Returns the 32-byte database encryption key (base64), creating and
  /// persisting one on first use. The raw key never leaves secure
  /// storage except to the encryption helper in memory.
  Future<String> getOrCreateEncryptionKey() async {
    final existing = await read(keyDbEncryptionKey);
    if (existing != null && existing.isNotEmpty) return existing;
    final bytes = List<int>.generate(32, (_) => Random.secure().nextInt(256));
    final encoded = base64Encode(bytes);
    await write(keyDbEncryptionKey, encoded);
    return encoded;
  }
}

/// Non-secret device preferences in shared_preferences.
class SettingsStorage {
  static const String keyTheme = 'app.theme';
  static const String keyLanguage = 'app.language';
  static const String keyAnimations = 'app.animations';
  static const String keyPrivacyMode = 'app.privacy_mode';
  static const String keyPrinterName = 'printer.name';
  static const String keyPrinterWidth = 'printer.width';
  static const String keyAutoLockMinutes = 'app.auto_lock_minutes';

  final SharedPreferences _prefs;

  SettingsStorage(this._prefs);

  static Future<SettingsStorage> create() async {
    return SettingsStorage(await SharedPreferences.getInstance());
  }

  Future<String?> getString(String key) async => _prefs.getString(key);
  Future<bool> setString(String key, String value) =>
      _prefs.setString(key, value);

  Future<bool?> getBool(String key) async => _prefs.getBool(key);
  Future<bool> setBool(String key, bool value) =>
      _prefs.setBool(key, value);

  Future<int?> getInt(String key) async => _prefs.getInt(key);
  Future<bool> setInt(String key, int value) => _prefs.setInt(key, value);

  Future<String> getTheme() async =>
      _prefs.getString(keyTheme) ?? 'hacker';
  Future<bool> setTheme(String theme) => _prefs.setString(keyTheme, theme);

  Future<String> getLanguage() async =>
      _prefs.getString(keyLanguage) ?? 'en';
  Future<bool> setLanguage(String language) =>
      _prefs.setString(keyLanguage, language);

  Future<bool> getAnimationsEnabled() async =>
      _prefs.getBool(keyAnimations) ?? true;
  Future<bool> setAnimationsEnabled(bool value) =>
      _prefs.setBool(keyAnimations, value);

  Future<bool> getPrivacyMode() async =>
      _prefs.getBool(keyPrivacyMode) ?? false;
  Future<bool> setPrivacyMode(bool value) =>
      _prefs.setBool(keyPrivacyMode, value);

  Future<String> getPrinterName() async =>
      _prefs.getString(keyPrinterName) ?? '';
  Future<bool> setPrinterName(String name) =>
      _prefs.setString(keyPrinterName, name);

  Future<String> getPrinterWidth() async =>
      _prefs.getString(keyPrinterWidth) ?? '80mm';
  Future<bool> setPrinterWidth(String width) =>
      _prefs.setString(keyPrinterWidth, width);

  Future<int> getAutoLockMinutes() async =>
      _prefs.getInt(keyAutoLockMinutes) ?? 2;
  Future<bool> setAutoLockMinutes(int minutes) =>
      _prefs.setInt(keyAutoLockMinutes, minutes);
}
