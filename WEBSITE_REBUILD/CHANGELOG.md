# CHANGELOG — WEBSITE_REBUILD

Format: `## [date] — <task file>` then bullet list of concrete changes.
Newest on top. Every completed task file appends exactly one entry.

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
