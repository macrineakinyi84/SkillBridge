import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../shared/theme/app_colors.dart';
import '../../../../shared/theme/app_radius.dart';
import '../../../../shared/theme/app_spacing.dart';
import '../../../../shared/theme/app_typography.dart';
import '../../../gamification/presentation/widgets/streak_flame.dart';
import '../../../../core/router/app_router.dart' as router;
import '../../domain/models/learning_path.dart';
import '../../domain/models/micro_lesson.dart';
import '../../domain/models/skill_gap_recommendation.dart';
import '../../data/learning_mock_data.dart';

/// Learning Hub: Today's micro-lesson, learning paths, skill-gap recommendations.
class LearningHubScreen extends StatelessWidget {
  const LearningHubScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final lesson = LearningMockData.todaysLesson;
    final streak = LearningMockData.learnStreakCount;
    final paths = LearningMockData.learningPaths;
    final inProgress = paths.where((p) => p.progressPercent > 0).toList();
    final recommended = paths.where((p) => p.isRecommended && p.progressPercent == 0).toList();
    final gaps = LearningMockData.skillGapRecommendations;

    return Scaffold(
      backgroundColor: isDark ? AppColors.backgroundDark : AppColors.background,
      appBar: AppBar(
        title: Text('Learning Hub', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 17, color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary)),
        backgroundColor: isDark ? AppColors.surfaceDark : AppColors.surface,
        elevation: 0,
        leading: IconButton(icon: const Icon(Icons.arrow_back_rounded), onPressed: () => context.pop()),
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.m),
        children: [
          _TodaysLessonCard(
            lesson: lesson,
            learnStreakCount: streak,
            isDark: isDark,
            onStart: () => context.push(router.AppRouter.microLesson(lesson.id)),
          ),
          const SizedBox(height: AppSpacing.l),
          _SectionTitle(title: "Your Learning Paths", isDark: isDark),
          const SizedBox(height: AppSpacing.s),
          if (inProgress.isNotEmpty) ...[
            _SectionSubtitle(title: 'In Progress', isDark: isDark),
            const SizedBox(height: AppSpacing.s),
            SizedBox(
              height: 180,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: inProgress.length,
                separatorBuilder: (_, __) => const SizedBox(width: AppSpacing.s),
                itemBuilder: (context, i) => _PathCard(
                  path: inProgress[i],
                  isDark: isDark,
                  onTap: () => context.push(router.AppRouter.learningPath(inProgress[i].id)),
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.m),
          ],
          _SectionSubtitle(title: 'Recommended', isDark: isDark),
          const SizedBox(height: AppSpacing.s),
          SizedBox(
            height: 180,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: (recommended.isEmpty ? paths : recommended).length,
              separatorBuilder: (_, __) => const SizedBox(width: AppSpacing.s),
              itemBuilder: (context, i) {
                final path = (recommended.isEmpty ? paths : recommended)[i];
                return _PathCard(
                  path: path,
                  isDark: isDark,
                  onTap: () => context.push(router.AppRouter.learningPath(path.id)),
                );
              },
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
          _SectionTitle(title: 'Skill-Gap Recommendations', isDark: isDark),
          const SizedBox(height: AppSpacing.s),
          ...gaps.map((g) => _GapCard(gap: g, isDark: isDark)),
        ],
      ),
    );
  }
}

class _TodaysLessonCard extends StatelessWidget {
  const _TodaysLessonCard({
    required this.lesson,
    required this.learnStreakCount,
    required this.isDark,
    required this.onStart,
  });

