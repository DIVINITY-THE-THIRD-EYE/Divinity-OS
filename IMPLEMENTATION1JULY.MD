# DIVINITY — THE THIRD EYE
## Comprehensive Implementation Gap Analysis & Production Roadmap

**Audit Date:** 2026-07-01, last updated 2026-07-02 (Session 22 — CI/CD verification & environment setup)
**Codebase State:** 36 migrations, 16 pgTAP test files (117 assertions, verified passing via `supabase test db`), 262 Flutter tests, 1 integration test. Session 21 (not independently re-audited here beyond compile/test/lint verification) added the Student Feedback, Student Support, and Weekly Schedule modules plus reports pagination and enrollment-capacity locking — see `STATUS.md` for details.
**Architecture Baseline:** 16-module ecosystem (Website + Flutter App + Admin Panel)

---

## 1. EXECUTIVE SUMMARY

The project is in late-stage development. The core platform is solid: authentication, role-based access, batch management, attendance with geofencing, payments with a state-machine, events, workouts, transformation tracking, certificates, notifications, and a full admin analytics suite are all built and tested. Since the original audit, the following Phase A/B items have been resolved: `.env` removed from the APK (secrets now via `--dart-define`), `ARCHITECTURE_COMPLIANCE.md` brought current, the Admin Certificate Issuance screen built, Admin Events/Holidays promoted to a discoverable dashboard quick-access row, and the Admin Trainer Management screen built (migration 032 adds `users.is_active`, admin can now view/activate/deactivate trainers from a "Trainers" dashboard quick-access card). `ChakraLoader` has also been standardized across all full-screen loading states.

The remaining gaps fall into two categories:

1. **Four missing student-facing blueprint surfaces** — Feedback, Support, Today's Class dedicated screen, and Weekly Schedule — are the most consequential features not yet started.
2. **Production operations gaps** — CI/CD workflows now exist in both real repos (`divinity_flutter` → `Divinity-App`, `divinity-third-eye/divinity` → `Divinity-Website`) and are locally verified to pass (pgTAP 16/16 files, `flutter analyze --fatal-infos` clean, `flutter test` 262/262, website lint/typecheck/build/vitest all clean), but the Android/iOS release jobs need GitHub Secrets (Supabase keys + Android keystore) configured in each repo's settings before they'll succeed — that configuration step, plus store signing itself, requires repo-admin/Play-Console/Apple-Developer access outside this session. Integration tests also remain severely thin.

