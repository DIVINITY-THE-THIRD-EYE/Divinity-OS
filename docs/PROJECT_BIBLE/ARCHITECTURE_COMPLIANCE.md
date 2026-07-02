# Architecture Compliance Report — 16-Module Ecosystem Blueprint

> Verifies the live codebase against the canonical "Divinity Complete Ecosystem" architecture
> (Website + Android/iOS App + Admin Panel) now encoded in the `divinity_tte` skill and in
> [03_System_Architecture](03_System_Architecture.md) / [AI_CONTEXT](AI_CONTEXT.md) rules 9–10.
>
> Method: direct source scan of `flutter-app/lib/features`, `supabase/migrations`,
> `supabase/tests`, and `website/app` — plus live checks against the linked production
> Supabase project (`ryvilbtrsnjncyfeskqm`) and GitHub (`DIVINITY-THE-THIRD-EYE/Divinity-OS`).
> Verified 2026-07-02. This monorepo is now a **single repository** — the old two-repo
> split (`divinity_flutter` repo → now `flutter-app/`, `divinity-third-eye/divinity` repo →
> now `website/`) referenced in older docs no longer applies; the legacy directory
> `divinity_flutter/` (note: NOT `flutter-app/`, which is the live app) is now empty.

## Verified structural facts

| Artifact | Found | Evidence |
|---|---|---|
| Flutter feature folders | 21 | `admissions, analytics, attendance, auth, batches, certificates, dashboard, events, feedback, holidays, home, leave, notifications, payments, profile, shared, shells, support, therapeutic_logs, trainer, transformation, workouts` |
| Role shells | 4 | `admin_shell.dart, role_shell.dart, student_shell.dart, trainer_shell.dart` |
| Supabase migrations | 36 | `001`…`036`, all applied to the live production project with zero schema drift (`supabase db diff --linked` → "No schema changes found") |
| pgTAP security tests | 16 | `c1`…`c16` (privileged fields, geofence, streak, JWT role, latches, lead convert, therapeutic logs, payment verification, certificates, workouts, events, reports, trainer active status, student feedback, support tickets, enrollment concurrency) — 117 assertions, all passing |
| Website routes | 12 | `about, blog, contact, events, gallery, pricing, privacy, schedule, services, terms, trainers, verify` |
| Website API routes | 3 | `/api/contact, /api/subscribe, /api/verify-certificate` |
| Student shell tabs (shipped) | 8 | Home, Third Eye, Workouts, Attendance, Leaves, Payments, Profile, Certificates |
| Production Supabase project | `divinity-tte` (`ryvilbtrsnjncyfeskqm`), `ACTIVE_HEALTHY`, Postgres 17.6.1, region `ap-south-1` | Linked; RLS confirmed live via anonymous REST calls returning `[]`; `payment_screenshots` bucket confirmed `public: false` via direct SQL |
| GitHub Secrets configured | 8 / 8 | `SUPABASE_URL`, `SUPABASE_ANON_KEY`, `SUPABASE_PROJECT_REF`, `SUPABASE_ACCESS_TOKEN`, `ANDROID_KEYSTORE_BASE64`, `ANDROID_STORE_PASSWORD`, `ANDROID_KEY_PASSWORD`, `ANDROID_KEY_ALIAS` (verified via `gh secret list`) |
| `verify-certificate` Edge Function | Deployed, `ACTIVE` | Verified via `supabase functions list` against production |

## Module-by-module compliance (16 core modules)

| # | Module | Status | Notes |
|---|---|---|---|
| 1 | Authentication | ✅ Built | Google/OTP/email, onboarding wizard, DPDP consent, `sync_user_role_to_auth` |
| 2 | User Profiles | ✅ Built | `profile` feature; `lock_privileged_fields` |
| 3 | Student Management | ✅ Built | `admissions` + leads CRM; `convert_lead_to_member` RPC |
| 4 | Trainer Management | ✅ Built | `trainer` feature; `is_trainer` helpers |
| 5 | Batch Management | ✅ Built | `batches`; geofence coords required (migr. 016) |
| 6 | Membership Management | ✅ Built | plan fields on `payments`; web `PlanCalculator` |
| 7 | QR Payment & Verification | ✅ Built | `payments`; state machine + `lock_payment_fields`; pgTAP c8 |
| 8 | Attendance Management | ✅ Built | `check_in` RPC, `haversine_m`, streak trigger; pgTAP c2/c3 |
| 9 | Workout Management | ✅ Built | Migration 026: `workouts` + `workout_exercises` + `workout_assignments` + `workout_completions`; RLS + assignment→notification trigger; trainer builder + student completion screens; pgTAP c10. `therapeutic_logs` retained for narrative notes. |
| 10 | Progress Tracking | ✅ Built | `transformation` (Consistency/Intensity/Mindfulness/Recovery) + AI insights |
| 11 | Events | ✅ Built | Migration 027: `events` + `event_registrations`; RLS (published-only for students, admin-managed), capacity-enforcement + publish→notify triggers; student browse/register + admin CRUD screens; pgTAP c11. Website `/events` marketing pages unchanged. |
| 12 | Notifications | ✅ Built | `notifications` table + FCM; payment notification trigger |
| 13 | Certificates | ✅ Built | `certificates` (migr. 024); web `/verify` + `/api/verify-certificate` (route deployed; live wiring needs `CERT_VERIFY_ENDPOINT` set on Vercel — see [SUPABASE_SETUP](../SUPABASE_SETUP.md)); pgTAP c9 |
| 14 | Website CMS | ✅ Built | Sanity + `lib/content.ts` zero-config fallback |
| 15 | Reports & Analytics | ✅ Built | `analytics` feature with `ReportsScreen`, paginated `get_reports_data` RPC (migr. 028, 035), CSV export, pgTAP c12. |
| 16 | Settings & Roles | ✅ Built | role-based shells; JWT sync; privileged-field locks; Trainer Management (`admin_trainers_screen.dart`, migr. 032, pgTAP c13) reachable via Admin Dashboard Quick Access |

