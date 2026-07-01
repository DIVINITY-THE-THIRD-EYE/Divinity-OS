-- c1_privileged_fields_test.sql  (pgTAP)
-- Run with:  supabase test db
--
-- Verifies FIX C1 (009_lock_privileged_fields.sql): a student cannot escalate
-- privileges by self-updating role / plan_status / lifecycle fields, while the
-- legitimate onboarding write and admin writes still succeed.
--
-- Fixtures are created as the postgres role (auth.uid() is null → trigger treats
-- it as a trusted server context, so fixture setup bypasses the lock). User
-- context is then simulated by setting request.jwt.claims + role authenticated.

begin;
select plan(7);

-- ── Fixtures ─────────────────────────────────────────────────────────────────
-- Inserting into auth.users fires handle_new_user(), which creates the matching
-- public.users row (role STUDENT by default). We then promote the admin.
insert into auth.users (id, email) values
  ('11111111-1111-1111-1111-111111111111', 'student.c1@test.local'),
  ('22222222-2222-2222-2222-222222222222', 'admin.c1@test.local');

update public.users set role = 'ADMIN'
  where id = '22222222-2222-2222-2222-222222222222';
-- Ensure the student starts from a known state.
update public.users
  set plan_status = 'UNPAID', onboarding_complete = false
  where id = '11111111-1111-1111-1111-111111111111';

-- ── Helper to act as a given user ────────────────────────────────────────────
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

-- ── Student attack attempts (must all be blocked) ────────────────────────────
select pg_temp.act_as('11111111-1111-1111-1111-111111111111');

select throws_ok(
  $$ update public.users set role = 'ADMIN'
       where id = '11111111-1111-1111-1111-111111111111' $$,
  '42501',
  null,
  'C1.1 student cannot self-promote to ADMIN'
);

select throws_ok(
  $$ update public.users set plan_status = 'ACTIVE'
       where id = '11111111-1111-1111-1111-111111111111' $$,
  '42501',
  null,
  'C1.2 student cannot self-activate plan (ACTIVE)'
);

select throws_ok(
  $$ update public.users set expiration_date = '2099-01-01'
       where id = '11111111-1111-1111-1111-111111111111' $$,
  '42501',
  null,
  'C1.3 student cannot set their own expiration_date'
);

-- ── Legitimate non-admin writes (must succeed) ───────────────────────────────
select lives_ok(
  $$ update public.users set plan_status = 'PENDING_ADMIN'
       where id = '11111111-1111-1111-1111-111111111111' $$,
  'C1.4 student CAN set own plan_status to PENDING_ADMIN (onboarding)'
);

select lives_ok(
  $$ update public.users set name = 'Renamed Student'
       where id = '11111111-1111-1111-1111-111111111111' $$,
  'C1.5 student CAN update non-privileged fields (name)'
);

-- ── Admin writes (must succeed) ──────────────────────────────────────────────
select pg_temp.act_as('22222222-2222-2222-2222-222222222222');

select lives_ok(
  $$ update public.users set role = 'TRAINER'
       where id = '11111111-1111-1111-1111-111111111111' $$,
  'C1.6 admin CAN change another user''s role'
);

select lives_ok(
  $$ update public.users set plan_status = 'ACTIVE', expiration_date = '2027-01-01'
       where id = '11111111-1111-1111-1111-111111111111' $$,
  'C1.7 admin CAN activate a plan'
);

select * from finish();
rollback;
