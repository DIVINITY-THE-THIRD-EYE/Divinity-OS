# Motion Inventory (Phase 0)

Every animation in the frozen build: **duration · trigger · dependency · perf impact · reduced-motion**.
This is the catalogue future motion work must respect (full spec: `design/10-motion-spec.md`).

| # | Animation | Component | Duration / cadence | Trigger | Dep | Perf | Reduced-motion |
|---|---|---|---|---|---|---|---|
| 1 | Breathing canvas (orb, rings, embers) | `BreathHero` | inhale 4s · hold 4s · exhale 6s loop | mount (rAF) | canvas | Med (rAF; capped dpr≤2) | Static single frame (0.6 fullness) |
| 2 | Hero text rise | `BreathHero` | ~1.1s, staggered | mount | framer | Low | Appears, no translate |
| 3 | Nav slide-in + solid-on-scroll | `Nav` | 1s in; 0.5s state | mount + scroll>64 | framer | Low | Color/state only |
| 4 | Mobile menu overlay | `Nav` | fade | open | framer | Low | Instant |
| 5 | Scroll-reveal (opacity+y26) | `Reveal` (About, Contact, Faq, Membership, Method, PlanCalc) | 0.9s, ease-out | in-view once (−80px) | framer | Low | Opacity only / immediate |
| 6 | Manifesto line reveal | `Manifesto` | scrubbed, stagger 0.5 | ScrollTrigger | gsap | Med | `gsap.set` visible, no scrub |
| 7 | Disciplines horizontal scroll | `Disciplines` | scrubbed | ScrollTrigger pin | gsap | Med–High | Falls back to vertical stack |
| 8 | Smooth scroll | `SmoothScroll` | continuous lerp | scroll | lenis+gsap | Med (rAF) | Disabled (native scroll) |
| 9 | Scroll progress bar | `ScrollProgress` | spring | scroll | framer | Low | Still updates (no harm) |
| 10 | Ambient gradient breathe | `Ambient`/CSS | 12s ease-in-out loop | always | css | Low | `animation:none`, opacity .7 |
| 11 | Film grain | CSS `.grain` | static | always | css | Negligible | n/a |
| 12 | Kinetic marquee (velocity skew) | `Marquee` | continuous | scroll velocity | js | Low–Med | Static |
| 13 | Custom cursor follow + magnetic | `Cursor`,`Magnetic` | spring | pointer | framer | Low | Disabled (fine-pointer gate) |
| 14 | Intro curtain | `IntroCurtain` | fade/slide | first visit/session | framer | Low | Reduced/instant |
| 15 | Command palette open | `CommandPalette` | 0.2s scale/fade | ⌘K | framer | Low | Instant |
| 16 | FAQ accordion | `Faq` | height/opacity | click | framer | Low | Instant |
| 17 | Plan calculator steps | `PlanCalculator` | fade/slide | interaction | framer | Low | Instant |
| 18 | Voices crossfade | `Voices` | 0.6s, 6.5s interval | timer | framer | Low | Crossfade minimal |
| 19 | Schedule tab transitions | `Schedule` | fade | tab change | framer | Low | Instant |
| 20 | WhatsApp FAB entrance | `WhatsAppFab` | spring (260/20) | scroll>90vh | framer | Low | Opacity only |
| 21 | Gallery reveal | `Gallery` | 0.8s stagger | in-view | framer | Low | Opacity only |
| 22 | Gallery hover (scale+grayscale) | `Gallery` | 700ms | hover | css/framer | Low | No transform |

## Observations
- **rAF-driven (1, 6, 7, 8, 12)** are the perf-sensitive set → keep capped, cancel on unmount (BreathHero already does), and they all have reduced-motion fallbacks.
- **Easing/duration are re-declared per component** → tokenise (TD6, `08 §11`) without changing behaviour.
- **100% of animations have a reduced-motion path** — the standard new work must also meet.

## Rule
New animations register here with the same columns and must (a) animate transform/opacity only,
(b) declare a reduced-motion equivalent, (c) stay within the INP/CLS budget (`11`).
