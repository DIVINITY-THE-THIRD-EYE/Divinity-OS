-- c13_trainer_active_status_test.sql  (pgTAP)
-- Run with:  supabase test db
--
-- Verifies migration 032 (032_trainer_active_status.sql): only an admin can
-- change `is_active`; a trainer cannot re-activate their own deactivated
-- account via the "users_update_own" RLS policy.

begin;
select plan(4);

-- ── Fixtures ─────────────────────────────────────────────────────────────────
insert into auth.users (id, email) values
  ('33333333-3333-3333-3333-333333333333', 'trainer.c13@test.local'),
  ('44444444-4444-4444-4444-444444444444', 'admin.c13@test.local');

update public.users set role = 'TRAINER'
  where id = '33333333-3333-3333-3333-333333333333';
update public.users set role = 'ADMIN'
  where id = '44444444-4444-4444-4444-444444444444';

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

-- ── New trainer defaults to active ───────────────────────────────────────────
select ok(
  (select is_active from public.users
     where id = '33333333-3333-3333-3333-333333333333') = true,
  'C13.1 new trainer defaults to is_active = true'
);

-- ── Admin can deactivate a trainer ───────────────────────────────────────────
select pg_temp.act_as('44444444-4444-4444-4444-444444444444');

select lives_ok(
  $$ update public.users set is_active = false
       where id = '33333333-3333-3333-3333-333333333333' $$,
  'C13.2 admin CAN deactivate a trainer'
);

-- ── Trainer cannot self-reactivate ───────────────────────────────────────────
select pg_temp.act_as('33333333-3333-3333-3333-333333333333');

select throws_ok(
  $$ update public.users set is_active = true
       where id = '33333333-3333-3333-3333-333333333333' $$,
  '42501',
  null,
  'C13.3 deactivated trainer cannot self-reactivate'
);

-- ── Admin can reactivate ─────────────────────────────────────────────────────
select pg_temp.act_as('44444444-4444-4444-4444-444444444444');

select lives_ok(
  $$ update public.users set is_active = true
       where id = '33333333-3333-3333-3333-333333333333' $$,
  'C13.4 admin CAN reactivate a trainer'
);

select * from finish();
rollback;
