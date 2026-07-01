/// A completion certificate issued to a student. The [code] is the public,
/// human-shareable verification code (format `DIV-XXXX-XXXX`) backed by the
/// `certificates` table (migration 024).
class Certificate {
  const Certificate({
    required this.id,
    required this.studentId,
    this.issuedBy,
    required this.code,
    required this.title,
    required this.programme,
    required this.issuedOn,
    this.notes,
    this.createdAt,
  });

  final String id;
  final String studentId;
  final String? issuedBy;
  final String code;
  final String title;
  final String programme;
  final DateTime issuedOn;
  final String? notes;
  final DateTime? createdAt;

  /// e.g. "12 June 2026"
  String get issuedOnLabel {
    const months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];
    return '${issuedOn.day} ${months[issuedOn.month - 1]} ${issuedOn.year}';
  }

  factory Certificate.fromMap(Map<String, dynamic> map) {
    return Certificate(
      id: map['id'] as String? ?? '',
      studentId: map['student_id'] as String? ?? '',
      issuedBy: map['issued_by'] as String?,
      code: map['code'] as String? ?? '',
      title: map['title'] as String? ?? 'Certificate of Completion',
      programme: map['programme'] as String? ?? '',
      issuedOn: map['issued_on'] != null
          ? DateTime.parse(map['issued_on'] as String)
          : DateTime.now(),
      notes: map['notes'] as String?,
      createdAt: map['created_at'] != null
          ? DateTime.parse(map['created_at'] as String)
          : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      if (id.isNotEmpty) 'id': id,
      'student_id': studentId,
      if (issuedBy != null) 'issued_by': issuedBy,
      // `code` is left to the DB default (gen_certificate_code) on insert.
      if (code.isNotEmpty) 'code': code,
      'title': title,
      'programme': programme,
      'issued_on':
          '${issuedOn.year.toString().padLeft(4, '0')}-${issuedOn.month.toString().padLeft(2, '0')}-${issuedOn.day.toString().padLeft(2, '0')}',
      if (notes != null) 'notes': notes,
    };
  }
}
