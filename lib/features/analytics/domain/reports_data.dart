class ReportFilters {
  final DateTime? startDate;
  final DateTime? endDate;
  final String? trainerId;
  final String? batchId;
  final String? membershipPlan;
  final String? studentStatus;
  final String? eventId;

  const ReportFilters({
    this.startDate,
    this.endDate,
    this.trainerId,
    this.batchId,
    this.membershipPlan,
    this.studentStatus,
    this.eventId,
  });

  ReportFilters copyWith({
    DateTime? Function()? startDate,
    DateTime? Function()? endDate,
    String? Function()? trainerId,
    String? Function()? batchId,
    String? Function()? membershipPlan,
    String? Function()? studentStatus,
    String? Function()? eventId,
  }) {
    return ReportFilters(
      startDate: startDate != null ? startDate() : this.startDate,
      endDate: endDate != null ? endDate() : this.endDate,
      trainerId: trainerId != null ? trainerId() : this.trainerId,
      batchId: batchId != null ? batchId() : this.batchId,
      membershipPlan: membershipPlan != null ? membershipPlan() : this.membershipPlan,
      studentStatus: studentStatus != null ? studentStatus() : this.studentStatus,
      eventId: eventId != null ? eventId() : this.eventId,
    );
  }

  bool get isEmpty =>
      startDate == null &&
      endDate == null &&
      trainerId == null &&
      batchId == null &&
      membershipPlan == null &&
      studentStatus == null &&
      eventId == null;
}

class DailyTrend {
  final DateTime date;
  final double value;
  const DailyTrend({required this.date, required this.value});
}

class MonthlyTrend {
  final DateTime month; // First day of the month
  final double value;
  const MonthlyTrend({required this.month, required this.value});
}

class LowAttendanceAlert {
  final String studentId;
  final String studentName;
  final double attendanceRate;
  final int totalClasses;
  final int attendedClasses;

  const LowAttendanceAlert({
    required this.studentId,
    required this.studentName,
    required this.attendanceRate,
    required this.totalClasses,
    required this.attendedClasses,
  });
}

class AttendanceReport {
  final List<DailyTrend> dailyAttendance;
  final List<MonthlyTrend> monthlyAttendance;
  final Map<String, double> perBatchAttendance;   // batchId/name -> check-in count or rate
  final Map<String, double> perTrainerAttendance; // trainerId/name -> check-in count or rate
  final Map<String, double> studentAttendancePercentage; // studentName -> check-in rate
  final List<LowAttendanceAlert> lowAttendanceAlerts;

  const AttendanceReport({
    required this.dailyAttendance,
    required this.monthlyAttendance,
    required this.perBatchAttendance,
    required this.perTrainerAttendance,
    required this.studentAttendancePercentage,
    required this.lowAttendanceAlerts,
  });
}

class RevenueReport {
  final List<DailyTrend> dailyRevenue;
  final List<MonthlyTrend> monthlyRevenue;
  final List<MonthlyTrend> yearlyRevenue;
  final double outstandingFees;
  final int paidCount;
  final int unpaidCount;
  final Map<String, int> membershipSales;   // planName -> count of sales
  final Map<String, double> revenueByPlan;  // planName -> revenue

  const RevenueReport({
    required this.dailyRevenue,
    required this.monthlyRevenue,
    required this.yearlyRevenue,
    required this.outstandingFees,
    required this.paidCount,
    required this.unpaidCount,
    required this.membershipSales,
    required this.revenueByPlan,
  });
}

class MembershipReport {
  final int activeMemberships;
  final int expiringMemberships;
  final int expiredMemberships;
  final int renewals;
  final int newRegistrations;
  final List<MonthlyTrend> membershipGrowth; // active count over time

  const MembershipReport({
    required this.activeMemberships,
    required this.expiringMemberships,
    required this.expiredMemberships,
    required this.renewals,
    required this.newRegistrations,
    required this.membershipGrowth,
  });
}

class StudentReport {
  final int totalStudents;
  final int activeStudents;
  final int inactiveStudents;
  final int newStudents;
  final List<MonthlyTrend> studentGrowth;
  final Map<String, int> genderDistribution;

  const StudentReport({
    required this.totalStudents,
    required this.activeStudents,
    required this.inactiveStudents,
    required this.newStudents,
    required this.studentGrowth,
    required this.genderDistribution,
  });
}

class TrainerReportItem {
  final String trainerId;
  final String trainerName;
  final int classesConducted;
  final int attendanceHandled;
  final int activeBatchesCount;
  final int studentCount;

  const TrainerReportItem({
    required this.trainerId,
    required this.trainerName,
    required this.classesConducted,
    required this.attendanceHandled,
    required this.activeBatchesCount,
    required this.studentCount,
  });
}

class EventReportItem {
  final String eventId;
  final String title;
  final DateTime startsAt;
  final int registrationsCount;
  final int attendanceCount;
  final bool isFull;
  final bool isCancelled;

  const EventReportItem({
    required this.eventId,
    required this.title,
    required this.startsAt,
    required this.registrationsCount,
    required this.attendanceCount,
    required this.isFull,
    required this.isCancelled,
  });
}

class HolidayReportItem {
  final String holidayId;
  final String name;
  final DateTime date;
  final int overlapCount; // attendance records marked HOLIDAY on this date

  const HolidayReportItem({
    required this.holidayId,
    required this.name,
    required this.date,
    required this.overlapCount,
  });
}

class BatchReportItem {
  final String id;
  final String name;
  const BatchReportItem({required this.id, required this.name});
}

class ReportsData {
  final AttendanceReport attendance;
  final RevenueReport revenue;
  final MembershipReport membership;
  final StudentReport students;
  final List<TrainerReportItem> trainers;
  final List<EventReportItem> events;
  final List<HolidayReportItem> holidays;
  final List<BatchReportItem> batches;

  const ReportsData({
    required this.attendance,
    required this.revenue,
    required this.membership,
    required this.students,
    required this.trainers,
    required this.events,
    required this.holidays,
    required this.batches,
  });
}
