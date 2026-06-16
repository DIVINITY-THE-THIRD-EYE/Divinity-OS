enum LeadStatus {
  newLead,
  consultation,
  admitted,
  lost;

  static LeadStatus fromString(String v) => switch (v.toUpperCase()) {
        'CONSULTATION' => LeadStatus.consultation,
        'ADMITTED' => LeadStatus.admitted,
        'LOST' => LeadStatus.lost,
        _ => LeadStatus.newLead,
      };

  String get dbValue => switch (this) {
        LeadStatus.newLead => 'NEW',
        LeadStatus.consultation => 'CONSULTATION',
        LeadStatus.admitted => 'ADMITTED',
        LeadStatus.lost => 'LOST',
      };

  String get label => switch (this) {
        LeadStatus.newLead => 'New',
        LeadStatus.consultation => 'Consultation',
        LeadStatus.admitted => 'Admitted',
        LeadStatus.lost => 'Lost',
      };

  LeadStatus? get nextStatus => switch (this) {
        LeadStatus.newLead => LeadStatus.consultation,
        LeadStatus.consultation => LeadStatus.admitted,
        _ => null,
      };
}

enum LeadSource {
  walkIn,
  referral,
  instagram,
  facebook,
  google,
  other;

  static LeadSource fromString(String? v) => switch (v?.toUpperCase()) {
        'WALK_IN' => LeadSource.walkIn,
        'REFERRAL' => LeadSource.referral,
        'INSTAGRAM' => LeadSource.instagram,
        'FACEBOOK' => LeadSource.facebook,
        'GOOGLE' => LeadSource.google,
        _ => LeadSource.other,
      };

  String get dbValue => switch (this) {
        LeadSource.walkIn => 'WALK_IN',
        LeadSource.referral => 'REFERRAL',
        LeadSource.instagram => 'INSTAGRAM',
        LeadSource.facebook => 'FACEBOOK',
        LeadSource.google => 'GOOGLE',
        LeadSource.other => 'OTHER',
      };

  String get label => switch (this) {
        LeadSource.walkIn => 'Walk-in',
        LeadSource.referral => 'Referral',
        LeadSource.instagram => 'Instagram',
        LeadSource.facebook => 'Facebook',
        LeadSource.google => 'Google',
        LeadSource.other => 'Other',
      };
}

class Lead {
  const Lead({
    required this.id,
    required this.name,
    this.phone,
    this.email,
    this.source,
    required this.pipelineStatus,
    this.notes,
    this.convertedUserId,
    this.createdBy,
    required this.createdAt,
    required this.updatedAt,
  });

  final String id;
  final String name;
  final String? phone;
  final String? email;
  final LeadSource? source;
  final LeadStatus pipelineStatus;
  final String? notes;
  final String? convertedUserId;
  final String? createdBy;
  final DateTime createdAt;
  final DateTime updatedAt;

  factory Lead.fromMap(Map<String, dynamic> m) => Lead(
        id: m['id'] as String,
        name: m['name'] as String,
        phone: m['phone'] as String?,
        email: m['email'] as String?,
        source: LeadSource.fromString(m['source'] as String?),
        pipelineStatus:
            LeadStatus.fromString(m['pipeline_status'] as String? ?? 'NEW'),
        notes: m['notes'] as String?,
        convertedUserId: m['converted_user_id'] as String?,
        createdBy: m['created_by'] as String?,
        createdAt: DateTime.parse(m['created_at'] as String),
        updatedAt: DateTime.parse(m['updated_at'] as String),
      );
}
