import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../shared/theme/app_colors.dart';
import '../../../../shared/theme/app_radius.dart';
import '../../../../shared/theme/app_spacing.dart';
import '../../../../shared/theme/app_typography.dart';
import '../../../../core/router/app_router.dart' as router;

/// Job Board (S-014). Nav tree: Search & Filter | Job Details | Apply Now | Saved Jobs | Application History | Status Tracker.
class JobBoardPage extends StatelessWidget {
  const JobBoardPage({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.backgroundDark : AppColors.background,
      appBar: AppBar(
        title: Text('Job Board', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 17, color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => context.canPop() ? context.pop() : context.go(router.AppRouter.dashboard),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        children: [
          Text('Search & filter jobs', style: AppTypography.h2(context, isDark: isDark)),
          const SizedBox(height: 8),
          TextField(
            decoration: InputDecoration(
              hintText: 'Search by role, company, location...',
              prefixIcon: const Icon(Icons.search_rounded),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              filled: true,
              fillColor: isDark ? AppColors.surfaceDark : AppColors.surface,
            ),
          ),
          const SizedBox(height: 24),
          Text('Quick actions', style: AppTypography.h2(context, isDark: isDark)),
          const SizedBox(height: 8),
          _NavTile(title: 'Job details & Apply Now', subtitle: 'View job and submit application', icon: Icons.work_rounded, isDark: isDark, onTap: () => context.push('${router.AppRouter.jobBoard}/job/sample')),
          _NavTile(title: 'Saved jobs', subtitle: 'Jobs you saved', icon: Icons.bookmark_rounded, isDark: isDark, onTap: () {}),
          _NavTile(title: 'Application history & Status tracker', subtitle: 'Pending / Viewed / Accepted / Rejected', icon: Icons.history_rounded, isDark: isDark, onTap: () => context.push('${router.AppRouter.jobBoard}/applications')),
        ],
      ),
    );
  }
}

class _NavTile extends StatelessWidget {
  const _NavTile({required this.title, required this.subtitle, required this.icon, required this.isDark, required this.onTap});
  final String title;
  final String subtitle;
  final IconData icon;
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
