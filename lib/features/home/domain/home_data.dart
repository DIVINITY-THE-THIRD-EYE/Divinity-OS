import 'package:intl/intl.dart';

class UpcomingClass {
  const UpcomingClass({
    required this.batchId,
    required this.batchName,
    required this.scheduleTime,
    required this.nextDate,
    this.trainerName,
  });

  final String batchId;
  final String batchName;
  final String scheduleTime;
  final DateTime nextDate;
  final String? trainerName;

  String get dayLabel {
    final today = DateTime.now();
    final d = DateTime(nextDate.year, nextDate.month, nextDate.day);
    final t = DateTime(today.year, today.month, today.day);
    final diff = d.difference(t).inDays;
    if (diff == 0) return 'Today';
    if (diff == 1) return 'Tomorrow';
    return DateFormat('EEE, MMM d').format(nextDate);
  }
}

class HomeData {
  const HomeData({
    required this.firstName,
    required this.streak,
    required this.upcomingClasses,
    required this.recentActivity,
  });

  final String firstName;
  final int streak;
  final List<UpcomingClass> upcomingClasses;
  final List<ActivityItem> recentActivity;
}

class ActivityItem {
  const ActivityItem({
    required this.date,
    required this.label,
    required this.icon,
    required this.isPositive,
  });

  final DateTime date;
  final String label;
  final String icon;
  final bool isPositive;

  String get dateLabel => DateFormat('EEE, MMM d').format(date);
}
