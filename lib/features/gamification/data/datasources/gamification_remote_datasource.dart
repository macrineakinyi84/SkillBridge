import '../../domain/models/gamification_profile.dart';
import '../../domain/models/career_health_score.dart';
import '../../domain/models/badge_model.dart';
import '../../domain/models/leaderboard_entry.dart';
import '../../domain/repositories/gamification_repository.dart';
import '../../domain/constants/xp_constants.dart';

/// Remote API for gamification. Mock impl below; replace with real HTTP calls.
abstract class GamificationRemoteDataSource {
  Future<GamificationProfile?> getProfile(String userId);
  Future<CareerHealthScore?> getCareerHealthScore(String studentId);
  Future<void> updateStreak(String userId, String streakType);
  Future<List<LeaderboardEntry>> getLeaderboard(String county, {int limit = 10});
  Future<List<bool>> getWeeklyActivityGrid(String userId);
  Future<List<BadgeModel>> getBadges(String userId);
  Future<XpAwardResult> awardXp(String userId, String eventType, [Map<String, dynamic>? metadata]);
  Future<List<BadgeModel>> checkAndAwardBadges(String userId, String triggerEvent);
}

class GamificationRemoteDataSourceMock implements GamificationRemoteDataSource {
  final Map<String, GamificationProfile> _profiles = {};
  final Map<String, CareerHealthScore> _healthScores = {};

  GamificationProfile _defaultProfile(String userId) {
    final now = DateTime.now();
    final week = List.generate(7, (i) => i < 4);
    return GamificationProfile(
      userId: userId,
      totalXp: 120,
      weeklyXp: 45,
      level: 2,
      levelName: 'Rising Star',
      xpInCurrentLevel: 45,
      xpToNextLevel: 100,
      jobStreak: 3,
      learnStreak: 5,
      lastJobStreakAt: now.subtract(const Duration(hours: 2)),
      lastLearnStreakAt: now.subtract(const Duration(hours: 1)),
      earnedBadgeIds: ['first_step', 'first_assessment'],
      lastActiveAt: now,
      careerHealthScore: 68,
      weeklyActivity: week,
    );
  }

  @override
  Future<GamificationProfile?> getProfile(String userId) async {
    await Future.delayed(const Duration(milliseconds: 200));
    return _profiles[userId] ?? _defaultProfile(userId);
  }

  @override
  Future<CareerHealthScore?> getCareerHealthScore(String studentId) async {
    await Future.delayed(const Duration(milliseconds: 150));
    if (_healthScores.containsKey(studentId)) return _healthScores[studentId];
    return CareerHealthScore(
      total: 68,
      skillsAverage: 72,
      portfolioComplete: 60,
      learningProgress: 50,
      jobActivity: 0.3,
      profileEngagement: 0.2,
      previousTotal: 62,
    );
  }

  @override
  Future<void> updateStreak(String userId, String streakType) async {
    await Future.delayed(const Duration(milliseconds: 100));
    final p = _profiles[userId] ?? _defaultProfile(userId);
    if (streakType == 'job') {
      _profiles[userId] = GamificationProfile(
        userId: p.userId,
        totalXp: p.totalXp,
        weeklyXp: p.weeklyXp,
        level: p.level,
        levelName: p.levelName,
        xpInCurrentLevel: p.xpInCurrentLevel,
        xpToNextLevel: p.xpToNextLevel,
        jobStreak: p.jobStreak + 1,
        learnStreak: p.learnStreak,
        lastJobStreakAt: DateTime.now(),
        lastLearnStreakAt: p.lastLearnStreakAt,
        earnedBadgeIds: p.earnedBadgeIds,
        lastActiveAt: DateTime.now(),
        careerHealthScore: p.careerHealthScore,
        weeklyActivity: p.weeklyActivity,
      );
    } else {
      _profiles[userId] = GamificationProfile(
        userId: p.userId,
        totalXp: p.totalXp,
        weeklyXp: p.weeklyXp,
        level: p.level,
        levelName: p.levelName,
        xpInCurrentLevel: p.xpInCurrentLevel,
        xpToNextLevel: p.xpToNextLevel,
        jobStreak: p.jobStreak,
        learnStreak: p.learnStreak + 1,
        lastJobStreakAt: p.lastJobStreakAt,
        lastLearnStreakAt: DateTime.now(),
        earnedBadgeIds: p.earnedBadgeIds,
        lastActiveAt: DateTime.now(),
        careerHealthScore: p.careerHealthScore,
        weeklyActivity: p.weeklyActivity,
      );
    }
  }

