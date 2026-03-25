import 'package:flutter/material.dart';

import '../../../../shared/theme/app_colors.dart';
import '../../../../shared/theme/app_radius.dart';
import '../../../../shared/theme/app_spacing.dart';
import '../../../../shared/theme/app_typography.dart';

/// Grid of skill categories vs score ranges. Color intensity = number of matching candidates.
/// Used in Post Job Step 2 and employer analytics. Tap a cell to see candidate count.
class SkillHeatmapWidget extends StatelessWidget {
  const SkillHeatmapWidget({
    super.key,
    required this.categoryLabels,
    required this.scoreRanges,
    required this.countGrid,
    this.onCellTap,
  });

  /// e.g. ['Digital Literacy', 'Communication', ...]
  final List<String> categoryLabels;
  /// e.g. ['0-20', '21-40', '41-60', '61-80', '81-100']
  final List<String> scoreRanges;
  /// countGrid[categoryIndex][rangeIndex] = candidate count
  final List<List<int>> countGrid;
  final void Function(int categoryIndex, int rangeIndex, int count)? onCellTap;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final maxCount = _maxCount();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Skill heatmap', style: AppTypography.h2(context, isDark: isDark)),
        const SizedBox(height: AppSpacing.s),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  const SizedBox(width: 80),
                  ...scoreRanges.asMap().entries.map((e) => SizedBox(
                        width: 44,
                        child: Padding(
                          padding: const EdgeInsets.only(left: 4),
                          child: Text(
                            e.value,
                            style: AppTypography.caption(context, isDark: isDark),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      )),
                ],
              ),
              const SizedBox(height: 4),
              ...categoryLabels.asMap().entries.map((catEntry) {
                final catIndex = catEntry.key;
                final label = catEntry.value;
                return Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      SizedBox(
                        width: 80,
                        child: Text(
                          label,
                          style: AppTypography.caption(context, isDark: isDark),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: List.generate(scoreRanges.length, (rangeIndex) {
                          final count = catIndex < countGrid.length && rangeIndex < countGrid[catIndex].length
                              ? countGrid[catIndex][rangeIndex]
                              : 0;
                          final intensity = maxCount > 0 ? (count / maxCount).clamp(0.0, 1.0) : 0.0;
                          return Padding(
                            padding: const EdgeInsets.only(left: 4),
                            child: _HeatmapCell(
                              count: count,
                              intensity: intensity,
                              isDark: isDark,
                              onTap: () => onCellTap?.call(catIndex, rangeIndex, count),
                            ),
                          );
                        }),
                      ),
                    ],
                  ),
                );
              }),
            ],
          ),
        ),
      ],
    );
  }

  int _maxCount() {
    int m = 0;
    for (final row in countGrid) {
      for (final c in row) {
        if (c > m) m = c;
      }
    }
    return m == 0 ? 1 : m;
  }
}

class _HeatmapCell extends StatelessWidget {
  const _HeatmapCell({
    required this.count,
    required this.intensity,
    required this.isDark,
    required this.onTap,
  });

  final int count;
  final double intensity;
  final bool isDark;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = Color.lerp(
      isDark ? AppColors.surfaceDark : AppColors.surface,
      AppColors.primary,
      intensity,
    )!;
    return Material(
      color: color,
      borderRadius: AppRadius.radiusM,
      child: InkWell(
        borderRadius: AppRadius.radiusM,
        onTap: onTap,
        child: SizedBox(
          width: 40,
          height: 36,
          child: Center(
            child: Text(
              '$count',
              style: AppTypography.caption(context, isDark: isDark).copyWith(
                fontWeight: FontWeight.w600,
                color: intensity > 0.5 ? Colors.white : (isDark ? AppColors.textPrimaryDark : AppColors.textPrimary),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
