import 'package:intl/intl.dart';

class Holiday {
  const Holiday({
    required this.id,
    required this.date,
    required this.name,
    required this.createdAt,
  });

  final String id;
  final DateTime date;
  final String name;
  final DateTime createdAt;

  factory Holiday.fromMap(Map<String, dynamic> m) => Holiday(
        id: m['id'] as String,
        date: DateTime.parse(m['date'] as String),
        name: m['name'] as String,
        createdAt: DateTime.parse(m['created_at'] as String),
      );

  String get dateLabel => DateFormat('d MMM yyyy').format(date);

  String get dayLabel => DateFormat('EEEE').format(date);
}
