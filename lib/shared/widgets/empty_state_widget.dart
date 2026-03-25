import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_typography.dart';

/// Reusable empty state: optional Lottie, title, subtitle, optional CTA.
class EmptyStateWidget extends StatelessWidget {
  const EmptyStateWidget({
    super.key,
    this.lottiePath,
    required this.title,
    required this.subtitle,
    this.actionLabel,
    this.onAction,
    this.icon,
  });

  final String? lottiePath;
  final String title;
  final String subtitle;
  final String? actionLabel;
  final VoidCallback? onAction;
  final IconData? icon;

  /// No jobs posted / no jobs found.
  factory EmptyStateWidget.noJobs({
    String? lottiePath,
    String? actionLabel,
    VoidCallback? onAction,
  }) =>
      EmptyStateWidget(
        lottiePath: lottiePath,
        title: 'No jobs yet',
        subtitle: 'Post your first job to start receiving applications.',
        actionLabel: actionLabel ?? 'Post job',
        onAction: onAction,
        icon: Icons.work_off_rounded,
      );

  /// No assessments taken.
  factory EmptyStateWidget.noAssessments({
    String? lottiePath,
    String? actionLabel,
    VoidCallback? onAction,
  }) =>
      EmptyStateWidget(
        lottiePath: lottiePath,
        title: 'No assessments yet',
        subtitle: 'Take a skill assessment to see your strengths and gaps.',
        actionLabel: actionLabel ?? 'Browse categories',
        onAction: onAction,
        icon: Icons.quiz_rounded,
      );

  /// No notifications.
  factory EmptyStateWidget.noNotifications({
    String? lottiePath,
  }) =>
      EmptyStateWidget(
        lottiePath: lottiePath,
        title: 'No notifications',
        subtitle: 'When you get updates, they’ll show up here.',
        icon: Icons.notifications_none_rounded,
      );

  /// No applications (employer or student).
  factory EmptyStateWidget.noApplications({
    String? lottiePath,
    String? actionLabel,
    VoidCallback? onAction,
  }) =>
      EmptyStateWidget(
        lottiePath: lottiePath,
        title: 'No applications yet',
        subtitle: 'Applications for this job will appear here.',
        actionLabel: actionLabel,
        onAction: onAction,
        icon: Icons.assignment_outlined,
      );

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.l, vertical: AppSpacing.xxl),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (lottiePath != null && lottiePath!.isNotEmpty) ...[
            SizedBox(
              height: 160,
              child: Lottie.asset(
                lottiePath!,
                fit: BoxFit.contain,
              ),
            ),
            const SizedBox(height: AppSpacing.l),
          ] else if (icon != null) ...[
            Container(
              padding: const EdgeInsets.all(AppSpacing.l),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 48, color: AppColors.primary),
            ),
            const SizedBox(height: AppSpacing.l),
          ],
          Text(
            title,
            style: AppTypography.h1(context, isDark: isDark),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.s),
          Text(
            subtitle,
            style: AppTypography.bodySecondary(context, isDark: isDark),
            textAlign: TextAlign.center,
          ),
          if (actionLabel != null && onAction != null) ...[
            const SizedBox(height: AppSpacing.xl),
            FilledButton(
              onPressed: onAction,
              style: FilledButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: Colors.white),
              child: Text(actionLabel!),
            ),
          ],
        ],
      ),
    );
  }
}
