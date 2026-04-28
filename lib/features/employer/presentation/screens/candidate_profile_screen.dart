import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/router/app_router.dart' as router;
import '../../../../shared/theme/app_colors.dart';
import '../../../../shared/theme/app_radius.dart';
import '../../../../shared/theme/app_spacing.dart';
import '../../../../shared/theme/app_typography.dart';
import '../../../../shared/widgets/progress_ring.dart';
import '../../data/models/candidate_model.dart';
import '../../domain/repositories/employer_repository.dart';

/// Full candidate view for employer: header, match breakdown, skills radar, portfolio, actions.
class CandidateProfileScreen extends StatefulWidget {
  const CandidateProfileScreen({super.key, required this.applicationId, this.jobId});

  final String applicationId;
  final String? jobId;

  @override
  State<CandidateProfileScreen> createState() => _CandidateProfileScreenState();
}

class _CandidateProfileScreenState extends State<CandidateProfileScreen> {
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
      await _load();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Status: $status')));
      }
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed: $e')));
    } finally {
      if (mounted) setState(() => _updating = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.backgroundDark : AppColors.background,
      appBar: AppBar(
        title: const Text('Candidate profile'),
        leading: IconButton(icon: const Icon(Icons.arrow_back_rounded), onPressed: () => context.pop()),
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
                          _buildMatchBreakdown(_candidate!, isDark),
                          const SizedBox(height: AppSpacing.l),
                          _buildSkillsRadar(_candidate!, isDark),
                          const SizedBox(height: AppSpacing.l),
                          _buildPortfolioSummary(_candidate!, isDark),
                          const SizedBox(height: AppSpacing.s),
                          OutlinedButton.icon(
                            onPressed: () => _openFullPortfolio(),
                            icon: const Icon(Icons.open_in_new_rounded),
                            label: const Text('View Full Portfolio'),
                          ),
                          const SizedBox(height: AppSpacing.xl),
                          _buildActions(isDark),
                        ],
                      ),
                    ),
    );
  }

  Widget _buildHeader(CandidateModel c, bool isDark) {
    final name = c.displayName ?? c.email ?? 'Candidate';
    return Material(
      color: isDark ? AppColors.surfaceDark : AppColors.surface,
      borderRadius: AppRadius.radiusL,
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.m),
        child: Row(
          children: [
            CircleAvatar(
              radius: 36,
              backgroundColor: AppColors.primary.withOpacity(0.2),
              child: Text(
                (name.isNotEmpty ? name[0] : '?').toUpperCase(),
                style: const TextStyle(fontSize: 24, color: AppColors.primary, fontWeight: FontWeight.w600),
              ),
            ),
            const SizedBox(width: AppSpacing.m),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(name, style: AppTypography.h1(context, isDark: isDark)),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.levelBadge.withOpacity(0.2),
                          borderRadius: AppRadius.radiusFull,
                        ),
                        child: Text('Level 2 • Rising Star', style: AppTypography.caption(context, isDark: isDark)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text('Aspiring Developer', style: AppTypography.bodySecondary(context, isDark: isDark)),
                  Text('Nairobi County • Open to work', style: AppTypography.caption(context, isDark: isDark)),
                ],
              ),
            ),
            ProgressRing(
              value: c.skillMatchPercent.clamp(0, 100),
              size: 64,
              strokeWidth: 6,
              foregroundColor: AppColors.matchScoreColor(c.skillMatchPercent),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMatchBreakdown(CandidateModel c, bool isDark) {
    const keys = ['digital-literacy', 'communication', 'business-entrepreneurship', 'technical-ict', 'soft-skills-leadership'];
    const labels = {'digital-literacy': 'Digital Literacy', 'communication': 'Communication', 'business-entrepreneurship': 'Business', 'technical-ict': 'Technical', 'soft-skills-leadership': 'Soft Skills'};
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Why this match?', style: AppTypography.h2(context, isDark: isDark)),
        const SizedBox(height: AppSpacing.s),
        ...keys.map((k) {
          final score = c.categoryScores[k] ?? 0;
          return Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: Row(
              children: [
                SizedBox(width: 120, child: Text(labels[k] ?? k, style: AppTypography.body(context, isDark: isDark))),
                Expanded(
                  child: LinearProgressIndicator(
                    value: score / 100,
                    backgroundColor: AppColors.primary.withOpacity(0.2),
                    valueColor: AlwaysStoppedAnimation<Color>(AppColors.matchScoreColor(score)),
                  ),
                ),
                const SizedBox(width: 8),
                Text('$score%', style: AppTypography.caption(context, isDark: isDark)),
              ],
            ),
          );
        }),
      ],
    );
  }

  Widget _buildSkillsRadar(CandidateModel c, bool isDark) {
    const keys = ['digital-literacy', 'communication', 'business-entrepreneurship', 'technical-ict', 'soft-skills-leadership'];
    const labels = ['Digital', 'Communication', 'Business', 'Technical', 'Soft skills'];
    final values = keys.map((k) => (c.categoryScores[k] ?? 0).toDouble()).toList();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Skills radar', style: AppTypography.h2(context, isDark: isDark)),
        const SizedBox(height: AppSpacing.s),
        SizedBox(
          height: 220,
          child: CustomPaint(
            size: const Size(double.infinity, 200),
            painter: _RadarPainter(values: values, labels: labels, maxValue: 100),
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
        Material(
          color: isDark ? AppColors.surfaceDark : AppColors.surface,
          borderRadius: AppRadius.radiusL,
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.m),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Experience: 1–2 years • Education: BSc CS', style: AppTypography.body(context, isDark: isDark)),
                const SizedBox(height: 4),
                Text(c.portfolioSummary ?? 'No portfolio summary.', style: AppTypography.bodySecondary(context, isDark: isDark)),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _openFullPortfolio() async {
    final c = _candidate;
    if (c == null) return;
    context.push(
      router.AppRouter.employerCandidatePortfolio(c.id),
      extra: {
        'displayName': c.displayName,
        'email': c.email,
        'summary': c.portfolioSummary,
      },
    );
  }

  Widget _buildActions(bool isDark) {
    final status = _candidate?.status ?? 'pending';
    return Row(
      children: [
        if (status != 'shortlisted')
          Expanded(
            child: FilledButton.tonal(
              onPressed: _updating ? null : () => _updateStatus('shortlisted'),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.bookmark_rounded, size: 20),
                  SizedBox(width: 8),
                  Text('Shortlist'),
                ],
              ),
            ),
          ),
        if (status != 'shortlisted') const SizedBox(width: AppSpacing.s),
        if (status != 'interview')
          Expanded(
            child: FilledButton(
              onPressed: _updating ? null : () => _updateStatus('interview'),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.event_rounded, size: 20),
                  SizedBox(width: 8),
                  Text('Move to Interview'),
                ],
              ),
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

class _RadarPainter extends CustomPainter {
  _RadarPainter({required this.values, required this.labels, this.maxValue = 100});
  final List<double> values;
  final List<String> labels;
  final double maxValue;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.shortestSide / 2) * 0.75;
    final n = values.length;
    if (n == 0) return;
    final axisColor = AppColors.textSecondary.withOpacity(0.5);
    final fillColor = AppColors.primary.withOpacity(0.3);
    final strokeColor = AppColors.primary;
    for (var i = 0; i < n; i++) {
      final angle = -i * (2 * math.pi / n) + math.pi / 2;
      final end = Offset(center.dx + radius * math.cos(angle), center.dy - radius * math.sin(angle));
      canvas.drawLine(center, end, Paint()..color = axisColor..strokeWidth = 1);
    }
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
    for (var i = 0; i < n && i < labels.length; i++) {
      final angle = -i * (2 * math.pi / n) + math.pi / 2;
      final labelRadius = radius + 18;
      final x = center.dx + labelRadius * math.cos(angle);
      final y = center.dy - labelRadius * math.sin(angle);
      final span = TextSpan(text: labels[i], style: TextStyle(fontSize: 11, color: AppColors.textPrimary, fontWeight: FontWeight.w500));
      final tp = TextPainter(text: span, textDirection: TextDirection.ltr)..layout();
      tp.paint(canvas, Offset(x - tp.width / 2, y - tp.height / 2));
    }
  }

  @override
  bool shouldRepaint(covariant _RadarPainter old) => old.values != values || old.labels != labels;
}
