# 05 — Security Audit

**Round 2 update (2026-07-05, post-merge):** the repository went public and gained live, verified security tooling since this report was first written. See `PUBLIC_REPOSITORY_SECURITY_AUDIT.md`, `GITHUB_CONFIGURATION_REPORT.md`, and `CODEQL_VERIFICATION.md` for the full detail. Summary of what changed:
- **CodeQL now actually uploads results** (Java/Kotlin + JavaScript/TypeScript both verified via the Code Scanning API) — 0 findings in both, corroborating this report's manual review below.
- **Dependabot alerts + automated security updates enabled** — formally tracks the exact `next@14.2.35`/`vite`/`vitest`/`glob` CVEs this report already found manually (21 alerts: 1 critical, 7 high, 11 moderate, 2 low), now with automated fix PRs.
- **Secret scanning + push protection enabled** — found only the two already-known, already-characterized Firebase API keys (see "Secrets" below), both resolved as false positives with documented reasoning.
- **Branch protection now enforces 8 required checks on `main`**, closing the "every check here is advisory" gap this report didn't previously have to consider.
- The **storage-bucket public-flag gap below is unchanged** — it's a production Supabase setting, unaffected by the repo's GitHub visibility.

## Authentication & authorization

- Flutter app uses Supabase Auth directly (email/password, Google, Apple, phone/OTP) — `flutter-app/lib/features/auth/data/auth_repository.dart`.
- JWT role claims are cached into `auth.users.raw_app_meta_data` via `sync_user_role_to_auth()` (`supabase/migrations/017_jwt_role_app_metadata.sql`), avoiding a recursive `users` table lookup on every RLS check — a real performance/security-hygiene win, covered by pgTAP `c4_jwt_role_test.sql` (7 tests).
- `is_admin()`/`is_trainer()`/`is_trainer_or_admin()` helper functions (introduced in migration 012 to fix an RLS-recursion bug, enhanced in 017) are used consistently across all 25 tables' policies — no table was found rolling its own ad hoc admin check.
- **Verified fix, not a regression:** the historical privilege-escalation bug (`009_lock_privileged_fields.sql`) — a `BEFORE UPDATE` trigger blocks non-admin writes to `role`/`plan_status`/`expiration_date`/`pause_start_date`/`current_streak`/`max_streak`, with one narrow, intentional exception (a user may set their own `plan_status` to `PENDING_ADMIN` during onboarding). Client-side (`auth_repository.dart:141-170`) filters the same columns as defense-in-depth, correctly documented as "not the sole control."

## Row-Level Security

All **25 tables have RLS enabled**, and every table has at least one policy (none are fully locked, none were found with RLS enabled but zero policies). Full per-table policy inventory is in [08_Database_Report.md](08_Database_Report.md). Highlights:
- `leave_days` and `audit_log` have **no client INSERT/UPDATE policy at all** — by design, only `SECURITY DEFINER` trigger functions write to them. This is the correct pattern for append-only/system-managed tables.
- `payments` has field-level write restriction beyond table-level RLS: `lock_payment_fields()` (migration 022) restricts trainers to only ever touching `receipt_given_by_trainer`, not arbitrary payment fields.

## Secrets

- **No secrets committed.** `.env*` is gitignored at the root (confirmed via `.gitignore`); only `.env.example`/`.env.local.example` templates are tracked.
- Firebase config files (`flutter-app/lib/firebase_options.dart`, `google-services.json`, `GoogleService-Info.plist`) contain `apiKey` values (`AIzaSy...`) — these are **public client identifiers by Google/Firebase design**, not secrets; Firebase's actual security boundary is App Check + Firebase Security Rules, not hiding this key. No `private_key`/`client_secret` fields were found in any of these files.
- Website secrets (`BREVO_API_KEY`, `CERT_VERIFY_ENDPOINT`, etc.) are read exclusively via `process.env` with safe, non-sensitive fallback behavior when unset (the app degrades gracefully rather than crashing or leaking a default credential).

## Input validation, XSS, injection

- `website/app/api/contact/route.ts` and `subscribe/route.ts`: length guards, email-shape validation, honeypot field, and — critically — **HTML-escaping of all user input** before embedding into the outgoing email body (`escapeHtml()`, lines 131-137 of `contact/route.ts`). No injection path found.
- `website/app/api/verify-certificate/route.ts`: strict regex validation on the certificate code (`^DIV-[A-Z0-9]{4}-[A-Z0-9]{4}$`) before any downstream use; uses `encodeURIComponent` when forwarding to an external endpoint.
- No SQL injection surface found — all Supabase access goes through the PostgREST client or `rpc()` calls with typed parameters, never raw string-interpolated SQL from client input.

## Rate limiting

- `website/lib/rate-limit.ts` — in-memory, fixed-window, 5 requests/minute/IP on `contact` and `subscribe`. **Caveat (not independently confirmed against production topology):** the code comment describes this as suited to "a single-instance / low-traffic marketing site," but if deployed to Vercel's serverless model, each cold instance gets an independent counter — the effective rate limit under horizontal scaling is weaker than the comment implies. `verify-certificate` has no rate limit at all (lower risk — it's a read-only lookup with no side effects and a strict input format).

