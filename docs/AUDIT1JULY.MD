# DIVINITY ACADEMY OPERATING SYSTEM — PRODUCTION AUDIT REPORT

> **⚠️ SUPERSEDED (2026-07-02):** this was the first read-only audit pass and predates
> Feedback/Support/Weekly Schedule modules, CI/CD, RLS/storage fixes, the production
> Supabase connection, and GitHub Secrets configuration — all of which are now done and
> live-verified. See [VERIFIED_AUDIT_2026-07-02.md](VERIFIED_AUDIT_2026-07-02.md) for
> current, evidence-based status. Body below preserved as the original snapshot.

**Date:** 2026-07-01, last updated 2026-07-02 (Session 22 — CI/CD verification & environment setup) | **Auditor:** Read-only code inspection | **Source of truth:** implementation only

---

## 1. EXECUTIVE SUMMARY

Divinity is a multi-platform academy operating system consisting of a Flutter mobile app (primary product), a Next.js marketing website, a Supabase PostgreSQL backend, and Firebase services. The codebase is significantly more mature than a typical early-stage project: 106+ Dart feature files, 36 Supabase migrations, 16 pgTAP database test files (117 assertions, verified passing against a real local Postgres instance via `supabase test db`), 262 Flutter tests, and a production-grade Next.js website (61 vitest tests passing, lint/typecheck/build all clean) with security headers, rate limiting, and CSP.

**This session (2026-07-02) also verified the CI/CD pipeline end-to-end** rather than trusting it on paper: started Docker Desktop, reset the local Supabase DB, ran the full pgTAP suite, found and fixed a broken test fixture (`c16`), found and fixed a CI-breaking formatting/lint gap (147 unformatted files + 6 lint infos that `flutter analyze --fatal-infos` would have failed on), and found and removed a genuinely broken workflow (the website repo's `ci.yml` called seven npm scripts that don't exist in `package.json`) plus dead/misleading workflow duplicates sitting outside the two real git repos.

Since the original audit, several launch blockers have been resolved: the `payment_screenshots` storage bucket is now private with signed-URL access, the `library_books` table has scoped RLS instead of an open policy, four missing DB indexes have been added, the CSV/PDF report export is now wired into the Reports screen, the theme preference now persists across restarts via `shared_preferences`, and the Admin Trainer Management screen has been built (migration 032 adds `users.is_active`, admin can view/activate/deactivate trainers from a dashboard quick-access card, pgTAP `c13` covers the new admin-only lock). A prior finding that `TrainerCheckInScreen` was unreachable from the trainer app was also found to be incorrect on closer inspection — it is reachable by tapping a batch card on the trainer's default dashboard tab.

The system is **closer to launch-ready** but still carries issues that need resolution before a public launch: meaningful gaps in test automation, one broken feature (certificate web verification), a phantom payment method (Razorpay referenced but not implemented), a streak divergence between client and server, and no functioning CI/CD (workflow files exist but this workspace is not yet a git repository, so nothing executes).

---

## 2. OVERALL PRODUCTION READINESS SCORE

| Dimension | Score | Notes |
|---|---|---|
| Architecture & Code Quality | 87/100 | Clean layered architecture, consistent patterns |
| Database & Schema | 87/100 | 32 migrations, RLS on all tables including `library_books`, indexes closed |
| Security | 85/100 | RLS, trigger locks, App Check, JWT-cached roles, payment screenshots now private |
| Feature Completeness | 80/100 | 16 modules, Razorpay unimplemented, cert verify broken |
| Testing | 62/100 | 262 Flutter + 117 pgTAP assertions, all verified passing; CI now wired; integration tests still sparse |
| Performance | 76/100 | Good indexes; N+1 risks; streak divergence |
| Navigation | 85/100 | Role shells work; minor FCM routing gaps |
| Documentation | 72/100 | PROJECT_BIBLE extensive but vs. code has some mismatches |
| DevOps / CI | 75/100 | Both live repos have verified-working CI (analyze/test/pgtap/lint/build); release jobs need secrets configured |
| **Overall** | **81/100** | **Close to launch-ready; remaining blockers are external (store signing, App Check verification) rather than in-repo** |

---

## 3. MODULE-BY-MODULE READINESS

### 3.1 Auth — 95%

- **Purpose:** Email/OTP, Google, Apple, Phone sign-in; onboarding wizard; role routing.
- **Implementation:** Fully implemented. `AuthNotifier` drives a sealed `AuthState` machine. GoRouter redirect covers all states (`AuthInitial`, `AuthLoading`, `AuthUnauthenticated`, `AuthOtpSent`, `AuthNeedsOnboarding`, `AuthPendingApproval`, `AuthPasswordRecovery`, `AuthAuthenticated`).
- **Architecture:** `AuthRepository` (interface) / `SupabaseAuthRepository`. Riverpod `StateNotifier`.
- **UI:** LoginScreen, OtpScreen, 6-step OnboardingWizard, PendingApprovalScreen, ResetPasswordScreen.
- **Security:** Role sync to JWT `app_metadata` (migration 017). Role/plan self-escalation blocked by trigger (migration 009).
- **Tests:** `auth_unit_test.dart` — 8+ test groups with mocktail. `auth_widget_test.dart` exists.
- **Gap:** Auth provider choices (`auth_enable_*`) come from Remote Config but no runtime UI to show which providers are enabled vs. hidden.

