# GitHub Configuration Report — Public Repository Re-Audit

Repository went public on 2026-07-05 (confirmed via `gh api repos/DIVINITY-THE-THIRD-EYE/Divinity-OS` → `"private": false, "visibility": "public"`). This document records every repository-setting change made in response, with before/after state and verification for each.

## Settings changed

| Setting | Before | After | Verified how |
|---|---|---|---|
| Dependabot vulnerability alerts | Disabled (`vulnerability-alerts` → 404 "disabled") | **Enabled** | `PUT .../vulnerability-alerts` → success; confirmed by GitHub's own push output: *"GitHub found 21 vulnerabilities on ... default branch (1 critical, 7 high, 11 moderate, 2 low)"* |
| Dependabot automated security updates | Disabled | **Enabled** | `PUT .../automated-security-fixes` → success; `security_and_analysis.dependabot_security_updates.status` now `"enabled"` |
| Secret scanning | Disabled | **Enabled** | `PATCH` repo `security_and_analysis.secret_scanning.status=enabled` → confirmed in response |
| Secret scanning push protection | Disabled | **Enabled** | Same PATCH, `secret_scanning_push_protection.status=enabled` → confirmed in response |
| Branch protection on `main` | Unavailable (403: *"Upgrade to GitHub Pro or make this repository public"*) | **Configured** | See `docs/BRANCH_PROTECTION_PLAN.md` for the full ruleset |
| Repository auto-merge | `allow_auto_merge: false` | **`true`** | Confirmed via `gh api repos/.../` |
| Merge methods | Squash + merge-commit + rebase all allowed | **Squash-only** (`allow_merge_commit: false`, `allow_rebase_merge: false`) | Confirmed via `gh api` |
| Delete branch on merge | `false` | **`true`** | Confirmed via `gh api` |
| CodeQL `pull_request` trigger (both workflows) | Removed (private-repo Actions-minutes constraint) | **Restored** | See `docs/CODEQL_VERIFICATION.md` |
| CodeQL SARIF upload | `upload: never` (workaround) | **Default (`upload: always`)** | Confirmed — see `docs/CODEQL_VERIFICATION.md` for the actual uploaded analyses |

## What was found once scanning was turned on

- **21 Dependabot alerts**: 1 critical, 7 high, 11 moderate, 2 low — all in `website/` dependencies (`next`, `vite`, `vitest`, `glob`, `esbuild`, `postcss`). These are not new: they match exactly what this session's earlier `npm audit` run found manually (see `project_audit/05_Security_Audit.md`) — Dependabot is now tracking the same issues natively, with automated security-update PRs enabled going forward.
- **2 secret scanning alerts**, both "Google API Key" pattern matches on the same two Firebase Web API keys this session's original audit already reviewed and characterized as public client identifiers (not secrets) in `firebase_options.dart`, `google-services.json`, and `GoogleService-Info.plist`. **Both resolved as false positives** with a documented reason (Firebase's security model relies on Firebase Security Rules + App Check, not on hiding this value) rather than left open as permanently-unresolvable noise in the Security tab.
- **0 CodeQL findings** across both languages (JavaScript/TypeScript and Java/Kotlin) — see `docs/CODEQL_VERIFICATION.md`.

## What was intentionally not changed

- **Required PR reviews were not configured** on branch protection — the task asked specifically for CI checks + auto-merge, not review requirements. This is a deliberate scope decision, not an oversight — see `docs/BRANCH_PROTECTION_PLAN.md` for the reasoning and how to add it later if wanted.
- **`enforce_admins` was left `false`** — repo admins (currently just the owner) can still push directly to `main` or merge without waiting on checks if truly necessary. Given this is a single-maintainer project today, forcing admin compliance with the same rules seemed like friction without a corresponding safety benefit yet; revisit if more maintainers join.
- **Advanced secret-scanning extras** (`secret_scanning_non_provider_patterns`, `secret_scanning_validity_checks`) were left disabled — the task asked for secret scanning "if available," and base secret scanning + push protection satisfies that; the extras are additional opt-in layers, not part of the core ask.