## CORS / CSP / security headers

`website/next.config.mjs:9-40` — all present and reasonable for a low-interactivity marketing site:
- CSP (`default-src 'self'`, `object-src 'none'`, `frame-ancestors 'self'`, scoped `img-src`/`connect-src` to Sanity CDN + Brevo API), production-only.
- `X-Content-Type-Options: nosniff`, `X-Frame-Options: SAMEORIGIN`, `Strict-Transport-Security` (2-year max-age, includeSubDomains, preload), `Cross-Origin-Opener-Policy: same-origin-allow-popups`, restrictive `Permissions-Policy`.
- `script-src`/`style-src` use `'unsafe-inline'` rather than nonces — the code comment explicitly documents this as a deliberate defense-in-depth trade-off (Next.js hydration + Framer Motion inline styles require it), not an oversight. Acceptable given the documented rationale, but worth revisiting if the site ever adds more third-party or user-generated content.

## Storage

- `payment_screenshots` bucket: RLS policies on `storage.objects` correctly scope reads to (a) the file's owner via path-prefix match, (b) Admin, (c) Trainer (`supabase/migrations/031_payment_screenshots_bucket_private.sql`).
- **HIGH — bucket-level public/private flag is not codified in any migration or CI check.** Migration 031's own header comment states: *"Supabase does not expose bucket-level public/private as SQL; it is configured via the Management API or the Studio UI... Storage → payment_screenshots → Settings → uncheck 'Public bucket'."* The migration only adds RLS policies (which govern the `/storage/v1/object/authenticated/...` access path) — it does **not**, and structurally cannot, flip the bucket's own `public` flag. **Verified locally:** replaying all 45 migrations on a fresh local Supabase instance leaves `storage.buckets.payment_screenshots.public = true` (`select id, name, public from storage.buckets where id='payment_screenshots'` → `t`). If the production bucket's flag were ever `true` (or reverted to `true` by a bucket recreation, project migration, or an accidental dashboard toggle), anyone with a screenshot's public URL could read it directly via `/storage/v1/object/public/...`, bypassing RLS entirely — and payment screenshots may contain UPI IDs or bank details. Prior memory records a human verified the production bucket was private on 2026-07-02, but that was a one-time manual check with **no automated drift detection**. **Recommendation:** re-verify the production bucket is still private, then add an automated check (a scheduled job or CI step calling the Supabase Management API) that fails loudly if the flag is ever `true`. Not fixed in this session — no production Supabase credentials are available from this sandbox, and flipping production infrastructure settings requires the owner's explicit action regardless.
- `verify-certificate` edge function uses the `service_role` key server-side only (never exposed to the client) to bypass RLS for the certificate lookup, and returns only PII-safe fields.

## Dependency vulnerabilities

`npm audit` on `website/` (after installing dependencies, which were not present at session start): **10 vulnerabilities — 1 critical, 5 high, 4 moderate.** Breakdown:
- `next@14.2.35` itself carries multiple disclosed CVEs affecting this version range: DoS via Image Optimizer `remotePatterns`, HTTP request smuggling in rewrites, cache poisoning (multiple advisories), XSS in CSP-nonce-using App Router apps (this site doesn't use nonces, so that specific vector doesn't apply as written, but the underlying package is still flagged), SSRF via WebSocket upgrades, and more.
- The critical/high findings in the `vite`/`vitest`/`glob` chain are all **devDependencies** (test tooling), not shipped to production — lower real-world impact, but still worth clearing via a controlled upgrade.
- **Recommendation:** do not run `npm audit fix --force` blindly (it proposes a Next.js major-version bump, `next@16.2.10`, and an ESLint config bump that are breaking changes). Scope a dedicated upgrade pass with a full regression test afterward.

## Overall security score: 8/10 (unchanged from the code-level review; see round-2 note below)

**Justification:** the fundamentals are strong — 100% RLS coverage with a genuinely-defense-in-depth pattern (client filtering + server trigger + RLS policy, verified not just asserted), no committed secrets, PII-safe public endpoints, solid CSP/security headers, and input validation/escaping on every public-facing form. The score isn't a 9-10 because of two concrete, unresolved items: the storage-bucket public flag being entirely un-codified (a real, if currently-mitigated, single point of failure for sensitive payment data), and an unpatched, CVE-bearing production dependency (`next@14.2.35`). Neither is exploited today as far as this audit could verify, but both are the kind of gap that turns into an incident with one unrelated infrastructure change.

**Round 2 note:** the code-level score above is unchanged because the underlying code didn't change — but the *process* around it materially improved: known CVEs are now tracked with automated remediation instead of only a point-in-time manual finding, static analysis runs and uploads on every PR instead of not at all, and no PR can merge without 8 required checks passing. Those are process/tooling wins layered on top of an already-8/10 codebase, not a change to the codebase's own score — the storage-bucket flag and the `next` upgrade remain the two items that would move this to 9+, and both are already tracked (the bucket flag as a manual recommendation above, the `next` upgrade as Dependabot alert-tracked and pending its own scoped upgrade pass).
