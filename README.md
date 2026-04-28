# SkillBridge Kenya

**Bridge your skills to career readiness.** A final-year academic project aligning with SDG 8 (Decent Work and Economic Growth) and SDG 4 (Quality Education) by helping youth and job-seekers in Kenya assess skills, build portfolios, and connect with opportunities.

---

## Project overview and SDG alignment

SkillBridge helps users:

- **Assess** skills across categories (Digital Literacy, Communication, Business & Entrepreneurship, Technical ICT, Soft Skills & Leadership) with tiered results (Beginner → Advanced).
- **Build** a portfolio and export a CV as PDF.
- **Get job-ready** via job matching, application tracking, and learning paths with micro-lessons.
- **Stay engaged** with gamification (XP, levels, badges, streaks), community feed and leaderboard, and peer challenges.

**SDG alignment:**

- **SDG 8:** Decent work and economic growth — job matching, application status, employer listings, and career readiness scoring.
- **SDG 4:** Quality education — skill assessments, learning paths, micro-lessons, and gap-based recommendations.

---

## Setup instructions

### Flutter app

1. **Prerequisites:** Flutter SDK (3.2+), Dart 3.2+.
2. **Clone and install:**
   ```bash
   cd SkillBridge
   flutter pub get
   ```
3. **Firebase (optional but recommended):**  
   Add `google-services.json` (Android) and `GoogleService-Info.plist` (iOS) and ensure `firebase_options.dart` is generated. Without Firebase, the app runs with stub auth and no push notifications.
4. **Run:**
   ```bash
   flutter run
   ```

### Environment variables and secrets

**Never hardcode API keys or secrets.** The app uses `flutter_dotenv` and loads from `assets/env.example` by default.

- **In code:** Use `EnvConfig` or `dotenv.env['KEY']`:
  ```dart
  import 'package:flutter_dotenv/flutter_dotenv.dart';
  final stripeKey = dotenv.env['STRIPE_KEY']!;  // when required
  // or
  import 'package:skillbridge/core/config/env_config.dart';
  final key = EnvConfig.stripeKey;  // optional, may be null
  ```
- **Local secrets:** Copy `assets/env.example` to a `.env` file in the project root, fill in values, add `.env` to `pubspec.yaml` under `flutter.assets`, and load it in `main.dart` (e.g. `await dotenv.load(fileName: '.env');`). Keep `.env` out of version control (it is in `.gitignore`).
- **Production:** Prefer `--dart-define-from-file=.env` or CI-injected env so secrets are not in the app bundle.

### Node.js backend (services)

Backend is a collection of **Node.js service modules** (no Express app in repo by default).

1. **Prerequisites:** Node.js 18+.
2. **Install dependencies** (when using a backend runner):
   ```bash
   cd backend
   npm install   # if package.json exists
   ```
   For **notifications**: `firebase-admin`, `node-cron`.  
   For **assessment**: no extra deps; scoring is in `src/modules/assessment/scoring.service.js`.

### PostgreSQL

Refer to your deployment or local setup for PostgreSQL. The app currently uses mock/remote datasources; when you connect a real API, configure DB URL and run migrations as needed.

---

## Architecture decisions

### Clean Architecture (Flutter)

The Flutter app follows **Clean Architecture**:

- **Domain:** Entities, models, repository interfaces, and pure services (e.g. `ScoringService`). No framework or I/O.
- **Data:** Implementations of repositories, remote/local datasources (mock or API), and DTOs.
- **Presentation:** Screens, pages, widgets, and state (e.g. Riverpod or setState).

**Why:** Clear separation of business rules from UI and I/O makes testing and swapping backends easier. Domain stays stable when APIs or design change.

### Backend structure

- **Modules:** `assessment`, `gamification`, `community`, `notifications`, `portfolio`, etc.
- **Services:** Stateless functions (e.g. scoring, XP, notifications) that can be called from an HTTP layer or cron when you add one.

---

## How the matching algorithm works

