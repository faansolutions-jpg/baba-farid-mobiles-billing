import 'package:flutter/material.dart';

import 'hud_background.dart';
import 'hud_core.dart';
import 'hud_panel.dart';
import 'hud_theme.dart';

/// HUD loading overlay shown while reports, sync, backup or Excel
/// import run.
///
/// Shows a [HudPanel] titled [title] (default "ANALYSING DATA"), the
/// real [progress] (0.0-1.0) as a percentage and a progress bar, a
/// [status] label, and a small [HudCore].
///
/// Place it inside a [Stack] over the screen being blocked. With
/// [fullscreen] true it also paints the HUD background behind the
/// panel; otherwise it renders just the panel (inline use).
class HudLoadingOverlay extends StatelessWidget {
  const HudLoadingOverlay({
    super.key,
    required this.progress,
    required this.status,
    this.title = 'ANALYSING DATA',
    this.showCore = true,
    this.fullscreen = true,
    this.isAnimating = true,
    this.particleBudget = 250,
  });

  /// Real progress 0.0-1.0 from the running task.
  final double progress;
  final String status;
  final String title;
  final bool showCore;
  final bool fullscreen;
  final bool isAnimating;
  final int particleBudget;

  @override
  Widget build(BuildContext context) {
    final double clamped = progress.clamp(0.0, 1.0);
    final Widget panel = HudPanel(
      title: title,
      accent: HudColors.cyan,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          if (showCore)
            Center(
              child: HudCore(
                size: 110,
                health: 1.0,
                particleBudget: particleBudget,
                isAnimating: isAnimating,
              ),
            ),
          if (showCore) const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Expanded(
                child: Text(
                  status,
                  style: HudTextStyles.label.copyWith(color: HudColors.text),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '${(clamped * 100).round()}%',
                style: HudTextStyles.valueSmall.copyWith(
                  color: HudColors.cyan,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          RepaintBoundary(
            child: Container(
              height: 8,
              decoration: BoxDecoration(
                color: HudColors.text.withValues(alpha: 0.10),
                borderRadius: BorderRadius.circular(2),
              ),
              child: LayoutBuilder(
                builder: (BuildContext context, BoxConstraints constraints) {
                  return Align(
                    alignment: Alignment.centerLeft,
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 250),
                      width: constraints.maxWidth * clamped,
                      decoration: BoxDecoration(
                        color: HudColors.cyan,
                        borderRadius: BorderRadius.circular(2),
                        boxShadow: <BoxShadow>[
                          BoxShadow(
                            color: HudColors.cyan.withValues(alpha: 0.6),
                            blurRadius: 8,
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'PLEASE WAIT — DO NOT CLOSE THE APP',
            style: HudTextStyles.label.copyWith(fontSize: 10),
          ),
        ],
      ),
    );

    final Widget centered = Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 380),
          child: panel,
        ),
      ),
    );

    if (!fullscreen) return centered;
    return HudBackground(
      opacity: 0.9,
      isAnimating: isAnimating,
      child: centered,
    );
  }
}
