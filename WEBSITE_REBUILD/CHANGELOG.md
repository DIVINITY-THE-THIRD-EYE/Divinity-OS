# CHANGELOG — WEBSITE_REBUILD

Format: `## [date] — <task file>` then bullet list of concrete changes.
Newest on top. Every completed task file appends exactly one entry.

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
