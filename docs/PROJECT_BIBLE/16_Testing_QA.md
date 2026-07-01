# Phase 16 — Testing & QA

> Sources: website `lib/*.test.ts` (vitest), `vitest.config.ts`; app `test/`, `integration_test` (pubspec), `supabase/tests/c1–c8`; [design/20-visual-regression.md](../divinity-third-eye/divinity/design/20-visual-regression.md), [design/23-launch-readiness.md](../divinity-third-eye/divinity/design/23-launch-readiness.md).

## Unit Tests

**Website (vitest):** committed suites for the pure `lib/` logic —
`api-routes.test.ts`, `content.test.ts`, `form-error.test.ts`, `links.test.ts`, `rate-limit.test.ts`, `recommend.test.ts`, `seo.test.ts`, `validation.test.ts`. Run: `npm test`.

**App:** `test/` dir present; `mocktail` for mocking; `flutter test`. `[Needs Verification]`: enumerate app unit-test coverage.

## Integration Tests

- App: `integration_test` package declared in `pubspec.yaml` (Flutter integration tests). `[Needs Verification]` for committed integration scenarios.
- Web: `api-routes.test.ts` exercises route logic.

## Widget/UI Tests

Flutter widget tests via `flutter_test`. `[Needs Verification]` for coverage of key screens (check-in, payments).

## E2E Tests

`[Needs Verification]`: no committed Playwright/E2E suite found for the website. Playwright skills are available if added. Visual-regression plan documented in [design/20-visual-regression.md](../divinity-third-eye/divinity/design/20-visual-regression.md).

## Accessibility Tests

Manual audit + baseline ([design/09-accessibility-audit.md], [design/phase0/accessibility-baseline.md]). `[Needs Verification]` for automated a11y (axe) in CI.

## Performance Tests

Lighthouse baselines committed in `design/phase0/reports/`. Budgets in `design/11-performance-budgets.md`. See [13_Performance](13_Performance.md).

## Security Tests

**Strong suite** — 8 SQL regression tests in `supabase/tests/` (c1–c8) covering privileged fields, geofence, streaks, JWT role, latches, lead conversion, therapeutic logs, payment verification. These are the security contract — keep green on any RLS/trigger change. See [12_Security](12_Security.md).

## Test Coverage

| Surface | Tooling | State |
|---|---|---|
| Web lib logic | vitest | Good (8 suites) |
| Web E2E | — | Gap `[Needs Verification]` |
| App unit/widget | flutter_test + mocktail | Partial `[Needs Verification]` |
| App integration | integration_test | `[Needs Verification]` |
| DB security | SQL c1–c8 | Strong |

## QA Checklist

Pre-launch QA lives in [BETA_LAUNCH_CHECKLIST.md](../Divinity/docs/BETA_LAUNCH_CHECKLIST.md) and [design/23-launch-readiness.md](../divinity-third-eye/divinity/design/23-launch-readiness.md). Quality gates: web → `npm test` + `npm run lint` + `tsc --noEmit`; app → `flutter analyze` + `flutter test`.
