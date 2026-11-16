import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

import 'data_rain.dart';
import 'hud_core.dart';
import 'hud_gauges.dart';
import 'hud_theme.dart';

/// Runs the HUD core + data rain + gauges for 10 seconds, measures
/// the real average frame rate from [SchedulerBinding] frame timings,
/// and reports the result plus the recommended animation level.
///
/// This is a diagnostic screen, not a shop screen: it is reached
/// from the [HudDemoGallery] ("RUN PERFORMANCE TEST" button) and from
/// Settings in Round 2.
class HudPerformanceTestScreen extends StatefulWidget {
  const HudPerformanceTestScreen({super.key});

  @override
  State<HudPerformanceTestScreen> createState() =>
      _HudPerformanceTestScreenState();
}

class _HudPerformanceTestScreenState
    extends State<HudPerformanceTestScreen> {
  static const Duration kTestDuration = Duration(seconds: 10);

  bool _running = false;
  bool _done = false;
  double _liveFps = 0;
  double _averageFps = 0;
  int _frames = 0;
  HudAnimationLevel _recommended = HudAnimationLevel.full;
  final List<Duration> _spans = <Duration>[];

  // Illustrative values only — this screen measures performance, it
  // does not show shop data.
  static const List<String> _kDemoRainValues = <String>[
    'IMEI 35988107...',
    'BILL-1042',
    'Rs 45,000',
    'IMEI 86941205...',
    'BILL-1043',
    'Rs 12,500',
  ];

  void _onTimings(List<FrameTiming> timings) {
    if (!_running) return;
    for (final FrameTiming timing in timings) {
      _spans.add(timing.totalSpan);
    }
    _frames += timings.length;
    final double avgMicros = _spans.fold<double>(
          0,
          (double sum, Duration d) => sum + d.inMicroseconds,
        ) /
        _spans.length;
    if (avgMicros > 0 && mounted) {
      setState(() => _liveFps = 1000000.0 / avgMicros);
    }
  }

  Future<void> _runTest() async {
    if (_running) return;
    setState(() {
      _running = true;
      _done = false;
      _liveFps = 0;
      _averageFps = 0;
      _frames = 0;
      _spans.clear();
    });
    SchedulerBinding.instance.addTimingsCallback(_onTimings);
    await Future<void>.delayed(kTestDuration);
    SchedulerBinding.instance.removeTimingsCallback(_onTimings);
    if (!mounted) return;
    final double avgMicros = _spans.isEmpty
        ? 0
        : _spans.fold<double>(
              0,
              (double sum, Duration d) => sum + d.inMicroseconds,
            ) /
            _spans.length;
    final double fps = avgMicros > 0 ? 1000000.0 / avgMicros : 0;
    setState(() {
      _running = false;
      _done = true;
      _averageFps = fps;
      _recommended = levelForAverageFps(fps);
    });
  }

  @override
  void dispose() {
    SchedulerBinding.instance.removeTimingsCallback(_onTimings);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: HudColors.background,
      appBar: AppBar(
        backgroundColor: HudColors.surface,
        title: Text(
          'HUD PERFORMANCE TEST',
          style: HudTextStyles.title.copyWith(color: HudColors.cyan),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            const Text(
              'Runs the core + data rain + gauges for 10 seconds and '
              'measures the real average frame rate on this device.',
              style: HudTextStyles.label,
            ),
            const SizedBox(height: 16),
            if (_running || _done)
              Expanded(
                child: Row(
                  children: <Widget>[
                    const Expanded(
                      child: HudCore(
                        size: 180,
                        particleBudget: 600,
                        isAnimating: true,
                      ),
                    ),
                    Expanded(
                      child: DataRain(
                        values: _kDemoRainValues,
                        columns: 3,
                        isAnimating: _running,
                        height: 220,
                      ),
                    ),
                  ],
                ),
              )
            else
              const Expanded(
                child: Center(
                  child: HudCore(
                    size: 180,
                    particleBudget: 600,
                    isAnimating: true,
                  ),
                ),
              ),
            const SizedBox(height: 8),
            HudPercentBar(
              label: 'LIVE FPS',
              percent: (_liveFps / 60 * 100).clamp(0.0, 100.0),
              color: HudColors.cyan,
              isAnimating: false,
            ),
            const SizedBox(height: 6),
            Text(
              _running
                  ? 'TESTING... ${_liveFps.toStringAsFixed(1)} FPS'
                  : _done
                      ? 'DONE'
                      : 'READY',
              style: HudTextStyles.status,
              textAlign: TextAlign.center,
            ),
            if (_done) ...<Widget>[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: HudColors.surface,
                  border: Border.all(color: HudColors.cyan.withValues(alpha: 0.5)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      'AVERAGE FPS: ${_averageFps.toStringAsFixed(1)}',
                      style: HudTextStyles.valueSmall,
                    ),
                    Text(
                      'FRAMES MEASURED: $_frames',
                      style: HudTextStyles.label,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'RECOMMENDED LEVEL: ${_recommended.name.toUpperCase()}',
                      style: HudTextStyles.title.copyWith(
                        color: HudColors.neonGreen,
                      ),
                    ),
                    Text(
                      _recommended == HudAnimationLevel.full
                          ? 'Full animation (600 particles, 60 fps).'
                          : _recommended == HudAnimationLevel.reduced
                              ? 'Reduced animation (250 particles, 30 fps).'
                              : 'Animations off (static core).',
                      style: HudTextStyles.label,
                    ),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 16),
            SizedBox(
              height: 48,
              child: ElevatedButton(
                onPressed: _running ? null : _runTest,
                style: ElevatedButton.styleFrom(
                  backgroundColor: HudColors.cyan,
                  foregroundColor: HudColors.background,
                ),
                child: Text(
                  _done ? 'RUN AGAIN' : 'RUN 10-SECOND TEST',
                  style: const TextStyle(
                    fontFamily: HudTextStyles.monoFamily,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.5,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
