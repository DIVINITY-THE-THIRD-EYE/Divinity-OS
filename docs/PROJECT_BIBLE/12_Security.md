# Phase 12 — Security

> Sources: [SECURITY_REVIEW_C1_C2.md](../Divinity/docs/SECURITY_REVIEW_C1_C2.md), [supabase/tests/](../divinity_flutter/supabase/tests/) (c1–c8), [next.config.mjs](../divinity-third-eye/divinity/next.config.mjs), [design/21-security-checklist.md](../divinity-third-eye/divinity/design/21-security-checklist.md).

## Threat Model (summary)

| Asset | Threat | Mitigation |
|---|---|---|
| Student PII (profile, health, emergency contact) | Unauthorized read | RLS `users_select_own` + role helpers |
| Role escalation | User self-promoting to admin | `lock_privileged_fields` trigger + JWT role from `app_metadata` (not client-set) |
| Payment fraud | Faking approval/expiry | `lock_payment_fields` + state-machine triggers; admin verification |
| Attendance spoofing | Remote check-in | `check_in` RPC geofence (`haversine_m` vs batch coords + radius) |
| Web form abuse | Spam / injection / DoS | rate-limit + honeypot + body-size guard + validation |
| Content injection | XSS | CSP (production) + React escaping |
| Generative AI API abuse | Unauthorized calls / API key extraction | Firebase App Check (Play Integrity on Android, App Attest on iOS) |

## Defense-in-depth: the C1–C8 security test suite

The app ships **8 SQL regression tests** that lock the security model:

| Test | Guards |
|---|---|
| `c1_privileged_fields_test` | users can't edit `role`/privileged fields |
| `c2_geofence_test` | check-in rejected outside batch radius |
| `c3_streak_test` | streak recalculation correctness |
| `c4_jwt_role_test` | role claim drives access, not client input |
| `c5_latches_test` | onboarding/email latches can't be bypassed |
| `c6_lead_convert_test` | lead→member conversion is admin-gated & correct |
| `c7_therapeutic_logs_test` | log visibility/write scoping |
| `c8_payment_verification_test` | payment transitions & locks |

**Rule:** any change to RLS/triggers must keep these green.

## CSP

Content-Security-Policy is configured (production) in `next.config.mjs`. `[Needs Verification]`: confirm the exact directive list and that it covers Sanity CDN / Brevo / image domains when those are enabled.

## Headers

Security headers set via `next.config.mjs` (e.g. X-Frame-Options, X-Content-Type-Options, Referrer-Policy, etc. — confirm exact set in file). Vercel adds HTTPS/HSTS at the edge.

## Encryption

- **In transit:** HTTPS everywhere (Vercel, Supabase, Firebase).
- **At rest:** Supabase managed Postgres encryption; Supabase Storage for screenshots.
- Secrets in `.env` / Vercel env, never in git.

## Secrets

| Secret | Location |
|---|---|
| `BREVO_API_KEY` | Vercel env / `.env.local` |
| Sanity project/dataset | public-prefixed (read-only) env |
| Supabase URL + anon key | app `.env` (anon key is RLS-gated, safe client-side) |
| Supabase service key | **must not** ship in client; server-only `[Needs Verification]` if used |
| Firebase config | `firebase_options.dart` (public client config) |

## Input Validation

- Web: `lib/validation.ts` + honeypot + body-size limit on API routes.
- DB: constraints + triggers.
- App: form validators in onboarding/payment flows.

## File Upload Security

Payment screenshots upload to Supabase Storage with RLS (migration 011): students may upload their own; reads are policy-gated. `[Needs Verification]`: confirm MIME/size limits and that signed URLs are used for reads.

## OWASP Review

| OWASP Top-10 | Status |
|---|---|
| A01 Broken Access Control | Mitigated via RLS + tests c1/c4/c7/c8 |
| A02 Cryptographic Failures | HTTPS + managed encryption |
| A03 Injection | Parameterized Supabase client; React escaping; CSP |
| A04 Insecure Design | ADRs + security review document the design |
| A05 Security Misconfiguration | headers/CSP in next.config; `[Verify]` prod config |
| A07 Auth Failures | OTP + JWT role; `[Verify]` rate-limit on auth |
| A09 Logging/Monitoring | Crashlytics/Analytics; `[Verify]` server log retention |

Full review: [SECURITY_REVIEW_C1_C2.md](../Divinity/docs/SECURITY_REVIEW_C1_C2.md).

## Risk Register

| Risk | Likelihood | Impact | Mitigation / Owner |
|---|---|---|---|
| In-memory rate limiter ineffective at scale | Med | Med | move to shared store `[Needs Verification]` |
| Manual payment verification error | Med | Med | triggers + admin double-check; audit log |
| Secret leakage via duplicate trees | Low | High | `.env` gitignored; cleanup quarantined dupes |
| CSP gaps when enabling 3rd-party | Med | Med | review CSP before enabling Sanity/Brevo prod |
| No automated dependency scanning confirmed | Med | Med | add Dependabot/`npm audit` `[Needs Verification]` |
