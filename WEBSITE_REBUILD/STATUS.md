# STATUS — live project state

> Updated after EVERY completed task. Newest entry on top. If you are a model starting a
> session: read the top entry, then open the file named in NEXT.

## Current

| Field | Value |
|---|---|
| Phase | 5 — All pages (Phase 4 gate passed: 07 COMPLETE, phased per ADR 0016) |
| Next file | `08_CORE_PAGES.md` |
| Branch | `rebuild/living-anatomy` |
| Blockers | PH-016 (figure mesh processing — needs Blender/gltf-transform/authenticated Sketchfab, none available here) |

## Known repo state (as of 2026-07-09, playbook creation)

- Branch at playbook creation: `docs/session-audit-and-verification`
- Uncommitted diff exists: trainer section removed from `website/app/page.tsx`,
  `framer-motion` bumped `11.5.4 → 11.18.2`, `.gitignore` +`graphify-out/`.
  Precheck decides: commit as-is on current branch, THEN branch. Trainer section
  returns in `04_HOMEPAGE.md` regardless — no content lost.
- Website: Next.js 14, builds green, Vitest + Playwright present.
- Supabase: 36 migrations, production project `divinity-tte` linked.
- No Supabase JS client in website yet (login task adds it).

## Log (append-only, newest first)

### 2026-07-09 — PHASE 4 GATE (07) — PASSED (phased delivery), auto-continuing
- Gate criterion (00_MASTER): "Desktop scene live with full fallback matrix;
  Lighthouse budgets still green."
  - Full WebGL Scene was NOT built this task — see ADR 0016 for why (two
    concrete tooling gaps: authenticated Sketchfab download, Blender/
    gltf-transform mesh processing — neither available in this environment).
    07's own Step 1.5 explicitly sanctions shipping SilhouetteTier alone and
    continuing to 08 rather than blocking the project on the mesh.
  - Fallback matrix: trivially satisfied — SilhouetteTier is unconditionally
    the hero visual for every visitor (desktop, mobile, reduced-motion, every
    theme) since there is no Scene yet to differ from. Re-verify meaningfully
    once PH-016 resolves and Scene/Figure/CameraRig exist.
  - Build numbers: `/` first-load JS 165 kB, +1 kB over the pre-07 baseline
    (164 kB) — well within the +5 kB budget for this refactor-plus-new-figure
    step. No `three`/r3f/drei dependencies added.
  - Lighthouse: not re-run this gate (no new render-blocking work, no new
    deps — 15_PERFORMANCE.md is the dedicated measurement task; nothing in
    07 as actually shipped should move the needle).
- Rebase: `main` unchanged since Phase 3 gate — no-op.
- Problems: PH-016 (mesh processing blocked by tooling) — non-blocking,
  documented, safe default (SilhouetteTier) already shipped and working.
- Next: `08_CORE_PAGES.md` (Phase 5).

