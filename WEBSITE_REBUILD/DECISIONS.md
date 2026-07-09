# DECISIONS (approved — never re-ask)

| ID | Decision | Status | Detail |
|---|---|---|---|
| D001 | "Living Anatomy" concept | **APPROVED** | One continuous 3D scene, three acts (Body → Breath → Stillness). Homepage is the cinematic flagship; all pages share the design language. Never ask again. |
| D002 | Figure mesh source | **APPROVED** | CC/licensed base mesh (fast, free). Do NOT wait for a commissioned sculpt. Verify license before use; uniqueness comes from art direction (materials, lighting, breath animation, flow lines). Commissioned sculpt may replace it post-launch. |
| D003 | Student login on website | **APPROVED** | Reuse existing Supabase auth. Same account, same database, no duplicate auth/profiles/business logic. Students only. |
| D004 | Flutter Web integration | **APPROVED** | After login, student dashboard hosts the Flutter Web app so it feels part of the website. See `13_FLUTTER_WEB.md` for the two-stage approach (link-out first, embed second). |
| D005 | Centralized content system | **APPROVED** | Every editable business fact lives in `website/content/*.ts` (typed modules, Sanity can override). One-file edits propagate site-wide. Never hardcode. |
| D006 | Day/night theme | **APPROVED** | Supersedes website ADR 0012 (no-theme-toggle). Two-layer theming: CSS semantic tokens + 3D scene lighting presets. Persisted, defaults to `prefers-color-scheme`. |
| D007 | WebGL on the homepage | **APPROVED** | Supersedes website ADR 0014 (2D-only hero). Conditions: three+r3f loads AFTER LCP as a deferred chunk; 2D silhouette tier serves mobile / reduced-motion / no-WebGL / low-memory; Lighthouse CI gates enforce budgets. |
| D008 | Full-site rebuild scope | **APPROVED** | Every page, not just homepage: Home, About, Founder, Trainers, Programs, Therapeutic Yoga, Meditation, Membership, Pricing, Schedule, Events, Gallery, Testimonials, FAQ, Blog, Contact, Certificate Verification, Privacy, Terms, Refund, Sitemap. |
| D009 | Performance floor | **APPROVED** | Lighthouse desktop ≥95, mobile ≥90, LCP <2.0s, CLS <0.05, INP <150ms. Non-negotiable; effects that can't fit use their fallback. |
| D010 | No new auth/analytics/CMS vendors | **APPROVED** | Stack stays: Next.js 14, Supabase, Firebase (app-side), Sanity (optional), Brevo. New npm packages only with clear justification recorded here. |
| D011 | Executor autonomy charter | **APPROVED** | Engineering decisions belong to the executing model (see `99_MODEL_INSTRUCTIONS.md` → Autonomy charter). Objectively better implementations are made immediately and documented in the EVOLUTION LOG below. Human approval only for business decisions (→ `PLACEHOLDERS.md`) and the launch itself. |
| D012 | Branch-as-flag release | **APPROVED** | No runtime feature flags for the rebuild. Build in place on `rebuild/living-anatomy`; preview deployment = review surface; merge = launch; rollback = promote previous deployment. See EVOLUTION LOG E-001. |

## EVOLUTION LOG (documented deviations — the charter's paper trail)

Every replaced approach gets an entry with all four fields. Format:

```
### E-xxx | date | <short title>
- What changed:
- Why it is better:
- What it replaced:
- Trade-offs:
```

### E-001 | 2026-07-09 | Branch-as-flag release strategy
- What changed: rebuild happens in place on the branch; no `NEXT_PUBLIC_NEW_HOME` runtime
  flag, no `home-legacy/` copy; merge = launch.
- Why it is better: zero legacy code in the bundle, no dual-render complexity, no
  flag-drift failure mode, preview deployments already provide the review surface,
  rollback is a one-action deployment promote.
- What it replaced: v1 playbook's runtime flag + frozen legacy homepage components.
- Trade-offs: long-lived branch needs periodic rebase onto main (rule added: rebase at
  every phase gate); the old homepage is not togglable at runtime post-merge (git
  history + deployment rollback cover it).

### E-002 | 2026-07-09 | Route-group architecture (marketing / portal split)
- What changed: `app/(marketing)/` owns Lenis/cursor/scroll providers + Nav/Footer;
  `app/(portal)/` gets a minimal layout; root layout keeps only fonts/theme/JsonLd.
