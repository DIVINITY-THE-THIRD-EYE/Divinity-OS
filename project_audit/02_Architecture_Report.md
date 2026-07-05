# 02 — Architecture Report

## Flutter app (`flutter-app/`)

**Entry point:** [lib/main.dart:36-92](flutter-app/lib/main.dart). Supabase initializes at lines 48-51 (`Supabase.initialize(url: _supabaseUrl, publishableKey: _supabaseAnonKey)`), with env vars injected via `--dart-define-from-file=dart_defines.json`. Firebase initializes at line 53 (`Firebase.initializeApp`), followed by App Check (line 56), Remote Config defaults (lines 59-77), and Crashlytics wiring (lines 80-84). The root widget `DivinityApp` (lines 94-120) watches `routerProvider`, `themeModeProvider`, and `localeProvider`, and builds a `MaterialApp.router`.

**Role-based routing:** [lib/core/router/app_router.dart:31-104](flutter-app/lib/core/router/app_router.dart) defines `routerProvider`; auth-state redirect logic lives in `_RouterNotifier.redirect()` (lines 116-138), handling the full state machine (`AuthInitial → AuthLoading → AuthOtpSent → AuthNeedsOnboarding → AuthPendingApproval → AuthAuthenticated`). Dispatch to role-specific UI happens in [lib/features/shells/role_shell.dart:12-48](flutter-app/lib/features/shells/role_shell.dart), switching on `authState.role` (line 40) to `AdminShell`, `TrainerShell`, or `StudentShell`. The Admin shell alone has 8 tabs (Dashboard, Payments, Admissions, Students, Leaves, Batches, Certs, Reports).

**State management:** Consistently `AsyncNotifier`-based across all 22 feature folders — no mixed `StateNotifier`/`Notifier`/plain-`Provider` inconsistency was found. Representative examples: `TodayAttendanceNotifier` ([lib/features/attendance/presentation/attendance_provider.dart:15-50](flutter-app/lib/features/attendance/presentation/attendance_provider.dart)), `MyPaymentsNotifier`, `MyLeaveNotifier`. Derived providers (`currentUserIdProvider`, `currentUserRoleProvider`, [lib/features/auth/presentation/auth_provider.dart:60-69](flutter-app/lib/features/auth/presentation/auth_provider.dart)) give every feature reactive teardown on logout for free. Auth itself is the one hand-rolled `StateNotifier` (a genuine domain state machine, not an inconsistency — `AuthNotifier extends StateNotifier<app_auth.AuthState>`, line 79-82).

**Data layer — feature → repository map** (22 features, 24 repository implementations; all Supabase-backed except `WeatherRepository`, which hits an external weather API):

| Feature | Primary file |
|---|---|
| auth | `lib/features/auth/data/auth_repository.dart` |
| attendance | `lib/features/attendance/data/attendance_repository.dart` |
| payments | `lib/features/payments/data/payment_repository.dart` |
| leave | `lib/features/leave/data/leave_repository.dart` |
| workouts | `lib/features/workouts/data/workout_repository.dart` |
| plans | `lib/features/plans/data/plans_repository.dart` |
| events | `lib/features/events/data/event_repository.dart` |
| feedback | `lib/features/feedback/data/feedback_repository.dart` + `supabase_feedback_repository.dart` |
| support | `lib/features/support/data/support_repository.dart` + `supabase_support_repository.dart` |
| therapeutic_logs | `lib/features/therapeutic_logs/data/therapeutic_log_repository.dart` |
| certificates | `lib/features/certificates/data/certificate_repository.dart` |
| admissions (leads) | `lib/features/admissions/data/leads_repository.dart` |
| batches | `lib/features/batches/data/batch_repository.dart` + `enrollment_repository.dart` |
| holidays | `lib/features/holidays/data/holiday_repository.dart` |
| notifications | `lib/features/notifications/data/notification_repository.dart` |
| dashboard | `lib/features/dashboard/data/dashboard_repository.dart` |
| analytics/reports | `lib/features/analytics/data/reports_repository.dart` |
| home | `lib/features/home/data/home_repository.dart` + `weather_repository.dart` |
| profile | `lib/features/profile/data/profile_repository.dart` |
| transformation | `lib/features/transformation/data/transformation_repository.dart` |
| admin_ops | inline in `lib/features/admin_ops/presentation/audit_log_screen.dart:9-19` (no dedicated repo — only screen not following the pattern) |

**Error handling:** consistent three-layer pattern — repository throws a domain exception (e.g. `CheckInException`) → notifier catches and sets `AsyncValue`/error state → UI shows a snackbar with a user-facing message, generic catch as fallback. Example: [lib/features/attendance/presentation/check_in_screen.dart:189-195](flutter-app/lib/features/attendance/presentation/check_in_screen.dart). No swallowed exceptions found.

