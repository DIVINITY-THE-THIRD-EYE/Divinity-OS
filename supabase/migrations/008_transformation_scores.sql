-- 008_transformation_scores.sql

create table if not exists public.transformation_scores (
  id              uuid primary key default gen_random_uuid(),
  student_id      uuid not null references public.users(id) on delete cascade,
  recorded_by     uuid references public.users(id) on delete set null,
  consistency     numeric(4,1) not null check (consistency >= 0.0 and consistency <= 10.0),
  intensity       numeric(4,1) not null check (intensity >= 0.0 and intensity <= 10.0),
  mindfulness     numeric(4,1) not null check (mindfulness >= 0.0 and mindfulness <= 10.0),
  recovery        numeric(4,1) not null check (recovery >= 0.0 and recovery <= 10.0),
  score           numeric(4,1) not null check (score >= 0.0 and score <= 10.0),
  week_start_date date not null,
  created_at      timestamptz not null default now(),
  updated_at      timestamptz not null default now(),
  unique(student_id, week_start_date)
);

-- Trigger to update updated_at
create or replace trigger transformation_scores_updated_at
  before update on public.transformation_scores
  for each row execute procedure public.set_updated_at();

-- Enable Row-Level Security
alter table public.transformation_scores enable row level security;

-- Policies
create policy "students_read_own_scores"
  on public.transformation_scores for select
  using (auth.uid() = student_id);

create policy "admins_all_scores"
  on public.transformation_scores for all
  using (
    exists (
      select 1 from public.users
      where id = auth.uid() and role = 'ADMIN'
    )
  );

create policy "trainers_all_scores"
  on public.transformation_scores for all
  using (
    exists (
      select 1 from public.users
      where id = auth.uid() and role = 'TRAINER'
    )
  );
