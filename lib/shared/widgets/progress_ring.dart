import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

// One ring for “your overall number” (readiness, match %) so we don’t mix
// chart types; bar is for per-item progress (see progress_bar_row.dart and docs/UI_SYSTEM.md).
class ProgressRing extends StatelessWidget {
  const ProgressRing({
    super.key,
    required this.value,
    this.size = 88,
    this.strokeWidth = 8,
    this.backgroundColor,
    this.foregroundColor,
    this.labelStyle,
  });

  final int value;
  final double size;
  final double strokeWidth;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final TextStyle? labelStyle;

  @override
  Widget build(BuildContext context) {
    final progress = (value.clamp(0, 100) / 100).toDouble();
    final bg = backgroundColor ?? AppColors.primary.withOpacity(0.2);
    final fg = foregroundColor ?? AppColors.primary;

    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _RingPainter(
          progress: progress,
          strokeWidth: strokeWidth,
          backgroundColor: bg,
          foregroundColor: fg,
        ),
        child: Center(
          child: Text(
            '$value%',
            style: labelStyle ??
                Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w800,
                      color: fg,
                    ),
          ),
        ),
      ),
    );
  }
}

class _RingPainter extends CustomPainter {
  _RingPainter({
    required this.progress,
    required this.strokeWidth,
    required this.backgroundColor,
    required this.foregroundColor,
  });

  final double progress;
  final double strokeWidth;
  final Color backgroundColor;
  final Color foregroundColor;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.shortestSide / 2) - strokeWidth / 2;

    final bgPaint = Paint()
      ..color = backgroundColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    final fgPaint = Paint()
      ..color = foregroundColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(center, radius, bgPaint);
    if (progress > 0) {
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        -math.pi / 2,
        2 * math.pi * progress,
        false,
        fgPaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _RingPainter old) =>
      old.progress != progress ||
      old.strokeWidth != strokeWidth ||
      old.backgroundColor != backgroundColor ||
      old.foregroundColor != foregroundColor;
}
