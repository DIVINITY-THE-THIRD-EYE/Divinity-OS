# 08 — Database Report

**Definitive current counts (verified this session against the live migration set — supersedes every prior doc's "12/19/20 tables" and "c1-c8"/"117 assertions" claims):**
25 tables · 45 migrations (001–045, gapless, no reverts) · 40+ functions · 35+ triggers · 1 storage bucket · 1 edge function · 23 pgTAP files / 188 assertions.

## Table inventory (creation migration, RLS status)

All 25 tables have RLS **enabled**, and every table has **at least one policy** — none are fully locked, none were found with RLS on but zero policies.

| Table | Created in | Notable later `alter`s | Policies |
|---|---|---|---|
| `users` | 001 | `auth_provider`(025), `certifications`/`published`/`submitted_at`(044), `is_active`(032), `current_plan_id`(039) | 3 SELECT, 1 INSERT, 2 UPDATE |
| `batches` | 002 | `end_time`/`created_by_id`(013), `radius_meters`(007), coordinate CHK(016) | SELECT/INSERT/UPDATE |
| `leads` | 002 | — | admin-only SELECT/INSERT/UPDATE, +trainer SELECT (041) |
| `enrollments` | 003 | `status` PENDING/CONFIRMED/REJECTED(040) | SELECT/INSERT (staff + student-pending)/UPDATE/DELETE |
| `attendance` | 003 | — (heavy trigger surface instead) | SELECT/INSERT(staff)/UPDATE; direct student INSERT dropped (010), routes through `check_in()` RPC |
| `leave_requests` | 003 | `is_auto_approved`(039) | SELECT/INSERT(student)/UPDATE(admin-only since 039) |
| `payments` | 004 | `screenshot_url`(011), `admin_approved`/`receipt_given_by_trainer`(013), `plan_expiration_date`(022), `plan_id`(038), `event_id`(045) | SELECT(own/admin/trainer)/INSERT(student-pending/admin)/UPDATE(trainer-field-locked/admin) |
| `notifications` | 004 | — | SELECT(own/admin)/UPDATE(own)/INSERT(admin/trainer) |
| `holidays` | 006 | — | SELECT(auth)/INSERT+DELETE(admin) |
| `therapeutic_logs` | 006 | `trainer_comment`/`comment_timestamp`(013) | SELECT/INSERT(staff)/UPDATE(018)/DELETE |
| `transformation_scores` | 008 | — | SELECT(own)/full(admin+trainer) |
| `library_books` | 013 | — | SELECT/admin-all/scoped student UPDATE(030 fix) |
| `certificates` | 024 | `plan_id`/`expiry_date`/`auto_issued`(042), unique idx `(student_id, plan_id)` | SELECT(own)/full(trainer+admin) |
| `plans` | 038 | `certify_after_days`/`is_addon`(042) | SELECT(active-or-admin)/admin-write |
| `workouts`, `workout_exercises`, `workout_assignments`, `workout_completions` | 026 | — | RLS-recursion-safe via `owns_workout()`/`student_sees_*()` helpers |
| `events`, `event_registrations` | 027 | `is_free`/`price`(045) | SELECT(published/own)/admin-write; capacity via `event_is_full()` |
| `student_feedback` | 033 | — | INSERT(student)/SELECT(own+admin+trainer-own-batch)/DELETE(admin) |
| `support_tickets` | 034 | — | full CRUD split student-own vs admin-all |
| `batch_waitlist` | 040 | — | SELECT(own+staff)/INSERT(student)/UPDATE+DELETE(admin) |
| `trial_attendances` | 041 | — | staff-only SELECT/INSERT, admin DELETE |
| `leave_days` | 039 | — | SELECT only — write is trigger-only |
| `audit_log` | 043 | — | admin SELECT only — write is trigger-only |

Plus `storage.objects` (the `payment_screenshots` bucket, migrations 011/031).

## RLS-recursion-safe design pattern

Migration 012 exists specifically to fix a real recursion bug: early policies queried `public.users` from within a `users` RLS policy itself. The fix — `is_admin()`, `is_trainer()`, `is_trainer_or_admin()` `SECURITY DEFINER` helper functions — is now used consistently everywhere a policy needs a role check, and the same pattern was extended for the `workouts`/`events` ownership checks (`owns_workout()`, `student_sees_workout()`, `event_is_full()`, etc.). This is a load-bearing architectural decision: any new table's RLS policy should reuse these helpers rather than re-introducing a direct `users` subquery.

## Triggers & functions — the automation backbone

35+ triggers, 40+ functions, the large majority `SECURITY DEFINER` (correct — they need to write across RLS boundaries: e.g. a student's `check_in()` needs to be able to touch `attendance` even though the student's own RLS policy wouldn't otherwise permit it). Highlights beyond the standard `set_updated_at()` boilerplate:

- **Leave/attendance/package chain:** `process_leave_request()` (before-insert decision) → `finalize_leave_approval()` (materializes `leave_days`, extends `expiration_date`, syncs `attendance` to `ON_LEAVE`, notifies student + trainer) → `recredit_leave_on_attendance()` (a real check-in wins over a SYSTEM-authored `ON_LEAVE` mark, recredits the day, undoes the extension). All three verified correct by pgTAP `c17` (17/17 after this session's fix) plus a live manual test (see [04_Bug_Report.md](04_Bug_Report.md)).
- **Payment state machine:** `process_payment_transitions()` → `propagate_payment_status()` → `lock_payment_fields()` → `handle_payment_notification()` → `log_audit_event()` — a five-stage trigger chain moving a payment from `PENDING` through admin-approval and trainer-receipt-confirmation to `PAID`, each stage logged and notified appropriately. pgTAP `c8` (12 tests).
- **Certificate automation:** `check_and_issue_certificate()` / `trigger_certificate_check()` — checks 80% attendance + program duration on every `PRESENT` attendance mark, auto-issues per plan/add-on independently. pgTAP `c20`.
- **Scheduled jobs:** `send_renewal_reminders()` is registered with `pg_cron` for a daily 08:00 IST run, with a graceful fallback (`raise notice`) if `pg_cron` isn't available in a given environment — meaning this won't silently no-op in an environment without the extension; it'll tell you.

## Storage

One bucket, `payment_screenshots`. RLS policies on `storage.objects` are correctly scoped (owner-by-path-prefix, admin-all, trainer-all). **See [05_Security_Audit.md](05_Security_Audit.md) for the unresolved finding: the bucket's own public/private flag is not codified in any migration and was found `public = true` on a fresh local replay.**

## Edge functions

One: `verify-certificate`. Public (`--no-verify-jwt`), uses the `service_role` key server-side to bypass RLS for the lookup, validates the certificate code against a strict regex, and returns only a masked name + programme + issue date — good PII hygiene for a publicly-reachable endpoint.

## pgTAP coverage

23 files, **188 assertions** (verified this session, post-fix — was 186/188 before this session's `c17` fix). Coverage spans every migration from the original privilege-escalation fix (`c1`) through the newest paid-events feature (`c23`). No table-level feature was found with zero test coverage.

## Migration hygiene

Sequential, gapless, no reverts, no contradictions. The one meaningful "process debt" item is `031`'s own admission that a full fix requires a manual, non-committed dashboard action — see [05_Security_Audit.md](05_Security_Audit.md).

## Text ER summary (major relationships)

```
users (role: STUDENT|TRAINER|ADMIN) ──< enrollments >── batches ──< workout_assignments
users ──< leave_requests ──< leave_days
users ──< payments >── plans
users ──< attendance >── batches
users ──< certificates >── plans
users ──< trial_attendances                     (leads, pre-conversion)
leads ── convert_lead_to_member() ──> users
batches ──< batch_waitlist >── users
events ──< event_registrations >── users
events ──< payments (event_id, paid events)
users ──< student_feedback / support_tickets / therapeutic_logs / transformation_scores
users (ADMIN action) ──> audit_log (append-only, trigger-written)
storage.objects (payment_screenshots bucket) ── payments.screenshot_url
```
