-- c17_leave_business_rules_test.sql  (pgTAP)
-- Run with:  supabase test db
--
-- Verifies 039_leave_business_rules.sql:
--   * >=24h-advance requests within the plan's monthly cap auto-approve.
--   * Over-cap requests stay PENDING for Admin.
--   * Late (<24h advance) requests stay PENDING even if within cap.
--   * Approval (auto or Admin) extends users.expiration_date by 1 day per
--     leave day and notifies the student + the student's trainer.
--   * A real check-in (PRESENT) on an approved leave day recredits it and
--     un-does the package extension.
--   * Week-offs (Sat/Sun) are excluded from leave-day counting.
--
-- NOTE: date1/date2/date3 are found by walking forward from "today + 5" and
-- skipping week-offs, so this assumes that window doesn't cross a calendar
-- month boundary (true almost all of the time; a known, accepted flakiness
-- trade-off shared with other relative-date tests in this suite, e.g. c3).

begin;
select plan(17);

-- ── Fixtures ─────────────────────────────────────────────────────────────────
insert into auth.users (id, email) values
  ('77777777-7777-7777-7777-777777777777', 'student.c17@test.local'),
  ('88888888-8888-8888-8888-888888888888', 'trainer.c17@test.local');

update public.users set role = 'TRAINER'
  where id = '88888888-8888-8888-8888-888888888888';

insert into public.plans (id, name, price, duration_days, max_leave_days_per_month)
values ('66666666-6666-6666-6666-666666666666', 'C17 Test Plan', 999, 30, 2);

update public.users
set current_plan_id = '66666666-6666-6666-6666-666666666666',
    expiration_date = current_date + 20
where id = '77777777-7777-7777-7777-777777777777';

insert into public.batches (id, name, trainer_id, schedule_time, days_of_week, location_lat, location_lng)
values ('99999999-9999-9999-9999-999999999999', 'C17 Test Batch',
        '88888888-8888-8888-8888-888888888888', '07:00', '{}', 26.8467, 80.9462);

insert into public.enrollments (student_id, batch_id)
values ('77777777-7777-7777-7777-777777777777', '99999999-9999-9999-9999-999999999999');

-- Baseline expiration date + 3 distinct future weekdays, all well outside the
-- 24h auto-approval cutoff, walked forward to (best-effort) stay in-month.
create temporary table t_state (k text primary key, v date);
insert into t_state values ('d0', current_date + 20);

do $$
declare
  v_d date := current_date + 5;
  v_found date[] := '{}';
begin
  while array_length(v_found, 1) is null or array_length(v_found, 1) < 3 loop
    if not public.is_week_off(v_d) then
      v_found := v_found || v_d;
    end if;
    v_d := v_d + 1;
  end loop;
  insert into t_state values ('date1', v_found[1]), ('date2', v_found[2]), ('date3', v_found[3]);
end;
$$;

-- ── C17.1-6: first leave day auto-approves (within cap, >=24h advance) ──────
insert into public.leave_requests (student_id, start_date, end_date, reason)
values (
  '77777777-7777-7777-7777-777777777777',
  (select v from t_state where k = 'date1'),
  (select v from t_state where k = 'date1'),
  'C17 request 1'
);

select is(
  (select status from public.leave_requests
   where student_id = '77777777-7777-7777-7777-777777777777'
     and start_date = (select v from t_state where k = 'date1')),
  'APPROVED',
  'C17.1 leave request well in advance and within cap auto-approves'
);

select is(
  (select is_auto_approved from public.leave_requests
   where student_id = '77777777-7777-7777-7777-777777777777'
     and start_date = (select v from t_state where k = 'date1')),
  true,
  'C17.2 auto-approved request is flagged is_auto_approved'
);

select is(
  (select expiration_date - (select v from t_state where k = 'd0')
   from public.users where id = '77777777-7777-7777-7777-777777777777'),
  1,
  'C17.3 package end date extends by 1 day after first approved leave day'
);

select is(
  (select extended_package::text || '/' || recredited::text from public.leave_days
   where student_id = '77777777-7777-7777-7777-777777777777'
     and date = (select v from t_state where k = 'date1')),
  'true/false',
  'C17.4 leave_days row for date1 is extended and not recredited'
);

select is(
  (select count(*)::int from public.notifications
   where user_id = '77777777-7777-7777-7777-777777777777' and kind = 'LEAVE_APPROVED'),
  1,
  'C17.5 student is notified of the approval'
);

