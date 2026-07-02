-- 042_certificate_automation.sql
-- ─────────────────────────────────────────────────────────────────────────────
-- Owner-confirmed PRD decisions #33/#34 — certificate auto-issuance:
--   • Auto-issue once a student completes a plan's defined program length
--     (a per-plan "duration to certify", distinct from the plan's billing
--     duration_days) AND has >=80% attendance over that window.
--   • Multiple certificates per student, one per completed program/plan —
--     a regular membership plan and each purchased special-class add-on
--     each earn their own independent certificate track.
--   • The program-completion clock starts at the first PAID payment for
--     that plan (a paying member), never from lead/trial activity.
--
-- Reactive design note: this fires from the attendance trigger (checked
-- whenever a PRESENT day is recorded), matching this schema's existing
-- trigger-driven conventions — there's no pg_cron/scheduled-job
-- infrastructure in this project yet (see Phase 6 for the same gap
-- affecting renewal reminders). This means a student who becomes eligible
-- without any further attendance activity (e.g. they simply stop coming
-- right after crossing the duration+80% line) won't retroactively trigger
-- issuance. `check_and_issue_certificate` is also exposed standalone so a
-- future scheduled job can sweep all students once cron is set up.
--
-- Caveat: because the check runs per-row on whatever attendance rows exist
-- at that instant, bulk-backdating a student's attendance history out of
-- chronological order (e.g. an admin data-fix inserting many past rows in
-- one go) could evaluate the 80% rate against a partial view mid-batch and
-- issue prematurely. Day-to-day operation (attendance marked for "today"
-- on today) isn't affected, since by the time the duration gate opens, all
-- earlier days were already recorded on their own real days.
--
-- Scope note: "add-on expiry, fully independent" is implemented here as
-- the add-on's own program window (paid_at + certify_after_days) stored on
-- its certificate record — not a full concurrent multi-plan active-
-- membership system (that would need restructuring users.current_plan_id
-- from singular to a proper many-to-many enrollment table, a materially
-- bigger change left for a follow-up).
-- ─────────────────────────────────────────────────────────────────────────────

alter table public.plans
  add column if not exists certify_after_days integer,
  add column if not exists is_addon boolean not null default false;

comment on column public.plans.certify_after_days is
  'Program length (days) after which a student on this plan is eligible for '
  'auto-issued certification, measured from their first PAID payment for the '
  'plan. Null = no auto-certification for this plan.';

alter table public.certificates
  add column if not exists plan_id uuid references public.plans(id),
  add column if not exists expiry_date date,
  add column if not exists auto_issued boolean not null default false;

create unique index if not exists idx_certificates_student_plan_unique
  on public.certificates (student_id, plan_id)
  where plan_id is not null;

-- ── check_and_issue_certificate ──────────────────────────────────────────────
create or replace function public.check_and_issue_certificate(
  p_student_id uuid,
  p_plan_id    uuid
)
returns public.certificates
language plpgsql
security definer
set search_path = public, pg_temp
as $$
declare
  v_plan    public.plans;
  v_start   date;
  v_present int;
  v_absent  int;
  v_rate    numeric;
  v_cert    public.certificates;
begin
  select * into v_plan from public.plans where id = p_plan_id;
  if v_plan.id is null or v_plan.certify_after_days is null then
    return null;
  end if;

  select * into v_cert
  from public.certificates where student_id = p_student_id and plan_id = p_plan_id;
  if v_cert.id is not null then
    return v_cert; -- already issued, one per program
  end if;

  select min(paid_at)::date into v_start
  from public.payments
  where student_id = p_student_id and plan_id = p_plan_id and status = 'PAID';

  if v_start is null or current_date < v_start + v_plan.certify_after_days then
    return null; -- not a paying member on this plan yet, or duration not complete
  end if;

  select
    count(*) filter (where status = 'PRESENT'),
    count(*) filter (where status = 'ABSENT')
  into v_present, v_absent
  from public.attendance
  where student_id = p_student_id
    and date between v_start and (v_start + v_plan.certify_after_days);

  if v_present + v_absent = 0 then
    return null;
  end if;

  v_rate := v_present::numeric / (v_present + v_absent);
  if v_rate < 0.8 then
    return null;
  end if;

  insert into public.certificates
    (student_id, plan_id, title, programme, issued_on, auto_issued, expiry_date)
  values (
    p_student_id,
    p_plan_id,
    'Certificate of Completion',
    coalesce(nullif(array_to_string(v_plan.programs, ' & '), ''), v_plan.name),
    current_date,
    true,
    case when v_plan.is_addon then v_start + v_plan.certify_after_days else null end
  )
  on conflict (student_id, plan_id) where plan_id is not null do nothing
  returning * into v_cert;

  if v_cert.id is not null then
    insert into public.notifications (user_id, kind, title, body)
    values (
      p_student_id,
      'GENERAL',
      'Certificate issued!',
      format('You earned your certificate for %s.', v_plan.name)
    );
  end if;

  return v_cert;
end;
$$;

revoke all on function public.check_and_issue_certificate(uuid, uuid) from public, anon;
grant execute on function public.check_and_issue_certificate(uuid, uuid) to authenticated, service_role;

-- ── Reactive trigger: check on every PRESENT attendance mark ────────────────
create or replace function public.trigger_certificate_check()
returns trigger
language plpgsql
security definer
set search_path = public, pg_temp
as $$
declare
  v_plan_id uuid;
begin
  if new.status <> 'PRESENT' then
    return new;
  end if;

  for v_plan_id in
    select distinct plan_id from public.payments
    where student_id = new.student_id and plan_id is not null and status = 'PAID'
  loop
    perform public.check_and_issue_certificate(new.student_id, v_plan_id);
  end loop;

  return new;
end;
$$;

drop trigger if exists attendance_certificate_check on public.attendance;
create trigger attendance_certificate_check
  after insert or update of status on public.attendance
  for each row execute function public.trigger_certificate_check();
