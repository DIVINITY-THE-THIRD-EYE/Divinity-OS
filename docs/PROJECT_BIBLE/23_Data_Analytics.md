# Phase 23 — Data & Analytics

> Business analytics (not the DB). Sources: [design/16-analytics-taxonomy.md](../website/design/16-analytics-taxonomy.md), `services/analytics_service.dart`, [design/24-success-metrics.md].

## Business KPIs

| KPI | Definition | Source |
|---|---|---|
| Enquiry rate | enquiries / visitors | web forms + WhatsApp clicks |
| Conversion rate | members / enquiries | leads → users |
| Active members | users with valid plan | `payments.plan_expiration_date` |
| Attendance rate | check-ins / scheduled | `attendance` |
| Streak distribution | consecutive attendance | streak triggers |
| Payment completion | approved / submitted | `payments` |
| Renewal rate | renewals / expiries | `payments` history |

## Event Taxonomy

Defined in [design/16-analytics-taxonomy.md](../website/design/16-analytics-taxonomy.md). App events flow through `analytics_service.dart` (Firebase Analytics). **`[Needs Verification]`:** transcribe the canonical event names/params and confirm web event wiring.

## Analytics Events (app)

Wrapper: `analytics_service.dart`. Likely events: login, onboarding_complete, check_in, payment_submitted, payment_approved, screen_view. `[Needs Verification]` for the exact set.

## Funnels

Acquisition: visit → explore → enquire (WhatsApp/form/calculator) → onboard → first payment → first check-in. Web conversion components: `PlanCalculator`, `WhatsAppFab`, `Contact`, `Newsletter`.

## Conversion Tracking

Web: form submissions + newsletter + WhatsApp `waHref`. `[Needs Verification]`: attribution/UTM handling.

## User Behaviour

App: screen views, check-in frequency, payment behavior via Firebase Analytics. Web: `[Needs Verification]` provider.

## Retention Metrics

Streaks + renewals as retention proxies. Cohorts `[Needs Verification]` (no cohort tooling committed).

## Dashboards

In-app admin dashboard (`admin_dashboard_screen` + `fl_chart`). External BI dashboards `[Needs Verification]`.

## Reports

Admin CSV export (payments/attendance) via `share_plus`. See [07_Admin_Panel](07_Admin_Panel.md).

## A/B Testing

`[Needs Verification]`: no experimentation framework found. Could leverage flags + analytics later.

## Cohort Analysis

`[Needs Verification]`: not implemented.
