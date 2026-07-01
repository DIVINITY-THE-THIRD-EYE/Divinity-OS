-- 032_trainer_active_status.sql
-- ─────────────────────────────────────────────────────────────────────────────
-- B4: Admin Trainer Management — adds the `is_active` flag the admin trainer
-- screen needs to deactivate a trainer account without deleting it (their
-- historical batches/attendance/logs must remain intact).
--
-- `is_active` is added to `users` generally (not trainer-specific) since the
-- column lives on a shared table, but today only the admin trainer screen
-- writes it. It defaults to true so no existing account is affected.
-- ─────────────────────────────────────────────────────────────────────────────

alter table public.users
  add column if not exists is_active boolean not null default true;

-- Composite index for the admin trainer list query (role + is_active filter).
create index if not exists users_role_is_active_idx
  on public.users(role, is_active);

-- Extend the existing privileged-field lock (migration 009) so a trainer
-- cannot simply re-activate their own account via "users_update_own".
create or replace function public.lock_privileged_fields()
returns trigger
language plpgsql
security definer
set search_path = public, pg_temp
as $$
begin
  -- Trusted server context (service_role / superuser / migration / trigger bypass): allow.
  if auth.uid() is null or coalesce(current_setting('my.bypass_lock', true), 'false') = 'true' then
    return new;
  end if;

  -- Admins may change any field.
  if public.is_admin(auth.uid()) then
    return new;
  end if;

  -- role is ADMIN-only, no exceptions.
  if new.role is distinct from old.role then
    raise exception 'role can only be changed by an admin'
      using errcode = '42501';
  end if;

  -- email: ADMIN-only, no exceptions.
  if new.email is distinct from old.email then
    raise exception 'email cannot be changed by the user'
      using errcode = '42501';
  end if;

  -- onboarding_complete: one-way latch (cannot be reset back to false)
  if old.onboarding_complete and not new.onboarding_complete then
    raise exception 'onboarding_complete cannot be reset to false'
      using errcode = '42501';
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

  if new.is_active is distinct from old.is_active then
    raise exception 'is_active can only be changed by an admin'
      using errcode = '42501';
  end if;

  return new;
end;
$$;

-- ─────────────────────────────────────────────────────────────────────────────
-- ROLLBACK (run manually; do NOT place in migrations/ or it will re-apply)
--
--   alter table public.users drop column if exists is_active;
--   drop index if exists public.users_role_is_active_idx;
--   -- and revert lock_privileged_fields() to the 009 definition.
-- ─────────────────────────────────────────────────────────────────────────────
