-- ── holidays ──────────────────────────────────────────────────────────────────

create table if not exists public.holidays (
  id         uuid default gen_random_uuid() primary key,
  date       date not null unique,
  name       text not null,
  created_at timestamptz not null default now()
);

alter table public.holidays enable row level security;

-- All authenticated users can read holidays (students see them on their calendar).
create policy "holidays_select_auth" on public.holidays
  for select using (auth.uid() is not null);

-- Only admins can manage holidays.
create policy "holidays_insert_admin" on public.holidays
  for insert with check (
    exists (
      select 1 from public.users u
      where u.id = auth.uid() and u.role = 'ADMIN'
    )
  );

create policy "holidays_delete_admin" on public.holidays
  for delete using (
    exists (
      select 1 from public.users u
      where u.id = auth.uid() and u.role = 'ADMIN'
    )
  );

-- ── therapeutic_logs ──────────────────────────────────────────────────────────

create table if not exists public.therapeutic_logs (
  id         uuid default gen_random_uuid() primary key,
  student_id uuid not null references public.users(id) on delete cascade,
  trainer_id uuid references public.users(id) on delete set null,
  note       text not null,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create or replace trigger therapeutic_logs_updated_at
  before update on public.therapeutic_logs
  for each row execute procedure public.set_updated_at();

alter table public.therapeutic_logs enable row level security;

-- Students see their own logs; trainers and admins see all.
create policy "therapeutic_logs_select" on public.therapeutic_logs
  for select using (
    student_id = auth.uid()
    or exists (
      select 1 from public.users u
      where u.id = auth.uid() and u.role in ('TRAINER', 'ADMIN')
    )
  );

-- Trainers and admins can add logs.
create policy "therapeutic_logs_insert_staff" on public.therapeutic_logs
  for insert with check (
    exists (
      select 1 from public.users u
      where u.id = auth.uid() and u.role in ('TRAINER', 'ADMIN')
    )
  );

-- Trainers can only delete their own notes; admins can delete any.
create policy "therapeutic_logs_delete" on public.therapeutic_logs
  for delete using (
    trainer_id = auth.uid()
    or exists (
      select 1 from public.users u
      where u.id = auth.uid() and u.role = 'ADMIN'
    )
  );
