# Ownership Matrix

> Maps each area to the responsible **role/system**. Named individuals are `[Needs Verification]` (the repo identifies the founder/guru, **Sachin Rajvanshi**, but not engineering owners).

## Product/business ownership

| Area | Owner | Notes |
|---|---|---|
| Brand / vision / academy | Founder — Sachin Rajvanshi | per website About/README |
| Pricing / plans | Academy owner/admin | `[Needs Verification]` real values |
| Content (marketing) | Admin via Sanity / `lib/content.ts` | |
| Operations (admissions, payments) | Admin + Trainers | SOPs in [17_Operations](17_Operations.md) |

## Engineering ownership (by area → where it lives)

| Area | System of record | Doc |
|---|---|---|
| Website | `website/` (Vercel) | [04](04_Public_Website.md) |
| Mobile app | `flutter-app/` (stores) | [05](05_Student_Mobile_App.md)–[07](07_Admin_Panel.md) |
| Database & RLS | Supabase (`supabase/migrations`) | [09](09_Database.md) |
| Auth | Supabase Auth + JWT sync | [10](10_Auth_Authorization.md) |
| Push/analytics/crash | Firebase | [14](14_Integrations.md), [28](28_Observability.md) |
| Email | Brevo | [14](14_Integrations.md) |
| CMS | Sanity (optional) | [25](25_Assets_Content.md) |
| Docs / agentic-OS | `Divinity/` (`CLAUDE.md`, `docs/`) | [18](18_Documentation.md) |

## RACI (proposed — confirm)

| Activity | Responsible | Accountable | Consulted | Informed |
|---|---|---|---|---|
| Schema change | Engineer | Tech lead `[Verify]` | Security | Admin |
| Payment verification | Trainer | Admin | — | Student |
| Member activation | Admin | Admin | Trainer | Student |
| Content edit | Admin | Owner | — | — |
| Release | Engineer | Tech lead `[Verify]` | QA | All |

> Fill in named owners once confirmed. `[Needs Verification]` throughout for individuals.
