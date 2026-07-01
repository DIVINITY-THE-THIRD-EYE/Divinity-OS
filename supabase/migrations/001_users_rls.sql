-- ── users table ─────────────────────────────────────────────────────────────
-- Mirrors auth.users (id = auth.uid()). Every column nullable except the
-- few needed for routing: role, plan_status.

create table if not exists public.users (
  id                     uuid references auth.users(id) on delete cascade primary key,
  name                   text,
  email                  text unique,
  phone                  text,
  role                   text not null default 'STUDENT'
                           check (role in ('STUDENT', 'TRAINER', 'ADMIN')),
  age                    integer,
  gender                 text
                           check (gender in ('MALE', 'FEMALE', 'OTHER', 'PREFER_NOT_TO_SAY')),
  emergency_contact_name  text,
  emergency_contact_phone text,
  primary_goal           text,
  injuries               text,
  medical_conditions     text,
  lifestyle_activity     text,
  plan_status            text not null default 'UNPAID'
                           check (plan_status in (
                             'UNPAID', 'PENDING_ADMIN', 'PENDING_TRAINER',
                             'ACTIVE', 'PAUSED', 'EXPIRED'
                           )),
  expiration_date        date,
  pause_start_date       date,
  current_streak         integer not null default 0,
  max_streak             integer not null default 0,
  fcm_token              text,
  onboarding_complete    boolean not null default false,
  avatar_url             text,
  created_at             timestamptz not null default now(),
  updated_at             timestamptz not null default now()
);

-- ── updated_at trigger ───────────────────────────────────────────────────────

create or replace function public.set_updated_at()
returns trigger language plpgsql as $$
begin
  new.updated_at = now();
  return new;
end;
$$;

create or replace trigger users_updated_at
  before update on public.users
  for each row execute procedure public.set_updated_at();

-- ── auto-create profile on signup ────────────────────────────────────────────

create or replace function public.handle_new_user()
returns trigger language plpgsql security definer
set search_path = public as $$
begin
  insert into public.users (id, email, phone, name)
  values (
    new.id,
    new.email,
    new.phone,
    coalesce(
      new.raw_user_meta_data->>'name',
      split_part(coalesce(new.email, ''), '@', 1)
    )
  )
  on conflict (id) do nothing;
  return new;
end;
$$;

create or replace trigger on_auth_user_created
  after insert on auth.users
  for each row execute procedure public.handle_new_user();

-- ── Row Level Security ───────────────────────────────────────────────────────

alter table public.users enable row level security;

-- Every user can read their own row.
create policy "users_select_own" on public.users
  for select using (auth.uid() = id);

-- Every user can update their own non-locked fields.
-- age and gender are locked at DB level after onboarding via an UPDATE policy
-- that checks onboarding_complete (enforced separately; see trigger below).
create policy "users_update_own" on public.users
  for update using (auth.uid() = id);

-- Trainers can read STUDENT rows (needed for attendance, progress).
create policy "trainers_select_students" on public.users
  for select using (
    role = 'STUDENT'
    and exists (
      select 1 from public.users u
      where u.id = auth.uid() and u.role = 'TRAINER'
    )
  );

-- Admins can read all rows.
create policy "admins_select_all" on public.users
  for select using (
    exists (
      select 1 from public.users u
      where u.id = auth.uid() and u.role = 'ADMIN'
    )
  );

-- Admins can update all rows (role assignment, plan activation, etc.).
create policy "admins_update_all" on public.users
  for update using (
    exists (
      select 1 from public.users u
      where u.id = auth.uid() and u.role = 'ADMIN'
    )
  );

-- Admins can insert new users (trainer creation, etc.).
create policy "admins_insert" on public.users
  for insert with check (
    exists (
      select 1 from public.users u
      where u.id = auth.uid() and u.role = 'ADMIN'
    )
  );

-- ── Lock age/gender after onboarding ─────────────────────────────────────────
-- Prevent clients from updating age or gender once onboarding_complete = true.

create or replace function public.lock_onboarded_fields()
returns trigger language plpgsql as $$
begin
  if old.onboarding_complete then
    -- Reject any attempt to change age or gender after onboarding
    if new.age is distinct from old.age or new.gender is distinct from old.gender then
      raise exception 'age and gender are locked after onboarding';
    end if;
  end if;
  return new;
end;
$$;

create or replace trigger users_lock_onboarded
  before update on public.users
  for each row execute procedure public.lock_onboarded_fields();
