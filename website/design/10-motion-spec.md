# 10 — Motion Specification

A precise, implementable spec built on the motion tokens (`08-design-tokens §11`). Governs the website
now and is forward-compatible with the app (`12`/mobile). **Golden rule:** every motion has a defined
**reduced-motion** behaviour; nothing essential depends on animation.

Stack already in place: **Framer Motion** (component anims), **GSAP + ScrollTrigger** (scroll-pinned),
**Lenis** (smooth scroll). No new animation libraries needed.

---

## 1. Tokens
| Token | Value | Use |
|---|---|---|
| `--ease-out` | `cubic-bezier(0.22,1,0.36,1)` | primary in/entrances (Reveal, Nav) |
| `--ease-inout` | `cubic-bezier(0.65,0,0.35,1)` | moves/morphs |
| `--ease-emphasis` | `cubic-bezier(0.16,1,0.3,1)` | hero/feature reveals |
| `--spring-soft` | `stiffness 260, damping 20` | FAB, playful pops (Framer) |
| `--dur-fast` | 200 ms | hover/press/micro |
| `--dur-base` | 600 ms | section reveals, bars |
| `--dur-slow` | 900 ms | hero, large transitions |
| breath cadence | inhale 4s · hold 4s · exhale 6s | hero canvas (signature) |

## 2. Per-interaction spec

### Scroll reveals (existing `Reveal`, reuse for all new sections)
- **Enter:** opacity 0→1, y 26→0; `--dur-slow` (0.9s); `--ease-out`; `viewport once:true, margin:-80px`.
- **Stagger:** children 0.06–0.1s; cap groups at ~6 to avoid long waits.
- **Reduced motion:** opacity only, no translate, or show immediately.

### Hero (BreathHero — preserve)
- Canvas breathing loop on the 4-4-6 cadence; text rises with `--ease-emphasis`, staggered 0.15s.
- **Reduced motion:** canvas renders one static frame at 0.6 fullness; text appears without translate.

### PromoBar (new)
- **Enter:** height 0→auto + opacity, `--dur-base`, `--ease-out`.
- **Dismiss:** collapse height + fade, `--dur-fast`; persist in `sessionStorage`.
- **Reduced motion:** instant show/hide.

### StickyCta (new, mobile)
- **Trigger:** `scrollY > hero height` (reuse WhatsApp FAB logic).
- **Enter:** y 20→0 + opacity + `--spring-soft`. **Exit:** reverse, `--dur-fast`.
- **Reduced motion:** opacity only.

### Stats count-up (new)
- On IntersectionObserver enter: number tweens 0→value over `--dur-slow`, `--ease-out`, once.
- **Reduced motion / SSR:** render final value immediately (no tween).

### Buttons / magnetic CTAs
- **Hover:** color + 1.02–1.04 scale, `--dur-fast`. **Press:** scale 0.98.
- **Magnetic** (existing `Magnetic`): pointer pull ≤8px, spring; **disabled** under reduced motion / coarse pointer.

### Gallery (enhance)
- **Hover:** image scale 1.0→1.04 + grayscale→color, 700ms `--ease-out`; caption fade-in (also on focus).
- **Lightbox open/close:** scale 0.96→1 + fade, `--dur-base`; backdrop fade; **focus trap on open, restore on close**.
- **Reduced motion:** no scale; instant lightbox; caption still available.

### Horizontal disciplines (existing GSAP pin — preserve)
- ScrollTrigger pin + horizontal translate tied to scroll; ensure keyboard/trackpad parity.
- **Reduced motion:** fall back to vertical stack (no pin/scrub).

### Marquee / kinetic (existing)
- Velocity-reactive skew/speed. **Reduced motion:** static; promo text never the *only* copy of the info.

### Forms (Contact/Newsletter)
- Field focus: border color to ember, `--dur-fast`. Submit: button → spinner (`aria-busy`) → success state.
- Status appears via live region (see `09 §A2`), not motion-dependent.

### Celebration (confirmation milestones)
- Subtle ember particle burst (canvas/Lottie), ≤1.2s, single fire; **skipped** under reduced motion;
  never blocks/obscures the success text.

## 3. Scroll system
- **Lenis** smooth scroll (existing); `lerp` tuned for calm (avoid jank). Disabled under reduced motion.
- **Scroll speed:** keep default; do not accelerate. ScrollTrigger `scrub:1` for the manifesto/disciplines.
- **Anchor nav:** palette + nav links use real anchors so Lenis handles easing consistently.

## 4. Shared-element / page transitions
- Single-page site → **no route transitions** today (intentional; fastest).
- Gallery tile→lightbox is the one **shared-element-like** move (scale-from-thumbnail); keep subtle.
- If routes are added later (blog), use a 200–300ms cross-fade; respect reduced motion.

## 5. Trigger conditions (summary)
| Animation | Trigger | Once? |
|---|---|---|
| Section reveal | in-viewport (−80px) | yes |
| Stats count-up | in-viewport | yes |
| StickyCta / FAB | scrollY > hero | n/a |
| PromoBar | mount (if not dismissed) | per session |
| Hover/press | pointer/focus | n/a |
| Lightbox | click/Enter on tile | n/a |
| Celebration | success event | per event |

## 6. Mobile alternatives
- Replace hover-only reveals with **tap/focus** equivalents (gallery caption on focus).
- Magnetic/cursor effects **off** on coarse pointers (already gated).
- Lighter transforms on low-power; honour `prefers-reduced-motion` + Save-Data where available.

## 7. Performance guardrails (see `11`)
- Animate only `transform`/`opacity` (GPU-friendly); avoid layout-thrashing props.
- `will-change` sparingly (gallery image only, during hover).
- No new animation deps; lazy-init GSAP per-section; cancel RAF/observers on unmount (BreathHero already does).
- Budget: animation must not regress INP > 150 ms or cause CLS (reserve space for animated-in elements).
