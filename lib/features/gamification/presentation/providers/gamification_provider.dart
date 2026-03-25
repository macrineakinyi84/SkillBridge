import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/di/injection.dart';
import '../../domain/models/gamification_profile.dart';
import '../../domain/models/career_health_score.dart';
import '../../domain/models/badge_model.dart';
import '../../domain/models/leaderboard_entry.dart';
import '../../domain/repositories/gamification_repository.dart';
import '../widgets/celebration_overlay.dart';

final gamificationRepositoryProvider = Provider<GamificationRepository>((ref) {
  return sl<GamificationRepository>();
});

final gamificationProfileProvider =
    FutureProvider.family<GamificationProfile?, String>((ref, userId) async {
  final repo = ref.watch(gamificationRepositoryProvider);
  return repo.getProfile(userId);
});

final careerHealthScoreProvider =
    FutureProvider.family<CareerHealthScore?, String>((ref, studentId) async {
  final repo = ref.watch(gamificationRepositoryProvider);
  return repo.getCareerHealthScore(studentId);
});

final streaksProvider =
    FutureProvider.family<({int job, int learn})?, String>((ref, userId) async {
  final profile = await ref.watch(gamificationProfileProvider(userId).future);
  if (profile == null) return null;
  return (job: profile.jobStreak, learn: profile.learnStreak);
});

final leaderboardProvider =
    FutureProvider.family<List<LeaderboardEntry>, String>((ref, county) async {
  final repo = ref.watch(gamificationRepositoryProvider);
  return repo.getLeaderboard(county, limit: 10);
});

final badgesProvider =
    FutureProvider.family<List<BadgeModel>, String>((ref, userId) async {
  final repo = ref.watch(gamificationRepositoryProvider);
  return repo.getBadges(userId);
});

final weeklyActivityProvider =
    FutureProvider.family<List<bool>, String>((ref, userId) async {
  final repo = ref.watch(gamificationRepositoryProvider);
  return repo.getWeeklyActivityGrid(userId);
});

/// Call to award XP; use from UI after actions. Optionally show celebration.
Future<XpAwardResult?> triggerXpAward(
  Ref ref,
  String userId,
  String eventType, {
  Map<String, dynamic>? metadata,
  void Function(XpAwardResult)? onAwarded,
}) async {
  final repo = ref.read(gamificationRepositoryProvider);
  final result = await repo.awardXp(userId, eventType, metadata);
  ref.invalidate(gamificationProfileProvider(userId));
  onAwarded?.call(result);
  return result;
}

/// Type of celebration to show (e.g. after XP award or badge).
enum CelebrationTrigger { scoreImprovement, badgeEarned, levelUp }
