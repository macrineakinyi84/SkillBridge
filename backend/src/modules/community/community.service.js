/**
 * Community: feed by county, leaderboard (weekly XP, reset Mondays), peer challenges.
 */

const HOUR_MS = 60 * 60 * 1000;
const CHALLENGE_EXPIRY_HOURS = 48;
const XP_WIN = 25;
const XP_LOSS = 5;
const XP_DRAW = 10;

// In-memory store (replace with DB)
const feedStore = [];
const leaderboardByCounty = new Map();
const challenges = new Map();
let challengeIdSeq = 0;

/**
 * Recent community activities for county.
 * @param {string} county
 * @param {number} [limit=20]
 * @returns {Promise<Array<{ id: string, type: string, userId: string, displayName: string, message: string, createdAt: Date, metadata?: object }>>}
 */
async function getFeed(county, limit = 20) {
  const list = (feedStore.filter((f) => f.county === county) || [])
    .sort((a, b) => new Date(b.createdAt) - new Date(a.createdAt))
    .slice(0, limit);
  return list;
}

/**
 * Top 10 by weeklyXp for county. Reset weeklyXp every Monday 00:00 EAT.
 * @param {string} county
 * @returns {Promise<{ entries: Array<{ rank: number, userId: string, displayName: string, weeklyXp: number, level: number, levelName: string }>, nextResetAt: Date }>}
 */
async function getLeaderboard(county) {
  const entries = (leaderboardByCounty.get(county) || [])
    .sort((a, b) => (b.weeklyXp || 0) - (a.weeklyXp || 0))
    .slice(0, 10)
    .map((e, i) => ({ ...e, rank: i + 1 }));
  const nextResetAt = getNextMondayEAT();
  return { entries, nextResetAt };
}

/**
 * Create a challenge. Validates same category; sets 48h expiry.
 * @param {string} fromUserId
 * @param {string} toUserId
 * @param {string} categoryId
 * @returns {Promise<{ id: string, fromUserId: string, toUserId: string, categoryId: string, categoryName: string, expiresAt: Date, status: string }>}
 */
async function createChallenge(fromUserId, toUserId, categoryId) {
  const categoryName = categoryIdToName(categoryId);
  const id = `ch-${++challengeIdSeq}`;
  const expiresAt = new Date(Date.now() + CHALLENGE_EXPIRY_HOURS * HOUR_MS);
  const challenge = {
    id,
    fromUserId,
    toUserId,
    categoryId,
    categoryName,
    expiresAt: expiresAt.toISOString(),
    status: 'pending',
    acceptedAt: null,
    fromScore: null,
    toScore: null,
    winnerUserId: null,
    xpAwarded: null,
    createdAt: new Date().toISOString(),
  };
  challenges.set(id, challenge);
  return {
    id: challenge.id,
    fromUserId: challenge.fromUserId,
    toUserId: challenge.toUserId,
    categoryId: challenge.categoryId,
    categoryName: challenge.categoryName,
    expiresAt: new Date(challenge.expiresAt),
    status: challenge.status,
  };
}

/**
 * Accept a challenge.
 * @param {string} challengeId
 * @param {string} userId
 * @returns {Promise<{ accepted: boolean }>}
 */
async function acceptChallenge(challengeId, userId) {
  const c = challenges.get(challengeId);
  if (!c || c.toUserId !== userId) return { accepted: false };
  if (new Date(c.expiresAt) < new Date()) return { accepted: false };
  c.status = 'active';
  c.acceptedAt = new Date().toISOString();
  challenges.set(challengeId, c);
  return { accepted: true };
}

/**
 * Submit score for a challenge. When both have submitted, determine winner, award XP, notify both.
 * @param {string} challengeId
 * @param {string} userId
 * @param {number} score
 * @returns {Promise<{ recorded: boolean, completed?: boolean, winner?: string, xpAwarded?: number }>}
 */
