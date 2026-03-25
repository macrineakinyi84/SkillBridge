import 'package:flutter/material.dart';
import '../../../../shared/theme/app_colors.dart';
import '../../../../shared/theme/app_radius.dart';
import '../../../../shared/theme/app_spacing.dart';

/// 7-day row of squares (GitHub-style). Active = primary, inactive = gray, today = accent border.
class WeeklyHeatmap extends StatelessWidget {
  const WeeklyHeatmap({
    super.key,
    required this.activityByDay,
    this.labels = const ['M', 'T', 'W', 'T', 'F', 'S', 'S'],
  });

  /// [oldest, ..., today] — 7 booleans.
  final List<bool> activityByDay;
  final List<String> labels;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final now = DateTime.now();
    final todayIndex = now.weekday - 1;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: List.generate(7, (i) {
            final active = i < activityByDay.length && activityByDay[i];
            final isToday = i == todayIndex;
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 32,
                  height: 32,
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  decoration: BoxDecoration(
                    color: active
                        ? AppColors.primary.withOpacity(0.8)
                        : (isDark
                            ? AppColors.textSecondaryDark.withOpacity(0.2)
                            : AppColors.textSecondary.withOpacity(0.15)),
                    borderRadius: AppRadius.radiusS,
                    border: isToday
                        ? Border.all(color: AppColors.primary, width: 2)
                        : null,
                  ),
                ),
                if (i < labels.length) ...[
                  const SizedBox(height: 4),
                  Text(
                    labels[i],
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ],
            );
          }),
        ),
      ],
    );
  }
}
