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
    final cId = categoryId;
    return Scaffold(
      backgroundColor: Theme.of(context).brightness == Brightness.dark ? AppColors.backgroundDark : AppColors.background,
      appBar: AppBar(
        title: const Text('Assessment'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => context.canPop() ? context.pop() : context.go('${router.AppRouter.skills}/categories'),
        ),
      ),
      body: EmptyState(
        icon: Icons.quiz_rounded,
        iconColor: AppColors.primary,
        headline: cId == null ? 'Select a category' : 'Ready to start assessment',
        body: cId == null
            ? 'Choose a category from Skills Assessment.'
            : 'Launch the quiz for ${cId.replaceAll('-', ' ')}.',
        actionLabel: cId == null ? 'Browse categories' : 'Start quiz',
        onAction: () => cId == null
            ? context.go('${router.AppRouter.skills}/categories')
            : context.push(router.AppRouter.assessmentQuizFor(cId)),
      ),
    );
  }
}