- Why it is better: the student portal stops paying for marketing-experience JS
  (smaller, faster app surface); providers live where they're used; clean separation of
  the two products sharing one domain.
- What it replaced: v1 inherited the old site's "everything mounted in root layout".
- Trade-offs: one-time mechanical move of existing route folders into the group
  (URLs unchanged); two layouts to keep consistent for shared chrome (tokens make this cheap).

### E-003 | 2026-07-09 | Reused existing theme system; renamed colliding tokens; fixed a contrast failure
- What changed: `03_DESIGN_SYSTEM.md` assumed no theme system existed and specified new
  `components/ThemeProvider.tsx`/`ThemeToggle.tsx` plus semantic tokens `--ink`/`--ink-muted`.
  Reality (found during execution): `lib/theme/ThemeContext.tsx` already existed, already
  wired into `layout.tsx`/`Nav.tsx`, with working persistence + toggle. Also, `--ink` already
  existed in `globals.css` with a different value, live on 6 components. Changed: reused
  `ThemeContext.tsx` (added a no-flash initial-state fix + inline `beforeInteractive` script),
  added only `ThemeToggle.tsx` as new, renamed the semantic tokens `--ink`/`--ink-muted` →
  `--fg`/`--fg-muted`, and darkened day `--accent` `#a85e2a` → `#9c4a2a` (existing `--clay`
  value) after it failed the 4.5:1 contrast floor at 4.26:1.
- Why it is better: avoids two competing theme providers on one page; avoids silently making
  `About`/`Faq`/`Membership`/`Method`/`SectionHeading`/`PreviewSection` text illegible by
  redefining a CSS variable those un-migrated components already depend on; ships a
  WCAG-AA-passing token set instead of one with a known failing pair.
- What it replaced: `03_DESIGN_SYSTEM.md`'s original (spec-only, unverified-against-repo)
  token names and day-accent value.
- Trade-offs: `--fg`/`--fg-muted` diverge from the task file's original naming (checked 04–19:
  no other task file referenced `--ink` by name, so no further edits needed); the day accent
  is one shade darker than originally speced.

### E-004 | 2026-07-09 | Fixed PromoBar/Nav click-interception bug found via Playwright
- What changed: `PromoBar` was `position: relative` (normal flow) while `Nav` was
  independently `fixed inset-x-0 top-0` — both painted in the same top-of-viewport
  screen region, and PromoBar's higher z-index (350 vs Nav's 300) meant it silently
  captured every click meant for Nav underneath it, site-wide, whenever the promo
  bar was showing. `PromoBar` now measures its own height and publishes it as a
  `--promo-h` CSS variable on `<html>`; `Nav` positions itself at
  `top-[var(--promo-h,0px)]` instead of `top-0`, so the two stack instead of
  overlapping, and Nav's links become clickable again.
- Why it is better: this wasn't a hypothetical — it was caught by the existing
  Playwright suite (`navigates from home to pricing` timed out clicking the Nav
  "Pricing" link; `elementFromPoint` at that link's coordinates resolved to the
  promo bar's own div, not the link). The original test had silently routed
  around it by clicking a mid-page CTA instead of the Nav link, which is why it
  went unnoticed until 04's homepage rebuild removed that mid-page CTA.
- What it replaced: independent fixed positioning with a z-index-only ordering
  (which only controls paint order, not which element "wins" the space it shares
  with another fixed element — both still occupy and capture events for that
  shared region regardless of z-index, whichever paints on top).
- Trade-offs: one `ResizeObserver` + effect in `PromoBar.tsx`; negligible cost.
- **Addendum (05, same day):** the first version measured the outer `m.div` —
  the element framer-motion animates `height: 0 → auto` on — so `--promo-h` was
  briefly wrong (too small) during PromoBar's own ~350ms mount animation,
  reopening a narrow version of the same overlap during that window. Caught by
  intermittent Playwright flakiness on the pricing-nav-click test (passed 100%
  in isolation/single-worker, occasionally failed under parallel load — the
  timing window is only reachable under contention). Fixed by measuring the
  *inner* content div instead (not animated, stable height from first render)
  in a `useLayoutEffect` (runs before paint) rather than `useEffect`.

### E-005 | 2026-07-09 | ScrollScore's useScrollProgress() is an external store, not React Context
- What changed: `05_MOTION_SCROLLSTORY.md` specified `useScrollProgress()` backed by
  React Context. Built it on `useSyncExternalStore` (a module-level subscriber set)
  instead, with `ScrollScore` mounted headlessly inside `Hero.tsx`.
- Why it is better: React Context requires a `<Provider>` ancestor wrapping every
  consumer. The 8 other homepage sections are siblings under `app/(marketing)/
  page.tsx` (04's file, not in 05's FILES ALLOWED), so a Context Provider couldn't
  wrap them without editing `page.tsx`. An external store has no such requirement —
  `useScrollProgress()` works from anywhere, which is also strictly more useful for
  06 (cursor) and 07 (3D camera), neither of which are guaranteed to live inside
  whatever tree a Context Provider would occupy either.
- What it replaced: a Context-based design that was never actually implementable
  within this task's own file boundaries.
- Trade-offs: none functionally — same public API (`useScrollProgress()`), same
  single-writer/many-reader shape.

### E-006 | 2026-07-09 | Reused Magnetic.tsx instead of building a new MagneticCta.tsx
- What changed: `05_MOTION_SCROLLSTORY.md` asked for a new `components/ui/
  MagneticCta.tsx` (spring stiffness 150/damping 15, max offset 8px, disabled on
  coarse pointer + reduced motion). `components/Magnetic.tsx` already existed,
  already used in `Nav.tsx`'s "Begin" CTA, already spring-based (stiffness
  200/damping 15 — close enough, not worth a second spring constant), and already
  disabled itself under reduced motion. It was missing only the coarse-pointer
  gate and the 8px clamp, both added directly to it.
