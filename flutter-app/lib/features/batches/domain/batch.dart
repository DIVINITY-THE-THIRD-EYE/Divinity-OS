enum BatchStatus {
  active,
  paused,
  cancelled;

  static BatchStatus fromString(String v) => switch (v.toUpperCase()) {
    'PAUSED' => BatchStatus.paused,
    'CANCELLED' => BatchStatus.cancelled,
    _ => BatchStatus.active,
  };

  String get label => switch (this) {
    BatchStatus.active => 'Active',
    BatchStatus.paused => 'Paused',
    BatchStatus.cancelled => 'Cancelled',
  };
}

class Batch {
  const Batch({
    required this.id,
    required this.name,
    required this.scheduleTime,
    required this.daysOfWeek,
    required this.capacity,
    required this.status,
    this.trainerId,
    this.locationLat,
    this.locationLng,
    this.radiusMeters = 100.0,
    required this.createdAt,
  });

  final String id;
  final String name;
  final String? trainerId;
  final String scheduleTime;
  final List<String> daysOfWeek;
  final int capacity;
  final BatchStatus status;
  final double? locationLat;
  final double? locationLng;
  final double radiusMeters;
  final DateTime createdAt;

  factory Batch.fromMap(Map<String, dynamic> m) {
    final days = (m['days_of_week'] as List<dynamic>? ?? [])
        .map((e) => e as String)
        .toList();
    return Batch(
      id: m['id'] as String,
      name: m['name'] as String,
      trainerId: m['trainer_id'] as String?,
      scheduleTime: m['schedule_time'] as String,
      daysOfWeek: days,
      capacity: (m['capacity'] as num).toInt(),
      status: BatchStatus.fromString(m['status'] as String? ?? 'ACTIVE'),
      locationLat: (m['location_lat'] as num?)?.toDouble(),
      locationLng: (m['location_lng'] as num?)?.toDouble(),
      radiusMeters: (m['radius_meters'] as num?)?.toDouble() ?? 100.0,
      createdAt: DateTime.parse(m['created_at'] as String),
    );
  }

  Map<String, dynamic> toInsertMap() => {
    'name': name,
    'trainer_id': trainerId,
    'schedule_time': scheduleTime,
    'days_of_week': daysOfWeek,
    'capacity': capacity,
    'status': status.name.toUpperCase(),
    if (locationLat != null) 'location_lat': locationLat,
    if (locationLng != null) 'location_lng': locationLng,
    'radius_meters': radiusMeters,
  };
}
