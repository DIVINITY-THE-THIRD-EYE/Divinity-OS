# File Index

Key files across the live products and where they're documented. Paths relative to the workspace root.

## Website — `divinity-third-eye/divinity/`

| File | Purpose | Phase |
|---|---|---|
| `app/layout.tsx` | fonts, metadata base, global chrome | 04, 11 |
| `app/page.tsx` | landing page | 04 |
| `app/api/contact/route.ts` | Brevo enquiry (rate-limit + honeypot) | 04, 08 |
| `app/api/subscribe/route.ts` | newsletter → Brevo | 04, 08 |
| `app/sitemap.ts` `robots.ts` `manifest.ts` `opengraph-image.tsx` | SEO/PWA | 04 |
| `lib/content.ts` | content source of truth / CMS fallback | 04, 25 |
| `lib/sanity.ts` | Sanity client + `fetchOrFallback` | 14, 25 |
| `lib/seo.ts` | `pageMeta()` per-page metadata | 04 |
| `lib/nav.ts` | navigation single source of truth | 04 |
| `lib/rate-limit.ts` | API abuse guard (in-memory) | 08, 12 |
| `lib/validation.ts` | shared validators | 08, 12 |
| `lib/recommend.ts` | plan recommendation (PlanCalculator) | 01, 04 |
| `lib/*.test.ts` | vitest unit suites | 16 |
| `components/BreathHero.tsx` | breathing canvas hero (signature) | 04, 11 |
| `sanity/schemas/*` | discipline, plan, testimonial, classSlot, siteSettings | 14, 25 |
| `next.config.mjs` | security headers + CSP | 12, 15 |
| `design/adr/*` | 12 ADRs | 03, 19 |
| `design/phase0/*` | quality gates, perf/a11y baselines | 13, 16 |

## App — `divinity_flutter/`

| File | Purpose | Phase |
|---|---|---|
| `lib/main.dart` | entrypoint, init (Supabase/Firebase) | 05 |
| `lib/firebase_options.dart` | Firebase config | 14 |
| `lib/core/router/app_router.dart` | GoRouter + role redirects | 05, 10 |
| `lib/core/theme/*` | theme, motion, tokens | 11 |
| `lib/features/<f>/{data,domain,presentation}` | feature modules (14) | 05–07 |
| `lib/features/shells/*` | role shells | 06, 07, 10 |
| `lib/services/fcm_service.dart` | push messaging | 24, 28 |
| `lib/services/analytics_service.dart` | analytics events | 23, 28 |
| `supabase/migrations/001–023` | schema, RLS, RPCs, triggers | 09 |
| `supabase/tests/c1–c8` | security regression tests | 12, 16 |
| `pubspec.yaml` | dependencies | 02 |

## Monorepo — `Divinity/`

| File | Purpose | Phase |
|---|---|---|
| `README.md` | workspace layout | 02 |
| `CLAUDE.md` | agentic-OS orchestration | 18, 19 |
| `docs/AUDIT_REPORT.md` | system audit | 12, 18 |
| `docs/SECURITY_REVIEW_C1_C2.md` | security review | 12 |
| `docs/BETA_LAUNCH_CHECKLIST.md` | launch checklist | 16, 21 |
| `build_all.ps1` / `.bat` | unified build (targets live repos) | 15 |
| `reference/divinity-website/` | Prisma + tRPC Next.js Reference site | 02, 04 |

## Workspace root

| File | Purpose | Phase |
|---|---|---|
| `.agents/AGENTS.md` | project-scoped customizations (approved rules) | 19, 30 |
| `.agents/skills/divinity_tte/SKILL.md` | project-scoped automated trigger skill | 19, 30 |
| `.claude/launch.json` | dev launcher (website, port 3000) | 15 |
| `EXTRA_FILES/MIGRATION_REPORT.md` | cleanup audit | 02 |
| `PROJECT_BIBLE/` | this knowledge base | 30 |
| `PROJECT_BIBLE/COMPARATIVE_WEBSITE_ANALYSIS.md` | Comparative website analysis (Prisma vs Sanity) | 02, 04 |
| `PROJECT_BIBLE/COMPLETENESS_AUDIT.md` | Completeness audit and onboarding guide | 30 |
| `PROJECT_BIBLE/ARCHITECTURE_COMPLIANCE.md` | 16-module blueprint compliance verification (gaps + backlog) | 03, 19 |
| `PROJECT_BIBLE/FINAL_INDEPENDENT_VALIDATION_REPORT.md` | Forensic validation and release audit report | 30 |
| `PROJECT_BIBLE/KNOWLEDGE_GRAPH.md` | Ecosystem dependency knowledge graph | 03, 30 |


