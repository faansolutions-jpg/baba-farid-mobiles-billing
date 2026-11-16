import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'hud_theme.dart';

/// Pre-computed drift-particle seeds (fixed, deterministic): each entry
/// is (x fraction, y fraction, phase, speed). Computed once, never per
/// frame.
final List<(double, double, double, double)> _kDriftSeeds =
    List<(double, double, double, double)>.generate(42, (int i) {
  final math.Random random = math.Random(20261116 + i);
  return (
    random.nextDouble(),
    random.nextDouble(),
    random.nextDouble() * math.pi * 2,
    0.4 + random.nextDouble() * 0.8,
  );
});

class _GridPainter extends CustomPainter {
  _GridPainter(this.opacity);

  final double opacity;

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..color = HudColors.cyan.withValues(alpha: 0.06 * opacity)
      ..strokeWidth = 1;
    const double step = 28;
    for (double x = 0; x <= size.width; x += step) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    for (double y = 0; y <= size.height; y += step) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(covariant _GridPainter oldDelegate) =>
      oldDelegate.opacity != opacity;
}

class _ScanlinesPainter extends CustomPainter {
  _ScanlinesPainter(this.opacity, this.bandPosition);

  final double opacity;

  /// 0.0-1.0 vertical position of the slow moving bright scan band.
  final double bandPosition;

  @override
  void paint(Canvas canvas, Size size) {
    final Paint linePaint = Paint()
      ..color = HudColors.text.withValues(alpha: 0.025 * opacity)
      ..strokeWidth = 1;
    for (double y = 0; y <= size.height; y += 4) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), linePaint);
    }
    // Slow drifting bright band.
    final double bandY = bandPosition * size.height;
    final Paint bandPaint = Paint()
      ..color = HudColors.cyan.withValues(alpha: 0.05 * opacity)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 18);
    canvas.drawRect(
      Rect.fromLTWH(0, bandY - 14, size.width, 28),
      bandPaint,
    );
  }

  @override
  bool shouldRepaint(covariant _ScanlinesPainter oldDelegate) =>
      oldDelegate.opacity != opacity ||
      oldDelegate.bandPosition != bandPosition;
}

class _DriftParticlesPainter extends CustomPainter {
  _DriftParticlesPainter(this.opacity, this.time);

  final double opacity;

  /// Elapsed seconds; particles drift slowly with sin/cos of time.
  final double time;

  @override
  void paint(Canvas canvas, Size size) {
    for (final (double, double, double, double) seed in _kDriftSeeds) {
      final double x = (seed.$1 +
              0.02 * math.sin(time * 0.12 * seed.$4 + seed.$3)) *
          size.width;
      final double y = (seed.$2 +
              0.03 * math.cos(time * 0.10 * seed.$4 + seed.$3)) *
          size.height;
      final double alpha =
          (0.10 + 0.10 * math.sin(time * 0.25 * seed.$4 + seed.$3))
              .clamp(0.02, 0.22);
      canvas.drawCircle(
        Offset(x, y),
        1.4,
        Paint()..color = HudColors.cyan.withValues(alpha: alpha * opacity),
      );
    }
  }

  @override
  bool shouldRepaint(covariant _DriftParticlesPainter oldDelegate) =>
      oldDelegate.time != time || oldDelegate.opacity != opacity;
}

/// Faint HUD background: grid + scanlines + slow drifting particles
/// at very low opacity, usable behind any screen.
///
/// [opacity] scales every layer (0.0 = invisible). [isAnimating]
/// false freezes the scan band and particles (grid stays, one static
/// frame is drawn).
class HudBackground extends StatefulWidget {
  const HudBackground({
    super.key,
    this.opacity = 1.0,
    this.isAnimating = true,
    this.child,
  });

  final double opacity;
  final bool isAnimating;
  final Widget? child;

  @override
  State<HudBackground> createState() => _HudBackgroundState();
}

class _HudBackgroundState extends State<HudBackground>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    // One very slow cycle (60 s) drives both the scan band and drift.
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 60),
    );
    if (widget.isAnimating) _controller.repeat();
  }

  @override
  void didUpdateWidget(covariant HudBackground oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isAnimating && !_controller.isAnimating) {
      _controller.repeat();
    } else if (!widget.isAnimating && _controller.isAnimating) {
      _controller.stop();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final double opacity = widget.opacity.clamp(0.0, 1.0);
    return RepaintBoundary(
      child: Stack(
        fit: StackFit.expand,
        children: <Widget>[
          Container(color: HudColors.background),
          CustomPaint(
            painter: _GridPainter(opacity),
            size: Size.infinite,
          ),
          AnimatedBuilder(
            animation: _controller,
            builder: (BuildContext context, Widget? child) {
              final double t = _controller.value;
              return Stack(
                fit: StackFit.expand,
                children: <Widget>[
                  CustomPaint(
                    painter: _ScanlinesPainter(opacity, t),
                    size: Size.infinite,
                  ),
                  CustomPaint(
                    painter:
                        _DriftParticlesPainter(opacity, t * 60.0),
                    size: Size.infinite,
                  ),
                ],
              );
            },
          ),
          if (widget.child != null) widget.child!,
        ],
      ),
    );
  }
}
