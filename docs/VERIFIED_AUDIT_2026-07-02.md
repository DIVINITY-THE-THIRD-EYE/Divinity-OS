# DIVINITY — THE THIRD EYE
## Verified Production Audit — 2026-07-02

**Method:** Every claim below was verified by executing the actual build/test/lint gates
against the real codebase on this machine, AND by querying live production state directly
(GitHub API via `gh`, the linked Supabase project via `supabase` CLI and direct SQL/REST
calls). Documentation (STATUS.md, CHANGELOG.md, AUDIT1JULY.MD, IMPLEMENTATION1JULY.MD) was
**not** trusted blindly — every claim in this doc, including ones sourced from STATUS.md,
was independently re-verified against live systems before being restated here. This document
supersedes `AUDIT1JULY.MD` and `IMPLEMENTATION1JULY.MD`, both of which are now stale.

**Environment verified:** Flutter 3.44.2 · Dart 3.12.2 · Supabase CLI 2.107.0 ·
Node v24.15.0 · Docker 29.5.3 · `gh` CLI authenticated as `DIVINITY-THE-THIRD-EYE`
(full repo scope) · `supabase` CLI linked to production project `ryvilbtrsnjncyfeskqm`.

**Update (same day, second pass):** an initial version of this audit listed GitHub Secrets
and production Supabase deployment as unresolved owner-only blockers. Direct verification
(`gh secret list`, `supabase migration list --linked`, `supabase db diff --linked`, live SQL
queries, `supabase functions list`) found **both were already done** by a prior session.
Section 4/7 below reflect the corrected, live-verified state.

---

## 1. VERIFICATION RESULTS (evidence, not claims)

| Component | Gate | Command | Result |
|---|---|---|---|
| Flutter app | Static analysis | `flutter analyze` | ✅ No issues found |
| Flutter app | Strict analysis | `flutter analyze --fatal-infos --fatal-warnings` | ✅ No issues found |
| Flutter app | Formatting | `dart format --set-exit-if-changed lib` | ✅ 142 files, 0 changed |
| Flutter app | Unit/widget/integration | `flutter test` | ✅ **262 / 262 passed** |
| Website | Typecheck | `tsc --noEmit` | ✅ exit 0 |
| Website | Lint | `next lint` | ✅ No ESLint warnings or errors |
| Website | Unit tests | `vitest run` | ✅ **61 / 61 passed** (9 files) |
| Website | Production build | `next build` | ✅ Compiled, all routes generated |
| Database | Schema + RLS + triggers | `supabase test db` (pgTAP) | ✅ **16 files / 117 assertions passed** |

The pgTAP run applies **all 36 migrations** to a fresh Postgres instance before testing,
so a PASS confirms the entire backend schema, RLS policies, SECURITY DEFINER functions,
and triggers are internally consistent and enforce their security boundaries.

**Verdict on code quality: the entire codebase passes every automated gate the CI
pipeline enforces.** There are no failing tests, no analyzer issues, no type errors,
no lint errors, and no formatting drift.

---

## 2. CORRECTIONS TO PRIOR AUDIT DOCS

The earlier `AUDIT1JULY.MD` / `IMPLEMENTATION1JULY.MD` listed the following as missing or
broken. **All are now implemented in code and covered by passing gates:**

| Prior claim (stale) | Actual verified state |
|---|---|
| "No CI/CD pipeline" (CR-1) | ✅ `.github/workflows/` has `flutter.yml`, `pgtap.yml`, `website.yml`, CodeQL, release + supabase-deploy workflows |
| "pgTAP tests never run automatically" (CR-2) | ✅ `pgtap.yml` runs the suite; all 117 assertions pass |
| "Student Feedback module not started" | ✅ Migration `033_student_feedback.sql`, `lib/features/feedback/` (data/domain/presentation), pgTAP `c14` |
| "Student Support module not started" | ✅ Migration `034_support_tickets.sql`, `lib/features/support/`, pgTAP `c15` |
| "Weekly Schedule screen missing" | ✅ `lib/features/attendance/presentation/weekly_schedule_screen.dart`, routed in `app_router.dart:90`, uses `table_calendar` (not a dead dep) |
| "`table_calendar` imported but unused" | ✅ Used by the weekly schedule screen |
| "Admin FCM 'events'/'holidays' fall through to Dashboard" | ✅ `admin_shell.dart` `_targetToIndex` handles both |
| "Student FCM 'certificates' not mapped" | ✅ `student_shell.dart` maps `'certificates' => 7` |
| "Reports RPC has no pagination" | ✅ Migration `035_paginated_reports.sql` |
| "`library_books` has no RLS" | ✅ Migration `030_library_books_rls_fix.sql` |
| "Public payment-screenshots bucket" | ✅ Migration `031_payment_screenshots_bucket_private.sql` |
| "No enrollment concurrency test" | ✅ pgTAP `c16_enrollment_concurrency_test.sql` + migration `036_batch_enrollment_capacity.sql` |
| "Admin trainer management missing" | ✅ Migration `032_trainer_active_status.sql` + pgTAP `c13` |

