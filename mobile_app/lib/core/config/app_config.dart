/// App-wide configuration: shop identity, API endpoint, currency.
///
/// Values come from the project spec (README.md / DECISIONS.md). The API
/// base URL can be overridden at compile time with
/// `--dart-define=API_BASE_URL=https://example.com/api/v1` or at runtime
/// from Settings (stored in SharedPreferences under [apiBaseUrlKey]).
library;

/// Compile-time override for the API base URL (empty = use the default).
const String _dartDefineApiBaseUrl = String.fromEnvironment(
  'API_BASE_URL',
  defaultValue: '',
);

class AppConfig {
  const AppConfig._();

  // --- App identity -------------------------------------------------------
  static const String appName = 'Baba Farid Mobiles';
  static const String appTagline = 'Billing & Inventory System';
  static const String version = '1.0.0';
  static const String buildNumber = '1';
  static const String versionDisplay = '$version+$buildNumber';

  // --- API ----------------------------------------------------------------
  /// Default backend endpoint (Node.js/Express, see DECISIONS.md #4-5).
  static const String defaultApiBaseUrl = 'http://localhost:3000/api/v1';

  /// Effective base URL: compile-time define wins, otherwise the default.
  /// The data layer may replace this at runtime with a stored setting.
  static String get apiBaseUrl =>
      _dartDefineApiBaseUrl.isNotEmpty ? _dartDefineApiBaseUrl : defaultApiBaseUrl;

  /// Builds a full API URL for a path such as `/auth/login`.
  static Uri apiUri(String path, [Map<String, String>? query]) {
    final base = apiBaseUrl.endsWith('/')
        ? apiBaseUrl.substring(0, apiBaseUrl.length - 1)
        : apiBaseUrl;
    final cleanPath = path.startsWith('/') ? path : '/$path';
    return Uri.parse('$base$cleanPath').replace(queryParameters: query);
  }

  // --- Shop defaults (README.md §1 / PLAN.md) -----------------------------
  static const String shopName = 'Baba Farid Mobiles';
  static const String shopAddressLine1 = 'Jamal Chowk, Depalpur Road';
  static const String shopAddressLine2 = 'Pakpattan, Punjab, Pakistan';
  static const String shopAddress = '$shopAddressLine1, $shopAddressLine2';

  static const String ownerName = 'Naeem Ahmad';
  static const String ownerPhone = '+923024988560';
  static const String ownerPhoneDisplay = '+92 302 4988560';

  static const String staffName = 'Anas Zaheer';
  static const String staffPhone = '+923299966771';
  static const String staffPhoneDisplay = '+92 329 9966771';

  static const String shopEmail = 'baba.farid.mobiles.bfw@gmail.com';

  // --- Money ---------------------------------------------------------------
  /// All money is whole PKR integers (no paisa decimals). See DECISIONS.md #14.
  static const String currencyCode = 'PKR';
  static const String currencySymbol = 'Rs ';
  static const String currencyLocale = 'en_PK';

  // --- Defaults ------------------------------------------------------------
  static const String defaultBranchId = 'main';
  static const String defaultLanguage = 'en';
  static const String defaultTheme = 'hacker';

  /// JWT access token lifetime (minutes) — mirrors the backend (DECISIONS.md #7).
  static const int accessTokenMinutes = 15;

  /// Auto-lock after inactivity (minutes) — DECISIONS.md #11.
  static const int autoLockMinutes = 2;

  /// Failed-login lockout: 5 attempts -> 15 minutes (DECISIONS.md #7).
  static const int maxLoginAttempts = 5;
  static const int loginLockoutMinutes = 15;

  // --- SharedPreferences keys ----------------------------------------------
  static const String apiBaseUrlKey = 'api_base_url';
  static const String themeKey = 'theme_mode';
  static const String languageKey = 'language';
  static const String animationsEnabledKey = 'animations_enabled';
  static const String privacyModeKey = 'privacy_mode';
  static const String lastUsernameKey = 'last_username';
}
