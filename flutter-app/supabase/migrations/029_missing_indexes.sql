-- 029_missing_indexes.sql
-- ─────────────────────────────────────────────────────────────────────────────
-- Critical missing indexes identified in the July 2026 production audit (LB-8).
-- All four are high-frequency filter columns with no existing index.
-- Also adds composite indexes for common query patterns from reports.
-- ─────────────────────────────────────────────────────────────────────────────

-- Leads: pipeline_status is the primary filter column in LeadsScreen
create index if not exists leads_pipeline_status_idx
  on public.leads(pipeline_status);

-- Leave requests: student_id is the only filter used in leave_repository.dart
create index if not exists leave_requests_student_id_idx
  on public.leave_requests(student_id);

-- Therapeutic logs: high read volume per student in TherapeuticLogsScreen
create index if not exists therapeutic_logs_student_id_idx
  on public.therapeutic_logs(student_id);

-- Transformation scores: student_id used in ThirdEyeDashboardScreen queries
create index if not exists transformation_scores_student_id_idx
  on public.transformation_scores(student_id);

-- Composite index for the common attendance query pattern
-- (student_id + date desc) used in home and attendance history screens
create index if not exists attendance_student_date_idx
  on public.attendance(student_id, date desc);

-- Composite index for enrollment lookups used in reports and batch assignment
create index if not exists enrollments_batch_student_idx
  on public.enrollments(batch_id, student_id);
