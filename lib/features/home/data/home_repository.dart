import 'package:supabase_flutter/supabase_flutter.dart';

import '../domain/home_data.dart';

abstract class HomeRepository {
  Future<HomeData> fetchHomeData(String userId);
}

class SupabaseHomeRepository implements HomeRepository {
  SupabaseHomeRepository(this._client);
  final SupabaseClient _client;

  static const _weekdayMap = {
    'MON': DateTime.monday,
    'TUE': DateTime.tuesday,
    'WED': DateTime.wednesday,
    'THU': DateTime.thursday,
    'FRI': DateTime.friday,
    'SAT': DateTime.saturday,
    'SUN': DateTime.sunday,
  };

  @override
  Future<HomeData> fetchHomeData(String userId) async {
    final results = await Future.wait<dynamic>([
      _client
          .from('users')
          .select('name')
          .eq('id', userId)
          .single(),
      _client
          .from('enrollments')
          .select('batch_id, batches(id, name, schedule_time, days_of_week, trainer_id, users(name))')
          .eq('student_id', userId),
      _client
          .from('attendance')
          .select('date, status')
          .eq('student_id', userId)
          .order('date', ascending: false)
          .limit(60),
    ]);

    final name = (results[0] as Map<String, dynamic>)['name'] as String? ?? '';
    final firstName = name.split(' ').first;

    final enrollments = results[1] as List<dynamic>;
    final attendance = results[2] as List<dynamic>;

    final streak = _computeStreak(attendance);
    final upcoming = _buildUpcomingClasses(enrollments);
    final activity = _buildActivityFeed(attendance);

    return HomeData(
      firstName: firstName,
      streak: streak,
      upcomingClasses: upcoming,
      recentActivity: activity,
    );
  }

  int _computeStreak(List<dynamic> rows) {
    if (rows.isEmpty) return 0;
    final presentDates = rows
        .where((r) => (r['status'] as String?) == 'PRESENT')
        .map((r) => DateTime.parse(r['date'] as String))
        .map((d) => DateTime(d.year, d.month, d.day))
        .toSet();

    final today = DateTime.now();
    var cursor = DateTime(today.year, today.month, today.day);
    var streak = 0;

    // Allow gap of today if not yet marked
    if (!presentDates.contains(cursor)) {
      cursor = cursor.subtract(const Duration(days: 1));
    }

    while (presentDates.contains(cursor)) {
      streak++;
      cursor = cursor.subtract(const Duration(days: 1));
    }
    return streak;
  }

  List<UpcomingClass> _buildUpcomingClasses(List<dynamic> enrollments) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final classes = <UpcomingClass>[];

    for (final e in enrollments) {
      final batch = e['batches'] as Map<String, dynamic>?;
      if (batch == null) continue;

      final daysOfWeek = (batch['days_of_week'] as List<dynamic>?)
          ?.map((d) => d as String)
          .toList() ?? [];
      if (daysOfWeek.isEmpty) continue;

      final trainerRow = batch['users'] as Map<String, dynamic>?;
      final trainerName = trainerRow?['name'] as String?;

      DateTime? nextDate;
      for (var offset = 0; offset <= 7; offset++) {
        final candidate = today.add(Duration(days: offset));
        final weekday = candidate.weekday;
        final dayMatches = daysOfWeek.any(
          (d) => _weekdayMap[d.toUpperCase()] == weekday,
        );
        if (dayMatches) {
          nextDate = candidate;
          break;
        }
      }

      if (nextDate == null) continue;

      classes.add(UpcomingClass(
        batchId: batch['id'] as String,
        batchName: batch['name'] as String,
        scheduleTime: batch['schedule_time'] as String? ?? '',
        nextDate: nextDate,
        trainerName: trainerName,
      ));
    }

    classes.sort((a, b) {
      final dateCmp = a.nextDate.compareTo(b.nextDate);
      if (dateCmp != 0) return dateCmp;
      return a.scheduleTime.compareTo(b.scheduleTime);
    });

    return classes.take(5).toList();
  }

  List<ActivityItem> _buildActivityFeed(List<dynamic> rows) {
    return rows.take(7).map((r) {
      final status = (r['status'] as String?) ?? 'ABSENT';
      final date = DateTime.parse(r['date'] as String);
      return switch (status) {
        'PRESENT' => ActivityItem(
            date: date,
            label: 'Attended class',
            icon: '✅',
            isPositive: true,
          ),
        'EXCUSED' => ActivityItem(
            date: date,
            label: 'Excused absence',
            icon: '📋',
            isPositive: true,
          ),
        'ON_LEAVE' => ActivityItem(
            date: date,
            label: 'On leave',
            icon: '🏖',
            isPositive: true,
          ),
        'HOLIDAY' => ActivityItem(
            date: date,
            label: 'Holiday',
            icon: '🎉',
            isPositive: true,
          ),
        _ => ActivityItem(
            date: date,
            label: 'Absent',
            icon: '❌',
            isPositive: false,
          ),
      };
    }).toList();
  }
}
