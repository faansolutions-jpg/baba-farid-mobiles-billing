import 'package:flutter/material.dart';

import '../catalog_models.dart';

/// Local cyberpunk theme for the catalog screens.
///
/// The shared [CyberTheme] (lib/core/theme) is being written by another
/// agent in parallel, so these screens stay self-contained: every colour,
/// text style and shared widget below lives here and uses the exact
/// palette from the brief. Round 2 swaps these tokens for the shared
/// CyberTheme — call sites only use [CatalogTheme], so the swap is a
/// one-file change.
class CatalogTheme {
  const CatalogTheme._();

  // --- Colours (exact values from the brief) ------------------------------
  static const Color background = Color(0xFF0A0E14);
  static const Color surface = Color(0xFF111827);
  static const Color card = Color(0xFF151C28);
  static const Color primary = Color(0xFF00FF9C); // neon green
  static const Color cyan = Color(0xFF00E5FF);
  static const Color magenta = Color(0xFFFF2E88);
  static const Color amber = Color(0xFFFFB020);
  static const Color red = Color(0xFFFF3B30);
  static const Color text = Color(0xFFE6EDF3);
  static const Color muted = Color(0xFF8B9BB4);
  static const Color border = Color(0xFF2A3644);
  static const Color onPrimary = Color(0xFF04120A);

  // --- Fonts ---------------------------------------------------------------
  // JetBrains Mono for numbers / SKU / amounts, a clean sans for body,
  // Noto Nastaliq Urdu for Urdu. All fall back to the system fonts when
  // the named font is not bundled on the device (DECISIONS.md #27).
  static const String monoFont = 'JetBrains Mono';
  static const String bodyFont = 'Inter';
  static const String urduFont = 'Noto Nastaliq Urdu';

  // --- Text styles -----------------------------------------------------------
  static const TextStyle title = TextStyle(
    fontFamily: bodyFont,
    fontSize: 20,
    fontWeight: FontWeight.w700,
    color: text,
  );

  static const TextStyle heading = TextStyle(
    fontFamily: bodyFont,
    fontSize: 16,
    fontWeight: FontWeight.w700,
    color: text,
  );

  static const TextStyle body = TextStyle(
    fontFamily: bodyFont,
    fontSize: 15,
    fontWeight: FontWeight.w400,
    color: text,
  );

  static const TextStyle bodySmall = TextStyle(
    fontFamily: bodyFont,
    fontSize: 13,
    fontWeight: FontWeight.w400,
    color: muted,
  );

  static const TextStyle mono = TextStyle(
    fontFamily: monoFont,
    fontSize: 15,
    fontWeight: FontWeight.w600,
    color: text,
  );

  static const TextStyle monoSmall = TextStyle(
    fontFamily: monoFont,
    fontSize: 12,
    fontWeight: FontWeight.w500,
    color: muted,
  );

  static const TextStyle monoLarge = TextStyle(
    fontFamily: monoFont,
    fontSize: 20,
    fontWeight: FontWeight.w700,
    color: primary,
  );

  static const TextStyle price = TextStyle(
    fontFamily: monoFont,
    fontSize: 15,
    fontWeight: FontWeight.w700,
    color: primary,
  );

  static const TextStyle urdu = TextStyle(
    fontFamily: urduFont,
    fontSize: 15,
    fontWeight: FontWeight.w400,
    color: muted,
  );

  static const TextStyle urduLarge = TextStyle(
    fontFamily: urduFont,
    fontSize: 17,
    fontWeight: FontWeight.w400,
    color: text,
  );

  static const TextStyle buttonLabel = TextStyle(
    fontFamily: bodyFont,
    fontSize: 16,
    fontWeight: FontWeight.w700,
    color: onPrimary,
  );

  // --- Money -----------------------------------------------------------------
  /// Formats a whole-PKR amount as e.g. `Rs 12,500`. No decimals, ever.
  static String formatPkr(int amount) {
    final negative = amount < 0;
    final digits = amount.abs().toString();
    final buf = StringBuffer();
    for (var i = 0; i < digits.length; i++) {
      if (i > 0 && (digits.length - i) % 3 == 0) buf.write(',');
      buf.write(digits[i]);
    }
    return 'Rs ${negative ? '-' : ''}$buf';
  }

  /// Short date: 16 Nov 2026.
  static String formatDate(DateTime date) {
    const months = <String>[
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }

  // --- Decorations -----------------------------------------------------------
  static BoxDecoration cardDecoration({
    Color? borderColor,
    bool glow = false,
    Color? fill,
  }) {
    final edge = borderColor ?? border;
    return BoxDecoration(
      color: fill ?? card,
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: edge, width: 1),
      boxShadow: glow
          ? <BoxShadow>[
              BoxShadow(
                color: edge.withValues(alpha: 0.35),
                blurRadius: 12,
                spreadRadius: 1,
              ),
            ]
          : null,
    );
  }

