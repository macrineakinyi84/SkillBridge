# Firestore Collections

Collection names and document shape for SkillBridge. Use `FirestoreConstants` in code.

---

## 1. `users`

Profile document per authenticated user. Document ID = Firebase Auth UID.

| Field        | Type     | Description        |
|-------------|----------|--------------------|
| id          | string   | Same as document ID |
| email       | string   | User email         |
| displayName | string?  | Display name       |
| photoUrl    | string?  | Profile photo URL   |
| createdAt   | timestamp| First created      |
| updatedAt   | timestamp| Last updated       |

**Model:** `UserProfileModel`  
**Repository:** `UserRepository`

---

## 2. `skills`

Catalog of skills (global or admin-defined). Document ID = auto or custom.

| Field          | Type     | Description     |
|----------------|----------|-----------------|
| id             | string   | Document ID     |
| name           | string   | Skill name      |
| category       | string?  | e.g. "Technical" |
| proficiencyLevel | string? | (optional for catalog) |
| notes          | string?  |                 |
| createdAt      | timestamp|                 |

**Model:** `SkillModel`  
**Repository:** `SkillRepository`

---

## 3. `user_skills`

User–skill link (user’s skills with proficiency). Document ID = auto-generated.

| Field             | Type     | Description  |
|-------------------|----------|--------------|
| id                | string   | Document ID  |
| userId            | string   | User UID     |
| skillId           | string   | Reference to skills |
| skillName         | string   | Denormalized for display |
| proficiencyLevel  | string?  | e.g. "Beginner", "Expert" |
| notes             | string?  |              |
| createdAt         | timestamp|              |

**Model:** `UserSkillModel`  
**Repository:** `UserSkillRepository`

---

## 4. `portfolios`

Portfolio items per user. Document ID = auto-generated.

| Field      | Type     | Description   |
|------------|----------|---------------|
| id         | string   | Document ID   |
| userId     | string   | Owner UID     |
| title      | string   | Project title |
| description| string?  |               |
| url        | string?  | Link          |
| imageUrl   | string?  | Thumbnail     |
| createdAt  | timestamp|               |
| updatedAt  | timestamp|               |

**Model:** `PortfolioItemModel`  
**Repository:** `PortfolioRepository`

---

## 5. `readiness_scores`

One document per user. Document ID = userId.

| Field     | Type     | Description   |
|-----------|----------|---------------|
| userId    | string   | User UID      |
| score     | number   | 0–100         |
| maxScore  | number   | Default 100   |
| feedback  | string?  | Optional text  |
| updatedAt | timestamp|               |

**Model:** `ReadinessScoreModel`  
**Repository:** `ReadinessScoreRepository`

---

## Indexes

Create composite indexes in Firebase Console as needed, for example:

- `user_skills`: `userId` (ASC) + `createdAt` (DESC)
- `portfolios`: `userId` (ASC) + `createdAt` (DESC)
