import 'package:flutter/material.dart';

import 'cyber_colors.dart';

/// Typography for the cyberpunk theme (DECISIONS.md #27).
///
/// * Numbers, IMEI, amounts, codes — **JetBrains Mono** (falls back to the
///   system monospace font when the font is not bundled on the device).
/// * Body / UI text — **Inter**, falling back to Roboto / system sans.
/// * Urdu — **Noto Nastaliq Urdu**, falling back to the system Urdu font.
///
/// Every style takes the active [CyberColors] so text always has enough
/// contrast against the surface it sits on.
class CyberTextStyles {
  const CyberTextStyles._();

  static const String monoFamily = 'JetBrainsMono';
  static const String bodyFamily = 'Inter';
  static const String urduFamily = 'Noto Nastaliq Urdu';

  // --- Headings -------------------------------------------------------------
  static TextStyle headline(CyberColors c, {double size = 28}) => TextStyle(
        fontFamily: bodyFamily,
        fontSize: size,
        fontWeight: FontWeight.w800,
        color: c.textPrimary,
        letterSpacing: -0.5,
        height: 1.2,
      );

  static TextStyle title(CyberColors c, {double size = 20}) => TextStyle(
        fontFamily: bodyFamily,
        fontSize: size,
        fontWeight: FontWeight.w700,
        color: c.textPrimary,
        height: 1.3,
      );

  static TextStyle subtitle(CyberColors c, {double size = 16}) => TextStyle(
        fontFamily: bodyFamily,
        fontSize: size,
        fontWeight: FontWeight.w600,
        color: c.textPrimary,
        height: 1.35,
      );

  // --- Body -----------------------------------------------------------------
  static TextStyle body(CyberColors c, {double size = 15}) => TextStyle(
        fontFamily: bodyFamily,
        fontSize: size,
        fontWeight: FontWeight.w400,
        color: c.textPrimary,
        height: 1.5,
      );

  static TextStyle bodySecondary(CyberColors c, {double size = 14}) => TextStyle(
        fontFamily: bodyFamily,
        fontSize: size,
        fontWeight: FontWeight.w400,
        color: c.textSecondary,
        height: 1.5,
      );

  static TextStyle caption(CyberColors c, {double size = 12}) => TextStyle(
        fontFamily: bodyFamily,
        fontSize: size,
        fontWeight: FontWeight.w400,
        color: c.textSecondary,
        letterSpacing: 0.3,
        height: 1.4,
      );

  static TextStyle label(CyberColors c, {double size = 12}) => TextStyle(
        fontFamily: bodyFamily,
        fontSize: size,
        fontWeight: FontWeight.w700,
        color: c.textSecondary,
        letterSpacing: 1.2,
      );

  static TextStyle button(CyberColors c, {double size = 16}) => TextStyle(
        fontFamily: bodyFamily,
        fontSize: size,
        fontWeight: FontWeight.w700,
        color: c.onPrimary,
        letterSpacing: 0.5,
      );

  // --- Monospace (numbers, IMEI, amounts, codes) ---------------------------
  static TextStyle mono(CyberColors c, {double size = 14}) => TextStyle(
        fontFamily: monoFamily,
        fontSize: size,
        fontWeight: FontWeight.w500,
        color: c.textPrimary,
        height: 1.4,
      );

  /// Large money amount, e.g. a bill total or a stat-card figure.
  static TextStyle amount(CyberColors c, {double size = 28}) => TextStyle(
        fontFamily: monoFamily,
        fontSize: size,
        fontWeight: FontWeight.w700,
        color: c.primary,
        height: 1.2,
      );

  /// IMEI / barcode / serial, always monospace and letter-spaced.
  static TextStyle imei(CyberColors c, {double size = 14}) => TextStyle(
        fontFamily: monoFamily,
        fontSize: size,
        fontWeight: FontWeight.w500,
        color: c.secondary,
        letterSpacing: 1.0,
        height: 1.4,
      );

  /// Terminal / boot-screen text.
  static TextStyle terminal(CyberColors c, {double size = 15}) => TextStyle(
        fontFamily: monoFamily,
        fontSize: size,
        fontWeight: FontWeight.w500,
        color: c.primary,
        height: 1.6,
      );

  // --- Urdu ------------------------------------------------------------------
  static TextStyle urdu(CyberColors c, {double size = 16}) => TextStyle(
        fontFamily: urduFamily,
        fontSize: size,
        fontWeight: FontWeight.w400,
        color: c.textPrimary,
        height: 1.9,
      );

  static TextStyle urduTitle(CyberColors c, {double size = 20}) => TextStyle(
        fontFamily: urduFamily,
        fontSize: size,
        fontWeight: FontWeight.w700,
        color: c.textPrimary,
        height: 1.9,
      );

  /// Picks the Urdu style when [isUrdu] is true, otherwise the body style.
  static TextStyle bodyForLanguage(CyberColors c, bool isUrdu) =>
      isUrdu ? urdu(c) : body(c);

  // --- Status colours --------------------------------------------------------
  static TextStyle success(CyberColors c, {double size = 15}) => TextStyle(
        fontFamily: monoFamily,
        fontSize: size,
        fontWeight: FontWeight.w700,
        color: c.success,
        letterSpacing: 0.5,
      );

  static TextStyle error(CyberColors c, {double size = 15}) => TextStyle(
        fontFamily: monoFamily,
        fontSize: size,
        fontWeight: FontWeight.w700,
        color: c.error,
        letterSpacing: 0.5,
      );

  static TextStyle warning(CyberColors c, {double size = 14}) => TextStyle(
        fontFamily: bodyFamily,
        fontSize: size,
        fontWeight: FontWeight.w600,
        color: c.warning,
      );
}
