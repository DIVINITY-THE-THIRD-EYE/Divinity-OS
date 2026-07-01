import 'package:divinity_app/features/admissions/data/leads_repository.dart';
import 'package:divinity_app/features/admissions/domain/lead.dart';
import 'package:divinity_app/features/admissions/presentation/leads_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

// ── Mock ─────────────────────────────────────────────────────────────────────

class MockLeadsRepository extends Mock implements LeadsRepository {}

// ── Helpers ──────────────────────────────────────────────────────────────────

Lead _fakeLead({
  String id = 'l-1',
  String name = 'Priya Sharma',
  LeadStatus status = LeadStatus.newLead,
  String? convertedUserId,
}) => Lead(
  id: id,
  name: name,
  phone: '+919876543210',
  source: LeadSource.instagram,
  pipelineStatus: status,
  convertedUserId: convertedUserId,
  createdAt: DateTime(2026),
  updatedAt: DateTime(2026),
);

// ── Tests ─────────────────────────────────────────────────────────────────────

void main() {
  group('LeadStatus', () {
    test('fromString parses all values', () {
      expect(LeadStatus.fromString('NEW'), LeadStatus.newLead);
      expect(LeadStatus.fromString('CONSULTATION'), LeadStatus.consultation);
      expect(LeadStatus.fromString('ADMITTED'), LeadStatus.admitted);
      expect(LeadStatus.fromString('LOST'), LeadStatus.lost);
    });

    test('fromString defaults to newLead for unknown', () {
      expect(LeadStatus.fromString('UNKNOWN'), LeadStatus.newLead);
      expect(LeadStatus.fromString(''), LeadStatus.newLead);
    });

    test('dbValue round-trips correctly', () {
      for (final s in LeadStatus.values) {
        expect(LeadStatus.fromString(s.dbValue), s);
      }
    });

    test('nextStatus advances the pipeline', () {
      expect(LeadStatus.newLead.nextStatus, LeadStatus.consultation);
      expect(LeadStatus.consultation.nextStatus, LeadStatus.admitted);
      expect(LeadStatus.admitted.nextStatus, isNull);
      expect(LeadStatus.lost.nextStatus, isNull);
    });
  });

  group('LeadSource', () {
    test('fromString parses all values', () {
      expect(LeadSource.fromString('WALK_IN'), LeadSource.walkIn);
      expect(LeadSource.fromString('REFERRAL'), LeadSource.referral);
      expect(LeadSource.fromString('INSTAGRAM'), LeadSource.instagram);
      expect(LeadSource.fromString(null), LeadSource.other);
    });

    test('dbValue round-trips correctly', () {
      for (final s in LeadSource.values) {
        expect(LeadSource.fromString(s.dbValue), s);
      }
    });
  });

  group('Lead.fromMap', () {
    test('parses full map', () {
      final lead = Lead.fromMap({
        'id': 'l-42',
        'name': 'Raj Kumar',
        'phone': '+919000000001',
        'email': 'raj@example.com',
        'source': 'REFERRAL',
        'pipeline_status': 'CONSULTATION',
        'notes': 'Interested in yoga',
        'converted_user_id': null,
        'created_by': 'admin-1',
        'created_at': '2026-01-10T08:00:00.000Z',
        'updated_at': '2026-01-11T09:00:00.000Z',
      });

      expect(lead.id, 'l-42');
      expect(lead.name, 'Raj Kumar');
      expect(lead.source, LeadSource.referral);
      expect(lead.pipelineStatus, LeadStatus.consultation);
      expect(lead.notes, 'Interested in yoga');
      expect(lead.convertedUserId, isNull);
    });
  });

  group('LeadsNotifier', () {
    late MockLeadsRepository mockRepo;
    late ProviderContainer container;

    setUp(() {
      mockRepo = MockLeadsRepository();
      container = ProviderContainer(
        overrides: [leadsRepositoryProvider.overrideWithValue(mockRepo)],
      );
    });

    tearDown(() => container.dispose());

    test('loads leads on build', () async {
      final leads = [_fakeLead(), _fakeLead(id: 'l-2', name: 'Amit')];
      when(() => mockRepo.fetchLeads()).thenAnswer((_) async => leads);

      final state = await container.read(leadsProvider.future);
      expect(state.length, 2);
    });

    test('addLead prepends to list', () async {
      when(() => mockRepo.fetchLeads()).thenAnswer((_) async => []);
      await container.read(leadsProvider.future);

      final newLead = _fakeLead(id: 'l-new', name: 'Nisha');
      when(
        () => mockRepo.createLead(
          name: any(named: 'name'),
          phone: any(named: 'phone'),
          email: any(named: 'email'),
          source: any(named: 'source'),
          notes: any(named: 'notes'),
          createdBy: any(named: 'createdBy'),
        ),
      ).thenAnswer((_) async => newLead);

      await container
          .read(leadsProvider.notifier)
          .addLead(name: 'Nisha', createdBy: 'admin-1');

      final state = container.read(leadsProvider).value!;
      expect(state.length, 1);
      expect(state.first.name, 'Nisha');
    });

    test('advancePipeline updates lead in list', () async {
      final lead = _fakeLead();
      when(() => mockRepo.fetchLeads()).thenAnswer((_) async => [lead]);
      await container.read(leadsProvider.future);

      final advanced = _fakeLead(status: LeadStatus.consultation);
      when(
        () => mockRepo.advancePipeline('l-1', LeadStatus.consultation),
      ).thenAnswer((_) async => advanced);

      await container
          .read(leadsProvider.notifier)
          .advancePipeline('l-1', LeadStatus.consultation);

      final state = container.read(leadsProvider).value!;
      expect(state.first.pipelineStatus, LeadStatus.consultation);
    });

    test('convertToMember links user and sets ADMITTED', () async {
      final lead = _fakeLead(status: LeadStatus.consultation);
      when(() => mockRepo.fetchLeads()).thenAnswer((_) async => [lead]);
      await container.read(leadsProvider.future);

      final admitted = _fakeLead(
        status: LeadStatus.admitted,
        convertedUserId: 'user-99',
      );
      when(
        () => mockRepo.convertToMember('l-1', 'user-99'),
      ).thenAnswer((_) async => admitted);

      await container
          .read(leadsProvider.notifier)
          .convertToMember('l-1', 'user-99');

      final state = container.read(leadsProvider).value!;
      expect(state.first.pipelineStatus, LeadStatus.admitted);
      expect(state.first.convertedUserId, 'user-99');
    });

    test('markLost advances to lost status', () async {
      final lead = _fakeLead();
      when(() => mockRepo.fetchLeads()).thenAnswer((_) async => [lead]);
      await container.read(leadsProvider.future);

      final lost = _fakeLead(status: LeadStatus.lost);
      when(
        () => mockRepo.advancePipeline('l-1', LeadStatus.lost),
      ).thenAnswer((_) async => lost);

      await container.read(leadsProvider.notifier).markLost('l-1');

      final state = container.read(leadsProvider).value!;
      expect(state.first.pipelineStatus, LeadStatus.lost);
    });
  });
}
