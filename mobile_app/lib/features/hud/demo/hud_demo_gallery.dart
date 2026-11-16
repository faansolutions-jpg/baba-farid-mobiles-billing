import 'package:flutter/material.dart';

import '../hud.dart';

/// Gallery showing every HUD widget with clearly-labelled
/// illustrative values.
///
/// Title says "HUD DEMO — illustrative values": NOTHING on this
/// screen is real shop data. Real values are passed in by the real
/// screens in Round 2 (see `README.md` in the hud folder).
class HudDemoGallery extends StatefulWidget {
  const HudDemoGallery({super.key});

  @override
  State<HudDemoGallery> createState() => _HudDemoGalleryState();
}

class _HudDemoGalleryState extends State<HudDemoGallery> {
  HudAnimationLevel _level = HudAnimationLevel.full;
  bool _posActive = false;
  final HudPerformanceManager _performance =
      HudPerformanceManager.instance;

  // --- Illustrative values only (labelled as such on screen). ---
  static const List<String> _kDemoRainValues = <String>[
    'IMEI 35988107...',
    'BILL-1042',
    'Rs 45,000',
    'IMEI 86941205...',
    'BILL-1043',
    'Rs 12,500',
    'IMEI 35501908...',
    'BILL-1044',
    'Rs 78,900',
  ];
  static const List<double> _kDemoWave = <double>[
    0.2, 0.5, 0.4, 0.8, 0.6, 0.9, 0.5, 0.7, 0.3, 0.6,
  ];
  static const List<double> _kDemoChart = <double>[
    12000, 18000, 15000, 26000, 22000, 34000, 31000, 42000,
  ];
  static const List<double> _kDemoBars = <double>[4, 7, 5, 9, 6, 8, 3];

  @override
  void initState() {
    super.initState();
    _performance.start();
    _performance.addListener(_onPerformanceChanged);
  }

  void _onPerformanceChanged() {
    if (mounted) setState(() => _level = _performance.currentLevel);
  }

  @override
  void dispose() {
    _performance.removeListener(_onPerformanceChanged);
    super.dispose();
  }

  bool get _animating =>
      _level != HudAnimationLevel.off && !_posActive;
  int get _budget => particleBudgetForLevel(_level);
  int get _frameSkip => frameSkipForLevel(_level);

  Future<void> _setLevel(HudAnimationLevel level) async {
    setState(() => _level = level);
    _performance.setLevel(level);
    await HudSettings.save(
      HudSettings.current.copyWith(level: level),
    );
  }

