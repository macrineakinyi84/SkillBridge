# SkillBridge — Product Navigation & Screen Inventory

Maps **Student / Youth Navigation Tree** and **Screen Inventory (1.4)** to app routes and implementation.

---

## 1.2 Student / Youth Navigation Tree → Implementation

| Nav node | Route / screen | Notes |
|----------|----------------|--------|
| **Home Dashboard** | `/dashboard` | Skills Score Card, Recent Job Matches, Learning Progress, Notifications |
| → Skills Score Card | `/readiness` | Progress ring, next steps |
| → Recent Job Matches | `/job-board` | Job match %, list, link to Job Board |
| → Learning Progress | Dashboard section + `/learning-hub` | |
| → Notifications | `/notifications` | App bar icon + centre screen |
| **My Profile** | `/profile` | Personal Info, Profile Photo, Contact Details, Social Links |
| **Skills Assessment** | `/skills` → `/skills/categories` | Browse Categories (5 MVP categories) |
| → Browse Categories | `/skills/categories` | Digital Literacy, Communication, Business & Entrepreneurship, Technical (ICT), Soft Skills & Leadership |
| → Take Assessment | `/skills/assess/:categoryId` | Quiz placeholder (S-010) |
| → View Results | `/skills/results/:categoryId` | Score, radar placeholder, Retake (S-011) |
| → Retake / Update | From Results → Categories | |
| **Portfolio Builder** | `/portfolio` | Add Experience, Add Education, Add Projects, Add Certifications |
| → Preview CV | `/portfolio/preview` | S-013; Export PDF from preview |
| → Export PDF | From Preview or Portfolio | |
| **Job Board** | `/job-board` | S-014 |
| → Search & Filter Jobs | Job Board page (search field + filters) | |
| → Job Details | `/job-board/job/:jobId` | S-015 |
| → Apply Now | From Job Detail | |
| → Saved Jobs | Job Board quick action | Placeholder |
| → Application History / Status Tracker | `/job-board/applications` | S-016 |
| **Learning Hub** | `/learning-hub` | S-017 |
| → Recommended Courses | Section on Learning Hub | |
| → Skill-Gap Courses | Section | |
| → Course Progress | Section | |
| → Certificates Earned | Section | |
| **Messages** | `/messages` | Phase 2 (S-027); placeholder |
| **Settings** | `/settings` | S-019 |
| → Account Settings | Account info, Change password | |
| → Notifications | Link to `/notifications` | |
| → Privacy | Profile visible toggle | |
| → Help & FAQ | List item | |
| → Logout | Button | |

---

## 1.4 Screen Inventory (P0 MVP) → Routes

| Screen ID | Screen name | Route |
|-----------|-------------|--------|
| S-001 | Splash Screen | `/splash` |
| S-002 | Onboarding Carousel | `/onboarding` |
| S-003 | Role Selection | Modal from onboarding |
| S-004 | Register Screen | `/register` |
| S-005 | Login Screen | `/login` |
| S-006 | OTP Verification | `/verify-otp` |
| S-007 | Student Dashboard | `/dashboard` |
| S-008 | Student Profile | `/profile` |
| S-009 | Skills Assessment List | `/skills/categories` |
| S-010 | Assessment Quiz | `/skills/assess/:categoryId` |
| S-011 | Assessment Results | `/skills/results/:categoryId` |
| S-012 | Portfolio Builder | `/portfolio` |
| S-013 | CV Preview & Export | `/portfolio/preview` |
| S-014 | Job Board / Search | `/job-board` |
| S-015 | Job Detail & Apply | `/job-board/job/:jobId` |
| S-016 | Application Tracker | `/job-board/applications` |
| S-017 | Learning Hub | `/learning-hub` |
| S-018 | Notifications | `/notifications` |
| S-019 | Settings | `/settings` |

Employer screens (S-020–S-025) and Phase 2 (S-027, S-028) are out of scope for current student app.

---

## MVP Spec References

- **Skill categories (4.7):** Digital Literacy, Communication, Business & Entrepreneurship, Technical (ICT), Soft Skills & Leadership.
- **Job match colours (PDR 4.3):** `AppColors.matchScoreColor(percent)` — green ≥70%, yellow 40–69%, grey <40%.
- **Touch targets (PDR 4.3):** `AppSpacing.minTouchTarget` = 48dp.
- **OTP (FR-002):** 6-digit, 10-minute validity; screen `/verify-otp`.
