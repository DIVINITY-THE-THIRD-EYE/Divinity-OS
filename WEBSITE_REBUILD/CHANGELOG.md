# CHANGELOG — WEBSITE_REBUILD

Format: `## [date] — <task file>` then bullet list of concrete changes.
Newest on top. Every completed task file appends exactly one entry.

## [2026-07-10] — 18_DEPLOYMENT (blocked by tooling — documented, not faked)
- Confirmed no `vercel.json` needed (zero-config Next.js 14 app; redirects/
  headers already in `next.config.mjs`, `middleware.ts` handles the one
  routing concern). Verified the `ENVIRONMENT VARIABLES` table against
  `.env.local.example`/`docs/SUPABASE_SETUP.md` — accurate, no changes.
  Documented the standard Vercel rollback procedure (promote-previous-
  deployment).
- **Blocked, not attempted:** preview deployment + login round-trip +
  Flutter embed check (no Vercel auth in this session — needs `claude mcp`/
  `/mcp` in an interactive session per this environment's own
  instructions); Flutter Web artifact build+deploy (nothing to deploy —
  13 already found no Flutter SDK here); Lighthouse against a real preview
  URL (no preview exists). None faked (E-017).
- Continuing to `19_LAUNCH.md` per D011 — its own PRECONDITIONS + step-1
  human approval gate (BD-001) is the correct, honest place these surface
  for the owner.

## [2026-07-10] — 17_TESTING
- New `e2e/visual.spec.ts`: 7 committed baseline screenshots (home × 2
  themes × 2 viewports, pricing/programs/contact desktop),
  `maxDiffPixelRatio: 0.02` configured in `playwright.config.ts`.
- Found and fixed 2 real flakes while building it (E-016), not retry-masked:
  `Voices.tsx`'s testimonial carousel never checked `prefers-reduced-motion`
  (a real WCAG 2.2.2 gap, not just a screenshot nuisance) — fixed; and a
  full-page-screenshot race against `next/image`'s lazy loading — fixed by
  forcing eager load before waiting for every image to complete.
- Added the missing Playwright `e2e` job to `.github/workflows/website.yml`
  (previously only lint/build/vitest/lighthouse existed).
- **Phase 7 gate passed** (14+15+16+17 all COMPLETE) — rebased onto main.
  Known limitation, documented not hidden: visual baselines need a one-time
  Linux-snapshot commit from within real CI (couldn't be generated from
  this Windows sandbox) — see STATUS.md/DECISIONS.md IN-013.
- Validation green: lint, tsc, 145 vitest tests, 140 Playwright e2e tests
  (2 consecutive full green runs), next build (45 routes + middleware).

## [2026-07-10] — 16_ACCESSIBILITY
- New `e2e/a11y.spec.ts` (`@axe-core/playwright`, new devDependency): 48
  axe scans (24 routes × dark/light theme) + skip-link, theme-toggle,
  WCAG 2.2 target-size, reduced-motion, 200%-zoom-proxy, and form
  label/autocomplete/error-recovery checks.
- Found and fixed 4 real bugs (E-015): `--ember`/`--mist` day-theme
  contrast gaps (same class of issue E-003 already fixed for `--accent`,
  never propagated to these older primitives — `--ember` ~2.7:1→passes,
  `--mist` 4.36:1→4.70:1), 5 inline links only distinguished by color at
  rest (hover-only underline → permanent underline), and an undersized Nav
  language-toggle control (11×16px → min 24×24).
- Two exceptions documented, not "fixed" per this task's own instruction:
  decorative `[data-watermark]` glyphs, and `Manifesto.tsx`'s scroll-
  triggered `.m-line` reveal (real content, reaches full contrast once
  scrolled into view; reduced-motion users get it instantly — verified).
- Validation green: lint, tsc, 145 vitest tests, 133 Playwright e2e tests
  (49 new in `e2e/a11y.spec.ts`), next build (45 routes + middleware).

## [2026-07-10] — 15_PERFORMANCE
- Real Lighthouse measurements (worked around a local Chrome-launch
  restriction via a Playwright-launched CDP target) on `/`, `/pricing`,
  `/programs`, `/contact`, `/login`, desktop + mobile.
