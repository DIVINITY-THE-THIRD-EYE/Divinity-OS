# Component Freeze (Phase 0)

Every reusable component tagged. **Only `Needs Improvement` and `Experimental` components may change in
Phase 1.** `Stable` components are frozen — changing one requires an ADR + evidence (final rule).

Tags: **Stable** (works, leave alone) · **Needs Improvement** (targeted change planned) ·
**Experimental** (signature/at-risk, may evolve) · **Deprecated** (none currently).

| Component | Tag | Rationale / planned change |
|---|---|---|
| `BreathHero` | **Experimental** | Signature canvas; Phase 1 adds intro-offer CTA (additive); keep canvas frozen |
| `Nav` | **Needs Improvement** | Add "Start here" link; ensure new CTA a11y |
| `CommandPalette` | Stable | Validated vs Linear; only data additions |
| `Footer` | **Needs Improvement** | Real social links already wired; minor (newsletter link) |
| `Contact` | **Needs Improvement** | A11y live-region + typed routing (R9); logic frozen |
| `Membership` | **Needs Improvement** | Incentive copy (R8); QR/logic frozen |
| `Disciplines` | **Needs Improvement** | Add intensity tags (R5); GSAP internals frozen |
| `Gallery` | **Needs Improvement** | Hover caption + lightbox (R6); masonry frozen |
| `Voices` | **Needs Improvement** | Strengthen testimonial specificity; dot target-size |
| `PlanCalculator` | Stable | Works well; no change planned |
| `Method` | Stable | — |
| `Schedule` | Stable | Static; live booking is future product |
| `Manifesto` | Stable | GSAP reveal; frozen |
| `Marquee` | Stable | Reduced-motion safe |
| `About` | Stable | Founder portrait integrated |
| `Faq` | Stable | Schema-backed |
| `SmoothScroll` | Stable | Lenis+GSAP bridge (ADR-0003) |
| `ScrollProgress` | Stable | — |
| `Ambient` | Stable | — |
| `Cursor` | Stable | Fine-pointer gated |
| `IntroCurtain` | Stable | Session-gated |
| `WhatsAppFab` | **Needs Improvement** | Real number pending (TD9); StickyCta reuses its scroll logic |
| `Reveal` (util) | **Experimental** | Will be extended/wrapped by a shared `useInView` (TD8) — back-compatible |
| `Magnetic` (util) | Stable | Reused for new CTAs as-is |
| `JsonLd` (util) | **Needs Improvement** | Add Offer/Event schema (additive) |

## New components (created in Phase 1+, born `Experimental` until validated)
`PromoBar`, `StickyCta`, `Stats`, `Newsletter`, `StartHere`, `Lightbox`, `Quote`, `SoundToggle`,
plus shared atoms `Button`, `Field`, `Tag` (TD7) and hooks `useInView`, `useReducedMotion` (TD8).

## Freeze rule
A change to a **Stable** component is a red flag: stop, write/lookup an ADR, attach measured evidence,
get review. `Needs Improvement`/`Experimental` changes still require tests + a11y/perf gates to pass.
