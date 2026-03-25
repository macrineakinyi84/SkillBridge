import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:share_plus/share_plus.dart';
import '../../../../core/router/app_router.dart' as router;
import '../../../../shared/theme/app_colors.dart';
import '../../../../shared/theme/app_radius.dart';
import '../../../../shared/theme/app_spacing.dart';
import '../../domain/models/assessment_result.dart';
import '../widgets/radar_chart_widget.dart';

/// Result: celebration, radar, score, tier, benchmark, gaps, recommendations, share, XP, Continue.
class AssessmentResultScreen extends StatefulWidget {
  const AssessmentResultScreen({super.key, this.result});

  final AssessmentResult? result;

  @override
  State<AssessmentResultScreen> createState() => _AssessmentResultScreenState();
}

class _AssessmentResultScreenState extends State<AssessmentResultScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _scoreController;
  late Animation<int> _scoreAnimation;

  @override
  void initState() {
    super.initState();
    final result = widget.result;
    _scoreController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    _scoreAnimation = IntTween(begin: 0, end: result?.normalisedScore ?? 0).animate(
      CurvedAnimation(parent: _scoreController, curve: Curves.easeOutCubic),
    );
    _scoreController.forward();
  }

  @override
  void dispose() {
    _scoreController.dispose();
    super.dispose();
  }

  static Color _tierColor(String tier) {
    if (tier == 'Advanced') return AppColors.success;
    if (tier == 'Proficient') return AppColors.primary;
    if (tier == 'Developing') return AppColors.warning;
    return AppColors.textSecondary;
  }

  @override
  Widget build(BuildContext context) {
    final result = widget.result;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    if (result == null) {
      return Scaffold(
        body: Center(child: Text('No result', style: Theme.of(context).textTheme.bodyLarge)),
      );
    }

    const labels = ['Digital', 'Communication', 'Business', 'Technical', 'Soft skills'];
    final benchmarkList = List.filled(5, 0.6);

    return Scaffold(
      backgroundColor: isDark ? AppColors.backgroundDark : AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.m),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text('Assessment Complete!', style: Theme.of(context).textTheme.headlineMedium, textAlign: TextAlign.center),
              const SizedBox(height: 24),
              RadarChartWidget(
                userValues: result.radarData,
                benchmarkValues: benchmarkList,
                labels: labels,
                size: 220,
                animateFromZero: true,
              ),
              const SizedBox(height: 24),
              AnimatedBuilder(
                animation: _scoreAnimation,
                builder: (context, _) => Text(
                  '${_scoreAnimation.value}',
                  style: Theme.of(context).textTheme.displayMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                        color: AppColors.primary,
                      ),
                  textAlign: TextAlign.center,
                ),
              ),
              Text('Score', style: Theme.of(context).textTheme.bodySmall),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: _tierColor(result.tier).withOpacity(0.2),
                  borderRadius: AppRadius.radiusM,
                ),
                child: Text(result.tier, style: TextStyle(fontWeight: FontWeight.w600, color: _tierColor(result.tier))),
              ),
              if (result.scoreChange != null) ...[
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(result.scoreChange! >= 0 ? Icons.trending_up_rounded : Icons.trending_down_rounded, color: result.scoreChange! >= 0 ? AppColors.success : AppColors.error, size: 20),
                    const SizedBox(width: 4),
                    Text(
                      result.scoreChange! >= 0 ? '↑ ${result.scoreChange} points improvement!' : '${result.scoreChange} points',
                      style: TextStyle(color: result.scoreChange! >= 0 ? AppColors.success : AppColors.error, fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              ],
              if (result.gaps.isNotEmpty) ...[
                const SizedBox(height: 24),
                Text('Top gaps', style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 8),
                ...result.gaps.take(3).map((g) => Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: ListTile(
                        title: Text(g.categoryId),
                        subtitle: Text('${g.gapPoints} pts below benchmark'),
                        trailing: FilledButton.tonal(onPressed: () => context.push(router.AppRouter.learningHub), child: const Text('Start Learning')),
                        shape: RoundedRectangleBorder(borderRadius: AppRadius.radiusM),
                        tileColor: isDark ? AppColors.surfaceDark : AppColors.surface,
                      ),
                    )),
              ],
              if (result.recommendations.isNotEmpty) ...[
                const SizedBox(height: 16),
                Text('Recommended paths', style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 8),
                ...result.recommendations.take(3).map((r) => Card(
                      child: ListTile(
                        title: Text(r.title),
                        onTap: () => context.push(router.AppRouter.learningHub),
                      ),
                    )),
              ],
              const SizedBox(height: 16),
              if (result.xpAwarded > 0)
                Card(
                  color: AppColors.xpGold.withOpacity(0.15),
                  child: Padding(
                    padding: const EdgeInsets.all(AppSpacing.m),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.star_rounded, color: AppColors.xpGold),
                        const SizedBox(width: 8),
                        Text('+${result.xpAwarded} XP earned', style: TextStyle(fontWeight: FontWeight.w700, color: AppColors.xpGold)),
                      ],
                    ),
                  ),
                ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => Share.share('I scored ${result.normalisedScore}% on my SkillBridge assessment!'),
                      icon: const Icon(Icons.share_rounded, size: 20),
                      label: const Text('Share score'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: FilledButton(
                      onPressed: () => context.go(router.AppRouter.dashboard),
                      child: const Text('Continue to Dashboard'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
