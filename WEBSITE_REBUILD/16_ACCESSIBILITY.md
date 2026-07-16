# 16 — ACCESSIBILITY (WCAG 2.2 AA)

## PURPOSE
Verified AA across the rebuilt site. The foundations exist (skip link, focus styles,
reduced-motion paths) — this task proves them page-by-page and fixes gaps.

## INPUTS
Phases 1–6 COMPLETE.

## CHECK MATRIX (per route — record PASS/FAIL table in STATUS)
1. Keyboard: every interactive element reachable in DOM order; visible focus; no traps;
   skip link works; theme toggle + batch picker + login form fully operable.
2. Screen reader semantics: landmarks (`header/nav/main/footer`), one h1, heading order,
   forms labelled, errors announced (`aria-live` on form error regions —
   `lib/form-error.ts` pattern), decorative canvas/cursor `aria-hidden`.
3. Contrast: automated scan both themes (axe). Known intentional exception: watermark
   glyphs (aria-hidden decorative) — document, don't "fix".
4. Reduced motion: no timeline, no pinning, no cursor morph, static silhouette,
   content fully readable.
5. Target size ≥24×24 CSS px on all controls (WCAG 2.2 2.5.8).
6. Zoom 200%: no loss of content/function, no horizontal scroll at 1280px base.
7. Forms: autocomplete attributes (`tel` on phone), input purpose, error recovery.

## TOOLING
`npx @axe-core/cli http://localhost:3000/<route>` per route (or Playwright + axe-core
integration — one spec `e2e/a11y.spec.ts` iterating routes). Keyboard/SR checks are manual —
follow the matrix literally, record honestly. NEVER mark a manual check done without doing it.

## FILES ALLOWED
Any component/page for FIXES within a11y scope · `e2e/a11y.spec.ts` · STATUS/CHANGELOG.

## FILES FORBIDDEN
Visual redesign under a11y cover; content values; api; supabase.

## STEPS
1. Add the axe Playwright spec (fails on serious/critical violations).
2. Run matrix per route group (home, core, commerce, community, contact/legal, portal).
3. Fix, re-run, iterate.
4. STATUS table with every route × 7 checks.

## VALIDATION
axe spec green in CI · matrix table complete, all PASS (or documented intentional
exceptions) · standard block green.

## STOP CONDITION
Matrix green. Auto-continue.

## NEXT
`17_TESTING.md`

## AMENDMENT (executed 2026-07-10)
- Installed `@axe-core/playwright` (this file's own sanctioned tooling
  option) and wrote `e2e/a11y.spec.ts` covering every CHECK MATRIX item —
  48 route×theme axe scans, skip-link, theme-toggle, target-size (WCAG
  2.2), reduced-motion, 200%-zoom-proxy, and form label/autocomplete/error
  checks. Full PASS table in STATUS.md.
- Found and fixed 4 real bugs (E-015): `--ember`/`--mist` day-theme
  contrast gaps (the same class of issue E-003 already fixed for
  `--accent`, just never propagated to these two older primitives),
  5 inline links only distinguished by color at rest (hover-only
  underline), and one undersized Nav control (11×16px, needs 24×24).
- Two exceptions documented, not "fixed" (this file's own instruction +
  its FILES FORBIDDEN clause against visual redesign under a11y cover):
  decorative `[data-watermark]` glyphs, and `Manifesto.tsx`'s `.m-line`
  scroll-triggered reveal (real content, but reaches full contrast once
  scrolled into view; reduced-motion users get it at full opacity
  immediately — verified, not assumed).