  static InputDecoration inputDecoration({
    required String hint,
    Widget? prefixIcon,
    Widget? suffixIcon,
  }) {
    return InputDecoration(
      hintText: hint,
      hintStyle: bodySmall,
      prefixIcon: prefixIcon,
      suffixIcon: suffixIcon,
      filled: true,
      fillColor: surface,
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: border),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: border),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: primary, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: red, width: 2),
      ),
    );
  }

  static ButtonStyle primaryButtonStyle = ElevatedButton.styleFrom(
    backgroundColor: primary,
    foregroundColor: onPrimary,
    minimumSize: const Size(double.infinity, 52),
    textStyle: buttonLabel,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    elevation: 0,
  );

  static ButtonStyle ghostButtonStyle = OutlinedButton.styleFrom(
    foregroundColor: primary,
    minimumSize: const Size(double.infinity, 52),
    side: const BorderSide(color: primary, width: 1.5),
    textStyle: buttonLabel.copyWith(color: primary),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
  );

  static ButtonStyle dangerButtonStyle = ElevatedButton.styleFrom(
    backgroundColor: red,
    foregroundColor: Colors.white,
    minimumSize: const Size(double.infinity, 52),
    textStyle: buttonLabel.copyWith(color: Colors.white),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    elevation: 0,
  );

  /// AppBar shared by every catalog screen.
  static AppBar appBar(String title, {List<Widget>? actions}) {
    return AppBar(
      title: Text(title, style: heading),
      backgroundColor: surface,
      foregroundColor: text,
      elevation: 0,
      actions: actions,
    );
  }

  /// Stock badge: green when healthy, amber at/below threshold, red at 0.
  static Widget stockChip(CatalogItem item) {
    final qty = item.stockQty;
    final Color color;
    final String label;
    if (qty <= 0) {
      color = red;
      label = '0';
    } else if (qty <= item.lowStockThreshold) {
      color = amber;
      label = '$qty';
    } else {
      color = primary;
      label = '$qty';
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color),
      ),
      child: Text(
        label,
        style: mono.copyWith(fontSize: 13, color: color),
      ),
    );
  }

  /// One catalog item row: EN + UR name, brand, SKU, sale price, stock.
  /// Tapping calls [onTap]. Used by the browser and the search pickers.
  static Widget itemTile(
    CatalogItem item, {
    required VoidCallback onTap,
    Widget? trailing,
    bool highlightZeroStock = true,
  }) {
    final isZero = item.stockQty <= 0;
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
      decoration: cardDecoration(
        borderColor: isZero && highlightZeroStock ? red.withValues(alpha: 0.6) : null,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(item.nameEn, style: body.copyWith(fontWeight: FontWeight.w600)),
                      if (item.nameUr.isNotEmpty) ...<Widget>[
                        const SizedBox(height: 2),
                        Text(item.nameUr, style: urdu, textDirection: TextDirection.rtl),
                      ],
                      const SizedBox(height: 6),
                      Text(
                        '${item.brand}  •  ${item.sku}',
                        style: monoSmall,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (item.modelCompatibility != null &&
                          item.modelCompatibility!.isNotEmpty) ...<Widget>[
                        const SizedBox(height: 2),
                        Text(
                          item.modelCompatibility!,
                          style: bodySmall,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(width: 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: <Widget>[
                    Text(formatPkr(item.salePriceEst), style: price),
                    const SizedBox(height: 6),
                    trailing ?? stockChip(item),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Full-screen loading state (dark background, neon spinner).
  static Widget loadingView([String? message]) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          const CircularProgressIndicator(color: primary),
          if (message != null) ...<Widget>[
            const SizedBox(height: 16),
            Text(message, style: bodySmall),
          ],
        ],
      ),
    );
  }

  /// Full-screen error state with a retry button.
  static Widget errorView(String message, VoidCallback onRetry) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            const Icon(Icons.error_outline, color: red, size: 48),
            const SizedBox(height: 12),
            Text(message, style: body, textAlign: TextAlign.center),
            const SizedBox(height: 20),
            SizedBox(
              width: 200,
              child: ElevatedButton(
                onPressed: onRetry,
                style: primaryButtonStyle.copyWith(
                  minimumSize: WidgetStateProperty.all(const Size(200, 48)),
                ),
                child: const Text('Try Again'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Full-screen empty state.
  static Widget emptyView(String title, [String? subtitle]) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            const Icon(Icons.inventory_2_outlined, color: muted, size: 48),
            const SizedBox(height: 12),
            Text(title, style: heading, textAlign: TextAlign.center),
            if (subtitle != null) ...<Widget>[
              const SizedBox(height: 6),
              Text(subtitle, style: bodySmall, textAlign: TextAlign.center),
            ],
          ],
        ),
      ),
    );
  }

  /// Section header with a neon left edge.
  static Widget sectionHeader(String title, {String? subtitle}) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Row(
        children: <Widget>[
          Container(width: 4, height: 22, color: primary),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(title, style: heading),
                if (subtitle != null) Text(subtitle, style: bodySmall),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Thin neon progress bar with a "x of y" label.
  static Widget progressBar(int done, int total, {String? label}) {
    final ratio = total <= 0 ? 0.0 : (done / total).clamp(0.0, 1.0);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Text(label ?? '', style: bodySmall),
            Text(
              '$done of $total',
              style: mono.copyWith(color: primary, fontSize: 13),
            ),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(6),
          child: LinearProgressIndicator(
            value: ratio,
            minHeight: 8,
            backgroundColor: border,
            valueColor: const AlwaysStoppedAnimation<Color>(primary),
          ),
        ),
      ],
    );
  }
}
