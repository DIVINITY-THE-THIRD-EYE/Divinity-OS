# 11 — Performance Budgets

Explicit, enforceable targets. The current build's First-Load JS for `/` is **~198 kB** (from `next build`).
These budgets keep the upgrade from eroding that while we add conversion features.

## 1. Core Web Vitals targets (stricter than the defaults)
| Metric | Target | Google "good" | Notes |
|---|---|---|---|
| **Lighthouse Perf** | **≥ 95** | — | mobile + desktop, throttled |
| **LCP** | **< 2.0 s** | < 2.5 s | hero studio image is LCP — keep `priority`, correct `sizes` |
| **CLS** | **< 0.05** | < 0.1 | reserve space for PromoBar/Stats/Newsletter; fonts already `swap` |
| **INP** | **< 150 ms** | < 200 ms | small client islands; avoid heavy hover handlers |
| **TTFB** | < 0.6 s | < 0.8 s | static/SSG on Vercel edge |
| **FCP** | < 1.5 s | < 1.8 s | |

## 2. Resource budgets (per page, mobile)
| Resource | Budget | Current/notes |
|---|---|---|
| **First-Load JS** | **≤ 210 kB** gz (hard ≤ 230) | ~198 kB now; new comps are small islands — **no new animation libs** |
| **Total JS** | ≤ 300 kB gz | reuse Framer/GSAP/Lenis already bundled |
| **CSS** | ≤ 60 kB gz | Tailwind JIT, purge on |
| **Fonts** | ≤ 150 kB total | 3 families, latin subset, `swap`; cap weights (Cormorant 300–600 only) |
| **Images (initial viewport)** | ≤ 300 kB | hero via `next/image` AVIF/WebP; below-fold lazy |
| **Per image (rendered)** | ≤ 200 kB | enforce `sizes`; gallery sources are 6000px → must downscale via optimizer |
| **Requests (initial)** | ≤ 35 | |
| **DOM nodes** | ≤ 1500 | watch gallery/marquee duplication |

## 3. Rules to hold the budget
1. **No new heavy dependencies.** Conversion comps use existing libs or vanilla (IntersectionObserver, `sessionStorage`).
2. **Lazy everything below the fold.** Newsletter, lightbox full-res, optional sound asset load on interaction/scroll.
3. **Images:** always pass `sizes`; never render a 6000px source at display size; lightbox loads full-res **only on open**.
4. **Audio (R10):** fetch on first toggle only; ≤ 200 kB looped ambient; respect Save-Data.
5. **Animate transform/opacity only;** no layout thrash; cancel observers/RAF on unmount.
6. **Keep SSG.** Don't convert static sections to client-only; keep core copy server-rendered (SEO + LCP).
7. **Third-party:** analytics loaded via GTM **after** interaction/idle; no render-blocking tags.

## 4. Verification (free, every phase)
- `next build` → inspect route First-Load JS (regression gate vs 210 kB).
- **Lighthouse CI** (free, GitHub Actions) on PRs: fail if Perf < 95, LCP > 2.0 s, CLS > 0.05.
- **WebPageTest** / PageSpeed Insights spot-checks (mobile, 4G).
- `@next/bundle-analyzer` (free) when JS budget is threatened.

## 5. Budget gate (CI pseudo-config)
```
perf>=95  a11y>=95  seo>=100  best-practices>=95
LCP<2000ms  CLS<0.05  INP<150ms  first-load-js<=210kb
```
Any breach blocks merge until resolved or explicitly waived with rationale in the PR.
