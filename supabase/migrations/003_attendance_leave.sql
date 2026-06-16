-- ── enrollments ──────────────────────────────────────────────────────────────

create table if not exists public.enrollments (
  id           uuid default gen_random_uuid() primary key,
  student_id   uuid not null references public.users(id) on delete cascade,
  batch_id     uuid not null references public.batches(id) on delete cascade,
  assigned_by  uuid references public.users(id) on delete set null,
  assigned_at  timestamptz not null default now(),
  unique(student_id, batch_id)
);

alter table public.enrollments enable row level security;

create policy "enrollments_select_auth" on public.enrollments
  for select using (
    student_id = auth.uid()
    or exists (
      select 1 from public.users u where u.id = auth.uid() and u.role in ('TRAINER','ADMIN')
    )
  );

create policy "enrollments_insert_trainer_admin" on public.enrollments
  for insert with check (
    exists (
      select 1 from public.users u where u.id = auth.uid() and u.role in ('TRAINER','ADMIN')
    )
  );

create policy "enrollments_delete_trainer_admin" on public.enrollments
  for delete using (
    exists (
      select 1 from public.users u where u.id = auth.uid() and u.role in ('TRAINER','ADMIN')
    )
  );

-- ── attendance ────────────────────────────────────────────────────────────────

create table if not exists public.attendance (
  id           uuid default gen_random_uuid() primary key,
  student_id   uuid not null references public.users(id) on delete cascade,
  batch_id     uuid references public.batches(id) on delete set null,
  date         date not null,
  checkin_time timestamptz,
  status       text not null default 'ABSENT'
                 check (status in ('PRESENT','ABSENT','EXCUSED','ON_LEAVE','HOLIDAY','CANCELLED')),
  marked_by    text not null default 'STUDENT'
                 check (marked_by in ('STUDENT','TRAINER','ADMIN','SYSTEM')),
  created_at   timestamptz not null default now(),
  updated_at   timestamptz not null default now(),
  unique(student_id, date)
);

create or replace trigger attendance_updated_at
  before update on public.attendance
  for each row execute procedure public.set_updated_at();

alter table public.attendance enable row level security;

-- students see their own; trainers/admin see all
create policy "attendance_select" on public.attendance
  for select using (
    student_id = auth.uid()
    or exists (
      select 1 from public.users u where u.id = auth.uid() and u.role in ('TRAINER','ADMIN')
    )
  );

-- students can mark their own check-in
create policy "attendance_insert_student" on public.attendance
  for insert with check (student_id = auth.uid());

-- trainers/admin can override
create policy "attendance_update_staff" on public.attendance
  for update using (
    exists (
      select 1 from public.users u where u.id = auth.uid() and u.role in ('TRAINER','ADMIN')
    )
  );

-- ── leave_requests ────────────────────────────────────────────────────────────

create table if not exists public.leave_requests (
  id           uuid default gen_random_uuid() primary key,
  student_id   uuid not null references public.users(id) on delete cascade,
  start_date   date not null,
  end_date     date not null,
  reason       text,
  status       text not null default 'PENDING'
                 check (status in ('PENDING','APPROVED','REJECTED')),
  approved_by  uuid references public.users(id) on delete set null,
  created_at   timestamptz not null default now(),
  updated_at   timestamptz not null default now()
);

create or replace trigger leave_requests_updated_at
  before update on public.leave_requests
  for each row execute procedure public.set_updated_at();

alter table public.leave_requests enable row level security;

create policy "leave_select" on public.leave_requests
  for select using (
    student_id = auth.uid()
    or exists (
      select 1 from public.users u where u.id = auth.uid() and u.role in ('TRAINER','ADMIN')
    )
  );

create policy "leave_insert_student" on public.leave_requests
  for insert with check (student_id = auth.uid());

create policy "leave_update_staff" on public.leave_requests
  for update using (
    exists (
      select 1 from public.users u where u.id = auth.uid() and u.role in ('TRAINER','ADMIN')
    )
  );
