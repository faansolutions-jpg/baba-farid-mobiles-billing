# Holographic HUD — Integration Guide (Round 2)

> M6-HUD. Original code-drawn animation only: every widget is drawn
> with Flutter `CustomPainter` code. No copied footage, logos, or
> movie layouts (DECISIONS.md #39). HUD labels stay English; Urdu
> text uses Noto Nastaliq Urdu; important numbers keep WCAG AA
> contrast on the `#0A0E14` background.

All widgets live in `lib/features/hud/` and are exported from
`lib/features/hud/hud.dart`. They are **data-driven**: every widget
takes real shop values as constructor params — never random text.
`DataRain` scrolls only the values you pass in (IMEI fragments, bill
numbers, amounts). The demo gallery is the one place illustrative
values are allowed, and it labels them as such.

## Which widget goes where

| Destination | Widget | Wiring |
|---|---|---|
| Splash screen (`lib/features/auth/`) | `HudBootSplash` | Standalone widget. Show it first; its `onComplete` fires after the core assembles and the boot lines are typed — then navigate to login/home. Pass real `bootSteps` (label + duration each). Do NOT re-implement the boot sequence in the splash screen. |
| Reports / sync / backup / Excel import | `HudLoadingOverlay` | Put it in a `Stack` over the running screen. Feed it the **real** `progress` (0.0–1.0) and `status` label from the running task. `fullscreen: true` paints the HUD background; `false` renders just the panel inline. |
| Dashboard | `HudDashboardHero` | Feed it from the repositories: `salesToday` / `salesTarget` (SaleRepository), `stockHealth` (ProductRepository), `cashDrawer` (cash register), `pendingUdhaarAmount` / `pendingUdhaarCount` (CustomerRepository ledger), `lowStockAlerts`, `syncStatus` / `isSynced` (SyncEngine). All numbers use `HudCountUp`. |
| Inactivity lock (auto-lock, 2 min default) | `HudLockScreen` | Show after inactivity. Pass real `rainValues` (recent bill numbers / IMEI fragments / amounts). `onUnlock` must run biometric/PIN via `local_auth` — the widget does NOT do biometric itself. Pass `isUnlocking: true` while verification runs. |
| POS bill saved | `HudSuccessPulse` | Show `message: 'TRANSACTION COMPLETE'` + `detail: 'BILL #<no>'`. `onDone` fires after the pulse so you can dismiss it / print. |
| POS / sync / import failure | `HudErrorGlitch` | Red glitch panel with `message` + `detail`. The glitch effect applies ONLY on errors (`HudGlitch(isError: true)`). |
| Any screen background | `HudBackground` | Faint grid + scanlines + drifting particles at low opacity. `opacity` scales it; `isAnimating: false` freezes it. |
| Optional video background | `HudVideoBackground` | See below. |
| Settings screen | `HudSettings` + `HudPerformanceManager` | See "Settings keys". |

## Building blocks

- `HudCore` — rotating particle sphere + orbiting dotted rings.
  `health` 0–1 shifts cyan → orange; `particleBudget` caps the
  pre-computed particles (600/250/0); `frameSkip` 1 = 60 fps, 2 = 30 fps;
  `isAnimating: false` pauses. Budget 0 renders `HudStaticCore`
  (one static frame, no ticker).
- `HudPanel` — angled cut-corner panel, `title` + `child` + `accent`.
- `DataRain` — scrolling columns of the exact `values` passed in.
- `HudGauges` — circular gauge, percentage bars, mini bar graph,
  live waveform. `HudWaveform` plots real `values` when given;
  with no values it draws a decorative sine wave (not fake data).
- `HudTyping` — typing effect + blinking cursor; `HudGlitch` wraps a
  child and glitches only when `isError` is true.
- `HudCountUp` — animated count-up; `animate: false` shows the
  target immediately. `HudChartLine` — glowing line chart from
  real `points`.
- `HudVideoBackground` — muted looping video; falls back to
  `HudBackground` when no video is set or the player fails.

## Settings keys (SharedPreferences — exact strings)

These keys are the contract between `HudSettings` and the settings
screen. Use them verbatim; do not rename.

| Key | Type | Meaning |
|---|---|---|
| `hud_animation_level` | String `full` / `reduced` / `off` | Animation level |
| `hud_battery_saver_auto_off` | bool | Auto-pause animations when battery saver is on |
| `hud_video_background` | bool | Use the looping video background |
| `hud_video_background_path` | String | Asset path of the video, e.g. `assets/hud_loop.mp4` (empty = none) |

```dart
// Load once at startup (publishes to HudSettings.notifier):
final settings = await HudSettings.load();

// Live updates anywhere:
ValueListenableBuilder<AnimationSettings>(
  valueListenable: HudSettings.notifier,
  builder: (context, settings, _) => ...,
);

// Save from the settings screen:
await HudSettings.save(settings.copyWith(level: HudAnimationLevel.reduced));
```

## Performance rules (enforced, not just documented)

- **Pre-computed particles:** sphere positions are computed once
  (Fibonacci sphere, fixed scatter for boot) and reused every frame.
- **RepaintBoundary** around every animated painter.
- **Fixed particle budget:** full 600, reduced 250, off 0 (static).
- **Auto-fallback:** `HudPerformanceManager` measures real fps from
  `SchedulerBinding` frame timings. After 3 consecutive samples
  below 45 fps it steps down full → reduced → off. It never
  auto-upgrades (avoids oscillation); the user picks "Full" again in
  Settings (`resetToFull()`).
- **Frame skipping:** reduced level repaints every 2nd frame
  (`frameSkip: 2`, 30 fps); rotation still advances by elapsed time.
- **Pause rules:** animation pauses while the POS screen is active
  (`setPosActive(true)` — call it from the POS route), while the app
  is backgrounded (lifecycle observer), or while battery saver is on
  (`setBatterySaver(true)`). `shouldAnimate` combines all three.
- **POS stays fast:** HUD work never runs on the POS screen; billing
  must still respond in under 1 second.

Start the manager once (e.g. in `main.dart` / app shell):

```dart
final hudPerformance = HudPerformanceManager.instance;
hudPerformance.start(); // measures fps + watches lifecycle
// In the POS route: hudPerformance.setPosActive(true) on enter,
// setPosActive(false) on exit.
```

The manager exposes `currentFps`, `currentLevel`, `particleBudget`,
`frameSkip`, `isPaused`, `shouldAnimate`.

## Video background

1. Render the loop with `docs/hud_video_render.md` (720p H.264,
   < 5 MB) and place it at `mobile_app/assets/hud_loop.mp4`.
2. Declare the asset in `pubspec.yaml` (foundation agent owns
   pubspec — ask them to add `assets/hud_loop.mp4`).
3. Enable in Settings: `hud_video_background = true` and
   `hud_video_background_path = 'assets/hud_loop.mp4'`.
4. Wrap the screen: `HudVideoBackground(videoAssetPath: path, child: ...)`.
   The video is muted, looped, pauses when hidden/backgrounded, and
   falls back to `HudBackground` on any failure. No video file is
   bundled by default.

   > Web note: `videoFilePath` uses `dart:io` and is Android/desktop
   > only — on Flutter Web use `videoAssetPath` (bundled asset),
   > which works on all platforms.

## Demo gallery & performance test

- `lib/features/hud/demo/hud_demo_gallery.dart` — `HudDemoGallery`
  shows every widget with clearly-labelled illustrative values and a
  level switcher + "POS ACTIVE" pause toggle. Title:
  "HUD DEMO — illustrative values".
- `lib/features/hud/hud_performance_test.dart` —
  `HudPerformanceTestScreen` runs core + rain + gauges for 10 s,
  measures average fps, and reports the recommended level.
  Reach it from the gallery ("RUN PERFORMANCE TEST").

## Theme unification (Round 2)

`hud_theme.dart` mirrors the cyberpunk tokens locally
(`HudColors`, `HudTextStyles`, `HudAnimationLevel`). In Round 2,
point `HudColors` at the shared `CyberColors` / `CyberTextStyles`
(`lib/core/theme/`) and delete the duplicates — keep the
`HudAnimationLevel` enum and the pure helpers
(`particleBudgetForLevel`, `frameSkipForLevel`,
`levelForAverageFps`) where they are, since the tests import them.
