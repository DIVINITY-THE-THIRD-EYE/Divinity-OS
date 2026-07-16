-- 047_drop_duplicate_attendance_index.sql
-- ─────────────────────────────────────────────────────────────────────────────
-- WHY: The Supabase performance linter (0009 duplicate_index) flags
-- `attendance_student_date_idx` (added in 029) as byte-identical to
-- `attendance_student_id_date_idx` (added in 015) — both index
-- public.attendance(student_id, date desc). 029 used `if not exists` on a NEW
-- NAME, so the guard couldn't see the existing duplicate. Two identical
-- indexes double the write amplification on every check-in for zero read
-- benefit. Keep the older 015 index (its name matches the column list
-- convention used elsewhere); drop 029's duplicate.
-- ─────────────────────────────────────────────────────────────────────────────

drop index if exists public.attendance_student_date_idx;
