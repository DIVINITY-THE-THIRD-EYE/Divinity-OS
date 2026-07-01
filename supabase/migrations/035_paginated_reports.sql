-- 035_paginated_reports.sql
-- ─────────────────────────────────────────────────────────────────────────────
-- Module 15 — Paginated Reports functions
-- ─────────────────────────────────────────────────────────────────────────────

create or replace function public.get_reports_attendance(
  p_start_date timestamptz default null,
  p_end_date timestamptz default null,
  p_limit int default 50,
  p_offset int default 0
)
returns json
language plpgsql
security definer
set search_path = public, pg_temp
as $$
declare
  v_result json;
begin
  -- Access Control Lock: Only authorized Admins can execute reports
  if not public.is_admin(auth.uid()) then
    raise exception 'Access denied: Reports are restricted to administrators.'
      using errcode = '42501';
  end if;

  with filtered_users as (
    select u.*
    from public.users u
    where u.role = 'STUDENT'
  ),
  filtered_attendance as (
    select a.*
    from public.attendance a
    join filtered_users fu on a.student_id = fu.id
    where (p_start_date is null or a.date >= p_start_date::date)
      and (p_end_date is null or a.date <= p_end_date::date)
  ),
  per_batch as (
    select b.name,
           case when count(a.id) = 0 then 0.0
                else (count(case when a.status = 'PRESENT' then 1 end)::double precision / count(a.id)) * 100
           end as rate
    from filtered_attendance a
    join public.batches b on a.batch_id = b.id
    group by b.name
  ),
  per_trainer as (
    select u.name,
           case when count(a.id) = 0 then 0.0
                else (count(case when a.status = 'PRESENT' then 1 end)::double precision / count(a.id)) * 100
           end as rate
    from filtered_attendance a
    join public.batches b on a.batch_id = b.id
    join public.users u on b.trainer_id = u.id
    group by u.name
  ),
  per_student as (
    select u.name,
           case when count(a.id) = 0 then 0.0
                else (count(case when a.status = 'PRESENT' then 1 end)::double precision / count(a.id)) * 100
           end as rate
    from filtered_attendance a
    join public.users u on a.student_id = u.id
    group by u.name
  ),
  low_attendance as (
    select a.student_id,
           u.name as student_name,
           case when count(a.id) = 0 then 0.0
                else (count(case when a.status = 'PRESENT' then 1 end)::double precision / count(a.id)) * 100
           end as attendance_rate,
           count(a.id)::int as total_classes,
           count(case when a.status = 'PRESENT' then 1 end)::int as attended_classes
    from filtered_attendance a
    join public.users u on a.student_id = u.id
    group by a.student_id, u.name
    having count(a.id) >= 2 and (count(case when a.status = 'PRESENT' then 1 end)::double precision / count(a.id)) < 0.75
    order by attendance_rate
    limit p_limit
    offset p_offset
  )
  select json_build_object(
    'dailyAttendance', coalesce((
      select json_agg(t) from (
        select date, count(*)::int as value
        from filtered_attendance
        where status = 'PRESENT'
        group by date
        order by date
      ) t
    ), '[]'::json),
    'monthlyAttendance', coalesce((
      select json_agg(t) from (
        select date_trunc('month', date)::date as month, count(*)::int as value
        from filtered_attendance
        where status = 'PRESENT'
        group by date_trunc('month', date)
        order by month
      ) t
    ), '[]'::json),
    'perBatchAttendance', coalesce((
      select json_object_agg(name, rate) from per_batch
    ), '{}'::json),
    'perTrainerAttendance', coalesce((
      select json_object_agg(name, rate) from per_trainer
    ), '{}'::json),
    'studentAttendancePercentage', coalesce((
      select json_object_agg(name, rate) from per_student
    ), '{}'::json),
    'lowAttendanceAlerts', coalesce((
      select json_agg(t) from low_attendance t
    ), '[]'::json)
  ) into v_result;

  return v_result;
end;
$$;

grant execute on function public.get_reports_attendance to authenticated, service_role;

create or replace function public.get_reports_revenue(
  p_start_date timestamptz default null,
  p_end_date timestamptz default null,
  p_limit int default 50,
  p_offset int default 0
)
returns json
language plpgsql
security definer
set search_path = public, pg_temp
as $$
declare
  v_result json;
