# 10 — Testing Report

## What exists (verified this session, fresh runs)

| Surface | Type | Count | Result |
|---|---|---|---|
| Flutter | Unit + widget (`flutter test`) | 262 tests | 262/262 pass |
| Flutter | `flutter analyze` (static) | — | 0 issues |
| Website | Unit (`vitest run`) | 66 tests, 10 files | 66/66 pass |
| Website | Type check (`tsc --noEmit`) | — | 0 errors |
| Website | Lint (`next lint`) | — | 0 warnings/errors |
| Website | E2E (Playwright, `website/e2e/`) | present (`test:e2e` script) | **not run this session** — see gap below |
| Database | pgTAP (`supabase test db`) | 23 files, 188 assertions | 188/188 pass (after this session's fix; was 186/188) |

## Coverage by area (Flutter)

Test files exist for the large majority of the 22 feature folders — spot-checked in this session's Flutter architecture map: `weather_unit_test.dart`, `support_widget_test.dart`, `therapeutic_logs_unit_test.dart`, `trainer_check_in_unit_test.dart`, `transformation_unit_test.dart`, `workout_unit_test.dart`, `workout_widget_test.dart` all ran successfully as part of the 262-test suite. `integration_test/` also exists as a separate directory (32 files total between `test/` and `integration_test/`), though integration tests specifically were not separately executed this session (the `flutter test` run covers `test/`, not the on-device `integration_test/` suite).

## Coverage by area (Supabase/pgTAP)

Every migration from the original security fix (`c1_privileged_fields_test.sql`) through the newest feature (`c23_event_payments_test.sql`) has dedicated test coverage — 23 files mapping close to 1:1 with major migrations/features. This is unusually thorough pgTAP coverage for a project this size, and it directly caught the test-fragility issue this session found and fixed (`c17`).

## Gaps

1. **Website Playwright e2e suite was not run this session.** `website/e2e/` exists and `package.json` has a `test:e2e` script, but running it requires browser binaries (`playwright install`) which weren't provisioned in this pass. This is a real gap in this audit's verification, not a claim that the e2e suite itself is broken — it simply wasn't exercised. **Recommendation:** run `npx playwright install && npm run test:e2e` as a follow-up and report results separately.
2. **Flutter `integration_test/` suite was not separately run.** These typically require a connected device/emulator; none was available in this sandboxed session.
3. **No production-equivalent load/concurrency testing** beyond the existing pgTAP concurrency unit tests (`c16_enrollment_concurrency_test.sql`) — those test correctness of the locking logic, not throughput under real concurrent load.
4. **No mutation testing or coverage-percentage tooling** is configured on either surface (no `flutter test --coverage` output reviewed, no `vitest --coverage` configured/run). Test *counts* are known and all passing; test *coverage percentage* is not.
5. **The c17 test fragility itself** (see [04_Bug_Report.md](04_Bug_Report.md)) is a reminder that date-relative test fixtures need explicit day-of-week guarding — worth a quick sweep of the other date-relative fixtures (`c3_streak_test.sql` and others use similar patterns) to confirm none of them have a latent version of the same issue. Not done this session; flagged as a roadmap item.

## Testing roadmap

1. Run the Playwright e2e suite and report results (Small effort).
2. Add `flutter test --coverage` / `vitest run --coverage` to CI so coverage percentage is visible over time, not just pass/fail counts (Small effort).
3. Audit other date-relative pgTAP fixtures for the same day-of-week fragility pattern found in `c17` (Small effort, given the pattern is now known).
4. Consider a lightweight load test against the Supabase backend before any major marketing push that would drive a traffic spike (Medium effort, needs a decision on acceptable tooling — k6, Artillery, or similar).
