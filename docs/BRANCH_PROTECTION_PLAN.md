# Branch Protection Plan — `main`

## Availability

Before the repo went public: `gh api repos/.../branches/main/protection` returned `403 "Upgrade to GitHub Pro or make this repository public to enable this feature"`. After going public: the same call returns `404 "Branch not protected"` (i.e. the feature is available, just not yet configured) — confirming branch protection is now genuinely usable on the free plan for a public repo.

## Configuration applied

```json
{
  "required_status_checks": {
    "strict": true,
    "contexts": [
      "Flutter Analyze",
      "Flutter Tests",
      "ESLint & TypeScript Check",
      "Next.js Build",
      "Vitest Unit Tests",
      "pgTAP Database Tests",
      "CodeQL Analysis",
      "CodeQL Analysis (JavaScript/TypeScript)"
    ]
  },
  "enforce_admins": false,
  "required_pull_request_reviews": null,
  "restrictions": null,
  "allow_force_pushes": false,
  "allow_deletions": false,
  "required_conversation_resolution": true
}
```

Applied via `PUT repos/DIVINITY-THE-THIRD-EYE/Divinity-OS/branches/main/protection` and confirmed live afterward.

## Why these 8 checks, and not others

| Included as required | Why |
|---|---|
| Flutter Analyze | Static analysis / compile-level correctness for the mobile app |
| Flutter Tests | Unit + widget test suite (262 tests as of the last full audit) |
| ESLint & TypeScript Check | Lint + type-check for the website |
| Next.js Build | Production build must succeed |
| Vitest Unit Tests | Website unit test suite |
| pgTAP Database Tests | 188 database assertions — RLS, triggers, business logic |
| CodeQL Analysis | Java/Kotlin security scan (now free, now uploads successfully — see `docs/CODEQL_VERIFICATION.md`) |
| CodeQL Analysis (JavaScript/TypeScript) | JS/TS security scan |

| Deliberately **not** required | Why |
|---|---|
| Android Release Build | Only runs on push to `main` (`if: github.ref == 'refs/heads/main'`) — it is *always* "skipped" on a PR, so requiring it would make every PR permanently unmergeable. |
| Label PR by size | Housekeeping automation, not a correctness or security gate. |
| `CodeQL` (the aggregate meta-check) | Redundant with the two specific language checks already required; requiring both the aggregate and the specifics adds no additional protection, just a third context to keep in sync if job names ever change. |
| Vercel / Vercel Preview Comments | Third-party deployment-preview integration, not a first-party CI gate — `Next.js Build` already covers build correctness. |

## Settings chosen and why

- **`strict: true`** — a PR's branch must be up to date with `main` before it's mergeable. Pairs naturally with auto-merge: a stale branch won't silently merge past checks that would have failed against the current `main`.
- **`enforce_admins: false`** — repo admins (currently the sole owner) can still bypass in a genuine emergency. This is a single-maintainer project today; revisit and flip to `true` if the maintainer set grows and bypass-by-anyone becomes a real risk rather than a convenience.
- **`required_pull_request_reviews: null` (not configured)** — the task asked specifically for "require all production CI checks to pass," not for a review-count requirement. Not adding one wasn't an oversight: on a single-maintainer repo, requiring N reviewers before merge would just block merges entirely (the owner can't review their own PR to satisfy a reviewer-count rule) unless a bot/second account exists to review. **If a second maintainer joins, add `required_pull_request_reviews: {"required_approving_review_count": 1}`** at that point.
- **`allow_force_pushes: false`, `allow_deletions: false`** — standard protection against history rewrites or accidental branch deletion on `main`.
- **`required_conversation_resolution: true`** — every review comment thread must be marked resolved before merging; a low-friction, no-downside addition since it doesn't require reviews to exist in the first place, just that any that do get left get addressed.

## Auto-merge

Enabled at the repository level (`allow_auto_merge: true`), restricted to squash-merge only (`allow_squash_merge: true`, `allow_merge_commit: false`, `allow_rebase_merge: false`), with `delete_branch_on_merge: true` so merged PR branches don't accumulate. **Not automatically requested on PR #20 itself** — enabling the auto-merge *capability* at the repo level is a configuration change; requesting auto-merge on a specific PR is a merge-adjacent action left to whoever is actually ready to merge that PR (`gh pr merge --auto --squash`, or the "Enable auto-merge" button in the PR UI).

## Verified working

`gh pr view 20 --json mergeable,mergeStateStatus` returned `{"mergeable": "MERGEABLE", "mergeStateStatus": "CLEAN"}` after all 8 required checks passed — confirming the ruleset is live and correctly evaluated against a real PR, not just accepted by the API.
