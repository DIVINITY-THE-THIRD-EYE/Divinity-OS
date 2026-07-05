# 06 — Performance Report

*Scope note: this audit did not run a dedicated profiler or load test against either surface. The findings below are derived from build output, migration/index inspection, and code-level review — not from live production metrics. Treat anything not explicitly marked "measured" as a code-level observation, not a benchmark.*

## Website build output (measured — `next build`, this session)

36 routes generated cleanly. First Load JS shared by all pages: **87.5 kB**. Heaviest individual route: home page at 9.38 kB own bundle / 168 kB first load. Most other routes sit in the 139-149 kB first-load range. These are reasonable numbers for a content-driven marketing site with animation libraries (Framer Motion, GSAP, Lenis) in the shared bundle.

- `next.config.mjs:45-51` sets `images.formats: ["image/avif", "image/webp"]` and a 24-hour `minimumCacheTTL` for optimized images — a deliberate, documented trade-off (comment: "short enough that a pre-launch asset swap still propagates within a day").
- Static generation is used wherever possible (`○` markers in the build output); only 3 API routes and the OG-image route are dynamic (`ƒ`).

## Database (code-level review, not measured against production load)

- Indexes exist for the obvious hot paths: `015_performance_indexes.sql`, `028_reports_indexes.sql`, `029_missing_indexes.sql` — three dedicated index-adding migrations suggest the team has iterated on this reactively rather than up front, which is a normal and fine pattern but worth keeping an eye on as new report queries get added (each new `get_reports_*` RPC should get an index review, not just a correctness review).
- `FOR UPDATE` row locks on `batches`/`events` for capacity enforcement (`enforce_batch_capacity()`, `enforce_event_capacity()`) are correct for correctness but do serialize concurrent enrollment/registration attempts on the same batch/event — fine at this studio's scale (single location, per PRD decision #15), would need revisiting only if enrollment volume per batch grows dramatically.
- No obvious N+1 pattern was found in the reviewed RPCs (`get_reports_data`, `get_reports_attendance`, `get_reports_revenue`, `get_reports_events`) — they're written as single aggregating SQL functions, not loops of individual queries from the client.
- `trigger_certificate_check()` (migration 042) loops through a student's paid plans server-side on every `PRESENT` attendance mark to check certificate eligibility — bounded by however many concurrent plans/add-ons one student can hold (small, per the data model), so not a practical concern, but worth noting as the one trigger that does a loop rather than a single set-based operation.

## Flutter app (code-level review only — no profiling run)

- Consistent `AsyncNotifier` pattern means most screens show proper loading/error states rather than blocking synchronously, which is good for perceived performance.
- No evidence of unbounded list rendering without pagination in the areas reviewed (reports repository, feature lists) — but this was not exhaustively checked across all 22 features.
- Firebase AI Wellness Coach insights (mentioned in prior product-decision records as a paid Gemini-backed feature) has a real per-call cost; the newly-approved drop-off risk alerts (decision #21) were deliberately built as free rule-based SQL instead — a good cost-conscious choice already reflected in the `check_dropoff_risk()` trigger rather than an LLM call.

## What wasn't assessed this session

- No Lighthouse/Web Vitals run against the live or local website build.
- No Flutter DevTools profiling (frame rendering, memory) was performed — this would require a running device/emulator session, which was out of scope for this pass.
- No load testing against the Supabase backend (concurrent check-ins, concurrent enrollment requests beyond the existing pgTAP concurrency unit tests).

**Recommendation:** if performance becomes a stated concern, the next audit pass should budget time for an actual Lighthouse run and a Flutter DevTools session on a real device — this report should not be read as clearing performance, only as not having found anything alarming in a code-level pass.
