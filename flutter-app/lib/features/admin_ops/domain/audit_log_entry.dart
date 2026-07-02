class AuditLogEntry {
  const AuditLogEntry({
    required this.id,
    this.actorName,
    required this.action,
    required this.targetTable,
    this.targetId,
    this.details,
    required this.createdAt,
  });

  final String id;
  final String? actorName;
  final String action;
  final String targetTable;
  final String? targetId;
  final Map<String, dynamic>? details;
  final DateTime createdAt;

  factory AuditLogEntry.fromMap(Map<String, dynamic> m) {
    final actor = m['users'] as Map<String, dynamic>?;
    return AuditLogEntry(
      id: m['id'] as String,
      actorName: actor?['name'] as String?,
      action: m['action'] as String,
      targetTable: m['target_table'] as String,
      targetId: m['target_id'] as String?,
      details: m['details'] as Map<String, dynamic>?,
      createdAt: DateTime.parse(m['created_at'] as String),
    );
  }

  String get actionLabel => action.replaceAll('_', ' ').toLowerCase();
}
