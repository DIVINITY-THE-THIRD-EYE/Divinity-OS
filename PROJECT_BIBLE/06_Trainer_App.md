# Phase 6 — Trainer App

> Same Flutter binary, **trainer role shell** (`features/shells/trainer_shell.dart`). Sources: `lib/features/trainer/`, plus shared features scoped by RLS to the trainer's students.

## Dashboard

`trainer/presentation/trainer_dashboard_screen.dart` — overview of assigned students, today's batches, pending actions (leave approvals, payment verification). Charts via `fl_chart`.

## Attendance

`trainer_check_in_screen.dart` — staff check-in/marking. Trainers can insert/update attendance (`attendance_insert_staff`, `attendance_update_staff` policies, migration 005). Geofence still applies for student self-check-in; staff override path is policy-gated.

## Student Management

Trainers can read their students (`trainers_select_students` policy) and view profiles via shared `students_screen.dart`. Enrollment management (`enrollment_repository`) lets trainers add/remove students from batches (`enrollments_insert/delete_trainer_admin`).

## Schedule

Batches (`batches_screen` / `admin_batches_screen`) + holiday calendar (`table_calendar`). Trainers can update **their own** batches (`batches_update_own_or_admin`).

## Reports

Trainer-facing reporting is dashboard-level (attendance, payments read). `trainer_payments_screen.dart` shows payment status across students. Full reporting/CSV is admin-side. `[Needs Verification]` for dedicated trainer report exports.

## Messaging

No direct in-app chat found; communication is via **notifications** (trainers can insert notifications — `admins_trainers_insert_notifications`) and therapeutic-log **comments**. `[Needs Verification]` if 1:1 messaging is planned. See [24_Communication_Notifications](24_Communication_Notifications.md).

## Diet Assignment

Via `therapeutic_logs` — trainers create logs and add `trainer_comment` (diet/therapeutic guidance) for their students (`therapeutic_logs_insert_staff`, migration 021).

## Workout Assignment

`[Needs Verification]`: no distinct "workout assignment" entity found in schema. Currently expressed through batches (class types) + therapeutic logs. Confirm roadmap intent.

## Permissions

Trainer capabilities (from RLS): read assigned students; create/delete enrollments; insert/update attendance; read all + update payments; create/comment therapeutic logs; read/write transformation scores; insert notifications. **Cannot** manage roles, leads (CRM), or holidays (admin-only). Full matrix: [10_Auth_Authorization](10_Auth_Authorization.md).

## Workflows

1. **Mark attendance:** open batch → mark present/absent → streak trigger updates.
2. **Approve leave:** `leave_approval_screen` → update `leave_requests` status.
3. **Verify payment:** review screenshot → set verification flags (subject to `lock_payment_fields` rules).
4. **Guide student:** add therapeutic log + comment → student notified.
