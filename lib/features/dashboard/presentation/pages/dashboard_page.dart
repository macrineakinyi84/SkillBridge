import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../shared/theme/app_colors.dart';
import '../../../../shared/theme/app_radius.dart';
import '../../../../shared/theme/app_spacing.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/router/app_router.dart' as router;
import '../../../../shared/widgets/auth_scope.dart';
import '../../../../shared/widgets/progress_ring.dart';
import '../../../../shared/widgets/progress_bar_row.dart';
import '../../domain/models/dashboard_data.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  late DashboardData _data;

  @override
  void initState() {
    super.initState();
    _data = _loadDashboardSummary();
  }

  // In-memory summary until a dashboard use case is wired — avoids blocking UI
  // on repo/API; real impl will aggregate from job match + readiness + skill repos (see docs/PRODUCT_NAV.md).
  DashboardData _loadDashboardSummary() {
    return const DashboardData(
      readinessScore: 72,
      skillProgressSummary: [
        SkillProgressItem(name: 'Flutter', proficiencyLevel: 'Advanced', progressPercent: 85),
        SkillProgressItem(name: 'Dart', proficiencyLevel: 'Intermediate', progressPercent: 70),
        SkillProgressItem(name: 'Firebase', proficiencyLevel: 'Intermediate', progressPercent: 60),
        SkillProgressItem(name: 'Clean Architecture', proficiencyLevel: 'Beginner', progressPercent: 40),
        SkillProgressItem(name: 'REST APIs', proficiencyLevel: 'Intermediate', progressPercent: 58),
      ],
      recommendedSkills: ['Riverpod', 'CI/CD', 'REST APIs', 'Testing', 'UI/UX'],
      portfolioCount: 5,
      activeDaysThisWeek: 3,
      nextStepTitle: 'Your next step',
      nextStepBody: 'Add 1 more skill to reach 80% readiness.',
      nextStepActionLabel: 'Add skill',
      jobMatchPercent: 68,
      recentJobMatches: [
        RecentJobMatchItem(title: 'Junior Flutter Developer', matchPercent: 85),
        RecentJobMatchItem(title: 'Mobile Dev Intern', matchPercent: 72),
        RecentJobMatchItem(title: 'Frontend Developer (Junior)', matchPercent: 70),
        RecentJobMatchItem(title: 'Product Design Intern', matchPercent: 61),
        RecentJobMatchItem(title: 'QA Tester (Entry)', matchPercent: 57),
      ],
      learningProgress: [
        LearningProgressItem(title: 'Dart & Flutter basics', progressPercent: 60),
        LearningProgressItem(title: 'Clean Architecture', progressPercent: 30),
        LearningProgressItem(title: 'REST APIs & networking', progressPercent: 45),
        LearningProgressItem(title: 'Testing in Flutter', progressPercent: 20),
        LearningProgressItem(title: 'UI/UX for mobile', progressPercent: 55),
      ],
      notificationCount: 2,
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = AuthScope.of(context).state.user;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.backgroundDark : AppColors.background,
      appBar: AppBar(
        title: Text(
          AppConstants.appName,
          style: TextStyle(
            fontWeight: FontWeight.w700,
            color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
          ),
        ),
        backgroundColor: isDark ? AppColors.surfaceDark : AppColors.surface,
        elevation: 0,
        scrolledUnderElevation: 1,
        actions: [
          IconButton(
            icon: Badge(
              isLabelVisible: _data.notificationCount > 0,
              label: Text('${_data.notificationCount}'),
              child: Icon(Icons.notifications_rounded, color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary),
            ),
            onPressed: () => context.push(router.AppRouter.notifications),
          ),
          IconButton(
            icon: Icon(Icons.logout_rounded, color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary),
            onPressed: () => AuthScope.of(context).signOut(),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          setState(() => _data = _loadDashboardSummary());
        },
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  gradient: isDark
                      ? null
                      : const LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            AppColors.gradientWarmStart,
                            AppColors.background,
                          ],
                        ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _WelcomeHeader(
                      displayName: user?.displayName,
                      isDark: isDark,
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
                      child: _ThisWeekStrip(
                        activeDays: _data.activeDaysThisWeek,
                        isDark: isDark,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
                child: _ReadinessScoreCard(score: _data.readinessScore, isDark: isDark),
              ),
            ),
            if (_data.nextStepTitle != null && _data.nextStepBody != null) ...[
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: _NextStepCard(
                    title: _data.nextStepTitle!,
                    body: _data.nextStepBody!,
                    actionLabel: _data.nextStepActionLabel ?? 'Go',
                    isDark: isDark,
                    onAction: () => context.go(router.AppRouter.skills),
                  ),
                ),
              ),
              const SliverToBoxAdapter(child: SizedBox(height: 16)),
            ],
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: _StatsRow(
                  portfolioCount: _data.portfolioCount,
                  skillsCount: _data.skillsCount,
                  jobMatchPercent: _data.jobMatchPercent,
                  isDark: isDark,
                  onPortfolioTap: () => context.go(router.AppRouter.portfolio),
                  onSkillsTap: () => context.go(router.AppRouter.skills),
                  onJobMatchTap: () => context.push(router.AppRouter.jobBoard),
                ),
              ),
            ),
            if (_data.recentJobMatches.isNotEmpty) ...[
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 24, 20, 8),
                  child: _SectionTitle(title: 'Recent Job Matches', isDark: isDark),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: _RecentJobMatchesCard(
                    items: _data.recentJobMatches,
                    isDark: isDark,
                    onSeeAll: () => context.push(router.AppRouter.jobBoard),
                  ),
                ),
              ),
            ],
            if (_data.learningProgress.isNotEmpty) ...[
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 24, 20, 8),
                  child: _SectionTitle(title: 'Learning Progress', isDark: isDark),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: _LearningProgressCard(
                    items: _data.learningProgress,
                    isDark: isDark,
                    onSeeAll: () => context.push(router.AppRouter.learningHub),
                  ),
                ),
              ),
            ],
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 24, 20, 8),
                child: _SectionTitle(title: 'Skill progress', isDark: isDark),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: _SkillProgressSummaryCard(
                  items: _data.skillProgressSummary,
                  isDark: isDark,
                  onSeeAll: () => context.go(router.AppRouter.skills),
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 24, 20, 8),
                child: _SectionTitle(title: 'Recommended for you', isDark: isDark),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.only(left: 20, bottom: 8),
                child: _RecommendedSkillsList(
                  skills: _data.recommendedSkills,
                  isDark: isDark,
                  onSkillTap: (_) => context.go(router.AppRouter.skills),
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 24, 20, 8),
                child: _SectionTitle(title: 'Quick actions', isDark: isDark),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 32),
                child: _QuickActionsCard(
                  isDark: isDark,
                  onSkills: () => context.go(router.AppRouter.skills),
                  onPortfolio: () => context.go(router.AppRouter.portfolio),
                  onReadiness: () => context.go(router.AppRouter.readiness),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _WelcomeHeader extends StatelessWidget {
  const _WelcomeHeader({this.displayName, required this.isDark});

  final String? displayName;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    final name = displayName?.trim();
    final greeting = name != null && name.isNotEmpty ? 'Hi, $name' : 'Hi there';

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            greeting,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
                ),
          ),
          const SizedBox(height: 4),
          Text(
            AppConstants.appTagline,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary,
                ),
          ),
        ],
      ),
    );
  }
}