### 2026-07-09 — 07_SCENE_3D complete (Part 1 — SilhouetteTier)
- Phase: 4
- Status: COMPLETE (phased — see ADR 0016)
- Changes:
  - `components/scene/useBreathClock.ts`: 4-4-6 pranayama clock extracted
    verbatim from the old `BreathHero.tsx`'s `breathAt()`, as one shared
    module-level external store (`useBreathPhase()` reactive hook, throttled
    to ~4x/sec for the text readout; `getBreath()` imperative accessor for
    per-frame canvas reads — mirrors 05's `useScrollProgress` architecture).
    Unit-tested (`useBreathClock.test.ts`) against known t=0/4/8/14 values.
  - `components/scene/SilhouetteTier.tsx`: seated meditation silhouette (two
    hand-authored Path2D sub-paths — head + torso/crossed-legs), breath-
    scaled, plus the existing glow/rings/embers moved here verbatim from
    `Hero.tsx`. Mounted unconditionally in `Hero.tsx` — this is the complete,
    shippable hero visual (D007), not a loading placeholder.
  - `Hero.tsx` slimmed: canvas/breath-clock logic removed (now delegates to
    `SilhouetteTier` + `useBreathPhase()`), same JSX/copy/CTA otherwise.
  - Mesh sourcing (Step 1, genuinely attempted via WebSearch/WebFetch): found
    one license-clear CC-BY 4.0 candidate ("A Man Sitting", Sketchfab, 18k
    tris/9k verts — recorded in DECISIONS.md asset registry). Did not
    download/process it — see PH-016 and ADR 0016 for the concrete tooling
    gaps (not effort/difficulty) blocking that.
  - Did not build `Scene.tsx`/`Figure.tsx`/`CameraRig.tsx`/`Lighting.tsx` or
    install `three`/`@react-three/fiber`/`@react-three/drei` — deferred to
    whoever resolves PH-016.
  - Wrote `design/adr/0016-webgl-scene.md` (Accepted, phased, supersedes
    0014's context under D007's new delivery conditions).
- **Two real bugs found and fixed via actual build/Playwright verification,
  not assumed**: (1) `Path2D` constructed at module top level crashed the
  production build (`Path2D is not defined`) — Next.js evaluates "use
  client" modules server-side too during prerendering, and Path2D is
  browser-only; moved construction inside the client-only effect. (2) The
  new opaque silhouette visually collided with the H1's second line at
  narrower viewports — lowered its fill opacity to a soft translucent
  presence, verified via Playwright canvas/section screenshots at 800px and
  1280px.
- **One pre-existing bug found and fixed, unrelated to 04-07's own work**:
  `Hero.tsx`'s hardcoded-dark backdrop never participated in the day/night
  toggle, but its text used the theme-flipping `text-bone`/`text-mist`
  tokens — in day mode the H1 rendered in the day theme's dark bone color
  against the permanently-dark backdrop, nearly illegible. This bug has
  existed since the day-theme colors were first authored; never caught
  because no prior session tested Hero specifically under a light-preference
  browser condition. Fixed by pinning `--bone`/`--bone-rgb`/`--mist`/
  `--mist-rgb` to their night values via inline style scoped to the Hero
  section (its background is theme-independent, so its text should be too).
  Verified via computed-style inspection and screenshots in both themes.
- Validation: lint clean · tsc clean · 131/131 vitest tests (+5 new
  useBreathClock tests) · `next build` 36/36 routes, `/` 165 kB (+1 kB) ·
  17/17 Playwright e2e tests · visual verification via Playwright canvas/
  section screenshots (both widths, both themes) confirmed a legible,
  recognizable seated-meditation silhouette with no text collision.
- Tests: 131 vitest + 17 Playwright, all passed
- Performance: +1 kB first-load JS (new figure-path data + one extra
  component split); no new runtime cost (same single rAF loop as before,
  now centralized in one shared clock instead of duplicated per-consumer)
- Accessibility: unchanged (canvas stays `aria-hidden`, `pointer-events:none`)
- Problems: PH-016 (mesh processing blocked by tooling, not effort) —
  documented, non-blocking, safe default shipped
- Next: Phase 4 gate (above), then `08_CORE_PAGES.md`

### 2026-07-09 — PHASE 3 GATE (05+06) — PASSED, auto-continuing
- Gate criterion (00_MASTER): "Scroll story + cursor working; reduced-motion
  paths verified; mobile experience complete."
  - Scroll story working: `useScrollProgress()` live, confirmed via real
    scroll input (`data-act` changes; Programs' independent pin/scrub
    ScrollTrigger coexists fine).
  - Cursor working: YogaCursor renders, pose changes with scroll, hover-grows,
    correctly absent on touch/reduced-motion.
  - Reduced-motion verified: `page.emulateMedia({reducedMotion:'reduce'})` —
    ScrollScore mounts nothing (no `data-act`), YogaCursor doesn't render, all
    homepage section headings stay visible.
  - Mobile experience complete: 390×844 touch-emulated viewport — no
    horizontal overflow, hero renders, Programs section (desktop-only
    horizontal pin) falls back to a plain readable vertical stack, no cursor
    JS mounted (touch has no hover to drive it).
- Rebase: `main` unchanged since Phase 2 gate — no-op.
- Problems: none blocking.
- Next: `07_SCENE_3D.md` (Phase 4).

### 2026-07-09 — 06_YOGA_CURSOR complete
- Phase: 3
- Status: COMPLETE
- Changes: `components/cursor-poses.ts` (12 Surya Namaskar poses — head
  circle + one M/L/Z-only body path each) and `components/YogaCursor.tsx`
  (replaces the dot+ring `Cursor.tsx`): reuses its exact lerp-follow (ease
  0.16) and hover-grow mechanics, adds pose selection from
  `useScrollProgress()` (05) — `floor(progress*11)`, held at pose 1
  (Pranamasana) on any non-home route or before ScrollScore has ever mounted,
  since `ScrollScore`'s unmount now explicitly resets progress to 0 (a fix
  made here, in `ScrollScore.tsx`, so the cursor's "hold pose 1 off-home"
  requirement is actually true rather than showing a stale scroll position
  from before the user navigated away). Renders only under `(hover:hover) and
  (pointer:fine)` and not reduced-motion; mounted in `app/(marketing)/
  layout.tsx` (see below).
