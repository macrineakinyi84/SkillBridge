import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/router/app_router.dart' as router;
import '../../../../shared/theme/app_colors.dart';
import '../../../../shared/theme/app_radius.dart';
import '../../../../shared/theme/app_spacing.dart';
import '../../../../shared/widgets/auth_scope.dart';
import '../../../../shared/widgets/empty_state.dart';
import '../../../../shared/widgets/progress_ring.dart';
import '../../domain/models/dashboard_data.dart';
import '../../../gamification/domain/repositories/gamification_repository.dart';
import '../../../gamification/domain/models/gamification_profile.dart';
import '../../../gamification/domain/models/career_health_score.dart';
import '../../../gamification/presentation/widgets/career_health_ring.dart';
import '../../../gamification/presentation/widgets/streak_flame.dart';
import '../../../gamification/presentation/widgets/xp_progress_bar.dart';
import '../../../gamification/presentation/widgets/weekly_heatmap.dart';
import '../../../notifications/presentation/widgets/smart_nudge_banner.dart';

/// Main student home: career health, streaks, XP, quick actions, job matches, quest, heatmap.
class StudentDashboardScreen extends StatefulWidget {
  const StudentDashboardScreen({super.key});

  @override
  State<StudentDashboardScreen> createState() => _StudentDashboardScreenState();
}

class _StudentDashboardScreenState extends State<StudentDashboardScreen> {
  final GamificationRepository _gamificationRepo = sl<GamificationRepository>();
  GamificationProfile? _profile;
  CareerHealthScore? _careerHealth;
  List<bool> _weeklyActivity = [];
  String? _error;
  final Set<NudgeType> _dismissedNudges = {};
  DashboardData _dashboardData = const DashboardData(
    readinessScore: 72,
    skillProgressSummary: [],
    recommendedSkills: [],
    portfolioCount: 0,
    activeDaysThisWeek: 0,
    recentJobMatches: [],
    learningProgress: [],
    notificationCount: 0,
  );

  String get _userId => AuthScope.maybeOf(context)?.state.user?.id ?? '';
  String get _displayName => AuthScope.maybeOf(context)?.state.user?.displayName ?? '';

  @override
  void initState() {
    super.initState();
    _dashboardData = _loadDashboardData();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Safe place to read inherited widgets (AuthScope) and kick off async loads.
    // Guards against calling dependOnInheritedWidgetOfExactType during initState.
    if (_profile != null || _careerHealth != null || _weeklyActivity.isNotEmpty) return;
    _load();
  }

  DashboardData _loadDashboardData() {
    return const DashboardData(
      readinessScore: 72,
      skillProgressSummary: [
        SkillProgressItem(name: 'Digital Literacy', proficiencyLevel: 'Proficient', progressPercent: 78),
        SkillProgressItem(name: 'Communication', proficiencyLevel: 'Developing', progressPercent: 62),
        SkillProgressItem(name: 'Technical (ICT)', proficiencyLevel: 'Advanced', progressPercent: 85),
        SkillProgressItem(name: 'Soft Skills', proficiencyLevel: 'Intermediate', progressPercent: 70),
      ],
      recommendedSkills: ['Riverpod', 'CI/CD', 'REST APIs'],
      portfolioCount: 3,
      activeDaysThisWeek: 4,
      nextStepTitle: 'Your next step',
      nextStepBody: 'Complete your Communication assessment to raise your readiness score. One more skill at 70%+ and you\'ll hit 80% overall.',
      nextStepActionLabel: 'Take assessment',
      jobMatchPercent: 68,
      recentJobMatches: [
        RecentJobMatchItem(title: 'Junior Flutter Developer', matchPercent: 85),
        RecentJobMatchItem(title: 'Mobile Dev Intern', matchPercent: 72),
        RecentJobMatchItem(title: 'Software Trainee', matchPercent: 68),
        RecentJobMatchItem(title: 'ICT Support Associate', matchPercent: 61),
      ],
      learningProgress: [
        LearningProgressItem(title: 'Digital Skills Basics', progressPercent: 60),
        LearningProgressItem(title: 'Job Readiness', progressPercent: 30),
      ],
      notificationCount: 2,
    );
  }

