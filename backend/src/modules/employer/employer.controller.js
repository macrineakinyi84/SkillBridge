/**
 * Employer-only controller. Call only from routes that use authenticate + requireEmployer.
 * Dashboard, candidate profile (what employers see), talent pool search.
 */
const db = require('../../lib/db');

/**
 * GET /api/employer/dashboard
 * Returns stats and recent activity. When Job/Application models exist, replace with real counts.
 */
async function getDashboard(employerId) {
  return {
    activeListingsCount: 0,
    totalApplicantsCount: 0,
    newApplicantsThisWeek: 0,
    avgMatchScore: 0,
    recentApplicants: [],
    newMatchesNotification: null,
  };
}

/**
 * GET /api/employer/candidates/:userId
 * Candidate profile — what employers see (student's public profile + skills + assessment summary).
 * Only students are visible; 404 if not found or not a student.
 */
async function getCandidateProfile(userId) {
  const user = await db.getStudentById(userId);
  if (!user) return null;

  const [skillScores, assessmentScores] = await Promise.all([
    db.getSkillScores(userId),
    db.getAssessmentScores(userId),
  ]);

  const avgScore =
    skillScores.length > 0
      ? Math.round(
          skillScores.reduce((sum, s) => sum + s.currentScore, 0) / skillScores.length
        )
      : null;

  return {
    id: user.id,
    displayName: user.displayName || 'Candidate',
    email: user.email,
    county: user.county,
    photoUrl: user.photoUrl,
    level: user.level,
    levelName: user.levelName,
    totalXp: user.totalXp,
    jobStreak: user.jobStreak,
    learnStreak: user.learnStreak,
    skillScores: skillScores.map((s) => ({ categoryId: s.categoryId, currentScore: s.currentScore })),
    assessmentCount: assessmentScores.length,
    averageScore: avgScore,
  };
}

/**
 * GET /api/employer/talent-pool
 * Query: county, categoryId, q (search displayName/email), limit, offset
 * Returns paginated list of students (talent pool search).
 */
async function getTalentPoolSearch({ county, categoryId, q, limit, offset }) {
  const { items, total } = await db.getStudentsForTalentPool({
    county: county || undefined,
    categoryId: categoryId || undefined,
    search: q || undefined,
    limit: limit ? parseInt(limit, 10) : 20,
    offset: offset ? parseInt(offset, 10) : 0,
  });

  return {
    items: items.map((u) => ({
      id: u.id,
      displayName: u.displayName || 'Candidate',
      county: u.county,
      photoUrl: u.photoUrl,
      level: u.level,
      levelName: u.levelName,
      totalXp: u.totalXp,
    })),
    total,
  };
}

module.exports = {
  getDashboard,
  getCandidateProfile,
  getTalentPoolSearch,
};
