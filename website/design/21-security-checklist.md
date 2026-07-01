# 21 — Security Checklist

Scoped to the **current static site + one API route** (and forward notes for the future product). Status:
✅ in place · ⚠️ gap to fix in this upgrade · 🔵 future product.

## 1. Authentication & authorization
- ✅ None needed — public marketing site, no accounts, no protected data.
- 🔵 Future app: Supabase Auth + **Row-Level Security** (per-row authz), Passkeys/biometric, least-privilege
  roles (student/trainer/admin), server-side session validation (ADR-0011).

## 2. Input validation & sanitisation
- ✅ Contact route validates name/email; **HTML-escapes** all fields before email (`escapeHtml`).
- ⚠️ Add: max length caps (name/email/message), reject oversized payloads, normalise unicode.
- ⚠️ Subscribe route (R3): same validation + consent required.

## 3. Injection / XSS
- ✅ React escapes by default; no `dangerouslySetInnerHTML` in components; JSON-LD is server-generated from typed content.
- ✅ Email HTML built from **escaped** values server-side.
- ⚠️ Keep the rule: never interpolate unescaped user input into HTML/JSON-LD.

## 4. CSRF
- ⚠️ Public JSON POST with no cookies/sessions → CSRF risk is low (no auth state to abuse), but add an
  **origin/referer check** + honeypot to the contact/subscribe routes to deter abuse.
- 🔵 Future authed mutations: same-site cookies + CSRF tokens or token-based auth.

## 5. Rate limiting / abuse
- ⚠️ **Gap:** no rate limiting on `/api/contact` today → spam/abuse vector. Add IP token-bucket
  (e.g. 5/min) + **honeypot** field on both forms; consider Cloudflare Turnstile (free) if spam persists.

## 6. Content Security Policy & headers
- ⚠️ Add security headers (Next `headers()` / Vercel): `Content-Security-Policy` (allow self + Brevo +
  analytics + `cdn.sanity.io`), `X-Content-Type-Options: nosniff`, `Referrer-Policy:
  strict-origin-when-cross-origin`, `Strict-Transport-Security`, `Permissions-Policy` (disable
  camera/mic/geo until needed), `X-Frame-Options: DENY`.
- Note: GSAP/Framer/Lenis are bundled (no inline-eval needed) → CSP can avoid `unsafe-eval`.

## 7. Secrets management
- ✅ Brevo/Sanity keys via env vars; not committed; `.env.local.example` documents them.
- ✅ `NEXT_PUBLIC_*` only for non-secret Sanity ids; **`BREVO_API_KEY` is server-only** (used in route, never shipped to client).
- ⚠️ Confirm no secret leaks in logs; rotate keys before launch; set them in Vercel env (not in repo).

## 8. File upload validation
- ✅ None today (no uploads).
- 🔵 Future (profile photos, etc.): type/size validation, content scanning, store in Supabase Storage with signed URLs.

## 9. Logging & audit trails
- ✅ Server logs enquiry receipt + errors (`console`); no PII beyond what's necessary; **email body not over-logged**.
- ⚠️ Add **Sentry** (free) for client+route error monitoring; scrub PII; alert on error spikes.
- 🔵 Future: audit trail for admin actions (who changed what), immutable logs.

## 10. Privacy / compliance
- ⚠️ Add a privacy policy + cookie/analytics **consent** (GA4/GTM gated); honour DNT/GPC; data-deletion path.
- India **DPDP Act** + EU **GDPR** awareness: lawful basis for newsletter (consent), purpose limitation, retention policy.
- Newsletter: double-opt-in recommended; clear unsubscribe (Brevo handles).

## 11. Dependency & supply chain
- ⚠️ Enable Dependabot/`npm audit` in CI; pin versions; review transitive deps; `eslint` (ignored in build today — run in CI instead).

## 12. Pre-launch security gate
- [ ] Rate limit + honeypot on contact/subscribe.
- [ ] Security headers + CSP deployed and tested.
- [ ] Secrets only in Vercel env; rotated; no client leakage.
- [ ] Consent + privacy policy live; analytics gated.
- [ ] Sentry on; PII scrubbed.
- [ ] `npm audit` clean (no high/critical).
