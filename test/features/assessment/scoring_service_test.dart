import 'package:flutter_test/flutter_test.dart';
import 'package:skillbridge/features/assessment/domain/services/scoring_service.dart';

void main() {
  group('ScoringService', () {
    group('normaliseScore', () {
      test('0 raw returns 0', () {
        expect(ScoringService.normaliseScore(0, 10), 0);
        expect(ScoringService.normaliseScore(0, 0), 0);
      });

      test('maxRaw returns 100', () {
        expect(ScoringService.normaliseScore(10, 10), 100);
        expect(ScoringService.normaliseScore(7, 7), 100);
      });

      test('mid returns correct value', () {
        expect(ScoringService.normaliseScore(5, 10), 50);
        expect(ScoringService.normaliseScore(3, 4), 75);
        expect(ScoringService.normaliseScore(1, 3), 33);
      });

      test('maxPossibleScore 0 returns 0', () {
        expect(ScoringService.normaliseScore(5, 0), 0);
      });
    });

    group('assignTier', () {
      test('0 and 39 = Beginner', () {
        expect(ScoringService.assignTier(0), 'Beginner');
        expect(ScoringService.assignTier(39), 'Beginner');
      });

      test('40 = Developing', () {
        expect(ScoringService.assignTier(40), 'Developing');
        expect(ScoringService.assignTier(59), 'Developing');
      });

      test('60 = Proficient', () {
        expect(ScoringService.assignTier(60), 'Proficient');
        expect(ScoringService.assignTier(79), 'Proficient');
      });

      test('80 = Advanced', () {
        expect(ScoringService.assignTier(80), 'Advanced');
        expect(ScoringService.assignTier(100), 'Advanced');
      });
    });

    group('identifyGaps', () {
      test('returns sorted by severity, excludes no-gap categories', () {
        final skillScores = [
          const SkillScore(categoryId: 'a', currentScore: 50),
          const SkillScore(categoryId: 'b', currentScore: 70),
          const SkillScore(categoryId: 'c', currentScore: 40),
        ];
        final benchmarks = {'a': 60, 'b': 70, 'c': 80};

        final gaps = ScoringService.identifyGaps(skillScores, benchmarks);

        expect(gaps.length, 2);
        expect(gaps[0].categoryId, 'c');
        expect(gaps[0].gapPoints, 40);
        expect(gaps[1].categoryId, 'a');
        expect(gaps[1].gapPoints, 10);
      });

      test('empty skillScores uses 0 for missing categories', () {
        final gaps = ScoringService.identifyGaps([], {'x': 50});
        expect(gaps.length, 1);
        expect(gaps[0].categoryId, 'x');
        expect(gaps[0].gapPoints, 50);
        expect(gaps[0].currentScore, 0);
      });

      test('no gap when score meets benchmark', () {
        final gaps = ScoringService.identifyGaps(
          [const SkillScore(categoryId: 'a', currentScore: 60)],
          {'a': 60},
        );
        expect(gaps, isEmpty);
      });
    });
  });
}
