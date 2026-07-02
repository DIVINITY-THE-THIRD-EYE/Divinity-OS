# Divinity — The Third Eye (Ecosystem Portal)

Welcome to the canonical workspace for **Divinity — The Third Eye**, a premium wellness, fitness, and yoga academy in Lucknow, India, guided by **Sachin Rajvanshi**. 

This is a single monorepo — the entire software architecture lives here, and this repo is the single source of truth:
1.  **Public Marketing Website**: Next.js 14, TailwindCSS, Framer Motion, GSAP, and Sanity CMS.
2.  **Academy Operating System (App)**: Flutter client using Riverpod, GoRouter, Supabase (data & RLS), and Firebase (FCM & Crashlytics).
3.  **Supabase Postgres Engine**: shared by both apps — 20 operational tables, row-level security (RLS) on all of them, automated database triggers, and Edge Functions. Connected to a real production project (`divinity-tte`), all 36 migrations applied, verified live 2026-07-02.

---

## 🗺️ Repo Structure

```
Divinity-OS/
├── .github/                  # CI/CD workflows, issue/PR templates, dependabot — repo-root only, GitHub requires this
├── flutter-app/              # Flutter mobile app (Android/iOS) — Riverpod, GoRouter, Firebase
├── website/                  # Next.js marketing website — zero-config with graceful fallback
├── supabase/                 # SHARED by both apps: migrations, pgTAP tests, Edge Functions
├── docs/                     # PROJECT_BIBLE knowledge base + audit/implementation tracking docs
└── scripts/                  # Cross-project build scripts (build_all.ps1 / build_all.bat)
```

`flutter-app/` and `website/` were previously separate GitHub repositories
(`Divinity-App`, `Divinity-Website`); both were merged into this monorepo with
full commit history preserved (`git log --follow` inside each folder still
shows their original history). There is one `supabase/` directory, shared —
see [`docs/SUPABASE_SETUP.md`](docs/SUPABASE_SETUP.md) for how both apps
connect to the same project and the current state of that connection.

---

## 📖 The Project Bible Index

The [`docs/PROJECT_BIBLE/`](docs/PROJECT_BIBLE/) directory contains a complete, 31-phase engineering knowledge base. Each phase is documented in detail:

| # | Document | Primary Focus |
|---|---|---|
| **00** | [Executive Overview](docs/PROJECT_BIBLE/00_Executive_Overview.md) | Vision, mission, brand philosophy ("Breathe"), and glossary. |
| **01** | [Business & Product](docs/PROJECT_BIBLE/01_Business_Product.md) | Journey mapping, membership plans, and pricing parameters. |
| **02** | [Repository Discovery](docs/PROJECT_BIBLE/02_Repository_Discovery.md) | Folder structure, dependencies, configuration files, and env vars. |
| **03** | [System Architecture](docs/PROJECT_BIBLE/03_System_Architecture.md) | System boundaries, sequence diagrams, and rendering strategies. |
| **04** | [Public Website](docs/PROJECT_BIBLE/04_Public_Website.md) | Routing structure, form actions, honey-pot validation, and CMS gateways. |
| **05** | [Student Mobile App](docs/PROJECT_BIBLE/05_Student_Mobile_App.md) | Student shell, Riverpod modules, geofencing, and payment uploads. |
| **06** | [Trainer App](docs/PROJECT_BIBLE/06_Trainer_App.md) | Trainer dashboard, attendance rosters, and student therapeutic logs. |
| **07** | [Admin Panel](docs/PROJECT_BIBLE/07_Admin_Panel.md) | Lead conversion tools, payment verifiers, and operational rosters. |
| **08** | [Backend](docs/PROJECT_BIBLE/08_Backend.md) | Rest API routes, Brevo client pipelines, and Firebase messaging. |
| **09** | [Database](docs/PROJECT_BIBLE/09_Database.md) | ER schemas, index strategies, triggers, and Postgres migrations. |
| **10** | [Auth & Authorization](docs/PROJECT_BIBLE/10_Auth_Authorization.md) | OTP login flow, JWT app_metadata mirroring, and role access matrices. |
| **11** | [UI/UX & Design System](docs/PROJECT_BIBLE/11_UIUX_Design_System.md) | Brand tokens, color variables, typography, and motion specifications. |
| **12** | [Security](docs/PROJECT_BIBLE/12_Security.md) | Threat modeling, RLS policies, Content Security Policies (CSP), and secrets. |
| **13** | [Performance](docs/PROJECT_BIBLE/13_Performance.md) | Caching, bundle sizes, rendering budgets, and Lighthouse scores. |
| **14** | [Integrations](docs/PROJECT_BIBLE/14_Integrations.md) | Firebase, Supabase, Sanity CMS, and Brevo mail engines. |
| **15** | [DevOps & Infrastructure](docs/PROJECT_BIBLE/15_DevOps_Infrastructure.md) | Build scripts, deployment tunnels, and environment configurations. |
| **16** | [Testing & QA](docs/PROJECT_BIBLE/16_Testing_QA.md) | SQL database tests, Vitest web suites, and test coverages. |
| **17** | [Operations](docs/PROJECT_BIBLE/17_Operations.md) | Admissions CRM workflows and daily operational rosters. |
| **18** | [Documentation](docs/PROJECT_BIBLE/18_Documentation.md) | Standard Operating Procedures (SOPs) and API references. |
| **19** | [AI Context](docs/PROJECT_BIBLE/19_AI_Context.md) | Conventions, pitfall warnings, and rules for future AI collaborators. |
| **20** | [Project History](docs/PROJECT_BIBLE/20_Project_History.md) | Decisions, migration logs, and technical debt registers. |
| **21** | [Future Roadmap](docs/PROJECT_BIBLE/21_Future_Roadmap.md) | Mobile/web features, milestones, and AI integration plans. |
| **22** | [Product Management](docs/PROJECT_BIBLE/22_Product_Management.md) | Feature scopes and product priority matrices. |
| **23** | [Data & Analytics](docs/PROJECT_BIBLE/23_Data_Analytics.md) | KPI structures and event tracking schemas. |
| **24** | [Comms & Notifications](docs/PROJECT_BIBLE/24_Communication_Notifications.md) | Email/push notification messaging templates. |
| **25** | [Assets & Content](docs/PROJECT_BIBLE/25_Assets_Content.md) | Image resolutions, WebP assets, and copywriting guidelines. |
| **26** | [Compliance & Legal](docs/PROJECT_BIBLE/26_Compliance_Legal.md) | Privacy policies, terms of service, and DPDP compliance. |
| **27** | [Business Continuity](docs/PROJECT_BIBLE/27_Business_Continuity.md) | DR guidelines, backup strategies, and incident response matrices. |
| **28** | [Observability](docs/PROJECT_BIBLE/28_Observability.md) | Log patterns, Crashlytics trackers, and diagnostic flows. |
| **29** | [Scaling Strategy](docs/PROJECT_BIBLE/29_Scaling_Strategy.md) | DB optimizations and serverless scaling plans. |
| **30** | [Knowledge Management](docs/PROJECT_BIBLE/30_Knowledge_Management.md) | Project Bible organization and file index references. |

