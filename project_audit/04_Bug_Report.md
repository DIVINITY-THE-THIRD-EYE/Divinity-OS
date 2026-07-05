# 04 — Bug Report

## Fixed this session

### BUG-1: `c17_leave_business_rules_test.sql` fails on Saturdays/Sundays (FIXED)
- **Location:** `supabase/tests/c17_leave_business_rules_test.sql:188-209` (before fix)
- **Cause:** the late-request test fixture inserted a single-day leave request for `current_date` directly, without walking forward past week-off days the way its own sibling fixtures (`date1`/`date2`/`date3`, same file lines 50-63) explicitly do. When `current_date` is itself a week-off day (Sat/Sun), `process_leave_request()` (`supabase/migrations/039_leave_business_rules.sql:132-137`) legitimately short-circuits to `APPROVED` via a *separate, also-correct* rule ("the entire requested range is week-offs, nothing to approve") — colliding with the late-request assertion, which expected `PENDING`.
- **Impact:** CI-visible test failure two days out of every seven, with no actual product bug behind it. Anyone re-running `supabase test db` on a Saturday/Sunday would see red and could waste time chasing a phantom regression.
- **Reproduction:** run `supabase test db` on any Saturday or Sunday (verified live: 2026-07-05 is a Sunday, `extract(isodow from current_date) = 7`, confirmed via `docker exec supabase_db_Divinity_TTE psql`).
- **Fix applied:** widened the fixture's `end_date` to `current_date + 2` so the range always spans at least one real class day, regardless of which weekday "today" is (week-offs are at most 2 consecutive days) — while `start_date` (what the advance-notice check actually evaluates) stays `current_date`, still guaranteed "late" under the formula. Commit `1cb10cf`.
- **Verification:** `supabase test db` → 188/188 pass (was 186/188).
- **Note on production logic:** the underlying business rule was never wrong. Verified directly by inserting a real weekday leave request in a rolled-back transaction: `status=PENDING, is_auto_approved=false`, exactly per the PRD's ≥24h-advance rule.

## Reported, not fixed (see severity rationale in each item)

### BUG-2: `release-please` CI broken on every run since introduction (FIXED this session)
See [14_Critical_Fixes.md](14_Critical_Fixes.md) for full detail — moved out of this list since it's now resolved (commit `706a2b2`).

### ISSUE-3: `payment_screenshots` storage bucket's public/private flag is not codified anywhere
- **Location:** `supabase/migrations/031_payment_screenshots_bucket_private.sql` (its own header comment admits this)
- **Not a confirmed live bug** — this is a process/infrastructure gap, not a code bug. See [05_Security_Audit.md](05_Security_Audit.md) for the full writeup and recommended remediation.

### ISSUE-4: In-memory rate limiter is weaker than its own comment implies on serverless deployment
- **Location:** `website/lib/rate-limit.ts:1-3` — comment says "suitable for a single-instance / low-traffic marketing site." If deployed to Vercel (referenced elsewhere in the repo), each cold serverless instance gets its own `Map`, so concurrent requests hitting different instances could exceed the intended 5/minute/IP limit. Not independently confirmed against the live Vercel deployment topology this session.
- **Impact:** contact/subscribe form spam-resistance is probably somewhat weaker in production than local testing suggests. Low severity — these are low-value targets (contact form, no auth, no payment surface).

## Areas checked and found bug-free

- **Privilege escalation via `users` self-update** (the historical "C1" issue) — verified the server-side fix (`supabase/migrations/009_lock_privileged_fields.sql`) correctly blocks non-admin changes to `role`/`plan_status`/`expiration_date`/`pause_start_date`/`current_streak`/`max_streak`, mirrored by client-side column filtering in `flutter-app/lib/features/auth/data/auth_repository.dart:141-170`. No regression found.
- **Contact form HTML injection** — `website/app/api/contact/route.ts:131-137` HTML-escapes all user input before embedding in the outgoing email body. No injection path found.
- **Certificate verification PII leakage** — the edge function only returns a masked name (first name + last initial) + programme + issue date, never phone/email/full name. Confirmed by direct read of `supabase/functions/verify-certificate/index.ts`.
- **Batch/event capacity race conditions** — both use `FOR UPDATE` row locks (`enforce_batch_capacity()`, `enforce_event_capacity()`) and have dedicated concurrency pgTAP coverage (`c16_enrollment_concurrency_test.sql`). No race condition found.