- Found and fixed a real LCP-gating bug: `Reveal`'s `whileInView` held the
  hero H1 (via `PageHeader.tsx`, used on nearly every route) at opacity:0
  until JS hydration + IntersectionObserver fired. Added a scoped
  `immediate` prop (E-014) — mobile perf scores improved `/programs` 80→90,
  `/contact` 82→90, `/home` 89→93. All 5 routes now clear the ≥90 mobile /
  ≥95 desktop D009 floors.
- Trimmed dead font weights (grep-verified unused): `Hanken_Grotesk`
  400/500, `JetBrains_Mono` 500 (IN-011) — 3 fewer font files, zero visual
  change.
- Image audit: zero raw `<img>` tags (next/image everywhere); ~34
  unreferenced files found in `public/studio/`/`public/guru/` — listed in
  STATUS, not deleted (19's job).
- Added a `lighthouse` job to `.github/workflows/website.yml` (desktop +
  mobile configs, `@lhci/cli` via npx) asserting D009's budgets — hasn't
  run in real CI yet from this session (no local runner available).
- Validation green: lint, tsc, 145 vitest tests, 84 Playwright e2e tests,
  next build (45 routes + middleware, font payload reduced).

## [2026-07-10] — 14_SEO
- `components/JsonLd.tsx` (site-wide, root layout) reduced to just the
  LocalBusiness-family block (now with real `geo` coordinates) — `FAQPage`/
  `Course` no longer emitted on every route regardless of relevance
  (Google's structured-data guidelines require the markup to match visible
  page content).
- New pure, unit-tested JSON-LD builders in `lib/seo.ts`
  (`buildLocalBusinessJsonLd`/`buildFaqJsonLd`/`buildCourseJsonLd`/
  `buildPersonJsonLd`) — the last filters out `[PLACEHOLDER: ...]`-labeled
  credentials so they can never reach the index.
- New `Person` schema on `/founder`; `Course` schema (converted from
  `Service`) on all three program-detail pages.
- Confirmed (grep) the noindex checklist already holds for `/blog`,
  `/events`(+slug), `/testimonials`, `/refund`, `/login`, `/portal`.
- Wired previously-dead `content/seo.ts` into the homepage's keywords (D005).
- New `e2e/seo.spec.ts` (25 tests): scripted matrix sweep — title/canonical/
  single-h1/indexable per route, noindex per route, JSON-LD correctness —
  instead of hand-checking.
- Validation green: lint, tsc, 145 vitest tests (+7 new), 84 Playwright e2e
  tests (+25 new), next build (45 routes + middleware, unchanged route
  count — no new pages this task).

## [2026-07-10] — 13_FLUTTER_WEB (Stage A partial — Nav link shipped; build/Stage B blocked by tooling)
- Added the "Student Login" link to `Nav.tsx` (desktop + mobile menus) —
  dark-launch ends here per this task's Step 3. Verified via a new
  Playwright test (click-through from `/` to `/login`).
- No Flutter SDK available in this environment — couldn't run `flutter
  build web`. This task's own INPUTS section pre-approves this exact
  fallback: documented the build command + a proposed CI job spec (STATUS.md)
  and handed the actual workflow-file creation off to `18_DEPLOYMENT.md`
  (which already owns `.github/workflows/**`), rather than fabricating a
  build or an iframe pointed at a URL that doesn't exist.
- Hosting-path decision (subdomain vs `/app`) needed no new call — already
  recorded as `PLACEHOLDERS.md` BD-002 (path-based default) before this task.
- Stage B (embedded iframe + token handoff) correctly deferred — it's gated
  behind Stage A shipping a real, reachable URL, which didn't happen here.
- Validation green: lint, tsc, 138 vitest tests, 59 Playwright e2e tests,
  next build (45 routes + middleware).
- **Phase 6 gate passed** (12 COMPLETE, 13 shipped to the extent tooling
  allows) — rebased onto main.

## [2026-07-10] — 12_STUDENT_LOGIN
- Installed `@supabase/ssr@0.12.0` + `@supabase/supabase-js@2.110.2`; added
  `lib/supabase/{client,server}.ts` (anon key only, cookie-based SSR
  session), `middleware.ts` (session refresh + `/portal/**` guard), and
  `lib/supabase/role-gate.ts` (`isStudent()`, trusts the JWT `app_metadata
  .role` claim — no client-side DB read).
- New route group `app/(portal)/`: `/login` (phone → OTP → code, E.164
  validated via a new `isE164Phone` in `lib/validation.ts`), `/portal`
  (dashboard shell + Flutter Web slot for 13), `/logout` (route handler).
  Non-student roles are signed out and bounced to `/login` with a message.
- CSP `connect-src` now includes the Supabase project host, read from
  `NEXT_PUBLIC_SUPABASE_URL` (never hardcoded, never a wildcard).
- Found this environment has no real Supabase env configured yet — made
  auth checks fail closed (missing env / thrown errors → treated as "no
  session" → redirect to `/login`) instead of crashing the site (E-011).
  Manual OTP QA marked pending owner env, not faked.
- New tests: `lib/validation.test.ts` (+4 phone-format cases),
  `lib/supabase/role-gate.test.ts` (4 tests), `e2e/portal.spec.ts` (4 tests:
  unauthenticated redirect, login form renders, non-student message,
  malformed-phone rejection).
- Validation green: lint, tsc, 138 vitest tests, 58 Playwright e2e tests,
  next build (45 routes + middleware). Zero `supabase/**` changes.

## [2026-07-10] — 11_CONTACT_LEGAL
- Re-skinned `/contact` (+ `Contact.tsx`), `/verify` (+ `VerifyForm.tsx`) to
  semantic tokens; form/verify submit logic, honeypot, and rate limiting
  untouched — `npm test -- api-routes` stays green (15/15).
- Found `/privacy` and `/terms` already had real, substantive body text
  sitting in page JSX (not the placeholder PH-010 assumed) — migrated it
  verbatim into `content/legal.ts` as structured sections instead of
  discarding it for a placeholder stub (E-010); pages now render from it,
  re-skinned to tokens.
- New `/refund`: PH-009 placeholder + "contact us" fallback, noindex; added
  to the footer legal group + Hindi i18n.
- Found (not fixed — outside FILES ALLOWED): production CSP blocks the
  Contact page's weather widget and Google Maps iframe; flagged as a
  background task rather than silently patched.
- Validation green: lint, tsc, 132 vitest tests (incl. 15/15 api-routes
  regression), 54 Playwright e2e tests, next build (43 routes).
- **Phase 5 gate passed** (08+09+10+11 all COMPLETE) — rebased onto main.

## [2026-07-09] — 10_COMMUNITY_PAGES
- `/events`/`/blog` (+ `[slug]` children) re-skinned, marked noindex —
  current content is 100% staging placeholders (BD-003).
- `/gallery` re-skinned; kept its existing IntersectionObserver-based
  reveal (already satisfies the task's parallax requirement).
- New `/testimonials`: always shows the invite-to-share state (not the
  staged carousel — 3 staging entries isn't "real quotes"), noindex.
- New `/faq`: full FAQ list + FAQPage JSON-LD, indexable.
- Added noindex support to pageMeta(); removed noindex routes from the
  sitemap (contradictory crawl signal otherwise).
- Validation green: lint, tsc, 131 vitest tests, 48 Playwright e2e tests,
  next build (41 routes), zero empty-alt images.

## [2026-07-09] — 09_COMMERCE_PAGES
- Re-skinned Membership/PlanCalculator to semantic tokens.
- `/pricing`: added the ₹99 offer block (PH-005 placeholder visible, as
  specified) and a link to the new `/membership` page.
- `/membership` (new): what's included, how joining works (UPI flow, copy
  only), FAQ subset.
- `/schedule`: per-row "Join →" wa.me link with that exact slot's day/time/
  batch prefilled — the practical form of "BatchPickerCta on every row".
- Cross-link audit: pricing/membership/schedule/contact all reachable
  ≤1 click; `/membership` added to the footer (was otherwise orphaned).
- Validation green: lint, tsc, 131 vitest tests, 34 Playwright e2e tests,
  next build (39 routes), zero overflow at 375px.

## [2026-07-09] — 08_CORE_PAGES
- Re-skinned PageHeader/Breadcrumbs/SectionHeading/CtaLink to semantic
  tokens (night parity verified, day mode now uses the curated palette).
- New `/founder` page (`content/founder.ts`); rebuilt `/about` and
  `/trainers` on the new tokens.
- Renamed `/services` → `/programs` (301 redirect, route folder moved,
  `ServiceCard.tsx`'s stale link fixed — a real routing bug the task's own
  link-sweep step exists to catch).
- Added `slug`/`longDescription`/`sessions`/`whoFor` fields to
  `content/programs.ts`; built `components/pages/ProgramDetail.tsx`
  (content-driven template) and two new deep pages,
  `/programs/therapeutic-yoga` and `/programs/meditation`.
- Updated sitemap, command palette, nav, and Hindi translations for the
  renamed/new routes.
- Validation green: lint, tsc, 131 vitest tests, 25 Playwright e2e tests,
  next build (38 routes), zero overflow at 375/1440px on all 6 routes both
  themes, zero business-data literals (grep sweep).

## [2026-07-09] — 07_SCENE_3D (Part 1 — SilhouetteTier; Part 2 deferred, PH-016)
- Added `components/scene/useBreathClock.ts` (shared 4-4-6 clock, extracted
  verbatim + unit-tested) and `components/scene/SilhouetteTier.tsx` (seated
  meditation silhouette + existing glow/embers) — mounted in `Hero.tsx` as
  the complete, shippable hero visual.
- Genuinely researched mesh sourcing via web search: found a license-clear
  CC-BY candidate, but downloading (Sketchfab auth-gated) and processing
  (needs Blender/gltf-transform, not available here) are blocked by tooling,
  not effort. Did not build the WebGL Scene/Figure/CameraRig/Lighting or add
  three/r3f/drei — recorded as PH-016, ADR 0016 written documenting the
  phased approach (07's own Step 1.5 explicitly allows this).
- Fixed a real build-breaking bug (Path2D constructed at module scope, which
  also runs during Next.js server prerendering where Path2D doesn't exist)
  and a real legibility regression (opaque silhouette colliding with hero
  text), both caught via actual build/Playwright verification.
- Fixed a pre-existing bug unrelated to this task: Hero's hardcoded-dark
  backdrop never adapted to day theme, but its text did — rendering
  dark-on-dark in day mode. Scoped a fix to the Hero section only.
- Validation green: lint, tsc, 131 vitest tests, 17 Playwright e2e tests,
  next build (36 routes, `/` +1kB), visual verification both themes/widths.
- **Phase 4 gate passed** (phased delivery per ADR 0016) — rebased onto
  main (no-op, unchanged).

## [2026-07-09] — 06_YOGA_CURSOR
- Replaced the dot+ring `Cursor.tsx` with `YogaCursor.tsx`: 12 Surya
  Namaskar poses that crossfade as the page scrolls (via
  `useScrollProgress()` from 05), held at pose 1 off the homepage. Same
  lerp-follow position and hover-grow mechanics as before.
- Took the task file's documented fallback (crossfade, not point-lerp morph)
  since hand-authoring 12 topology-matched paths with no visual editor is
  the exact failure-prone scenario it warns against.
- Fixed `ScrollScore` to reset progress to 0 on unmount, so "hold pose 1
  off-home" is actually true instead of showing a stale value.
- Validation green: lint, tsc, 126 vitest tests, 17 Playwright e2e tests
  (new pose/hover/reduced-motion/touch checks), next build (36 routes),
  mobile viewport check.
- **Phase 3 gate passed** (05+06) — rebased onto main (no-op, unchanged).

## [2026-07-09] — 05_MOTION_SCROLLSTORY
- Added `ScrollScore` (headless, mounted in `Hero.tsx`): one GSAP
  `ScrollTrigger` publishing whole-page scroll progress via
  `useScrollProgress()` (external store) and a `data-act` attribute driving
  an act-break ambient light shift (new `.ambient::after` layer, finally
  consuming 03's `--glow` token). Reduced motion / `?no-motion=1` → nothing
  mounts.
- Reused `Magnetic.tsx` (not a new `MagneticCta.tsx`) for the hero/final-CTA
  hover-follow, adding the coarse-pointer gate + 8px clamp it was missing.
  Skipped re-implementing section enter animations as a second GSAP system —
  the existing `Reveal` component already covers that correctly.
- Found and fixed a narrower recurrence of 04's PromoBar/Nav overlap bug:
  `--promo-h` was measured from the wrong (animating) DOM node, briefly wrong
  during PromoBar's own mount animation. Caught by intermittent Playwright
  flakiness under parallel load; fixed with a `useLayoutEffect` measuring the
  stable inner content div instead.
- Validation green: lint, tsc, 121 vitest tests, 13 Playwright e2e tests
  (stable across repeated runs), next build (36 routes), reduced-motion
  emulation confirmed.

## [2026-07-09] — 04_HOMEPAGE
- Route-group restructure: `app/(marketing)/layout.tsx` owns all marketing
  chrome; root layout slimmed to fonts/theme/JsonLd. All routes moved via
  `git mv`; URLs unchanged, verified with Playwright.
- Rebuilt the homepage as 9 sections (Hero, AboutStrip, Programs, Benefits,
  Trainer, Voices, GalleryPreview, FinalCta, Footer) per D001's three acts.
  Newsletter moved into Footer; FAQ footer link added.
- Wired the ₹99-offer hardcodes (Hero, FinalCta, PromoBar) to
  `content/offers.introOffer`, closing out the exceptions flagged in 02.
- Deleted orphaned `Marquee.tsx`/`TrustBadges.tsx` (verified zero imports
  first); kept `Method.tsx`/`StatsBand.tsx` (still live on `/about`).
- Found and fixed a real bug via Playwright: PromoBar was silently blocking
  every click on the Nav underneath it (both independently `fixed` at the
  same screen region). Not hypothetical — an existing test had unknowingly
  routed around it.
- Validation green: lint, tsc, 121 vitest tests, 10 Playwright e2e tests,
  next build (36 routes), zero horizontal overflow at 375/1440px, both
  themes checked, zero orphaned components (`knip`).

## [2026-07-09] — 03_DESIGN_SYSTEM
- Added semantic token layer to `globals.css` (`--surface`/`-2`/`-3`, `--fg`/
  `--fg-muted`, `--accent`/`--accent-2`, `--line`, `--glow`) + Tailwind mapping
  + type scale (`display-xl`/`-l`/`-m`, `lead`, `body`, `caption`, balanced text).
- Reused the pre-existing `lib/theme/ThemeContext.tsx` (found already wired
  into `layout.tsx`/`Nav.tsx`) instead of building a new provider; added the
  no-flash init script and `components/ThemeToggle.tsx`.
- Fixed a real hydration bug caught in browser preview (initial-state read of
  `data-theme` inside `useState` caused server/client mismatch) — state now
  starts `"dark"` on both, self-corrects post-mount.
- Renamed `--ink`/`--ink-muted` → `--fg`/`--fg-muted` (collided with an
  existing, differently-valued, live token) and darkened day `--accent` to
  pass the 4.5:1 contrast floor — both documented in DECISIONS.md E-003 and
  `design/adr/0015-day-night-theme.md`.
- Validation green: lint, tsc, 121 vitest tests, next build (36 routes),
  manual toggle verification in browser preview.
- **Phase 1 gate passed** (01+02+03) — rebased onto main (no-op, main unchanged).

## [2026-07-09] — 02_CONTENT_SYSTEM
- Created `website/content/` (18 typed modules + index barrel) as the single
  source of truth for business data; moved every fallback constant out of
  `lib/content.ts` verbatim.
- `lib/content.ts` rewritten as a compat/merge layer — re-exports every old
  name, reassembles the legacy flat `site` object. Zero consumer edits needed.
- Added `content/content.test.ts` (55 tests) + registered it in
  `vitest.config.ts`.
- Hardcode sweep found 3 pre-existing `₹99` hits in homepage components —
  documented as exceptions (JSX edits out of this task's scope, deferred to
  `04_HOMEPAGE.md`).
- Validation green: lint, tsc, 121 vitest tests, next build (36 routes).

## [2026-07-09] — 01_REPO_PRECHECK
- Committed parked pre-rebuild diff, created `rebuild/living-anatomy` branch.
- Baseline validation green: lint, tsc, 66 vitest tests, next build (36 routes).
- No application code changed.

## [2026-07-09] — Playbook evolution pass
- Added Autonomy charter (99, D011): executor owns engineering decisions; deviations
  documented in EVOLUTION LOG, never asked.
- Replaced runtime-flag release with branch-as-flag (D012, E-001): edits across
  00/04/05/12/13/15/18/19; `home-legacy/` concept removed; per-task deletion sweeps added.
- Added route-group architecture baseline `(marketing)`/`(portal)` (E-002) to 00/04/12.
- Phase gates converted from approval stops to self-validating checkpoints with
  rebase-onto-main; only human gates left: launch (BD-001) + business placeholder rows.
- PLACEHOLDERS.md: new "Pending business decisions" section (BD-001…BD-004).

## [2026-07-09] — Playbook creation
- Created `WEBSITE_REBUILD/` execution playbook (20 task files + 5 support files).
- No application code modified.
