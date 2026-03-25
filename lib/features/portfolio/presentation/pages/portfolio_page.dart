import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../shared/theme/app_colors.dart';
import '../../../../shared/theme/app_radius.dart';
import '../../../../shared/theme/app_spacing.dart';
import '../../../../shared/theme/app_typography.dart';
import '../../../../core/router/app_router.dart' as router;
import '../../../../shared/widgets/empty_state.dart';

/// Portfolio Builder (nav tree): Add Experience | Education | Projects | Certifications | Preview CV | Export PDF.
class PortfolioPage extends StatelessWidget {
  const PortfolioPage({super.key});

  @override
  Widget build(BuildContext context) {
    const hasItems = false;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.backgroundDark : AppColors.background,
      appBar: AppBar(
        title: Text('Portfolio Builder', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 17, color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary)),
        backgroundColor: isDark ? AppColors.surfaceDark : AppColors.surface,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (!hasItems)
              Padding(
                padding: const EdgeInsets.only(bottom: 24),
                child: EmptyState(
                  icon: Icons.folder_special_rounded,
                  iconColor: AppColors.secondary,
                  headline: 'No portfolio items yet',
                  body: 'Add experience, education, projects and certifications. Preview and export your CV.',
                  actionLabel: 'Add experience',
                  onAction: () {},
                ),
              ),
            Text('Build your CV', style: AppTypography.h2(context, isDark: isDark)),
            const SizedBox(height: 8),
            // Section taps navigate to add/edit when portfolio use cases are wired (portfolio/domain).
            _CvSectionTile(icon: Icons.work_rounded, title: 'Add Experience', subtitle: 'Work history and responsibilities', isDark: isDark, onTap: () {}),
            _CvSectionTile(icon: Icons.school_rounded, title: 'Add Education', subtitle: 'Degrees and qualifications', isDark: isDark, onTap: () {}),
            _CvSectionTile(icon: Icons.folder_rounded, title: 'Add Projects', subtitle: 'Showcase your work', isDark: isDark, onTap: () {}),
            _CvSectionTile(icon: Icons.card_membership_rounded, title: 'Add Certifications', subtitle: 'Courses and certs', isDark: isDark, onTap: () {}),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: () => context.push(router.AppRouter.cvPreview),
                icon: const Icon(Icons.visibility_rounded, size: 20),
                label: const Text('Preview CV'),
                style: FilledButton.styleFrom(backgroundColor: AppColors.primary),
              ),
            ),
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.picture_as_pdf_rounded, size: 20),
                label: const Text('Export PDF'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CvSectionTile extends StatelessWidget {
  const _CvSectionTile({required this.icon, required this.title, required this.subtitle, required this.isDark, required this.onTap});
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
          leading: Icon(icon, color: AppColors.primary),
          title: Text(title, style: AppTypography.body(context, isDark: isDark)),
          subtitle: Text(subtitle, style: AppTypography.caption(context, isDark: isDark)),
          trailing: const Icon(Icons.chevron_right_rounded),
          onTap: onTap,
        ),
      ),
    );
  }
}
