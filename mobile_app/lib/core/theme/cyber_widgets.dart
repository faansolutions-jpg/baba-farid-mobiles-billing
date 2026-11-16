library;

/// Reusable cyberpunk widgets. Every feature screen builds with these —
/// no screen invents its own buttons, cards or fields.
///
/// Rules baked in here: minimum 48dp touch targets, WCAG-AA-friendly
/// contrast (colours come from [CyberColors]), bilingual-ready (all labels
/// are plain strings so they can come from `AppStrings.tr`).
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../config/constants.dart';
import 'app_theme.dart';
import 'cyber_colors.dart';
import 'cyber_text_styles.dart';

// ---------------------------------------------------------------------------
// Buttons
// ---------------------------------------------------------------------------

enum CyberButtonVariant { primary, ghost, danger }

/// Primary / ghost / danger button. Always at least 48dp tall.
class CyberButton extends StatelessWidget {
  const CyberButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.variant = CyberButtonVariant.primary,
    this.icon,
    this.isLoading = false,
    this.fullWidth = true,
  });

  final String label;
  final VoidCallback? onPressed;
  final CyberButtonVariant variant;
  final IconData? icon;
  final bool isLoading;
  final bool fullWidth;

  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (context, ref, _) {
        final c = ref.watch(themeNotifierProvider).colors;
        final enabled = onPressed != null && !isLoading;
        final Widget child = isLoading
            ? SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  color: variant == CyberButtonVariant.primary
                      ? c.onPrimary
                      : c.primary,
                ),
              )
            : Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (icon != null) ...[
                    Icon(icon, size: 20),
                    const SizedBox(width: 8),
                  ],
                  Flexible(
                    child: Text(
                      label,
                      style: CyberTextStyles.button(
                        c,
                        size: 16,
                      ).copyWith(
                        color: variant == CyberButtonVariant.primary
                            ? c.onPrimary
                            : variant == CyberButtonVariant.danger
                                ? c.error
                                : c.primary,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              );

        final ButtonStyle style;
        switch (variant) {
          case CyberButtonVariant.primary:
            style = ElevatedButton.styleFrom(
              backgroundColor: c.primary,
              foregroundColor: c.onPrimary,
              minimumSize: const Size(0, AppConstants.minTouchTarget),
              disabledBackgroundColor: c.border,
            );
            return SizedBox(
              width: fullWidth ? double.infinity : null,
              child: ElevatedButton(
                onPressed: enabled ? onPressed : null,
                style: style,
                child: child,
              ),
            );
          case CyberButtonVariant.ghost:
            return SizedBox(
              width: fullWidth ? double.infinity : null,
              child: OutlinedButton(
                onPressed: enabled ? onPressed : null,
                style: OutlinedButton.styleFrom(
                  foregroundColor: c.primary,
                  side: BorderSide(color: c.primary, width: 1.5),
                  minimumSize:
                      const Size(0, AppConstants.minTouchTarget),
                ),
                child: child,
              ),
            );
          case CyberButtonVariant.danger:
            return SizedBox(
              width: fullWidth ? double.infinity : null,
              child: OutlinedButton(
                onPressed: enabled ? onPressed : null,
                style: OutlinedButton.styleFrom(
                  foregroundColor: c.error,
                  side: BorderSide(color: c.error, width: 1.5),
                  minimumSize:
                      const Size(0, AppConstants.minTouchTarget),
                ),
                child: child,
              ),
            );
        }
      },
    );
  }
}

// ---------------------------------------------------------------------------
// Card with angled cut corners + glowing border
// ---------------------------------------------------------------------------

class _CutCornerClipper extends CustomClipper<Path> {
  const _CutCornerClipper();

  // Corner cut in logical pixels. The constructor used to take this as
  // an optional parameter, but no caller ever passed one, so `dart fix`
  // removed the parameter — and left the field uninitialised. The
  // default is restored here (12 matches the card's corner radius
  // language); the clipper is const-constructed everywhere.
  final double cut = 12;