**Theming:** single shared source, [lib/core/theme/app_theme.dart](flutter-app/lib/core/theme/app_theme.dart) — `DivinityPalette` constants (`voidColor`/`bone`/`ember`, lines 12-23) explicitly comment that they mirror the website's tokens (`app/globals.css`, `tailwind.config.ts`), which is the cross-surface design-token consistency the product decisions require. Typography: Cormorant/Hanken Grotesk/JetBrains Mono via `google_fonts`.

**i18n:** fully wired — `lib/l10n/app_en.arb` + `app_hi.arb` (44 keys each, complete parallel translation), generated `AppLocalizations` delegates, a `StateNotifierProvider`-backed `LocaleNotifier` ([lib/core/l10n/locale_provider.dart](flutter-app/lib/core/l10n/locale_provider.dart)) persisting choice to `SharedPreferences`, and a switcher UI in [lib/features/profile/presentation/profile_screen.dart:378-397](flutter-app/lib/features/profile/presentation/profile_screen.dart).

**Dead code:** minimal. One TODO found repo-wide: `lib/services/fcm_service.dart` — "show in-app banner with flutter_local_notifications" (push itself works; only the in-app toast is missing). No orphaned repositories or unused providers detected.

## Website (`website/`)

**Entry/layout:** [app/layout.tsx:1-126](website/app/layout.tsx). Provider tree (lines 89-124): `ThemeProvider` → `LocaleProvider` → `MotionProvider` → global chrome (Ambient, ScrollProgress, SmoothScroll, Cursor, CommandPalette, PromoBar, Nav, Footer, WhatsAppFab, StickyCta) → page content, with a skip-to-content a11y link (lines 96-101). Fonts (Cormorant/Hanken Grotesk/JetBrains Mono) loaded via `next/font/google` (lines 20-42).

**Routing:** 16 pages under `app/`, 3 of them statically pre-rendered via `generateStaticParams` (`/blog/[slug]`, `/events/[slug]`, `/services/[slug]`). 3 API routes: `contact`, `subscribe`, `verify-certificate` (all under `app/api/`).

**Data layer:** `lib/content.ts` (487 lines) is the local static-content fallback; `lib/sanity.ts` conditionally creates a Sanity client only if `NEXT_PUBLIC_SANITY_PROJECT_ID` is set, with a `fetchOrFallback<T>()` pattern (lines 22-34) that always degrades gracefully to local content on any CMS error. 5 Sanity schema types registered (`siteSettings`, `discipline`, `plan`, `classSlot`, `testimonial`).

**Theme:** tokens in `app/globals.css:14-78` — `--void`/`--bone`/`--ember` plus supporting variables, dark (`:root`) and light (`[data-theme="light"]`) variants. A dark/light toggle exists (`lib/theme/ThemeContext.tsx`), correctly overriding the older `design/adr/0012-no-user-theme-toggle.md` per the current product decision — the code comment explicitly documents the override.

**i18n:** `lib/i18n/translations.ts` covers only nav/footer/homepage-hero (17 strings) — English + Hindi, client-side toggle via `LocaleContext.tsx`, persisted to `localStorage`, switcher in `components/Nav.tsx:109-121`. This is real but **partial** coverage — see [03_Feature_Status.md](03_Feature_Status.md) for the gap against the "all user-facing screens" decision.

**Verified live (this session):** started the dev server and pulled an accessibility-tree snapshot of the homepage — skip-link, semantic nav/headings/articles all present; resizing to a 375px mobile viewport correctly collapsed the desktop nav into a hamburger "MENU" button. Console showed only informational React DevTools messages and a `prefers-reduced-motion` notice (the site correctly respects that media feature) — no errors.

**Dead code:** none found. All 41 components in `website/components/` are used; no duplicated logic; no repo-wide TODO/FIXME/HACK comments in first-party code.

## Supabase (`supabase/`)

45 migrations (001–045, gapless, no reverts), 25 tables (all RLS-enabled, every table has ≥1 policy — see [08_Database_Report.md](08_Database_Report.md) for the full table/policy/trigger inventory), 40+ functions (mostly `SECURITY DEFINER`, using `is_admin()`/`is_trainer()` helper functions introduced in migration 012 specifically to break RLS-policy recursion), 1 edge function (`verify-certificate`), 23 pgTAP test files / 188 assertions.

## Cross-surface consistency

- **Design tokens:** the Flutter app's theme file explicitly cites the website's token source in a comment — this is the one place cross-surface consistency is self-documented in code, not just asserted in a PRD doc.
- **Auth:** Flutter app uses Supabase Auth directly (`supabase_flutter`); the website has no login surface at all (it's public-marketing-only) — this isn't a mismatch, it's simply out of scope for the website by design.
- **i18n:** the Flutter app's localization is materially more complete (all 44 UI strings, generated delegates) than the website's (17 chrome strings only) — a real, if minor, cross-surface asymmetry worth a product decision (expand website i18n, or explicitly scope it down in the decision record).
