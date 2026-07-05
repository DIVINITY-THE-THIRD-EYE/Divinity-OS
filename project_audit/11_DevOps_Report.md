# 11 — DevOps Report

## Git hygiene

- Clean working tree at audit start; this session's work was done on a dedicated branch (`audit/full-review-loving-einstein` — the originally-planned `audit/full-review` name was already in use by an unrelated worktree, so a collision-free name was chosen instead).
- Commit history (prior to this session) shows a healthy pattern: feature merges via PR, a dedicated post-merge CI-fixes PR (#19), and formatting-only commits kept separate from logic changes (`4fa771c style: apply dart format`) — good separation of concerns already in practice.
- Two commits made this session, one concern each, both with verification evidence in the message: `1cb10cf` (pgTAP test fix) and `706a2b2` (CI config fix).

## CI/CD workflows (`.github/workflows/`, 8 files)

| Workflow | Purpose | Status this session |
|---|---|---|
| `flutter.yml` | Flutter analyze/test | Not separately re-run as a workflow this session, but the underlying commands were run manually and pass (see [10_Testing_Report.md](10_Testing_Report.md)) |
| `website.yml` | ESLint/tsc, build, vitest (3 parallel jobs) | Commands run manually, all pass |
| `codeql-flutter.yml`, `codeql-website.yml` | Security static analysis | Not run this session (requires GitHub-hosted execution) |
| `pgtap.yml` | Database test suite | Underlying `supabase test db` run manually and passes (188/188, post-fix) |
| `supabase-deploy.yml` | Migration deployment | Not exercised this session (would touch production) |
| `release-flutter.yml`, `release-website.yml` | Automated versioned releases | **Was broken on every run since 2026-07-01** (confirmed via `gh run list` — every single run failed in ~10-18 seconds). **Fixed this session** — see below. |
| `size-label.yml`, `stale.yml`, `dependabot.yml`, `labeler.yml` | PR hygiene automation | Not exercised this session |

## Release-please fix (this session)

**Root cause:** both release workflows passed `release-type`, `path`, `package-name`, and `changelog-types` as direct scalar inputs to `googleapis/release-please-action@v4` — this was valid in v3 but v4 requires manifest-style JSON configuration instead (confirmed against current `googleapis/release-please-action` and `release-please` documentation via Context7, not assumed from training data).

**Fix:** added `release-please-config.json` + `.release-please-manifest.json` per surface (`flutter-app/`, `website/`), each declaring its package under a `packages` map keyed by its repo-root-relative path, carrying over the same custom changelog sections (renamed from `changelog-types` to the current `changelog-sections` key) and `package-name` values. Updated both workflows to reference `config-file`/`manifest-file` instead of the old scalar inputs. Because the release path is no longer the repo root, action outputs are now path-prefixed (`steps.release.outputs['flutter-app--release_created']` etc.) — the downstream AAB-build-and-upload steps in `release-flutter.yml` were updated to match.

**Verification performed:** JSON syntax validated (`node -e "JSON.parse(...)"`), YAML syntax validated (`js-yaml` parse) for both workflow files. **Not verified end-to-end** — that would require an actual push to `main` to trigger the real workflow run, which is outside this session's authorized scope (no push was made). **Recommendation:** watch the first real run on `main` after this fix merges, and confirm a release PR is actually created.

## Deploy configuration

- Website: no `vercel.json` in-repo; `website.yml` CI does lint/build/test only, with no deploy step — deployment is presumably handled by Vercel's own GitHub integration (auto-deploy on push), which is a standard, valid pattern, but means deploy configuration lives outside this repo entirely (in the Vercel dashboard) and wasn't inspectable this session.
- Supabase: `supabase-deploy.yml` exists for migration deployment; not exercised this session (would apply migrations to production).
- Android: keystore + `key.properties` referenced via GitHub Secrets (`ANDROID_KEYSTORE_BASE64`, `ANDROID_STORE_PASSWORD`, etc.) in `release-flutter.yml` — per prior verified memory, these secrets are confirmed set. Not re-verified this session (would require GitHub API access to secret metadata, which doesn't reveal values but wasn't checked).

## Versioning & rollback

- `release-please` (once its first real run is confirmed) handles semantic versioning + changelog generation automatically from Conventional Commits.
- No explicit rollback runbook was found in the repo for either the website (Vercel) or the Flutter app (Play Store/App Store) — rollback would rely on each platform's native "redeploy previous version" capability, not a documented in-repo procedure.

## Monitoring / crash reporting

- Firebase Crashlytics is wired in the Flutter app (`main.dart:80-84`, catching both Flutter framework errors and async errors) — this is real crash reporting, not just declared as a dependency.
- No equivalent server-side error tracking (e.g. Sentry) was found for the website's API routes — errors are currently only `console.error`-logged (visible in Vercel's function logs, but not aggregated/alerted).
- No dedicated uptime/synthetic monitoring was found for either the website or the Supabase project in this repo (may exist in Vercel/Supabase dashboards outside the repo — not inspectable from here).

## DevOps recommendations

1. Confirm the release-please fix works end-to-end on the next real push to `main`.
2. Consider adding a lightweight error-tracking integration (Sentry or similar) for the website's API routes, since `console.error` alone won't proactively alert anyone.
3. Document a rollback procedure (even a short one) for both the website and mobile app releases.
