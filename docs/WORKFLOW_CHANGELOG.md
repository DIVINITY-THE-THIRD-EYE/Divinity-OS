# Workflow Changelog

Chronological record of every `.github/workflows/*.yml` change made across this audit/CI-optimization session, for traceability. Each entry names the file, what changed, and why — see the cross-referenced doc for full reasoning.

## `supabase/tests/c17_leave_business_rules_test.sql`
- Fixed a day-of-week-dependent test fragility (not a workflow file, but the fix that made `pgtap.yml` reliable again). See `project_audit/04_Bug_Report.md`.

## `release-flutter.yml`, `release-website.yml`
- **First pass:** migrated from `release-please-action@v3`-era scalar inputs (`release-type`, `path`, `package-name`, `changelog-types`) to v4's manifest-config format (`config-file`/`manifest-file` + new `flutter-app/release-please-config.json`, `flutter-app/.release-please-manifest.json`, `website/release-please-config.json`, `website/.release-please-manifest.json`). Fixed a workflow that had failed on every single run since introduction. See `project_audit/14_Critical_Fixes.md`.
- **This pass:** added a `concurrency` block (`cancel-in-progress: false` — a release build must not be canceled mid-way).

## `size-label.yml`
- **First pass:** fixed `pascalgn/size-label-action@v0.5.4` config — the workflow was passing v3-era `labels`/`fail_if_xl`/`message_if_xl` inputs this version doesn't accept, and had the `sizes` map's keys/values backwards. Corrected to the action's real contract (ascending numeric thresholds → bare size names) and created the five missing `size/*` GitHub labels the repo didn't have yet.
- **This pass:** added a `concurrency` block.

## `codeql-website.yml`
- **First pass:** added `upload: never` + `output: codeql-results` + an `actions/upload-artifact` step, since this private repo doesn't have GitHub Advanced Security (Code scanning) enabled and the default `upload: always` failed every run trying to upload SARIF results nowhere could receive them. See `docs/CODEQL_ADVANCED_SECURITY.md`.
- **This pass:**
  - Removed the `pull_request` trigger entirely; kept `push` (main/feature branches), weekly `schedule`, added `workflow_dispatch`. See `docs/CODEQL_STRATEGY.md`.
  - Added a `concurrency` block.
  - `queries: security-and-quality` → `queries: security-extended` (drops non-security quality queries only).
  - `runs-on: ubuntu-latest` → `runs-on: ${{ vars.CODEQL_RUNNER_LABEL || 'ubuntu-latest' }}` (self-hosted prep, no behavior change — see `docs/SELF_HOSTED_RUNNER_SETUP.md`).

## `codeql-flutter.yml`
- **First pass:** same `upload: never` fix as `codeql-website.yml`.
- **This pass:**
  - Same trigger scope-down, concurrency, `security-extended` switch, and `runs-on` parameterization as `codeql-website.yml`.
  - Added a Gradle dependency/wrapper cache step (`actions/cache@v4` on `~/.gradle/caches` and `~/.gradle/wrapper`, keyed on the Android Gradle config files) — the debug-APK build step this job depends on was re-downloading the entire Gradle/Android dependency graph from scratch on every run.

## Files unchanged (audited, no issue found)

- `flutter.yml` — already had concurrency, Flutter SDK+pub-cache caching, and `ubuntu-latest`-only runners.
- `website.yml` — already had concurrency and npm caching.
- `pgtap.yml` — already had concurrency; no further caching opportunity was found worth the added complexity (see `docs/CI_OPTIMIZATION_REPORT.md`).
- `supabase-deploy.yml` — already had a serialized (`cancel-in-progress: false`) concurrency group appropriate for a deploy workflow.

## New files added this session

- `docs/CODEQL_ADVANCED_SECURITY.md` — what the `upload: never` fix trades off.
- `docs/CODEQL_STRATEGY.md` — trigger and query-suite rationale.
- `docs/SELF_HOSTED_RUNNER_SETUP.md` — self-hosted runner prep, not activated.
- `docs/GITHUB_ACTIONS_USAGE_REPORT.md` — the billing-quota root-cause evidence.
- `docs/CI_OPTIMIZATION_REPORT.md` — full before/after audit and minute estimate.
- `docs/WORKFLOW_CHANGELOG.md` — this file.
- `flutter-app/release-please-config.json`, `flutter-app/.release-please-manifest.json`, `website/release-please-config.json`, `website/.release-please-manifest.json` — release-please v4 manifest config (from the earlier release-please fix, listed here for completeness).
