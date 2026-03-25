const scoring = require('./scoring.service');
const db = require('../../lib/db');
const xpService = require('../gamification/xp.service');
const achievementService = require('../gamification/achievement.service');

function getCategories() {
  return [
    { id: 'digital-literacy', name: 'Digital Literacy', icon: 'computer' },
    { id: 'communication', name: 'Communication', icon: 'voice' },
    { id: 'business-entrepreneurship', name: 'Business & Entrepreneurship', icon: 'store' },
    { id: 'technical-ict', name: 'Technical (ICT)', icon: 'code' },
    { id: 'soft-skills-leadership', name: 'Soft Skills & Leadership', icon: 'groups' },
  ];
}

function seededRandom(seed) {
  let s = seed;
  return function () {
    s = (s * 9301 + 49297) % 233280;
    return s / 233280;
  };
}

function getQuestions(categoryId) {
  const count = 15;
  const questions = [];
  for (let i = 0; i < count; i++) {
    questions.push({
      id: `${categoryId}-q-${i}`,
      text: `Sample question ${i + 1} for ${categoryId}?`,
      options: ['Option A', 'Option B', 'Option C', 'Option D'],
      correctIndex: i % 4,
      difficulty: i % 3 === 0 ? 'hard' : i % 3 === 1 ? 'medium' : 'easy',
    });
  }
  const rng = seededRandom(categoryId.length * 1000 + Date.now());
  for (let i = questions.length - 1; i > 0; i--) {
    const j = Math.floor(rng() * (i + 1));
    [questions[i], questions[j]] = [questions[j], questions[i]];
  }
  return questions.slice(0, 15);
}

async function submitAssessment(studentId, categoryId, answers) {
  const questions = getQuestions(categoryId);
  const { rawScore, maxPossibleScore } = scoring.calculateRawScore(answers, questions);
  const normalisedScore = scoring.normaliseScore(rawScore, maxPossibleScore);
  const tier = scoring.assignTier(normalisedScore);

  // 2. Update or create SkillScore record
  await upsertSkillScore(studentId, categoryId, normalisedScore);

  // 3. Update or create Assessment record
  const previousScore = await getPreviousScore(studentId, categoryId);
  await saveAssessment(studentId, categoryId, { normalisedScore, rawScore, maxPossibleScore, tier });

  // 4. Identify gaps → LearningRecommendation (top 3 per gap)
  const skillScores = await getSkillScores(studentId);
  const benchmarks = { [categoryId]: 60 };
  const gaps = scoring.identifyGaps(skillScores, benchmarks);
  const recommendations = gaps.slice(0, 3).map(g => ({ categoryId: g.categoryId, gapPoints: g.gapPoints, title: `Improve ${g.categoryId}` }));

  // 5. Recalculate job matches
  await triggerJobMatching(studentId);

  // 6. Award XP: 50 base + 30 if improved
  const xpAwarded = 50 + (normalisedScore > (previousScore || 0) ? 30 : 0);
  await xpService.awardXp(studentId, 'assessment_completed', { xp: xpAwarded, score: normalisedScore });

  // 7. Check badges
  await achievementService.checkAndAwardBadges(studentId, { first_assessment: true, perfect_score: normalisedScore === 100 });

  // 8. Update career health score
  await updateCareerHealth(studentId);

  const radarData = scoring.generateRadarData(skillScores);

  return {
    normalisedScore,
    rawScore,
    maxPossibleScore,
    tier,
    previousScore: previousScore ?? null,
    scoreChange: previousScore != null ? normalisedScore - previousScore : null,
    gaps,
    recommendations,
    xpAwarded,
    radarData,
  };
}

async function upsertSkillScore(studentId, categoryId, currentScore) {
  return db.upsertSkillScore(studentId, categoryId, currentScore);
}

async function getPreviousScore(studentId, categoryId) {
  return db.getPreviousScore(studentId, categoryId);
}

async function saveAssessment(studentId, categoryId, data) {
  return db.saveAssessment(studentId, categoryId, data);
}

async function getSkillScores(studentId) {
  return db.getSkillScores(studentId);
}

async function triggerJobMatching(studentId) {
  // TODO: call matching.service when implemented
}

async function updateCareerHealth(studentId) {
  // TODO: recalc career health
}

module.exports = {
  getCategories,
  getQuestions,
  submitAssessment,
};
