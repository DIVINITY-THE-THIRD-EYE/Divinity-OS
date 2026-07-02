-- 041_trials_and_lead_conversion.sql
-- ─────────────────────────────────────────────────────────────────────────────
-- Owner-confirmed PRD decisions #31 (lead conversion) and #32 (trial
-- tracking):
--   • Trial-class attendance is tracked separately from the member
--     `attendance` table, tied to a lead (a lead has no auth account).
--   • Lead conversion is valid via three paths: Admin, Trainer (e.g. closes
--     the sale after running the trial themselves), or the lead
--     self-converting via their own sign-up + payment.
-- ─────────────────────────────────────────────────────────────────────────────

-- ── trial_attendances ────────────────────────────────────────────────────────
create table if not exists public.trial_attendances (
  id           uuid primary key default gen_random_uuid(),
  lead_id      uuid not null references public.leads(id) on delete cascade,
  batch_id     uuid references public.batches(id) on delete set null,
  attended_on  date not null default (now() at time zone 'Asia/Kolkata')::date,
  marked_by    uuid references public.users(id) on delete set null,
  notes        text,
  created_at   timestamptz not null default now()
);

create index if not exists idx_trial_attendances_lead on public.trial_attendances (lead_id);

grant select, insert, update, delete on public.trial_attendances to authenticated, service_role;

alter table public.trial_attendances enable row level security;

-- Trial classes are run by Trainer or Admin (leads have no login of their own).
create policy "trial_attendances_select_staff"
  on public.trial_attendances for select
  using (
    exists (select 1 from public.users u where u.id = auth.uid() and u.role in ('TRAINER','ADMIN'))
  );

create policy "trial_attendances_insert_staff"
  on public.trial_attendances for insert
  with check (
    exists (select 1 from public.users u where u.id = auth.uid() and u.role in ('TRAINER','ADMIN'))
  );

create policy "trial_attendances_delete_admin"
  on public.trial_attendances for delete
  using (public.is_admin(auth.uid()));

-- ── Trainer needs to see leads to run/convert a trial (was Admin-only) ──────
create policy "leads_select_trainer"
  on public.leads for select
  using (exists (select 1 from public.users u where u.id = auth.uid() and u.role = 'TRAINER'));

-- ── convert_lead_to_member: now callable by Admin OR Trainer ────────────────
create or replace function public.convert_lead_to_member(
  p_lead_id uuid,
  p_user_id uuid
)
returns public.leads
language plpgsql
security definer
set search_path = public, pg_temp
as $$
declare
  v_lead public.leads;
begin
  if not (public.is_admin(auth.uid()) or public.is_trainer(auth.uid())) then
    raise exception 'only admin or trainer staff can convert leads'
      using errcode = '42501';
  end if;

  -- A Trainer-initiated conversion still needs to set plan_status, which
  -- lock_privileged_fields() otherwise restricts to Admin only. This RPC is
  -- the trusted gate (already checked above), so bypass that check here —
  -- same pattern used by propagate_payment_status().
  perform set_config('my.bypass_lock', 'true', true);

  if not exists (select 1 from public.users where id = p_user_id) then
    raise exception 'user not found'
      using errcode = 'P0002';
  end if;

  update public.leads
  set pipeline_status = 'ADMITTED',
      converted_user_id = p_user_id,
      updated_at = now()
  where id = p_lead_id
  returning * into v_lead;

  if not found then
    raise exception 'lead not found'
      using errcode = 'P0002';
  end if;

  update public.users
  set plan_status = 'PENDING_ADMIN',
      updated_at = now()
  where id = p_user_id;

  return v_lead;
end;
$$;

-- ── self_convert_lead: the lead's own sign-up links their pipeline record ───
-- Doesn't touch plan_status (self-service signups start UNPAID like any
-- normal sign-up and become ACTIVE through the existing payment flow) —
-- this purely closes out the CRM pipeline record so it doesn't sit stale.
-- Matches by phone or email so a user can only link a lead that is
-- genuinely theirs.
create or replace function public.self_convert_lead()
returns public.leads
language plpgsql
security definer
set search_path = public, pg_temp
as $$
declare
  v_uid  uuid := auth.uid();
  v_lead public.leads;
begin
  if v_uid is null then
    raise exception 'authentication required' using errcode = '42501';
  end if;

  update public.leads l
  set pipeline_status = 'ADMITTED',
      converted_user_id = v_uid,
      updated_at = now()
  from public.users u
  where u.id = v_uid
    and l.pipeline_status <> 'ADMITTED'
    and (
      (l.phone is not null and l.phone = u.phone)
      or (l.email is not null and l.email = u.email)
    )
  returning l.* into v_lead;

  return v_lead; -- null if no matching lead — a fine no-op for a walk-in with no lead record
end;
$$;

revoke all on function public.self_convert_lead() from public, anon;
grant execute on function public.self_convert_lead() to authenticated;
