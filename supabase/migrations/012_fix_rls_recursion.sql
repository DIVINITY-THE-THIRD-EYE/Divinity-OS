-- 012_fix_rls_recursion.sql
-- ─────────────────────────────────────────────────────────────────────────────
-- Explicit table-level GRANTS for Supabase default roles
-- ─────────────────────────────────────────────────────────────────────────────

grant usage on schema public to authenticated, anon, service_role;
grant select, insert, update, delete on all tables in schema public to authenticated, anon, service_role;
grant usage, select on all sequences in schema public to authenticated, anon, service_role;

-- ─────────────────────────────────────────────────────────────────────────────
-- Helper functions running as security definer to bypass RLS and avoid infinite recursion
-- ─────────────────────────────────────────────────────────────────────────────

create or replace function public.is_admin(user_id uuid)
returns boolean
language plpgsql
security definer
set search_path = public
as $$
begin
  return exists (
    select 1 from public.users
    where id = user_id and role = 'ADMIN'
  );
end;
$$;

create or replace function public.is_trainer(user_id uuid)
returns boolean
language plpgsql
security definer
set search_path = public
as $$
begin
  return exists (
    select 1 from public.users
    where id = user_id and role = 'TRAINER'
  );
end;
$$;

create or replace function public.is_trainer_or_admin(user_id uuid)
returns boolean
language plpgsql
security definer
set search_path = public
as $$
begin
  return exists (
    select 1 from public.users
    where id = user_id and role in ('TRAINER', 'ADMIN')
  );
end;
$$;

-- Redefine lock_privileged_fields to use the new helper function
create or replace function public.lock_privileged_fields()
returns trigger
language plpgsql
security definer
set search_path = public, pg_temp
as $$
begin
  -- Trusted server context (service_role / superuser / migration): allow.
  if auth.uid() is null then
    return new;
  end if;

  -- Admins may change any field.
  if public.is_admin(auth.uid()) then
    return new;
  end if;

  -- ── Non-admin caller: enforce per-column locks ──────────────────────────────

  -- role is ADMIN-only, no exceptions.
  if new.role is distinct from old.role then
    raise exception 'role can only be changed by an admin'
      using errcode = '42501';  -- insufficient_privilege
  end if;

  -- plan_status: ADMIN-only, EXCEPT a user setting their OWN row to
  -- 'PENDING_ADMIN' (the onboarding-complete transition).
  if new.plan_status is distinct from old.plan_status then
    if not (auth.uid() = old.id and new.plan_status = 'PENDING_ADMIN') then
      raise exception 'plan_status can only be set by an admin (onboarding may set PENDING_ADMIN only)'
        using errcode = '42501';
    end if;
  end if;

  -- Plan lifecycle + streak fields: ADMIN-only.
  if new.expiration_date  is distinct from old.expiration_date
     or new.pause_start_date is distinct from old.pause_start_date
     or new.current_streak   is distinct from old.current_streak
     or new.max_streak       is distinct from old.max_streak then
    raise exception 'plan lifecycle and streak fields can only be changed by an admin'
      using errcode = '42501';
  end if;

  return new;
end;
$$;

-- ─────────────────────────────────────────────────────────────────────────────
-- Re-apply policies using the new helpers
-- ─────────────────────────────────────────────────────────────────────────────

-- 1. users policies
drop policy if exists "trainers_select_students" on public.users;
drop policy if exists "admins_select_all" on public.users;
drop policy if exists "admins_update_all" on public.users;
drop policy if exists "admins_insert" on public.users;

create policy "trainers_select_students" on public.users
  for select using (
    role = 'STUDENT'
    and public.is_trainer(auth.uid())
  );

create policy "admins_select_all" on public.users
  for select using (
    public.is_admin(auth.uid())
  );

create policy "admins_update_all" on public.users
  for update using (
    public.is_admin(auth.uid())
  );

create policy "admins_insert" on public.users
  for insert with check (
    public.is_admin(auth.uid())
  );

