import 'package:divinity_app/features/certificates/domain/certificate.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Certificate.fromMap', () {
    test('parses all fields', () {
      final c = Certificate.fromMap({
        'id': 'cert-1',
        'student_id': 'stu-1',
        'issued_by': 'trn-1',
        'code': 'DIV-7K2A-9QF3',
        'title': 'Certificate of Completion',
        'programme': '200-Hour Foundation',
        'issued_on': '2026-06-12',
        'notes': 'With distinction',
        'created_at': '2026-06-12T10:00:00Z',
      });

      expect(c.id, 'cert-1');
      expect(c.studentId, 'stu-1');
      expect(c.issuedBy, 'trn-1');
      expect(c.code, 'DIV-7K2A-9QF3');
      expect(c.programme, '200-Hour Foundation');
      expect(c.notes, 'With distinction');
      expect(c.issuedOn, DateTime(2026, 6, 12));
    });

    test('applies sensible defaults for missing fields', () {
      final c = Certificate.fromMap({
        'student_id': 'stu-2',
        'code': 'DIV-AAAA-BBBB',
        'programme': 'Pranayama Intensive',
      });

      expect(c.id, '');
      expect(c.title, 'Certificate of Completion');
      expect(c.issuedBy, isNull);
      expect(c.notes, isNull);
    });
  });

  group('Certificate.issuedOnLabel', () {
    test('formats as "D Month YYYY"', () {
      final c = Certificate.fromMap({
        'student_id': 'stu-1',
        'code': 'DIV-7K2A-9QF3',
        'programme': 'X',
        'issued_on': '2026-06-12',
      });
      expect(c.issuedOnLabel, '12 June 2026');
    });
  });

  group('Certificate.toMap', () {
    test('serializes for insert and omits empty id', () {
      final c = Certificate(
        id: '',
        studentId: 'stu-1',
        issuedBy: 'trn-1',
        code: '',
        title: 'Certificate of Completion',
        programme: '200-Hour Foundation',
        issuedOn: DateTime(2026, 6, 12),
      );
      final map = c.toMap();

      expect(map.containsKey('id'), isFalse, reason: 'empty id is omitted');
      expect(map['student_id'], 'stu-1');
      expect(map['issued_by'], 'trn-1');
      expect(map['programme'], '200-Hour Foundation');
      expect(map['issued_on'], '2026-06-12');
      // code left empty so the DB default (gen_certificate_code) applies
      expect(map.containsKey('code'), isFalse);
    });
  });
}
