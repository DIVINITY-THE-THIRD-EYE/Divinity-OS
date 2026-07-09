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

### E-010 | 2026-07-10 | Migrated real privacy/terms text into content/legal.ts instead of stubbing placeholders
- What changed: `11_CONTACT_LEGAL.md` assumed `/privacy` and `/terms` needed
  PH-010 placeholder text pending owner migration (`content/legal.ts` shipped
  from 02 with only a `"Status: [PLACEHOLDER...]"` row for each). Reality
  (found during execution): both pages already had complete, real body text
  written directly in their page JSX (data collection, retention, bookings,
  health & safety, etc. — substantive, already-authored policy language, not
  filler). Moved that real text verbatim into `content/legal.ts` as proper
  `LegalSection[]` arrays and made the pages render from it, instead of
  replacing working copy with a placeholder stub.
- Why it is better: PROJECT_RULES' placeholder protocol exists to prevent
  *fabricating* business data that doesn't exist — it was never meant to
  discard real data that already exists in favor of a placeholder, which
  would be a strict regression (shipping "[PLACEHOLDER: ...]" text on a live
  legal page instead of the real policy already sitting in the repo).
  PH-010 is still correctly listed in PLACEHOLDERS.md as CONFIRM-status (the
  owner should still review the migrated text against DPDP Act 2023 /
  counsel before launch — the existing page-level NOTE FOR THE BUSINESS
  comments say exactly this and were kept) — the content is real, just unconfirmed.
- What it replaced: `content/legal.ts`'s placeholder-only `privacy`/`terms`
  arrays from 02_CONTENT_SYSTEM (never actually rendered anywhere until now).
- Trade-offs: the migrated text drops the live `{site.full}`/`{site.city}`
  interpolation the JSX had (now says "the academy" generically, since
  `content/legal.ts` is static data without access to the site object) —
  acceptable since the page's own PageHeader intro already names the site.

### E-011 | 2026-07-10 | Auth checks fail closed on missing env / thrown errors instead of crashing
- What changed: `12_STUDENT_LOGIN.md`'s reference snippets (and the
  `@supabase/ssr` docs they're based on) assume `NEXT_PUBLIC_SUPABASE_URL`/
  `_ANON_KEY` are always present. This repo's `website/.env.local` doesn't
  have them yet (confirmed: visiting `/portal` before this fix threw
  "Your project's URL and Key are required to create a Supabase client!").
  `middleware.ts` now returns early (no auth check, plain passthrough) when
  either env var is missing, and both `middleware.ts` and `/portal`'s own
  server check wrap `supabase.auth.getUser()` in try/catch, treating any
  thrown error identically to "no session" (→ redirect to `/login`).
