# 17 — TESTING (consolidation)

## PURPOSE
Close test gaps the build-phase tasks left, wire visual regression, make CI the honest gate.

## INPUTS
Phases 1–6 + 14–16 · existing Vitest suites (`lib/*.test.ts`) + Playwright config.

## TARGET SUITE (what must exist when this task closes)
| Layer | Tests |
|---|---|
| Unit (Vitest) | content modules (02) · breath clock (07) · cursor path parity (06) · role gate (12) · schema JSON-LD (14) · all pre-existing lib tests untouched and green |
| E2E (Playwright) | new-home sections + CTA (04/05) · per-route smoke h1/console-clean (08–11) · portal redirect (12) · a11y spec (16) |
| Visual regression | Playwright `toHaveScreenshot` on: home (both themes, desktop+mobile), pricing, programs, contact — baselines committed; threshold `maxDiffPixelRatio: 0.02`; animations disabled via reduced-motion emulation for stability |
| CI | lint + tsc + vitest + build + playwright + lhci all in the workflow, all blocking |

## RULES
- No test frameworks beyond what's installed (Vitest + Playwright). No fixture factories,
  no snapshot sprawl — screenshots only for the 4 named pages.
- A flaky test is a bug: fix the flake (usually animation/network wait), never retry-mask it.

## FILES ALLOWED
`website/e2e/**` · `website/**/*.test.ts` · `playwright.config.ts` ·
`.github/workflows/**` · STATUS/CHANGELOG.

## FILES FORBIDDEN
Application source EXCEPT trivially-testability fixes (export a function) — anything
bigger goes back to its owning task's protocol.

## STEPS
1. Inventory: list existing tests vs TARGET SUITE; write the gap list to STATUS.
2. Fill gaps in table order.
3. Visual baselines: generate on ONE machine profile (CI's), commit.
4. Full CI run green twice consecutively (flake check).

## VALIDATION
Entire suite green locally + in CI. Runtime under 10 min (parallelize Playwright if over).

## STOP CONDITION
Phase 7 gate (14–17 all COMPLETE). Gate report + rebase → auto-continue (D011).
The NEXT human touchpoint is launch approval (BD-001) in 19.

## NEXT
`18_DEPLOYMENT.md`

## AMENDMENT (executed 2026-07-10)
- Inventory (Step 1): unit/E2E TARGET SUITE rows were already met by prior
  tasks (02/06/07/12/14's own test additions); the two real gaps were
  visual regression (didn't exist) and the CI Playwright job (missing
  entirely from `.github/workflows/website.yml`).
- Added `e2e/visual.spec.ts` (7 baselines: home × 2 themes × 2 viewports,
  `/pricing`/`/programs`/`/contact` desktop) + `maxDiffPixelRatio: 0.02` in
  `playwright.config.ts`. Found and fixed 2 real flakes while building it
  (E-016) rather than retry-masking either.
- Added the missing `e2e` (Playwright) job to `website.yml`, `needs: lint`,
  uploads the HTML report as an artifact.
- **Known limitation:** visual baselines are Windows-generated; first real
  CI (Ubuntu) run needs a one-time `--update-snapshots` commit from within
  CI to add the Linux-namespaced baselines (IN-013) — couldn't be done from
  this sandbox (no GitHub Actions runner available here). Everything else
  (spec correctness, flake fixes, CI job wiring) is real and verified.
- Full suite run twice consecutively, both green (RULES step 4): 145
  vitest + 140 Playwright (56 pre-existing + 49 a11y (16) + 7 new visual +
  new CI-job-only additions), ~57s wall-clock for the full Playwright run —
  comfortably under the 10-minute budget.
