import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_typography.dart';

/// One row: label, optional badge, and a horizontal progress bar (0–100).
/// Use for skill progress lists. See docs/UI_DESIGN.md.
class ProgressBarRow extends StatelessWidget {
  const ProgressBarRow({
    super.key,
    required this.label,
    required this.progressPercent,
    this.badgeLabel,
    this.badgeColor,
  });

  final String label;
  final int progressPercent;
  final String? badgeLabel;
  final Color? badgeColor;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final progress = (progressPercent.clamp(0, 100) / 100).toDouble();
    final badge = badgeColor ?? AppColors.primary;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: AppTypography.body(context, isDark: isDark).copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            if (badgeLabel != null)
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.s,
                  vertical: 2,
                ),
                decoration: BoxDecoration(
                  color: badge.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(AppSpacing.s),
                ),
                child: Text(
                  badgeLabel!,
                  style: AppTypography.caption(context, isDark: isDark).copyWith(
                    color: badge,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: AppSpacing.s),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: progress,
            minHeight: 6,
            backgroundColor: AppColors.primary.withOpacity(0.15),
            valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
          ),
        ),
      ],
    );
  }
}
