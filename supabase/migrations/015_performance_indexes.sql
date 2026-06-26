-- 015_performance_indexes.sql
-- ─────────────────────────────────────────────────────────────────────────────
-- FIX B3 — Add performance indexes for hot queries
--
-- Create indexes on foreign keys and commonly filtered columns:
--   - payments(student_id)
--   - notifications(user_id, is_read)
-- ─────────────────────────────────────────────────────────────────────────────

create index if not exists payments_student_id_idx on public.payments(student_id);
create index if not exists notifications_user_id_is_read_idx on public.notifications(user_id, is_read);
create index if not exists attendance_student_id_date_idx on public.attendance(student_id, date desc);
