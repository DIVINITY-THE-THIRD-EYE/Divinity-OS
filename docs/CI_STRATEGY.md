# CI Strategy — What Runs When, and Why

A single reference for the whole CI pipeline's trigger design after this session's optimization work, answering: **do the checks that still run on every PR actually catch what they need to?**

## PR-triggered checks (run on every push to an open PR against `main`)

| Concern | Workflow / job | Confirmed still triggers on `pull_request`? |
|---|---|---|
| Build failures (website) | `website.yml` → `Next.js Build` | Yes |
| Build failures (mobile) | `flutter.yml` → `Flutter Analyze` (catches compile-level issues via `flutter analyze --fatal-infos`) | Yes |
| Lint issues (website) | `website.yml` → `ESLint & TypeScript Check` (`npm run lint`) | Yes |
| Type errors (website) | `website.yml` → `ESLint & TypeScript Check` (`npx tsc --noEmit`, same job) | Yes |
| Flutter static analysis | `flutter.yml` → `Flutter Analyze` (`flutter analyze --fatal-infos`, plus `dart format --set-exit-if-changed`) | Yes |
| Failing tests (website) | `website.yml` → `Vitest Unit Tests` (`npm test`) | Yes |
| Failing tests (mobile) | `flutter.yml` → `Flutter Tests` (`flutter test --coverage`) | Yes |
| Database regressions | `pgtap.yml` → `pgTAP Database Tests` (`supabase test db`, 188 assertions) | Yes |
| PR size labeling | `size-label.yml` | Yes (housekeeping, not a correctness gate) |

**Every category asked about — build, lint, type, Flutter analysis, tests, database — still has a PR-triggered check, unchanged by this session's optimization work.** The only thing removed from the PR path was CodeQL (see `docs/SECURITY_COVERAGE.md` for why that specific removal doesn't leave the gap it might sound like).

**Not PR-triggered (by original design, unchanged):** `Android Release Build` (only runs on push to `main` — building a signed release App Bundle on every PR would be pure waste, it's not a correctness check PRs need), `supabase-deploy.yml` (production migration deploy, `main`-only by design — deploying migrations from an unmerged PR would be actively wrong), both release-please workflows (metadata/versioning, `main`-only by design).

## Push-to-`main`-only checks

- `Android Release Build` (`flutter.yml`) — builds the signed release bundle once code has actually landed on `main`.
- `Supabase Deploy` (`supabase-deploy.yml`) — pushes migrations/Edge Functions to production. Gated further by a runtime check for `SUPABASE_ACCESS_TOKEN`/`SUPABASE_PROJECT_REF` secrets; skips cleanly if unset.
- Both CodeQL workflows (as of this session) — see `docs/CODEQL_STRATEGY.md`.
- Both release-please workflows — open/update a release PR when Conventional Commits land on `main`.

## Schedule-only / on-demand checks

- CodeQL (weekly + `workflow_dispatch`) — see `docs/CODEQL_STRATEGY.md` and `docs/SECURITY_COVERAGE.md`.
- `stale.yml` (daily) — issue/PR housekeeping, not a correctness or security gate.

## Enforcement reality check (this matters more than the trigger design)

**None of the above is a hard merge gate.** `gh api repos/DIVINITY-THE-THIRD-EYE/Divinity-OS/branches/main/protection` returns *"Upgrade to GitHub Pro or make this repository public to enable this feature"* — branch protection, and therefore required status checks, is unavailable on this private repo at its current plan tier. Every single check discussed in this document — including the ones that were never touched by this session's work (Flutter Tests, pgTAP, ESLint) — is advisory. A PR can be merged with any or all of them red, or before they've even finished running. **This was true before this session's changes and remains true after them; it is not something the CI-optimization work introduced or could fix from workflow files alone.**

This means the actual safety net for this repository is: someone looks at the PR checks list before clicking merge. That's a process/discipline matter, not a configuration one — and it applies uniformly to every check on this page, not specifically to the CodeQL trigger change under review.

## Alignment with GitHub's recommended practice

**Partially, with an important caveat spelled out rather than glossed over:**

- **Concurrency groups, dependency caching, path filters, and query-suite scoping** — these are standard, widely-documented GitHub Actions cost-reduction levers and align cleanly with common practice for any repo trying to control Actions-minute spend.
- **Removing CodeQL from `pull_request`** — checked directly against GitHub's own CodeQL setup documentation (via live fetch during this review, not assumed from training data): GitHub's default guidance actually *favors* running CodeQL on pull requests, specifically so findings can block a merge before it happens. That guidance implicitly assumes Advanced Security + branch protection are in place to make that blocking possible. **This repository has neither**, which is exactly why removing the PR trigger doesn't cost as much here as it would on a repo where those enforcement mechanisms exist. This is a deliberate, reasoned deviation made necessary by a real resource constraint (an exhausted free Actions-minutes quota), not an implementation of GitHub's ideal-case recommendation — and it should be revisited if this repo ever gains Advanced Security + branch protection (e.g. via a plan upgrade), at which point restoring the `pull_request` trigger would become genuinely valuable again in a way it currently isn't.
