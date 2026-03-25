import 'package:flutter/material.dart';

import '../../../../shared/theme/app_colors.dart';
import '../../../../shared/theme/app_radius.dart';
import '../../../../shared/theme/app_spacing.dart';
import '../../../../shared/theme/app_typography.dart';
import '../screens/public_profile_screen.dart';

class PortfolioThemeSelector extends StatelessWidget {
  const PortfolioThemeSelector({
    super.key,
    required this.current,
    required this.onChanged,
  });

  final PortfolioTheme current;
  final ValueChanged<PortfolioTheme> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.m),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Choose theme', style: AppTypography.h2(context, isDark: false)),
          const SizedBox(height: AppSpacing.m),
          Row(
            children: PortfolioTheme.values.map((theme) {
              return Expanded(
                child: GestureDetector(
                  onTap: () => onChanged(theme),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    padding: const EdgeInsets.all(AppSpacing.s),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: AppRadius.radiusL,
                      border: Border.all(
                        color: theme == current ? AppColors.primary : Colors.grey.shade300,
                        width: theme == current ? 2 : 1,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _ThemeMiniPreview(theme: theme),
                        const SizedBox(height: AppSpacing.s),
                        Text(
                          _labelFor(theme),
                          style: AppTypography.caption(context, isDark: false),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: AppSpacing.m),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Done'),
            ),
          ),
        ],
      ),
    );
  }

  String _labelFor(PortfolioTheme theme) {
    switch (theme) {
      case PortfolioTheme.minimal:
        return 'Minimal';
      case PortfolioTheme.bold:
        return 'Bold';
      case PortfolioTheme.professional:
        return 'Professional';
      case PortfolioTheme.creative:
        return 'Creative';
    }
  }
}

class _ThemeMiniPreview extends StatelessWidget {
  const _ThemeMiniPreview({required this.theme});

  final PortfolioTheme theme;

  @override
  Widget build(BuildContext context) {
    Color background;
    Color accent;
    switch (theme) {
      case PortfolioTheme.minimal:
        background = Colors.white;
        accent = AppColors.textPrimary;
        break;
      case PortfolioTheme.bold:
        background = AppColors.primary;
        accent = Colors.white;
        break;
      case PortfolioTheme.professional:
        background = AppColors.background;
        accent = AppColors.primary;
        break;
      case PortfolioTheme.creative:
        background = AppColors.gradientWarmStart;
        accent = AppColors.secondary;
        break;
    }

    return Container(
      height: 80,
      decoration: BoxDecoration(
        color: background,
        borderRadius: AppRadius.radiusM,
      ),
      child: Stack(
        children: [
          Positioned(
            left: 8,
            top: 8,
            child: Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: accent, width: 2),
              ),
            ),
          ),
          Positioned(
            left: 8,
            bottom: 8,
            right: 8,
            child: Container(
              height: 8,
              decoration: BoxDecoration(
                color: accent,
                borderRadius: AppRadius.radiusFull,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

