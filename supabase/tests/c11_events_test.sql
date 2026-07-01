-- c11_events_test.sql (pgTAP)
-- Run with:  supabase test db
--
-- Verifies Module 11 (027_events.sql):
--   - Admins create events; students cannot.
--   - Students see only PUBLISHED events (not DRAFT).
--   - Students self-register for published events; capacity is enforced.
--   - Publishing an event notifies students.

begin;
select plan(10);

-- ── Fixtures ─────────────────────────────────────────────────────────────────
insert into auth.users (id, email) values
  ('11111111-1111-1111-1111-111111111111', 'student1.c11@test.local'),
  ('55555555-5555-5555-5555-555555555555', 'student2.c11@test.local'),
  ('44444444-4444-4444-4444-444444444444', 'admin.c11@test.local');

update public.users set role = 'STUDENT' where id = '11111111-1111-1111-1111-111111111111';
update public.users set role = 'STUDENT' where id = '55555555-5555-5555-5555-555555555555';
update public.users set role = 'ADMIN'   where id = '44444444-4444-4444-4444-444444444444';

create or replace function pg_temp.act_as(uid uuid) returns void
language plpgsql as $$
begin
  perform set_config('role', 'authenticated', true);
  perform set_config(
    'request.jwt.claims',
    json_build_object('sub', uid::text, 'role', 'authenticated')::text,
    true
  );
end; $$;

-- ── 1-3. Admin creates events ────────────────────────────────────────────────
select pg_temp.act_as('44444444-4444-4444-4444-444444444444');

select lives_ok(
  $$ insert into public.events (id, title, location, starts_at, status, created_by)
     values ('bbbbbbbb-0000-0000-0000-000000000001', 'Sunrise Camp', 'Rishikesh',
             now() + interval '7 days', 'PUBLISHED',
             '44444444-4444-4444-4444-444444444444') $$,
  'C11.1 admin can create a published event'
);

select lives_ok(
  $$ insert into public.events (id, title, starts_at, status, created_by)
     values ('bbbbbbbb-0000-0000-0000-000000000002', 'Draft Workshop',
             now() + interval '14 days', 'DRAFT',
             '44444444-4444-4444-4444-444444444444') $$,
  'C11.2 admin can create a draft event'
);

select lives_ok(
  $$ insert into public.events (id, title, starts_at, capacity, status, created_by)
     values ('bbbbbbbb-0000-0000-0000-000000000003', 'Small Seminar',
             now() + interval '10 days', 1, 'PUBLISHED',
             '44444444-4444-4444-4444-444444444444') $$,
  'C11.3 admin can create a capacity-limited event'
);

-- ── 4. Student cannot create events ──────────────────────────────────────────
select pg_temp.act_as('11111111-1111-1111-1111-111111111111');
select throws_ok(
  $$ insert into public.events (title, starts_at)
     values ('Student event', now() + interval '1 day') $$,
  '42501',
  null,
  'C11.4 student cannot create events'
);

-- ── 5. Student sees published events ─────────────────────────────────────────
select is(
  (select count(*)::int from public.events
     where id in ('bbbbbbbb-0000-0000-0000-000000000001',
                  'bbbbbbbb-0000-0000-0000-000000000003')),
  2,
  'C11.5 student can see published events'
);

-- ── 6. Student cannot see draft events ───────────────────────────────────────
select is(
  (select count(*)::int from public.events
     where id = 'bbbbbbbb-0000-0000-0000-000000000002'),
  0,
  'C11.6 student cannot see draft events'
);

-- ── 7. Student registers for a published event ───────────────────────────────
select lives_ok(
  $$ insert into public.event_registrations (event_id, student_id)
     values ('bbbbbbbb-0000-0000-0000-000000000001',
             '11111111-1111-1111-1111-111111111111') $$,
  'C11.7 student can register for a published event'
);

-- ── 8. Student registers for the capacity-1 event (fills it) ─────────────────
select lives_ok(
  $$ insert into public.event_registrations (event_id, student_id)
     values ('bbbbbbbb-0000-0000-0000-000000000003',
             '11111111-1111-1111-1111-111111111111') $$,
  'C11.8 student can take the last seat of a limited event'
);

-- ── 9. A second student cannot register once full ────────────────────────────
select pg_temp.act_as('55555555-5555-5555-5555-555555555555');
select throws_ok(
  $$ insert into public.event_registrations (event_id, student_id)
     values ('bbbbbbbb-0000-0000-0000-000000000003',
             '55555555-5555-5555-5555-555555555555') $$,
  '42501',
  null,
  'C11.9 registration is blocked once an event is at capacity'
);

-- ── 10. Publishing events notified the student ───────────────────────────────
select pg_temp.act_as('11111111-1111-1111-1111-111111111111');
select is(
  (select count(*)::int from public.notifications
     where user_id = '11111111-1111-1111-1111-111111111111'
       and metadata->>'action' = 'event_published'),
  2,
  'C11.10 students are notified when events are published (2 published)'
);

select * from finish();
rollback;