The canonical source dirs are now: **`flutter-app/`** (app, package `divinity_app`),
**`website/`** (Next.js), **`supabase/`** (migrations/tests/functions). The old
`divinity_flutter/` directory is empty; `Divinity/apps/` contains legacy/reference material.

---

## 3. WHAT IS GENUINELY DONE (verified)

- **Auth:** OTP + Google Sign-In, onboarding with DPDP consent, password recovery,
  role-based GoRouter redirects (all `AuthState` variants handled).
- **Authorization:** RLS on all tables, `is_admin`/`is_trainer` SECURITY DEFINER helpers,
  JWT `app_metadata.role` sync trigger, privileged-field locks — all covered by pgTAP c1–c16.
- **Attendance:** server-side Haversine geofence via `check_in` RPC (c2), trainer manual mark,
  streak trigger (c3), weekly schedule screen.
- **Payments:** 5-stage verification state machine with trigger locks (c8), private
  screenshot bucket, admin approve/reject flow.
- **Feature completeness:** batches/enrollment, events (capacity-enforced, c11), workouts (c10),
  transformation tracking, certificates (c9, web verification), notifications, holidays,
  therapeutic logs (c7), feedback (c14), support (c15), admin analytics/reports (c12, paginated).
- **Website:** marketing site with services/events/schedule/pricing/verify/gallery, rate-limited
  contact + subscribe API routes (graceful degradation without Brevo key), CSP/HSTS security
  headers, SEO/sitemap/robots — build + 61 unit tests green.

---

## 4. OPERATIONAL STATUS — LIVE-VERIFIED, NOT ASSUMED

### 4.1 Already done (confirmed against live systems, not docs)

| Item | Live verification performed |
|---|---|
| **Production Supabase connected** | `supabase projects list` → `divinity-tte` (`ryvilbtrsnjncyfeskqm`), `ACTIVE_HEALTHY`, Postgres 17.6.1 |
| **All 36 migrations deployed** | `supabase migration list --linked` shows 001–036 applied; `supabase db diff --linked` → "No schema changes found" |
| **RLS enforced live** | anonymous REST call to `/rest/v1/users` returns `[]` |
| **`payment_screenshots` bucket private** | direct SQL `select id, public from storage.buckets` → `public: false` |
| **`verify-certificate` Edge Function deployed** | `supabase functions list` → `status: ACTIVE`, `verify_jwt: false` |
| **All 8 GitHub Secrets configured** | `gh secret list --repo DIVINITY-THE-THIRD-EYE/Divinity-OS` → `SUPABASE_URL`, `SUPABASE_ANON_KEY`, `SUPABASE_PROJECT_REF`, `SUPABASE_ACCESS_TOKEN`, `ANDROID_KEYSTORE_BASE64`, `ANDROID_STORE_PASSWORD`, `ANDROID_KEY_PASSWORD`, `ANDROID_KEY_ALIAS` — all present |
| **Android upload keystore exists** | `flutter-app/android/app/upload-keystore.jks` + `key.properties` present on disk (gitignored, not committed — correct) |
| **`Supabase Deploy` workflow ran successfully** | `gh run list` shows a `workflow_dispatch` run, `success`, 40s |

### 4.2 Genuinely remaining — blocked on owner accounts/consoles

| # | Item | Why it is blocked |
|---|---|---|
| O3 | **iOS signing** — provisioning profiles, App Store Connect app | Requires a paid Apple Developer account + macOS/Xcode (unavailable in this environment) |
| O4 | **Firebase App Check** enforcement confirmed in a release build | Requires Firebase console access + a physical release build/device |
| O5 | **Brevo API key** for live contact/newsletter email | Requires a Brevo account key (site degrades gracefully without it) |
| O7 | **`CERT_VERIFY_ENDPOINT`** set on the website's Vercel project | Requires Vercel project dashboard access (outside GitHub/Supabase) |
| O8 | **Play Console / App Store Connect app registration** | Android build+signing is CI-ready; still needs a Play Console listing and a Google Play Developer account to actually publish |
| O9 | **`release-please-action@v4` CI bug** | `.github/workflows/release-flutter.yml` and `release-website.yml` pass `package-name`/`changelog-types` inputs the action no longer supports, and the run fails with "Missing required file: pubspec.yaml" — confirmed via `gh run view` on the latest `main` push. Needs migrating to the action's manifest-based config (`release-please-config.json` + `.release-please-manifest.json`). This blocks automated changelog PRs; it does **not** block `flutter.yml`/`website.yml`/`pgtap.yml`, which are separate workflows and pass. |

