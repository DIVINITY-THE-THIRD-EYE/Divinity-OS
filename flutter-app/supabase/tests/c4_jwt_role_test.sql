-- c4_jwt_role_test.sql  (pgTAP)
-- Run with:  supabase test db
--
-- Verifies FIX H3 (017_jwt_role_app_metadata.sql):
--   * Changing role in public.users syncs to auth.users.raw_app_meta_data.
--   * is_admin(), is_trainer(), is_trainer_or_admin() correctly check the JWT claims
--     when queried for the currently logged-in user.

begin;
select plan(7);

-- ── Fixtures ─────────────────────────────────────────────────────────────────
insert into auth.users (id, email) values
  ('66666666-6666-6666-6666-666666666666', 'user.c4@test.local');

-- User starts as STUDENT by default in public.users
select is(
  (select role from public.users where id = '66666666-6666-6666-6666-666666666666'),
  'STUDENT',
  'C4.1 user role starts as STUDENT in public.users'
);

-- Check that it is synced to auth.users app_metadata
select is(
  (select raw_app_meta_data ->> 'role' from auth.users where id = '66666666-6666-6666-6666-666666666666'),
  'STUDENT',
  'C4.2 role STUDENT is synced to auth.users.raw_app_meta_data'
);

-- Update role to ADMIN (in trusted context, bypassing lock)
update public.users set role = 'ADMIN' where id = '66666666-6666-6666-6666-666666666666';

-- Check that the update is synced
select is(
  (select raw_app_meta_data ->> 'role' from auth.users where id = '66666666-6666-6666-6666-666666666666'),
  'ADMIN',
  'C4.3 updated role ADMIN is synced to auth.users'
);

-- ── Test helper functions using simulated JWT ───────────────────────────────
create or replace function pg_temp.act_as(uid uuid, role_claim text) returns void
language plpgsql as $$
begin
  perform set_config('role', 'authenticated', true);
  perform set_config(
    'request.jwt.claims',
    json_build_object(
      'sub', uid::text,
      'role', 'authenticated',
      'app_metadata', json_build_object('role', role_claim)
    )::text,
    true
  );
end; $$;

-- 1. Act as ADMIN
select pg_temp.act_as('66666666-6666-6666-6666-666666666666', 'ADMIN');

select is(
  public.is_admin('66666666-6666-6666-6666-666666666666'),
  true,
  'C4.4 is_admin returns true when JWT app_metadata role is ADMIN'
);

select is(
  public.is_trainer_or_admin('66666666-6666-6666-6666-666666666666'),
  true,
  'C4.5 is_trainer_or_admin returns true when JWT app_metadata role is ADMIN'
);

-- 2. Act as TRAINER
select pg_temp.act_as('66666666-6666-6666-6666-666666666666', 'TRAINER');

select is(
  public.is_trainer('66666666-6666-6666-6666-666666666666'),
  true,
  'C4.6 is_trainer returns true when JWT app_metadata role is TRAINER'
);

select is(
  public.is_admin('66666666-6666-6666-6666-666666666666'),
  false,
  'C4.7 is_admin returns false when JWT app_metadata role is TRAINER'
);

select * from finish();
rollback;
