-- c25_drop_duplicate_attendance_index_test.sql  (pgTAP)
-- Run with:  supabase test db
--
-- Verifies 047_drop_duplicate_attendance_index.sql: the duplicate
-- attendance_student_date_idx (029) is gone, and the surviving
-- attendance_student_id_date_idx (015) still exists so student
-- attendance-history reads stay indexed.

begin;
select plan(2);

select is(
  (select count(*)::int from pg_indexes
    where schemaname = 'public'
      and indexname = 'attendance_student_date_idx'),
  0,
  'C25.1 duplicate attendance_student_date_idx is dropped'
);

select is(
  (select count(*)::int from pg_indexes
    where schemaname = 'public'
      and indexname = 'attendance_student_id_date_idx'),
  1,
  'C25.2 original attendance_student_id_date_idx survives'
);

select * from finish();
rollback;
