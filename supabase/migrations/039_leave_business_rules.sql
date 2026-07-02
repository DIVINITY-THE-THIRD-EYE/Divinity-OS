-- 039_leave_business_rules.sql
-- ─────────────────────────────────────────────────────────────────────────────
-- Leave system business rules (owner-confirmed PRD decisions):
--   • Default cap: 4 leave days/month, or plans.max_leave_days_per_month
--     for the student's current plan.
--   • Auto-approval when requested >=24h before the leave starts AND within
--     the monthly cap. Trainer is notified (informational only, no approval
--     power). Late/over-cap requests stay PENDING for Admin only.
--   • Sat/Sun are week-offs: they don't consume leave balance or need
--     approval, so they're excluded when counting days in a request.
--   • Attendance override: if a student marked ON_LEAVE actually checks in,
--     that day flips to PRESENT, is "recredited" (no longer counts against
--     the cap), and any package-extension already applied for that day is
--     undone.
--   • Package auto-extension: student's expiration_date += 1 day per
--     approved (non-recredited) leave day.
--
-- Simplification: advance-notice is measured as "requested before midnight
-- of the day prior to start_date" (Asia/Kolkata), since leave_requests are
-- date ranges not tied to one batch's specific class time.
-- ─────────────────────────────────────────────────────────────────────────────

-- ── Track current plan per student (per-plan leave cap lookup) ─────────────
alter table public.users
  add column if not exists current_plan_id uuid references public.plans(id);

-- Stamp current_plan_id alongside expiration_date when a payment activates.
create or replace function public.propagate_payment_status()
returns trigger
language plpgsql
security definer
set search_path = public, pg_temp
as $$
begin
  perform set_config('my.bypass_lock', 'true', true);

  if new.status = 'PENDING' and new.admin_approved = false and new.receipt_given_by_trainer = false then
    update public.users
    set plan_status = 'PENDING_ADMIN'
    where id = new.student_id;

  elsif new.admin_approved = true and new.receipt_given_by_trainer = false and new.status = 'PENDING' then
    update public.users
    set plan_status = 'PENDING_TRAINER'
    where id = new.student_id;

  elsif new.admin_approved = true and new.receipt_given_by_trainer = true and new.status = 'PAID' then
    update public.users
    set plan_status = 'ACTIVE',
        expiration_date = coalesce(new.plan_expiration_date, expiration_date, (now() + interval '30 days')::date),
        current_plan_id = coalesce(new.plan_id, current_plan_id)
    where id = new.student_id;

  elsif new.status = 'FAILED' then
    update public.users
    set plan_status = 'UNPAID'
    where id = new.student_id;
  end if;

  return new;
end;
$$;

-- ── leave_days: one row per actual class day consumed by a leave request ───
-- (normalizing out of the leave_requests date range makes cap-counting,
-- attendance-recredit, and extension bookkeeping exact per-day.)
create table if not exists public.leave_days (
  id                uuid primary key default gen_random_uuid(),
  leave_request_id  uuid not null references public.leave_requests(id) on delete cascade,
  student_id        uuid not null references public.users(id) on delete cascade,
  date              date not null,
  recredited        boolean not null default false,
  extended_package  boolean not null default false,
  created_at        timestamptz not null default now(),
  unique (student_id, date)
);

create index if not exists idx_leave_days_student_date on public.leave_days (student_id, date);
create index if not exists idx_leave_days_request on public.leave_days (leave_request_id);

alter table public.leave_days enable row level security;

create policy "leave_days_select"
  on public.leave_days for select
  using (
    student_id = auth.uid()
    or exists (select 1 from public.users u where u.id = auth.uid() and u.role in ('TRAINER','ADMIN'))
  );
-- No client insert/update policy: leave_days is only ever written by the
-- SECURITY DEFINER trigger functions below.

-- ── Leave request bookkeeping + tighter approval RLS ────────────────────────
alter table public.leave_requests
  add column if not exists is_auto_approved boolean not null default false;

