# Phase 7 — Admin Panel

> **Admin role shell** (`features/shells/admin_shell.dart`) inside the Flutter app. Admins have full RLS access. Sources: `lib/features/*/presentation/admin_*`, dashboard feature.

> Note: a separate web-based admin (the Prisma site at `Divinity/apps/divinity-website`) exists but is **not** the live admin surface — the live admin is the Flutter app's admin shell. `[Needs Verification]` if a web admin is planned.

## Dashboard

`dashboard/presentation/admin_dashboard_screen.dart` + `dashboard_repository` + `dashboard_stats` domain — KPIs (students, attendance, payments, leads) rendered with `fl_chart`.

## Student Management

Full CRUD over `users` (`admins_select_all`, `admins_update_all`, `admins_insert`). Activate pending students (clears the pending-approval gate). Shared `students_screen.dart`.

## Trainer Management

Trainers are `users` with `role='trainer'`; admins assign roles (role change syncs to JWT via `sync_user_role_to_auth`). `[Needs Verification]` for a dedicated trainer-management screen vs. generic user management.

## Memberships

Membership = plan on `payments` (`plan_name`, `plan_expiration_date`). Admin payment screens manage approval and expiry. Plan definitions for the website live in Sanity (`plan.ts` schema) / `lib/content.ts`. `[Needs Verification]`: unified membership entity across app+web.

## Payments

`payments/presentation/admin_payments_screen.dart` — verify/approve payments, manage status transitions, view screenshots. Backed by payment state machine (022/023). CSV export added (recent commit "admin CSV export").

## Classes

`batches/presentation/admin_batches_screen.dart` — create/edit batches (name, schedule, coordinates, radius, end_time). Coordinates required (016).

## Attendance

Admin views across all students/batches (`attendance_select` admin scope, `attendance_update_staff`). Reports below.

## Reports

Dashboard stats + **CSV export** (`share_plus`/`path_provider`) for payments/attendance. `[Needs Verification]` for the full report catalog.

## CMS

Marketing content is managed in **Sanity** (web), not the app. Admins edit disciplines/plans/testimonials there. See [25_Assets_Content](25_Assets_Content.md).

## Settings

`[Needs Verification]`: admin settings screen scope (academy info, holiday management is via `holidays_screen` admin actions — insert/delete holidays).

## Audit Logs

`[Needs Verification]`: no dedicated audit-log table found. Privileged-field locks + payment triggers provide partial tamper-resistance, but a general audit trail is a gap. Recommended — see [26_Compliance_Legal](26_Compliance_Legal.md) and [Risk Register](12_Security.md).
