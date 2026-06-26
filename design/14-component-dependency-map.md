# 14 — Component Dependency Map

Derived from the **actual imports** in `components/`, `app/`, and `lib/`. Shows coupling and
simplification opportunities. (No hooks/contexts/services exist yet — the site is stateless; "services"
= the one API route + the content/CMS layer.)

## 1. Layers

**Layout / entry**
- `app/layout.tsx` (Server) → `next/font`, `lib/content` (site), `components/JsonLd`, `globals.css`.
- `app/page.tsx` (Server) → `lib/sanity.fetchOrFallback` + `lib/content` (fallbacks) → renders all sections.

**Chrome / global**
`Nav`, `Footer`, `CommandPalette`, `Cursor`, `ScrollProgress`, `SmoothScroll`, `Ambient`,
`IntroCurtain`, `WhatsAppFab`.

**Section organisms**
`BreathHero`, `Marquee`, `Manifesto`, `About`, `Disciplines`, `Method`, `Schedule`, `Membership`,
`PlanCalculator`, `Voices`, `Faq`, `Gallery`, `Contact`.

**Shared utility (the only reused internal components)**
- `Reveal` ← About, Contact, Faq, Membership, Method, PlanCalculator (scroll-in wrapper).
- `Magnetic` ← Nav (and intended for new CTAs).

**External libs**
- `framer-motion` ← 12 components.
- `gsap` + `gsap/ScrollTrigger` ← Disciplines, Manifesto, SmoothScroll.
- `lenis` ← SmoothScroll.
- `next/image` ← About, BreathHero, Footer, Gallery, Membership, Nav.
- `next/font` ← layout.

**Data / services**
- `lib/content.ts` — canonical content + types (`Discipline`, `Plan`, `ClassSlot`, `Testimonial`,
  `GalleryShot`), consumed by nearly every component + `JsonLd`.
- `lib/sanity.ts` — `fetchOrFallback`, used only by `app/page.tsx`.
- `app/api/contact/route.ts` — Brevo transactional email (Node runtime); consumed by `Contact` via `fetch`.
- `app/opengraph-image.tsx`, `app/sitemap.ts`, `app/robots.ts` — metadata routes (standalone).

## 2. Dependency graph (text)
```
layout.tsx ──> JsonLd ──> content(site, faqs, disciplines)
          └──> content(site), next/font, globals.css

page.tsx ──> sanity.fetchOrFallback ──> (Sanity | content fallback)
        └──> [Nav, BreathHero, Marquee, Manifesto, About, Disciplines, Method,
              Schedule, Membership, PlanCalculator, Voices, Faq, Gallery, Contact,
              Footer, Cursor, Ambient, ScrollProgress, SmoothScroll, CommandPalette,
              IntroCurtain, WhatsAppFab]

Reveal  <── About, Contact, Faq, Membership, Method, PlanCalculator
Magnetic<── Nav
content <── (almost everything)
SmoothScroll ──> lenis + gsap/ScrollTrigger
Disciplines, Manifesto ──> gsap/ScrollTrigger
Contact ──fetch──> /api/contact ──> Brevo (or fallback)
```

## 3. Coupling assessment
| Observation | Type | Note |
|---|---|---|
| `lib/content.ts` is imported almost everywhere | **High fan-in (good)** | Single source of truth; intended. Keep typed; don't bloat into logic. |
| `Reveal` reused by 6 sections | Healthy reuse | Extend (not fork) for new sections. |
| Section organisms are **independent** (no cross-section imports) | **Low coupling (good)** | Easy to add/remove/reorder in `page.tsx`. |
| `framer-motion` in 12 files | Lib coupling | Acceptable; unify via motion tokens (`08/10`). |
| Animation duplicated (each comp re-declares easing/duration) | **Minor duplication** | → tokenise (`08 §11`) to DRY. |
| No shared `Button`/`Tag`/`Field` atoms yet | **Simplification opp.** | New work adds these atoms so Contact/Newsletter/PromoBar/StickyCta share one button + field. |

## 4. Simplification opportunities (no rewrite)
1. **Extract atoms** — `Button`, `Tag/Chip`, `Field` (label+input+status) so Contact, Newsletter, and the
   new CTAs share one implementation (consistency + a11y in one place).
2. **Tokenise motion** — replace per-file easing/duration literals with `08 §11` tokens incrementally.
3. **A `useReducedMotion` + `useInView` hook** — centralise the repeated reduced-motion/observer logic
   (BreathHero, Manifesto, Stats-to-be) instead of re-implementing per component.
4. **Keep section independence** — do **not** introduce cross-section imports; mount order stays in `page.tsx`.

## 5. New components — where they attach
| New | Imports | Mounted in |
|---|---|---|
| `PromoBar` | content(offer), (framer) | `page.tsx` top |
| `StickyCta` | content(site, offer) | `page.tsx` end |
| `Stats` | content(stats), new `useInView` | `page.tsx` after hero |
| `Newsletter` | new `Field`/`Button`, fetch→`/api/subscribe` | `page.tsx` before Faq |
| `StartHere` | content(disciplines intentions) | `page.tsx` after About |
| `Lightbox` | (framer) | inside `Gallery` |
| `Quote` | content(quote) | `page.tsx` |
| `SoundToggle` | — (audio asset) | chrome (optional) |
All depend on `lib/content.ts` for copy and (optionally) the new shared atoms — preserving the existing
low-coupling, high-fan-in-to-content shape.
