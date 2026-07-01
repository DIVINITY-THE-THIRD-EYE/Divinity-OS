-- c2_geofence_test.sql  (pgTAP)
-- Run with:  supabase test db
--
-- Verifies FIX C2 (010_attendance_geofence_rpc.sql):
--   * the direct student INSERT path on attendance is gone
--   * check_in() enforces the geofence server-side
--   * check_in() forces marked_by='STUDENT' and student_id=auth.uid()
--   * check-ins outside the radius and into non-enrolled batches are rejected
--
-- Geofence fixture: batch at Butler Colony, Lucknow (26.8467, 80.9462), 100 m.

begin;
select plan(6);

-- ── Fixtures ─────────────────────────────────────────────────────────────────
insert into auth.users (id, email) values
  ('33333333-3333-3333-3333-333333333333', 'student.c2@test.local'),
  ('44444444-4444-4444-4444-444444444444', 'trainer.c2@test.local');

update public.users set role = 'TRAINER'
  where id = '44444444-4444-4444-4444-444444444444';

-- Two batches: one the student is enrolled in (with a geofence), one they are not.
insert into public.batches
  (id, name, schedule_time, location_lat, location_lng, radius_meters)
values
  ('aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa', 'Morning Hatha', '06:00',
   26.8467, 80.9462, 100),
  ('bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb', 'Evening Power', '18:00',
   26.8467, 80.9462, 100);

insert into public.enrollments (student_id, batch_id) values
  ('33333333-3333-3333-3333-333333333333',
   'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa');

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

select pg_temp.act_as('33333333-3333-3333-3333-333333333333');

-- ── C2.1 direct student INSERT is now blocked (policy removed) ────────────────
select throws_ok(
  $$ insert into public.attendance (student_id, date, status, marked_by)
     values ('33333333-3333-3333-3333-333333333333', current_date, 'PRESENT', 'STUDENT') $$,
  '42501',
  null,
  'C2.1 direct student INSERT into attendance is denied by RLS'
);

-- ── C2.2 check_in within the geofence succeeds ───────────────────────────────
select lives_ok(
  $$ select public.check_in(26.8467, 80.9462,
       'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa') $$,
  'C2.2 check_in inside radius succeeds'
);

-- ── C2.3 the resulting row is PRESENT and marked_by STUDENT ───────────────────
select is(
  (select status || '/' || marked_by from public.attendance
   where student_id = '33333333-3333-3333-3333-333333333333'
     and date = (now() at time zone 'Asia/Kolkata')::date),
  'PRESENT/STUDENT',
  'C2.3 check_in writes PRESENT and forces marked_by=STUDENT'
);

-- ── C2.4 check_in outside the radius is rejected ─────────────────────────────
-- ~7 km away (26.90, 81.00) — well beyond 100 m.
select throws_ok(
  $$ select public.check_in(26.9000, 81.0000,
       'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa') $$,
  '42501',
  null,
  'C2.4 check_in outside radius is rejected'
);

-- ── C2.5 check_in into a non-enrolled batch is rejected ──────────────────────
select throws_ok(
  $$ select public.check_in(26.8467, 80.9462,
       'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb') $$,
  '42501',
  null,
  'C2.5 check_in into a batch the student is not enrolled in is rejected'
);

-- ── C2.6 a student cannot forge a check-in for another student ───────────────
-- The RPC ignores any client-supplied student id and uses auth.uid(); verify no
-- row was created for the trainer's id by the student's calls above.
select is(
  (select count(*)::int from public.attendance
   where student_id = '44444444-4444-4444-4444-444444444444'),
  0,
  'C2.6 check_in never writes attendance for a different user'
);

select * from finish();
rollback;
