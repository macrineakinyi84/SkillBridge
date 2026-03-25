const {
  calculateRawScore,
  normaliseScore,
  assignTier,
  identifyGaps,
  generateRadarData,
  DIFFICULTY_POINTS,
} = require('../src/modules/assessment/scoring.service');

describe('scoring.service', () => {
  describe('normaliseScore', () => {
    it('returns 0 when maxPossibleScore is 0', () => {
      expect(normaliseScore(0, 0)).toBe(0);
      expect(normaliseScore(5, 0)).toBe(0);
    });

    it('returns 100 when raw equals max', () => {
      expect(normaliseScore(10, 10)).toBe(100);
      expect(normaliseScore(7, 7)).toBe(100);
    });

    it('returns correct mid value', () => {
      expect(normaliseScore(5, 10)).toBe(50);
      expect(normaliseScore(3, 4)).toBe(75);
    });
  });

  describe('assignTier', () => {
    it('0 and 39 = Beginner', () => {
      expect(assignTier(0)).toBe('Beginner');
      expect(assignTier(39)).toBe('Beginner');
    });

    it('40 = Developing, 60 = Proficient, 80 = Advanced', () => {
      expect(assignTier(40)).toBe('Developing');
      expect(assignTier(59)).toBe('Developing');
      expect(assignTier(60)).toBe('Proficient');
      expect(assignTier(79)).toBe('Proficient');
      expect(assignTier(80)).toBe('Advanced');
      expect(assignTier(100)).toBe('Advanced');
    });
  });

  describe('identifyGaps', () => {
    it('returns sorted by severity, excludes no-gap', () => {
      const skillScores = [
        { categoryId: 'a', currentScore: 50 },
        { categoryId: 'b', currentScore: 70 },
        { categoryId: 'c', currentScore: 40 },
      ];
      const benchmarks = { a: 60, b: 70, c: 80 };
      const gaps = identifyGaps(skillScores, benchmarks);
      expect(gaps).toHaveLength(2);
      expect(gaps[0].categoryId).toBe('c');
      expect(gaps[0].gapPoints).toBe(40);
      expect(gaps[1].categoryId).toBe('a');
      expect(gaps[1].gapPoints).toBe(10);
    });

    it('handles empty skillScores', () => {
      const gaps = identifyGaps([], { x: 50 });
      expect(gaps).toHaveLength(1);
      expect(gaps[0].categoryId).toBe('x');
      expect(gaps[0].gapPoints).toBe(50);
      expect(gaps[0].currentScore).toBe(0);
    });
  });

  describe('calculateRawScore', () => {
    it('sums points for correct answers by difficulty', () => {
      const questions = [
        { id: 'q1', difficulty: 'easy', correctIndex: 0 },
        { id: 'q2', difficulty: 'medium', correctIndex: 1 },
        { id: 'q3', difficulty: 'hard', correctIndex: 2 },
      ];
      const answers = { q1: 0, q2: 1, q3: 2 };
      const { rawScore, maxPossibleScore } = calculateRawScore(answers, questions);
      const expectedScore = DIFFICULTY_POINTS.easy + DIFFICULTY_POINTS.medium + DIFFICULTY_POINTS.hard;
      expect(rawScore).toBe(expectedScore);
      expect(maxPossibleScore).toBe(expectedScore);
    });

    it('wrong answers get 0 points', () => {
      const questions = [{ id: 'q1', difficulty: 'easy', correctIndex: 0 }];
      const answers = { q1: 1 };
      const { rawScore } = calculateRawScore(answers, questions);
      expect(rawScore).toBe(0);
    });
  });
});
