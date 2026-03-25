# Employer vs Student Roles — Brainstorm

## Why employers see the same as students today

1. **Role is not stored**  
   Onboarding lets users choose "Student / Youth" or "Employer", but that choice is only used once: the login URL gets `?next=/employer/dashboard`. The backend `User` has `role: 'user' | 'admin'` only — there is no `employer` role. The Flutter `UserEntity` has no `role` at all. So the app never "remembers" that someone is an employer.

2. **Everyone is sent to the same home**  
   After login, redirect is: use `next` if present, otherwise **always** go to `/dashboard` (student dashboard). So:
   - If an employer logs in **without** the `next` param (e.g. from Login screen or after app restart), they land on the **student** dashboard.
   - Only when they come from onboarding and tap "Employer" do they get `next=/employer/dashboard` and see the employer dashboard once.

3. **Same bottom nav for everyone**  
   The main shell has one set of tabs: **Home, Skills, Portfolio, Profile**. "Home" is always the **student** dashboard. Employer routes (`/employer/dashboard`, `/employer/listings`, etc.) live **outside** this shell, so there is no employer-specific tab bar. Employers who reach the employer dashboard have no bottom nav there — only the FAB and in-screen links.

4. **Data is actually different, but entry point isn’t**  
   The **employer** dashboard already uses different data: `EmployerDashboardModel` (active listings, applicants, pipeline, etc.) from `EmployerRepository`. So employer screens *do* show employer-specific data when you reach them. The problem is **routing and navigation**: employers often land on the student home and see student data (career health, job matches, quests) because the app doesn’t treat them as employers by default.

---

## What should change (summary)

| Area | Current | Desired |
|------|--------|--------|
| **Role** | Not persisted; backend has `user`/`admin` only | Persist **student** vs **employer** (and keep admin). Backend + JWT + Flutter `UserEntity` all know role. |
| **Post-login redirect** | `next` only when coming from onboarding Employer | **By role:** if `role === 'employer'` → `/employer/dashboard`, else → `/dashboard`. |
| **Home / Shell** | Single shell: student dashboard as "Home" | **Role-based shell:** students keep current nav (Home = student dashboard); employers get a **separate shell** with tabs like Dashboard, Listings, Candidates, Profile. |
| **Who sees what** | Everyone can open same routes (no guard) | **Guard by role:** e.g. employer-only routes redirect students; student-only (e.g. assessment, job matches) can be hidden or restricted for employers. |

---

## 1. Role in backend and app

- **Backend (Prisma + JWT)**  
  - Extend `User.role` to: `'student' | 'employer' | 'admin'` (or keep `'user'` as alias for student).  
  - Sign-up / onboarding: when user chooses "Employer", create or update user with `role: 'employer'` (e.g. via a dedicated signup path or a "Set role" call after first login).  
  - JWT payload: include `role` so the app and API can use it.

- **Flutter**  
  - Add `role` to `UserEntity` (e.g. `'student' | 'employer' | 'admin'`).  
  - Parse `role` from JWT (or from GET /api/users/me) and store in auth state so the whole app can branch on it.

---

## 2. Redirect and default home by role

- **After login / app start (authenticated)**  
  - If `role == 'employer'` → redirect to **`/employer/dashboard`**.  
  - Else → redirect to **`/dashboard`** (student).  
  - Optional: still respect `next` when it’s allowed for that role (e.g. employer can have `next=/employer/listings`).

- **Onboarding**  
  - When user taps "Employer", either:  
    - Send them to login with `next=/employer/dashboard` and **also** call an API to set role to employer (so next time they open the app they go to employer dashboard without `next`), or  
    - Have a separate "Employer sign up" flow that creates an account with `role: 'employer'` so the backend is the source of truth.

---

## 3. Different “home” and navigation for employers

- **Employer shell (new)**  
  - Give employers their own **bottom nav** (or drawer) when they’re on employer routes, for example:  
    - **Dashboard** → `/employer/dashboard`  
    - **Listings** → `/employer/listings`  
    - **Candidates** (or Pipeline) → e.g. list of jobs with applicant counts, or a combined pipeline  
    - **Profile** → same profile screen, maybe with an "Employer account" section  

  - Implementation options:  
    - A second `StatefulShellRoute` (or branch) that’s used when the user is an employer and the path is under `/employer/`, so the employer tab bar only shows for those routes.  
    - Or a dedicated "employer shell" widget that wraps `/employer/*` routes and shows employer tabs; students never see this shell.

- **Student shell (current)**  
  - Keep as is: Home (student dashboard), Skills, Portfolio, Profile.  
  - Students never see employer tabs; they don’t need to open employer dashboard.

---

## 4. Who sees what (role-based visibility and guards)

**Students only (hide or restrict for employers):**