  @override
  Path getClip(Size size) {
    final p = Path()
      ..moveTo(0, cut)
      ..lineTo(cut, 0)
      ..lineTo(size.width, 0)
      ..lineTo(size.width, size.height - cut)
      ..lineTo(size.width - cut, size.height)
      ..lineTo(0, size.height)
      ..close();
    return p;
  }

  @override
  bool shouldReclip(_CutCornerClipper old) => old.cut != cut;
}

/// Card with angled cut corners and a subtle neon glow border.
class CyberCard extends StatelessWidget {
  const CyberCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(AppConstants.paddingMedium),
    this.margin = const EdgeInsets.symmetric(vertical: 6),
    this.onTap,
    this.glow = true,
    this.borderColor,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry margin;
  final VoidCallback? onTap;
  final bool glow;
  final Color? borderColor;

  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (context, ref, _) {
        final c = ref.watch(themeNotifierProvider).colors;
        final border = borderColor ?? c.border;
        final card = ClipPath(
          clipper: const _CutCornerClipper(),
          child: Container(
            padding: padding,
            decoration: BoxDecoration(
              color: c.card,
              border: Border.all(color: border),
              boxShadow: glow
                  ? [
                      BoxShadow(
                        color: c.glow,
                        blurRadius: 12,
                        spreadRadius: 0,
                        offset: const Offset(0, 0),
                      ),
                    ]
                  : null,
            ),
            child: child,
          ),
        );
        return Padding(
          padding: margin,
          child: onTap == null
              ? card
              : InkWell(
                  onTap: onTap,
                  borderRadius: BorderRadius.circular(8),
                  child: card,
                ),
        );
      },
    );
  }
}

// ---------------------------------------------------------------------------
// Text field
// ---------------------------------------------------------------------------

/// Text field with optional monospace input (IMEI / amounts / codes),
/// neon focus border from the theme, and a blinking block cursor.
class CyberTextField extends StatelessWidget {
  const CyberTextField({
    super.key,
    this.controller,
    this.label,
    this.hint,
    this.monospace = false,
    this.obscureText = false,
    this.keyboardType,
    this.prefixIcon,
    this.suffixIcon,
    this.onChanged,
    this.onSubmitted,
    this.validator,
    this.maxLength,
    this.readOnly = false,
    this.enabled = true,
    this.autofocus = false,
    this.textInputAction,
  });

  final TextEditingController? controller;
  final String? label;
  final String? hint;
  final bool monospace;
  final bool obscureText;
  final TextInputType? keyboardType;
  final IconData? prefixIcon;
  final Widget? suffixIcon;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final FormFieldValidator<String>? validator;
  final int? maxLength;
  final bool readOnly;
  final bool enabled;
  final bool autofocus;
  final TextInputAction? textInputAction;

  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (context, ref, _) {
        final c = ref.watch(themeNotifierProvider).colors;
        return TextFormField(
          controller: controller,
          obscureText: obscureText,
          keyboardType: keyboardType,
          onChanged: onChanged,
          onFieldSubmitted: onSubmitted,
          validator: validator,
          maxLength: maxLength,
          readOnly: readOnly,
          enabled: enabled,
          autofocus: autofocus,
          textInputAction: textInputAction,
          cursorColor: c.primary,
          cursorWidth: 2,
          style: monospace
              ? CyberTextStyles.mono(c, size: 15)
              : CyberTextStyles.body(c, size: 15),
          decoration: InputDecoration(
            labelText: label,
            hintText: hint,
            prefixIcon:
                prefixIcon == null ? null : Icon(prefixIcon, color: c.primary),
            suffixIcon: suffixIcon,
            counterText: '',
          ),
        );
      },
    );
  }
}

// ---------------------------------------------------------------------------
// Table
// ---------------------------------------------------------------------------

/// Simple styled table: neon header row, zebra rows, monospace numbers.
class CyberTable extends StatelessWidget {
  const CyberTable({
    super.key,
    required this.headers,
    required this.rows,
    this.monospaceColumns = const <int>{},
  });

