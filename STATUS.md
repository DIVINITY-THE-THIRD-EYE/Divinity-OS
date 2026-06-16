# DIVINITY BUILD STATUS
Session completed: 1 — Auth + RBAC + RLS
Date: 2026-06-16

## Done this session
- Added `AuthOtpSent` state to sealed `AuthState`
- `AuthNotifier.sendOtp` → transitions to `AuthOtpSent`; `verifyOtp` → resolves role; `resendOtp` helper
- `LoginScreen` OTP toggle (password ↔ OTP mode, single phone field shared)
- New `OtpScreen` — 6-digit PIN input, auto-submit on full entry, Resend + Back to Login
- `Routes.otp` added to router; redirect handles `AuthOtpSent` → `/otp`
- Role-based shells: `StudentShell` (5 tabs), `TrainerShell` (4 tabs), `AdminShell` (5 tabs)
- `RoleShell` — reads `AuthAuthenticated.role` and renders correct shell
- Router home `/` now uses `RoleShell` instead of `HomeStubScreen`
- Supabase migration `001_users_rls.sql` — `public.users` table, 6 RLS policies, auto-create trigger on signup, age/gender lock trigger after onboarding
- Unit tests (12): UserRole.fromString, AuthNotifier init/signIn/sendOtp/verifyOtp/signOut
- Widget tests (9): LoginScreen render/toggle/validation/branding, OtpScreen render/phone display
- `flutter analyze`: 0 issues | `flutter test`: 24/24 passing

## Next session (2) will do
- `branches` + `batches` CRUD (admin/trainer)
- Member onboarding wizard (medical, emergency contacts, age/gender lock UI)
- CRM: `leads` table, pipeline NEW→CONSULTATION→ADMITTED→LOST
- Admission flow: convert lead → `users` row + set plan_status
- Tests: unit (lead→member conversion), widget (onboarding wizard lock), integration stubs

## Decisions needed from human
- Supabase ANON KEY still needs to be added to .env (placeholder in place)
- Firebase project not yet created — needed for Session 5 (FCM/Analytics/Crashlytics)

## How to resume
Paste: "Read STATUS.md and git log, then continue with the next session."

## Test status
unit: PASS  widget: PASS  integration: n/a  e2e: n/a
