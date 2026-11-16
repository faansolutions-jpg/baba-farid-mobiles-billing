import 'package:flutter/material.dart';

/// The four cyberpunk themes (DECISIONS.md #26).
///
/// Default theme is [CyberThemeMode.hacker]. Every screen reads its colours
/// from [CyberColors] — never hard-code a colour in a feature screen.
enum CyberThemeMode {
  hacker,
  matrix,
  cyberBlue,
  light;

  /// Parses the value stored in SharedPreferences (`AppConfig.themeKey`).
  static CyberThemeMode fromString(String? value) {
    switch (value) {
      case 'matrix':
        return CyberThemeMode.matrix;
      case 'cyberBlue':
      case 'cyber_blue':
        return CyberThemeMode.cyberBlue;
      case 'light':
        return CyberThemeMode.light;
      case 'hacker':
      default:
        return CyberThemeMode.hacker;
    }
  }

  String get storageValue => name;
}

/// Colour tokens for one theme. All colours are opaque so text contrast
/// can be checked directly against the background they sit on.
class CyberColors {
  const CyberColors({
    required this.background,
    required this.surface,
    required this.card,
    required this.primary,
    required this.secondary,
    required this.accent,
    required this.warning,
    required this.error,
    required this.success,
    required this.textPrimary,
    required this.textSecondary,
    required this.border,
    required this.glow,
    required this.onPrimary,
    required this.brightness,
  });

  final Color background;
  final Color surface;
  final Color card;
  final Color primary;
  final Color secondary;
  final Color accent;
  final Color warning;
  final Color error;
  final Color success;
  final Color textPrimary;
  final Color textSecondary;
  final Color border;

  /// Colour used for glow shadows / neon borders.
  final Color glow;

  /// Text/icon colour drawn on top of [primary].
  final Color onPrimary;

  final Brightness brightness;

  bool get isDark => brightness == Brightness.dark;

  // --- Hacker (default) ----------------------------------------------------
  // bg #0A0E14, primary #00FF9C, cyan #00E5FF, magenta #FF2E88.
  static const CyberColors hacker = CyberColors(
    background: Color(0xFF0A0E14),
    surface: Color(0xFF11161F),
    card: Color(0xFF151C28),
    primary: Color(0xFF00FF9C),
    secondary: Color(0xFF00E5FF),
    accent: Color(0xFFFF2E88),
    warning: Color(0xFFFFB020),
    error: Color(0xFFFF3B5C),
    success: Color(0xFF00FF9C),
    textPrimary: Color(0xFFE8FFF4),
    textSecondary: Color(0xFF8FA3B0),
    border: Color(0xFF2A3644),
    glow: Color(0x6600FF9C),
    onPrimary: Color(0xFF04120A),
    brightness: Brightness.dark,
  );

  // --- Matrix Green ---------------------------------------------------------
  static const CyberColors matrix = CyberColors(
    background: Color(0xFF000A00),
    surface: Color(0xFF031207),
    card: Color(0xFF071A0B),
    primary: Color(0xFF00FF41),
    secondary: Color(0xFF39D353),
    accent: Color(0xFF7CFFB2),
    warning: Color(0xFFFFC53D),
    error: Color(0xFFFF4D4D),
    success: Color(0xFF00FF41),
    textPrimary: Color(0xFFD6FFDD),
    textSecondary: Color(0xFF7FB98A),
    border: Color(0xFF1E4D2B),
    glow: Color(0x6600FF41),
    onPrimary: Color(0xFF001A05),
    brightness: Brightness.dark,
  );

  // --- Cyber Blue -----------------------------------------------------------
  static const CyberColors cyberBlue = CyberColors(
    background: Color(0xFF050A18),
    surface: Color(0xFF0A1226),
    card: Color(0xFF0F1B36),
    primary: Color(0xFF00BFFF),
    secondary: Color(0xFF7C4DFF),
    accent: Color(0xFFFF2E88),
    warning: Color(0xFFFFB020),
    error: Color(0xFFFF3B5C),
    success: Color(0xFF2EE6A8),
    textPrimary: Color(0xFFE6F2FF),
    textSecondary: Color(0xFF8AA0C2),
    border: Color(0xFF22345C),
    glow: Color(0x6600BFFF),
    onPrimary: Color(0xFF02131F),
    brightness: Brightness.dark,
  );

  // --- Light ----------------------------------------------------------------
  // WCAG AA: dark text on a near-white background; primary is a deep green
  // so primary-coloured text on white still passes 4.5:1.
  static const CyberColors light = CyberColors(
    background: Color(0xFFF4F6F8),
    surface: Color(0xFFFFFFFF),
    card: Color(0xFFFFFFFF),
    primary: Color(0xFF006B3F),
    secondary: Color(0xFF0066CC),
    accent: Color(0xFFC2185B),
    warning: Color(0xFF8A5A00),
    error: Color(0xFFB00020),
    success: Color(0xFF006B3F),
    textPrimary: Color(0xFF101418),
    textSecondary: Color(0xFF4A5560),
    border: Color(0xFFCBD5DE),
    glow: Color(0x33006B3F),
    onPrimary: Color(0xFFFFFFFF),
    brightness: Brightness.light,
  );

  /// Returns the token set for [mode].
  static CyberColors of(CyberThemeMode mode) {
    switch (mode) {
      case CyberThemeMode.matrix:
        return matrix;
      case CyberThemeMode.cyberBlue:
        return cyberBlue;
      case CyberThemeMode.light:
        return light;
      case CyberThemeMode.hacker:
        return hacker;
    }
  }

  /// All themes, in the order shown by the theme switcher in Settings.
  static const List<CyberThemeMode> allModes = <CyberThemeMode>[
    CyberThemeMode.hacker,
    CyberThemeMode.matrix,
    CyberThemeMode.cyberBlue,
    CyberThemeMode.light,
  ];
}
