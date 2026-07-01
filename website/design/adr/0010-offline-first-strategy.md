# ADR 0010 — Offline-first strategy (future app)
Status: Proposed · Date: 2026-06-26

## Context
The marketing site is static and inherently cacheable. A future product app (schedule, downloads,
attendance) needs deliberate offline behaviour.

## Problem
Define how the platform behaves without connectivity — for the site now and the app later.

## Alternatives considered
1. **Online-only** — poor on flaky mobile networks; downloads impossible.
2. **Full offline sync everywhere** — complex; unnecessary for a static brand site.
3. **Tiered: static-cache for the site, offline-first store for the app** — chosen.

## Decision
- **Site (now):** PWA service worker caches the app shell + static pages/imagery (ADR-0009); read-only,
  conservative revalidation.
- **App (future):** local store as source of truth (Room/Drift/SwiftData), background sync (WorkManager/
  BGTask), booking actions queued and reconciled; downloaded sessions play offline (`04 §6.1`).

## Consequences
- Resilient UX on poor networks; clear data-ownership boundary between site and app.

## Risks
- Sync conflicts / stale caches. → Versioned caches, last-write-wins or server-authoritative reconcile;
  surface an "offline" state (`10 §8.7`).

## Rollback strategy
Site: unregister SW (see ADR-0009). App: feature-flag offline sync; fall back to online-only fetch.
