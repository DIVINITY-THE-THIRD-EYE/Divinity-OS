# DECISIONS (approved — never re-ask)

| ID | Decision | Status | Detail |
|---|---|---|---|
| D001 | "Living Anatomy" concept | **APPROVED** | One continuous 3D scene, three acts (Body → Breath → Stillness). Homepage is the cinematic flagship; all pages share the design language. Never ask again. |
| D002 | Figure mesh source | **APPROVED** | CC/licensed base mesh (fast, free). Do NOT wait for a commissioned sculpt. Verify license before use; uniqueness comes from art direction (materials, lighting, breath animation, flow lines). Commissioned sculpt may replace it post-launch. |
| D003 | Student login on website | **APPROVED** | Reuse existing Supabase auth. Same account, same database, no duplicate auth/profiles/business logic. Students only. |
| D004 | Flutter Web integration | **APPROVED** | After login, student dashboard hosts the Flutter Web app so it feels part of the website. See `13_FLUTTER_WEB.md` for the two-stage approach (link-out first, embed second). |
| D005 | Centralized content system | **APPROVED** | Every editable business fact lives in `website/content/*.ts` (typed modules, Sanity can override). One-file edits propagate site-wide. Never hardcode. |
| D006 | Day/night theme | **APPROVED** | Supersedes website ADR 0012 (no-theme-toggle). Two-layer theming: CSS semantic tokens + 3D scene lighting presets. Persisted, defaults to `prefers-color-scheme`. |
| D007 | WebGL on the homepage | **APPROVED** | Supersedes website ADR 0014 (2D-only hero). Conditions: three+r3f loads AFTER LCP as a deferred chunk; 2D silhouette tier serves mobile / reduced-motion / no-WebGL / low-memory; Lighthouse CI gates enforce budgets. |
| D008 | Full-site rebuild scope | **APPROVED** | Every page, not just homepage: Home, About, Founder, Trainers, Programs, Therapeutic Yoga, Meditation, Membership, Pricing, Schedule, Events, Gallery, Testimonials, FAQ, Blog, Contact, Certificate Verification, Privacy, Terms, Refund, Sitemap. |
| D009 | Performance floor | **APPROVED** | Lighthouse desktop ≥95, mobile ≥90, LCP <2.0s, CLS <0.05, INP <150ms. Non-negotiable; effects that can't fit use their fallback. |
| D010 | No new auth/analytics/CMS vendors | **APPROVED** | Stack stays: Next.js 14, Supabase, Firebase (app-side), Sanity (optional), Brevo. New npm packages only with clear justification recorded here. |
| D011 | Executor autonomy charter | **APPROVED** | Engineering decisions belong to the executing model (see `99_MODEL_INSTRUCTIONS.md` → Autonomy charter). Objectively better implementations are made immediately and documented in the EVOLUTION LOG below. Human approval only for business decisions (→ `PLACEHOLDERS.md`) and the launch itself. |
| D012 | Branch-as-flag release | **APPROVED** | No runtime feature flags for the rebuild. Build in place on `rebuild/living-anatomy`; preview deployment = review surface; merge = launch; rollback = promote previous deployment. See EVOLUTION LOG E-001. |

## EVOLUTION LOG (documented deviations — the charter's paper trail)

Every replaced approach gets an entry with all four fields. Format:

```
### E-xxx | date | <short title>
- What changed:
- Why it is better:
- What it replaced:
- Trade-offs:
```

### E-001 | 2026-07-09 | Branch-as-flag release strategy
- What changed: rebuild happens in place on the branch; no `NEXT_PUBLIC_NEW_HOME` runtime
  flag, no `home-legacy/` copy; merge = launch.
- Why it is better: zero legacy code in the bundle, no dual-render complexity, no
  flag-drift failure mode, preview deployments already provide the review surface,
  rollback is a one-action deployment promote.
- What it replaced: v1 playbook's runtime flag + frozen legacy homepage components.
- Trade-offs: long-lived branch needs periodic rebase onto main (rule added: rebase at
  every phase gate); the old homepage is not togglable at runtime post-merge (git
  history + deployment rollback cover it).

### E-002 | 2026-07-09 | Route-group architecture (marketing / portal split)
- What changed: `app/(marketing)/` owns Lenis/cursor/scroll providers + Nav/Footer;
  `app/(portal)/` gets a minimal layout; root layout keeps only fonts/theme/JsonLd.
- Why it is better: the student portal stops paying for marketing-experience JS
  (smaller, faster app surface); providers live where they're used; clean separation of
  the two products sharing one domain.
