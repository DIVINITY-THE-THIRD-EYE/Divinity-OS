-- 020_convert_lead_to_member_rpc.sql
-- ─────────────────────────────────────────────────────────────────────────────
-- FIX C4 (NEW-2) — Lead-to-member conversion atomic RPC
--
-- Expose a security definer RPC function to atomically update both the lead status
-- to 'ADMITTED' (with the converted_user_id linked) and set the user's plan_status
-- to 'PENDING_ADMIN' in a single transaction. This prevents partial-failure CRM desync.
--
-- Only users with ADMIN role can execute this RPC.
-- ─────────────────────────────────────────────────────────────────────────────

create or replace function public.convert_lead_to_member(
  p_lead_id uuid,
  p_user_id uuid
)
returns public.leads
language plpgsql
security definer
set search_path = public, pg_temp
as $$
declare
  v_lead public.leads;
begin
  -- 1. Verify executing user is ADMIN
  if not public.is_admin(auth.uid()) then
    raise exception 'only admins can convert leads'
      using errcode = '42501';  -- insufficient_privilege
  end if;

  -- 2. Verify target user exists
  if not exists (select 1 from public.users where id = p_user_id) then
    raise exception 'user not found'
      using errcode = 'P0002';  -- no_data_found
  end if;

  -- 3. Update the lead to mark as ADMITTED and link user_id
  update public.leads
  set pipeline_status = 'ADMITTED',
      converted_user_id = p_user_id,
      updated_at = now()
  where id = p_lead_id
  returning * into v_lead;

  if not found then
    raise exception 'lead not found'
      using errcode = 'P0002';  -- no_data_found
  end if;

  -- 4. Update users table plan_status to PENDING_ADMIN
  update public.users
  set plan_status = 'PENDING_ADMIN',
      updated_at = now()
  where id = p_user_id;

  return v_lead;
end;
$$;
