-- 021_therapeutic_logs_rls.sql
-- ─────────────────────────────────────────────────────────────────────────────
-- FIX R4 — therapeutic_logs trainer_id enforcement on insert
--
-- Redefine the insert policy on public.therapeutic_logs to ensure:
--   - Trainers can only insert logs where trainer_id equals their own user ID.
--   - Admins can insert logs for any trainer (trainer_id must be provided).
-- ─────────────────────────────────────────────────────────────────────────────

drop policy if exists "therapeutic_logs_insert_staff" on public.therapeutic_logs;

create policy "therapeutic_logs_insert_staff" on public.therapeutic_logs
  for insert with check (
    (public.is_admin(auth.uid()) and trainer_id is not null)
    or
    (public.is_trainer(auth.uid()) and trainer_id = auth.uid())
  );
