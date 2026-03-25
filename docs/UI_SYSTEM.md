# SkillBridge — Full UI System

**Senior product design: complete UI system for a non-generic, production-ready mobile app.**

This document defines layout, components, patterns, and rationale for **skill tracking**, **portfolio**, **readiness score**, and **recommendations**. Implementation lives in `lib/core/theme/` and `lib/core/widgets/`.

---

## 1. Design principles (avoid generic UI)

### 1.1 Product-led, not template-led

- **Bridge as journey:** The app is about moving from current skills to career readiness. Every screen answers “Where am I?” and “What’s next?”. We avoid generic “Dashboard” or “Settings-first” layouts.
- **One story per screen:** Each screen has a single primary job (e.g. “See my readiness” or “Manage my skills”). Secondary actions are available but don’t compete with the primary story.
- **Named, not generic:** Section titles are specific (“Skill progress”, “Recommended for you”, “Your next step”) instead of “Overview” or “Activity”. Copy is second person (“Your portfolio”) so it feels personal.

### 1.2 Production UX principles

- **Progressive disclosure:** Show summary first (score, counts); detail on tap or on dedicated screens. No overwhelming tables or long forms on the home screen.
- **One primary action per block:** Each card or section has at most one main CTA. Avoid “Learn more” + “Get started” + “Browse” in the same block.
- **Consistent feedback:** Loading, success, and error states use the same patterns everywhere (skeleton vs spinner, inline error vs snackbar).
- **Touch-first:** Minimum 44pt touch targets; list rows and cards are fully tappable. No tiny “info” icons as the only tap target.

### 1.3 What we avoid

- Stock “dashboard with 6 identical tiles”.
- Generic illustrations (e.g. people with laptops). We use simple icons or a single brand motif.
- Multiple competing accent colors in one view. One accent per section (e.g. orange for “next step”, blue for readiness).
- Dense, admin-style tables. We use cards and list rows with clear hierarchy.

---

## 2. Layout system

### 2.1 Grid and spacing

- **Base unit:** 4pt. All spacing uses the **named scale** (xs=4, s=8, m=16, l=24, xl=32, xxl=48). See `AppSpacing`.
- **Screen padding:** 20pt horizontal (`screenPadding`) so content doesn’t touch edges and scroll bars have room. Vertical padding is applied per section (e.g. xxl above fold, xl between sections).
- **Rationale:** A single scale removes arbitrary “18px here, 22px there”. Generous section spacing (l, xl) makes each block (readiness card, skills list, recommendations) read as one idea and reduces visual noise.

### 2.2 Screen structure (mobile)

- **App bar:** Same as scaffold background (warm cream in light theme) so the first screen feels like one surface. Title: H1 or app name. Actions: icon-only (e.g. profile, logout); no text in app bar for secondary actions.
- **Body:** Single scrollable column (e.g. `CustomScrollView` with slivers). No persistent bottom nav in the current design; primary navigation is “back to dashboard” and entry points from dashboard cards.
- **Safe area:** Respect top and bottom safe area (notch, home indicator). No content under system UI.
- **Rationale:** One column keeps the mental model simple and works for all four focus areas. Bottom nav can be added later as a single “Home / Skills / Portfolio / Profile” strip if needed.

### 2.3 Section order and hierarchy

- **Dashboard:** Greeting → “This week” (habit strip) → Readiness card → “Your next step” → Stats row (portfolio count, skills count) → Skill progress → Recommended for you → Quick actions.
- **Rationale:** The user sees “how I’m doing” (readiness, this week) and “what to do next” before diving into lists. Stats and lists support the story rather than leading it.

---

## 3. Typography and color

### 3.1 Type scale

| Token   | Size | Weight | Use |
|---------|------|--------|-----|
| Display | 28sp | Bold   | Hero (e.g. “Hi, Alex”); one per screen max. |
| H1      | 22sp | SemiBold | Screen title. |
| H2      | 17sp | SemiBold | Section title (“Skill progress”, “Recommended for you”). |
| Body    | 15sp | Regular | Descriptions, list primary text. |
| Caption | 13sp | Regular | Metadata, hints, empty-state secondary. |

**Rationale:** Clear steps between levels so hierarchy is obvious without relying on color. Body at 15sp is readable on small screens. See `AppTypography`.

### 3.2 Color roles

