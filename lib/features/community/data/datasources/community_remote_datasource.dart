import '../../domain/models/feed_item.dart';
import '../../domain/models/community_leaderboard_entry.dart';
import '../../domain/models/challenge.dart';
import '../../domain/repositories/community_repository.dart';

abstract class CommunityRemoteDataSource {
  Future<List<FeedItem>> getFeed(String county, {int limit = 20});
  Future<CommunityLeaderboardData> getLeaderboard(String county, {String? currentUserId});
  Future<Challenge?> createChallenge(String fromUserId, String toUserId, String categoryId);
  Future<bool> acceptChallenge(String challengeId, String userId);
  Future<SubmitChallengeScoreResult> submitChallengeScore(String challengeId, String userId, int score);
  Future<List<Challenge>> getChallengesForUser(String userId);
}

/// Mock implementation. Replace with HTTP calls to backend community API.
class CommunityRemoteDataSourceMock implements CommunityRemoteDataSource {
  final List<FeedItem> _feed = [];
  final List<CommunityLeaderboardEntry> _leaderboardNairobi = [];
  final Map<String, Challenge> _challenges = {};
  int _challengeIdSeq = 0;

  CommunityRemoteDataSourceMock() {
    _seedFeed();
    _seedLeaderboard();
  }

  void _seedFeed() {
    final now = DateTime.now();
    if (_feed.isNotEmpty) return;
    _feed.addAll([
      FeedItem(
        id: 'f1',
        type: FeedActivityType.assessment,
        userId: 'u1',
        displayName: 'Alice',
        message: 'Completed Digital Literacy assessment with 85%',
        createdAt: now.subtract(const Duration(hours: 1)),
        metadata: {'categoryId': 'digital-literacy', 'score': 85},
      ),
      FeedItem(
        id: 'f2',
        type: FeedActivityType.job,
        userId: 'u2',
        displayName: 'Bob',
        message: 'Applied to Junior Developer at Tech Co',
        createdAt: now.subtract(const Duration(hours: 2)),
      ),
      FeedItem(
        id: 'f3',
        type: FeedActivityType.badge,
        userId: 'u3',
        displayName: 'Carol',
        message: 'Earned the First Assessment badge',
        createdAt: now.subtract(const Duration(days: 1)),
        metadata: {'badgeId': 'first_assessment'},
      ),
      FeedItem(
        id: 'f4',
        type: FeedActivityType.level,
        userId: 'u1',
        displayName: 'Alice',
        message: 'Reached Level 3 • Rising Star',
        createdAt: now.subtract(const Duration(days: 2)),
        metadata: {'level': 3},
      ),
      FeedItem(
        id: 'f5',
        type: FeedActivityType.assessment,
        userId: 'u4',
        displayName: 'Dave',
        message: 'Completed Communication assessment',
        createdAt: now.subtract(const Duration(days: 2)),
        metadata: {'categoryId': 'communication'},
      ),
      FeedItem(
        id: 'f6',
        type: FeedActivityType.job,
        userId: 'u5',
        displayName: 'Eve',
        message: 'Applied to Mobile Dev Intern at Startup Kenya',
        createdAt: now.subtract(const Duration(days: 3)),
      ),
      FeedItem(
        id: 'f7',
        type: FeedActivityType.badge,
        userId: 'u2',
        displayName: 'Bob',
        message: 'Earned the Job Ready badge',
        createdAt: now.subtract(const Duration(days: 4)),
        metadata: {'badgeId': 'job_ready'},
      ),
    ]);
  }

