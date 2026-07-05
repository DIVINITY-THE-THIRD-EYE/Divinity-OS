# 03 — Feature Status

## Doc authority order (unchanged from prior audit, still correct)

When any two docs disagree, trust the newer/more-evidenced one: **this audit (2026-07-05) > `docs/VERIFIED_AUDIT_2026-07-02.md` > `docs/PROJECT_BIBLE/ARCHITECTURE_COMPLIANCE.md` > `docs/PROJECT_BIBLE/AI_CONTEXT.md` > everything else.** `docs/AUDIT1JULY.MD` and `docs/IMPLEMENTATION1JULY.MD` are self-flagged/externally-confirmed superseded — useful only for granular historical bug descriptions, never for status counts. Several `docs/PROJECT_BIBLE/*.md` files repeat stale counts (e.g. "12 tables", "c1-c8 security tests", "14 feature modules") that this audit's live-verified numbers (25 tables, 23 pgTAP files, 21+ Flutter feature folders) supersede.

## Feature inventory

| Module | Status | Evidence | Priority if incomplete |
|---|---|---|---|
| Auth (email/OTP/Google/Apple/phone) | Complete | `flutter-app/lib/features/auth/data/auth_repository.dart:14-49` (full interface + impl) | — |
| Attendance + geofence check-in | Complete | `check_in()` RPC, `supabase/migrations/010_attendance_geofence_rpc.sql:46-132`, extended `039:330-412` | — |
| Streak tracking | Complete | `attendance_streak_trigger` / `recalculate_student_streaks()`, `014_attendance_streak_trigger.sql`; pgTAP `c3_streak_test.sql` (7 tests) | — |
| Leave & package-extension (decision #1) | Complete, verified correct | `039_leave_business_rules.sql`; pgTAP `c17` (17 tests, now 17/17 after this session's fix) — auto-approve ≥24h+in-cap, admin approval over-cap, week-off exclusion, attendance-override recredit, package-extension math all verified | — |
| Admin-manageable Plans module (decision #4) | Complete | `038_plans_module.sql` — plan name/price/duration, `is_addon`, `certify_after_days`, active/inactive toggle, RLS (admin write, public read of active) | — |
| Razorpay removal (decision #2) | Complete | `037_remove_razorpay.sql` — CHK constraint restricts `payment_method` | — |
| Enrollment waitlist (decision #24, #26) | Complete | `040_enrollment_waitlist.sql` — `batch_waitlist` table, `request_enrollment()`/`convert_waitlist_entry()` RPCs, admin-picks-who-gets-the-spot semantics; pgTAP `c18` (9 tests) | — |
| Hybrid enrollment (self-request + staff-confirm) (decision #22) | Complete | `040_enrollment_waitlist.sql:62-69` — `enrollments.status` now PENDING/CONFIRMED/REJECTED, new `enrollments_insert_student_pending` + `enrollments_update_staff` policies | — |
| Trial-class tracking (decision #32) | Complete | `041_trials_and_lead_conversion.sql` — `trial_attendances` table; pgTAP `c19` | — |
| Lead conversion — admin/trainer/self (decision #31) | Complete | `041_trials_and_lead_conversion.sql` — `convert_lead_to_member()` extended to trainer callers, new `self_convert_lead()` RPC | — |
| Certificate auto-issuance (decision #33) | Complete | `042_certificate_automation.sql` — `check_and_issue_certificate()` checks 80% attendance + program duration, `auto_issued` flag, reactive trigger on attendance; pgTAP `c20` | — |
| Multiple certificates per student/program (decision #34) | Complete | `042` unique index on `(student_id, plan_id)` — one cert per program, not one lifetime cert | — |
| Special-class add-ons as separate certificate tracks (decision #34) | Complete | `plans.is_addon` column (`042`) | — |
| Admin audit log — sensitive actions only (decision #14) | Complete, correctly scoped | `043_notifications_and_admin_ops.sql` — `audit_log` table, RLS admin-select-only, triggers log `PAYMENT_VERIFIED`/`ROLE_CHANGED`/`STUDENT_SUSPENDED`/`STUDENT_REACTIVATED`/`PLAN_PRICE_CHANGED` — matches the "sensitive actions only, not full activity log" scope exactly | — |
| Admin broadcast notifications (decision #43) | Complete | `send_broadcast(p_target, p_title, p_body)`, `043` — targets STUDENTS/TRAINERS/ALL | — |
| Drop-off risk alerts (decision #21) | Complete | `check_dropoff_risk()` trigger, `043` — fires on 3+ consecutive ABSENT or <50% attendance in trailing 2 weeks, 7-day cooldown, notifies both Admin and assigned Trainer | — |
| Renewal reminders 7d/1d (decision #36) | Complete, well-engineered | `send_renewal_reminders()`, scheduled via `pg_cron` daily 08:00 IST with a graceful `raise notice` fallback if pg_cron is unavailable in-environment (`043:237-250`) | — |
| Self-service in-app renewal (decision #29) | Complete | `flutter-app/lib/features/payments/presentation/payments_screen.dart` — `_RenewSoonCard`/`_UnpaidRenewalCard` widgets | — |
| Trainer certifications, public + approval gate (decision #12) | Complete | `044_trainer_surfaces.sql` — `users.certifications`/`published`/`submitted_at`, admin-approval-required publish gate, auto-unpublish-on-edit trigger; pgTAP `c22` | — |
| Trainer-scoped reports (decision #40) | Complete | `044` extends `get_reports_data()`/`get_reports_attendance()` with trainer-scoped variants | — |
| Paid events (decision #37, #38) | Complete | `045_event_payments.sql` — `events.is_free`/`price`, payment→registration auto-enroll, free events keep direct self-RSVP; pgTAP `c23` | — |
| i18n Hindi+English — Flutter app (decision #18) | Complete | `lib/l10n/app_en.arb` + `app_hi.arb`, full 44-string parallel translation, generated delegates, switcher UI | — |
| i18n Hindi+English — website (decision #18) | **Partial** | `website/lib/i18n/translations.ts` covers only 17 nav/footer/hero strings, not full page content | Medium — needs a product decision on scope, then an expansion pass |
| Payment screenshot → text conversion (decision #10) | **Not built** | No OCR/conversion code found anywhere in the repo; only the raw `screenshot_url` upload path exists | Low — decision #10 itself says "not yet specified, needs follow-up," so this isn't a broken promise, just unscoped work |
| Theme toggle, both surfaces, cross-surface identical tokens (decision #3) | Complete | Website: `lib/theme/ThemeContext.tsx` (overrides ADR-0012, documented in-code); Flutter: `lib/core/theme/app_theme.dart` cites the website's tokens directly in a comment | — |
| Support tickets | Complete | `034_support_tickets.sql`; pgTAP `c15` (9 tests) | — |
| Student feedback | Complete | `033_student_feedback.sql`; pgTAP `c14` (10 tests) | — |
| Workouts (trainer-authored, student-assigned) | Complete | `026_workouts.sql`; pgTAP `c10` (9 tests) | — |
| Events (general, non-payment) | Complete | `027_events.sql`; pgTAP `c11` (11 tests) | — |
| Therapeutic logs | Complete | `006_holidays_therapeutic_logs.sql` + RLS fix `021`; pgTAP `c7` | — |
| Reports & analytics (4 report types, decision #39) | Complete | `028_reports_indexes.sql` + `035_paginated_reports.sql` — attendance/revenue/membership/events reports, paginated; pgTAP `c12` (10 tests) | — |
| Payment verification flow (manual UPI + screenshot) | Complete | `022_payment_verification_flow.sql`; pgTAP `c8` (12 tests) | — |

## Not independently verified this session (scope/time)

- Exact field-level completeness of trainer certification data entry (owner said "take data from trainer," implying open input — the recommended field set from prior PRD work was not re-confirmed against the live `admin_plans_screen.dart`/trainer profile UI this session).
- Whether the website's Sanity CMS schemas (`discipline`, `plan`, `classSlot`, `testimonial`) are actually populated in the live Sanity project, vs. the local `lib/content.ts` fallback being the de facto content source in production.
- iOS build/signing readiness, Play Console/App Store registration, and other owner-account/console items flagged in prior memory as genuinely outside code — these are unchanged by this audit and still require the account-holder, not an engineering fix.
