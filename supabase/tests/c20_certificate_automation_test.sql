-- c20_certificate_automation_test.sql  (pgTAP)
-- Run with:  supabase test db
--
-- Verifies 042_certificate_automation.sql:
--   * A student with >=80% attendance over a completed program duration
--     auto-earns a certificate when a PRESENT day is recorded.
--   * A student below 80% attendance does not.
--   * A student whose program duration hasn't elapsed yet does not.
--   * Auto-issuance is idempotent (one certificate per student/plan).
--   * An add-on plan's certificate gets its own independent expiry_date.

begin;
select plan(9);

-- ── Fixtures: three plans (fast 10-day "programs" for testability) ──────────
insert into public.plans (id, name, price, duration_days, certify_after_days, is_addon)
values ('20200000-0000-0000-0000-000000000001', 'C20 Regular Plan', 3000, 30, 10, false);

insert into public.plans (id, name, price, duration_days, certify_after_days, is_addon)
values ('20200000-0000-0000-0000-000000000002', 'C20 Low Attendance Plan', 3000, 30, 10, false);

insert into public.plans (id, name, price, duration_days, certify_after_days, is_addon)
values ('20200000-0000-0000-0000-000000000003', 'C20 Addon Workshop', 1500, 30, 10, true);

insert into public.plans (id, name, price, duration_days, certify_after_days, is_addon)
values ('20200000-0000-0000-0000-000000000004', 'C20 Not-Yet-Due Plan', 3000, 30, 10, false);

insert into auth.users (id, email) values
  ('20200000-1111-0000-0000-000000000001', 'student.good.c20@test.local'),
  ('20200000-1111-0000-0000-000000000002', 'student.low.c20@test.local'),
  ('20200000-1111-0000-0000-000000000003', 'student.addon.c20@test.local'),
  ('20200000-1111-0000-0000-000000000004', 'student.notdue.c20@test.local');

-- ── C20.1-3: good attendance (9 present / 1 absent = 90%) auto-issues ───────
insert into public.payments (student_id, plan_id, amount, status, paid_at)
values (
  '20200000-1111-0000-0000-000000000001', '20200000-0000-0000-0000-000000000001',
  3000, 'PAID', (current_date - 15)::timestamptz
);

do $$
declare
  v_student uuid := '20200000-1111-0000-0000-000000000001';
  v_day date := current_date - 14;
begin
  for i in 1..9 loop
    insert into public.attendance (student_id, date, status, marked_by)
    values (v_student, v_day, 'PRESENT', 'TRAINER');
    v_day := v_day + 1;
  end loop;
  insert into public.attendance (student_id, date, status, marked_by)
  values (v_student, v_day, 'ABSENT', 'TRAINER');
end;
$$;

select is(
  (select count(*)::int from public.certificates
   where student_id = '20200000-1111-0000-0000-000000000001'
     and plan_id = '20200000-0000-0000-0000-000000000001'),
  1,
  'C20.1 a student with 90% attendance over a completed program auto-earns a certificate'
);

select is(
  (select auto_issued from public.certificates
   where student_id = '20200000-1111-0000-0000-000000000001'
     and plan_id = '20200000-0000-0000-0000-000000000001'),
  true,
  'C20.2 the certificate is flagged auto_issued'
);

select is(
  (select count(*)::int from public.notifications
   where user_id = '20200000-1111-0000-0000-000000000001' and title ilike '%certificate%'),
  1,
  'C20.3 the student is notified'
);

-- ── C20.4: low attendance (1 present / 9 absent = 10%) does not issue ───────
insert into public.payments (student_id, plan_id, amount, status, paid_at)
values (
  '20200000-1111-0000-0000-000000000002', '20200000-0000-0000-0000-000000000002',
  3000, 'PAID', (current_date - 15)::timestamptz
);

-- Inserted in real chronological order (as a trainer would actually mark
-- each day when it happens) so no prefix of the sequence ever shows a
-- spuriously high rate from partial data — the 1 PRESENT day is last.
do $$
declare
  v_student uuid := '20200000-1111-0000-0000-000000000002';
  v_day date := current_date - 14;
begin
  for i in 1..9 loop
    insert into public.attendance (student_id, date, status, marked_by)
    values (v_student, v_day, 'ABSENT', 'TRAINER');
    v_day := v_day + 1;
  end loop;
  insert into public.attendance (student_id, date, status, marked_by)
  values (v_student, v_day, 'PRESENT', 'TRAINER');
end;
$$;

select is(
  (select count(*)::int from public.certificates
   where student_id = '20200000-1111-0000-0000-000000000002'),
  0,
  'C20.4 a student below 80% attendance does not earn a certificate'
);

-- ── C20.5: program duration not yet complete does not issue ─────────────────
insert into public.payments (student_id, plan_id, amount, status, paid_at)
values (
  '20200000-1111-0000-0000-000000000004', '20200000-0000-0000-0000-000000000004',
  3000, 'PAID', (current_date - 2)::timestamptz
);

insert into public.attendance (student_id, date, status, marked_by)
values ('20200000-1111-0000-0000-000000000004', current_date - 1, 'PRESENT', 'TRAINER');

select is(
  (select count(*)::int from public.certificates
   where student_id = '20200000-1111-0000-0000-000000000004'),
  0,
  'C20.5 a student whose program duration has not elapsed does not earn a certificate yet'
);

-- ── C20.6-7: idempotent — re-checking an already-issued cert is a no-op ─────
select lives_ok(
  format(
    'select public.check_and_issue_certificate(%L, %L)',
    '20200000-1111-0000-0000-000000000001', '20200000-0000-0000-0000-000000000001'
  ),
  'C20.6 re-checking an already-certified student does not error'
);

select is(
  (select count(*)::int from public.certificates
   where student_id = '20200000-1111-0000-0000-000000000001'
     and plan_id = '20200000-0000-0000-0000-000000000001'),
  1,
  'C20.7 still exactly one certificate for that student/plan (no duplicate)'
);

-- ── C20.8-9: add-on plan certificate gets an independent expiry_date ────────
insert into public.payments (student_id, plan_id, amount, status, paid_at)
values (
  '20200000-1111-0000-0000-000000000003', '20200000-0000-0000-0000-000000000003',
  1500, 'PAID', (current_date - 15)::timestamptz
);

do $$
declare
  v_student uuid := '20200000-1111-0000-0000-000000000003';
  v_day date := current_date - 14;
begin
  for i in 1..9 loop
    insert into public.attendance (student_id, date, status, marked_by)
    values (v_student, v_day, 'PRESENT', 'TRAINER');
    v_day := v_day + 1;
  end loop;
end;
$$;

select is(
  (select expiry_date is not null from public.certificates
   where student_id = '20200000-1111-0000-0000-000000000003'
     and plan_id = '20200000-0000-0000-0000-000000000003'),
  true,
  'C20.8 an add-on certificate has its own expiry_date set'
);

select is(
  (select expiry_date from public.certificates
   where student_id = '20200000-1111-0000-0000-000000000001'
     and plan_id = '20200000-0000-0000-0000-000000000001'),
  null::date,
  'C20.9 a regular (non-add-on) plan certificate has no expiry_date'
);

select * from finish();
rollback;
