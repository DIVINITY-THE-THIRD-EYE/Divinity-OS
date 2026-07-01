-- 009_payments_upgrade.sql

-- 1. Add screenshot_url column to payments table
alter table public.payments
  add column if not exists screenshot_url text;

-- 2. Allow students to submit (insert) their own payments (status must be PENDING)
create policy "students_insert_own_payments" on public.payments
  for insert with check (
    auth.uid() = student_id
    and status = 'PENDING'
  );

-- 3. Configure Supabase Storage bucket for payment screenshots
insert into storage.buckets (id, name, public)
values ('payment_screenshots', 'payment_screenshots', true)
on conflict (id) do nothing;

-- 4. Enable RLS on storage.objects if not already enabled (it is enabled by default in Supabase storage)
-- Note: Storage policies are written on storage.objects table.

-- Allow authenticated users to upload screenshots into their own user folder (bucket_id/user_id/filename)
create policy "allow_student_upload_screenshots" on storage.objects
  for insert with check (
    bucket_id = 'payment_screenshots'
    and auth.role() = 'authenticated'
    and (storage.foldername(name))[1] = auth.uid()::text
  );

-- Allow students to read their own screenshots, and staff (admins/trainers) to read all screenshots
create policy "allow_read_screenshots" on storage.objects
  for select using (
    bucket_id = 'payment_screenshots'
    and (
      (storage.foldername(name))[1] = auth.uid()::text
      or exists (
        select 1 from public.users u
        where u.id = auth.uid() and u.role in ('TRAINER', 'ADMIN')
      )
    )
  );
