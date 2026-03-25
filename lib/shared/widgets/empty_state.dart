import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_typography.dart';

// Single pattern for “no data yet” so every screen has one CTA and consistent copy,
// not ad-hoc “No data” text (see docs/UI_SYSTEM.md §4.5).
class EmptyState extends StatelessWidget {
  const EmptyState({
    super.key,
    required this.headline,
    required this.body,
    required this.actionLabel,
    required this.onAction,
    this.icon,
    this.iconColor,
  });

  final String headline;
  final String body;
  final String actionLabel;
  final VoidCallback onAction;
  final IconData? icon;
  final Color? iconColor;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final color = iconColor ?? AppColors.primary;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.l, vertical: AppSpacing.xxl),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (icon != null) ...[
            Container(
              padding: const EdgeInsets.all(AppSpacing.l),
              decoration: BoxDecoration(color: color.withOpacity(0.1), shape: BoxShape.circle),
              child: Icon(icon, size: 40, color: color),
            ),
            const SizedBox(height: AppSpacing.l),
          ],
          Text(headline, style: AppTypography.h1(context, isDark: isDark), textAlign: TextAlign.center),
          const SizedBox(height: AppSpacing.s),
          Text(body, style: AppTypography.bodySecondary(context, isDark: isDark), textAlign: TextAlign.center),
          const SizedBox(height: AppSpacing.xl),
          FilledButton(onPressed: onAction, child: Text(actionLabel)),
        ],
      ),
    );
  }
}
