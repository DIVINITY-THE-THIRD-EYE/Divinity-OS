# 13 — Roadmap

Ordered by priority. "Files to touch" are starting points, not exhaustive lists.

## Priority 1 — Verify the CI fix landed correctly
- **Approach:** watch the first real push-to-`main` run of `release-flutter.yml`/`release-website.yml` after this session's fix merges; confirm a release PR is actually opened.
- **Files:** none — observation only.
- **Dependencies:** the fix from this session must be merged to `main` first.
- **Risk:** Low. If it still fails, the `config-file`/`manifest-file` paths or the path-prefixed output names are the first things to check.
- **Effort:** S.

## Priority 2 — Re-verify the `payment_screenshots` bucket is private in production
- **Approach:** owner/admin logs into the Supabase dashboard, confirms Storage → payment_screenshots → Settings → "Public bucket" is unchecked. Then, as a follow-up, add an automated check (a small script hitting the Supabase Management API, run on a schedule or as a CI step) that fails loudly if the flag ever flips back to `true`.
- **Files:** a new script (e.g. `scripts/check-bucket-privacy.ts` or similar) + a new scheduled GitHub Action.
- **Dependencies:** requires a Supabase Management API token with read access to storage config.
- **Risk:** Low for the check itself; the underlying exposure (if it exists) is what matters — see [05_Security_Audit.md](05_Security_Audit.md).
- **Effort:** S (the manual check) + S (the automated guard).

## Priority 3 — Next.js dependency upgrade
- **Approach:** in a throwaway branch, `npm install next@latest` (or the latest 14.x patch if a full major bump feels too risky for one pass), then run the complete website gate suite (tsc, lint, vitest, build) plus the not-yet-run Playwright e2e suite, and manually spot-check the site in preview before merging.
- **Files:** `website/package.json`, `website/package-lock.json`, possibly `next.config.mjs` if any config API changed.
- **Dependencies:** none blocking, but should be its own PR, not bundled with feature work.
- **Risk:** Medium — a Next.js major-version bump can have real breaking changes; do not treat this as a drive-by fix.
- **Effort:** M.

## Priority 4 — Website i18n scope decision + expansion
- **Approach:** the owner decides whether "full Hindi+English on all user-facing screens" (the existing decision) should actually mean full page-content translation on the website, or whether the current nav/footer/hero-only scope was always intended to be lighter than the Flutter app's coverage. If expansion is wanted, extend `lib/i18n/translations.ts` and wire `t()` calls through the remaining page components.
- **Files:** `website/lib/i18n/translations.ts`, most `website/app/**/page.tsx` files, `website/components/*`.
- **Dependencies:** a product decision first; this is not purely an engineering call.
- **Risk:** Low technically, but scope creep risk if not bounded up front.
- **Effort:** M–L depending on scope chosen.

## Priority 5 — Testing gaps
- **Approach:** run the Playwright e2e suite for the first time and report results; add coverage-percentage tooling (`flutter test --coverage`, `vitest run --coverage`) to CI; sweep other date-relative pgTAP fixtures for the same day-of-week fragility class as `c17`.
- **Files:** `.github/workflows/website.yml` (add e2e job), `.github/workflows/flutter.yml`/`pgtap.yml` (add coverage reporting), `supabase/tests/*` (fragility sweep).
- **Dependencies:** Playwright browser binaries need provisioning in CI.
- **Risk:** Low.
- **Effort:** S–M.

## Priority 6 — Screenshot-to-text conversion (decision #10)
- **Approach:** this was never fully specified by the owner (exact conversion timing — immediately after verification vs. after N months — was left open). Needs a short scoping conversation before any implementation: what OCR/extraction approach, what triggers the conversion, and what happens to the original image afterward.
- **Files:** likely a new Supabase Edge Function or scheduled job, plus a new column/table for the extracted structured data.
- **Dependencies:** a product decision on the open questions above.
- **Risk:** Low technically; the ambiguity is the real blocker.
- **Effort:** M, once scoped.

## Priority 7 — Observability
- **Approach:** add lightweight server-side error tracking (e.g. Sentry) for the website's API routes, which currently only `console.error`-log; document a short rollback procedure for both website and mobile releases.
- **Files:** `website/app/api/*/route.ts` (error reporting calls), a new `docs/` runbook file.
- **Dependencies:** choice of error-tracking vendor/budget.
- **Risk:** Low.
- **Effort:** S.

## Explicitly deferred (not this roadmap's job to force)

- Owner-account/console items (iOS signing, Play Console/App Store registration, DPDP grievance officer real contact details, production domain finalization) — these are outside engineering's control and were already correctly identified as such in prior project memory; this audit found nothing new to add here.
- Full reconciliation of every `docs/PROJECT_BIBLE/*.md` internal contradiction — already catalogued in a prior session; re-doing that exhaustive pass wasn't in this audit's scope, and the doc-authority order in [03_Feature_Status.md](03_Feature_Status.md) is sufficient to work around it in the meantime.
