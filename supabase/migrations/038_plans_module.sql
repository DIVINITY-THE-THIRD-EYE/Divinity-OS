-- 038_plans_module.sql
-- Admin-manageable Plans module. Replaces hardcoded plan pricing with a real
-- table so Admin can create/edit/retire plans without a code deploy.

create table if not exists public.plans (
  id                        uuid primary key default gen_random_uuid(),
  name                      text not null,
  price                     numeric(10,2) not null check (price >= 0),
  duration_days             integer not null check (duration_days > 0),
  discount_percent          numeric(5,2) not null default 0
                              check (discount_percent >= 0 and discount_percent <= 100),
  coupon_code               text,
  programs                  text[] not null default '{}',
  max_leave_days_per_month  integer not null default 4 check (max_leave_days_per_month >= 0),
  is_active                 boolean not null default true,
  created_by                uuid references public.users(id),
  created_at                timestamptz not null default now(),
  updated_at                timestamptz not null default now()
);

create index if not exists idx_plans_is_active on public.plans (is_active);

alter table public.plans enable row level security;

-- Everyone (any authenticated role) can read active plans to pick one at
-- signup/renewal; Admin can also see retired ones for history/reporting.
create policy "read_active_plans_or_admin_all"
  on public.plans for select
  using (is_active = true or public.is_admin(auth.uid()));

create policy "admins_manage_plans"
  on public.plans for all
  using (public.is_admin(auth.uid()))
  with check (public.is_admin(auth.uid()));

create or replace trigger plans_updated_at
  before update on public.plans
  for each row execute function public.set_updated_at();

-- ── Link payments to a plan, and freeze the price actually paid ────────────
-- (grandfathering: a plan's price can change later without altering
-- historical receipts, because the paid amount already lives on `payments`).

alter table public.payments
  add column if not exists plan_id uuid references public.plans(id);

comment on column public.payments.plan_id is
  'FK to plans. payments.amount is the price actually charged (may differ '
  'from plans.price due to grandfathering or an admin override).';
