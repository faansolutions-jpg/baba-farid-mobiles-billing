import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'hud_theme.dart';

/// SharedPreferences keys for HUD animation settings (DECISIONS.md
/// #43). These exact keys are the contract between this helper and
/// the Round 2 settings screen — both sides must use them verbatim.
class HudSettingsKeys {
  HudSettingsKeys._();

  /// String: 'full' | 'reduced' | 'off'.
  static const String animationLevel = 'hud_animation_level';

  /// Bool: auto-turn animations off when battery saver is on.
  static const String batterySaverAutoOff = 'hud_battery_saver_auto_off';

  /// Bool: use the looping video background when a video is set.
  static const String videoBackground = 'hud_video_background';

  /// String (optional extra): asset path of the looping HUD video,
  /// e.g. 'assets/hud_loop.mp4'. Empty/absent means "no video".
  static const String videoBackgroundPath = 'hud_video_background_path';
}

/// Animation settings model: the animation level, the battery-saver
/// auto-off switch, and the optional video background switch + path.
class AnimationSettings {
  const AnimationSettings({
    this.level = HudAnimationLevel.full,
    this.batterySaverAutoOff = true,
    this.videoBackground = false,
    this.videoBackgroundPath = '',
  });

  final HudAnimationLevel level;
  final bool batterySaverAutoOff;
  final bool videoBackground;
  final String videoBackgroundPath;

  AnimationSettings copyWith({
    HudAnimationLevel? level,
    bool? batterySaverAutoOff,
    bool? videoBackground,
    String? videoBackgroundPath,
  }) {
    return AnimationSettings(
      level: level ?? this.level,
      batterySaverAutoOff: batterySaverAutoOff ?? this.batterySaverAutoOff,
      videoBackground: videoBackground ?? this.videoBackground,
      videoBackgroundPath: videoBackgroundPath ?? this.videoBackgroundPath,
    );
  }

  @override
  bool operator ==(Object other) =>
      other is AnimationSettings &&
      other.level == level &&
      other.batterySaverAutoOff == batterySaverAutoOff &&
      other.videoBackground == videoBackground &&
      other.videoBackgroundPath == videoBackgroundPath;

  @override
  int get hashCode => Object.hash(
        level,
        batterySaverAutoOff,
        videoBackground,
        videoBackgroundPath,
      );

  @override
  String toString() =>
      'AnimationSettings(level: ${level.storageValue}, '
      'batterySaverAutoOff: $batterySaverAutoOff, '
      'videoBackground: $videoBackground, '
      'videoBackgroundPath: $videoBackgroundPath)';
}

/// Helper for loading/saving [AnimationSettings] with
/// SharedPreferences, using the exact keys in [HudSettingsKeys].
///
/// [notifier] is a [ValueNotifier] holding the current settings so
/// the HUD and the settings screen stay live-updated: call [load]
/// once at startup, then read [notifier] (or listen to it) anywhere.
class HudSettings {
  HudSettings._();

  static final ValueNotifier<AnimationSettings> notifier =
      ValueNotifier<AnimationSettings>(const AnimationSettings());

  /// Current settings (same object as [notifier].value).
  static AnimationSettings get current => notifier.value;

  /// Loads settings from SharedPreferences (defaults when nothing
  /// is stored yet), publishes them to [notifier], and returns them.
  static Future<AnimationSettings> load() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final AnimationSettings settings = AnimationSettings(
      level: HudAnimationLevel.fromString(
        prefs.getString(HudSettingsKeys.animationLevel),
      ),
      batterySaverAutoOff:
          prefs.getBool(HudSettingsKeys.batterySaverAutoOff) ?? true,
      videoBackground:
          prefs.getBool(HudSettingsKeys.videoBackground) ?? false,
      videoBackgroundPath:
          prefs.getString(HudSettingsKeys.videoBackgroundPath) ?? '',
    );
    notifier.value = settings;
    return settings;
  }

  /// Saves [settings] to SharedPreferences and publishes them to
  /// [notifier] so live listeners update immediately.
  static Future<void> save(AnimationSettings settings) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      HudSettingsKeys.animationLevel,
      settings.level.storageValue,
    );
    await prefs.setBool(
      HudSettingsKeys.batterySaverAutoOff,
      settings.batterySaverAutoOff,
    );
    await prefs.setBool(
      HudSettingsKeys.videoBackground,
      settings.videoBackground,
    );
    await prefs.setString(
      HudSettingsKeys.videoBackgroundPath,
      settings.videoBackgroundPath,
    );
    notifier.value = settings;
  }
}
