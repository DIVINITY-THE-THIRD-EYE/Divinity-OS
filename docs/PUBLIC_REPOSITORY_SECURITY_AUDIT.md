# Public Repository Security Audit

This repository went public on 2026-07-05. Going public means the entire commit history and source code are now readable by anyone — this document re-checks everything that matters once "nobody but the owner can see this" is no longer a backstop, and records what was turned on in response.

## What going public actually changes about risk

Nothing in the *application's* production security posture changes by the repo becoming readable — Supabase RLS, Firebase Security Rules, and App Check don't care whether the source is public. What changes is: **anyone can now read every line of code, every commit message, and every historical diff**, including anything that was ever committed and later removed (git history isn't erased by deleting a file in a later commit). This audit re-verifies the two things that actually matter under that new assumption.

## 1. No real secrets were ever committed (re-verified, not just carried over from the private-repo audit)

This session's original full engineering audit (`project_audit/05_Security_Audit.md`, done while the repo was still private) already established: `.env*` is gitignored, only `.env.example` templates are tracked, and no `private_key`/`client_secret` fields exist anywhere in the Firebase config files. **That finding is re-confirmed here under public-repo assumptions**, and GitHub's own secret scanner (now enabled) independently corroborates it:

- **2 secret-scanning alerts fired**, both "Google API Key" pattern matches on the two Firebase Web API keys in `firebase_options.dart` / `google-services.json` / `GoogleService-Info.plist`.
- **Both resolved as false positives**, with reasoning attached to each alert: Firebase Web API keys are public client identifiers by Google's own design — Firebase's actual access control is Firebase Security Rules and App Check (`firebase_app_check` is already a dependency in `pubspec.yaml`), not secrecy of this value. Google's own documentation explicitly states these keys are safe to expose in client code.
- **Zero other secret-scanning alerts fired** — no API tokens, private keys, database credentials, or similar were flagged anywhere in the tracked history.

**Conclusion: no remediation needed.** The one category of finding secret scanning produced was a well-understood, documented non-issue, not a real exposure.

## 2. Dependency vulnerabilities — now formally tracked, not just manually found

Dependabot alerts (newly enabled) found **21 open alerts: 1 critical, 7 high, 11 moderate, 2 low** — entirely in `website/` dependencies (`next@14.2.35`, the `vite`/`vitest` chain, `glob`, `esbuild`, `postcss`). This is not a new discovery: it matches exactly what `npm audit` found manually during this session's original security audit (`project_audit/05_Security_Audit.md`), which already recommended a scoped Next.js upgrade rather than a blind `npm audit fix --force` (that command proposes a Next.js major-version bump as a breaking change). Now that Dependabot security updates are enabled, expect automated PRs proposing fixes for at least the patchable ones — **review each on its own merits rather than merging all of them reflexively**, since some (the Next.js major bump in particular) carry real breaking-change risk that needs its own test pass, exactly as flagged in the original audit's recommendation.

## 3. CodeQL — now uploading, zero findings

See `docs/CODEQL_VERIFICATION.md` for the full verification trail. Summary: both language scans (Java/Kotlin, JavaScript/TypeScript) now successfully upload to the Security tab (previously impossible on a private repo without paid Advanced Security), and both report **zero open alerts**. This corroborates rather than contradicts this session's earlier manual code read, which found no injection/XSS/similar issues in either codebase.

## 4. What a public repo exposes that a private one didn't (non-code considerations)

- **Issue/PR history and discussion** — anything discussed in issues or PR comments is now public. Nothing sensitive was found in a spot-check of open issue titles, but this wasn't exhaustively re-read line-by-line as part of this pass; worth a quick human skim if there's any concern about past discussion containing anything sensitive (customer data, real credentials shared for debugging, etc.).
- **Contributor identity** — commit author emails/names are now publicly attributable. Not a security issue per se, but worth being aware of if any commits were made under a personal email not intended for public association with this project.
- **Business logic visibility** — competitors or bad actors can now read the exact leave-approval, payment-verification, and RLS-policy logic. This is a product/business decision (open-sourcing implies accepting this), not something to remediate — noted here only so it's a conscious trade-off, not an overlooked one.

## Overall public-repo security posture: solid

- No real secrets in the codebase or its history (re-verified two ways: manual audit + automated secret scanning).
- Known dependency vulnerabilities are now tracked with automated remediation PRs, not just a point-in-time manual finding.
- Static analysis (CodeQL) is live, uploading, and clean.
- RLS/auth/payment logic was already independently verified correct in this session's original audit and doesn't change by being readable.

**Nothing found in this pass requires an urgent fix.** The two secret-scanning alerts were resolved as expected false positives; the 21 Dependabot alerts are a known, already-documented, already-recommended-for-a-scoped-fix issue, not a new emergency.