-- 2. batches policies
drop policy if exists "batches_update_own_or_admin" on public.batches;
drop policy if exists "batches_insert" on public.batches;

create policy "batches_update_own_or_admin" on public.batches
  for update using (
    trainer_id = auth.uid()
    or public.is_admin(auth.uid())
  );

create policy "batches_insert" on public.batches
  for insert with check (
    public.is_trainer_or_admin(auth.uid())
  );

-- 3. leads policies
drop policy if exists "leads_select_admin" on public.leads;
drop policy if exists "leads_insert_admin" on public.leads;
drop policy if exists "leads_update_admin" on public.leads;

create policy "leads_select_admin" on public.leads
  for select using (
    public.is_admin(auth.uid())
  );

create policy "leads_insert_admin" on public.leads
  for insert with check (
    public.is_admin(auth.uid())
  );

create policy "leads_update_admin" on public.leads
  for update using (
    public.is_admin(auth.uid())
  );

-- 4. enrollments policies
drop policy if exists "enrollments_select_auth" on public.enrollments;
drop policy if exists "enrollments_insert_trainer_admin" on public.enrollments;
drop policy if exists "enrollments_delete_trainer_admin" on public.enrollments;

create policy "enrollments_select_auth" on public.enrollments
  for select using (
    student_id = auth.uid()
    or public.is_trainer_or_admin(auth.uid())
  );

create policy "enrollments_insert_trainer_admin" on public.enrollments
  for insert with check (
    public.is_trainer_or_admin(auth.uid())
  );

create policy "enrollments_delete_trainer_admin" on public.enrollments
  for delete using (
    public.is_trainer_or_admin(auth.uid())
  );

-- 5. attendance policies
drop policy if exists "attendance_select" on public.attendance;
drop policy if exists "attendance_update_staff" on public.attendance;

create policy "attendance_select" on public.attendance
  for select using (
    student_id = auth.uid()
    or public.is_trainer_or_admin(auth.uid())
  );

create policy "attendance_update_staff" on public.attendance
  for update using (
    public.is_trainer_or_admin(auth.uid())
  );

-- 6. leave_requests policies
drop policy if exists "leave_select" on public.leave_requests;
drop policy if exists "leave_update_staff" on public.leave_requests;

create policy "leave_select" on public.leave_requests
  for select using (
    student_id = auth.uid()
    or public.is_trainer_or_admin(auth.uid())
  );

create policy "leave_update_staff" on public.leave_requests
  for update using (
    public.is_trainer_or_admin(auth.uid())
  );

-- 7. payments policies
drop policy if exists "admins_all_payments" on public.payments;

create policy "admins_all_payments" on public.payments
  for all using (
    public.is_admin(auth.uid())
  )
  with check (
    public.is_admin(auth.uid())
  );

-- 8. storage.objects bucket read policy
drop policy if exists "allow_read_screenshots" on storage.objects;

create policy "allow_read_screenshots" on storage.objects
  for select using (
    bucket_id = 'payment_screenshots'
    and (
      (storage.foldername(name))[1] = auth.uid()::text
      or public.is_trainer_or_admin(auth.uid())
    )
  );

-- 9. notifications policies
drop policy if exists "admins_trainers_insert_notifications" on public.notifications;
drop policy if exists "admins_read_all_notifications" on public.notifications;

create policy "admins_trainers_insert_notifications" on public.notifications
  for insert with check (
    public.is_trainer_or_admin(auth.uid())
  );

create policy "admins_read_all_notifications" on public.notifications
  for select using (
    public.is_admin(auth.uid())
  );

-- 10. transformation_scores policies
drop policy if exists "admins_all_scores" on public.transformation_scores;
drop policy if exists "trainers_all_scores" on public.transformation_scores;

create policy "admins_all_scores" on public.transformation_scores
  for all using (
    public.is_admin(auth.uid())
  );

create policy "trainers_all_scores" on public.transformation_scores
  for all using (
    public.is_trainer(auth.uid())
  );
