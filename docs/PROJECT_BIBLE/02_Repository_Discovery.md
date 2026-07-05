# Phase 2 — Repository Discovery

> **⚠️ SUPERSEDED (2026-07-02):** this inventory (directory tree, commit hashes, "LIVE
> app"/"LIVE website" repo labels) describes the pre-monorepo state, when `divinity_flutter`
> and `divinity-third-eye/divinity` were two separate GitHub repos. They were merged into
> **one** repo, `DIVINITY-THE-THIRD-EYE/Divinity-OS`, with canonical dirs `flutter-app/`,
> `website/`, `supabase/` (shared, repo root). Commit hashes below are historical. Body
> preserved as the original scan snapshot.
>
> Produced by automated scan of the workspace (git repos, manifests, content hashes, reference tracing). See [EXTRA_FILES/MIGRATION_REPORT.md](../EXTRA_FILES/MIGRATION_REPORT.md) for the full cleanup audit.

## Repository Inventory (post-cleanup)

Workspace root `C:\Users\PC\OneDrive\Documents\Divinity TTE\`:

```
Divinity TTE/
├── .claude/                  dev launcher (launch.json → website dev server, port 3000)
├── Divinity/                 monorepo: docs, agentic-OS, build scripts, parallel app copies
├── flutter-app/         ★ LIVE Flutter app  (divinity-app.git @ 33c82a9)
├── divinity-third-eye/       ★ LIVE website      (divinity-website.git, Sanity+Next.js)
└── EXTRA_FILES/              quarantined duplicates/junk (never deleted)
```

### Git repositories (11 found)

| Repo | Remote | Role |
|---|---|---|
| `divinity_flutter` | github …/divinity-app | **LIVE app** (newest commit `33c82a9`) |
| `divinity-third-eye/divinity` | github …/divinity-website | **LIVE website** (uncommitted work) |
| `Divinity/reference/divinity-website` | *(no remote)* | Next.js + Prisma + tRPC Reference website (preserved in monorepo) |
| `Divinity/archive/divinity_app_v1` | gitlab …/divinity-app-data | legacy archive |
| `Divinity/ANTIGRAVITY/_g1`..`_g5` | various | third-party tool clones (graphify, ECC, etc.) |
| `EXTRA_FILES/Duplicate Projects/divinity_flutter (monorepo older duplicate aefdf77)` | github …/divinity-app | older duplicate (clean aefdf77) (quarantined) |


## Folder Structure (live products)

### Website — `website/`
```
app/        13 routes (home, about, services[/slug], pricing, schedule, trainers,
            gallery, blog[/slug], events[/slug], contact, privacy, terms) +
            api/contact, api/subscribe + SEO files (sitemap, robots, manifest, OG)
components/  ~40 components: layout/, ui/, cards/, + sections & chrome
lib/         content, nav, seo, sanity, rate-limit, validation, recommend, links,
             focus-trap  (+ matching *.test.ts vitest suites)
sanity/schemas/  classSlot, discipline, plan, siteSettings, testimonial
design/      24 numbered design docs + adr/ (12 ADRs) + phase0/ quality gates
public/      brand/, founder.webp, guru_*.webp, yc_*.webp, payment-qr.png
```

### Flutter app — `flutter-app/`
```
lib/
  main.dart, firebase_options.dart
  core/        constants/, router/ (GoRouter + transitions), theme/ (+ motion)
  features/    admissions, attendance, auth (+onboarding), batches, dashboard,
               holidays, home, leave, notifications, payments, profile,
               therapeutic_logs, trainer, transformation   (14 features)
               each = data/ + domain/ + presentation/
  features/shells/  role_shell, student_shell, trainer_shell, admin_shell
  services/    analytics_service, fcm_service, fcm_provider
  shared/widgets/  shimmer, spring_tap, magnetic-style, third_eye_icon, etc.
supabase/    migrations/ (001–023) + tests/ (c1–c8) + MIGRATION_NOTES
android/  ios/  web/  test/
```

## Module Map

See [MODULE_INDEX.md](MODULE_INDEX.md) for the per-module table. High level:
- **Web modules:** routing (app/), content/CMS (lib/content + sanity), SEO (lib/seo), forms+abuse-guard (api/ + rate-limit + validation), motion (MotionProvider/GSAP/Lenis), recommendation (lib/recommend).
- **App modules:** 14 feature modules + `core` (router/theme/constants) + `services` (FCM/analytics) + `shared` widgets.
- **Data module:** 12 Postgres tables + RPCs + triggers (see [09_Database](09_Database.md)).

## Dependency Graph (summary)

- **Website** → Next.js 14 · React · Tailwind · Framer Motion · GSAP + ScrollTrigger · Lenis · Sanity client · Brevo (HTTP) · vitest. (Source: [website package.json](../website/package.json))
- **App** → flutter_riverpod + riverpod_generator · go_router · supabase_flutter · firebase_core/analytics/crashlytics/messaging · google_fonts · fl_chart · table_calendar · geolocator · share_plus · image_picker · flutter_dotenv · shared_preferences · flutter_animate. Dev: build_runner, mocktail, flutter_lints. (Source: [pubspec.yaml](../flutter-app/pubspec.yaml))

## Tech Stack

| Layer | Website | App |
|---|---|---|
| Language | TypeScript | Dart |
| Framework | Next.js 14 (App Router) | Flutter |
| State | React Server/Client components | Riverpod |
| Routing | App Router (file-based) | GoRouter |
| Styling/Theme | Tailwind + design tokens | ThemeData + google_fonts |
| Motion | Framer Motion + GSAP + Lenis | flutter_animate + custom transitions |
| Backend | API routes (Brevo), Sanity | Supabase + Firebase |
| Hosting | Vercel (+ Cloudflare) | Play Store / App Store `[Needs Verification]` |

## Build System

- **Website:** `npm install` → `npm run dev` / `npm run build && npm start`; `npm test` (vitest); `npm run lint`; `tsc --noEmit`. (Source: website README)
- **App:** `flutter pub get` → `flutter run`; `flutter build apk --release` / `appbundle`; iOS via macOS. Code-gen: `dart run build_runner`.
- **Unified:** `Divinity/build_all.ps1` / `.bat` build the live website and Flutter app (updated to point to `..\divinity-third-eye\divinity` and `..\divinity_flutter`).

## Environment Variables

| Var | Used by | Purpose |
|---|---|---|
| `BREVO_API_KEY`, `BREVO_TO_EMAIL`, `BREVO_FROM_EMAIL` | website contact/subscribe | transactional email (optional) |
| `NEXT_PUBLIC_SANITY_PROJECT_ID`, `NEXT_PUBLIC_SANITY_DATASET` | website | CMS (optional) |
| Supabase URL + anon key (in app `.env`) | Flutter app | backend connection |
| Firebase config | `firebase_options.dart` | FCM/Analytics/Crashlytics |

> Full secret inventory and storage policy: [12_Security](12_Security.md) and [14_Integrations](14_Integrations.md). Actual values are not stored in the Bible.

## Configuration Files

- Website: `next.config.mjs` (security headers + CSP), `tailwind.config.ts`, `tsconfig.json`, `vitest.config.ts`, `postcss.config.mjs`, `.env.local.example`, `.nvmrc`.
- App: `pubspec.yaml`, `analysis_options.yaml`, `.env`/`.env.example`, `firebase_options.dart`, platform gradle/xcode configs.
- Supabase: `supabase/migrations/*`, `supabase/config` (CLI).

## Coding Standards

- **Web:** strict TypeScript (`tsc --noEmit` gate), `next lint`, pure tested helpers in `lib/`, single-source-of-truth modules (`nav.ts`, `content.ts`, `seo.ts`).
- **App:** `flutter_lints` v6, feature-first `data/domain/presentation`, Riverpod providers per feature, code-gen via build_runner. See [Coding standards in 19_AI_Context](19_AI_Context.md).
