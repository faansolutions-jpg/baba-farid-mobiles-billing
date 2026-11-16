import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'hud_theme.dart';

/// Formats an integer with thousands separators (e.g. 125000 -> "125,000").
/// Pure helper, no intl dependency needed for the HUD.
String formatHudInt(num value) {
  final bool negative = value < 0;
  final String digits = value.abs().truncate().toString();
  final StringBuffer out = StringBuffer();
  for (int i = 0; i < digits.length; i++) {
    if (i > 0 && (digits.length - i) % 3 == 0) out.write(',');
    out.write(digits[i]);
  }
  return '${negative ? '-' : ''}$out';
}

/// Formats a whole-PKR amount: 125000 -> "Rs 125,000".
String formatHudPkr(num value) => 'Rs ${formatHudInt(value)}';

/// Animated count-up number.
///
/// Takes a [target] value and a [duration]. When [animate] is false
/// (animations off / reduced level), the target is shown statically
/// immediately — no motion, no timer.
class HudCountUp extends StatelessWidget {
  const HudCountUp({
    super.key,
    required this.target,
    this.duration = const Duration(milliseconds: 900),
    this.decimals = 0,
    this.prefix = '',
    this.suffix = '',
    this.style,
    this.animate = true,
    this.usePkrFormat = false,
  });

  /// Target value to count up to.
  final double target;

  final Duration duration;

  /// Decimal places to show (0 for whole PKR).
  final int decimals;
  final String prefix;
  final String suffix;
  final TextStyle? style;

  /// False renders [target] immediately (animations off).
  final bool animate;

  /// True formats the integer part with thousands separators and a
  /// "Rs " prefix (whole PKR, per the money rules).
  final bool usePkrFormat;

  String _format(double value) {
    if (usePkrFormat) {
      final String body = decimals == 0
          ? formatHudInt(value)
          : '${formatHudInt(value)}.${((value - value.truncate()).abs() * math.pow(10, decimals)).round().toString().padLeft(decimals, '0')}';
      return 'Rs $body$suffix';
    }
    final String body = decimals == 0
        ? formatHudInt(value)
        : value.toStringAsFixed(decimals);
    return '$prefix$body$suffix';
  }

  @override
  Widget build(BuildContext context) {
    final TextStyle textStyle = style ?? HudTextStyles.value;
    if (!animate) {
      return Text(_format(target), style: textStyle);
    }
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0, end: target),
      duration: duration,
      builder: (BuildContext context, double value, Widget? child) {
        return Text(_format(value), style: textStyle);
      },
    );
  }
}

/// Painter for the glowing line chart: smooth line through the points
/// plus a faint gradient fill underneath and a glow pass.
class _ChartLinePainter extends CustomPainter {
  _ChartLinePainter({
    required this.points,
    required this.color,
    required this.reveal,
  });

  final List<double> points;
  final Color color;

  /// 0.0-1.0 horizontal reveal progress (1.0 = fully drawn).
  final double reveal;

  @override
  void paint(Canvas canvas, Size size) {
    if (points.length < 2) return;
    final double minV = points.reduce(math.min);
    final double maxV = points.reduce(math.max);
    final double span = (maxV - minV) <= 0 ? 1 : (maxV - minV);

    Offset toPoint(int i) {
      final double x = size.width * (i / (points.length - 1));
      final double y = size.height -
          ((points[i] - minV) / span) * (size.height * 0.86) -
          size.height * 0.07;
      return Offset(x, y);
    }

    // Smooth path through the points (Catmull-Rom -> cubic Bezier).
    final Path path = Path()..moveTo(toPoint(0).dx, toPoint(0).dy);
    for (int i = 0; i < points.length - 1; i++) {
      final Offset p0 = toPoint(i == 0 ? 0 : i - 1);
      final Offset p1 = toPoint(i);
      final Offset p2 = toPoint(i + 1);
      final Offset p3 = toPoint(i + 2 >= points.length ? points.length - 1 : i + 2);
      final Offset c1 = p1 + (p2 - p0) / 6;
      final Offset c2 = p2 - (p3 - p1) / 6;
      path.cubicTo(c1.dx, c1.dy, c2.dx, c2.dy, p2.dx, p2.dy);
    }

    // Clip the path to the reveal progress.
    final Path revealed = Path();
    final Path clip = Path()
      ..addRect(Rect.fromLTWH(0, 0, size.width * reveal.clamp(0.0, 1.0), size.height));
    revealed.addPath(path, Offset.zero);
    final Path clipped = Path.combine(PathOperation.intersect, revealed, clip);

    // Fill under the line.
    final Path fill = Path.from(clipped)
      ..lineTo(size.width * reveal.clamp(0.0, 1.0), size.height)
      ..lineTo(0, size.height)
      ..close();
    final Paint fillPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: <Color>[
          color.withValues(alpha: 0.28),
          color.withValues(alpha: 0.0),
        ],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height))
      ..style = PaintingStyle.fill;
    canvas.drawPath(fill, fillPaint);

    // Glow pass then crisp line.
    final Paint glow = Paint()
      ..color = color.withValues(alpha: 0.35)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 6
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6);
    canvas.drawPath(clipped, glow);
    final Paint line = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..strokeJoin = StrokeJoin.round;
    canvas.drawPath(clipped, line);

    // End dot.
    if (reveal >= 1.0) {
      final Offset end = toPoint(points.length - 1);
      canvas.drawCircle(end, 3.5, Paint()..color = color);
      canvas.drawCircle(end, 3.5,
          Paint()..color = Colors.white.withValues(alpha: 0.85));
    }
  }

  @override
  bool shouldRepaint(covariant _ChartLinePainter oldDelegate) =>
      oldDelegate.points != points ||
      oldDelegate.color != color ||
      oldDelegate.reveal != reveal;
}

/// Glowing line chart from a list of real values ([points]) and a
/// [color]. The line reveals left-to-right when [animate] is true;
/// with animations off it draws fully at once.
class HudChartLine extends StatefulWidget {
  const HudChartLine({
    super.key,
    required this.points,
    this.color = HudColors.cyan,
    this.height = 90,
    this.animate = true,
  });

  final List<double> points;
  final Color color;
  final double height;
  final bool animate;

  @override
  State<HudChartLine> createState() => _HudChartLineState();
}

class _HudChartLineState extends State<HudChartLine>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    if (widget.animate) {
      _controller.forward();
    } else {
      _controller.value = 1.0;
    }
  }

  @override
  void didUpdateWidget(covariant HudChartLine oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!widget.animate) {
      _controller.value = 1.0;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.points.length < 2) {
      return SizedBox(
        height: widget.height,
        child: const Center(child: Text('NO DATA', style: HudTextStyles.label)),
      );
    }
    return RepaintBoundary(
      child: AnimatedBuilder(
        animation: _controller,
        builder: (BuildContext context, Widget? child) {
          return SizedBox(
            height: widget.height,
            width: double.infinity,
            child: CustomPaint(
              painter: _ChartLinePainter(
                points: widget.points,
                color: widget.color,
                reveal: _controller.value,
              ),
            ),
          );
        },
      ),
    );
  }
}
