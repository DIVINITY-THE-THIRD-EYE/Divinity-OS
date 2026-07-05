# Divinity — The Third Eye — Project Guide

## Canonical layout

Three first-party surfaces sharing one Supabase project:
- `flutter-app/` — the mobile app (package `divinity_app`), 3 role-based shells (Student/Trainer/Admin).
- `website/` — Next.js 14 App Router marketing site, optional Sanity CMS with a local `lib/content.ts` fallback.
- `supabase/` — shared Postgres backend: migrations, RLS policies, triggers, 1 edge function, pgTAP tests.

Ignore anything referencing `divinity_flutter/`, `Divinity/apps/`, or similar — those are legacy/reference material excluded from this monorepo (see root `.gitignore`).

## Before trusting any status claim, re-run the gates

This project moves fast (45 migrations as of 2026-07-05, up from 36 three days earlier). Docs and memory go stale quickly — always re-verify against live code/gates rather than trusting a prior audit's numbers.

```bash
# Flutter
cd flutter-app && flutter analyze && flutter test

# Website
cd website && npm install && npx tsc --noEmit && npm run lint && npm run test && npm run build

# Database
supabase start && supabase test db
```

As of the 2026-07-05 audit (see `project_audit/`): all green — 262/262 Flutter tests, 66/66 website tests, 188/188 pgTAP assertions, clean lint/typecheck/build.

## Doc authority order (when docs disagree)

Newest/most-evidenced wins: **`project_audit/` (this audit, 2026-07-05) > `docs/VERIFIED_AUDIT_2026-07-02.md` > `docs/PROJECT_BIBLE/ARCHITECTURE_COMPLIANCE.md` > `docs/PROJECT_BIBLE/AI_CONTEXT.md` > everything else.** `docs/AUDIT1JULY.MD` and `docs/IMPLEMENTATION1JULY.MD` are historical only — self-flagged/externally-confirmed superseded, useful only for granular bug history, never for status counts.

## Database conventions (follow these for any new migration)

- One migration file per change, numbered sequentially, with a header comment explaining the *why*, not just the *what* — this repo's migrations are unusually well-documented and that's a maintained convention, not a one-off.
- Any new RLS policy needing a role check should reuse the existing `is_admin()` / `is_trainer()` / `is_trainer_or_admin()` `SECURITY DEFINER` helper functions (introduced in migration 012 specifically to avoid RLS-recursion bugs) rather than writing a fresh subquery against `public.users`.
- Add a matching `cNN_<feature>_test.sql` pgTAP file for any new migration — the project has near-1:1 migration-to-test-file coverage and that convention has already caught real issues (see `project_audit/04_Bug_Report.md`).
- Date-relative pgTAP fixtures must guard against "today" landing on a week-off day (Sat/Sun) if the logic under test has its own week-off short-circuit — see `project_audit/04_Bug_Report.md` for a worked example of this exact failure class.

## Full audit reports

See `project_audit/` for the complete 17-file breakdown (architecture, feature status, bugs, security, performance, code quality, database, UI/UX, testing, DevOps, tooling, roadmap, and health score) from the 2026-07-05 full engineering audit.
