import 'package:flutter/material.dart';

// Palette and semantic roles so we don’t scatter hex codes; one place to change
// for theming and accessibility (see docs/BRANDING.md).
class AppColors {
  AppColors._();

  // Gun Powder palette (primary)
  // 50  F5F6F9  | 100 E8EAF1 | 200 D7DBE6 | 300 BBC1D5
  // 400 9AA3C0 | 500 81839B | 600 6F74A1 | 700 636592
  // 800 555678 | 900 3A3B50 | 950 2E2E3D
  static const Color paletteDark = Color(0xFF2E2E3D); // 950
  static const Color palettePrimary = Color(0xFF636592); // 700
  static const Color paletteSecondary = Color(0xFF9AA3C0); // 400
  static const Color paletteLight = Color(0xFFF5F6F9); // 50

  static const Color primary = palettePrimary;
  static const Color primaryLight = Color(0xFF9AA3C0); // 400
  static const Color primaryDark = Color(0xFF3A3B50); // 900

  static const Color secondary = paletteSecondary;
  static const Color secondaryLight = Color(0xFFD7DBE6); // 200

  static const Color background = paletteLight;
  static const Color surface = Color(0xFFFFFFFF);
  static const Color textPrimary = paletteDark;
  static const Color textSecondary = Color(0xFF555678); // 800

  static const Color gradientWarmStart = Color(0xFFE8EAF1); // 100
  static const Color gradientWarmEnd = Color(0xFFD7DBE6); // 200
  static const Color accentWarm = primary;

  static const Color backgroundDark = paletteDark;
  static const Color surfaceDark = Color(0xFF3A3B50); // 900
  static const Color textPrimaryDark = Color(0xFFF5F6F9); // 50
  static const Color textSecondaryDark = Color(0xFFBBC1D5); // 300

  static const Color error = Color(0xFFDC2626);
  static const Color success = Color(0xFF10B981);
  static const Color warning = Color(0xFFF59E0B);
  static const Color medium = Color(0xFFFBBF24);

  static const Color streakFlame = Color(0xFFF97316);
  static const Color xpGold = Color(0xFFEAB308);
  static const Color levelBadge = Color(0xFF8B5CF6);
  static const Color borderLight = Color(0xFFE5E7EB);

  static Color matchScoreColor(int percent) {
    if (percent >= 70) return success;
    if (percent >= 40) return warning;
    return textSecondary;
  }
}
