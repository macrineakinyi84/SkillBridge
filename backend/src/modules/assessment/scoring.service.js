const DIFFICULTY_POINTS = { easy: 1, medium: 2, hard: 3 };

function calculateRawScore(answers, questions) {
  let rawScore = 0;
  let maxPossibleScore = 0;
  for (let i = 0; i < questions.length; i++) {
    const q = questions[i];
    const pts = DIFFICULTY_POINTS[q.difficulty] || 1;
    maxPossibleScore += pts;
    const answer = answers[q.id] ?? answers[i];
    const correctIndex = q.correctIndex ?? q.correct;
    if (answer === correctIndex) rawScore += pts;
  }
  return { rawScore, maxPossibleScore };
}

function normaliseScore(rawScore, maxPossibleScore) {
  if (maxPossibleScore <= 0) return 0;
  return Math.round((rawScore / maxPossibleScore) * 100);
}

function assignTier(score) {
  if (score >= 80) return 'Advanced';
  if (score >= 60) return 'Proficient';
  if (score >= 40) return 'Developing';
  return 'Beginner';
}

function identifyGaps(skillScores, benchmarks) {
  const gaps = [];
  for (const catId of Object.keys(benchmarks || {})) {
    const userScore = (skillScores || []).find(s => s.categoryId === catId)?.currentScore ?? 0;
    const bench = benchmarks[catId] ?? 60;
    const gap = bench - userScore;
    if (gap > 0) gaps.push({ categoryId: catId, gapPoints: gap, benchmark: bench, currentScore: userScore });
  }
  gaps.sort((a, b) => b.gapPoints - a.gapPoints);
  return gaps;
}

function generateRadarData(skillScores) {
  const cats = ['digital-literacy', 'communication', 'business-entrepreneurship', 'technical-ict', 'soft-skills-leadership'];
  return cats.map(catId => ((skillScores || []).find(s => s.categoryId === catId)?.currentScore ?? 0) / 100);
}

module.exports = { calculateRawScore, normaliseScore, assignTier, identifyGaps, generateRadarData, DIFFICULTY_POINTS };
