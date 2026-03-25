import 'package:equatable/equatable.dart';

class AssessmentResult extends Equatable {
  const AssessmentResult({
    required this.normalisedScore,
    required this.rawScore,
    required this.maxPossibleScore,
    required this.tier,
    this.previousScore,
    this.scoreChange,
    this.gaps = const [],
    this.recommendations = const [],
    this.xpAwarded = 0,
    this.radarData = const [],
  });

  final int normalisedScore;
  final int rawScore;
  final int maxPossibleScore;
  final String tier;
  final int? previousScore;
  final int? scoreChange;
  final List<GapItem> gaps;
  final List<LearningRecommendation> recommendations;
  final int xpAwarded;
  final List<double> radarData;

  @override
  List<Object?> get props => [normalisedScore, tier, previousScore, scoreChange, gaps, recommendations, xpAwarded];
}

class GapItem extends Equatable {
  const GapItem({required this.categoryId, required this.gapPoints, this.benchmark, this.currentScore});
  final String categoryId;
  final int gapPoints;
  final int? benchmark;
  final int? currentScore;
  @override
  List<Object?> get props => [categoryId, gapPoints];
}

class LearningRecommendation extends Equatable {
  const LearningRecommendation({required this.categoryId, required this.title, this.gapPoints});
  final String categoryId;
  final String title;
  final int? gapPoints;
  @override
  List<Object?> get props => [categoryId, title];
}
