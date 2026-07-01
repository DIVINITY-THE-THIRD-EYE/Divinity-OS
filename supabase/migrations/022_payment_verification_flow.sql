-- 022_payment_verification_flow.sql
-- ─────────────────────────────────────────────────────────────────────────────
-- M2 — Payment Verification State Machine
--
-- 1. Add plan_expiration_date column to public.payments.
-- 2. Define before insert/update trigger to process automated state transitions.
-- 3. Define after insert/update trigger to propagate user plan status.
-- 4. Define field lock trigger to prevent students from updating payments and 
--    restrict trainers to only modifying receipt_given_by_trainer.
-- 5. Add RLS policies for trainers to read/update payments.
-- ─────────────────────────────────────────────────────────────────────────────

-- ── 1. Schema Upgrades ────────────────────────────────────────────────────────
alter table public.payments
  add column if not exists plan_expiration_date date;

-- ── 2. Before Insert/Update State Processing ──────────────────────────────────
create or replace function public.process_payment_transitions()
returns trigger
language plpgsql
security definer
set search_path = public, pg_temp
as $$
begin
  -- If payment is CASH and logged in user is admin, auto-approve
  if new.payment_method = 'CASH' and public.is_admin(auth.uid()) then
    new.admin_approved := true;
  end if;

  -- Stage 5 activation transition:
  -- If both admin approved and trainer confirmed, status is PAID and paid_at is now.
  if new.admin_approved = true and new.receipt_given_by_trainer = true and new.status = 'PENDING' then
    new.status := 'PAID';
    new.paid_at := now();
  end if;

  return new;
end;
$$;

drop trigger if exists payments_before_trigger on public.payments;
create trigger payments_before_trigger
  before insert or update on public.payments
  for each row execute function public.process_payment_transitions();

-- ── 3. After Insert/Update Propagation Trigger ────────────────────────────────
create or replace function public.propagate_payment_status()
returns trigger
language plpgsql
security definer
set search_path = public, pg_temp
as $$
begin
  -- Set transaction setting to bypass lock trigger on public.users
  perform set_config('my.bypass_lock', 'true', true);

  -- Stage 3: Student UPI/Bank Transfer submission -> PENDING_ADMIN
  if new.status = 'PENDING' and new.admin_approved = false and new.receipt_given_by_trainer = false then
    update public.users
    set plan_status = 'PENDING_ADMIN'
    where id = new.student_id;

  -- Stage 4: Admin approved, waiting for trainer confirmation -> PENDING_TRAINER
  elsif new.admin_approved = true and new.receipt_given_by_trainer = false and new.status = 'PENDING' then
    update public.users
    set plan_status = 'PENDING_TRAINER'
    where id = new.student_id;

  -- Stage 5: Active membership -> ACTIVE
  elsif new.admin_approved = true and new.receipt_given_by_trainer = true and new.status = 'PAID' then
    update public.users
    set plan_status = 'ACTIVE',
        expiration_date = coalesce(new.plan_expiration_date, expiration_date, (now() + interval '30 days')::date)
    where id = new.student_id;

  -- Rejection/Failures -> UNPAID
  elsif new.status = 'FAILED' then
    update public.users
    set plan_status = 'UNPAID'
    where id = new.student_id;
  end if;

  return new;
end;
$$;

drop trigger if exists payments_after_trigger on public.payments;
create trigger payments_after_trigger
  after insert or update on public.payments
  for each row execute function public.propagate_payment_status();

-- ── 4. Lock Payments Write Fields Trigger ─────────────────────────────────────
create or replace function public.lock_payment_fields()
returns trigger
language plpgsql
security definer
set search_path = public, pg_temp
as $$
begin
  -- Server / Migration context: allow
  if auth.uid() is null then
    return new;
  end if;

  -- Admin can update anything: allow
  if public.is_admin(auth.uid()) then
    return new;
  end if;

  -- Student cannot update payments at all
  if not public.is_trainer(auth.uid()) then
    raise exception 'Students cannot update payment records'
      using errcode = '42501';
  end if;

  -- Trainer context:
  -- Trainers can ONLY change receipt_given_by_trainer.
  -- Any change to other fields is blocked.
  -- Note: we allow status to transition to 'PAID' when receipt_given_by_trainer is set to true.
  if old.student_id is distinct from new.student_id
     or old.recorded_by is distinct from new.recorded_by
     or old.amount is distinct from new.amount
     or old.currency is distinct from new.currency
     or old.payment_method is distinct from new.payment_method
     or old.reference_number is distinct from new.reference_number
     or old.notes is distinct from new.notes
     or old.screenshot_url is distinct from new.screenshot_url
     or old.admin_approved is distinct from new.admin_approved
     or old.plan_expiration_date is distinct from new.plan_expiration_date
     or (old.status is distinct from new.status and not (old.status = 'PENDING' and new.status = 'PAID' and new.receipt_given_by_trainer = true)) then
    raise exception 'Trainers can only update the receipt confirmation status'
      using errcode = '42501';
  end if;

  -- Trainer can only set receipt_given_by_trainer to true (cannot undo back to false)
  if old.receipt_given_by_trainer and not new.receipt_given_by_trainer then
    raise exception 'Trainer receipt confirmation cannot be undone'
      using errcode = '42501';
  end if;

  return new;
end;
$$;

drop trigger if exists payments_lock_trigger on public.payments;
create trigger payments_lock_trigger
  before update on public.payments
  for each row execute function public.lock_payment_fields();

-- ── 5. RLS Policies for Trainer Access ────────────────────────────────────────
drop policy if exists "trainers_read_all_payments" on public.payments;
create policy "trainers_read_all_payments" on public.payments
  for select using (
    public.is_trainer(auth.uid())
  );

drop policy if exists "trainers_update_payments" on public.payments;
create policy "trainers_update_payments" on public.payments
  for update using (
    public.is_trainer(auth.uid())
  ) with check (
    public.is_trainer(auth.uid())
  );
