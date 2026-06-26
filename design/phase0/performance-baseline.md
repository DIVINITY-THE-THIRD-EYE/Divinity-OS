# Performance Baseline (Phase 0)

Captured 2026-06-26. Store every phase's report under `design/phase0/reports/` and diff against this.

## Build-derived (real, from `next build`)
| Metric | Value |
|---|---|
| First-Load JS `/` | **198 kB** |
| Shared JS (all routes) | 87.3 kB |
| Route `/` HTML/RSC payload | 110 kB |
| `/_not-found` | 88.1 kB |
| Static routes | home, 404, icons, robots, sitemap (prerendered ○) |
| Dynamic routes | `/api/contact`, `/opengraph-image` (ƒ) |

## Field/lab vitals — **TO RUN** (not fabricated)
No headless Chrome bridge was available this session, so the table below is a **template to fill** by
running Lighthouse locally against `npm run start` (production build). Do this before Phase 1 begins.

| Metric | Desktop target | Desktop actual | Mobile target | Mobile actual |
|---|---|---|---|---|
| Performance | ≥95 | _TO RUN_ | ≥95 | _TO RUN_ |
| LCP | <2.0s | _TO RUN_ | <2.5s* | _TO RUN_ |
| CLS | <0.05 | _TO RUN_ | <0.05 | _TO RUN_ |
| INP | <150ms | _TO RUN_ | <200ms | _TO RUN_ |
| FCP | <1.5s | _TO RUN_ | <1.8s | _TO RUN_ |
| TBT | <150ms | _TO RUN_ | <200ms | _TO RUN_ |
| Speed Index | <3.0s | _TO RUN_ | <3.4s | _TO RUN_ |
\*Mobile LCP is allowed slightly higher in field; lab target stays aggressive.

### Capture commands
```bash
npm run build && npm run start        # serve production on :3000
npx lighthouse http://localhost:3000 --preset=desktop \
  --output=json --output=html --output-path=./design/phase0/reports/lh-desktop
npx lighthouse http://localhost:3000 --form-factor=mobile --throttling-method=simulate \
  --output=json --output=html --output-path=./design/phase0/reports/lh-mobile
# or one-shot multi-page:
npx unlighthouse --site http://localhost:3000
```

## Known performance characteristics (from code review)
- ✅ `next/font` (Cormorant/Hanken/JetBrains, `swap`) → no font CLS.
- ✅ Static prerender + RSC; `next/image` everywhere; hero image `priority`.
- ⚠️ Animation libs bundled (framer-motion + gsap + lenis) drive most of the 87.3 kB shared JS — the
  main optimisation lever if budget pressure appears (no new libs in the upgrade — `11`).
- ⚠️ Gallery source images up to 6000px → rely on optimizer + `sizes`; verify no over-fetch in field.

## Regression policy
Every phase re-runs the capture and appends a dated report. **Any** regression beyond budget
(First-Load >210 kB, LCP >2.0s, CLS >0.05, INP >150ms) blocks merge (`quality-gates.md`).
