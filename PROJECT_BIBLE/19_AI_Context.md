# Phase 19 — AI Context

> This phase is a pointer + summary. The authoritative, detailed instructions live in **[AI_CONTEXT.md](AI_CONTEXT.md)** — read that first.

## Project Philosophy

"Breathe." Calm, deliberate, secure-by-default, zero-config-with-fallbacks, feature-first. Concept and brand tokens are product identity, not styling preferences.

## Non-Negotiable Rules (summary)

1. Never weaken RLS; keep `c1–c8` security tests green.
2. Roles (Student/Trainer/Admin) enforced in the DB, not just UI.
3. Website must run with zero config (Sanity/Brevo optional).
4. Respect `prefers-reduced-motion`.
5. Secrets out of git and out of this Bible.
6. Payments change via migrations + tests only.
7. Migrations are append-only.

Full list + rationale: [AI_CONTEXT §2](AI_CONTEXT.md).

## Coding Style

Flutter feature-first (`data/domain/presentation`), Riverpod, GoRouter; web RSC-default with pure tested `lib/` helpers and single-source modules. See [AI_CONTEXT §3](AI_CONTEXT.md).

## Naming Conventions

Dart snake_case files; SQL snake_case + intent-named policies; migrations `NNN_*.sql`. See [AI_CONTEXT §4](AI_CONTEXT.md).

## Architectural Decisions

12 web ADRs (`design/adr/`) + cross-cutting decisions in [DECISION_LOG.md](DECISION_LOG.md). Supabase-primary, GSAP+Lenis, RSC islands, UPI payments, optional CMS, no theme toggle.

## Known Pitfalls

RLS recursion (use `is_admin`/`is_trainer` helpers), JWT role drift (trigger sync), geofence RPC, duplicate app trees (now quarantined), and build script path updates. Detail: [AI_CONTEXT §6](AI_CONTEXT.md).

## Current Priorities

Closed-beta readiness: payment verification, FCM deep-linking, admin reporting/CSV, launch checklist. Confirm against `Divinity/docs/status.md`.

## Future Priorities

Native apps, self-booking, payment gateway, richer programs, web analytics, distributed rate-limit. See [21_Future_Roadmap](21_Future_Roadmap.md).

## Things Never to Change

RLS model + privileged-field locks; payment state machine; zero-config web guarantee; brand tokens + "Breathe" concept. ([AI_CONTEXT §8](AI_CONTEXT.md))

## AI Working Instructions

Locate-before-edit (mind the duplicate trees), change data via migrations+tests, keep gates green, never invent business facts, record decisions as ADRs, update this Bible on architectural change. ([AI_CONTEXT §9](AI_CONTEXT.md))
