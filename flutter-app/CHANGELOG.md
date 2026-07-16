# Changelog

All notable changes to the Divinity Academy OS will be documented in this file.

## [1.1.0](https://github.com/DIVINITY-THE-THIRD-EYE/Divinity-OS/compare/divinity_flutter-v1.0.0...divinity_flutter-v1.1.0) (2026-07-16)


### ✨ Features

* 10-phase build-out — Plans, leave rules, waitlist, certs, events payments, i18n, unified theme ([d4a769e](https://github.com/DIVINITY-THE-THIRD-EYE/Divinity-OS/commit/d4a769e2d10b46a956632cf79149101e0535a5f3))
* audit log, drop-off alerts, renewal reminders, admin broadcasts ([07dd317](https://github.com/DIVINITY-THE-THIRD-EYE/Divinity-OS/commit/07dd31723454eb09572993d8caf1a00086f11c85))
* Hindi + English i18n on both Flutter app and website ([2c24840](https://github.com/DIVINITY-THE-THIRD-EYE/Divinity-OS/commit/2c2484060456b8d8d2213be38a0c156c5904d839))
* implement leave system business rules (cap, auto-approval, extension) ([e749062](https://github.com/DIVINITY-THE-THIRD-EYE/Divinity-OS/commit/e74906281b9897adbda310369a4c81f923ae0857))
* paid events, reusing the membership UPI QR payment flow ([2b53e6b](https://github.com/DIVINITY-THE-THIRD-EYE/Divinity-OS/commit/2b53e6bb1fc07917f0b2742edb5e81050d4c794e))
* remove Razorpay dead code, add admin-manageable Plans module ([bf8c29b](https://github.com/DIVINITY-THE-THIRD-EYE/Divinity-OS/commit/bf8c29b8c80b619d38ae2e0f80f0341a80b0545c))
* self-service enrollment requests + batch waitlist ([8ea25a0](https://github.com/DIVINITY-THE-THIRD-EYE/Divinity-OS/commit/8ea25a078b059a33a3b905bb07b4f31877b66537))
* **supabase:** connect real project end-to-end, fix live security bug ([6198f0b](https://github.com/DIVINITY-THE-THIRD-EYE/Divinity-OS/commit/6198f0ba1ab356e76bde2f76983ab4cbabf8e30c))
* trainer certifications (approve-to-publish) + trainer-scoped reports ([c9faea7](https://github.com/DIVINITY-THE-THIRD-EYE/Divinity-OS/commit/c9faea7a8bb97d77153d5cbde798e5e1f7b72493))
* trial-class tracking + Trainer/self-service lead conversion ([be55d8b](https://github.com/DIVINITY-THE-THIRD-EYE/Divinity-OS/commit/be55d8b88cceeba0a2120e3b8f1fdb60274ff540))
* unified void/bone/ember design system across website and Flutter app ([974f420](https://github.com/DIVINITY-THE-THIRD-EYE/Divinity-OS/commit/974f42048a205e4bbeeb2e06bf431160fc5e061f))


### 🐛 Bug Fixes

* post-merge CI cleanup (dart format + stale pgTAP assertion) ([1fcd93a](https://github.com/DIVINITY-THE-THIRD-EYE/Divinity-OS/commit/1fcd93ab8db754ff2607443c5a161dd328b78759))

## [1.1.0] - 2026-07-01

### Added
- **Module 15: Reports & Analytics**:
  - Domain models representing report categories and filters (`reports_data.dart`).
  - Analytics repository mapping Supabase database rows to aggregated figures (`reports_repository.dart`).
  - Riverpod state providers for reports analytics (`reports_provider.dart`).
  - visual reports dashboard with `fl_chart` trends, batch progress bars, and trainer performance metrics (`reports_screen.dart`).
  - CSV export utility generating files for Attendance, Revenue, Memberships, Students, Events, and Trainers (`reports_export_utils.dart`).
  - Security database tests checking student RLS boundaries and trainer query permissions (`c12_reports_test.sql`).
  - Widget and unit tests covering reports state, tabs, and metric visualizations (`reports_unit_test.dart` and `reports_widget_test.dart`).

### Changed
- Added "Reports" tab to bottom navigation bar of the `AdminShell` (`admin_shell.dart`).
