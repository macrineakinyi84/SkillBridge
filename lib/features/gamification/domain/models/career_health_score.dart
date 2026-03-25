import 'package:equatable/equatable.dart';

/// Composite career health score 0–100 with component breakdown.
class CareerHealthScore extends Equatable {
  const CareerHealthScore({
    required this.total,
    required this.skillsAverage,
    required this.portfolioComplete,
    required this.learningProgress,
    required this.jobActivity,
    required this.profileEngagement,
    this.previousTotal,
  });

  final int total;
  final double skillsAverage;
  final double portfolioComplete;
  final double learningProgress;
  final double jobActivity;
  final double profileEngagement;
  final int? previousTotal;

  int get delta => previousTotal != null ? total - previousTotal! : 0;

  @override
  List<Object?> get props => [
        total,
        skillsAverage,
        portfolioComplete,
        learningProgress,
        jobActivity,
        profileEngagement,
        previousTotal,
      ];
}
