import 'package:equatable/equatable.dart';

/// Configurable parameters for readiness score calculation.
/// Tune these for research evaluation and A/B testing.
class ReadinessScoreConfig extends Equatable {
  const ReadinessScoreConfig({
    this.maxScore = 100,
    this.weightCompletedSkills = 0.25,
    this.weightSkillProgress = 0.25,
    this.weightPortfolio = 0.25,
    this.weightLearningConsistency = 0.25,
    this.maxSkillsForFullScore = 10,
    this.minSkillsForAnyScore = 1,
    Map<String, int>? proficiencyLevelScores,
    this.defaultProficiencyScore = 25,
    this.portfolioItemsForFullScore = 5,
    this.minPortfolioItemsForAnyScore = 0,
    this.consistencyWindowDays = 30,
    this.consistencyTargetDaysForFullScore = 15,
    this.minConsistencyDaysForAnyScore = 0,
  }) : proficiencyLevelScores = proficiencyLevelScores ??
            const {
              'beginner': 25,
              'intermediate': 50,
              'advanced': 75,
              'expert': 100,
            };

  final int maxScore;
  final double weightCompletedSkills;
  final double weightSkillProgress;
  final double weightPortfolio;
  final double weightLearningConsistency;
  final int maxSkillsForFullScore;
  final int minSkillsForAnyScore;
  final Map<String, int> proficiencyLevelScores;
  final int defaultProficiencyScore;
  final int portfolioItemsForFullScore;
  final int minPortfolioItemsForAnyScore;
  final int consistencyWindowDays;
  final int consistencyTargetDaysForFullScore;
  final int minConsistencyDaysForAnyScore;

  /// Preset: equal weights, standard thresholds.
  static const ReadinessScoreConfig researchDefault = ReadinessScoreConfig();

  /// Preset: skills-heavy (e.g. for technical roles).
  static ReadinessScoreConfig get researchSkillsHeavy => ReadinessScoreConfig(
        weightCompletedSkills: 0.35,
        weightSkillProgress: 0.35,
        weightPortfolio: 0.15,
        weightLearningConsistency: 0.15,
      );

  /// Preset: portfolio-heavy (e.g. for creative roles).
  static ReadinessScoreConfig get researchPortfolioHeavy => ReadinessScoreConfig(
        weightCompletedSkills: 0.15,
        weightSkillProgress: 0.15,
        weightPortfolio: 0.45,
        weightLearningConsistency: 0.25,
      );

  @override
  List<Object?> get props => [
        maxScore,
        weightCompletedSkills,
        weightSkillProgress,
        weightPortfolio,
        weightLearningConsistency,
        maxSkillsForFullScore,
        proficiencyLevelScores,
        portfolioItemsForFullScore,
        consistencyWindowDays,
        consistencyTargetDaysForFullScore,
      ];
}
