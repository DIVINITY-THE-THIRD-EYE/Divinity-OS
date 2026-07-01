import 'package:flutter/foundation.dart'
    show kDebugMode, defaultTargetPlatform, TargetPlatform;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_theme.dart';
import '../../../services/analytics_service.dart';
import '../../../shared/widgets/loading_widget.dart' show ChakraLoader;
import '../../leave/presentation/leave_request_screen.dart';
import '../data/attendance_repository.dart' show CheckInException;
import '../domain/attendance_record.dart';
import 'attendance_history_screen.dart';
import 'attendance_provider.dart';

class CheckInScreen extends ConsumerStatefulWidget {
  const CheckInScreen({super.key});

  @override
  ConsumerState<CheckInScreen> createState() => _CheckInScreenState();
}

class _CheckInScreenState extends ConsumerState<CheckInScreen> {
  bool _submitting = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(geolocationProvider.notifier).requestAndFetch();
    });
  }

  @override
  Widget build(BuildContext context) {
    final todayAsync = ref.watch(todayAttendanceProvider);
    final batchAsync = ref.watch(activeBatchProvider);
    final geoAsync = ref.watch(geolocationProvider);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _DateCard(),
          const SizedBox(height: 12),
          ElevatedButton.icon(
            key: const Key('weekly_schedule_btn'),
            onPressed: () => context.push('/schedule'),
            icon: const Icon(Icons.calendar_month_outlined),
            label: const Text('Weekly Schedule'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 12),
            ),
          ),
          const SizedBox(height: 16),
          todayAsync.when(
            loading: () => const Center(child: ChakraLoader()),
            error: (e, _) => _ErrorCard(message: e.toString()),
            data: (record) => _StatusCard(record: record),
          ),
          const SizedBox(height: 16),
          batchAsync.when(
            loading: () => const SizedBox.shrink(),
            error: (_, _) => const SizedBox.shrink(),
            data: (batch) => _CheckInCard(
              batch: batch,
              position: geoAsync.value,
              isLoading: geoAsync.isLoading || _submitting,
              todayRecord: todayAsync.value,
              onCheckIn: () => _handleCheckIn(batch),
            ),
          ),
          const SizedBox(height: 12),
          OutlinedButton.icon(
            onPressed: _showLeaveSheet,
            icon: const Icon(Icons.event_busy_outlined),
            label: const Text('Request Leave'),
          ),
          const SizedBox(height: 24),
          const Text('Recent Attendance', style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          const _RecentList(),
        ],
      ),
    );
  }

  Future<void> _handleCheckIn(Map<String, dynamic>? batch) async {
    if (_submitting) return; // re-entrancy guard (double-tap)
    final messenger = ScaffoldMessenger.of(context);

    // 1. Resolve device location (permission prompt + fix).
    final error = await ref.read(geolocationProvider.notifier).requestAndFetch();
    if (error != null) {
      messenger.showSnackBar(SnackBar(content: Text(error)));
      return;
    }
    final pos = ref.read(geolocationProvider).value;
    if (pos == null) {
      messenger.showSnackBar(
        const SnackBar(content: Text('Could not determine your location.')),
      );
      return;
    }

    // 2. Mock-location deterrent (Android-only; isMocked is always false on
    // iOS). Excluded in debug builds so emulators/QA devices are not blocked.
    if (!kDebugMode &&
        defaultTargetPlatform == TargetPlatform.android &&
        pos.isMocked) {
      try {
        AnalyticsService.logMockLocationBlocked().ignore();
      } catch (_) {}
      messenger.showSnackBar(const SnackBar(
        content: Text(
          'Mock location detected. Disable fake GPS / developer location '
          'mocking to check in. Contact your trainer if this is a mistake.',
        ),
      ));
      return;
    }

    // 3. Fast-fail hint
    if (batch != null) {
      final lat = (batch['location_lat'] as num?)?.toDouble();
      final lng = (batch['location_lng'] as num?)?.toDouble();
      if (lat != null && lng != null) {
        final radius = (batch['radius_meters'] as num?)?.toDouble()
            ?? AppConstants.geofenceDefaultRadius;
        final dist = Geolocator.distanceBetween(
          pos.latitude, pos.longitude, lat, lng,
        );
        if (dist > radius) {
          messenger.showSnackBar(SnackBar(content: Text(
            'You are ${dist.toStringAsFixed(0)} m from the centre '
            '(max ${radius.toStringAsFixed(0)} m).',
          )));
          return;
        }
      }
    }

    // 4. Server-validated check-in.
    setState(() => _submitting = true);
    try {
      final record = await ref.read(todayAttendanceProvider.notifier).checkIn(
            lat: pos.latitude,
            lng: pos.longitude,
            batchId: batch?['id'] as String?,
          );
      if (!mounted) return;
      
      if (record.status == AttendanceStatus.present) {
        messenger.showSnackBar(
          const SnackBar(content: Text('Check-in recorded ✓')),
        );
      } else {
        messenger.showSnackBar(
          SnackBar(
            content: Text(
              'Check-in received. Maintained "${record.status.label}" '
              'previously marked by ${record.markedBy.label}.',
            ),
          ),
        );
      }
      ref.invalidate(attendanceHistoryProvider);
    } on CheckInException catch (e) {
      messenger.showSnackBar(SnackBar(content: Text(e.message)));
    } catch (e) {
      messenger.showSnackBar(SnackBar(content: Text('Check-in failed: $e')));
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  void _showLeaveSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) => const LeaveRequestSheet(),
    );
  }
}

