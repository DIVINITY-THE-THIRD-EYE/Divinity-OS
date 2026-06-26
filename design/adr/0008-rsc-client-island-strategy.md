# ADR 0008 — React Server Components + client-island strategy
Status: Accepted · Date: 2026-06-26

## Context
`app/page.tsx` and `app/layout.tsx` are **Server Components** (the page `await`s `fetchOrFallback`
server-side). Interactive sections are `"use client"` islands (Nav, BreathHero, Disciplines, Faq,
PlanCalculator, etc.). `JsonLd` renders structured data server-side.

## Problem
Maximise SSR/SEO/LCP while keeping rich interactivity, without shipping unnecessary JS.

## Alternatives considered
1. **All-client** — worse SEO/LCP, larger bundle.
2. **All-server** — impossible for the animation/interaction layer.
3. **Server by default, client islands where interactive** — chosen (current pattern).

## Decision
Keep RSC as the default; mark only interactive components `"use client"`. New upgrade components follow
the same rule: **server unless they need state/effects/events**. Core copy stays server-rendered (SEO).

## Consequences
- Small First-Load JS; content crawlable; data-fetching stays on the server.
- Clear contributor rule for where `"use client"` belongs.

## Risks
- Accidentally making a wrapper client-only pulls children into the client bundle. → Review boundaries in PR;
  keep islands leaf-level.

## Rollback strategy
Boundary changes are per-component and reversible; no global rollback concept needed.