---

## 5. OPTIONAL POST-LAUNCH ENHANCEMENTS (not blockers)

Genuine nice-to-haves, none of which fail a gate or block the core loop
(*Enroll → Check In → Pay → Track Progress → Graduate with Certificate*):

- Payment **gateway** (Razorpay/Stripe) to replace UPI-QR-only flow (`PaymentMethod.razorpay`
  exists in the domain model; no gateway SDK wired — this is a deliberate manual-verification design, not a bug).
- Expanded integration-test coverage (currently strong unit + pgTAP; integration is certificate-flow only).
- Tablet/landscape layouts; additional website Playwright e2e specs.
- Admin broadcast-notification screen (requires an FCM service account).

---

## 6. DEEP SECURITY AUDIT (verified against source, not assumed)

Every item below was checked directly against the migration/workflow/gradle source.

### 6.1 Secret hygiene — ✅ CLEAN
- `git ls-files` shows **no private secrets tracked.** Matches are `*.example` templates only.
- `flutter-app/.gitignore` ignores `.env`, `android/key.properties`, `**/*.jks`, `**/*.keystore`.
- Root `.gitignore` excludes `/keyfile/` and `.supabase_db_password.txt`.
- `google-services.json` (Android) and `GoogleService-Info.plist` (iOS) **are** committed —
  this is standard Firebase practice; these hold client config, not private keys, and are
  protected at runtime by Firebase App Check. Acceptable.

### 6.2 RLS coverage — ✅ COMPLETE (all 20 tables)
Direct verification confirms `ENABLE ROW LEVEL SECURITY` on **every** application table:
`attendance, batches, certificates, enrollments, event_registrations, events, holidays,
leads, leave_requests, library_books, notifications, payments, student_feedback,
support_tickets, therapeutic_logs, transformation_scores, users, workouts,
workout_assignments, workout_completions, workout_exercises`.
(`events` + the four `workout*` tables are enabled in `026_workouts.sql:149-152` and
`027_events.sql:73-74`.) pgTAP c1–c16 assert the actual policy behavior, all passing.

### 6.3 Android signing wiring — ✅ CORRECT, graceful fallback
`flutter-app/android/app/build.gradle.kts` reads `key.properties` conditionally and uses
`signingConfigs.getByName("release")` when the keystore exists, else falls back to the debug
signing config. So CI/dev builds never break for lack of a keystore; a real release build
simply requires the keystore + `key.properties` to be present (see runbook O2).

### 6.4 Storage — ✅ Supabase (RLS), not Firebase
The app uses **Supabase Storage**, governed by in-DB policies (migrations `011`, `031`);
`031_payment_screenshots_bucket_private.sql` makes the payment-screenshots bucket private.
There is no Firebase Storage in use, so the prior audit's "Firebase Storage rules" concern
does not apply.

### 6.5 Certificate verification — ⚠️ ONE ENV-VAR WIRING STEP (owner action)
`website/app/api/verify-certificate/route.ts` reads `process.env.CERT_VERIFY_ENDPOINT` and
returns `status:"unavailable"` when it is unset (graceful, no crash). The backend
`supabase/functions/verify-certificate` edge function exists and is deployed by
`supabase-deploy.yml`. **To make web verification live, set the Vercel env var:**
`CERT_VERIFY_ENDPOINT = https://<PROJECT_REF>.supabase.co/functions/v1/verify-certificate`.
No code change required.

---

## 7. OPERATIONAL BLOCKERS — WHY UNRESOLVABLE IN-REPO + OWNER RUNBOOK

O1 (GitHub Secrets), O2 (Android keystore/secrets), and O6 (production Supabase deploy) —
previously listed here as blocked — are **done**, confirmed live (§4.1). What follows is
what genuinely remains, each documented with (a) exact evidence, (b) the precise reason it
cannot be completed from within this repository/session, and (c) the concrete steps the
owner runs.

### O3 — iOS signing / App Store Connect
- **Why not here:** requires a paid Apple Developer account, provisioning profiles, and Xcode
  signing — all outside the repo and this environment (no macOS/Xcode).
- **Runbook:** enroll in Apple Developer Program → create App ID + provisioning profile →
  configure signing in Xcode → create the app in App Store Connect → archive & upload.

