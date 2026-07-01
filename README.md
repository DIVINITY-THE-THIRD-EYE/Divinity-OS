# Divinity — The Third Eye (Ecosystem Portal)

Welcome to the canonical workspace for **Divinity — The Third Eye**, a premium wellness, fitness, and yoga academy in Lucknow, India, guided by **Sachin Rajvanshi**. 

This repository consolidates the entire software architecture, which comprises:
1.  **Public Marketing Website**: Next.js 14, TailwindCSS, Framer Motion, GSAP, and Sanity CMS.
2.  **Academy Operating System (App)**: Flutter client using Riverpod, GoRouter, Supabase (data & RLS), and Firebase (FCM & Crashlytics).
3.  **Supabase Postgres Engine**: 18 operational tables, row-level security (RLS), and automated database triggers.

---

## 🗺️ Workspace Structure

The workspace root is organized into exactly six logical directories:
```
Divinity TTE/
├── .agents/                  # Project-scoped customization rules (AGENTS.md)
├── .claude/                  # dev launch configurations (launch.json)
├── Divinity/                 # Monorepo (docs, archived calling_app, and build scripts)
│   └── reference/            # Prisma/tRPC reference portal & WebGL particle shader
├── divinity_flutter/         # ★ LIVE operational Flutter app (divinity-app.git @ 33c82a9)
├── divinity-third-eye/       # ★ LIVE Next.js Sanity website (divinity-website.git)
├── EXTRA_FILES/              # Quarantined duplicates, logs, and stray platform folders
└── PROJECT_BIBLE/            # The comprehensive project knowledge base
```

---

## 📖 The Project Bible Index

The [`PROJECT_BIBLE/`](PROJECT_BIBLE/) directory contains a complete, 31-phase engineering knowledge base. Each phase is documented in detail:

| # | Document | Primary Focus |
|---|---|---|
| **00** | [Executive Overview](PROJECT_BIBLE/00_Executive_Overview.md) | Vision, mission, brand philosophy ("Breathe"), and glossary. |
| **01** | [Business & Product](PROJECT_BIBLE/01_Business_Product.md) | Journey mapping, membership plans, and pricing parameters. |
| **02** | [Repository Discovery](PROJECT_BIBLE/02_Repository_Discovery.md) | Folder structure, dependencies, configuration files, and env vars. |
| **03** | [System Architecture](PROJECT_BIBLE/03_System_Architecture.md) | System boundaries, sequence diagrams, and rendering strategies. |
| **04** | [Public Website](PROJECT_BIBLE/04_Public_Website.md) | Routing structure, form actions, honey-pot validation, and CMS gateways. |
| **05** | [Student Mobile App](PROJECT_BIBLE/05_Student_Mobile_App.md) | Student shell, Riverpod modules, geofencing, and payment uploads. |
| **06** | [Trainer App](PROJECT_BIBLE/06_Trainer_App.md) | Trainer dashboard, attendance rosters, and student therapeutic logs. |
| **07** | [Admin Panel](PROJECT_BIBLE/07_Admin_Panel.md) | Lead conversion tools, payment verifiers, and operational rosters. |
| **08** | [Backend](PROJECT_BIBLE/08_Backend.md) | Rest API routes, Brevo client pipelines, and Firebase messaging. |
| **09** | [Database](PROJECT_BIBLE/09_Database.md) | ER schemas, index strategies, triggers, and 23 Postgres migrations. |
| **10** | [Auth & Authorization](PROJECT_BIBLE/10_Auth_Authorization.md) | OTP login flow, JWT app_metadata mirroring, and role access matrices. |
| **11** | [UI/UX & Design System](PROJECT_BIBLE/11_UIUX_Design_System.md) | Brand tokens, color variables, typography, and motion specifications. |
| **12** | [Security](PROJECT_BIBLE/12_Security.md) | Threat modeling, RLS policies, Content Security Policies (CSP), and secrets. |
| **13** | [Performance](PROJECT_BIBLE/13_Performance.md) | Caching, bundle sizes, rendering budgets, and Lighthouse scores. |
| **14** | [Integrations](PROJECT_BIBLE/14_Integrations.md) | Firebase, Supabase, Sanity CMS, and Brevo mail engines. |
| **15** | [DevOps & Infrastructure](PROJECT_BIBLE/15_DevOps_Infrastructure.md) | Build scripts, deployment tunnels, and environment configurations. |
| **16** | [Testing & QA](PROJECT_BIBLE/16_Testing_QA.md) | SQL database tests, Vitest web suites, and test coverages. |
| **17** | [Operations](PROJECT_BIBLE/17_Operations.md) | Admissions CRM workflows and daily operational rosters. |
| **18** | [Documentation](PROJECT_BIBLE/18_Documentation.md) | Standard Operating Procedures (SOPs) and API references. |
| **19** | [AI Context](PROJECT_BIBLE/19_AI_Context.md) | Conventions, pitfall warnings, and rules for future AI collaborators. |
| **20** | [Project History](PROJECT_BIBLE/20_Project_History.md) | Decisions, migration logs, and technical debt registers. |
| **21** | [Future Roadmap](PROJECT_BIBLE/21_Future_Roadmap.md) | Mobile/web features, milestones, and AI integration plans. |
| **22** | [Product Management](PROJECT_BIBLE/22_Product_Management.md) | Feature scopes and product priority matrices. |
| **23** | [Data & Analytics](PROJECT_BIBLE/23_Data_Analytics.md) | KPI structures and event tracking schemas. |
| **24** | [Comms & Notifications](PROJECT_BIBLE/24_Communication_Notifications.md) | Email/push notification messaging templates. |
| **25** | [Assets & Content](PROJECT_BIBLE/25_Assets_Content.md) | Image resolutions, WebP assets, and copywriting guidelines. |
| **26** | [Compliance & Legal](PROJECT_BIBLE/26_Compliance_Legal.md) | Privacy policies, terms of service, and DPDP compliance. |
| **27** | [Business Continuity](PROJECT_BIBLE/27_Business_Continuity.md) | DR guidelines, backup strategies, and incident response matrices. |
| **28** | [Observability](PROJECT_BIBLE/28_Observability.md) | Log patterns, Crashlytics trackers, and diagnostic flows. |
| **29** | [Scaling Strategy](PROJECT_BIBLE/29_Scaling_Strategy.md) | DB optimizations and serverless scaling plans. |
| **30** | [Knowledge Management](PROJECT_BIBLE/30_Knowledge_Management.md) | Project Bible organization and file index references. |

