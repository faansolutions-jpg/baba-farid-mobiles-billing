import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'cyber_colors.dart';
import 'cyber_text_styles.dart';

/// Theme state: which of the four themes is active, and whether
/// animations are enabled (Settings can turn them off for low-end phones,
/// DECISIONS.md #26).
class ThemeState {
  const ThemeState({
    this.mode = CyberThemeMode.hacker,
    this.animationsEnabled = true,
  });

  final CyberThemeMode mode;
  final bool animationsEnabled;

  CyberColors get colors => CyberColors.of(mode);

  ThemeState copyWith({CyberThemeMode? mode, bool? animationsEnabled}) =>
      ThemeState(
        mode: mode ?? this.mode,
        animationsEnabled: animationsEnabled ?? this.animationsEnabled,
      );

  @override
  bool operator ==(Object other) =>
      other is ThemeState &&
      other.mode == mode &&
      other.animationsEnabled == animationsEnabled;

  @override
  int get hashCode => Object.hash(mode, animationsEnabled);
}

/// Riverpod notifier for the theme. Screens read the active colours with
/// `ref.watch(themeNotifierProvider).colors` and switch themes with
/// `ref.read(themeNotifierProvider.notifier).setMode(...)`.
class ThemeNotifier extends StateNotifier<ThemeState> {
  ThemeNotifier({ThemeState? initial}) : super(initial ?? const ThemeState());

  void setMode(CyberThemeMode mode) {
    if (state.mode != mode) state = state.copyWith(mode: mode);
  }

  /// Cycles Hacker -> Matrix -> Cyber Blue -> Light -> Hacker.
  void cycleMode() {
    const modes = CyberColors.allModes;
    final next = modes[(modes.indexOf(state.mode) + 1) % modes.length];
    setMode(next);
  }

  void setAnimationsEnabled(bool enabled) {
    if (state.animationsEnabled != enabled) {
      state = state.copyWith(animationsEnabled: enabled);
    }
  }

  void toggleAnimations() => setAnimationsEnabled(!state.animationsEnabled);
}

final themeNotifierProvider =
    StateNotifierProvider<ThemeNotifier, ThemeState>((ref) => ThemeNotifier());

/// Builds [ThemeData] for the four themes. All feature screens use these
/// widgets/themes — no screen defines its own colours.
class CyberTheme {
  const CyberTheme._();

  /// ThemeData for a theme mode.
  static ThemeData themeFor(CyberThemeMode mode) => _fromColors(CyberColors.of(mode));

  static ThemeData get hacker => themeFor(CyberThemeMode.hacker);
  static ThemeData get matrix => themeFor(CyberThemeMode.matrix);
  static ThemeData get cyberBlue => themeFor(CyberThemeMode.cyberBlue);
  static ThemeData get light => themeFor(CyberThemeMode.light);

  static ThemeData _fromColors(CyberColors c) {
    final colorScheme = ColorScheme(
      brightness: c.brightness,
      primary: c.primary,
      onPrimary: c.onPrimary,
      secondary: c.secondary,
      onSecondary: c.onPrimary,
      error: c.error,
      onError: c.isDark ? const Color(0xFF1A0505) : Colors.white,
      surface: c.surface,
      onSurface: c.textPrimary,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: c.brightness,
      scaffoldBackgroundColor: c.background,
      colorScheme: colorScheme,
      primaryColor: c.primary,
      canvasColor: c.surface,
      cardColor: c.card,
      dividerColor: c.border,
      // Text
      textTheme: TextTheme(
        displayLarge: CyberTextStyles.headline(c, size: 32),
        headlineMedium: CyberTextStyles.headline(c, size: 28),
        titleLarge: CyberTextStyles.title(c, size: 20),
        titleMedium: CyberTextStyles.subtitle(c, size: 16),
        bodyLarge: CyberTextStyles.body(c, size: 16),
        bodyMedium: CyberTextStyles.body(c, size: 15),
        bodySmall: CyberTextStyles.bodySecondary(c, size: 13),
        labelLarge: CyberTextStyles.button(c, size: 16),
        labelMedium: CyberTextStyles.label(c, size: 12),
      ),
      // App bar: dark surface, mono title, neon bottom border via shadow.
      appBarTheme: AppBarTheme(
        backgroundColor: c.surface,
        foregroundColor: c.textPrimary,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: CyberTextStyles.mono(c, size: 17).copyWith(
          fontWeight: FontWeight.w700,
          letterSpacing: 1.0,
        ),
        iconTheme: IconThemeData(color: c.primary),
      ),
      // Cards: dark surface, thin neon-tinted border.
      cardTheme: CardThemeData(
        color: c.card,
        elevation: 0,
        margin: const EdgeInsets.all(8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          side: BorderSide(color: c.border),
        ),
      ),
      // Buttons: minimum 48dp touch target, filled primary.
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: c.primary,
          foregroundColor: c.onPrimary,
          minimumSize: const Size(0, 48),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          textStyle: CyberTextStyles.button(c, size: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(6),
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: c.primary,
          minimumSize: const Size(0, 48),
          side: BorderSide(color: c.primary, width: 1.5),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          textStyle: CyberTextStyles.button(c, size: 16)
              .copyWith(color: c.primary),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(6),
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: c.secondary,
          minimumSize: const Size(0, 48),
          textStyle: CyberTextStyles.button(c, size: 15)
              .copyWith(color: c.secondary),
        ),
      ),
      // Text fields: mono-friendly, neon focus border.
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: c.surface,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        hintStyle: CyberTextStyles.bodySecondary(c),
        labelStyle: CyberTextStyles.label(c),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(6),
          borderSide: BorderSide(color: c.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(6),
          borderSide: BorderSide(color: c.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(6),
          borderSide: BorderSide(color: c.primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(6),
          borderSide: BorderSide(color: c.error, width: 1.5),
        ),
      ),
      // Dialogs, lists, switches.
      dialogTheme: DialogThemeData(
        backgroundColor: c.card,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          side: BorderSide(color: c.primary.withValues(alpha: 0.5)),
        ),
        titleTextStyle: CyberTextStyles.title(c, size: 18),
        contentTextStyle: CyberTextStyles.body(c),
      ),
      listTileTheme: ListTileThemeData(
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        iconColor: c.primary,
        textColor: c.textPrimary,
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith(
          (states) => states.contains(WidgetState.selected)
              ? c.onPrimary
              : c.textSecondary,
        ),
        trackColor: WidgetStateProperty.resolveWith(
          (states) => states.contains(WidgetState.selected)
              ? c.primary
              : c.border,
        ),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: c.primary,
        foregroundColor: c.onPrimary,
      ),
      progressIndicatorTheme: ProgressIndicatorThemeData(color: c.primary),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: c.card,
        contentTextStyle: CyberTextStyles.body(c),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(6),
          side: BorderSide(color: c.border),
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: c.surface,
        selectedColor: c.primary,
        labelStyle: CyberTextStyles.body(c, size: 13),
        side: BorderSide(color: c.border),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
      ),
    );
  }
}

/// Human-readable theme names for the Settings theme switcher.
String themeModeLabel(CyberThemeMode mode) {
  switch (mode) {
    case CyberThemeMode.hacker:
      return 'Hacker';
    case CyberThemeMode.matrix:
      return 'Matrix Green';
    case CyberThemeMode.cyberBlue:
      return 'Cyber Blue';
    case CyberThemeMode.light:
      return 'Light';
  }
}
