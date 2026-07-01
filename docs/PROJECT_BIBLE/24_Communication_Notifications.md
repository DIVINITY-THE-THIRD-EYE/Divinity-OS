# Phase 24 — Communication & Notifications

> Sources: `notifications` table (migrations 004/023), `services/fcm_service.dart` + `fcm_provider.dart`, `app/api/contact` + `subscribe` (Brevo), `lib/links.ts` (WhatsApp).

## Channels

| Channel | Tech | Direction | Surface |
|---|---|---|---|
| Push | Firebase Cloud Messaging | → user | app |
| In-app | `notifications` table + `notification_bell` | → user | app |
| Email | Brevo | ↔ academy | website |
| WhatsApp | `wa.me` click-to-chat | → academy | website + app `[Verify]` |
| SMS | — | — | `[Needs Verification]` (none) |

## Email Templates

Brevo transactional sends for contact enquiry + newsletter. Template/branding `[Needs Verification]` (currently plain enquiry email with visitor as reply-to). Sender config via `BREVO_FROM_EMAIL`/`BREVO_TO_EMAIL`.

## SMS Templates

`[Needs Verification]`: no SMS channel.

## WhatsApp Templates

Pre-filled message via `waHref` (`lib/links.ts`); message text from `lib/content.ts`. Not WhatsApp Business API.

## Push Notifications

FCM via `fcm_service.dart`; tokens managed per device; **deep-linking** to target screens (commit: "FCM deep linking"). Triggered by `handle_payment_notification` and staff-created notifications.

## In-App Notifications

`notifications` table (user-scoped RLS); `notifications_screen` + `notification_bell` badge; mark-as-read (`is_read` indexed).

## Reminder Rules

`[Needs Verification]`: automated reminders (payment due/expiry, class) not yet scheduled. Candidate: pg_cron/Supabase scheduled function.

## Scheduling

Notifications are event-driven (triggers) today; time-based scheduling `[Needs Verification]`.

## Retry Policies

FCM handles delivery retries; Brevo API failures fall back to server-side logging (web). App-side retry for failed sends `[Needs Verification]`.

## Localization

`[Needs Verification]`: app appears English-only (`intl` package present for formatting). No multi-language strings found. See [internationalization gap].

## Notification Matrix

| Event | Push | In-app | Email |
|---|---|---|---|
| Payment status change | ✅ | ✅ | `[Verify]` |
| Leave decision | `[Verify]` | ✅ | — |
| New enquiry (to academy) | — | — | ✅ (Brevo) |
| Newsletter | — | — | ✅ |
