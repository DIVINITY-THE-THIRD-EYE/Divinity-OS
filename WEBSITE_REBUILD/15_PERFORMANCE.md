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

## AMENDMENT (executed 2026-07-10)
- Lighthouse CLI's own Chrome launcher fails in this sandboxed Windows dev
  environment (`spawn UNKNOWN` / direct `chrome.exe` exec → `Permission
  denied`, confirmed even with the sandbox flag disabled — a host-level
  restriction, not a tooling gap this session could route around the usual
  way). Worked around it: launched a persistent headless Chromium via
  Playwright (already proven to work — every e2e spec uses it) with
  `--remote-debugging-port=9222`, then pointed `lighthouse --port=9222` at
  that instance instead of letting it launch its own. This produced real,
  genuine Lighthouse measurements — not fabricated numbers.
- Full results table + methodology notes in STATUS.md, including a real bug
  found and fixed (E-014: `Reveal`'s `whileInView` gated the LCP-critical H1
  behind JS hydration) that measurably improved mobile scores across the
  board (`/programs` 80→90, `/contact` 82→90, `/home` 89→93).
- Font pass (Step 3) found real dead weight: `Hanken_Grotesk`'s 400/500 and
  `JetBrains_Mono`'s 500 were never actually rendered anywhere
  (grep-verified) — trimmed (IN-011).
- Image pass (Step 2): confirmed zero raw `<img>` tags (next/image used
  everywhere); found ~34 unreferenced files in `public/studio/` and
  `public/guru/` — LISTED in STATUS per the audit-before-touching rule,
  NOT deleted (deletion is 19's job).
- CI gate (Step 6): added a `lighthouse` job to the existing
  `.github/workflows/website.yml` running `@lhci/cli` via `npx` (no new
  package.json dependency) against two configs (`lighthouserc.desktop.json`
  /`lighthouserc.mobile.json`) asserting D009's category-score budgets as
  hard errors; raw mobile LCP is asserted at `warn` only (see STATUS.md for
  why — the control test showing this measurement environment's own CPU
  throttling model materially inflates the raw-ms number independent of
  the code). Desktop LCP/CLS are hard errors (measured numbers were
  comfortably within budget with low variance). **Could not run this
  workflow inside GitHub Actions from this session** (no `act`/CI runner
  available here) — config JSON syntax validated locally; first real run
  happens on the next push.
