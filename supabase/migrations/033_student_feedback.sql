-- 033_student_feedback.sql

-- Create feedback table
create table if not exists public.student_feedback (
  id         uuid default gen_random_uuid() primary key,
  student_id uuid not null references public.users(id) on delete cascade,
  trainer_id uuid references public.users(id) on delete set null,
  batch_id   uuid references public.batches(id) on delete set null,
  rating     integer not null check (rating >= 1 and rating <= 5),
  comments   text,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

-- Performance and lookup indexes
create index if not exists student_feedback_student_idx on public.student_feedback(student_id);
create index if not exists student_feedback_batch_idx on public.student_feedback(batch_id);
create index if not exists student_feedback_trainer_idx on public.student_feedback(trainer_id);

-- Standard update trigger
create or replace trigger student_feedback_updated_at
  before update on public.student_feedback
  for each row execute procedure public.set_updated_at();

-- Table-level grants
grant select, insert, update, delete on public.student_feedback to authenticated, service_role;

-- Enable Row Level Security
alter table public.student_feedback enable row level security;

-- RLS Policies
-- Students can insert feedback for themselves, but only if they are enrolled in the batch (if batch_id is specified)
create policy "feedback_insert_student" on public.student_feedback
  for insert with check (
    student_id = auth.uid()
    and (
      batch_id is null
      or exists (
        select 1 from public.enrollments e
        where e.student_id = auth.uid() and e.batch_id = student_feedback.batch_id
      )
    )
  );

-- Students can read their own feedback
create policy "feedback_select_student" on public.student_feedback
  for select using (student_id = auth.uid());

-- Admins can read all feedback
create policy "feedback_select_admin" on public.student_feedback
  for select using (public.is_admin(auth.uid()));

-- Trainers can read feedback for batches they are assigned to
create policy "feedback_select_trainer" on public.student_feedback
  for select using (
    public.is_trainer(auth.uid())
    and exists (
      select 1 from public.batches b
      where b.id = student_feedback.batch_id and b.trainer_id = auth.uid()
    )
  );

-- Admins can delete feedback if needed (no update policy exists to ensure feedback is immutable)
create policy "feedback_delete_admin" on public.student_feedback
  for delete using (public.is_admin(auth.uid()));
