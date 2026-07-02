-- c21_notifications_and_admin_ops_test.sql  (pgTAP)
-- Run with:  supabase test db
--
-- Verifies 043_notifications_and_admin_ops.sql:
--   * Audit log captures payment verification, role changes, suspension,
--     and plan price changes — and only Admin can read it.
--   * Drop-off risk fires on 3 consecutive ABSENT marks, with a 7-day
--     cooldown against re-notifying.
--   * send_renewal_reminders() notifies users expiring in 7 or 1 days,
--     and is idempotent (doesn't double-send).
--   * send_broadcast() is Admin-only and fans out to the right audience.

begin;
select plan(12);

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
  ('21210000-0000-0000-0000-000000000001', 'admin.c21@test.local'),
  ('21210000-0000-0000-0000-000000000002', 'trainer.c21@test.local'),
  ('21210000-0000-0000-0000-000000000003', 'student.c21@test.local'),
  ('21210000-0000-0000-0000-000000000004', 'expiring7.c21@test.local'),
  ('21210000-0000-0000-0000-000000000005', 'expiring1.c21@test.local'),
  ('21210000-0000-0000-0000-000000000006', 'plainstudent.c21@test.local');

update public.users set role = 'ADMIN' where id = '21210000-0000-0000-0000-000000000001';
update public.users set role = 'TRAINER' where id = '21210000-0000-0000-0000-000000000002';

-- ── C21.1-2: audit log captures a role change, readable only by Admin ───────
update public.users set role = 'TRAINER' where id = '21210000-0000-0000-0000-000000000003';

select is(
  (select action from public.audit_log where target_id = '21210000-0000-0000-0000-000000000003' and action = 'ROLE_CHANGED'),
  'ROLE_CHANGED',
  'C21.1 changing a user role writes an audit_log entry'
);

select pg_temp.act_as('21210000-0000-0000-0000-000000000003');
select is(
  (select count(*)::int from public.audit_log),
  0,
  'C21.2 a non-admin cannot read the audit log'
);

-- ── C21.3: suspending a student (is_active) is logged ────────────────────────
select pg_temp.act_as('21210000-0000-0000-0000-000000000001');
update public.users set is_active = false where id = '21210000-0000-0000-0000-000000000003';

select is(
  (select action from public.audit_log
   where target_id = '21210000-0000-0000-0000-000000000003' and action = 'STUDENT_SUSPENDED'),
  'STUDENT_SUSPENDED',
  'C21.3 deactivating a user writes STUDENT_SUSPENDED to the audit log'
);

-- ── C21.4: plan price change is logged ───────────────────────────────────────
insert into public.plans (id, name, price, duration_days)
values ('21210000-9999-0000-0000-000000000001', 'C21 Plan', 1000, 30);
update public.plans set price = 1200 where id = '21210000-9999-0000-0000-000000000001';

select is(
  (select action from public.audit_log
   where target_id = '21210000-9999-0000-0000-000000000001' and action = 'PLAN_PRICE_CHANGED'),
  'PLAN_PRICE_CHANGED',
  'C21.4 changing a plan price writes an audit_log entry'
);

-- ── C21.5-6: drop-off risk on 3 consecutive absences, with cooldown ──────────
do $$
declare
  v_student uuid := '21210000-0000-0000-0000-000000000003';
begin
  insert into public.attendance (student_id, date, status, marked_by)
  values (v_student, current_date - 2, 'ABSENT', 'TRAINER');
  insert into public.attendance (student_id, date, status, marked_by)
  values (v_student, current_date - 1, 'ABSENT', 'TRAINER');
  insert into public.attendance (student_id, date, status, marked_by)
  values (v_student, current_date, 'ABSENT', 'TRAINER');
end;
$$;

select is(
  (select count(*)::int from public.notifications
   where user_id = '21210000-0000-0000-0000-000000000001'
     and kind = 'DROPOFF_RISK'
     and metadata->>'student_id' = '21210000-0000-0000-0000-000000000003'),
  1,
  'C21.5 3 consecutive absences notifies Admin of drop-off risk'
);

-- A 4th absence the next day should NOT re-notify within the 7-day cooldown.
insert into public.attendance (student_id, date, status, marked_by)
values ('21210000-0000-0000-0000-000000000003', current_date + 1, 'ABSENT', 'TRAINER');

select is(
  (select count(*)::int from public.notifications
   where user_id = '21210000-0000-0000-0000-000000000001'
     and kind = 'DROPOFF_RISK'
     and metadata->>'student_id' = '21210000-0000-0000-0000-000000000003'),
  1,
  'C21.6 a further absence within 7 days does not re-notify (cooldown)'
);

-- ── C21.7-9: renewal reminders (7-day and 1-day), idempotent ─────────────────
-- send_renewal_reminders() is meant to be invoked by pg_cron (superuser),
-- not through a client role — reset back out of the act_as simulation.
select set_config('role', 'postgres', true);

update public.users
set plan_status = 'ACTIVE', expiration_date = current_date + 7
where id = '21210000-0000-0000-0000-000000000004';

update public.users
set plan_status = 'ACTIVE', expiration_date = current_date + 1
where id = '21210000-0000-0000-0000-000000000005';

select is(
  (select public.send_renewal_reminders()),
  2,
  'C21.7 send_renewal_reminders notifies both the 7-day-out and 1-day-out users'
);

select is(
  (select count(*)::int from public.notifications
   where user_id = '21210000-0000-0000-0000-000000000005' and kind = 'PAYMENT_DUE'),
  1,
  'C21.8 the 1-day-out user received exactly one reminder'
);

select is(
  (select public.send_renewal_reminders()),
  0,
  'C21.9 re-running send_renewal_reminders is idempotent (no duplicate sends)'
);

-- ── C21.10-12: broadcast is Admin-only and targets the right audience ───────
select pg_temp.act_as('21210000-0000-0000-0000-000000000003');

select throws_ok(
  $$ select public.send_broadcast('ALL', 'Hi', 'test') $$,
  '42501',
  null,
  'C21.10 a non-admin cannot send a broadcast'
);

select pg_temp.act_as('21210000-0000-0000-0000-000000000001');

select cmp_ok(
  (select public.send_broadcast('TRAINERS', 'Studio closed', 'Closed tomorrow for maintenance.')),
  '>=',
  1,
  'C21.11 broadcasting to TRAINERS reaches at least the one trainer fixture'
);

select is(
  (select count(*)::int from public.notifications
   where user_id = '21210000-0000-0000-0000-000000000006'
     and title = 'Studio closed'),
  0,
  'C21.12 a TRAINERS-only broadcast does not reach a non-trainer'
);

select * from finish();
rollback;
