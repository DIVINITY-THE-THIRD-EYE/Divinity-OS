# DIVINITY BUILD STATUS
Session completed: 3 — Attendance + Leave Requests + Admin Student Activation
Date: 2026-06-16

## Done this session
- Migration `003_attendance_leave.sql` — `enrollments`, `attendance`, `leave_requests` tables with RLS + unique constraint on `(student_id, date)` for upsert
- Attendance domain: `AttendanceRecord`, `AttendanceStatus`, `MarkedBy` enums with `fromString`/`dbValue`
- `SupabaseAttendanceRepository` — `fetchTodayRecord`, `fetchHistory`, `checkIn` (upsert), `updateStatus`, `fetchActiveBatch` (joins enrollments→batches for geofence), `fetchBatchAttendanceToday`
- Attendance providers: `TodayAttendanceNotifier`, `AttendanceHistoryNotifier`, `GeolocationNotifier`, `activeBatchProvider`
- `CheckInScreen` — date card, status card, geofenced check-in (Haversine via `geolocator`), "Request Leave" button, recent history list
- `AttendanceHistoryScreen` — full history list
- Android/iOS location permissions added to `AndroidManifest.xml` + `Info.plist`
- Leave domain: `LeaveRequest`, `LeaveStatus` with `fromString`/`dbValue`
- `SupabaseLeaveRepository` — `fetchMyRequests`, `fetchPendingRequests` (joined), `submitRequest`, `updateStatus`
- Leave providers: `MyLeaveNotifier.submit`, `PendingLeaveNotifier.approve/reject/refresh` — `approvedBy` passed as param for testability
- `LeaveRequestSheet` (bottom sheet) + `MyLeaveScreen` (student history)
- `LeaveApprovalScreen` — pending list with approve/reject + confirm dialog
- `StudentsScreen` (Admin) — lists all students, "Activate" button sets `plan_status = ACTIVE`
- Shell wiring: `StudentShell` tab 1→CheckIn, tab 2→MyLeave; `AdminShell` tab 2→Students, tab 3→Batches, tab 4→LeaveApproval; `TrainerShell` tab 1→LeaveApproval
- Tests: 71/71 passing
- `flutter analyze`: 0 issues

## Next session (4) will do
- Payments: Razorpay integration (package `razorpay_flutter`), `payments` table, `PaymentRecord` model, fee collection screen, receipt view, payment history
- Notifications: In-app notification centre, `notifications` table, `NotificationNotifier`, mark-read
- Trainer dashboard: batch attendance summary, daily check-in list per batch

## Decisions needed from human
- Supabase ANON KEY still needs to be added to .env (placeholder in place)
- Firebase project not yet created — needed for Session 5 (FCM/Analytics/Crashlytics)
- Razorpay test key needed for Session 4 payment integration

## How to resume
Paste: "Read STATUS.md and git log, then continue with the next session."

## Test status
unit: PASS (71/71)  widget: PASS  integration: n/a  e2e: n/a
