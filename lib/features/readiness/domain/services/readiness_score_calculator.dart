import '../entities/readiness_entity.dart';
import '../models/readiness_score_config.dart';
import '../models/readiness_score_input.dart';
import '../../../skills/domain/entities/user_skill_entity.dart';

/// Calculates job readiness score from skills, portfolio, and consistency data.
/// Logic is fully configurable via [ReadinessScoreConfig] for research evaluation.
class ReadinessScoreCalculator {
  const ReadinessScoreCalculator({this.config = ReadinessScoreConfig.researchDefault});

  final ReadinessScoreConfig config;

  /// Computes readiness score and optional feedback.
  ReadinessResult calculate(ReadinessScoreInput input) {
    final now = input.referenceDate ?? DateTime.now();
    final breakdown = _computeBreakdown(input, now);
    final total = breakdown.totalScore;
    final feedback = _buildFeedback(breakdown, total);
    return ReadinessResult(
      entity: ReadinessEntity(
        score: total,
        maxScore: config.maxScore,
        feedback: feedback.isEmpty ? null : feedback,
      ),
      breakdown: breakdown,
    );
  }

  /// Score only (no breakdown). Use when breakdown is not needed.
  ReadinessEntity calculateScore(ReadinessScoreInput input) {
    return calculate(input).entity;
  }

  ReadinessScoreBreakdown _computeBreakdown(ReadinessScoreInput input, DateTime now) {
    final completedSkillsScore = _scoreCompletedSkills(input.userSkills);
    final skillProgressScore = _scoreSkillProgress(input.userSkills);
    final portfolioScore = _scorePortfolio(input.portfolioItemCount);
    final consistencyScore = _scoreLearningConsistency(input.activityDates, now);

    final w1 = config.weightCompletedSkills;
    final w2 = config.weightSkillProgress;
    final w3 = config.weightPortfolio;
    final w4 = config.weightLearningConsistency;

    final weighted = (completedSkillsScore * w1) +
        (skillProgressScore * w2) +
        (portfolioScore * w3) +
        (consistencyScore * w4);
    final total = (weighted * config.maxScore / 100).round().clamp(0, config.maxScore);
    final uniqueActiveDays = _uniqueActiveDaysInWindow(input.activityDates, now, config.consistencyWindowDays);

    return ReadinessScoreBreakdown(
      totalScore: total,
      completedSkillsScore: completedSkillsScore,
      skillProgressScore: skillProgressScore,
      portfolioScore: portfolioScore,
      learningConsistencyScore: consistencyScore,
      completedSkillsCount: input.userSkills.length,
      portfolioItemCount: input.portfolioItemCount,
      uniqueActiveDays: uniqueActiveDays,
    );
  }

  /// Completed skills: 0–100 based on count vs maxSkillsForFullScore.
  double _scoreCompletedSkills(List<UserSkillEntity> userSkills) {
    final count = userSkills.length;
    if (count < config.minSkillsForAnyScore) return 0;
    final range = config.maxSkillsForFullScore - config.minSkillsForAnyScore;
    if (range <= 0) return count >= config.maxSkillsForFullScore ? 100 : 0;
    final progress = (count - config.minSkillsForAnyScore) / range;
    return (progress * 100).clamp(0.0, 100.0).toDouble();
  }

  /// Skill progress: average of per-skill progress (from proficiency level).
  double _scoreSkillProgress(List<UserSkillEntity> userSkills) {
    if (userSkills.isEmpty) return 0;
    int sum = 0;
    for (final s in userSkills) {
      final level = s.proficiencyLevel?.toLowerCase().trim();
      sum += config.proficiencyLevelScores[level ?? ''] ?? config.defaultProficiencyScore;
    }
    return sum / userSkills.length;
  }

  /// Portfolio: 0–100 based on item count vs portfolioItemsForFullScore.
  double _scorePortfolio(int portfolioItemCount) {
    if (portfolioItemCount <= config.minPortfolioItemsForAnyScore) return 0;
    final range = config.portfolioItemsForFullScore - config.minPortfolioItemsForAnyScore;
    if (range <= 0) return portfolioItemCount >= config.portfolioItemsForFullScore ? 100 : 0;
    final progress = (portfolioItemCount - config.minPortfolioItemsForAnyScore) / range;
    return (progress * 100).clamp(0.0, 100.0).toDouble();
  }

  /// Learning consistency: 0–100 from unique active days in window.
  double _scoreLearningConsistency(List<DateTime> activityDates, DateTime now) {
    final days = _uniqueActiveDaysInWindow(activityDates, now, config.consistencyWindowDays);
    if (days <= config.minConsistencyDaysForAnyScore) return 0;
    final range = config.consistencyTargetDaysForFullScore - config.minConsistencyDaysForAnyScore;
    if (range <= 0) return days >= config.consistencyTargetDaysForFullScore ? 100 : 0;
    final progress = (days - config.minConsistencyDaysForAnyScore) / range;
    return (progress * 100).clamp(0.0, 100.0).toDouble();
  }

  int _uniqueActiveDaysInWindow(List<DateTime> activityDates, DateTime now, int windowDays) {
    final start = now.subtract(Duration(days: windowDays));
    final set = <int>{};
    for (final d in activityDates) {
      if (d.isAfter(start) || d.isAtSameMomentAs(start)) {
        set.add(DateTime(d.year, d.month, d.day).millisecondsSinceEpoch);
      }
    }
    return set.length;
  }

  String _buildFeedback(ReadinessScoreBreakdown b, int total) {
    final parts = <String>[];
    if (b.completedSkillsScore < 50 && b.completedSkillsCount < config.maxSkillsForFullScore) {
      parts.add('Add more skills to improve (${b.completedSkillsCount} so far).');
    }
    if (b.skillProgressScore < 50 && b.completedSkillsCount > 0) {
      parts.add('Level up skill proficiency for a higher score.');
    }
    if (b.portfolioScore < 50 && b.portfolioItemCount < config.portfolioItemsForFullScore) {
      parts.add('Add portfolio items (${b.portfolioItemCount} of ${config.portfolioItemsForFullScore} for full marks).');
    }
    if (b.learningConsistencyScore < 50 && b.uniqueActiveDays < config.consistencyTargetDaysForFullScore) {
      parts.add('Stay consistent: aim for ${config.consistencyTargetDaysForFullScore} active days in the last ${config.consistencyWindowDays} days.');
    }
    if (total >= 70 && parts.isEmpty) {
      parts.add('You\'re in good shape. Keep it up.');
    }
    return parts.join(' ');
  }
}

/// Result of a readiness calculation (entity + optional breakdown for research).
class ReadinessResult {
  const ReadinessResult({required this.entity, required this.breakdown});

  final ReadinessEntity entity;
  final ReadinessScoreBreakdown breakdown;
}
