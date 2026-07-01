# Phase 8 — Backend

> The app has **no bespoke API server** — Supabase *is* the backend. The website has two serverless API routes. Sources: [`supabase/`](../divinity_flutter/supabase/), [`app/api/`](../divinity-third-eye/divinity/app/api/), [`lib/`](../divinity-third-eye/divinity/lib/).

## API Architecture

| Surface | Style | Where |
|---|---|---|
| App ↔ data | Supabase auto-generated REST/Realtime + **RPC** (Postgres functions) | `supabase_flutter` client |
| App writes with invariants | Postgres **RPCs** + triggers | `check_in`, `convert_lead_to_member`, payment triggers |
| Website forms | Next.js Route Handlers (serverless) | `app/api/contact/route.ts`, `app/api/subscribe/route.ts` |
| Website content | Sanity GROQ fetch with fallback | `lib/sanity.ts` |

## Services (logical)

- **Auth service** — Supabase Auth (OTP) + JWT role sync trigger.
- **Attendance service** — `check_in` RPC (geofence) + streak triggers.
- **Admissions service** — `leads` table + `convert_lead_to_member` RPC.
- **Payments service** — `payments` table + state-machine triggers + notification trigger.
- **Notifications service** — `notifications` table → FCM via app (`fcm_service.dart`).
- **Email service (web)** — Brevo via `app/api/contact` and `app/api/subscribe`.

## Controllers (web route handlers)

- `POST /api/contact` — enquiry form → Brevo email (or logged fallback). Guards: **rate-limit**, **honeypot**, **body-size**.
- `POST /api/subscribe` — newsletter → Brevo contact. Same guard pattern.

(There are no app-side controllers; repositories call Supabase directly.)

## Middleware

- **Web:** security headers + CSP set in [`next.config.mjs`](../divinity-third-eye/divinity/next.config.mjs); per-route guards in the handlers (`lib/rate-limit.ts`, honeypot, validation).
- **DB:** RLS acts as the authorization "middleware" for all data access; triggers act as write-time middleware.
- **App:** GoRouter redirect logic acts as client-side route guard (auth/role); the DB remains the source of truth.

## Validation

- **Web:** `lib/validation.ts` (shared validators, tested in `validation.test.ts`); form-error shaping in `lib/form-error.ts`.
- **DB:** constraints + triggers (coordinates required, privileged-field locks, payment transitions).
- **App:** domain models + form validation in onboarding steps and `record_payment_sheet`.

## Error Handling

- **Web:** `app/error.tsx`, `app/global-error.tsx`, `app/not-found.tsx`; API handlers return structured JSON errors (`form-error.ts`).
- **App:** repository try/catch surfacing to providers; Crashlytics captures uncaught errors (`fcm_service`/`analytics_service` + `firebase_crashlytics`).

## Logging

- **Web:** contact fallback logs server-side when no Brevo key (`delivered:false`).
- **App:** Firebase Crashlytics + Analytics. See [28_Observability](28_Observability.md).

## Rate Limiting

In-memory fixed-window limiter `lib/rate-limit.ts` (tested) applied to API routes. **Note:** in-memory state is per-instance; for multi-instance scale a shared store would be needed — see [29_Scaling_Strategy](29_Scaling_Strategy.md). `[Needs Verification]` whether a distributed limiter is planned.

## Background Jobs

- DB-side: trigger-driven side effects (streak recalculation, payment propagation, notification creation) run synchronously in Postgres.
- No external job queue found. `[Needs Verification]` for any scheduled tasks (e.g. plan-expiry sweeps) — currently `plan_expiration_date` is stored but expiry enforcement mechanism should be confirmed.

## Scheduled Tasks

> None committed in-repo. Candidate scheduled jobs (expiry reminders, streak resets) are `[Needs Verification]`. Supabase scheduled functions / pg_cron could host these.

## Webhooks

- Inbound: none found for the app. Brevo is called outbound (HTTP).
- `[Needs Verification]`: payment-provider webhooks are not used — payments are **manual UPI screenshot + admin verification** (ADR-0006), not a gateway callback.
