# ADR 0001 — Single-page static marketing architecture (Next 14 App Router, SSG)
Status: Accepted · Date: 2026-06-26

## Context
Divinity is the public marketing front door for a single-location yoga academy in Lucknow. The roadmap's
portals/dashboards/app are explicitly a separate product (README).

## Problem
What rendering/architecture best serves a fast, secure, low-maintenance brand site with a single
conversion goal (enquiry/booking)?

## Alternatives considered
1. **Multi-page app with a backend/DB** — overkill; more attack surface and ops for static content.
2. **SPA (CSR)** — worse SEO/LCP; unnecessary for mostly-static content.
3. **Single-page, statically prerendered (SSG) with client islands** — chosen.

## Decision
Next.js 14 App Router, statically prerendered single page (`app/page.tsx`) with interactive **client
islands**; content from `lib/content.ts` (CMS-or-fallback, ADR-0004); deployed on Vercel.

## Consequences
- Excellent LCP/TTFB; trivial scaling; minimal security surface (one stateless API route).
- New "pages" are anchors/sections, not routes — IA stays a single narrative.
- Future product features must live in their own app/repo, not bolt onto this site.

## Risks
- If the business later needs accounts/booking *on the marketing domain*, this constrains it. → Mitigated
  by ADR-0011 (separate backend) and incremental routes only when justified by an ADR.

## Rollback strategy
Additive routes can be introduced under `app/` without affecting the static home; no rollback needed for
the SSG decision itself. Revert any route addition via isolated PR.