  void _seedLeaderboard() {
    if (_leaderboardNairobi.isNotEmpty) return;
    _leaderboardNairobi.addAll([
      const CommunityLeaderboardEntry(rank: 1, userId: 'u1', displayName: 'Alice', weeklyXp: 320, level: 3, levelName: 'Rising Star'),
      const CommunityLeaderboardEntry(rank: 2, userId: 'u2', displayName: 'Bob', weeklyXp: 280, level: 2, levelName: 'Rising Star'),
      const CommunityLeaderboardEntry(rank: 3, userId: 'u3', displayName: 'Carol', weeklyXp: 250, level: 2, levelName: 'Rising Star'),
      const CommunityLeaderboardEntry(rank: 4, userId: 'u4', displayName: 'Dave', weeklyXp: 180, level: 2, levelName: 'Rising Star'),
      const CommunityLeaderboardEntry(rank: 5, userId: 'u5', displayName: 'Eve', weeklyXp: 120, level: 1, levelName: 'Starter'),
      const CommunityLeaderboardEntry(rank: 6, userId: 'u6', displayName: 'Faith', weeklyXp: 95, level: 1, levelName: 'Starter'),
      const CommunityLeaderboardEntry(rank: 7, userId: 'u7', displayName: 'Grace', weeklyXp: 80, level: 1, levelName: 'Starter'),
      const CommunityLeaderboardEntry(rank: 8, userId: 'u8', displayName: 'Henry', weeklyXp: 65, level: 1, levelName: 'Starter'),
      const CommunityLeaderboardEntry(rank: 9, userId: 'u9', displayName: 'Ivy', weeklyXp: 52, level: 1, levelName: 'Starter'),
      const CommunityLeaderboardEntry(rank: 10, userId: 'u10', displayName: 'James', weeklyXp: 40, level: 1, levelName: 'Starter'),
    ]);
  }

  @override
  Future<List<FeedItem>> getFeed(String county, {int limit = 20}) async {
    await Future.delayed(const Duration(milliseconds: 300));
    final forCounty = county == 'Nairobi' ? _feed : <FeedItem>[];
    return forCounty.take(limit).toList();
  }

  static DateTime _nextMonday() {
    final d = DateTime.now();
    final weekday = d.weekday;
    final daysUntilMonday = weekday == DateTime.monday ? 0 : (8 - weekday) % 7;
    if (daysUntilMonday == 0 && d.hour >= 0) {
      final next = d.add(const Duration(days: 7));
      return DateTime(next.year, next.month, next.day, 0, 0, 0);
    }
    final next = d.add(Duration(days: daysUntilMonday));
    return DateTime(next.year, next.month, next.day, 0, 0, 0);
  }

  @override
  Future<CommunityLeaderboardData> getLeaderboard(String county, {String? currentUserId}) async {
    await Future.delayed(const Duration(milliseconds: 250));
    final list = county == 'Nairobi'
        ? _leaderboardNairobi.asMap().entries.map((e) => CommunityLeaderboardEntry(
              rank: e.key + 1,
              userId: e.value.userId,
              displayName: e.value.displayName,
              photoUrl: e.value.photoUrl,
              weeklyXp: e.value.weeklyXp,
              level: e.value.level,
              levelName: e.value.levelName,
            )).toList()
        : <CommunityLeaderboardEntry>[];
    CommunityLeaderboardEntry? currentUserEntry;
    if (currentUserId != null) {
      final idx = list.indexWhere((e) => e.userId == currentUserId);
      if (idx >= 0) {
        currentUserEntry = list[idx];
      } else {
        currentUserEntry = CommunityLeaderboardEntry(
          rank: 11,
          userId: currentUserId,
          displayName: 'You',
          weeklyXp: 50,
          level: 1,
          levelName: 'Starter',
        );
      }
    }
    return CommunityLeaderboardData(
      entries: list,
      nextResetAt: _nextMonday(),
      currentUserEntry: currentUserEntry,
    );
  }

  @override
  Future<Challenge?> createChallenge(String fromUserId, String toUserId, String categoryId) async {
    await Future.delayed(const Duration(milliseconds: 150));
    final id = 'ch-${++_challengeIdSeq}';
    final expiresAt = DateTime.now().add(const Duration(hours: 48));
    const categoryName = 'Digital Literacy';
    final c = Challenge(
      id: id,
      fromUserId: fromUserId,
      toUserId: toUserId,
      categoryId: categoryId,
      categoryName: categoryName,
      status: ChallengeStatus.pending,
      expiresAt: expiresAt,
      fromDisplayName: 'You',
      toDisplayName: 'Friend',
    );
    _challenges[id] = c;
    return c;
  }

