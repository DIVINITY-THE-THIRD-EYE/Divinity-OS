# AI_CONTEXT — Working Instructions for AI Collaborators

> Read this **first**. It is the single most important file for any AI agent working on Divinity. It encodes the non-negotiable rules, the conventions, and the known pitfalls so a fresh agent can act safely without re-deriving everything.

## 1. Project shape (orient yourself)

- **Single monorepo** (`DIVINITY-THE-THIRD-EYE/Divinity-OS`, one GitHub repo, one Supabase project) with two live products: **website** `website/` (Next.js) and **app** `flutter-app/` (Flutter, package `divinity_app`). Both were previously separate repos; they were merged with full commit history preserved.
- Shared backend lives at `supabase/` (root-level, one directory for both apps): migrations, pgTAP tests, Edge Functions.
- Backend: **Supabase** (Postgres + RLS + Auth + Storage) and **Firebase** (FCM/Analytics/Crashlytics/App Check/Remote Config/AI Logic).
- `divinity_flutter/` (NOT `flutter-app/`, which is the live app) is an **empty legacy
  directory** — do not use it. `Divinity/` is archived reference material (Prisma reference
  website, legacy build scripts) — gitignored, not part of the shipped product.
- `EXTRA_FILES/` is quarantine containing old duplicate project folders, stray platforms, and old assets — also gitignored.

## 2. Non-Negotiable Rules

1. **Never weaken Row-Level Security.** Every table has RLS (all 20 application tables, verified). Privileged fields (`role`, approval flags, payment status) are locked by triggers (`lock_privileged_fields`, `lock_payment_fields`). Changes to RLS must keep the `supabase/tests/c1..c16` (117 assertions) security tests passing — run via `supabase test db`.
2. **Roles are the spine.** Student / Trainer / Admin. Authorization is enforced in the DB (RLS + `is_admin`/`is_trainer` helpers + JWT `app_metadata` role sync), not just in the UI.
3. **The website must run with zero config.** Don't introduce a hard dependency on Sanity or Brevo; use the existing `fetchOrFallback` / logged-fallback pattern.
4. **Respect `prefers-reduced-motion`.** All motion must degrade. Don't add unconditional animations.
5. **Keep secrets out of git and out of this Bible.** Use `.env` / Vercel env vars.
6. **Money is sensitive.** The payment flow is a DB state machine with triggers and notifications — change it via migrations + tests, never by ad-hoc UI writes.
7. **Migrations are append-only.** Add `NNN_*.sql`; never rewrite history of applied migrations.
8. **Generative AI must be free/Spark-tier and DPDP compliant.** Use `FirebaseAI.googleAI()` to remain on the free Spark plan (do not upgrade to Blaze Vertex AI). Enforce explicit data tracking consent checkbox in onboarding before profile activation. Secure AI endpoints via Firebase App Check and manage settings through Remote Config.
9. **Ecosystem Architecture Compliance.** All development must align with the 16-module ecosystem structure (Website + Mobile + Admin Panel) and operational flows (Student Journey, Payments, Attendance, Workouts, Notifications) defined in the `divinity_tte` skill.
10. **Module Implementation Standard.** When implementing/extending a core module, address all layers: Database (migrations, RLS, triggers), Backend (repositories, models, providers), Presentation (screens for relevant roles), and Tests (unit, widget, pgTAP).

## 3. Coding Style & Conventions

**Flutter app**
- Feature-first: `lib/features/<feature>/{data,domain,presentation}`. New features follow this exactly.
- State: Riverpod (`*_provider.dart`), generated where annotated (`riverpod_generator` + build_runner).
- Routing: GoRouter in `core/router/app_router.dart`; role shells in `features/shells`.
- Theme/motion: `core/theme` + `shared/widgets` (reuse `spring_tap`, `shimmer_loading`, `third_eye_icon`).
- Lints: `flutter_lints` ^6 — keep `flutter analyze` clean (latest commit was literally a lint-clearing fix).
- Weather & Caching: Segregate network calls in a reusable `WeatherService` and repository. Use `SharedPreferences` to cache weather telemetry for 15 minutes, falling back to cached values when offline or upon API timeout (5s).

**Website**
- Single sources of truth: navigation → `lib/nav.ts`, content/CMS fallback → `lib/content.ts`, metadata → `lib/seo.ts`.
- Keep `lib/` helpers **pure and tested** (`*.test.ts` with vitest).
- Server Components by default; client islands only where interaction/motion needs them (see ADR-0008).
- SEO is first-class: update `sitemap.ts`, JSON-LD (`JsonLd.tsx`), and `pageMeta()` when adding routes.
- Weather & Maps Config: Pull all coordinate configurations from `locationConfig` in `lib/content.ts`. Cache weather requests client-side in `localStorage` (15-min TTL) to protect Open-Meteo performance budgets. Fail gracefully to cached data on error.

