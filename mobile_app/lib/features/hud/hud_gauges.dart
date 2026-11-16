import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'hud_theme.dart';

/// Circular gauge painter: track ring + glowing value arc + centre text.
class _GaugePainter extends CustomPainter {
  _GaugePainter({required this.value, required this.color});

  final double value; // 0.0-1.0
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final Offset center = Offset(size.width / 2, size.height / 2);
    final double radius = math.min(size.width, size.height) / 2 - 8;
    const double startAngle = -math.pi / 2;
    final Rect rect = Rect.fromCircle(center: center, radius: radius);

    final Paint track = Paint()
      ..color = HudColors.text.withValues(alpha: 0.12)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 7
      ..strokeCap = StrokeCap.round;
    canvas.drawArc(rect, 0, math.pi * 2, false, track);

    // Glow pass (wide, faint) then the crisp arc.
    final double sweep = (value.clamp(0.0, 1.0)) * math.pi * 2;
    final Paint glow = Paint()
      ..color = color.withValues(alpha: 0.30)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 13
      ..strokeCap = StrokeCap.round
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6);
    canvas.drawArc(rect, startAngle, sweep, false, glow);
    final Paint arc = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 7
      ..strokeCap = StrokeCap.round;
    canvas.drawArc(rect, startAngle, sweep, false, arc);
  }

  @override
  bool shouldRepaint(covariant _GaugePainter oldDelegate) =>
      oldDelegate.value != value || oldDelegate.color != color;
}

/// A circular gauge: value 0-1, a label under it and the percentage
/// in the centre. All values come from constructor params.
class HudCircularGauge extends StatelessWidget {
  const HudCircularGauge({
    super.key,
    required this.value,
    required this.label,
    this.color = HudColors.cyan,
    this.size = 110,
    this.isAnimating = true,
  });

  final double value;
  final String label;
  final Color color;
  final double size;
  final bool isAnimating;

