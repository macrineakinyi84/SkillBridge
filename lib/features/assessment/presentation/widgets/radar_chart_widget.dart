import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../../../../shared/theme/app_colors.dart';

/// Radar chart: 5 axes, user scores (filled) + benchmark (dashed). Animated from 0. Touch tooltip.
class RadarChartWidget extends StatefulWidget {
  const RadarChartWidget({
    super.key,
    required this.userValues,
    this.benchmarkValues,
    required this.labels,
    this.size = 200,
    this.animateFromZero = true,
  });

  final List<double> userValues;
  final List<double>? benchmarkValues;
  final List<String> labels;
  final double size;
  final bool animateFromZero;

  @override
  State<RadarChartWidget> createState() => _RadarChartWidgetState();
}

class _RadarChartWidgetState extends State<RadarChartWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _animation = CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic);
    if (widget.animateFromZero) _controller.forward();
    else _controller.value = 1;
  }

  @override
  void didUpdateWidget(covariant RadarChartWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.userValues != widget.userValues && widget.animateFromZero) {
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
    final n = widget.labels.length;
    if (n == 0) return const SizedBox.shrink();

    final scaledUser = widget.userValues.map((v) => v * _animation.value).toList();
    while (scaledUser.length < n) scaledUser.add(0);

    final dataSets = <RadarDataSet>[
      RadarDataSet(
        dataEntries: scaledUser.map((v) => RadarEntry(value: v.clamp(0.0, 1.0))).toList(),
        fillColor: AppColors.primary.withOpacity(0.3),
        borderColor: AppColors.primary,
        borderWidth: 2,
      ),
    ];
    if (widget.benchmarkValues != null && widget.benchmarkValues!.length >= n) {
      dataSets.add(
        RadarDataSet(
          dataEntries: widget.benchmarkValues!.take(n).map((v) => RadarEntry(value: v.clamp(0.0, 1.0))).toList(),
          fillColor: Colors.transparent,
          borderColor: AppColors.textSecondary,
          borderWidth: 1.5,
        ),
      );
    }

    return SizedBox(
      width: widget.size,
      height: widget.size,
      child: RadarChart(
        RadarChartData(
          dataSets: dataSets,
          getTitle: (i, angle) => RadarChartTitle(
            text: i < widget.labels.length ? widget.labels[i] : '',
            angle: angle,
          ),
          tickCount: 4,
          radarShape: RadarShape.polygon,
        ),
        duration: const Duration(milliseconds: 300),
      ),
    );
  }
}
