import 'package:divinity_app/features/batches/data/batch_repository.dart';
import 'package:divinity_app/features/batches/domain/batch.dart';
import 'package:divinity_app/features/batches/presentation/batch_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

// ── Mock ─────────────────────────────────────────────────────────────────────

class MockBatchRepository extends Mock implements BatchRepository {}

// ── Helpers ──────────────────────────────────────────────────────────────────

Batch _fakeBatch({
  String id = 'b-1',
  String name = 'Morning Yoga',
  BatchStatus status = BatchStatus.active,
}) =>
    Batch(
      id: id,
      name: name,
      scheduleTime: '06:00',
      daysOfWeek: const ['MON', 'WED', 'FRI'],
      capacity: 20,
      status: status,
      createdAt: DateTime(2026),
    );

// ── Tests ─────────────────────────────────────────────────────────────────────

void main() {
  setUpAll(() {
    registerFallbackValue(_fakeBatch());
  });

  group('BatchStatus.fromString', () {
    test('parses known values', () {
      expect(BatchStatus.fromString('ACTIVE'), BatchStatus.active);
      expect(BatchStatus.fromString('PAUSED'), BatchStatus.paused);
      expect(BatchStatus.fromString('CANCELLED'), BatchStatus.cancelled);
    });

    test('defaults to active for unknown', () {
      expect(BatchStatus.fromString('DELETED'), BatchStatus.active);
      expect(BatchStatus.fromString(''), BatchStatus.active);
    });
  });

  group('Batch.fromMap', () {
    test('parses correctly', () {
      final batch = Batch.fromMap({
        'id': 'b-99',
        'name': 'Evening Stretch',
        'trainer_id': 'trainer-1',
        'schedule_time': '18:30',
        'days_of_week': ['TUE', 'THU'],
        'capacity': 15,
        'status': 'PAUSED',
        'location_lat': 12.9716,
        'location_lng': 77.5946,
        'created_at': '2026-01-15T10:00:00.000Z',
      });

      expect(batch.id, 'b-99');
      expect(batch.name, 'Evening Stretch');
      expect(batch.trainerId, 'trainer-1');
      expect(batch.scheduleTime, '18:30');
      expect(batch.daysOfWeek, ['TUE', 'THU']);
      expect(batch.capacity, 15);
      expect(batch.status, BatchStatus.paused);
      expect(batch.locationLat, 12.9716);
    });

    test('handles null optional fields', () {
      final batch = Batch.fromMap({
        'id': 'b-1',
        'name': 'Yoga',
        'schedule_time': '07:00',
        'days_of_week': [],
        'capacity': 20,
        'status': 'ACTIVE',
        'created_at': '2026-01-01T00:00:00.000Z',
      });

      expect(batch.trainerId, isNull);
      expect(batch.locationLat, isNull);
      expect(batch.daysOfWeek, isEmpty);
    });

    test('parses radius_meters when present', () {
      final batch = Batch.fromMap({
        'id': 'b-1',
        'name': 'Yoga',
        'schedule_time': '07:00',
        'days_of_week': [],
        'capacity': 20,
        'status': 'ACTIVE',
        'location_lat': 12.9716,
        'location_lng': 77.5946,
        'radius_meters': 50,
        'created_at': '2026-01-01T00:00:00.000Z',
      });

      expect(batch.radiusMeters, 50.0);
    });

    test('defaults radiusMeters to 100 when absent', () {
      final batch = Batch.fromMap({
        'id': 'b-1',
        'name': 'Yoga',
        'schedule_time': '07:00',
        'days_of_week': [],
        'capacity': 20,
        'status': 'ACTIVE',
        'created_at': '2026-01-01T00:00:00.000Z',
      });

      expect(batch.radiusMeters, 100.0);
    });

    test('toInsertMap includes radius_meters', () {
      final batch = Batch(
        id: '',
        name: 'Yoga',
        scheduleTime: '07:00',
        daysOfWeek: const ['MON'],
        capacity: 20,
        status: BatchStatus.active,
        locationLat: 12.9716,
        locationLng: 77.5946,
        radiusMeters: 75.0,
        createdAt: DateTime(2026),
      );

      final map = batch.toInsertMap();
      expect(map['radius_meters'], 75.0);
      expect(map['location_lat'], 12.9716);
      expect(map['location_lng'], 77.5946);
    });
  });

  group('BatchNotifier', () {
    late MockBatchRepository mockRepo;
    late ProviderContainer container;

    setUp(() {
      mockRepo = MockBatchRepository();
      container = ProviderContainer(
        overrides: [
          batchRepositoryProvider.overrideWithValue(mockRepo),
        ],
      );
    });

    tearDown(() => container.dispose());

    test('loads batches on build', () async {
      final batches = [_fakeBatch(), _fakeBatch(id: 'b-2', name: 'Pilates')];
      when(() => mockRepo.fetchBatches()).thenAnswer((_) async => batches);

      final state = await container.read(batchesProvider.future);
      expect(state.length, 2);
      expect(state.first.name, 'Morning Yoga');
    });

    test('createBatch appends to list', () async {
      final initial = [_fakeBatch()];
      when(() => mockRepo.fetchBatches()).thenAnswer((_) async => initial);
      await container.read(batchesProvider.future);

      final newBatch = _fakeBatch(id: 'b-3', name: 'Power Yoga');
      when(() => mockRepo.createBatch(any()))
          .thenAnswer((_) async => newBatch);

      await container
          .read(batchesProvider.notifier)
          .createBatch(newBatch);

      final updated = container.read(batchesProvider).value!;
      expect(updated.length, 2);
      expect(updated.last.name, 'Power Yoga');
    });

    test('updateBatch replaces the updated item', () async {
      final batches = [_fakeBatch(), _fakeBatch(id: 'b-2', name: 'Pilates')];
      when(() => mockRepo.fetchBatches()).thenAnswer((_) async => batches);
      await container.read(batchesProvider.future);

      final paused = _fakeBatch(status: BatchStatus.paused);
      when(() => mockRepo.updateBatch('b-1', any()))
          .thenAnswer((_) async => paused);

      await container
          .read(batchesProvider.notifier)
          .updateBatch('b-1', {'status': 'PAUSED'});

      final updated = container.read(batchesProvider).value!;
      expect(updated.first.status, BatchStatus.paused);
      expect(updated[1].name, 'Pilates');
    });
  });
}
