import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'hud_theme.dart';
import 'hud_typing.dart';

/// Expanding pulse rings painter for the success animation.
class _PulsePainter extends CustomPainter {
  _PulsePainter({required this.progress, required this.color});

  /// 0.0-1.0 animation progress.
  final double progress;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final Offset center = Offset(size.width / 2, size.height / 2);
    final double maxRadius = size.width / 2;
    // Three rings, staggered.
    for (int i = 0; i < 3; i++) {
      final double p = ((progress * 1.6) - i * 0.28).clamp(0.0, 1.0);
      if (p <= 0) continue;
      final double radius = 12 + p * (maxRadius - 12);
      canvas.drawCircle(
        center,
        radius,
        Paint()
          ..color = color.withValues(alpha: (1 - p) * 0.7)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _PulsePainter oldDelegate) =>
      oldDelegate.progress != progress || oldDelegate.color != color;
}

/// Success pulse shown after a transaction completes.
///
/// Expanding neon-green rings + a check mark + [message] (default
/// "TRANSACTION COMPLETE"). Calls [onDone] after [duration] so the
/// caller can dismiss it / move on.
class HudSuccessPulse extends StatefulWidget {
  const HudSuccessPulse({
    super.key,
    this.message = 'TRANSACTION COMPLETE',
    this.detail,
    this.duration = const Duration(milliseconds: 1800),
    this.onDone,
  });

  final String message;

  /// Optional second line, e.g. the bill number ("BILL #1042").
  final String? detail;
  final Duration duration;
  final VoidCallback? onDone;

  @override
  State<HudSuccessPulse> createState() => _HudSuccessPulseState();
}

class _HudSuccessPulseState extends State<HudSuccessPulse>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: widget.duration)
      ..forward();
    Future<void>.delayed(widget.duration, () {
      if (mounted) widget.onDone?.call();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: AnimatedBuilder(
        animation: _controller,
        builder: (BuildContext context, Widget? child) {
          final double t = _controller.value;
          // Check mark scales in quickly, then the rings expand.
          final double checkScale = (t * 3).clamp(0.0, 1.0);
          final double checkEase =
              1 - math.pow(1 - checkScale, 3).toDouble();
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              SizedBox(
                width: 140,
                height: 140,
                child: Stack(
                  alignment: Alignment.center,
                  children: <Widget>[
                    CustomPaint(
                      size: const Size(140, 140),
                      painter: _PulsePainter(
                        progress: t,
                        color: HudColors.neonGreen,
                      ),
                    ),
                    Transform.scale(
                      scale: checkEase,
                      child: Container(
                        width: 64,
                        height: 64,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: HudColors.neonGreen.withValues(alpha: 0.15),
                          border: Border.all(
                            color: HudColors.neonGreen,
                            width: 2,
                          ),
                          boxShadow: <BoxShadow>[
                            BoxShadow(
                              color: HudColors.neonGreen.withValues(alpha: 0.5),
                              blurRadius: 18,
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.check,
                          color: HudColors.neonGreen,
                          size: 36,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              Text(
                widget.message,
                style: HudTextStyles.title.copyWith(
                  color: HudColors.neonGreen,
                  fontSize: 15,
                ),
                textAlign: TextAlign.center,
              ),
              if (widget.detail != null) ...<Widget>[
                const SizedBox(height: 6),
                Text(
                  widget.detail!,
                  style: HudTextStyles.label
                      .copyWith(color: HudColors.text),
                  textAlign: TextAlign.center,
                ),
              ],
            ],
          );
        },
      ),
    );
  }
}

/// Red glitch wrapper for failures: the [message] (and optional
/// [detail]) is shown inside a red HUD panel wrapped in [HudGlitch],
/// which only glitches because this is an error.
class HudErrorGlitch extends StatelessWidget {
  const HudErrorGlitch({
    super.key,
    required this.message,
    this.detail,
    this.onDismiss,
  });

  final String message;
  final String? detail;
  final VoidCallback? onDismiss;

  @override
  Widget build(BuildContext context) {
    final Widget content = Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
      decoration: BoxDecoration(
        color: HudColors.surface,
        border: Border.all(color: HudColors.red.withValues(alpha: 0.7), width: 1),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: HudColors.red.withValues(alpha: 0.25),
            blurRadius: 16,
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          const Icon(
            Icons.error_outline,
            color: HudColors.red,
            size: 32,
          ),
          const SizedBox(height: 8),
          Text(
            message,
            style: HudTextStyles.title.copyWith(
              color: HudColors.red,
              fontSize: 14,
            ),
            textAlign: TextAlign.center,
          ),
          if (detail != null) ...<Widget>[
            const SizedBox(height: 6),
            Text(
              detail!,
              style: HudTextStyles.label.copyWith(color: HudColors.text),
              textAlign: TextAlign.center,
            ),
          ],
          if (onDismiss != null) ...<Widget>[
            const SizedBox(height: 12),
            TextButton(
              onPressed: onDismiss,
              child: Text(
                'DISMISS',
                style: HudTextStyles.label.copyWith(color: HudColors.red),
              ),
            ),
          ],
        ],
      ),
    );
    return HudGlitch(isError: true, child: content);
  }
}
