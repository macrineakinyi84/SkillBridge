import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/network/backend_api_client.dart';
import '../../../../shared/theme/app_colors.dart';
import '../../../../shared/theme/app_radius.dart';
import '../../../../shared/theme/app_spacing.dart';
import '../../../../shared/widgets/progress_ring.dart';

/// Read-only candidate profile for employers (from talent pool). Fetches GET /api/employer/candidates/:userId.
/// No edit controls; radar chart, match breakdown, portfolio summary. Pipeline actions only if applied to a job.
class CandidateProfileByUserIdScreen extends StatefulWidget {
  const CandidateProfileByUserIdScreen({super.key, required this.userId});

  final String userId;

  @override
  State<CandidateProfileByUserIdScreen> createState() => _CandidateProfileByUserIdScreenState();
}

class _CandidateProfileByUserIdScreenState extends State<CandidateProfileByUserIdScreen> {
  final BackendApiClient _api = sl<BackendApiClient>();
  Map<String, dynamic>? _data;
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
      final res = await _api.get('/api/employer/candidates/${widget.userId}');
      final data = res['data'] as Map<String, dynamic>?;
      if (mounted) setState(() {
        _data = data;
        _loading = false;
      });
    } catch (e) {
      final raw = e.toString();
      final friendly = raw.contains('(404)') || raw.toLowerCase().contains('candidate not found')
          ? 'This candidate profile is not available yet. Use Talent Pool to open candidates with complete profiles.'
          : raw;
      if (mounted) setState(() {
        _error = friendly;
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
                        Text(_error!, textAlign: TextAlign.center),
                        const SizedBox(height: AppSpacing.m),
                        Wrap(
                          spacing: AppSpacing.s,
                          runSpacing: AppSpacing.s,
                          alignment: WrapAlignment.center,
                          children: [
                            FilledButton(onPressed: _load, child: const Text('Retry')),
                            OutlinedButton(
                              onPressed: () => context.pop(),
                              child: const Text('Back'),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                )
              : _data == null
                  ? const Center(child: Text('Candidate not found'))
                  : _buildContent(isDark),
    );
  }

  Widget _buildContent(bool isDark) {
    final d = _data!;
    final name = d['displayName'] as String? ?? 'Candidate';
    final email = d['email'] as String?;
    final county = d['county'] as String?;
    final level = d['level'] as int? ?? 0;
    final levelName = d['levelName'] as String?;
    final totalXp = d['totalXp'] as int? ?? 0;
    final avgScore = d['averageScore'] as int?;
    final skillScores = (d['skillScores'] as List?)?.cast<Map<String, dynamic>>() ?? [];
    final assessmentCount = d['assessmentCount'] as int? ?? 0;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.m),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(name, county, level, levelName, totalXp, avgScore, isDark),
          const SizedBox(height: AppSpacing.l),
          if (skillScores.isNotEmpty) ...[
            _buildMatchBreakdown(skillScores, isDark),
            const SizedBox(height: AppSpacing.l),
            _buildRadar(skillScores, isDark),
            const SizedBox(height: AppSpacing.l),
          ],
          Text('Assessments: $assessmentCount completed', style: Theme.of(context).textTheme.bodySmall),
          const SizedBox(height: AppSpacing.xl),
          if (email != null && email.isNotEmpty)
            FilledButton.icon(
              onPressed: () async {
                final uri = Uri(
                  scheme: 'mailto',
                  path: email,
                  query: Uri.encodeQueryComponent('subject=Opportunity from SkillBridge&body=Hi $name,%0D%0A%0D%0AI saw your SkillBridge profile and would like to connect about an opportunity.'),
                );
                if (await canLaunchUrl(uri)) {
                  await launchUrl(uri, mode: LaunchMode.externalApplication);
                }
              },
              icon: const Icon(Icons.email_rounded, size: 20),
              label: const Text('Contact'),
            ),
        ],
      ),
    );
  }

  Widget _buildHeader(String name, String? county, int level, String? levelName, int totalXp, int? avgScore, bool isDark) {
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
                  Text(name, style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700)),
                  if (county != null) Text(county, style: Theme.of(context).textTheme.bodySmall),
                  Text('Level $level${levelName != null ? ' • $levelName' : ''}', style: Theme.of(context).textTheme.bodySmall),
                  Text('$totalXp XP', style: Theme.of(context).textTheme.bodySmall),
                ],
              ),
            ),
            if (avgScore != null)
              ProgressRing(
                value: avgScore.clamp(0, 100),
                size: 64,
                strokeWidth: 6,
                foregroundColor: AppColors.matchScoreColor(avgScore),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildMatchBreakdown(List<Map<String, dynamic>> skillScores, bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Skill scores', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600)),
        const SizedBox(height: AppSpacing.s),
        ...skillScores.map((s) {
          final categoryId = s['categoryId'] as String? ?? '';
          final score = (s['currentScore'] as num?)?.toInt() ?? 0;
          final label = categoryId.replaceAll('-', ' ').split(' ').map((e) => e.isNotEmpty ? '${e[0].toUpperCase()}${e.substring(1)}' : '').join(' ');
          return Padding(
            padding: const EdgeInsets.only(bottom: 6),
            child: Row(
              children: [
                SizedBox(width: 130, child: Text(label, style: Theme.of(context).textTheme.bodyMedium)),
                Expanded(
                  child: LinearProgressIndicator(
                    value: score / 100,
                    backgroundColor: AppColors.primary.withOpacity(0.2),
                    valueColor: AlwaysStoppedAnimation<Color>(AppColors.matchScoreColor(score)),
                  ),
                ),
                const SizedBox(width: 8),
                Text('$score%', style: Theme.of(context).textTheme.bodySmall),
              ],
            ),
          );
        }),
      ],
    );
  }

  Widget _buildRadar(List<Map<String, dynamic>> skillScores, bool isDark) {
    const keys = ['digital-literacy', 'communication', 'business-entrepreneurship', 'technical-ict', 'soft-skills-leadership'];
    final scoreMap = {for (var s in skillScores) s['categoryId'] as String: (s['currentScore'] as num?)?.toDouble() ?? 0.0};
    final values = keys.map((k) => scoreMap[k] ?? 0.0).toList();
    final labels = ['Digital', 'Communication', 'Business', 'Technical', 'Soft skills'];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Skills radar', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600)),
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
      final span = TextSpan(text: labels[i], style: const TextStyle(fontSize: 11, color: AppColors.textPrimary, fontWeight: FontWeight.w500));
      final tp = TextPainter(text: span, textDirection: TextDirection.ltr)..layout();
      tp.paint(canvas, Offset(x - tp.width / 2, y - tp.height / 2));
    }
  }

  @override
  bool shouldRepaint(covariant _RadarPainter old) => old.values != values || old.labels != labels;
}
