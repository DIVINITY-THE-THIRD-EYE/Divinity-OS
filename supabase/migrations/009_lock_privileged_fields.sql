-- 009_lock_privileged_fields.sql
-- ─────────────────────────────────────────────────────────────────────────────
-- FIX C1 — Privilege escalation via self-update of public.users
--
-- Problem: policy "users_update_own" (001_users_rls.sql) is
--   for update using (auth.uid() = id)
-- with no column restriction, so a STUDENT can run
--   update users set role = 'ADMIN'        -- self-promote to admin
--   update users set plan_status = 'ACTIVE' -- self-activate paid plan
-- The only existing guard (lock_onboarded_fields) covers age/gender only.
--
-- Fix: a BEFORE UPDATE trigger that rejects changes to privileged columns
-- unless the caller is an ADMIN (or a trusted server context). One narrow
-- exception preserves the legitimate onboarding write: a user may set their
-- OWN plan_status to 'PENDING_ADMIN' (auth_provider.completeOnboarding).
--
-- Privileged columns:
--   role             -> ADMIN only
--   plan_status      -> ADMIN only, except own-row -> 'PENDING_ADMIN'
--   expiration_date  -> ADMIN only
--   pause_start_date -> ADMIN only
--   current_streak   -> ADMIN only (no client writes these today)
--   max_streak       -> ADMIN only
--
-- Trusted server contexts (service_role key, direct DB / migrations) have a
-- null auth.uid() and bypass the check, so backend jobs are unaffected.
-- ─────────────────────────────────────────────────────────────────────────────

create or replace function public.lock_privileged_fields()
returns trigger
language plpgsql
security definer
set search_path = public, pg_temp
as $$
declare
  v_is_admin boolean;
begin
  -- Trusted server context (service_role / superuser / migration): allow.
  if auth.uid() is null then
    return new;
  end if;

  select exists (
    select 1 from public.users
    where id = auth.uid() and role = 'ADMIN'
  ) into v_is_admin;

  -- Admins may change any field.
  if v_is_admin then
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

-- Fires after users_lock_onboarded (alphabetical) and before users_updated_at;
-- all three BEFORE UPDATE triggers are independent.
drop trigger if exists users_lock_privileged on public.users;
create trigger users_lock_privileged
  before update on public.users
  for each row execute procedure public.lock_privileged_fields();

-- ─────────────────────────────────────────────────────────────────────────────
-- ROLLBACK (run manually; do NOT place in migrations/ or it will re-apply)
--
--   drop trigger if exists users_lock_privileged on public.users;
--   drop function if exists public.lock_privileged_fields();
--
-- After rollback, C1 is OPEN again — only roll back if 009 is shown to break a
-- legitimate flow, and re-apply a corrected version immediately.
-- ─────────────────────────────────────────────────────────────────────────────
