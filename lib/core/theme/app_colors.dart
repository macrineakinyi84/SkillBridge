import 'package:flutter/material.dart';

/// Design system colors: palette + semantic naming.
/// Single source of truth for theming and accessibility (see docs/BRANDING.md).
class AppColors {
  AppColors._();

  // ─── Palette ─────────────────────────────────────────────────────────────
  static const Color paletteDark = Color(0xFF21222D);
  static const Color palettePrimary = Color(0xFF958CE8);
  static const Color paletteSecondary = Color(0xFFACD1FD);
  static const Color paletteLight = Color(0xFFDBDBE5);

  // ─── Primary & secondary ──────────────────────────────────────────────────
  static const Color primary = palettePrimary;
  static const Color primaryLight = Color(0xFFB5AEF2);
  static const Color primaryDark = Color(0xFF7B73D9);

  static const Color secondary = paletteSecondary;
  static const Color secondaryLight = Color(0xFFC5E0FD);

  // ─── Surfaces (light) ─────────────────────────────────────────────────────
  static const Color background = paletteLight;
  static const Color surface = Color(0xFFFFFFFF);
  static const Color textPrimary = paletteDark;
  static const Color textSecondary = Color(0xFF5C5E6B);

  // ─── Gradients & accents ──────────────────────────────────────────────────
  static const Color gradientWarmStart = Color(0xFFE8E5FC);
  static const Color gradientWarmEnd = Color(0xFFE3F2FD);
  static const Color accentWarm = primary;

  // ─── Dark theme ───────────────────────────────────────────────────────────
  static const Color backgroundDark = paletteDark;
  static const Color surfaceDark = Color(0xFF2C2D3A);
  static const Color textPrimaryDark = Color(0xFFDBDBE5);
  static const Color textSecondaryDark = Color(0xFFACD1FD);

  // ─── Semantic: feedback ───────────────────────────────────────────────────
  static const Color error = Color(0xFFDC2626);
  static const Color success = Color(0xFF10B981);
  static const Color warning = Color(0xFFF59E0B);
  static const Color medium = Color(0xFFFBBF24);

  // ─── Semantic: match score (job/skill match %) ───────────────────────────
  /// High match (e.g. ≥70%): use for strong fit.
  static const Color matchScoreHigh = success;
  /// Medium match (e.g. 40–69%): use for partial fit.
  static const Color matchScoreMedium = warning;
  /// Low match (e.g. <40%): use for weak fit or secondary text.
  static const Color matchScoreLow = textSecondary;

  // ─── Semantic: gamification / engagement ──────────────────────────────────
  /// Streak flame / activity streak accent.
  static const Color streakFlame = Color(0xFFF97316);
  /// XP / points / progress gold.
  static const Color xpGold = Color(0xFFEAB308);
  /// Level badge / tier accent.
  static const Color levelBadge = Color(0xFF8B5CF6);

  // ─── Semantic: borders & dividers ─────────────────────────────────────────
  static const Color borderLight = Color(0xFFE5E7EB);
  static const Color borderDark = Color(0xFF374151);

  // ─── Helpers ─────────────────────────────────────────────────────────────
  /// Returns match score color by percent (≥70 high, 40–69 medium, <40 low).
  static Color matchScoreColor(int percent) {
    if (percent >= 70) return matchScoreHigh;
    if (percent >= 40) return matchScoreMedium;
    return matchScoreLow;
  }
}
