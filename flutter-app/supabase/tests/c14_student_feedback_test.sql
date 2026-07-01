-- c14_student_feedback_test.sql (pgTAP)
-- Run with: supabase test db

begin;
select plan(10);

-- ── Fixtures ─────────────────────────────────────────────────────────────────
insert into auth.users (id, email) values
  ('11111111-1111-1111-1111-111111111111', 'student1.c14@test.local'),
  ('22222222-2222-2222-2222-222222222222', 'student2.c14@test.local'),
  ('33333333-3333-3333-3333-333333333333', 'trainer1.c14@test.local'),
  ('44444444-4444-4444-4444-444444444444', 'trainer2.c14@test.local'),
  ('55555555-5555-5555-5555-555555555555', 'admin.c14@test.local');

update public.users set role = 'STUDENT' where id in ('11111111-1111-1111-1111-111111111111', '22222222-2222-2222-2222-222222222222');
update public.users set role = 'TRAINER' where id in ('33333333-3333-3333-3333-333333333333', '44444444-4444-4444-4444-444444444444');
update public.users set role = 'ADMIN' where id = '55555555-5555-5555-5555-555555555555';

insert into public.batches (id, name, trainer_id, schedule_time, capacity, location_lat, location_lng) values
  ('bbbbbbbb-1111-1111-1111-bbbbbbbbbbbb', 'Batch 1', '33333333-3333-3333-3333-333333333333', '06:00', 20, 12.9716, 77.5946),
  ('bbbbbbbb-2222-2222-2222-bbbbbbbbbbbb', 'Batch 2', '44444444-4444-4444-4444-444444444444', '07:00', 20, 12.9716, 77.5946);

insert into public.enrollments (student_id, batch_id) values
  ('11111111-1111-1111-1111-111111111111', 'bbbbbbbb-1111-1111-1111-bbbbbbbbbbbb'),
  ('22222222-2222-2222-2222-222222222222', 'bbbbbbbb-2222-2222-2222-bbbbbbbbbbbb');

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

-- ── Test 1: Student cannot submit feedback for batch they are not enrolled in ──
select pg_temp.act_as('11111111-1111-1111-1111-111111111111');

select throws_ok(
  $$ insert into public.student_feedback (student_id, trainer_id, batch_id, rating, comments)
     values ('11111111-1111-1111-1111-111111111111', '44444444-4444-4444-4444-444444444444', 'bbbbbbbb-2222-2222-2222-bbbbbbbbbbbb', 4, 'Great trainer!') $$,
  'new row violates row-level security policy for table "student_feedback"',
  'C14.1 student cannot submit feedback for a batch they are not enrolled in'
);

-- ── Test 2: Student can submit feedback for their own enrolled batch ───────────
select lives_ok(
  $$ insert into public.student_feedback (student_id, trainer_id, batch_id, rating, comments)
     values ('11111111-1111-1111-1111-111111111111', '33333333-3333-3333-3333-333333333333', 'bbbbbbbb-1111-1111-1111-bbbbbbbbbbbb', 5, 'Awesome session!') $$,
  'C14.2 student can submit feedback for enrolled batch'
);

-- ── Test 3: Student cannot submit feedback for other students ───────────────
select throws_ok(
  $$ insert into public.student_feedback (student_id, trainer_id, batch_id, rating, comments)
     values ('22222222-2222-2222-2222-222222222222', '33333333-3333-3333-3333-333333333333', 'bbbbbbbb-1111-1111-1111-bbbbbbbbbbbb', 5, 'Hijack attempt') $$,
  'new row violates row-level security policy for table "student_feedback"',
  'C14.3 student cannot submit feedback on behalf of other students'
);

-- ── Test 4: Rating constraints (1-5) ──────────────────────────────────────────
select throws_ok(
  $$ insert into public.student_feedback (student_id, trainer_id, batch_id, rating, comments)
     values ('11111111-1111-1111-1111-111111111111', '33333333-3333-3333-3333-333333333333', 'bbbbbbbb-1111-1111-1111-bbbbbbbbbbbb', 6, 'Invalid rating') $$,
  'new row for relation "student_feedback" violates check constraint "student_feedback_rating_check"',
  'C14.4 rating must not be greater than 5'
);

select throws_ok(
  $$ insert into public.student_feedback (student_id, trainer_id, batch_id, rating, comments)
     values ('11111111-1111-1111-1111-111111111111', '33333333-3333-3333-3333-333333333333', 'bbbbbbbb-1111-1111-1111-bbbbbbbbbbbb', 0, 'Invalid rating') $$,
  'new row for relation "student_feedback" violates check constraint "student_feedback_rating_check"',
  'C14.5 rating must not be less than 1'
);

-- ── Test 5: Student can select their own feedback ────────────────────────────
select ok(
  (select count(*)::int from public.student_feedback where student_id = '11111111-1111-1111-1111-111111111111') = 1,
  'C14.6 student can view their own feedback'
);

-- ── Test 6: Student cannot select other students'' feedback ───────────────────
-- Student 2 inserts feedback for Batch 2
select pg_temp.act_as('22222222-2222-2222-2222-222222222222');
insert into public.student_feedback (student_id, trainer_id, batch_id, rating, comments)
  values ('22222222-2222-2222-2222-222222222222', '44444444-4444-4444-4444-444444444444', 'bbbbbbbb-2222-2222-2222-bbbbbbbbbbbb', 4, 'Ok!');

select pg_temp.act_as('11111111-1111-1111-1111-111111111111');
select ok(
  (select count(*)::int from public.student_feedback) = 1,
  'C14.7 student can only see their own feedback (count should be 1, not 2)'
);

-- ── Test 7: Trainer can view feedback for their own assigned batches only ─────
select pg_temp.act_as('33333333-3333-3333-3333-333333333333');
select ok(
  (select count(*)::int from public.student_feedback) = 1,
  'C14.8 trainer 1 can only see 1 feedback (for batch 1)'
);

-- ── Test 8: Admin can view all feedback ──────────────────────────────────────
select pg_temp.act_as('55555555-5555-5555-5555-555555555555');
select ok(
  (select count(*)::int from public.student_feedback) = 2,
  'C14.9 admin can view all feedback (2 entries)'
);

-- ── Test 9: Admin can delete feedback ────────────────────────────────────────
select lives_ok(
  $$ delete from public.student_feedback where student_id = '11111111-1111-1111-1111-111111111111' $$,
  'C14.10 admin can delete feedback'
);

select * from finish();
rollback;
