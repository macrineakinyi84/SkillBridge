import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

/// Design system typography using Inter. Use these for consistent hierarchy.
class AppTypography {
  AppTypography._();

  static Color _color(bool isDark, bool primary) {
    if (primary) return isDark ? AppColors.textPrimaryDark : AppColors.textPrimary;
    return isDark ? AppColors.textSecondaryDark : AppColors.textSecondary;
  }

  // ─── Display (hero / screen titles) ──────────────────────────────────────
  /// 32sp bold — hero headings.
  static TextStyle displayLarge(BuildContext context, {bool isDark = false}) =>
      GoogleFonts.inter(
        fontSize: 32,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.5,
        color: _color(isDark, true),
      );

  /// 28sp bold — screen titles.
  static TextStyle displayMedium(BuildContext context, {bool isDark = false}) =>
      GoogleFonts.inter(
        fontSize: 28,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.5,
        color: _color(isDark, true),
      );

  // ─── Headlines ────────────────────────────────────────────────────────────
  /// 24sp bold.
  static TextStyle headlineLarge(BuildContext context, {bool isDark = false}) =>
      GoogleFonts.inter(
        fontSize: 24,
        fontWeight: FontWeight.w700,
        color: _color(isDark, true),
      );

  /// 20sp semibold.
  static TextStyle headlineMedium(BuildContext context, {bool isDark = false}) =>
      GoogleFonts.inter(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: _color(isDark, true),
      );

  // ─── Titles ────────────────────────────────────────────────────────────────
  /// 18sp semibold — card titles, section headers.
  static TextStyle titleLarge(BuildContext context, {bool isDark = false}) =>
      GoogleFonts.inter(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: _color(isDark, true),
      );

  /// 16sp medium.
  static TextStyle titleMedium(BuildContext context, {bool isDark = false}) =>
      GoogleFonts.inter(
        fontSize: 16,
        fontWeight: FontWeight.w500,
        color: _color(isDark, true),
      );

  // ─── Body ─────────────────────────────────────────────────────────────────
  /// 16sp regular.
  static TextStyle bodyLarge(BuildContext context, {bool isDark = false}) =>
      GoogleFonts.inter(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        height: 1.4,
        color: _color(isDark, true),
      );

  /// 14sp regular.
  static TextStyle bodyMedium(BuildContext context, {bool isDark = false}) =>
      GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        height: 1.4,
        color: _color(isDark, true),
      );

  /// 12sp regular — captions, hints.
  static TextStyle bodySmall(BuildContext context, {bool isDark = false}) =>
      GoogleFonts.inter(
        fontSize: 12,
        fontWeight: FontWeight.w400,
        height: 1.35,
        color: _color(isDark, false),
      );

  // ─── Labels ──────────────────────────────────────────────────────────────
  /// 14sp semibold — button text, labels.
  static TextStyle labelLarge(BuildContext context, {bool isDark = false}) =>
      GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: _color(isDark, true),
      );

  // ─── Legacy aliases (for gradual migration from shared/theme) ─────────────
  static const double displaySize = 28;
  static const double h1Size = 22;
  static const double h2Size = 17;
  static const double bodySize = 15;
  static const double captionSize = 13;

  static TextStyle display(BuildContext context, {bool isDark = false}) =>
      displayMedium(context, isDark: isDark);
  static TextStyle h1(BuildContext context, {bool isDark = false}) =>
      headlineLarge(context, isDark: isDark);
  static TextStyle h2(BuildContext context, {bool isDark = false}) =>
      titleLarge(context, isDark: isDark);
  static TextStyle body(BuildContext context, {bool isDark = false}) =>
      bodyLarge(context, isDark: isDark);
  static TextStyle bodySecondary(BuildContext context, {bool isDark = false}) =>
      GoogleFonts.inter(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        height: 1.4,
        color: _color(isDark, false),
      );
  static TextStyle caption(BuildContext context, {bool isDark = false}) =>
      bodySmall(context, isDark: isDark);
}
