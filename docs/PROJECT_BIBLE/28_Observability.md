# Phase 28 — Observability

> Sources: `firebase_crashlytics` + `firebase_analytics` (app), `services/analytics_service.dart`, Vercel (web), `android-mcp.log` (dev artifact, quarantined).

## Logging Strategy

- **App:** Crashlytics for errors; Analytics for events. Local `debugPrint` in dev.
- **Web:** Vercel function logs; contact route logs fallback deliveries.
- **Centralized aggregation:** `[Needs Verification]` (no log sink like Datadog/Logtail configured).

## Metrics

- App engagement via Firebase Analytics; DB metrics via admin dashboard queries.
- Infra metrics via Vercel/Supabase/Firebase consoles.

## Tracing

`[Needs Verification]`: no distributed tracing (OpenTelemetry) configured. Low need given BaaS architecture.

## Dashboards

- Firebase console (crash/analytics), Supabase dashboard (DB), Vercel (web).
- In-product: admin dashboard (`fl_chart`).

## Alert Rules

`[Needs Verification]`: none committed. Recommend: Crashlytics crash-free-rate alert, Supabase error-rate, Vercel deploy-failure, uptime check.

## Error Reporting

Crashlytics (app). Web errors via Vercel + `error.tsx`/`global-error.tsx`. `[Needs Verification]` for a web error tracker (Sentry).

## Crash Analytics

Firebase Crashlytics integrated (`pubspec` + init). Provides stack traces, crash-free users.

## Health Checks

`[Needs Verification]`: no committed health endpoint/canary. The website is static (CDN); add a synthetic check on `/` and `/api/contact`. (`Divinity:canary-watch`.)

## Uptime

`[Needs Verification]`: no uptime monitor configured (UptimeRobot/Better Stack candidates).

## Monitoring SOP

Proposed: daily glance at Crashlytics + Supabase + Vercel; weekly KPI review from admin dashboard; alert-driven response per severity matrix ([27_Business_Continuity](27_Business_Continuity.md)). `[Needs Verification]`.
