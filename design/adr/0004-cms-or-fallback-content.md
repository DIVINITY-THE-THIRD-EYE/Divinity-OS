# ADR 0004 — CMS-or-fallback content layer (Sanity optional, `lib/content.ts` canonical)
Status: Accepted · Date: 2026-06-26

## Context
`lib/content.ts` is the single source of truth for all copy/data (site, disciplines, plans, schedule,
faqs, testimonials, gallery, payment). `lib/sanity.ts` exposes `fetchOrFallback<T>()` which returns
Sanity data **only if** a project id is configured and the query succeeds, else the local fallback.
`app/page.tsx` fetches disciplines/plans/testimonials this way.

## Problem
The owner should be able to edit content without code, but the site must run with **zero config** and
never break on a CMS outage.

## Alternatives considered
1. **Hardcode copy in components** — not translator/owner friendly; scattered.
2. **CMS-required (Sanity/Contentful)** — breaks the zero-config promise; outage = broken page.
3. **Local canonical + optional CMS override with graceful fallback** — chosen.

## Decision
Keep `lib/content.ts` canonical and typed; Sanity is an **optional override** via `fetchOrFallback`
(`useCdn:true`, try/catch → fallback). All **new** upgrade copy (offer, stats, newsletter) goes into
`lib/content.ts` too.

## Consequences
- Works offline/dev with no keys; CMS can be added later without refactor.
- One typed seam for future i18n (`09 §9`).

## Risks
- Drift between local fallback and CMS docs. → Keep schemas mirrored; treat local as the contract.

## Rollback strategy
Unset `NEXT_PUBLIC_SANITY_PROJECT_ID` → site instantly serves local content. No deploy/rollback risk
from CMS issues by design.
