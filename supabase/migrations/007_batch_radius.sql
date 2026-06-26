-- ── Add radius_meters to batches ─────────────────────────────────────────────
-- Per-batch geofence radius. Defaults to 100 m (same as AppConstants.geofenceDefaultRadius).

alter table public.batches
  add column if not exists radius_meters numeric not null default 100;