## 4. Naming Conventions

- Dart: `snake_case` files, `PascalCase` types, `camelCase` members; providers suffixed `Provider`.
- TS/React: `PascalCase` components, `camelCase` functions, route folders lowercase.
- SQL: `snake_case` tables/columns; policies named by intent (`students_read_own_payments`).
- Migrations: `NNN_short_description.sql` (zero-padded, sequential).

## 5. Architectural Decisions (see DECISION_LOG + design/adr)

Key locked choices: **Supabase over Firebase for primary data** (ADR-0011; Firebase kept only for FCM/analytics/crash), **GSAP + Lenis** for scroll motion (ADR-0002/0003), **single-page static + RSC islands** for web (ADR-0001/0008), **UPI QR payments** (ADR-0006), **CMS optional with fallback** (ADR-0004), **PWA now / native later** (ADR-0009), **no user theme toggle** (ADR-0012). Don't relitigate these without an ADR.

## 6. Known Pitfalls

- **RLS recursion:** policies that query `users` from within `users` policies caused infinite recursion — fixed in migration `012_fix_rls_recursion` by using `SECURITY DEFINER` helper functions (`is_admin`, `is_trainer`). Use the helpers; don't inline sub-selects on `users`.
- **JWT role drift:** the app reads role from JWT `app_metadata`; it is synced by trigger `sync_user_role_to_auth` (migration 017). If you change a user's role directly in the table, ensure the trigger fires / re-issue the token.
- **Geofenced check-in:** attendance check-in is an RPC (`check_in`) using `haversine_m` against the batch's coordinates + `radius_meters`. Batches now **require** coordinates (migration 016). Don't bypass the RPC.
- **Duplicate trees:** Older duplicate apps have been successfully quarantined under `EXTRA_FILES/Duplicate Projects/`.
- **Build script path updates:** `build_all.ps1` and `build_all.bat` have been updated to build the live website and Flutter app from the root directories using relative paths.

## 7. Current Priorities

**Updated 2026-07-02, verified against live state (code, GitHub, and the linked production
Supabase project) — see [../VERIFIED_AUDIT_2026-07-02.md](../VERIFIED_AUDIT_2026-07-02.md)
for full evidence.**

- **Application code is feature-complete against the 16-module blueprint** (plus Feedback,
  Support, Weekly Schedule beyond it). All gates green: `flutter analyze`/`test` (262/262),
  website `lint`/`tsc`/`vitest` (61/61)/`build`, pgTAP (117/117 assertions).
- **Production Supabase is connected and live**: project `divinity-tte`
  (`ryvilbtrsnjncyfeskqm`), all 36 migrations applied with zero drift, RLS verified live,
  `verify-certificate` Edge Function deployed and `ACTIVE`.
- **GitHub Secrets: 8/8 configured** (Supabase + Android signing) on
  `DIVINITY-THE-THIRD-EYE/Divinity-OS`.
- **Remaining priorities are operational, not code**: (1) iOS signing needs a Mac + Apple
  Developer account — cannot be done from this environment; (2) Android/iOS store
  submissions need Play Console / App Store Connect apps created; (3) `CERT_VERIFY_ENDPOINT`
  needs setting on the website's Vercel project; (4) Firebase App Check enforcement needs
  confirming against a real signed release build; (5) a known CI tooling bug —
  `release-please-action@v4` rejects the `package-name`/`changelog-types` inputs used in
  `.github/workflows/release-flutter.yml` / `release-website.yml` and fails to locate
  `pubspec.yaml` — needs migrating to the action's manifest-based config.

## 8. Things Never to Change (without explicit sign-off)

- The RLS model and privileged-field locks.
- The payment state machine + notification triggers.
- The "zero-config + graceful fallback" guarantee on the website.
- The brand tokens (void/bone/ember) and the "Breathe" concept — these are product identity, not arbitrary styling.

## 9. AI Working Instructions

1. **Locate before editing.** Use the live trees; confirm which of the duplicate copies you're in (`git remote -v`, path).
2. **Change data via migrations + tests.** Add a migration and, if it touches security, a `tests/cN_*.sql`.
3. **Keep gates green:** web → `npm test`, `npm run lint`, `tsc --noEmit`; app → `flutter analyze`, `flutter test`.
4. **Don't guess business facts.** Pricing, legal entity, infra accounts are `[Needs Verification]` — ask, don't invent.
5. **Record decisions** as ADRs (web: `design/adr/`; app/global: append to [DECISION_LOG.md](DECISION_LOG.md)).
6. **Update this Bible** when you change architecture, schema, or a non-negotiable.
