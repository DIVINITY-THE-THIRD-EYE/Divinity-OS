import 'package:intl/intl.dart';

enum EventStatus {
  draft,
  published,
  cancelled;

  static EventStatus fromString(String v) => switch (v.toUpperCase()) {
    'DRAFT' => EventStatus.draft,
    'CANCELLED' => EventStatus.cancelled,
    _ => EventStatus.published,
  };

  String get wire => switch (this) {
    EventStatus.draft => 'DRAFT',
    EventStatus.published => 'PUBLISHED',
    EventStatus.cancelled => 'CANCELLED',
  };

  String get label => switch (this) {
    EventStatus.draft => 'Draft',
    EventStatus.published => 'Published',
    EventStatus.cancelled => 'Cancelled',
  };
}

/// A workshop/seminar/camp. [registrationCount] and [isRegistered] are populated
/// depending on the query (admin list vs. student list).
class Event {
  const Event({
    required this.id,
    required this.title,
    this.description,
    this.location,
    required this.startsAt,
    this.capacity,
    required this.status,
    this.createdBy,
    this.registrationCount = 0,
    this.isRegistered = false,
    this.isFree = true,
    this.price,
    required this.createdAt,
  });

  final String id;
  final String title;
  final String? description;
  final String? location;
  final DateTime startsAt;
  final int? capacity;
  final EventStatus status;
  final String? createdBy;
  final int registrationCount;
  final bool isRegistered;
  final bool isFree;
  final double? price;
  final DateTime createdAt;

  bool get isFull => capacity != null && registrationCount >= capacity!;

  int? get seatsLeft => capacity == null
      ? null
      : (capacity! - registrationCount).clamp(0, capacity!);

  String get whenLabel {
    final d = DateFormat('EEE, d MMM yyyy · h:mm a').format(startsAt.toLocal());
    return d;
  }

  factory Event.fromMap(Map<String, dynamic> m, {String? currentStudentId}) {
    // Registration count may arrive as an aggregate list: [{count: n}].
    var count = 0;
    final regsAgg = m['event_registrations'];
    if (regsAgg is List && regsAgg.isNotEmpty) {
      final first = regsAgg.first;
      if (first is Map && first['count'] != null) {
        count = (first['count'] as num).toInt();
      } else {
        count = regsAgg.length;
      }
    }

    // Whether the current student is registered may arrive as a filtered list.
    var registered = false;
    final myRegs = m['my_registration'];
    if (myRegs is List) {
      registered = myRegs.isNotEmpty;
    } else if (m['is_registered'] is bool) {
      registered = m['is_registered'] as bool;
    }

    return Event(
      id: m['id'] as String,
      title: m['title'] as String,
      description: m['description'] as String?,
      location: m['location'] as String?,
      startsAt: DateTime.parse(m['starts_at'] as String),
      capacity: (m['capacity'] as num?)?.toInt(),
      status: EventStatus.fromString(m['status'] as String? ?? 'PUBLISHED'),
      createdBy: m['created_by'] as String?,
      registrationCount: count,
      isRegistered: registered,
      isFree: m['is_free'] as bool? ?? true,
      price: (m['price'] as num?)?.toDouble(),
      createdAt: DateTime.parse(m['created_at'] as String),
    );
  }

  Map<String, dynamic> toInsertMap() => {
    'title': title.trim(),
    if (description != null && description!.trim().isNotEmpty)
      'description': description!.trim(),
    if (location != null && location!.trim().isNotEmpty)
      'location': location!.trim(),
    'starts_at': startsAt.toUtc().toIso8601String(),
    if (capacity != null) 'capacity': capacity,
    'status': status.wire,
    'is_free': isFree,
    if (!isFree) 'price': price,
  };
}
