-- c24_security_advisories_test.sql  (pgTAP)
-- Run with:  supabase test db
--
-- Verifies 046_security_advisories.sql: the five legacy functions flagged by
-- linter WARN 0011 now have a pinned (non-mutable) search_path.

begin;
select plan(1);

select is(
  (select count(distinct proname)::int
     from pg_proc
     where pronamespace = 'public'::regnamespace
       and proname in ('set_updated_at', 'lock_onboarded_fields',
                       'haversine_m', 'gen_certificate_code', 'is_week_off')
       and array_to_string(proconfig, ',') like '%search_path%'),
  5,
  'C24.1 the five legacy functions all pin search_path'
);

select * from finish();
rollback;
