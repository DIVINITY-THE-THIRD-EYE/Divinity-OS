-- 026_workouts.sql
-- ─────────────────────────────────────────────────────────────────────────────
-- Module 9 — Workout Management
--
-- Structured workout plans authored by trainers, composed of ordered exercises,
-- assigned to batches, and completed by the students enrolled in those batches.
-- This replaces the free-text `therapeutic_logs` stand-in for structured workouts
-- (therapeutic_logs remains for narrative progress notes — the two are distinct).
--
-- Integrates with existing primitives:
--   • public.users (roles), public.batches, public.enrollments
--   • RLS helpers public.is_admin / public.is_trainer / public.is_trainer_or_admin
--   • public.set_updated_at() trigger
--   • public.notifications (student receives a notice when a workout is assigned)
-- ─────────────────────────────────────────────────────────────────────────────

-- ── workouts ──────────────────────────────────────────────────────────────────
-- A reusable workout plan owned by the trainer (or admin) who created it.
create table if not exists public.workouts (
  id          uuid primary key default gen_random_uuid(),
  trainer_id  uuid not null references public.users(id) on delete cascade,
  title       text not null check (char_length(trim(title)) > 0),
  description text,
  created_at  timestamptz not null default now(),
  updated_at  timestamptz not null default now()
);

create index if not exists workouts_trainer_idx on public.workouts(trainer_id);

create or replace trigger workouts_updated_at
  before update on public.workouts
  for each row execute procedure public.set_updated_at();

-- ── workout_exercises ─────────────────────────────────────────────────────────
-- Ordered exercises that make up a workout.
create table if not exists public.workout_exercises (
  id           uuid primary key default gen_random_uuid(),
  workout_id   uuid not null references public.workouts(id) on delete cascade,
  name         text not null check (char_length(trim(name)) > 0),
  sets         integer check (sets is null or sets > 0),
  reps         integer check (reps is null or reps > 0),
  duration_sec integer check (duration_sec is null or duration_sec > 0),
  rest_sec     integer check (rest_sec is null or rest_sec >= 0),
  notes        text,
  position     integer not null default 0,
  created_at   timestamptz not null default now()
);

create index if not exists workout_exercises_workout_idx
  on public.workout_exercises(workout_id);

-- ── workout_assignments ───────────────────────────────────────────────────────
-- Assigns a workout to a batch. Students enrolled in the batch receive it.
create table if not exists public.workout_assignments (
  id          uuid primary key default gen_random_uuid(),
  workout_id  uuid not null references public.workouts(id) on delete cascade,
  batch_id    uuid not null references public.batches(id) on delete cascade,
  assigned_by uuid references public.users(id) on delete set null,
  assigned_at timestamptz not null default now(),
  unique (workout_id, batch_id)
);

create index if not exists workout_assignments_batch_idx
  on public.workout_assignments(batch_id);

-- ── workout_completions ───────────────────────────────────────────────────────
-- A student marks an assigned workout complete (one row per assignment/student).
create table if not exists public.workout_completions (
  id            uuid primary key default gen_random_uuid(),
  assignment_id uuid not null references public.workout_assignments(id) on delete cascade,
  student_id    uuid not null references public.users(id) on delete cascade,
  notes         text,
  completed_at  timestamptz not null default now(),
  unique (assignment_id, student_id)
);

create index if not exists workout_completions_student_idx
  on public.workout_completions(student_id);

-- ── Table-level privileges ────────────────────────────────────────────────────
-- The blanket grant in migration 012 only covered tables that existed then, so
-- tables added later must grant explicitly (RLS below still governs the rows).
grant select, insert, update, delete on public.workouts            to authenticated, service_role;
grant select, insert, update, delete on public.workout_exercises   to authenticated, service_role;
grant select, insert, update, delete on public.workout_assignments to authenticated, service_role;
grant select, insert, update, delete on public.workout_completions to authenticated, service_role;

-- ── SECURITY DEFINER helpers (break RLS recursion) ────────────────────────────
-- workouts_select needs to know if a student may see a workout (via an
-- assignment→enrollment path), while workout_assignments_insert needs to know
-- workout ownership. Referencing those tables inline from each other's policies
-- causes mutual RLS recursion (same class of bug fixed in migration 012 for
-- users). These helpers run as SECURITY DEFINER so they bypass RLS and break
-- the cycle.

create or replace function public.owns_workout(p_workout uuid, p_uid uuid)
returns boolean
language sql
security definer
set search_path = public
as $$
  select exists (
    select 1 from public.workouts w
    where w.id = p_workout and w.trainer_id = p_uid
  );
$$;

create or replace function public.student_in_batch(p_batch uuid, p_uid uuid)
returns boolean
language sql
security definer
set search_path = public
as $$
  select exists (
    select 1 from public.enrollments e
    where e.batch_id = p_batch and e.student_id = p_uid
  );
$$;

