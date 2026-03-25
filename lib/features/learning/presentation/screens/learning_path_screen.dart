import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/router/app_router.dart' as router;
import '../../../../shared/theme/app_colors.dart';
import '../../../../shared/theme/app_radius.dart';
import '../../../../shared/theme/app_spacing.dart';
import '../../../../shared/theme/app_typography.dart';
import '../../../../shared/widgets/auth_scope.dart';
import '../../../gamification/domain/repositories/gamification_repository.dart';
import '../../domain/models/learning_path.dart';
import '../../domain/repositories/learning_progress_repository.dart';
import '../../data/learning_mock_data.dart';

/// Week-by-week learning path with resources, progress, and completion celebration.
class LearningPathScreen extends StatefulWidget {
  const LearningPathScreen({super.key, required this.pathId});

  final String pathId;

  @override
  State<LearningPathScreen> createState() => _LearningPathScreenState();
}

class _LearningPathScreenState extends State<LearningPathScreen> {
  LearningPath? _path;
  Set<String> _completedResourceIds = {};
  Set<int> _completedWeeks = {};
  bool _showCelebration = false;
  bool _savedProgressLoaded = false;

  final LearningProgressRepository _progressRepo = sl<LearningProgressRepository>();
  final GamificationRepository _gamificationRepo = sl<GamificationRepository>();

  String get _userId => AuthScope.maybeOf(context)?.state.user?.id ?? '';

