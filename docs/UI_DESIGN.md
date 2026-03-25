# SkillBridge UI Design — Product Design Rationale

**Senior product design spec: non-generic, production-ready UX.**

For the **full UI system** (layout, component catalog, feature patterns, production UX), see **[UI_SYSTEM.md](UI_SYSTEM.md)**.

---

## Design philosophy

SkillBridge’s UI is built around the idea of **“bridge as journey”**: the user is moving from current skills toward career readiness. The interface should feel like a **progress-oriented workspace**, not a generic dashboard.

**Principles:**
- **Journey over dashboard** — Progress and “what’s next” are central; cards and lists support that story.
- **Personal, not corporate** — Copy and layout speak to the individual (e.g. “Your bridge”, “For you”), with clear hierarchy so the user sees their state at a glance.
- **Calm density** — Plenty of whitespace and clear grouping so screens don’t feel like admin panels.
- **Progress is visible** — Readiness and skill progress use consistent, recognizable progress patterns so users build a mental model quickly.

These choices avoid a “template” look by tying layout, copy, and visuals to the product concept instead of generic patterns.

---

## 1. Spacing system

**Decision: 4pt base grid, named scale.**

We use a single scale so spacing is consistent and predictable. All margins and padding come from this scale so the layout never feels arbitrary.

| Token | Value | Use |
|-------|--------|-----|
| `xs` | 4 | Icon–label gap, tight inline spacing |
| `s` | 8 | Between related elements (e.g. label + value) |
| `m` | 16 | Within-card padding, list item internal spacing |
| `l` | 24 | Section spacing, card-to-card |
| `xl` | 32 | Between major sections |
| `xxl` | 48 | Hero to content, screen-level breathing room |

**Design rationale:** 4pt is a common mobile baseline; 8pt steps keep alignment clean. We avoid odd numbers (e.g. 20) so the system stays easy to implement and reason about. Section spacing (`l`, `xl`) is deliberately generous so each block (readiness card, skills block, recommendations) reads as one idea.

---

## 2. Typography hierarchy

**Decision: Five-level hierarchy with clear weight and size steps.**

We define explicit roles so every piece of text has a place. That creates a clear reading order and avoids “everything looks the same” template feel.

| Level | Role | Size | Weight | Use |
|-------|------|------|--------|-----|
| **Display** | Hero, app name | 28sp | Bold (700) | One per screen max (e.g. “Your bridge”) |
| **H1** | Screen title | 22sp | SemiBold (600) | Page title |
| **H2** | Section title | 17sp | SemiBold (600) | “Skill progress”, “Recommended for you” |
| **Body** | Main content | 15sp | Regular (400) | Descriptions, list content |
| **Caption** | Supporting | 13sp | Regular (400) | Hints, metadata, empty-state secondary |

**Design rationale:** One dominant element per screen (display or H1) establishes focus. Section titles (H2) are smaller than the screen title so hierarchy is obvious. Body at 15sp is readable without crowding. Caption is clearly secondary so we don’t rely on color alone for hierarchy. We avoid mid-weights (e.g. Medium) for body so the jump from Regular to SemiBold stays clear.

---

## 3. Progress visualization

**Decision: Two patterns — ring for one number, bars for lists.**

- **Single metric (e.g. readiness %):** Circular progress ring with the value in the centre. Ring is thick enough to read at a glance; colour reflects state (e.g. primary for neutral, secondary for “on track”) if we add thresholds later.
- **Multiple items (e.g. skills):** Horizontal bar per row, with a short label and optional level badge. Same bar style everywhere so “this is progress” is immediately recognizable.

**Design rationale:** One pattern for “your overall score” and one for “each item’s progress” keeps the mental model simple. We avoid decorative charts (e.g. donuts with multiple segments) so the UI doesn’t look like a generic analytics template. Progress is always 0–100 (or 0–1) so we can reuse the same components across features.

---

## 4. Personalization

**Decision: Name, contextual copy, and “for you” sections.**

- **Greeting:** Use the user’s display name when available (“Hi, Alex”) and a neutral fallback when not (“Hi there”). Placed at the top so the screen feels personal from the first line.
- **Contextual copy:** Empty states and CTAs reference the user’s situation (“Add your first skill”, “Your readiness improves when…”). Avoid generic “No data” or “Get started” without context.
- **Recommended for you:** A dedicated section with suggestions (e.g. next skills) so the home screen feels tailored. Section title uses “for you” to signal personalization.

