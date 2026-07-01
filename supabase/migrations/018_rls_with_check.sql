-- 018_rls_with_check.sql
-- ─────────────────────────────────────────────────────────────────────────────
-- FIX C6 — RLS with check on batches / therapeutic_logs
--
-- Redefine update policies for batches and therapeutic_logs to enforce safety
-- check constraints and restrict editing fields based on roles.
-- ─────────────────────────────────────────────────────────────────────────────

-- ── 1. Batches Update Policy ─────────────────────────────────────────────────
drop policy if exists "batches_update_own_or_admin" on public.batches;

create policy "batches_update_own_or_admin" on public.batches
  for update
  using (
    public.is_trainer(auth.uid()) and trainer_id = auth.uid()
    or public.is_admin(auth.uid())
  )
  with check (
    -- Enforce that coordinates are not null (geofence coordinates required)
    location_lat is not null and location_lng is not null
    and (
      -- Only admins can change the trainer_id of a batch
      public.is_admin(auth.uid())
      or (public.is_trainer(auth.uid()) and trainer_id = auth.uid())
    )
  );

-- ── 2. Therapeutic Logs Update Policy ────────────────────────────────────────
-- Currently no update policy exists, meaning client-side edits are blocked by RLS.
-- Add update policy permitting trainers to edit their own logs and admins to edit any.
drop policy if exists "therapeutic_logs_update" on public.therapeutic_logs;

create policy "therapeutic_logs_update" on public.therapeutic_logs
  for update
  using (
    trainer_id = auth.uid()
    or public.is_admin(auth.uid())
  )
  with check (
    trainer_id = auth.uid()
    or public.is_admin(auth.uid())
  );
