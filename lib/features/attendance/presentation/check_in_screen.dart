import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_theme.dart';
import '../../../shared/widgets/loading_widget.dart' show ChakraLoader;
import '../../leave/presentation/leave_request_screen.dart';
import '../domain/attendance_record.dart';
import 'attendance_history_screen.dart';
import 'attendance_provider.dart';

class CheckInScreen extends ConsumerWidget {
  const CheckInScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final todayAsync = ref.watch(todayAttendanceProvider);
    final batchAsync = ref.watch(activeBatchProvider);
    final geoAsync = ref.watch(geolocationProvider);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _DateCard(),
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
              isLoading: geoAsync.isLoading,
              todayRecord: todayAsync.value,
              onCheckIn: () => _handleCheckIn(context, ref, batch),
            ),
          ),
          const SizedBox(height: 12),
          OutlinedButton.icon(
            onPressed: () => _showLeaveSheet(context),
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

  Future<void> _handleCheckIn(
    BuildContext context,
    WidgetRef ref,
    Map<String, dynamic>? batch,
  ) async {
    // 1. Request location
    final geoNotifier = ref.read(geolocationProvider.notifier);
    final error = await geoNotifier.requestAndFetch();
    if (error != null && context.mounted) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(error)));
      return;
    }

    final pos = ref.read(geolocationProvider).value;

    // 2. Validate geofence if batch has location
    if (pos != null && batch != null) {
      final lat = (batch['location_lat'] as num?)?.toDouble();
      final lng = (batch['location_lng'] as num?)?.toDouble();
      if (lat != null && lng != null) {
        final dist = Geolocator.distanceBetween(
          pos.latitude, pos.longitude, lat, lng,
        );
        if (dist > AppConstants.geofenceDefaultRadius && context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(
              'You are ${dist.toStringAsFixed(0)} m from the centre '
              '(max ${AppConstants.geofenceDefaultRadius.toStringAsFixed(0)} m).',
            ),
          ));
          return;
        }
      }
    }

    // 3. Record check-in
    final batchId = batch?['id'] as String?;
    await ref.read(todayAttendanceProvider.notifier).checkIn(batchId: batchId);

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Check-in recorded ✓')),
      );
    }
    ref.invalidate(attendanceHistoryProvider);
  }

  void _showLeaveSheet(BuildContext context) {
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

    String? distanceLabel;
    if (position != null && batch != null) {
      final lat = (batch!['location_lat'] as num?)?.toDouble();
      final lng = (batch!['location_lng'] as num?)?.toDouble();
      if (lat != null && lng != null) {
        final dist = Geolocator.distanceBetween(
          position!.latitude, position!.longitude, lat, lng,
        );
        distanceLabel =
            '${dist.toStringAsFixed(0)} m from ${batch!['name'] ?? 'centre'}';
      }
    }

    return Card(
      color: AppColors.accentViolet.withValues(alpha: 0.1),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (batch != null)
              Text(
                'Batch: ${batch!['name'] ?? 'Unnamed'} · ${batch!['schedule_time'] ?? ''}',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            if (distanceLabel != null) ...[
              const SizedBox(height: 4),
              Text(distanceLabel,
                  style: Theme.of(context).textTheme.bodySmall),
            ],
            const SizedBox(height: 12),
            FilledButton.icon(
              onPressed: alreadyPresent || isLoading ? null : onCheckIn,
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
