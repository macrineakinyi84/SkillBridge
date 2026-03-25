import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../shared/theme/app_colors.dart';
import '../../../../shared/theme/app_radius.dart';
import '../../../../shared/theme/app_spacing.dart';
import '../../../../shared/theme/app_typography.dart';
import '../../../../core/router/app_router.dart' as router;

/// Learning Hub (S-017). Nav tree: Recommended Courses | Skill-Gap Courses | Course Progress | Certificates Earned.
class LearningHubPage extends StatelessWidget {
  const LearningHubPage({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.backgroundDark : AppColors.background,
      appBar: AppBar(
        title: Text('Learning Hub', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 17, color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary)),
        leading: IconButton(icon: const Icon(Icons.arrow_back_rounded), onPressed: () => context.pop()),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        children: [
          Text('Recommended Courses', style: AppTypography.h2(context, isDark: isDark)),
          const SizedBox(height: 8),
          _SectionTile(icon: Icons.school_rounded, title: 'Recommended courses', subtitle: 'Based on your profile and goals', isDark: isDark, onTap: () {}),
          const SizedBox(height: 16),
          Text('Skill-Gap Courses', style: AppTypography.h2(context, isDark: isDark)),
          const SizedBox(height: 8),
          _SectionTile(icon: Icons.trending_up_rounded, title: 'Skill-gap courses', subtitle: 'Linked to assessment gaps (MVP FR-020)', isDark: isDark, onTap: () {}),
          const SizedBox(height: 16),
          Text('Course Progress', style: AppTypography.h2(context, isDark: isDark)),
          const SizedBox(height: 8),
          _SectionTile(icon: Icons.bar_chart_rounded, title: 'Course progress', subtitle: 'Track completion and time spent', isDark: isDark, onTap: () {}),
          const SizedBox(height: 16),
          Text('Certificates Earned', style: AppTypography.h2(context, isDark: isDark)),
          const SizedBox(height: 8),
          _SectionTile(icon: Icons.card_membership_rounded, title: 'Certificates earned', subtitle: 'Completed courses and certs', isDark: isDark, onTap: () {}),
        ],
      ),
    );
  }
}

class _SectionTile extends StatelessWidget {
  const _SectionTile({required this.icon, required this.title, required this.subtitle, required this.isDark, required this.onTap});
  final IconData icon;
  final String title;
  final String subtitle;
  final bool isDark;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Material(
        color: isDark ? AppColors.surfaceDark : AppColors.surface,
        borderRadius: AppRadius.radiusL,
        child: ListTile(
          leading: Icon(icon, color: AppColors.secondary),
          title: Text(title, style: AppTypography.body(context, isDark: isDark)),
          subtitle: Text(subtitle, style: AppTypography.caption(context, isDark: isDark)),
          trailing: const Icon(Icons.chevron_right_rounded),
          onTap: onTap,
        ),
      ),
    );
  }
}
