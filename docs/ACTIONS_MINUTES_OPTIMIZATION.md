# Actions Minutes Optimization — Merge-Readiness Summary

Concise summary for reviewers deciding whether to merge PR #20. Full detail lives in `docs/CI_OPTIMIZATION_REPORT.md` and `docs/GITHUB_ACTIONS_USAGE_REPORT.md` — this document is the short version.

## The problem this solved

This is a free personal GitHub account (2,000 Actions-minutes/month on private repos, $0 spending limit). Billing data showed 1,278+ minutes already used in the current period before this session's own CI activity. The `CodeQL Security Scan (Flutter/Android)` job — 25-60 minutes per run, triggered on every single PR push — was confirmed (via two live, reproduced failures) to be getting killed mid-run by GitHub's own quota-enforcement mechanism, not failing due to a code or config bug.

## What changed

1. Every workflow now has a `concurrency` group, canceling superseded runs on new pushes (safe ones do; release/deploy workflows deliberately don't).
2. Both CodeQL workflows no longer trigger on `pull_request` — only `push` to `main`/`feature/trust-certificates`, a weekly schedule, and manual `workflow_dispatch`.
3. Both CodeQL workflows switched `security-and-quality` → `security-extended` (all security queries retained, non-security quality/style queries dropped — see `docs/CODEQL_STRATEGY.md`).
4. Added Gradle dependency caching to the Flutter CodeQL job (its ~12-minute build step was previously uncached).
5. Both CodeQL workflows' `runs-on` is now parameterized (`${{ vars.CODEQL_RUNNER_LABEL || 'ubuntu-latest' }}`) to allow an opt-in self-hosted runner later, with zero behavior change today (see `docs/SELF_HOSTED_RUNNER_SETUP.md`) — **not activated**.

## Verified impact (real data, post-merge push to this PR)

After pushing these changes, PR #20's check list showed **no CodeQL entries at all** (expected — removed from `pull_request`) and every remaining check passed cleanly and quickly:

| Check | Result |
|---|---|
| ESLint & TypeScript Check | 41s |
| Flutter Analyze | 55s |
| Flutter Tests | 2m24s |
| Label PR by size | 4s |
| Next.js Build | 1m20s |
| Vitest Unit Tests | 44s |
| pgTAP Database Tests | 3m3s |
| Android Release Build | skipped (correct — main-only) |

No runner-shutdown/quota symptoms recurred on any of these. Estimated reduction for a typical PR lifecycle (~5 pushes before merge): **from ≈235 minutes to ≈63-64 minutes, roughly 73%** (see `docs/CI_OPTIMIZATION_REPORT.md` for the full methodology and per-workflow breakdown — the CodeQL-Flutter post-optimization number specifically is a reasoned estimate, since no run under the new config could be observed completing end-to-end while the account was still over quota).

## What this doesn't fix

This reduces *future* consumption. It does not restore the already-exhausted current-month quota. If a later push shows the same runner-shutdown symptom on a job that just ran fine (Flutter Tests, pgTAP, etc.), that's the remaining quota exhaustion, not a regression from this work — see "Remaining External Tasks" in the final answer.

## No paid feature enabled, no visibility change, no runner change

Confirmed as constraints throughout: repository is still private, no GitHub Advanced Security was enabled, no workflow runs on `self-hosted` yet.
