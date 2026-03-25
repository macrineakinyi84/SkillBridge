import '../../domain/models/gamification_profile.dart';
import '../../domain/models/career_health_score.dart';
import '../../domain/models/badge_model.dart';
import '../../domain/models/leaderboard_entry.dart';
import '../../domain/repositories/gamification_repository.dart';
import '../datasources/gamification_remote_datasource.dart';

class GamificationRepositoryImpl implements GamificationRepository {
  GamificationRepositoryImpl(this._remote);

  final GamificationRemoteDataSource _remote;

  @override
  Future<GamificationProfile?> getProfile(String userId) => _remote.getProfile(userId);

  @override
  Future<CareerHealthScore?> getCareerHealthScore(String studentId) =>
      _remote.getCareerHealthScore(studentId);

  @override
  Future<void> updateStreak(String userId, String streakType) =>
      _remote.updateStreak(userId, streakType);

  @override
  Future<List<LeaderboardEntry>> getLeaderboard(String county, {int limit = 10}) =>
      _remote.getLeaderboard(county, limit: limit);

  @override
  Future<List<bool>> getWeeklyActivityGrid(String userId) =>
      _remote.getWeeklyActivityGrid(userId);

  @override
  Future<List<BadgeModel>> getBadges(String userId) => _remote.getBadges(userId);

  @override
  Future<XpAwardResult> awardXp(String userId, String eventType, [Map<String, dynamic>? metadata]) =>
      _remote.awardXp(userId, eventType, metadata);

  @override
  Future<List<BadgeModel>> checkAndAwardBadges(String userId, String triggerEvent) =>
      _remote.checkAndAwardBadges(userId, triggerEvent);
}