  @override
  Widget build(BuildContext context) {
    final double clamped = value.clamp(0.0, 1.0);
    final Widget gauge = RepaintBoundary(
      child: SizedBox(
        width: size,
        height: size,
        child: Stack(
          alignment: Alignment.center,
          children: <Widget>[
            CustomPaint(
              size: Size(size, size),
              painter: _GaugePainter(value: clamped, color: color),
            ),
            Text(
              '${(clamped * 100).round()}%',
              style: HudTextStyles.valueSmall.copyWith(color: color),
            ),
          ],
        ),
      ),
    );
    final Widget withAnimation = isAnimating
        ? TweenAnimationBuilder<double>(
            tween: Tween<double>(begin: 0, end: clamped),
            duration: const Duration(milliseconds: 900),
            builder: (BuildContext context, double animated, Widget? child) {
              return RepaintBoundary(
                child: SizedBox(
                  width: size,
                  height: size,
                  child: Stack(
                    alignment: Alignment.center,
                    children: <Widget>[
                      CustomPaint(
                        size: Size(size, size),
                        painter: _GaugePainter(value: animated, color: color),
                      ),
                      Text(
                        '${(animated * 100).round()}%',
                        style:
                            HudTextStyles.valueSmall.copyWith(color: color),
                      ),
                    ],
                  ),
                ),
              );
            },
          )
        : gauge;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        withAnimation,
        const SizedBox(height: 6),
        Text(
          label.toUpperCase(),
          style: HudTextStyles.label,
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}

/// One labelled percentage bar, e.g. "SALES 55%".
class HudPercentBar extends StatelessWidget {
  const HudPercentBar({
    super.key,
    required this.label,
    required this.percent,
    this.color = HudColors.cyan,
    this.isAnimating = true,
  });

  final String label;
  final double percent; // 0-100
  final Color color;
  final bool isAnimating;

  @override
  Widget build(BuildContext context) {
    final double clamped = percent.clamp(0.0, 100.0);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Text(label.toUpperCase(), style: HudTextStyles.label),
            Text(
              '${clamped.round()}%',
              style: HudTextStyles.valueSmall.copyWith(color: color),
            ),
          ],
        ),
        const SizedBox(height: 4),
        RepaintBoundary(
          child: Container(
            height: 8,
            decoration: BoxDecoration(
              color: HudColors.text.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(2),
            ),
            child: LayoutBuilder(
              builder: (BuildContext context, BoxConstraints constraints) {
                final Widget bar = Container(
                  width: constraints.maxWidth * (clamped / 100),
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(2),
                    boxShadow: <BoxShadow>[
                      BoxShadow(
                        color: color.withValues(alpha: 0.5),
                        blurRadius: 8,
                      ),
                    ],
                  ),
                );
                if (!isAnimating) {
                  return Align(
                  alignment: Alignment.centerLeft,
                  child: bar,
                );
                }
                return TweenAnimationBuilder<double>(
                  tween: Tween<double>(begin: 0, end: clamped / 100),
                  duration: const Duration(milliseconds: 800),
                  builder: (BuildContext context, double v, Widget? child) {
                    return Align(
                      alignment: Alignment.centerLeft,
                      child: Container(
                        width: constraints.maxWidth * v,
                        decoration: BoxDecoration(
                          color: color,
                          borderRadius: BorderRadius.circular(2),
                          boxShadow: <BoxShadow>[
                            BoxShadow(
                              color: color.withValues(alpha: 0.5),
                              blurRadius: 8,
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ),
      ],
    );
  }
}

/// A labelled set of percentage bars, e.g. "55% 81% 78%".
/// Pass the real values in as [bars] (label + percent pairs).
class HudPercentBars extends StatelessWidget {
  const HudPercentBars({
    super.key,
    required this.bars,
    this.isAnimating = true,
  });

  /// Each entry is (label, percent 0-100, colour).
  final List<({String label, double percent, Color color})> bars;
  final bool isAnimating;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        for (int i = 0; i < bars.length; i++) ...<Widget>[
          HudPercentBar(
            label: bars[i].label,
            percent: bars[i].percent,
            color: bars[i].color,
            isAnimating: isAnimating,
          ),
          if (i < bars.length - 1) const SizedBox(height: 10),
        ],
      ],
    );
  }
}

/// Mini bar-graph block from a list of real values (normalised
/// internally to the max value). Each bar gets a label when [labels]
/// is supplied.
class HudMiniBarGraph extends StatelessWidget {
  const HudMiniBarGraph({
    super.key,
    required this.values,
    this.labels,
    this.color = HudColors.neonGreen,
    this.height = 64,
    this.isAnimating = true,
  });

  final List<double> values;
  final List<String>? labels;
  final Color color;
  final double height;
  final bool isAnimating;

  @override
  Widget build(BuildContext context) {
    if (values.isEmpty) {
      return SizedBox(
        height: height,
        child: const Center(
          child: Text('NO DATA', style: HudTextStyles.label),
        ),
      );
    }
    final double max =
        values.reduce(math.max) <= 0 ? 1 : values.reduce(math.max);
    return SizedBox(
      height: height,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: <Widget>[
          for (int i = 0; i < values.length; i++)
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 2),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  mainAxisSize: MainAxisSize.max,
                  children: <Widget>[
                    Expanded(
                      child: Align(
                        alignment: Alignment.bottomCenter,
                        child: _AnimatedBar(
                          fraction: (values[i] / max).clamp(0.0, 1.0),
                          color: color,
                          isAnimating: isAnimating,
                        ),
                      ),
                    ),
                    if (labels != null && i < labels!.length)
                      Padding(
                        padding: const EdgeInsets.only(top: 3),
                        child: Text(
                          labels![i],
                          style: HudTextStyles.label.copyWith(fontSize: 9),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _AnimatedBar extends StatelessWidget {
  const _AnimatedBar({
    required this.fraction,
    required this.color,
    required this.isAnimating,
  });

  final double fraction;
  final Color color;
  final bool isAnimating;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        final double targetHeight =
            (constraints.maxHeight * fraction).clamp(2.0, double.infinity);
        if (!isAnimating) {
          return Container(
            height: targetHeight,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.85),
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(2)),
            ),
          );
        }
        return TweenAnimationBuilder<double>(
          tween: Tween<double>(begin: 0, end: targetHeight),
          duration: const Duration(milliseconds: 700),
          builder: (BuildContext context, double h, Widget? child) {
            return Container(
              height: h,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.85),
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(2)),
              ),
            );
          },
        );
      },
    );
  }
}

/// Painter for the live waveform strip.
class _WaveformPainter extends CustomPainter {
  _WaveformPainter({
    required this.values,
    required this.color,
    required this.phase,
  });

  /// Real values (normalised 0-1 by the widget) when supplied;
  /// empty means "draw the decorative smooth wave".
  final List<double> values;
  final Color color;
  final double phase;