-- Only Admin can manually change a leave request's status. Trainer keeps
-- read access via "leave_select" but never gets update rights — per the PRD,
-- Trainer can only forward/observe, auto-approval or Admin decides.
drop policy if exists "leave_update_staff" on public.leave_requests;
create policy "leave_update_admin"
  on public.leave_requests for update
  using (public.is_admin(auth.uid()));

-- ── Week-off helper (Sat/Sun) ────────────────────────────────────────────────
create or replace function public.is_week_off(d date)
returns boolean
language sql
immutable
as $$
  select extract(isodow from d) in (6, 7);
$$;

-- ── Before insert: decide auto-approve vs pending-admin ─────────────────────
create or replace function public.process_leave_request()
returns trigger
language plpgsql
security definer
set search_path = public, pg_temp
as $$
declare
  v_cap             integer;
  v_requested_days  integer;
  v_used_days       integer;
  v_advance_ok      boolean;
begin
  select count(*) into v_requested_days
  from generate_series(new.start_date, new.end_date, interval '1 day') d
  where not public.is_week_off(d::date);

  if v_requested_days = 0 then
    -- Entire range is week-offs: nothing to approve, just record it.
    new.status := 'APPROVED';
    new.is_auto_approved := true;
    return new;
  end if;

  select coalesce(p.max_leave_days_per_month, 4) into v_cap
  from public.users u
  left join public.plans p on p.id = u.current_plan_id
  where u.id = new.student_id;
  v_cap := coalesce(v_cap, 4);

  select count(*) into v_used_days
  from public.leave_days ld
  join public.leave_requests lr on lr.id = ld.leave_request_id
  where ld.student_id = new.student_id
    and ld.recredited = false
    and lr.status = 'APPROVED'
    and date_trunc('month', ld.date) = date_trunc('month', new.start_date);

  v_advance_ok := (now() at time zone 'Asia/Kolkata')
    <= (new.start_date::timestamp - interval '24 hours');

  if v_advance_ok and (v_used_days + v_requested_days) <= v_cap then
    new.status := 'APPROVED';
    new.is_auto_approved := true;
  else
    new.status := 'PENDING';
    new.is_auto_approved := false;
  end if;

  return new;
end;
$$;

drop trigger if exists leave_requests_before_insert on public.leave_requests;
create trigger leave_requests_before_insert
  before insert on public.leave_requests
  for each row execute function public.process_leave_request();

-- ── After insert/update: materialize leave_days, extend package, sync
--    attendance, and notify (student always; trainer informationally) ──────
create or replace function public.finalize_leave_approval()
returns trigger
language plpgsql
security definer
set search_path = public, pg_temp
as $$
declare
  v_trainer_id uuid;
begin
  if tg_op = 'UPDATE' and new.status = 'REJECTED' and old.status <> 'REJECTED' then
    insert into public.notifications (user_id, kind, title, body)
    values (
      new.student_id,
      'LEAVE_REJECTED',
      'Leave request rejected',
      format('Your leave request for %s to %s was not approved.', new.start_date, new.end_date)
    );
    return new;
  end if;

  if new.status <> 'APPROVED' then
    return new;
  end if;
  if tg_op = 'UPDATE' and old.status = 'APPROVED' then
    return new; -- already processed
  end if;

  -- 1. Materialize one leave_days row per actual class day (skip week-offs).
  --    A day already checked in as PRESENT is recredited immediately — the
  --    student was there, so it never should have consumed leave/extension.
  insert into public.leave_days (leave_request_id, student_id, date, recredited)
  select
    new.id,
    new.student_id,
    d::date,
    exists (
      select 1 from public.attendance a
      where a.student_id = new.student_id and a.date = d::date and a.status = 'PRESENT'
    )
  from generate_series(new.start_date, new.end_date, interval '1 day') d
  where not public.is_week_off(d::date)
  on conflict (student_id, date) do nothing;

  -- 2. Extend the package end date by 1 day per newly-approved, non-recredited day.
  update public.users u
  set expiration_date = u.expiration_date + (
    select count(*)::int from public.leave_days ld
    where ld.leave_request_id = new.id and ld.extended_package = false and ld.recredited = false
  )
  where u.id = new.student_id and u.expiration_date is not null;

  update public.leave_days
  set extended_package = true
  where leave_request_id = new.id and extended_package = false and recredited = false;

  -- 3. Attendance auto-updates to ON_LEAVE — never overwrites an existing PRESENT.
  insert into public.attendance (student_id, date, status, marked_by)
  select new.student_id, ld.date, 'ON_LEAVE', 'SYSTEM'
  from public.leave_days ld
  where ld.leave_request_id = new.id
  on conflict (student_id, date) do update
    set status = 'ON_LEAVE', marked_by = 'SYSTEM'
    where public.attendance.status not in ('PRESENT');

  -- 4. Notify the student.
  insert into public.notifications (user_id, kind, title, body)
  values (
    new.student_id,
    'LEAVE_APPROVED',
    'Leave approved',
    format('Your leave from %s to %s has been approved.', new.start_date, new.end_date)
  );

  -- 5. Notify assigned trainer(s) — informational only, no approval power.
  for v_trainer_id in
    select distinct b.trainer_id
    from public.enrollments e
    join public.batches b on b.id = e.batch_id
    where e.student_id = new.student_id and b.trainer_id is not null
  loop
    insert into public.notifications (user_id, kind, title, body)
    values (
      v_trainer_id,
      'GENERAL',
      'Student on leave',
      format('A student in your batch will be on leave %s to %s.', new.start_date, new.end_date)
    );
  end loop;

  return new;
