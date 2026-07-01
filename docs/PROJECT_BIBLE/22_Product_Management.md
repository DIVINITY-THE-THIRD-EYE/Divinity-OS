# Phase 22 — Product Management

> Bridge between business and engineering. Sources: [design/17-feature-inventory.md](../divinity-third-eye/divinity/design/17-feature-inventory.md), [design/12-implementation-planning.md], feature code, `Divinity/docs/task.md`.

## Product Requirements (PRD pointers)

Executable build PRDs exist as prompts: [DIVINITY_MASTER_PROMPT.md](../Divinity/docs/DIVINITY_MASTER_PROMPT.md), [DIVINITY_UI_PROMPT.md](../Divinity/docs/DIVINITY_UI_PROMPT.md). Web feature inventory: [design/17-feature-inventory.md].

## Epics

1. **Public Brand & Conversion** (website).
2. **Identity & Onboarding** (auth, roles, onboarding, activation).
3. **Class & Attendance** (batches, enrollments, geofenced attendance, streaks, leave).
4. **Payments & Membership** (UPI flow, verification, expiry, notifications).
5. **Guidance & Progress** (therapeutic logs, transformation scores).
6. **Admin & Reporting** (dashboard, CSV, holidays, CRM leads).
7. **Notifications** (FCM + in-app).

## Features → Stories (examples)

| Feature | Story | Acceptance (derived) |
|---|---|---|
| Geofenced check-in | "As a student I check in when at the studio" | check-in only succeeds within `radius_meters` of batch coords (c2 test) |
| Payment | "As a student I submit a UPI payment" | screenshot stored; status pending until staff approves; expiry set; notified (c8) |
| Lead conversion | "As an admin I convert a lead to a member" | admin-only; creates user; CRM updated (c6) |
| Role security | "Roles can't be self-escalated" | privileged fields locked (c1, c4) |

## Acceptance Criteria

Encoded as the **c1–c8 security tests** + web `lib` tests. New features should ship with equivalent tests (see [16_Testing_QA](16_Testing_QA.md)).

## Prioritization

Closed-beta scope drives priority (RICE-style ordering in `design/12-implementation-planning.md`). Current top priority: payments + reporting + launch checklist.

## Feature Flags

`[Needs Verification]`: no feature-flag system found. CMS/email act as soft toggles (presence of keys). Consider a flag layer for staged rollouts (`Divinity` flag skills available).

## Release Planning

Beta → store release. Quality gates must pass. See [15_DevOps_Infrastructure](15_DevOps_Infrastructure.md), [20_Project_History](20_Project_History.md).

## Product Metrics

See [23_Data_Analytics](23_Data_Analytics.md) and [design/24-success-metrics.md].

## Product Decisions

Tracked in [DECISION_LOG.md](DECISION_LOG.md) + ADRs.
