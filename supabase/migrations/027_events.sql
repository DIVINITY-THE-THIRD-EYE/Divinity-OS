-- 027_events.sql
-- ─────────────────────────────────────────────────────────────────────────────
-- Module 11 — Events (in-app)
--
-- Workshops, seminars, and camps published by admins. All authenticated users
-- see PUBLISHED events; students self-register (RSVP) subject to capacity.
-- The website continues to render its own `/events` marketing pages; this is the
-- operational, app-facing store — no duplication of the CMS.
--
-- Integrates with: public.users (roles), RLS helpers is_admin/is_trainer_or_admin,
-- public.set_updated_at(), public.notifications (publish → student fan-out).
-- ─────────────────────────────────────────────────────────────────────────────

-- ── events ────────────────────────────────────────────────────────────────────
create table if not exists public.events (
  id           uuid primary key default gen_random_uuid(),
  title        text not null check (char_length(trim(title)) > 0),
  description  text,
  location     text,
  starts_at    timestamptz not null,
  capacity     integer check (capacity is null or capacity > 0),
  status       text not null default 'PUBLISHED'
                 check (status in ('DRAFT', 'PUBLISHED', 'CANCELLED')),
  created_by   uuid references public.users(id) on delete set null,
  created_at   timestamptz not null default now(),
  updated_at   timestamptz not null default now()
);

create index if not exists events_starts_at_idx on public.events(starts_at);
create index if not exists events_status_idx on public.events(status);

create or replace trigger events_updated_at
  before update on public.events
  for each row execute procedure public.set_updated_at();

-- ── event_registrations ───────────────────────────────────────────────────────
create table if not exists public.event_registrations (
  id           uuid primary key default gen_random_uuid(),
  event_id     uuid not null references public.events(id) on delete cascade,
  student_id   uuid not null references public.users(id) on delete cascade,
  created_at   timestamptz not null default now(),
  unique (event_id, student_id)
);

create index if not exists event_registrations_event_idx
  on public.event_registrations(event_id);
create index if not exists event_registrations_student_idx
  on public.event_registrations(student_id);

-- ── Table-level privileges (blanket grant in 012 predates these tables) ───────
grant select, insert, update, delete on public.events              to authenticated, service_role;
grant select, insert, update, delete on public.event_registrations to authenticated, service_role;

-- ── SECURITY DEFINER helper (capacity check bypasses RLS row visibility) ──────
create or replace function public.event_is_full(p_event uuid)
returns boolean
language sql
security definer
set search_path = public
as $$
  select case
    when e.capacity is null then false
    else (
      select count(*) from public.event_registrations r
      where r.event_id = p_event
    ) >= e.capacity
  end
  from public.events e
  where e.id = p_event;
$$;

-- ── RLS ───────────────────────────────────────────────────────────────────────
alter table public.events              enable row level security;
alter table public.event_registrations enable row level security;

-- events: everyone authenticated sees PUBLISHED; admins see all statuses.
drop policy if exists "events_select" on public.events;
create policy "events_select" on public.events
  for select using (
    status = 'PUBLISHED' or public.is_admin(auth.uid())
  );

drop policy if exists "events_insert_admin" on public.events;
create policy "events_insert_admin" on public.events
  for insert with check (public.is_admin(auth.uid()));

drop policy if exists "events_update_admin" on public.events;
create policy "events_update_admin" on public.events
  for update using (public.is_admin(auth.uid()));

drop policy if exists "events_delete_admin" on public.events;
create policy "events_delete_admin" on public.events
  for delete using (public.is_admin(auth.uid()));

-- event_registrations: a student sees their own; admins see all.
drop policy if exists "event_registrations_select" on public.event_registrations;
create policy "event_registrations_select" on public.event_registrations
  for select using (
    student_id = auth.uid() or public.is_admin(auth.uid())
  );

-- A student may register themselves for a PUBLISHED event. Capacity is enforced
-- by the concurrency-safe BEFORE INSERT trigger below (a non-locking check here
-- would be bypassable by simultaneous transactions).
drop policy if exists "event_registrations_insert" on public.event_registrations;
create policy "event_registrations_insert" on public.event_registrations
  for insert with check (
    student_id = auth.uid()
    and exists (
      select 1 from public.events e
      where e.id = event_registrations.event_id and e.status = 'PUBLISHED'
    )
  );

-- Students may cancel their own registration; admins may remove any.
drop policy if exists "event_registrations_delete" on public.event_registrations;
create policy "event_registrations_delete" on public.event_registrations
  for delete using (
    student_id = auth.uid() or public.is_admin(auth.uid())
  );

-- ── Capacity enforcement (concurrency-safe) ───────────────────────────────────
-- A non-locking capacity check is bypassable: two simultaneous transactions each
-- read the pre-insert count and both succeed. This BEFORE INSERT trigger takes a
-- row lock on the parent event (FOR UPDATE), which serializes registrations for
-- the same event — the second transaction blocks until the first commits, then
-- re-counts and is correctly rejected.
create or replace function public.enforce_event_capacity()
returns trigger
language plpgsql
security definer
set search_path = public, pg_temp
as $$
begin
  -- Serialize concurrent registrations for this event.
  perform 1 from public.events where id = new.event_id for update;
  if public.event_is_full(new.event_id) then
    raise exception 'Event % is at capacity', new.event_id
      using errcode = '23514';  -- check_violation
  end if;
  return new;
end;
$$;

drop trigger if exists event_registrations_capacity on public.event_registrations;
create trigger event_registrations_capacity
  before insert on public.event_registrations
  for each row execute function public.enforce_event_capacity();

-- ── Notification on publish ───────────────────────────────────────────────────
-- Notify every student when an event becomes PUBLISHED (on insert as PUBLISHED
-- or on a DRAFT→PUBLISHED transition), surfacing the Notification flow for events.
create or replace function public.notify_event_published()
returns trigger
language plpgsql
security definer
set search_path = public, pg_temp
as $$
declare
  v_should_notify boolean := false;
begin
  if tg_op = 'INSERT' and new.status = 'PUBLISHED' then
    v_should_notify := true;
  elsif tg_op = 'UPDATE'
        and new.status = 'PUBLISHED'
        and old.status is distinct from 'PUBLISHED' then
    v_should_notify := true;
  end if;

  if v_should_notify then
    insert into public.notifications (user_id, kind, title, body, metadata)
    select
      u.id,
      'GENERAL',
      '📅 New Event: ' || new.title,
      coalesce(
        'Join us' ||
          case when new.location is not null then ' at ' || new.location else '' end ||
          '. Open Events to register.',
        'A new event has been announced. Open Events to register.'
      ),
      jsonb_build_object(
        'event_id', new.id,
        'action', 'event_published',
        'target', 'events'
      )
    from public.users u
    where u.role = 'STUDENT';
  end if;

  return new;
end;
$$;

drop trigger if exists events_notify_published on public.events;
create trigger events_notify_published
  after insert or update on public.events
  for each row execute function public.notify_event_published();
