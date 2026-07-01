# Knowledge Graph — Divinity Ecosystem

This document maps the entire Divinity software architecture from repositories to operational business rules.

---

## 1. Structural Architecture Diagram

The diagram below visualizes the dependencies and relationships across the stack:

```mermaid
graph TD
  %% Repositories Layer
  subgraph Repositories
    DF[divinity_flutter]
    DTE[divinity-third-eye/divinity]
    DIV[Divinity Monorepo]
  end

  %% Modules Layer
  subgraph Modules
    DF_MOD[lib/features/]
    DTE_MOD[lib/ helpers]
    DIV_MOD[reference/divinity-website]
  end
  DF --> DF_MOD
  DTE --> DTE_MOD
  DIV --> DIV_MOD

  %% Features Layer
  subgraph Features
    F_GEOFENCE[Geofenced Check-In]
    F_STREAK[Attendance Streaks]
    F_PAYFLOW[Payment Lifecycle]
    F_CRM[Admissions CRM]
    F_BREATHE[Breathing Hero Cadence]
    F_CALC[Plan Recommendation]
  end
  DF_MOD --> F_GEOFENCE
  DF_MOD --> F_STREAK
  DF_MOD --> F_PAYFLOW
  DF_MOD --> F_CRM
  DTE_MOD --> F_BREATHE
  DTE_MOD --> F_CALC

  %% Components Layer
  subgraph Components
    C_SHELLS[Student/Trainer/Admin Shells]
    C_MAT[Custom Widgets / spring_tap]
    C_HERO[BreathHero Canvas]
    C_AURA[WebGL AuraCanvas]
  end
  F_GEOFENCE --> C_SHELLS
  F_CRM --> C_SHELLS
  F_BREATHE --> C_HERO
  DIV_MOD --> C_AURA

  %% APIs Layer
  subgraph APIs
    API_RPC[check_in / convert_lead_to_member RPCs]
    API_FCM[Firebase FCM Push Notifications]
    API_EMAIL[POST /api/contact Brevo API]
    API_TRPC[tRPC Routers]
  end
  C_SHELLS --> API_RPC
  C_SHELLS --> API_FCM
  C_HERO --> API_EMAIL
  C_AURA --> API_TRPC

  %% Database Layer
  subgraph Database
    DB_TBL[(12 Supabase Tables)]
    DB_RLS[Row-Level Security Policies]
    DB_TRIG[Postgres Triggers]
  end
  API_RPC --> DB_TBL
  API_RPC --> DB_RLS
  DB_TBL --> DB_TRIG

  %% Business Rules Layer
  subgraph Business Rules
    R_GEO[Geofencing: check-in within batch radius]
    R_STR[Streak: increment on weekdays, Fri-Mon gaps allowed]
    R_LOCK[Privileged Lock: users cannot self-promote or alter active batches]
    R_LEAVE[Leave Limit: cap at 4 approved leaves]
    R_PAY[Payment State Lock: verified payments are immutable]
  end
  DB_TRIG --> R_GEO
  DB_TRIG --> R_STR
  DB_TRIG --> R_LOCK
  DB_TRIG --> R_LEAVE
  DB_TRIG --> R_PAY
```

---

## 2. Layer Definitions & Relationships

### A. Repositories
*   [`divinity_flutter/`](file:///C:/Users/PC/OneDrive/Documents/Divinity%20TTE/divinity_flutter) — The live production Flutter repository representing the operational app.
*   [`divinity-third-eye/divinity/`](file:///C:/Users/PC/OneDrive/Documents/Divinity%20TTE/divinity-third-eye/divinity) — The live marketing website built on Next.js 14 App Router.
*   [`Divinity/`](file:///C:/Users/PC/OneDrive/Documents/Divinity%20TTE/Divinity) — The workspace root monorepo, holding developer guides, build scripts, archived `calling_app`, and the archived high-fidelity [`reference/divinity-website`](file:///C:/Users/PC/OneDrive/Documents/Divinity%20TTE/Divinity/reference/divinity-website).

### B. Modules
*   **Flutter features (`lib/features/`)**: A modular directory structure dividing business logic into 14 distinct feature folders (e.g. `attendance`, `payments`).
*   **Website core helpers (`lib/`)**: Isolated pure TypeScript modules for content CMS overrides, rate-limiting, and validation.
*   **WebGL Reference (`reference/divinity-website`)**: Archival tRPC next-app containing 3D canvas modules.

### C. Features
*   **Geofenced Check-In**: Enables students to check into scheduled batches on weekdays if coordinates are valid.
*   **Attendance Streaks**: Track consecutive student check-in streaks, adjusting for weekend gaps.
*   **Payment Lifecycle**: Uploads UPI screenshots, records payment state transitions, and notifies admins for verification.
*   **Admissions CRM**: Enables admins to register, update, and convert incoming leads into active academy users.
*   **Breathing Hero Cadence**: Signature marketing experience displaying a pranayama rhythm (inhale 4s, hold 4s, exhale 6s).
*   **Plan Recommendation**: Computes recommended memberships based on the user's primary wellness objective.

### D. Components
*   **Role Shells**: Student/Trainer/Admin UI tab navigations in Flutter.
*   **BreathHero**: Raw HTML5 canvas component rendering breathing ripples.
*   **WebGL AuraCanvas**: Custom GLSL shader rendering 3D particle energy.

### E. APIs
*   **RPCs**: Direct PostgreSQL functions `check_in` and `convert_lead_to_member` invoked via Supabase.
*   **Firebase FCM**: Push notification provider targeting mobile client tokens.
*   **Brevo Email API**: Backend endpoint executing contact form submissions.

### F. Database (Supabase)
*   **12 Tables**: `users`, `batches`, `leads`, `enrollments`, `attendance`, `leave_requests`, `payments`, `notifications`, `holidays`, `therapeutic_logs`, `transformation_scores`, `library_books`.
*   **RLS Policies**: Restricts access based on user role (`is_admin`, `is_trainer`).
*   **Triggers**: Postgres hooks automating audit logging, state updates, and push notifications.

### G. Business Rules
1.  **Geofencing constraint**: Check-ins are rejected if user distance from batch coordinates exceeds `radius_meters` (default 100m).
2.  **Consecutive check-in rule**: A student's streak is incremented if the check-in is consecutive. Fri-to-Mon gaps are treated as consecutive. All other gaps reset the streak.
3.  **Privileged-field lock**: Triggers prevent non-admin users from self-promoting roles or completing onboarding without validation.
4.  **Leave balance cap**: A user is restricted to a maximum of 4 approved leaves.
5.  **Payment immutability**: Once a payment record status transitions to `Verified`, it is permanently locked against modifications.
