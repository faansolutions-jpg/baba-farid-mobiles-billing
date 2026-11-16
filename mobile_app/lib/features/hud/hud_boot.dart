import 'package:flutter/material.dart';

import 'hud_background.dart';
import 'hud_core.dart';
import 'hud_theme.dart';
import 'hud_typing.dart';

/// One step of the boot sequence: a [label] typed on screen, then a
/// [waitAfter] pause before the next step starts.
class BootStep {
  const BootStep({required this.label, this.waitAfter = const Duration(milliseconds: 350)});

  final String label;
  final Duration waitAfter;
}

/// Default boot steps for Baba Farid Mobiles.
const List<BootStep> kDefaultBootSteps = <BootStep>[
  BootStep(label: 'SYSTEM BOOT'),
  BootStep(label: 'Loading database...'),
  BootStep(label: 'Syncing...'),
  BootStep(label: 'ACCESS GRANTED', waitAfter: Duration(milliseconds: 700)),
];

/// Boot sequence widget (standalone — Round 2 wires it into the
/// splash screen owned by the foundation agent).
///
/// Phase 1: the [HudCore] assembles from scattered particles
/// ([assembleDuration]). Phase 2: each [steps] line is typed in turn
/// via [HudTyping] (the final line is styled green). Then [onComplete]
/// is called once. A SKIP button calls [onComplete] immediately.
class HudBootSplash extends StatefulWidget {
  const HudBootSplash({
    super.key,
    required this.onComplete,
    this.steps = kDefaultBootSteps,
    this.assembleDuration = const Duration(milliseconds: 1400),
    this.isAnimating = true,
    this.particleBudget = 600,
  });

  final VoidCallback onComplete;
  final List<BootStep> steps;
  final Duration assembleDuration;
  final bool isAnimating;
  final int particleBudget;

  @override
  State<HudBootSplash> createState() => _HudBootSplashState();
}

class _HudBootSplashState extends State<HudBootSplash>
    with SingleTickerProviderStateMixin {
  late final AnimationController _assembleController;
  int _currentStep = -1; // -1 = still assembling
  bool _done = false;

  @override
  void initState() {
    super.initState();
    _assembleController = AnimationController(
      vsync: this,
      duration: widget.assembleDuration,
    );
    if (!widget.isAnimating) {
      _assembleController.value = 1.0;
      _currentStep = 0;
    } else {
      _assembleController.forward().then((_) {
        if (mounted) setState(() => _currentStep = 0);
      });
    }
  }

  void _onStepTyped() {
    if (_done || !mounted) return;
    final BootStep step = widget.steps[_currentStep];
    Future<void>.delayed(step.waitAfter, () {
      if (!mounted || _done) return;
      if (_currentStep >= widget.steps.length - 1) {
        _finish();
      } else {
        setState(() => _currentStep++);
      }
    });
  }

  void _finish() {
    if (_done) return;
    _done = true;
    widget.onComplete();
  }

  @override
  void dispose() {
    _assembleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool assembling = _currentStep < 0;
    return HudBackground(
      isAnimating: widget.isAnimating,
      child: SafeArea(
        child: Stack(
          children: <Widget>[
            Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  AnimatedBuilder(
                    animation: _assembleController,
                    builder: (BuildContext context, Widget? child) {
                      return HudCore(
                        size: 200,
                        health: 1.0,
                        particleBudget: widget.particleBudget,
                        isAnimating: widget.isAnimating,
                        assembleProgress: _assembleController.value,
                      );
                    },
                  ),
                  const SizedBox(height: 18),
                  Text(
                    'BABA FARID MOBILES',
                    style: HudTextStyles.title.copyWith(
                      fontSize: 16,
                      letterSpacing: 4,
                      color: HudColors.cyan,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'BILLING // INVENTORY SYSTEM',
                    style: HudTextStyles.label,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 28),
                  SizedBox(
                    width: 280,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        for (int i = 0; i < widget.steps.length; i++)
                          if (i < _currentStep)
                            Padding(
                              padding: const EdgeInsets.only(bottom: 6),
                              child: Text(
                                widget.steps[i].label,
                                style: HudTextStyles.status.copyWith(
                                  color: i == widget.steps.length - 1
                                      ? HudColors.neonGreen
                                      : HudColors.muted,
                                ),
                              ),
                            )
                          else if (i == _currentStep && !assembling)
                            Padding(
                              padding: const EdgeInsets.only(bottom: 6),
                              child: HudTyping(
                                key: ValueKey<int>(i),
                                text: widget.steps[i].label,
                                speed: widget.isAnimating
                                    ? const Duration(milliseconds: 40)
                                    : Duration.zero,
                                style: HudTextStyles.status.copyWith(
                                  color: i == widget.steps.length - 1
                                      ? HudColors.neonGreen
                                      : HudColors.text,
                                ),
                                onComplete: _onStepTyped,
                              ),
                            ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Positioned(
              right: 16,
              bottom: 16,
              child: TextButton(
                onPressed: _finish,
                child: Text(
                  'SKIP >>',
                  style: HudTextStyles.label
                      .copyWith(color: HudColors.cyan),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