  final List<String> headers;
  final List<List<String>> rows;

  /// Column indexes rendered in monospace (amounts, IMEI, quantities).
  final Set<int> monospaceColumns;

  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (context, ref, _) {
        final c = ref.watch(themeNotifierProvider).colors;
        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Table(
            border: TableBorder.all(color: c.border),
            columnWidths: {
              for (var i = 0; i < headers.length; i++)
                i: const IntrinsicColumnWidth(),
            },
            children: [
              TableRow(
                decoration: BoxDecoration(color: c.surface),
                children: headers
                    .map(
                      (h) => Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 10,
                        ),
                        child: Text(h, style: CyberTextStyles.label(c)),
                      ),
                    )
                    .toList(),
              ),
              for (var r = 0; r < rows.length; r++)
                TableRow(
                  decoration: BoxDecoration(
                    color: r.isEven ? c.card : c.surface,
                  ),
                  children: [
                    for (var col = 0; col < rows[r].length; col++)
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 10,
                        ),
                        child: Text(
                          rows[r][col],
                          style: monospaceColumns.contains(col)
                              ? CyberTextStyles.mono(c, size: 14)
                              : CyberTextStyles.body(c, size: 14),
                        ),
                      ),
                  ],
                ),
            ],
          ),
        );
      },
    );
  }
}

// ---------------------------------------------------------------------------
// Dialog
// ---------------------------------------------------------------------------

/// Shows a themed confirmation dialog. Returns true when confirmed.
Future<bool> showCyberDialog(
  BuildContext context, {
  required String title,
  required String message,
  String confirmLabel = 'Confirm',
  String cancelLabel = 'Cancel',
  bool danger = false,
}) async {
  final result = await showDialog<bool>(
    context: context,
    builder: (context) => Consumer(
      builder: (context, ref, _) {
        final c = ref.watch(themeNotifierProvider).colors;
        return AlertDialog(
          title: Text(title, style: CyberTextStyles.title(c, size: 18)),
          content: Text(message, style: CyberTextStyles.body(c)),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text(cancelLabel),
            ),
            CyberButton(
              label: confirmLabel,
              fullWidth: false,
              variant: danger
                  ? CyberButtonVariant.danger
                  : CyberButtonVariant.primary,
              onPressed: () => Navigator.of(context).pop(true),
            ),
          ],
        );
      },
    ),
  );
  return result ?? false;
}

/// Plain themed dialog shell for custom content (forms, QR codes, etc.).
class CyberDialog extends StatelessWidget {
  const CyberDialog({
    super.key,
    required this.title,
    required this.child,
    this.actions = const <Widget>[],
  });

  final String title;
  final Widget child;
  final List<Widget> actions;

  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (context, ref, _) {
        final c = ref.watch(themeNotifierProvider).colors;
        return AlertDialog(
          title: Text(title, style: CyberTextStyles.title(c, size: 18)),
          content: SingleChildScrollView(child: child),
          actions: actions,
        );
      },
    );
  }
}

// ---------------------------------------------------------------------------
// Badge / chip
// ---------------------------------------------------------------------------

/// Small status badge (e.g. PAID, OVERDUE, SOLD, AVAILABLE).
class CyberBadge extends StatelessWidget {
  const CyberBadge({
    super.key,
    required this.label,
    this.color,
    this.background,
  });

  final String label;
  final Color? color;
  final Color? background;

  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (context, ref, _) {
        final c = ref.watch(themeNotifierProvider).colors;
        final fg = color ?? c.primary;
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: background ?? fg.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: fg),
          ),
          child: Text(
            label,
            style: CyberTextStyles.label(c, size: 11).copyWith(color: fg),
          ),
        );
      },
    );
  }
}

/// Selectable chip (filters, payment methods, categories).
class CyberChip extends StatelessWidget {
  const CyberChip({
    super.key,
    required this.label,
    required this.selected,
    required this.onSelected,
  });

