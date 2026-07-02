-- 043_notifications_and_admin_ops.sql
-- ─────────────────────────────────────────────────────────────────────────────
-- Owner-confirmed PRD decisions #14 (audit log), #21 (drop-off risk alerts),
-- #35/#36 (renewal reminders), #43 (admin broadcast notifications).
--
-- Delivery note: like every other notification kind already in this schema
-- (LEAVE_APPROVED, PAYMENT_DUE, etc.), these write to public.notifications
-- for the in-app notification center only — there's no FCM push wiring in
-- this backend yet (that needs a Firebase service account + Edge Function,
-- an owner-account prerequisite, not a code gap).
-- ─────────────────────────────────────────────────────────────────────────────

-- ── Audit log (sensitive actions only, append-only) ──────────────────────────
create table if not exists public.audit_log (
  id           uuid primary key default gen_random_uuid(),
  actor_id     uuid references public.users(id) on delete set null,
  action       text not null,
  target_table text not null,
  target_id    uuid,
  details      jsonb,
  created_at   timestamptz not null default now()
);

create index if not exists idx_audit_log_created_at on public.audit_log (created_at desc);

-- Append-only: Admin can read, nobody gets direct write access (writes only
-- happen via the SECURITY DEFINER trigger below, which runs as the table
-- owner regardless of the calling role).
grant select on public.audit_log to authenticated, service_role;

alter table public.audit_log enable row level security;

create policy "audit_log_select_admin"
  on public.audit_log for select
  using (public.is_admin(auth.uid()));

create or replace function public.log_audit_event()
returns trigger
language plpgsql
security definer
set search_path = public, pg_temp
as $$
declare
  -- This one function is shared across payments/users/plans triggers, each
  -- with a different row shape. Direct dotted access like `new.admin_approved`
  -- errors ("record has no field") the moment NEW is bound to a row type
  -- that lacks it — Postgres does not guarantee short-circuiting field
  -- resolution across an IF/ELSIF chain's branches. Going through jsonb
  -- sidesteps that: a missing key just evaluates to NULL.
  v_new     jsonb := to_jsonb(new);
  v_old     jsonb := to_jsonb(old);
  v_action  text;
  v_details jsonb;
begin
  if tg_table_name = 'payments' and (v_new->>'admin_approved') is distinct from (v_old->>'admin_approved') then
    v_action := 'PAYMENT_VERIFIED';
    v_details := jsonb_build_object(
      'admin_approved', v_new->'admin_approved',
      'student_id', v_new->'student_id',
      'amount', v_new->'amount'
    );
  elsif tg_table_name = 'users' and (v_new->>'role') is distinct from (v_old->>'role') then
    v_action := 'ROLE_CHANGED';
    v_details := jsonb_build_object('from', v_old->'role', 'to', v_new->'role');
  elsif tg_table_name = 'users' and (v_new->>'is_active') is distinct from (v_old->>'is_active') then
    v_action := case when (v_new->>'is_active')::boolean then 'STUDENT_REACTIVATED' else 'STUDENT_SUSPENDED' end;
    v_details := jsonb_build_object('user_id', v_new->'id');
  elsif tg_table_name = 'plans' and (v_new->>'price') is distinct from (v_old->>'price') then
    v_action := 'PLAN_PRICE_CHANGED';
    v_details := jsonb_build_object('plan_id', v_new->'id', 'from', v_old->'price', 'to', v_new->'price');
  else
    return new;
  end if;

  insert into public.audit_log (actor_id, action, target_table, target_id, details)
  values (auth.uid(), v_action, tg_table_name, (v_new->>'id')::uuid, v_details);

  return new;
end;
$$;

drop trigger if exists payments_audit_log on public.payments;
create trigger payments_audit_log
  after update of admin_approved on public.payments
  for each row execute function public.log_audit_event();

drop trigger if exists users_role_audit_log on public.users;
create trigger users_role_audit_log
  after update of role on public.users
  for each row execute function public.log_audit_event();

drop trigger if exists users_active_audit_log on public.users;
create trigger users_active_audit_log
  after update of is_active on public.users
  for each row execute function public.log_audit_event();

drop trigger if exists plans_price_audit_log on public.plans;
create trigger plans_price_audit_log
  after update of price on public.plans
  for each row execute function public.log_audit_event();

-- ── Drop-off risk alerts ──────────────────────────────────────────────────────
-- Fires when EITHER: 3 of the student's last 3 attendance records are
-- ABSENT (an ON_LEAVE-marked day never counts — see 039, approved leave
-- flips status to ON_LEAVE, not ABSENT, so "no leave request filed" is
-- automatically satisfied by only counting ABSENT rows), OR the PRESENT
-- rate over the trailing 2 weeks is under 50%. 7-day cooldown per student
-- to avoid re-notifying daily once already flagged.
create or replace function public.check_dropoff_risk()
returns trigger
language plpgsql
security definer
set search_path = public, pg_temp
as $$
declare
  v_consecutive_absent int;
  v_present_2wk        int;
  v_total_2wk          int;
  v_rate               numeric;
  v_already_flagged    boolean;
  v_trainer_id         uuid;
  v_admin_id           uuid;
