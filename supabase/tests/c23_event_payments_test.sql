-- c23_event_payments_test.sql  (pgTAP)
-- Run with:  supabase test db
--
-- Verifies 045_event_payments.sql:
--   * A paid event requires a price > 0.
--   * A student cannot self-RSVP directly into a paid event (only free ones).
--   * A fully-approved event payment auto-registers the student, without
--     touching their membership plan_status/expiration_date.
--   * A partially-approved event payment does not register the student yet.

begin;
select plan(5);

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
insert into auth.users (id, email) values
  ('23230000-0000-0000-0000-000000000001', 'admin.c23@test.local'),
  ('23230000-0000-0000-0000-000000000002', 'student.c23@test.local');

update public.users set role = 'ADMIN' where id = '23230000-0000-0000-0000-000000000001';
update public.users set plan_status = 'ACTIVE', expiration_date = current_date + 30
  where id = '23230000-0000-0000-0000-000000000002';

-- ── C23.1: a paid event needs a price ────────────────────────────────────────
select throws_ok(
  $$ insert into public.events (title, starts_at, is_free, price)
     values ('C23 Paid Workshop Bad', now() + interval '7 days', false, null) $$,
  '23514',
  null,
  'C23.1 a paid event (is_free=false) requires a price'
);

insert into public.events (id, title, starts_at, is_free, price, status)
values (
  '23230000-9999-0000-0000-000000000001', 'C23 Paid Workshop',
  now() + interval '7 days', false, 500, 'PUBLISHED'
);

-- ── C23.2: a student cannot self-RSVP directly into a paid event ────────────
select pg_temp.act_as('23230000-0000-0000-0000-000000000002');

select throws_ok(
  format(
    $$ insert into public.event_registrations (event_id, student_id) values (%L, %L) $$,
    '23230000-9999-0000-0000-000000000001', '23230000-0000-0000-0000-000000000002'
  ),
  '42501',
  null,
  'C23.2 a student cannot self-RSVP directly into a paid event'
);

-- ── C23.3-5: a fully-approved event payment auto-registers, no plan change ──
-- Fully reset to server context: role AND the stale JWT claim from act_as()
-- (auth.uid() reads request.jwt.claims regardless of the `role` GUC).
select set_config('role', 'postgres', true);
select set_config('request.jwt.claims', '', true);
select set_config('request.jwt.claim.sub', '', true);

insert into public.payments (id, student_id, event_id, amount, status, admin_approved, receipt_given_by_trainer)
values (
  '23230000-8888-0000-0000-000000000001', '23230000-0000-0000-0000-000000000002',
  '23230000-9999-0000-0000-000000000001', 500, 'PENDING', false, false
);

update public.payments set admin_approved = true where id = '23230000-8888-0000-0000-000000000001';
update public.payments set receipt_given_by_trainer = true, status = 'PAID'
  where id = '23230000-8888-0000-0000-000000000001';

select is(
  (select count(*)::int from public.event_registrations
   where event_id = '23230000-9999-0000-0000-000000000001'
     and student_id = '23230000-0000-0000-0000-000000000002'),
  1,
  'C23.3 a fully-approved event payment auto-registers the student'
);

select is(
  (select expiration_date from public.users where id = '23230000-0000-0000-0000-000000000002'),
  (current_date + 30),
  'C23.4 the event payment did not touch the student''s membership expiration_date'
);

-- ── C23.6: a partially-approved event payment does not register yet ─────────
insert into public.events (id, title, starts_at, is_free, price, status)
values (
  '23230000-9999-0000-0000-000000000002', 'C23 Paid Workshop 2',
  now() + interval '7 days', false, 500, 'PUBLISHED'
);

insert into public.payments (id, student_id, event_id, amount, status, admin_approved, receipt_given_by_trainer)
values (
  '23230000-8888-0000-0000-000000000002', '23230000-0000-0000-0000-000000000002',
  '23230000-9999-0000-0000-000000000002', 500, 'PENDING', false, false
);
update public.payments set admin_approved = true where id = '23230000-8888-0000-0000-000000000002';

select is(
  (select count(*)::int from public.event_registrations
   where event_id = '23230000-9999-0000-0000-000000000002'),
  0,
  'C23.5 a partially-approved (admin only, no trainer receipt) event payment does not register yet'
);

select * from finish();
rollback;
