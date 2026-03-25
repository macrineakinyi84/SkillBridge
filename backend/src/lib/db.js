/**
 * Centralised Prisma-based data access. Use from services; never create PrismaClient in routes.
 * When prisma is null (no DATABASE_URL), functions return defaults / no-ops.
 */
const prisma = require('./prisma');

async function upsertSkillScore(userId, categoryId, currentScore) {
  if (!prisma) return;
  await prisma.skillScore.upsert({
    where: { userId_categoryId: { userId, categoryId } },
    create: { userId, categoryId, currentScore },
    update: { currentScore, updatedAt: new Date() },
  });
}

async function getSkillScores(userId) {
  if (!prisma) return [];
  const rows = await prisma.skillScore.findMany({
    where: { userId },
    orderBy: { updatedAt: 'desc' },
  });
  return rows.map((r) => ({ categoryId: r.categoryId, currentScore: r.currentScore }));
}

async function getPreviousScore(userId, categoryId) {
  if (!prisma) return null;
  const last = await prisma.assessment.findFirst({
    where: { userId, categoryId },
    orderBy: { createdAt: 'desc' },
    select: { normalisedScore: true },
  });
  return last ? last.normalisedScore : null;
}

async function saveAssessment(userId, categoryId, data) {
  if (!prisma) return;
  await prisma.assessment.create({
    data: {
      userId,
      categoryId,
      normalisedScore: data.normalisedScore,
      rawScore: data.rawScore,
      maxPossibleScore: data.maxPossibleScore,
      tier: data.tier,
    },
  });
}

async function getGamificationProfile(userId) {
  if (!prisma) return { totalXp: 0, weeklyXp: 0, level: 1, jobStreak: 0, learnStreak: 0 };
  const user = await prisma.user.findUnique({
    where: { id: userId },
    select: {
      totalXp: true,
      weeklyXp: true,
      level: true,
      levelName: true,
      jobStreak: true,
      learnStreak: true,
      lastJobStreakAt: true,
      lastLearnStreakAt: true,
    },
  });
  if (!user) return { totalXp: 0, weeklyXp: 0, level: 1, jobStreak: 0, learnStreak: 0 };
  return user;
}

async function updateGamificationProfile(userId, data) {
  if (!prisma) return;
  await prisma.user.update({
    where: { id: userId },
    data: {
      ...(data.totalXp != null && { totalXp: data.totalXp }),
      ...(data.weeklyXp != null && { weeklyXp: data.weeklyXp }),
      ...(data.level != null && { level: data.level }),
      ...(data.levelName != null && { levelName: data.levelName }),
      ...(data.jobStreak != null && { jobStreak: data.jobStreak }),
      ...(data.learnStreak != null && { learnStreak: data.learnStreak }),
      ...(data.lastJobStreakAt !== undefined && { lastJobStreakAt: data.lastJobStreakAt }),
      ...(data.lastLearnStreakAt !== undefined && { lastLearnStreakAt: data.lastLearnStreakAt }),
    },
  });
}

async function logXpEvent(userId, eventType, xpAwarded, metadata = {}) {
  if (!prisma) return;
  await prisma.xpEvent.create({
    data: { userId, eventType, xpAwarded, metadata },
  });
}

async function getEarnedBadgeIds(userId) {
  if (!prisma) return new Set();
  const badges = await prisma.userBadge.findMany({
    where: { userId },
    select: { badgeId: true },
  });
  return new Set(badges.map((b) => b.badgeId));
}

async function awardBadge(userId, badgeId) {
  if (!prisma) return;
  await prisma.userBadge.upsert({
    where: {
      userId_badgeId: { userId, badgeId },
    },
    create: { userId, badgeId },
    update: {},
  });
}

async function getLeaderboardByWeeklyXp(county, limit = 10) {
  if (!prisma) return [];
  const users = await prisma.user.findMany({
    where: county ? { county } : {},
    orderBy: { weeklyXp: 'desc' },
    take: limit,
    select: {
      id: true,
      email: true,
      displayName: true,
      weeklyXp: true,
      level: true,
      levelName: true,
      county: true,
    },
  });
  return users;
}

async function getAssessmentCount(userId) {
  if (!prisma) return 0;
  return prisma.assessment.count({ where: { userId } });
}

async function getAssessmentScores(userId) {
  if (!prisma) return [];
  const list = await prisma.assessment.findMany({
    where: { userId },
    select: { normalisedScore: true },
    orderBy: { createdAt: 'desc' },
  });
  return list.map((a) => ({ normalisedScore: a.normalisedScore }));
}

/** Get a student user by id; returns null if not found or not a student. For employer candidate profile. */
async function getStudentById(userId) {
  if (!prisma) return null;
  const user = await prisma.user.findFirst({
    where: { id: userId, role: 'student' },
    select: {
      id: true,
      email: true,
      displayName: true,
      county: true,
      photoUrl: true,
      totalXp: true,
      level: true,
      levelName: true,
      jobStreak: true,
      learnStreak: true,
    },
  });
  return user;
}

/** Talent pool: list students with optional filters. For employer search. */
async function getStudentsForTalentPool({ county, categoryId, search, limit = 20, offset = 0 } = {}) {
  if (!prisma) return { items: [], total: 0 };
  const where = { role: 'student' };
  if (county) where.county = county;
  if (categoryId) where.skillScores = { some: { categoryId } };
  if (search && search.trim()) {
    where.OR = [
      { displayName: { contains: search.trim(), mode: 'insensitive' } },
      { email: { contains: search.trim(), mode: 'insensitive' } },
    ];
  }
  const [items, total] = await Promise.all([
    prisma.user.findMany({
      where,
      select: {
        id: true,
        displayName: true,
        county: true,
        photoUrl: true,
        level: true,
        levelName: true,
        totalXp: true,
      },
      orderBy: { totalXp: 'desc' },
      take: Math.min(limit, 100),
      skip: offset,
    }),
    prisma.user.count({ where }),
  ]);
  return { items, total };
}

module.exports = {
  upsertSkillScore,
  getSkillScores,
  getPreviousScore,
  saveAssessment,
  getGamificationProfile,
  updateGamificationProfile,
  logXpEvent,
  getEarnedBadgeIds,
  awardBadge,
  getLeaderboardByWeeklyXp,
  getAssessmentCount,
  getAssessmentScores,
  getStudentById,
  getStudentsForTalentPool,
};