  @override
  void initState() {
    super.initState();
    _loadPathFromMock();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_path != null && _userId.isNotEmpty && !_savedProgressLoaded) {
      _savedProgressLoaded = true;
      _loadSavedProgress();
    }
  }

  void _loadPathFromMock() {
    LearningPath? path;
    for (final p in LearningMockData.learningPaths) {
      if (p.id == widget.pathId) {
        path = p;
        break;
      }
    }
    if (path != null) {
      setState(() {
        _path = path;
        for (final w in path!.weeks) {
          for (final r in w.resources) {
            if (r.isCompleted) _completedResourceIds.add(r.id);
          }
          if (w.resources.every((r) => _completedResourceIds.contains(r.id))) _completedWeeks.add(w.weekNumber);
        }
      });
    }
  }

  Future<void> _loadSavedProgress() async {
    final userId = _userId;
    if (userId.isEmpty || _path == null) return;
    final savedIds = await _progressRepo.getCompletedResourceIds(userId, widget.pathId);
    setState(() {
      _completedResourceIds.addAll(savedIds);
      _completedWeeks.clear();
      for (final w in _path!.weeks) {
        if (w.resources.every((r) => _completedResourceIds.contains(r.id))) _completedWeeks.add(w.weekNumber);
      }
    });
  }

  Future<void> _persistProgress() async {
    final userId = _userId;
    if (userId.isEmpty) return;
    await _progressRepo.setCompletedResourceIds(userId, widget.pathId, _completedResourceIds.toList());
  }

  double get _progressPercent {
    if (_path == null) return 0;
    int total = 0;
    int done = 0;
    for (final w in _path!.weeks) {
      for (final r in w.resources) {
        total++;
        if (_completedResourceIds.contains(r.id)) done++;
      }
    }
    return total == 0 ? 0 : done / total;
  }

  int get _currentWeek {
    if (_path == null) return 1;
    for (final w in _path!.weeks) {
      final allDone = w.resources.every((r) => _completedResourceIds.contains(r.id));
      if (!allDone) return w.weekNumber;
    }
    return _path!.weeks.length;
  }

  bool get _allWeeksComplete => _path != null && _path!.weeks.every((w) => w.resources.every((r) => _completedResourceIds.contains(r.id)));

  void _markResourceComplete(String resourceId) {
    final prevCompletedWeeks = Set<int>.from(_completedWeeks);
    final wasAllComplete = _allWeeksComplete;
    setState(() {
      _completedResourceIds.add(resourceId);
      if (_path != null) {
        for (final w in _path!.weeks) {
          if (w.resources.every((r) => _completedResourceIds.contains(r.id))) _completedWeeks.add(w.weekNumber);
        }
      }
      if (_allWeeksComplete) _showCelebration = true;
    });
    _persistProgress();
    final newlyCompleted = _completedWeeks.difference(prevCompletedWeeks);
    if (newlyCompleted.isNotEmpty && !wasAllComplete && _allWeeksComplete) {
      final userId = _userId;
      if (userId.isNotEmpty) {
        _gamificationRepo.awardXp(userId, 'learning_path_completed');
      }
    }
    if (newlyCompleted.isNotEmpty && !_allWeeksComplete) {
      final weekNum = newlyCompleted.first;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Week $weekNum complete! Week ${weekNum + 1} unlocked.'),
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      });
    }
  }

  Future<void> _openUrl(String? url) async {
    if (url == null || url.isEmpty) return;
    final uri = Uri.tryParse(url);
    if (uri == null) return;
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    if (_path == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Learning Path')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    final path = _path!;
    final currentWeek = _currentWeek;

    return Scaffold(
      backgroundColor: isDark ? AppColors.backgroundDark : AppColors.background,
      appBar: AppBar(
        title: Text(path.title),
        backgroundColor: isDark ? AppColors.surfaceDark : AppColors.surface,
        leading: IconButton(icon: const Icon(Icons.arrow_back_rounded), onPressed: () => context.pop()),
      ),
      body: Stack(
        children: [
          ListView(
            padding: const EdgeInsets.all(AppSpacing.m),
            children: [
              _buildHeader(path, isDark),
              const SizedBox(height: AppSpacing.l),
              ...path.weeks.map((week) => _WeekSection(
                    week: week,
                    totalWeeks: path.weeks.length,
                    isDark: isDark,
                    isCurrentWeek: week.weekNumber == currentWeek,
                    isUnlocked: week.weekNumber == 1 || _completedWeeks.contains(week.weekNumber - 1),
                    completedResourceIds: _completedResourceIds,
                    onStart: _openUrl,
                    onMarkComplete: _markResourceComplete,
                  )),
              const SizedBox(height: AppSpacing.xxl),
            ],
          ),
          if (_showCelebration) _CelebrationOverlay(
                pathId: path.id,
                pathTitle: path.title,
                onClose: () => setState(() => _showCelebration = false),
                onViewCertificate: () {
                  setState(() => _showCelebration = false);
                  context.push(router.AppRouter.learningPathCertificate(path.id, path.title), extra: path.title);
                },
              ),
        ],
      ),
    );
  }

  Widget _buildHeader(LearningPath path, bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(path.category, style: AppTypography.caption(context, isDark: isDark)),
        const SizedBox(height: 4),
        Row(
          children: [
            Text('${path.totalWeeks} weeks', style: AppTypography.body(context, isDark: isDark)),
            const SizedBox(width: AppSpacing.m),
            Text('${path.estimatedHours.toInt()} hrs', style: AppTypography.body(context, isDark: isDark)),
          ],
        ),
        const SizedBox(height: AppSpacing.m),
        Row(
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius: AppRadius.radiusFull,
                child: LinearProgressIndicator(
                  value: _progressPercent,
                  minHeight: 8,
                  backgroundColor: isDark ? AppColors.surfaceDark : AppColors.background,
                  valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
                ),
              ),
            ),
            const SizedBox(width: AppSpacing.s),
            Text('${(_progressPercent * 100).round()}%', style: AppTypography.body(context, isDark: isDark).copyWith(fontWeight: FontWeight.w600)),
          ],
        ),
      ],
    );
  }
}

class _WeekSection extends StatelessWidget {
  const _WeekSection({
    required this.week,
    required this.totalWeeks,
    required this.isDark,
    required this.isCurrentWeek,
    required this.isUnlocked,
    required this.completedResourceIds,
    required this.onStart,
    required this.onMarkComplete,
  });

  final PathWeek week;
  final int totalWeeks;
  final bool isDark;
  final bool isCurrentWeek;
  final bool isUnlocked;
  final Set<String> completedResourceIds;
  final ValueChanged<String?> onStart;
  final ValueChanged<String> onMarkComplete;