begin
  -- Access Control Lock: Only authorized Admins can execute reports
  if not public.is_admin(auth.uid()) then
    raise exception 'Access denied: Reports are restricted to administrators.'
      using errcode = '42501';
  end if;

  with filtered_users as (
    select u.*
    from public.users u
    where u.role = 'STUDENT'
  ),
  filtered_payments as (
    select p.*
    from public.payments p
    join filtered_users fu on p.student_id = fu.id
    where (p_start_date is null or p.paid_at >= p_start_date)
      and (p_end_date is null or p.paid_at <= p_end_date)
  ),
  paginated_daily_revenue as (
    select paid_at::date as date, sum(amount)::double precision as value
    from filtered_payments
    where status = 'PAID' and paid_at is not null
    group by paid_at::date
    order by date
    limit p_limit
    offset p_offset
  )
  select json_build_object(
    'dailyRevenue', coalesce((
      select json_agg(t) from paginated_daily_revenue t
    ), '[]'::json),
    'monthlyRevenue', coalesce((
      select json_agg(t) from (
        select date_trunc('month', paid_at)::date as month, sum(amount)::double precision as value
        from filtered_payments
        where status = 'PAID' and paid_at is not null
        group by date_trunc('month', paid_at)
        order by month
      ) t
    ), '[]'::json),
    'yearlyRevenue', coalesce((
      select json_agg(t) from (
        select date_trunc('year', paid_at)::date as month, sum(amount)::double precision as value
        from filtered_payments
        where status = 'PAID' and paid_at is not null
        group by date_trunc('year', paid_at)
        order by month
      ) t
    ), '[]'::json),
    'outstandingFees', coalesce((
      select sum(amount)::double precision from filtered_payments where status = 'PENDING'
    ), 0.0),
    'paidCount', coalesce((
      select count(*)::int from filtered_payments where status = 'PAID'
    ), 0),
    'unpaidCount', coalesce((
      select count(*)::int from filtered_payments where status = 'PENDING'
    ), 0),
    'membershipSales', coalesce((
      select json_object_agg(plan_name, sales_count) from (
        select plan_name, count(*)::int as sales_count
        from (
          select case when amount >= 15000 then 'Annual Plan'
                      when amount >= 4000 then 'Quarterly Plan'
                      else 'Monthly Plan'
                 end as plan_name
          from filtered_payments
          where status = 'PAID'
        ) sub
        group by plan_name
      ) t
    ), '{}'::json),
    'revenueByPlan', coalesce((
      select json_object_agg(plan_name, revenue) from (
        select plan_name, sum(amount)::double precision as revenue
        from (
          select amount,
                 case when amount >= 15000 then 'Annual Plan'
                      when amount >= 4000 then 'Quarterly Plan'
                      else 'Monthly Plan'
                 end as plan_name
          from filtered_payments
          where status = 'PAID'
        ) sub
        group by plan_name
      ) t
    ), '{}'::json)
  ) into v_result;

  return v_result;
end;
$$;

grant execute on function public.get_reports_revenue to authenticated, service_role;

create or replace function public.get_reports_events(
  p_start_date timestamptz default null,
  p_end_date timestamptz default null,
  p_limit int default 50,
  p_offset int default 0
)
returns json
language plpgsql
security definer
set search_path = public, pg_temp
as $$
declare
  v_result json;
begin
  -- Access Control Lock: Only authorized Admins can execute reports
  if not public.is_admin(auth.uid()) then
    raise exception 'Access denied: Reports are restricted to administrators.'
      using errcode = '42501';
  end if;

  with paginated_events as (
    select e.id as event_id,
           e.title,
           e.starts_at,
           (select count(*)::int from public.event_registrations er where er.event_id = e.id) as registrations_count,
           (select count(*)::int from public.event_registrations er where er.event_id = e.id) as attendance_count,
           (e.capacity is not null and (select count(*)::int from public.event_registrations er where er.event_id = e.id) >= e.capacity) as is_full,
           (e.status = 'CANCELLED') as is_cancelled
    from public.events e
    where (p_start_date is null or e.starts_at >= p_start_date)
      and (p_end_date is null or e.starts_at <= p_end_date)
    order by e.starts_at
    limit p_limit
    offset p_offset
  )
  select coalesce((
    select json_agg(t) from paginated_events t
  ), '[]'::json) into v_result;

  return v_result;
end;
$$;

grant execute on function public.get_reports_events to authenticated, service_role;
