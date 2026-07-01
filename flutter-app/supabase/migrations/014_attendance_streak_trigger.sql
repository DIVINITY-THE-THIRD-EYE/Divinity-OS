-- 014_attendance_streak_trigger.sql
-- ─────────────────────────────────────────────────────────────────────────────
-- FIX B2 — Streak bug (low-streak alert reads always-0 column)
--
-- Redefine lock_privileged_fields to check my.bypass_lock transaction parameter,
-- so that system triggers/functions can update current_streak and max_streak.
--
-- Create recalculate_student_streaks and the attendance trigger to automatically
-- update user streaks upon attendance change.
-- ─────────────────────────────────────────────────────────────────────────────

create or replace function public.lock_privileged_fields()
returns trigger
language plpgsql
security definer
set search_path = public, pg_temp
as $$
begin
  -- Trusted server context (service_role / superuser / migration / trigger bypass): allow.
  if auth.uid() is null or coalesce(current_setting('my.bypass_lock', true), 'false') = 'true' then
    return new;
  end if;

  -- Admins may change any field.
  if public.is_admin(auth.uid()) then
    return new;
  end if;

  -- role is ADMIN-only, no exceptions.
  if new.role is distinct from old.role then
    raise exception 'role can only be changed by an admin'
      using errcode = '42501';  -- insufficient_privilege
  end if;

  -- plan_status: ADMIN-only, EXCEPT a user setting their OWN row to
  -- 'PENDING_ADMIN' (the onboarding-complete transition).
  if new.plan_status is distinct from old.plan_status then
    if not (auth.uid() = old.id and new.plan_status = 'PENDING_ADMIN') then
      raise exception 'plan_status can only be set by an admin (onboarding may set PENDING_ADMIN only)'
        using errcode = '42501';
    end if;
  end if;

  -- Plan lifecycle + streak fields: ADMIN-only.
  if new.expiration_date  is distinct from old.expiration_date
     or new.pause_start_date is distinct from old.pause_start_date
     or new.current_streak   is distinct from old.current_streak
     or new.max_streak       is distinct from old.max_streak then
    raise exception 'plan lifecycle and streak fields can only be changed by an admin'
      using errcode = '42501';
  end if;

  return new;
end;
$$;

-- Recalculate streaks helper
create or replace function public.recalculate_student_streaks(p_student_id uuid)
returns void
language plpgsql
security definer
set search_path = public, pg_temp
as $$
declare
  v_today date := (now() at time zone 'Asia/Kolkata')::date;
  v_date date;
  v_current_streak integer := 0;
  v_max_streak integer := 0;
  v_temp_streak integer := 0;
  v_prev_date date := null;
  v_bypass_prev text;
begin
  -- Initialize max_streak with the historical value from the user's profile
  select coalesce(max_streak, 0) into v_max_streak
  from public.users
  where id = p_student_id;

  -- 1. Calculate max_streak and current_streak by sorting all PRESENT dates ascending
  -- (ordered from oldest to newest) to find contiguous segments.
  for v_date in
    select date
    from public.attendance
    where student_id = p_student_id and status = 'PRESENT'
    order by date asc
  loop
    if v_prev_date is null then
      v_temp_streak := 1;
    elsif v_date = v_prev_date + 1 then
      v_temp_streak := v_temp_streak + 1;
    elsif v_date > v_prev_date + 1 then
      if v_temp_streak > v_max_streak then
        v_max_streak := v_temp_streak;
      end if;
      v_temp_streak := 1;
    end if;
    v_prev_date := v_date;
  end loop;

  if v_temp_streak > v_max_streak then
    v_max_streak := v_temp_streak;
  end if;

  -- 2. Calculate current_streak going backwards from today/yesterday.
  if exists (
    select 1 from public.attendance 
    where student_id = p_student_id and date = v_today and status = 'PRESENT'
  ) then
    v_date := v_today;
  elsif exists (
    select 1 from public.attendance 
    where student_id = p_student_id and date = v_today - 1 and status = 'PRESENT'
  ) then
    v_date := v_today - 1;
  else
    v_date := null;
  end if;

  if v_date is not null then
    loop
      exit when not exists (
        select 1 from public.attendance 
        where student_id = p_student_id and date = v_date and status = 'PRESENT'
      );
      v_current_streak := v_current_streak + 1;
      v_date := v_date - 1;
    end loop;
  end if;

  -- Store current bypass state, set config, update users table
  v_bypass_prev := coalesce(current_setting('my.bypass_lock', true), 'false');
  perform set_config('my.bypass_lock', 'true', true);

  update public.users
  set current_streak = v_current_streak,
      max_streak = v_max_streak
  where id = p_student_id;

  perform set_config('my.bypass_lock', v_bypass_prev, true);
end;
$$;

-- Trigger function
create or replace function public.on_attendance_change()
returns trigger
language plpgsql
security definer
set search_path = public, pg_temp
as $$
begin
  if tg_op = 'DELETE' then
    perform public.recalculate_student_streaks(old.student_id);
    return old;
  else
    perform public.recalculate_student_streaks(new.student_id);
    return new;
  end if;
end;
$$;

-- Trigger
drop trigger if exists attendance_streak_trigger on public.attendance;
create trigger attendance_streak_trigger
after insert or update or delete
on public.attendance
for each row
execute function public.on_attendance_change();

-- Initialize streaks for all existing students
do $$
declare
  v_student_id uuid;
begin
  for v_student_id in select id from public.users where role = 'STUDENT' loop
    perform public.recalculate_student_streaks(v_student_id);
  end loop;
end;
$$;