  @override
  Widget build(BuildContext context) {
    final opacity = isUnlocked ? 1.0 : 0.5;
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.l),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: isCurrentWeek ? AppColors.primary : (isDark ? AppColors.surfaceDark : AppColors.surface),
                  shape: BoxShape.circle,
                  border: Border.all(color: isCurrentWeek ? AppColors.primary : AppColors.borderLight, width: 2),
                ),
                child: Center(
                  child: Text('${week.weekNumber}', style: TextStyle(fontWeight: FontWeight.w700, color: isCurrentWeek ? Colors.white : (isDark ? AppColors.textPrimaryDark : AppColors.textPrimary))),
                ),
              ),
              if (week.weekNumber < totalWeeks) Container(width: 2, height: 80, color: AppColors.borderLight.withOpacity(opacity)),
            ],
          ),
          const SizedBox(width: AppSpacing.m),
          Expanded(
            child: Opacity(
              opacity: opacity,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Week ${week.weekNumber}', style: AppTypography.h2(context, isDark: isDark)),
                  const SizedBox(height: AppSpacing.s),
                  ...week.resources.map((r) => _ResourceCard(
                        resource: r,
                        isDark: isDark,
                        isUnlocked: isUnlocked,
                        isCompleted: completedResourceIds.contains(r.id),
                        onStart: () => onStart(r.url),
                        onMarkComplete: () => onMarkComplete(r.id),
                      )),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ResourceCard extends StatelessWidget {
  const _ResourceCard({
    required this.resource,
    required this.isDark,
    required this.isUnlocked,
    required this.isCompleted,
    required this.onStart,
    required this.onMarkComplete,
  });

  final PathResource resource;
  final bool isDark;
  final bool isUnlocked;
  final bool isCompleted;
  final VoidCallback onStart;
  final VoidCallback onMarkComplete;

  @override
  Widget build(BuildContext context) {
    IconData icon;
    switch (resource.type) {
      case ResourceType.video:
        icon = Icons.play_circle_outline_rounded;
        break;
      case ResourceType.article:
        icon = Icons.article_outlined;
        break;
      case ResourceType.quiz:
        icon = Icons.quiz_outlined;
        break;
    }
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.s),
      child: Material(
        color: isDark ? AppColors.surfaceDark : AppColors.surface,
        borderRadius: AppRadius.radiusL,
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.m),
          child: Row(
            children: [
              Icon(icon, color: isCompleted ? AppColors.success : AppColors.primary),
              const SizedBox(width: AppSpacing.s),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(resource.title, style: AppTypography.body(context, isDark: isDark).copyWith(fontWeight: FontWeight.w500)),
                    const SizedBox(height: 2),
                    Text('${resource.durationMinutes} min', style: AppTypography.caption(context, isDark: isDark)),
                  ],
                ),
              ),
              if (isCompleted)
                const Icon(Icons.check_circle_rounded, color: AppColors.success)
              else ...[
                TextButton(onPressed: isUnlocked ? onStart : null, child: const Text('Start')),
                IconButton(
                  icon: const Icon(Icons.check_circle_outline_rounded),
                  onPressed: isUnlocked ? onMarkComplete : null,
                  color: AppColors.primary,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _CelebrationOverlay extends StatelessWidget {
  const _CelebrationOverlay({
    required this.pathId,
    required this.pathTitle,
    required this.onClose,
    required this.onViewCertificate,
  });

  final String pathId;
  final String pathTitle;
  final VoidCallback onClose;
  final VoidCallback onViewCertificate;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.black54,
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.l),
          child: Material(
            color: Theme.of(context).scaffoldBackgroundColor,
            borderRadius: AppRadius.radiusL,
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.xl),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.celebration_rounded, size: 64, color: AppColors.xpGold),
                  const SizedBox(height: AppSpacing.m),
                  Text('Path complete!', style: Theme.of(context).textTheme.headlineSmall),
                  const SizedBox(height: AppSpacing.s),
                  Text('You finished $pathTitle', textAlign: TextAlign.center, style: Theme.of(context).textTheme.bodyLarge),
                  const SizedBox(height: AppSpacing.s),
                  Text('Certificate generated • XP awarded', style: Theme.of(context).textTheme.bodySmall),
                  const SizedBox(height: AppSpacing.l),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      FilledButton(onPressed: onViewCertificate, child: const Text('View certificate')),
                      const SizedBox(width: AppSpacing.s),
                      OutlinedButton(onPressed: onClose, child: const Text('Done')),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