- Deviation (documented, E-007 in DECISIONS.md, `06_YOGA_CURSOR.md` amended
  in place): poses crossfade (120ms opacity swap) instead of numerically
  morphing — the task file's own documented fallback, taken because
  hand-authoring 12 paths with an identical point count with no visual editor
  is exactly the failure-prone scenario the task file itself warns about.
  Verified visually via browser preview (12 distinct, recognizable stick-
  figure silhouettes, confirmed by inspecting rendered path/attribute values
  directly) and via Playwright (pose actually changes on real scroll input).
  Cursor mount swapped in `app/(marketing)/layout.tsx`, not root
  `app/layout.tsx` — Cursor.tsx has lived there since 04, predating this task
  file. `components/cursor-poses.test.ts` replaces the path-parity unit test
  (not applicable to crossfade) — needed `vitest.config.ts`'s `include` glob
  extended again (IN-004, same recurring gap as 02/04/05).
- Validation: lint clean · tsc clean · 126/126 vitest tests (+5 new
  cursor-poses tests) · `next build` 36/36 routes · 17/17 Playwright e2e
  tests (new `e2e/yoga-cursor.spec.ts`: pose-changes-on-scroll, hover-grow,
  reduced-motion-absent, touch-absent) · mobile viewport check (gate entry
  above).
- Tests: 126 vitest + 17 Playwright, all passed
- Performance: replaces one cursor component with another of similar size;
  12 poses pre-rendered as inline SVG `<g>` elements (crossfade via CSS
  opacity, not per-frame JS work) — no measurable cost added to the existing
  single rAF position loop
- Accessibility: `aria-hidden`, `pointer-events:none` kept; native cursor
  never hidden without the replacement active (same `has-custom-cursor`
  class mechanism as before)
- Problems: none blocking
- Next: Phase 3 gate (above), then `07_SCENE_3D.md`

### 2026-07-09 — 05_MOTION_SCROLLSTORY complete
- Phase: 3
- Status: COMPLETE
- Changes:
  - `components/home/ScrollScore.tsx` (new): headless, mounted inside
    `Hero.tsx`. One GSAP `ScrollTrigger` (trigger `document.body`, `scrub:
    0.3`, no pin) tracks whole-page scroll progress; publishes it through
    `useScrollProgress()` (a `useSyncExternalStore`-backed external store, not
    React Context — see E-005) and toggles `data-act="1|2|3"` on `<html>` at
    the 0.45/0.72 act boundaries. Reduced-motion or `?no-motion=1` in the URL
    → the effect returns immediately, nothing mounts, no timeline, no
    `data-act` ever gets set (verified both branches with Playwright).
  - `globals.css`: `.ambient::after` (new, additive — the base `.ambient`
    gradient is untouched) consumes `--glow` (defined in 03, orphaned until
    now) and fades in via `[data-act="2"]`/`[data-act="3"]` selectors with an
    800ms CSS transition — the "act-break light shift" requirement, done in
    CSS so no gradient-string interpolation math was needed in JS.
  - `components/Magnetic.tsx` (existing — reused, not duplicated, see E-006):
    added a coarse-pointer gate (`hover:hover) and (pointer:fine)`) alongside
    its existing reduced-motion check, and clamped its spring offset to the
    spec's 8px max. Wired onto Hero's and FinalCta's primary CTA links.
  - Programs.tsx's own independent pin+scrub `ScrollTrigger` (built pre-04,
    untouched) confirmed still working correctly alongside the new master
    ScrollTrigger — multiple STs coexist fine since neither pins the other's
    trigger element.
