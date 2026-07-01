# ADR 0014 — WebGL AuraCanvas vs 2D Canvas BreathHero

| Field       | Value                                           |
|-------------|------------------------------------------------|
| **Status**  | Accepted                                        |
| **Date**    | 2026-07-01                                      |
| **Context** | R2 – WebGL AuraCanvas Technical Evaluation      |

## Context

The archived `reference/divinity-website/src/components/marketing/aura-canvas.tsx`
implements a 12 000-particle WebGL eye-opening animation using
`@react-three/fiber`, `@react-three/postprocessing`, and raw GLSL shaders.

The live `components/BreathHero.tsx` renders an ambient pranayama-guided breathing
visualisation using the native 2D Canvas API with ~46 ember particles, concentric
breath rings, and a radial glow — no third-party 3D dependencies.

The question: should the WebGL implementation replace or augment the current hero?

## Decision

**Retain the 2D Canvas BreathHero. Do not integrate the WebGL AuraCanvas.**

The WebGL implementation is preserved in `Divinity/reference/` for future
consideration if the bundle budget is raised or code-splitting is adopted
for the hero section.

## Evaluation Summary

| Criterion                        | AuraCanvas (WebGL)                             | BreathHero (2D Canvas)                        | Winner       |
|----------------------------------|------------------------------------------------|-----------------------------------------------|--------------|
| **Bundle impact**                | +120–160 kB gzipped (`three` + r3f + postproc) | 0 kB (native Canvas API)                      | BreathHero   |
| **First Load JS (/ route)**      | ~290–330 kB (exceeds 210 kB hard budget)       | 168 kB (within budget)                        | BreathHero   |
| **GPU requirement**              | Requires WebGL 2 + dedicated/integrated GPU    | CPU-only, works on any device                 | BreathHero   |
| **Mobile performance**           | Falls back to static CSS on mobile/touch       | Full animation at 60 fps on mid-range mobile  | BreathHero   |
| **`prefers-reduced-motion`**     | Handled (falls back to CSS pulse)              | Handled (renders single static frame)         | Tie          |
| **Accessibility (WCAG AA)**      | `aria-hidden`, no focus traps                  | `aria-hidden`, no focus traps                 | Tie          |
| **Visual richness**              | Exceptional (12K particles, bloom, swirl)      | Subtle & elegant (breath rings, ember drift)  | AuraCanvas   |
| **Scroll interaction**           | Eye-open scroll morph (impressive)             | None (hero section only)                      | AuraCanvas   |
| **Maintenance cost**             | Requires GLSL expertise, r3f version tracking  | Plain JS, no dependencies                     | BreathHero   |
| **Brand alignment**              | Violet/gold cosmic palette (different brand)   | Ember/bone/void palette (matches site tokens) | BreathHero   |
| **Power/battery usage**          | Continuous GPU pipeline, bloom post-processing | IntersectionObserver pauses when offscreen    | BreathHero   |

**Score: BreathHero wins 7–2 (2 ties).**

## Consequences

1. The First Load JS budget stays at 168 kB — well under the 210 kB hard limit.
2. Mobile users get full animation, not a static CSS fallback.
3. No `three.js` tree-shaking configuration or dynamic imports needed.
4. If the brand ever shifts toward the violet/cosmic palette, the WebGL shader
   can be revisited — the GLSL is self-contained and well-documented.

## Alternatives Considered

- **Dynamic import (`next/dynamic`) with SSR disabled**: Would keep the initial
  bundle under budget but adds ~150 kB on first interaction, degrading TTI.
- **Reduced particle count (2 000)**: Still requires the full `three.js` runtime;
  bundle size reduction is negligible.
- **Intersection-triggered lazy load**: Improves LCP but the hero *is* the first
  viewport — it would show a blank canvas until hydration completes.
