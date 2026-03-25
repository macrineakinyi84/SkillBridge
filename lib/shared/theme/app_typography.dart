import 'package:flutter/material.dart';
import 'app_colors.dart';

/// SkillBridge typography scale. See docs/UI_DESIGN.md.
class AppTypography {
  AppTypography._();

  static const double displaySize = 28;
  static const double h1Size = 22;
  static const double h2Size = 17;
  static const double bodySize = 15;
  static const double captionSize = 13;

  static TextStyle display(BuildContext context, {bool isDark = false}) =>
      TextStyle(
        fontSize: displaySize,
        fontWeight: FontWeight.w700,
        color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
        letterSpacing: -0.5,
      );

  static TextStyle h1(BuildContext context, {bool isDark = false}) =>
      TextStyle(
        fontSize: h1Size,
        fontWeight: FontWeight.w600,
        color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
      );

  static TextStyle h2(BuildContext context, {bool isDark = false}) =>
      TextStyle(
        fontSize: h2Size,
        fontWeight: FontWeight.w600,
        color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
      );

  static TextStyle body(BuildContext context, {bool isDark = false}) =>
      TextStyle(
        fontSize: bodySize,
        fontWeight: FontWeight.w400,
        color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
        height: 1.4,
      );

  static TextStyle bodySecondary(BuildContext context, {bool isDark = false}) =>
      TextStyle(
        fontSize: bodySize,
        fontWeight: FontWeight.w400,
        color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary,
        height: 1.4,
      );

  static TextStyle caption(BuildContext context, {bool isDark = false}) =>
      TextStyle(
        fontSize: captionSize,
        fontWeight: FontWeight.w400,
        color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary,
        height: 1.35,
      );
}
