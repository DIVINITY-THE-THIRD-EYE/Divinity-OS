# 05 — MOTION & SCROLL STORY

## PURPOSE
One master scroll timeline that makes the homepage feel like a single continuous
experience (the three acts), plus the motion grammar all pages share.

## INPUTS
- `04_HOMEPAGE.md` COMPLETE.
- Existing: `SmoothScroll.tsx` (Lenis), `MotionProvider.tsx`, GSAP installed.
- `website/design/10-motion-spec.md` (house durations/easings) — IF MISSING: use grammar below.

## MOTION GRAMMAR (house rules)
- Durations 200/400/800ms · ease `cubic-bezier(0.22,1,0.36,1)` · stagger 60ms.
- DOM animates transform/opacity ONLY. No layout properties, no scroll-jacking;
  Lenis stays 1:1.
- Every animation has a reduced-motion variant (usually: none, content just visible).

## OUTPUTS
- `components/home/ScrollScore.tsx` — client component creating ONE GSAP ScrollTrigger
  scrubbed timeline for the whole new homepage. Exposes progress (0..1) via React context
  `useScrollProgress()` — consumed later by cursor (06) and scene camera (07).
- Section choreography wired to it: copy panels enter (y+opacity), act-break light shifts
  (CSS variable interpolation on `--glow`), Programs horizontal traverse pinned via
  ScrollTrigger (adapt existing Disciplines pattern).
- `components/ui/MagneticCta.tsx` — spring-follow hover for primary CTAs (pointer-fine only).

> **Amended during execution:** "copy panels enter (y+opacity)" was NOT
> re-implemented as a second GSAP-driven system. Every section already gets a
> correct, working, reduced-motion-respecting enter animation from the
> existing `Reveal` component (framer-motion `whileInView`, `once:true`,
> `-80px` margin — exactly what `design/10-motion-spec.md` §"Scroll reveals"
> prescribes: "reuse for all new sections"). Layering ScrollScore's own
> position-based opacity/y tweens on the *same* elements would double-animate
> them — two independent systems fighting over the same `transform`/`opacity`
> values, a real jank/conflict risk for zero visual gain. `ScrollScore`'s
> actual job here: (1) publish the shared progress signal 06/07 need — the
> part that didn't already exist anywhere — and (2) the `--glow` act-break
> shift (new, also didn't exist). See DECISIONS.md E-005 for why (1) is an
> external store, not Context.

## FILES ALLOWED
- `website/components/home/**`, `website/components/ui/MagneticCta.tsx`
- `website/app/globals.css` (keyframes/utility additions only)
- STATUS/CHANGELOG.

> **Amended (E-005, E-006 in DECISIONS.md):** no `components/ui/MagneticCta.tsx`
> — `components/Magnetic.tsx` already existed (already used in `Nav.tsx`,
> already spring-based, already reduced-motion-safe) and `design/10-motion-
> spec.md` independently confirms it's the intended component. Added the
> missing coarse-pointer gate + 8px clamp to it instead. `useScrollProgress()`
> is an external store (`useSyncExternalStore`), not React Context — Context
> needs a Provider ancestor wrapping the other 8 sections, which live in
> `app/(marketing)/page.tsx` (04's file, not in this task's FILES ALLOWED).
> `e2e/home.spec.ts` also needed extending for the reduced-motion/`?no-motion=1`
> validation bullet below (IN-003) — same recurring gap as 02/04.

## FILES FORBIDDEN
- Legacy home, other routes, 3D, cursor file, `lib/`.

## STEPS
1. Build `ScrollScore` with the timeline mapped to document scroll of the new home:
   segment boundaries at progress 0.00/0.12/0.28/0.45/0.60/0.72/0.85/1.00
   (hero → about → programs → benefits → trainer → voices+gallery → cta).
2. Register each section's enter/exit tweens against its segment. Panels: y 24→0,
   opacity 0→1 over 15% of the segment. Act breaks: interpolate `--glow` set.
3. Pin the Programs horizontal traverse inside its segment (reuse the Disciplines
   mechanics — do not write a second horizontal-scroll engine).
4. Reduced-motion: if `prefers-reduced-motion`, ScrollScore mounts NOTHING (no timeline,
   no pinning); sections must be fully readable statically — verify.
5. `MagneticCta`: framer-motion spring (stiffness 150, damping 15), max offset 8px,
   disabled on coarse pointer + reduced motion. Wrap hero + final CTAs only.
6. Debug lever: `ScrollScore` renders children unchanged when URL has `?no-motion=1`
   (dev-only query check — cheaper than an env flag, works on any preview URL).

## VALIDATION
- Standard block.
- Preview: scroll top→bottom smooth 60fps feel, no jump at segment boundaries, pinned
  section releases cleanly, browser back/forward restores scroll sanely.
- Reduced-motion emulation: page fully readable, zero pinning, zero timeline.
- Playwright: extend `e2e/new-home.spec.ts` — with reduced motion, all section headings visible.

## IF VALIDATION FAILS
- Jank → check for layout-property tweens (forbidden) and non-passive listeners.
- Pin conflicts with Lenis → ensure ScrollTrigger uses Lenis' `scrollerProxy` pattern
  (see existing SmoothScroll integration).

## CHECKPOINT
Commit: `feat(rebuild): 05 scroll story — master timeline + motion grammar`

## STOP CONDITION
Green + reduced-motion verified. Auto-continue (same phase).

## NEXT
`06_YOGA_CURSOR.md`
