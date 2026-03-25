const db = require('../../lib/db');

/**
 * Career health score: composite 0-100 from skills, portfolio, learning, job activity, engagement.
 * Weights: skills 30%, portfolio 25%, learning 20%, job 15%, profile 10%.
 */
async function getCareerHealthScore(studentId) {
  const data = await getStudentData(studentId);
  const skillsAverage = (data.skillScores || []).reduce((a, s) => a + (s.currentScore || 0), 0) / Math.max((data.skillScores || []).length, 1);
  const portfolioComplete = data.completenessScore ?? 0;
  const learningProgress = (data.learningPaths || []).reduce((a, p) => a + (p.completionPct || 0), 0) / Math.max((data.learningPaths || []).length, 1);
  const jobActivity = Math.min(1, ((data.applicationsLast30Days || 0) / 10));
  const profileEngagement = Math.min(1, ((data.profileViewsLast7Days || 0) / 5));

  const total = Math.round(
    skillsAverage * 0.30 +
    portfolioComplete * 0.25 +
    learningProgress * 0.20 +
    jobActivity * 100 * 0.15 +
    profileEngagement * 100 * 0.10
  );

  return {
    total: Math.min(100, Math.max(0, total)),
    skillsAverage,
    portfolioComplete,
    learningProgress,
    jobActivity,
    profileEngagement,
  };
}

/**
 * Update streak: if lastActiveAt was yesterday, increment; else reset to 1.
 * @param {string} userId
 * @param {string} streakType - 'job' | 'learn'
 */
async function updateStreak(userId, streakType) {
  const profile = await db.getGamificationProfile(userId);
  const lastAt = streakType === 'job' ? profile.lastJobStreakAt : profile.lastLearnStreakAt;
  const now = new Date();
  const yesterday = new Date(now);
  yesterday.setDate(yesterday.getDate() - 1);

  const sameDay = (a, b) => a.getFullYear() === b.getFullYear() && a.getMonth() === b.getMonth() && a.getDate() === b.getDate();
  let newCount = 1;
  if (lastAt) {
    const last = new Date(lastAt);
    if (sameDay(last, yesterday)) newCount = (streakType === 'job' ? profile.jobStreak : profile.learnStreak) + 1;
  }

  if (streakType === 'job') {
    await db.updateGamificationProfile(userId, { jobStreak: newCount, lastJobStreakAt: now });
  } else {
    await db.updateGamificationProfile(userId, { learnStreak: newCount, lastLearnStreakAt: now });
  }
  return { streak: newCount };
}

/**
 * Top users by weeklyXp in county. Reset weeklyXp every Monday 00:00 EAT.
 */
async function getLeaderboard(county, limit = 10) {
  return db.getLeaderboardByWeeklyXp(county, limit);
}

/**
 * Last 7 days activity for heatmap. [oldest, ..., today].
 */
async function getWeeklyActivityGrid(userId) {
  // TODO: from activity/events, aggregate per day for last 7 days
  return [false, false, false, false, false, false, false];
}

async function getStudentData(studentId) {
  return {};
}

async function getProfile(userId) {
  return db.getGamificationProfile(userId);
}

async function updateProfile(userId, data) {
  return db.updateGamificationProfile(userId, data);
}

module.exports = {
  getCareerHealthScore,
  updateStreak,
  getLeaderboard,
  getWeeklyActivityGrid,
};
