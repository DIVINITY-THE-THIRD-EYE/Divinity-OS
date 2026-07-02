-- c12_reports_test.sql (pgTAP)
-- Run with:  supabase test db
--
-- Verifies reports-related security boundaries, role permissions, and access logs:
--   - Trainer can read all payments (needed for trainer payment reports)
--   - Student cannot read other students' payments (RLS)
--   - Student cannot read other students' attendance (RLS)
--   - Trainer can read all student attendance (RLS)
--   - Admin can read everything
-- ─────────────────────────────────────────────────────────────────────────────

begin;
select plan(10);

-- ── Fixtures ─────────────────────────────────────────────────────────────────
insert into auth.users (id, email) values
  ('11111111-1111-1111-1111-111111111111', 'student1.c12@test.local'),
  ('22222222-2222-2222-2222-222222222222', 'student2.c12@test.local'),
  ('33333333-3333-3333-3333-333333333333', 'trainer.c12@test.local'),
  ('44444444-4444-4444-4444-444444444444', 'admin.c12@test.local');

update public.users set role = 'STUDENT' where id in ('11111111-1111-1111-1111-111111111111', '22222222-2222-2222-2222-222222222222');
update public.users set role = 'TRAINER' where id = '33333333-3333-3333-3333-333333333333';
update public.users set role = 'ADMIN'   where id = '44444444-4444-4444-4444-444444444444';

-- Insert a test payment record
insert into public.payments (student_id, amount, status, payment_method)
values ('11111111-1111-1111-1111-111111111111', 5000.00, 'PAID', 'UPI');

-- Insert a test attendance record
insert into public.attendance (student_id, date, status, marked_by)
values ('11111111-1111-1111-1111-111111111111', '2026-06-01', 'PRESENT', 'TRAINER');

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

-- ── Test 1: Student can read their own payment ───────────────────────────────
select pg_temp.act_as('11111111-1111-1111-1111-111111111111');
select is(
  (select count(*)::int from public.payments where student_id = '11111111-1111-1111-1111-111111111111'),
  1,
  'C12.1 Student can read their own payment records'
);

-- ── Test 2: Student cannot read other student's payment (RLS) ────────────────
select pg_temp.act_as('22222222-2222-2222-2222-222222222222');
select is(
  (select count(*)::int from public.payments where student_id = '11111111-1111-1111-1111-111111111111'),
  0,
  'C12.2 Student cannot read another student''s payment record'
);

-- ── Test 3: Trainer can read all payments (for reports) ──────────────────────
select pg_temp.act_as('33333333-3333-3333-3333-333333333333');
select is(
  (select count(*)::int from public.payments where student_id = '11111111-1111-1111-1111-111111111111'),
  1,
  'C12.3 Trainer can read student payment records'
);

-- ── Test 4: Student can read their own attendance ───────────────────────────
select pg_temp.act_as('11111111-1111-1111-1111-111111111111');
select is(
  (select count(*)::int from public.attendance where student_id = '11111111-1111-1111-1111-111111111111'),
  1,
  'C12.4 Student can read their own attendance'
);

-- ── Test 5: Student cannot read other student's attendance ──────────────────
select pg_temp.act_as('22222222-2222-2222-2222-222222222222');
select is(
  (select count(*)::int from public.attendance where student_id = '11111111-1111-1111-1111-111111111111'),
  0,
  'C12.5 Student cannot read another student''s attendance record'
);

-- ── Test 6: Trainer can read student attendance ──────────────────────────────
select pg_temp.act_as('33333333-3333-3333-3333-333333333333');
select is(
  (select count(*)::int from public.attendance where student_id = '11111111-1111-1111-1111-111111111111'),
  1,
  'C12.6 Trainer can read student attendance records'
);

-- ── Test 7: Admin can read all payments ──────────────────────────────────────
select pg_temp.act_as('44444444-4444-4444-4444-444444444444');
select is(
  (select count(*)::int from public.payments where student_id = '11111111-1111-1111-1111-111111111111'),
  1,
  'C12.7 Admin can read any student payment records'
);
-- ── Test 8: Student cannot run get_reports_data ───────────────────────────────
select pg_temp.act_as('11111111-1111-1111-1111-111111111111');
select throws_ok(
  $$ select public.get_reports_data() $$,
  '42501',
  null,
  'C12.8 Student is blocked from calling get_reports_data'
);

-- ── Test 9: Trainer can run get_reports_data (044_trainer_surfaces.sql
--    opened this up, forced-scoped to the trainer's own data — see c22
--    for the scoping assertions) ────────────────────────────────────────────
select pg_temp.act_as('33333333-3333-3333-3333-333333333333');
select lives_ok(
  $$ select public.get_reports_data() $$,
  'C12.9 Trainer can call get_reports_data (scoped to their own batches)'
);

-- ── Test 10: Admin can run get_reports_data ──────────────────────────────────
select pg_temp.act_as('44444444-4444-4444-4444-444444444444');
select lives_ok(
  $$ select public.get_reports_data() $$,
  'C12.10 Admin can successfully call get_reports_data'
);

select * from finish();
rollback;
