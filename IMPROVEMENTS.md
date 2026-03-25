# SkillBridge — Improvements & Data to Add

Suggestions for new features, real data, and UX improvements. Use this to prioritize what to build next.

---

## 1. Dashboard data from backend (high value)

**Current:** Dashboard uses hardcoded `_loadDashboardData()` for job matches, skills snapshot, active quest, readiness score, and “Last assessed”.

**Improvement:**

- Add **GET /api/dashboard/summary** (or `/api/users/me/dashboard`) that returns:
  - `readinessScore` (from skill scores / assessments)
  - `lastAssessedAt` (latest Assessment.createdAt)
  - `portfolioCount` (from portfolio or user profile)
  - `recentJobMatches` (when job matching is implemented)
  - `nextStepTitle`, `nextStepBody`, `nextStepActionLabel` (from gaps: missing assessment, incomplete profile, etc.)
  - `notificationCount`
- Flutter: load this in `StudentDashboardScreen` and use it instead of (or as fallback to) the hardcoded data.

**Data to add:** Readiness from `SkillScore`/`Assessment`, last assessment date from `Assessment`, portfolio count from backend or user profile.

---

## 2. Real “Last assessed” in Skills Snapshot

**Current:** “Last assessed: 3 days ago” is hardcoded.

**Improvement:**

- Backend: include `lastAssessedAt` in user summary or dashboard API (from `Assessment` table).
- Flutter: show “Last assessed: X days ago” or “Never” using that value.

---

## 3. Job matches from backend

**Current:** Top Job Matches use local mock list. Backend has `triggerJobMatching(studentId)` (TODO).

**Improvement:**

- Backend: implement job matching (e.g. match skills to jobs), store results (new table or JSON), expose **GET /api/users/me/job-matches**.
- Flutter: dashboard and job board consume this for “Top Job Matches” and “See all”.

**Data to add:** Job listings (if not already), job–skill mapping, match scores per user.

---

## 4. Active quest / next step from real state

**Current:** Active Quest text is from hardcoded `DashboardData`.

**Improvement:**

- Backend: compute next step from:
  - Incomplete profile (e.g. no photo, no bio)
  - Assessments not taken or low scores
  - Portfolio incomplete
- Return in dashboard summary; Flutter displays it in Active Quest and links the CTA to the right screen (profile, assessment, portfolio).

---

## 5. Profile completion %

**Current:** Nudge says “Complete your profile” but no percentage.

**Improvement:**

- Backend: **GET /api/users/me** (or profile endpoint) returns `profileCompletionPercent` (e.g. from photo, displayName, bio, county).
- Flutter: show “Profile 60% complete” in the nudge or welcome card and drive user to profile/settings.

**Data to add:** Rules for what counts as “complete” (e.g. photo + displayName + bio + county).

---

## 6. Notifications from backend

**Current:** Notification count can be mock; notification list may be local.

**Improvement:**

- Backend: store notifications (table or cache), expose **GET /api/notifications** (paginated).
- Flutter: badge count and notification center load from API; mark-as-read via **PATCH /api/notifications/:id/read**.

**Data to add:** Notification model (title, body, type, read, userId, createdAt).

---

## 7. Gamification (XP, streaks, badges) from backend

**Current:** Flutter uses `GamificationRemoteDataSourceMock` (no HTTP).

**Improvement:**

- Backend: already has User (totalXp, level, jobStreak, learnStreak), XpEvent, UserBadge. Expose:
  - **GET /api/users/me/profile** (or gamification profile) with XP, level, streaks, badges.
  - **POST /api/xp** or event endpoint for awarding XP (called after assessment, login, etc.).
- Flutter: switch to a real `GamificationRemoteDataSource` that calls these APIs so dashboard career health, level, and streaks reflect DB.

---

## 8. Community feed on dashboard

**Current:** “Community Activity” is placeholder text.

**Improvement:**

- Backend: **GET /api/community/feed** (e.g. recent badges, level-ups, county leaderboard) filtered by user’s county.
- Flutter: dashboard shows a short list of feed items; “See community” goes to full community screen.

**Data to add:** Feed items (type, userId, displayName, message, createdAt, county).

---

## 9. Learning progress on dashboard

**Current:** `DashboardData` has `learningProgress` but it may not be shown in the UI.

**Improvement:**

- Add a small “Learning progress” section (e.g. “Digital Skills Basics 60%”, “Job Readiness 30%”) or merge into Skills Snapshot / Active Quest.
- Backend: if learning paths and progress are stored, expose **GET /api/users/me/learning-progress** and use it here.

---

## 10. UX / UI improvements

- **Streak cards:** Minimum height added so “Keep applying!” / “Keep learning!” are not truncated (done).
- **Pull-to-refresh:** Already on dashboard; ensure it refreshes any new dashboard API data.
- **Skeleton loading:** Show skeleton while dashboard summary is loading instead of blank or only mock data.
- **Empty states:** Consistent empty states for job matches, community feed, and notifications with clear CTAs (e.g. “Take assessment”, “Complete profile”).

---

## 11. Security & production readiness

- **OTP in production:** Send OTP by email/SMS (e.g. SendGrid, Twilio); never return OTP in API response when `NODE_ENV=production`.
- **Job apply:** Implement **POST /api/jobs/:id/apply** (store application, optional cover note) and wire Flutter “Apply” to it.
- **Rate limiting:** Already on auth; consider limits on dashboard or notification endpoints if needed.

---

## 12. Optional data and metrics

- **Analytics:** Events for “assessment started”, “assessment completed”, “job applied”, “profile completed” for product insights.
- **Recommendations:** “Recommended skills” from backend based on job market or skill gaps (from assessments).
- **County / region:** Use `User.county` for localised content, leaderboards, and job filters.

---

**Suggested order to tackle:** (1) Dashboard API + real readiness/last assessed, (2) Gamification API so XP/streaks are real, (3) Job matches API when matching logic exists, (4) Notifications and profile completion %, (5) Community feed and learning progress.