- Why it is better: a second, near-identical hover-follow component would be
  pure duplication — same pattern as E-003 (03_DESIGN_SYSTEM's ThemeProvider).
  `design/10-motion-spec.md` §"Buttons / magnetic CTAs" independently confirms
  "Magnetic (existing Magnetic)" is the intended component, not a new one — the
  task file's instruction to create `MagneticCta.tsx` predates that spec doc or
  didn't cross-reference it.
- What it replaced: the task file's `components/ui/MagneticCta.tsx` (not created).
- Trade-offs: none. `Magnetic.tsx` isn't under `components/ui/`, so this is a
  location deviation from FILES ALLOWED, not a functional one.

### E-007 | 2026-07-09 | YogaCursor: crossfade fallback instead of point-lerp morphing
- What changed: `06_YOGA_CURSOR.md` asked for 12 hand-authored SVG paths sharing an
  IDENTICAL command/point sequence, so consecutive poses could be numerically
  lerped frame-by-frame with no morphing library. Took the task file's own
  documented fallback instead: 12 independent, simpler poses (head circle +
  one M/L/Z-only body path each) that crossfade (opacity swap, 120ms) at
  segment boundaries rather than morph.
- Why it is better: the task file itself flags this exact risk — "critical for
  a weak model — follow exactly" — because hand-authoring 12 complex paths with
  matching topology, entirely by reasoning about coordinates with no visual
  editor, is extremely failure-prone; a wrong attempt would either silently
  produce garbled in-between shapes or require many blind iterations to fix.
  Crossfade needs no such constraint, so each pose could be authored
  independently and verified by rendering it (done via Playwright + browser
  preview — confirmed 12 distinct, recognizable stick-figure silhouettes).
- What it replaced: point-by-point path interpolation.
- Trade-offs: pose transitions are a 120ms crossfade instead of a continuous
  morph — a minor motion-quality difference, explicitly pre-approved by the
  task file's own fallback clause.
- Also swapped the cursor mount in `app/(marketing)/layout.tsx`, not root
  `app/layout.tsx` — Cursor.tsx has lived in the marketing layout since 04's
  route-group restructure (predates this task file), and cursor should stay
  marketing-only regardless (the portal, added in 12/13, has no decorative
  cursor need). Root `layout.tsx` was never touched.

### E-008 | 2026-07-09 | 07: SilhouetteTier shipped, full Scene/Figure/CameraRig deferred
- What changed: built `useBreathClock.ts` (shared clock, extracted verbatim +
  unit-tested) and `SilhouetteTier.tsx` (seated meditation silhouette + glow +
  embers, mounted in `Hero.tsx` as the complete hero visual) — Steps 1-2 of
  07's build order. Did NOT build `Scene.tsx`/`Figure.tsx`/`CameraRig.tsx`/
  `Lighting.tsx` (Steps 3-5) or install `three`/`@react-three/fiber`/`drei`.
- Why: 07's own Step 1.5 explicitly sanctions exactly this outcome ("IF no
  acceptable mesh found... do NOT stop the project: proceed with
  SilhouetteTier as the shipped hero... continue to 08"). A real, license-clear
  mesh candidate WAS found via WebSearch (see asset registry, PH-016), but two
  concrete tooling gaps block finishing the pipeline in this environment, not
  just effort/difficulty: (1) Sketchfab gates downloads behind an authenticated
  account UI — no available tool can fetch the actual binary through it; (2)
  decimation/glTF export/Draco compression needs Blender or the gltf-transform
  CLI, neither available here, and there's no way to visually verify a
  processed 3D mesh in this session's tools even if produced. Writing custom
  WebGL shaders (fresnel-rim translucent material, UV-scrolled emissive flow-
  lines) blind, with no mesh and no way to render/inspect a 3D scene, would be
  guessing, not engineering — SilhouetteTier is deliberately the tier that
  doesn't require any of that (D007: "everything else gets the 2D silhouette
  tier" — it's designed to be a complete, shippable hero on its own).
- What it replaced: nothing existing — this is new, additive scaffolding.
  `components/scene/` now holds the two pieces that don't depend on the mesh;
  `Scene.tsx` etc. are for whoever picks up PH-016 with the right tooling.
- Trade-offs: no WebGL centerpiece yet. Fallback matrix (07's VALIDATION) is
  trivially satisfied for now — SilhouetteTier is unconditionally what every
  visitor sees, desktop and mobile alike, so there's no dual-tier logic to
  test until Scene exists.
- **Bugs found and fixed while building this** (not hypothetical, caught via
  Playwright screenshot verification): (1) `Path2D` is browser-only — module-
  top-level construction crashed the production build during Next.js's
  server-side prerendering (`Path2D is not defined`); moved construction
  inside the client-only effect. (2) The new opaque silhouette shape visually
  collided with the H1's second line at narrower viewports (a real legibility
  regression from making the visual more solid than the old abstract rings);
  lowered its fill opacity substantially. (3) A **pre-existing** bug,
  unrelated to anything built in 04-06: `Hero.tsx`'s backdrop has always been
  a hardcoded dark gradient that never participates in the day/night toggle,
  but its text used the theme-flipping `text-bone`/`text-mist` tokens — in
  day mode (e.g. Playwright's default `prefers-color-scheme: light`), the H1
  rendered in the *day* theme's dark bone color against the *permanently
  dark* backdrop, nearly illegible. Fixed by pinning `--bone`/`--bone-rgb`/
  `--mist`/`--mist-rgb` to their night values via inline style scoped to the
  Hero section only (its background never changes with theme, so its text
  shouldn't either) — this bug has existed since the day-theme colors were
  first authored and was never caught because no prior session tested Hero
  specifically under a light-preference/day-theme browser condition.

### E-009 | 2026-07-09 | /testimonials shows an invite-to-share state, not the staged carousel
- What changed: `10_COMMUNITY_PAGES.md` says `/testimonials`'s empty rule is
  "zero real quotes → explanation + invite-to-share form, noindex." Literally,
  `content/testimonials.ts` has 3 entries (non-empty), all verbatim-labeled
  `[STAGING CONTENT]`. Built the page to always show the invite-to-share empty
  state instead of conditionally rendering the `Voices` carousel on
  `testimonials.length > 0`.
- Why: "zero real quotes" is the actual state — 3 staging placeholders isn't
  "some real quotes," it's zero, worded around an array that happens to be
  non-empty for display-parity reasons elsewhere on the site. On a page whose
  *entire purpose* is testimonials, rendering `[STAGING CONTENT]` text as if
  it were the answer to "what do members say" would read as fabricated
  content, not obviously-staged filler — the opposite of the honest empty-
  handling this task requires.
- What it replaced: nothing existing (new page) — noted because a more
  literal reading of the task file (checking `.length > 0`) would have
  shipped the wrong behavior.
- Trade-offs: none. `Voices` itself is unchanged and still used correctly
  elsewhere (homepage) where showing a labeled staging carousel already made
  sense as a design-preview, not a factual claim page.

## Implementation notes (appended by executing models — one line each, dated)

IN-007 | 2026-07-09 | `10_COMMUNITY_PAGES.md`'s empty/noindex rules for
`/events`/`/blog`/`/testimonials` required adding `noindex` support to
`pageMeta()` (`lib/seo.ts`, not in FILES ALLOWED) and removing the now-
noindex routes + their `[slug]` children from `app/sitemap.ts` (a noindex
sitemap entry is a contradictory crawl signal — also not in FILES ALLOWED).
Also touched `lib/nav.ts`/`lib/i18n/translations.ts`/
`components/CommandPalette.tsx` for `/testimonials` and `/faq` reachability,
and added `noindex: true` to `blog/[slug]` and `events/[slug]`'s own
`pageMeta()` calls for consistency with their parent listing pages (same
staging-content reason, not explicitly listed in FILES ALLOWED either).
Same recurring class as IN-001-006.

IN-006 | 2026-07-09 | `09_COMMERCE_PAGES.md`'s route table requires the
`/schedule` rebuild to add a `BatchPickerCta`-style per-row join CTA, which
needs editing `components/Schedule.tsx` (not in FILES ALLOWED — only
`Membership.tsx`/`PlanCalculator.tsx` are listed). Also touched
`lib/nav.ts`/`lib/i18n/translations.ts`/`app/sitemap.ts`/
`components/CommandPalette.tsx` to make the new `/membership` page
1-click reachable site-wide (footer) rather than an orphaned page — same
recurring class as IN-001-005.

IN-005 | 2026-07-09 | `08_CORE_PAGES.md` step 3 ("update internal links: grep
-rn '"/services"' website") required touching files outside FILES ALLOWED:
`components/cards/ServiceCard.tsx` (hardcoded `/services/` link — the actual
routing bug this step exists to catch), `app/sitemap.ts` and
`components/CommandPalette.tsx` (stale `/services` entries — redirects cover
correctness but not sitemap/palette hygiene), `lib/nav.ts` (Services→Programs
rename + new Founder entry) and `lib/i18n/translations.ts` (matching Hindi
entries for the renamed/new labels). Same recurring class as IN-001-004 —
small, mechanical, directly required by the task's own steps.

IN-004 | 2026-07-09 | `06_YOGA_CURSOR.md`'s step 1 unit test ("all 12 paths
parse to the same command/point count") doesn't apply to the crossfade
fallback (E-007) — replaced with `components/cursor-poses.test.ts` checking
what crossfade actually needs (12 poses, valid M/L/Z-only paths, in-bounds
heads). `vitest.config.ts`'s `include` needed a `components/**/*.test.ts`
glob added (not in FILES ALLOWED) — same recurring gap as IN-001.

IN-003 | 2026-07-09 | `05_MOTION_SCROLLSTORY.md`'s VALIDATION section requires a
Playwright reduced-motion check ("extend e2e/new-home.spec.ts" — the actual file
is `e2e/home.spec.ts`, no `new-home.spec.ts` exists; extended the real file
instead of creating a differently-named duplicate). `e2e/` isn't in FILES
ALLOWED, same class of gap as IN-002.

IN-002 | 2026-07-09 | `04_HOMEPAGE.md` step 5 ("FAQ/Journal/Events become footer
links") required adding a `{ href: "/contact#faq", label: "FAQ" }` row to
`lib/nav.ts`'s `footerGroups` (Blog/Events were already present from a prior
session) — `lib/nav.ts` isn't in FILES ALLOWED but the step can't be completed
without touching it. That in turn required a Hindi translation entry in
`lib/i18n/translations.ts` (also not in FILES ALLOWED) to keep
`translations.test.ts`'s completeness check green. Both are small, mechanical,
directly required by the task's own steps — same class as IN-001.

IN-001 | 2026-07-09 | `02_CONTENT_SYSTEM.md` step 5 asks for `content/content.test.ts`, but `vitest.config.ts`'s `include` only globbed `lib/**/*.test.ts` — added `content/**/*.test.ts` to the include array (not in the task's FILES ALLOWED, but omitting it makes step 5 a silent no-op: the file exists, never runs, "validation green" would be a false signal). Charter D011: engineering fix, documented not asked.

## Asset registry (license verification — mandatory before any asset enters repo)

| Asset | Source URL | License | Verified date | Used in |
|---|---|---|---|---|
| _(candidate, not yet downloaded/used — see PH-016)_ "A Man Sitting" by Sketchfab user 1056878 | https://sketchfab.com/3d-models/a-man-sitting-41b3107ced274de8a1c523d75272535e | CC-BY 4.0 (creativecommons.org/licenses/by/4.0/ — attribution required if used) | 2026-07-09 (via WebSearch/WebFetch, not downloaded) | Not yet — pipeline execution blocked (PH-016) |