select is(
  (select count(*)::int from public.notifications
   where user_id = '88888888-8888-8888-8888-888888888888' and body ilike '%leave%'),
  1,
  'C17.6 assigned trainer gets an informational notification'
);

-- ── C17.7-8: second leave day still within the 2-day cap ────────────────────
insert into public.leave_requests (student_id, start_date, end_date, reason)
values (
  '77777777-7777-7777-7777-777777777777',
  (select v from t_state where k = 'date2'),
  (select v from t_state where k = 'date2'),
  'C17 request 2'
);

select is(
  (select status from public.leave_requests
   where student_id = '77777777-7777-7777-7777-777777777777'
     and start_date = (select v from t_state where k = 'date2')),
  'APPROVED',
  'C17.7 second leave day (still within cap) auto-approves'
);

select is(
  (select expiration_date - (select v from t_state where k = 'd0')
   from public.users where id = '77777777-7777-7777-7777-777777777777'),
  2,
  'C17.8 package end date now extended by 2 total days'
);

-- ── C17.9-10: third leave day exceeds the cap -> PENDING, no extension ──────
insert into public.leave_requests (student_id, start_date, end_date, reason)
values (
  '77777777-7777-7777-7777-777777777777',
  (select v from t_state where k = 'date3'),
  (select v from t_state where k = 'date3'),
  'C17 request 3'
);

select is(
  (select status from public.leave_requests
   where student_id = '77777777-7777-7777-7777-777777777777'
     and start_date = (select v from t_state where k = 'date3')),
  'PENDING',
  'C17.9 third leave day (over the 2-day cap) requires Admin approval'
);

select is(
  (select expiration_date - (select v from t_state where k = 'd0')
   from public.users where id = '77777777-7777-7777-7777-777777777777'),
  2,
  'C17.10 package end date unchanged while the over-cap request is pending'
);

-- ── C17.11-12: Admin approval of the pending request extends the package ────
update public.leave_requests
set status = 'APPROVED', approved_by = '88888888-8888-8888-8888-888888888888'
where student_id = '77777777-7777-7777-7777-777777777777'
  and start_date = (select v from t_state where k = 'date3');

select is(
  (select status from public.leave_requests
   where student_id = '77777777-7777-7777-7777-777777777777'
     and start_date = (select v from t_state where k = 'date3')),
  'APPROVED',
  'C17.11 Admin can manually approve an over-cap request'
);

select is(
  (select expiration_date - (select v from t_state where k = 'd0')
   from public.users where id = '77777777-7777-7777-7777-777777777777'),
  3,
  'C17.12 Admin approval also extends the package end date'
);

-- ── C17.13-14: request starting today (< 24h advance) is never auto-approved ─
insert into public.leave_requests (student_id, start_date, end_date, reason)
values (
  '77777777-7777-7777-7777-777777777777',
  current_date,
  current_date,
  'C17 request 4 (late)'
);

select is(
  (select status from public.leave_requests
   where student_id = '77777777-7777-7777-7777-777777777777' and start_date = current_date),
  'PENDING',
  'C17.13 a same-day (< 24h advance) request stays PENDING regardless of cap'
);

select is(
  (select is_auto_approved from public.leave_requests
   where student_id = '77777777-7777-7777-7777-777777777777' and start_date = current_date),
  false,
  'C17.14 late request is not flagged as auto-approved'
);

-- ── C17.15-16: a real check-in recredits the leave day and undoes extension ──
insert into public.attendance (student_id, batch_id, date, status, marked_by)
values (
  '77777777-7777-7777-7777-777777777777',
  '99999999-9999-9999-9999-999999999999',
  (select v from t_state where k = 'date1'),
  'PRESENT',
  'STUDENT'
)
on conflict (student_id, date) do update set status = 'PRESENT', marked_by = 'STUDENT';

select is(
  (select recredited from public.leave_days
   where student_id = '77777777-7777-7777-7777-777777777777'
     and date = (select v from t_state where k = 'date1')),
  true,
  'C17.15 checking in on an approved leave day recredits it'
);

select is(
  (select expiration_date - (select v from t_state where k = 'd0')
   from public.users where id = '77777777-7777-7777-7777-777777777777'),
  2,
  'C17.16 recredit undoes the earlier package extension for that day'
);

-- ── C17.17: week-off sanity check (any 7-day window has exactly 2) ──────────
select is(
  (select count(*)::int from generate_series(current_date, current_date + 6, interval '1 day') d
   where public.is_week_off(d::date)),
  2,
  'C17.17 any 7-day window has exactly 2 week-off (Sat/Sun) days'
);

select * from finish();
rollback;
