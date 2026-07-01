import 'package:divinity_app/features/attendance/data/attendance_repository.dart';
import 'package:divinity_app/features/attendance/presentation/attendance_provider.dart';
import 'package:divinity_app/features/attendance/presentation/check_in_screen.dart';
import 'package:divinity_app/features/auth/presentation/auth_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:geolocator/geolocator.dart';
import 'package:mocktail/mocktail.dart';

class MockAttendanceRepository extends Mock implements AttendanceRepository {}

class FakeGeolocationNotifier extends GeolocationNotifier {
  FakeGeolocationNotifier(this._position);
  final Position? _position;

  @override
  Future<Position?> build() async => _position;

  @override
  Future<String?> requestAndFetch() async {
    state = AsyncData(_position);
    return null;
  }
}

void main() {
  late MockAttendanceRepository mockAttendanceRepo;

  setUp(() {
    mockAttendanceRepo = MockAttendanceRepository();
  });

  Widget createWidgetUnderTest({
    required Position? position,
    required Map<String, dynamic>? batch,
  }) {
    return ProviderScope(
      overrides: [
        currentUserIdProvider.overrideWithValue('student-1'),
        attendanceRepositoryProvider.overrideWithValue(mockAttendanceRepo),
        if (batch != null) activeBatchProvider.overrideWith((ref) => batch),
        geolocationProvider.overrideWith(() => FakeGeolocationNotifier(position)),
      ],
      child: const MaterialApp(
        home: Scaffold(
          body: CheckInScreen(),
        ),
      ),
    );
  }

  testWidgets('Check In button is disabled if distance > radius', (tester) async {
    final mockBatch = {
      'id': 'batch-123',
      'name': 'Hatha Yoga Morning',
      'schedule_time': '06:00 AM - 07:00 AM',
      'days_of_week': ['MON', 'WED'],
      'location_lat': 12.9716,
      'location_lng': 77.5946,
      'radius_meters': 100.0,
      'users': {
        'name': 'Trainer Guru',
      }
    };

    // User is far away (e.g. lat 13.9716 is ~110 km away)
    final farPosition = Position(
      latitude: 13.9716,
      longitude: 77.5946,
      timestamp: DateTime.now(),
      accuracy: 1.0,
      altitude: 1.0,
      altitudeAccuracy: 1.0,
      heading: 1.0,
      headingAccuracy: 1.0,
      speed: 1.0,
      speedAccuracy: 1.0,
    );

    when(() => mockAttendanceRepo.fetchActiveBatch('student-1'))
        .thenAnswer((_) async => mockBatch);
    when(() => mockAttendanceRepo.fetchTodayRecord('student-1'))
        .thenAnswer((_) async => null);
    when(() => mockAttendanceRepo.fetchHistory('student-1'))
        .thenAnswer((_) async => []);

    await tester.pumpWidget(createWidgetUnderTest(
      position: farPosition,
      batch: mockBatch,
    ));
    await tester.pump();
    await tester.pumpAndSettle();

    // Verify distance is shown
    expect(find.textContaining('limit: 100 meters'), findsOneWidget);

    // Verify Check In button is disabled
    final btnFinder = find.byKey(const Key('check_in_now_btn'));
    expect(btnFinder, findsOneWidget);
    
    final FilledButton button = tester.widget<FilledButton>(btnFinder);
    expect(button.onPressed, isNull); // disabled
  });

  testWidgets('Check In button is enabled if distance <= radius', (tester) async {
    final mockBatch = {
      'id': 'batch-123',
      'name': 'Hatha Yoga Morning',
      'schedule_time': '06:00 AM - 07:00 AM',
      'days_of_week': ['MON', 'WED'],
      'location_lat': 12.9716,
      'location_lng': 77.5946,
      'radius_meters': 100.0,
      'users': {
        'name': 'Trainer Guru',
      }
    };

    // User is at the exact location
    final nearPosition = Position(
      latitude: 12.9716,
      longitude: 77.5946,
      timestamp: DateTime.now(),
      accuracy: 1.0,
      altitude: 1.0,
      altitudeAccuracy: 1.0,
      heading: 1.0,
      headingAccuracy: 1.0,
      speed: 1.0,
      speedAccuracy: 1.0,
    );

    when(() => mockAttendanceRepo.fetchActiveBatch('student-1'))
        .thenAnswer((_) async => mockBatch);
    when(() => mockAttendanceRepo.fetchTodayRecord('student-1'))
        .thenAnswer((_) async => null);
    when(() => mockAttendanceRepo.fetchHistory('student-1'))
        .thenAnswer((_) async => []);

    await tester.pumpWidget(createWidgetUnderTest(
      position: nearPosition,
      batch: mockBatch,
    ));
    await tester.pump();
    await tester.pumpAndSettle();

    // Verify Check In button is enabled
    final btnFinder = find.byKey(const Key('check_in_now_btn'));
    expect(btnFinder, findsOneWidget);
    
    final FilledButton button = tester.widget<FilledButton>(btnFinder);
    expect(button.onPressed, isNotNull); // enabled
  });
}
