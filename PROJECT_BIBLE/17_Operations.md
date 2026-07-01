# Phase 17 — Operations

> SOPs derived from the implemented workflows (RLS/triggers/screens). Where a human process isn't encoded in software it is flagged `[Needs Verification]`. See also [Appendix/Academy_Operations_Handbook](Appendix/Academy_Operations_Handbook.md).

## Student Admission SOP

1. Lead captured (website enquiry / WhatsApp / walk-in) → `leads` (admin CRM).
2. Admin converts lead → member via `convert_lead_to_member` RPC (creates `users` row).
3. Student installs app, logs in (OTP), completes onboarding wizard.
4. Admin activates the student (clears pending-approval gate).
5. Admin/trainer enrolls student into batch(es) (`enrollments`).

## Trainer SOP

- Mark attendance per batch; approve leave; verify payments; maintain therapeutic logs/comments. (See [06_Trainer_App](06_Trainer_App.md).)
- Onboarding of a trainer = admin sets `role='trainer'` (syncs to JWT).

## Payment SOP

1. Student selects plan, pays via UPI QR, uploads screenshot (`record_payment_sheet`).
2. `payments` row created; before/after triggers set initial status.
3. Trainer/admin verifies screenshot → approves (`admin_approved`, receipt flags) under `lock_payment_fields` rules.
4. `plan_expiration_date` set; notification fired to student.

## Membership Renewal

On/near expiry, student repeats Payment SOP for the new term. `[Needs Verification]`: automated expiry reminders (no scheduled job committed — see [08_Backend](08_Backend.md) Background Jobs).

## Refund Process

`[Needs Verification]`: no refund flow in schema. Define policy + manual process (and whether a `payments` status for refunds is needed).

## Support Workflow

`[Needs Verification]`: no in-app ticketing. Support likely via WhatsApp/phone/email (`lib/content.ts` contact). Consider documenting an SLA.

## Incident Response

See [28_Observability](28_Observability.md) + [27_Business_Continuity](27_Business_Continuity.md). Crashlytics surfaces app incidents; web via Vercel. Severity matrix `[Needs Verification]`.

## Daily Operations

- Trainers: mark attendance, respond to leave, verify payments, update logs.
- Admin: monitor dashboard KPIs, manage batches/holidays, approve members, export reports (CSV).
