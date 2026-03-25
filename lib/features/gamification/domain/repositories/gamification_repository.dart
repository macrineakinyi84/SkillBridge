import '../models/gamification_profile.dart';
import '../models/career_health_score.dart';
import '../models/badge_model.dart';
import '../models/leaderboard_entry.dart';

/// Gamification API: profile, career health, streaks, leaderboard, badges, XP award.
abstract class GamificationRepository {
  Future<GamificationProfile?> getProfile(String userId);
  Future<CareerHealthScore?> getCareerHealthScore(String studentId);
  Future<void> updateStreak(String userId, String streakType);
  Future<List<LeaderboardEntry>> getLeaderboard(String county, {int limit = 10});
  Future<List<bool>> getWeeklyActivityGrid(String userId);
  Future<List<BadgeModel>> getBadges(String userId);
  Future<XpAwardResult> awardXp(String userId, String eventType, [Map<String, dynamic>? metadata]);
  Future<List<BadgeModel>> checkAndAwardBadges(String userId, String triggerEvent);
}

class XpAwardResult {
  const XpAwardResult({
    required this.newTotal,
    required this.xpAwarded,
    this.leveledUp = false,
    this.newLevel,
  });

  final int newTotal;
  final int xpAwarded;
  final bool leveledUp;
  final int? newLevel;
}
