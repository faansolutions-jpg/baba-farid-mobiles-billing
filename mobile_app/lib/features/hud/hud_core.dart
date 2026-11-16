import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

import 'hud_theme.dart';

/// A 3D point on the unit sphere. Kept as a tiny local class so the
/// HUD does not depend on vector_math.
class _Vec3 {
  const _Vec3(this.x, this.y, this.z);
  final double x;
  final double y;
  final double z;
}

/// Pre-computed particle positions on a sphere (Fibonacci sphere:
/// deterministic, evenly spread, computed exactly once).
///
/// 600 points is the full particle budget (DECISIONS.md #42); lower
/// budgets simply use a prefix of this list, so no work is ever
/// re-done per frame.
List<_Vec3> _buildSpherePoints(int count) {
  final List<_Vec3> points = <_Vec3>[];
  final double goldenAngle = math.pi * (3.0 - math.sqrt(5.0));
  for (int i = 0; i < count; i++) {
    final double y = 1.0 - (i / (count - 1)) * 2.0; // -1 .. 1
    final double radius = math.sqrt(math.max(0.0, 1.0 - y * y));
    final double theta = goldenAngle * i;
    points.add(_Vec3(math.cos(theta) * radius, y, math.sin(theta) * radius));
  }
  return points;
}

/// Pre-computed "scattered" positions used while the core assembles
/// during boot: a fixed-seed deterministic scatter, so the boot
/// animation looks the same every run and costs nothing per frame.
List<_Vec3> _buildScatterPoints(int count) {
  final math.Random random = math.Random(1337);
  return List<_Vec3>.generate(count, (_) {
    final double theta = random.nextDouble() * math.pi * 2.0;
    final double phi = math.acos(2.0 * random.nextDouble() - 1.0);
    final double r = 1.6 + random.nextDouble() * 1.1;
    return _Vec3(
      r * math.sin(phi) * math.cos(theta),
      r * math.sin(phi) * math.sin(theta),
      r * math.cos(phi),
    );
  });
}

final List<_Vec3> _kSpherePoints = _buildSpherePoints(600);
final List<_Vec3> _kScatterPoints = _buildScatterPoints(600);

/// Painter for the holographic core: a particle sphere plus three
/// orbiting concentric dotted rings. All geometry is pre-computed;
/// [paint] only rotates, projects and draws.
///
/// [rotation] is the current Y-rotation in radians. [assembleProgress]
/// (0.0-1.0) lerps particles from their scattered boot positions to
/// the sphere; 1.0 is the fully assembled core.
class HudCorePainter extends CustomPainter {
  HudCorePainter({
    required this.rotation,
    required this.color,
    required this.particleCount,
    this.assembleProgress = 1.0,
    this.ringRotation = 0.0,
  });

  final double rotation;
  final Color color;
  final int particleCount;
  final double assembleProgress;
  final double ringRotation;

  @override
  void paint(Canvas canvas, Size size) {
    final Offset center = Offset(size.width / 2, size.height / 2);
    final double radius = math.min(size.width, size.height) * 0.38;

    final double cosA = math.cos(rotation);
    final double sinA = math.sin(rotation);
    // Fixed slight X tilt so the sphere reads as 3D.
    const double tilt = 0.38;
    final double cosT = math.cos(tilt);
    final double sinT = math.sin(tilt);

    // --- Orbiting dotted rings (drawn first, behind the sphere). ---
    _drawRing(canvas, center, radius * 1.28, ringRotation, HudColors.cyan,
        dots: 72, tiltSquash: 0.32);
    _drawRing(canvas, center, radius * 1.45, -ringRotation * 0.7,
        HudColors.neonGreen,
        dots: 56, tiltSquash: 0.32);
    _drawRing(canvas, center, radius * 1.08, ringRotation * 1.6,
        HudColors.orange,
        dots: 40, tiltSquash: 0.32);

    // --- Particle sphere. ---
    final int count = particleCount.clamp(0, _kSpherePoints.length);
    final double progress = assembleProgress.clamp(0.0, 1.0);
    for (int i = 0; i < count; i++) {
      final _Vec3 sphere = _kSpherePoints[i];
      final _Vec3 scattered = _kScatterPoints[i];
      final double sx = _lerp(scattered.x, sphere.x, progress);
      final double sy = _lerp(scattered.y, sphere.y, progress);
      final double sz = _lerp(scattered.z, sphere.z, progress);

      // Rotate around Y, then tilt around X.
      final double rx = sx * cosA + sz * sinA;
      final double rz = -sx * sinA + sz * cosA;
      final double ry = sy * cosT - rz * sinT;
      final double rz2 = sy * sinT + rz * cosT;

      // Simple perspective projection; front particles are bigger/brighter.
      const double focal = 3.0;
      final double scale = focal / (focal - rz2);
      final double depth = (rz2 + 1.0) / 2.0; // 0 = back, 1 = front
      final Offset pos = center + Offset(rx * radius * scale, ry * radius * scale);
      final double dotRadius = 0.8 + depth * 1.9;
      final Paint paint = Paint()
        ..color = color.withValues(alpha: 0.25 + depth * 0.75)
        ..style = PaintingStyle.fill;
      canvas.drawCircle(pos, dotRadius, paint);
    }

    // --- Centre glow dot. ---
    final Paint glow = Paint()
      ..color = color.withValues(alpha: 0.85)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10);
    canvas.drawCircle(center, 5, glow);
    canvas.drawCircle(center, 2.5, Paint()..color = Colors.white);
  }

  void _drawRing(Canvas canvas, Offset center, double radius, double rotation,
      Color color,
      {required int dots, required double tiltSquash}) {
    for (int i = 0; i < dots; i++) {
      final double a = (i / dots) * math.pi * 2.0 + rotation;
      final Offset pos = center +
          Offset(math.cos(a) * radius, math.sin(a) * radius * tiltSquash);
      final double alpha = 0.25 + 0.55 * (0.5 + 0.5 * math.sin(a * 2.0));
      canvas.drawCircle(
        pos,
        1.6,
        Paint()..color = color.withValues(alpha: alpha.clamp(0.0, 1.0)),
      );
    }
  }

  static double _lerp(double a, double b, double t) => a + (b - a) * t;

  @override
  bool shouldRepaint(covariant HudCorePainter oldDelegate) {
    return oldDelegate.rotation != rotation ||
        oldDelegate.ringRotation != ringRotation ||
        oldDelegate.color != color ||
        oldDelegate.particleCount != particleCount ||
        oldDelegate.assembleProgress != assembleProgress;
  }
}

