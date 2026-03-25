import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/router/app_router.dart' as router;
import '../../../../shared/theme/app_colors.dart';
import '../../../../shared/theme/app_radius.dart';
import '../../../../shared/theme/app_spacing.dart';
import '../../../../shared/theme/app_typography.dart';
import '../../data/models/candidate_model.dart';
import '../../domain/repositories/employer_repository.dart';

/// List of applicants for a job with skill match scores; tap to open CandidateProfilePage (S-022).
class CandidateProfileListPage extends StatefulWidget {
  const CandidateProfileListPage({super.key, required this.jobId});

  final String jobId;

  @override
  State<CandidateProfileListPage> createState() => _CandidateProfileListPageState();
}

class _CandidateProfileListPageState extends State<CandidateProfileListPage> {
  final EmployerRepository _repo = sl<EmployerRepository>();
  List<CandidateModel> _candidates = [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final list = await _repo.getCandidatesByJob(widget.jobId);
      if (mounted) setState(() {
        _candidates = list;
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
          'Candidates',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => context.pop(),
        ),
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
    if (_candidates.isEmpty) {
      return Center(
        child: Text(
          'No applicants yet for this job.',
          style: AppTypography.bodySecondary(context, isDark: isDark),
        ),
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.all(AppSpacing.m),
      itemCount: _candidates.length,
      itemBuilder: (context, index) {
        final c = _candidates[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: AppSpacing.s),
          child: Material(
            color: isDark ? AppColors.surfaceDark : AppColors.surface,
            borderRadius: AppRadius.radiusL,
            child: InkWell(
              borderRadius: AppRadius.radiusL,
              onTap: () => context.push(router.AppRouter.employerCandidate(c.applicationId)),
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.m),
                child: Row(
                  children: [
                    CircleAvatar(
                      backgroundColor: AppColors.primary.withOpacity(0.2),
                      child: Text(
                        ((c.displayName ?? c.email ?? '?').isNotEmpty ? (c.displayName ?? c.email ?? '?')[0] : '?').toUpperCase(),
                        style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.w600),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.m),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(c.displayName ?? c.email ?? 'Applicant', style: AppTypography.body(context, isDark: isDark)),
                          Text('Match: ${c.skillMatchPercent}%', style: AppTypography.caption(context, isDark: isDark)),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.matchScoreColor(c.skillMatchPercent).withOpacity(0.2),
                        borderRadius: AppRadius.radiusM,
                      ),
                      child: Text(
                        '${c.skillMatchPercent}%',
                        style: TextStyle(
                          color: AppColors.matchScoreColor(c.skillMatchPercent),
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                        ),
                      ),
                    ),
                    const Icon(Icons.chevron_right_rounded),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

/// Single candidate profile: radar chart, portfolio summary, accept/reject/shortlist (S-023).
class CandidateProfilePage extends StatefulWidget {
  const CandidateProfilePage({super.key, required this.applicationId});

  final String applicationId;

  @override
  State<CandidateProfilePage> createState() => _CandidateProfilePageState();
}

class _CandidateProfilePageState extends State<CandidateProfilePage> {
  final EmployerRepository _repo = sl<EmployerRepository>();
  CandidateModel? _candidate;
  bool _loading = true;
  String? _error;
  bool _updating = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final c = await _repo.getCandidateByApplicationId(widget.applicationId);
      if (mounted) setState(() {
        _candidate = c;
        _loading = false;
      });
    } catch (e) {
      if (mounted) setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  Future<void> _updateStatus(String status) async {
    setState(() => _updating = true);
    try {
      await _repo.updateApplicationStatus(widget.applicationId, status);
      if (mounted) {
        setState(() {
          _candidate = _candidate != null
              ? CandidateModel(
                  id: _candidate!.id,
                  applicationId: _candidate!.applicationId,
                  displayName: _candidate!.displayName,
                  email: _candidate!.email,
                  skillMatchPercent: _candidate!.skillMatchPercent,
                  categoryScores: _candidate!.categoryScores,
                  portfolioSummary: _candidate!.portfolioSummary,
                  status: status,
                )
              : null;
          _updating = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Status: $status')));
      }
    } catch (e) {
      if (mounted) {
        setState(() => _updating = false);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.backgroundDark : AppColors.background,
      appBar: AppBar(
        title: Text(
          'Candidate profile',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => context.pop(),
        ),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(
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
                )
              : _candidate == null
                  ? const Center(child: Text('Candidate not found'))
                  : SingleChildScrollView(
                      padding: const EdgeInsets.all(AppSpacing.m),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildHeader(_candidate!, isDark),
                          const SizedBox(height: AppSpacing.l),
                          _buildRadarChart(_candidate!, isDark),
                          const SizedBox(height: AppSpacing.l),
                          _buildPortfolioSummary(_candidate!, isDark),
                          const SizedBox(height: AppSpacing.xl),
                          _buildActions(isDark),
                        ],
                      ),
                    ),
    );
  }

  Widget _buildHeader(CandidateModel c, bool isDark) {
    return Row(
      children: [
        CircleAvatar(
          radius: 32,
          backgroundColor: AppColors.primary.withOpacity(0.2),
          child: Text(
            ((c.displayName ?? c.email ?? '?').isNotEmpty ? (c.displayName ?? c.email ?? '?')[0] : '?').toUpperCase(),
            style: const TextStyle(fontSize: 24, color: AppColors.primary, fontWeight: FontWeight.w600),
          ),
        ),
        const SizedBox(width: AppSpacing.m),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(c.displayName ?? c.email ?? 'Applicant', style: AppTypography.h1(context, isDark: isDark)),
              if (c.email != null) Text(c.email!, style: AppTypography.caption(context, isDark: isDark)),
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.matchScoreColor(c.skillMatchPercent).withOpacity(0.2),
                  borderRadius: AppRadius.radiusM,
                ),
                child: Text(
                  '${c.skillMatchPercent}% match',
                  style: TextStyle(color: AppColors.matchScoreColor(c.skillMatchPercent), fontWeight: FontWeight.w600, fontSize: 13),
                ),
              ),
              if (c.status != 'pending')
                Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text('Status: ${c.status}', style: AppTypography.caption(context, isDark: isDark)),
                ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildRadarChart(CandidateModel c, bool isDark) {
    const labels = [
      'Digital',
      'Communication',
      'Business',
      'Technical',
      'Soft skills',
    ];
    final keys = ['digital-literacy', 'communication', 'business-entrepreneurship', 'technical-ict', 'soft-skills-leadership'];
    final values = keys.map((k) => (c.categoryScores[k] ?? 0).toDouble()).toList();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Skill profile', style: AppTypography.h2(context, isDark: isDark)),
        const SizedBox(height: AppSpacing.s),
        SizedBox(
          height: 220,
          child: RadarChartWidget(
            values: values,
            labels: labels,
            maxValue: 100,
          ),
        ),
      ],
    );
  }

  Widget _buildPortfolioSummary(CandidateModel c, bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Portfolio summary', style: AppTypography.h2(context, isDark: isDark)),
        const SizedBox(height: AppSpacing.s),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(AppSpacing.m),
          decoration: BoxDecoration(
            color: isDark ? AppColors.surfaceDark : AppColors.surface,
            borderRadius: AppRadius.radiusL,
          ),
          child: Text(
            c.portfolioSummary ?? 'No portfolio summary.',
            style: AppTypography.body(context, isDark: isDark),
          ),
        ),
      ],
    );
  }

  Widget _buildActions(bool isDark) {
    final status = _candidate?.status ?? 'pending';
    return Row(
      children: [
        if (status != 'shortlisted')
          Expanded(
            child: OutlinedButton.icon(
              onPressed: _updating ? null : () => _updateStatus('shortlisted'),
              icon: const Icon(Icons.bookmark_rounded, size: 20),
              label: const Text('Shortlist'),
            ),
          ),
        if (status != 'shortlisted') const SizedBox(width: AppSpacing.s),
        if (status != 'accepted')
          Expanded(
            child: FilledButton.icon(
              onPressed: _updating ? null : () => _updateStatus('accepted'),
              icon: const Icon(Icons.check_rounded, size: 20),
              label: const Text('Accept'),
              style: FilledButton.styleFrom(backgroundColor: AppColors.success),
            ),
          ),
        const SizedBox(width: AppSpacing.s),
        if (status != 'rejected')
          Expanded(
            child: OutlinedButton.icon(
              onPressed: _updating ? null : () => _updateStatus('rejected'),
              icon: const Icon(Icons.close_rounded, size: 20),
              label: const Text('Reject'),
              style: OutlinedButton.styleFrom(foregroundColor: AppColors.error),
            ),
          ),
      ],
    );
  }
}

/// Simple radar chart: 5 axes, polygon from 0–100 values.
class RadarChartWidget extends StatelessWidget {
  const RadarChartWidget({
    super.key,
    required this.values,
    required this.labels,
    this.maxValue = 100,
  });

  final List<double> values;
  final List<String> labels;
  final double maxValue;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: const Size(double.infinity, 200),
      painter: _RadarChartPainter(
        values: values,
        labels: labels,
        maxValue: maxValue,
      ),
    );
  }
}

class _RadarChartPainter extends CustomPainter {
  _RadarChartPainter({
    required this.values,
    required this.labels,
    required this.maxValue,
  });

  final List<double> values;
  final List<String> labels;
  final double maxValue;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.shortestSide / 2) * 0.75;
    final n = values.length;
    if (n == 0) return;

    final isDark = false; // could pass from theme
    final axisColor = AppColors.textSecondary.withOpacity(0.5);
    final fillColor = AppColors.primary.withOpacity(0.3);
    final strokeColor = AppColors.primary;
    final labelColor = AppColors.textPrimary;

    // Axes and grid
    for (var i = 0; i < n; i++) {
      final angle = -i * (2 * math.pi / n) + math.pi / 2;
      final end = Offset(center.dx + radius * math.cos(angle), center.dy - radius * math.sin(angle));
      final paint = Paint()
        ..color = axisColor
        ..strokeWidth = 1;
      canvas.drawLine(center, end, paint);
    }

    // Data polygon
    final path = Path();
    for (var i = 0; i < n; i++) {
      final angle = -i * (2 * math.pi / n) + math.pi / 2;
      final r = radius * (values[i].clamp(0.0, maxValue) / maxValue);
      final pt = Offset(center.dx + r * math.cos(angle), center.dy - r * math.sin(angle));
      if (i == 0) path.moveTo(pt.dx, pt.dy);
      else path.lineTo(pt.dx, pt.dy);
    }
    path.close();
    canvas.drawPath(path, Paint()..color = fillColor..style = PaintingStyle.fill);
    canvas.drawPath(path, Paint()..color = strokeColor..style = PaintingStyle.stroke..strokeWidth = 2);

    // Labels (simplified: at axis end)
    for (var i = 0; i < n && i < labels.length; i++) {
      final angle = -i * (2 * math.pi / n) + math.pi / 2;
      final labelRadius = radius + 18;
      final x = center.dx + labelRadius * math.cos(angle);
      final y = center.dy - labelRadius * math.sin(angle);
      _drawText(canvas, labels[i], x, y, labelColor);
    }
  }

  void _drawText(Canvas canvas, String text, double x, double y, Color color) {
    final span = TextSpan(text: text, style: TextStyle(fontSize: 11, color: color, fontWeight: FontWeight.w500));
    final tp = TextPainter(text: span, textDirection: TextDirection.ltr)..layout();
    tp.paint(canvas, Offset(x - tp.width / 2, y - tp.height / 2));
  }

  @override
  bool shouldRepaint(covariant _RadarChartPainter old) =>
      old.values != values || old.labels != labels || old.maxValue != maxValue;
}
