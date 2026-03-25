import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import '../../../../shared/theme/app_colors.dart';
import '../../../../shared/theme/app_spacing.dart';

/// Streak display: Lottie flame + count. Intensity by streak (1–6 small, 7+ large).
enum StreakType { job, learn }

class StreakFlame extends StatelessWidget {
  const StreakFlame({
    super.key,
    required this.count,
    required this.type,
    this.lottiePathSmall,
    this.lottiePathLarge,
  });

  final int count;
  final StreakType type;
  final String? lottiePathSmall;
  final String? lottiePathLarge;

  @override
  Widget build(BuildContext context) {
    final isLarge = count >= 7;
    final label = type == StreakType.job ? 'Job Streak' : 'Learn Streak';
    final sublabel = type == StreakType.job ? 'Keep applying!' : 'Keep learning!';
    final icon = type == StreakType.job ? Icons.work_rounded : Icons.menu_book_rounded;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (lottiePathSmall != null || lottiePathLarge != null)
          SizedBox(
            height: isLarge ? 56 : 40,
            child: Lottie.asset(
              (isLarge ? lottiePathLarge : lottiePathSmall) ?? lottiePathSmall!,
              fit: BoxFit.contain,
            ),
          )
        else
          Container(
            padding: const EdgeInsets.all(AppSpacing.m),
            decoration: BoxDecoration(
              color: AppColors.streakFlame.withOpacity(0.15),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              size: isLarge ? 32 : 24,
              color: AppColors.streakFlame,
            ),
          ),
        const SizedBox(height: 4),
        Text(
          '$count',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w800,
                color: AppColors.streakFlame,
              ),
        ),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall,
        ),
        Text(
          sublabel,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                fontStyle: FontStyle.italic,
              ),
        ),
      ],
    );
  }
}
