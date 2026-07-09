# 04 — HOMEPAGE (9-section DOM, no 3D yet)

## PURPOSE
Rebuild the homepage IN PLACE as a complete, fast, DOM-only page (D012 branch-as-flag —
the branch preview is the review surface; no runtime flag, no legacy copy). The 3D scene
arrives in 07; this page must already be shippable without it. This task also establishes
the route-group architecture (E-002).

## INPUTS
- `02_CONTENT_SYSTEM.md` COMPLETE (all data from `website/content/`).
- `03_DESIGN_SYSTEM.md` COMPLETE (semantic tokens).
- `website/app/page.tsx` (old homepage — replaced by this task; git history is the archive).

## OUTPUTS
- Route groups per `00_MASTER_EXECUTION.md` → ARCHITECTURE BASELINE:
  `app/(marketing)/layout.tsx` (Lenis, ScrollProgress, cursor slot, Nav, Footer,
  WhatsAppFab, StickyCta — moved out of root layout), root `layout.tsx` slimmed to
  fonts + ThemeProvider + JsonLd + skip link.
- All existing route folders moved into `(marketing)/` (URLs unchanged — verify).
- `website/app/(marketing)/page.tsx` — the new homepage.
- `website/components/home/` — new section components.
- Old homepage-only components DELETED in this task once nothing imports them
  (Marquee, StatsBand, TrustBadges, PromoBar if unused — verify via import grep before
  each deletion; `BreathHero.tsx` survives until 07 extracts the breath clock).

## SECTION ORDER (exact — D001 three acts)

| # | Act | Component | Data source | Rules |
|---|---|---|---|---|
| 1 | I | `Hero` | `content/site`, `content/offers` | H1 = LCP element, transform-only entrance; CSS gradient backdrop; slot for Silhouette (07) — until then reuse breath-canvas visual extracted from old BreathHero |
| 2 | I | `AboutStrip` | `content/site`, `content/founder` | short manifesto + founder pull-quote |
| 3 | I | `Programs` | `content/programs` | 6 disciplines; keep existing horizontal-scroll pattern from `Disciplines.tsx` (reuse/adapt, don't rewrite) |
| 4 | II | `Benefits` | `content/statistics` | outcome-led band; render a stat ONLY if `verified: true`; unverified → render benefit copy without numbers |
| 5 | II | `Trainer` | `content/founder`, `content/trainers` | founder + guru photos (`public/guru/`); placeholder-labeled bio ok |
| 6 | III | `Voices` | `content/testimonials` | REAL quotes only; array empty → section renders NOTHING (no empty state on home) |
| 7 | III | `GalleryPreview` | `content/gallery` | 6 images, depth treatment later (05) |
| 8 | III | `FinalCta` | `content/offers`, `content/schedule` | ₹99 offer + `BatchPickerCta` |
| 9 | — | Footer (shared) | `content/*` | newsletter form moves here; FAQ/blog/events become footer links |

`BatchPickerCta` (new, `components/home/BatchPickerCta.tsx`): select of batch times from
`content/schedule` → builds prefilled WhatsApp deep link via existing `lib/links.ts`
`waHref()` ("Namaste — I'd like to join the <time> batch under the ₹99 first-week offer").
No backend. If schedule content is placeholder → plain WhatsApp CTA without picker.

## FILES ALLOWED
- `website/app/**` (route-group restructure + new homepage)
- `website/components/home/**` (new)
- `website/components/Footer.tsx`, `Nav.tsx` (consolidation/moves)
- Deletion of verified-unimported old components
- STATUS/CHANGELOG/PLACEHOLDERS/DECISIONS(EVOLUTION LOG if structure evolves further).

## FILES FORBIDDEN
- `lib/` logic, `api/`, auth, supabase, 3D, cursor internals.

> **Amended (IN-002, E-004 in DECISIONS.md):** `lib/nav.ts` (one new footer link
> row, required by step 5) and `lib/i18n/translations.ts` (one Hindi entry for
> that new label, required to keep the existing translation-completeness test
> green) — both small, mechanical, directly required by this task's own steps.
> `components/Nav.tsx` and `components/PromoBar.tsx` also needed a small fix
> beyond "toggle placement only" — see E-004 (a real click-interception bug
> caught by the existing Playwright suite, not a cosmetic change).

## STEPS
1. Route-group restructure FIRST, homepage untouched: create `(marketing)/layout.tsx`,
   move providers out of root layout, move route folders in. Build green + Playwright
   smoke (existing pages render at same URLs) BEFORE any homepage work. Commit separately.
2. Replace `page.tsx` content with the new 9-section homepage skeleton, then build
   sections in order. After EACH section: `npm run build` stays green; commit per section.
3. All copy from `content/`; anything missing → placeholder protocol (PH entry + label).
4. Every section: semantic tokens only, `<section>` with `aria-labelledby` h2 (except Hero h1),
   mobile-first layout, no fixed heights that can shift (CLS).
5. Footer consolidation: Newsletter form into Footer, FAQ/Journal/Events links added.
6. Trainer section: restores the section removed in the parked diff — content from
   `content/trainers.ts`, not the old hardcoded array.
7. Deletion sweep: for each replaced component run the import grep; unimported → delete
   in one dedicated commit (clean revert point).

## VALIDATION
- Standard block.
- All 9 sections render, both themes, 375px and 1440px widths, no horizontal overflow
  (check `document.body.scrollWidth <= innerWidth`).
- Every pre-existing route still renders at its old URL (route-group move is invisible).
- Playwright: add `e2e/home.spec.ts` — sections present, CTA link contains `wa.me`.
- `npx knip` (or import grep) — zero orphaned components at task end.

## IF VALIDATION FAILS
Section-by-section rollback: each section is one commit; revert the failing one, fix, recommit.

## CHECKPOINT
Commits: route-groups · per section · deletion sweep. Final:
`feat(rebuild): 04 homepage — 9-section DOM, route-group architecture`

## STOP CONDITION
Phase 2 gate. STATUS gate report + rebase → auto-continue (D011).

## NEXT
`05_MOTION_SCROLLSTORY.md`
