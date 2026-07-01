class TransformationScore {
  const TransformationScore({
    required this.id,
    required this.studentId,
    this.recordedBy,
    required this.consistency,
    required this.intensity,
    required this.mindfulness,
    required this.recovery,
    required this.score,
    required this.weekStartDate,
    this.createdAt,
  });

  final String id;
  final String studentId;
  final String? recordedBy;
  final double consistency;
  final double intensity;
  final double mindfulness;
  final double recovery;
  final double score;
  final DateTime weekStartDate;
  final DateTime? createdAt;

  TransformationScore copyWith({
    String? id,
    String? studentId,
    String? recordedBy,
    double? consistency,
    double? intensity,
    double? mindfulness,
    double? recovery,
    double? score,
    DateTime? weekStartDate,
    DateTime? createdAt,
  }) {
    return TransformationScore(
      id: id ?? this.id,
      studentId: studentId ?? this.studentId,
      recordedBy: recordedBy ?? this.recordedBy,
      consistency: consistency ?? this.consistency,
      intensity: intensity ?? this.intensity,
      mindfulness: mindfulness ?? this.mindfulness,
      recovery: recovery ?? this.recovery,
      score: score ?? this.score,
      weekStartDate: weekStartDate ?? this.weekStartDate,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  factory TransformationScore.fromMap(Map<String, dynamic> map) {
    return TransformationScore(
      id: map['id'] as String? ?? '',
      studentId: map['student_id'] as String? ?? '',
      recordedBy: map['recorded_by'] as String?,
      consistency: (map['consistency'] as num? ?? 0.0).toDouble(),
      intensity: (map['intensity'] as num? ?? 0.0).toDouble(),
      mindfulness: (map['mindfulness'] as num? ?? 0.0).toDouble(),
      recovery: (map['recovery'] as num? ?? 0.0).toDouble(),
      score: (map['score'] as num? ?? 0.0).toDouble(),
      weekStartDate: map['week_start_date'] != null
          ? DateTime.parse(map['week_start_date'] as String)
          : DateTime.now(),
      createdAt: map['created_at'] != null
          ? DateTime.parse(map['created_at'] as String)
          : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      if (id.isNotEmpty) 'id': id,
      'student_id': studentId,
      'recorded_by': recordedBy,
      'consistency': consistency,
      'intensity': intensity,
      'mindfulness': mindfulness,
      'recovery': recovery,
      'score': score,
      'week_start_date':
          '${weekStartDate.year.toString().padLeft(4, '0')}-${weekStartDate.month.toString().padLeft(2, '0')}-${weekStartDate.day.toString().padLeft(2, '0')}',
      if (createdAt != null) 'created_at': createdAt!.toIso8601String(),
    };
  }
}