**Score: 16 / 16 fully built.** Two more student-facing modules beyond the original 16
(Feedback, Support) have also been added — see below.

## Beyond the original 16 — additional modules shipped

| Module | Status | Notes |
|---|---|---|
| Student Feedback | ✅ Built | `student_feedback` table (migr. 033), `lib/features/feedback/`, pgTAP c14 |
| Student Support | ✅ Built | `support_tickets` table (migr. 034), `lib/features/support/`, pgTAP c15 |
| Weekly Schedule | ✅ Built | `weekly_schedule_screen.dart` (inside `attendance/presentation/`), routed at `/schedule`, uses `table_calendar` |
| Batch enrollment concurrency guard | ✅ Built | Migration 036, pgTAP c16 |

## Student dashboard compliance (blueprint vs shipped)

The blueprint's Student Dashboard lists 14 sections. Shipped app surfaces:

| Blueprint section | Built as app surface? |
|---|---|
| My Profile | ✅ (Profile tab) |
| Membership | ✅ (within Payments) |
| Attendance | ✅ (tab) |
| Today's Class | ⚠️ Partial — upcoming-class cards on Home; no dedicated single-purpose screen |
| Weekly Schedule | ✅ (`weekly_schedule_screen.dart`, routed at `/schedule`) |
| Events | ✅ (Events screen — browse + register; admin CRUD; publish notifications) |
| Workout Plan | ✅ (Workouts tab — student sees assigned workouts, marks complete) |
| Progress | ✅ (Third Eye tab) |
| Certificates | ✅ (tab) |
| Notifications | ✅ (screen) |
| Payment History | ✅ (within Payments) |
| Feedback | ✅ (`student_feedback_screen.dart`, migr. 033, pgTAP c14) |
| Support | ✅ (`student_support_screen.dart`, migr. 034, pgTAP c15) |
| Leaves (extra, shipped) | ✅ (tab — not in blueprint list) |

**13 / 14 fully built, 1 partial** (Today's Class — functionally covered by the Home screen's
upcoming-class cards and the new Weekly Schedule screen, but not a dedicated single-purpose
surface with trainer bio / batch notes / direct check-in CTA).

## Remaining backlog to reach full blueprint compliance

All items previously tracked here as outstanding are now done:

1. ~~**Workout Management**~~ — ✅ Done (migration 026, `lib/features/workouts`, pgTAP c10).
2. ~~**Events in app**~~ — ✅ Done (migration 027, `lib/features/events`, pgTAP c11).
3. ~~**Reports & Analytics suite**~~ — ✅ Done (migration 028/035 `get_reports_data` RPC + pagination, `lib/features/analytics`, pgTAP c12).
4. ~~**Trainer Management**~~ — ✅ Done (migration 032, `admin_trainers_screen.dart` reachable via Admin Dashboard Quick Access, pgTAP c13).
5. ~~**Student Feedback / Support / Weekly Schedule**~~ — ✅ Done (migrations 033/034, `lib/features/feedback`, `lib/features/support`, `weekly_schedule_screen.dart`, pgTAP c14/c15).

**Only remaining gap:** a dedicated "Today's Class" screen (partial per table above) — cosmetic/UX,
not a missing capability. See [docs/VERIFIED_AUDIT_2026-07-02.md](../VERIFIED_AUDIT_2026-07-02.md)
for operational (non-code) launch blockers.

New modules must still follow AI_CONTEXT rule 10 (Module Implementation Standard: DB migration +
RLS/triggers + repository/provider + screens + tests). None require relitigating a locked ADR.

## Governance

- Architecture is the source of truth via the `divinity_tte` skill (`.agents/skills/divinity_tte/`) and AI_CONTEXT rules 9–10.
- Any new module or surface must map to one of the 16 modules and be recorded here + in [MODULE_INDEX](MODULE_INDEX.md).
