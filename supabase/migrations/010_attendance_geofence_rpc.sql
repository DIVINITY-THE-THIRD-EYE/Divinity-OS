-- 010_attendance_geofence_rpc.sql
-- ─────────────────────────────────────────────────────────────────────────────
-- FIX C2 — Client-side-only geofence on attendance check-in
--
-- Problem: attendance_repository.checkIn() inserts status='PRESENT' with no
-- location, and policy "attendance_insert_student" (003) only checks
--   with check (student_id = auth.uid())
-- The Haversine distance check lives in the Flutter UI and is advisory: a
-- student can mark PRESENT from anywhere, and marked_by is client-supplied
-- (could be forged to 'TRAINER').
--
-- Fix:
--   1. A SECURITY DEFINER RPC public.check_in(lat, lng, batch_id) that
--      validates the student is enrolled, computes server-side Haversine
--      distance against the batch geofence, rejects out-of-radius check-ins,
--      and forces student_id = auth.uid() and marked_by = 'STUDENT'.
--   2. Remove the direct student INSERT policy so attendance can only be
--      created by staff (trainer/admin policy from 005) or via this RPC.
--   3. Staff-marked records (ABSENT/ON_LEAVE/etc.) are NOT overwritten by a
--      student self check-in.
--
-- NOTE: the Flutter client MUST be updated to call this RPC instead of the
-- direct upsert (see MIGRATION_NOTES_009_010.md). Without the client change,
-- student check-in will fail closed (RLS denies the direct insert) — which is
-- safe, but check-in is unavailable until the client ships.
-- ─────────────────────────────────────────────────────────────────────────────

-- ── Haversine helper (metres) ────────────────────────────────────────────────
create or replace function public.haversine_m(
  lat1 double precision, lng1 double precision,
  lat2 double precision, lng2 double precision
)
returns double precision
language sql
immutable
parallel safe
as $$
  select 2 * 6371000 * asin(sqrt(
    power(sin(radians(lat2 - lat1) / 2), 2) +
    cos(radians(lat1)) * cos(radians(lat2)) *
    power(sin(radians(lng2 - lng1) / 2), 2)
  ));
$$;

-- ── Check-in RPC ─────────────────────────────────────────────────────────────
create or replace function public.check_in(
  p_lat      double precision,
  p_lng      double precision,
  p_batch_id uuid default null
)
returns public.attendance
language plpgsql
security definer
set search_path = public, pg_temp
as $$
declare
  v_uid    uuid := auth.uid();
  v_batch  uuid;
  v_lat    double precision;
  v_lng    double precision;
  v_radius numeric;
  v_dist   double precision;
  v_today  date := (now() at time zone 'Asia/Kolkata')::date;
  v_row    public.attendance;
begin
  if v_uid is null then
    raise exception 'authentication required' using errcode = '42501';
  end if;
  if p_lat is null or p_lng is null then
    raise exception 'location (lat/lng) is required to check in' using errcode = '22023';
  end if;

  -- Resolve the batch: either the one passed (must be enrolled) or the
  -- student's first enrollment.
  if p_batch_id is not null then
    select e.batch_id into v_batch
    from public.enrollments e
    where e.student_id = v_uid and e.batch_id = p_batch_id
    limit 1;
    if v_batch is null then
      raise exception 'not enrolled in batch %', p_batch_id using errcode = '42501';
    end if;
  else
    select e.batch_id into v_batch
    from public.enrollments e
    where e.student_id = v_uid
    order by e.assigned_at asc
    limit 1;
    if v_batch is null then
      raise exception 'no active batch enrollment found' using errcode = 'P0002';
    end if;
  end if;

  select b.location_lat, b.location_lng, b.radius_meters
    into v_lat, v_lng, v_radius
  from public.batches b
  where b.id = v_batch;

  -- Geofence is enforced only when the batch has coordinates configured.
  -- A batch without coordinates is treated as "no geofence" (open check-in).
  if v_lat is not null and v_lng is not null then
    v_dist := public.haversine_m(v_lat, v_lng, p_lat, p_lng);
    if v_dist > coalesce(v_radius, 100) then
      raise exception
        'outside check-in radius: % m from batch (limit % m)',
        round(v_dist)::int, coalesce(v_radius, 100)
        using errcode = '42501';
    end if;
  end if;

  -- Upsert, but never overwrite a staff-authored mark (trainer/admin override
  -- of ABSENT / ON_LEAVE must stick).
  insert into public.attendance
    (student_id, batch_id, date, checkin_time, status, marked_by)
  values
    (v_uid, v_batch, v_today, now(), 'PRESENT', 'STUDENT')
  on conflict (student_id, date) do update
    set checkin_time = excluded.checkin_time,
        status       = 'PRESENT',
        batch_id     = excluded.batch_id,
        marked_by    = 'STUDENT'
    where public.attendance.marked_by = 'STUDENT';

  -- Return the resulting row (the new one, or the pre-existing staff mark that
  -- the conditional upsert intentionally left untouched).
  select * into v_row
  from public.attendance
  where student_id = v_uid and date = v_today;

  return v_row;
end;
$$;

revoke all on function public.check_in(double precision, double precision, uuid) from public, anon;
grant execute on function public.check_in(double precision, double precision, uuid) to authenticated;

-- ── Remove direct student INSERT path ────────────────────────────────────────
-- Students can no longer insert attendance directly; they must go through
-- check_in() (SECURITY DEFINER bypasses RLS internally). Staff insert/update
-- policies from 003/005 remain in force.
drop policy if exists "attendance_insert_student" on public.attendance;

-- ─────────────────────────────────────────────────────────────────────────────
-- ROLLBACK (run manually; do NOT place in migrations/)
--
--   -- restore the original permissive student insert policy
--   create policy "attendance_insert_student" on public.attendance
--     for insert with check (student_id = auth.uid());
--   drop function if exists public.check_in(double precision, double precision, uuid);
--   drop function if exists public.haversine_m(double precision, double precision, double precision, double precision);
--
-- WARNING: rolling back re-opens C2 (geofence bypass). If you roll back, also
-- revert the client to call the direct upsert, or check-in will break.
-- ─────────────────────────────────────────────────────────────────────────────
