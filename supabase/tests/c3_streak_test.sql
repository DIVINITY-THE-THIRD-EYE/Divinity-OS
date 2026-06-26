-- c3_streak_test.sql  (pgTAP)
-- Run with:  supabase test db
--
-- Verifies FIX B2 (014_attendance_streak_trigger.sql):
--   * Inserting PRESENT attendance updates users.current_streak and users.max_streak.
--   * Contiguous days increment the streak.
--   * Gaps reset the current streak but preserve the max streak.
--   * Deleting attendance or marking as ABSENT decrements or updates the streak.

begin;
select plan(7);

-- ── Fixtures ─────────────────────────────────────────────────────────────────
insert into auth.users (id, email) values
  ('55555555-5555-5555-5555-555555555555', 'student.c3@test.local');

-- User starts with 0 streaks
select is(
  (select current_streak || '/' || max_streak from public.users where id = '55555555-5555-5555-5555-555555555555'),
  '0/0',
  'C3.1 student starts with 0 current and max streak'
);

-- We need a batch to reference
insert into public.batches
  (id, name, schedule_time, location_lat, location_lng, radius_meters)
values
  ('cccccccc-cccc-cccc-cccc-cccccccccccc', 'Yoga Morning', '07:00',
   26.8467, 80.9462, 100);

-- ── Contiguous 2-day attendance starting 2 days ago ──────────────────────────
do $$
declare
  v_today date := (now() at time zone 'Asia/Kolkata')::date;
begin
  -- 2 days ago:
  insert into public.attendance (student_id, batch_id, date, status, marked_by)
  values ('55555555-5555-5555-5555-555555555555', 'cccccccc-cccc-cccc-cccc-cccccccccccc', v_today - 2, 'PRESENT', 'TRAINER');
  
  -- 1 day ago:
  insert into public.attendance (student_id, batch_id, date, status, marked_by)
  values ('55555555-5555-5555-5555-555555555555', 'cccccccc-cccc-cccc-cccc-cccccccccccc', v_today - 1, 'PRESENT', 'TRAINER');
end;
$$;

-- Streak should be 2 because they were present yesterday (which is acceptable gap for today not yet checked in)
select is(
  (select current_streak || '/' || max_streak from public.users where id = '55555555-5555-5555-5555-555555555555'),
  '2/2',
  'C3.2 streak is 2 after 2 contiguous days (ending yesterday)'
);

-- Checked in today:
do $$
declare
  v_today date := (now() at time zone 'Asia/Kolkata')::date;
begin
  insert into public.attendance (student_id, batch_id, date, status, marked_by)
  values ('55555555-5555-5555-5555-555555555555', 'cccccccc-cccc-cccc-cccc-cccccccccccc', v_today, 'PRESENT', 'TRAINER');
end;
$$;

-- Streak should be 3
select is(
  (select current_streak || '/' || max_streak from public.users where id = '55555555-5555-5555-5555-555555555555'),
  '3/3',
  'C3.3 streak is 3 after present today'
);

-- Break the streak by deleting yesterday's attendance:
do $$
declare
  v_today date := (now() at time zone 'Asia/Kolkata')::date;
begin
  delete from public.attendance
  where student_id = '55555555-5555-5555-5555-555555555555' and date = v_today - 1;
end;
$$;

-- Current streak becomes 1 (just today), but max streak remains 3!
select is(
  (select current_streak || '/' || max_streak from public.users where id = '55555555-5555-5555-5555-555555555555'),
  '1/3',
  'C3.4 break in streak resets current to 1 but preserves max_streak = 3'
);

-- Check that marking status = 'ABSENT' updates the streaks correctly:
do $$
declare
  v_today date := (now() at time zone 'Asia/Kolkata')::date;
begin
  update public.attendance
  set status = 'ABSENT'
  where student_id = '55555555-5555-5555-5555-555555555555' and date = v_today;
end;
$$;

-- Current streak becomes 0 (no present today or yesterday), max streak is still 3
select is(
  (select current_streak || '/' || max_streak from public.users where id = '55555555-5555-5555-5555-555555555555'),
  '0/3',
  'C3.5 current streak is 0 after marking today as ABSENT'
);

-- Restore attendance to get current streak to 3 again:
do $$
declare
  v_today date := (now() at time zone 'Asia/Kolkata')::date;
begin
  -- upsert today to PRESENT
  update public.attendance
  set status = 'PRESENT'
  where student_id = '55555555-5555-5555-5555-555555555555' and date = v_today;

  -- insert yesterday to PRESENT
  insert into public.attendance (student_id, batch_id, date, status, marked_by)
  values ('55555555-5555-5555-5555-555555555555', 'cccccccc-cccc-cccc-cccc-cccccccccccc', v_today - 1, 'PRESENT', 'TRAINER');
end;
$$;

select is(
  (select current_streak || '/' || max_streak from public.users where id = '55555555-5555-5555-5555-555555555555'),
  '3/3',
  'C3.6 restored contiguous attendance restores current streak to 3'
);

-- Now let's try a 4-day streak to exceed max_streak:
do $$
declare
  v_today date := (now() at time zone 'Asia/Kolkata')::date;
begin
  -- 3 days ago:
  insert into public.attendance (student_id, batch_id, date, status, marked_by)
  values ('55555555-5555-5555-5555-555555555555', 'cccccccc-cccc-cccc-cccc-cccccccccccc', v_today - 3, 'PRESENT', 'TRAINER');
end;
$$;

-- Streak should be 4 and max_streak should be 4
select is(
  (select current_streak || '/' || max_streak from public.users where id = '55555555-5555-5555-5555-555555555555'),
  '4/4',
  'C3.7 longer contiguous streak updates max_streak to 4'
);

select * from finish();
rollback;