### 3.2 Dashboard (Admin) — 84%

- **Purpose:** Admin home with headline KPIs, pending actions, alerts, and a quick-access row to Events/Holidays/Trainers.
- **Implementation:** `AdminDashboardScreen` watches `dashboardStatsProvider`. Repository queries `users`, `payments`, `leave_requests`. `_QuickAccessRow` now surfaces Events, Holidays, and Trainer management directly on the dashboard (`AdminTrainersScreen` — view/activate/deactivate trainers, migration 032 adds `users.is_active`).
- **Gap:** Data loaded via FutureProvider (one-shot); no real-time subscription. Dashboard goes stale without a pull-to-refresh. `dashboard_unit_test.dart` exists. `AdminTrainersScreen` itself has no dedicated unit/widget test (same gap as the sibling `StudentsScreen`, which also talks to Supabase directly rather than through a mockable repository).

### 3.3 Attendance — 90%

- **Purpose:** Student geofenced check-in; trainer manual mark; attendance history.
- **Implementation:** Student path calls `check_in` RPC (migration 010) — server-side Haversine geofence + enrollment validation. Trainer path calls `trainerMark()` directly into `attendance` table via staff INSERT policy (migration 005). Client has mock-location deterrent in production Android builds.
- **UI:** `CheckInScreen`, `AttendanceHistoryScreen`, `TrainerCheckInScreen` (reachable by tapping a batch card on `TrainerDashboardScreen` — the trainer's default tab — or via the "Check-in" button on `BatchesScreen`; it is not a dedicated bottom-nav tab, but it is reachable).
- **Gap:** Streak shown on Home Screen is computed client-side from last 60 attendance records; the DB `current_streak` field (maintained by trigger in migration 014) is never read by the UI. **These can diverge.**
- **Tests:** `attendance_unit_test.dart` covers parsing, `AttendanceRecord.fromMap`, and provider states.

### 3.4 Payments — 84%

- **Purpose:** Student submits UPI/bank payment with screenshot; admin approves; trainer confirms receipt; membership activates.
- **Implementation:** 5-stage state machine: PENDING → PENDING_ADMIN → PENDING_TRAINER → PAID (via DB triggers in migration 022). Screenshot upload to Supabase Storage, now via `createSignedUrl()` against a bucket restricted by owner/admin/trainer RLS (migration 031). `AdminPaymentsScreen`, `TrainerPaymentsScreen`, `PaymentsScreen`, `RecordPaymentSheet`.
- **DB:** `process_payment_transitions()` trigger, `propagate_payment_status()` trigger, `handle_payment_notification()` trigger.
- **BROKEN:** `PaymentMethod.razorpay` exists in domain model and DB schema, but **no Razorpay SDK is in `pubspec.yaml`** and no implementation exists. If a user selects Razorpay, nothing will happen.
- **Tests:** `payments_unit_test.dart` exists.

### 3.5 Admissions / Leads CRM — 87%

- **Purpose:** Lead intake, pipeline tracking (NEW → CONTACTED → TRIAL → ADMITTED), lead-to-member conversion.
- **Implementation:** `LeadsScreen`, `LeadsRepository`, `convert_lead_to_member` RPC (migration 020) atomically transitions lead + user plan_status. `leads(pipeline_status)` is now indexed (migration 029).
- **Gap:** No lead analytics; no follow-up reminders.

### 3.6 Batches — 90%

- **Purpose:** Admin creates/manages batches with per-batch geofence; assigns trainers; manages enrollments.
- **Implementation:** `AdminBatchesScreen`, `BatchesScreen` (trainer view), `batch_repository.dart`, `enrollment_repository.dart`. Coordinates required by DB constraint (migration 016).
- **Tests:** `batch_unit_test.dart`, `enrollment_unit_test.dart`.

### 3.7 Transformation / Third Eye — 78%

- **Purpose:** Weekly wellness scores (consistency, intensity, mindfulness, recovery) with radar chart, trend chart, and AI wellness coach.
- **Implementation:** `ThirdEyeDashboardScreen` (student), `StudentProgressDetailScreen`. AI coach uses Firebase AI (Gemini 1.5 Flash) with Remote Config-driven model and system instruction. `transformation_scores(student_id)` is now indexed (migration 029).
- **Gap:** No trainer or admin screen for entering transformation scores in the Flutter app (scores must be entered directly into DB or via admin SQL). The `transformation_scores` table has trainer/admin RLS for ALL operations but no UI for it.

### 3.8 Workouts — 85%

- **Purpose:** Trainer creates structured workout plans with ordered exercises; assigns to batches; students view assigned workouts and mark them complete.
- **Implementation:** `TrainerWorkoutsScreen`, `StudentWorkoutsScreen` (with a working completion toggle backed by the `workout_completions` table), `workout_repository.dart`.
- **Tests:** `workout_unit_test.dart`, `workout_widget_test.dart`.

### 3.9 Therapeutic Logs — 85%

- **Purpose:** Trainer writes per-student narrative progress notes.
- **Implementation:** `TherapeuticLogsScreen` (trainer), `therapeutic_log_repository.dart`. RLS enforces trainer_id = auth.uid() on insert (migration 021). `therapeutic_logs(student_id)` is now indexed (migration 029).
- **Gap:** No search, no export, no admin-authored log view.

### 3.10 Events — 78%

- **Purpose:** Admin creates events (workshops, camps); students RSVP; FCM fan-out on publish.
- **Implementation:** `AdminEventsScreen`, `StudentEventsScreen`, `event_repository.dart`. Capacity enforcement via `event_is_full()` SECURITY DEFINER function. Now also surfaced via a quick-access card on the admin dashboard.
- **Gap:** Trainer shell has **no events screen or target**. If an FCM notification arrives with `target: 'events'`, the trainer shell `_targetToIndex` returns 0 (dashboard). Students receive events via push modal; trainer doesn't.
- **Tests:** `event_unit_test.dart`, `event_widget_test.dart`.

### 3.11 Certificates — 88%

- **Purpose:** Issue, view, share trust certificates with verifiable code (DIV-XXXX-XXXX); admin can now issue/revoke from the app.
- **Implementation:** `CertificatesScreen` (student), `AdminCertificatesScreen` (issue/revoke/list with copy-to-clipboard codes, wired as a "Certs" tab in `admin_shell.dart`), `certificate_repository.dart`. Share via `share_plus`. Integration test covers the student flow.
- **BROKEN:** Certificate verification on the website (`/verify`) returns `"unavailable"` because `CERT_VERIFY_ENDPOINT` env var is not configured. Certificates are issued in-app but cannot be verified online.
- **Tests:** `certificates_unit_test.dart`, integration test.

### 3.12 Notifications — 83%

- **Purpose:** In-app notification list, FCM push, notification bell.
- **Implementation:** `NotificationsScreen`, `NotificationBell` widget, `fcm_provider.dart`, `fcm_service.dart`. Payment notifications sent by DB triggers (migration 023).
- **Gap:** No notification preferences. No bulk-mark-as-read. FCM token refresh is handled by `FcmService.init()` but no error recovery if token update fails.
- **Tests:** `notifications_unit_test.dart`.

### 3.13 Leave Management — 78%

- **Purpose:** Student submits leave requests; trainer/admin approves or rejects.
- **Implementation:** `LeaveRequestScreen`, `LeaveApprovalScreen`, `leave_repository.dart`. `leave_requests(student_id)` is now indexed (migration 029).
- **Gap:** Approving a leave does **not** automatically update attendance records for the leave period. This must be done manually. No leave balance tracking.
- **Tests:** `leave_unit_test.dart`.

### 3.14 Holidays — 90%

- **Purpose:** Admin manages public holidays; all users see them.
- **Implementation:** `HolidaysScreen`, `holiday_repository.dart`. Holiday attendance auto-status not wired (attendance still shows ABSENT for holidays unless manually marked).
- **Tests:** `holidays_unit_test.dart`.

### 3.15 Profile — 78%

- **Purpose:** View and edit profile; update non-locked fields; avatar.
- **Implementation:** `ProfileScreen`, `profile_repository.dart`. Age/gender locked after onboarding by trigger. Dark/light theme preference now persists via `SharedPreferences` (`theme_provider.dart`) and survives app restart.
- **Gap:** Avatar URL is stored but there is no upload UI in the profile screen (no `image_picker` integration there, only in payments).
- **Tests:** `profile_unit_test.dart`.

### 3.16 Analytics / Reports — 78%

- **Purpose:** Admin-only reports with attendance trends, revenue, enrollment, events.
- **Implementation:** `ReportsScreen`, server-side `get_reports_data` RPC (migration 028). Export utilities (`reports_export_utils.dart`) are now wired into the screen — CSV export buttons call `ReportsExportUtils` for Attendance, Revenue, Memberships, Students, Events, and Trainers.
- **Gap:** Plan classification in RPC uses **hardcoded amount thresholds** (`>=15000 Annual`, `>=4000 Quarterly`), not plan names. This is fragile.
- **Tests:** `reports_unit_test.dart`, `reports_widget_test.dart`.

---

## 4. FEATURE INVENTORY

| Feature | Status |
|---|---|
| Email + OTP auth | Production Ready |
| Google / Apple / Phone auth | Production Ready |
| Onboarding wizard (6 steps) | Production Ready |
| Role-based navigation (Admin/Trainer/Student) | Production Ready |
| Admin dashboard KPIs + Events/Holidays/Trainers quick access | Production Ready |
| Admin trainer management (view, activate, deactivate) | Production Ready |
| Student geofenced check-in (server-side RPC) | Production Ready |
| Trainer manual attendance mark | Production Ready |
| Attendance history calendar | Production Ready |
| Batch management (admin + trainer) | Production Ready |
| Enrollment management | Production Ready |
| Payment submission (UPI/screenshot, private bucket + signed URLs) | Production Ready |
| Payment 5-stage verification state machine | Production Ready |
| Razorpay integration | **BROKEN — Referenced, not implemented** |
| Lead CRM pipeline | Production Ready |
| Lead-to-member atomic conversion | Production Ready |
| Transformation scores + radar chart | Production Ready |
| Third Eye AI coach (Gemini 1.5 Flash) | Production Ready |
| Transformation score entry UI (Admin/Trainer) | **MISSING** |
| Workout plan creation | Production Ready |
| Workout assignment to batches | Production Ready |
| Student workout completion tracking | Production Ready |
| Therapeutic logs | Production Ready |
| Events (admin publish + student RSVP) | Production Ready |
| Trainer event view | **MISSING** |
| Certificates (issue, view, share) | Production Ready |
| Admin certificate issuance/revocation | Production Ready |
| Certificate online verification | **BROKEN — endpoint not configured** |
| In-app notifications | Production Ready |
| FCM push notifications | Production Ready |
| Leave request + approval | Production Ready |
| Auto-attendance update on leave approval | **MISSING** |
| Holiday management | Production Ready |
| Dark/Light theme toggle | Production Ready (now persisted) |
| Profile editing | Production Ready |
| Avatar upload | **MISSING from profile UI** |
| Analytics reports (admin) | Production Ready (export now connected) |
| Library books (DB table) | **EXISTS in DB, RLS scoped, NO Flutter module** |
| Newsletter subscribe (website) | Production Ready |
| Contact form (website) | Production Ready |
| Certificate web verification (website) | **BROKEN** |

---

## 5. DATABASE AUDIT

### Migration Order & Idempotency

Migrations 001–032 are sequentially numbered and use `CREATE TABLE IF NOT EXISTS`, `CREATE OR REPLACE FUNCTION`, `ADD COLUMN IF NOT EXISTS`, and `DROP POLICY IF EXISTS`. They are idempotent for most operations. Functions and triggers use `CREATE OR REPLACE`, safe to re-run.

**Exception:** The blanket GRANT in migration 012 (`GRANT ... ON ALL TABLES`) only covers tables existing at migration time. Later migrations (024 certificates, 026 workouts, 027 events) correctly add their own explicit grants.

### Tables (18 total)

`users`, `batches`, `leads`, `enrollments`, `attendance`, `payments`, `notifications`, `holidays`, `therapeutic_logs`, `transformation_scores`, `leave_requests`, `certificates`, `workouts`, `workout_exercises`, `workout_assignments`, `events`, `event_registrations`, `library_books` (unused by Flutter but now RLS-scoped)

### Indexes

**Present:** `payments(student_id)`, `payments(paid_at)`, `payments(status)`, `notifications(user_id, is_read)`, `attendance(student_id, date desc)`, `attendance(date, status)`, `users(role, plan_status)`, `users(created_at)`, `certificates(student_id)`, `certificates(code)`, `workouts(trainer_id)`, `workout_exercises(workout_id)`, `events(starts_at)`, `events(status)`, `event_registrations(event_id)`, `event_registrations(student_id)`, `leads(pipeline_status)`, `leave_requests(student_id)`, `therapeutic_logs(student_id)`, `transformation_scores(student_id)` (migration 029).

### Foreign Keys & Constraints

All FK relationships use `ON DELETE CASCADE` or `ON DELETE SET NULL` appropriately. Batch coordinates required by check constraint (migration 016). Payment amount `> 0` check. Workout title/name `char_length(trim(...)) > 0` checks.

### RLS

All 18 tables have `enable row level security`, including `library_books` (migration 030 replaced the over-broad student UPDATE policy with one scoped to the student's own borrow/request rows). Policies use helper functions `is_admin()`, `is_trainer()`, `is_trainer_or_admin()` that read JWT `app_metadata.role` for the current user, avoiding recursive table scans.

### Triggers

| Trigger | Table | Purpose |
|---|---|---|
| `users_updated_at` | users | Maintain updated_at |
| `on_auth_user_created` | auth.users | Auto-create public.users profile |
| `users_lock_onboarded` | users | Lock age/gender post-onboarding |
| `users_lock_privileged` | users | Block role/plan self-escalation |
| `attendance_streak_trigger` | attendance | Recalculate DB streaks on mark |
| `payments_before_trigger` | payments | State machine transitions |
| `payments_after_trigger` | payments | Propagate plan_status to users |
| `payments_notification_trigger` | payments | Notify student on payment events |
| `sync_role_to_app_metadata` | users | Sync role → JWT on role change |
| `set_updated_at` (multiple) | all | Maintain updated_at |

### Functions / RPCs

- `check_in(lat, lng, batch_id)` — SECURITY DEFINER, geofenced attendance
- `convert_lead_to_member(lead_id, user_id)` — SECURITY DEFINER, atomic CRM
- `get_reports_data(...)` — SECURITY DEFINER, admin analytics
- `is_admin()`, `is_trainer()`, `is_trainer_or_admin()` — SECURITY DEFINER role helpers
- `haversine_m()` — immutable, parallel safe Haversine calculator
- `event_is_full(event_id)` — SECURITY DEFINER capacity check
- `gen_certificate_code()` — volatile, generates DIV-XXXX-XXXX codes
- `lock_privileged_fields()`, `lock_onboarded_fields()` — BEFORE UPDATE triggers

### Duplicate / Unused Schema

- `library_books` table (migration 013): created, no Flutter module, no pgTAP test. RLS is now correctly scoped (migration 030) but the table remains otherwise dead schema.
- `batches.end_time` column (migration 013): added for Next.js compatibility, never used in app code.
- `batches.created_by_id` column (migration 013): added for Next.js compatibility, never read or written by Flutter app.

### Performance Risks in DB

- `get_reports_data` RPC does multiple full-table CTEs with optional filters. On large datasets this will be slow. No materialized views.
- Plan classification in reports uses amount ranges, not stored plan names.

---

## 6. SECURITY AUDIT

### Authentication

Supabase Auth handles all auth flows. App Check (Play Integrity / App Attest) protects Firebase endpoints in production. Remote Config flag-controlled auth providers: email, Google, Apple, Phone.

### Authorization

Role-based: ADMIN, TRAINER, STUDENT. Role stored in `users.role` and synced to JWT `app_metadata.role` via trigger (migration 017). Role helpers read JWT first, fall back to table only for other users.

### RLS

All tables protected, including `library_books` as of migration 030. Verified for every table in migrations. `is_admin()` / `is_trainer()` helpers use `SECURITY DEFINER` to avoid RLS recursion.

### Privilege Escalation Prevention

`lock_privileged_fields()` trigger (final version in migration 019) blocks: role, email, plan_status (except own row → PENDING_ADMIN), expiration_date, pause_start_date, current_streak, max_streak from non-admin writes. `onboarding_complete` is a one-way latch (cannot be reset to false by non-admin).

### SECURITY DEFINER Functions

All SECURITY DEFINER functions set `search_path = public, pg_temp` to prevent search path injection. This is correct.

### Storage

- `payment_screenshots` bucket: now accessed via `createSignedUrl()` (not `getPublicUrl()`), with row-level storage policies (migration 031) scoped to the owner, plus admin/trainer read access. Financial documents are no longer publicly reachable by URL.
- Other buckets (avatars, etc.): no `storage.rules` reviewed yet — see Launch Blockers.

### Environment Variables

- Flutter secrets (`SUPABASE_URL`, `SUPABASE_ANON_KEY`) are now injected at build time via `--dart-define` / `String.fromEnvironment` in `main.dart`, rather than bundled via `flutter_dotenv`/`.env` in the APK. `dart_defines.json.example` is committed as a template; the real file is gitignored.
- Firebase API keys in `firebase_options.dart` are semi-public by design (Firebase security enforced via App Check + security rules).
- Next.js `.env.local` contains a **real Vercel OIDC token** (exp ≈ July 2026). This is a local dev token created by `vercel env pull`. No secrets in `.env.local.example`.

### SQL Injection

All queries use Supabase client's parameterized methods (`.eq()`, `.from().select()`). No raw string interpolation in queries found.

### XSS (Next.js)

All user input in the contact form is HTML-escaped before embedding in email body (`escapeHtml()`). CSP headers applied in production.

---

## 7. PERFORMANCE AUDIT

### N+1 Queries

- `fetchAllPayments()` joins `users(id, name, phone)` in a single query — no N+1.
- `fetchBatchAttendanceToday()` joins `users` — no N+1.
- `fetchHomeData()` uses `Future.wait` for 3 parallel queries — good.
- `TrainerCheckInScreen` instantiates `SupabaseAttendanceRepository` directly (not via DI) — bypasses DI layer.

### Streak Divergence (Performance + Correctness Risk)

- `home_repository.dart` computes streak from last 60 attendance records in Dart.
- `recalculate_student_streaks()` trigger (migration 014) maintains `users.current_streak` in DB.
- The home screen **ignores** `users.current_streak`. On a device with poor connectivity, or if a student has >60 days of history, the client-side computation diverges from the DB value. The DB value is authoritative; the UI shows an approximation.

### Memory / Rebuilds

`IndexedStack` preserves all role shell tabs in memory simultaneously (8 student tabs, 8 admin tabs, 7 trainer tabs). This is intentional for instant tab switching but means all providers are alive at once.

### Slow Query Risk

- `get_reports_data` RPC with no filters will scan all attendance, payments, and users rows. No pagination, no limit, no materialized views.
- `fetchAllPayments()` has `.limit(100)` — safe.

### Weather Service

Calls two Open-Meteo APIs in parallel on every home screen load. No persistent caching beyond provider state. App restart triggers fresh API calls.

---

## 8. NAVIGATION AUDIT

### Route Map

The GoRouter has 6 declared routes:

- `/login`, `/otp`, `/onboarding`, `/pending`, `/reset-password`, `/` (RoleShell)

All application screens are rendered inside `IndexedStack` within the three role shells. There are no deep-link routes to individual screens.

### FCM Deep-Link Routing

FCM notifications carry a `target` string in data payload that maps to tab indices.

**Admin shell targets:** `payments→1`, `admissions→2`, `students→3`, `leaves→4`, `batches→5`, `certificates→6`, `reports→7`. Events and Holidays are still push-routed via AppBar/dashboard, not `_targetToIndex`.

**Student shell targets:** `thirdeye→1`, `workouts→2`, `attendance→3`, `leaves→4`, `payments→5`, `profile→6`. `events` opens via push route.

**Trainer shell targets:** `leaves→1`, `batches→2`, `workouts→3`, `logs→4`, `payments→5`, `profile→6`.

**Gaps:**
- Trainer shell has no handler for `events`, `attendance`, `thirdeye`, `students`. An FCM `target` not in the map defaults to tab 0 (dashboard) silently.
- Student `certificates` tab (index 7) has no `target` mapping. FCM cannot navigate directly to certificates.
- No URL-based deep links. This prevents sharing specific screens as URLs or handling Android App Links.

### Unreachable Screens

- `home_stub_screen.dart` — exists in `features/shared/`, not imported anywhere.

### Duplicate Screens

- `LeaveApprovalScreen` is reused in both `AdminShell` (tab 4) and `TrainerShell` (tab 1). Intentional reuse; must correctly scope queries by role.

---

## 9. TESTING AUDIT

### Flutter Tests

**Unit tests:** 22 files covering all major modules (auth, attendance, batches, certificates, dashboard, events, holidays, home, leave, notifications, payments, profile, therapeutic_logs, trainer check-in, transformation, workouts, analytics). All use mocktail for dependency mocking. Tests verify domain model parsing, provider state transitions, and repository interactions.

**Widget tests:** 3 files (`auth_widget_test.dart`, `event_widget_test.dart`, `workout_widget_test.dart`). Coverage is shallow — tests render a single widget in isolation.

**Integration test:** 1 file (`integration_test/app_test.dart`) covering the certificate screen only. Does not touch authentication, attendance, payments, or any network call.

**Root widget test:** `test/widget_test.dart` — 3 smoke tests only (ThirdEyeIcon renders, light/dark theme colors correct).

### pgTAP Tests (Database)

16 test files, 117 assertions total, **verified passing** (`supabase db reset` then `supabase test db`, 2026-07-02, against a real local Postgres instance via Docker):

- `c1_privileged_fields_test.sql` — 7 assertions on privilege escalation prevention
- `c2_geofence_test.sql` — geofence RPC checks
- `c3_streak_test.sql` — streak recalculation
- `c4_jwt_role_test.sql` — JWT role sync
- `c5_latches_test.sql` — email/onboarding latches
- `c6_lead_convert_test.sql` — lead-to-member atomic RPC
- `c7_therapeutic_logs_test.sql` — log RLS
- `c8_payment_verification_test.sql` — payment state machine
- `c9_certificates_test.sql` — certificate RLS
- `c10_workouts_test.sql` — workouts
- `c11_events_test.sql` — events
- `c12_reports_test.sql` — reports access control
- `c13_trainer_active_status_test.sql` — 4 assertions that only an admin can change `users.is_active`
- `c14_student_feedback_test.sql` — student feedback RLS
- `c15_support_tickets_test.sql` — support ticket RLS
- `c16_enrollment_concurrency_test.sql` — batch enrollment capacity lock (fixture was broken — inserted a batch without required coordinates — fixed this session; now passes)

**Still not run automatically in CI.** `pgtap.yml` exists in `divinity_flutter/.github/workflows/` and is correctly written (`supabase start` → `supabase test db` → `supabase stop`), but its actual execution on GitHub's runners has not been observed — only the equivalent commands run locally this session. Migrations 029–031 still have no corresponding pgTAP assertions.

### CI/CD

**Corrected finding:** this workspace's earlier "no git repo" / "no CI" conclusion was accurate for the outer `Divinity TTE/` folder but missed that `divinity_flutter/` and `divinity-third-eye/divinity/` are each their own git repositories, already pushed to GitHub (`divinitythethirdeye-ux/Divinity-App` and `divinitythethirdeye-ux/Divinity-Website` respectively), each with real, working GitHub Actions workflows in their own `.github/workflows/`.

- **`divinity_flutter`** (`Divinity-App`): `flutter.yml` (dart format check → analyze → test → Android release build), `pgtap.yml`, `codeql.yml` (Android/Kotlin scan), `release.yml` (release-please + signed AAB), `labeler.yml`, `size-label.yml`, `stale.yml`. All gate commands verified locally this session: `dart format --set-exit-if-changed` exits 0, `flutter analyze --fatal-infos` reports 0 issues, `flutter test` 262/262, pgTAP 16/16 files (117/117 assertions).
- **`divinity-third-eye/divinity`** (`Divinity-Website`): `website.yml` (lint → typecheck → build → vitest), `codeql.yml`, `release.yml`, `size-label.yml`, `stale.yml`. Verified locally: `npm run lint` clean, `npx tsc --noEmit` clean, `npm run build` succeeds, `npm test` 61/61 pass.
- **Removed this session:** `divinity-third-eye/divinity/.github/workflows/ci.yml` — labeled "inert scaffold" by an earlier session, but since the repo is now genuinely pushed to GitHub it would have actually triggered and failed (it called `npm run typecheck`/`format:check`/`test:unit`/`size`/`test:a11y`/`test:vrt`/`test:images`, none of which exist in `package.json`); fully redundant with `website.yml`. Also removed the dead `.github/workflows/` at the outer `Divinity TTE/` root and `Divinity/.github/workflows/build-and-test.yml` (pointed at an unrelated Prisma reference project) — neither could ever run and both were misleading.
- **Remaining gap:** the release-signing jobs (`flutter.yml`'s `build-android`, `release.yml`'s AAB build, `website.yml`'s `build`) need GitHub Secrets configured (`SUPABASE_URL`, `SUPABASE_ANON_KEY` on both repos; `ANDROID_KEYSTORE_BASE64`/`ANDROID_STORE_PASSWORD`/`ANDROID_KEY_PASSWORD`/`ANDROID_KEY_ALIAS` on `Divinity-App`) — not yet done, needs repo-admin access. See `STATUS.md` Session 22 for the full secrets table.
- **No automated deploy.** Next.js is deployed to Vercel (Hobby plan) manually. Supabase migrations applied manually with `supabase db push`.

### Missing Coverage

- All API route integration testing (contact form, subscribe endpoint, verify endpoint)
- Auth flow end-to-end
- Payment state machine end-to-end
- Geofence RPC (tested in pgTAP but not in Flutter)
- FCM deep-link routing
- Analytics report generation

---

## 10. DOCUMENTATION AUDIT

### PROJECT_BIBLE

Extensive (30+ documents). Contains architecture, module index, decision logs, auth migration strategy, executive summaries.

**Trust gap:** The PROJECT_BIBLE was generated iteratively and may describe intended architecture, not verified implementation. Audit findings above supersede PROJECT_BIBLE claims where they differ.

**Identified mismatches:**
- PROJECT_BIBLE likely describes Razorpay as implemented — it is not.
- PROJECT_BIBLE may not reflect the streak divergence between client-computed and DB-stored values.
- Certificate web verification may be described as complete — it is not wired.

### EXTRA_FILES Directory

Contains `Duplicate Projects`, `Old Android`, `Old Assets`, `Old Builds`, `Old Documents`, `Old iOS`, `Temp Files`. These are historical artifacts, not production code.

### Calling App (`Divinity/apps/calling_app`)

Default Flutter starter project with an `.xlsx` contact list. This is unrelated to the main product. Its README is the default Flutter README. **This app is not part of the Divinity Academy OS.**

---

## 11. CRITICAL RISKS — RESOLVED THIS SESSION

### ~~CR-1: No Functioning CI/CD Pipeline~~ — Downgraded

**Was:** the CI conclusion in earlier passes conflated the non-git outer workspace folder with the actual repos. **Now:** `divinity_flutter` and `divinity-third-eye/divinity` are each real git repos pushed to GitHub with working `flutter.yml`/`pgtap.yml`/`website.yml` workflows — every gate (`dart format`, `flutter analyze --fatal-infos`, `flutter test`, `supabase test db`, `npm run lint`, `tsc --noEmit`, `npm run build`, `npm test`) was run locally this session and passes. **Remaining:** GitHub Secrets (Supabase keys, Android keystore) aren't configured yet, so the *release-build* jobs specifically (not analyze/test/pgtap/lint) will still fail on push until someone with repo-admin access adds them — see `STATUS.md` Session 22.

### ~~CR-2: pgTAP Tests Never Run Automatically~~ — Downgraded

**Was:** no evidence the 12 pgTAP files had ever executed. **Now:** all 16 pgTAP files (117 assertions, including the 4 added in Sessions 19–21) were run against a real local Postgres instance this session via `supabase test db` — all pass. `pgtap.yml` is correctly configured to do the same in CI, but its actual execution on a GitHub-hosted runner has not been separately observed (only the local equivalent).

---

## 12. HIGH RISKS

### HR-1: Razorpay Payment Method — Referenced, Not Implemented

`PaymentMethod.razorpay` is in the domain model and the DB schema accepts `RAZORPAY` as a valid `payment_method` value. No Razorpay SDK is in `pubspec.yaml`. No payment flow routes through Razorpay. If a user or admin selects "Razorpay" as a payment method via the `RecordPaymentSheet`, the payment will be recorded without any gateway processing.

### HR-2: Certificate Online Verification Broken

`CERT_VERIFY_ENDPOINT` is not configured on Vercel. The `/verify` page returns: *"Online verification isn't enabled yet."* Certificates are issued in-app with unique codes, but students cannot verify them on the website — defeating the purpose of the verification feature.

### HR-3: Streak Divergence — Client vs. DB

The home screen computes current streak from the last 60 attendance records in Dart. The DB maintains `users.current_streak` via trigger (migration 014). These values can diverge: (a) if a student has >60 days of history, the client-side computation truncates; (b) if the trigger fires at a different time; (c) if any admin manually edits attendance. The DB value is the single source of truth; the UI shows an approximation.

### HR-4: Transformation Score Entry — No UI for Staff

Trainers and admins can write transformation scores (RLS permits it). However, there is no screen in the Flutter app where a trainer or admin can enter scores for a student. The only path is via direct Supabase dashboard SQL. The Third Eye module relies entirely on admin SQL access to populate scores.

---

## 13. MEDIUM RISKS

### MR-1: Leave Approval Does Not Update Attendance

When a leave is approved, the attendance records for the leave period are not automatically set to `ON_LEAVE` status. Students on approved leave still show `ABSENT`. This requires manual trainer/admin attendance correction.

### MR-2: In-Memory Rate Limiter (Next.js)

The rate limiter (`lib/rate-limit.ts`) is an in-memory Map. On Vercel Hobby plan (single-instance), this works. On multi-region Pro plans, each instance has a separate Map and rate limits are per-instance. This is not a bug today but will fail silently if the plan is upgraded.

### MR-3: Vercel OIDC Token in `.env.local`

The `.env.local` file in `divinity-third-eye/divinity/` contains a real Vercel OIDC JWT with expiry ≈ July 2026. This is a local development token created by `vercel env pull`. If the project directory is shared, cloned, or archived, this token provides temporary Vercel API access.

### MR-4: FCM Target Routing Gaps

Trainer shell has no handler for `events`, `attendance`, `thirdeye`, `students` FCM targets. Student shell has no `certificates` FCM target. Admin shell has no `events`/`holidays` FCM target. Unrecognized targets silently default to tab 0.

### MR-5: Reports Plan Classification is Amount-Based

The `get_reports_data` RPC classifies payments by hardcoded amount thresholds (`>=15000 Annual`, `>=4000 Quarterly`), not stored plan names. If pricing changes, historical plan classification in reports will be wrong.

### MR-6: Trainer Creates Repository Directly in Check-in Screen

`TrainerCheckInScreen` instantiates `SupabaseAttendanceRepository(ref.read(supabaseClientProvider))` inline rather than via a provider. This bypasses the DI layer, makes testing harder, and creates a new instance on every batch selection.

---

## 14. LOW RISKS

### LR-1: `AppConstants` Dead Code

`AppConstants.supabaseUrl` and `AppConstants.supabaseAnonKey` use `String.fromEnvironment`, which is now the live path for loading these values in `main.dart` following the `--dart-define` migration — confirm no other dead duplicate remains once the class is reviewed.

### LR-2: Library Books Table is Orphaned

Migration 013 creates `public.library_books`. No Flutter feature, no website feature, no pgTAP test references this table. RLS is now scoped correctly (migration 030), but the table itself remains unused.

### LR-3: `home_stub_screen.dart` is Unused

`features/shared/home_stub_screen.dart` exists but is not imported anywhere. Dead file.

### LR-4: Avatar Upload Not in Profile Screen

`pubspec.yaml` includes `image_picker` and the payment flow has screenshot upload, but the profile screen UI does not have an avatar upload flow.

### LR-5: Calling App in Repository

`Divinity/apps/calling_app` is a default Flutter starter project with a `.xlsx` file of contacts. It should be removed or placed in a separate repository.

### LR-6: `google_fonts` Loads at Runtime

Fonts are loaded via `google_fonts` package at runtime (no pre-bundled fonts). First launch requires network access to download fonts. On first launch without internet, the Material default font will be used.

### LR-7: Open-Meteo Weather with No API Key

Weather service calls the Open-Meteo free API with no authentication. The free tier has rate limits. Heavy usage could be throttled without warning.

---

## 15. TECHNICAL DEBT

| Item | Location | Severity |
|---|---|---|
| Dual streak computation (client + DB trigger) | `home_repository.dart` + migration 014 | High |
| `library_books` table — orphaned, RLS now scoped but table unused | migration 013 / 030 | Low |
| `batches.end_time`, `batches.created_by_id` — compatibility columns never used | migration 013 | Low |
| `AppConstants.supabaseUrl/anonKey` — verify no leftover dead code post-`--dart-define` migration | `app_constants.dart` | Low |
| `home_stub_screen.dart` — unused file | `features/shared/` | Low |
| `calling_app` — unrelated empty project | `Divinity/apps/` | Low |
| `EXTRA_FILES` — old build artifacts | `EXTRA_FILES/` | Low |
| Trainer check-in creates repository directly, not via DI | `trainer_check_in_screen.dart` | Medium |
| In-memory rate limiter non-distributed | `lib/rate-limit.ts` | Medium |

---

## 16. LAUNCH BLOCKERS

The following issues must be resolved before a public production launch:

| # | Blocker | Module | Severity |
|---|---|---|---|
| LB-1 | GitHub Secrets not yet configured — CI release jobs (Android AAB build, website prod build) will fail on push until Supabase keys + Android keystore are added to each repo's settings. The CI pipeline itself (analyze/test/pgtap/lint) is verified working. A new upload keystore was generated this session; see `STATUS.md` Session 23. | DevOps | High |
| ~~LB-3~~ | ~~Certificate web verification unavailable~~ — **RESOLVED 2026-07-02.** Built `supabase/functions/verify-certificate/index.ts`, a public PII-safe edge function (masks holder name to first-name + last-initial). Verified locally via `supabase functions serve` (bad-format, not-found, and real-certificate cases all return the expected shape). Needs `supabase functions deploy verify-certificate --no-verify-jwt` + `CERT_VERIFY_ENDPOINT` set on Vercel to go live. | Certificates | Resolved (pending deploy) |
| LB-4 | Razorpay shown as a payment option in DB/domain but not implemented — will silently create unprocessed payment records if selected | Payments | High |
| LB-5 | Transformation score entry has no trainer/admin UI — Third Eye module is read-only for staff without direct DB access | Transformation | High |
| LB-6 | Firebase Storage rules for non-payment buckets (avatars, etc.) not reviewed or committed to version control | Security | Medium |

---

*Audit complete. All findings are based on inspection of the actual implementation as of 2026-07-01–2026-07-02, including fixes applied in Session 19 (Admin Trainer Management, correcting an earlier false "trainer check-in unreachable" finding) and Session 22 (Docker/local-Supabase setup, verifying all 16 pgTAP files and 262 Flutter tests actually pass, fixing a broken pgTAP fixture and a broken CI formatting/lint gate, and removing dead/misleading workflow duplicates).*
