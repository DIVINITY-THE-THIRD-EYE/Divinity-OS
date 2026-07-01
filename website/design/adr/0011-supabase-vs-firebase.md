# ADR 0011 — Supabase vs Firebase (future product backend)
Status: Proposed · Date: 2026-06-26

## Context
The student/trainer/admin product needs auth, a database, storage, and realtime — none of which exist
today (the site is static). The README anticipates "their own auth and database."

## Problem
Pick a free-tier-friendly backend for the future platform that matches the team's React/SQL comfort and
supports RLS-grade security.

## Alternatives considered
1. **Firebase** — fast start, great mobile SDKs, but NoSQL (Firestore) modelling, vendor lock-in,
   security rules DSL.
2. **Supabase** — Postgres + Row-Level Security, auth, storage, realtime, `pgvector` (for AI recs);
   SQL portability; generous free tier.
3. **Custom Node/Postgres** — most control, most ops.

## Decision
**Supabase** for the future product: relational modelling fits memberships/bookings/attendance; **RLS**
gives per-row authz; `pgvector` supports the AI roadmap (`13`); SQL avoids lock-in. **Not adopted now** —
the marketing site remains backend-less (ADR-0001).

## Consequences
- Clear future path; data portable (standard Postgres); auth/storage/realtime included.

## Risks
- Free-tier limits (pausing on inactivity, connection caps). → Acceptable for MVP; upgrade when needed.
- RLS policy mistakes = data exposure. → Security review (`21`) + policy tests before launch.

## Rollback strategy
N/A for the site (not used). For the app, Postgres portability means migration to managed PG (Neon/RDS)
is feasible without an app rewrite.
