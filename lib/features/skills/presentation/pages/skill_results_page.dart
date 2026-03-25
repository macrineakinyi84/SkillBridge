import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../shared/theme/app_colors.dart';
import '../../../../shared/theme/app_spacing.dart';
import '../../../../shared/theme/app_typography.dart';
import '../../../../core/router/app_router.dart' as router;
import '../../../../shared/widgets/progress_ring.dart';

/// S-011: Assessment Results. Radar chart + gap analysis (MVP FR-005, FR-006). Retake/Update per nav tree.
class SkillResultsPage extends StatelessWidget {
  const SkillResultsPage({super.key, this.categoryId});

  final String? categoryId;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.backgroundDark : AppColors.background,
      appBar: AppBar(
        title: Text('Assessment Results', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 17, color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary)),
        leading: IconButton(icon: const Icon(Icons.arrow_back_rounded), onPressed: () => context.pop()),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Column(
          children: [
            const SizedBox(height: 16),
            ProgressRing(value: 72, size: 120, strokeWidth: 10),
            const SizedBox(height: 16),
            Text('Score: 72 / 100', style: AppTypography.h1(context, isDark: isDark)),
            const SizedBox(height: 8),
            Text('Radar chart and gap vs benchmark will appear here (MVP FR-005, FR-006).', style: AppTypography.bodySecondary(context, isDark: isDark), textAlign: TextAlign.center),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: () => context.go('${router.AppRouter.skills}/categories'),
              icon: const Icon(Icons.refresh_rounded, size: 20),
              label: const Text('Retake / Update'),
              style: FilledButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: Colors.white),
            ),
          ],
        ),
      ),
    );
  }
}
