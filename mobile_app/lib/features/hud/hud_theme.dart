import 'package:flutter/material.dart';

/// Local HUD theme tokens (M6-HUD, DECISIONS.md #39-#44).
///
/// These mirror the cyberpunk token values used by the shared `CyberTheme`
/// (see `lib/core/theme/cyber_colors.dart`). The HUD keeps its own local
/// copy so it can be built and tested independently; Round 2 unifies
/// [HudColors] with the shared `CyberTheme`.
class HudColors {
  HudColors._();

  /// Background dark teal/black.
  static const Color background = Color(0xFF0A0E14);

  /// Panel surface.
  static const Color surface = Color(0xFF111827);

  /// Primary HUD cyan.
  static const Color cyan = Color(0xFF00E5FF);

  /// Attention / warning orange.
  static const Color orange = Color(0xFFFF8A00);

  /// Neon green (healthy / success).
  static const Color neonGreen = Color(0xFF00FF9C);

  /// Magenta accent.
  static const Color magenta = Color(0xFFFF2E88);

  /// Amber accent.
  static const Color amber = Color(0xFFFFB020);

  /// Error red. WCAG AA: use on dark backgrounds only, never as small
  /// text on a light background.
  static const Color red = Color(0xFFFF3B30);

  /// Primary text. #E6EDF3 on #0A0E14 passes WCAG AA (> 4.5:1).
  static const Color text = Color(0xFFE6EDF3);

  /// Muted text. #8B9BB4 on #0A0E14 passes WCAG AA for large text and
  /// UI components; use [text] for small body copy.
  static const Color muted = Color(0xFF8B9BB4);

  /// Thin technical line / border colour (cyan at low alpha).
  static const Color line = Color(0x3300E5FF);

  /// Glow colour used for box shadows (cyan at ~40% alpha).
  static const Color glowCyan = Color(0x6600E5FF);

  /// Glow colour for success states.
  static const Color glowGreen = Color(0x6600FF9C);

  /// Glow colour for error states.
  static const Color glowRed = Color(0x66FF3B30);

  /// Interpolates the core colour by health: cyan when healthy (1.0),
  /// orange when it needs attention (0.0).
  static Color colorForHealth(double health) {
    final double h = health.clamp(0.0, 1.0);
    return Color.lerp(orange, cyan, h)!;
  }
}

/// Animation level for the whole HUD (DECISIONS.md #42-#43).
///
/// Stored in SharedPreferences under `hud_animation_level` as
/// `full` / `reduced` / `off`.
enum HudAnimationLevel {
  /// Full animation: 60 fps, 600 particles.
  full,

  /// Reduced animation: 30 fps (frame skipping), 250 particles.
  reduced,

  /// No animation: static pre-rendered core, no rain, no motion.
  off;

  /// Parses the value stored in SharedPreferences. Unknown values
  /// fall back to [full].
  static HudAnimationLevel fromString(String? value) {
    switch (value) {
      case 'reduced':
        return reduced;
      case 'off':
        return off;
      case 'full':
      default:
        return full;
    }
  }

  /// Value written to SharedPreferences.
  String get storageValue => name;
}

/// Particle budget for an animation level (DECISIONS.md #42).
///
/// Pure function so it is unit-testable without a widget tree.
int particleBudgetForLevel(HudAnimationLevel level) {
  switch (level) {
    case HudAnimationLevel.full:
      return 600;
    case HudAnimationLevel.reduced:
      return 250;
    case HudAnimationLevel.off:
      return 0;
  }
}

/// Frame-skip factor for an animation level: 1 = every frame (60 fps),
/// 2 = every second frame (30 fps). Level `off` never animates, so the
/// factor is irrelevant there and returns 1.
int frameSkipForLevel(HudAnimationLevel level) {
  switch (level) {
    case HudAnimationLevel.reduced:
      return 2;
    case HudAnimationLevel.full:
    case HudAnimationLevel.off:
      return 1;
  }
}

/// Recommended animation level for a measured average frame rate.
///
/// Thresholds (DECISIONS.md #42): 60 fps target; fall back to 30 fps
/// (`reduced`) below 50 fps, and to a static image (`off`) below 28 fps.
/// Pure function so it is unit-testable without a widget tree.
HudAnimationLevel levelForAverageFps(double fps) {
  if (fps >= 50.0) return HudAnimationLevel.full;
  if (fps >= 28.0) return HudAnimationLevel.reduced;
  return HudAnimationLevel.off;
}

/// Monospace-first text styles for the HUD.
///
/// Numbers, labels and IMEI/bill values use JetBrains Mono with a
/// system-monospace fallback (DECISIONS.md #27). Urdu text uses
/// Noto Nastaliq Urdu with a system fallback.
class HudTextStyles {
  HudTextStyles._();

  static const String monoFamily = 'JetBrains Mono';
  static const String urduFamily = 'Noto Nastaliq Urdu';

  static const TextStyle title = TextStyle(
    fontFamily: monoFamily,
    fontFamilyFallback: <String>['monospace'],
    fontSize: 13,
    fontWeight: FontWeight.w700,
    letterSpacing: 2.0,
    color: HudColors.text,
  );

  static const TextStyle label = TextStyle(
    fontFamily: monoFamily,
    fontFamilyFallback: <String>['monospace'],
    fontSize: 11,
    fontWeight: FontWeight.w600,
    letterSpacing: 1.5,
    color: HudColors.muted,
  );

  static const TextStyle value = TextStyle(
    fontFamily: monoFamily,
    fontFamilyFallback: <String>['monospace'],
    fontSize: 22,
    fontWeight: FontWeight.w700,
    color: HudColors.text,
  );

  static const TextStyle valueSmall = TextStyle(
    fontFamily: monoFamily,
    fontFamilyFallback: <String>['monospace'],
    fontSize: 15,
    fontWeight: FontWeight.w700,
    color: HudColors.text,
  );

  static const TextStyle data = TextStyle(
    fontFamily: monoFamily,
    fontFamilyFallback: <String>['monospace'],
    fontSize: 11,
    color: HudColors.cyan,
  );

  static const TextStyle status = TextStyle(
    fontFamily: monoFamily,
    fontFamilyFallback: <String>['monospace'],
    fontSize: 12,
    color: HudColors.neonGreen,
  );

  /// Readable Urdu style (Noto Nastaliq Urdu) for any Urdu copy
  /// shown inside HUD panels.
  static const TextStyle urdu = TextStyle(
    fontFamily: urduFamily,
    fontSize: 15,
    color: HudColors.text,
  );
}
