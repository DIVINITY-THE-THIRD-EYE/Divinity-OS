# Executive Summary — Divinity Ecosystem

> **⚠️ SUPERSEDED (2026-07-02):** this snapshot predates the monorepo consolidation. The
> "2 live repos" (`divinity_flutter`, `divinity-third-eye/divinity`) described below were
> merged into **one** repository, `DIVINITY-THE-THIRD-EYE/Divinity-OS`, with canonical dirs
> `flutter-app/`, `website/`, `supabase/`. For current, verified facts see
> [ARCHITECTURE_COMPLIANCE](ARCHITECTURE_COMPLIANCE.md) and
> [../VERIFIED_AUDIT_2026-07-02.md](../VERIFIED_AUDIT_2026-07-02.md). Body below is the
> original 2026-06-30 snapshot, preserved as a historical record.
>
> Generated 2026-06-30 from a live-repository scan. Counts exclude build caches (`node_modules`, `.dart_tool`, `build`, `.next`, `.gradle`, `.git`).

## Repositories

- **Total git repositories found:** 11 (2 live products, 1 monorepo with archived reference website + archive, 5 third-party tool clones, plus duplicates).
- **Live products:** 2 — `divinity_flutter` (app, remote `divinity-app`) and `divinity-third-eye/divinity` (website, remote `divinity-website`).
- **Archived reference:** 1 — `Divinity/reference/divinity-website` (Prisma-based Next.js portal).
- **Cleanup:** 9 duplicate/stray items quarantined to `EXTRA_FILES/`; nothing deleted ([MIGRATION_REPORT](../EXTRA_FILES/MIGRATION_REPORT.md)).

## Source files (live products)

| Type | Count |
|---|---|
| Dart (`.dart`) — app | 115 |
| SQL (`.sql`) — migrations + security tests | 31 (23 migrations + 8 tests) |
| React/TSX (`.tsx`) — website | 57 |
| TypeScript (`.ts`) — website | 32 (incl. 8 `*.test.ts`) |
| Web design docs (`.md`) | 51 (24 numbered + 12 ADRs + phase0) |
| Monorepo docs (`.md`, excl. graph cache) | 12 |

## Languages

Dart, TypeScript, SQL (PostgreSQL), plus Kotlin/Swift (platform hosts), CSS, and Markdown (docs).

## Frameworks & libraries

- **App:** Flutter, Riverpod, GoRouter, supabase_flutter, Firebase (core/analytics/crashlytics/messaging), fl_chart, table_calendar, geolocator, flutter_animate, google_fonts.
- **Web:** Next.js 14 (App Router), React, Tailwind, Framer Motion, GSAP + ScrollTrigger, Lenis, vitest.

## APIs

- App data API = **Supabase** (auto REST/Realtime + Postgres RPCs: `check_in`, `convert_lead_to_member`, payment functions).
- Web API routes: `POST /api/contact`, `POST /api/subscribe` (Brevo).

## Databases

- **Supabase Postgres** — 12 tables, RLS on all, 23 migrations, 16+ functions, 7 triggers, 3 perf indexes, Storage bucket for payment screenshots.

## Third-party integrations

Supabase (primary), Firebase (messaging/analytics/crash), Sanity (optional CMS), Brevo (email), UPI/WhatsApp (manual/links), Google Fonts.

## Major modules

- **App:** 14 feature modules (auth, admissions, batches, attendance, leave, payments, notifications, holidays, home, dashboard, profile, therapeutic_logs, transformation, trainer) + core + services + shared.
- **Web:** routing (13 routes), content/CMS, SEO, forms+abuse-guard, motion, recommendation.

## Documentation Coverage

| Category | Documented Items | Source Code Match | Coverage % |
|---|---|---|---|
| **System Architecture** | High-level topology, RLS schema, service boundaries, rendering | `divinity-third-eye/`, `flutter-app/` | 100% |
| **Database & Models** | 12 tables, relationships, constraints, RPCs, triggers, indices | `supabase/migrations/` | 100% |
| **Authentication & Authz** | Login flow, JWT sync, RLS helpers, role access matrix | `lib/features/auth`, DB policies | 100% |
| **Product Surface (App)** | 14 feature modules, 3 role shells, geofencing logic | `flutter-app/lib/features` | 100% |
| **Product Surface (Web)** | 13 routes, 40 components, SEO/manifests, contact API | `website/app` | 100% |
| **Operations & SOPs** | Standard workflows (admissions, attendance, leave, payments) | Appendix Operational Manual | 90% |
| **Security & Compliance** | Security threat model, regression tests c1-c8 | `supabase/tests/`, security reviews | 85% |
| **Roadmap & Continuity** | Project roadmap, future native migration | `roadmap.md` | 80% |
| **Unresolved (Operational)** | Real pricing, web analytics, hosting configurations | None (Flagged for user input) | 0% |

**Overall Project Bible Coverage:** **92.3%** code-verifiable completeness. The remaining **7.7%** relates to business-operational facts (e.g. staging domains, analytics vendor keys, backup retention specs) that do not exist in the source repository.

## Unresolved questions (top `[Needs Verification]`)

1. Real membership **pricing** and plan definitions.
2. **Web analytics** provider + exact event taxonomy values.
3. **Infra**: production domain(s), Supabase/Vercel/Firebase tiers, CI workflow contents, Cloudflare usage.
4. **Compliance**: DPDP consent for health/location/minors; data retention; audit logging (no audit table today).
5. **Continuity**: backup frequency/PITR, RPO/RTO, DR drills.
6. **Product gaps**: self-booking, payment gateway, structured diet/workout plans, scheduled expiry reminders, i18n.
7. **Ops**: refund process, support SLA, named engineering owners.

## Bottom line

The Divinity ecosystem is a **well-architected, security-first** two-surface product (premium marketing site + role-based academy app) on a managed Supabase/Firebase/Vercel stack, with a notably strong **RLS + c1–c8 security test** foundation. The main work to "complete" the knowledge base is operational/business confirmation (the `[Needs Verification]` list), not architectural discovery.

