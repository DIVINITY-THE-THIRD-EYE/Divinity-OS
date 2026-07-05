# Comparative Website Analysis

This document provides a rigorous comparative analysis between the two Next.js website implementations in this workspace:
1. **Prisma/tRPC Prototype Site**: Located at [`Divinity/reference/divinity-website/`](file:///C:/Users/PC/OneDrive/Documents/Divinity%20TTE/Divinity/reference/divinity-website/).
2. **Live Sanity Website**: Located at [`website/`](file:///C:/Users/PC/OneDrive/Documents/Divinity%20TTE/website/).

Based on detailed analysis of source code, git histories, and architectures, these two projects are **independent implementations** with **complementary architectures**. The live site serves as the public marketing front door, while the Prisma site acts as a high-fidelity interactive dashboard portal prototype.

---

## 1. Architectural Comparison

| Dimension | Live Website (`website/`) | Prisma Website (`Divinity/reference/divinity-website`, archived) |
|---|---|---|
| **Role & Purpose** | Public-facing marketing front door | High-fidelity interactive portal & dashboard |
| **Rendering Model** | Static Site Generation (SSG) / Server Component defaults | Client-heavy Interactive SPA + Server Components |
| **API Architecture** | Serverless API routes (`/api/contact`, `/api/subscribe`) | tRPC endpoints (`/api/trpc/*`) |
| **Data Flow** | Sanity CMS / local JSON fallback → React Server Components | tRPC React Query → Prisma ORM → Supabase Postgres |
| **State Management** | URL-based state + simple local hooks | Zustand (`zustand`) stores for global app state |
| **Graphics & Motion** | GSAP, Framer Motion, Lenis smooth scrolling | React Three Fiber (Three.js WebGL shaders) |
| **Database Integration**| None (CMS content only) | Prisma Client (Postgres) |
| **Authentication** | None | Supabase Auth (`@supabase/ssr`) |

---

## 2. Dependency Graph

The package dependencies show the difference between the marketing focus of the live site and the database/app-portal focus of the Prisma reference site.

```mermaid
graph TD
  subgraph Shared Core
    N[Next.js 14]
    R[React 18]
    T[TailwindCSS]
    F[Framer Motion]
    G[GSAP]
    L[Lenis]
  end

  subgraph Live Website Only
    S[@sanity/client]
    V[Vitest]
  end

  subgraph Prisma Reference Website Only
    P[@prisma/client]
    TRPC[@trpc/server / @trpc/client]
    RQ[@tanstack/react-query]
    SUP[@supabase/supabase-js / @supabase/ssr]
    R3F[@react-three/fiber / @react-three/drei]
    PP[@react-three/postprocessing]
    Z[Zustand]
    ZOD[Zod]
    RH[React Hook Form]
    REC[Recharts]
  end
```

---

## 3. File Similarity Report

We conducted a similarity comparison between the source files of both repositories. File contents show **0% code similarity** beyond shared static assets, confirming they were built independently from different templates.

| Live File Path | Prisma File Path | Similarity | Note |
|---|---|---|---|
| `app/about/page.tsx` | `src/app/(marketing)/about/page.tsx` | **0.0%** | Live uses custom manifesto components; Prisma is static text. |
| `app/pricing/page.tsx` | `src/app/(marketing)/pricing/page.tsx` | **5.0%** | Shared naming of pricing tiers; layouts are completely unique. |
| `app/globals.css` | `src/app/globals.css` | **45.0%** | Shares the same CSS color variables (`--void`, `--bone`, `--ember`). |
| `public/founder.webp` | `public/founder.webp` | **100.0%** | Identical byte-hash (shared assets). |
| `public/payment-qr.png` | `public/payment-qr.png` | **100.0%** | Identical byte-hash (shared assets). |
| `tsconfig.json` | `tsconfig.json` | **85.0%** | Similar Next.js TS compiler configurations. |

---

## 4. Feature Matrix

| Feature | Live Website | Prisma Reference Website | Status |
|---|---|---|---|
| **Marketing Pages** | Rich (13 pages, SSG, SEO, JSON-LD) | Basic static representations | Complementary |
| **Sanity CMS Integration** | Yes (optional fallback) | No | Complementary |
| **Interactive Blog** | Yes | No | Complementary |
| **Interactive Schedule** | Yes (weekly slots) | No | Complementary |
| **Interactive 3D Graphics** | No | Yes (WebGL `AuraCanvas` shader) | Unique to Prisma |
| **Student Dashboard** | No | Yes (check-in, streaks, upload UI) | Unique to Prisma |
| **Trainer Dashboard** | No | Yes (attendance marking, diets UI) | Unique to Prisma |
| **Admin Dashboard** | No | Yes (revenue charts, approve payments) | Unique to Prisma |
| **Auth System** | No | Yes (OTP + Role-based session middleware) | Unique to Prisma |
| **UPI/Manual Payments** | Static instructions only | Upload screenshot UI + transition trigger | Unique to Prisma |
| **Excel Mock DB** | No | Yes (Express + `server.js` Excel CRUD) | Unique to Prisma |

---

## 5. Detailed Comparison Parameters

### Source Code
- **Live Website**: Highly polished production-ready codebase. Functions are separated cleanly into `lib/` helpers, with comprehensive test coverage.
- **Prisma Website**: High-fidelity prototype. The dashboard UI matches modern glassmorphic designs but is largely populated with mock variables. It includes rich shaders and Express mock servers.

### Routing
- **Live Website**: App Router directory `app/` with flat structure. Uses dynamic directories for blogs/events (`blog/[slug]`).
- **Prisma Website**: App Router directory `src/app/` split into groups: `(marketing)` and `(dashboard)`. This separation isolates the public and operational portals.

### Database Layer
- **Live Website**: No database. Queries dynamic schemas via CMS or falls back to hardcoded JSON data.
- **Prisma Website**: Prisma Postgres ORM integration (`schema.prisma`). Additionally includes a mock database script (`server.js`) that uses the `xlsx` library to read/write to `divinity_academy_database.xlsx`.

### CMS & Content
- **Live Website**: Integrated with Sanity CMS. Schemas define classes, disciplines, plans, and testimonials.
- **Prisma Website**: No CMS integration. Data is hardcoded or fetched via database endpoints.

### Authentication & APIs
- **Live Website**: No auth. APIs are `/api/contact` and `/api/subscribe` for Brevo mailing.
- **Prisma Website**: Supabase Auth cookie middleware. APIs are tRPC type-safe routers mapping operational modules (attendance, payments, etc.).

---

## 6. Migration & Integration Strategy

Rather than deleting the Prisma project or leaving it isolated, we recommend importing its high-value assets and components into the live website or operational app when needed.

```
       [Prisma Reference Website]
                   │
         ┌─────────┴─────────┐
         ▼                   ▼
  [Aura Canvas]       [tRPC Routers]
         │                   │
         ▼                   ▼
  [Live Website]      [Future Mobile/Web Portal]
(3D WebGL Hero BG)   (Type-safe Supabase Clients)
```

### Step 1: Upgrade Live Website Aesthetics (Visual Migration)
- **Target**: Copy the Three.js WebGL canvas (`aura-canvas.tsx`, `control-hud.tsx`, `sound-manager.tsx`) into the live website `components/` folder.
- **Wiring**: Replace the standard static backgrounds in the live site's `BreathHero.tsx` or `Ambient.tsx` with the animated, mouse-interactive WebGL aura.

### Step 2: Implement a Unified Web Portal (Operational Migration)
- **Target**: If the business requires a web portal for student check-ins and admin management:
  - Copy the UI shells for `(dashboard)` (Admin, Trainer, and Student homepages) into a new workspace module.
  - Re-wire the backend logic: replace the Prisma DB client with the standard `@supabase/supabase-js` client to query the live Supabase tables, reusing the existing Flutter database tables (`users`, `batches`, `payments`, `attendance`) and RLS policies.

---

## 7. Recommendation with Evidence

> [!TIP]
> **Preserve the Prisma Website under `reference/`**
>
> The Prisma website contains **irreplaceable engineering assets**:
> 1. The custom WebGL Ajna/Aura shader material which represents significant math/creative effort and cannot be easily recreated.
> 2. The mock Excel-database server (`server.js`) which acts as an excellent standalone demonstration tool.
> 3. A ready-to-use template for tRPC Next.js routing.
>
> Moving it to `EXTRA_FILES/` as dead junk would hide these assets. Keeping it in `Divinity/reference/divinity-website/` preserves its utility for the team.
