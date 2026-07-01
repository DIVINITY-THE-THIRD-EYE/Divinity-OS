import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';

import '../../../services/analytics_service.dart';
import '../../auth/presentation/auth_provider.dart';
import '../data/attendance_repository.dart';
import '../domain/attendance_record.dart';

final attendanceRepositoryProvider = Provider<AttendanceRepository>(
  (ref) => SupabaseAttendanceRepository(ref.watch(supabaseClientProvider)),
);

// ── Today's record ────────────────────────────────────────────────────────────

class TodayAttendanceNotifier extends AsyncNotifier<AttendanceRecord?> {
  @override
  Future<AttendanceRecord?> build() {
    final uid = ref.watch(currentUserIdProvider);
    if (uid == null) return Future.value();
    return ref.read(attendanceRepositoryProvider).fetchTodayRecord(uid);
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => future);
  }

  Future<AttendanceRecord> checkIn({
    required double lat,
    required double lng,
    String? batchId,
  }) async {
    // On reject, CheckInException propagates and `state` is left as the real
    // persisted today-record (no error-card flicker); the screen shows a snackbar.
    final record = await ref
        .read(attendanceRepositoryProvider)
        .checkIn(lat: lat, lng: lng, batchId: batchId);
    state = AsyncData(record);
    if (batchId != null) {
      try {
        AnalyticsService.logCheckIn(batchId: batchId).ignore();
      } catch (_) {}
    }
    return record;
  }
}

final todayAttendanceProvider =
    AsyncNotifierProvider<TodayAttendanceNotifier, AttendanceRecord?>(
      TodayAttendanceNotifier.new,
    );

// ── History ───────────────────────────────────────────────────────────────────

class AttendanceHistoryNotifier extends AsyncNotifier<List<AttendanceRecord>> {
  @override
  Future<List<AttendanceRecord>> build() {
    final uid = ref.watch(currentUserIdProvider);
    if (uid == null) return Future.value([]);
    return ref.read(attendanceRepositoryProvider).fetchHistory(uid);
  }
}

final attendanceHistoryProvider =
    AsyncNotifierProvider<AttendanceHistoryNotifier, List<AttendanceRecord>>(
      AttendanceHistoryNotifier.new,
    );

// ── Geolocation helpers ───────────────────────────────────────────────────────

class GeolocationNotifier extends AsyncNotifier<Position?> {
  @override
  Future<Position?> build() => Future.value();

  Future<String?> requestAndFetch() async {
    state = const AsyncLoading();
    try {
      var perm = await Geolocator.checkPermission();
      if (perm == LocationPermission.denied) {
        perm = await Geolocator.requestPermission();
      }
      if (perm == LocationPermission.deniedForever ||
          perm == LocationPermission.denied) {
        state = const AsyncData(null);
        return 'Location permission denied. Please enable in settings.';
      }
      final pos = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 10),
        ),
      );
      state = AsyncData(pos);
      return null;
    } catch (e) {
      state = const AsyncData(null);
      return 'Could not get location: $e';
    }
  }
}

final geolocationProvider =
    AsyncNotifierProvider<GeolocationNotifier, Position?>(
      GeolocationNotifier.new,
    );

// ── Active batch for student ──────────────────────────────────────────────────

final activeBatchProvider = FutureProvider<Map<String, dynamic>?>((ref) {
  final uid = ref.watch(currentUserIdProvider);
  if (uid == null) return Future.value();
  return ref.read(attendanceRepositoryProvider).fetchActiveBatch(uid);
});
