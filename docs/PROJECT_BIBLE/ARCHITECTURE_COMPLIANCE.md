# Architecture Compliance Report — 16-Module Ecosystem Blueprint

> Verifies the live codebase against the canonical "Divinity Complete Ecosystem" architecture
> (Website + Android/iOS App + Admin Panel) now encoded in the `divinity_tte` skill and in
> [03_System_Architecture](03_System_Architecture.md) / [AI_CONTEXT](AI_CONTEXT.md) rules 9–10.
>
> Method: direct source scan of `divinity_flutter/lib/features`, `divinity_flutter/supabase/migrations`,
> `divinity_flutter/supabase/tests`, and `divinity-third-eye/divinity/app`. Verified 2026-07-01.

## Verified structural facts

| Artifact | Found | Evidence |
|---|---|---|
| Flutter feature folders | 18 | `admissions, analytics, attendance, auth, batches, certificates, dashboard, holidays, home, leave, notifications, payments, profile, shared, shells, therapeutic_logs, trainer, transformation` |
| Role shells | 4 | `admin_shell.dart, role_shell.dart, student_shell.dart, trainer_shell.dart` |
| Supabase migrations | 29 | `001`…`029` (append-only); 029 = missing indexes (LB-8 fix) |
| pgTAP security tests | 12 | `c1`…`c12` (privileged fields, geofence, streak, JWT role, latches, lead convert, therapeutic logs, payment verification, certificates, workouts, events, reports) |
| Website routes | 12 | `about, blog, contact, events, gallery, pricing, privacy, schedule, services, terms, trainers, verify` |
| Website API routes | 3 | `/api/contact, /api/subscribe, /api/verify-certificate` |
| Student shell tabs (shipped) | 8 | Home, Third Eye, Workouts, Attendance, Leaves, Payments, Profile, Certificates |

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
| 13 | Certificates | ✅ Built | `certificates` (migr. 024); web `/verify` + `/api/verify-certificate`; pgTAP c9 |
| 14 | Website CMS | ✅ Built | Sanity + `lib/content.ts` zero-config fallback |
| 15 | Reports & Analytics | ✅ Built | `analytics` feature with `ReportsScreen`, `get_reports_data` RPC (migr. 028), CSV export, pgTAP c12. |
| 16 | Settings & Roles | ✅ Built | role-based shells; JWT sync; privileged-field locks |

**Score: 15 / 16 fully built, 1 partial/stub.** (Workout Management + Events completed 2026-07-01; Reports & Analytics completed Session 17.)

## Student dashboard compliance (blueprint vs shipped)

The blueprint's Student Dashboard lists 14 sections. Shipped app surfaces:

| Blueprint section | Built as app surface? |
|---|---|
| My Profile | ✅ (Profile tab) |
| Membership | ✅ (within Payments) |
| Attendance | ✅ (tab) |
| Today's Class | ❌ not a surface |
| Weekly Schedule | ❌ not a surface (web `/schedule` only) |
| Events | ✅ (Events screen — browse + register; admin CRUD; publish notifications) |
| Workout Plan | ✅ (Workouts tab — student sees assigned workouts, marks complete) |
| Progress | ✅ (Third Eye tab) |
| Certificates | ✅ (tab) |
| Notifications | ✅ (screen) |
| Payment History | ✅ (within Payments) |
| Feedback | ❌ not built |
| Support | ❌ not built |
| Leaves (extra, shipped) | ✅ (tab — not in blueprint list) |

## Remaining backlog to reach full blueprint compliance

1. ~~**Workout Management**~~ — ✅ Done 2026-07-01 (migration 026, `lib/features/workouts`, pgTAP c10).
2. ~~**Events in app**~~ — ✅ Done 2026-07-01 (migration 027, `lib/features/events`, pgTAP c11).
3. ~~**Reports & Analytics suite**~~ — ✅ Done Session 17 (migration 028 `get_reports_data` RPC + indexes, `lib/features/analytics`, pgTAP c12).
4. **Settings & Roles gaps** — Trainer Management tab missing from `admin_shell.dart` (BUG-H02).
5. **Student surfaces** — add Today's Class, Weekly Schedule, Feedback, and Support to close the dashboard gap.

These are additive and must follow AI_CONTEXT rule 10 (Module Implementation Standard: DB migration + RLS/triggers + repository/provider + screens + tests). None require relitigating a locked ADR.

## Governance

- Architecture is the source of truth via the `divinity_tte` skill (`.agents/skills/divinity_tte/`) and AI_CONTEXT rules 9–10.
- Any new module or surface must map to one of the 16 modules and be recorded here + in [MODULE_INDEX](MODULE_INDEX.md).