/// Habit-style: active days this week (e.g. "Active 3 days" + 7 dots).
class _ThisWeekStrip extends StatelessWidget {
  const _ThisWeekStrip({required this.activeDays, required this.isDark});

  final int activeDays;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    final days = activeDays.clamp(0, 7);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.m, vertical: AppSpacing.s),
      decoration: BoxDecoration(
        color: isDark
            ? AppColors.secondary.withOpacity(0.12)
            : AppColors.secondary.withOpacity(0.08),
        borderRadius: AppRadius.radiusM,
      ),
      child: Row(
        children: [
          Icon(
            Icons.local_fire_department_rounded,
            size: 20,
            color: AppColors.secondary,
          ),
          const SizedBox(width: AppSpacing.s),
          Text(
            days == 0
                ? 'No active days this week yet'
                : 'Active $days day${days == 1 ? '' : 's'} this week',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w500,
                  color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
                ),
          ),
          const Spacer(),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: List.generate(7, (i) {
              final filled = i < days;
              return Container(
                margin: const EdgeInsets.only(left: 2),
                width: 6,
                height: 6,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: filled
                      ? AppColors.secondary
                      : (isDark
                          ? AppColors.textSecondaryDark.withOpacity(0.3)
                          : AppColors.textSecondary.withOpacity(0.3)),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
}

/// Learning-style: one clear next step with a single action.
class _NextStepCard extends StatelessWidget {
  const _NextStepCard({
    required this.title,
    required this.body,
    required this.actionLabel,
    required this.isDark,
    required this.onAction,
  });

  final String title;
  final String body;
  final String actionLabel;
  final bool isDark;
  final VoidCallback onAction;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: isDark ? AppColors.surfaceDark : AppColors.surface,
      borderRadius: AppRadius.radiusL,
      elevation: isDark ? 0 : 1,
      shadowColor: Colors.black.withOpacity(0.06),
      child: InkWell(
        onTap: onAction,
        borderRadius: AppRadius.radiusL,
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.m),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.accentWarm.withOpacity(0.12),
                  borderRadius: AppRadius.radiusM,
                ),
                child: Icon(Icons.arrow_forward_rounded, size: 20, color: AppColors.accentWarm),
              ),
              const SizedBox(width: AppSpacing.m),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
                          ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      body,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary,
                          ),
                    ),
                  ],
                ),
              ),
              FilledButton(
                onPressed: onAction,
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.accentWarm,
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.m),
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: Text(actionLabel),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ReadinessScoreCard extends StatelessWidget {
  const _ReadinessScoreCard({required this.score, required this.isDark});

  final int score;
  final bool isDark;

  @override
  Widget build(BuildContext context) {

    return GestureDetector(
      onTap: () => context.go(router.AppRouter.readiness),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: isDark
                ? [
                    AppColors.primary.withOpacity(0.35),
                    AppColors.primaryDark.withOpacity(0.25),
                  ]
                : [
                    AppColors.primary.withOpacity(0.12),
                    AppColors.primaryLight.withOpacity(0.08),
                  ],
          ),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: AppColors.primary.withOpacity(0.2),
            width: 1,
          ),
        ),
        child: Row(
          children: [
            ProgressRing(value: score, size: 88, strokeWidth: 8),
            const SizedBox(width: AppSpacing.l),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Job readiness',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
                        ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    score >= 70
                        ? 'You\'re in good shape. Keep building skills.'
                        : score >= 40
                            ? 'Add more skills and portfolio items to improve.'
                            : 'Start adding skills and projects to boost your score.',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary,
                        ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios_rounded,
              size: 16,
              color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary,
            ),
          ],
        ),
      ),
    );
  }
}

