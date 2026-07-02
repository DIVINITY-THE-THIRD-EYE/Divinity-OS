# Divinity — The Third Eye · Project Bible

> The permanent engineering & product knowledge base for the Divinity ecosystem.
> **Generated:** 2026-06-30 · **Method:** mined from the live repositories (git state, source, migrations, configs, docs) — every statement is traceable to a file. Uncertain items are marked **`[Needs Verification]`**.

---

## What Divinity is

**Divinity — The Third Eye** is a yoga, fitness & wellness **academy in Lucknow, India**, guided by **Sachin Rajvanshi**. The software ecosystem turns the academy into a digital product:

1. A public **marketing website** (the "front door").
2. A cross-platform **mobile app** (the "Academy Operating System") for Students, Trainers, and Admins.
3. A **Supabase + Firebase** backend with row-level security, geofenced attendance, and a payment-verification workflow.

The product philosophy comes straight from the practice: **"Breathe."** Pranayama (breath control) is the heart of the academy, and it is the organizing metaphor for the brand, the UI motion, and the calm, deliberate UX. (Source: [website README](../website/README.md))

---

## The two live products

| Product | Location | Stack | Git remote |
|---|---|---|---|
| **Website** ("The Third Eye") | `website/` | Next.js 14 (App Router), Tailwind, Framer Motion + GSAP + Lenis, Sanity (optional), Brevo | `github.com/divinitythethirdeye-ux/divinity-website` |
| **Mobile app** ("Academy OS") | `flutter-app/` | Flutter, Riverpod, GoRouter, Supabase, Firebase | `github.com/divinitythethirdeye-ux/divinity-app` |

A third tree, `Divinity/`, is the **monorepo / workspace** that also holds documentation (`docs/`), an agentic-OS layer (`CLAUDE.md`, `ANTIGRAVITY/`, `data/`), build scripts, and parallel copies of the apps. See [02_Repository_Discovery](02_Repository_Discovery.md) for the full map and [EXTRA_FILES/MIGRATION_REPORT.md](../EXTRA_FILES/MIGRATION_REPORT.md) for the cleanup that produced the current layout.

---

## How to use this Bible

- Start with **[00_Executive_Overview](00_Executive_Overview.md)** for the 5-minute picture.
- Use **[MASTER_INDEX](MASTER_INDEX.md)** to navigate all 31 phases + appendices.
- AI agents: read **[AI_CONTEXT](AI_CONTEXT.md)** first — it has the non-negotiable rules and working instructions.
- Look up a term in **[GLOSSARY](GLOSSARY.md)**, a file in **[FILE_INDEX](FILE_INDEX.md)**, a module in **[MODULE_INDEX](MODULE_INDEX.md)**.

## Structure of this folder

```
PROJECT_BIBLE/
├── README.md              ← you are here
├── MASTER_INDEX.md        navigation hub for all phases
├── 00..30_*.md            31 phase documents
├── EXECUTIVE_SUMMARY.md   final repository statistics
├── AI_CONTEXT.md          rules + working instructions for AI collaborators
├── GLOSSARY.md FAQ.md     terminology + frequent questions
├── FILE_INDEX.md MODULE_INDEX.md SEARCH_INDEX.md  lookup tables
├── DECISION_LOG.md DECISION_TREE.md  decisions + routing
├── OWNERSHIP_MATRIX.md    who/what owns each area
├── CHANGELOG.md PROJECT_HISTORY.md  history
└── Appendix/
    ├── Yoga_and_Wellness_Domain_Guide.md
    ├── Academy_Operations_Handbook.md
    └── Brand_and_Content_Library.md
```

## Provenance & confidence

This Bible was assembled by reading the repository — not from assumptions. Where a fact is **derived from code** it links to the source. Where the repository does **not** contain the answer (e.g. real pricing, legal entity, infra account IDs), it is explicitly flagged **`[Needs Verification]`** so it can be filled in by a human rather than guessed.
