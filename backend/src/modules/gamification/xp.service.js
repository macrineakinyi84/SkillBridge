const XP = require('./xp.constants');
const db = require('../../lib/db');

// Award XP for eventType. Updates totalXp, weeklyXp, checks level, logs XpEvent.
async function awardXp(userId, eventType, metadata = {}) {
  const xpAwarded = XP[eventType] ?? 10;
  const profile = await getProfile(userId);
  const previousLevel = profile.level ?? 1;
  const newTotal = (profile.totalXp || 0) + xpAwarded;
  const newWeeklyXp = (profile.weeklyXp || 0) + xpAwarded;
  const { level: newLevel, xpInCurrentLevel, xpToNextLevel } = xpToLevel(newTotal);

  await updateProfile(userId, {
    totalXp: newTotal,
    weeklyXp: newWeeklyXp,
    level: newLevel,
    levelName: getLevelName(newLevel),
  });

  await db.logXpEvent(userId, eventType, xpAwarded, metadata);
  const leveledUp = newLevel > previousLevel;
  if (leveledUp) await triggerLevelUpNotification(userId, newLevel);

  return {
    newTotal,
    xpAwarded,
    leveledUp,
    newLevel: leveledUp ? newLevel : undefined,
  };
}

function xpToLevel(totalXp) {
  let level = 1;
  let remaining = totalXp;
  let threshold = 100;
  while (remaining >= threshold) {
    remaining -= threshold;
    level++;
    threshold = 100 + level * 50;
  }
  return { level, xpInCurrentLevel: remaining, xpToNextLevel: threshold };
}

function getLevelName(level) {
  if (level <= 2) return 'Rising Star';
  if (level <= 5) return 'Champion';
  return 'Legend';
}

async function getProfile(userId) {
  return db.getGamificationProfile(userId);
}

async function updateProfile(userId, data) {
  return db.updateGamificationProfile(userId, data);
}

async function triggerLevelUpNotification(userId, newLevel) {
  // TODO: send notification
}

module.exports = { awardXp, xpToLevel };