class _StatsRow extends StatelessWidget {
  const _StatsRow({
    required this.portfolioCount,
    required this.skillsCount,
    required this.isDark,
    required this.onPortfolioTap,
    required this.onSkillsTap,
    this.jobMatchPercent,
    this.onJobMatchTap,
  });

  final int portfolioCount;
  final int skillsCount;
  final bool isDark;
  final VoidCallback onPortfolioTap;
  final VoidCallback onSkillsTap;
  final int? jobMatchPercent;
  final VoidCallback? onJobMatchTap;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _StatCard(
            value: '$portfolioCount',
            label: 'Portfolio items',
            icon: Icons.folder_rounded,
            color: AppColors.secondary,
            isDark: isDark,
            onTap: onPortfolioTap,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _StatCard(
            value: '$skillsCount',
            label: 'Skills',
            icon: Icons.psychology_rounded,
            color: AppColors.primary,
            isDark: isDark,
            onTap: onSkillsTap,
          ),
        ),
        if (jobMatchPercent != null && onJobMatchTap != null) ...[
          const SizedBox(width: 12),
          Expanded(
            child: _StatCard(
              value: '$jobMatchPercent%',
              label: 'Job match',
              icon: Icons.work_rounded,
              color: AppColors.primary,
              isDark: isDark,
              onTap: onJobMatchTap!,
            ),
          ),
        ],
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.value,
    required this.label,
    required this.icon,
    required this.color,
    required this.isDark,
    required this.onTap,
  });

  final String value;
  final String label;
  final IconData icon;
  final Color color;
  final bool isDark;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: isDark ? AppColors.surfaceDark : AppColors.surface,
          borderRadius: AppRadius.radiusL,
      elevation: isDark ? 0 : 1,
      shadowColor: Colors.black.withOpacity(0.06),
      child: InkWell(
        onTap: onTap,
          borderRadius: AppRadius.radiusL,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, size: 22, color: color),
              ),
              const SizedBox(height: 12),
              Text(
                value,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
                    ),
              ),
              const SizedBox(height: 2),
              Text(
                label,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary,
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RecentJobMatchesCard extends StatelessWidget {
  const _RecentJobMatchesCard({required this.items, required this.isDark, required this.onSeeAll});

  final List<RecentJobMatchItem> items;
  final bool isDark;
  final VoidCallback onSeeAll;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: isDark ? AppColors.surfaceDark : AppColors.surface,
      borderRadius: AppRadius.radiusL,
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.m),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ...items.take(2).map((e) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    children: [
                      Expanded(child: Text(e.title, style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary))),
                      Text('${e.matchPercent}% match', style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.primary, fontWeight: FontWeight.w600)),
                    ],
                  ),
                )),
            TextButton(onPressed: onSeeAll, child: const Text('See all jobs')),
          ],
        ),
      ),
    );
  }
}

class _LearningProgressCard extends StatelessWidget {
  const _LearningProgressCard({required this.items, required this.isDark, required this.onSeeAll});

