# ADR 0007 — `next/image` + local assets (vs external CDN)
Status: Accepted · Date: 2026-06-26

## Context
All imagery (logo mark, founder, studio/guru galleries, payment QR) lives in `public/` and renders via
`next/image`. `next.config.mjs` allows remote `cdn.sanity.io` for future CMS images. Source photos are
large (up to 6000px webp); the optimizer downsizes on demand.

## Problem
Deliver AVIF/WebP, responsive, no-CLS images for free, without an external DAM.

## Alternatives considered
1. **Cloudinary/ImageKit** — powerful transforms, but paid tiers and another dependency for a small set.
2. **Raw `<img>`** — no optimization, CLS/LCP risk.
3. **`next/image` + local `public/` (+ optional Sanity CDN)** — chosen.

## Decision
Keep `next/image` with local assets; rely on Next's optimizer (Sharp) for format/size. Enforce `sizes`
on every image; lightbox loads full-res only on open (`11`).

## Consequences
- Free, fast, no CLS; CMS images still possible via the allowed remote pattern.
- Large originals are fine since the optimizer serves right-sized variants.

## Risks
- Vercel image-optimization usage limits on free tier at high traffic. → Monitor; static export of common
  sizes possible later.
- Over-fetching if `sizes` omitted. → Perf budget enforces `sizes`.

## Rollback strategy
Swapping to a CDN later = change `src`/loader; assets remain in `public/` as fallback. Isolated, low risk.
