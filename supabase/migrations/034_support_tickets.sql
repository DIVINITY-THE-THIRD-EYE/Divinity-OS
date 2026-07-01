-- 034_support_tickets.sql

-- Create support tickets table
create table if not exists public.support_tickets (
  id          uuid default gen_random_uuid() primary key,
  student_id  uuid not null references public.users(id) on delete cascade,
  subject     text not null check (char_length(trim(subject)) > 0),
  description text not null check (char_length(trim(description)) > 0),
  status      text not null default 'OPEN' check (status in ('OPEN', 'RESOLVED')),
  created_at  timestamptz not null default now(),
  updated_at  timestamptz not null default now()
);

-- Performance and status indexes
create index if not exists support_tickets_student_idx on public.support_tickets(student_id);
create index if not exists support_tickets_status_idx on public.support_tickets(status);

-- Standard update trigger
create or replace trigger support_tickets_updated_at
  before update on public.support_tickets
  for each row execute procedure public.set_updated_at();

-- Table-level grants
grant select, insert, update, delete on public.support_tickets to authenticated, service_role;

-- Enable Row Level Security
alter table public.support_tickets enable row level security;

-- RLS Policies
-- Students can insert their own support tickets
create policy "tickets_insert_student" on public.support_tickets
  for insert with check (student_id = auth.uid());

-- Students can read their own support tickets
create policy "tickets_select_student" on public.support_tickets
  for select using (student_id = auth.uid());

-- Students can update their own support tickets (e.g., edit description before resolution)
create policy "tickets_update_student" on public.support_tickets
  for update using (student_id = auth.uid()) with check (student_id = auth.uid());

-- Admins can read all tickets
create policy "tickets_select_admin" on public.support_tickets
  for select using (public.is_admin(auth.uid()));

-- Admins can update all tickets (specifically to mark them as RESOLVED)
create policy "tickets_update_admin" on public.support_tickets
  for update using (public.is_admin(auth.uid()));

-- Admins can delete tickets
create policy "tickets_delete_admin" on public.support_tickets
  for delete using (public.is_admin(auth.uid()));