  final List<LearningProgressItem> items;
  final bool isDark;
  final VoidCallback onSeeAll;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: isDark ? AppColors.surfaceDark : AppColors.surface,
      borderRadius: AppRadius.radiusL,
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.m),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ...items.take(2).map((e) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(e.title, style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary)),
                      const SizedBox(height: 4),
                      LinearProgressIndicator(value: e.progressPercent / 100, backgroundColor: AppColors.primary.withOpacity(0.2), valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary)),
                    ],
                  ),
                )),
            TextButton(onPressed: onSeeAll, child: const Text('Learning Hub')),
          ],
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.title, required this.isDark});

  final String title;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
            color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
          ),
    );
  }
}

class _SkillProgressSummaryCard extends StatelessWidget {
  const _SkillProgressSummaryCard({
    required this.items,
    required this.isDark,
    required this.onSeeAll,
  });

  final List<SkillProgressItem> items;
  final bool isDark;
  final VoidCallback onSeeAll;

  @override
  Widget build(BuildContext context) {
    final displayItems = items.take(4).toList();

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : AppColors.surface,
          borderRadius: AppRadius.radiusL,
        border: isDark ? null : Border.all(color: Colors.black.withOpacity(0.06)),
        boxShadow: isDark ? null : [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10, offset: const Offset(0, 2))],
      ),
      child: Column(
        children: [
          if (displayItems.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Text(
                'No skills yet. Add your first skill to see progress here.',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary,
                    ),
              ),
            )
          else ...[
            ...displayItems.map(
              (item) => Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.m),
                child: ProgressBarRow(
                  label: item.name,
                  progressPercent: item.progressPercent,
                  badgeLabel: item.proficiencyLevel,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: TextButton(
                onPressed: onSeeAll,
                child: const Text('See all skills'),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _RecommendedSkillsList extends StatelessWidget {
  const _RecommendedSkillsList({
    required this.skills,
    required this.isDark,
    required this.onSkillTap,
  });

  final List<String> skills;
  final bool isDark;
  final void Function(String skill) onSkillTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 44,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: skills.length,
        separatorBuilder: (_, __) => const SizedBox(width: 10),
        itemBuilder: (context, index) {
          final skill = skills[index];
          return _RecommendedChip(
            label: skill,
            isDark: isDark,
            onTap: () => onSkillTap(skill),
          );
        },
      ),
    );
  }
}

class _RecommendedChip extends StatelessWidget {
  const _RecommendedChip({
    required this.label,
    required this.isDark,
    required this.onTap,
  });

  final String label;
  final bool isDark;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: isDark ? AppColors.surfaceDark : AppColors.surface,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isDark ? AppColors.textSecondaryDark.withOpacity(0.3) : AppColors.textSecondary.withOpacity(0.3),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.add_rounded, size: 18, color: AppColors.secondary),
              const SizedBox(width: 6),
              Text(
                label,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w500,
                      color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _QuickActionsCard extends StatelessWidget {
  const _QuickActionsCard({
    required this.isDark,
    required this.onSkills,
    required this.onPortfolio,
    required this.onReadiness,
  });

  final bool isDark;
  final VoidCallback onSkills;
  final VoidCallback onPortfolio;
  final VoidCallback onReadiness;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : AppColors.surface,
          borderRadius: AppRadius.radiusL,
        border: isDark ? null : Border.all(color: Colors.black.withOpacity(0.06)),
      ),
      child: Column(
        children: [
          _QuickActionTile(
            title: 'Skills',
            subtitle: 'Manage your skills',
            icon: Icons.psychology_rounded,
            color: AppColors.primary,
            isDark: isDark,
            onTap: onSkills,
          ),
          Divider(height: 1, color: isDark ? AppColors.textSecondaryDark.withOpacity(0.2) : AppColors.textSecondary.withOpacity(0.2)),
          _QuickActionTile(
            title: 'Portfolio',
            subtitle: 'Projects & achievements',
            icon: Icons.folder_special_rounded,
            color: AppColors.secondary,
            isDark: isDark,
            onTap: onPortfolio,
          ),
          Divider(height: 1, color: isDark ? AppColors.textSecondaryDark.withOpacity(0.2) : AppColors.textSecondary.withOpacity(0.2)),
          _QuickActionTile(
            title: 'Readiness score',
            subtitle: 'View full breakdown',
            icon: Icons.insights_rounded,
            color: AppColors.primary,
            isDark: isDark,
            onTap: onReadiness,
          ),
        ],
      ),
    );
  }
}

class _QuickActionTile extends StatelessWidget {
  const _QuickActionTile({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.isDark,
    required this.onTap,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final bool isDark;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      leading: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: color.withOpacity(0.12),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(icon, size: 22, color: color),
      ),
      title: Text(
        title,
        style: TextStyle(
          fontWeight: FontWeight.w600,
          color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary,
            ),
      ),
      trailing: Icon(
        Icons.arrow_forward_ios_rounded,
        size: 14,
        color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary,
      ),
    );
  }
}
