# Master Index — Divinity Project Bible

Navigation hub for all 31 phases, index files, and appendices. Each phase is one markdown file in this folder.

## Phases

| # | Document | Covers | Primary source |
|---|---|---|---|
| 00 | [Executive Overview](00_Executive_Overview.md) | Vision, mission, philosophy, goals, metrics, principles, glossary pointer | website README, Divinity/README, CLAUDE.md |
| 01 | [Business & Product](01_Business_Product.md) | Business/revenue model, personas, journey, pricing, plans, KPIs | website content + `[Needs Verification]` |
| 02 | [Repository Discovery](02_Repository_Discovery.md) | Inventory, folder structure, module map, deps, tech stack, env vars | full-tree scan, package.json, pubspec.yaml |
| 03 | [System Architecture](03_System_Architecture.md) | High-level arch, boundaries, rendering, data/event flow, sequences, ADRs | architecture.md, design/adr, source |
| 04 | [Public Website](04_Public_Website.md) | Pages, components, layouts, SEO, animation, CMS, routing, forms, a11y | `divinity-third-eye/divinity/` |
| 05 | [Student Mobile App](05_Student_Mobile_App.md) | Screens, navigation, features, offline, notifications, payments, progress | `divinity_flutter/lib/features` |
| 06 | [Trainer App](06_Trainer_App.md) | Dashboard, attendance, student mgmt, schedule, assignments, permissions | `divinity_flutter/lib/features/trainer` |
| 07 | [Admin Panel](07_Admin_Panel.md) | Dashboard, students, trainers, memberships, payments, classes, reports | `divinity_flutter` admin shells |
| 08 | [Backend](08_Backend.md) | API architecture, services, middleware, validation, jobs, webhooks | supabase/, app/api, Firebase |
| 09 | [Database](09_Database.md) | ER diagram, tables, relationships, indexes, RLS, migrations, seed | `supabase/migrations` |
| 10 | [Auth & Authorization](10_Auth_Authorization.md) | Login, OTP, sessions, roles, permissions, access matrix | auth feature, RLS, JWT sync |
| 11 | [UI/UX & Design System](11_UIUX_Design_System.md) | Brand, color, type, icons, components, motion, tokens, a11y | design/, theme, globals.css |
| 12 | [Security](12_Security.md) | Threat model, CSP, headers, encryption, secrets, OWASP, risk register | SECURITY_REVIEW, next.config, RLS tests |
| 13 | [Performance](13_Performance.md) | Lighthouse, bundle, lazy load, caching, code split, budgets | design/phase0, performance budgets |
| 14 | [Integrations](14_Integrations.md) | Supabase, Firebase, payments, email, SMS, WhatsApp, analytics | configs, lib/sanity, Brevo, FCM |
| 15 | [DevOps & Infrastructure](15_DevOps_Infrastructure.md) | Hosting, domains, CDN, CI/CD, monitoring, secrets, DR | Vercel/Cloudflare, .github, build scripts |
| 16 | [Testing & QA](16_Testing_QA.md) | Unit, integration, widget, E2E, a11y, perf, security tests, coverage | lib/*.test.ts, supabase/tests, test/ |
| 17 | [Operations](17_Operations.md) | Admission/trainer/payment SOPs, renewals, refunds, support, incidents | Appendix + `[Needs Verification]` |
| 18 | [Documentation](18_Documentation.md) | Dev guide, API docs, manuals, runbooks, troubleshooting | docs/, READMEs |
| 19 | [AI Context](19_AI_Context.md) | Philosophy, rules, style, decisions, pitfalls, AI instructions | CLAUDE.md, ADRs (see also AI_CONTEXT.md) |
| 20 | [Project History](20_Project_History.md) | Changelog, decision log, migration history, tech debt, backlog | git log, docs/changelog, tech-debt-register |
| 21 | [Future Roadmap](21_Future_Roadmap.md) | Milestones, pipeline, scaling, mobile + AI roadmap | roadmap.md, design/13-ai-roadmap |
| 22 | [Product Management](22_Product_Management.md) | PRDs, epics, stories, acceptance, prioritization, flags, releases | feature-inventory, design docs |
| 23 | [Data & Analytics](23_Data_Analytics.md) | KPIs, event taxonomy, funnels, retention, dashboards, A/B | analytics-taxonomy, analytics_service |
| 24 | [Communication & Notifications](24_Communication_Notifications.md) | Email/SMS/WhatsApp/push templates, reminders, retry, matrix | Brevo, FCM, notifications table |
| 25 | [Assets & Content](25_Assets_Content.md) | Images, video, PDFs, logos, CMS content, copy, workflow | public/, Sanity, lib/content |
| 26 | [Compliance & Legal](26_Compliance_Legal.md) | Privacy, terms, consent, DPDP, GDPR, retention, audit | privacy/terms pages + `[Needs Verification]` |
| 27 | [Business Continuity](27_Business_Continuity.md) | Backup, restore, DR, severity matrix, SLA, RPO/RTO | backup-strategy + `[Needs Verification]` |
| 28 | [Observability](28_Observability.md) | Logging, metrics, tracing, alerts, crash analytics, health | Crashlytics, Analytics, monitoring |
| 29 | [Scaling Strategy](29_Scaling_Strategy.md) | Growth, DB/API/storage scaling, CDN, multi-tenant, cost | architecture + `[Needs Verification]` |
| 30 | [Knowledge Management](30_Knowledge_Management.md) | Bible index, AI memory, decision tree, glossary, ownership | this folder |

## Index & reference files

- [EXECUTIVE_SUMMARY.md](EXECUTIVE_SUMMARY.md) — repository statistics & coverage
- [AI_CONTEXT.md](AI_CONTEXT.md) — rules & working instructions for AI collaborators
- [COMPARATIVE_WEBSITE_ANALYSIS.md](COMPARATIVE_WEBSITE_ANALYSIS.md) — Next.js website comparative analysis (Prisma/tRPC vs Sanity)
- [COMPLETENESS_AUDIT.md](COMPLETENESS_AUDIT.md) — Documentation coverage matrix and developer onboarding guide
- [ARCHITECTURE_COMPLIANCE.md](ARCHITECTURE_COMPLIANCE.md) — Live code verified against the 16-module ecosystem blueprint (gaps + backlog)
- [FINAL_INDEPENDENT_VALIDATION_REPORT.md](FINAL_INDEPENDENT_VALIDATION_REPORT.md) — Big Four forensic validation and release audit report
- [KNOWLEDGE_GRAPH.md](KNOWLEDGE_GRAPH.md) — Ecosystem relationship graph from repositories to business rules
- [GLOSSARY.md](GLOSSARY.md) · [FAQ.md](FAQ.md)
- [FILE_INDEX.md](FILE_INDEX.md) · [MODULE_INDEX.md](MODULE_INDEX.md) · [SEARCH_INDEX.md](SEARCH_INDEX.md)
- [DECISION_LOG.md](DECISION_LOG.md) · [DECISION_TREE.md](DECISION_TREE.md)
- [OWNERSHIP_MATRIX.md](OWNERSHIP_MATRIX.md) · [CHANGELOG.md](CHANGELOG.md) · [PROJECT_HISTORY.md](PROJECT_HISTORY.md)


## Appendices (domain-specific)

- [Yoga & Wellness Domain Guide](Appendix/Yoga_and_Wellness_Domain_Guide.md)
- [Academy Operations Handbook](Appendix/Academy_Operations_Handbook.md)
- [Brand & Content Library](Appendix/Brand_and_Content_Library.md)
