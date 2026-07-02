import 'package:supabase_flutter/supabase_flutter.dart';

import '../domain/plan.dart';

abstract interface class PlansRepository {
  Future<List<Plan>> fetchAll();
  Future<List<Plan>> fetchActive();
  Future<Plan> createPlan({
    required String name,
    required double price,
    required int durationDays,
    double discountPercent = 0,
    String? couponCode,
    List<String> programs = const [],
    int maxLeaveDaysPerMonth = 4,
  });
  Future<Plan> updatePlan(
    String id, {
    String? name,
    double? price,
    int? durationDays,
    double? discountPercent,
    String? couponCode,
    List<String>? programs,
    int? maxLeaveDaysPerMonth,
    bool? isActive,
  });
}

class SupabasePlansRepository implements PlansRepository {
  SupabasePlansRepository(this._client);

  final SupabaseClient _client;

  @override
  Future<List<Plan>> fetchAll() async {
    final rows = await _client.from('plans').select().order('created_at');
    return (rows as List<dynamic>)
        .map((r) => Plan.fromMap(r as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<List<Plan>> fetchActive() async {
    final rows = await _client
        .from('plans')
        .select()
        .eq('is_active', true)
        .order('price');
    return (rows as List<dynamic>)
        .map((r) => Plan.fromMap(r as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<Plan> createPlan({
    required String name,
    required double price,
    required int durationDays,
    double discountPercent = 0,
    String? couponCode,
    List<String> programs = const [],
    int maxLeaveDaysPerMonth = 4,
  }) async {
    final row = await _client
        .from('plans')
        .insert({
          'name': name,
          'price': price,
          'duration_days': durationDays,
          'discount_percent': discountPercent,
          'coupon_code': couponCode,
          'programs': programs,
          'max_leave_days_per_month': maxLeaveDaysPerMonth,
          'created_by': _client.auth.currentUser?.id,
        })
        .select()
        .single();
    return Plan.fromMap(row);
  }

  @override
  Future<Plan> updatePlan(
    String id, {
    String? name,
    double? price,
    int? durationDays,
    double? discountPercent,
    String? couponCode,
    List<String>? programs,
    int? maxLeaveDaysPerMonth,
    bool? isActive,
  }) async {
    final patch = <String, dynamic>{};
    if (name != null) patch['name'] = name;
    if (price != null) patch['price'] = price;
    if (durationDays != null) patch['duration_days'] = durationDays;
    if (discountPercent != null) patch['discount_percent'] = discountPercent;
    if (couponCode != null) patch['coupon_code'] = couponCode;
    if (programs != null) patch['programs'] = programs;
    if (maxLeaveDaysPerMonth != null) {
      patch['max_leave_days_per_month'] = maxLeaveDaysPerMonth;
    }
    if (isActive != null) patch['is_active'] = isActive;
    final row = await _client
        .from('plans')
        .update(patch)
        .eq('id', id)
        .select()
        .single();
    return Plan.fromMap(row);
  }
}
