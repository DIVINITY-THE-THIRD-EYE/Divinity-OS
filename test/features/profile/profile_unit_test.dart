import 'package:divinity_app/features/auth/presentation/auth_provider.dart'
    show currentUserIdProvider;
import 'package:divinity_app/features/profile/data/profile_repository.dart';
import 'package:divinity_app/features/profile/domain/user_profile.dart';
import 'package:divinity_app/features/profile/presentation/profile_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

// ── Mocks ─────────────────────────────────────────────────────────────────────

class MockProfileRepository extends Mock implements ProfileRepository {}

// ── Helpers ───────────────────────────────────────────────────────────────────

UserProfile _fakeProfile({
  String id = 'user-1',
  String name = 'Priya Kapoor',
  String planStatus = 'ACTIVE',
  String role = 'STUDENT',
  int currentStreak = 5,
  int maxStreak = 14,
}) =>
    UserProfile(
      id: id,
      name: name,
      phone: '+919876543210',
      role: role,
      planStatus: planStatus,
      currentStreak: currentStreak,
      maxStreak: maxStreak,
      createdAt: DateTime(2026, 1, 15),
    );

// ── Tests ─────────────────────────────────────────────────────────────────────

void main() {
  // ── UserProfile.fromMap ───────────────────────────────────────────────────

  group('UserProfile.fromMap', () {
    test('parses required fields', () {
      final profile = UserProfile.fromMap({
        'id': 'u-1',
        'name': 'Arjun Sharma',
        'phone': '+919123456789',
        'role': 'STUDENT',
        'plan_status': 'ACTIVE',
        'current_streak': 3,
        'max_streak': 10,
        'created_at': '2026-01-01T00:00:00.000Z',
      });
      expect(profile.id, 'u-1');
      expect(profile.name, 'Arjun Sharma');
      expect(profile.planStatus, 'ACTIVE');
    });

    test('handles null optional fields gracefully', () {
      final profile = UserProfile.fromMap({
        'id': 'u-2',
        'role': 'STUDENT',
        'plan_status': 'UNPAID',
        'created_at': '2026-01-01T00:00:00.000Z',
      });
      expect(profile.name, 'Unknown');
      expect(profile.age, isNull);
      expect(profile.primaryGoal, isNull);
      expect(profile.expirationDate, isNull);
    });

    test('parses expiration_date', () {
      final profile = UserProfile.fromMap({
        'id': 'u-3',
        'role': 'STUDENT',
        'plan_status': 'ACTIVE',
        'expiration_date': '2027-06-30',
        'created_at': '2026-01-01T00:00:00.000Z',
      });
      expect(profile.expirationDate, DateTime(2027, 6, 30));
    });
  });

  // ── UserProfile computed labels ───────────────────────────────────────────

  group('UserProfile.roleLabel', () {
    test('maps all roles', () {
      expect(_fakeProfile().roleLabel, 'Student');
      expect(_fakeProfile(role: 'TRAINER').roleLabel, 'Trainer');
      expect(_fakeProfile(role: 'ADMIN').roleLabel, 'Admin');
    });
  });

  group('UserProfile.planStatusLabel', () {
    for (final entry in {
      'ACTIVE': 'Active',
      'PAUSED': 'Paused',
      'EXPIRED': 'Expired',
      'UNPAID': 'Unpaid',
      'PENDING_ADMIN': 'Pending Approval',
    }.entries) {
      test('${entry.key} → ${entry.value}', () {
        expect(
          _fakeProfile(planStatus: entry.key).planStatusLabel,
          entry.value,
        );
      });
    }
  });

  group('UserProfile.goalLabel', () {
    test('maps known goals', () {
      final p = UserProfile.fromMap({
        'id': 'u-1',
        'role': 'STUDENT',
        'plan_status': 'ACTIVE',
        'primary_goal': 'WEIGHT_LOSS',
        'created_at': '2026-01-01T00:00:00.000Z',
      });
      expect(p.goalLabel, 'Weight Loss');
    });

    test('returns Not set for null goal', () {
      expect(_fakeProfile().goalLabel, 'Not set');
    });
  });

  group('UserProfile.initials', () {
    test('two-word name gives two initials', () {
      expect(_fakeProfile().initials, 'PK');
    });

    test('single name gives one initial', () {
      expect(_fakeProfile(name: 'Divinity').initials, 'D');
    });

    test('empty name returns ?', () {
      expect(_fakeProfile(name: '').initials, '?');
    });

    test('initials are uppercase', () {
      expect(_fakeProfile(name: 'rahul verma').initials, 'RV');
    });
  });

  group('UserProfile.copyWith', () {
    test('replaces name only', () {
      final original = _fakeProfile(name: 'Priya');
      final updated = original.copyWith(name: 'Priya Kapoor');
      expect(updated.name, 'Priya Kapoor');
      expect(updated.id, original.id);
      expect(updated.planStatus, original.planStatus);
    });
  });

  // ── MyProfileNotifier ─────────────────────────────────────────────────────

  group('MyProfileNotifier', () {
    late MockProfileRepository mockRepo;
    late ProviderContainer container;

    setUp(() {
      mockRepo = MockProfileRepository();
      container = ProviderContainer(
        overrides: [
          currentUserIdProvider.overrideWithValue('user-1'),
          profileRepositoryProvider.overrideWithValue(mockRepo),
        ],
      );
    });

    tearDown(() => container.dispose());

    test('loads profile on build', () async {
      when(() => mockRepo.fetchProfile('user-1'))
          .thenAnswer((_) async => _fakeProfile());

      final profile = await container.read(myProfileProvider.future);
      expect(profile.name, 'Priya Kapoor');
    });

    test('updateName calls repository and reloads', () async {
      when(() => mockRepo.fetchProfile('user-1'))
          .thenAnswer((_) async => _fakeProfile());
      await container.read(myProfileProvider.future);

      when(() => mockRepo.updateName('user-1', 'Priya Sharma'))
          .thenAnswer((_) async {});
      when(() => mockRepo.fetchProfile('user-1'))
          .thenAnswer((_) async => _fakeProfile(name: 'Priya Sharma'));

      await container.read(myProfileProvider.notifier).updateName('Priya Sharma');

      final updated = container.read(myProfileProvider).value!;
      expect(updated.name, 'Priya Sharma');
      verify(() => mockRepo.updateName('user-1', 'Priya Sharma')).called(1);
    });

    test('updateEmergencyContact calls repository and reloads', () async {
      when(() => mockRepo.fetchProfile('user-1'))
          .thenAnswer((_) async => _fakeProfile());
      await container.read(myProfileProvider.future);

      when(() => mockRepo.updateEmergencyContact(
            'user-1',
            name: 'Ravi Kapoor',
            phone: '+919999999999',
          )).thenAnswer((_) async {});
      when(() => mockRepo.fetchProfile('user-1'))
          .thenAnswer((_) async => _fakeProfile());

      await container.read(myProfileProvider.notifier).updateEmergencyContact(
            name: 'Ravi Kapoor',
            phone: '+919999999999',
          );

      verify(() => mockRepo.updateEmergencyContact(
            'user-1',
            name: 'Ravi Kapoor',
            phone: '+919999999999',
          )).called(1);
    });

    test('propagates error on failed fetch', () async {
      when(() => mockRepo.fetchProfile(any()))
          .thenThrow(Exception('DB error'));

      await expectLater(
        container.read(myProfileProvider.future),
        throwsA(isA<Exception>()),
      );
    });
  });
}