  Future<void> _load() async {
    final userId = _userId;
    if (userId.isEmpty) return;
    setState(() => _error = null);
    try {
      final profile = await _gamificationRepo.getProfile(userId);
      final health = await _gamificationRepo.getCareerHealthScore(userId);
      final activity = await _gamificationRepo.getWeeklyActivityGrid(userId);
      if (mounted) {
        setState(() {
          _profile = profile;
          _careerHealth = health;
          _weeklyActivity = activity;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _error = e.toString());
    }
  }

  String _greeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good morning';
    if (hour < 17) return 'Good afternoon';
    return 'Good evening';
  }

  PreferredSizeWidget _buildAppBar(bool isDark) {
    final name = _displayName.trim().isNotEmpty ? _displayName : 'there';
    return AppBar(
      backgroundColor: isDark ? AppColors.surfaceDark : AppColors.surface,
      elevation: 0,
      title: Text(
        '${_greeting()}, $name 👋',
        style: TextStyle(
          fontWeight: FontWeight.w700,
          fontSize: 20,
          color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
        ),
      ),
      actions: [
        IconButton(
          icon: Badge(
            isLabelVisible: _dashboardData.notificationCount > 0,
            label: Text('${_dashboardData.notificationCount}'),
            child: Icon(Icons.notifications_rounded, color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary),
          ),
          onPressed: () => context.push(router.AppRouter.notifications),
        ),
        IconButton(
          icon: CircleAvatar(
            radius: 18,
            backgroundColor: AppColors.primary.withOpacity(0.2),
            child: Text(
              (name.isNotEmpty ? name[0] : '?').toUpperCase(),
              style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.w600),
            ),
          ),
          onPressed: () => context.go(router.AppRouter.profile),
        ),
      ],
    );
  }

