import 'package:equatable/equatable.dart';

class ReadinessEntity extends Equatable {
  const ReadinessEntity({
    required this.score,
    this.maxScore = 100,
    this.feedback,
  });

  final int score;
  final int maxScore;
  final String? feedback;

  double get percentage => maxScore > 0 ? score / maxScore : 0.0;

  @override
  List<Object?> get props => [score, maxScore, feedback];
}
