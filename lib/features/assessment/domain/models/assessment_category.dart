import 'package:equatable/equatable.dart';

class AssessmentCategory extends Equatable {
  const AssessmentCategory({
    required this.id,
    required this.name,
    required this.iconName,
    this.currentScore,
    this.tier,
    this.lastAssessedAt,
  });

  final String id;
  final String name;
  final String iconName;
  final int? currentScore;
  final String? tier;
  final DateTime? lastAssessedAt;

  int get daysSinceLastAssessment {
    if (lastAssessedAt == null) return -1;
    return DateTime.now().difference(lastAssessedAt!).inDays;
  }

  @override
  List<Object?> get props => [id, name, iconName, currentScore, tier, lastAssessedAt];
}