create or replace function public.student_sees_workout(p_workout uuid, p_uid uuid)
returns boolean
language sql
security definer
set search_path = public
as $$
  select exists (
    select 1
    from public.workout_assignments wa
    join public.enrollments e on e.batch_id = wa.batch_id
    where wa.workout_id = p_workout and e.student_id = p_uid
  );
$$;

create or replace function public.student_sees_assignment(p_assignment uuid, p_uid uuid)
returns boolean
language sql
security definer
set search_path = public
as $$
  select exists (
    select 1
    from public.workout_assignments wa
    join public.enrollments e on e.batch_id = wa.batch_id
    where wa.id = p_assignment and e.student_id = p_uid
  );
$$;

-- ── RLS ───────────────────────────────────────────────────────────────────────
alter table public.workouts             enable row level security;
alter table public.workout_exercises    enable row level security;
alter table public.workout_assignments  enable row level security;
alter table public.workout_completions  enable row level security;

-- workouts: staff see all; a student sees a workout iff it is assigned to a
-- batch they are enrolled in.
create policy "workouts_select" on public.workouts
  for select using (
    public.is_trainer_or_admin(auth.uid())
    or public.student_sees_workout(id, auth.uid())
  );

-- Trainers create workouts they own; admins may create for any trainer.
create policy "workouts_insert" on public.workouts
  for insert with check (
    (public.is_admin(auth.uid()) and trainer_id is not null)
    or (public.is_trainer(auth.uid()) and trainer_id = auth.uid())
  );

create policy "workouts_update" on public.workouts
  for update using (
    public.is_admin(auth.uid()) or trainer_id = auth.uid()
  );

create policy "workouts_delete" on public.workouts
  for delete using (
    public.is_admin(auth.uid()) or trainer_id = auth.uid()
  );

-- workout_exercises: visible to anyone who can see the parent workout.
create policy "workout_exercises_select" on public.workout_exercises
  for select using (
    public.is_trainer_or_admin(auth.uid())
    or public.student_sees_workout(workout_id, auth.uid())
  );

-- Only the owning trainer (or an admin) may mutate exercises.
create policy "workout_exercises_write" on public.workout_exercises
  for all using (
    public.is_admin(auth.uid()) or public.owns_workout(workout_id, auth.uid())
  ) with check (
    public.is_admin(auth.uid()) or public.owns_workout(workout_id, auth.uid())
  );

-- workout_assignments: staff see all; students see assignments for their batch.
create policy "workout_assignments_select" on public.workout_assignments
  for select using (
    public.is_trainer_or_admin(auth.uid())
    or public.student_in_batch(batch_id, auth.uid())
  );

-- Trainers assign their own workouts; admins may assign any. assigned_by must
-- be the acting trainer (admins may leave/set it to any staff id).
create policy "workout_assignments_insert" on public.workout_assignments
  for insert with check (
    public.is_admin(auth.uid())
    or (
      public.is_trainer(auth.uid())
      and assigned_by = auth.uid()
      and public.owns_workout(workout_id, auth.uid())
    )
  );

create policy "workout_assignments_delete" on public.workout_assignments
  for delete using (
    public.is_admin(auth.uid()) or public.owns_workout(workout_id, auth.uid())
  );

-- workout_completions: students manage their own; staff read all for review.
create policy "workout_completions_select" on public.workout_completions
  for select using (
    student_id = auth.uid() or public.is_trainer_or_admin(auth.uid())
  );

-- A student may only complete an assignment for a batch they are enrolled in.
create policy "workout_completions_insert" on public.workout_completions
  for insert with check (
    student_id = auth.uid()
    and public.student_sees_assignment(assignment_id, auth.uid())
  );

create policy "workout_completions_delete" on public.workout_completions
  for delete using (student_id = auth.uid());

-- ── Notification on assignment ────────────────────────────────────────────────
-- When a workout is assigned to a batch, notify every enrolled student so the
-- Workout Flow ("Student Receives Workout") surfaces in-app + via FCM fan-out.
create or replace function public.notify_workout_assignment()
returns trigger
language plpgsql
security definer
set search_path = public, pg_temp
as $$
declare
  v_title text;
begin
  select w.title into v_title from public.workouts w where w.id = new.workout_id;

  insert into public.notifications (user_id, kind, title, body, metadata)
  select
    e.student_id,
    'BATCH_UPDATE',
    '🧘 New Workout Assigned',
    'A new workout "' || coalesce(v_title, 'plan') ||
      '" has been added to your batch. Open Workouts to begin.',
    jsonb_build_object(
      'assignment_id', new.id,
      'workout_id', new.workout_id,
      'batch_id', new.batch_id,
      'action', 'workout_assigned',
      'target', 'workouts'
    )
  from public.enrollments e
  where e.batch_id = new.batch_id;

  return new;
end;
$$;

drop trigger if exists workout_assignments_notify on public.workout_assignments;
create trigger workout_assignments_notify
  after insert on public.workout_assignments
  for each row execute function public.notify_workout_assignment();
