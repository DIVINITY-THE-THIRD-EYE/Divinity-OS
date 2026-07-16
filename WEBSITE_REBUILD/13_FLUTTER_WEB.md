# 13 — FLUTTER WEB (app inside the student portal)

## PURPOSE
After login, the student uses the existing Flutter app on the web, feeling like part of
the site. No duplicated business logic (D004).

## APPROACH — two stages, in order (do not skip stage A)

**Stage A — build + link-out (must ship first):**
Flutter Web build deployed at its own path/subdomain; the portal dashboard links to it.
Same Supabase account; the Flutter web app performs its own session (its existing auth
flow works on web). Simple, zero coupling, always the fallback.

**Stage B — embedded experience (only after A works):**
Portal page embeds the Flutter Web app in an `<iframe>` styled full-height under the
site nav, with a token handoff so the student does NOT log in twice.

## SECURITY NOTES (normal prose — follow exactly)
- Token handoff (Stage B): pass the CURRENT session's access+refresh tokens from the
  parent page to the iframe via `postMessage` with an EXACT `targetOrigin` (never `*`),
  after the iframe signals ready. The Flutter side calls its existing Supabase
  `setSession(access, refresh)`. Never put tokens in URL query strings (they leak into
  logs/history). URL fragment is acceptable only as a documented fallback if postMessage
  proves unworkable — fragment is cleared immediately after read.
- iframe gets `sandbox="allow-scripts allow-same-origin allow-forms allow-popups"` and the
  site CSP gains `frame-src` for the app origin only.
- The Flutter app keeps enforcing everything through RLS — the website adds no privileges.

## INPUTS
- `12_STUDENT_LOGIN.md` COMPLETE.
- `flutter-app/web/` exists (verified in repo). Flutter SDK available on the build machine —
  IF NOT: Stage A becomes "document build command + CI job spec", STATUS-note
  "flutter web build pending environment", portal shows "app coming soon" card, continue.

## STEPS — Stage A
1. Confirm web target: `cd flutter-app && flutter build web --release --dart-define-from-file=dart_defines.json`.
   Build errors that are web-incompatibility (e.g. a plugin without web support) →
   record the exact plugin list in STATUS; wrap those features with `kIsWeb` guards ONLY
   if the guard is trivial (<10 lines); otherwise STATUS-note as app-team work and
   continue with whatever builds (login + core screens may be enough for v1).
2. Decide hosting path (record in DECISIONS): `app.<domain>` subdomain (preferred,
   clean origin for CSP) or `/app` static hosting. Vercel: separate project or static
   output copied — document the chosen deploy step in `18_DEPLOYMENT.md` addendum.
3. Portal dashboard card: "Open the Academy App" → link (new tab). Add the
   "Student Login" link to `Nav.tsx` now (dark-launch ends here). Ship.

## STEPS — Stage B
4. `app/(portal)/portal/app/page.tsx`: full-height iframe to the Stage-A URL, loading
   skeleton, error state (app origin unreachable → Stage-A link fallback).
5. Handshake: iframe posts `{type:"DIVINITY_APP_READY"}` → parent responds
   `{type:"DIVINITY_SESSION", access_token, refresh_token}` with exact targetOrigin.
   Flutter side: small web-only bootstrap listening for the message before showing its
   own login (falls back to own login after 3s timeout — the app must never dead-end).
   Flutter changes live in `flutter-app/lib/` behind `kIsWeb` — this is the ONLY task
   allowed to touch flutter-app, keep the diff minimal and additive.
6. CSP `frame-src` + `postMessage` origin constants from ONE config place
   (`content/site.ts` → `appOrigin`).

## FILES ALLOWED
`website/app/(portal)/**` · `website/components/Nav.tsx` (login link) ·
`next.config.mjs` (frame-src) · `content/site.ts` (appOrigin) ·
`flutter-app/lib/**` (Stage B bootstrap ONLY, `kIsWeb`-guarded, minimal) ·
`flutter-app/web/**` · STATUS/CHANGELOG/DECISIONS.

## FILES FORBIDDEN
`supabase/**` · website api routes · everything else.

## VALIDATION
- Stage A: flutter web build succeeds (or documented environment block), portal link opens app, student can log in there with the same account.
- Stage B: embedded app receives session (no second login), timeout fallback shows app's
  own login, wrong-origin message ignored (test with a manual postMessage from console).
- Website standard block still green; `flutter test` still green if flutter-app touched.

## IF VALIDATION FAILS
Stage B failing ≠ project blocked: ship Stage A, STATUS-note B as pending, continue.

## CHECKPOINT
Commits: `feat(rebuild): 13a flutter web link-out` · `feat(rebuild): 13b embedded session handoff`

## STOP CONDITION
Phase 6 gate. Gate report (state exactly which stage shipped) + rebase → auto-continue (D011).

## NEXT
`14_SEO.md`

## AMENDMENT (executed 2026-07-10)
Flutter SDK is NOT available in this environment (`flutter` not on PATH) —
exactly the condition this file's own INPUTS section pre-approves a fallback
for. `flutter-app/web/` does exist (real scaffold: `index.html`, `icons/`,
`manifest.json`) — it has just never been built here.

What shipped (Stage A, partial — the part that doesn't need a Flutter
build):
- `components/Nav.tsx`: added a "Student Login" link (`/login`) to both the
  desktop and mobile menus — dark-launch ends here, exactly as Step 3 asks,
  verified via a new Playwright test (`e2e/portal.spec.ts`: "Nav exposes a
  Student Login link that opens /login").
- Hosting-path decision (Step 2): no new decision needed — `PLACEHOLDERS.md`
  BD-002 already recorded the safe default (path-based `/app` hosting until
  the owner grants DNS for an `app.<domain>` subdomain), made *before* this
  task, during the playbook-evolution pass. It still holds; nothing to add.
- `/portal`'s dashboard card (built in 12) already reads as an honest
  "coming soon" placeholder — no fake link to a nonexistent deployment was
  added.

What did NOT ship (documented, not silently skipped):
- The actual `flutter build web --release --dart-define-from-file=
  dart_defines.json` — cannot run without the Flutter SDK. Proposed build
  command + CI job spec (following this repo's existing
  `.github/workflows/release-flutter.yml` conventions —
  `subosito/flutter-action@v2`, `flutter pub get`, then `flutter build web`)
  is written up in STATUS.md for whoever has the SDK, and handed off
  explicitly to `18_DEPLOYMENT.md` (Step 2 there: "Flutter Web artifact:
  build + deploy... Document the exact commands in this file"), since
  `.github/workflows/**` isn't in *this* file's FILES ALLOWED.
  STATUS-noted as "flutter web build pending environment."
- Stage B (embedded iframe + token handoff): correctly gated behind Stage A
  actually shipping a live, reachable Flutter Web URL — this file's own
  APPROACH section says "do not skip stage A." With no build/deploy, there
  is nothing to embed yet; building the iframe/handshake against a URL that
  doesn't exist would be unverifiable, fabricated-looking work. Deferred,
  not attempted.
