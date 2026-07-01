-- c5_latches_test.sql  (pgTAP)
-- Run with:  supabase test db
--
-- Verifies FIX C7 (R2/R3) (019_email_onboarding_latches.sql):
--   * A student cannot modify their email after it is set.
--   * A student cannot set onboarding_complete from true back to false.
--   * An admin can perform both updates.

begin;
select plan(4);

-- ── Fixtures ─────────────────────────────────────────────────────────────────
insert into auth.users (id, email) values
  ('77777777-7777-7777-7777-777777777777', 'student.c5@test.local'),
  ('88888888-8888-8888-8888-888888888888', 'admin.c5@test.local');

update public.users set role = 'ADMIN' where id = '88888888-8888-8888-8888-888888888888';

-- Setup student as onboarding completed
update public.users
  set email = 'student.c5@test.local', onboarding_complete = true
  where id = '77777777-7777-7777-7777-777777777777';

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

-- ── 1. Act as Student (untrusted) ─────────────────────────────────────────────
select pg_temp.act_as('77777777-7777-7777-7777-777777777777');

-- Try to update email (must throw)
select throws_ok(
  $$ update public.users set email = 'hacker.c5@test.local'
       where id = '77777777-7777-7777-7777-777777777777' $$,
  '42501',
  null,
  'C5.1 student cannot modify their email'
);

-- Try to reset onboarding_complete to false (must throw)
select throws_ok(
  $$ update public.users set onboarding_complete = false
       where id = '77777777-7777-7777-7777-777777777777' $$,
  '42501',
  null,
  'C5.2 student cannot reset onboarding_complete to false'
);

-- ── 2. Act as Admin (trusted) ─────────────────────────────────────────────────
select pg_temp.act_as('88888888-8888-8888-8888-888888888888');

-- Try to update student's email as admin (must succeed)
select lives_ok(
  $$ update public.users set email = 'student.new.c5@test.local'
       where id = '77777777-7777-7777-7777-777777777777' $$,
  'C5.3 admin can update student''s email'
);

-- Try to reset student's onboarding_complete as admin (must succeed)
select lives_ok(
  $$ update public.users set onboarding_complete = false
       where id = '77777777-7777-7777-7777-777777777777' $$,
  'C5.4 admin can reset student''s onboarding_complete'
);

select * from finish();
rollback;
