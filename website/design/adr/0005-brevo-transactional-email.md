# ADR 0005 — Brevo for transactional email (vs Resend) + graceful fallback
Status: Accepted · Date: 2026-06-26

## Context
`app/api/contact/route.ts` (Node runtime) validates `{name,email,intention,message}` and, if
`BREVO_API_KEY` is set, sends a transactional email via `api.brevo.com/v3/smtp/email` with the visitor
as `replyTo`. With **no key**, it accepts and logs the enquiry (`{ok:true, delivered:false}`).

## Problem
Need reliable contact delivery on a free tier, in India, with zero-config dev behaviour.

## Alternatives considered
1. **Resend** — great DX, free 3k/mo, but Brevo's free tier (300/mo emails/day) + contacts/marketing
   suits a studio newsletter too.
2. **Direct SMTP** — credentials/ops burden, deliverability risk.
3. **Brevo transactional + graceful fallback** — chosen (already integrated).

## Decision
Keep Brevo. Reuse the **same pattern** for the new newsletter subscribe route (`R3`): add contact to a
Brevo list; no key → accept+log. Email content is HTML-escaped server-side.

## Consequences
- One provider for transactional + future marketing; free tier sufficient at studio scale.
- Dev/preview works without secrets.

## Risks
- Free-tier send limits; deliverability needs a verified sender. → Document in launch checklist (`23`).
- No rate limiting/honeypot today → spam risk. → Tracked in tech-debt (`22`) + security (`21`); add in R3/R9.

## Rollback strategy
Provider swap is isolated to the route file; switching to Resend = change the fetch call + env var. The
fallback path guarantees the UI never hard-fails regardless of provider.
