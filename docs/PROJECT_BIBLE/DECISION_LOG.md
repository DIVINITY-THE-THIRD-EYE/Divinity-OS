# Decision Log

Consolidated architectural & product decisions. Web ADRs live in [`design/adr/`](../website/design/adr/); this log mirrors them and adds app/cross-cutting decisions. Append new decisions here (and as an ADR for web).

## Web ADRs (`design/adr/0001–0012`)

| ID | Decision | Rationale (short) |
|---|---|---|
| 0001 | Single-page static architecture | speed, security, simplicity for a marketing site |
| 0002 | GSAP **and** Framer Motion (scoped) | GSAP for scroll-tied, Framer for micro |
| 0003 | Lenis over native scroll | controlled smooth-scroll, reduced-motion safe |
| 0004 | CMS optional with fallback | zero-config; owner can edit later via Sanity |
| 0005 | Brevo for transactional email | simple API, free tier, graceful fallback |
| 0006 | UPI QR payments (manual) | India-appropriate, no gateway cost/complexity |
| 0007 | next/image with local assets | optimization without external image host |
| 0008 | RSC + client-island strategy | minimal JS, interactivity only where needed |
| 0009 | PWA now, native later | ship fast; native via Flutter when ready |
| 0010 | Offline-first strategy | resilience for the app |
| 0011 | **Supabase over Firebase** for primary data | relational + RLS; Firebase kept for FCM/analytics/crash |
| 0012 | No user theme toggle | the dark breath-paced aesthetic is the identity |
| 0013 | Staging vs Verified Content Policy | clear separation of verified and staging content |

## App / cross-cutting decisions

| ID | Decision | Rationale | Source |
|---|---|---|---|
| APP-01 | Feature-first architecture (`data/domain/presentation`) | modularity, testability | `lib/features/*` |
| APP-02 | Riverpod for state, GoRouter for nav | typed providers + declarative routing | `pubspec.yaml`, `core/router` |
| APP-03 | Enforce authz in DB (RLS), not UI | UI can't be trusted | migrations |
| APP-04 | RLS via `SECURITY DEFINER` helpers | avoid policy recursion | migration 012 |
| APP-05 | Role in JWT `app_metadata`, trigger-synced | RLS reads role without table recursion | migration 017 |
| APP-06 | Geofenced check-in as an RPC | prevent spoofing server-side | migration 010/016 |
| APP-07 | Payment lifecycle as DB state machine + triggers | integrity + auto-notifications | migrations 022/023 |
| APP-08 | Security regression tests c1–c8 are the contract | lock the security model | `supabase/tests` |
| OPS-01 | Cleanup: prove duplication by git/hash, move-not-delete | safe migration | `EXTRA_FILES/MIGRATION_REPORT.md` |
| OPS-02 | Archive Prisma website as active reference | Contains unique WebGL, Prisma, tRPC visuals/code | `PROJECT_BIBLE/COMPARATIVE_WEBSITE_ANALYSIS.md` |
| OPS-03 | Update build scripts to relative paths | Ensures portability across systems | `Divinity/build_all.ps1` |
| APP-09 | Weather/AQI Repository + Service | Segregate networking from widgets, implement SharedPrefs cache & offline fallback | `lib/services/weather_service.dart` |
| WEB-13 | Client-cached weather + accessible Google Map | localStorage 15-min cache, responsive accessible map, directions URL | `components/WeatherWidget.tsx` |
| APP-10 | Extensible, multi-provider authentication (Email, Google, Apple, Phone) | Configurable, provider-agnostic auth layer toggled via Remote Config | `lib/features/auth/` |


## How to add a decision

1. Write the decision + context + alternatives + consequences.
2. Web architecture → add an ADR file in `design/adr/NNNN-title.md` and a row here.
3. Update the affected phase doc and [AI_CONTEXT](AI_CONTEXT.md) if it changes a rule.
