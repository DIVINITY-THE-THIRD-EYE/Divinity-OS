# Phase 20 — Project History

> Sources: git history (`divinity-app`), [Divinity/docs/changelog.md](../Divinity/docs/changelog.md), [design/22-tech-debt-register.md](../divinity-third-eye/divinity/design/22-tech-debt-register.md), [website CHANGELOG](../divinity-third-eye/divinity/CHANGELOG.md).

## Changelog (app — by commit "session")

| Commit | Session | Delivered |
|---|---|---|
| `d34a9e5` | 0 | Scaffold: Flutter + Riverpod + GoRouter + Supabase + theme |
| `b38ef7e` | 1 | Auth OTP flow, role shells (Student/Trainer/Admin), users RLS migration |
| `08f531f` | 2+3 | Onboarding wizard, batches CRUD, CRM leads pipeline, attendance check-in, leave requests, admin student activation |
| `09ea0dd` | 4 | Payments, notifications, trainer dashboard |
| `4941e4c` | 5 | Firebase/FCM, admin dashboard (fl_chart), profile screen |
| `c273559` | 6 | Firebase cleanup, Student Home tab, Admin CSV export, FCM deep linking |
| `aefdf77` | — | chore: stage uncommitted changes before first push |
| `33c82a9` | — | fix: clear analyzer lints in shimmer_loading (**current HEAD**) |
| `weather-maps` | 7 | Open-Meteo Weather/AQI integration with 15-min caching, offline fallbacks, accessible Google Maps iframe, and unit tests |

Website changelog: [CHANGELOG.md](../divinity-third-eye/divinity/CHANGELOG.md) + `design/phase0` freezes.

## Decision Log

See [DECISION_LOG.md](DECISION_LOG.md) (consolidated) and `design/adr/0001–0012`.

## Migration History

23 Supabase migrations (001–023). Notable: 001 users+RLS, 010 geofence RPC, 011 payment screenshots/storage, 012 RLS-recursion fix, 013 Next.js-compat + library_books, 017 JWT role sync, 022/023 payment verification + notifications. Full list: [09_Database](09_Database.md).

## Technical Debt

From [design/22-tech-debt-register.md](../divinity-third-eye/divinity/design/22-tech-debt-register.md) (web) + observed:
- In-memory rate limiter (not multi-instance safe).
- No committed web E2E / automated a11y in CI.
- Duplicate app trees in `Divinity/apps/*` and old snapshots (now quarantined).
- Stale `build_all.ps1` path/target.
- No audit-log table; no scheduled expiry jobs.
- Web analytics provider unconfirmed.

## Known Issues

`[Needs Verification]`: consolidate from `Divinity/docs/status.md` / `task.md`. None blocking found in scan beyond the debt items above.

## Backlog

See `Divinity/docs/task.md` + [22_Product_Management](22_Product_Management.md).

## Release Notes

`[Needs Verification]`: no tagged releases found in scan. Recommend semver tags at beta launch.

## Version History

App on branch `Divinity`; website on `main`. No formal version tags yet `[Needs Verification]`.
