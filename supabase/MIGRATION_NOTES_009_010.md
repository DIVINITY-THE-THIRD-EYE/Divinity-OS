# Migration Notes — 009 & 010 (Security Fixes C1 + C2)

**Status:** Generated for review. **Nothing has been applied to any database.**
**Author note:** these close the two launch-blockers from `AUDIT_REPORT.md`.

| File | Closes | Type |
|---|---|---|
| `migrations/009_lock_privileged_fields.sql` | C1 — role/plan self-escalation | Trigger (additive) |
| `migrations/010_attendance_geofence_rpc.sql` | C2 — client-only geofence | RPC + policy removal |
| `tests/c1_privileged_fields_test.sql` | C1 regression | pgTAP (7 assertions) |
| `tests/c2_geofence_test.sql` | C2 regression | pgTAP (6 assertions) |

---

## ⚠️ REQUIRED client change (ships WITH 010, not after)

Migration 010 **drops** the `attendance_insert_student` policy. The current client
does a direct upsert, which will then **fail closed** (safe, but check-in breaks).
Update the repository to call the RPC. This is the only code change required.

`lib/features/attendance/data/attendance_repository.dart` — replace `checkIn`:

```dart
@override
Future<AttendanceRecord> checkIn(
  String studentId, {
  String? batchId,
  double? lat,
  double? lng,
}) async {
  if (lat == null || lng == null) {
    throw StateError('Location required to check in');
  }
  final row = await _client.rpc('check_in', params: {
    'p_lat': lat,
    'p_lng': lng,
    'p_batch_id': batchId,
  });
  return AttendanceRecord.fromMap((row as List).first as Map<String, dynamic>);
}
```

> `studentId` is no longer trusted — the RPC uses `auth.uid()`. Keep the param for
> interface compatibility or drop it. The caller in `attendance_provider.dart`
> already obtains the device position via `geolocationProvider`; pass that
> position's `latitude`/`longitude` into `checkIn`. The client-side Haversine
> check becomes a UX nicety (fast-fail before the round-trip); the server is now
> authoritative.

Interface + provider deltas:
- `AttendanceRepository.checkIn` signature gains `double? lat, double? lng`.
- `TodayAttendanceNotifier.checkIn` resolves the position first, then calls the repo.

---

## Apply procedure (staging → prod)

```bash
# 0. From divinity_flutter/. Confirm only 009/010 are pending.
supabase migration list

# 1. STAGING first.
supabase link --project-ref <STAGING_REF>
supabase db push                 # applies 009 then 010

# 2. Run the regression suite (must be GREEN before prod).
supabase test db                 # runs tests/*.sql via pgTAP

# 3. Ship the client change to staging, smoke-test real check-in on a phone
#    inside and outside the geofence.

# 4. PRODUCTION — only after staging is green and smoke-tested.
supabase link --project-ref <PROD_REF>
supabase db push
supabase test db
```

**Ordering:** 009 is independent and can go first/alone safely. 010 must be paired
with the client RPC change in the same release window.

---

## Verification checklist (manual, post-apply)

C1:
- [ ] As a student JWT: `update users set role='ADMIN' where id=<self>` → **denied** (42501).
- [ ] As a student JWT: `update users set plan_status='ACTIVE' where id=<self>` → **denied**.
- [ ] Fresh signup → onboarding completes (sets `plan_status=PENDING_ADMIN`) → **works**.
- [ ] Admin “Activate plan” on a student → **works**.

C2:
- [ ] Student check-in inside radius → row `PRESENT` / `marked_by=STUDENT`.
- [ ] Student check-in outside radius → error shown, **no row**.
- [ ] Direct `insert into attendance ...` as student JWT → **denied**.
- [ ] Trainer ABSENT mark is **not** overwritten by a later student check-in.

---

## Rollback

> Supabase migrations are forward-only. Do **not** drop rollback `.sql` into
> `migrations/` — run these by hand (`supabase db execute` / SQL editor).

**009 rollback** (re-opens C1 — emergency only):
```sql
drop trigger if exists users_lock_privileged on public.users;
drop function if exists public.lock_privileged_fields();
```

**010 rollback** (re-opens C2 — also revert the client to the direct upsert):
```sql
create policy "attendance_insert_student" on public.attendance
  for insert with check (student_id = auth.uid());
drop function if exists public.check_in(double precision, double precision, uuid);
drop function if exists public.haversine_m(double precision, double precision, double precision, double precision);
```

Both rollbacks are non-destructive to data (they only drop the guard
function/trigger/policy; no rows are touched). Prefer fixing-forward over rolling
back, since rollback restores a known-exploitable state.

---

## Design notes / assumptions (flag if any are wrong)

1. **Trusted-context bypass.** 009 allows the write when `auth.uid()` is null
   (service_role key, migrations, direct DB). If a future backend job updates
   `users` with a *user* JWT it would be subject to the lock — use the service
   role for such jobs.
2. **Trainer plan activation.** Today only admins can update other users' rows
   (RLS), so 009 locks plan fields to ADMIN. When Milestone 2 adds trainer
   verification, add a trainer UPDATE policy **and** widen 009's plan_status
   branch to allow `TRAINER`.
3. **Streak fields locked to admin.** No client writes `current_streak`/
   `max_streak` today (grep-confirmed: read-only). A future server-side streak
   job should run as service_role (auto-bypasses the lock).
4. **Date basis.** `check_in` stamps the day in `Asia/Kolkata`, not device-local
   time — more reliable for the `unique(student_id, date)` constraint than the
   client's `DateFormat('yyyy-MM-dd')` on device time.
5. **Open geofence.** A batch with null `location_lat/lng` is treated as “no
   geofence” (check-in allowed). Batches created via `admin_batches_screen`
   should set coordinates to enforce the radius.
6. **pgTAP fixtures** insert into `auth.users (id, email)` and rely on the
   `handle_new_user` trigger + column defaults. If your instance has extra NOT
   NULL columns on `auth.users`, add them to the fixture inserts or use the
   `supabase_test_helpers` extension.
