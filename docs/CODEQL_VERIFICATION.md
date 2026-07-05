# CodeQL Verification — Public Repository

Confirms CodeQL is genuinely working end-to-end (analysis + upload + Security tab visibility) after re-enabling it on `pull_request`, not just "the workflow file looks right."

## What changed and why (see `docs/CODEQL_STRATEGY.md` and `docs/GITHUB_ACTIONS_USAGE_REPORT.md` for the original context)

Both `codeql-flutter.yml` and `codeql-website.yml` previously ran with `upload: never` because this repo was private without GitHub Advanced Security, and had `pull_request` removed as a trigger because this account's free Actions-minutes quota was being exhausted by the ~25-60 minute Flutter CodeQL job running on every PR push. The repo going public removes both constraints: Advanced Security is free for public repos, and GitHub-hosted Actions minutes are unlimited for public repos. Both workflows were reverted to their default, fully-functional configuration (`pull_request` trigger restored, `upload: never` removed).

## Verification performed (this session, on PR #20 itself)

### 1. Both CodeQL jobs actually ran on the PR

```
CodeQL Analysis                              pass   9m14s
CodeQL Analysis (JavaScript/TypeScript)      pass   1m31s
CodeQL                                       pass   2s      <- GitHub's own aggregate check
```

The `CodeQL` aggregate check appearing and passing is itself confirming GitHub's native code-scanning integration recognizes the setup — that check doesn't exist until Advanced Security is actually wired up correctly.

### 2. SARIF upload actually succeeded (not just "the step didn't error")

Checked directly against the Code Scanning API, not inferred from the workflow's own exit code:

```
$ gh api repos/DIVINITY-THE-THIRD-EYE/Divinity-OS/code-scanning/analyses --jq '.[] | select(.category=="/language:java-kotlin")'
{
  "category": "/language:java-kotlin",
  "results_count": 0,
  "rules_count": 120,
  "error": "",
  "warning": "",
  "tool": {"name": "CodeQL", "version": "2.25.6"}
}
```

```
$ gh api repos/DIVINITY-THE-THIRD-EYE/Divinity-OS/code-scanning/analyses --jq '.[] | select(.category=="/language:javascript-typescript")'
{"category": "/language:javascript-typescript", "results_count": 70, ...}   <- an earlier/interim upload
{"category": "/language:javascript-typescript", "results_count": 0, ...}   <- the final, current analysis
```

Before this session's fix, this same endpoint returned `{"message": "no analysis found", "status": 404}` — there was no prior successful upload to compare against. **This is the actual proof the fix worked**, not just "the job shows green."

### 3. Findings are visible where they're supposed to be

```
$ gh api repos/DIVINITY-THE-THIRD-EYE/Divinity-OS/code-scanning/alerts --jq 'length'
0
```

Zero open CodeQL alerts across both languages. This is a genuine result, not a sign the scan didn't run — it's consistent with this session's own earlier manual security review (`project_audit/05_Security_Audit.md`), which found no injection, XSS, or similar vulnerability-class issues in either codebase during a direct code read.

## Query suite: kept as `security-extended`, not reverted to `security-and-quality`

Both workflows still use `queries: security-extended` (changed from `security-and-quality` during the Actions-minutes optimization work). This is a deliberate choice, not an oversight: `security-extended` retains every security query and only drops non-security code-style/quality queries (naming conventions, dead code, etc.) — coverage for actual vulnerabilities is identical to `security-and-quality`. Since Actions minutes are no longer the constraint that originally motivated this, reverting to `security-and-quality` is a free option now if maximum query breadth (including non-security lint-style findings) is wanted — but since this repo's ESLint and `flutter analyze` configs already cover code-style/quality linting, `security-extended` avoids duplicate signal without giving up any security coverage. Left as-is; flagged here as an explicit, revisitable decision rather than silently kept.

## Result: CodeQL is fully functional

- Runs on `pull_request`, `push` to `main`/`feature/trust-certificates`, weekly schedule, and `workflow_dispatch`.
- Both languages upload successfully to the Security tab.
- Zero false starts, zero upload errors, in this verification pass.
