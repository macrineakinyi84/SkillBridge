import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/router/app_router.dart' as router;
import '../../../../shared/theme/app_colors.dart';
import '../../../../shared/theme/app_radius.dart';
import '../../../../shared/theme/app_spacing.dart';
import '../../../../shared/theme/app_typography.dart';
import '../../../../shared/widgets/auth_scope.dart';
import '../../../../shared/widgets/progress_ring.dart';
import '../../data/models/employer_dashboard_model.dart';
import '../../domain/repositories/employer_repository.dart';

/// Employer dashboard: recruiter-focused only. Active listings, new applicants this week, recent applicants feed with actions.
/// No career health score or skills radar — students see those on their dashboard.
class EmployerDashboardScreen extends StatefulWidget {
  const EmployerDashboardScreen({super.key});

  @override
  State<EmployerDashboardScreen> createState() => _EmployerDashboardScreenState();
}

class _EmployerDashboardScreenState extends State<EmployerDashboardScreen> {
  final EmployerRepository _repo = sl<EmployerRepository>();
  EmployerDashboardModel? _data;
  bool _loading = true;
  String? _error;

  String get _employerId => AuthScope.maybeOf(context)?.state.user?.id ?? '';

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    if (_employerId.isEmpty) {
      setState(() => _loading = false);
      return;
    }
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final data = await _repo.getDashboard(_employerId);
      if (mounted) setState(() {
        _data = data;
        _loading = false;
      });
    } catch (e) {
      if (mounted) setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.backgroundDark : AppColors.background,
      appBar: AppBar(
        title: Text(
          'Employer Dashboard',
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
            icon: Icon(Icons.logout_rounded, color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary),
            onPressed: () => AuthScope.of(context).signOut(),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _load,
        child: _buildBody(isDark),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push(router.AppRouter.employerPostJob),
        icon: const Icon(Icons.add_rounded),
        label: const Text('Post New Job'),
        backgroundColor: AppColors.primary,
      ),
    );
  }

  Widget _buildBody(bool isDark) {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.l),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(_error!, style: AppTypography.body(context, isDark: isDark), textAlign: TextAlign.center),
              const SizedBox(height: AppSpacing.m),
              FilledButton(onPressed: _load, child: const Text('Retry')),
            ],
          ),
        ),
      );
    }
    final data = _data;
    if (data == null) {
      return const Center(child: Text('Sign in to see your dashboard'));
    }

    return ListView(
      padding: const EdgeInsets.all(AppSpacing.m),
      children: [
        if (data.newMatchesNotification != null && data.newMatchesNotification!.isNotEmpty) ...[
          _NotificationBanner(message: data.newMatchesNotification!, isDark: isDark),
          const SizedBox(height: AppSpacing.m),
        ],
        _buildStatsRow(data, isDark),
        const SizedBox(height: AppSpacing.l),
        SizedBox(
          width: double.infinity,
          child: FilledButton.icon(
            onPressed: () => context.push(router.AppRouter.employerPostJob),
            icon: const Icon(Icons.add_rounded),
            label: const Text('Post New Job'),
            style: FilledButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: AppSpacing.m),
              backgroundColor: AppColors.primary,
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.xl),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Recent applicants', style: AppTypography.h2(context, isDark: isDark)),
            if (data.recentApplicants.isNotEmpty)
              TextButton(
                onPressed: () => context.push(router.AppRouter.employerListings),
                child: const Text('View all'),
              ),
          ],
        ),
        const SizedBox(height: AppSpacing.s),
        if (data.recentApplicants.isEmpty)
          Padding(
            padding: const EdgeInsets.all(AppSpacing.l),
            child: Text(
              'No applications yet. Post a job to get applicants.',
              style: AppTypography.bodySecondary(context, isDark: isDark),
            ),
          )
        else
          ...data.recentApplicants.take(5).map((a) => _RecentApplicantCard(
                item: a,
                isDark: isDark,
                onTap: () => context.push(router.AppRouter.employerCandidate(a.applicationId)),
              )),
      ],
    );
  }

  Widget _buildStatsRow(EmployerDashboardModel data, bool isDark) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(child: _StatCard(title: 'Active Jobs', value: '${data.activeListingsCount}', icon: Icons.work_rounded, isDark: isDark)),
            const SizedBox(width: AppSpacing.s),
            Expanded(child: _StatCard(title: 'Total Applicants', value: '${data.totalApplicantsCount}', icon: Icons.people_rounded, isDark: isDark)),
          ],
        ),
        const SizedBox(height: AppSpacing.s),
        Row(
          children: [
            Expanded(child: _StatCard(title: 'New This Week', value: '${data.newApplicantsThisWeek}', icon: Icons.trending_up_rounded, isDark: isDark)),
            const SizedBox(width: AppSpacing.s),
            Expanded(child: _StatCard(title: 'Avg Match', value: '${data.avgMatchScore.round()}%', icon: Icons.percent_rounded, isDark: isDark)),
          ],
        ),
      ],
    );
  }
}

class _NotificationBanner extends StatelessWidget {
  const _NotificationBanner({required this.message, required this.isDark});
  final String message;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.primary.withOpacity(0.12),
      borderRadius: AppRadius.radiusL,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.m, vertical: AppSpacing.s),
        child: Row(
          children: [
            Icon(Icons.notifications_active_rounded, color: AppColors.primary, size: 24),
            const SizedBox(width: AppSpacing.s),
            Expanded(child: Text(message, style: AppTypography.body(context, isDark: isDark))),
          ],
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({required this.title, required this.value, required this.icon, required this.isDark});
  final String title;
  final String value;
  final IconData icon;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: isDark ? AppColors.surfaceDark : AppColors.surface,
      borderRadius: AppRadius.radiusL,
      child: InkWell(
        borderRadius: AppRadius.radiusL,
        onTap: () => context.push(router.AppRouter.employerListings),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.m),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, color: AppColors.primary, size: 26),
              const SizedBox(height: AppSpacing.s),
              Text(value, style: AppTypography.display(context, isDark: isDark).copyWith(fontSize: 22)),
              Text(title, style: AppTypography.caption(context, isDark: isDark)),
            ],
          ),
        ),
      ),
    );
  }
}

class _RecentApplicantCard extends StatelessWidget {
  const _RecentApplicantCard({required this.item, required this.isDark, required this.onTap});
  final RecentApplicantItem item;
  final bool isDark;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final percent = item.skillMatchPercent ?? 0;
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.s),
      child: Material(
        color: isDark ? AppColors.surfaceDark : AppColors.surface,
        borderRadius: AppRadius.radiusL,
        child: InkWell(
          borderRadius: AppRadius.radiusL,
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.m),
            child: Row(
              children: [
                ProgressRing(
                  value: percent.clamp(0, 100),
                  size: 52,
                  strokeWidth: 6,
                  foregroundColor: AppColors.matchScoreColor(percent),
                  backgroundColor: AppColors.matchScoreColor(percent).withOpacity(0.2),
                ),
                const SizedBox(width: AppSpacing.m),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(item.candidateName, style: AppTypography.body(context, isDark: isDark).copyWith(fontWeight: FontWeight.w600)),
                      Text(item.jobTitle, style: AppTypography.caption(context, isDark: isDark)),
                    ],
                  ),
                ),
                Icon(Icons.chevron_right_rounded, color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