  @override
  void paint(Canvas canvas, Size size) {
    final Path path = Path();
    const int steps = 120;
    for (int i = 0; i <= steps; i++) {
      final double t = i / steps;
      final double x = t * size.width;
      double y;
      if (values.isEmpty) {
        // Decorative smooth wave only — clearly not data. Two summed
        // sines with fixed phases, drifting with [phase].
        final double wave = 0.5 +
            0.28 * math.sin(t * math.pi * 4 + phase) +
            0.14 * math.sin(t * math.pi * 9 - phase * 1.7);
        y = size.height * (1.0 - wave.clamp(0.05, 0.95));
      } else {
        // Real values, linearly interpolated between samples.
        final double pos = t * (values.length - 1);
        final int idx = pos.floor().clamp(0, values.length - 1);
        final int next = (idx + 1).clamp(0, values.length - 1);
        final double frac = pos - idx;
        final double v = values[idx] + (values[next] - values[idx]) * frac;
        y = size.height * (1.0 - v.clamp(0.0, 1.0));
      }
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    // Glow pass then crisp line.
    final Paint glow = Paint()
      ..color = color.withValues(alpha: 0.35)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 5
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5);
    canvas.drawPath(path, glow);
    final Paint line = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.8
      ..strokeJoin = StrokeJoin.round;
    canvas.drawPath(path, line);
  }

  @override
  bool shouldRepaint(covariant _WaveformPainter oldDelegate) =>
      oldDelegate.phase != phase || oldDelegate.values != values;
}

/// Live waveform strip.
///
/// * When [values] is supplied (real shop values, e.g. hourly sales
///   normalised 0-1), the strip plots those values.
/// * When [values] is empty, it draws a smooth decorative sine wave
///   (clearly a decorative animation, not fake data).
class HudWaveform extends StatefulWidget {
  const HudWaveform({
    super.key,
    this.values = const <double>[],
    this.color = HudColors.cyan,
    this.height = 48,
    this.isAnimating = true,
  });

  final List<double> values;
  final Color color;
  final double height;
  final bool isAnimating;

  @override
  State<HudWaveform> createState() => _HudWaveformState();
}

class _HudWaveformState extends State<HudWaveform>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    );
    if (widget.isAnimating) _controller.repeat();
  }

  @override
  void didUpdateWidget(covariant HudWaveform oldWidget) {
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
    // Normalise real values to 0-1 against their own max.
    final List<double> normalised;
    if (widget.values.isEmpty) {
      normalised = const <double>[];
    } else {
      final double max =
          widget.values.reduce(math.max) <= 0 ? 1 : widget.values.reduce(math.max);
      normalised =
          widget.values.map((double v) => (v / max).clamp(0.0, 1.0)).toList();
    }
    return RepaintBoundary(
      child: AnimatedBuilder(
        animation: _controller,
        builder: (BuildContext context, Widget? child) {
          return SizedBox(
            height: widget.height,
            width: double.infinity,
            child: CustomPaint(
              painter: _WaveformPainter(
                values: normalised,
                color: widget.color,
                phase: _controller.value * math.pi * 2,
              ),
            ),
          );
        },
      ),
    );
  }
}

/// Convenience bundle: gauge + percent bars + mini bar graph +
/// waveform, all from real values passed in. Used by the demo gallery
/// and the dashboard hero side panels.
class HudGauges extends StatelessWidget {
  const HudGauges({
    super.key,
    required this.gaugeValue,
    required this.gaugeLabel,
    required this.percentBars,
    required this.barValues,
    this.barLabels,
    this.waveformValues = const <double>[],
    this.isAnimating = true,
  });

  final double gaugeValue;
  final String gaugeLabel;
  final List<({String label, double percent, Color color})> percentBars;
  final List<double> barValues;
  final List<String>? barLabels;
  final List<double> waveformValues;
  final bool isAnimating;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Center(
          child: HudCircularGauge(
            value: gaugeValue,
            label: gaugeLabel,
            isAnimating: isAnimating,
          ),
        ),
        const SizedBox(height: 14),
        HudPercentBars(bars: percentBars, isAnimating: isAnimating),
        const SizedBox(height: 14),
        HudMiniBarGraph(
          values: barValues,
          labels: barLabels,
          isAnimating: isAnimating,
        ),
        const SizedBox(height: 10),
        HudWaveform(
          values: waveformValues,
          isAnimating: isAnimating,
        ),
      ],
    );
  }
}
