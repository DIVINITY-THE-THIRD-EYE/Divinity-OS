-- c19_trials_and_lead_conversion_test.sql  (pgTAP)
-- Run with:  supabase test db
--
-- Verifies 041_trials_and_lead_conversion.sql:
--   * Trainer (not just Admin) can record + read trial_attendances; a
--     regular student cannot.
--   * Trainer can now see leads and call convert_lead_to_member(); a
--     regular student still cannot.
--   * self_convert_lead() lets a newly-signed-up user link their own
--     matching lead by phone/email without touching plan_status (unlike
--     staff conversion, which sets PENDING_ADMIN).

begin;
select plan(10);

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

-- ── Fixtures ─────────────────────────────────────────────────────────────────
insert into auth.users (id, email, phone) values
  ('11111111-9999-1111-1111-111111111111', 'admin.c19@test.local', null),
  ('22222222-9999-2222-2222-222222222222', 'trainer.c19@test.local', null),
  ('33333333-9999-3333-3333-333333333333', 'student.c19@test.local', null),
  ('44444444-9999-4444-4444-444444444444', 'convertee.c19@test.local', null),
  ('55555555-9999-5555-5555-555555555555', 'selfserve.c19@test.local', '+911234567890');

update public.users set role = 'ADMIN' where id = '11111111-9999-1111-1111-111111111111';
update public.users set role = 'TRAINER' where id = '22222222-9999-2222-2222-222222222222';

insert into public.leads (id, name, phone, pipeline_status)
values ('66666666-9999-1111-1111-111111111111', 'C19 Trial Lead', '+919000000001', 'CONSULTATION');

insert into public.leads (id, name, phone, pipeline_status)
values ('66666666-9999-2222-2222-222222222222', 'C19 Self-Serve Lead', '+911234567890', 'NEW');

-- ── C19.1-3: trial_attendances — Trainer can write/read, Student cannot ─────
select pg_temp.act_as('22222222-9999-2222-2222-222222222222');

select lives_ok(
  format(
    $$ insert into public.trial_attendances (lead_id, marked_by) values (%L, %L) $$,
    '66666666-9999-1111-1111-111111111111', '22222222-9999-2222-2222-222222222222'
  ),
  'C19.1 Trainer can record a trial attendance'
);

select is(
  (select count(*)::int from public.trial_attendances
   where lead_id = '66666666-9999-1111-1111-111111111111'),
  1,
  'C19.2 Trainer can read the trial attendance back'
);

select pg_temp.act_as('33333333-9999-3333-3333-333333333333');

select throws_ok(
  format(
    $$ insert into public.trial_attendances (lead_id, marked_by) values (%L, %L) $$,
    '66666666-9999-1111-1111-111111111111', '33333333-9999-3333-3333-333333333333'
  ),
  '42501',
  null,
  'C19.3 a regular student cannot record a trial attendance'
);

-- ── C19.4-5: leads visibility + conversion — Trainer allowed ────────────────
select pg_temp.act_as('22222222-9999-2222-2222-222222222222');

select is(
  (select count(*)::int from public.leads where id = '66666666-9999-1111-1111-111111111111'),
  1,
  'C19.4 Trainer can now see leads (previously Admin-only)'
);

select lives_ok(
  format(
    $$ select public.convert_lead_to_member(%L, %L) $$,
    '66666666-9999-1111-1111-111111111111', '44444444-9999-4444-4444-444444444444'
  ),
  'C19.5 Trainer can convert a lead to a member'
);

select is(
  (select pipeline_status from public.leads where id = '66666666-9999-1111-1111-111111111111'),
  'ADMITTED',
  'C19.6 the lead is marked ADMITTED after Trainer conversion'
);

-- ── C19.7: a regular student still cannot convert a lead ────────────────────
select pg_temp.act_as('33333333-9999-3333-3333-333333333333');

select throws_ok(
  format(
    $$ select public.convert_lead_to_member(%L, %L) $$,
    '66666666-9999-2222-2222-222222222222', '33333333-9999-3333-3333-333333333333'
  ),
  '42501',
  null,
  'C19.7 a regular student cannot call convert_lead_to_member'
);

-- ── C19.8-10: self_convert_lead — matches by phone, doesn't touch plan_status ─
select pg_temp.act_as('55555555-9999-5555-5555-555555555555');

select is(
  (select (public.self_convert_lead()).pipeline_status),
  'ADMITTED',
  'C19.8 self_convert_lead admits the caller''s own phone-matching lead'
);

-- Re-check as Admin: the self-service caller has no SELECT policy on leads
-- (by design — the RPC's own return value is their only visibility).
select pg_temp.act_as('11111111-9999-1111-1111-111111111111');

select is(
  (select converted_user_id from public.leads where id = '66666666-9999-2222-2222-222222222222'),
  '55555555-9999-5555-5555-555555555555'::uuid,
  'C19.9 the lead is linked to the calling user'
);

select is(
  (select plan_status from public.users where id = '55555555-9999-5555-5555-555555555555'),
  'UNPAID',
  'C19.10 self-service conversion does not touch plan_status (unlike staff conversion)'
);

select * from finish();
rollback;
