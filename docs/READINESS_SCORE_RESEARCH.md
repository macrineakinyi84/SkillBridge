# Readiness Score – Configurable Logic for Research

The readiness score is computed by a **configurable service** so you can change weights and thresholds for research evaluation and A/B testing.

---

## Components (all configurable)

| Component | What it measures | Default weight |
|----------|------------------|----------------|
| **Completed skills** | Number of skills the user has (capped at `maxSkillsForFullScore`) | 0.25 |
| **Skill progress** | Average proficiency level across skills (Beginner → Expert mapped to 25–100) | 0.25 |
| **Portfolio items** | Number of portfolio items (capped at `portfolioItemsForFullScore`) | 0.25 |
| **Learning consistency** | Unique days with activity in the last `consistencyWindowDays` days | 0.25 |

Weights should sum to **1.0** so the total score stays 0–100 (or your `maxScore`).

---

## Configuration: `ReadinessScoreConfig`

Defined in `lib/features/readiness/domain/models/readiness_score_config.dart`.

### Weights (sum to 1.0)

- `weightCompletedSkills`
- `weightSkillProgress`
- `weightPortfolio`
- `weightLearningConsistency`

### Completed skills

- `maxSkillsForFullScore` – number of skills needed for 100% on this component (default 10).
- `minSkillsForAnyScore` – minimum skills to get any points (default 1).

### Skill progress (proficiency → 0–100)

- `proficiencyLevelScores` – map, e.g. `beginner: 25, intermediate: 50, advanced: 75, expert: 100`.
- `defaultProficiencyScore` – used when level is missing or unknown (default 25).

### Portfolio

- `portfolioItemsForFullScore` – items needed for 100% (default 5).
- `minPortfolioItemsForAnyScore` – minimum for any points (default 0).

### Learning consistency

- `consistencyWindowDays` – look-back window (default 30).
- `consistencyTargetDaysForFullScore` – unique active days in that window for 100% (default 15).
- `minConsistencyDaysForAnyScore` – minimum for any points (default 0).

### Output scale

- `maxScore` – e.g. 100 (default).

---

## Presets for research

- **`ReadinessScoreConfig.researchDefault`** – equal weights (0.25 each), standard thresholds.
- **`ReadinessScoreConfig.researchSkillsHeavy`** – skills + progress = 0.35 each, portfolio 0.15, consistency 0.15.
- **`ReadinessScoreConfig.researchPortfolioHeavy`** – portfolio 0.45, consistency 0.25, skills 0.15 each.

Register a different config in DI to run a variant:

```dart
sl.registerLazySingleton<ReadinessScoreCalculator>(
  () => ReadinessScoreCalculator(config: ReadinessScoreConfig.researchSkillsHeavy),
);
```

---

## Input: `ReadinessScoreInput`

Build this from your repositories before calling the calculator:

- **`userSkills`** – list of `UserSkillEntity` (with `proficiencyLevel`).
- **`portfolioItemCount`** – count of portfolio items.
- **`activityDates`** – list of `DateTime` when the user had activity (e.g. add/update skill or portfolio). Used to count unique active days in the consistency window.
- **`referenceDate`** – optional; defaults to “now” for “last N days”.

---

## Usage

### 1. Use case (recommended)

```dart
final result = sl<CalculateReadinessScore>().call(input);
// result.entity  -> ReadinessEntity(score, maxScore, feedback)
// result.breakdown -> ReadinessScoreBreakdown (for logging/research)
```

### 2. Calculator directly

```dart
final calculator = ReadinessScoreCalculator(config: myConfig);
final result = calculator.calculate(input);
```

### 3. Building input from repositories

When you have `UserSkillRepository`, `PortfolioRepository`, and activity data:

```dart
final userSkills = await userSkillRepo.getUserSkills(userId);
final portfolioItems = await portfolioRepo.getPortfolioItems(userId);
final activityDates = await activityRepo.getActivityDates(userId); // or derive from skills/portfolio

final input = ReadinessScoreInput(
  userSkills: userSkills,
  portfolioItemCount: portfolioItems.length,
  activityDates: activityDates,
);
final result = sl<CalculateReadinessScore>().call(input);
await readinessScoreRepo.setReadinessScore(userId, result.entity);
```

---

## Research / evaluation

- **Breakdown** – `ReadinessResult.breakdown` exposes each component score (0–100), total, and counts. Log or store these for analysis.
- **A/B tests** – register different `ReadinessScoreConfig` per cohort (e.g. by user id hash) and compare outcomes.
- **Sensitivity** – change one weight at a time and recompute to see impact on score distribution.