/// Static (non-animated) core: a single pre-rendered frame of
/// [HudCorePainter]. Used when the animation level is `off`
/// (DECISIONS.md #42) — zero per-frame work.
class HudStaticCore extends StatelessWidget {
  const HudStaticCore({
    super.key,
    this.size = 220,
    this.health = 1.0,
    this.particleBudget = 600,
  });

  final double size;
  final double health;
  final int particleBudget;

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: SizedBox(
        width: size,
        height: size,
        child: CustomPaint(
          painter: HudCorePainter(
            rotation: 0.6,
            ringRotation: 0.4,
            color: HudColors.colorForHealth(health),
            particleCount: particleBudget,
          ),
        ),
      ),
    );
  }
}

/// The holographic HUD core: a slowly rotating 3D-looking particle
/// sphere with orbiting concentric dotted rings, drawn entirely in
/// code ([HudCorePainter]).
///
/// * [health] (0.0-1.0) shifts the core colour cyan (healthy) ->
///   orange (needs attention).
/// * [particleBudget] caps how many of the 600 pre-computed particles
///   are drawn (600 / 250 / 0, from [particleBudgetForLevel]).
/// * [frameSkip] 1 = 60 fps, 2 = every second frame (30 fps, reduced
///   level). Rotation still advances by elapsed time, so motion stays
///   correct at the lower rate.
/// * [isAnimating] false pauses the ticker; the last frame stays.
/// * [assembleProgress] (0.0-1.0) is used by the boot splash to show
///   the core assembling from scattered particles.
class HudCore extends StatefulWidget {
  const HudCore({
    super.key,
    this.size = 220,
    this.health = 1.0,
    this.particleBudget = 600,
    this.isAnimating = true,
    this.frameSkip = 1,
    this.assembleProgress = 1.0,
  });

  final double size;
  final double health;
  final int particleBudget;
  final bool isAnimating;
  final int frameSkip;
  final double assembleProgress;

  @override
  State<HudCore> createState() => _HudCoreState();
}

class _HudCoreState extends State<HudCore>
    with SingleTickerProviderStateMixin {
  late final Ticker _ticker;
  Duration _elapsed = Duration.zero;
  Duration _lastTick = Duration.zero;
  int _tickCount = 0;
  bool _started = false;

  @override
  void initState() {
    super.initState();
    _ticker = createTicker(_onTick);
    if (widget.isAnimating && widget.particleBudget > 0) {
      _ticker.start();
      _started = true;
    }
  }

  @override
  void didUpdateWidget(covariant HudCore oldWidget) {
    super.didUpdateWidget(oldWidget);
    final bool wantRunning =
        widget.isAnimating && widget.particleBudget > 0;
    if (wantRunning && !_started) {
      _ticker.start();
      _started = true;
    } else if (!wantRunning && _started) {
      _ticker.stop();
      _started = false;
      _lastTick = Duration.zero;
    }
  }

  void _onTick(Duration elapsed) {
    if (_lastTick == Duration.zero) {
      _lastTick = elapsed;
      return;
    }
    final Duration delta = elapsed - _lastTick;
    _lastTick = elapsed;
    // Always advance by elapsed time (so motion stays correct at
    // 30 fps); only the repaint is skipped on alternate ticks.
    _elapsed += delta;
    _tickCount++;
    if (_tickCount % widget.frameSkip.clamp(1, 4) != 0) return;
    setState(() {});
  }

  @override
  void dispose() {
    _ticker.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Budget 0 (level `off`) renders the static snapshot: no ticker,
    // no per-frame work.
    if (widget.particleBudget <= 0) {
      return HudStaticCore(
        size: widget.size,
        health: widget.health,
        particleBudget: 600,
      );
    }
    final double seconds = _elapsed.inMilliseconds / 1000.0;
    return RepaintBoundary(
      child: SizedBox(
        width: widget.size,
        height: widget.size,
        child: CustomPaint(
          painter: HudCorePainter(
            rotation: seconds * 0.35,
            ringRotation: seconds * 0.5,
            color: HudColors.colorForHealth(widget.health),
            particleCount: widget.particleBudget,
            assembleProgress: widget.assembleProgress,
          ),
        ),
      ),
    );
  }
}