### Reference & Index Documents
*   [**Ecosystem Knowledge Graph**](PROJECT_BIBLE/KNOWLEDGE_GRAPH.md): Graphical mapping from repositories down to database tables and business rules using Mermaid.
*   [**Comparative Website Analysis**](PROJECT_BIBLE/COMPARATIVE_WEBSITE_ANALYSIS.md): Comprehensive forensic review comparing the live Sanity website with the Prisma/tRPC reference dashboard.
*   [**Completeness & Onboarding Audit**](PROJECT_BIBLE/COMPLETENESS_AUDIT.md): Detailed documentation coverage matrix alongside instructions to clone, build, run, and test every application module.
*   [**AI-Assisted Repository Validation Report**](PROJECT_BIBLE/FINAL_INDEPENDENT_VALIDATION_REPORT.md): Final forensic validation audit verifying git commit histories, environmental configurations, and data integrity.

---

## 🛠️ Onboarding & Local Development

Follow these setup commands to run each component locally. For complete details, see [`PROJECT_BIBLE/COMPLETENESS_AUDIT.md`](PROJECT_BIBLE/COMPLETENESS_AUDIT.md).

### 1. Live Website (`divinity-third-eye/divinity`)
```bash
cd divinity-third-eye/divinity
npm install
npm run dev     # Starts development server at http://localhost:3000
npm run build   # Compile production package
npm test        # Run Vitest test suites
```

### 2. Live Mobile App (`divinity_flutter`)
1. Copy `dart_defines.json.example` to `dart_defines.json` in `divinity_flutter/` and fill in:
   ```json
   {
     "SUPABASE_URL": "https://your-project.supabase.co",
     "SUPABASE_ANON_KEY": "your-anon-key"
   }
   ```
   Secrets are injected at build/run time via `--dart-define-from-file=dart_defines.json` (no `.env` is bundled into the APK).
2. Build and run:
   ```bash
   cd divinity_flutter
   flutter pub get
   dart run build_runner build --delete-conflicting-outputs
   flutter run --dart-define-from-file=dart_defines.json     # Launches app on connected emulator
   flutter test    # Run unit/widget tests
   ```

### 3. Supabase Local Database
Requires Docker Desktop running.
```bash
cd divinity_flutter
supabase start      # Start local DB engine
supabase db reset   # Applies SQL migrations 001 to 036
supabase test db    # Run security regression tests (c1 to c16, 117 assertions)
```

---

## 🔒 Key Database Business Rules (Supabase Triggers)

*   **Geofenced Check-In**: Check-ins (`attendance`) are rejected if the user is outside the batch's `radius_meters` (default 100m) calculated via the `haversine_m` RPC.
*   **Streak Accumulation**: Triggers recalculate check-in streaks daily, allowing for consecutive weekday check-ins and ignoring weekend gaps.
*   **Role Protection**: Trigger functions block non-admin users from altering their own `role` or completing onboarding parameters without verification.
*   **Payment Immutability**: Payments transition through states (`Pending` → `Verified`). Once set to `Verified`, payment records are locked against future edits.
*   **Leave Balance Cap**: Limits student leave balance to a maximum of 4 approved leaves.
