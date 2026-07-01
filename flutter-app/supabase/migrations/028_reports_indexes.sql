-- 028_reports_indexes.sql
-- ─────────────────────────────────────────────────────────────────────────────
-- Module 15 — Reports & Analytics Indexes & Server-side Aggregations
--
-- 1. Create indexes to optimize analytics queries.
-- 2. Define get_reports_data RPC for security-definer admin-only server-side aggregates.
-- ─────────────────────────────────────────────────────────────────────────────

-- ── 1. Create Performance Indexes ─────────────────────────────────────────────
create index if not exists payments_paid_at_idx on public.payments(paid_at);
create index if not exists payments_status_idx on public.payments(status);
create index if not exists users_role_plan_status_idx on public.users(role, plan_status);
create index if not exists users_created_at_idx on public.users(created_at);
create index if not exists attendance_date_status_idx on public.attendance(date, status);

-- ── 2. Reports Aggregator RPC ──────────────────────────────────────────────────
create or replace function public.get_reports_data(
  p_start_date timestamptz default null,
  p_end_date timestamptz default null,
  p_trainer_id uuid default null,
  p_batch_id uuid default null,
  p_plan text default null,
  p_status text default null,
  p_event_id uuid default null
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

  with filtered_batches as (
    select b.* 
    from public.batches b
    where (p_trainer_id is null or b.trainer_id = p_trainer_id)
      and (p_batch_id is null or b.id = p_batch_id)
  ),
  
  filtered_enrollments as (
    select e.*
    from public.enrollments e
    join filtered_batches fb on e.batch_id = fb.id
  ),
  
  filtered_users as (
    select u.*
    from public.users u
    where u.role = 'STUDENT'
      and (p_status is null or u.plan_status = p_status)
      and (
        (p_trainer_id is null and p_batch_id is null)
        or u.id in (select student_id from filtered_enrollments)
      )
      and (
        p_plan is null
        or u.id in (
          select student_id from public.payments
          where status = 'PAID'
            and (
              (p_plan = 'Annual Plan' and amount >= 15000) or
              (p_plan = 'Quarterly Plan' and amount >= 4000 and amount < 15000) or
              (p_plan = 'Monthly Plan' and amount < 4000)
            )
        )
      )
  ),
  
  filtered_attendance as (
    select a.*
    from public.attendance a
    join filtered_users fu on a.student_id = fu.id
    where (p_start_date is null or a.date >= p_start_date::date)
      and (p_end_date is null or a.date <= p_end_date::date)
      and (p_batch_id is null or a.batch_id = p_batch_id)
      and (
        p_trainer_id is null
        or a.batch_id in (select id from filtered_batches)
      )
  ),
  
  filtered_payments as (
    select p.*
    from public.payments p
    join filtered_users fu on p.student_id = fu.id
    where (p_start_date is null or p.paid_at >= p_start_date)
      and (p_end_date is null or p.paid_at <= p_end_date)
      and (
        p_plan is null
        or (
          (p_plan = 'Annual Plan' and p.amount >= 15000) or
          (p_plan = 'Quarterly Plan' and p.amount >= 4000 and p.amount < 15000) or
          (p_plan = 'Monthly Plan' and p.amount < 4000)
        )
      )
  )

  select json_build_object(
    'attendance', json_build_object(
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
        select json_object_agg(name, rate) from (
          select b.name,
                 case when count(a.id) = 0 then 0.0
                      else (count(case when a.status = 'PRESENT' then 1 end)::double precision / count(a.id)) * 100
                 end as rate
          from filtered_attendance a
          join public.batches b on a.batch_id = b.id
          group by b.name    
        ) t
      ), '{}'::json),
      'perTrainerAttendance', coalesce((
        select json_object_agg(name, rate) from (
          select u.name,
                 case when count(a.id) = 0 then 0.0
                      else (count(case when a.status = 'PRESENT' then 1 end)::double precision / count(a.id)) * 100
                 end as rate
          from filtered_attendance a
          join public.batches b on a.batch_id = b.id
          join public.users u on b.trainer_id = u.id
          group by u.name
        ) t
      ), '{}'::json),
      'studentAttendancePercentage', coalesce((
        select json_object_agg(name, rate) from (
          select u.name,
                 case when count(a.id) = 0 then 0.0
                      else (count(case when a.status = 'PRESENT' then 1 end)::double precision / count(a.id)) * 100
                 end as rate
          from filtered_attendance a
          join public.users u on a.student_id = u.id
          group by u.name
        ) t
      ), '{}'::json),
      'lowAttendanceAlerts', coalesce((
        select json_agg(t) from (
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
        ) t
      ), '[]'::json)
    ),
    'revenue', json_build_object(
      'dailyRevenue', coalesce((
        select json_agg(t) from (
          select paid_at::date as date, sum(amount)::double precision as value
          from filtered_payments
          where status = 'PAID' and paid_at is not null
          group by paid_at::date
          order by date
        ) t
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
    ),
    'membership', json_build_object(
      'activeMemberships', coalesce((select count(*)::int from filtered_users where plan_status = 'ACTIVE'), 0),
      'expiringMemberships', coalesce((
        select count(*)::int from filtered_users 
        where plan_status = 'ACTIVE' 
          and expiration_date is not null 
          and expiration_date >= now()::date 
          and expiration_date <= (now() + interval '30 days')::date
      ), 0),
      'expiredMemberships', coalesce((
        select count(*)::int from filtered_users 
        where plan_status = 'EXPIRED' or (plan_status = 'ACTIVE' and expiration_date is not null and expiration_date < now()::date)
      ), 0),
      'renewals', coalesce((
        select count(*)::int from (
          select student_id
          from public.payments
          where status = 'PAID'
          group by student_id
          having count(*) > 1
        ) t where student_id in (select id from filtered_users)
      ), 0),
      'newRegistrations', coalesce((
        select count(*)::int from filtered_users 
        where (p_start_date is null or created_at >= p_start_date)
          and (p_end_date is null or created_at <= p_end_date)
      ), 0),
      'membershipGrowth', coalesce((
        select json_agg(t) from (
          select date_trunc('month', created_at)::date as month, count(*)::int as value
          from filtered_users
          where plan_status = 'ACTIVE'
          group by date_trunc('month', created_at)
          order by month
        ) t
      ), '[]'::json)
    ),
    'students', json_build_object(
      'totalStudents', coalesce((select count(*)::int from filtered_users), 0),
      'activeStudents', coalesce((select count(*)::int from filtered_users where plan_status = 'ACTIVE'), 0),
      'inactiveStudents', coalesce((select count(*)::int from filtered_users where plan_status != 'ACTIVE'), 0),
      'newStudents', coalesce((
        select count(*)::int from filtered_users 
        where (p_start_date is null or created_at >= p_start_date)
          and (p_end_date is null or created_at <= p_end_date)
      ), 0),
      'studentGrowth', coalesce((
        select json_agg(t) from (
          select date_trunc('month', created_at)::date as month, count(*)::int as value
          from filtered_users
          group by date_trunc('month', created_at)
          order by month
        ) t
      ), '[]'::json),
      'genderDistribution', coalesce((
        select json_object_agg(coalesce(gender, 'PREFER_NOT_TO_SAY'), count) from (
          select gender, count(*)::int as count
          from filtered_users
          group by gender
        ) t
      ), '{}'::json)
    ),
    'trainers', coalesce((
      select json_agg(t) from (
        select u.id as trainer_id,
               u.name as trainer_name,
               (select count(distinct date)::int from public.attendance a where a.batch_id in (select id from public.batches b where b.trainer_id = u.id)) as classes_conducted,
               (select count(*)::int from public.attendance a where a.batch_id in (select id from public.batches b where b.trainer_id = u.id)) as attendance_handled,
               (select count(*)::int from public.batches b where b.trainer_id = u.id) as active_batches_count,
               (select count(distinct student_id)::int from public.enrollments e where e.batch_id in (select id from public.batches b where b.trainer_id = u.id)) as student_count
        from public.users u
        where u.role = 'TRAINER'
          and (p_trainer_id is null or u.id = p_trainer_id)
      ) t
    ), '[]'::json),
    'events', coalesce((
      select json_agg(t) from (
        select e.id as event_id,
               e.title,
               e.starts_at,
               (select count(*)::int from public.event_registrations er where er.event_id = e.id) as registrations_count,
               (select count(*)::int from public.event_registrations er where er.event_id = e.id) as attendance_count,
               (e.capacity is not null and (select count(*)::int from public.event_registrations er where er.event_id = e.id) >= e.capacity) as is_full,
               (e.status = 'CANCELLED') as is_cancelled
        from public.events e
        where (p_event_id is null or e.id = p_event_id)
          and (p_start_date is null or e.starts_at >= p_start_date)
          and (p_end_date is null or e.starts_at <= p_end_date)
        order by e.starts_at
      ) t
    ), '[]'::json),
    'holidays', coalesce((
      select json_agg(t) from (
        select h.id as holiday_id,
               h.name,
               h.date,
               (select count(*)::int from public.attendance a where a.date = h.date and status = 'HOLIDAY') as overlap_count
        from public.holidays h
        order by h.date
      ) t
    ), '[]'::json),
    'batches', coalesce((
      select json_agg(t) from (
        select id, name from filtered_batches
      ) t
    ), '[]'::json)
  ) into v_result;

  return v_result;
end;
$$;

-- ── 3. Explicit Grants ────────────────────────────────────────────────────────
grant execute on function public.get_reports_data to authenticated, service_role;
