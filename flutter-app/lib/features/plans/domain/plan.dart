class Plan {
  const Plan({
    required this.id,
    required this.name,
    required this.price,
    required this.durationDays,
    this.discountPercent = 0,
    this.couponCode,
    this.programs = const [],
    this.maxLeaveDaysPerMonth = 4,
    this.isActive = true,
    required this.createdAt,
    required this.updatedAt,
  });

  final String id;
  final String name;
  final double price;
  final int durationDays;
  final double discountPercent;
  final String? couponCode;
  final List<String> programs;
  final int maxLeaveDaysPerMonth;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;

  double get discountedPrice => price - (price * discountPercent / 100);

  factory Plan.fromMap(Map<String, dynamic> m) => Plan(
    id: m['id'] as String,
    name: m['name'] as String,
    price: (m['price'] as num).toDouble(),
    durationDays: m['duration_days'] as int,
    discountPercent: (m['discount_percent'] as num?)?.toDouble() ?? 0,
    couponCode: m['coupon_code'] as String?,
    programs: (m['programs'] as List<dynamic>?)?.cast<String>() ?? const [],
    maxLeaveDaysPerMonth: m['max_leave_days_per_month'] as int? ?? 4,
    isActive: m['is_active'] as bool? ?? true,
    createdAt: DateTime.parse(m['created_at'] as String),
    updatedAt: DateTime.parse(m['updated_at'] as String),
  );
}