  Widget _section(String title, Widget child) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        const SizedBox(height: 20),
        Text(
          title,
          style: HudTextStyles.title.copyWith(color: HudColors.cyan),
        ),
        const SizedBox(height: 8),
        child,
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: HudColors.background,
      appBar: AppBar(
        backgroundColor: HudColors.surface,
        title: Text(
          'HUD DEMO — illustrative values',
          style: HudTextStyles.title.copyWith(color: HudColors.cyan),
        ),
      ),
      body: HudBackground(
        isAnimating: _animating,
        opacity: 0.6,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: <Widget>[
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: HudColors.surface,
                border: Border.all(color: HudColors.amber.withValues(alpha: 0.6)),
              ),
              child: Text(
                'ALL VALUES ON THIS SCREEN ARE ILLUSTRATIVE DEMO VALUES, '
                'NOT REAL SHOP DATA.',
                style: HudTextStyles.label.copyWith(color: HudColors.amber),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: <Widget>[
                Expanded(
                  child: DropdownButton<HudAnimationLevel>(
                    value: _level,
                    dropdownColor: HudColors.surface,
                    style: HudTextStyles.label
                        .copyWith(color: HudColors.text),
                    isExpanded: true,
                    items: HudAnimationLevel.values
                        .map((HudAnimationLevel level) {
                      return DropdownMenuItem<HudAnimationLevel>(
                        value: level,
                        child: Text('LEVEL: ${level.name.toUpperCase()}'),
                      );
                    }).toList(),
                    onChanged: (HudAnimationLevel? level) {
                      if (level != null) _setLevel(level);
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Row(
                    children: <Widget>[
                      Switch(
                        value: _posActive,
                        activeThumbColor: HudColors.orange,
                        onChanged: (bool value) {
                          setState(() => _posActive = value);
                          _performance.setPosActive(value);
                        },
                      ),
                      const Expanded(
                        child: Text(
                          'POS ACTIVE\n(pauses HUD)',
                          style: HudTextStyles.label,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            Text(
              'PERFORMANCE: ${_performance.currentFps.toStringAsFixed(1)} FPS '
              '· BUDGET $_budget · ${isAnimatingLabel(_animating)}',
              style: HudTextStyles.label,
            ),
            _section(
              '1 · HUD CORE (HEALTH 0.85)',
              Center(
                child: HudCore(
                  size: 200,
                  health: 0.85,
                  particleBudget: _budget,
                  isAnimating: _animating,
                  frameSkip: _frameSkip,
                ),
              ),
            ),
            _section(
              '2 · HUD CORE — STATIC (LEVEL OFF)',
              const Center(
                child: HudStaticCore(size: 140, health: 0.4),
              ),
            ),
            _section(
              '3 · DATA RAIN (REAL-LOOKING DEMO VALUES)',
              DataRain(
                values: _kDemoRainValues,
                columns: 4,
                isAnimating: _animating,
                height: 180,
              ),
            ),
            _section(
              '4 · GAUGES',
              HudGauges(
                gaugeValue: 0.72,
                gaugeLabel: 'SALES VS TARGET',
                percentBars: const <({String label, double percent, Color color})>[
                  (label: 'SALES', percent: 55, color: HudColors.cyan),
                  (label: 'STOCK', percent: 81, color: HudColors.neonGreen),
                  (label: 'CASH', percent: 78, color: HudColors.orange),
                ],
                barValues: _kDemoBars,
                barLabels: const <String>[
                  'MON', 'TUE', 'WED', 'THU', 'FRI', 'SAT', 'SUN',
                ],
                waveformValues: _kDemoWave,
                isAnimating: _animating,
              ),
            ),
            _section(
              '5 · WAVEFORM — DECORATIVE (NO DATA)',
              HudWaveform(
                isAnimating: _animating,
                color: HudColors.magenta,
              ),
            ),
            _section(
              '6 · TYPING + GLITCH',
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  const HudTyping(
                    text: 'SYSTEM BOOT — DEMO',
                    speed: Duration(milliseconds: 60),
                  ),
                  const SizedBox(height: 10),
                  HudGlitch(
                    isError: true,
                    child: Text(
                      'ERROR: DEMO FAILURE (GLITCH ONLY ON ERROR)',
                      style: HudTextStyles.title
                          .copyWith(color: HudColors.red),
                    ),
                  ),
                ],
              ),
            ),
            _section(
              '7 · COUNT-UP + LINE CHART',
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  HudCountUp(
                    target: 125000,
                    usePkrFormat: true,
                    animate: _animating,
                  ),
                  const SizedBox(height: 10),
                  HudChartLine(
                    points: _kDemoChart,
                    animate: _animating,
                  ),
                ],
              ),
            ),
            _section(
              '8 · LOADING OVERLAY (INLINE, 62%)',
              HudLoadingOverlay(
                progress: 0.62,
                status: 'GENERATING REPORT...',
                fullscreen: false,
                isAnimating: _animating,
                particleBudget: 250,
              ),
            ),
            _section(
              '9 · DASHBOARD HERO (DEMO VALUES)',
              HudDashboardHero(
                salesToday: 125000,
                salesTarget: 200000,
                stockHealth: 0.81,
                cashDrawer: 86400,
                pendingUdhaarAmount: 45200,
                pendingUdhaarCount: 6,
                lowStockAlerts: 3,
                syncStatus: 'SYNCED 10:24',
                isSynced: true,
                isAnimating: _animating,
                particleBudget: _budget,
                frameSkip: _frameSkip,
              ),
            ),
            _section(
              '10 · SUCCESS PULSE',
              const Center(
                child: HudSuccessPulse(
                  message: 'TRANSACTION COMPLETE',
                  detail: 'BILL #1042 — DEMO',
                ),
              ),
            ),
            _section(
              '11 · ERROR GLITCH',
              const HudErrorGlitch(
                message: 'PAYMENT FAILED',
                detail: 'Demo error — please try again.',
              ),
            ),
            _section(
              '12 · BOOT SPLASH (TAP TO PREVIEW)',
              SizedBox(
                height: 48,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (BuildContext context) => Scaffold(
                          body: HudBootSplash(
                            onComplete: () =>
                                Navigator.of(context).pop(),
                          ),
                        ),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: HudColors.cyan,
                    foregroundColor: HudColors.background,
                  ),
                  child: const Text(
                    'PREVIEW BOOT SPLASH',
                    style: TextStyle(
                      fontFamily: HudTextStyles.monoFamily,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.5,
                    ),
                  ),
                ),
              ),
            ),
            _section(
              '13 · LOCK SCREEN (TAP TO PREVIEW)',
              SizedBox(
                height: 48,
                child: OutlinedButton(
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (BuildContext context) => Scaffold(
                          body: HudLockScreen(
                            rainValues: _kDemoRainValues,
                            isAnimating: _animating,
                            onUnlock: () =>
                                Navigator.of(context).pop(),
                          ),
                        ),
                      ),
                    );
                  },
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: HudColors.cyan),
                    foregroundColor: HudColors.cyan,
                  ),
                  child: const Text(
                    'PREVIEW LOCK SCREEN',
                    style: TextStyle(
                      fontFamily: HudTextStyles.monoFamily,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.5,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              height: 52,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (BuildContext context) =>
                          const HudPerformanceTestScreen(),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: HudColors.neonGreen,
                  foregroundColor: HudColors.background,
                ),
                child: const Text(
                  'RUN PERFORMANCE TEST',
                  style: TextStyle(
                    fontFamily: HudTextStyles.monoFamily,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.5,
                    fontSize: 15,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}

String isAnimatingLabel(bool animating) =>
    animating ? 'ANIMATING' : 'PAUSED';
