-- c16_enrollment_concurrency_test.sql (pgTAP)
-- Run with:  supabase test db
--
-- Verifies that batch enrollment capacity constraints cannot be bypassed.
-- ─────────────────────────────────────────────────────────────────────────────

begin;
select plan(3);

-- ── Setup Fixtures ───────────────────────────────────────────────────────────
insert into auth.users (id, email) values
  ('11111111-1111-1111-1111-111111111111', 'student1.c16@test.local'),
  ('22222222-2222-2222-2222-222222222222', 'student2.c16@test.local'),
  ('33333333-3333-3333-3333-333333333333', 'student3.c16@test.local'),
  ('44444444-4444-4444-4444-444444444444', 'admin.c16@test.local');

update public.users set role = 'STUDENT' where id in ('11111111-1111-1111-1111-111111111111', '22222222-2222-2222-2222-222222222222', '33333333-3333-3333-3333-333333333333');
update public.users set role = 'ADMIN' where id = '44444444-4444-4444-4444-444444444444';

-- Insert a batch with capacity 2. location_lat/location_lng are required by
-- the batches_coordinates_required check constraint (migration 016).
insert into public.batches (id, name, schedule_time, capacity, status, location_lat, location_lng)
values ('aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa', 'Limited Yoga Batch', '08:00', 2, 'ACTIVE', 26.8467, 80.9462);

-- Helper to act as admin
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

select pg_temp.act_as('44444444-4444-4444-4444-444444444444');

-- Test 1: First enrollment insertion succeeds
select lives_ok(
  $$ insert into public.enrollments (student_id, batch_id) values ('11111111-1111-1111-1111-111111111111', 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa') $$,
  'C16.1 First enrollment succeeds'
);

-- Test 2: Second enrollment insertion succeeds
select lives_ok(
  $$ insert into public.enrollments (student_id, batch_id) values ('22222222-2222-2222-2222-222222222222', 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa') $$,
  'C16.2 Second enrollment succeeds'
);

-- Test 3: Third enrollment insertion throws exception since capacity is 2
select throws_ok(
  $$ insert into public.enrollments (student_id, batch_id) values ('33333333-3333-3333-3333-333333333333', 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa') $$,
  '23514',
  null,
  'C16.3 Third enrollment fails because batch is at capacity'
);

select * from finish();
rollback;
