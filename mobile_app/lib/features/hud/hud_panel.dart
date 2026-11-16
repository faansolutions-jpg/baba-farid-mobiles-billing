import 'package:flutter/material.dart';

import 'hud_theme.dart';

/// Clips a rectangle with two opposite corners cut at 45 degrees
/// (top-right and bottom-left), the classic angled HUD panel shape.
class _CutCornerClipper extends CustomClipper<Path> {
  const _CutCornerClipper();

  // See the note on the twin clipper in core/theme/cyber_widgets.dart:
  // the cut size used to be a (never-passed) constructor parameter that
  // `dart fix` removed; 12 restores the previous look.
  final double cut = 12;

  @override
  Path getClip(Size size) {
    final Path path = Path()
      ..moveTo(0, 0)
      ..lineTo(size.width - cut, 0)
      ..lineTo(size.width, cut)
      ..lineTo(size.width, size.height)
      ..lineTo(cut, size.height)
      ..lineTo(0, size.height - cut)
      ..close();
    return path;
  }

  @override
  bool shouldReclip(covariant _CutCornerClipper oldClipper) =>
      oldClipper.cut != cut;
}

/// A HUD panel with angled (cut-corner) edges, a thin glowing border
/// and a monospace title bar.
///
/// Takes a [title] (e.g. "ANALYSING DATA"), an [accent] colour for
/// the border/title, and any [child] content.
class HudPanel extends StatelessWidget {
  const HudPanel({
    super.key,
    required this.title,
    required this.child,
    this.accent = HudColors.cyan,
    this.padding = const EdgeInsets.fromLTRB(14, 10, 14, 14),
    this.showCornerTicks = true,
  });

  final String title;
  final Widget child;
  final Color accent;
  final EdgeInsetsGeometry padding;
  final bool showCornerTicks;

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: ClipPath(
        clipper: const _CutCornerClipper(),
        child: Container(
          decoration: BoxDecoration(
            color: HudColors.surface.withValues(alpha: 0.92),
            border: Border.all(color: accent.withValues(alpha: 0.55), width: 1),
            boxShadow: <BoxShadow>[
              BoxShadow(
                color: accent.withValues(alpha: 0.18),
                blurRadius: 14,
                spreadRadius: 0,
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                decoration: BoxDecoration(
                  color: accent.withValues(alpha: 0.12),
                  border: Border(
                    bottom: BorderSide(
                      color: accent.withValues(alpha: 0.35),
                      width: 1,
                    ),
                  ),
                ),
                child: Row(
                  children: <Widget>[
                    Container(
                      width: 7,
                      height: 7,
                      decoration: BoxDecoration(
                        color: accent,
                        shape: BoxShape.circle,
                        boxShadow: <BoxShadow>[
                          BoxShadow(
                            color: accent.withValues(alpha: 0.7),
                            blurRadius: 6,
                            spreadRadius: 1,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        title.toUpperCase(),
                        style: HudTextStyles.title.copyWith(
                          color: accent,
                          fontSize: 12,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (showCornerTicks)
                      Text(
                        '//',
                        style: HudTextStyles.label
                            .copyWith(color: accent.withValues(alpha: 0.6)),
                      ),
                  ],
                ),
              ),
              Padding(padding: padding, child: child),
            ],
          ),
        ),
      ),
    );
  }
}