  Widget _buildScrollContent(bool isDark) {
    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // In-shell header (avoid nested Scaffold/AppBar on web).
          Padding(
            padding: const EdgeInsets.fromLTRB(AppSpacing.m, AppSpacing.m, AppSpacing.m, 0),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    '${_greeting()}, ${_displayName.trim().isNotEmpty ? _displayName.trim() : 'there'} 👋',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 20,
                      color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  tooltip: 'Notifications',
                  icon: Badge(
                    isLabelVisible: _dashboardData.notificationCount > 0,
                    label: Text('${_dashboardData.notificationCount}'),
                    child: Icon(Icons.notifications_rounded, color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary),
                  ),
                  onPressed: () => context.push(router.AppRouter.notifications),
                ),
                IconButton(
                  tooltip: 'Profile',
                  icon: CircleAvatar(
                    radius: 18,
                    backgroundColor: AppColors.primary.withOpacity(0.2),
                    child: Text(
                      ((_displayName.trim().isNotEmpty ? _displayName.trim()[0] : '?')).toUpperCase(),
                      style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.w600),
                    ),
                  ),
                  onPressed: () => context.go(router.AppRouter.profile),
                ),
              ],
            ),
          ),
          _buildWelcomeOrPlaceholder(isDark),
          SizedBox(height: AppSpacing.sectionVerticalGap),
          _buildNudgeBanner(isDark),
          SizedBox(height: AppSpacing.sectionVerticalGap),
          _buildCareerHealthCard(isDark),
          SizedBox(height: AppSpacing.sectionVerticalGap),
          _buildStreaksRow(isDark),
          SizedBox(height: AppSpacing.sectionVerticalGap),
          _buildLevelXp(isDark),
          SizedBox(height: AppSpacing.sectionVerticalGap),
          _buildQuickActions(isDark),
          SizedBox(height: AppSpacing.sectionVerticalGap),
          _buildTopJobMatches(isDark),
          SizedBox(height: AppSpacing.sectionVerticalGap),
          _buildActiveQuest(isDark),
          SizedBox(height: AppSpacing.sectionVerticalGap),
          _buildSkillsSnapshot(isDark),
          SizedBox(height: AppSpacing.sectionVerticalGap),
          _buildWeeklyHeatmap(isDark),
          SizedBox(height: AppSpacing.sectionVerticalGap),
          _buildCommunityFeed(isDark),
          const SizedBox(height: 48),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Material(
      color: isDark ? AppColors.backgroundDark : AppColors.background,
      child: RefreshIndicator(
        onRefresh: _load,
        child: _error != null
            ? Center(
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.l),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(_error!, textAlign: TextAlign.center),
                      const SizedBox(height: 16),
                      FilledButton(onPressed: _load, child: const Text('Retry')),
                    ],
                  ),
                ),
              )
            : _buildScrollContent(isDark),
      ),
    );
  }

  /// One nudge at a time; highest priority wins; dismiss hides for this session.
  Widget _buildNudgeBanner(bool isDark) {
    const priority = [NudgeType.streakWarning, NudgeType.profileIncomplete, NudgeType.newMatches, NudgeType.learningReminder];
    NudgeType? current;
    for (final t in priority) {
      if (!_dismissedNudges.contains(t)) {
        current = t;
        break;
      }
    }
    if (current == null) return const SizedBox.shrink();

    String title;
    String message;
    switch (current) {
      case NudgeType.streakWarning:
        title = 'Keep your streak';
        message = 'Complete an activity today to keep your streak.';
        break;
      case NudgeType.profileIncomplete:
        title = 'Complete your profile';
        message = 'Add a photo and bio to stand out to employers.';
        break;
      case NudgeType.newMatches:
        title = 'New job matches';
        message = 'Jobs matching your skills were added this week.';
        break;
      case NudgeType.learningReminder:
        title = 'Today\'s lesson';
        message = 'Spend 5 minutes on a micro-lesson.';
        break;
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(AppSpacing.m, AppSpacing.s, AppSpacing.m, 0),
      child: SmartNudgeBanner(
        nudgeType: current,
        title: title,
        message: message,
        onDismiss: () {
          final nudgeType = current;
          if (nudgeType != null) setState(() => _dismissedNudges.add(nudgeType));
        },
      ),
    );
  }

  /// When profile/health aren't loaded yet, show a welcome card so the page is never blank.
  /// Title avoids repeating the header greeting (e.g. "Good morning, there 👋").
  Widget _buildWelcomeOrPlaceholder(bool isDark) {
    if (_profile != null || _careerHealth != null) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.fromLTRB(AppSpacing.m, 8, AppSpacing.m, 0),
      child: Material(
        color: isDark ? AppColors.surfaceDark : AppColors.surface,
        borderRadius: AppRadius.radiusL,
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.m),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Welcome to SkillBridge',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Complete your profile and take the assessment to see your career health and job matches.',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 12),
              FilledButton(
                onPressed: () => context.push(router.AppRouter.assessmentList),
                child: const Text('Take assessment'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCareerHealthCard(bool isDark) {
    final health = _careerHealth;
    if (health == null) return const SizedBox.shrink();
    final delta = health.delta;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.m),
      child: Material(
        color: isDark ? AppColors.surfaceDark : AppColors.surface,
        borderRadius: AppRadius.radiusL,
        elevation: 0,
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.l),
          child: Column(
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CareerHealthRing(score: health, size: 160, previousScore: health.previousTotal),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${health.total}',
                          style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                                fontWeight: FontWeight.w800,
                                color: AppColors.primary,
                              ),
                        ),
                        Text(
                          'Career Health Score',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                        if (delta != 0)
                          Text(
                            'This week: ${delta > 0 ? "+" : ""}$delta points',
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: delta > 0 ? AppColors.success : AppColors.error,
                                  fontWeight: FontWeight.w600,
                                ),
                          ),
                      ],
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

  Widget _buildStreaksRow(bool isDark) {
    final job = _profile?.jobStreak ?? 0;
    final learn = _profile?.learnStreak ?? 0;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.m),
      child: Row(
        // In a scroll view, height is unbounded; stretching would force infinite height.
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Material(
              color: isDark ? AppColors.surfaceDark : AppColors.surface,
              borderRadius: AppRadius.radiusL,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.m, vertical: AppSpacing.l),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(minHeight: 116),
                  child: StreakFlame(count: job, type: StreakType.job),
                ),
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.m),
          Expanded(
            child: Material(
              color: isDark ? AppColors.surfaceDark : AppColors.surface,
              borderRadius: AppRadius.radiusL,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.m, vertical: AppSpacing.l),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(minHeight: 116),
                  child: StreakFlame(count: learn, type: StreakType.learn),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLevelXp(bool isDark) {
    final profile = _profile;
    if (profile == null) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.m),
      child: Material(
        color: isDark ? AppColors.surfaceDark : AppColors.surface,
        borderRadius: AppRadius.radiusL,
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.l),
          child: XpProgressBar(profile: profile),
        ),
      ),
    );
  }

  Widget _buildQuickActions(bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.m),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Quick Actions', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: AppSpacing.m),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _QuickActionChip(icon: Icons.quiz_rounded, label: 'Take Assessment', isDark: isDark, onTap: () => context.push(router.AppRouter.assessmentList)),
                _QuickActionChip(icon: Icons.work_rounded, label: 'Browse Jobs', isDark: isDark, onTap: () => context.push(router.AppRouter.jobBoard)),
                _QuickActionChip(icon: Icons.folder_rounded, label: 'Update Portfolio', isDark: isDark, onTap: () => context.go(router.AppRouter.portfolio)),
                _QuickActionChip(icon: Icons.menu_book_rounded, label: "Today's Lesson", isDark: isDark, onTap: () => context.push(router.AppRouter.learningHub)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTopJobMatches(bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.m),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Top Job Matches', style: Theme.of(context).textTheme.titleMedium),
              TextButton(onPressed: () => context.push(router.AppRouter.jobBoard), child: const Text('See all')),
            ],
          ),
          const SizedBox(height: AppSpacing.m),
          if (_dashboardData.recentJobMatches.isEmpty)
            EmptyState(
              headline: 'No matches yet',
              body: 'Complete your assessment to see job matches.',
              actionLabel: 'Take assessment',
              onAction: () => context.push(router.AppRouter.assessmentList),
              icon: Icons.work_rounded,
            )
          else
            SizedBox(
              height: 140,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: _dashboardData.recentJobMatches.length,
                separatorBuilder: (_, __) => const SizedBox(width: 12),
                itemBuilder: (context, i) {
                  final item = _dashboardData.recentJobMatches[i];
                  return SizedBox(
                    width: 200,
                    child: Material(
                      color: isDark ? AppColors.surfaceDark : AppColors.surface,
                      borderRadius: AppRadius.radiusL,
                      child: InkWell(
                        borderRadius: AppRadius.radiusL,
                        onTap: () => context.push('${router.AppRouter.jobBoard}/job/${i}'),
                        child: Padding(
                          padding: const EdgeInsets.all(AppSpacing.m),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  SizedBox(
                                    width: 44,
                                    height: 44,
                                    child: ProgressRing(value: item.matchPercent, size: 40, strokeWidth: 4),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Text(
                                      item.title,
                                      style: Theme.of(context).textTheme.titleSmall,
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                              const Spacer(),
                              Text('Match: ${item.matchPercent}%', style: Theme.of(context).textTheme.bodySmall),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildActiveQuest(bool isDark) {
    final nextStep = _dashboardData.nextStepTitle;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.m),
      child: Material(
        color: isDark ? AppColors.surfaceDark : AppColors.surface,
        borderRadius: AppRadius.radiusL,
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.l),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Active Quest', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: AppSpacing.m),
              Text(nextStep ?? 'Set your goal', style: Theme.of(context).textTheme.bodyLarge),
              const SizedBox(height: AppSpacing.m),
              LinearProgressIndicator(value: 0.4, backgroundColor: AppColors.primary.withOpacity(0.2), valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary)),
              const SizedBox(height: AppSpacing.m),
              Text(_dashboardData.nextStepBody ?? 'Complete steps to level up.', style: Theme.of(context).textTheme.bodySmall),
              const SizedBox(height: AppSpacing.m),
              FilledButton(onPressed: () => context.go(router.AppRouter.skills), child: Text(_dashboardData.nextStepActionLabel ?? 'Continue')),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSkillsSnapshot(bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.m),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Skills Snapshot', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: AppSpacing.m),
          Row(
            children: [
              ProgressRing(value: _dashboardData.readinessScore, size: 120, strokeWidth: 10),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Readiness: ${_dashboardData.readinessScore}%', style: Theme.of(context).textTheme.titleSmall),
                    Text('Last assessed: 3 days ago', style: Theme.of(context).textTheme.bodySmall),
                    FilledButton.tonal(onPressed: () => context.go(router.AppRouter.skills), child: const Text('Reassess now')),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildWeeklyHeatmap(bool isDark) {
    final activity = _weeklyActivity.isNotEmpty ? _weeklyActivity : List.filled(7, false);
    final activeCount = activity.where((e) => e).length;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.m),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Weekly Activity', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: AppSpacing.m),
          WeeklyHeatmap(activityByDay: activity),
          const SizedBox(height: 8),
          Text('$activeCount days active this week', style: Theme.of(context).textTheme.bodySmall),
        ],
      ),
    );
  }

  Widget _buildCommunityFeed(bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.m),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Community Activity', style: Theme.of(context).textTheme.titleMedium),
              TextButton(
                onPressed: () => context.push(router.AppRouter.community),
                child: const Text('See community'),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.s),
          Text('Recent activity from your county will appear here. Check the Feed and Leaderboard in Community.', style: Theme.of(context).textTheme.bodySmall),
        ],
      ),
    );
  }

  Widget _buildSkeleton(bool isDark) {
    final surface = isDark ? AppColors.surfaceDark : AppColors.surface;
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.m),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 24),
          Container(height: 200, decoration: BoxDecoration(color: surface, borderRadius: AppRadius.radiusL)),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(child: Container(height: 120, decoration: BoxDecoration(color: surface, borderRadius: AppRadius.radiusL))),
              const SizedBox(width: 16),
              Expanded(child: Container(height: 120, decoration: BoxDecoration(color: surface, borderRadius: AppRadius.radiusL))),
            ],
          ),
        ],
      ),
    );
  }
}

class _QuickActionChip extends StatelessWidget {
  const _QuickActionChip({required this.icon, required this.label, required this.isDark, required this.onTap});
  final IconData icon;
  final String label;
  final bool isDark;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 12),
      child: Material(
        color: isDark ? AppColors.surfaceDark : AppColors.surface,
        borderRadius: AppRadius.radiusL,
        child: InkWell(
          borderRadius: AppRadius.radiusL,
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, color: AppColors.primary, size: 24),
                const SizedBox(width: 8),
                Text(label, style: Theme.of(context).textTheme.bodyMedium),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
