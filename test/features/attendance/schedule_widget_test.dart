import 'package:divinity_app/features/attendance/data/attendance_repository.dart';
import 'package:divinity_app/features/attendance/domain/attendance_record.dart';
import 'package:divinity_app/features/attendance/presentation/attendance_provider.dart';
import 'package:divinity_app/features/attendance/presentation/weekly_schedule_screen.dart';
import 'package:divinity_app/features/auth/presentation/auth_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:table_calendar/table_calendar.dart';

class MockAttendanceRepository extends Mock implements AttendanceRepository {}

void main() {
  late MockAttendanceRepository mockAttendanceRepo;

  setUp(() {
    mockAttendanceRepo = MockAttendanceRepository();
  });

  Widget createWidgetUnderTest() {
    return ProviderScope(
      overrides: [
        currentUserIdProvider.overrideWithValue('student-1'),
        attendanceRepositoryProvider.overrideWithValue(mockAttendanceRepo),
      ],
      child: const MaterialApp(
        home: WeeklyScheduleScreen(),
      ),
    );
  }

  testWidgets('renders table_calendar and shows class list', (tester) async {
    const weekdayNames = {
      DateTime.monday: 'MON',
      DateTime.tuesday: 'TUE',
      DateTime.wednesday: 'WED',
      DateTime.thursday: 'THU',
      DateTime.friday: 'FRI',
      DateTime.saturday: 'SAT',
      DateTime.sunday: 'SUN',
    };
    final today = DateTime.now();
    final todayWeekday = weekdayNames[today.weekday]!;

    final mockBatch = {
      'id': 'batch-123',
      'name': 'Hatha Yoga Morning',
      'schedule_time': '06:00 AM - 07:00 AM',
      'days_of_week': [todayWeekday],
      'location_lat': 12.9716,
      'location_lng': 77.5946,
      'radius_meters': 100,
      'users': {
        'name': 'Trainer Guru',
      }
    };

    when(() => mockAttendanceRepo.fetchActiveBatch('student-1'))
        .thenAnswer((_) async => mockBatch);

    final todayNormalized = DateTime(today.year, today.month, today.day);

    final mockHistory = [
      AttendanceRecord(
        id: 'rec-1',
        studentId: 'student-1',
        batchId: 'batch-123',
        date: todayNormalized,
        status: AttendanceStatus.present,
        markedBy: MarkedBy.student,
      )
    ];

    when(() => mockAttendanceRepo.fetchHistory('student-1'))
        .thenAnswer((_) async => mockHistory);

    await tester.pumpWidget(createWidgetUnderTest());
    await tester.pump();
    await tester.pumpAndSettle();

    // Verify WeeklyScheduleScreen has TableCalendar
    expect(find.byType(TableCalendar), findsOneWidget);

    // Verify class details are rendered for today
    expect(find.text('Hatha Yoga Morning'), findsOneWidget);
    expect(find.text('06:00 AM - 07:00 AM'), findsOneWidget);
    expect(find.text('Trainer: Trainer Guru'), findsOneWidget);
    expect(find.text('Present'), findsOneWidget);
  });
}