  @override
  Future<bool> acceptChallenge(String challengeId, String userId) async {
    await Future.delayed(const Duration(milliseconds: 100));
    final c = _challenges[challengeId];
    if (c == null || c.toUserId != userId) return false;
    if (c.expiresAt.isBefore(DateTime.now())) return false;
    _challenges[challengeId] = Challenge(
      id: c.id,
      fromUserId: c.fromUserId,
      toUserId: c.toUserId,
      categoryId: c.categoryId,
      categoryName: c.categoryName,
      status: ChallengeStatus.active,
      expiresAt: c.expiresAt,
      acceptedAt: DateTime.now(),
      fromScore: c.fromScore,
      toScore: c.toScore,
      winnerUserId: c.winnerUserId,
      xpAwarded: c.xpAwarded,
      fromDisplayName: c.fromDisplayName,
      toDisplayName: c.toDisplayName,
    );
    return true;
  }

  @override
  Future<SubmitChallengeScoreResult> submitChallengeScore(String challengeId, String userId, int score) async {
    await Future.delayed(const Duration(milliseconds: 100));
    final c = _challenges[challengeId];
    if (c == null) return const SubmitChallengeScoreResult(recorded: false);
    if (c.expiresAt.isBefore(DateTime.now())) return const SubmitChallengeScoreResult(recorded: false);
    int? fromScore = c.fromScore;
    int? toScore = c.toScore;
    if (c.fromUserId == userId) fromScore = score;
    else if (c.toUserId == userId) toScore = score;
    else return const SubmitChallengeScoreResult(recorded: false);

    if (fromScore != null && toScore != null) {
      String? winner;
      int fromXp = 10;
      int toXp = 10;
      if (fromScore > toScore) {
        winner = c.fromUserId;
        fromXp = 25;
        toXp = 5;
      } else if (toScore > fromScore) {
        winner = c.toUserId;
        fromXp = 5;
        toXp = 25;
      }
      final xpForUser = userId == c.fromUserId ? fromXp : toXp;
      _challenges[challengeId] = Challenge(
        id: c.id,
        fromUserId: c.fromUserId,
        toUserId: c.toUserId,
        categoryId: c.categoryId,
        categoryName: c.categoryName,
        status: ChallengeStatus.completed,
        expiresAt: c.expiresAt,
        acceptedAt: c.acceptedAt,
        fromScore: fromScore,
        toScore: toScore,
        winnerUserId: winner,
        xpAwarded: xpForUser,
        fromDisplayName: c.fromDisplayName,
        toDisplayName: c.toDisplayName,
      );
      return SubmitChallengeScoreResult(
        recorded: true,
        completed: true,
        winnerUserId: winner,
        xpAwarded: xpForUser,
      );
    }
    _challenges[challengeId] = Challenge(
      id: c.id,
      fromUserId: c.fromUserId,
      toUserId: c.toUserId,
      categoryId: c.categoryId,
      categoryName: c.categoryName,
      status: ChallengeStatus.active,
      expiresAt: c.expiresAt,
      acceptedAt: c.acceptedAt,
      fromScore: fromScore,
      toScore: toScore,
      winnerUserId: c.winnerUserId,
      xpAwarded: c.xpAwarded,
      fromDisplayName: c.fromDisplayName,
      toDisplayName: c.toDisplayName,
    );
    return const SubmitChallengeScoreResult(recorded: true);
  }

  @override
  Future<List<Challenge>> getChallengesForUser(String userId) async {
    await Future.delayed(const Duration(milliseconds: 200));
    final list = _challenges.values
        .where((c) => c.fromUserId == userId || c.toUserId == userId)
        .toList();
    list.sort((a, b) => b.expiresAt.compareTo(a.expiresAt));
    return list;
  }
}
