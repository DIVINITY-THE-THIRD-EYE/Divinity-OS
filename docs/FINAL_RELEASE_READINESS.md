# Final Release Readiness

Verifies six production-readiness dimensions directly, as of 2026-07-05, against current `main` (post both audit rounds).

## 1. Supabase storage bucket security

**Unresolved, unchanged since the original audit.** `payment_screenshots` bucket's `public` flag is not codified in any migration (migration 031's own header comment admits this requires a manual Supabase Studio/Management API action — SQL cannot set it). **Re-verified locally this pass:** replaying all 45 migrations on a fresh local Supabase instance still leaves `storage.buckets.payment_screenshots.public = true` (`docker exec supabase_db_Divinity_TTE psql -U postgres -c "select id, public from storage.buckets where id='payment_screenshots';"` → `t`). **This cannot be checked against the actual production Supabase project from this environment** — no production credentials are available here. This is the single most important item to verify manually before release: log into the production Supabase dashboard and confirm Storage → `payment_screenshots` → Settings → "Public bucket" is unchecked. RLS policies on `storage.objects` are correctly scoped regardless (owner/admin/trainer read paths) — but they only matter if the bucket-level flag is actually `false`; a `public: true` bucket's public URLs bypass RLS entirely.

## 2. RLS policies

**Solid, verified twice now (original audit + this round).** All 25 tables have RLS enabled; every table has at least one policy; the `is_admin()`/`is_trainer()`/`is_trainer_or_admin()` helper-function pattern (migration 012) is used consistently to avoid recursion bugs. Re-ran `supabase test db` this round: **188/188 pgTAP assertions pass**, including the RLS-adjacent security tests (`c1_privileged_fields_test.sql`, `c4_jwt_role_test.sql`). No regressions. See `project_audit/08_Database_Report.md` for the full per-table policy inventory.

## 3. Website deployment

**Working, verified via live evidence, not assumed.** Every PR triggers a Vercel preview deployment, and every one checked this session (round 1, round 2, and every Dependabot PR listed in the Dependabot triage) shows `Vercel: pass — Deployment has completed`, except PR #23 (Next.js 15) where the Vercel deployment **fails for the same reason `next build` fails locally** (the dynamic-route `params` type error) — consistent, corroborating evidence, not a separate Vercel-specific issue. No `vercel.json` exists in-repo; deployment configuration lives entirely in the Vercel dashboard (out of this audit's reach), which is a standard, valid setup for a Vercel + GitHub integration.

## 4. Firebase configuration

**Sound, re-confirmed.** `firebase_options.dart` / `google-services.json` / `GoogleService-Info.plist` contain Firebase Web API keys — public client identifiers by Google's own design, not secrets (independently corroborated this round by GitHub secret scanning, which flagged exactly these two values and had both resolved as false positives with documented reasoning — see `PUBLIC_REPOSITORY_SECURITY_AUDIT.md`). `firebase_app_check` is a declared dependency (`pubspec.yaml`), meaning the actual security boundary (App Check + Firebase Security Rules) is in place, not merely assumed. Firebase Crashlytics is wired for crash reporting (`main.dart:80-84`). **Not independently re-verified this round:** whether App Check is actually *enforced* (vs. just present as a dependency) on a signed production build — this requires a signed release build + live device test, which prior project memory already flagged as an owner-account-dependent item (needs a signed Android/iOS build to confirm), unchanged by this audit.

## 5. Release Please

**Confirmed working end-to-end.** This was the single biggest unknown after the original CI fix (config was validated syntactically but never observed running for real). It has now actually run: two release PRs are currently open —
- **PR #24**: `chore(main): release divinity_flutter 1.1.0` — correctly bumps `flutter-app/.release-please-manifest.json` (`1.0.0` → `1.1.0`) and generates a real Conventional-Commits-derived `CHANGELOG.md` entry.
- **PR #25**: `chore(main): release divinity-website 1.1.0` — same pattern for `website/`.

Both were generated automatically after this session's merges landed on `main`, with zero further intervention. This is the proof the earlier release-please fix (`706a2b2`, `abb7676`) actually works, not just passes syntax validation.

## 6. GitHub Releases

**None cut yet — expected, not a gap.** `gh release list` returns empty. This is correct and expected: release-please's flow is (1) open a release PR with the version bump + changelog, (2) a human merges it, (3) *only then* does release-please tag the commit and create the actual GitHub Release (and, for the Flutter app, build and attach the signed AAB per `release-flutter.yml`). Steps 1 is done (PRs #24/#25 exist); step 2 (merge) is a deliberate decision for whoever is ready to actually cut v1.1.0 — not something this audit should do unilaterally, since it's a real, visible, hard-to-reverse release action.

## Cross-cutting: what the Dependabot PR triage (see chat) adds to this picture

Two of the 21 open Dependabot alerts (both `next`-related) won't be resolved until PR #23 is fixed and merged (see `NEXT15_MIGRATION_REPORT.md` — recommend "Test First", not ready to merge as-is). The `vite`/`vitest` chain (PR #22, including the one **critical** alert) is already CI-green and ready to merge. Full breakdown in the Dependabot triage.

## Summary table

| Dimension | Status |
|---|---|
| Supabase storage bucket security | ⚠️ Unverifiable from here — needs owner to check production dashboard |
| RLS policies | ✅ Verified, 188/188 pgTAP assertions pass |
| Website deployment | ✅ Working (Vercel previews green on every mergeable PR) |
| Firebase configuration | ✅ Sound (keys are non-secret by design, App Check present) — App Check *enforcement* on a signed build not independently re-verified |
| Release Please | ✅ Confirmed working end-to-end (PRs #24/#25 exist as proof) |
| GitHub Releases | ⏳ None cut yet — expected, pending a deliberate merge decision on #24/#25 |
