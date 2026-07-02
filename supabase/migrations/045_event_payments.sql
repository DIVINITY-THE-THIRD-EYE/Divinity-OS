-- 045_event_payments.sql
-- ─────────────────────────────────────────────────────────────────────────────
-- Owner-confirmed PRD decisions #37/#38 — paid events, reusing the existing
-- manual UPI QR + screenshot + Admin verification flow already built for
-- memberships. No new payment infrastructure: payments.event_id links a
-- payment to the event it's for, and the existing admin_approved +
-- receipt_given_by_trainer state machine (022) drives it to PAID exactly
-- like a membership payment — it just auto-registers the student for the
-- event instead of activating a membership.
-- ─────────────────────────────────────────────────────────────────────────────

alter table public.events
  add column if not exists is_free boolean not null default true,
  add column if not exists price   numeric(10,2);

alter table public.events
  add constraint events_price_required_if_paid
  check (is_free or (price is not null and price > 0));

alter table public.payments
  add column if not exists event_id uuid references public.events(id);

-- Only FREE events accept a direct self-RSVP insert. A paid event's
-- registration can only be created by the payment-approval trigger below
-- (SECURITY DEFINER, bypasses this policy) — never a bare client insert.
drop policy if exists "event_registrations_insert" on public.event_registrations;
create policy "event_registrations_insert" on public.event_registrations
  for insert with check (
    student_id = auth.uid()
    and exists (
      select 1 from public.events e
      where e.id = event_registrations.event_id
        and e.status = 'PUBLISHED'
        and e.is_free = true
    )
  );

-- Event payments never touch membership plan_status/expiration_date; on
-- full approval (admin + trainer receipt) they instead auto-register the
-- student for the event. Membership branches are unchanged.
create or replace function public.propagate_payment_status()
returns trigger
language plpgsql
security definer
set search_path = public, pg_temp
as $$
begin
  perform set_config('my.bypass_lock', 'true', true);

  if new.event_id is not null then
    if new.admin_approved = true and new.receipt_given_by_trainer = true and new.status = 'PAID' then
      insert into public.event_registrations (event_id, student_id)
      values (new.event_id, new.student_id)
      on conflict (event_id, student_id) do nothing;
    end if;
    return new;
  end if;

  if new.status = 'PENDING' and new.admin_approved = false and new.receipt_given_by_trainer = false then
    update public.users
    set plan_status = 'PENDING_ADMIN'
    where id = new.student_id;

  elsif new.admin_approved = true and new.receipt_given_by_trainer = false and new.status = 'PENDING' then
    update public.users
    set plan_status = 'PENDING_TRAINER'
    where id = new.student_id;

  elsif new.admin_approved = true and new.receipt_given_by_trainer = true and new.status = 'PAID' then
    update public.users
    set plan_status = 'ACTIVE',
        expiration_date = coalesce(new.plan_expiration_date, expiration_date, (now() + interval '30 days')::date),
        current_plan_id = coalesce(new.plan_id, current_plan_id)
    where id = new.student_id;

  elsif new.status = 'FAILED' then
    update public.users
    set plan_status = 'UNPAID'
    where id = new.student_id;
  end if;

  return new;
end;
$$;

-- Add event_id to the trainer field lock (a trainer confirming receipt
-- should never be able to also reassign a payment to a different event).
create or replace function public.lock_payment_fields()
returns trigger
language plpgsql
security definer
set search_path = public, pg_temp
as $$
begin
  if auth.uid() is null then
    return new;
  end if;

  if public.is_admin(auth.uid()) then
    return new;
  end if;

  if not public.is_trainer(auth.uid()) then
    raise exception 'Students cannot update payment records'
      using errcode = '42501';
  end if;

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
     or old.event_id is distinct from new.event_id
     or (old.status is distinct from new.status and not (old.status = 'PENDING' and new.status = 'PAID' and new.receipt_given_by_trainer = true)) then
    raise exception 'Trainers can only update the receipt confirmation status'
      using errcode = '42501';
  end if;

  if old.receipt_given_by_trainer and not new.receipt_given_by_trainer then
    raise exception 'Trainer receipt confirmation cannot be undone'
      using errcode = '42501';
  end if;

  return new;
end;
$$;