// ── Subwidgets ────────────────────────────────────────────────────────────────

class _DateCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            const Icon(Icons.calendar_today_outlined),
            const SizedBox(width: 12),
            Text(
              DateFormat('EEEE, d MMMM yyyy').format(now),
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ],
        ),
      ),
    );
  }
}

class _StatusCard extends StatelessWidget {
  const _StatusCard({required this.record});
  final AttendanceRecord? record;

  @override
  Widget build(BuildContext context) {
    if (record == null) {
      return const Card(
        child: ListTile(
          leading: Icon(Icons.radio_button_unchecked, color: Colors.orange),
          title: Text('Not checked in yet'),
          subtitle: Text('Tap "Check In Now" below'),
        ),
      );
    }

    final color = record!.status == AttendanceStatus.present
        ? Colors.green
        : Colors.grey;

    return Card(
      child: ListTile(
        leading: Icon(Icons.check_circle, color: color),
        title: Text(record!.status.label),
        subtitle: record!.checkinTime != null
            ? Text(
                'Checked in at ${DateFormat('HH:mm').format(record!.checkinTime!.toLocal())}',
              )
            : null,
      ),
    );
  }
}

class _CheckInCard extends StatelessWidget {
  const _CheckInCard({
    required this.batch,
    required this.position,
    required this.isLoading,
    required this.todayRecord,
    required this.onCheckIn,
  });

  final Map<String, dynamic>? batch;
  final Position? position;
  final bool isLoading;
  final AttendanceRecord? todayRecord;
  final VoidCallback onCheckIn;

  @override
  Widget build(BuildContext context) {
    final alreadyPresent = todayRecord?.status == AttendanceStatus.present;

    if (batch == null) return const SizedBox.shrink();

    final lat = (batch!['location_lat'] as num?)?.toDouble();
    final lng = (batch!['location_lng'] as num?)?.toDouble();
    final radius = (batch!['radius_meters'] as num?)?.toDouble() ??
        AppConstants.geofenceDefaultRadius;
    final trainerName = batch!['users']?['name'] ?? 'Not assigned';
    final scheduleTime = batch!['schedule_time'] ?? 'No time set';

    double? distance;
    bool isWithinGeofence = false;

    if (position != null && lat != null && lng != null) {
      distance = Geolocator.distanceBetween(
        position!.latitude,
        position!.longitude,
        lat,
        lng,
      );
      isWithinGeofence = distance <= radius;
    }

    final String distanceText;
    if (position == null) {
      distanceText = 'Distance: Unknown (Locating device...)';
    } else {
      distanceText = 'Distance: ${distance?.toStringAsFixed(0) ?? '0'} meters (limit: ${radius.toStringAsFixed(0)} meters)';
    }

    final bool canCheckIn = !alreadyPresent &&
        !isLoading &&
        position != null &&
        isWithinGeofence;

    return Card(
      color: AppColors.accentViolet.withValues(alpha: 0.1),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              "Today's Class",
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.accentViolet,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              'Batch: ${batch!['name'] ?? 'Unnamed'}',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                const Icon(Icons.access_time, size: 16, color: Colors.grey),
                const SizedBox(width: 6),
                Text('Time: $scheduleTime'),
              ],
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                const Icon(Icons.person_outline, size: 16, color: Colors.grey),
                const SizedBox(width: 6),
                Text('Trainer: $trainerName'),
              ],
            ),
            if (lat != null && lng != null) ...[
              const SizedBox(height: 4),
              Row(
                children: [
                  const Icon(Icons.pin_drop_outlined, size: 16, color: Colors.grey),
                  const SizedBox(width: 6),
                  Text('Location: Lat ${lat.toStringAsFixed(4)}, Lng ${lng.toStringAsFixed(4)}'),
                ],
              ),
            ],
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: isWithinGeofence
                    ? AppColors.success.withValues(alpha: 0.1)
                    : AppColors.error.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: isWithinGeofence ? AppColors.success : AppColors.error,
                ),
              ),
              child: Text(
                distanceText,
                style: TextStyle(
                  color: isWithinGeofence ? AppColors.success : AppColors.error,
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 12),
            FilledButton.icon(
              key: const Key('check_in_now_btn'),
              onPressed: canCheckIn ? onCheckIn : null,
              icon: isLoading
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: Colors.white),
                    )
                  : const Icon(Icons.location_on_outlined),
              label: Text(alreadyPresent ? 'Already Checked In' : 'Check In Now'),
            ),
          ],
        ),
      ),
    );
  }
}

class _RecentList extends ConsumerWidget {
  const _RecentList();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final historyAsync = ref.watch(attendanceHistoryProvider);
    return historyAsync.when(
      loading: () => const Center(child: ChakraLoader()),
      error: (e, _) => _ErrorCard(message: e.toString()),
      data: (records) {
        if (records.isEmpty) {
          return const Center(child: Text('No attendance history yet.'));
        }
        final recent = records.take(7).toList();
        return ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: recent.length,
          separatorBuilder: (_, _) => const Divider(height: 1),
          itemBuilder: (ctx, i) => AttendanceHistoryScreen.buildTile(ctx, recent[i]),
        );
      },
    );
  }
}

class _ErrorCard extends StatelessWidget {
  const _ErrorCard({required this.message});
  final String message;

  @override
  Widget build(BuildContext context) => Card(
        color: Colors.red.shade50,
        child: ListTile(
          leading: const Icon(Icons.error_outline, color: Colors.red),
          title: Text(message, style: const TextStyle(fontSize: 13)),
        ),
      );
}
