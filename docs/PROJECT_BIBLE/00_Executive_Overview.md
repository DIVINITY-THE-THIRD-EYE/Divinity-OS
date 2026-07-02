# Phase 0 — Executive Overview

## Project Summary

Divinity — The Third Eye is the complete software ecosystem for a **yoga, fitness & wellness academy in Lucknow, India**, guided by **Sachin Rajvanshi**. It comprises a public marketing **website** (visitors/members), a Student/Trainer/Admin **mobile app** ("Academy Operating System" for Android and iOS), and an integrated **Admin Panel**. The entire ecosystem is structured around **16 core business modules** and **6 operational flows**, backed by **Supabase** (Postgres + RLS + Auth + Storage) and **Firebase** (FCM + Analytics + Crashlytics). (Source: [website README](../website/README.md), [Divinity/README](../Divinity/README.md), [Divinity/CLAUDE.md](../Divinity/CLAUDE.md))

## Vision

To make a traditional, breath-centred yoga academy feel as considered and trustworthy online as it does in the studio — a calm, premium digital presence that converts visitors into students and then runs the day-to-day academy (attendance, payments, progress) without friction.

## Mission

- Give prospective students a **fast, beautiful, accessible** front door that explains the practice and routes them to enquiry/WhatsApp.
- Give enrolled students a **single app** for batches, attendance, payments, diet/therapeutic guidance, and visible transformation.
- Give trainers and admins the **operational tooling** (attendance, CRM, payment verification, reporting) to run the academy.

## Product Philosophy

**"Breathe."** Pranayama is the heart of the practice, so the product is deliberately calm: a breathing-guide hero on a real cadence (inhale 4s · hold 4s · exhale 6s), restrained motion, and information structure that mirrors a real sequence (the **Method**: Align → Awaken → Ascend). Effects are used only where they reinforce the concept; "piling on every effect reads as AI clutter." (Source: [website README](../website/README.md))

Engineering philosophy: **zero-config with graceful fallbacks** (the website runs fully without any API keys), **security by default** (RLS on every table, CSP + rate limiting on the web), and **feature-first modularity** in the app.

## Business Goals

1. Convert website visitors → enquiries (WhatsApp / contact form / plan calculator).
2. Enroll and retain students across membership plans.
3. Reduce admin overhead by digitizing attendance, payments, and communication.
4. Differentiate via a premium, award-quality brand experience.

> Concrete revenue targets, enrollment numbers, and unit economics are **`[Needs Verification]`** — not present in the repository.

## Success Metrics

| Area | Metric (derivable from product) | Source |
|---|---|---|
| Web | Lighthouse desktop/mobile, Core Web Vitals | [design/phase0 reports](../website/design/phase0/) |
| Conversion | Contact-form submissions, newsletter subs, WhatsApp clicks, plan-calculator completions | `app/api/contact`, `app/api/subscribe`, `WhatsAppFab`, `PlanCalculator` |
| App engagement | Attendance check-ins, streaks, payment completion | `attendance`, `transformation_scores`, `payments` tables |
| Quality | Test pass rate, RLS security tests (c1–c8) | `lib/*.test.ts`, `supabase/tests/` |

See [23_Data_Analytics](23_Data_Analytics.md) for the full metric/event taxonomy.

## Core Principles

1. **Concept over decoration** — every motion/visual ties back to "Breathe."
2. **Accessible floor** — keyboard focus, `prefers-reduced-motion`, WCAG AA target. ([accessibility-audit](../website/design/09-accessibility-audit.md))
3. **Secure by default** — RLS everywhere, least-privilege roles, CSP, rate limiting.
4. **Graceful degradation** — CMS and email are optional; the site never breaks without keys.
5. **Feature-first code** — the Flutter app is organized by feature, each with `data / domain / presentation`.
6. **Traceability** — decisions captured as ADRs; this Bible cites sources.

## Terminology & Glossary

Key terms: **The Third Eye** (brand), **Academy OS** (the app), **Method** (Align/Awaken/Ascend), **Disciplines** (offerings grouped by intention), **Transformation Score** (student progress), **Batch** (a scheduled class group), **geofenced check-in**, **RLS**. Full definitions in [GLOSSARY.md](GLOSSARY.md).
