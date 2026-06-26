# Architecture Snapshot (Phase 0)

Reference diagrams for the frozen build (Mermaid — renders on GitHub). These are the baseline for future ADRs.

## 1. Folder structure
```
divinity/
├─ app/
│  ├─ layout.tsx           # Server — fonts, metadata, JsonLd
│  ├─ page.tsx             # Server — fetchOrFallback + section assembly
│  ├─ globals.css          # tokens + base styles
│  ├─ opengraph-image.tsx  # edge OG image
│  ├─ sitemap.ts · robots.ts
│  └─ api/contact/route.ts # Node — Brevo (or fallback)
├─ components/             # 24 components (client islands + utils)
├─ lib/
│  ├─ content.ts           # canonical content + types
│  └─ sanity.ts            # fetchOrFallback (CMS-or-fallback)
├─ sanity/schemas/         # schemas for an optional Studio
├─ public/                 # brand, founder, studio/, guru/, payment-qr
├─ design/                 # this dossier (+ phase0/)
└─ config: next.config.mjs · tailwind.config.ts · tsconfig.json · postcss.config.mjs
```

## 2. Route tree
```mermaid
graph TD
  ROOT["/ (app)"] --> HOME["/ — page.tsx (static ○)"]
  ROOT --> NF["/_not-found (static)"]
  ROOT --> API["/api/contact (dynamic ƒ, Node)"]
  ROOT --> OG["/opengraph-image (dynamic ƒ, edge)"]
  ROOT --> ICON["/icon.png · /apple-icon.png (static)"]
  ROOT --> SEO["/sitemap.xml · /robots.txt (static)"]
```

## 3. Component hierarchy (render tree)
```mermaid
graph TD
  L[layout.tsx Server] --> JL[JsonLd]
  L --> P[page.tsx Server]
  P --> CH[Chrome: IntroCurtain, Ambient, ScrollProgress, SmoothScroll, Cursor, CommandPalette, Nav, WhatsAppFab]
  P --> M[main]
  M --> Hero[BreathHero] --> Mq[Marquee] --> Man[Manifesto] --> Ab[About]
  Ab --> Dis[Disciplines] --> Gal[Gallery] --> Met[Method] --> Sch[Schedule]
  Sch --> Mem[Membership] --> PC[PlanCalculator] --> Voi[Voices] --> Faq --> Con[Contact] --> Foot[Footer]
  subgraph shared
    Rev[Reveal] -.-> Ab & Con & Faq & Mem & Met & PC
    Mag[Magnetic] -.-> Nav
  end
```

## 4. Data flow (content)
```mermaid
flowchart LR
  C[lib/content.ts<br/>canonical + types] --> PAGE[page.tsx]
  S[(Sanity CMS<br/>optional)] -. fetchOrFallback .-> PAGE
  PAGE -->|props| SECTIONS[Section components]
  C --> JL[JsonLd]
  C --> MANY[Nav/Footer/Hero/etc.]
  note["No projectId OR fetch error ⇒ falls back to content.ts"]:::n
  S -.-> note
classDef n fill:#fff3,stroke:#aaa,font-size:10px;
```

## 5. Authentication flow
```mermaid
flowchart LR
  X[No authentication] --> Y[Public static marketing site]
  Y --> Z[Future product: Supabase Auth + RLS<br/>see ADR-0011 — NOT in this app]
```
**There is no auth in the current build** (intentional — ADR-0001). Diagram documents the absence + future path.

## 6. CMS flow
```mermaid
sequenceDiagram
  participant Page as page.tsx (Server)
  participant Sanity as lib/sanity.ts
  participant CMS as Sanity CDN
  participant Local as lib/content.ts
  Page->>Sanity: fetchOrFallback(GROQ, fallback)
  alt projectId set
    Sanity->>CMS: client.fetch(query) [useCdn]
    CMS-->>Sanity: data | error
    Sanity-->>Page: data (if non-empty) else fallback
  else no projectId
    Sanity-->>Page: fallback (Local)
  end
```

## 7. API flow (contact)
```mermaid
sequenceDiagram
  participant U as Contact.tsx (client)
  participant R as /api/contact (Node)
  participant B as Brevo API
  U->>R: POST {name,email,intention,message}
  R->>R: parse + validate + escapeHtml
  alt invalid
    R-->>U: 400 / 422 {error}
  else no BREVO_API_KEY
    R-->>U: 200 {ok, delivered:false}  (logged)
  else key present
    R->>B: POST /v3/smtp/email (replyTo: visitor)
    B-->>R: 2xx | error
    R-->>U: 200 {ok, delivered:true} | 502 {error}
  end
```

## 8. Build & deploy pipeline (current + proposed gate)
```mermaid
flowchart LR
  DEV[next dev] --> SRC[Source]
  SRC --> BUILD[next build → SSG + RSC + image optim]
  BUILD --> ART[.next static + serverless route]
  ART --> VERCEL[Vercel CDN/edge]
  subgraph proposed[Phase 0 gate — design/phase0/quality-gates]
    PR[Pull request] --> CI[CI: typecheck · lint · format · unit · a11y · bundle · Lighthouse · VRT · links/images]
    CI -->|all green| MERGE[merge]
    CI -->|any fail| BLOCK[block]
  end
  MERGE --> BUILD
```