  final String label;
  final bool selected;
  final ValueChanged<bool> onSelected;

  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (context, ref, _) {
        final c = ref.watch(themeNotifierProvider).colors;
        return FilterChip(
          label: Text(label),
          selected: selected,
          onSelected: onSelected,
          selectedColor: c.primary,
          checkmarkColor: c.onPrimary,
          labelStyle: CyberTextStyles.body(c, size: 13).copyWith(
            color: selected ? c.onPrimary : c.textPrimary,
          ),
          side: BorderSide(color: selected ? c.primary : c.border),
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        );
      },
    );
  }
}

// ---------------------------------------------------------------------------
// Stat card (count-up animation, disabled when animations are off)
// ---------------------------------------------------------------------------

/// Dashboard stat card: label + animated count-up number.
/// When animations are off in Settings, the final value shows instantly.
class CyberStatCard extends ConsumerWidget {
  const CyberStatCard({
    super.key,
    required this.label,
    required this.value,
    this.prefix = '',
    this.suffix = '',
    this.icon,
    this.valueColor,
    this.onTap,
  });

  final String label;
  final int value;
  final String prefix;
  final String suffix;
  final IconData? icon;
  final Color? valueColor;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = ref.watch(themeNotifierProvider);
    final c = theme.colors;
    final animated = theme.animationsEnabled;
    return CyberCard(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              if (icon != null) ...[
                Icon(icon, color: c.primary, size: 20),
                const SizedBox(width: 8),
              ],
              Expanded(
                child: Text(
                  label,
                  style: CyberTextStyles.label(c),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          TweenAnimationBuilder<double>(
            tween: Tween<double>(begin: 0, end: value.toDouble()),
            duration:
                animated ? const Duration(milliseconds: 900) : Duration.zero,
            builder: (context, animatedValue, _) {
              final shown = animated
                  ? animatedValue.round()
                  : value;
              return Text(
                '$prefix$shown$suffix',
                style: CyberTextStyles.amount(c, size: 26)
                    .copyWith(color: valueColor ?? c.primary),
              );
            },
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Chart (fl_chart)
// ---------------------------------------------------------------------------

enum CyberChartType { line, bar }

/// Line / bar chart over the theme colours. Values are raw doubles;
/// callers pass already-rounded PKR amounts or counts.
class CyberChart extends ConsumerWidget {
  const CyberChart({
    super.key,
    required this.values,
    this.labels = const <String>[],
    this.type = CyberChartType.line,
    this.height = 200,
    this.showGrid = true,
  });

  final List<double> values;
  final List<String> labels;
  final CyberChartType type;
  final double height;
  final bool showGrid;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c = ref.watch(themeNotifierProvider).colors;
    if (values.isEmpty) {
      return SizedBox(
        height: height,
        child: Center(
          child: Text('No data', style: CyberTextStyles.bodySecondary(c)),
        ),
      );
    }
    final spots = <FlSpot>[
      for (var i = 0; i < values.length; i++) FlSpot(i.toDouble(), values[i]),
    ];
    final Widget chart;
    if (type == CyberChartType.line) {
      chart = LineChart(
        LineChartData(
          gridData: FlGridData(show: showGrid),
          borderData: FlBorderData(
            show: true,
            border: Border.all(color: c.border),
          ),
          titlesData: FlTitlesData(
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: labels.isNotEmpty,
                getTitlesWidget: (v, meta) {
                  final i = v.toInt();
                  if (i < 0 || i >= labels.length) {
                    return const SizedBox.shrink();
                  }
                  return Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(
                      labels[i],
                      style: CyberTextStyles.caption(c, size: 10),
                    ),
                  );
                },
              ),
            ),
            leftTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            topTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            rightTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
          ),
          lineBarsData: [
            LineChartBarData(
              spots: spots,
              isCurved: true,
              color: c.primary,
              barWidth: 2.5,
              dotData: const FlDotData(show: false),
              belowBarData: BarAreaData(
                show: true,
                color: c.primary.withValues(alpha: 0.15),
              ),
            ),
          ],
        ),
      );
    } else {
      chart = BarChart(
        BarChartData(
          gridData: FlGridData(show: showGrid),
          borderData: FlBorderData(
            show: true,
            border: Border.all(color: c.border),
          ),
          titlesData: FlTitlesData(
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: labels.isNotEmpty,
                getTitlesWidget: (v, meta) {
                  final i = v.toInt();
                  if (i < 0 || i >= labels.length) {
                    return const SizedBox.shrink();
                  }
                  return Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(
                      labels[i],
                      style: CyberTextStyles.caption(c, size: 10),
                    ),
                  );
                },
              ),
            ),
            leftTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            topTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            rightTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
          ),
          barGroups: [
            for (var i = 0; i < values.length; i++)
              BarChartGroupData(
                x: i,
                barRods: [
                  BarChartRodData(
                    toY: values[i],
                    color: c.primary,
                    width: 16,
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(4),
                    ),
                  ),
                ],
              ),
          ],
        ),
      );
    }
    return SizedBox(height: height, child: chart);
  }
}

