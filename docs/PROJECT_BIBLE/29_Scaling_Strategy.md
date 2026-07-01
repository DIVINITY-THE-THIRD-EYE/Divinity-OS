# Phase 29 — Scaling Strategy

> A single-academy product on managed infrastructure; scaling is mostly a vendor-tier + data-design exercise. Targets are `[Needs Verification]` until growth numbers are set.

## Expected Growth

`[Needs Verification]`: target member count / concurrent users not in repo. Design assumes hundreds–low-thousands of members initially.

## Performance Limits

- Web: effectively unbounded (static + CDN) for reads; API routes limited by Vercel function concurrency + the **in-memory rate limiter** (per-instance) — the first thing to revisit at scale.
- DB: Supabase Postgres; indexed hot paths (payments, notifications, attendance — migration 015).

## Database Scaling

- Add FK/filter indexes as queries grow (pattern set in 015).
- Consider partitioning `attendance` by date if volume is high.
- Use RPCs to keep heavy logic server-side. Supabase compute tier upgrade as needed. `[Needs Verification]` current tier.

## API Scaling

- Replace in-memory rate limiter with a shared store (e.g., Upstash/Redis) for multi-instance correctness.
- Supabase connection pooling (PgBouncer) for app concurrency.

## Storage Scaling

Supabase Storage for screenshots — set lifecycle/retention + size limits ([26_Compliance_Legal](26_Compliance_Legal.md)). Offload old media to cheaper storage `[Needs Verification]`.

## CDN Strategy

Vercel edge for web; consider Cloudflare (per CLAUDE.md) for additional caching/WAF. Image optimization via `next/image`.

## Multi-Tenant Strategy

Currently single-tenant. For multi-academy/franchise: add an `academy_id` dimension + RLS scoping, or DB-per-tenant. `[Needs Verification]` — not yet designed.

## Regional Expansion

Single-region (India) today. Multi-region would need Supabase read replicas + edge config. `[Needs Verification]`.

## Cost Optimization

- Stay on managed free/low tiers until growth justifies upgrades.
- Watch Supabase egress, Firebase messaging volume, Vercel function invocations.
- `Divinity:cost-optimization` / `cost-tracking` skills available.
