import 'package:equatable/equatable.dart';

/// Summary of a user's skill for dashboard display.
class SkillProgressItem extends Equatable {
  const SkillProgressItem({
    required this.name,
    required this.proficiencyLevel,
    this.progressPercent = 0,
  });

  final String name;
  final String proficiencyLevel;
  final int progressPercent;

  @override
  List<Object?> get props => [name, proficiencyLevel, progressPercent];
}

/// Summary item for recent job matches (dashboard).
class RecentJobMatchItem extends Equatable {
  const RecentJobMatchItem({required this.title, required this.matchPercent});
  final String title;
  final int matchPercent;
  @override
  List<Object?> get props => [title, matchPercent];
}

/// Summary item for learning progress (dashboard).
class LearningProgressItem extends Equatable {
  const LearningProgressItem({required this.title, this.progressPercent = 0});
  final String title;
  final int progressPercent;
  @override
  List<Object?> get props => [title, progressPercent];
}

/// Data for the Student dashboard. Can be loaded from repositories.
class DashboardData extends Equatable {
  const DashboardData({
    required this.readinessScore,
    required this.skillProgressSummary,
    required this.recommendedSkills,
    required this.portfolioCount,
    this.activeDaysThisWeek = 0,
    this.nextStepTitle,
    this.nextStepBody,
    this.nextStepActionLabel,
    this.jobMatchPercent,
    this.recentJobMatches = const [],
    this.learningProgress = const [],
    this.notificationCount = 0,
  });

  final int readinessScore;
  final List<SkillProgressItem> skillProgressSummary;
  final List<String> recommendedSkills;
  final int portfolioCount;
  final int activeDaysThisWeek;
  final String? nextStepTitle;
  final String? nextStepBody;
  final String? nextStepActionLabel;
  /// Job match percentage (Student Dashboard spec).
  final int? jobMatchPercent;
  final List<RecentJobMatchItem> recentJobMatches;
  final List<LearningProgressItem> learningProgress;
  final int notificationCount;

  int get skillsCount => skillProgressSummary.length;

  @override
  List<Object?> get props => [
        readinessScore,
        skillProgressSummary,
        recommendedSkills,
        portfolioCount,
        activeDaysThisWeek,
        nextStepTitle,
        nextStepBody,
        nextStepActionLabel,
        jobMatchPercent,
        recentJobMatches,
        learningProgress,
        notificationCount,
      ];
}
