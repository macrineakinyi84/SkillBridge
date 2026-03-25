import '../models/readiness_score_input.dart';
import '../services/readiness_score_calculator.dart';

/// Use case: compute readiness score from input using the configured calculator.
/// Callers build [ReadinessScoreInput] from UserSkillRepository, PortfolioRepository, etc.
class CalculateReadinessScore {
  const CalculateReadinessScore(this._calculator);
  final ReadinessScoreCalculator _calculator;

  /// Returns score entity and breakdown (for research / debugging).
  ReadinessResult call(ReadinessScoreInput input) => _calculator.calculate(input);
}