| Role | Use |
|------|-----|
| **Primary (blue)** | Readiness ring, primary nav, links. Trust and focus. |
| **Secondary (green)** | Success, “this week” streak, completed state. Growth. |
| **Accent warm (orange)** | Single primary CTA per context (e.g. “Your next step” button). Energy and action. |
| **Text primary** | Headings, list titles. |
| **Text secondary** | Captions, hints, metadata. |
| **Surface** | Cards, sheets, inputs. White on light theme. |
| **Background** | Scaffold. Warm cream in light theme. |
| **Semantic** | Error (red), warning (amber), success (green). |

**Rationale:** One primary and one warm accent prevent “rainbow dashboard”. Semantic colors are used only for status (error, warning, success). See `AppColors`.

---

## 4. Component system

### 4.1 Progress

- **ProgressRing:** Single 0–100 metric (e.g. readiness score). Value in centre, ring thickness ~8–12pt. Use for: readiness score on dashboard and readiness screen.
- **ProgressBarRow:** Label + optional badge (e.g. “Intermediate”) + horizontal bar. Use for: each skill in “Skill progress” list. Same bar style everywhere so “progress” is recognizable.
- **Rationale:** Two patterns only—ring for “your overall number”, bar for “each item’s progress”. No decorative donuts or multi-segment rings.

### 4.2 Cards

- **Surface card:** White (light theme) background, rounded corners (16pt), no strong shadow. Use for: stats (portfolio count, skills count), skill progress block, quick actions list.
- **Gradient card:** Soft gradient (e.g. primary tint or warm gradient) for the **hero** block only (readiness card). One per screen so it stays special.
- **Next-step card:** One title, one body line, one CTA (warm accent). Use for: “Your next step” on dashboard. No multiple buttons.
- **Rationale:** Cards group related content. Gradient is reserved for the main metric so the eye goes there first.

### 4.3 Lists

- **List row:** Minimum height 56pt (touch target). Leading: icon or avatar; title (body, SemiBold); trailing: optional badge or chevron. Full row tappable.
- **Stat row:** Two columns (e.g. “Portfolio items” | “3”). Used in stats row on dashboard.
- **Rationale:** Rows are tappable as a whole. We avoid “card per item” for long lists to reduce scrolling; cards are for grouped content (e.g. “Skill progress” as one card with N rows inside).

### 4.4 Buttons

- **Primary (Filled):** One per section or screen for the main action. Blue or warm orange depending on context (e.g. “Sign in” = blue, “Add skill” in next-step = orange).
- **Secondary (Text/Outlined):** For “See all”, “Skip”, “Cancel”. No strong background.
- **Rationale:** One primary CTA per block. Buttons are labeled with verbs (“Add skill”, “Save”, “Sign in”).

### 4.5 Empty states

- **Structure:** Icon (optional) + headline (H1) + one body sentence + one primary button. No “No data” without explanation.
- **Tone:** Encouraging and specific (“Add your first skill to see progress here”).
- **Use:** Skills list empty, portfolio empty, no readiness score yet. See `EmptyState` widget.

### 4.6 Chips and tags

- **Level badge:** Small pill (e.g. “Beginner”, “Advanced”) with tinted background (e.g. primary at 12% opacity). Use for: skill level in progress bar row.
- **Recommendation chip:** Outline style, optional “+” icon, tappable. Use for: “Recommended for you” horizontal list.
- **Rationale:** Chips are for categories and levels, not for primary actions.

---

## 5. Feature-specific patterns

### 5.1 Skill tracking

- **Dashboard:** “Skill progress” section = one surface card with up to 4 `ProgressBarRow` items + “See all skills” link. Each row: skill name, level badge, bar.
- **Skills screen:** If empty → `EmptyState` (“No skills yet”, “Add your first skill…”, “Add skill”). If list exists → list of rows (skill name, level, optional metadata); tap → detail/edit. One FAB or header action: “Add skill”.
- **Rationale:** Summary on dashboard; full list and add/edit on dedicated screen. Progress is always visible as bars so the user doesn’t need to open each skill to see level.

### 5.2 Portfolio

- **Dashboard:** Stat card “Portfolio items” with count; tap → portfolio screen.
- **Portfolio screen:** If empty → `EmptyState` (“No portfolio items yet”, “Showcase projects…”, “Add project”). If list exists → one row or card per item (title, optional thumbnail/description); tap → detail/edit. One primary action: “Add project”.
- **Rationale:** Portfolio is item-based (projects/achievements). Same empty-state and list pattern as skills for consistency.

