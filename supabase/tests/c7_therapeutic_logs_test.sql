-- c7_therapeutic_logs_test.sql (pgTAP)
-- Run with:  supabase test db
--
-- Verifies FIX R4 (021_therapeutic_logs_rls.sql):
--   - A trainer can only insert logs where trainer_id = their own ID.
--   - An admin can insert logs for any trainer.
--   - A student cannot insert therapeutic logs.

begin;
select plan(5);

-- ── Fixtures ─────────────────────────────────────────────────────────────────
insert into auth.users (id, email) values
  ('11111111-1111-1111-1111-111111111111', 'student.c7@test.local'),
  ('22222222-2222-2222-2222-222222222222', 'trainer1.c7@test.local'),
  ('33333333-3333-3333-3333-333333333333', 'trainer2.c7@test.local'),
  ('44444444-4444-4444-4444-444444444444', 'admin.c7@test.local');

-- Update roles
update public.users set role = 'STUDENT' where id = '11111111-1111-1111-1111-111111111111';
update public.users set role = 'TRAINER' where id = '22222222-2222-2222-2222-222222222222';
update public.users set role = 'TRAINER' where id = '33333333-3333-3333-3333-333333333333';
update public.users set role = 'ADMIN' where id = '44444444-4444-4444-4444-444444444444';

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

-- ── 1. Act as Student ────────────────────────────────────────────────────────
select pg_temp.act_as('11111111-1111-1111-1111-111111111111');

-- Trying to insert a log (must throw RLS error 42501)
select throws_ok(
  $$ insert into public.therapeutic_logs (student_id, trainer_id, note)
     values ('11111111-1111-1111-1111-111111111111', '22222222-2222-2222-2222-222222222222', 'Test student log') $$,
  '42501',
  null,
  'C7.1 student cannot insert therapeutic logs'
);

-- ── 2. Act as Trainer 1 ──────────────────────────────────────────────────────
select pg_temp.act_as('22222222-2222-2222-2222-222222222222');

-- Inserting own log (must succeed)
select lives_ok(
  $$ insert into public.therapeutic_logs (student_id, trainer_id, note)
     values ('11111111-1111-1111-1111-111111111111', '22222222-2222-2222-2222-222222222222', 'Trainer 1 note') $$,
  'C7.2 trainer can insert logs with their own trainer_id'
);

-- Inserting log with other trainer's ID (must throw RLS error 42501)
select throws_ok(
  $$ insert into public.therapeutic_logs (student_id, trainer_id, note)
     values ('11111111-1111-1111-1111-111111111111', '33333333-3333-3333-3333-333333333333', 'Trainer 2 note by Trainer 1') $$,
  '42501',
  null,
  'C7.3 trainer cannot spoof trainer_id to another trainer'
);

-- ── 3. Act as Admin ──────────────────────────────────────────────────────────
select pg_temp.act_as('44444444-4444-4444-4444-444444444444');

-- Inserting log for Trainer 2 as admin (must succeed)
select lives_ok(
  $$ insert into public.therapeutic_logs (student_id, trainer_id, note)
     values ('11111111-1111-1111-1111-111111111111', '33333333-3333-3333-3333-333333333333', 'Trainer 2 note by Admin') $$,
  'C7.4 admin can insert logs for any trainer'
);

-- ── 4. Verify log update policy (Fix C6 check) ───────────────────────────────
select pg_temp.act_as('22222222-2222-2222-2222-222222222222');

-- Trainer 1 tries to update Trainer 2's note (should do nothing / update 0 rows)
update public.therapeutic_logs set note = 'Modified'
  where trainer_id = '33333333-3333-3333-3333-333333333333';

-- Assert that the note is NOT 'Modified'
select is(
  (select note from public.therapeutic_logs where trainer_id = '33333333-3333-3333-3333-333333333333' limit 1),
  'Trainer 2 note by Admin'::text,
  'C7.5 trainer cannot update log of another trainer (note remains unchanged)'
);

select * from finish();
rollback;
