import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../../../shared/theme/app_colors.dart';
import '../../domain/models/career_health_score.dart';

/// Large animated ring showing career health 0-100. Five segments. Tap to expand breakdown.
class CareerHealthRing extends StatefulWidget {
  const CareerHealthRing({
    super.key,
    required this.score,
    this.size = 200,
    this.strokeWidth = 14,
    this.animated = true,
    this.previousScore,
  });

  final CareerHealthScore score;
  final double size;
  final double strokeWidth;
  final bool animated;
  final int? previousScore;

  @override
  State<CareerHealthRing> createState() => _CareerHealthRingState();
}

class _CareerHealthRingState extends State<CareerHealthRing>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  bool _expanded = false;

  static const List<Color> _segmentColors = [
    Color(0xFF10B981),
    Color(0xFF3B82F6),
    Color(0xFF8B5CF6),
    Color(0xFFF59E0B),
    Color(0xFFEC4899),
  ];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    final end = (widget.score.total.clamp(0, 100)) / 100;
    _animation = Tween<double>(
      begin: (widget.previousScore ?? 0) / 100,
      end: end,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));
    if (widget.animated) _controller.forward();
    else _controller.value = 1;
  }

  @override
  void didUpdateWidget(covariant CareerHealthRing oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.score.total != widget.score.total && widget.animated) {
      _animation = Tween<double>(
        begin: oldWidget.score.total / 100,
        end: widget.score.total.clamp(0, 100) / 100,
      ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));
      _controller.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final total = widget.score.total.clamp(0, 100) / 100;
    final values = [
      widget.score.skillsAverage / 100,
      widget.score.portfolioComplete / 100,
      widget.score.learningProgress / 100,
      widget.score.jobActivity.clamp(0.0, 1.0),
      widget.score.profileEngagement.clamp(0.0, 1.0),
    ];
    final labels = ['Skills', 'Portfolio', 'Learning', 'Jobs', 'Profile'];

    return GestureDetector(
      onTap: () => setState(() => _expanded = !_expanded),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: widget.size,
            height: widget.size,
            child: AnimatedBuilder(
              animation: _animation,
              builder: (context, _) {
                final t = widget.animated ? _animation.value : total;
                return CustomPaint(
                  painter: _SegmentedRingPainter(
                    progress: t,
                    segmentValues: values,
                    segmentColors: _segmentColors,
                    strokeWidth: widget.strokeWidth,
                  ),
                  child: Center(
                    child: Text(
                      '${(t * 100).round()}',
                      style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                            fontWeight: FontWeight.w800,
                            color: AppColors.primary,
                          ),
                    ),
                  ),
                );
              },
            ),
          ),
          if (_expanded) ...[
            const SizedBox(height: 16),
            ...List.generate(
              5,
              (i) => Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Row(
                  children: [
                    Container(
                      width: 12,
                      height: 12,
                      decoration: BoxDecoration(
                        color: _segmentColors[i],
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(labels[i], style: Theme.of(context).textTheme.bodySmall),
                    const Spacer(),
                    Text(
                      '${(values[i] * 100).round()}%',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _SegmentedRingPainter extends CustomPainter {
  _SegmentedRingPainter({
    required this.progress,
    required this.segmentValues,
    required this.segmentColors,
    required this.strokeWidth,
  });

  final double progress;
  final List<double> segmentValues;
  final List<Color> segmentColors;
  final double strokeWidth;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.shortestSide / 2) - strokeWidth / 2;
    final rect = Rect.fromCircle(center: center, radius: radius);
    const startAngle = -math.pi / 2;

    for (var i = 0; i < 5; i++) {
      final sweep = 2 * math.pi * (segmentValues[i].clamp(0.0, 1.0)) / 5;
      final angle = startAngle + (i * 2 * math.pi / 5);
      final paint = Paint()
        ..color = segmentColors[i].withOpacity(0.35)
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.round;
      canvas.drawArc(rect, angle, sweep, false, paint);
    }

    final overallSweep = 2 * math.pi * progress;
    final fgPaint = Paint()
      ..shader = SweepGradient(
        startAngle: startAngle,
        endAngle: startAngle + overallSweep,
        colors: segmentColors,
      ).createShader(rect)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;
    if (overallSweep > 0) {
      canvas.drawArc(rect, startAngle, overallSweep, false, fgPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _SegmentedRingPainter old) =>
      old.progress != progress || old.segmentValues != segmentValues;
}
