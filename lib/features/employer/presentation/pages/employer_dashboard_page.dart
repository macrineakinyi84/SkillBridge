import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/router/app_router.dart' as router;
import '../../../../shared/theme/app_colors.dart';
import '../../../../shared/theme/app_radius.dart';
import '../../../../shared/theme/app_spacing.dart';
import '../../../../shared/theme/app_typography.dart';
import '../../../../shared/widgets/auth_scope.dart';
import '../../data/models/employer_dashboard_model.dart';
import '../../domain/repositories/employer_repository.dart';

/// Employer dashboard: stats cards (active listings, new applicants), recent applicants, quick Post job (S-020).
class EmployerDashboardPage extends StatefulWidget {
  const EmployerDashboardPage({super.key});

  @override
  State<EmployerDashboardPage> createState() => _EmployerDashboardPageState();
}

class _EmployerDashboardPageState extends State<EmployerDashboardPage> {
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
        label: const Text('Post job'),
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

    return CustomScrollView(
      slivers: [
        SliverPadding(
          padding: const EdgeInsets.all(AppSpacing.m),
          sliver: SliverList(
            delegate: SliverChildListDelegate([
              _buildStatCards(data, isDark),
              const SizedBox(height: AppSpacing.xl),
              _buildRecentApplicants(data, isDark),
            ]),
          ),
        ),
      ],
    );
  }

  Widget _buildStatCards(EmployerDashboardModel data, bool isDark) {
    return Row(
      children: [
        Expanded(
          child: _StatCard(
            title: 'Active listings',
            value: '${data.activeListingsCount}',
            icon: Icons.work_rounded,
            isDark: isDark,
            onTap: () => context.push(router.AppRouter.employerListings),
          ),
        ),
        const SizedBox(width: AppSpacing.m),
        Expanded(
          child: _StatCard(
            title: 'New this week',
            value: '${data.newApplicantsThisWeek}',
            icon: Icons.people_rounded,
            isDark: isDark,
            onTap: () => context.push(router.AppRouter.employerListings),
          ),
        ),
      ],
    );
  }

  Widget _buildRecentApplicants(EmployerDashboardModel data, bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
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
          Text(
            'No applications yet. Post a job to get applicants.',
            style: AppTypography.bodySecondary(context, isDark: isDark),
          )
        else
          ...data.recentApplicants.map((a) => Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.s),
                child: Material(
                  color: isDark ? AppColors.surfaceDark : AppColors.surface,
                  borderRadius: AppRadius.radiusL,
                  child: InkWell(
                    borderRadius: AppRadius.radiusL,
                    onTap: () => context.push(
                      router.AppRouter.employerCandidate(a.applicationId),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(AppSpacing.m),
                      child: Row(
                        children: [
                          CircleAvatar(
                            backgroundColor: AppColors.primary.withOpacity(0.2),
                            child: Text(
                              (a.candidateName.isNotEmpty ? a.candidateName[0] : '?').toUpperCase(),
                              style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.w600),
                            ),
                          ),
                          const SizedBox(width: AppSpacing.m),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(a.candidateName, style: AppTypography.body(context, isDark: isDark)),
                                Text(a.jobTitle, style: AppTypography.caption(context, isDark: isDark)),
                              ],
                            ),
                          ),
                          if (a.skillMatchPercent != null)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: AppColors.matchScoreColor(a.skillMatchPercent!).withOpacity(0.2),
                                borderRadius: AppRadius.radiusM,
                              ),
                              child: Text(
                                '${a.skillMatchPercent}%',
                                style: AppTypography.caption(context, isDark: isDark)
                                    .copyWith(color: AppColors.matchScoreColor(a.skillMatchPercent!), fontWeight: FontWeight.w600),
                              ),
                            ),
                          const SizedBox(width: AppSpacing.xs),
                          Icon(Icons.chevron_right_rounded, color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary),
                        ],
                      ),
                    ),
                  ),
                ),
              )),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.isDark,
    required this.onTap,
  });

  final String title;
  final String value;
  final IconData icon;
  final bool isDark;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
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
              Icon(icon, color: AppColors.primary, size: 28),
              const SizedBox(height: AppSpacing.s),
              Text(value, style: AppTypography.display(context, isDark: isDark)),
              Text(title, style: AppTypography.caption(context, isDark: isDark)),
            ],
          ),
        ),
      ),
    );
  }
}
