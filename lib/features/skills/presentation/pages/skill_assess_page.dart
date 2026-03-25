import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../shared/theme/app_colors.dart';
import '../../../../shared/theme/app_spacing.dart';
import '../../../../core/router/app_router.dart' as router;
import '../../../../shared/widgets/empty_state.dart';

/// Take Assessment placeholder. Adaptive quiz engine UI coming later.
class SkillAssessPage extends StatelessWidget {
  const SkillAssessPage({super.key, this.categoryId});

  final String? categoryId;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).brightness == Brightness.dark ? AppColors.backgroundDark : AppColors.background,
      appBar: AppBar(
        title: const Text('Assessment'),
        leading: IconButton(icon: const Icon(Icons.arrow_back_rounded), onPressed: () => context.pop()),
      ),
      body: EmptyState(
        icon: Icons.quiz_rounded,
        iconColor: AppColors.primary,
        headline: 'Assessment coming soon',
        body: 'Adaptive quiz engine, category-based assessments, and visual results with gap analysis will appear here.',
        actionLabel: 'View sample results',
        onAction: () => context.push('${router.AppRouter.skills}/results/digital-literacy'),
      ),
    );
  }
}
