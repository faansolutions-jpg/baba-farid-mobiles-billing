import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'hud_theme.dart';

/// Typing text effect with a blinking cursor.
///
/// Takes the full [text] and reveals it one character at a time at
/// [speed] (per character). Calls [onComplete] once the full text is
/// shown. The cursor is a separate widget so the text itself is
/// exactly [text] when complete (widget tests can find it verbatim).
class HudTyping extends StatefulWidget {
  const HudTyping({
    super.key,
    required this.text,
    this.speed = const Duration(milliseconds: 45),
    this.style,
    this.showCursor = true,
    this.cursorColor = HudColors.neonGreen,
    this.onComplete,
  });

  final String text;
  final Duration speed;
  final TextStyle? style;
  final bool showCursor;
  final Color cursorColor;
  final VoidCallback? onComplete;

  @override
  State<HudTyping> createState() => _HudTypingState();
}

class _HudTypingState extends State<HudTyping> {
  Timer? _typeTimer;
  Timer? _blinkTimer;
  int _shown = 0;
  bool _cursorOn = true;
  bool _completed = false;

  @override
  void initState() {
    super.initState();
    _blinkTimer = Timer.periodic(
      const Duration(milliseconds: 530),
      (_) {
        if (mounted) setState(() => _cursorOn = !_cursorOn);
      },
    );
    _startTyping();
  }

  @override
  void didUpdateWidget(covariant HudTyping oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.text != widget.text || oldWidget.speed != widget.speed) {
      _typeTimer?.cancel();
      _shown = 0;
      _completed = false;
      _startTyping();
    }
  }

  void _startTyping() {
    if (widget.text.isEmpty) {
      _finish();
      return;
    }
    // Zero (or negative) speed = show the full text immediately
    // (animations-off mode).
    if (widget.speed.inMicroseconds <= 0) {
      setState(() => _shown = widget.text.length);
      _finish();
      return;
    }
    _typeTimer = Timer.periodic(widget.speed, (Timer timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      setState(() => _shown++);
      if (_shown >= widget.text.length) {
        timer.cancel();
        _finish();
      }
    });
  }

  void _finish() {
    if (_completed) return;
    _completed = true;
    widget.onComplete?.call();
  }

  @override
  void dispose() {
    _typeTimer?.cancel();
    _blinkTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final String shown = widget.text.substring(0, _shown.clamp(0, widget.text.length));
    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.baseline,
      textBaseline: TextBaseline.alphabetic,
      children: <Widget>[
        Flexible(
          child: Text(
            shown,
            style: widget.style ?? HudTextStyles.status,
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        if (widget.showCursor)
          AnimatedOpacity(
            opacity: _cursorOn ? 1.0 : 0.0,
            duration: const Duration(milliseconds: 120),
            child: Container(
              width: 8,
              height: 15,
              margin: const EdgeInsets.only(left: 2),
              color: widget.cursorColor,
            ),
          ),
      ],
    );
  }
}

/// Glitch wrapper that applies a glitch effect ONLY on errors.
///
/// When [isError] is false, [child] is returned untouched. When true,
/// the child is shown with two offset red/cyan ghost copies and a
/// small periodic horizontal jitter, driven by a short repeating
/// controller that runs only while the error is shown.
class HudGlitch extends StatefulWidget {
  const HudGlitch({
    super.key,
    required this.isError,
    required this.child,
    this.intensity = 3.0,
  });

  final bool isError;
  final Widget child;
  final double intensity;

  @override
  State<HudGlitch> createState() => _HudGlitchState();
}

class _HudGlitchState extends State<HudGlitch>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    if (widget.isError) _controller.repeat();
  }

  @override
  void didUpdateWidget(covariant HudGlitch oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isError && !_controller.isAnimating) {
      _controller.repeat();
    } else if (!widget.isError && _controller.isAnimating) {
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
    if (!widget.isError) return widget.child;
    return AnimatedBuilder(
      animation: _controller,
      builder: (BuildContext context, Widget? child) {
        final double t = _controller.value * math.pi * 2;
        // Jitter is bursty: mostly still, with sharp jumps.
        final double jump = math.sin(t * 7).abs() > 0.86
            ? math.sin(t * 13) * widget.intensity
            : 0.0;
        return Stack(
          children: <Widget>[
            Transform.translate(
              offset: const Offset(-2.5, 0),
              child: ColorFiltered(
                colorFilter: const ColorFilter.mode(
                  HudColors.red,
                  BlendMode.srcATop,
                ),
                child: Opacity(opacity: 0.45, child: widget.child),
              ),
            ),
            Transform.translate(
              offset: const Offset(2.5, 0),
              child: ColorFiltered(
                colorFilter: const ColorFilter.mode(
                  HudColors.cyan,
                  BlendMode.srcATop,
                ),
                child: Opacity(opacity: 0.45, child: widget.child),
              ),
            ),
            Transform.translate(offset: Offset(jump, 0), child: widget.child),
          ],
        );
      },
    );
  }
}
