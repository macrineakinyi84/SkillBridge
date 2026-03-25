import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../shared/theme/app_colors.dart';
import '../../../../shared/theme/app_spacing.dart';
import '../../../../core/router/app_router.dart' as router;
import '../../../../shared/widgets/empty_state.dart';

class SkillsPage extends StatelessWidget {
  const SkillsPage({super.key});

  @override
  Widget build(BuildContext context) {
    const hasSkills = false; // Toggle to true to preview list UI; real state from UserSkillRepository (see skills/domain).

    return Scaffold(
      backgroundColor: Theme.of(context).brightness == Brightness.dark
          ? AppColors.backgroundDark
          : AppColors.background,
      appBar: AppBar(
        title: Text(
          'Skills',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 17,
            color: Theme.of(context).brightness == Brightness.dark
                ? AppColors.textPrimaryDark
                : AppColors.textPrimary,
          ),
        ),
        backgroundColor: Theme.of(context).brightness == Brightness.dark
            ? AppColors.surfaceDark
            : AppColors.surface,
        elevation: 0,
      ),
      body: hasSkills
          ? _buildSkillsList(context)
          : SingleChildScrollView(
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                    child: InkWell(
                      onTap: () => context.push('${router.AppRouter.skills}/categories'),
                      borderRadius: BorderRadius.circular(16),
                      child: Container(
                        padding: const EdgeInsets.all(AppSpacing.m),
                        decoration: BoxDecoration(
                          color: Theme.of(context).brightness == Brightness.dark ? AppColors.surfaceDark : AppColors.surface,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.quiz_rounded, color: AppColors.primary),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Skills Assessment', style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600)),
                                  Text('Browse categories (Tech, Soft, Business). Take assessment, view results.', style: Theme.of(context).textTheme.bodySmall),
                                ],
                              ),
                            ),
                            const Icon(Icons.arrow_forward_ios_rounded, size: 14),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  EmptyState(
                    icon: Icons.psychology_rounded,
                    iconColor: AppColors.primary,
                    headline: 'No skills yet',
                    body: 'Add your first skill to see progress here and improve your readiness score.',
                    actionLabel: 'Add skill',
                    onAction: () {
                      // Add-skill flow (form or bottom sheet) will push to repo via UserSkillRepository; not yet wired.
                    },
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildSkillsList(BuildContext context) {
    return ListView(
      padding: AppSpacing.screenPadding,
      children: const [
        SizedBox(height: AppSpacing.m),
        // When hasSkills is true, list comes from UserSkillRepository stream (see skills/data).
        Text('Skills list will appear here'),
      ],
    );
  }
}
