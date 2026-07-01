# ADR 0009 — PWA layer now, native apps later
Status: Proposed · Date: 2026-06-26

## Context
The brief asks for iOS/Android UX. The site is static Next.js; a native build is a separate product
(README). A PWA can make the existing site installable/offline with no native project.

## Problem
Deliver "app on the home screen" value quickly and free, without committing to native development or
the Apple Developer fee.

## Alternatives considered
1. **Native now (Flutter/Capacitor)** — premature; needs backend/auth/store accounts + $99/yr Apple fee.
2. **No mobile-app story** — misses low-cost installable value.
3. **PWA layer now, native later (when product greenlit)** — chosen (see `04-mobile-and-motion §6.0`).

## Decision
Add a PWA layer (manifest + service worker via `@serwist/next` or `next-pwa`, reusing existing icons) as
an **optional Phase-4 item**. Defer native to the future product on a real backend (ADR-0011).

## Consequences
- Installable, offline-capable site; iOS add-to-home-screen via existing apple-icon.
- Zero store cost; no native maintenance now.

## Risks
- Service-worker caching bugs (stale content). → Conservative cache strategy + versioned SW; test offline.
- iOS PWA limitations (push pre-16.4). → Defer push; not required for v1.

## Rollback strategy
PWA is additive; removing the SW registration + manifest reverts to a plain site. Unregister SW on
rollback to avoid stale caches.
