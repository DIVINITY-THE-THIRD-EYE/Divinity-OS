# Architecture Decision Records

Each ADR captures one significant decision: **Context · Problem · Alternatives · Decision ·
Consequences · Risks · Rollback**. ADRs describe what the codebase already does (status `Accepted`)
or what the upgrade proposes (`Proposed`). **No architectural rewrite proceeds without an ADR + evidence.**

| ADR | Title | Status |
|---|---|---|
| [0001](0001-single-page-static-architecture.md) | Single-page static marketing architecture (Next 14 App Router, SSG) | Accepted |
| [0002](0002-gsap-vs-framer-motion.md) | GSAP **and** Framer Motion (scoped, not either/or) | Accepted |
| [0003](0003-lenis-vs-native-scroll.md) | Lenis smooth scroll vs native scrolling | Accepted |
| [0004](0004-cms-or-fallback-content.md) | CMS-or-fallback content layer (Sanity optional, `lib/content.ts` canonical) | Accepted |
| [0005](0005-brevo-transactional-email.md) | Brevo for transactional email (vs Resend) + graceful fallback | Accepted |
| [0006](0006-upi-qr-payments.md) | UPI QR payments (vs Stripe/Razorpay gateway) | Accepted |
| [0007](0007-next-image-local-assets.md) | `next/image` + local assets (vs external CDN) | Accepted |
| [0008](0008-rsc-client-island-strategy.md) | React Server Components + client-island strategy | Accepted |
| [0009](0009-pwa-now-native-later.md) | PWA layer now, native apps later | Proposed |
| [0010](0010-offline-first-strategy.md) | Offline-first strategy (future app) | Proposed |
| [0011](0011-supabase-vs-firebase.md) | Supabase vs Firebase (future product backend) | Proposed |
| [0012](0012-no-user-theme-toggle.md) | No user dark/light toggle (dual-surface art direction) | Accepted |

## Template
```md
# ADR NNNN — Title
Status: Proposed | Accepted | Superseded by ADR-XXXX   ·   Date: YYYY-MM-DD
## Context
## Problem
## Alternatives considered
## Decision
## Consequences
## Risks
## Rollback strategy
```
