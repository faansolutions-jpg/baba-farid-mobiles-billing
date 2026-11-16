import 'package:flutter/scheduler.dart';
import 'package:flutter/widgets.dart';

import 'hud_theme.dart';

/// Thresholds for the automatic fallback (DECISIONS.md #42).
///
/// A sample is one batch of frame timings averaged into an fps value.
/// [kLowFpsThreshold] fps or below counts as a "slow" sample;
/// [kSlowSamplesToDowngrade] slow samples in a row trigger one step
/// down (full -> reduced -> off). The streak resets on any good
/// sample, so a single hitch never downgrades the HUD.
const double kLowFpsThreshold = 45.0;
const int kSlowSamplesToDowngrade = 3;

/// How many recent frame durations are kept for the rolling average.
const int kFrameWindow = 120;

/// Performance manager for the HUD: measures real frame rate, falls
/// back automatically, and enforces the pause rules.
///
/// * Measures fps from [SchedulerBinding] frame timings.
/// * Auto-fallback: 60 fps -> 30 fps (`reduced`) -> static (`off`)
///   after [kSlowSamplesToDowngrade] consecutive slow samples.
///   The fallback actually reduces work: fewer particles
///   ([particleBudget]), frame skipping ([frameSkip]), and at `off`
///   the widgets render [HudStaticCore] with no ticker at all.
///   The level never auto-upgrades (avoids oscillation); call
///   [resetToFull] to go back up, e.g. from Settings.
/// * Pause rules (DECISIONS.md #42): animation pauses while the POS
///   screen is active ([setPosActive]), while the app is backgrounded
///   (via [AppLifecycleState]), or while battery saver is on
///   ([setBatterySaver]).
///
/// App code uses the singleton [HudPerformanceManager.instance];
/// tests can construct fresh instances with the default constructor.
class HudPerformanceManager extends ChangeNotifier
    with WidgetsBindingObserver {
  HudPerformanceManager();

  static final HudPerformanceManager instance =
      HudPerformanceManager._internal();

  HudPerformanceManager._internal();

  HudAnimationLevel _level = HudAnimationLevel.full;
  double _currentFps = 0;
  bool _posActive = false;
  bool _backgrounded = false;
  bool _batterySaver = false;
  bool _running = false;
  int _slowStreak = 0;
  final List<Duration> _recentFrames = <Duration>[];

  /// Current animation level (full / reduced / off).
  HudAnimationLevel get currentLevel => _level;

  /// Most recently measured average fps (0 before the first sample).
  double get currentFps => _currentFps;

  /// Number of particles widgets should draw right now.
  int get particleBudget => particleBudgetForLevel(_level);

  /// Frame-skip factor widgets should use (1 = 60 fps, 2 = 30 fps).
  int get frameSkip => frameSkipForLevel(_level);

  /// True while the POS screen is active.
  bool get isPosActive => _posActive;

  /// True while the app is backgrounded.
  bool get isBackgrounded => _backgrounded;

  /// True while battery saver is on.
  bool get isBatterySaver => _batterySaver;

  /// True when animation must pause for any reason (POS active,
  /// backgrounded, or battery saver).
  bool get isPaused => _posActive || _backgrounded || _batterySaver;

  /// True when widgets should animate at all: not paused and the
  /// level is not `off`.
  bool get shouldAnimate => !isPaused && _level != HudAnimationLevel.off;

  /// Sets the level directly (e.g. from Settings). Notifies listeners.
  void setLevel(HudAnimationLevel level) {
    if (_level == level) return;
    _level = level;
    _slowStreak = 0;
    notifyListeners();
  }

  /// Back to full animation (e.g. after the user picks "Full" in
  /// Settings, or after a device restart). Notifies listeners.
  void resetToFull() => setLevel(HudAnimationLevel.full);

  /// Call when the POS screen becomes active/inactive. While POS is
  /// active the HUD pauses so billing stays under 1 second
  /// (DECISIONS.md #29, #42).
  void setPosActive(bool active) {
    if (_posActive == active) return;
    _posActive = active;
    notifyListeners();
  }

  /// Call when battery saver turns on/off. While on, the HUD pauses.
  void setBatterySaver(bool on) {
    if (_batterySaver == on) return;
    _batterySaver = on;
    notifyListeners();
  }

  /// Applies one averaged fps sample to the fallback logic. Called by
  /// the frame-timings callback; exposed (and synchronous) so tests
  /// can drive the fallback thresholds directly.
  void applyFpsSample(double fps) {
    _currentFps = fps;
    if (fps >= kLowFpsThreshold) {
      _slowStreak = 0;
      notifyListeners();
      return;
    }
    _slowStreak++;
    if (_slowStreak >= kSlowSamplesToDowngrade) {
      _slowStreak = 0;
      switch (_level) {
        case HudAnimationLevel.full:
          _level = HudAnimationLevel.reduced;
          break;
        case HudAnimationLevel.reduced:
          _level = HudAnimationLevel.off;
          break;
        case HudAnimationLevel.off:
          break;
      }
    }
    notifyListeners();
  }

  void _onTimings(List<FrameTiming> timings) {
    if (timings.isEmpty) return;
    for (final FrameTiming timing in timings) {
      _recentFrames.add(timing.totalSpan);
      if (_recentFrames.length > kFrameWindow) {
        _recentFrames.removeAt(0);
      }
    }
    final double avgMicros = _recentFrames.fold<double>(
          0,
          (double sum, Duration d) => sum + d.inMicroseconds,
        ) /
        _recentFrames.length;
    if (avgMicros <= 0) return;
    final double fps = 1000000.0 / avgMicros;
    applyFpsSample(fps);
  }

  /// Starts measuring frame timings and listening to lifecycle
  /// changes. Safe to call more than once.
  void start() {
    if (_running) return;
    _running = true;
    SchedulerBinding.instance.addTimingsCallback(_onTimings);
    WidgetsBinding.instance.addObserver(this);
  }

  /// Stops measuring. Widgets already built keep their last level.
  void stop() {
    if (!_running) return;
    _running = false;
    SchedulerBinding.instance.removeTimingsCallback(_onTimings);
    WidgetsBinding.instance.removeObserver(this);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final bool backgrounded = state != AppLifecycleState.resumed;
    if (_backgrounded == backgrounded) return;
    _backgrounded = backgrounded;
    notifyListeners();
  }

  @override
  void dispose() {
    stop();
    super.dispose();
  }
}
