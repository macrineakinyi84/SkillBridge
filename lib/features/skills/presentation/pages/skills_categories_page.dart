import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../shared/theme/app_colors.dart';
import '../../../../shared/theme/app_radius.dart';
import '../../../../shared/theme/app_spacing.dart';
import '../../../../shared/theme/app_typography.dart';
import '../../../../core/router/app_router.dart' as router;

/// Browse Categories (MVP: 5 categories per spec 4.7). Take Assessment → View Results → Retake/Update.
class SkillsCategoriesPage extends StatelessWidget {
  const SkillsCategoriesPage({super.key});

  /// MVP skill categories: Digital Literacy, Communication, Business & Entrepreneurship, Technical (ICT), Soft Skills & Leadership
  static const _categories = [
    _Cat(title: 'Digital Literacy', icon: Icons.computer_rounded, subtitle: 'Basic digital tools, online safety, information literacy'),
    _Cat(title: 'Communication', icon: Icons.record_voice_over_rounded, subtitle: 'Written and verbal communication'),
    _Cat(title: 'Business & Entrepreneurship', icon: Icons.store_rounded, subtitle: 'Business basics, entrepreneurship'),
    _Cat(title: 'Technical (ICT)', icon: Icons.code_rounded, subtitle: 'Programming, tools, technical skills'),
    _Cat(title: 'Soft Skills & Leadership', icon: Icons.groups_rounded, subtitle: 'Teamwork, leadership, adaptability'),
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.backgroundDark : AppColors.background,
      appBar: AppBar(
        title: Text('Skills Assessment', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 17, color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary)),
        backgroundColor: isDark ? AppColors.surfaceDark : AppColors.surface,
        elevation: 0,
        leading: IconButton(icon: const Icon(Icons.arrow_back_rounded), onPressed: () => context.go(router.AppRouter.skills)),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        children: [
          Text('Browse categories', style: AppTypography.h2(context, isDark: isDark)),
          const SizedBox(height: 8),
          Text('Take an assessment to see your level. View results and retake anytime.', style: AppTypography.bodySecondary(context, isDark: isDark)),
          const SizedBox(height: 24),
          ..._categories.map((c) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Material(
                  color: isDark ? AppColors.surfaceDark : AppColors.surface,
                  borderRadius: AppRadius.radiusL,
                  child: InkWell(
                    borderRadius: AppRadius.radiusL,
                    onTap: () => context.push('${router.AppRouter.skills}/assess/${c.title.toLowerCase().replaceAll(' ', '-')}'),
                    child: Padding(
                      padding: const EdgeInsets.all(AppSpacing.m),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(color: AppColors.primary.withOpacity(0.12), borderRadius: AppRadius.radiusM),
                            child: Icon(c.icon, color: AppColors.primary),
                          ),
                          const SizedBox(width: AppSpacing.m),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(c.title, style: AppTypography.h2(context, isDark: isDark)),
                                Text(c.subtitle, style: AppTypography.caption(context, isDark: isDark)),
                              ],
                            ),
                          ),
                          Icon(Icons.arrow_forward_ios_rounded, size: 14, color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary),
                        ],
                      ),
                    ),
                  ),
                ),
              )),
        ],
      ),
    );
  }
}

class _Cat {
  const _Cat({required this.title, required this.icon, required this.subtitle});
  final String title;
  final IconData icon;
  final String subtitle;
}
