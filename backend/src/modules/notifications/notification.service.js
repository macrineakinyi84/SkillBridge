/**
 * Notifications: FCM push via Firebase Admin SDK + smart nudge scheduler (node-cron).
 * Requires: firebase-admin, node-cron. FCM tokens stored per user (e.g. in DB).
 */

// Optional: require('firebase-admin'); require('node-cron');
// When wiring: init Firebase Admin with service account; store/read FCM tokens by userId.

let cron = null;
try {
  cron = require('node-cron');
} catch (_) {
  // node-cron not installed; scheduler no-ops
}

/** In-memory stub: userId -> fcmToken. Replace with DB lookup. */
const fcmTokens = new Map();

/**
 * Look up FCM token for user and send message.
 * @param {string} userId
 * @param {{ title: string, body: string, data?: Record<string, string> }} payload
 * @returns {Promise<{ sent: boolean }>}
 */
async function sendToUser(userId, { title, body, data = {} }) {
  const token = fcmTokens.get(userId);
  if (!token) return { sent: false };
  try {
    // const messaging = getAdmin().messaging();
    // await messaging.send({ token, notification: { title, body }, data: { ...data } });
    return { sent: true };
  } catch (e) {
    return { sent: false };
  }
}

function getAdmin() {
  throw new Error('Firebase Admin not initialized. Call initNotificationService(admin) first.');
}

/** Register FCM token for user (call from API when client sends token). */
function registerFcmToken(userId, token) {
  if (token) fcmTokens.set(userId, token);
}

async function sendJobMatchNotification(studentId, jobTitle, matchScore) {
  return sendToUser(studentId, {
    title: 'New job match',
    body: `"${jobTitle}" is ${matchScore}% match for you.`,
    data: { type: 'job_match', jobTitle, matchScore: String(matchScore) },
  });
}

async function sendApplicationStatusNotification(studentId, jobTitle, newStatus, companyName) {
  return sendToUser(studentId, {
    title: 'Application update',
    body: `${companyName}: Your application for "${jobTitle}" is now ${newStatus}.`,
    data: { type: 'application_status', jobTitle, newStatus, companyName },
  });
}

async function sendBadgeEarnedNotification(userId, badgeName) {
  return sendToUser(userId, {
    title: 'Badge earned',
    body: `You earned the "${badgeName}" badge!`,
    data: { type: 'badge_earned', badgeName },
  });
}

async function sendLevelUpNotification(userId, newLevel) {
  return sendToUser(userId, {
    title: 'Level up!',
    body: `You reached level ${newLevel}.`,
    data: { type: 'level_up', newLevel: String(newLevel) },
  });
}

/** Send at 6pm if user not active today (run from cron). */
async function sendStreakWarningNotification(userId, streakType, currentCount) {
  return sendToUser(userId, {
    title: 'Streak at risk',
    body: `Your ${streakType} streak (${currentCount}) will reset if you don't act today.`,
    data: { type: 'streak_warning', streakType, currentCount: String(currentCount) },
  });
}

/** Send at 8am daily (run from cron). */
async function sendMicroLessonNotification(userId, lessonTitle) {
  return sendToUser(userId, {
    title: 'Quick lesson',
    body: `Today's micro-lesson: ${lessonTitle}.`,
    data: { type: 'micro_lesson', lessonTitle },
  });
}

// ─── Smart Nudge Scheduler (run as cron jobs) ─────────────────────────────────
// Use node-cron with EAT timezone. Guard each job with isRunning so overlapping
// runs don't stack (e.g. if a run takes longer than the interval).

/** Every day 9am EAT: send micro-lesson to active users. */
let microLessonRunning = false;
function scheduleMicroLessonNotifications() {
  if (!cron) return;
  cron.schedule('0 9 * * *', async () => {
    if (microLessonRunning) return;
    microLessonRunning = true;
    try {
      // const activeUserIds = await getActiveUserIds(); // last 7 days
      // const lesson = await getTodaysMicroLesson();
      // for (const uid of activeUserIds) await sendMicroLessonNotification(uid, lesson.title);
    } finally {
      microLessonRunning = false;
    }
  }, { timezone: 'Africa/Nairobi' });
}

/** Every day 6pm EAT: send streak warning to users at risk. */
let streakWarningsRunning = false;
function scheduleStreakWarnings() {
  if (!cron) return;
  cron.schedule('0 18 * * *', async () => {
    if (streakWarningsRunning) return;
    streakWarningsRunning = true;
    try {
      // const atRisk = await getUsersAtStreakRisk(); // not active today, has streak > 0
      // for (const { userId, streakType, currentCount } of atRisk)
      //   await sendStreakWarningNotification(userId, streakType, currentCount);
    } finally {
      streakWarningsRunning = false;
    }
  }, { timezone: 'Africa/Nairobi' });
}

/** Every Friday 4pm EAT: new jobs this week digest. */
let weeklyJobsRunning = false;
function scheduleWeeklyJobsDigest() {
  if (!cron) return;
  cron.schedule('0 16 * * 5', async () => {
    if (weeklyJobsRunning) return;
    weeklyJobsRunning = true;
    try {
      // const users = await getUsersWithJobAlerts();
      // for (const u of users) await sendToUser(u.id, { title: 'New jobs this week', body: '...', data: { type: 'jobs_digest' } });
    } finally {
      weeklyJobsRunning = false;
    }
  }, { timezone: 'Africa/Nairobi' });
}

/** Every Monday 00:01 EAT: reset weeklyXp, send weekly summary. */
let weeklyResetRunning = false;
function scheduleWeeklyResetAndSummary() {
  if (!cron) return;
  cron.schedule('1 0 * * 1', async () => {
    if (weeklyResetRunning) return;
    weeklyResetRunning = true;
    try {
      // await resetWeeklyXpAllUsers();
      // const users = await getAllUsersWithTokens();
      // for (const u of users) await sendToUser(u.id, { title: 'Your week on SkillUp', body: '...', data: { type: 'weekly_summary' } });
    } finally {
      weeklyResetRunning = false;
    }
  }, { timezone: 'Africa/Nairobi' });
}

/** Every 3 days: re-engagement for inactive users. */
let reengagementRunning = false;
function scheduleReengagement() {
  if (!cron) return;
  cron.schedule('0 10 */3 * *', async () => {
    if (reengagementRunning) return;
    reengagementRunning = true;
    try {
      // const inactive = await getInactiveUserIds(3); // no activity in 3 days
      // for (const uid of inactive) await sendToUser(uid, { title: 'We miss you!', body: '...', data: { type: 'reengagement' } });
    } finally {
      reengagementRunning = false;
    }
  }, { timezone: 'Africa/Nairobi' });
}

function startNotificationScheduler() {
  scheduleMicroLessonNotifications();
  scheduleStreakWarnings();
  scheduleWeeklyJobsDigest();
  scheduleWeeklyResetAndSummary();
  scheduleReengagement();
}

module.exports = {
  sendToUser,
  registerFcmToken,
  sendJobMatchNotification,
  sendApplicationStatusNotification,
  sendBadgeEarnedNotification,
  sendLevelUpNotification,
  sendStreakWarningNotification,
  sendMicroLessonNotification,
  startNotificationScheduler,
};
