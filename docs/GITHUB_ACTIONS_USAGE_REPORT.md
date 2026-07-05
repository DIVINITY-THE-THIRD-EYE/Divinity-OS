# GitHub Actions Usage Report

## Account context

Repository owner (`DIVINITY-THE-THIRD-EYE`) is a **free-tier personal GitHub User account** (confirmed via `gh api users/DIVINITY-THE-THIRD-EYE` → `"plan": {"name": "free", ...}`), not an organization. Free personal accounts get **2,000 included Actions minutes/month** on private repositories, and (per GitHub's own billing behavior) a **$0 spending limit by default** when no payment method is on file — meaning usage beyond the included quota isn't billed, it's simply **not run**: in-progress jobs get killed.

## Evidence this was actually hit (not just theoretical)

Billing usage pulled via `gh api users/DIVINITY-THE-THIRD-EYE/settings/billing/usage` during this session showed:

```
{"date":"2026-07-01T00:00:00Z","product":"actions","sku":"Actions Linux","quantity":1278.0, ..., "netAmount":0.0, "repositoryName":"Divinity-Website"}
{"date":"2026-06-01T00:00:00Z","product":"actions","sku":"Actions Linux","quantity":29.0, ..., "netAmount":0.0, "repositoryName":"divinity-website"}
```

1,278 minutes already used in the current billing period **before** this session's own CI activity is added on top — well over half the 2,000-minute monthly allowance — and every line item shows `netAmount: 0.0`, consistent with usage hitting a $0 spending limit rather than being billed.

**Direct symptom observed live, twice, on the same job:** the `CodeQL Security Scan (Flutter/Android)` job died mid-analysis with:
```
##[error]The runner has received a shutdown signal. This can happen when the runner service is stopped, or a manually started runner is canceled.
##[error]The operation was canceled.
```
— not an application error, not a workflow syntax error. Both times this happened after the job had already been running for 24-35+ minutes with no error in the actual CodeQL analysis output up to that point. This is the signature of GitHub reclaiming a runner mid-job, which is exactly what happens when an account's spending limit is reached during a run.

## Observed per-workflow run costs (this session, real data)

| Workflow | Typical duration observed | Notes |
|---|---|---|
| PR Size Labeler | ~5-10s | Negligible |
| Next.js Website CI (lint+build+test) | ~2-3 min | |
| Flutter CI (analyze+test; build-android skipped on PRs) | ~3-4 min | build-android only runs on push to `main` |
| Supabase pgTAP Tests | ~3 min | |
| CodeQL (JavaScript/TypeScript) | ~3.5 min | Consistently fast, low risk |
| **CodeQL (Flutter/Android)** | **19m46s, 35m45s, 24m37s, 59m** across 4 observed attempts on this branch alone | Highly variable, frequently killed before completing; single largest cost by a wide margin |

## Why CodeQL (Flutter/Android) is the dominant cost

Three factors compound:
1. **The debug APK build step** (`flutter build apk --debug`) took ~11-12 minutes on every attempt, re-downloading the full Gradle/Android dependency graph from scratch each time (no Gradle caching existed before this change).
2. **`queries: security-and-quality`** ran all 244 Java/Kotlin queries, including many pure code-style queries unrelated to security, on every single invocation.
3. **Every `pull_request` push re-triggered the whole thing** — before this session's fix, a PR that received several pushes before merge would re-run this ~25-60 minute job on every single one of them.

## What changed (see `docs/CI_OPTIMIZATION_REPORT.md` for the itemized before/after)

- CodeQL workflows no longer trigger on `pull_request` at all — only `push` to `main`/`feature/trust-certificates`, a weekly schedule, and manual `workflow_dispatch`.
- `security-and-quality` → `security-extended` (drops non-security queries only — see `docs/CODEQL_STRATEGY.md`).
- Gradle dependency/wrapper caching added to the Flutter CodeQL job.
- Concurrency groups with `cancel-in-progress: true` added everywhere a superseded run should be canceled rather than left to finish and waste minutes.

## What this doesn't fix

**These changes reduce future consumption — they do not restore this month's already-exhausted quota.** Until the billing period resets or the account owner raises the spending limit / adds a payment method, *any* Actions job on this account (not just CodeQL) may still be killed mid-run if the quota is fully exhausted. If subsequent pushes to this PR show the same "runner shutdown signal" on jobs that were previously fast and reliable (Flutter CI, Website CI, pgTAP), that is expected under this theory and confirms it further — it is not a sign that this session's fixes didn't work.

## Recommendation

1. Confirm the theory directly: check `gh api users/DIVINITY-THE-THIRD-EYE/settings/billing/usage` again once the account owner has visibility into their GitHub billing dashboard (Settings → Billing and plans), which shows the actual remaining-quota number this API doesn't expose directly.
2. If minutes are the binding constraint going forward, the two real levers are: (a) a self-hosted runner for the expensive jobs (prepared, not activated — see `docs/SELF_HOSTED_RUNNER_SETUP.md`), or (b) raising the spending limit slightly so occasional overage is billed in cents rather than silently killing jobs (GitHub Actions Linux minutes are $0.006/minute beyond the free 2,000/month quota per GitHub's published pricing — a few dollars/month buys a lot of headroom).
