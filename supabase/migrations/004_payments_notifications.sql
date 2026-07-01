-- 004_payments_notifications.sql

-- ── Payments ──────────────────────────────────────────────────────────────────

create table if not exists public.payments (
  id              uuid primary key default gen_random_uuid(),
  student_id      uuid not null references public.users(id) on delete cascade,
  recorded_by     uuid references public.users(id),
  amount          numeric(10,2) not null check (amount > 0),
  currency        text not null default 'INR',
  -- CASH | UPI | BANK_TRANSFER | RAZORPAY
  payment_method  text not null default 'CASH',
  -- PENDING | PAID | FAILED | REFUNDED
  status          text not null default 'PAID',
  reference_number text,
  notes           text,
  razorpay_order_id   text,
  razorpay_payment_id text,
  paid_at         timestamptz not null default now(),
  created_at      timestamptz not null default now()
);

alter table public.payments enable row level security;

create policy "students_read_own_payments"
  on public.payments for select
  using (auth.uid() = student_id);

create policy "admins_all_payments"
  on public.payments for all
  using (
    exists (
      select 1 from public.users
      where id = auth.uid() and role = 'ADMIN'
    )
  )
  with check (
    exists (
      select 1 from public.users
      where id = auth.uid() and role = 'ADMIN'
    )
  );

-- ── Notifications ─────────────────────────────────────────────────────────────

create table if not exists public.notifications (
  id         uuid primary key default gen_random_uuid(),
  user_id    uuid not null references public.users(id) on delete cascade,
  -- GENERAL | LEAVE_APPROVED | LEAVE_REJECTED | PAYMENT_DUE | BATCH_UPDATE | ATTENDANCE
  kind       text not null default 'GENERAL',
  title      text not null,
  body       text,
  is_read    boolean not null default false,
  metadata   jsonb,
  created_at timestamptz not null default now()
);

alter table public.notifications enable row level security;

create policy "users_read_own_notifications"
  on public.notifications for select
  using (auth.uid() = user_id);

create policy "users_update_own_notifications"
  on public.notifications for update
  using (auth.uid() = user_id);

create policy "admins_trainers_insert_notifications"
  on public.notifications for insert
  with check (
    exists (
      select 1 from public.users
      where id = auth.uid() and role in ('ADMIN', 'TRAINER')
    )
  );

create policy "admins_read_all_notifications"
  on public.notifications for select
  using (
    exists (
      select 1 from public.users
      where id = auth.uid() and role = 'ADMIN'
    )
  );
