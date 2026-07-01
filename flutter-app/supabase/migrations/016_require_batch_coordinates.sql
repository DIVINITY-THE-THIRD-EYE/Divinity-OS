-- 016_require_batch_coordinates.sql
-- ─────────────────────────────────────────────────────────────────────────────
-- FIX B5 — Require batch coordinates at creation (else geofence silently off)
--
-- Adds check constraints to the public.batches table to ensure location_lat and
-- location_lng are always provided.
-- ─────────────────────────────────────────────────────────────────────────────

alter table public.batches
  add constraint batches_coordinates_required
  check (location_lat is not null and location_lng is not null);
