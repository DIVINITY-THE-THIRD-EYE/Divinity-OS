# 15 — PERFORMANCE

## PURPOSE
Prove the budgets (D009) with measurements, wire them into CI so they cannot regress.

## BUDGETS (hard — from DECISIONS D009)
Lighthouse desktop ≥95 · mobile ≥90 · LCP <2.0s · CLS <0.05 · INP <150ms ·
`/` first-load JS ≤ 215 kB (pre-scene value +5 kB; scene chunk deferred, not counted).

## INPUTS
Phases 1–6 COMPLETE.

## STEPS
1. Baseline measurement: `npm run build && npm run start`, run Lighthouse (CLI:
   `npx lighthouse http://localhost:3000 --preset=desktop` and default mobile) on:
   `/`, `/pricing`, `/programs`, `/contact`, `/login`. Record all scores in STATUS.
2. Image pass: every `public/` image referenced by the site — correct sizes, AVIF/WebP,
   `next/image` everywhere, no image >300 kB shipped. Unreferenced files in `public/`:
   LIST them in STATUS (deletion happens in 19, not here — audit-before-touching rule).
3. Font pass: confirm only used weights load (check build output / network tab).
4. JS pass: `next build` route table into STATUS; any route >250 kB first-load → find the
   import that doesn't tree-shake (usual suspects: drei barrel imports, gsap plugins) and fix.
5. Fix anything under budget. Re-measure. Iterate until green.
   **Rule: optimize by REMOVING cost, never by adding more animation/effects to mask jank.**
6. CI gate: add Lighthouse CI (`@lhci/cli`, free) to the existing GitHub workflow —
   assert the budget numbers on `/` and `/pricing`. Build fails on regression.

## FILES ALLOWED
Anything needed for optimization EXCEPT: business logic, api routes, supabase, auth flow
semantics, content values. `.github/workflows/**` for the CI gate.

## FILES FORBIDDEN
`content/` values · `supabase/` · feature removal without a STATUS note.

## VALIDATION
All five routes meet budget in BOTH themes (theme shouldn't matter — verify once each).
CI job runs and passes. Numbers recorded in STATUS.

## IF VALIDATION FAILS
The failing metric names its own fix (LCP → critical path; CLS → reserve space; INP →
long tasks; JS → imports). A metric that cannot reach budget without removing an approved
feature → STATUS gate report with the trade-off options, STOP for owner decision.

## STOP CONDITION
Budgets green + CI gate live. Auto-continue.

## NEXT
`16_ACCESSIBILITY.md`