### Reference & Index Documents
*   [**Ecosystem Knowledge Graph**](docs/PROJECT_BIBLE/KNOWLEDGE_GRAPH.md): Graphical mapping from repositories down to database tables and business rules using Mermaid.
*   [**Comparative Website Analysis**](docs/PROJECT_BIBLE/COMPARATIVE_WEBSITE_ANALYSIS.md): Comprehensive forensic review comparing the live Sanity website with the Prisma/tRPC reference dashboard.
*   [**Completeness & Onboarding Audit**](docs/PROJECT_BIBLE/COMPLETENESS_AUDIT.md): Detailed documentation coverage matrix alongside instructions to clone, build, run, and test every application module.
*   [**AI-Assisted Repository Validation Report**](docs/PROJECT_BIBLE/FINAL_INDEPENDENT_VALIDATION_REPORT.md): Final forensic validation audit verifying git commit histories, environmental configurations, and data integrity.
*   [**Supabase Setup**](docs/SUPABASE_SETUP.md): How both apps connect to one shared Supabase project — connected and verified live as of 2026-07-02.
*   [**Verified Production Audit**](docs/VERIFIED_AUDIT_2026-07-02.md): Latest evidence-based audit — every claim verified by running the actual build/test/lint/pgTAP gates and live production checks. Supersedes older audit docs.

---

## 🛠️ Onboarding & Local Development

Follow these setup commands to run each component locally. For complete details, see [`docs/PROJECT_BIBLE/COMPLETENESS_AUDIT.md`](docs/PROJECT_BIBLE/COMPLETENESS_AUDIT.md). To build everything at once, see [`scripts/build_all.ps1`](scripts/build_all.ps1) / [`scripts/build_all.bat`](scripts/build_all.bat).

### 1. Website (`website/`)
```bash
cd website
npm install
npm run dev     # Starts development server at http://localhost:3000
npm run build   # Compile production package
npm test        # Run Vitest test suites
```

### 2. Mobile App (`flutter-app/`)
1. Copy `dart_defines.json.example` to `dart_defines.json` in `flutter-app/` and fill in:
   ```json
   {
     "SUPABASE_URL": "https://your-project.supabase.co",
     "SUPABASE_ANON_KEY": "your-anon-key"
   }
   ```
   Secrets are injected at build/run time via `--dart-define-from-file=dart_defines.json` (no `.env` is bundled into the APK).
2. Build and run:
   ```bash
   cd flutter-app
   flutter pub get
   dart run build_runner build --delete-conflicting-outputs
   flutter run --dart-define-from-file=dart_defines.json     # Launches app on connected emulator
   flutter test    # Run unit/widget tests
   ```

### 3. Supabase Local Database
Requires Docker Desktop running. `supabase/` is shared at the repo root — the Supabase CLI expects to be run from the directory that *contains* `supabase/`, i.e. the repo root itself, not from inside `supabase/` or `flutter-app/`.
```bash
# from the repo root (Divinity-OS/)
supabase start      # Start local DB engine
supabase db reset   # Applies SQL migrations 001 to 036
supabase test db    # Run security regression tests (c1 to c16, 117 assertions)
```

To connect to the real (production) project instead of local dev, see [`docs/SUPABASE_SETUP.md`](docs/SUPABASE_SETUP.md) — **the production project (`divinity-tte`, ref `ryvilbtrsnjncyfeskqm`) is linked, migrated, and verified live as of 2026-07-02.**

---

## 🔒 Key Database Business Rules (Supabase Triggers)

*   **Geofenced Check-In**: Check-ins (`attendance`) are rejected if the user is outside the batch's `radius_meters` (default 100m) calculated via the `haversine_m` RPC.
*   **Streak Accumulation**: Triggers recalculate check-in streaks daily, allowing for consecutive weekday check-ins and ignoring weekend gaps.
*   **Role Protection**: Trigger functions block non-admin users from altering their own `role` or completing onboarding parameters without verification.
*   **Payment Immutability**: Payments transition through states (`Pending` → `Verified`). Once set to `Verified`, payment records are locked against future edits.
*   **Leave Balance Cap**: Limits student leave balance to a maximum of 4 approved leaves.
