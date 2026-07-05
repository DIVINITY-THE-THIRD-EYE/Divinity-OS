# CodeQL Strategy

This documents the current trigger and query-suite configuration for both CodeQL workflows (`codeql-flutter.yml`, `codeql-website.yml`) and the reasoning behind it, so a future change to either isn't made without understanding what it costs.

## Why CodeQL no longer runs on every pull request

Both workflows previously triggered on `push`, `pull_request`, and a weekly `schedule`. In practice, the Flutter CodeQL job alone (Flutter debug APK build + Java/Kotlin CodeQL analysis) took **25-40+ minutes per run** and had started failing mid-analysis with a runner-shutdown signal once this account's free 2,000 Actions-minutes/month allowance was exhausted (see `docs/GITHUB_ACTIONS_USAGE_REPORT.md`). Running that on every single PR push (including every additional commit to an open PR, before `concurrency: cancel-in-progress` could even help) was the single largest driver of that usage.

**Current triggers (both workflows):**
```yaml
on:
  push:
    branches: [main, feature/trust-certificates]
    paths: [ ... ]
  schedule:
    - cron: '30 20 * * 6'   # weekly, Sunday 2 AM IST
  workflow_dispatch:
```

- **`push` to `main`/`feature/trust-certificates`** — every real merge/direct push to a long-lived branch still gets scanned.
- **Weekly schedule** — catches anything that slipped through (e.g. a dependency-only change with no direct push trigger) at a predictable, bounded cost of one run per week instead of one per PR-push.
- **`workflow_dispatch`** — this is the escape hatch for "a security-related PR explicitly requires it." From the Actions tab, either workflow can be manually run against any branch, including an open PR's branch, by picking that branch/ref in the "Run workflow" dropdown. No code change or label automation was built for this — `workflow_dispatch` already covers the need with zero added complexity, and it's discoverable by anyone with write access to the repo.

**What this trades away:** a PR that introduces a new CodeQL-detectable issue won't get an automatic scan-and-annotate before merge — it'll be caught on the next push to `main` (or the next weekly run, or a manual dispatch) instead of pre-merge. Given this repo also has `flutter analyze`, ESLint/tsc, and a full test suite gating every PR already, CodeQL was one layer of several, not the only one — this narrows *when* that particular layer runs, it doesn't remove it.

## Why `security-extended` instead of `security-and-quality`

**No security coverage was removed.** `security-extended` is a standard, GitHub-maintained CodeQL query suite that is a strict superset of the default suite's security queries. `security-and-quality` = `security-extended` **plus** a large set of pure code-style/maintainability queries that have nothing to do with vulnerabilities — naming conventions, dead code, "confusing method names," chained `instanceof`, and similar. Those are legitimate code-quality checks, but they are not security findings, and they were responsible for a large fraction of the 244 total queries the Flutter job was running (visible directly in the job logs as `Violations of Best Practice/Naming Conventions/...`, `Language Abuse/...`, etc.).

Dropping to `security-extended`:
- Keeps every actual vulnerability-class query in place.
- Meaningfully reduces query count and evaluation time, which is exactly the axis this account is constrained on (Actions minutes), not query coverage.
- Is the same tradeoff GitHub's own documentation recommends when `security-and-quality`'s runtime is a problem and code-quality linting is already handled elsewhere (this repo already has `flutter analyze --fatal-infos` and ESLint doing exactly that job).

If code-quality-via-CodeQL is wanted back later, switch `queries: security-extended` back to `queries: security-and-quality` in both workflow files — that's the only line that needs to change, and `docs/CI_OPTIMIZATION_REPORT.md` records the before/after minute estimate for that tradeoff.

## Re-enabling PR-triggered CodeQL for a specific case

If a specific PR genuinely needs a pre-merge CodeQL pass (e.g. it touches authentication, payment verification, or RLS-adjacent code):

1. Go to the **Actions** tab → select **CodeQL Security Scan (Flutter/Android)** or **CodeQL Security Scan (Website)**.
2. Click **Run workflow**, choose the PR's branch, and run it.
3. Results land as a downloadable artifact (`codeql-results-flutter` / `codeql-results-website`) on that run — see `docs/CODEQL_ADVANCED_SECURITY.md` for how to read them (SARIF viewer, since this repo doesn't have the GitHub Security tab enabled).

This is a manual, per-PR judgment call by whoever is reviewing — it is intentionally not automatic, to keep the default cost bounded.