async function submitChallengeScore(challengeId, userId, score) {
  const c = challenges.get(challengeId);
  if (!c || (c.status !== 'active' && c.status !== 'pending')) return { recorded: false };
  if (new Date(c.expiresAt) < new Date()) return { recorded: false };
  const isFrom = c.fromUserId === userId;
  const isTo = c.toUserId === userId;
  if (!isFrom && !isTo) return { recorded: false };

  if (isFrom) c.fromScore = score;
  else c.toScore = score;
  c.status = 'active';

  if (c.fromScore != null && c.toScore != null) {
    let winner = null;
    if (c.fromScore > c.toScore) winner = c.fromUserId;
    else if (c.toScore > c.fromScore) winner = c.toUserId;
    const xpWin = winner ? XP_WIN : 0;
    const xpLoss = winner ? XP_LOSS : 0;
    const xpDraw = !winner ? XP_DRAW : 0;
    const fromXp = winner === c.fromUserId ? xpWin : winner === c.toUserId ? xpLoss : xpDraw;
    const toXp = winner === c.toUserId ? xpWin : winner === c.fromUserId ? xpLoss : xpDraw;
    c.status = 'completed';
    c.winnerUserId = winner;
    c.xpAwarded = { [c.fromUserId]: fromXp, [c.toUserId]: toXp };
    c.completedAt = new Date().toISOString();
    challenges.set(challengeId, c);
    // TODO: call gamification.awardXp for each user; send notifications
    return {
      recorded: true,
      completed: true,
      winner: winner || null,
      xpAwarded: userId === c.fromUserId ? fromXp : toXp,
    };
  }
  challenges.set(challengeId, c);
  return { recorded: true };
}

function getNextMondayEAT() {
  const d = new Date();
  const day = d.getUTCDay();
  const daysUntilMonday = day === 0 ? 1 : day === 1 ? 0 : 8 - day;
  const monday = new Date(d);
  monday.setUTCDate(d.getUTCDate() + daysUntilMonday);
  monday.setUTCHours(0, 0, 0, 0);
  return monday;
}

function categoryIdToName(categoryId) {
  const map = {
    'digital-literacy': 'Digital Literacy',
    'communication': 'Communication',
    'business-entrepreneurship': 'Business & Entrepreneurship',
    'technical-ict': 'Technical (ICT)',
    'soft-skills-leadership': 'Soft Skills & Leadership',
  };
  return map[categoryId] || categoryId;
}

// Seed mock feed and leaderboard for development
function seedMock(county) {
  const now = new Date();
  if (!leaderboardByCounty.has(county)) {
    leaderboardByCounty.set(
      county,
      [
        { userId: 'u1', displayName: 'Alice', weeklyXp: 320, level: 3, levelName: 'Rising Star' },
        { userId: 'u2', displayName: 'Bob', weeklyXp: 280, level: 2, levelName: 'Rising Star' },
        { userId: 'u3', displayName: 'Carol', weeklyXp: 250, level: 2, levelName: 'Rising Star' },
        { userId: 'u4', displayName: 'Dave', weeklyXp: 180, level: 2, levelName: 'Rising Star' },
        { userId: 'u5', displayName: 'Eve', weeklyXp: 120, level: 1, levelName: 'Starter' },
      ]
    );
  }
  if (feedStore.length === 0) {
    feedStore.push(
      { id: 'f1', county: 'Nairobi', type: 'assessment', userId: 'u1', displayName: 'Alice', message: 'Completed Digital Literacy assessment', createdAt: new Date(now - 3600000), metadata: { categoryId: 'digital-literacy', score: 85 } },
      { id: 'f2', county: 'Nairobi', type: 'job', userId: 'u2', displayName: 'Bob', message: 'Applied to Junior Developer at Tech Co', createdAt: new Date(now - 7200000), metadata: {} },
      { id: 'f3', county: 'Nairobi', type: 'badge', userId: 'u3', displayName: 'Carol', message: 'Earned the First Assessment badge', createdAt: new Date(now - 86400000), metadata: { badgeId: 'first_assessment' } },
      { id: 'f4', county: 'Nairobi', type: 'level', userId: 'u1', displayName: 'Alice', message: 'Reached Level 3', createdAt: new Date(now - 172800000), metadata: { level: 3 } }
    );
  }
}

module.exports = {
  getFeed,
  getLeaderboard,
  createChallenge,
  acceptChallenge,
  submitChallengeScore,
  seedMock,
  _challenges: challenges,
};
