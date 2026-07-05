# Phase 13 — Performance

> Sources: [design/11-performance-budgets.md](../website/design/11-performance-budgets.md), [design/phase0/performance-baseline.md](../website/design/phase0/performance-baseline.md), [design/phase0/reports/](../website/design/phase0/reports/) (Lighthouse desktop/mobile reports + `final-d.json`/`final-m.json`).

## Lighthouse

Baseline Lighthouse runs are committed: `lh-desktop.report.html`, `lh-mobile.report.html`, plus machine-readable `final-d.json` / `final-m.json` and a `home-desktop.png` screenshot. **`[Needs Verification]`:** extract the exact scores from those reports for the scorecard (not parsed here).

## Bundle Analysis

Next.js automatic code-splitting per route; client islands kept small (RSC default). `[Needs Verification]`: committed bundle-analyzer output not found — add `@next/bundle-analyzer` run to budgets.

## Lazy Loading

- Web: route-level code splitting; `next/image` lazy by default; motion libs loaded in client islands only.
- App: feature screens built on navigation; `shimmer_loading` placeholders during fetch.

## Caching

- Web: Vercel CDN/edge caching for static/SSG pages; route prefetch.
- App: `shared_preferences` for light state; Supabase client caching per session.
- Content hashing pattern available (`Divinity:content-hash-cache-pattern` skill).

## Code Splitting

App Router automatic per-route; dynamic imports for heavy client components (motion). `[Needs Verification]` for explicit `next/dynamic` usage list.

## Image Optimization

`next/image` (AVIF/WebP, responsive). Studio/guru images already `.webp`. ADR-0007 (local assets). Founder image optimized (`founder.webp`).

## Font Strategy

`next/font` self-hosts Google Fonts → zero layout shift; subset to the three families. App uses `google_fonts` runtime loading.

## Performance Budgets

Defined in [design/11-performance-budgets.md](../website/design/11-performance-budgets.md) and frozen quality gates ([design/phase0/quality-gates.md](../website/design/phase0/quality-gates.md)). Targets cover Core Web Vitals (LCP/CLS/INP). **`[Needs Verification]`:** transcribe the exact budget numbers from that doc.

## App performance

Flutter release builds (APK/AAB); `fl_chart` for charts; geolocation throttled to check-in events. `[Needs Verification]`: app startup/jank metrics (no committed profiling found).
