import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/router/app_router.dart' as router;
import '../../../../core/utils/date_helpers.dart' show formatDisplayDate;
import '../../../../shared/theme/app_colors.dart';
import '../../../../shared/theme/app_radius.dart';
import '../../../../shared/theme/app_spacing.dart';
import '../../../../shared/theme/app_typography.dart';
import '../../../../shared/widgets/auth_scope.dart';
import '../../../../shared/widgets/empty_state.dart';
import '../../data/models/job_listing_model.dart';
import '../../domain/repositories/employer_repository.dart';

/// Manage listings: list of jobs with edit/close actions (S-021).
class ManageListingsPage extends StatefulWidget {
  const ManageListingsPage({super.key});

  @override
  State<ManageListingsPage> createState() => _ManageListingsPageState();
}

class _ManageListingsPageState extends State<ManageListingsPage> {
  final EmployerRepository _repo = sl<EmployerRepository>();
  List<JobListingModel> _listings = [];
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
      final list = await _repo.getListings(_employerId);
      if (mounted) setState(() {
        _listings = list;
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
          'My job listings',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
          ),
        ),
        backgroundColor: isDark ? AppColors.surfaceDark : AppColors.surface,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => context.go(router.AppRouter.employerDashboard),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_rounded),
            onPressed: () => context.push(router.AppRouter.employerPostJob),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _load,
        child: _buildBody(isDark),
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
    if (_listings.isEmpty) {
      return EmptyState(
        headline: 'No job listings yet',
        body: 'Post your first job to start receiving applications.',
        actionLabel: 'Post job',
        onAction: () => context.push(router.AppRouter.employerPostJob),
        icon: Icons.work_rounded,
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.all(AppSpacing.m),
      itemCount: _listings.length,
      itemBuilder: (context, index) {
        final job = _listings[index];
        return _JobListingTile(
          job: job,
          isDark: isDark,
          onEdit: () => context.push(router.AppRouter.employerPostJobEdit(job.id)),
          onViewCandidates: () => context.push(router.AppRouter.employerCandidates(job.id)),
          onClose: () => _showCloseConfirm(context, job, isDark),
        );
      },
    );
  }

  void _showCloseConfirm(BuildContext context, JobListingModel job, bool isDark) {
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Close listing?'),
        content: Text('"${job.title}" will no longer accept new applications.'),
        actions: [
          TextButton(onPressed: () => Navigator.of(ctx).pop(), child: const Text('Cancel')),
          FilledButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              _closeListing(job.id);
            },
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Future<void> _closeListing(String id) async {
    // Mock: we don't have PATCH listing in repo yet; in real API we'd call close listing.
    // For now just refresh so UI is consistent; mock datasource doesn't support close.
    await _load();
  }
}

class _JobListingTile extends StatelessWidget {
  const _JobListingTile({
    required this.job,
    required this.isDark,
    required this.onEdit,
    required this.onViewCandidates,
    required this.onClose,
  });

  final JobListingModel job;
  final bool isDark;
  final VoidCallback onEdit;
  final VoidCallback onViewCandidates;
  final VoidCallback onClose;

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
              Row(
                children: [
                  Expanded(
                    child: Text(job.title, style: AppTypography.h2(context, isDark: isDark)),
                  ),
                  if (!job.isActive)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.textSecondary.withOpacity(0.2),
                        borderRadius: AppRadius.radiusM,
                      ),
                      child: Text('Closed', style: AppTypography.caption(context, isDark: isDark)),
                    ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                '${job.county} • ${job.type} • Deadline ${formatDisplayDate(job.deadline)}',
                style: AppTypography.caption(context, isDark: isDark),
              ),
              const SizedBox(height: AppSpacing.m),
              Row(
                children: [
                  TextButton.icon(
                    onPressed: onViewCandidates,
                    icon: const Icon(Icons.people_rounded, size: 18),
                    label: const Text('Candidates'),
                  ),
                  TextButton.icon(
                    onPressed: job.isActive ? onEdit : null,
                    icon: const Icon(Icons.edit_rounded, size: 18),
                    label: const Text('Edit'),
                  ),
                  if (job.isActive)
                    TextButton.icon(
                      onPressed: onClose,
                      icon: const Icon(Icons.close_rounded, size: 18),
                      label: const Text('Close'),
                      style: TextButton.styleFrom(foregroundColor: AppColors.error),
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