  @override
  Future<List<LeaderboardEntry>> getLeaderboard(String county, {int limit = 10}) async {
    await Future.delayed(const Duration(milliseconds: 250));
    return List.generate(limit.clamp(1, 10), (i) => LeaderboardEntry(
      rank: i + 1,
      userId: 'user-$i',
      displayName: i == 0 ? 'You' : 'User ${i + 1}',
      weeklyXp: 100 - i * 8,
    ));
  }

  @override
  Future<List<bool>> getWeeklyActivityGrid(String userId) async {
    await Future.delayed(const Duration(milliseconds: 100));
    final p = _profiles[userId] ?? _defaultProfile(userId);
    return List.from(p.weeklyActivity);
  }

  @override
  Future<List<BadgeModel>> getBadges(String userId) async {
    await Future.delayed(const Duration(milliseconds: 150));
    final earned = [
      const BadgeModel(id: 'first_step', name: 'First Step', description: 'Completed onboarding', earnedAt: null),
      const BadgeModel(id: 'first_assessment', name: 'First Assessment', description: 'Completed first assessment', earnedAt: null),
    ];
    final locked = [
      const BadgeModel(id: 'job_ready', name: 'Job Ready', requirementText: 'Complete profile 100%'),
      const BadgeModel(id: 'on_fire', name: 'On Fire', requirementText: '7-day streak'),
    ];
    return [...earned, ...locked];
  }

  static int _xpForEvent(String eventType) {
    switch (eventType) {
      case 'daily_login': return XpConstants.dailyLogin;
      case 'assessment_completed': return XpConstants.assessmentCompleted;
      case 'first_assessment': return XpConstants.firstAssessment;
      case 'job_application_submitted': return XpConstants.jobApplicationSubmitted;
      case 'portfolio_item_added': return XpConstants.portfolioItemAdded;
      case 'learning_path_completed': return XpConstants.learningPathCompleted;
      case 'lesson_completed': return XpConstants.lessonCompleted;
      case 'micro_lesson_completed': return XpConstants.microLessonCompleted;
      case 'profile_completed': return XpConstants.profileCompleted;
      case 'referral': return XpConstants.referral;
      case 'badge_earned': return XpConstants.badgeEarned;
      case 'level_up': return XpConstants.levelUp;
      case 'perfect_score': return XpConstants.perfectScore;
      case 'comeback': return XpConstants.comeback;
      default: return 10;
    }
  }

  @override
  Future<XpAwardResult> awardXp(String userId, String eventType, [Map<String, dynamic>? metadata]) async {
    await Future.delayed(const Duration(milliseconds: 150));
    final xp = _xpForEvent(eventType);
    final p = _profiles[userId] ?? _defaultProfile(userId);
    final newTotal = p.totalXp + xp;
    final newWeekly = p.weeklyXp + xp;
    int newLevel = p.level;
    int inLevel = p.xpInCurrentLevel + xp;
    int toNext = p.xpToNextLevel;
    while (inLevel >= toNext && toNext > 0) {
      inLevel -= toNext;
      newLevel++;
      toNext = 100 + newLevel * 50;
    }
    _profiles[userId] = GamificationProfile(
      userId: p.userId,
      totalXp: newTotal,
      weeklyXp: newWeekly,
      level: newLevel,
      levelName: newLevel <= 2 ? 'Rising Star' : 'Champion',
      xpInCurrentLevel: inLevel,
      xpToNextLevel: toNext,
      jobStreak: p.jobStreak,
      learnStreak: p.learnStreak,
      lastJobStreakAt: p.lastJobStreakAt,
      lastLearnStreakAt: p.lastLearnStreakAt,
      earnedBadgeIds: p.earnedBadgeIds,
      lastActiveAt: DateTime.now(),
      careerHealthScore: p.careerHealthScore,
      weeklyActivity: p.weeklyActivity,
    );
    return XpAwardResult(
      newTotal: newTotal,
      xpAwarded: xp,
      leveledUp: newLevel != p.level,
      newLevel: newLevel != p.level ? newLevel : null,
    );
  }

  @override
  Future<List<BadgeModel>> checkAndAwardBadges(String userId, String triggerEvent) async {
    await Future.delayed(const Duration(milliseconds: 100));
    return [];
  }
}
