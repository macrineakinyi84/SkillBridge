import 'package:equatable/equatable.dart';
import '../../../skills/domain/entities/user_skill_entity.dart';

/// Input data for readiness score calculation.
/// Build this from UserSkillRepository, PortfolioRepository, and activity logs.
class ReadinessScoreInput extends Equatable {
  const ReadinessScoreInput({
    this.userSkills = const [],
    this.portfolioItemCount = 0,
    this.activityDates = const [],
    this.referenceDate,
  });

  /// User's skills (with proficiency) for "completed skills" and "skill progress".
  final List<UserSkillEntity> userSkills;

  /// Number of portfolio items for the portfolio component.
  final int portfolioItemCount;

  /// Dates when the user had activity (e.g. added/updated skill or portfolio).
  /// Used for learning consistency (e.g. unique days in last N days).
  final List<DateTime> activityDates;

  /// Reference date for "last N days" (defaults to now).
  final DateTime? referenceDate;

  @override
  List<Object?> get props => [userSkills, portfolioItemCount, activityDates, referenceDate];
}

/// Optional breakdown of component scores for research and debugging.
class ReadinessScoreBreakdown extends Equatable {
  const ReadinessScoreBreakdown({
    required this.totalScore,
    required this.completedSkillsScore,
    required this.skillProgressScore,
    required this.portfolioScore,
    required this.learningConsistencyScore,
    this.completedSkillsCount = 0,
    this.portfolioItemCount = 0,
    this.uniqueActiveDays = 0,
  });

  final int totalScore;
  final double completedSkillsScore;
  final double skillProgressScore;
  final double portfolioScore;
  final double learningConsistencyScore;
  final int completedSkillsCount;
  final int portfolioItemCount;
  final int uniqueActiveDays;

  @override
  List<Object?> get props => [
        totalScore,
        completedSkillsScore,
        skillProgressScore,
        portfolioScore,
        learningConsistencyScore,
        completedSkillsCount,
        portfolioItemCount,
        uniqueActiveDays,
      ];
}
