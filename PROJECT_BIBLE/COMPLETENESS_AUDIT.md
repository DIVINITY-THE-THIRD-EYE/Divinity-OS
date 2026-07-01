# Project Bible Completeness Audit

This document performs a comprehensive audit of the Divinity Ecosystem's source repositories against the Project Bible (Phases 00–30), documenting coverage metrics, identifying gaps, and providing instructions for developer onboarding (clone, install, build, run, test, deploy).

---

## 1. Documentation Coverage Matrix

The table below breaks down the coverage status of all project components. Every item found in the source code is categorized as **Covered**, **Missing**, or **Needs Verification**.

| Category | Item in Code | Status | Documented In |
|---|---|---|---|
| **Repositories** | `divinity_flutter` | **Covered** | [02_Repository_Discovery](02_Repository_Discovery.md) |
| | `divinity-third-eye/divinity` | **Covered** | [02_Repository_Discovery](02_Repository_Discovery.md) |
| | `Divinity/reference/divinity-website` | **Covered** | [COMPARATIVE_WEBSITE_ANALYSIS](COMPARATIVE_WEBSITE_ANALYSIS.md) |
| **Modules** | 14 Flutter features | **Covered** | [MODULE_INDEX](MODULE_INDEX.md), [05_Student_Mobile_App](05_Student_Mobile_App.md) |
| | 9 Website core helpers | **Covered** | [MODULE_INDEX](MODULE_INDEX.md), [04_Public_Website](04_Public_Website.md) |
| **Components** | Flutter Role/Student/Trainer/Admin shells | **Covered** | [05_Student_Mobile_App](05_Student_Mobile_App.md), [06_Trainer_App](06_Trainer_App.md), [07_Admin_Panel](07_Admin_Panel.md) |
| | Flutter Custom Widgets (`spring_tap`, etc.) | **Covered** | [11_UIUX_Design_System](11_UIUX_Design_System.md) |
| | Website `BreathHero`, `Ambient`, etc. | **Covered** | [04_Public_Website](04_Public_Website.md) |
| | WebGL `AuraCanvas` | **Covered** | [COMPARATIVE_WEBSITE_ANALYSIS](COMPARATIVE_WEBSITE_ANALYSIS.md) |
| **APIs & Endpoints**| `check_in` (Supabase RPC) | **Covered** | [09_Database](09_Database.md), [05_Student_Mobile_App](05_Student_Mobile_App.md) |
| | `convert_lead_to_member` (Supabase RPC) | **Covered** | [09_Database](09_Database.md), [07_Admin_Panel](07_Admin_Panel.md) |
| | `POST /api/contact` (Brevo email API) | **Covered** | [04_Public_Website](04_Public_Website.md), [08_Backend](08_Backend.md) |
| | `POST /api/subscribe` (Brevo subscribe API) | **Covered** | [04_Public_Website](04_Public_Website.md), [08_Backend](08_Backend.md) |
| **Database Tables** | `users`, `batches`, `leads`, `enrollments` | **Covered** | [09_Database](09_Database.md) |
| | `attendance`, `leave_requests`, `payments` | **Covered** | [09_Database](09_Database.md) |
| | `notifications`, `holidays`, `library_books` | **Covered** | [09_Database](09_Database.md) |
| | `therapeutic_logs`, `transformation_scores` | **Covered** | [09_Database](09_Database.md) |
| **RLS Policies** | policies on all 12 operational tables | **Covered** | [09_Database](09_Database.md), [12_Security](12_Security.md) |
| **Triggers** | `lock_privileged_fields` (users lock) | **Covered** | [09_Database](09_Database.md) |
| | `recalculate_student_streaks` (attendance) | **Covered** | [09_Database](09_Database.md) |
| | `sync_user_role_to_auth` (JWT mirror) | **Covered** | [09_Database](09_Database.md), [10_Auth_Authorization](10_Auth_Authorization.md) |
| | `lock_payment_fields` (payment freeze) | **Covered** | [09_Database](09_Database.md) |
| **SQL Functions** | `haversine_m` (distance calculation) | **Covered** | [09_Database](09_Database.md) |
| | `is_admin`, `is_trainer` (RLS helpers) | **Covered** | [09_Database](09_Database.md), [10_Auth_Authorization](10_Auth_Authorization.md) |
| **Scripts** | `build_all.ps1`, `build_all.bat` (relative paths)| **Covered** | [02_Repository_Discovery](02_Repository_Discovery.md), [15_DevOps_Infrastructure](15_DevOps_Infrastructure.md) |
| | `install_additional_skills.ps1` | **Intentionally Undoc**| CLI helper for local developer setup. |
| **Env Variables** | `BREVO_API_KEY` (Brevo email client) | **Covered** | [02_Repository_Discovery](02_Repository_Discovery.md), [14_Integrations](14_Integrations.md) |
| | `NEXT_PUBLIC_SANITY_PROJECT_ID` (CMS) | **Covered** | [02_Repository_Discovery](02_Repository_Discovery.md), [14_Integrations](14_Integrations.md) |
| | `SUPABASE_URL`, `SUPABASE_ANON_KEY` (App client) | **Covered** | [02_Repository_Discovery](02_Repository_Discovery.md), [14_Integrations](14_Integrations.md) |
| **Configurations** | `next.config.mjs` (headers, CSP settings) | **Covered** | [12_Security](12_Security.md), [15_DevOps_Infrastructure](15_DevOps_Infrastructure.md) |
| | `tailwind.config.ts`, `tsconfig.json` | **Covered** | [02_Repository_Discovery](02_Repository_Discovery.md), [11_UIUX_Design_System](11_UIUX_Design_System.md) |
| | `pubspec.yaml`, `analysis_options.yaml` | **Covered** | [02_Repository_Discovery](02_Repository_Discovery.md), [19_AI_Context](19_AI_Context.md) |
| | `.claude/launch.json` | **Covered** | [15_DevOps_Infrastructure](15_DevOps_Infrastructure.md) |
| **Assets** | Brand logos, founder & guru `.webp` files | **Covered** | [04_Public_Website](04_Public_Website.md), [25_Assets_Content](25_Assets_Content.md) |
| **Tests** | `lib/*.test.ts` (Vitest suites for website) | **Covered** | [16_Testing_QA](16_Testing_QA.md) |
| | `supabase/tests/c1-c8` (pgTAP database tests)| **Covered** | [16_Testing_QA](16_Testing_QA.md) |
| | App unit tests | **Covered** | 197 Dart unit and widget tests passing in `divinity_flutter/test/`. |
| **Deployment** | Vercel production hosting settings | **Covered** | [15_DevOps_Infrastructure](15_DevOps_Infrastructure.md) |
| | App Store / Play Store pipelines | **Needs Verification**| CI config is not checked into the repository. |
| **Business Rules** | Geofenced distance checking, streaks | **Covered** | [05_Student_Mobile_App](05_Student_Mobile_App.md), [09_Database](09_Database.md) |
| | Role-based database locks, leaf limit | **Covered** | [09_Database](09_Database.md), [10_Auth_Authorization](10_Auth_Authorization.md) |
| **ADRs** | 12 website Architectural Decision Records | **Covered** | [03_System_Architecture](03_System_Architecture.md), [DECISION_LOG](DECISION_LOG.md) |

