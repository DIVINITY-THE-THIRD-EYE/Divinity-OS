# Divinity — Design Upgrade Dossier

A competitive reverse-engineering study (21 yoga/wellness sites + 11 product/interaction leaders),
turned into an **incremental, evidence-based, measurable** upgrade plan for the existing Divinity
production build.

> **Status: AWAITING APPROVAL. No application code has been modified.**
> Scope rule: preserve existing architecture, routing, branding, business logic, content, CMS, SEO,
> APIs, and working animations. Upgrade like a premium software release, not a redesign. **Free tools only.**

## Phase 0 — Engineering baseline (current stage)
The app is **frozen** and baselined before any feature work. See **[`phase0/`](phase0/README.md)** and
**[`../BASELINE.md`](../BASELINE.md)**: real env/build data, 8 architecture diagrams, CI quality gates,
performance/a11y/SEO baselines, component & motion inventories, versioned token export, computed
tech-debt re-score, and the dev/preview/staging/production release strategy. Phase 1 begins only when the
baseline is green.

## How to read this

| # | Doc | What's inside |
|---|---|---|
| 00 | **README** (this) | Index, integrity notes, approval ask |
| 01 | [Research & matrix](01-research-and-matrix.md) | 21-site tiered report · ranked comparison matrix (17 categories) |
| 05 | [Benchmark: product leaders](05-benchmark-product-leaders.md) | Apple, Linear, Stripe, Airbnb, Headspace, Calm, Raycast, Nike, Vercel, Arc, Notion — interaction-only |
| 06 | [Quantitative scoring matrix](06-scoring-matrix.md) | 1–10 across 14 dims, **weighted overall** (leaders 8.6 · yoga 6.8 · Divinity 7.4) |
| 02 | [Patterns · system · IA](02-patterns-system-ia.md) | Pattern library · component inventory · IA review |
| 07 | [Visual pattern library](07-visual-pattern-library.md) | 14 capture-ready pattern cards (links, wireframes, slots) |
| 08 | [Design tokens](08-design-tokens.md) | Full token system: color/semantic, type, 8pt space, radius, border, elevation, blur/glass, opacity, z-index, motion, breakpoints, theme |
| 03 | [Web upgrade plan](03-web-upgrade-plan.md) | **Approval artifact** — R1–R11 (evidence fields), CRO, a11y, perf, SEO, Phase 1–4 roadmap, file-by-file, risk register, timeline |
| 09 | [Accessibility audit](09-accessibility-audit.md) | WCAG 2.2 AA · keyboard · focus · SR · contrast · reduced-motion · forced-colors · targets · RTL · i18n |
| 10 | [Motion specification](10-motion-spec.md) | Durations, easing, stagger, springs, scroll, triggers, exits, shared-element, mobile alt, reduced-motion |
| 11 | [Performance budgets](11-performance-budgets.md) | Lighthouse ≥95, LCP<2.0s, CLS<0.05, INP<150ms, JS/image/font budgets, CI gate |
| 12 | [Implementation planning](12-implementation-planning.md) | Dependency graph · milestones · sprints · QA · rollback · analytics events · A/B · monitoring |
| 04 | [Mobile & motion](04-mobile-and-motion.md) | Android (M3) + iOS (HIG) UX, foldables/widgets/Live Activities/deep links/biometrics; PWA now |
| 13 | [AI roadmap](13-ai-roadmap.md) | Future AI modules, free/open-weight-first, privacy & cost honesty |

### v1.0 approval additions (baseline governance — grounded in the actual codebase)
| # | Doc | What's inside |
|---|---|---|
| — | [adr/](adr/README.md) | **12 ADRs** — single-page SSG, GSAP+Framer, Lenis, CMS-fallback, Brevo, UPI, next/image, RSC, PWA, offline-first, Supabase-vs-Firebase, no-theme-toggle |
| 14 | [Component dependency map](14-component-dependency-map.md) | Real import graph, coupling, simplification opportunities |
| 15 | [User journeys](15-user-journeys.md) | 9 journeys: goals/actions/emotion/friction/opportunity/metric |
| 16 | [Analytics & event taxonomy](16-analytics-taxonomy.md) | Event catalog, properties, funnels, KPIs (no-PII) |
| 17 | [Feature inventory](17-feature-inventory.md) | Every feature: status/deps/priority/effort/value/debt |
| 18 | [API & data contracts](18-api-data-contracts.md) | Contact route (verbatim) + proposed subscribe; data model; sequences |
| 19 | [Content strategy](19-content-strategy.md) | Voice, hierarchy, microcopy, form/empty/error messaging |
| 20 | [Visual regression](20-visual-regression.md) | Baselines, thresholds, breakpoints, animation testing |
| 21 | [Security checklist](21-security-checklist.md) | Auth, validation, CSRF/XSS/CSP, rate limit, secrets, logging |
| 22 | [Tech-debt register](22-tech-debt-register.md) | 16 items with impact/risk/solution/effort/milestone |
| 23 | [Launch readiness](23-launch-readiness.md) | Perf/a11y/SEO/security/content/rollback gates |
| 24 | [Success metrics](24-success-metrics.md) | 6-month targets; honest "unmeasured today" baselines |

### Deliverable → doc map (original 18 + the 10 review additions)
Research(1)→01 · Matrix(2)→01 · Pattern library(3)→02+07 · Design system(4)→08 · Web UX(5)→03 ·
Android(6)/iOS(7)→04 · Interaction/motion(8)→10 · Component inventory(9)→02 · IA(10)→02 ·
CRO(11)→03 · A11y(12)→09 · Perf(13)→11 · SEO(14)→03 · Roadmap(15)→03 · File-by-file(16)→03 ·
Risk register(17)→03 · Timeline(18)→03.
Review adds: product-leader benchmarks→05 · scoring→06 · visual library→07 · full tokens→08 ·
expanded a11y→09 · dedicated motion→10 · perf budgets→11 · sprint/dependency/QA/rollback/analytics/AB/monitoring→12 ·
expanded mobile→04 · AI roadmap→13.

## Research integrity
- **19/21** yoga sites + **11/11** product leaders fetched and analysed for real.
- **2 excluded** (no detail invented): `aoustudio.com` (JS-only Wix shell), `hale.now` (HTTP 503).
- **Scores** are structured expert assessment, not lab data; **perf/a11y of third-party sites are
  stack-inferred**. Divinity's own perf/a11y targets are concrete and must be confirmed with
  Lighthouse/axe (see 11, 09).
- **No external screenshots** were fabricated; 07 is a capture-ready scaffold (see `assets/patterns/README.md`).

## The headline
Divinity already scores **7.4** — above the yoga-field average (6.8), tied to its best peers — on the
strength of **motion, visual, branding, dev quality (all 9)**. The drag is **Booking (4), Conversion (5),
Trust (6)**. Closing only those reaches **~8.4 (leader tier)** without touching what excels. Phase 1 of
[03](03-web-upgrade-plan.md) targets exactly that.

## Approval ask
Review and approve (a) the **scope/priority** in [03 §15](03-web-upgrade-plan.md#15-prioritised-roadmap)
and (b) the two items needing real-world sign-off — **stats numbers** (R2) and **intro-offer terms**
(R1/R8). On approval I'll begin **Phase 1**, preserving all existing architecture, branding, and features.
