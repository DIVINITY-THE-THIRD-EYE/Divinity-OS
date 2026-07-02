# Phase 18 — Documentation

> Inventory of existing documentation and pointers. Much of it lives in `Divinity/docs/` and the website `design/` folder.

## Developer Guide

- Website: [README](../website/README.md) (run/build/test/deploy, structure).
- App: pubspec + feature-first conventions (see [02_Repository_Discovery](02_Repository_Discovery.md), [AI_CONTEXT](AI_CONTEXT.md)).
- Monorepo: [Divinity/README](../Divinity/README.md), [Divinity/CLAUDE.md](../Divinity/CLAUDE.md) (agentic-OS orchestration).

## API Docs

- App "API" = Supabase tables/RPCs (see [08_Backend](08_Backend.md), [09_Database](09_Database.md)).
- Web API routes documented in [04_Public_Website](04_Public_Website.md) + [design/18-api-data-contracts.md](../website/design/18-api-data-contracts.md).

## User Manual

`[Needs Verification]`: no end-user manual found. Source material: website copy + app screens. Recommend generating per-role guides.

## Admin Manual

`[Needs Verification]`: partial (admin screens). See [07_Admin_Panel](07_Admin_Panel.md) + [Appendix/Academy_Operations_Handbook](Appendix/Academy_Operations_Handbook.md).

## Trainer Manual

See [06_Trainer_App](06_Trainer_App.md) + Operations SOPs. Formal manual `[Needs Verification]`.

## Student Manual

See [05_Student_Mobile_App](05_Student_Mobile_App.md). Formal manual `[Needs Verification]`.

## Runbooks

`[Needs Verification]`: no committed runbooks. Recommended set: deploy, rollback, restore DB, rotate secrets, incident triage. (`Divinity:runbook-generator`-style content can seed these.)

## Troubleshooting

- Known pitfalls captured in [AI_CONTEXT §6](AI_CONTEXT.md) (RLS recursion, JWT drift, geofence, duplicate trees, build path).
- App migration notes: `supabase/MIGRATION_NOTES_009_010.md`.
- Website: `design/22-tech-debt-register.md`.

## Key existing documents (Divinity/docs/)

| Doc | Purpose |
|---|---|
| `DIVINITY_MASTER_REPORT.md` | consolidated audit→fix→review |
| `AUDIT_REPORT.md` | system audit & production readiness |
| `SECURITY_REVIEW_C1_C2.md` | deep security/architecture review |
| `BETA_LAUNCH_CHECKLIST.md` | closed-beta checklist |
| `architecture.md` | interaction & motion architecture |
| `roadmap/changelog/status/task/walkthrough.md` | project tracking |
| `DIVINITY_MASTER_PROMPT.md`, `DIVINITY_UI_PROMPT.md` | executable build prompts |
| `graph/GRAPH_REPORT.md` | CodeGraph output (regenerable) |