end;
$$;

drop trigger if exists leave_requests_after_approval on public.leave_requests;
create trigger leave_requests_after_approval
  after insert or update of status on public.leave_requests
  for each row execute function public.finalize_leave_approval();

-- ── Attendance-override recredit: check-in wins over an ON_LEAVE mark ───────
create or replace function public.recredit_leave_on_attendance()
returns trigger
language plpgsql
security definer
set search_path = public, pg_temp
as $$
declare
  v_leave_request_id uuid;
  v_was_extended      boolean;
begin
  if new.status <> 'PRESENT' then
    return new;
  end if;
  if tg_op = 'UPDATE' and old.status = 'PRESENT' then
    return new;
  end if;

  select ld.leave_request_id, ld.extended_package
  into v_leave_request_id, v_was_extended
  from public.leave_days ld
  join public.leave_requests lr on lr.id = ld.leave_request_id
  where ld.student_id = new.student_id
    and ld.date = new.date
    and ld.recredited = false
    and lr.status = 'APPROVED';

  if v_leave_request_id is null then
    return new;
  end if;

  update public.leave_days
  set recredited = true
  where student_id = new.student_id and date = new.date;

  if v_was_extended then
    update public.users
    set expiration_date = expiration_date - 1
    where id = new.student_id and expiration_date is not null;

    update public.leave_days
    set extended_package = false
    where student_id = new.student_id and date = new.date;
  end if;

  return new;
end;
$$;

drop trigger if exists attendance_recredit_leave on public.attendance;
create trigger attendance_recredit_leave
  after insert or update of status on public.attendance
  for each row execute function public.recredit_leave_on_attendance();

-- ── check_in RPC: let a genuine check-in win over a SYSTEM-authored
--    ON_LEAVE mark too (previously only 'STUDENT'-marked rows could be
--    overwritten, which blocked "checking in wins" for on-leave days). ─────
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
  -- of ABSENT / ON_LEAVE-by-staff must stick). SYSTEM marks (the automatic
  -- ON_LEAVE from an approved leave request) DO yield to a real check-in,
  -- per the "checking in wins" + leave-recredit rule.
  insert into public.attendance
    (student_id, batch_id, date, checkin_time, status, marked_by)
  values
    (v_uid, v_batch, v_today, now(), 'PRESENT', 'STUDENT')
  on conflict (student_id, date) do update
    set checkin_time = excluded.checkin_time,
        status       = 'PRESENT',
        batch_id     = excluded.batch_id,
        marked_by    = 'STUDENT'
    where public.attendance.marked_by in ('STUDENT', 'SYSTEM');

  select * into v_row
  from public.attendance
  where student_id = v_uid and date = v_today;

  return v_row;
end;
$$;
