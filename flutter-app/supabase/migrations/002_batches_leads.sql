-- ── batches table ────────────────────────────────────────────────────────────

create table if not exists public.batches (
  id            uuid default gen_random_uuid() primary key,
  name          text not null,
  trainer_id    uuid references public.users(id) on delete set null,
  schedule_time text not null,           -- '06:00'
  days_of_week  text[] not null default '{}',
  capacity      integer not null default 20,
  status        text not null default 'ACTIVE'
                  check (status in ('ACTIVE', 'PAUSED', 'CANCELLED')),
  location_lat  double precision,
  location_lng  double precision,
  created_at    timestamptz not null default now(),
  updated_at    timestamptz not null default now()
);

create or replace trigger batches_updated_at
  before update on public.batches
  for each row execute procedure public.set_updated_at();

alter table public.batches enable row level security;

-- All authenticated users may read batches (students see their schedule).
create policy "batches_select_auth" on public.batches
  for select using (auth.uid() is not null);

-- Admins and the assigned trainer may update a batch.
create policy "batches_update_own_or_admin" on public.batches
  for update using (
    trainer_id = auth.uid()
    or exists (
      select 1 from public.users u
      where u.id = auth.uid() and u.role = 'ADMIN'
    )
  );

-- Admins and trainers may create batches.
create policy "batches_insert" on public.batches
  for insert with check (
    exists (
      select 1 from public.users u
      where u.id = auth.uid() and u.role in ('ADMIN', 'TRAINER')
    )
  );

-- ── leads table ───────────────────────────────────────────────────────────────

create table if not exists public.leads (
  id                uuid default gen_random_uuid() primary key,
  name              text not null,
  phone             text,
  email             text,
  source            text
                      check (source in (
                        'WALK_IN', 'REFERRAL', 'INSTAGRAM',
                        'FACEBOOK', 'GOOGLE', 'OTHER'
                      )),
  pipeline_status   text not null default 'NEW'
                      check (pipeline_status in (
                        'NEW', 'CONSULTATION', 'ADMITTED', 'LOST'
                      )),
  notes             text,
  converted_user_id uuid references public.users(id) on delete set null,
  created_by        uuid references public.users(id) on delete set null,
  created_at        timestamptz not null default now(),
  updated_at        timestamptz not null default now()
);

create or replace trigger leads_updated_at
  before update on public.leads
  for each row execute procedure public.set_updated_at();

alter table public.leads enable row level security;

-- Only admins can manage leads.
create policy "leads_select_admin" on public.leads
  for select using (
    exists (
      select 1 from public.users u
      where u.id = auth.uid() and u.role = 'ADMIN'
    )
  );

create policy "leads_insert_admin" on public.leads
  for insert with check (
    exists (
      select 1 from public.users u
      where u.id = auth.uid() and u.role = 'ADMIN'
    )
  );

create policy "leads_update_admin" on public.leads
  for update using (
    exists (
      select 1 from public.users u
      where u.id = auth.uid() and u.role = 'ADMIN'
    )
  );