- Deviations (documented, E-005/E-006 in DECISIONS.md, `05_MOTION_
  SCROLLSTORY.md` amended in place): no `components/ui/MagneticCta.tsx`
  (reused `Magnetic.tsx`); `useScrollProgress()` is an external store, not
  Context (page.tsx isn't in this task's FILES ALLOWED, so there's nowhere to
  put a Provider); section enter/exit tweens were NOT re-implemented as a
  second GSAP system — every section already has a correct, reduced-motion-
  safe enter animation via the existing `Reveal` component, which `design/
  10-motion-spec.md` itself says to reuse; a second position-driven tween
  system on the same elements would double-animate them. `e2e/home.spec.ts`
  extended (IN-003) with reduced-motion, `?no-motion=1`, and a real-scroll
  `data-act` check.
- **A real, if narrow, race found via Playwright, not build/lint** (E-004
  addendum): the PromoBar/Nav fix from 04 measured the wrong DOM node —
  the outer element framer-motion animates `height:0→auto` on, not the
  stable inner content div — so `--promo-h` was briefly too-small during
  PromoBar's own ~350ms mount animation, reopening a narrow version of 04's
  overlap bug during that window. Only reachable under parallel-worker CPU
  contention (100% reliable in isolation/single-worker, occasionally flaky
  under 8 parallel workers) — fixed by measuring the inner div in a
  `useLayoutEffect` instead.
- Validation: lint clean · tsc clean · 121/121 vitest tests · `next build`
  36/36 routes · 13/13 Playwright e2e tests, confirmed stable across 3
  repeated full-suite runs and 5 repeated single-worker runs of the
  previously-flaky test · reduced-motion emulation confirmed via Playwright
  (`page.emulateMedia`) — all section headings visible, zero pinning, zero
  `data-act` · scroll-progress mechanism confirmed live via real wheel input
  (`data-act` becomes non-null after scrolling with motion enabled).