- What it replaced: v1 inherited the old site's "everything mounted in root layout".
- Trade-offs: one-time mechanical move of existing route folders into the group
  (URLs unchanged); two layouts to keep consistent for shared chrome (tokens make this cheap).

### E-003 | 2026-07-09 | Reused existing theme system; renamed colliding tokens; fixed a contrast failure
- What changed: `03_DESIGN_SYSTEM.md` assumed no theme system existed and specified new
  `components/ThemeProvider.tsx`/`ThemeToggle.tsx` plus semantic tokens `--ink`/`--ink-muted`.
  Reality (found during execution): `lib/theme/ThemeContext.tsx` already existed, already
  wired into `layout.tsx`/`Nav.tsx`, with working persistence + toggle. Also, `--ink` already
  existed in `globals.css` with a different value, live on 6 components. Changed: reused
  `ThemeContext.tsx` (added a no-flash initial-state fix + inline `beforeInteractive` script),
  added only `ThemeToggle.tsx` as new, renamed the semantic tokens `--ink`/`--ink-muted` →
  `--fg`/`--fg-muted`, and darkened day `--accent` `#a85e2a` → `#9c4a2a` (existing `--clay`
  value) after it failed the 4.5:1 contrast floor at 4.26:1.
- Why it is better: avoids two competing theme providers on one page; avoids silently making
  `About`/`Faq`/`Membership`/`Method`/`SectionHeading`/`PreviewSection` text illegible by
  redefining a CSS variable those un-migrated components already depend on; ships a
  WCAG-AA-passing token set instead of one with a known failing pair.
- What it replaced: `03_DESIGN_SYSTEM.md`'s original (spec-only, unverified-against-repo)
  token names and day-accent value.
- Trade-offs: `--fg`/`--fg-muted` diverge from the task file's original naming (checked 04–19:
  no other task file referenced `--ink` by name, so no further edits needed); the day accent
  is one shade darker than originally speced.

### E-004 | 2026-07-09 | Fixed PromoBar/Nav click-interception bug found via Playwright
- What changed: `PromoBar` was `position: relative` (normal flow) while `Nav` was
  independently `fixed inset-x-0 top-0` — both painted in the same top-of-viewport
  screen region, and PromoBar's higher z-index (350 vs Nav's 300) meant it silently
  captured every click meant for Nav underneath it, site-wide, whenever the promo
  bar was showing. `PromoBar` now measures its own height and publishes it as a
  `--promo-h` CSS variable on `<html>`; `Nav` positions itself at
  `top-[var(--promo-h,0px)]` instead of `top-0`, so the two stack instead of
  overlapping, and Nav's links become clickable again.
- Why it is better: this wasn't a hypothetical — it was caught by the existing
  Playwright suite (`navigates from home to pricing` timed out clicking the Nav
  "Pricing" link; `elementFromPoint` at that link's coordinates resolved to the
  promo bar's own div, not the link). The original test had silently routed
  around it by clicking a mid-page CTA instead of the Nav link, which is why it
  went unnoticed until 04's homepage rebuild removed that mid-page CTA.
- What it replaced: independent fixed positioning with a z-index-only ordering
  (which only controls paint order, not which element "wins" the space it shares
  with another fixed element — both still occupy and capture events for that
  shared region regardless of z-index, whichever paints on top).
- Trade-offs: one `ResizeObserver` + effect in `PromoBar.tsx`; negligible cost.

## Implementation notes (appended by executing models — one line each, dated)

IN-002 | 2026-07-09 | `04_HOMEPAGE.md` step 5 ("FAQ/Journal/Events become footer
links") required adding a `{ href: "/contact#faq", label: "FAQ" }` row to
`lib/nav.ts`'s `footerGroups` (Blog/Events were already present from a prior
session) — `lib/nav.ts` isn't in FILES ALLOWED but the step can't be completed
without touching it. That in turn required a Hindi translation entry in
`lib/i18n/translations.ts` (also not in FILES ALLOWED) to keep
`translations.test.ts`'s completeness check green. Both are small, mechanical,
directly required by the task's own steps — same class as IN-001.

IN-001 | 2026-07-09 | `02_CONTENT_SYSTEM.md` step 5 asks for `content/content.test.ts`, but `vitest.config.ts`'s `include` only globbed `lib/**/*.test.ts` — added `content/**/*.test.ts` to the include array (not in the task's FILES ALLOWED, but omitting it makes step 5 a silent no-op: the file exists, never runs, "validation green" would be a false signal). Charter D011: engineering fix, documented not asked.

## Asset registry (license verification — mandatory before any asset enters repo)

| Asset | Source URL | License | Verified date | Used in |
|---|---|---|---|---|
| _(pending — figure mesh goes here first)_ | | | | |