- Why it is better: `middleware.ts`'s matcher runs on nearly every route on
  the site — letting a missing-env or a transient Supabase-auth-service
  outage throw there would 500 the entire site, not just `/portal`. Failing
  closed (no verified session = redirect to login) is also the *correct*
  security default regardless of cause, and it's what makes this task's own
  required Playwright check ("`/portal` unauthenticated → redirected to
  `/login`, no real OTP in CI") actually pass honestly in an environment
  without real Supabase credentials configured yet, instead of skipping it.
- What it replaced: the reference snippets' implicit assumption that env is
  always present and `getUser()` always resolves.
- Trade-offs: none functionally once real env is provided — the try/catch
  and env-guard are no-ops on the happy path (verified: no vitest/lint/tsc
  regressions, all 138 vitest + 58 Playwright tests green).

### E-012 | 2026-07-10 | 13: Stage A shipped partially (Nav link only) — Flutter build blocked by tooling, Stage B deferred
- What changed: `13_FLUTTER_WEB.md` asks for a Flutter Web build+deploy
  (Stage A) before an embedded-iframe session handoff (Stage B). No Flutter
  SDK is available in this environment (`flutter` not on PATH) — this file's
  own INPUTS section pre-approves exactly this fallback ("Stage A becomes
  'document build command + CI job spec'... portal shows 'app coming soon'
  card, continue"). Shipped only the part that doesn't need a build: the
  "Student Login" Nav link (Step 3, real and working — verified via
  Playwright). Did not build/deploy Flutter Web, did not attempt Stage B.
- Why: same reasoning as E-008 (07's SilhouetteTier/mesh split) — a missing
  build toolchain is a tooling gap, not an effort/difficulty problem;
  faking a Flutter Web deploy or an iframe pointed at a URL that doesn't
  exist would be unverifiable, fabricated-looking work. The hosting-path
  decision this file's Step 2 asks for was already made and recorded
  (`PLACEHOLDERS.md` BD-002, from the playbook-evolution pass, predating
  this task) — nothing new to decide.
- What it replaced: nothing existing — Stage A/B are both new, additive
  work. The proposed build command + CI job spec (following this repo's
  `release-flutter.yml` conventions) is documented in STATUS.md and handed
  off to `18_DEPLOYMENT.md` (its own Step 2 + FILES ALLOWED already own
  `.github/workflows/**` and "document the exact commands in this file").
- Trade-offs: no live Flutter Web experience yet; the portal's "coming
  soon" card (built in 12) is the honest interim state. Whoever has the
  Flutter SDK: run the documented build command, pick actual hosting
  (subdomain vs `/app`), and pick up Stage B from there.

### E-013 | 2026-07-10 | JsonLd.tsx no longer emits FAQPage/Course site-wide
- What changed: `components/JsonLd.tsx` (mounted once, in the ROOT layout —
  every route) previously emitted `HealthAndBeautyBusiness`/
  `SportsActivityLocation`, `FAQPage`, and a generic `Course` block on
  literally every page, regardless of whether that page's visible content
  matched. Reduced it to only the site-wide-legitimate part (the
  LocalBusiness-family block, now built via a shared `buildLocalBusinessJsonLd()`
  in `lib/seo.ts`, enriched with real `geo` coordinates from
  `locationConfig`). `FAQPage` now renders only on `/faq` (already had its
  own copy from task 10 — deduplicated to use the same builder); `Course`
  now renders per-program-page with that program's actual name/description
  (`programs/[slug]`, `/programs/therapeutic-yoga`, `/programs/meditation`),
  replacing the `Service` type those three already used inline.
- Why it is better: Google's structured-data guidelines require FAQPage
  markup to match content actually visible on that page — emitting it
  site-wide (e.g. on `/pricing`, which has no FAQ content of its own) is
  exactly the mismatch that gets rich-result eligibility pulled. A single
  generic sitewide `Course` block also isn't "per program page" (14_SEO.md's
  explicit ask) and duplicated real per-page `Service` blocks that already
  existed. `Person` schema (new, `/founder` only) filters out the
  `[PLACEHOLDER: ...]`-labeled credential entry via `buildPersonJsonLd()`, so
  a placeholder can never reach the index (PROJECT_RULES #3).
- What it replaced: `JsonLd.tsx`'s inline sitewide FAQPage/Course objects;
  the three program pages' inline `Service` objects.
- Trade-offs: `Course`'s `provider` uses `url` (not `sameAs`, which the old
  generic block used) — both are valid schema.org Organization properties;
  `url` matches what the pre-existing per-program `Service` blocks already
  used, kept for consistency rather than reintroducing a second convention.
- Also wired the previously-dead `content/seo.ts` (`routeOverrides`, unused
  since 02_CONTENT_SYSTEM) into the homepage's keyword list in root
  `app/layout.tsx` — D005 ("never hardcode") — a one-line change, logged as
  IN-010 since `app/layout.tsx` isn't literally "per-page metadata" in
  14_SEO.md's FILES ALLOWED, though it is the homepage's only metadata
  source (no page-level `pageMeta()` call exists for `/`).

### E-014 | 2026-07-10 | Reveal.tsx gained an `immediate` prop for above-the-fold content
- What changed: `PageHeader.tsx` (the H1 on nearly every non-homepage route)
  wrapped its heading in `Reveal`, which starts at `opacity:0` and only
  transitions to visible once an `IntersectionObserver` fires post-hydration
  (`whileInView`). Measured via real Lighthouse runs (see 15_PERFORMANCE.md):
  this gated the page's LCP paint behind full JS delivery + hydration,
  costing ~1.3-1.8s of LCP under mobile network throttling on `/programs`
  and `/contact` (perf score 80/82, below the 90 floor). Added an
  `immediate?: boolean` prop to `Reveal` — when true, `initial={false}`
  instead of `initial={{opacity:0,y}}`, so the wrapped content renders
  already in its final, visible state (no flash, no entrance transition).
  Wired only into `PageHeader.tsx`'s hero content.
- Why it is better: D009 states budgets are non-negotiable and "effects
  that can't fit use their fallback" — this is exactly that fallback,
  scoped to the single most-repeated above-the-fold element site-wide.
  Verified via re-measurement: `/programs` mobile perf 80→90, `/contact`
  mobile perf 82→90, `/home` mobile perf 89→93 — all now clear the ≥90
  floor. `Reveal`'s API and every OTHER call site (below-the-fold sections
  throughout the site) are completely unaffected — this doesn't remove the
  motion-grammar system, it exempts one already-in-viewport instance from
  a fade that JS-throttled network conditions can't hide for free.
- What it replaced: nothing removed — `Reveal` still defaults to its
  original fade-in behavior everywhere else.
- Trade-offs: `PageHeader`'s hero content no longer performs the fade-up
  entrance on load (it did so functionally instantly anyway for anyone with
  a fast connection — the fix mainly matters under throttling). Verified
  full test suite (145 vitest + 84 Playwright) unaffected.

### E-015 | 2026-07-10 | Real day-theme contrast bugs found via axe-core, fixed the same way E-003 already established
- What changed: an automated axe-core sweep (48 route×theme combinations)
  found the OLD primitive tokens `--ember` and `--mist` never got the
  day-theme contrast correction that the NEW semantic `--accent` token
  already received in E-003 — `--ember` (#d08a3e) measured ~2.7:1 against
  the day `--void` background (need 4.5:1); `--mist` (#6b6f7e) measured
  4.36:1 against the day `--surface` background (need 4.5:1). Darkened
  `--ember`'s day value to `#9c4a2a` (same value `--accent`/`--clay` already
  use — same brand hue family, already proven to pass) and `--mist`'s day
  value to `#666a78` (computed to clear 4.5:1 with margin: 4.70:1).
  Also fixed 5 inline links (`privacy`/`terms`/`refund`/`verify` pages,
  `LoginForm.tsx`'s "Change number") that used `hover:underline` — only
  distinguishable by color at rest, failing WCAG 1.4.1 (axe:
  `link-in-text-block`, 1.07:1 contrast against surrounding text, "no
  styling to distinguish it from surrounding text") — changed to a
  permanent `underline` (removed on hover instead). And `Nav.tsx`'s
  Language toggle button, which axe's WCAG 2.2 `target-size` check found
  at 11.2×16.5px (need 24×24) — gave it `min-h-6 min-w-6` matching
  `ThemeToggle`'s existing correct pattern.
- Why it is better: these are the exact class of bug E-003 already fixed
  once for `--accent` — the fix wasn't propagated to the two OLD primitive
  tokens that still drive un-migrated components (Footer, Voices, About,
  Trainers, Manifesto, etc.), so the same day-theme contrast gap persisted
  wherever those primitives are still used. All four fixes are real,
  axe-confirmed, minimal, and don't touch any component's layout/design —
  only color values and two Tailwind utility classes.
- What it replaced: `--ember`'s day value being an unmodified copy of its
  night value (never actually "overridden"); `--mist`'s day value being
  4.36:1 (a hair under floor); hover-only underlines on 5 inline links;
  an undersized Nav control.
- Trade-offs: none — verified via the full 133-test suite (145 vitest + a
  49-test axe sweep across every route × both themes, 84 other e2e tests)
  staying green, and the color shifts are barely perceptible (same rust/
  gray hue family, ~1 shade darker).
- Two INTENTIONAL exceptions, NOT fixed (documented per 16_ACCESSIBILITY.md's
  own instruction and its FILES FORBIDDEN clause against visual redesign):
  1. `[data-watermark]` decorative background glyphs (`aria-hidden`,
     `::before` generated content, ~0.025-0.04 alpha) — pure decoration,
     WCAG 1.4.3's own exception for incidental/decorative text.
  2. `.m-line` (`Manifesto.tsx`) — real manifesto copy, GSAP-animated from
     opacity 0.12→1 as its section scrolls into view (05_MOTION_SCROLLSTORY's
     established scroll-reveal grammar). A static axe scan catches the
     pre-scroll starting frame; the content reaches full contrast once
     scrolled into view, and `Manifesto.tsx` already checks
     `prefers-reduced-motion` itself and skips the GSAP setup entirely for
     those users (verified by a dedicated Playwright test). Redesigning
     this motion pattern would be exactly the "visual redesign under a11y
     cover" this task explicitly forbids.

## Implementation notes (appended by executing models — one line each, dated)

IN-012 | 2026-07-10 | `16_ACCESSIBILITY.md` names `@axe-core/cli` OR a
Playwright+axe-core integration as the tooling option — used
`@axe-core/playwright` (installed as a new devDependency, clearly justified:
this is the task's own explicitly-sanctioned tool, not a discretionary
addition, per D010). New `e2e/a11y.spec.ts` covers the full CHECK MATRIX:
48 axe scans (24 routes × dark/light), skip-link keyboard test, theme-toggle
keyboard+name test, WCAG 2.2 target-size scan, reduced-motion scan, 200%-zoom
proxy at 3 routes, login/contact form label+autocomplete+error-recovery
checks. A real methodology bug in my own first draft (scanning mid-animation-
transition, producing false-positive "low contrast" reads on a frame that
settles within ~1s) was found and fixed by waiting for transitions before
each scan — documented inline in the spec so it isn't rediscovered.

IN-011 | 2026-07-10 | `15_PERFORMANCE.md`'s font pass (Step 3) found
`Hanken_Grotesk` (body) loading weights 300/400/500 and `JetBrains_Mono`
(mono) loading 400/500 in `app/layout.tsx`, but grep-verified (searched
every `.tsx` under `app/`/`components/` for `font-medium`/`font-semibold`/
`font-bold`/`font-normal` paired with `font-body`/`font-mono`, and for any
`fontWeight` inline style) that: (a) `globals.css`'s `body { font-weight:
300 }` is never overridden for body text anywhere, so only 300 ever
renders; (b) mono text likewise never requests a specific weight, and with
only 400 available it renders at 400 (CSS font-matching's nearest-available
fallback) — 500 was pure dead weight in both families. Trimmed
`Hanken_Grotesk` to `["300"]` and `JetBrains_Mono` to `["400"]` — 3 fewer
font files downloaded, zero visual change (verified: full test suite green,
`next build` output unchanged in route structure). `app/layout.tsx` isn't
literally the FILES ALLOWED wording ("Anything needed for optimization
EXCEPT...") but IS covered by 15's own broad allowance, so no deviation
note needed beyond this record for traceability.

IN-010 | 2026-07-10 | `14_SEO.md` lists `content/seo.ts` in FILES ALLOWED
but it was never actually consumed anywhere (dead code since
02_CONTENT_SYSTEM). Wired its `routeOverrides` into root `app/layout.tsx`'s
`generateMetadata()` (the homepage's only metadata source — no
`app/(marketing)/page.tsx` `pageMeta()` call exists) to replace a hardcoded
keywords array, per D005. `app/layout.tsx` isn't literally listed in FILES
ALLOWED (only "per-page `metadata` exports" is) — same recurring class as
IN-001..009, a one-line necessity to make the task's own file useful.

IN-009 | 2026-07-10 | `12_STUDENT_LOGIN.md`'s FILES ALLOWED lists
`website/.env.example` (doesn't exist) — documented the two new Supabase env
vars in the real `website/.env.local.example` instead. Also touched
`lib/validation.ts` (new `isE164Phone`, task-sanctioned by this file's own
Step 3) and `e2e/portal.spec.ts` (new, not listed) — same recurring class as
IN-001..008.

IN-008 | 2026-07-10 | `11_CONTACT_LEGAL.md`'s re-skin requirement for
`/contact` and `/verify` required editing `components/Contact.tsx` and
`components/VerifyForm.tsx` (not in FILES ALLOWED — only the page files were
listed) since the semantic-token classNames live in the components the pages
compose, not the thin page wrappers themselves. Also touched `lib/nav.ts`
(new `/refund` footer entry) and `lib/i18n/translations.ts` (Hindi label for
"Refund Policy") to satisfy the existing translations-completeness test and
keep the new route reachable from the footer. Same recurring class as
IN-001..007.

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