- Student dashboard (career health, streaks, job matches, quest, heatmap, community).
- Assessments (take / retake), assessment results, readiness.
- Job board (browse and apply) and “Top Job Matches” on dashboard.
- Learning hub, learning paths, certificates.
- “My applications” / application tracker.
- Portfolio (own) and CV export.

**Employers only (hide or restrict for students):**

- Employer dashboard (listings count, applicants, pipeline stats).
- Post job, edit listing, manage listings.
- Talent pipeline: list of applicants per job, with match % and status.
- **View student/candidate profiles**: full profile of applicants (portfolio, skills, assessment summary, contact) — this is the main “employers see students” feature.
- Shortlist / reject / stage (e.g. “Interview”) applications.
- Optional: employer-facing notifications (“3 new applicants for Junior Flutter Dev”).

**Shared (both roles):**

- Profile (with optional “Account type: Student / Employer” or switch).
- Notifications (list and badge); messages if you add them.
- Settings, logout.

**Optional:**

- Allow an account to have **both** roles (e.g. “I’m a youth but also hire for my team”) and switch context (Student view vs Employer view) from profile or a switcher in the app bar.

---

## 5. Employer-only features to add or clarify

These are features that make the employer side clearly different from the student side and let employers “see” and act on students:

| Feature | Description |
|--------|-------------|
| **View student/candidate profile** | From pipeline or dashboard, open a **full candidate profile**: name, photo, bio, education, experience, skills (from assessments), match %, and portfolio/CV. Option to download CV (PDF). |
| **Talent pipeline per job** | List of applicants per listing with status (e.g. New, Shortlisted, Rejected, Interview). Filter/sort by match %, date applied. |
| **Application actions** | Buttons to Shortlist, Reject, or move to stage (e.g. “Interview”). Backend stores status; Flutter reflects it. |
| **Employer dashboard data** | Real data from backend: **active listings**, **new applicants this week**, **recent applicants** (with link to candidate profile). Optional: “new matches” notification. |
| **Post / edit job** | Already in app; ensure backend has **POST/PUT /api/employer/listings** and that only employers (and maybe admin) can call them. |
| **Search / filter candidates** | By job, by skill, by match range, by county (if stored). |
| **Backend employer APIs** | e.g. `GET /api/employer/dashboard`, `GET /api/employer/listings`, `GET /api/employer/jobs/:id/candidates`, `GET /api/employer/candidates/:id` (student profile), `PATCH /api/employer/applications/:id` (status). All require `role === 'employer'` (or admin). |

---

## 6. Student-only protections

- **API:** Student-only endpoints (e.g. submit assessment, get job matches, get my dashboard) should allow `role === 'student'` (or `'user'`). Optionally allow employers to have a “student” side too if you support dual role.
- **Flutter:** On student dashboard, assessments, job board, learning hub, don’t show employer nav or employer dashboard link (unless you add “Switch to employer view”). Guard employer routes: if `role !== 'employer'` and path starts with `/employer/`, redirect to `/dashboard`.

---

## 7. Suggested order of implementation

1. **Backend:** Add `employer` (and optionally `student`) to `User.role`; include `role` in JWT and in GET /api/users/me.  
2. **Flutter:** Add `role` to `UserEntity` and auth state; parse from backend.  
3. **Redirect:** After login (and on app open when authenticated), redirect to `/employer/dashboard` if role is employer, else `/dashboard`.  
4. **Employer shell:** Add employer bottom nav for `/employer/*` routes so employers have a dedicated home (Dashboard, Listings, Candidates, Profile).  
5. **Guards:** Redirect to correct home when an employer hits `/dashboard` or a student hits `/employer/dashboard` (optional but clearer).  
6. **Employer backend APIs:** Implement or wire dashboard, listings, candidates, and “get candidate profile” (student profile for employer).  
7. **Candidate profile screen:** Ensure employers can open a full student profile (portfolio, skills, assessment summary, CV).  
8. **Pipeline actions:** Shortlist / Reject / Stage and persist in backend.

---

## 8. Quick reference: data each role sees

| Data / Screen | Student | Employer |
|---------------|--------|----------|
| Career health, streaks, XP, quest | ✅ | ❌ (or hidden) |
| Job matches, job board, apply | ✅ | ❌ (or browse-only) |
| Assessments, learning hub | ✅ | ❌ |
| My portfolio, CV export | ✅ (own) | ❌ |
| My applications | ✅ | ❌ |
| Employer dashboard (stats, recent applicants) | ❌ | ✅ |
| My job listings, post/edit job | ❌ | ✅ |
| Talent pipeline (applicants per job) | ❌ | ✅ |
| **View student/candidate profile** | ❌ (own only) | ✅ (applicants) |
| Shortlist / reject / stage application | ❌ | ✅ |
| Profile, notifications, settings | ✅ | ✅ |

This way employers and students get clearly different experiences and data, with employers able to see and act on student (candidate) profiles while students stay in a job-seeking and learning flow.
