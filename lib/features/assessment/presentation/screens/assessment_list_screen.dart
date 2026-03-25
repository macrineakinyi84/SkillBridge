import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/router/app_router.dart' as router;
import '../../../../shared/theme/app_colors.dart';
import '../../../../shared/theme/app_radius.dart';
import '../../../../shared/theme/app_spacing.dart';
import '../../../../shared/widgets/auth_scope.dart';
import '../../../../shared/widgets/progress_ring.dart';
import '../../domain/repositories/assessment_repository.dart';
import '../../domain/models/assessment_category.dart';

/// Grid of 5 category cards: icon, name, score ring or "Not yet assessed", tier, benchmark, days since, Retake/Start.
class AssessmentListScreen extends StatefulWidget {
  const AssessmentListScreen({super.key});

  @override
  State<AssessmentListScreen> createState() => _AssessmentListScreenState();
}

class _AssessmentListScreenState extends State<AssessmentListScreen> {
  final AssessmentRepository _repo = sl<AssessmentRepository>();
  List<AssessmentCategory> _categories = [];
  bool _loading = true;

  String get _userId => AuthScope.maybeOf(context)?.state.user?.id ?? '';

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final list = await _repo.getCategories(_userId);
      if (mounted) setState(() {
        _categories = list;
        _loading = false;
      });
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  static IconData _iconFor(String iconName) {
    switch (iconName) {
      case 'digital-literacy': return Icons.computer_rounded;
      case 'communication': return Icons.record_voice_over_rounded;
      case 'business-entrepreneurship': return Icons.store_rounded;
      case 'technical-ict': return Icons.code_rounded;
      case 'soft-skills-leadership': return Icons.groups_rounded;
      default: return Icons.quiz_rounded;
    }
  }

  static Color _tierColor(String? tier) {
    if (tier == null) return AppColors.textSecondary;
    if (tier == 'Advanced') return AppColors.success;
    if (tier == 'Proficient') return AppColors.primary;
    if (tier == 'Developing') return AppColors.warning;
    return AppColors.textSecondary;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.backgroundDark : AppColors.background,
      appBar: AppBar(
        title: Text('Skills Assessment', style: TextStyle(fontWeight: FontWeight.w600, color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary)),
        backgroundColor: isDark ? AppColors.surfaceDark : AppColors.surface,
        elevation: 0,
        leading: IconButton(icon: const Icon(Icons.arrow_back_rounded), onPressed: () => context.go(router.AppRouter.skills)),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : GridView.builder(
              padding: const EdgeInsets.all(AppSpacing.m),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.85,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
              ),
              itemCount: _categories.length,
              itemBuilder: (context, i) {
                final cat = _categories[i];
                final assessed = cat.currentScore != null;
                return Material(
                  color: isDark ? AppColors.surfaceDark : AppColors.surface,
                  borderRadius: AppRadius.radiusL,
                  child: InkWell(
                    borderRadius: AppRadius.radiusL,
                    onTap: () => context.push('${router.AppRouter.assessmentQuiz}/${cat.id}'),
                    child: Padding(
                      padding: const EdgeInsets.all(AppSpacing.m),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(_iconFor(cat.iconName), size: 40, color: AppColors.primary),
                          const SizedBox(height: 8),
                          Text(cat.name, style: Theme.of(context).textTheme.titleSmall, textAlign: TextAlign.center, maxLines: 2),
                          const SizedBox(height: 8),
                          if (assessed)
                            ProgressRing(value: cat.currentScore!, size: 56, strokeWidth: 6)
                          else
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(color: AppColors.textSecondary.withOpacity(0.2), borderRadius: AppRadius.radiusS),
                              child: Text('Not yet assessed', style: Theme.of(context).textTheme.bodySmall),
                            ),
                          if (cat.tier != null) ...[
                            const SizedBox(height: 4),
                            Text(cat.tier!, style: Theme.of(context).textTheme.bodySmall?.copyWith(color: _tierColor(cat.tier), fontWeight: FontWeight.w600)),
                          ],
                          if (cat.daysSinceLastAssessment >= 0) ...[
                            const SizedBox(height: 2),
                            Text('${cat.daysSinceLastAssessment}d ago', style: Theme.of(context).textTheme.bodySmall),
                          ],
                          const SizedBox(height: 8),
                          FilledButton.tonal(
                            onPressed: () => context.push('${router.AppRouter.assessmentQuiz}/${cat.id}'),
                            style: FilledButton.styleFrom(minimumSize: const Size.fromHeight(36)),
                            child: Text(assessed ? 'Retake' : 'Start'),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
    );
  }
}
