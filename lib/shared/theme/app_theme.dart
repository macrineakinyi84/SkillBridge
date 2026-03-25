import 'package:flutter/material.dart';
import 'app_colors.dart';
import 'app_radius.dart';
import 'app_spacing.dart';
import 'app_typography.dart';

/// SkillBridge theme: brand colors, spacing grid, typography hierarchy.
class AppTheme {
  AppTheme._();

  static ThemeData get light => ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.primary,
          primary: AppColors.primary,
          secondary: AppColors.secondary,
          surface: AppColors.surface,
          error: AppColors.error,
          brightness: Brightness.light,
        ),
        scaffoldBackgroundColor: AppColors.background,
        appBarTheme: const AppBarTheme(
          centerTitle: true,
          elevation: 0,
          backgroundColor: AppColors.background,
          foregroundColor: AppColors.textPrimary,
        ),
        cardTheme: CardThemeData(
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: AppRadius.radiusL),
          color: AppColors.surface,
          shadowColor: Colors.black.withOpacity(0.06),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.l, vertical: 14),
            shape: RoundedRectangleBorder(borderRadius: AppRadius.radiusM),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: AppColors.surface,
          border: OutlineInputBorder(borderRadius: AppRadius.radiusM),
          contentPadding: const EdgeInsets.symmetric(horizontal: AppSpacing.m, vertical: 14),
        ),
        textTheme: _buildTextTheme(Brightness.light),
      );

  static ThemeData get dark => ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.primary,
          primary: AppColors.primary,
          secondary: AppColors.secondary,
          surface: AppColors.surfaceDark,
          error: AppColors.error,
          brightness: Brightness.dark,
        ),
        scaffoldBackgroundColor: AppColors.backgroundDark,
        appBarTheme: const AppBarTheme(
          centerTitle: true,
          elevation: 0,
          backgroundColor: AppColors.surfaceDark,
          foregroundColor: Colors.white,
        ),
        cardTheme: CardThemeData(
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: AppRadius.radiusL),
          color: AppColors.surfaceDark,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.l, vertical: 14),
            shape: RoundedRectangleBorder(borderRadius: AppRadius.radiusM),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: AppColors.surfaceDark,
          border: OutlineInputBorder(borderRadius: AppRadius.radiusM),
          contentPadding: const EdgeInsets.symmetric(horizontal: AppSpacing.m, vertical: 14),
        ),
        textTheme: _buildTextTheme(Brightness.dark),
      );

  static TextTheme _buildTextTheme(Brightness brightness) {
    final isDark = brightness == Brightness.dark;
    final primary = isDark ? AppColors.textPrimaryDark : AppColors.textPrimary;
    final secondary = isDark ? AppColors.textSecondaryDark : AppColors.textSecondary;
    return TextTheme(
      headlineMedium: TextStyle(fontSize: AppTypography.displaySize, fontWeight: FontWeight.w700, color: primary),
      titleLarge: TextStyle(fontSize: AppTypography.h1Size, fontWeight: FontWeight.w600, color: primary),
      titleMedium: TextStyle(fontSize: AppTypography.h2Size, fontWeight: FontWeight.w600, color: primary),
      bodyLarge: TextStyle(fontSize: AppTypography.bodySize, fontWeight: FontWeight.w400, color: primary),
      bodyMedium: TextStyle(fontSize: AppTypography.bodySize, fontWeight: FontWeight.w400, color: primary),
      bodySmall: TextStyle(fontSize: AppTypography.captionSize, fontWeight: FontWeight.w400, color: secondary),
    );
  }
}
