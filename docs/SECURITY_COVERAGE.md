# Security Coverage — Before vs. After the CI Optimization

This answers one question directly: **does removing CodeQL from the `pull_request` trigger leave a critical security gap?**

## Short answer

**No critical gap, for a reason that matters more than the trigger change itself: CodeQL was never actually functioning as an automated pre-merge security gate on this repository, before or after this change.** Two independent facts combine to make that true:

1. **This repository has no branch protection** — confirmed via `gh api repos/DIVINITY-THE-THIRD-EYE/Divinity-OS/branches/main/protection`, which returns: *"Upgrade to GitHub Pro or make this repository public to enable this feature."* Branch protection (and therefore "required status checks") is not available on a private repo on the free plan. **No CI check on this repository — not CodeQL, not Flutter Tests, not pgTAP, none of them — can technically block a merge.** Every check here is informational; merge safety currently depends on a human looking at the PR checks before clicking merge, for every workflow, not just CodeQL.
2. **This repository does not have GitHub Advanced Security (Code scanning) enabled** (see `docs/CODEQL_ADVANCED_SECURITY.md` from earlier this session) — so even when CodeQL ran on every `pull_request` before this change, its findings never appeared as inline PR annotations or in the Security tab. The only way anyone ever saw a CodeQL finding was by manually downloading and opening the SARIF artifact. That is exactly as true after this change as it was before it.

**What actually changed is cadence, not visibility or enforcement** — both were already manual/best-effort. Before: a scan happened on every PR push (expensive, often didn't even finish under this account's quota). After: a scan happens on every push to `main`/`feature/trust-certificates`, once a week regardless, or on demand via `workflow_dispatch`. The artifact a human would need to go find and open is produced identically either way.

## Which events now run CodeQL, and what each catches

| Trigger | Frequency | What it catches |
|---|---|---|
| `push` to `main` / `feature/trust-certificates` | Every merge/direct push to those branches | Anything introduced by that merge, scanned right after it lands — the closest thing to a safety net this repo has, just after-the-fact instead of before |
| `schedule` (weekly, Sunday 2 AM IST) | Fixed weekly cadence | Anything missed by push-triggered scans (e.g. a dependency-only bump with no direct code push), and any new CodeQL query/rule additions from GitHub's own query pack updates, applied retroactively to unchanged code |
| `workflow_dispatch` | On demand | A maintainer/reviewer manually running either CodeQL workflow against a specific PR branch from the Actions tab, when that PR is judged security-sensitive (touches auth, payment verification, RLS policies, etc.) |

**Worst-case latency for a real vulnerability to get a CodeQL pass:** up to 7 days (if introduced right after the weekly scan and not touching `main` directly) — down from "never, if the account is out of quota" under the pre-fix broken state, and functionally similar to "next PR push" under the pre-optimization *working* state, given neither state produced an automatically-surfaced result either way.

## What GitHub's own guidance says (checked, not assumed)

GitHub's documentation on CodeQL setup does **not** recommend dropping the `pull_request` trigger for cost reasons — if anything, its default advanced-setup guidance favors scanning on pull requests specifically because that's when a finding can still block a merge *if* Advanced Security + branch protection + required-checks are configured together. **This repository has none of those three**, which is precisely why the trade-off made here is defensible: removing a trigger doesn't cost you an enforcement mechanism you don't currently have, on a plan that doesn't support having it. This is a pragmatic adaptation to a resource-constrained, unprotected-branch reality — not an implementation of GitHub's out-of-the-box "best practice," and this document says so plainly rather than overclaiming alignment.

## What else is actually providing security coverage right now, independent of CodeQL

- **pgTAP (`c1`-`c23`, 188 assertions)** — still runs on every `pull_request` to `main`, unchanged by this work. This is the repo's actual strongest security-relevant automated gate: it directly tests RLS policies, privilege-escalation prevention (`c1_privileged_fields_test.sql`), JWT role handling (`c4_jwt_role_test.sql`), and payment-state-machine correctness (`c8_payment_verification_test.sql`) — the categories of bug most likely to cause real harm in this app (unauthorized data access, privilege escalation, payment logic errors) are covered by tests that run on every PR and, unlike CodeQL, are actually testing *this app's specific* authorization logic rather than generic vulnerability patterns.
- **ESLint (`next/core-web-vitals` only)** — runs on every PR, but is a web-vitals/code-quality config, not a security linter (no `eslint-plugin-security` or equivalent). This is a real, separate gap, unrelated to the CodeQL/Actions-minutes work, worth its own follow-up.
- **Dependabot version-update PRs** — configured and running weekly (`.github/dependabot.yml`) for pub, npm, and GitHub Actions dependencies. **However, GitHub Dependabot *vulnerability alerts* are currently disabled** (`gh api repos/.../vulnerability-alerts` → *"Vulnerability alerts are disabled"*). This is a free, zero-Actions-minutes GitHub-native feature, unrelated to anything changed in this session, and is a genuinely easy, no-cost win — see the recommendation below.

## Recommendation (not performed as part of this review — a settings toggle, not a workflow change)

**Enable Dependabot vulnerability alerts** (`Settings → Code security and analysis → Dependabot alerts`). This costs nothing, consumes no Actions minutes, and directly addresses known-CVE dependencies (relevant given this audit separately found `next@14.2.35` carrying several disclosed CVEs — see `project_audit/05_Security_Audit.md`). This wasn't toggled automatically in this session, consistent with the practice established earlier of not flipping repository security/billing settings without an explicit go-ahead — but unlike GitHub Advanced Security, this one has no cost or downside, so it's a low-friction next step whenever convenient.
