# 12 — STUDENT LOGIN (existing Supabase auth on the website)

## PURPOSE
Students sign in on the website with the SAME account they use in the Flutter app.
No new auth system (D003, PROJECT_RULES #9/#10).

## SECURITY NOTES (read fully — normal prose, no shortcuts)
- The website uses the Supabase **anon key only** (`NEXT_PUBLIC_SUPABASE_URL`,
  `NEXT_PUBLIC_SUPABASE_ANON_KEY`). The service-role key must NEVER appear in the
  website codebase, its env files, or client bundles.
- Authorization is enforced by the existing RLS policies in the shared database. The
  website must not add privileged endpoints that bypass RLS.
- Role comes from the JWT `app_metadata.role` (synced by the existing
  `sync_user_role_to_auth` trigger). Trust the JWT claim, not a client-side database read.
- Auth flow matches the app: phone OTP via Supabase. Do not add password auth or new
  OAuth providers in this task.
- CSP (`next.config.mjs`) must be extended to allow `connect-src https://<project-ref>.supabase.co`
  — add the explicit host, not a wildcard.
- If any change to `supabase/` seems necessary: STOP and follow the repo skill
  `change-database-safely`. Expected: ZERO schema changes in this task.

## INPUTS
- Phases 1–5 COMPLETE.
- `docs/SUPABASE_SETUP.md` (project ref, how apps connect) — IF MISSING: get URL/ref
  from `flutter-app/dart_defines.json.example` naming and STATUS-note it.
- Env: `website/.env.local` with the two public vars — IF MISSING: create
  `website/.env.example` documenting them, mark BLOCKED-for-env in STATUS only if real
  values are unavailable in `docs/SUPABASE_SETUP.md`.

## OUTPUTS
- `npm i @supabase/supabase-js @supabase/ssr` (record versions in DECISIONS notes).
- `website/lib/supabase/client.ts` (browser) + `website/lib/supabase/server.ts`
  (server components/route handlers, cookie-based via `@supabase/ssr`).
- `website/middleware.ts` — session refresh + guard for `/portal/**`.
- Routes (route group `app/(portal)/`):
  - `/login` — phone input → OTP code → session. Students only: after session,
    read `app_metadata.role`; role !== `student` → sign out + message
    "This portal is for students. Trainers and admins use the mobile app."
  - `/portal` — student dashboard shell (greeting from session, links, and the
    Flutter Web slot filled by task 13).
  - `/logout` — sign out + redirect home.
- Portal routes live under `app/(portal)/` with the minimal layout (E-002 — no Lenis,
  no cursor, no marketing providers).
- Nav "Student Login" link is added in task 13 after its validation passes (structural
  dark-launch — routes exist unlinked; no env flag).

## FILES ALLOWED
`website/app/(portal)/**` · `website/lib/supabase/**` · `website/middleware.ts` ·
`website/package.json` · `next.config.mjs` (CSP connect-src line only) ·
`website/.env.example` · STATUS/CHANGELOG/DECISIONS.

## FILES FORBIDDEN
`supabase/**` (any change → STOP per SECURITY NOTES) · `flutter-app/**` ·
`app/api/**` existing routes · service keys anywhere.

## STEPS
1. Install deps; create client/server helpers per `@supabase/ssr` documented pattern
   (fetch current docs via context7/web if available; else follow the package README in
   `node_modules/@supabase/ssr`).
2. Middleware: refresh session cookie; unauthenticated request to `/portal/**` →
   redirect `/login?next=...`.
3. `/login` page: phone (E.164, reuse `lib/validation.ts` if it has a phone validator;
   else add one there with a test), `signInWithOtp({ phone })`, then `verifyOtp`.
   Error states: wrong code, expired, rate-limited — each with a visible message
   (`lib/form-error.ts` pattern).
4. Role gate exactly as OUTPUTS describes. Write it server-side (`/portal` layout reads
   session via server client) — not client-only.
5. `/portal` shell page on design tokens.
6. CSP addition. Env example file.
7. Tests: Vitest for the role-gate helper (student passes, trainer/admin/missing role
   rejected) using a mocked session object. Playwright: `/portal` unauthenticated →
   redirected to `/login` (no real OTP in CI).

## VALIDATION
- Standard block + new tests green.
- Manual (requires real env + a test student account): full OTP round-trip, non-student
  rejection, session survives reload, logout works. Record results in STATUS —
  IF no test account/env available: mark "manual auth QA pending owner env", do NOT
  fake the result, continue to 13 (13's validation repeats this gate).

## IF VALIDATION FAILS
- OTP not arriving → Supabase project SMS provider config is an OWNER task; STATUS-note,
  placeholder-block manual QA, continue with automated tests green.
- CSP blocks requests → add the exact supabase host to connect-src; never widen to `*`.

## CHECKPOINT
Commit: `feat(rebuild): 12 student login — supabase ssr auth, role-gated portal`

## STOP CONDITION
Automated validation green. Auto-continue to 13 (same phase).

## NEXT
`13_FLUTTER_WEB.md`

## AMENDMENT (executed 2026-07-10)
- `website/.env.example` doesn't exist in this repo — the real convention is
  `website/.env.local.example` (already existed, pre-dating this task).
  Documented `NEXT_PUBLIC_SUPABASE_URL`/`NEXT_PUBLIC_SUPABASE_ANON_KEY` there
  instead of creating a differently-named duplicate.
- `lib/validation.ts` had no phone validator — added `isE164Phone` there with
  tests, exactly as this file's own Step 3 allows ("reuse `lib/validation.ts`
  if it has a phone validator; else add one there with a test").
- Also touched `e2e/portal.spec.ts` (new, not in FILES ALLOWED) — same
  recurring class as IN-001..008.
- Found: this environment's `website/.env.local` has no
  `NEXT_PUBLIC_SUPABASE_URL`/`_ANON_KEY` set (real values are the owner's to
  provide). Made both `middleware.ts` and `/portal` fail closed (treat
  missing-env / a thrown auth check identically to "no session" → redirect
  to `/login`) instead of crashing — see E-011. This made the required
  Playwright coverage ("`/portal` unauthenticated → redirected to `/login`")
  actually true and testable without real credentials, rather than skipping
  it. Manual OTP QA (real phone round-trip, non-student rejection, session-
  survives-reload, logout) is marked **pending owner env** per this file's
  own VALIDATION clause — not faked, not skipped, continuing to 13.

## AMENDMENT (2026-07-15 — phone OTP removed)
Owner directive: "REMOVE PHONE OTP SYSTEM". The Supabase project has no SMS
provider and won't get one. `/login` is now email+password
(`signInWithPassword`) — same accounts as the app's email sign-in. `isE164Phone`
deleted from `lib/validation.ts` (login was its only consumer). Flutter app's
"Continue with Phone" option, OTP screen/route/states, and the
`auth_enable_phone` Remote Config flag removed in the same commit; optional
phone number on sign-up remains (profile data, not auth). Portal login
round-trip and trainer/not-student bounce verified live against production
Supabase with seeded test users.