begin
  if new.status <> 'ABSENT' then
    return new;
  end if;

  select count(*) into v_consecutive_absent
  from (
    select status from public.attendance
    where student_id = new.student_id and date <= new.date
    order by date desc
    limit 3
  ) last3
  where status = 'ABSENT';

  select
    count(*) filter (where status = 'PRESENT'),
    count(*)
  into v_present_2wk, v_total_2wk
  from public.attendance
  where student_id = new.student_id
    and date between (new.date - 13) and new.date
    and status in ('PRESENT', 'ABSENT');

  v_rate := case when v_total_2wk > 0 then v_present_2wk::numeric / v_total_2wk else null end;

  if not (v_consecutive_absent = 3 or (v_rate is not null and v_rate < 0.5)) then
    return new;
  end if;

  select exists(
    select 1 from public.notifications
    where kind = 'DROPOFF_RISK'
      and metadata->>'student_id' = new.student_id::text
      and created_at > now() - interval '7 days'
  ) into v_already_flagged;

  if v_already_flagged then
    return new;
  end if;

  for v_admin_id in select id from public.users where role = 'ADMIN' loop
    insert into public.notifications (user_id, kind, title, body, metadata)
    values (
      v_admin_id, 'DROPOFF_RISK', 'Drop-off risk',
      'A student may be at risk of dropping off — slipping attendance.',
      jsonb_build_object('student_id', new.student_id)
    );
  end loop;

  for v_trainer_id in
    select distinct b.trainer_id
    from public.enrollments e join public.batches b on b.id = e.batch_id
    where e.student_id = new.student_id and b.trainer_id is not null
  loop
    insert into public.notifications (user_id, kind, title, body, metadata)
    values (
      v_trainer_id, 'DROPOFF_RISK', 'Drop-off risk',
      'A student in your batch may be at risk of dropping off — slipping attendance.',
      jsonb_build_object('student_id', new.student_id)
    );
  end loop;

  return new;
end;
$$;

drop trigger if exists attendance_dropoff_check on public.attendance;
create trigger attendance_dropoff_check
  after insert or update of status on public.attendance
  for each row execute function public.check_dropoff_risk();

-- ── Renewal reminders (7-day and 1-day before expiry) ────────────────────────
create or replace function public.send_renewal_reminders()
returns integer
language plpgsql
security definer
set search_path = public, pg_temp
as $$
declare
  v_user  record;
  v_count int := 0;
begin
  for v_user in
    select id, expiration_date from public.users
    where plan_status = 'ACTIVE'
      and expiration_date in (current_date + 7, current_date + 1)
  loop
    if not exists (
      select 1 from public.notifications
      where user_id = v_user.id
        and kind = 'PAYMENT_DUE'
        and metadata->>'expiration_date' = v_user.expiration_date::text
    ) then
      insert into public.notifications (user_id, kind, title, body, metadata)
      values (
        v_user.id,
        'PAYMENT_DUE',
        case when v_user.expiration_date - current_date = 1
          then 'Membership expires tomorrow'
          else 'Membership expires in 7 days'
        end,
        format('Your membership expires on %s. Renew now to avoid losing access.', v_user.expiration_date),
        jsonb_build_object('expiration_date', v_user.expiration_date)
      );
      v_count := v_count + 1;
    end if;
  end loop;
  return v_count;
end;
$$;

revoke all on function public.send_renewal_reminders() from public, anon, authenticated;
grant execute on function public.send_renewal_reminders() to service_role;

-- Schedule daily at 08:00 IST (02:30 UTC). pg_cron is available on Supabase's
-- managed Postgres; if this project's tier/environment doesn't support it,
-- this statement is safe to skip — send_renewal_reminders() still works
-- standalone for a manual/external scheduler to call instead.
do $$
begin
  create extension if not exists pg_cron;
  perform cron.schedule(
    'daily-renewal-reminders',
    '30 2 * * *',
    $cron$select public.send_renewal_reminders();$cron$
  );
exception when others then
  raise notice 'pg_cron not available in this environment — send_renewal_reminders() must be scheduled externally: %', sqlerrm;
end;
$$;

-- ── Admin broadcast notifications ────────────────────────────────────────────
create or replace function public.send_broadcast(
  p_target text, -- 'STUDENTS' | 'TRAINERS' | 'ALL'
  p_title  text,
  p_body   text
)
returns integer
language plpgsql
security definer
set search_path = public, pg_temp
as $$
declare
  v_count int;
begin
  if not public.is_admin(auth.uid()) then
    raise exception 'only admin can send broadcasts' using errcode = '42501';
  end if;
  if p_target not in ('STUDENTS', 'TRAINERS', 'ALL') then
    raise exception 'p_target must be STUDENTS, TRAINERS, or ALL' using errcode = '22023';
  end if;

  insert into public.notifications (user_id, kind, title, body)
  select id, 'GENERAL', p_title, p_body
  from public.users
  where (p_target = 'ALL')
     or (p_target = 'STUDENTS' and role = 'STUDENT')
     or (p_target = 'TRAINERS' and role = 'TRAINER');

  get diagnostics v_count = row_count;
  return v_count;
end;
$$;

revoke all on function public.send_broadcast(text, text, text) from public, anon;
grant execute on function public.send_broadcast(text, text, text) to authenticated;