// ---------------------------------------------------------------------------
// Toggle, app bar, search bar
// ---------------------------------------------------------------------------

/// Labelled on/off switch with a 48dp-tall row.
class CyberToggle extends StatelessWidget {
  const CyberToggle({
    super.key,
    required this.label,
    required this.value,
    required this.onChanged,
    this.subtitle,
  });

  final String label;
  final bool value;
  final ValueChanged<bool> onChanged;
  final String? subtitle;

  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (context, ref, _) {
        final c = ref.watch(themeNotifierProvider).colors;
        return SwitchListTile(
          title: Text(label, style: CyberTextStyles.body(c, size: 15)),
          subtitle: subtitle == null
              ? null
              : Text(subtitle!, style: CyberTextStyles.bodySecondary(c)),
          value: value,
          onChanged: onChanged,
          contentPadding: const EdgeInsets.symmetric(horizontal: 4),
        );
      },
    );
  }
}

/// App bar with a monospace title and the theme's neon accent.
class CyberAppBar extends StatelessWidget implements PreferredSizeWidget {
  const CyberAppBar({
    super.key,
    required this.title,
    this.actions = const <Widget>[],
    this.showBack = true,
  });

  final String title;
  final List<Widget> actions;
  final bool showBack;

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (context, ref, _) {
        final c = ref.watch(themeNotifierProvider).colors;
        return AppBar(
          title: Text(title, style: CyberTextStyles.mono(c, size: 17)),
          actions: actions,
          automaticallyImplyLeading: showBack,
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(1),
            child: Container(height: 1, color: c.primary.withValues(alpha: 0.4)),
          ),
        );
      },
    );
  }
}

/// Search field with a scan action slot (barcode / IMEI camera scan).
class CyberSearchBar extends StatelessWidget {
  const CyberSearchBar({
    super.key,
    required this.hint,
    this.controller,
    this.onChanged,
    this.onSubmitted,
    this.onScanPressed,
    this.autofocus = false,
  });

  final String hint;
  final TextEditingController? controller;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final VoidCallback? onScanPressed;
  final bool autofocus;

  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (context, ref, _) {
        final c = ref.watch(themeNotifierProvider).colors;
        return TextField(
          controller: controller,
          onChanged: onChanged,
          onSubmitted: onSubmitted,
          autofocus: autofocus,
          cursorColor: c.primary,
          style: CyberTextStyles.body(c, size: 15),
          decoration: InputDecoration(
            hintText: hint,
            prefixIcon: Icon(Icons.search, color: c.primary),
            suffixIcon: onScanPressed == null
                ? null
                : IconButton(
                    icon: Icon(Icons.qr_code_scanner, color: c.primary),
                    tooltip: 'Scan barcode / IMEI',
                    onPressed: onScanPressed,
                  ),
          ),
        );
      },
    );
  }
}
