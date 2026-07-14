-- 046_security_advisories.sql
--
-- WHY: Clears the five WARN 0011 "role-mutable search_path" advisories from the
-- Supabase database linter before public launch (which introduces anonymous
-- traffic to this project for the first time).
--
-- Every function added since the trainer/leave work (see `check_in`,
-- `process_leave_request`, `unpublish_certifications_on_edit`) already pins
-- `search_path = public, pg_temp`; these five predate that convention. Pinning
-- them closes the search_path-injection vector with no behaviour change — all
-- five reference only built-ins / NEW / OLD.
--
-- NOT ADDRESSED HERE (deliberate): the ERROR 0010 advisory on the
-- `public.published_trainers` view. That view is intentionally SECURITY
-- DEFINER: it is the *privacy-preserving* tool for this schema. `anon` and
-- `authenticated` hold table-level SELECT on ALL columns of `public.users`
-- (the Supabase default; RLS is the row gate), and `authenticated` legitimately
-- reads its own full row via `users_select_own`. Converting the view to
-- `security_invoker` would require granting a row-level read policy on
-- `public.users` to those roles, which — combined with the existing broad
-- column grant — would expose published trainers' phone/email/medical columns
-- to the public. A definer view projecting exactly four safe columns, bypassing
-- RLS, is the correct design. The advisory is reviewed and accepted; a linter-
-- clean alternative would need a full rework of the anon/authenticated grant
-- model on public.users and is out of scope for this migration.

alter function public.set_updated_at()            set search_path = public, pg_temp;
alter function public.lock_onboarded_fields()     set search_path = public, pg_temp;
alter function public.haversine_m(double precision, double precision, double precision, double precision)
                                                  set search_path = public, pg_temp;
alter function public.gen_certificate_code()      set search_path = public, pg_temp;
alter function public.is_week_off(date)           set search_path = public, pg_temp;
