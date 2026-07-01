# Project Bible — Changelog

Changes to **this Bible** (not the product; product history is in [20_Project_History](20_Project_History.md) / [PROJECT_HISTORY.md](PROJECT_HISTORY.md)).

## 2026-07-01 — v1.5 (Module 11 production audit — issues found & fixed)

Full pre-approval audit of Events. Three issues found and fixed (verified, not assumed):
- **Concurrent-registration capacity bypass (critical):** the capacity check lived only in a non-locking RLS `count(*)`; two simultaneous transactions both passed (proven live: 2 rows for capacity 1). Fixed with a BEFORE INSERT `enforce_event_capacity` trigger that row-locks the event (`FOR UPDATE`), serializing registrations. Re-proven: second concurrent insert now rejected, final count 1.
- **Migration idempotency:** `CREATE POLICY` statements weren't guarded; added `drop policy if exists`. Re-applying 027 against a live DB now succeeds.
- **Placeholder/dead code:** removed never-populated `ends_at` + `cover_image_url` columns (and Dart plumbing) and the unused `isPast` getter.
- Verified clean: RLS enabled on both tables; least-privilege policies; both (now three) SECURITY DEFINER functions have fixed `search_path`; no trigger recursion; FKs SET NULL/CASCADE (no orphans); all join/lookup indexes present; counts correct after delete (live `count(*)`, pgTAP c11.11); publish notifies exactly once (proven — no re-notify on edits); UTC throughout (`timestamptz` + `toUtc()`).
- Gates: `flutter analyze` clean, Flutter 231/231, pgTAP 81/81. Module 11 is production-ready.

## 2026-07-01 — v1.4 (Module 11 — Events shipped)

- Built Events in-app on the existing architecture: migration `027_events.sql` (`events`, `event_registrations`), RLS (students see only PUBLISHED, admins manage, students self-register), `event_is_full` capacity guard + `notify_event_published` trigger, and pgTAP `c11_events_test.sql`.
- Flutter feature `lib/features/events/` (domain, repository, providers, student browse/register screen + admin CRUD screen); Events reached via appbar action in student & admin shells, with FCM deep-link target `events`. Website `/events` pages untouched.
- Tests: 231 Flutter tests pass (214 → 231), pgTAP 80/80 (added c11), `flutter analyze` clean.
- Compliance now **14/16 modules fully built**; updated [ARCHITECTURE_COMPLIANCE](ARCHITECTURE_COMPLIANCE.md), [09_Database](09_Database.md) (19 tables, migrations 001–027), and the `divinity_tte` skill module 11.

## 2026-07-01 — v1.3 (Module 9 — Workout Management shipped)

- Built Workout Management to production quality on the existing architecture: migration `026_workouts.sql` (`workouts`, `workout_exercises`, `workout_assignments`, `workout_completions`), RLS reusing `is_admin`/`is_trainer`/`is_trainer_or_admin` + enrollment checks, `notify_workout_assignment` trigger, and pgTAP `c10_workouts_test.sql`.
- Flutter feature `lib/features/workouts/` (domain, repository, providers, trainer builder + student completion screens); wired "Workouts" tabs into trainer and student shells with FCM deep-link targets.
- Tests: 214 Flutter tests pass (197 → 214), `flutter analyze` clean.
- Compliance now **13/16 modules fully built**; updated [ARCHITECTURE_COMPLIANCE](ARCHITECTURE_COMPLIANCE.md), [09_Database](09_Database.md) (17 tables, migrations 001–026), and the `divinity_tte` skill module 9.

## 2026-07-01 — v1.2 (architecture compliance verification)

- Re-scanned the live codebase against the 16-module ecosystem blueprint (now in the `divinity_tte` skill + AI_CONTEXT rules 9–10).
- Added [ARCHITECTURE_COMPLIANCE.md](ARCHITECTURE_COMPLIANCE.md): verified 12/16 modules fully built, 3 partial/stub (Workout, Reports/Analytics, plus Events web-only), and mapped the student-dashboard blueprint against the 7 shipped tabs.
- Verified structural facts: 18 Flutter feature folders, 4 role shells, 26 migrations (001–025), 9 pgTAP tests (c1–c9), 12 website routes, 3 API routes.
- Recorded the backlog needed to reach full blueprint compliance (Workout schema, in-app Events, reporting suite, Today's Class/Weekly Schedule/Feedback/Support surfaces).

## 2026-07-01 — v1.1 (onboarding consent & test completeness)

- Resolved the Dart Unit Test gap in `COMPLETENESS_AUDIT.md` after verifying the 197 passing tests.
- Documented the new DPDP-compliant Location and Health data consent step in the student onboarding flow.
- Synced the database schema audits and remote config parameter listings.

## 2026-06-30 — v1.0 (initial generation)

- Generated the full Project Bible from a live-repository scan: 31 phase docs (00–30), index/reference files, and 3 domain appendices.
- Source method: git state + content hashes + reference tracing; every claim traceable; unknowns marked `[Needs Verification]`.
- Companion workspace cleanup performed first — see [EXTRA_FILES/MIGRATION_REPORT.md](../EXTRA_FILES/MIGRATION_REPORT.md).

### Coverage at v1.0
- Strong (code-derived): repository map, architecture, database/RLS, auth, security, website, app (student/trainer/admin), integrations, testing, design system.
- Partial / flagged: business pricing, analytics provider, infra tiers/domains, compliance (DPDP), DR targets, audit logging, scheduled jobs — all `[Needs Verification]`.

## How to update

Bump the version + date here whenever a phase doc changes materially. Keep a one-line summary per change.

> Next: resolve `[Needs Verification]` items with the academy owner; transcribe exact perf budgets and analytics event names from `design/`.
