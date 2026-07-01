import 'package:intl/intl.dart';

class MonthlyValue {
  const MonthlyValue({required this.month, required this.value});
  final DateTime month; // first day of month
  final double value;

  String get monthLabel => DateFormat('MMM').format(month);
}

class DashboardStats {
  const DashboardStats({
    required this.totalStudents,
    required this.activeStudents,
    required this.totalRevenue,
    required this.pendingAmount,
    required this.monthlyRevenue,
    required this.monthlyEnrolments,
  });

  final int totalStudents;
  final int activeStudents;
  final double totalRevenue;
  final double pendingAmount;
  final List<MonthlyValue> monthlyRevenue; // oldest→newest, length 6
  final List<MonthlyValue> monthlyEnrolments; // oldest→newest, length 6

  String get totalRevenueLabel => NumberFormat.currency(
    locale: 'en_IN',
    symbol: '₹',
    decimalDigits: 0,
  ).format(totalRevenue);

  String get pendingAmountLabel => NumberFormat.currency(
    locale: 'en_IN',
    symbol: '₹',
    decimalDigits: 0,
  ).format(pendingAmount);
}
