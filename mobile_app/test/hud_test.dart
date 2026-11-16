import 'package:baba_farid_mobiles/features/hud/hud.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  // --- Pure helpers: particle budget + frame skip by level ------------
  group('particle budget selection by level', () {
    test('full -> 600 particles', () {
      expect(particleBudgetForLevel(HudAnimationLevel.full), 600);
    });

    test('reduced -> 250 particles', () {
      expect(particleBudgetForLevel(HudAnimationLevel.reduced), 250);
    });

    test('off -> 0 particles', () {
      expect(particleBudgetForLevel(HudAnimationLevel.off), 0);
    });

    test('frame skip: full 1 (60fps), reduced 2 (30fps)', () {
      expect(frameSkipForLevel(HudAnimationLevel.full), 1);
      expect(frameSkipForLevel(HudAnimationLevel.reduced), 2);
    });

    test('level parses from its storage value and back', () {
      for (final HudAnimationLevel level in HudAnimationLevel.values) {
        expect(
          HudAnimationLevel.fromString(level.storageValue),
          level,
        );
      }
      expect(HudAnimationLevel.fromString('nonsense'),
          HudAnimationLevel.full);
      expect(HudAnimationLevel.fromString(null), HudAnimationLevel.full);
    });
  });

  // --- Pure helpers: fps -> level thresholds --------------------------
  group('fps fallback thresholds', () {
    test('60fps and 50fps stay full', () {
      expect(levelForAverageFps(60), HudAnimationLevel.full);
      expect(levelForAverageFps(50), HudAnimationLevel.full);
    });

    test('49fps down to 28fps is reduced', () {
      expect(levelForAverageFps(49), HudAnimationLevel.reduced);
      expect(levelForAverageFps(35), HudAnimationLevel.reduced);
      expect(levelForAverageFps(28), HudAnimationLevel.reduced);
    });

    test('below 28fps is off', () {
      expect(levelForAverageFps(27.9), HudAnimationLevel.off);
      expect(levelForAverageFps(0), HudAnimationLevel.off);
    });
  });

  // --- Performance manager: fallback + pause rules --------------------
  group('HudPerformanceManager', () {
    test('three slow samples downgrade full -> reduced -> off', () {
      final HudPerformanceManager manager = HudPerformanceManager();
      expect(manager.currentLevel, HudAnimationLevel.full);
      expect(manager.particleBudget, 600);

      manager.applyFpsSample(30);
      manager.applyFpsSample(30);
      manager.applyFpsSample(30);
      expect(manager.currentLevel, HudAnimationLevel.reduced);
      expect(manager.particleBudget, 250);
      expect(manager.frameSkip, 2);

      manager.applyFpsSample(20);
      manager.applyFpsSample(20);
      manager.applyFpsSample(20);
      expect(manager.currentLevel, HudAnimationLevel.off);
      expect(manager.particleBudget, 0);
      expect(manager.shouldAnimate, isFalse);
    });

    test('a good sample resets the slow streak (no flapping)', () {
      final HudPerformanceManager manager = HudPerformanceManager();
      manager.applyFpsSample(30);
      manager.applyFpsSample(30);
      manager.applyFpsSample(60); // good sample resets the streak
      manager.applyFpsSample(30);
      manager.applyFpsSample(30);
      expect(manager.currentLevel, HudAnimationLevel.full);
    });

    test('level never auto-upgrades from a good sample', () {
      final HudPerformanceManager manager = HudPerformanceManager();
      manager.setLevel(HudAnimationLevel.reduced);
      manager.applyFpsSample(60);
      manager.applyFpsSample(60);
      expect(manager.currentLevel, HudAnimationLevel.reduced);
      manager.resetToFull();
      expect(manager.currentLevel, HudAnimationLevel.full);
    });

    test('pause rules: POS active, backgrounded, battery saver', () {
      final HudPerformanceManager manager = HudPerformanceManager();
      expect(manager.shouldAnimate, isTrue);

      manager.setPosActive(true);
      expect(manager.isPaused, isTrue);
      expect(manager.shouldAnimate, isFalse);
      manager.setPosActive(false);
      expect(manager.isPaused, isFalse);

      manager.didChangeAppLifecycleState(AppLifecycleState.paused);
      expect(manager.isBackgrounded, isTrue);
      expect(manager.isPaused, isTrue);
      manager.didChangeAppLifecycleState(AppLifecycleState.resumed);
      expect(manager.isPaused, isFalse);

      manager.setBatterySaver(true);
      expect(manager.isBatterySaver, isTrue);
      expect(manager.isPaused, isTrue);
      manager.setBatterySaver(false);
      expect(manager.shouldAnimate, isTrue);
    });
  });

  // --- DataRain: real values only --------------------------------------
  group('DataRain', () {
    test('splitIntoColumns shows every value exactly once per pass', () {
      const List<String> values = <String>[
        'IMEI 35988107...',
        'BILL-1042',
        'Rs 45,000',
      ];
      final List<List<String>> columns =
          DataRain.splitIntoColumns(values, 4);
      expect(columns.length, 4);
      final List<String> all =
          columns.expand((List<String> c) => c).toList();
      for (final String value in values) {
        expect(all, contains(value));
      }
    });

    testWidgets('renders the real values passed in (not random text)',
        (WidgetTester tester) async {
      const List<String> values = <String>[
        'IMEI 35988107...',
        'BILL-1042',
        'Rs 45,000',
      ];
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DataRain(values: values, columns: 3, height: 120),
          ),
        ),
      );
      await tester.pump();
      for (final String value in values) {
        expect(find.text(value), findsWidgets);
      }
    });
  });

  // --- HudCountUp --------------------------------------------------------
  group('HudCountUp', () {
    testWidgets('reaches the target value', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: HudCountUp(
              target: 125000,
              duration: Duration(milliseconds: 100),
              usePkrFormat: true,
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('Rs 125,000'), findsOneWidget);
    });

    testWidgets('shows the target immediately when animations are off',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: HudCountUp(
              target: 125000,
              animate: false,
              usePkrFormat: true,
            ),
          ),
        ),
      );
      await tester.pump();
      expect(find.text('Rs 125,000'), findsOneWidget);
    });

    test('PKR formatting groups thousands', () {
      expect(formatHudPkr(125000), 'Rs 125,000');
      expect(formatHudPkr(0), 'Rs 0');
      expect(formatHudInt(1000000), '1,000,000');
    });
  });

  // --- HudTyping -----------------------------------------------------------
  group('HudTyping', () {
    testWidgets('completes the full text', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: HudTyping(
              text: 'SYSTEM BOOT',
              speed: Duration(milliseconds: 10),
            ),
          ),
        ),
      );
      // Pump manually: the blinking cursor uses a periodic timer, so
      // pumpAndSettle would never settle.
      for (int i = 0;
          i < 30 && find.text('SYSTEM BOOT').evaluate().isEmpty;
          i++) {
        await tester.pump(const Duration(milliseconds: 50));
      }
      expect(find.text('SYSTEM BOOT'), findsOneWidget);
    });
  });

  // --- Static widgets render ----------------------------------------------
  group('HUD widgets render', () {
    testWidgets('HudCore and HudPanel render without error',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Column(
              children: <Widget>[
                HudCore(size: 120, particleBudget: 250),
                HudPanel(title: 'ANALYSING DATA', child: Text('test')),
              ],
            ),
          ),
        ),
      );
      await tester.pump();
      expect(find.text('ANALYSING DATA'), findsOneWidget);
      expect(find.byType(HudCore), findsOneWidget);
    });

    testWidgets('HudGlitch passes the child through when not an error',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: HudGlitch(
              isError: false,
              child: Text('plain child'),
            ),
          ),
        ),
      );
      await tester.pump();
      expect(find.text('plain child'), findsOneWidget);
    });

    testWidgets('HudDashboardHero shows real values passed in',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: HudDashboardHero(
                salesToday: 125000,
                salesTarget: 200000,
                stockHealth: 0.81,
                cashDrawer: 86400,
                pendingUdhaarAmount: 45200,
                pendingUdhaarCount: 6,
                lowStockAlerts: 3,
                syncStatus: 'SYNCED 10:24',
                isSynced: true,
                isAnimating: false,
              ),
            ),
          ),
        ),
      );
      await tester.pump();
      expect(find.text('CORE TEMP'), findsOneWidget);
      expect(find.text('CASH DRAWER'), findsOneWidget);
      expect(find.text('PENDING UDHAAR'), findsOneWidget);
      expect(find.text('SYNCED 10:24'), findsOneWidget);
      expect(find.text('Rs 86,400'), findsOneWidget);
    });
  });

  // --- Settings keys round-trip -------------------------------------------
  group('HudSettings keys round-trip', () {
    test('load/save round-trips through the exact keys', () async {
      SharedPreferences.setMockInitialValues(<String, Object>{});
      const AnimationSettings saved = AnimationSettings(
        level: HudAnimationLevel.reduced,
        batterySaverAutoOff: false,
        videoBackground: true,
        videoBackgroundPath: 'assets/hud_loop.mp4',
      );
      await HudSettings.save(saved);

      final SharedPreferences prefs =
          await SharedPreferences.getInstance();
      expect(prefs.getString('hud_animation_level'), 'reduced');
      expect(prefs.getBool('hud_battery_saver_auto_off'), isFalse);
      expect(prefs.getBool('hud_video_background'), isTrue);
      expect(
        prefs.getString('hud_video_background_path'),
        'assets/hud_loop.mp4',
      );

      final AnimationSettings loaded = await HudSettings.load();
      expect(loaded, saved);
      expect(HudSettings.notifier.value, saved);
    });

    test('load defaults to full when nothing is stored', () async {
      SharedPreferences.setMockInitialValues(<String, Object>{});
      final AnimationSettings loaded = await HudSettings.load();
      expect(loaded.level, HudAnimationLevel.full);
      expect(loaded.batterySaverAutoOff, isTrue);
      expect(loaded.videoBackground, isFalse);
      expect(loaded.videoBackgroundPath, isEmpty);
    });
  });
}
