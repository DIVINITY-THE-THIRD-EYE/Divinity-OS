# Phase 21 — Future Roadmap

> Sources: [Divinity/docs/roadmap.md](../Divinity/docs/roadmap.md), [design/13-ai-roadmap.md](../website/design/13-ai-roadmap.md), [design/12-implementation-planning.md](../website/design/12-implementation-planning.md), ADRs. Confirm live priorities in `Divinity/docs/status.md`.

## Next Milestones

1. **Closed beta launch** — complete [BETA_LAUNCH_CHECKLIST](../Divinity/docs/BETA_LAUNCH_CHECKLIST.md): real pricing, real testimonials, Brevo sender, UPI QR verified, OG image.
2. Finish payment-verification UX + notifications.
3. FCM deep-linking polish; admin reporting/CSV completeness.

## Feature Pipeline

- Self-service **class booking** (currently staff-driven enrollment).
- Structured **diet/workout plans** (beyond therapeutic logs).
- **Payment gateway** option (Razorpay/UPI intent) alongside manual QR.
- **Web analytics** instrumentation (taxonomy already designed).
- **Audit log** + scheduled expiry reminders.

## Long-Term Vision

A complete "Academy OS" platform: premium public brand + full member lifecycle + data-driven retention. Potentially multi-academy/franchise (`[Needs Verification]`).

## Scaling Strategy

See [29_Scaling_Strategy](29_Scaling_Strategy.md): distributed rate-limiting, DB indexing/partitioning as data grows, CDN, Supabase plan scaling.

## Mobile Roadmap

ADR-0009: **PWA now, native later.** Path: harden Flutter app → store releases (Play/App Store) → richer offline (ADR-0010). Native distribution status `[Needs Verification]`.

## AI Roadmap

[design/13-ai-roadmap.md](../website/design/13-ai-roadmap.md): AI-assisted content, recommendations, possibly progress insights. The repo already embeds an **agentic-OS** layer (`Divinity/CLAUDE.md`, `ANTIGRAVITY/`) for AI-assisted development.

## Expansion Plans

`[Needs Verification]`: additional locations, new disciplines, retail/wellness products — confirm with owner.