**Correction:** An earlier pass of this audit claimed `trainer_check_in_screen.dart` was unreachable from the trainer app. That was wrong — tapping any batch card on `TrainerDashboardScreen` (the trainer's default tab) or the "Check-in" button on the Batches tab pushes directly into it. Trainers can mark attendance today; it just isn't a dedicated bottom-nav tab.

**Assessment:** The project can reach a production soft-launch in **3–5 weeks** if the remaining Phase A items are addressed first.

---

## PHASE 1 — IMPLEMENTATION GAPS

### Gap 1.1 — Student Feedback Module

| Field | Detail |
|---|---|
| **Current Implementation** | Not started. No `lib/features/feedback/` directory, no DB migration, no Supabase table, no UI. |
| **Missing Functionality** | Student → submit session feedback (rating + comment); Trainer/Admin → view aggregated feedback. |
| **Why Incomplete** | Listed in blueprint Section 5 Student Dashboard as "Feedback" item. Never prioritized. |
| **Production Impact** | HIGH — students have no channel to report class quality. Management cannot measure trainer performance. |

### Gap 1.2 — Student Support Module

| Field | Detail |
|---|---|
| **Current Implementation** | Not started. No `lib/features/support/` directory, no DB migration, no ticket table, no UI. |
| **Missing Functionality** | Student → raise support ticket; Admin → view/resolve tickets. |
| **Why Incomplete** | Blueprint item never scheduled. |
| **Production Impact** | HIGH — students with billing/app problems have no in-app contact path. |

### Gap 1.3 — Today's Class Dedicated Surface

| Field | Detail |
|---|---|
| **Current Implementation** | `student_home_screen.dart` shows upcoming class cards in a `_NextClassBanner` + `_ClassCard` list. Data loaded via `homeDataProvider`. |
| **Missing Functionality** | No dedicated "Today's Class" tab/screen with full class details (trainer bio, batch notes, location, check-in CTA). Home treats upcoming classes as sidebar items. |
| **Why Incomplete** | Blueprint lists "Today's Class" as a first-class dashboard section. Home screen approximates it but without a dedicated surface. |
| **Production Impact** | MEDIUM — functionality exists partially on the Home tab but the UX is below blueprint intent. |

### Gap 1.4 — Weekly Schedule Surface

| Field | Detail |
|---|---|
| **Current Implementation** | `table_calendar: ^3.1.2` is in `pubspec.yaml` (imported but unused). Website has `/schedule` page. No schedule screen in the Flutter app. |
| **Missing Functionality** | Student sees their full 7-day batch schedule in a calendar/list view; highlights today's class. |
| **Why Incomplete** | Web `/schedule` handles it, but the blueprint requires it in the app too. |
| **Production Impact** | MEDIUM — students must open the website to see their weekly schedule. |

---

## PHASE 2 — MISSING MODULES

### Modules Not Started

| Module | Type | Missing Assets |
|---|---|---|
| Student Feedback | Feature | `lib/features/feedback/{data,domain,presentation}`, migration `033_feedback.sql`, pgTAP `c14_feedback_test.sql` |
| Student Support | Feature | `lib/features/support/{data,domain,presentation}`, migration `034_support.sql`, pgTAP `c15_support_test.sql` |

### Modules Partially Built

| Module | What Exists | What's Missing |
|---|---|---|
| Today's Class | Upcoming class cards in `student_home_screen.dart` | Dedicated screen/tab with full detail view + direct check-in CTA |
| Weekly Schedule | `table_calendar` package imported | No screen, no schedule view, no date navigation |

### Missing Screens

**Student App:**
- `student_feedback_screen.dart`
- `student_support_screen.dart`
- `weekly_schedule_screen.dart`
- `todays_class_screen.dart`

**Admin App:**
- `admin_notification_broadcast_screen.dart`

### Missing Repositories

| Repository | Feature |
|---|---|
| `FeedbackRepository` | Student feedback submission + admin read |
| `SupportRepository` | Support ticket CRUD |

### Missing Providers

| Provider | Feature |
|---|---|
| `feedbackProvider` | Feedback submission state |
| `supportProvider` | Support ticket state |
| `weeklyScheduleProvider` | Student's weekly class schedule |

### Missing Database Work

| Migration | Purpose |
|---|---|
| `033_feedback.sql` | `feedback` table (student_id, trainer_id, batch_id, rating, comment, created_at), RLS, indexes |
| `034_support.sql` | `support_tickets` table (student_id, subject, body, status, resolved_at), RLS |
| `035_membership_expiry_trigger.sql` | Auto-update `plan_status` to 'EXPIRED' when `expiration_date` passes |
| `036_notification_cleanup.sql` | Purge old notifications (>90 days) to prevent table bloat |
| `037_audit_log.sql` | Admin action audit table |
| `038_check_in_rate_limit.sql` | Prevent duplicate same-day check-in at DB level |

### Missing pgTAP Tests

| Test File | Purpose |
|---|---|
| `c14_feedback_test.sql` | Student can submit own feedback; admin reads all; trainer cannot read other trainers' |
| `c15_support_test.sql` | Student can create/read own tickets; admin can read/close all |
| Missing in existing | No pgTAP test for enrollment RLS (who can enroll students in batches) |
| Missing in existing | No pgTAP test for therapeutic logs batch-scoping (trainer sees only own students' logs) |
| Missing in existing | No pgTAP test for batch coordinate enforcement |
| Missing in existing | No pgTAP test for holiday date uniqueness constraint |

### Missing Documentation

- `MODULE_INDEX.md` — needs Module 15 entry
- `AI_CONTEXT.md` rule 7 — priorities section is stale (references pre-Session-17 work)
- ADR for `.env` → `--dart-define` migration decision
- ADR for "IndexedStack vs lazy shell" decision
- Release runbook for Play Store / App Store submission
- Database backup strategy documentation
- Monitoring & alerting runbook

---

## PHASE 3 — BUGS

### High-Priority Bugs

**BUG-H01: Admin FCM Deep-Link 'events' Falls Through to Dashboard**
- **Root Cause:** `admin_shell.dart`'s `_targetToIndex` has no case for `'events'` or `'holidays'`. FCM deep-link target `events` routes admin to index 0 (Dashboard).
- **Affected Module:** Admin App / Notifications
- **Production Impact:** Admin FCM tap for event notifications opens Dashboard instead of Events.

**BUG-H03: `table_calendar` Package Imported But Unused**
- **Root Cause:** `table_calendar: ^3.1.2` is in `pubspec.yaml` with no screen using it. Adds unnecessary APK weight.
- **Affected Module:** pubspec.yaml / App size
- **Production Impact:** MEDIUM — unnecessary dependency increases APK size and build time.

### Medium-Priority Bugs

**BUG-M02: Reports RPC Has No Pagination — Potential Timeout**
- **Root Cause:** `get_reports_data` aggregates all records in a single query with no `LIMIT`. With 1000+ students over 3+ years, this could exceed Supabase's 10-second RPC timeout.
- **Production Impact:** MEDIUM — reports may fail for mature academies.

**BUG-M03: Student Shell FCM Target 'certificates' Not Mapped**
- **Root Cause:** `_targetToIndex` in `student_shell.dart` has no case for `'certificates'`. FCM deep-link to certificates falls through to Home (index 0) instead of Certificates (index 7).
- **Production Impact:** LOW — no FCM notifications target certificates yet, but the tab is unreachable via deep link.

**BUG-M04: Reports Filter Triggers Full RPC on Every Change**
- **Root Cause:** `reportsDataProvider` watches `reportsFilterProvider`. Each filter change immediately re-fires the expensive `get_reports_data` RPC with no debounce.
- **Production Impact:** MEDIUM — unnecessary API calls; risk of rate limiting.

### Low-Priority Bugs

**BUG-L02: Attendance History Screen Has No Pagination**
- `attendance_repository.dart` fetches all records for a student with no `LIMIT`/`OFFSET`.

**BUG-L03: Quote-of-Day Is Static Per Weekday — Not Personalized**
- `student_home_screen.dart` cycles through 7 fixed quotes by day-of-week. All users see the same quote simultaneously.

---

## PHASE 4 — MISSING TESTS

### Missing Unit Tests

| Module | What Exists | What's Missing |
|---|---|---|
| Admissions | `admissions_unit_test.dart` ✅ | Edge: converting lead with existing account |
| Attendance | `attendance_unit_test.dart` ✅ | Edge: check-in outside geofence, duplicate check-in same day |
| Auth | `auth_unit_test.dart` ✅ | Edge: OTP expiry, password recovery state transitions |
| Batches | `batch_unit_test.dart`, `enrollment_unit_test.dart` ✅ | Edge: batch without coordinates, over-enrollment |
| Certificates | `certificates_unit_test.dart` ✅ | Edge: duplicate code generation |
| Events | `event_unit_test.dart` ✅ | Edge: capacity race condition, cancelled event registration attempt |
| Home | `home_unit_test.dart`, `weather_unit_test.dart` ✅ | Edge: weather cache TTL expiry, offline fallback |
| Leave | `leave_unit_test.dart` ✅ | Edge: overlapping leave requests |
| Payments | `payments_unit_test.dart` ✅ | Edge: payment already PAID, verification token reuse |
| Reports | `reports_unit_test.dart` ✅ | Edge: empty dataset, all filters combined |
| Workouts | `workout_unit_test.dart` ✅ | Edge: unassigned workout access |
| **Feedback** | ❌ None | All unit tests (module not built) |
| **Support** | ❌ None | All unit tests (module not built) |

### Missing Widget Tests

| Module | Has Widget Test | Missing |
|---|---|---|
| Analytics | `reports_widget_test.dart` ✅ | — |
| Auth | `auth_widget_test.dart` ✅ | Reset password screen widget test |
| Events | `event_widget_test.dart` ✅ | Admin event creation form test |
| Workouts | `workout_widget_test.dart` ✅ | Trainer workout builder with exercises |
| Admissions | ❌ | Leads screen with empty state, leads screen with data |
| Attendance | ❌ | CheckIn screen, AttendanceHistory list |
| Batches | ❌ | BatchesScreen, AdminBatchesScreen, EnrollmentSheet |
| Certificates | ❌ | CertificatesScreen empty state, share button, AdminCertificatesScreen |
| Dashboard | ❌ | AdminDashboardScreen stats cards |
| Home | ❌ | StudentHomeScreen with mock data, StreakCard, NextClassBanner |
| Leave | ❌ | LeaveRequestScreen validation, LeaveApprovalScreen admin actions |
| Notifications | ❌ | NotificationsScreen empty/populated states |
| Payments | ❌ | PaymentsScreen, AdminPaymentsScreen, RecordPaymentSheet validation |
| Profile | ❌ | ProfileScreen edit flow |
| Therapeutic Logs | ❌ | TherapeuticLogsScreen |
| Trainer | ❌ | TrainerDashboardScreen, TrainerCheckInScreen |
| Transformation | ❌ | ThirdEyeDashboardScreen, StudentProgressDetailScreen |

### Missing Integration Tests

| Flow | Status |
|---|---|
| Student views certificate, opens detail | ✅ `app_test.dart` |
| Empty certificates state shows trust badges | ✅ `app_test.dart` |
| **Login → OTP → onboarding → home** | ❌ |
| **Attendance check-in (geofenced)** | ❌ |
| **Payment submission → QR verification** | ❌ |
| **Admin creates batch → trainer assigned** | ❌ |
| **Leave request → trainer/admin approval** | ❌ |
| **Trainer marks workout complete** | ❌ |
| **Student registers for event** | ❌ |
| **Admin generates/exports report** | ❌ |
| **FCM notification → deep link navigation** | ❌ |

### Missing pgTAP Tests

| Test | Current State |
|---|---|
| Privileged field locks | c1 ✅ |
| Geofence check-in | c2 ✅ |
| Streak trigger | c3 ✅ |
| JWT role sync | c4 ✅ |
| Onboarding latches | c5 ✅ |
| Lead conversion | c6 ✅ |
| Therapeutic logs RLS | c7 ✅ |
| Payment verification | c8 ✅ |
| Certificates | c9 ✅ |
| Workouts | c10 ✅ |
| Events | c11 ✅ |
| Reports RLS | c12 ✅ |
| **Enrollment RLS (who can enroll students in batches)** | ❌ |
| **Feedback RLS** | ❌ (module not built) |
| **Support ticket RLS** | ❌ (module not built) |
| **Therapeutic logs batch-scoping (trainer sees own students only)** | ❌ |
| **Holiday date uniqueness constraint** | ❌ |
| **Batch coordinate enforcement via check_in** | ❌ |

### Missing Edge-Case and Stress Tests

- Concurrent attendance check-in (race condition on streak trigger)
- OTP resend rate limiting
- JWT expiry and refresh during a long session
- Payment already PAID — lock enforcement under concurrent writes
- Event capacity — two students register simultaneously when 1 seat remains
- `get_reports_data` with 10,000 attendance records (performance baseline)
- Offline app behavior (no connectivity fallback tests)
- Malformed JWT handling
- Expired Supabase session recovery

---

## PHASE 5 — PERFORMANCE IMPROVEMENTS

### Database

| Issue | Impact | Fix |
|---|---|---|
| `get_reports_data` RPC: monolithic single query, no pagination | Timeout risk with 1000+ student academy | Add pagination params (`p_limit`, `p_offset`) or split into lazy per-tab RPCs |
| Attendance history: no `LIMIT` parameter in query | Returns entire history for long-tenured students | Add `LIMIT`/`OFFSET` to `attendance_repository.dart` |
| Notifications table: no purge strategy | Table grows unboundedly | Add `036_notification_cleanup.sql` scheduled purge |
| No `ANALYZE` / autovacuum tuning documented | Stale planner statistics | Document maintenance cadence in PROJECT_BIBLE |

### Flutter

| Issue | Impact | Fix |
|---|---|---|
| `IndexedStack` loads all tabs eagerly at startup | 7–8 screens initialized simultaneously | Replace with lazy loading pattern or conditional `Builder` |
| `homeDataProvider`: no `LIMIT` on upcoming classes | Fetches all future classes for a student | Limit to next 7 days / 5 classes |
| Image loading: no `cacheHeight`/`cacheWidth` on NetworkImage | Memory pressure from large avatars | Add `cacheWidth` constraints to all NetworkImage widgets |
| `reports_screen.dart` is 1048 lines | Hard to maintain, increases build time | Split into separate tab files |
| Weather re-fetches on hot reload due to TTL logic | Wastes API quota | Fix TTL check to use persisted timestamp, not in-memory |

### Providers / Repositories

| Issue | Impact | Fix |
|---|---|---|
| No debounce on `reportsFilterProvider` changes | Each filter toggle fires expensive RPC | Add 500ms debounce in `reportsFilterProvider` notifier |
| `batchProvider` not cached between tab switches | Re-fetches on every navigation | Add `keepAlive` or local in-memory cache |
| No `ref.invalidate` strategy documented after mutations | Stale data after trainer marks attendance | Document and enforce invalidation on write operations |

### Caching

| Item | Current | Recommended |
|---|---|---|
| Weather | SharedPreferences 15-min TTL ✅ | Keep; add stale-while-revalidate |
| Batches | None — fetched on demand | Add `keepAlive` on batchProvider |
| Reports | None — re-fetched on each filter change | Add short-lived (30s) cache per filter combination |
| Certificates | None | Add `keepAlive` — changes rarely |

### Charts

| Issue | Fix |
|---|---|
| `fl_chart` loads all data points at once — no virtualization | Limit daily attendance trend to 90 days by default; add "Show All" option |
| Chart axis labels overlap with many data points | Add `getTitlesWidget` to skip every N-th label automatically |

---

## PHASE 6 — SECURITY IMPROVEMENTS

### Authentication

| Item | Status | Action |
|---|---|---|
| OTP login with Supabase Auth | ✅ | — |
| Google Sign-In | ✅ | — |
| DPDP consent gate in onboarding | ✅ | — |
| Password recovery screen | ✅ | — |
| Firebase App Check (`app_check_service.dart`) | ⚠️ Exists but not tested in production builds | Verify attestation active in release; add integration smoke test |
| OTP rate limiting | ⚠️ Supabase default — not custom configured | Document Supabase auth rate limit settings |
| Session token rotation | ⚠️ Not documented | Document Supabase JWT expiry policy (default 1 hour) |

### Authorization

| Item | Status | Action |
|---|---|---|
| RLS on all tables | ✅ (c1–c12 pgTAP) | — |
| `is_admin`/`is_trainer` SECURITY DEFINER helpers | ✅ | — |
| Privileged field locks (role, plan_status, payment status) | ✅ | — |
| JWT role sync trigger | ✅ | — |
| `get_reports_data` admin-only guard | ✅ | — |
| Therapeutic logs batch-scoping test | ⚠️ c7 tests general RLS but not batch-specific scoping | Add specific pgTAP assertion |
| Enrollment authorization test | ⚠️ No pgTAP test | Add test |

### Storage (Firebase)

| Item | Status | Action |
|---|---|---|
| Firebase Storage security rules (avatars, non-payment buckets) | ❓ Not reviewed — no `storage.rules` visible in project | Locate and audit — ensure students can only upload own avatar |
| File size/type validation on upload | ⚠️ `image_picker` in pubspec but no validation shown | Add MIME type + size validation before Firebase upload |

### Environment & Secrets

| Item | Status | Action |
|---|---|---|
| Firebase `google-services.json` | ⚠️ In Android directory — standard practice | Verify not committed to version control |
| `firebase_options.dart` | ⚠️ Contains Firebase project IDs | Acceptable for project IDs; never put secret keys here |

### Logging & Audit Trails

| Item | Status | Action |
|---|---|---|
| Firebase Crashlytics | ⚠️ In pubspec but integration not verified in tests | Add smoke test that Crashlytics initializes in debug mode |
| Firebase Analytics | ✅ Router observer wired | — |
| Admin action audit log | ❌ No `admin_audit_log` table | Add migration with admin action events (payment edits, user role changes, batch creation) |
| Payment state change log | ✅ Payment status locked via trigger | — |
| Login attempt logging | ⚠️ Not visible | Supabase Auth logs by default; document where to access |

### RPCs

| Item | Status | Action |
|---|---|---|
| `check_in` RPC — geofence enforced | ✅ | — |
| `convert_lead_to_member` RPC — admin-only | ✅ (c6) | — |
| `get_reports_data` RPC — admin-only | ✅ (c12) | — |
| `lock_privileged_fields` trigger | ✅ (c1) | — |
| `lock_payment_fields` trigger | ✅ (c8) | — |
| `sync_user_role_to_auth` trigger | ✅ (c4) | — |
| Rate limiting on `check_in` | ⚠️ No per-student rate limit on repeated same-day check-in attempts | Add guard: raise exception if student already checked in today |

---

## PHASE 7 — UI/UX IMPROVEMENTS

### Navigation

| Issue | Impact | Fix |
|---|---|---|
| Events accessible via AppBar icon only (student) | Students miss events feature | Add "Events" as 9th bottom nav tab OR promote to prominent home screen card |
| Trainer check-in only reachable by tapping a batch card (dashboard/batches tab), not a dedicated tab | Minor extra tap for a high-frequency daily action | Consider promoting to its own trainer shell tab |

### Responsiveness

| Issue | Fix |
|---|---|
| All screens are single-column — no tablet/landscape optimization | Add `LayoutBuilder` breakpoints for tablet (iPad) support |
| `table_calendar` imported but no calendar screen | Build a schedule screen using it, or remove from pubspec |
| Reports tabs don't adapt to landscape | Add two-column layout for landscape orientation |

### Accessibility

| Issue | Fix |
|---|---|
| `ThirdEyeIcon` widget has no `Semantics` wrapper | Add `semanticsLabel: 'Divinity logo'` |
| `ChakraLoader` widget has no `Semantics` wrapper | Add `semanticsLabel: 'Loading'` |
| Animated fire emoji in `_StreakCard` has no reduced-motion guard | Check `MediaQuery.of(context).disableAnimations` before calling `.animate()` |
| `_NextClassBanner` pulse animation has no reduced-motion guard | Same fix as above |
| `flutter_animate` used broadly — `prefers-reduced-motion` not consistently honoured | Create global `shouldAnimate(BuildContext)` helper and use everywhere |
| Chart colours rely on colour alone to differentiate data series | Add patterns or direct labels on chart elements |

### Empty States

| Screen | Empty State Status |
|---|---|
| Home (no classes) | ✅ `_EmptyState` widget |
| Reports tabs | ✅ Each tab checks `.isEmpty` |
| Events (no events) | ✅ |
| Workouts (no assignments) | ✅ |
| Certificates (none) | ✅ |
| Payments (none) | Needs verification |
| Notifications (none) | Needs verification |
| Therapeutic logs (none) | Needs verification |
| Batches (no batches) | Needs verification |
| Leads (no leads) | Needs verification |

### Consistency Issues

| Issue | Fix |
|---|---|
| SnackBar success messages use inconsistent background colours | Create `showAppSnackBar(context, message, isError: bool)` utility |
| AppBar title: some screens show feature name, others show "Divinity" | Standardize per shell |
| Date format varies across screens | Create `AppDateFormats` constants class |

---

## PHASE 8 — PRODUCTION READINESS ROADMAP

### Phase A — Critical (Must Complete Before Launch)

| # | Task | Module | Dependencies | Effort | Risk |
|---|---|---|---|---|---|
| A3 | **Configure GitHub Secrets** for the existing, verified CI workflows (`SUPABASE_URL`, `SUPABASE_ANON_KEY` on both repos; `ANDROID_KEYSTORE_BASE64`/`ANDROID_STORE_PASSWORD`/`ANDROID_KEY_PASSWORD`/`ANDROID_KEY_ALIAS` on `Divinity-App`) — see `STATUS.md` Session 22 for the full list | DevOps | Repo admin access | Small | CRITICAL |
| A4 | **Android signing config** — keystore, `key.properties`, Play Console app | Android / Release | Keystore | Small | CRITICAL |
| A5 | **iOS signing config** — Xcode provisioning profiles, App Store Connect | iOS / Release | Apple Developer | Small | CRITICAL |
| A6 | **Firebase App Check verification** — confirm attestation enforced in release builds | Security | Firebase console | Small | HIGH |

**Recommended Order:** A4 → A5 → A3 → A6 (A3 needs the Android keystore from A4 before its secrets can be filled in)

---

### Phase B — High Priority (Should Complete Before Launch)

| # | Task | Module | Dependencies | Effort | Risk |
|---|---|---|---|---|---|
| B1 | **Build Student Feedback module** — DB migration 033 + RLS + pgTAP c14 + Flutter feature | Feedback | None | Large | HIGH |
| B2 | **Build Student Support module** — DB migration 034 + RLS + pgTAP c15 + Flutter feature | Support | None | Large | HIGH |
| B3 | **Build Weekly Schedule screen** — use `table_calendar` (already in pubspec) | Schedule | Batches repo | Medium | MEDIUM |
| B5 | **Add integration tests for critical flows** — auth, attendance, payment, events | Testing | Flutter test env | Large | HIGH |
| B6 | **Add widget tests for all major screens** | Testing | mocktail | Large | HIGH |
| B7 | **Move Events to student bottom nav or home card** | Student / UX | None | Small | MEDIUM |
| B8 | **Add `prefers-reduced-motion` guard to all animations** | Accessibility | app_theme | Medium | HIGH |
| B9 | **Add Crashlytics integration smoke test** | Monitoring | Firebase | Small | MEDIUM |
| B10 | **Add `semantics` labels to `ThirdEyeIcon` and `ChakraLoader`** | Accessibility | None | Small | MEDIUM |

**Recommended Order:** B7 → B3 → B1 → B2 → B5 → B6 → B8 → B9 → B10

---

### Phase C — Medium Priority (Recommended Before Launch)

| # | Task | Module | Dependencies | Effort | Risk |
|---|---|---|---|---|---|
| C1 | **Pagination for Reports RPC** — add `p_limit`/`p_offset` to `get_reports_data` | Reports / DB | Migration 028 | Medium | MEDIUM |
| C2 | **Pagination for attendance history** — `LIMIT`/`OFFSET` in repository + infinite scroll UI | Attendance | None | Small | MEDIUM |
| C3 | **Replace `IndexedStack` with lazy shell loading** | All shells | None | Medium | LOW |
| C4 | **Add membership expiration auto-update trigger** — migration 035 | DB | None | Small | HIGH |
| C5 | **Add notification purge strategy** — migration 036 | DB | None | Small | LOW |
| C6 | **Add pgTAP test for enrollment RLS** | DB / Testing | None | Small | MEDIUM |
| C7 | **Add pgTAP test for therapeutic log batch scoping** | DB / Testing | None | Small | MEDIUM |
| C8 | **Add admin action audit log table** — migration 037 | DB / Security | None | Medium | MEDIUM |
| C9 | **Debounce reports filter changes** — 500ms delay before RPC call | Reports / Flutter | None | Small | LOW |
| C10 | **Remove `table_calendar` from pubspec if schedule screen not built** | Dependencies | None | Small | LOW |
| C11 | **Firebase Storage rules audit (non-payment buckets)** | Security | Firebase console | Small | MEDIUM |
| C12 | **Image upload size/type validation** in profile photo flow | Profile / Security | image_picker | Small | MEDIUM |
| C14 | **Standardize date formats** — create `AppDateFormats` constants | UI Consistency | None | Small | LOW |
| C15 | **Build Today's Class dedicated screen** | Student / Home | Home repo | Medium | LOW |
| C16 | **Website e2e tests** — Playwright: events page, contact form, schedule, mobile viewport | Website / Testing | Playwright | Medium | MEDIUM |
| C17 | **Add `fcm_target` 'certificates' mapping in student shell** | Student / Nav | None | Small | LOW |

---

### Phase D — Post-Launch Improvements

| # | Task | Module | Notes |
|---|---|---|---|
| D1 | Calendar view for student schedule using `table_calendar` | Schedule | Package already in pubspec |
| D2 | In-app chat between trainer and student | Communication | Supabase Realtime or new service |
| D3 | Leaderboard / gamification (streak leaderboard) | Transformation | Requires privacy policy update |
| D4 | Video attachments for workout exercises | Workouts | Firebase Storage integration |
| D5 | PDF generation for downloadable certificates | Certificates | `pdf` Flutter package |
| D6 | Payment gateway integration (Razorpay/Stripe) for online payments | Payments | Replaces UPI QR-only flow |
| D7 | Push notification opt-in management screen | Notifications | `firebase_messaging` already integrated |
| D8 | Admin broadcast notification screen | Notifications | Needs FCM service account |
| D9 | Student progress comparison across multiple transformation cycles | Transformation | Chart enhancement |
| D10 | Full-text search in student directory | Admin | GIN index + Supabase full-text search |
| D11 | Batch capacity enforcement in admin UI | Batches | DB constraint already exists |
| D12 | Dark mode for website | Website | CSS variables already tokenized |
| D13 | PWA offline caching strategy | Website | service-worker.js |
| D14 | Analytics event tracking (Firebase Analytics custom events) | Analytics | Route observer already wired |
| D15 | Tablet/iPad layout optimization | Flutter | `LayoutBuilder` breakpoints |

---

## 2. Remaining Modules

| Module | Status | Gap |
|---|---|---|
| Student Feedback | ❌ Not started | Full: DB + Flutter + Tests |
| Student Support | ❌ Not started | Full: DB + Flutter + Tests |
| Today's Class (as dedicated screen) | ⚠️ Partial (cards on home) | Dedicated screen + check-in CTA |
| Weekly Schedule | ⚠️ Partial (web only) | Flutter screen using `table_calendar` |

---

## 3. Remaining Features

1. Student Feedback submission + admin view
2. Student Support ticket creation + admin resolution
3. Weekly schedule calendar screen (student)
4. Today's Class dedicated view (student)
5. Admin trainer management (view, activate, deactivate)
6. Events moved to prominent/discoverable student navigation
7. Admin action audit trail
8. Membership auto-expiry trigger
9. Notification purge schedule
10. Admin broadcast notification capability

---

## 4. Missing Database Work

| Priority | Migration | Purpose |
|---|---|---|
| HIGH | `033_feedback.sql` | Feedback table + RLS + index |
| HIGH | `034_support.sql` | Support tickets table + RLS |
| HIGH | `035_membership_expiry_trigger.sql` | Auto-set `plan_status='EXPIRED'` via scheduled function |
| MEDIUM | `036_notification_cleanup.sql` | Delete notifications older than 90 days |
| MEDIUM | `037_audit_log.sql` | Admin action audit table |
| LOW | `038_check_in_rate_limit.sql` | Prevent duplicate same-day check-in at DB level |

---

## 5. Missing Backend Work

- `get_weekly_schedule(p_student_id)` RPC — returns student's batch schedule for the next 7 days
- `submit_feedback(p_batch_id, p_trainer_id, p_rating, p_comment)` RPC
- `create_support_ticket(p_subject, p_body)` RPC
- Membership expiry cron Edge Function (Supabase Deno) or DB trigger
- Notification purge Edge Function
- Admin broadcast FCM Edge Function

---

## 6. Missing Flutter Work

**New feature directories to create:**
- `lib/features/feedback/` — full data/domain/presentation
- `lib/features/support/` — full data/domain/presentation
- `lib/features/schedule/` — weekly schedule using `table_calendar`

**New screens to build:**
- `student_feedback_screen.dart`
- `student_support_screen.dart`
- `weekly_schedule_screen.dart`
- `todays_class_screen.dart`

**Fixes to existing screens/shells:**
- `student_shell.dart` — add Events as bottom nav tab or promote on home
- `admin_shell.dart` — fix `_targetToIndex` for 'events'/'holidays'
- All screens with `.animate()` — add `prefers-reduced-motion` guard

**Performance:**
- All shell `IndexedStack` → lazy loading
- Add `keepAlive` to batchProvider and certificatesProvider
- Add debounce to `reportsFilterProvider`
- Add `LIMIT` to `homeDataProvider` upcoming classes query

---

## 7. Missing Website Work

**Playwright e2e tests missing:**
- Events page rendering
- Contact form submission
- Schedule page navigation
- Certificate verification failure case
- Mobile viewport responsive layout test
- Blog page rendering

**Vitest unit tests:**
- Audit `lib/nav.ts`, `lib/seo.ts` for test coverage
- Add tests if missing

**Build pipeline:**
- No Lighthouse CI check in website build pipeline
- No broken-link checker in CI

---

## 8. Missing Tests

| Category | Current Count | Target | Gap |
|---|---|---|---|
| Flutter unit tests | 243 | ~320 | ~77 (Feedback, Support, Schedule, edge cases) |
| Flutter widget tests | ~12 (4 modules with widget tests) | ~40 | ~28 (missing modules, incl. AdminTrainersScreen) |
| Integration tests | 2 (certificates only) | ~12 | 10 critical flows |
| pgTAP test files | 13 (c1–c13) | 15 | c14 (feedback), c15 (support) |
| pgTAP assertions | 92 | ~120 | +28 (enrollment, batch-scoping, new modules) |
| Website e2e (Playwright) | 3 specs | 8 | +5 specs |

---

## 9. Missing Documentation

| Document | Gap |
|---|---|
| `MODULE_INDEX.md` | Module 15 entry missing |
| `AI_CONTEXT.md` Rule 7 | Priorities section stale (references pre-Session-17 work) |
| ADR for `.env` → `--dart-define` migration | No ADR documenting the decision |
| ADR for IndexedStack vs lazy loading | Architectural decision not documented |
| Release runbook | No documented steps for Play Store / App Store submission |
| Database backup strategy | Not documented in PROJECT_BIBLE |
| Monitoring & alerting runbook | No documented on-call procedure |

---

## 10. Security Improvements

| Priority | Item |
|---|---|
| 🔴 HIGH | Firebase App Check enforcement verified in production builds |
| 🔴 HIGH | Firebase Storage security rules audit for non-payment buckets and commit to version control |
| 🟠 MEDIUM | Admin action audit log table (migration 037) |
| 🟠 MEDIUM | File upload size/type validation (image_picker) |
| 🟠 MEDIUM | Therapeutic logs batch-scoping pgTAP assertion |
| 🟠 MEDIUM | Enrollment RLS pgTAP assertion |
| 🟡 LOW | OTP rate limiting custom configuration |
| 🟡 LOW | Session token rotation policy documented |
| 🟡 LOW | Same-day check-in duplicate guard at DB level |

---

## 11. Performance Improvements

| Priority | Item |
|---|---|
| 🔴 HIGH | `get_reports_data` pagination — timeout risk with large datasets |
| 🔴 HIGH | Lazy shell loading — replace `IndexedStack` with on-demand loading |
| 🟠 MEDIUM | Attendance history pagination (LIMIT/OFFSET) |
| 🟠 MEDIUM | Debounce reports filter changes (500ms) |
| 🟠 MEDIUM | Add `keepAlive` to frequently-used providers (batches, certificates) |
| 🟡 LOW | Chart data virtualization for long attendance trends |
| 🟡 LOW | Notification table purge to prevent unbounded growth |
| 🟡 LOW | Remove unused `table_calendar` package to reduce APK size |

---

## 12. UI/UX Improvements

| Priority | Item |
|---|---|
| 🔴 HIGH | `prefers-reduced-motion` guard on all Flutter animations (AI_CONTEXT rule 4) |
| 🔴 HIGH | Trainer check-in navigation wired into trainer shell |
| 🟠 MEDIUM | Events to student bottom nav (discoverability) |
| 🟠 MEDIUM | Semantic labels on `ThirdEyeIcon` and `ChakraLoader` |
| 🟠 MEDIUM | Standardize date formats — create `AppDateFormats` constants |
| 🟡 LOW | Tablet layout optimization |
| 🟡 LOW | Standardize SnackBar helper utility |
| 🟡 LOW | `fcm_target` 'certificates' mapping in student shell |

---

## 13. Production Launch Checklist

```
PRE-LAUNCH BLOCKLIST — all must be ✅ before launch:

☑ A1  .env removed from APK / secrets secured via --dart-define
□ A3  GitHub Secrets configured (CI/CD pipeline itself verified working — analyze/test/pgTAP/lint/build all pass locally)
□ A4  Android keystore + Play Console app created
□ A5  iOS provisioning + App Store Connect app created
□ A6  Firebase App Check active in production builds
☑ A7  ARCHITECTURE_COMPLIANCE.md updated (15/16 modules)
☑ A8  Admin certificate issuance screen built
☑ A9  Admin Events/Holidays in discoverable navigation
☑ B4  Admin Trainer Management screen built
□ B8  prefers-reduced-motion compliance verified
□ B9  Crashlytics confirmed active in production build
□ C4  Membership expiry trigger migration applied
□ C11 Firebase Storage rules audited and committed

LAUNCH-RECOMMENDED — should be ✅:

□ B1  Student Feedback module built
□ B2  Student Support module built
□ B3  Weekly Schedule screen built
□ B5  Integration tests for critical flows
□ C8  Admin audit log migration applied
□ C1  Reports RPC pagination implemented
```

---

## 14. Prioritized Roadmap

### Week 1
| Task | Effort |
|---|---|
| B8: Prefers-reduced-motion audit across all animations | 2 days |
| B7: Move Events to student bottom nav | 0.5 days |

### Week 2
| Task | Effort |
|---|---|
| A3: Configure GitHub Secrets on both repos (Supabase keys + Android keystore) | 0.5 days |

### Week 3
| Task | Effort |
|---|---|
| A4 + A5: App store signing config (Android + iOS) | 2 days |
| B1: Student Feedback module — migration 033 + feature + pgTAP c14 + unit/widget tests | 4 days |

### Week 4
| Task | Effort |
|---|---|
| B2: Student Support module — migration 034 + feature + pgTAP c15 + tests | 4 days |
| C4: Membership expiry trigger — migration 035 | 1 day |

### Week 5
| Task | Effort |
|---|---|
| B3: Weekly schedule screen using `table_calendar` | 3 days |
| B5: Integration test suite — auth, attendance, payment, events flows | 2 days |
| C8: Admin audit log — migration 037 | 1 day |

### Week 6
| Task | Effort |
|---|---|
| B6: Widget tests for all missing screens | 4 days |
| C1: Reports RPC pagination | 2 days |
| Final pre-launch audit and release build | 1 day |

---

## 15. Estimated Time to Production

| Scenario | Timeline |
|---|---|
| **Minimum viable launch** (remaining Phase A only — GitHub Secrets + store signing) | **1 week** |
| **Recommended soft launch** (Phase A + high-priority Phase B) | **3–4 weeks** |
| **Full blueprint compliance launch** (all 16 modules + Phase A + B + C) | **6–7 weeks** |

*Assumes 1 developer, full-time. Two developers would compress this further.*

---

## 16. Final Recommendation

**Conditional Go — Target Soft Launch in 3–4 Weeks.**

The platform's foundation is production-grade: comprehensive RLS with 92 pgTAP assertions enforcing security boundaries, geofenced attendance (student RPC + trainer manual mark, both reachable in-app), payment state machine with trigger locks, events with capacity enforcement, workouts with assignment notifications and student completion tracking, transformation tracking with AI insights, certificates with web verification and full admin issuance tooling, admin trainer management, and a full admin analytics suite. The 262 Flutter tests and 16 pgTAP test files (117 assertions, verified passing against a real Postgres instance) provide meaningful regression protection across all core flows. CI/CD (`flutter analyze`, `flutter test`, pgTAP, website lint/typecheck/build/vitest) is wired and verified working in both live repos — only the release-signing secrets remain to be configured.

### Do not launch before:

1. **A4–A5 — App store signing** (operational blocker: cannot publish to stores)
2. **A3 — GitHub Secrets configured** (blocks the CI release jobs only; analyze/test/pgtap/lint gates already pass without them)

### After those are resolved:

The project is suitable for **closed beta** with real students. The Feedback, Support, and Schedule modules (Phase B) are important quality-of-life features but do not block the core student loop:

> **Enroll → Check In → Pay → Track Progress → Graduate with Certificate**

The architecture is clean, modular, and extensible. Each remaining module follows the identical established pattern: **DB migration + RLS + triggers + repository + provider + screens + pgTAP tests**. No architectural redesign is required — only feature completion and operational hardening.

---

*Generated: 2026-07-01 | Updated 2026-07-02 (Session 22) after verifying pgTAP c1–c16 (117/117 assertions) against a real Postgres instance, fixing a broken test fixture (c16) and CI formatting/lint gates, and removing dead/broken workflow duplicates | Divinity – The Third Eye*
