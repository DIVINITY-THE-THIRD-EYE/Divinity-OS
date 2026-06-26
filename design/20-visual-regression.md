# 20 — Visual Regression Strategy

Protect the existing premium look as we add features. Tooling (free): **Playwright** test runner with
screenshot assertions (`toHaveScreenshot`) — free/OSS, runs in **GitHub Actions** — optionally
**Storybook** + a free VRT (Playwright/Loki) for component isolation.

## 1. Baselines
- Generate baseline screenshots per critical page/section × breakpoint after Phase 0 (current build) so
  the **"before"** is locked before any change.
- Store baselines in-repo (`tests/visual/__screenshots__/`); update intentionally via reviewed PR.
- Mask known-dynamic regions (breathing canvas, marquee, ambient gradient, count-up) to avoid false fails.

## 2. Critical surfaces to cover
| Surface | Why |
|---|---|
| Hero (BreathHero) | LCP + signature; mask canvas |
| Nav (top + scrolled solid state + mobile menu open) | global chrome |
| About (founder portrait) | trust block |
| Disciplines (start + scrolled) | GSAP layout |
| Membership + UPI card | revenue surface |
| Gallery (grid + lightbox open) | new lightbox (R6) |
| Contact (idle + success + error) | conversion + a11y states |
| New: PromoBar, Stats, Newsletter, StickyCta, StartHere | regressions on additions |
| Footer | links/brand |

## 3. Breakpoints (match `08 §12`)
`390` (mobile), `768` (tablet), `1280` (desktop), `1536` (wide). Capture each critical surface at all four.

## 4. Acceptable change thresholds
- Pixel diff ratio **≤ 0.1%** for static surfaces (anti-alias tolerance) → fail above.
- Animated/dynamic regions: **masked** (not compared).
- Any intended visual change requires an **explicit baseline update** in the PR with reviewer sign-off
  (so diffs are deliberate, never silent).

## 5. Animation testing strategy
- VRT captures **end states** (animations disabled via `prefers-reduced-motion` emulation in Playwright)
  → deterministic shots, no flake.
- Separate **interaction tests** (not pixel): assert hover/focus/press classes, lightbox focus-trap,
  PromoBar dismiss persistence, reduced-motion fallbacks — via Playwright assertions, not screenshots.
- Motion correctness (timing/easing) is reviewed manually against `10-motion-spec.md` (not pixel-tested).

## 6. CI integration
- Run VRT + interaction tests on every PR (GitHub Actions, free minutes); block merge on unreviewed diffs.
- Pair with the perf/a11y gate (`11`, `09`) so one CI run guards visuals + CWV + accessibility.
- Nightly run on `main` to catch font/CDN/data drift.

## 7. Scope discipline
- VRT guards **existing** look first; new components get baselines once their design is approved.
- Keep the suite small and high-signal (critical surfaces only) to avoid flaky-test fatigue.
