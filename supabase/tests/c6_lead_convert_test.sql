-- c6_lead_convert_test.sql (pgTAP)
-- Run with:  supabase test db
--
-- Verifies FIX C4 (NEW-2) (020_convert_lead_to_member_rpc.sql):
--   - A student cannot call convert_lead_to_member.
--   - An admin can call convert_lead_to_member to atomically update lead and user.
--   - Non-existent lead or user throws an exception and rolls back.

begin;
select plan(5);

-- ── Fixtures ─────────────────────────────────────────────────────────────────
insert into auth.users (id, email) values
  ('11111111-1111-1111-1111-111111111111', 'student.c6@test.local'),
  ('22222222-2222-2222-2222-222222222222', 'admin.c6@test.local'),
  ('33333333-3333-3333-3333-333333333333', 'target.c6@test.local');

-- Update roles
update public.users set role = 'ADMIN' where id = '22222222-2222-2222-2222-222222222222';
update public.users set role = 'STUDENT', plan_status = 'UNPAID' where id = '33333333-3333-3333-3333-333333333333';

-- Insert a lead
insert into public.leads (id, name, phone, email, source, pipeline_status, created_by) values
  ('99999999-9999-9999-9999-999999999999', 'Lead Number Six', '9999999999', 'lead6@test.local', 'WALK_IN', 'NEW', '22222222-2222-2222-2222-222222222222');

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
select pg_temp.act_as('11111111-1111-1111-1111-111111111111');

-- Try to call RPC (must throw 42501)
select throws_ok(
  $$ select public.convert_lead_to_member(
       '99999999-9999-9999-9999-999999999999'::uuid,
       '33333333-3333-3333-3333-333333333333'::uuid
     ) $$,
  '42501',
  'only admin or trainer staff can convert leads',
  'C6.1 student cannot call convert_lead_to_member'
);

-- ── 2. Act as Admin (trusted) ─────────────────────────────────────────────────
select pg_temp.act_as('22222222-2222-2222-2222-222222222222');

-- Try to call RPC for non-existent lead (must throw no_data_found)
select throws_ok(
  $$ select public.convert_lead_to_member(
       'deadbeef-dead-beef-dead-beefdeadbeef'::uuid,
       '33333333-3333-3333-3333-333333333333'::uuid
     ) $$,
  'P0002',
  'lead not found',
  'C6.2 admin calling with invalid lead ID throws lead not found'
);

-- Try to call RPC for non-existent user (must throw no_data_found)
select throws_ok(
  $$ select public.convert_lead_to_member(
       '99999999-9999-9999-9999-999999999999'::uuid,
       'deadbeef-dead-beef-dead-beefdeadbeef'::uuid
     ) $$,
  'P0002',
  'user not found',
  'C6.3 admin calling with invalid user ID throws user not found'
);

-- Try to call RPC with valid lead and user (must succeed)
select lives_ok(
  $$ select public.convert_lead_to_member(
       '99999999-9999-9999-9999-999999999999'::uuid,
       '33333333-3333-3333-3333-333333333333'::uuid
     ) $$,
  'C6.4 admin successfully converts lead to member'
);

-- Verify database state is updated correctly
select results_eq(
  $$ select pipeline_status, converted_user_id from public.leads where id = '99999999-9999-9999-9999-999999999999' $$,
  $$ values ('ADMITTED'::text, '33333333-3333-3333-3333-333333333333'::uuid) $$,
  'C6.5 lead pipeline_status is ADMITTED and converted_user_id is set'
);

select * from finish();
rollback;
