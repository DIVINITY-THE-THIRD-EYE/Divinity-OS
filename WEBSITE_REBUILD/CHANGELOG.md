# CHANGELOG — WEBSITE_REBUILD

Format: `## [date] — <task file>` then bullet list of concrete changes.
Newest on top. Every completed task file appends exactly one entry.

## [2026-07-09] — 04_HOMEPAGE
- Route-group restructure: `app/(marketing)/layout.tsx` owns all marketing
  chrome; root layout slimmed to fonts/theme/JsonLd. All routes moved via
  `git mv`; URLs unchanged, verified with Playwright.
- Rebuilt the homepage as 9 sections (Hero, AboutStrip, Programs, Benefits,
  Trainer, Voices, GalleryPreview, FinalCta, Footer) per D001's three acts.
  Newsletter moved into Footer; FAQ footer link added.
- Wired the ₹99-offer hardcodes (Hero, FinalCta, PromoBar) to
  `content/offers.introOffer`, closing out the exceptions flagged in 02.
- Deleted orphaned `Marquee.tsx`/`TrustBadges.tsx` (verified zero imports
  first); kept `Method.tsx`/`StatsBand.tsx` (still live on `/about`).
- Found and fixed a real bug via Playwright: PromoBar was silently blocking
  every click on the Nav underneath it (both independently `fixed` at the
  same screen region). Not hypothetical — an existing test had unknowingly
  routed around it.
- Validation green: lint, tsc, 121 vitest tests, 10 Playwright e2e tests,
  next build (36 routes), zero horizontal overflow at 375/1440px, both
  themes checked, zero orphaned components (`knip`).

## [2026-07-09] — 03_DESIGN_SYSTEM
- Added semantic token layer to `globals.css` (`--surface`/`-2`/`-3`, `--fg`/
  `--fg-muted`, `--accent`/`--accent-2`, `--line`, `--glow`) + Tailwind mapping
  + type scale (`display-xl`/`-l`/`-m`, `lead`, `body`, `caption`, balanced text).
- Reused the pre-existing `lib/theme/ThemeContext.tsx` (found already wired
  into `layout.tsx`/`Nav.tsx`) instead of building a new provider; added the
  no-flash init script and `components/ThemeToggle.tsx`.
- Fixed a real hydration bug caught in browser preview (initial-state read of
  `data-theme` inside `useState` caused server/client mismatch) — state now
  starts `"dark"` on both, self-corrects post-mount.
- Renamed `--ink`/`--ink-muted` → `--fg`/`--fg-muted` (collided with an
  existing, differently-valued, live token) and darkened day `--accent` to
  pass the 4.5:1 contrast floor — both documented in DECISIONS.md E-003 and
  `design/adr/0015-day-night-theme.md`.
- Validation green: lint, tsc, 121 vitest tests, next build (36 routes),
  manual toggle verification in browser preview.
- **Phase 1 gate passed** (01+02+03) — rebased onto main (no-op, main unchanged).

## [2026-07-09] — 02_CONTENT_SYSTEM
- Created `website/content/` (18 typed modules + index barrel) as the single
  source of truth for business data; moved every fallback constant out of
  `lib/content.ts` verbatim.
- `lib/content.ts` rewritten as a compat/merge layer — re-exports every old
  name, reassembles the legacy flat `site` object. Zero consumer edits needed.
- Added `content/content.test.ts` (55 tests) + registered it in
  `vitest.config.ts`.
- Hardcode sweep found 3 pre-existing `₹99` hits in homepage components —
  documented as exceptions (JSX edits out of this task's scope, deferred to
  `04_HOMEPAGE.md`).
- Validation green: lint, tsc, 121 vitest tests, next build (36 routes).

## [2026-07-09] — 01_REPO_PRECHECK
- Committed parked pre-rebuild diff, created `rebuild/living-anatomy` branch.
- Baseline validation green: lint, tsc, 66 vitest tests, next build (36 routes).
- No application code changed.

## [2026-07-09] — Playbook evolution pass
- Added Autonomy charter (99, D011): executor owns engineering decisions; deviations
  documented in EVOLUTION LOG, never asked.
- Replaced runtime-flag release with branch-as-flag (D012, E-001): edits across
  00/04/05/12/13/15/18/19; `home-legacy/` concept removed; per-task deletion sweeps added.
- Added route-group architecture baseline `(marketing)`/`(portal)` (E-002) to 00/04/12.
- Phase gates converted from approval stops to self-validating checkpoints with
  rebase-onto-main; only human gates left: launch (BD-001) + business placeholder rows.
- PLACEHOLDERS.md: new "Pending business decisions" section (BD-001…BD-004).

## [2026-07-09] — Playbook creation
- Created `WEBSITE_REBUILD/` execution playbook (20 task files + 5 support files).
- No application code modified.
