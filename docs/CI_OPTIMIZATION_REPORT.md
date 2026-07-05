# CI Optimization Report

Objectives (as given): keep the repository private, avoid increasing GitHub spending, maintain production-grade CI quality, minimize Actions-minute consumption. No paid GitHub feature was enabled and the repository was not made public.

## Audit summary — every workflow

| Workflow | Had concurrency? | Caching? | Runners | Change made |
|---|---|---|---|---|
| `flutter.yml` | Yes (already) | Flutter SDK + pub-cache via `cache: true` (already) | ubuntu-latest only | None needed |
| `website.yml` | Yes (already) | npm via `cache: npm` (already) | ubuntu-latest only | None needed |
| `pgtap.yml` | Yes (already) | No practical caching available (Docker image pulls for local Supabase stack) | ubuntu-latest only | None — documented limitation below |
| `supabase-deploy.yml` | Yes (already, serialized) | N/A (deploy-only, low frequency) | ubuntu-latest only | None needed |
| `codeql-flutter.yml` | **No → added** | Flutter SDK+pub-cache existed; **Gradle cache added** | ubuntu-latest → **parameterized for future self-hosted** | Trigger restricted, query suite trimmed, concurrency + Gradle cache added |
| `codeql-website.yml` | **No → added** | npm via `cache: npm` (already) | ubuntu-latest → **parameterized for future self-hosted** | Trigger restricted, query suite trimmed, concurrency added |
| `release-flutter.yml` | **No → added** | Flutter SDK+pub-cache via `cache: true` (already, release-only step) | ubuntu-latest only | Concurrency added (`cancel-in-progress: false` — a release build should never be canceled mid-way) |
| `release-website.yml` | **No → added** | N/A (release-please metadata step only, no build) | ubuntu-latest only | Concurrency added |
| `size-label.yml` | **No → added** | N/A (trivial job) | ubuntu-latest only | Concurrency added |
| `stale.yml` | **No → added** | N/A (schedule/dispatch only) | ubuntu-latest only | Concurrency added |

**No Windows or macOS runners were found anywhere in this repository** — every job already used `ubuntu-latest`. Nothing to change on that objective.

## Duplicate-execution prevention

All ten workflows now have a `concurrency` block. For PR-triggered workflows (`flutter.yml`, `website.yml`, `pgtap.yml`, `size-label.yml`, and now both CodeQL workflows), `cancel-in-progress: true` means a new push to the same PR/branch cancels any still-running job for the previous commit instead of letting both finish — this was already true for `flutter.yml`/`website.yml`/`pgtap.yml` before this change, and is now consistent everywhere it's safe to do. For release/deploy workflows (`release-flutter.yml`, `release-website.yml`, `supabase-deploy.yml`), `cancel-in-progress: false` is deliberate — canceling a release build or a production migration deploy partway through is a correctness risk, not a savings opportunity.

## The one workflow that actually mattered for minutes: CodeQL (Flutter/Android)

See `docs/GITHUB_ACTIONS_USAGE_REPORT.md` for the full data. In short: this single job, on `pull_request`, at 25-60 minutes per run, was the dominant cost. Three changes target it directly:

1. **Trigger scope-down** (`docs/CODEQL_STRATEGY.md`): removed from `pull_request` entirely; now `push` to `main`/`feature/trust-certificates`, weekly schedule, `workflow_dispatch`.
2. **`security-and-quality` → `security-extended`**: same security coverage, drops non-security quality/style queries, cutting query count from 244.
3. **Gradle caching added**: the ~11-12 minute debug-APK build step was re-downloading the entire Gradle/Android dependency graph every single run; caching `~/.gradle/caches` and `~/.gradle/wrapper` keyed on the Gradle config files should cut that to a fraction of that time on cache hits.

## Estimated Actions-minute usage: before vs. after

**Methodology:** figures below are built from this session's own observed run durations (see `docs/GITHUB_ACTIONS_USAGE_REPORT.md`'s per-workflow table), not vendor benchmarks. The post-optimization CodeQL (Flutter) number is a reasoned estimate, not a measured one — this account's exhausted quota meant no run under the new configuration could be observed completing end-to-end during this session. Treat it as directional, and re-measure once minutes are available again (see the recommendation at the end of this document).

**Per PR-push event** (what runs on every commit pushed to an open PR):

| | Before | After |
|---|---|---|
| Flutter CI | ~3-4 min | ~3-4 min (unchanged) |
| Website CI | ~2-3 min | ~2-3 min (unchanged) |
| pgTAP | ~3 min | ~3 min (unchanged) |
| Size Labeler | ~0.2 min | ~0.2 min (unchanged) |
| CodeQL (Website) | ~3.5 min | **0 min (no longer triggers on PR)** |
| CodeQL (Flutter) | ~20-59 min (avg. observed ≈ 35 min), frequently incomplete | **0 min (no longer triggers on PR)** |
| **Total per PR push** | **≈ 47 min** | **≈ 8.7 min** (≈ **81% reduction**) |

**Per push-to-`main` event** (the only remaining trigger for CodeQL besides schedule/dispatch):

| | Before | After (estimated) |
|---|---|---|
| CodeQL (Website) | ~3.5 min | ~3.5 min (unchanged — already fast, `security-extended` has less to save here) |
| CodeQL (Flutter) | ~20-59 min | **estimated ~12-20 min** — build time cut substantially by Gradle caching (after the first cache-populating run), analysis time cut by the smaller query suite |

**Illustrative PR lifecycle** (a PR that receives 5 pushes before merging, a plausible average for this repo):

- **Before:** 5 × ~47 min (every push) + the merge itself didn't re-trigger CodeQL as a separate push-to-main event in the old config's typical flow ≈ **~235 min** of Actions time for that PR's CI feedback loop.
- **After:** 5 × ~8.7 min (pushes) + 1 × ~15-20 min (the eventual merge-to-main CodeQL run) ≈ **~63-64 min** — roughly a **73% reduction** for the same PR.

**Weekly scheduled run** (both CodeQL workflows, runs regardless of PR activity): unchanged in frequency, reduced in per-run cost by the same query-suite and caching changes above — was already a fixed, bounded cost before this change, now simply a cheaper fixed cost.

## What was intentionally not changed

- `pgtap.yml`'s Docker-image-pull cost for the local Supabase stack was not optimized — GitHub Actions doesn't offer a simple, reliable Docker-layer cache for externally-pulled images without significant added complexity (a self-hosted Docker registry mirror or `actions/cache` tricks that are fragile across Supabase CLI version bumps). This was judged not worth the complexity given `pgtap.yml` was already one of the cheaper workflows (~3 min/run).
- `release-flutter.yml` and `release-website.yml` were given concurrency groups but were otherwise left alone — they're release-triggered (infrequent, not per-PR-push), and `release-flutter.yml`'s bash-heredoc steps were explicitly out of scope for the self-hosted-runner portability work (see `docs/SELF_HOSTED_RUNNER_SETUP.md`).
- No workflow was switched to `runs-on: self-hosted`. Both CodeQL workflows are *prepared* to (parameterized via a `vars.CODEQL_RUNNER_LABEL` that defaults to `ubuntu-latest`, i.e. no behavior change), but activating that is a separate, explicit decision — see `docs/SELF_HOSTED_RUNNER_SETUP.md`.

## Recommendation for closing the loop

Re-run `gh api users/DIVINITY-THE-THIRD-EYE/settings/billing/usage` after a few real pushes/merges under this new configuration and compare actual minutes consumed against this estimate — that will validate (or correct) the ~70-80% reduction figures above with real data instead of session-derived estimates.
