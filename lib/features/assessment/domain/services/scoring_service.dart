/// Pure scoring logic for assessments (mirrors backend scoring.service.js).
/// Used by assessment repository and tests.

class SkillScore {
  const SkillScore({required this.categoryId, required this.currentScore});
  final String categoryId;
  final int currentScore;
}

class GapItemResult {
  const GapItemResult({
    required this.categoryId,
    required this.gapPoints,
    this.benchmark,
    this.currentScore,
  });
  final String categoryId;
  final int gapPoints;
  final int? benchmark;
  final int? currentScore;
}

class ScoringService {
  ScoringService._();

  static const Map<String, int> difficultyPoints = {'easy': 1, 'medium': 2, 'hard': 3};

  /// 0 raw returns 0; maxRaw returns 100; mid returns correct value.
  static int normaliseScore(int rawScore, int maxPossibleScore) {
    if (maxPossibleScore <= 0) return 0;
    return (rawScore / maxPossibleScore * 100).round().clamp(0, 100);
  }

  /// assignTier: 0=Beginner, 39=Beginner, 40=Developing, 60=Proficient, 80=Advanced
  static String assignTier(int score) {
    if (score >= 80) return 'Advanced';
    if (score >= 60) return 'Proficient';
    if (score >= 40) return 'Developing';
    return 'Beginner';
  }

  /// Returns gaps sorted by severity (highest gap first); excludes no-gap categories.
  static List<GapItemResult> identifyGaps(
    List<SkillScore> skillScores,
    Map<String, int> benchmarks,
  ) {
    final gaps = <GapItemResult>[];
    for (final entry in benchmarks.entries) {
      final categoryId = entry.key;
      final bench = entry.value;
      final matching = skillScores.where((s) => s.categoryId == categoryId).toList();
      final userScore = matching.isEmpty ? 0 : matching.first.currentScore;
      final gap = bench - userScore;
      if (gap > 0) {
        gaps.add(GapItemResult(
          categoryId: categoryId,
          gapPoints: gap,
          benchmark: bench,
          currentScore: userScore,
        ));
      }
    }
    gaps.sort((a, b) => b.gapPoints.compareTo(a.gapPoints));
    return gaps;
  }
}