### 5.3 Readiness score

- **Dashboard:** One hero card: `ProgressRing` + short copy (“Job readiness”, contextual line based on score) + tap to go to readiness screen.
- **Readiness screen:** Large `ProgressRing` (e.g. 140pt), H1 “Career readiness”, body text explaining what the score is based on. Optional: breakdown (skills, portfolio, consistency) as expandable or second screen. If no score yet → empty state with ring at 0 and “Add skills and portfolio items…”.
- **Rationale:** One number is the hero. Explanation and breakdown support it without competing. No decorative charts; ring is the single progress metaphor.

### 5.4 Recommendations

- **Dashboard:** Section “Recommended for you” + horizontal scroll of chips (e.g. skill names). Each chip tappable (e.g. “Add Riverpod” → skills screen or add flow). No “See all” required if the list is short.
- **Rationale:** Recommendations are “what to do next”; they sit after “where you are” (readiness, progress). Chips keep the list scannable and action-oriented.

---

## 6. Production UX patterns

### 6.1 Loading

- **List or grid:** Skeleton placeholders (same layout as content, shimmer or gray blocks). Prefer over a single spinner in the centre.
- **Single metric (e.g. readiness):** Small shimmer on the card or a lightweight pulse. Avoid full-screen loader for one number.
- **Rationale:** Skeletons preserve layout and reduce perceived wait. Spinner only when no layout can be shown (e.g. initial auth).

### 6.2 Errors

- **Inline:** Validation and API errors near the trigger (e.g. under form field or under “Sign in” button). Red caption or small banner. Optional “Retry” on the same screen.
- **Screen-level:** Only if the whole screen fails (e.g. “Couldn’t load skills”). Message + one “Retry” button. No generic “Something went wrong” without action.
- **Rationale:** User can correct or retry without leaving the screen. One recovery action per error.

### 6.3 Navigation

- **Back:** From any secondary screen (Skills, Portfolio, Readiness) back to dashboard. Clear back control (arrow or “Dashboard”).
- **Deep link:** Dashboard is the home. No tab bar in the current system; entry points are cards and “Quick actions” on dashboard.
- **Rationale:** Single home reduces confusion. “Quick actions” repeat the main entry points so the user doesn’t rely on memory.

### 6.4 Accessibility and touch

- **Touch targets:** Minimum 44pt for interactive elements. List rows and cards are fully tappable (not only a small arrow).
- **Contrast:** Text primary and secondary meet contrast guidelines on background and surface. Semantic colors (error, success) are distinguishable.
- **Labels:** Icon-only buttons have semantic labels for screen readers.

---

## 7. Implementation map

| System piece | Implementation |
|--------------|----------------|
| Spacing | `lib/core/theme/app_spacing.dart` |
| Typography | `lib/core/theme/app_typography.dart` |
| Colors | `lib/core/theme/app_colors.dart` |
| Radius | `lib/core/theme/app_radius.dart` |
| Theme | `lib/core/theme/app_theme.dart` |
| Progress ring | `lib/core/widgets/progress_ring.dart` |
| Progress bar row | `lib/core/widgets/progress_bar_row.dart` |
| Empty state | `lib/core/widgets/empty_state.dart` |
| Dashboard | `lib/features/dashboard/` |
| Skills | `lib/features/skills/` |
| Portfolio | `lib/features/portfolio/` |
| Readiness | `lib/features/readiness/` |

---

## 8. Summary

- **Layout:** 4pt grid, 20pt screen padding, single scrollable column, safe area respected. Section order puts “how I’m doing” and “what’s next” before lists.
- **Components:** Two progress patterns (ring, bar row); surface and gradient cards; list rows with 44pt+ touch; one primary CTA per block; consistent empty states and chips.
- **Features:** Skill tracking and portfolio use list + empty state + one add action; readiness is ring-first with optional breakdown; recommendations are horizontal chips on dashboard.
- **Production UX:** Skeletons for lists, inline errors with retry, clear back navigation, 44pt touch targets, and accessible labels.

This system keeps the app **non-generic** by tying layout and components to SkillBridge’s story (bridge as journey, progress, and next steps) and to production patterns (loading, errors, navigation, a11y).
