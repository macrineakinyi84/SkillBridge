import 'package:equatable/equatable.dart';

/// User's gamification state: XP, level, streaks, badges.
class GamificationProfile extends Equatable {
  const GamificationProfile({
    required this.userId,
    required this.totalXp,
    required this.weeklyXp,
    required this.level,
    required this.levelName,
    required this.xpInCurrentLevel,
    required this.xpToNextLevel,
    this.jobStreak = 0,
    this.learnStreak = 0,
    this.lastJobStreakAt,
    this.lastLearnStreakAt,
    this.earnedBadgeIds = const [],
    this.lastActiveAt,
    this.careerHealthScore,
    this.weeklyActivity = const [],
  });

  final String userId;
  final int totalXp;
  final int weeklyXp;
  final int level;
  final String levelName;
  final int xpInCurrentLevel;
  final int xpToNextLevel;
  final int jobStreak;
  final int learnStreak;
  final DateTime? lastJobStreakAt;
  final DateTime? lastLearnStreakAt;
  final List<String> earnedBadgeIds;
  final DateTime? lastActiveAt;
  final int? careerHealthScore;
  /// Last 7 days: [oldest, ..., today]. true = had activity.
  final List<bool> weeklyActivity;

  @override
  List<Object?> get props => [
        userId,
        totalXp,
        weeklyXp,
        level,
        levelName,
        xpInCurrentLevel,
        xpToNextLevel,
        jobStreak,
        learnStreak,
        earnedBadgeIds,
        careerHealthScore,
        weeklyActivity,
      ];
}
