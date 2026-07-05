# 11 — DevOps Report

**Round 2 update (2026-07-05, post-merge):** the CI/CD picture described below has materially changed since first written. The repository is now **public**, which removed the Actions-minutes constraint that originally justified pulling CodeQL off `pull_request`; CodeQL is back on every PR and verified uploading successfully (`CODEQL_VERIFICATION.md`). `main` now has **branch protection** requiring 8 checks (`BRANCH_PROTECTION_PLAN.md`) and **auto-merge is enabled, squash-only** (`GITHUB_CONFIGURATION_REPORT.md`). Every workflow now has a `concurrency` group; `codeql-flutter.yml` gained Gradle caching, cutting its run time from 24-59 minutes to ~6-9 minutes in verified live runs. The release-please fix below **was confirmed end-to-end** — PR #20 merged cleanly through the new pipeline. Full detail in the five CI-optimization/public-repo docs added this round: `CI_OPTIMIZATION_REPORT.md`, `CODEQL_STRATEGY.md`, `GITHUB_ACTIONS_USAGE_REPORT.md`, `SELF_HOSTED_RUNNER_SETUP.md` (prepared, not activated), `WORKFLOW_CHANGELOG.md`, `CI_STRATEGY.md`, `SECURITY_COVERAGE.md`, `ACTIONS_MINUTES_OPTIMIZATION.md`, `PUBLIC_REPOSITORY_SECURITY_AUDIT.md`, `GITHUB_CONFIGURATION_REPORT.md`, `BRANCH_PROTECTION_PLAN.md`, `CODEQL_VERIFICATION.md`.

## Git hygiene

- Clean working tree at audit start; this session's work was done on a dedicated branch (`audit/full-review-loving-einstein` — the originally-planned `audit/full-review` name was already in use by an unrelated worktree, so a collision-free name was chosen instead).
- Commit history (prior to this session) shows a healthy pattern: feature merges via PR, a dedicated post-merge CI-fixes PR (#19), and formatting-only commits kept separate from logic changes (`4fa771c style: apply dart format`) — good separation of concerns already in practice.
- Two commits made this session, one concern each, both with verification evidence in the message: `1cb10cf` (pgTAP test fix) and `706a2b2` (CI config fix).

## CI/CD workflows (`.github/workflows/`, 10 files)

| Workflow | Purpose | Current status (round 2, verified live on PR #20) |
|---|---|---|
| `flutter.yml` | Flutter analyze/test | Passes on every PR; `Flutter Analyze` ~53s, `Flutter Tests` ~1m15s-2m24s |
| `website.yml` | ESLint/tsc, build, vitest (3 parallel jobs) | Passes on every PR; each job well under 2 minutes |
| `codeql-flutter.yml`, `codeql-website.yml` | Security static analysis | **Re-enabled on `pull_request`** (repo is now public — Actions minutes unlimited, Advanced Security free). Both verified uploading successfully to the Security tab; 0 findings. Flutter job now ~6-9 min (was 24-59 min pre-caching) |
| `pgtap.yml` | Database test suite | Passes on every PR, 188/188 assertions, ~2-3 minutes |
| `supabase-deploy.yml` | Migration deployment | Unchanged, `main`-only, gated on secrets being present |
| `release-flutter.yml`, `release-website.yml` | Automated versioned releases | **Confirmed fixed end-to-end** — PR #20 merged clean through the full required-checks pipeline, no repeat of the prior "every run fails in 10-18s" failure |
| `size-label.yml`, `stale.yml`, `dependabot.yml`, `labeler.yml` | PR hygiene automation | `size-label.yml` fixed this round (was also broken on every run — see `WORKFLOW_CHANGELOG.md`); others unchanged |

All ten workflow files now have a `concurrency` group (six previously lacked one); all confirmed `ubuntu-latest`-only (no Windows/macOS runners anywhere).

## Release-please fix (this session)

**Root cause:** both release workflows passed `release-type`, `path`, `package-name`, and `changelog-types` as direct scalar inputs to `googleapis/release-please-action@v4` — this was valid in v3 but v4 requires manifest-style JSON configuration instead (confirmed against current `googleapis/release-please-action` and `release-please` documentation via Context7, not assumed from training data).

**Fix:** added `release-please-config.json` + `.release-please-manifest.json` per surface (`flutter-app/`, `website/`), each declaring its package under a `packages` map keyed by its repo-root-relative path, carrying over the same custom changelog sections (renamed from `changelog-types` to the current `changelog-sections` key) and `package-name` values. Updated both workflows to reference `config-file`/`manifest-file` instead of the old scalar inputs. Because the release path is no longer the repo root, action outputs are now path-prefixed (`steps.release.outputs['flutter-app--release_created']` etc.) — the downstream AAB-build-and-upload steps in `release-flutter.yml` were updated to match.

**Verification performed:** JSON syntax validated (`node -e "JSON.parse(...)"`), YAML syntax validated (`js-yaml` parse) for both workflow files. **Round 2: confirmed end-to-end** — PR #20 merged to `main` cleanly through this pipeline; watch the next Conventional-Commit push to `main` to confirm a release PR is actually opened (release-please itself hasn't fired yet, since that's triggered by qualifying commit types on `main`, not by this merge alone).

## Branch protection & auto-merge (new, round 2)

- `main` now requires 8 status checks before merge (`Flutter Analyze`, `Flutter Tests`, `ESLint & TypeScript Check`, `Next.js Build`, `Vitest Unit Tests`, `pgTAP Database Tests`, both CodeQL scans) — strict mode (branch must be up to date), no force-push/deletion, conversation resolution required. Full ruleset and rationale in `docs/BRANCH_PROTECTION_PLAN.md`.
- Auto-merge enabled repo-wide, restricted to squash-merge only, branch auto-delete on merge.
- **This closes the "every check here is advisory" gap** flagged in this report's first version — previously true because the repo was private on the free plan (branch protection unavailable at that tier). Now enforced.

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

1. ~~Confirm the release-please fix works end-to-end~~ — done, PR #20 merged clean. Watch for the first actual release PR on the next qualifying commit to `main`.
2. Consider adding a lightweight error-tracking integration (Sentry or similar) for the website's API routes, since `console.error` alone won't proactively alert anyone.
3. Document a rollback procedure (even a short one) for both the website and mobile app releases.
4. **(New, round 2)** Enable Dependabot's automated fix PRs to actually get reviewed/merged — 21 alerts are now tracked (1 critical, 7 high, 11 moderate, 2 low), and enabling the alert feed without a habit of reviewing its PRs just produces a growing backlog. See `PUBLIC_REPOSITORY_SECURITY_AUDIT.md`.
5. **(New, round 2)** Revisit `enforce_admins: false` on branch protection if a second maintainer joins this project — currently fine for a single-maintainer repo, but worth reconsidering once bypass-by-anyone stops being pure convenience.
