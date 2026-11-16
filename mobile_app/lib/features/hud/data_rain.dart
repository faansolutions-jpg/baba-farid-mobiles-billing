import 'package:flutter/material.dart';

import 'hud_theme.dart';

/// One scrolling column of real data values.
///
/// The column's items are the caller's strings (IMEI fragments, bill
/// numbers, amounts). The list is duplicated so the scroll loops
/// seamlessly. Each column gets its own duration, so columns move at
/// different speeds.
class _RainColumn extends StatefulWidget {
  const _RainColumn({
    required this.values,
    required this.duration,
    required this.isAnimating,
    this.color = HudColors.cyan,
    this.fontSize = 11,
  });

  final List<String> values;
  final Duration duration;
  final bool isAnimating;
  final Color color;
  final double fontSize;

  @override
  State<_RainColumn> createState() => _RainColumnState();
}

class _RainColumnState extends State<_RainColumn>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: widget.duration);
    if (widget.isAnimating) _controller.repeat();
  }

  @override
  void didUpdateWidget(covariant _RainColumn oldWidget) {
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
    // Item height is fixed so the loop offset is exact.
    final double itemHeight = widget.fontSize + 10;
    final double totalHeight = itemHeight * widget.values.length;
    final TextStyle style = HudTextStyles.data.copyWith(
      color: widget.color,
      fontSize: widget.fontSize,
    );
    Widget columnContent() {
      return Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          for (final String value in widget.values)
            SizedBox(
              height: itemHeight,
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  value,
                  style: style,
                  maxLines: 1,
                  overflow: TextOverflow.clip,
                  softWrap: false,
                ),
              ),
            ),
        ],
      );
    }

    return RepaintBoundary(
      child: ClipRect(
        child: AnimatedBuilder(
          animation: _controller,
          builder: (BuildContext context, Widget? child) {
            final double offset =
                (_controller.value * totalHeight) % totalHeight;
            return Transform.translate(
              offset: Offset(0, -offset),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                // Four copies: enough to fill tall areas (e.g. the lock
                // screen) while the translate loops seamlessly.
                children: <Widget>[
                  columnContent(),
                  columnContent(),
                  columnContent(),
                  columnContent(),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

/// Scrolling columns of small numbers/hex built ONLY from the real
/// values passed in ([values]: IMEI fragments, bill numbers, amounts).
/// Never generates random text — every visible string came from the
/// caller (DECISIONS.md #40).
///
/// Columns scroll at different speeds. Pauses when [isAnimating] is
/// false. Values are dealt round-robin across columns; when there are
/// fewer values than columns, values cycle so no column is empty.
class DataRain extends StatelessWidget {
  const DataRain({
    super.key,
    required this.values,
    this.columns = 4,
    this.isAnimating = true,
    this.color = HudColors.cyan,
    this.fontSize = 11,
    this.height = 220,
  }) : assert(values.length > 0, 'DataRain needs at least one value');

  /// Real values to scroll (IMEI fragments, bill numbers, amounts).
  final List<String> values;
  final int columns;
  final bool isAnimating;
  final Color color;
  final double fontSize;
  final double height;

  /// Splits [values] round-robin across [columns] columns, cycling
  /// values when there are fewer values than columns. Pure helper,
  /// unit-tested.
  static List<List<String>> splitIntoColumns(
      List<String> values, int columns) {
    final int cols = columns.clamp(1, 12);
    final List<List<String>> out =
        List<List<String>>.generate(cols, (_) => <String>[]);
    for (int i = 0; i < cols; i++) {
      // Each column gets at least one value; cycle the source list.
      final int perColumn =
          (values.length / cols).ceil().clamp(1, values.length);
      for (int k = 0; k < perColumn; k++) {
        out[i].add(values[(i * perColumn + k) % values.length]);
      }
    }
    return out;
  }

  @override
  Widget build(BuildContext context) {
    final List<List<String>> columnValues =
        splitIntoColumns(values, columns);
    return SizedBox(
      height: height,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          for (int i = 0; i < columnValues.length; i++)
            Expanded(
              child: Opacity(
                opacity: 0.85 - (i % 3) * 0.15,
                child: _RainColumn(
                  values: columnValues[i],
                  // Different speed per column: 9 s + 3 s per index.
                  duration: Duration(seconds: 9 + i * 3),
                  isAnimating: isAnimating,
                  color: color,
                  fontSize: fontSize,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
