-- c10_workouts_test.sql (pgTAP)
-- Run with:  supabase test db
--
-- Verifies Module 9 (026_workouts.sql):
--   - A trainer can create workouts they own but cannot spoof trainer_id.
--   - A student cannot create workouts.
--   - Assigning a workout to a batch notifies enrolled students.
--   - A student sees only workouts assigned to a batch they are enrolled in.
--   - A student can complete their own assignments but not others' batches.

begin;
select plan(9);

-- ── Fixtures ─────────────────────────────────────────────────────────────────
insert into auth.users (id, email) values
  ('11111111-1111-1111-1111-111111111111', 'student1.c10@test.local'),
  ('55555555-5555-5555-5555-555555555555', 'student2.c10@test.local'),
  ('22222222-2222-2222-2222-222222222222', 'trainer1.c10@test.local'),
  ('44444444-4444-4444-4444-444444444444', 'admin.c10@test.local');

update public.users set role = 'STUDENT' where id = '11111111-1111-1111-1111-111111111111';
update public.users set role = 'STUDENT' where id = '55555555-5555-5555-5555-555555555555';
update public.users set role = 'TRAINER' where id = '22222222-2222-2222-2222-222222222222';
update public.users set role = 'ADMIN'   where id = '44444444-4444-4444-4444-444444444444';

-- Batch + enrollment (created as the test superuser, bypassing RLS).
-- Coordinates are required since migration 016 (batches_coordinates_required).
insert into public.batches (id, name, trainer_id, schedule_time, days_of_week,
                            capacity, status, location_lat, location_lng)
values ('aaaaaaaa-0000-0000-0000-000000000001', 'Morning Flow',
        '22222222-2222-2222-2222-222222222222', '06:00', '{MON,WED,FRI}', 20,
        'ACTIVE', 19.0760, 72.8777);

insert into public.enrollments (student_id, batch_id)
values ('11111111-1111-1111-1111-111111111111', 'aaaaaaaa-0000-0000-0000-000000000001');

-- ── Helper to act as user ────────────────────────────────────────────────────
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

-- ── 1. Trainer creates own workout ───────────────────────────────────────────
select pg_temp.act_as('22222222-2222-2222-2222-222222222222');

select lives_ok(
  $$ insert into public.workouts (id, trainer_id, title, description)
     values ('bbbbbbbb-0000-0000-0000-000000000001',
             '22222222-2222-2222-2222-222222222222',
             'Core & Breath', 'Foundational core sequence') $$,
  'C10.1 trainer can create a workout they own'
);

-- ── 2. Trainer cannot spoof trainer_id ───────────────────────────────────────
select throws_ok(
  $$ insert into public.workouts (trainer_id, title)
     values ('44444444-4444-4444-4444-444444444444', 'Spoofed') $$,
  '42501',
  null,
  'C10.2 trainer cannot create a workout owned by another user'
);

-- ── 3. Student cannot create workouts ────────────────────────────────────────
select pg_temp.act_as('11111111-1111-1111-1111-111111111111');
select throws_ok(
  $$ insert into public.workouts (trainer_id, title)
     values ('11111111-1111-1111-1111-111111111111', 'Student workout') $$,
  '42501',
  null,
  'C10.3 student cannot create workouts'
);

-- ── 4. Trainer assigns workout to their batch ────────────────────────────────
select pg_temp.act_as('22222222-2222-2222-2222-222222222222');
select lives_ok(
  $$ insert into public.workout_assignments (id, workout_id, batch_id, assigned_by)
     values ('cccccccc-0000-0000-0000-000000000001',
             'bbbbbbbb-0000-0000-0000-000000000001',
             'aaaaaaaa-0000-0000-0000-000000000001',
             '22222222-2222-2222-2222-222222222222') $$,
  'C10.4 trainer can assign their workout to a batch'
);

-- ── 5. Enrolled student received a notification ──────────────────────────────
select pg_temp.act_as('11111111-1111-1111-1111-111111111111');
select is(
  (select count(*)::int from public.notifications
     where user_id = '11111111-1111-1111-1111-111111111111'
       and metadata->>'action' = 'workout_assigned'),
  1,
  'C10.5 enrolled student is notified when a workout is assigned'
);

-- ── 6. Enrolled student sees the assigned workout ────────────────────────────
select is(
  (select count(*)::int from public.workouts
     where id = 'bbbbbbbb-0000-0000-0000-000000000001'),
  1,
  'C10.6 enrolled student can see a workout assigned to their batch'
);

-- ── 7. Non-enrolled student cannot see the workout ───────────────────────────
select pg_temp.act_as('55555555-5555-5555-5555-555555555555');
select is(
  (select count(*)::int from public.workouts
     where id = 'bbbbbbbb-0000-0000-0000-000000000001'),
  0,
  'C10.7 a student not enrolled in the batch cannot see the workout'
);

-- ── 8. Enrolled student can complete the assignment ──────────────────────────
select pg_temp.act_as('11111111-1111-1111-1111-111111111111');
select lives_ok(
  $$ insert into public.workout_completions (assignment_id, student_id, notes)
     values ('cccccccc-0000-0000-0000-000000000001',
             '11111111-1111-1111-1111-111111111111', 'Done, felt great') $$,
  'C10.8 enrolled student can complete their assigned workout'
);

-- ── 9. Non-enrolled student cannot complete the assignment ───────────────────
select pg_temp.act_as('55555555-5555-5555-5555-555555555555');
select throws_ok(
  $$ insert into public.workout_completions (assignment_id, student_id)
     values ('cccccccc-0000-0000-0000-000000000001',
             '55555555-5555-5555-5555-555555555555') $$,
  '42501',
  null,
  'C10.9 a student not enrolled in the batch cannot complete the workout'
);

select * from finish();
rollback;
