-- 017_jwt_role_app_metadata.sql
-- ─────────────────────────────────────────────────────────────────────────────
-- FIX H3 — Role → JWT app_metadata (kills RLS subqueries & recursion)
--
-- Redefine role check helpers to read directly from JWT claims when checking the
-- current user, preventing recursive users table queries and improving performance.
--
-- Add a trigger to public.users to automatically sync the user's role to
-- auth.users.raw_app_meta_data.
-- ─────────────────────────────────────────────────────────────────────────────

-- ── Redefine Role Helper Functions ───────────────────────────────────────────

create or replace function public.is_admin(user_id uuid)
returns boolean
language plpgsql
security definer
set search_path = public, pg_temp
as $$
declare
  v_role text;
begin
  if auth.uid() = user_id then
    v_role := auth.jwt() -> 'app_metadata' ->> 'role';
    if v_role is not null then
      return v_role = 'ADMIN';
    end if;
  end if;

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
set search_path = public, pg_temp
as $$
declare
  v_role text;
begin
  if auth.uid() = user_id then
    v_role := auth.jwt() -> 'app_metadata' ->> 'role';
    if v_role is not null then
      return v_role = 'TRAINER';
    end if;
  end if;

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
set search_path = public, pg_temp
as $$
declare
  v_role text;
begin
  if auth.uid() = user_id then
    v_role := auth.jwt() -> 'app_metadata' ->> 'role';
    if v_role is not null then
      return v_role in ('TRAINER', 'ADMIN');
    end if;
  end if;

  return exists (
    select 1 from public.users
    where id = user_id and role in ('TRAINER', 'ADMIN')
  );
end;
$$;

-- ── Sync Role to auth.users Trigger ──────────────────────────────────────────

create or replace function public.sync_user_role_to_auth()
returns trigger
language plpgsql
security definer
set search_path = auth, pg_temp
as $$
begin
  update auth.users
  set raw_app_meta_data = coalesce(raw_app_meta_data, '{}'::jsonb) || jsonb_build_object('role', new.role)
  where id = new.id;
  return new;
end;
$$;

drop trigger if exists sync_user_role_trigger on public.users;
create trigger sync_user_role_trigger
after insert or update of role
on public.users
for each row
execute function public.sync_user_role_to_auth();

-- ── One-time Sync for Existing Users ─────────────────────────────────────────

do $$
declare
  v_row record;
begin
  for v_row in select id, role from public.users loop
    update auth.users
    set raw_app_meta_data = coalesce(raw_app_meta_data, '{}'::jsonb) || jsonb_build_object('role', v_row.role)
    where id = v_row.id;
  end loop;
end;
$$;
