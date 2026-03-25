# SkillBridge — Architecture & Code Conventions

Opinionated **feature-first** structure and **intentional naming** to avoid generic, AI-style code.

---

## 1. Folder structure

```
lib/
  core/                    # Cross-cutting, no UI
    errors/                # Custom exceptions, failure types
      failures.dart        # Failure, AuthFailure, NetworkFailure, AssessmentFailure
      app_exception.dart   # AppException, NetworkException, AuthException
    network/               # HTTP client, interceptors (e.g. Dio)
      api_client.dart
    utils/                 # Date helpers, formatters (domain-agnostic)
      date_helpers.dart
      formatters.dart
    router/                # go_router config
    di/                    # GetIt setup
    constants/

  shared/                  # Reusable across features
    theme/                 # Colors, typography, spacing, radius, ThemeData
      app_colors.dart
      app_typography.dart
      app_spacing.dart
      app_radius.dart
      app_theme.dart
    widgets/               # Shared UI components
      empty_state.dart
      progress_ring.dart
      progress_bar_row.dart
      auth_scope.dart
      scaffold_with_nav_bar.dart

  features/
    auth/
      data/                # repositories, datasources, models
      domain/              # entities, use_cases, repository interfaces
      presentation/         # screens, widgets, state/controllers
    assessment/            # (or skills) — assessment engine, categories, results
      data/
      domain/
      presentation/
    jobs/
      data/
      domain/
      presentation/
    portfolio/
    readiness/
    profile/
    ...
```

**Rules:**
- **core/** — no dependency on `shared/` or `features/`. Use for errors, network, utils, router, DI.
- **shared/** — can depend on `core/`. Use for theme and widgets used in multiple features.
- **features/** — each feature has `data/`, `domain/`, `presentation/`. Feature may use `core/` and `shared/`, and other features only via domain (e.g. use cases), not presentation.

---

## 2. Comments: explain why, not what

Comments should give **reasoning and cross-references**, not restate the code.

**Good (why + reference):**
```dart
// JWT expiry is checked client-side as a UX optimisation only —
// the API re-validates server-side on every request (see auth_interceptor.dart)
```

```dart
// Stub used when Firebase init fails so app still runs;
// real impl: AuthRepositoryImpl (see auth/data/repositories/auth_repository_impl.dart).
```

**Avoid (what / generic):**
```dart
// This function handles the user authentication
// We need to check if the token is valid
// TODO: Add error handling
```

Prefer **why** (why this approach, why this file), and point to **related code** (see X) where it helps.

---

## 3. Commit history: small, semantic commits

Avoid a few giant “vibe coded” commits. Make **small, semantic commits** as you go:

```
feat(auth): add OTP resend cooldown timer (60s)
fix(assessment): radar chart not re-rendering on score update
refactor(jobs): extract match score calculation to separate service
chore: update flutter to 3.19.0
```

Use scope (auth, assessment, jobs, …) and a clear, imperative message.

---

## 4. Intentional naming (avoid vibe coding)

Use **domain-specific** names so intent is clear and code is searchable.

| ❌ Avoid | ✅ Prefer |
|----------|-----------|
| `final data = await fetchData();` | `final jobMatches = await jobMatchingService.fetchTopMatches(studentId);` |
| `final result = processResult(data);` | `final assessmentResult = assessmentEngine.scoreResponses(answers);` |
| `Widget buildCard() {}` | `Widget _buildJobMatchCard(JobMatch match) {}` |
| `List<dynamic> items` | `List<JobMatch> jobMatches` or `List<SkillProgressItem> skillProgress` |
| `void onSubmit()` | `void _onSignInSubmitted()` or `void _onAssessmentSubmitted()` |
| `Repository getRepo()` | `JobMatchRepository get jobMatchRepository` (named by domain) |

**Guidelines:**
- **Variables:** Name after the domain concept (`jobMatches`, `assessmentResult`, `readinessScore`).
- **Widgets:** Name after what they render (`_buildJobMatchCard`, `_ReadinessScoreCard`, `_NextStepCard`).
- **Callbacks / handlers:** Name after the action (`onSignIn`, `onRetakeAssessment`, `onExportPdf`).
- **Use cases / services:** Verb or domain action (`FetchTopJobMatches`, `CalculateReadinessScore`, `ScoreAssessmentResponses`).

---

## 5. Feature slice

Each feature owns:
- **data:** Repositories (impl), datasources, DTOs/models. Maps exceptions → failures.
- **domain:** Entities, repository interfaces (abstract), use cases. No Flutter.
- **presentation:** Pages, widgets, state (e.g. notifiers). Calls use cases; never datasources directly.

Dependency direction: **presentation → domain ← data**. Domain has no dependency on data or presentation.

---

## 6. Errors and failures

- **core/errors/app_exception.dart** — Thrown by data layer (repos, datasources). Catch in repos and convert to `Failure`.
- **core/errors/failures.dart** — Returned from use cases. Presentation handles `Failure` (e.g. show message, retry).
- Use **domain-specific failures** where it helps: `AssessmentFailure`, `AuthFailure`, `NetworkFailure`.

---

## 7. Current mapping

- **Theme & widgets:** Live under **shared/theme** and **shared/widgets**. Import from `shared/theme/` and `shared/widgets/` (e.g. `../../../../shared/theme/app_colors.dart` from feature presentation).
- **Core:** `core/errors`, `core/network`, `core/utils`, `core/router`, `core/di`, `core/constants` — no UI; used by features.
- **Features:** `auth`, `dashboard`, `skills` (assessment), `portfolio`, `readiness`, `profile`, `jobs`, `learning`, `notifications`, `onboarding` — each with `data/`, `domain/`, or `presentation/` where applicable.
