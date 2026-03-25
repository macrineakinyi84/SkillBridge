import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../shared/theme/app_colors.dart';
import '../../../../shared/theme/app_radius.dart';
import '../../../../shared/theme/app_spacing.dart';
import '../../../../shared/theme/app_typography.dart';
import '../../../../core/router/app_router.dart' as router;
import '../../../../shared/widgets/progress_ring.dart';

class ReadinessPage extends StatelessWidget {
  const ReadinessPage({super.key});

  @override
  Widget build(BuildContext context) {
    const score = 65; // Hardcoded so readiness UI is testable before ReadinessScoreRepository is wired (see readiness/domain).
    const hasScore = true; // false when no score calculated yet
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.backgroundDark : AppColors.background,
      appBar: AppBar(
        title: Text(
          'Readiness score',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 17,
            color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
          ),
        ),
        backgroundColor: isDark ? AppColors.surfaceDark : AppColors.surface,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => context.go(router.AppRouter.dashboard),
        ),
      ),
      body: hasScore
          ? SingleChildScrollView(
              padding: AppSpacing.screenPadding,
              child: Column(
                children: [
                  const SizedBox(height: AppSpacing.xxl),
                  Center(
                    child: ProgressRing(
                      value: score,
                      size: 140,
                      strokeWidth: 12,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  Text(
                    'Career readiness',
                    style: AppTypography.h1(context, isDark: isDark),
                  ),
                  const SizedBox(height: AppSpacing.s),
                  Text(
                    'Your score is based on skills, portfolio items, and learning consistency. Add more to improve.',
                    style: AppTypography.bodySecondary(context, isDark: isDark),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: AppSpacing.xxl),
                  _NextStepsSection(isDark: isDark),
                ],
              ),
            )
          : _buildEmptyReadiness(context, isDark),
    );
  }

  Widget _buildEmptyReadiness(BuildContext context, bool isDark) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.l),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ProgressRing(value: 0, size: 120, strokeWidth: 10),
            const SizedBox(height: AppSpacing.xl),
            Text(
              'No score yet',
              style: AppTypography.h1(context, isDark: isDark),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.s),
            Text(
              'Add skills and portfolio items to get your first readiness score.',
              style: AppTypography.bodySecondary(context, isDark: isDark),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.xl),
            FilledButton.icon(
              onPressed: () => context.go(router.AppRouter.skills),
              icon: const Icon(Icons.add_rounded, size: 18),
              label: const Text('Add skill'),
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _NextStepsSection extends StatelessWidget {
  const _NextStepsSection({required this.isDark});

  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Improve your score',
          style: AppTypography.h2(context, isDark: isDark),
        ),
        const SizedBox(height: AppSpacing.m),
        _NextStepTile(
          icon: Icons.psychology_rounded,
          title: 'Add a skill',
          subtitle: 'Skills directly boost your readiness.',
          isDark: isDark,
          onTap: () => context.go(router.AppRouter.skills),
        ),
        const SizedBox(height: AppSpacing.s),
        _NextStepTile(
          icon: Icons.folder_special_rounded,
          title: 'Add a portfolio item',
          subtitle: 'Showcase projects and achievements.',
          isDark: isDark,
          onTap: () => context.go(router.AppRouter.portfolio),
        ),
        const SizedBox(height: AppSpacing.s),
        _NextStepTile(
          icon: Icons.dashboard_rounded,
          title: 'See recommendations',
          subtitle: 'Get personalized next steps on your dashboard.',
          isDark: isDark,
          onTap: () => context.go(router.AppRouter.dashboard),
        ),
      ],
    );
  }
}

class _NextStepTile extends StatelessWidget {
  const _NextStepTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.isDark,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final bool isDark;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: isDark ? AppColors.surfaceDark : AppColors.surface,
      borderRadius: AppRadius.radiusL,
      child: InkWell(
        onTap: onTap,
        borderRadius: AppRadius.radiusL,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.m,
            vertical: AppSpacing.m,
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.12),
                  borderRadius: AppRadius.radiusM,
                ),
                child: Icon(icon, size: 22, color: AppColors.primary),
              ),
              const SizedBox(width: AppSpacing.m),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: AppTypography.h2(context, isDark: isDark),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: AppTypography.caption(context, isDark: isDark),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios_rounded,
                size: 14,
                color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
