class UserProfile {
  const UserProfile({
    required this.id,
    required this.name,
    required this.phone,
    required this.role,
    required this.planStatus,
    this.age,
    this.gender,
    this.primaryGoal,
    this.lifestyleActivity,
    this.emergencyContactName,
    this.emergencyContactPhone,
    this.injuries,
    this.medicalConditions,
    this.currentStreak = 0,
    this.maxStreak = 0,
    this.expirationDate,
    this.pauseStartDate,
    this.avatarUrl,
    required this.createdAt,
  });

  final String id;
  final String name;
  final String? phone;
  final String role;
  final String planStatus;
  final int? age;
  final String? gender;
  final String? primaryGoal;
  final String? lifestyleActivity;
  final String? emergencyContactName;
  final String? emergencyContactPhone;
  final String? injuries;
  final String? medicalConditions;
  final int currentStreak;
  final int maxStreak;
  final DateTime? expirationDate;
  final DateTime? pauseStartDate;
  final String? avatarUrl;
  final DateTime createdAt;

  factory UserProfile.fromMap(Map<String, dynamic> m) => UserProfile(
        id: m['id'] as String,
        name: m['name'] as String? ?? 'Unknown',
        phone: m['phone'] as String?,
        role: m['role'] as String? ?? 'STUDENT',
        planStatus: m['plan_status'] as String? ?? 'UNPAID',
        age: m['age'] as int?,
        gender: m['gender'] as String?,
        primaryGoal: m['primary_goal'] as String?,
        lifestyleActivity: m['lifestyle_activity'] as String?,
        emergencyContactName: m['emergency_contact_name'] as String?,
        emergencyContactPhone: m['emergency_contact_phone'] as String?,
        injuries: m['injuries'] as String?,
        medicalConditions: m['medical_conditions'] as String?,
        currentStreak: m['current_streak'] as int? ?? 0,
        maxStreak: m['max_streak'] as int? ?? 0,
        expirationDate: m['expiration_date'] == null
            ? null
            : DateTime.parse(m['expiration_date'] as String),
        pauseStartDate: m['pause_start_date'] == null
            ? null
            : DateTime.parse(m['pause_start_date'] as String),
        avatarUrl: m['avatar_url'] as String?,
        createdAt: DateTime.parse(m['created_at'] as String),
      );

  UserProfile copyWith({
    String? name,
    String? planStatus,
    DateTime? expirationDate,
    DateTime? pauseStartDate,
  }) => UserProfile(
        id: id,
        name: name ?? this.name,
        phone: phone,
        role: role,
        planStatus: planStatus ?? this.planStatus,
        age: age,
        gender: gender,
        primaryGoal: primaryGoal,
        lifestyleActivity: lifestyleActivity,
        emergencyContactName: emergencyContactName,
        emergencyContactPhone: emergencyContactPhone,
        injuries: injuries,
        medicalConditions: medicalConditions,
        currentStreak: currentStreak,
        maxStreak: maxStreak,
        expirationDate: expirationDate ?? this.expirationDate,
        pauseStartDate: pauseStartDate ?? this.pauseStartDate,
        avatarUrl: avatarUrl,
        createdAt: createdAt,
      );

  String get roleLabel => switch (role.toUpperCase()) {
        'ADMIN' => 'Admin',
        'TRAINER' => 'Trainer',
        _ => 'Student',
      };

  String get planStatusLabel => switch (planStatus.toUpperCase()) {
        'ACTIVE' => 'Active',
        'PAUSED' => 'Paused',
        'EXPIRED' => 'Expired',
        'PENDING_ADMIN' => 'Pending Approval',
        'PENDING_TRAINER' => 'Pending Trainer',
        _ => 'Unpaid',
      };

  String get goalLabel => switch (primaryGoal?.toUpperCase()) {
        'WEIGHT_LOSS' => 'Weight Loss',
        'STRENGTH' => 'Strength',
        'WELLNESS' => 'Wellness',
        'THERAPEUTIC_RECOVERY' => 'Therapeutic Recovery',
        'LIFE_TRANSFORMATION' => 'Life Transformation',
        _ => 'Not set',
      };

  String get lifestyleLabel => switch (lifestyleActivity?.toUpperCase()) {
        'SEDENTARY' => 'Sedentary',
        'LIGHTLY_ACTIVE' => 'Lightly Active',
        'MODERATELY_ACTIVE' => 'Moderately Active',
        'VERY_ACTIVE' => 'Very Active',
        _ => 'Not set',
      };

  String get genderLabel => switch (gender?.toUpperCase()) {
        'MALE' => 'Male',
        'FEMALE' => 'Female',
        'OTHER' => 'Other',
        _ => 'Prefer not to say',
      };

  String get initials {
    final parts = name.trim().split(' ');
    if (parts.length >= 2) {
      return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
    }
    return name.trim().isEmpty ? '?' : name.trim()[0].toUpperCase();
  }
}
