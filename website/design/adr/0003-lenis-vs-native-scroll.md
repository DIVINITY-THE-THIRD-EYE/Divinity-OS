# ADR 0003 — Lenis smooth scroll vs native scrolling
Status: Accepted · Date: 2026-06-26

## Context
`SmoothScroll.tsx` initialises **Lenis** and bridges it to GSAP ScrollTrigger so pinned/scrubbed
sections stay in sync. The award-layer feel depends on smooth, eased scrolling.

## Problem
Smooth-scroll libraries can harm accessibility (hijacking), performance (rAF cost), and INP if misused.

## Alternatives considered
1. **Native scroll only** — best a11y/perf default, but loses the eased "calm" feel and ScrollTrigger sync polish.
2. **CSS `scroll-behavior:smooth`** — only affects anchor jumps, not continuous scrolling.
3. **Lenis, gated by reduced-motion** — chosen.

## Decision
Keep Lenis, but **disable it under `prefers-reduced-motion`** (already implemented) and keep `lerp`
tuned for calm (no input lag). Anchors route through Lenis for consistent easing.

## Consequences
- Cohesive motion feel; ScrollTrigger pinning works reliably.
- Users who opt out get plain native scrolling (no hijack).

## Risks
- INP/jank on low-end devices, or scroll-hijack complaints. → Mitigated by reduced-motion path, modest
  `lerp`, and INP budget (<150 ms, `11`).
- Anchor/focus interactions must remain keyboard-correct. → Verified in a11y audit (`09`).

## Rollback strategy
Remove `SmoothScroll` mount in `app/page.tsx`; site falls back to native scroll with no other code
changes (Lenis is isolated). Single-line, low-risk revert.