**Design rationale:** Personalization is about relevance and tone, not just “Hello {name}`. We combine name, contextual empty states, and a clear “for you” block so the app feels like a coach, not a form.

---

## 5. Empty states

**Decision: Illustration + headline + short explanation + single primary action.**

Every list or content area can be empty. We treat empty as a normal state and design for it explicitly.

- **Structure:** Icon or simple illustration (not decorative art), headline (e.g. “No skills yet”), one sentence explaining why it matters or what happens next, one primary button (e.g. “Add skill”).
- **Tone:** Encouraging and specific (“Add your first skill to see progress here”) rather than generic (“No data”).
- **No dead ends:** Empty state always offers the next action so the user is never stuck.

**Design rationale:** Empty states are the first experience for new users and recurring for sparse data. A consistent pattern (icon + headline + explanation + CTA) makes the product feel considered. One CTA keeps focus and avoids template-style “Browse” / “Learn more” clutter.

---

## 6. Production UX patterns

**Decision: Explicit patterns for loading, errors, and navigation.**

- **Loading:** Use skeleton placeholders for list/card content where possible so layout doesn’t jump. For single metrics (e.g. readiness), a small pulse or shimmer on the card is acceptable.
- **Errors:** Inline message near the trigger (e.g. under a form) with optional retry. Avoid full-screen error unless the whole screen failed.
- **Pull-to-refresh:** Used on the dashboard and any list that can update (skills, portfolio) so users can refresh without a menu.
- **Back / navigation:** Clear back from secondary screens to dashboard; primary actions (e.g. “Add skill”) are buttons or FABs, not buried in app bars.
- **Touch targets:** Minimum 44pt for primary actions; list rows and cards are tappable as a whole, not just a small arrow.

**Design rationale:** Consistent loading and error handling build trust. Pull-to-refresh is a standard mobile pattern and fits a “check my progress” use case. Large touch targets and full-row taps reduce mis-taps and feel more app-like than web-like.

---

## 7. Avoiding “template” look

**Concrete choices:**

- **No generic illustrations:** We use simple icons or a single brand motif (e.g. bridge) in empty states, not stock “people with laptops” art.
- **Named sections, not “Dashboard”:** Section titles describe content (“Skill progress”, “Recommended for you”) so the screen reads as SkillBridge, not “Dashboard v2”.
- **One primary accent:** Primary blue and growth green are used for meaning (actions, progress, success), not for decorating every card. Cards are mostly neutral with one accent per block.
- **Consistent progress language:** Same progress treatment (ring for score, bars for list items) across the app so the product has a recognizable visual language.
- **Copy in first person / second person:** “Your skills”, “Your bridge”, “Add your first…” so the product speaks to the user, not about “the system”.

---

## 8. Implementation checklist

- [ ] All spacing from `AppSpacing` (or equivalent tokens).
- [ ] All text styles from `AppTypography` (or theme extensions).
- [ ] Readiness and single-metric progress use the shared ring component.
- [ ] List-based progress uses the shared bar row component.
- [ ] Every list/content screen has an empty state with headline + explanation + one CTA.
- [ ] Dashboard greeting uses display name; “Recommended for you” is present.
- [ ] Pull-to-refresh on dashboard and list screens.
- [ ] Loading: skeletons or shimmer where content will appear; errors inline with retry.

---

## 9. Implementation reference

| Decision | Implementation |
|----------|----------------|
| Spacing scale | `lib/core/theme/app_spacing.dart` |
| Typography scale | `lib/core/theme/app_typography.dart` |
| Radius tokens | `lib/core/theme/app_radius.dart` |
| Theme (colors + text theme) | `lib/core/theme/app_theme.dart` |
| Progress ring (single metric) | `lib/core/widgets/progress_ring.dart` |
| Progress bar row (list items) | `lib/core/widgets/progress_bar_row.dart` |
| Empty state | `lib/core/widgets/empty_state.dart` |
| Dashboard (personalization, progress, sections) | `lib/features/dashboard/` |
| Skills / Portfolio / Readiness (empty states, titles) | `lib/features/skills/`, `portfolio/`, `readiness/` |

This document is the single source of truth for UI and UX decisions so the implementation stays consistent and non-generic.
