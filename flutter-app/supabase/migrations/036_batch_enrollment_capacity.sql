-- 036_batch_enrollment_capacity.sql
-- ─────────────────────────────────────────────────────────────────────────────
-- Module 5 — Batch Enrollment Capacity Constraint
-- ─────────────────────────────────────────────────────────────────────────────

create or replace function public.enforce_batch_capacity()
returns trigger
language plpgsql
security definer
set search_path = public, pg_temp
as $$
declare
  v_capacity int;
  v_enrolled int;
begin
  -- Take FOR UPDATE lock on the batch row to serialize concurrent enrollments
  select capacity into v_capacity
  from public.batches
  where id = new.batch_id
  for update;

  -- Count existing active enrollments for this batch
  select count(*)::int into v_enrolled
  from public.enrollments
  where batch_id = new.batch_id;

  if v_enrolled >= v_capacity then
    raise exception 'Batch enrollment capacity exceeded. Limit is %.', v_capacity
      using errcode = '23514'; -- check_violation
  end if;

  return new;
end;
$$;

create or replace trigger enrollments_capacity_trigger
  before insert on public.enrollments
  for each row execute function public.enforce_batch_capacity();
