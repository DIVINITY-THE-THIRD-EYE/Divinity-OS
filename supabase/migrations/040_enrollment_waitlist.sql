-- 040_enrollment_waitlist.sql
-- ─────────────────────────────────────────────────────────────────────────────
-- Self-service enrollment requests + batch waitlist (owner-confirmed PRD
-- decisions #22 and #24):
--   • Students can request to join a batch themselves; it lands PENDING
--     until staff (Trainer or Admin) confirms it — not instant.
--   • If the batch is already full, the request goes to a waitlist instead.
--     Admin manually reviews the waitlist and offers the spot to whoever
--     they choose (no first-come auto-fill) — Admin is notified when a spot
--     opens, not the waitlisted students directly.
-- Staff-created enrollments (existing admin/trainer flow) are unaffected:
-- they still insert directly as CONFIRMED.
-- ─────────────────────────────────────────────────────────────────────────────

-- ── enrollments: add a status so a request can be PENDING before it's real ──
alter table public.enrollments
  add column if not exists status text not null default 'CONFIRMED'
    check (status in ('PENDING', 'CONFIRMED', 'REJECTED'));

-- Only CONFIRMED enrollments consume a capacity slot.
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
  if new.status <> 'CONFIRMED' then
    return new;
  end if;

  select capacity into v_capacity
  from public.batches
  where id = new.batch_id
  for update;

  select count(*)::int into v_enrolled
  from public.enrollments
  where batch_id = new.batch_id
    and status = 'CONFIRMED'
    and id is distinct from new.id;

  if v_enrolled >= v_capacity then
    raise exception 'Batch enrollment capacity exceeded. Limit is %.', v_capacity
      using errcode = '23514';
  end if;

  return new;
end;
$$;

drop trigger if exists enrollments_capacity_trigger on public.enrollments;
create trigger enrollments_capacity_trigger
  before insert or update of status on public.enrollments
  for each row execute function public.enforce_batch_capacity();

-- Students can submit their own PENDING request (staff-direct inserts keep
-- using the existing trainer/admin policy, which defaults to CONFIRMED).
create policy "enrollments_insert_student_pending" on public.enrollments
  for insert with check (student_id = auth.uid() and status = 'PENDING');

-- Staff confirm/reject a pending request (or otherwise manage enrollments).
create policy "enrollments_update_staff" on public.enrollments
  for update using (
    exists (select 1 from public.users u where u.id = auth.uid() and u.role in ('TRAINER','ADMIN'))
  );

-- ── batch_waitlist ───────────────────────────────────────────────────────────
create table if not exists public.batch_waitlist (
  id           uuid primary key default gen_random_uuid(),
  student_id   uuid not null references public.users(id) on delete cascade,
  batch_id     uuid not null references public.batches(id) on delete cascade,
  status       text not null default 'WAITING'
                 check (status in ('WAITING', 'OFFERED', 'CONVERTED', 'CANCELLED')),
  requested_at timestamptz not null default now(),
  updated_at   timestamptz not null default now(),
  unique (student_id, batch_id)
);

create index if not exists idx_batch_waitlist_batch on public.batch_waitlist (batch_id, status);

create or replace trigger batch_waitlist_updated_at
  before update on public.batch_waitlist
  for each row execute function public.set_updated_at();

alter table public.batch_waitlist enable row level security;

create policy "waitlist_select"
  on public.batch_waitlist for select
  using (
    student_id = auth.uid()
    or exists (select 1 from public.users u where u.id = auth.uid() and u.role in ('TRAINER','ADMIN'))
  );

create policy "waitlist_insert_student"
  on public.batch_waitlist for insert
  with check (student_id = auth.uid());

create policy "waitlist_update_admin"
  on public.batch_waitlist for update
  using (public.is_admin(auth.uid()));

create policy "waitlist_delete_admin"
  on public.batch_waitlist for delete
  using (public.is_admin(auth.uid()));

-- ── request_enrollment RPC ───────────────────────────────────────────────────
-- Student-facing entry point: routes to a PENDING enrollment request if the
-- batch has room, or the waitlist if it's full. Re-requesting after a
-- REJECTED enrollment re-opens it as PENDING instead of erroring on the
-- unique(student_id, batch_id) constraint.
create or replace function public.request_enrollment(p_batch_id uuid)
returns text
language plpgsql
security definer
set search_path = public, pg_temp
as $$
declare
  v_uid       uuid := auth.uid();
  v_capacity  int;
  v_confirmed int;
  v_existing  record;
begin
  if v_uid is null then
    raise exception 'authentication required' using errcode = '42501';
  end if;

  select capacity into v_capacity from public.batches where id = p_batch_id for update;
  if v_capacity is null then
    raise exception 'batch not found' using errcode = 'P0002';
  end if;

  select id, status into v_existing from public.enrollments
    where student_id = v_uid and batch_id = p_batch_id;

  if v_existing.status in ('PENDING', 'CONFIRMED') then
    return v_existing.status;
  end if;

  select count(*)::int into v_confirmed
  from public.enrollments where batch_id = p_batch_id and status = 'CONFIRMED';

  if v_confirmed < v_capacity then
    if v_existing.id is not null then
      update public.enrollments set status = 'PENDING' where id = v_existing.id;
    else
      insert into public.enrollments (student_id, batch_id, status) values (v_uid, p_batch_id, 'PENDING');
    end if;
    return 'PENDING';
  else
    insert into public.batch_waitlist (student_id, batch_id, status)
    values (v_uid, p_batch_id, 'WAITING')
    on conflict (student_id, batch_id) do update set status = 'WAITING', updated_at = now();
    return 'WAITLISTED';
  end if;
end;
$$;

revoke all on function public.request_enrollment(uuid) from public, anon;
grant execute on function public.request_enrollment(uuid) to authenticated;

-- ── Notify Admin when a spot frees up on a batch with a waitlist ────────────
create or replace function public.notify_waitlist_on_spot_open()
returns trigger
language plpgsql
security definer
set search_path = public, pg_temp
as $$
declare
  v_batch_name  text;
  v_waiting     int;
  v_admin_id    uuid;
  v_old_batch   uuid;
  v_old_status  text;
begin
  v_old_batch := coalesce(old.batch_id, null);
  v_old_status := coalesce(old.status, null);

  if v_old_batch is null or v_old_status <> 'CONFIRMED' then
    return coalesce(new, old);
  end if;
  -- Only fires when a CONFIRMED seat actually goes away (delete, or status
  -- change off CONFIRMED) — not on unrelated updates.
  if tg_op = 'UPDATE' and new.status = 'CONFIRMED' then
    return new;
  end if;

  select count(*)::int into v_waiting
  from public.batch_waitlist where batch_id = v_old_batch and status = 'WAITING';

  if v_waiting = 0 then
    return coalesce(new, old);
  end if;

  select name into v_batch_name from public.batches where id = v_old_batch;

  for v_admin_id in select id from public.users where role = 'ADMIN' loop
    insert into public.notifications (user_id, kind, title, body)
    values (
      v_admin_id,
      'GENERAL',
      'Waitlist: spot opened',
      format('A spot opened in "%s" — %s student(s) waiting.', coalesce(v_batch_name, 'a batch'), v_waiting)
    );
  end loop;

  return coalesce(new, old);
end;
$$;

drop trigger if exists enrollments_notify_waitlist on public.enrollments;
create trigger enrollments_notify_waitlist
  after update of status or delete on public.enrollments
  for each row execute function public.notify_waitlist_on_spot_open();

-- ── convert_waitlist_entry RPC (Admin picks who gets the open spot) ─────────
create or replace function public.convert_waitlist_entry(p_waitlist_id uuid)
returns public.enrollments
language plpgsql
security definer
set search_path = public, pg_temp
as $$
declare
  v_row public.enrollments;
  v_wl  public.batch_waitlist;
begin
  if not public.is_admin(auth.uid()) then
    raise exception 'only Admin can convert a waitlist entry' using errcode = '42501';
  end if;

  select * into v_wl from public.batch_waitlist where id = p_waitlist_id and status = 'WAITING';
  if v_wl.id is null then
    raise exception 'waitlist entry not found or already resolved' using errcode = 'P0002';
  end if;

  insert into public.enrollments (student_id, batch_id, assigned_by, status)
  values (v_wl.student_id, v_wl.batch_id, auth.uid(), 'CONFIRMED')
  on conflict (student_id, batch_id) do update set status = 'CONFIRMED'
  returning * into v_row;

  update public.batch_waitlist set status = 'CONVERTED' where id = p_waitlist_id;

  return v_row;
end;
$$;

revoke all on function public.convert_waitlist_entry(uuid) from public, anon;
grant execute on function public.convert_waitlist_entry(uuid) to authenticated;
