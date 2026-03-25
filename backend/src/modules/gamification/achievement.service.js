async function checkAndAwardBadges(userId, triggerEvent) {
  const userState = await getUserState(userId);
  const earned = await getEarnedBadgeIds(userId);
  const newlyEarned = [];
  const badges = [
    { id: 'first_assessment', check: () => userState.assessmentCount === 1 },
    { id: 'job_ready', check: () => userState.completenessScore === 100 },
    { id: 'fast_mover', check: () => userState.applicationWithin24hOfMatch === true },
    { id: 'scholar', check: () => (userState.completedLearningPathsCount || 0) >= 5 },
    { id: 'on_fire', check: () => (userState.jobStreakCurrentCount || 0) >= 7 || (userState.learnStreakCurrentCount || 0) >= 7 },
    { id: 'top_talent', check: () => (userState.jobMatches || []).some(m => m.matchScore >= 85) },
    { id: 'connector', check: () => (userState.referralCount || 0) >= 1 },
    { id: 'comeback', check: () => userState.wasInactive7PlusDays && userState.justCompletedAssessment === true },
    { id: 'perfect_score', check: () => (userState.assessmentScores || []).some(s => s.normalisedScore === 100) },
    { id: 'county_leader', check: () => (userState.countyRank || 99) <= 3 },
  ];
  for (const badge of badges) {
    if (earned.has(badge.id)) continue;
    if (badge.check()) {
      await awardBadge(userId, badge.id);
      newlyEarned.push({ id: badge.id, name: badge.id, earnedAt: new Date() });
      earned.add(badge.id);
    }
  }
  return newlyEarned;
}

const db = require('../../lib/db');

async function getUserState(userId) {
  const [assessmentCount, skillScores, profile, assessmentScores] = await Promise.all([
    db.getAssessmentCount(userId),
    db.getSkillScores(userId),
    db.getGamificationProfile(userId),
    db.getAssessmentScores(userId),
  ]);
  return {
    assessmentCount,
    skillScores: skillScores.map((s) => ({ categoryId: s.categoryId, currentScore: s.currentScore })),
    assessmentScores,
    jobStreakCurrentCount: profile.jobStreak ?? 0,
    learnStreakCurrentCount: profile.learnStreak ?? 0,
  };
}

async function getEarnedBadgeIds(userId) {
  return db.getEarnedBadgeIds(userId);
}

async function awardBadge(userId, badgeId) {
  return db.awardBadge(userId, badgeId);
}

module.exports = { checkAndAwardBadges };
