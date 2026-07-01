# Changelog

All notable changes to the Divinity Academy OS will be documented in this file.

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
