-- Allow trainers and admins to INSERT attendance records so the
-- trainer check-in screen can create records for students who have
-- not self-checked in yet.

create policy "attendance_insert_staff" on public.attendance
  for insert with check (
    exists (
      select 1 from public.users u
      where u.id = auth.uid() and u.role in ('TRAINER', 'ADMIN')
    )
  );
