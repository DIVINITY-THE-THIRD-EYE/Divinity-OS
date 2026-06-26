# ADR 0002 — GSAP and Framer Motion (scoped, not either/or)
Status: Accepted · Date: 2026-06-26

## Context
The site uses **both** libraries: Framer Motion for component/UI animation (`Nav`, `Reveal`, `Faq`,
`PlanCalculator`, `WhatsAppFab`, `ScrollProgress`, `Voices`, `Schedule`, `Magnetic`, `IntroCurtain`)
and **GSAP + ScrollTrigger** for scroll-pinned sequences (`Disciplines` horizontal scroll, `Manifesto`
breath-paced reveal, `SmoothScroll` integration with Lenis).

## Problem
Two animation libraries raise bundle-size and consistency concerns. Should we consolidate?

## Alternatives considered
1. **Framer Motion only** — weaker for scroll-scrubbed pinning/timelines than ScrollTrigger.
2. **GSAP only** — heavier for simple declarative component state/AnimatePresence ergonomics.
3. **Keep both, scoped by job** — chosen.

## Decision
Retain both with a clear boundary: **Framer Motion = component/state/gesture**; **GSAP/ScrollTrigger =
scroll-driven timelines & pinning**. GSAP is now fully free (incl. plugins), so no licence cost.

## Consequences
- Best tool per job; both already bundled (no net-new deps for the upgrade — see perf budget `11`).
- Motion tokens unify easing/duration across both (`08 §11`, `10`).

## Risks
- Bundle weight. → Mitigated by performance budget (≤210 kB First-Load JS) and lazy GSAP per-section.
- Two mental models for contributors. → Mitigated by the boundary rule + motion spec.

## Rollback strategy
Either library can be removed only if all its usages are ported and CWV/UX are verified equal or better —
which would itself require a new ADR with measured evidence.
