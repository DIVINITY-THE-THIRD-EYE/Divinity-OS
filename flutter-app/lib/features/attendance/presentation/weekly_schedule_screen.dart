import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:table_calendar/table_calendar.dart';

import '../../../core/theme/app_theme.dart';
import '../../../shared/widgets/loading_widget.dart';
import '../domain/attendance_record.dart';
import 'attendance_provider.dart';

class WeeklyScheduleScreen extends ConsumerStatefulWidget {
  const WeeklyScheduleScreen({super.key});

  @override
  ConsumerState<WeeklyScheduleScreen> createState() =>
      _WeeklyScheduleScreenState();
}

class _WeeklyScheduleScreenState extends ConsumerState<WeeklyScheduleScreen> {
  late DateTime _focusedDay;
  late DateTime _selectedDay;

  static const _weekdayNames = {
    DateTime.monday: 'MON',
    DateTime.tuesday: 'TUE',
    DateTime.wednesday: 'WED',
    DateTime.thursday: 'THU',
    DateTime.friday: 'FRI',
    DateTime.saturday: 'SAT',
    DateTime.sunday: 'SUN',
  };

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _focusedDay = now;
    _selectedDay = now;
  }

  @override
  Widget build(BuildContext context) {
    final activeBatchAsync = ref.watch(activeBatchProvider);
    final historyAsync = ref.watch(attendanceHistoryProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Weekly Schedule')),
      body: activeBatchAsync.when(
        loading: () => const Center(child: ChakraLoader()),
        error: (err, _) => Center(child: Text('Error loading schedule: $err')),
        data: (batch) {
          if (batch == null) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(20),
                child: Text(
                  'No active batch found. Enroll in a batch to view your schedule.',
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }

          final daysOfWeek =
              (batch['days_of_week'] as List<dynamic>?)
                  ?.map((d) => d.toString().toUpperCase())
                  .toList() ??
              [];

          // Filter history matching selected date
          final matchingRecord = historyAsync.maybeWhen(
            data: (records) {
              try {
                return records.firstWhere(
                  (r) =>
                      r.date.year == _selectedDay.year &&
                      r.date.month == _selectedDay.month &&
                      r.date.day == _selectedDay.day,
                );
              } catch (_) {
                return null;
              }
            },
            orElse: () => null,
          );

          final selectedWeekdayStr = _weekdayNames[_selectedDay.weekday];
          final hasClassOnSelectedDay = daysOfWeek.contains(selectedWeekdayStr);

          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Card(
                margin: const EdgeInsets.all(12),
                child: TableCalendar(
                  firstDay: DateTime.now().subtract(const Duration(days: 365)),
                  lastDay: DateTime.now().add(const Duration(days: 365)),
                  focusedDay: _focusedDay,
                  calendarFormat: CalendarFormat.week,
                  selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
                  onDaySelected: (selectedDay, focusedDay) {
                    setState(() {
                      _selectedDay = selectedDay;
                      _focusedDay = focusedDay;
                    });
                  },
                  eventLoader: (day) {
                    final dayStr = _weekdayNames[day.weekday];
                    if (daysOfWeek.contains(dayStr)) {
                      return ['Class'];
                    }
                    return [];
                  },
                  headerStyle: const HeaderStyle(
                    formatButtonVisible: false,
                    titleCentered: true,
                  ),
                  calendarBuilders: CalendarBuilders(
                    markerBuilder: (context, date, events) {
                      if (events.isNotEmpty) {
                        return Positioned(
                          bottom: 4,
                          child: Container(
                            width: 6,
                            height: 6,
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              color: AppColors.accentViolet,
                            ),
                          ),
                        );
                      }
                      return null;
                    },
                  ),
                ),
              ),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Text(
                  'Classes for this day',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
              ),
              Expanded(
                child: hasClassOnSelectedDay
                    ? Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        child: ListView(
                          children: [
                            _ClassDetailsCard(
                              batch: batch,
                              selectedDate: _selectedDay,
                              record: matchingRecord,
                            ),
                          ],
                        ),
                      )
                    : const Center(
                        child: Text(
                          'No classes scheduled for this day.',
                          style: TextStyle(color: Colors.grey),
                        ),
                      ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _ClassDetailsCard extends StatelessWidget {
  const _ClassDetailsCard({
    required this.batch,
    required this.selectedDate,
    required this.record,
  });

  final Map<String, dynamic> batch;
  final DateTime selectedDate;
  final AttendanceRecord? record;

  @override
  Widget build(BuildContext context) {
    final name = batch['name'] ?? 'Unnamed Batch';
    final scheduleTime = batch['schedule_time'] ?? 'No time set';
    final trainerName = batch['users']?['name'] ?? 'Not assigned';

    final Color statusColor;
    final String statusLabel;

    if (record != null) {
      statusLabel = record!.status.label;
      statusColor = switch (record!.status) {
        AttendanceStatus.present => AppColors.success,
        AttendanceStatus.excused ||
        AttendanceStatus.onLeave => AppColors.warning,
        AttendanceStatus.holiday => Colors.blue,
        AttendanceStatus.cancelled => Colors.grey,
        AttendanceStatus.absent => AppColors.error,
      };
    } else {
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      final sel = DateTime(
        selectedDate.year,
        selectedDate.month,
        selectedDate.day,
      );
      if (sel.isAfter(today)) {
        statusLabel = 'Scheduled';
        statusColor = Colors.blue;
      } else {
        statusLabel = 'Not Checked In';
        statusColor = AppColors.error;
      }
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    name,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: statusColor),
                  ),
                  child: Text(
                    statusLabel,
                    style: TextStyle(
                      color: statusColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                const Icon(Icons.access_time, size: 18, color: Colors.grey),
                const SizedBox(width: 8),
                Text(scheduleTime),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.person_outline, size: 18, color: Colors.grey),
                const SizedBox(width: 8),
                Text('Trainer: $trainerName'),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
