-- c18_enrollment_waitlist_test.sql  (pgTAP)
-- Run with:  supabase test db
--
-- Verifies 040_enrollment_waitlist.sql:
--   * request_enrollment() returns PENDING when the batch has room.
--   * request_enrollment() returns WAITLISTED when the batch is full.
--   * PENDING requests don't consume a capacity slot; CONFIRMED ones do.
--   * Deleting a CONFIRMED enrollment on a batch with a waitlist notifies Admin.
--   * convert_waitlist_entry() (Admin-only) creates a CONFIRMED enrollment
--     and marks the waitlist entry CONVERTED.

begin;
select plan(9);

-- ── Fixtures: a 1-seat batch, 1 confirmed student, 1 requesting student ─────
insert into auth.users (id, email) values
  ('11111111-1111-1111-1111-111111111111', 'admin.c18@test.local'),
  ('22222222-2222-2222-2222-222222222222', 'student.confirmed.c18@test.local'),
  ('33333333-3333-3333-3333-333333333333', 'student.waitlist.c18@test.local'),
  ('44444444-4444-4444-4444-444444444444', 'student.room.c18@test.local');

update public.users set role = 'ADMIN' where id = '11111111-1111-1111-1111-111111111111';

insert into public.batches (id, name, schedule_time, days_of_week, capacity, location_lat, location_lng)
values ('55555555-1111-1111-1111-111111111111', 'C18 Full Batch', '07:00', '{}', 1, 26.8467, 80.9462);

insert into public.batches (id, name, schedule_time, days_of_week, capacity, location_lat, location_lng)
values ('55555555-2222-2222-2222-222222222222', 'C18 Roomy Batch', '08:00', '{}', 5, 26.8467, 80.9462);

insert into public.enrollments (student_id, batch_id, assigned_by, status)
values ('22222222-2222-2222-2222-222222222222', '55555555-1111-1111-1111-111111111111',
        '11111111-1111-1111-1111-111111111111', 'CONFIRMED');

-- ── C18.1: request into a full batch waitlists ───────────────────────────────
select is(
  (select public.request_enrollment('55555555-1111-1111-1111-111111111111')
   from (select set_config('request.jwt.claim.sub', '33333333-3333-3333-3333-333333333333', true)) _),
  'WAITLISTED',
  'C18.1 requesting a full batch returns WAITLISTED'
);

select is(
  (select status from public.batch_waitlist
   where student_id = '33333333-3333-3333-3333-333333333333'
     and batch_id = '55555555-1111-1111-1111-111111111111'),
  'WAITING',
  'C18.2 a WAITING waitlist row was created'
);

select is(
  (select count(*)::int from public.enrollments
   where batch_id = '55555555-1111-1111-1111-111111111111'
     and student_id = '33333333-3333-3333-3333-333333333333'),
  0,
  'C18.3 waitlisted student did not get an enrollment row'
);

-- ── C18.4-5: request into a roomy batch goes PENDING, no capacity consumed ──
select is(
  (select public.request_enrollment('55555555-2222-2222-2222-222222222222')
   from (select set_config('request.jwt.claim.sub', '44444444-4444-4444-4444-444444444444', true)) _),
  'PENDING',
  'C18.4 requesting a batch with room returns PENDING'
);

select is(
  (select status from public.enrollments
   where student_id = '44444444-4444-4444-4444-444444444444'
     and batch_id = '55555555-2222-2222-2222-222222222222'),
  'PENDING',
  'C18.5 the enrollment row is PENDING, not auto-confirmed'
);

-- ── C18.6: freeing the confirmed seat notifies Admin (waitlist exists) ──────
delete from public.enrollments
where student_id = '22222222-2222-2222-2222-222222222222'
  and batch_id = '55555555-1111-1111-1111-111111111111';

select is(
  (select count(*)::int from public.notifications
   where user_id = '11111111-1111-1111-1111-111111111111' and title ilike '%waitlist%'),
  1,
  'C18.6 Admin is notified when a spot opens on a batch with a waitlist'
);

-- ── C18.7-9: Admin converts the waitlist entry into a real enrollment ───────
select lives_ok(
  format(
    'select public.convert_waitlist_entry(%L::uuid) from (select set_config(''request.jwt.claim.sub'', %L, true)) _',
    (select id from public.batch_waitlist
     where student_id = '33333333-3333-3333-3333-333333333333'
       and batch_id = '55555555-1111-1111-1111-111111111111'),
    '11111111-1111-1111-1111-111111111111'
  ),
  'C18.7 Admin can convert a waitlist entry'
);

select is(
  (select status from public.enrollments
   where student_id = '33333333-3333-3333-3333-333333333333'
     and batch_id = '55555555-1111-1111-1111-111111111111'),
  'CONFIRMED',
  'C18.8 the converted enrollment is CONFIRMED'
);

select is(
  (select status from public.batch_waitlist
   where student_id = '33333333-3333-3333-3333-333333333333'
     and batch_id = '55555555-1111-1111-1111-111111111111'),
  'CONVERTED',
  'C18.9 the waitlist entry is marked CONVERTED'
);

select * from finish();
rollback;