  final MicroLesson lesson;
  final int learnStreakCount;
  final bool isDark;
  final VoidCallback onStart;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.primary.withOpacity(0.12),
      borderRadius: AppRadius.radiusL,
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.m),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text('Daily Lesson 📚', style: AppTypography.caption(context, isDark: isDark).copyWith(color: AppColors.primary, fontWeight: FontWeight.w600)),
                const Spacer(),
                StreakFlame(count: learnStreakCount, type: StreakType.learn),
              ],
            ),
            const SizedBox(height: AppSpacing.s),
            Text(lesson.title, style: AppTypography.h2(context, isDark: isDark)),
            const SizedBox(height: AppSpacing.s),
            Wrap(
              spacing: AppSpacing.s,
              runSpacing: AppSpacing.xs,
              children: [
                _Chip(label: '${lesson.durationMinutes} min'),
                _Chip(label: lesson.category),
              ],
            ),
            const SizedBox(height: AppSpacing.xs),
            Text('Skill this improves: ${lesson.skillImproved}', style: AppTypography.caption(context, isDark: isDark)),
            const SizedBox(height: AppSpacing.m),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: onStart,
                style: FilledButton.styleFrom(backgroundColor: AppColors.primary),
                child: Text('Start ${lesson.durationMinutes}-min lesson'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  const _Chip({required this.label});
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.2),
        borderRadius: AppRadius.radiusFull,
      ),
      child: Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: AppColors.primary)),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.title, required this.isDark});
  final String title;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Text(title, style: AppTypography.h2(context, isDark: isDark));
  }
}

class _SectionSubtitle extends StatelessWidget {
  const _SectionSubtitle({required this.title, required this.isDark});
  final String title;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Text(title, style: AppTypography.body(context, isDark: isDark).copyWith(fontWeight: FontWeight.w600));
  }
}

class _PathCard extends StatelessWidget {
  const _PathCard({required this.path, required this.isDark, required this.onTap});
  final LearningPath path;
  final bool isDark;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 220,
      child: Material(
        color: isDark ? AppColors.surfaceDark : AppColors.surface,
        borderRadius: AppRadius.radiusL,
        child: InkWell(
          borderRadius: AppRadius.radiusL,
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.m),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(path.title, style: AppTypography.body(context, isDark: isDark).copyWith(fontWeight: FontWeight.w600), maxLines: 2, overflow: TextOverflow.ellipsis),
                const SizedBox(height: 4),
                Text(path.category, style: AppTypography.caption(context, isDark: isDark)),
                const Spacer(),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('${path.totalWeeks} wks • ${path.estimatedHours.toInt()}h', style: AppTypography.caption(context, isDark: isDark)),
                    if (path.progressPercent > 0) Text('${(path.progressPercent * 100).round()}%', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.primary)),
                  ],
                ),
                if (path.progressPercent > 0) ...[
                  const SizedBox(height: 4),
                  ClipRRect(
                    borderRadius: AppRadius.radiusFull,
                    child: LinearProgressIndicator(
                      value: path.progressPercent,
                      minHeight: 4,
                      backgroundColor: isDark ? AppColors.backgroundDark : AppColors.background,
                      valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _GapCard extends StatelessWidget {
  const _GapCard({required this.gap, required this.isDark});
  final SkillGapRecommendation gap;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.m),
      child: Material(
        color: isDark ? AppColors.surfaceDark : AppColors.surface,
        borderRadius: AppRadius.radiusL,
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.m),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(gap.skillName, style: AppTypography.body(context, isDark: isDark).copyWith(fontWeight: FontWeight.w600)),
              const SizedBox(height: 4),
              Text('Your score: ${gap.yourScore}% • Benchmark: ${gap.benchmarkScore}% • Gap: ${gap.gapPoints} pts', style: AppTypography.caption(context, isDark: isDark)),
              const SizedBox(height: AppSpacing.s),
              ...gap.resources.take(3).map(
                    (r) => Padding(
                      padding: const EdgeInsets.only(bottom: 4),
                      child: InkWell(
                        onTap: () => _openUrl(context, r.url),
                        child: Row(
                          children: [
                            Icon(Icons.link_rounded, size: 16, color: AppColors.primary),
                            const SizedBox(width: 6),
                            Expanded(child: Text(r.title, style: AppTypography.bodySecondary(context, isDark: isDark).copyWith(decoration: TextDecoration.underline))),
                          ],
                        ),
                      ),
                    ),
                  ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _openUrl(BuildContext context, String url) async {
    final uri = Uri.tryParse(url);
    if (uri == null) return;
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }
}
