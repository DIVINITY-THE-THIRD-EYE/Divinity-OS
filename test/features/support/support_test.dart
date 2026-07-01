import 'package:divinity_app/features/auth/presentation/auth_provider.dart';
import 'package:divinity_app/features/support/data/support_repository.dart';
import 'package:divinity_app/features/support/domain/support_ticket.dart';
import 'package:divinity_app/features/support/presentation/support_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockSupportRepository extends Mock implements SupportRepository {}

SupportTicket _fakeTicket({
  String id = 'tkt-1',
  String studentId = 'student-1',
  String? studentName,
  String subject = 'Login issue',
  String description = 'Cannot login via OTP',
  SupportTicketStatus status = SupportTicketStatus.open,
}) =>
    SupportTicket(
      id: id,
      studentId: studentId,
      studentName: studentName,
      subject: subject,
      description: description,
      status: status,
      createdAt: DateTime(2026, 6, 20),
    );

void main() {
  setUpAll(() {
    registerFallbackValue(SupportTicketStatus.open);
  });

  group('SupportTicketStatus enum', () {
    test('fromString parses correctly', () {
      expect(SupportTicketStatus.fromString('OPEN'), SupportTicketStatus.open);
      expect(SupportTicketStatus.fromString('RESOLVED'), SupportTicketStatus.resolved);
      expect(SupportTicketStatus.fromString('UNKNOWN'), SupportTicketStatus.open);
    });

    test('dbValue matches expectations', () {
      expect(SupportTicketStatus.open.dbValue, 'OPEN');
      expect(SupportTicketStatus.resolved.dbValue, 'RESOLVED');
    });
  });

  group('SupportTicket Model', () {
    test('fromMap parses correctly with flat fields', () {
      final t = SupportTicket.fromMap({
        'id': 'tkt-1',
        'student_id': 'stud-1',
        'subject': 'Help',
        'description': 'Description',
        'status': 'OPEN',
        'created_at': '2026-06-20T10:00:00Z',
      });
      expect(t.id, 'tkt-1');
      expect(t.studentId, 'stud-1');
      expect(t.subject, 'Help');
      expect(t.status, SupportTicketStatus.open);
    });

    test('fromMap parses joins correctly', () {
      final t = SupportTicket.fromMap({
        'id': 'tkt-1',
        'student_id': 'stud-1',
        'student': {'name': 'Arjun'},
        'subject': 'Help',
        'description': 'Description',
        'status': 'RESOLVED',
        'created_at': '2026-06-20T10:00:00Z',
      });
      expect(t.studentName, 'Arjun');
      expect(t.status, SupportTicketStatus.resolved);
    });
  });

  group('MyTicketsNotifier', () {
    late MockSupportRepository mockRepo;
    late ProviderContainer container;

    setUp(() {
      mockRepo = MockSupportRepository();
      container = ProviderContainer(
        overrides: [
          supportRepositoryProvider.overrideWithValue(mockRepo),
          currentUserIdProvider.overrideWithValue('student-1'),
        ],
      );
    });

    tearDown(() => container.dispose());

    test('loads my tickets on build', () async {
      final list = [_fakeTicket()];
      when(() => mockRepo.fetchMyTickets('student-1'))
          .thenAnswer((_) async => list);

      await container.read(myTicketsProvider.future);
      final state = container.read(myTicketsProvider).value!;
      expect(state.length, 1);
      expect(state.first.id, 'tkt-1');
    });

    test('createTicket adds ticket to state', () async {
      final list = [_fakeTicket()];
      when(() => mockRepo.fetchMyTickets('student-1'))
          .thenAnswer((_) async => list);

      await container.read(myTicketsProvider.future);

      final created = _fakeTicket(id: 'tkt-2', subject: 'New Help', description: 'Desc');
      when(() => mockRepo.createTicket(
            studentId: 'student-1',
            subject: 'New Help',
            description: 'Desc',
          )).thenAnswer((_) async => created);

      await container.read(myTicketsProvider.notifier).createTicket(
            subject: 'New Help',
            description: 'Desc',
          );

      final state = container.read(myTicketsProvider).value!;
      expect(state.length, 2);
      expect(state.first.id, 'tkt-2');
    });
  });

  group('AllTicketsNotifier', () {
    late MockSupportRepository mockRepo;
    late ProviderContainer container;

    setUp(() {
      mockRepo = MockSupportRepository();
      container = ProviderContainer(
        overrides: [
          supportRepositoryProvider.overrideWithValue(mockRepo),
        ],
      );
    });

    tearDown(() => container.dispose());

    test('loads all tickets on build', () async {
      final list = [_fakeTicket()];
      when(() => mockRepo.fetchAllTickets()).thenAnswer((_) async => list);

      await container.read(allTicketsProvider.future);
      final state = container.read(allTicketsProvider).value!;
      expect(state.length, 1);
    });

    test('resolveTicket updates ticket status in state', () async {
      final list = [_fakeTicket()];
      when(() => mockRepo.fetchAllTickets()).thenAnswer((_) async => list);
      await container.read(allTicketsProvider.future);

      final resolved = _fakeTicket(status: SupportTicketStatus.resolved);
      when(() => mockRepo.updateTicketStatus('tkt-1', SupportTicketStatus.resolved))
          .thenAnswer((_) async => resolved);

      await container.read(allTicketsProvider.notifier).resolveTicket('tkt-1');

      final state = container.read(allTicketsProvider).value!;
      expect(state.first.status, SupportTicketStatus.resolved);
    });

    test('refresh reloads ticket list', () async {
      when(() => mockRepo.fetchAllTickets()).thenAnswer((_) async => [_fakeTicket()]);
      await container.read(allTicketsProvider.future);
      expect(container.read(allTicketsProvider).value!.length, 1);

      when(() => mockRepo.fetchAllTickets()).thenAnswer((_) async => [
            _fakeTicket(),
            _fakeTicket(id: 'tkt-2'),
          ]);
      await container.read(allTicketsProvider.notifier).refresh();
      expect(container.read(allTicketsProvider).value!.length, 2);
    });
  });
}