---

## 2. Onboarding & Local Development Guide

An engineer can fully clone, install, build, run, test, and deploy the Divinity projects using only the repositories and the guidelines detailed below.

### A. Next.js Website (`divinity-third-eye/divinity`)

1.  **Clone & Navigate**:
    ```bash
    git clone <repository_url>
    cd divinity-third-eye/divinity
    ```
2.  **Install Dependencies**:
    ```bash
    npm install
    ```
3.  **Local Run**:
    ```bash
    npm run dev
    # The server starts at http://localhost:3000
    ```
4.  **Production Compilation**:
    ```bash
    npm run build
    ```
5.  **Run Tests**:
    ```bash
    npm test
    # Runs the Vitest test suites (e.g. rate-limit.test.ts, validation.test.ts)
    ```
6.  **Deploy**:
    Deploy via the Vercel Git integration or manually:
    ```bash
    npm install -g vercel
    vercel --prod
    ```

### B. Flutter Mobile Application (`divinity_flutter`)

1.  **Clone & Navigate**:
    ```bash
    git clone <repository_url>
    cd divinity_flutter
    ```
2.  **Configure Environment**:
    Create `.env` inside the project root containing:
    ```env
    SUPABASE_URL=https://your-project.supabase.co
    SUPABASE_ANON_KEY=your-anon-key
    ```
3.  **Install Dependencies**:
    ```bash
    flutter pub get
    ```
4.  **Run Code Generator**:
    ```bash
    dart run build_runner build --delete-conflicting-outputs
    ```
5.  **Local Run**:
    Ensure a simulator/emulator is running and execute:
    ```bash
    flutter run
    ```
6.  **Run Tests**:
    ```bash
    flutter test
    ```
7.  **Build App Bundle**:
    *   **Android**:
        ```bash
        flutter build apk --release
        flutter build appbundle --release
        ```
    *   **iOS** (Requires macOS and Xcode):
        ```bash
        flutter build ios --no-codesign
        ```

### C. Supabase Database (`divinity_flutter/supabase`)

1.  **Install Supabase CLI**:
    ```bash
    # On Windows via Scoop
    scoop bucket add supabase https://github.com/supabase/scoop-bucket.git
    scoop install supabase
    ```
2.  **Start Local DB Engine**:
    ```bash
    cd divinity_flutter
    supabase start
    ```
3.  **Apply Database Migrations**:
    ```bash
    supabase db reset
    # This recreates the local schema and applies migrations 001 to 023.
    ```
4.  **Run Security Regression Tests**:
    ```bash
    supabase test db
    # Applies and asserts c1_privileged_fields_test.sql through c8_payment_verification_test.sql.
    ```

---

## 3. Identified Gaps & Missing Information

The following items are **Missing** or flagged as **Needs Verification** in the Divinity Ecosystem:
1.  **App Store & Google Play Deploy Tunnels**: Fastlane or CI/CD pipelines (e.g. GitHub Actions) are not present in the repository, making store deployments a manual process. *[Needs Verification]*
2.  **Web Analytics Provider**: While the event taxonomy is detailed in the design documents, no provider code (Google Analytics, Vercel Analytics) is actively initialized in the website source code. *[Needs Verification]*
3.  **Staging Tunnels & Domains**: Staging/testing domains and DNS records are undocumented. *[Needs Verification]*
4.  **Firebase Config Console Keys**: Remote Config variables for AI and auth switches must be published in the live console. *[Needs Verification]*
