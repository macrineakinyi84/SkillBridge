import '../../domain/models/feed_item.dart';
import '../../domain/models/community_leaderboard_entry.dart';
import '../../domain/models/challenge.dart';
import '../../domain/repositories/community_repository.dart';
import '../datasources/community_remote_datasource.dart';

class CommunityRepositoryImpl implements CommunityRepository {
  CommunityRepositoryImpl(this._remote);

  final CommunityRemoteDataSource _remote;

  @override
  Future<List<FeedItem>> getFeed(String county, {int limit = 20}) =>
      _remote.getFeed(county, limit: limit);

  @override
  Future<CommunityLeaderboardData> getLeaderboard(String county, {String? currentUserId}) =>
      _remote.getLeaderboard(county, currentUserId: currentUserId);

  @override
  Future<Challenge?> createChallenge(String fromUserId, String toUserId, String categoryId) =>
      _remote.createChallenge(fromUserId, toUserId, categoryId);

  @override
  Future<bool> acceptChallenge(String challengeId, String userId) =>
      _remote.acceptChallenge(challengeId, userId);

  @override
  Future<SubmitChallengeScoreResult> submitChallengeScore(String challengeId, String userId, int score) =>
      _remote.submitChallengeScore(challengeId, userId, score);

  @override
  Future<List<Challenge>> getChallengesForUser(String userId) =>
      _remote.getChallengesForUser(userId);
}