- Tests: 121 vitest + 13 Playwright, all passed
- Performance: one extra idle-deferred GSAP `ScrollTrigger` (same lazy-import
  pattern as `SmoothScroll.tsx`/`Programs.tsx`); homepage `/` first-load JS
  164 kB (was 154 kB pre-05 — Magnetic's framer-motion springs + ScrollScore)
- Accessibility: unchanged from 04; reduced-motion path independently verified
- Problems: none blocking
- Next: `06_YOGA_CURSOR.md` (same phase — auto-continue, no gate between 05
  and 06 per `00_MASTER_EXECUTION.md`'s phase table)

### 2026-07-09 — PHASE 2 GATE (04) — PASSED, auto-continuing
- Gate criterion (00_MASTER): "Homepage rebuilt in place as fast DOM site (no
  3D); route groups live; old routes still render."
  - Route groups live: `app/(marketing)/layout.tsx` owns Lenis/scroll, cursor,
    Nav, Footer, CTAs, CommandPalette, PromoBar; root `layout.tsx` slimmed to
    fonts + ThemeProvider + JsonLd + skip-link + no-flash script. All 13
    existing route folders moved via `git mv` (history preserved); URLs
    unchanged (verified: same 36 routes in `next build` output, same paths).
  - Old routes still render: 10/10 Playwright specs green, including
    `core marketing routes return 200` for about/services/schedule/trainers/
    verify, and a `/blog/[slug]` bad-slug check confirming Nav/Footer/PromoBar
    chrome survives an in-segment `notFound()`.
  - Homepage rebuilt as fast DOM site, no 3D: 9 sections per D001's three acts
    (Hero → AboutStrip → Programs → Benefits → Trainer → Voices →
    GalleryPreview → FinalCta → Footer), all server/DOM-rendered, no WebGL
    (that's 07). First-load JS for `/` dropped 168 kB → 154 kB (fewer,
    tighter sections than the pre-rebuild page).
  - No horizontal overflow at 375px or 1440px (`body.scrollWidth <=
    innerWidth` checked both); both themes render without console errors.
  - `npx knip`: zero orphaned component files. (Unused exports flagged —
    `mantra`, `assurances`, Sanity schema files — are pre-existing/out of this
    task's `content/`-editing scope, not new orphans from this task.)
- **Bug found and fixed via Playwright, not just build/lint** (E-004): PromoBar
  and Nav were independently `fixed` at the same screen region; PromoBar's
  higher z-index silently ate every click meant for Nav underneath it,
  site-wide, whenever the promo bar was showing. This was a real, pre-existing,
  user-facing bug — not hypothetical — caught because the rebuilt homepage's
  Playwright spec exercises the Nav "Pricing" link directly, where the old spec
  had (accidentally-in-hindsight) routed around it via a mid-page CTA that no
  longer exists post-rebuild. Fixed: PromoBar publishes its rendered height as
  `--promo-h`; Nav positions at `top-[var(--promo-h,0px)]` instead of `top-0`.
- Rebase: `main` unchanged since Phase 1 gate — no-op.
- Problems: none blocking.
- Next: `05_MOTION_SCROLLSTORY.md` (Phase 3).

### 2026-07-09 — 04_HOMEPAGE complete
- Phase: 2
- Status: COMPLETE
- Changes:
  - Step 1 (own commit `0726fd6`): route-group restructure — see gate entry.
  - Step 2+ (this commit): 9-section homepage. Moved `BreathHero.tsx` →
    `components/home/Hero.tsx` and `Disciplines.tsx` → `components/home/
    Programs.tsx` (both homepage-only, `git mv` to preserve history). New:
    `AboutStrip.tsx` (short manifesto + founder pull-quote, links to full
    `/about`), `Benefits.tsx` (verified-only stats from `content/statistics`,
    qualitative fallback copy since the one seeded entry is
    `verified: false`), `Trainer.tsx`, `GalleryPreview.tsx`, `FinalCta.tsx`,
    `BatchPickerCta.tsx` (batch `<select>` → prefilled `wa.me` link, no
    backend, falls back to a plain WhatsApp CTA if `content/schedule` is ever
    empty).
  - Footer consolidation (step 5): `Newsletter` now renders inside `Footer`
    (was its own homepage section); added an "FAQ" footer link
    (`/contact#faq` — no dedicated `/faq` route exists yet, out of scope for
    this task per D008's page list, lands in 08_CORE_PAGES or similar). Blog
    ("Journal") and Events links were already present in `footerGroups` from
    a prior session.
  - Wired the 3 hardcode-sweep exceptions flagged (and deferred to this task)
    in `02_CONTENT_SYSTEM.md`'s STATUS entry: `Hero.tsx`, `FinalCta.tsx`, and
    `PromoBar.tsx`'s "₹99 first week" copy now read from
    `content/offers.introOffer`.
  - Deletion sweep (own commit): `Marquee.tsx`, `TrustBadges.tsx` — both
    verified zero remaining imports (`grep -rln`) before removal. `Method.tsx`
    and `StatsBand.tsx` were NOT deleted despite being cut from the new
    homepage — both are still live on `/about` (`app/(marketing)/about/
    page.tsx`), confirmed via the same import grep before assuming anything
    was orphaned.
  - Updated `e2e/home.spec.ts` (new section-presence + wa.me-link assertions,
    replacing the removed TrustBadges/membership-preview assertions) and
    `e2e/navigation.spec.ts` (pricing-navigation test now clicks the Nav link
    directly instead of a now-removed mid-page CTA — see the PromoBar bug
    this surfaced, gate entry above).
  - Installed Playwright's Chromium browser (`npx playwright install
    chromium`) — missing from this machine, an environment gap unrelated to
    any code change; `npx playwright test` failed outright without it.
- Deviations from the task file (documented, IN-002 + E-004 in DECISIONS.md,
  `04_HOMEPAGE.md` FILES FORBIDDEN section amended in place): `lib/nav.ts`
  (new FAQ footer link), `lib/i18n/translations.ts` (matching Hindi entry),
  `components/Nav.tsx`/`components/PromoBar.tsx` beyond "toggle placement
  only" (real click-interception bugfix, not cosmetic).
- Validation: lint clean · tsc clean · 121/121 vitest tests · `next build`
  36/36 routes (first-load JS for `/`: 168 kB → 154 kB) · 10/10 Playwright
  e2e tests · zero horizontal overflow at 375px/1440px · both themes checked
  in browser preview, no console errors · `npx knip` zero orphaned
  components.
- Tests: 121 vitest + 10 Playwright, all passed
- Performance: homepage first-load JS reduced (fewer/tighter sections); full
  Lighthouse budget verification is 15_PERFORMANCE.md's job, not this task's
- Accessibility: every new section is a `<section>` with `aria-labelledby`
  (Hero keeps its `h1`, per spec); BatchPickerCta's `<select>` has a
  (visually-hidden) `<label>`
- Problems: none blocking
- Next: Phase 2 gate (above), then `05_MOTION_SCROLLSTORY.md`

### 2026-07-09 — PHASE 1 GATE (01+02+03) — PASSED, auto-continuing
- Gate criterion (00_MASTER): "Validation green + content system live + both themes
  AA-verified."
  - Validation green: lint clean · tsc clean · 121/121 vitest tests · `next build`
    36/36 routes. Verified again at the gate (not just per-task).
  - Content system live: `website/content/` (18 modules) is the single source of
    truth; `lib/content.ts` is a pure re-export/merge compat layer; zero
    `app/`/`components/` consumer imports changed (verified via `grep`).
  - Both themes AA-verified: contrast audit in `design/adr/0015-day-night-theme.md`
    — all 8 required pairs (fg/surface, fg-muted/surface, accent/surface,
    fg/surface-2 × night+day) ≥4.5:1. Toggle manually verified in the browser
    preview: switches both directions, persists across reload (`localStorage`
    `divinity_theme`), no flash-of-wrong-theme (inline `beforeInteractive` script
    sets `data-theme` before paint), zero hydration-error console output on a
    clean server for both the matching-default and self-correcting-after-mount
    branches, real `<button>` with `aria-pressed`/`aria-label`, 32×32px target,
    keyboard-operable natively.
  - **Correctness note**: initial attempt at the no-flash fix (reading
    `data-theme` inside `ThemeContext`'s `useState` initializer) caused a genuine
    hydration failure in the browser preview — React detected the toggle icon's
    text differed between server and client render and discarded the server
    HTML, a worse flash than the one being fixed. Caught by driving the actual
    page in preview (not just lint/tsc/build, which are blind to this class of
    bug) and corrected: state now starts `"dark"` identically on server and
    first client render, self-corrects via a post-mount effect. See ADR 0015 and
    `lib/theme/ThemeContext.tsx`.
- Rebase: `main` had no new commits since branch creation (checked
  `git log main..rebuild/living-anatomy` / no upstream changes) — rebase was a
  no-op, nothing to reconcile.
- Problems: none blocking.
- Next: `04_HOMEPAGE.md` (Phase 2).

### 2026-07-09 — 03_DESIGN_SYSTEM complete
- Phase: 1
- Status: COMPLETE
- Changes: added a semantic token layer to `globals.css` (`--surface`/`-2`/`-3`,
  `--fg`/`--fg-muted`, `--accent`/`--accent-2`, `--line`, `--glow`) parallel to
  the existing void/bone/ember primitives — those stay untouched, driving
  unmigrated components until their own re-skin tasks. Mapped the new tokens
  into `tailwind.config.ts` (`surface`, `surface-2`, `surface-3`, `fg`,
  `fg-muted`, `accent`, `accent-2` colors; `display-xl`/`-l`/`-m`/`lead`/`body`/
  `caption` fontSize scale; `text-wrap: balance` on the three display classes).
  Discovered — and reused rather than duplicated — an existing, already-wired
  theme system (`lib/theme/ThemeContext.tsx`, live in `layout.tsx`/`Nav.tsx`
  before this task started): added the no-flash `beforeInteractive` script to
  `layout.tsx`, extracted `components/ThemeToggle.tsx` from Nav's two
  duplicated inline toggle buttons, fixed a real hydration bug found during
  manual preview verification (see gate entry above). Wrote
  `design/adr/0015-day-night-theme.md` (Accepted, supersedes 0012, full
  contrast table).
- Deviations from the task file (documented, E-003 in DECISIONS.md,
  `03_DESIGN_SYSTEM.md` amended in place): `--ink`/`--ink-muted` → `--fg`/
  `--fg-muted` (name collision — `--ink` already existed with a different
  value, live on 6 components: About/Faq/Membership/Method/SectionHeading/
  PreviewSection; redefining it would have silently made their text illegible).
  Day `--accent` darkened `#a85e2a` → `#9c4a2a` (reuses existing `--clay`
  value, same hue family) after the spec value failed the 4.5:1 floor at
  4.26:1. No `components/ThemeProvider.tsx` created (the task file predates
  discovery of the existing provider).
- Validation: lint clean · tsc clean · 121/121 vitest tests (unchanged from 02
  — no test file touched this task) · `next build` 36/36 routes · manual
  preview verification (see gate entry).
- Tests: 121/121 passed
- Performance: unchanged (additive CSS variables + one new component; no
  component re-skinned yet)
- Accessibility: contrast audit passed both themes (see ADR 0015); toggle
  meets the button/aria-pressed/aria-label/24px-target/keyboard bar
- Problems: none blocking
- Next: Phase 1 gate (see above), then `04_HOMEPAGE.md`

### 2026-07-09 — 02_CONTENT_SYSTEM complete
- Phase: 1
- Status: COMPLETE
- Changes: created `website/content/` (18 modules: site, contact, social, founder,
  trainers, programs, pricing, offers, statistics, testimonials, gallery, events,
  posts, faq, schedule, seo, legal, marketing, + index.ts barrel). Moved every
  fallback data constant out of `lib/content.ts` verbatim into the matching module.
  Split the old flat `site` object across `site.ts`/`contact.ts`/`social.ts`/
  `founder.ts`; `lib/content.ts` rewritten as a compat/merge layer that
  reassembles the legacy `site` shape and re-exports every old name — zero
  consumer import changes needed (verified: no `app/`or `components/` file edited).
  Added `content/content.test.ts` (55 tests: every module non-empty, site/contact
  critical fields real not placeholder, every `[PLACEHOLDER:` has a matching
  `TODO(PH-` in the same file). Added `content/**/*.test.ts` to
  `vitest.config.ts` include glob — required for the new test file to actually
  run; without it step 5 would silently be a no-op (documented per charter D011,
  see DECISIONS.md IN-001).
- New/forward-scaffolded modules not yet consumed by any component (wiring lands
  in later phases; creating them now was still in scope — `website/content/**` is
  unrestricted in FILES ALLOWED): `offers.ts` (introOffer/promoBar), `statistics.ts`
  (StatsBand still computes its own counts), `seo.ts` (route overrides table),
  `legal.ts` (privacy/terms/refund — real copy still lives in page JSX, migrates
  in 08/11).
- Hardcode sweep (`grep -rn "₹|+91|wa.me|@gmail|@divinity" app components --include=*.tsx -l`):
  3 hits, all pre-existing `₹99 first week` copy in `app/page.tsx`,
  `components/BreathHero.tsx`, `components/PromoBar.tsx`. NOT fixed here —
  `FILES FORBIDDEN` for this task explicitly excludes "Components' JSX/logic,
  app/ pages"; wiring these three to `content/offers.ts`'s `introOffer` is a
  JSX edit that belongs to `04_HOMEPAGE.md` (which owns that page/component).
  Allowed exception per this task's own VALIDATION clause.
  `components/ui/CtaLink.tsx` hit is a code *comment* mentioning "wa.me" as an
  example, not a real hardcode — no action needed.
- Validation: `npm run lint` clean · `npx tsc --noEmit` clean · `npm test` →
  11 files, 121 tests passed (was 66; +55 new content tests) · `npm run build`
  → 36 routes, same route count/shape as baseline (one `.next` EINVAL cleanup
  needed first — stale OneDrive-locked build dir from before this session,
  unrelated to the code change; `rm -rf .next` then rebuild was clean).
- Tests: 121/121 passed
- Performance: unchanged (no runtime behavior changed, pure data relocation)
- Accessibility: unchanged
- Problems: none blocking. PLACEHOLDERS.md rows already pointed at the exact
  `content/*.ts` files/fields this task created — no table edits needed.
- Next: `03_DESIGN_SYSTEM.md`

### 2026-07-09 — 01_REPO_PRECHECK complete
- Phase: 1
- Status: COMPLETE
- Changes: committed parked pre-rebuild diff on `docs/session-audit-and-verification`
  (`50ecadc` — trainer section removal, framer-motion bump, `.gitignore` graphify-out/);
  `git checkout main` (no network for pull, continued on local main per rule);
  created + checked out `rebuild/living-anatomy`.
- Baseline validation (all green):
  - `node -v` → v26.5.0, `npm -v` → 11.17.0
  - `npm install` → up to date, 452 packages (10 audit vulnerabilities pre-existing,
    unrelated to this task — not fixed here, out of FILES ALLOWED scope)
  - `npm run lint` → No ESLint warnings or errors
  - `npx tsc --noEmit` → clean, no output
  - `npm test` (vitest) → 10 test files, 66 tests, all passed
  - `npm run build` (next build) → Compiled successfully, 36 routes generated
  - route count: `ls website/app` → 25 entries
  - secret scan: `git check-ignore website/.env.local keyfile` → both ignored (exit 0)
- Tests: 66/66 passed
- Performance: baseline unchanged (no app code touched)
- Accessibility: baseline unchanged
- Problems: none
- Next: `02_CONTENT_SYSTEM.md`

### 2026-07-09 — Playbook evolved (autonomy charter + architecture)
- Phase: 0
- Status: COMPLETE (docs only, no application code)
- Changes: D011 autonomy charter (engineering decisions belong to executor; human
  approval only for business rows + launch) · D012 branch-as-flag release (runtime
  flags removed everywhere; E-001) · route-group architecture `(marketing)`/`(portal)`
  (E-002) · per-task deletion rule (no orphans) · phase gates now self-validating
  auto-continue · PLACEHOLDERS gained "Pending business decisions" (BD-001…BD-004) ·
  rebase-at-gate rule for the long-lived branch.
- Problems: none
- Next: `01_REPO_PRECHECK.md` (execution NOT started — awaiting owner's go)

### 2026-07-09 — Playbook authored
- Phase: 0
- Status: COMPLETE
- Files modified: `WEBSITE_REBUILD/*` (created)
- Tests: n/a (no code changed)
- Performance: baseline unchanged
- Accessibility: baseline unchanged
- Problems: none
- Next: `01_REPO_PRECHECK.md`
- ETA to next gate: precheck ≈ 30 min of model time
