# 01 — Project Overview

**Audit date:** 2026-07-05 (round 1), re-verified and extended 2026-07-05 (round 2, post-merge)
**Branch:** `audit/full-review-loving-einstein` (round 1, merged as PR #20) → `audit/full-review-round2` (round 2)
**Scope:** Full engineering audit of the Divinity — The Third Eye monorepo (Flutter mobile app + Next.js marketing website + shared Supabase backend).

**Round 2 status:** round 1's fixes are merged to `main`. The repository then went public, which prompted a second wave of work (CodeQL restored to every PR, Dependabot + secret scanning enabled, branch protection + auto-merge configured on `main`) — see `PUBLIC_REPOSITORY_SECURITY_AUDIT.md`, `GITHUB_CONFIGURATION_REPORT.md`, `BRANCH_PROTECTION_PLAN.md`, `CODEQL_VERIFICATION.md`, and the CI-optimization doc set. This round re-ran every verification gate fresh against current `main` (all green: 262/262 Flutter tests, 66/66 website tests, 188/188 pgTAP assertions) and confirmed via `git diff` that no application code changed between rounds — only CI/CD and repository configuration.

## What this project is

Divinity — The Third Eye is a yoga/fitness/wellness academy operating system for a single studio in Lucknow, Uttar Pradesh. It has three first-party surfaces sharing one Supabase project:

- **`flutter-app/`** — the mobile app (package `divinity_app`), with three role-based shells: Student, Trainer, Admin.
- **`website/`** — a Next.js 14 App Router marketing site (public-facing, no login), with optional Sanity CMS content and a local fallback.
- **`supabase/`** — the shared Postgres backend: 45 migrations, 25 tables, RLS on every table, 40+ functions/triggers, 1 edge function, 23 pgTAP test files (188 assertions).

## Canonical layout

Trust these three directories as the real source of code. Ignore any references elsewhere in old docs to `divinity_flutter/`, `Divinity/apps/`, or a separate admin-panel directory — those are legacy/reference material, not part of this monorepo (see root `.gitignore`, which excludes `/Divinity/`, `/EXTRA_FILES/`, `/.agents/` as "legacy/archival material kept locally but not part of this monorepo").

## Headline status (verified this session, not carried over from old docs)

| Gate | Result |
|---|---|
| `flutter analyze` | Clean |
| `flutter test` | 262/262 pass |
| Website `tsc --noEmit` | Clean |
| Website `next lint` | Clean |
| Website `vitest run` | 66/66 pass |
| Website `next build` | Success, 36 routes |
| `supabase test db` (pgTAP) | 188/188 pass (after this session's fix — was 186/188) |

## The single most important finding of this audit

**The codebase is significantly further along than the most recent in-repo/memory snapshot (2026-07-02) suggested.** Migrations grew from 36 to 45 in three days, and nearly every item that a prior PRD/requirements pass had flagged as "confirmed but not yet built" now has a real, tested implementation: the admin Plans module, Razorpay removal, enrollment waitlist, trial/lead conversion, certificate automation, the admin audit log, broadcast notifications, trainer-scoped reports, and paid events. See [03_Feature_Status.md](03_Feature_Status.md) for the item-by-item verification.

This means: **do not trust any status document (including this one) beyond its stated verification date.** Re-run the gates above before making any claim about "what's built." The project's own historical docs (`docs/AUDIT1JULY.MD`, `docs/IMPLEMENTATION1JULY.MD`) are self-flagged or externally-confirmed stale — see [03_Feature_Status.md](03_Feature_Status.md) for the doc-authority order.

## What changed in this audit session

Two low-risk, localized fixes were approved and applied (see [14_Critical_Fixes.md](14_Critical_Fixes.md) for detail):
1. A flaky pgTAP test (`c17_leave_business_rules_test.sql`) that spuriously failed on Saturdays/Sundays was fixed — the underlying business logic was already correct.
2. Both `release-please` GitHub Actions workflows, broken on every run since introduction, were repaired by migrating to the v4 manifest-config format.

Three other findings were surfaced but deliberately **not** auto-fixed, per the audit's own severity policy and the user's explicit choice to scope this session to "localized/low-risk fixes only": the `payment_screenshots` storage bucket's public/private flag (needs the owner's production Supabase dashboard access to re-verify), the outdated `next@14.2.35` dependency (multiple CVEs — needs its own careful upgrade pass), and the website's partial i18n coverage (a product scope decision, not a bug).
