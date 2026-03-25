import '../models/feed_item.dart';
import '../models/community_leaderboard_entry.dart';
import '../models/challenge.dart';

abstract class CommunityRepository {
  Future<List<FeedItem>> getFeed(String county, {int limit = 20});
  Future<CommunityLeaderboardData> getLeaderboard(String county, {String? currentUserId});
  Future<Challenge?> createChallenge(String fromUserId, String toUserId, String categoryId);
  Future<bool> acceptChallenge(String challengeId, String userId);
  Future<SubmitChallengeScoreResult> submitChallengeScore(String challengeId, String userId, int score);
  Future<List<Challenge>> getChallengesForUser(String userId);
}

class CommunityLeaderboardData {
  const CommunityLeaderboardData({
    required this.entries,
    required this.nextResetAt,
    this.currentUserEntry,
  });

  final List<CommunityLeaderboardEntry> entries;
  final DateTime nextResetAt;
  final CommunityLeaderboardEntry? currentUserEntry;
}

class SubmitChallengeScoreResult {
  const SubmitChallengeScoreResult({
    required this.recorded,
    this.completed = false,
    this.winnerUserId,
    this.xpAwarded,
  });

  final bool recorded;
  final bool completed;
  final String? winnerUserId;
  final int? xpAwarded;
}