Job–candidate matching is intended to score how well a candidate fits a job (e.g. 0–100).

**Typical formula (conceptual):**

- **Skill match:** Overlap between job required skills and candidate skill scores (e.g. by category), weighted by proficiency.
- **Location:** Same county = full score; same region = partial; mismatch = lower.
- **Job type:** Preference match (e.g. full-time, internship) vs mismatch.

**Threshold:** Matches below a set threshold (e.g. 30) are excluded.  
Implementation lives in the employer/jobs backend or Flutter datasource; the app displays match % and filters by threshold.

---

## How the scoring algorithm works

**Assessment scoring** (`backend/src/modules/assessment/scoring.service.js` and Flutter `ScoringService`):

1. **Raw score:** Sum of difficulty-weighted points for correct answers (e.g. easy=1, medium=2, hard=3).
2. **Normalised score:**  
   `normalisedScore = round((rawScore / maxPossibleScore) * 100)`  
   - 0 raw → 0; max raw → 100; mid raw → proportional value.
3. **Tier:**  
   - 0–39: Beginner  
   - 40–59: Developing  
   - 60–79: Proficient  
   - 80–100: Advanced  
4. **Gaps:** For each category, `gap = benchmark - currentScore`. Only positive gaps; sorted by severity (highest first). Used for recommendations and radar charts.

---

## How the gamification system works

- **XP:** Awarded per event (e.g. assessment completed, job application, badge earned). Constants in `xp.constants.js` / Flutter.
- **Levels:** Total XP maps to level (e.g. thresholds 0, 100, 250, …). Level name (e.g. “Starter”, “Rising Star”) is derived from level.
- **Weekly XP:** Tracked separately; **reset every Monday 00:00 EAT** for leaderboards and weekly summary.
- **Streaks:** Job and learning streaks: increment if user was active the previous day; else reset to 1.
- **Badges:** Unlocked by triggers (e.g. first assessment, profile complete). Stored per user and shown in profile/achievements.

---

## API documentation summary

When an HTTP API is added, typical modules and endpoints:

| Area        | Purpose                          |
|------------|-----------------------------------|
| Auth       | Register, login, OTP verify, refresh token |
| Assessment | Categories, questions, submit answers, get result |
| Gamification | Profile, leaderboard, award XP, badges, streaks |
| Community  | Feed by county, leaderboard, create/accept challenge, submit score |
| Notifications | Register FCM token, send push (job match, application status, badge, level, streak, micro-lesson) |
| Jobs       | Listings, apply, application status (employer + student) |

Use **Zod** (or similar) for request validation and **JWT** for protected routes; store tokens in **flutter_secure_storage** only.

---

## Testing instructions

### Flutter

```bash
flutter test
```

- **Unit:** e.g. `test/features/assessment/scoring_service_test.dart` — `normaliseScore`, `assignTier`, `identifyGaps`.
- Add tests for jobs matching, XP service, and widgets as needed.

### Backend (Node)

If Jest (or similar) is set up:

```bash
cd backend
npm test
```

- **Unit:** e.g. `__tests__/scoring.service.test.js` — scoring functions and edge cases.
- Add tests for auth, matching, and notifications when those services are wired.

---

## Deployment guide

1. **Flutter:** Build for target (e.g. `flutter build apk`, `flutter build ios`, `flutter build web`). Configure signing and environment (e.g. API base URL) per platform.
2. **Backend:** Run Node services behind a process manager (e.g. PM2) or container; add Express/Fastify and wire modules. Use env vars for DB, Firebase Admin, and secrets.
3. **Cron:** Schedule notification jobs (e.g. node-cron) for 9am micro-lesson, 6pm streak warning, Friday jobs digest, Monday weekly reset, and re-engagement.
4. **Security:** HTTPS only; JWT in httpOnly/secure storage; rate limiting on auth; no sensitive data in logs.

---

## License and acknowledgements

Academic project; see repository or course for licence and acknowledgements.