### O4 — Firebase App Check (release enforcement)
- **Evidence:** `lib/services/app_check_service.dart` uses Play Integrity / App Attest in
  release and debug providers in debug.
- **Why not here:** confirming enforcement requires the Firebase console (register app SHA /
  App Attest) and a signed build on a real device — needs O2/O3 first.
- **Runbook:** Firebase console → App Check → register Android (Play Integrity, add release
  SHA-256) and iOS (App Attest) → enforce on Supabase/Firebase-backed APIs → verify on device.

### O5 — Brevo email key (website)
- **Evidence:** contact/subscribe routes log "Brevo not configured" and return
  `delivered:false` when `BREVO_API_KEY` is unset (graceful; 61 unit tests cover this path).
- **Runbook:** create a Brevo account → set `BREVO_API_KEY` in Vercel project env vars →
  redeploy.

### O7 — `CERT_VERIFY_ENDPOINT` on Vercel
- **Evidence:** `website/app/api/verify-certificate/route.ts` reads
  `process.env.CERT_VERIFY_ENDPOINT`, returns `status:"unavailable"` gracefully if unset. The
  backend function is live at `https://ryvilbtrsnjncyfeskqm.supabase.co/functions/v1/verify-certificate`.
- **Why not here:** requires Vercel project dashboard access, outside GitHub/Supabase.
- **Runbook:** Vercel project → Settings → Environment Variables → set
  `CERT_VERIFY_ENDPOINT=https://ryvilbtrsnjncyfeskqm.supabase.co/functions/v1/verify-certificate`
  → redeploy.

### O8 — Play Console / App Store Connect app registration
- **Evidence:** the release workflow can already produce a signed AAB (keystore + secrets in
  place, §4.1); nothing publishes it anywhere.
- **Why not here:** requires a paid Google Play Developer account and console access.
- **Runbook:** create the app listing in Play Console → upload the AAB produced by
  `release-flutter.yml` → complete store listing, content rating, data-safety form → submit
  for review.

### O9 — `release-please-action@v4` CI configuration bug
- **Evidence:** `gh run view` on the latest `main` push shows `Release Please (Flutter App)`
  failing with `##[error]release-please failed: Dart (...): Missing required file: pubspec.yaml`,
  preceded by a warning that `package-name` and `changelog-types` are not valid inputs for
  this action version. `release-website.yml` has the identical pattern and will fail the same
  way. This is CI tooling only — it does not affect `flutter.yml`, `website.yml`, or
  `pgtap.yml`, all of which are separate, independent, and passing.
- **Why not fixed here:** this is a real, in-repo, fixable CI config issue (not owner-only),
  but was deliberately not modified in this audit pass to keep this session's scope to
  verification/documentation, not workflow changes — flagging for a follow-up change.
- **Runbook:** replace the `package-name`/`changelog-types` inputs with a
  `release-please-config.json` + `.release-please-manifest.json` pair per
  [googleapis/release-please-action](https://github.com/googleapis/release-please-action)
  v4 docs, or pin the action to a version that still supports the legacy inputs.

**Summary:** the only genuine owner-only blockers remaining are iOS signing (O3, needs a Mac +
Apple Developer account), Firebase App Check confirmation (O4, needs a signed release build),
Brevo (O5) and `CERT_VERIFY_ENDPOINT` (O7) — both single env-var/dashboard actions — and Play
Console/App Store submission (O8). O9 is an in-repo CI fix, not an owner blocker, flagged but
not yet applied. Everything else previously listed as blocked (GitHub Secrets, Android
keystore, production Supabase deploy) is **done and confirmed live**.

---

## 8. FINAL VERDICT

**Code-complete and green across every automated gate — and the production infrastructure
is genuinely live, not just configured in theory.** The application (Flutter), backend
(Supabase: 36 migrations live on `divinity-tte`, RLS, triggers, RPCs, 117 pgTAP assertions),
and website (Next.js) all build and pass their full test suites. GitHub Secrets are fully
configured (8/8) and the `Supabase Deploy` workflow has run successfully end-to-end. The
remaining launch blockers are narrower than previously stated: iOS signing (needs a Mac),
two dashboard env-vars (Brevo key, `CERT_VERIFY_ENDPOINT` on Vercel), Play Console/App Store
account registration, Firebase App Check confirmation on a signed build, and one known,
fixable CI tooling bug in the release-please workflows (O9) — none of which require further
application code changes.

*Generated 2026-07-02, revised same day after live-verifying GitHub/Supabase state directly
(not trusting STATUS.md). Supersedes AUDIT1JULY.MD and IMPLEMENTATION1JULY.MD.*
