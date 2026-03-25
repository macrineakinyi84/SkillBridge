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
import '../../data/models/application_model.dart';
import '../../data/models/candidate_model.dart';
import '../../data/models/job_listing_model.dart';
import '../../domain/repositories/employer_repository.dart';

/// Kanban board for a job's applications. Columns by stage; drag-and-drop to move.
class TalentPipelineScreen extends StatefulWidget {
  const TalentPipelineScreen({super.key, required this.jobId});

  final String jobId;

  @override
  State<TalentPipelineScreen> createState() => _TalentPipelineScreenState();
}

class _TalentPipelineScreenState extends State<TalentPipelineScreen> {
  final EmployerRepository _repo = sl<EmployerRepository>();
  JobListingModel? _job;
  List<CandidateModel> _candidates = [];
  bool _loading = true;
  String? _error;
  bool _loadStarted = false;

  static const _stages = ['pending', 'shortlisted', 'interview', 'rejected'];
  static const _stageLabels = {'pending': 'Applied', 'shortlisted': 'Shortlisted', 'interview': 'Interview', 'rejected': 'Rejected'};

  @override
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_loadStarted) {
      _loadStarted = true;
      _load();
    }
  }

  Future<void> _load() async {
    final employerId = AuthScope.maybeOf(context)?.state.user?.id ?? 'mock';
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final listings = await _repo.getListings(employerId);
      JobListingModel? job;
      for (final l in listings) {
        if (l.id == widget.jobId) {
          job = l;
          break;
        }
      }
      final candidates = await _repo.getCandidatesByJob(widget.jobId);
      if (mounted) setState(() {
        _job = job;
        _candidates = candidates;
        _loading = false;
      });
    } catch (e) {
      if (mounted) setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  List<CandidateModel> _byStage(String status) =>
      _candidates.where((c) => c.status == status).toList();

  Future<void> _moveToStage(String applicationId, String newStatus) async {
    await _repo.updateApplicationStatus(applicationId, newStatus);
    await _load();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.backgroundDark : AppColors.background,
      appBar: AppBar(
        title: Text(_job?.title ?? 'Pipeline'),
        leading: IconButton(icon: const Icon(Icons.arrow_back_rounded), onPressed: () => context.pop()),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [Text(_error!), FilledButton(onPressed: _load, child: const Text('Retry'))]))
              : _buildKanban(isDark),
    );
  }

  Widget _buildKanban(bool isDark) {
    return Column(
      children: [
        Expanded(
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.all(AppSpacing.m),
            children: _stages.map((stage) => _PipelineColumn(
              stage: stage,
              label: _stageLabels[stage]!,
              candidates: _byStage(stage),
              isDark: isDark,
              onTapCard: (c) => context.push(router.AppRouter.employerCandidate(c.applicationId)),
              onMoveToStage: _moveToStage,
              onLongPress: (c) => _showQuickActions(context, c, isDark),
            )).toList(),
          ),
        ),
      ],
    );
  }

  void _showQuickActions(BuildContext context, CandidateModel c, bool isDark) {
    showModalBottomSheet(
      context: context,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.check_circle_rounded),
              title: const Text('Shortlist'),
              onTap: () {
                Navigator.pop(ctx);
                _moveToStage(c.applicationId, 'shortlisted');
              },
            ),
            ListTile(
              leading: const Icon(Icons.event_rounded),
              title: const Text('Move to Interview'),
              onTap: () {
                Navigator.pop(ctx);
                _moveToStage(c.applicationId, 'interview');
              },
            ),
            ListTile(
              leading: Icon(Icons.cancel_rounded, color: AppColors.error),
              title: const Text('Reject'),
              onTap: () {
                Navigator.pop(ctx);
                _moveToStage(c.applicationId, 'rejected');
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _PipelineColumn extends StatelessWidget {
  const _PipelineColumn({
    required this.stage,
    required this.label,
    required this.candidates,
    required this.isDark,
    required this.onTapCard,
    required this.onMoveToStage,
    required this.onLongPress,
  });

  final String stage;
  final String label;
  final List<CandidateModel> candidates;
  final bool isDark;
  final ValueChanged<CandidateModel> onTapCard;
  final Future<void> Function(String applicationId, String newStatus) onMoveToStage;
  final ValueChanged<CandidateModel> onLongPress;

  @override
  Widget build(BuildContext context) {
    return DragTarget<String>(
      onAcceptWithDetails: (d) async {
        final applicationId = d.data;
        await onMoveToStage(applicationId, stage);
      },
      builder: (context, candidateData, __) {
        return Container(
          width: 280,
          margin: const EdgeInsets.only(right: AppSpacing.m),
          decoration: BoxDecoration(
            color: isDark ? AppColors.surfaceDark : AppColors.surface,
            borderRadius: AppRadius.radiusL,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.all(AppSpacing.m),
                child: Row(
                  children: [
                    Text(label, style: AppTypography.h2(context, isDark: isDark)),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.2),
                        borderRadius: AppRadius.radiusFull,
                      ),
                      child: Text('${candidates.length}', style: AppTypography.caption(context, isDark: isDark).copyWith(fontWeight: FontWeight.w600)),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.s, vertical: 0),
                  itemCount: candidates.length,
                  itemBuilder: (context, i) {
                    final c = candidates[i];
                    return _PipelineCard(
                      candidate: c,
                      isDark: isDark,
                      onTap: () => onTapCard(c),
                      onLongPress: () => onLongPress(c),
                      onMoveToStage: onMoveToStage,
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _PipelineCard extends StatelessWidget {
  const _PipelineCard({
    required this.candidate,
    required this.isDark,
    required this.onTap,
    required this.onLongPress,
    required this.onMoveToStage,
  });

  final CandidateModel candidate;
  final bool isDark;
  final VoidCallback onTap;
  final VoidCallback onLongPress;
  final Future<void> Function(String applicationId, String newStatus) onMoveToStage;

  @override
  Widget build(BuildContext context) {
    final appliedDate = ''; // We don't have appliedAt on CandidateModel in the list; could extend.
    return Draggable<String>(
      data: candidate.applicationId,
      feedback: Material(
        elevation: 4,
        borderRadius: AppRadius.radiusL,
        child: SizedBox(
          width: 260,
          child: _CardContent(candidate: candidate, isDark: isDark, appliedDate: appliedDate),
        ),
      ),
      childWhenDragging: Opacity(
        opacity: 0.5,
        child: _CardContent(candidate: candidate, isDark: isDark, appliedDate: appliedDate),
      ),
      child: Padding(
        padding: const EdgeInsets.only(bottom: AppSpacing.s),
        child: Material(
          color: isDark ? AppColors.backgroundDark : AppColors.background,
          borderRadius: AppRadius.radiusL,
          child: InkWell(
            borderRadius: AppRadius.radiusL,
            onTap: onTap,
            onLongPress: onLongPress,
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.s),
              child: _CardContent(candidate: candidate, isDark: isDark, appliedDate: appliedDate),
            ),
          ),
        ),
      ),
    );
  }
}

class _CardContent extends StatelessWidget {
  const _CardContent({required this.candidate, required this.isDark, required this.appliedDate});
  final CandidateModel candidate;
  final bool isDark;
  final String appliedDate;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        ProgressRing(
          value: candidate.skillMatchPercent.clamp(0, 100),
          size: 44,
          strokeWidth: 5,
          foregroundColor: AppColors.matchScoreColor(candidate.skillMatchPercent),
        ),
        const SizedBox(width: AppSpacing.s),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(candidate.displayName ?? 'Candidate', style: AppTypography.body(context, isDark: isDark).copyWith(fontWeight: FontWeight.w600), maxLines: 1, overflow: TextOverflow.ellipsis),
              if (appliedDate.isNotEmpty) Text(appliedDate, style: AppTypography.caption(context, isDark: isDark)),
            ],
          ),
        ),
      ],
    );
  }
}
