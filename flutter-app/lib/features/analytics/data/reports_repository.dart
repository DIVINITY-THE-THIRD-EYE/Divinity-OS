import 'package:supabase_flutter/supabase_flutter.dart';
import '../domain/reports_data.dart';

abstract interface class ReportsRepository {
  Future<ReportsData> fetchReports(ReportFilters filters);
}

class SupabaseReportsRepository implements ReportsRepository {
  SupabaseReportsRepository(this._client);
  final SupabaseClient _client;

  @override
  Future<ReportsData> fetchReports(ReportFilters filters) async {
    try {
      // Call the server-side aggregator RPC
      final dynamic rawData = await _client.rpc(
        'get_reports_data',
        params: {
          if (filters.startDate != null)
            'p_start_date': filters.startDate!.toIso8601String(),
          if (filters.endDate != null)
            'p_end_date': filters.endDate!.toIso8601String(),
          if (filters.trainerId != null) 'p_trainer_id': filters.trainerId,
          if (filters.batchId != null) 'p_batch_id': filters.batchId,
          if (filters.membershipPlan != null) 'p_plan': filters.membershipPlan,
          if (filters.studentStatus != null) 'p_status': filters.studentStatus,
          if (filters.eventId != null) 'p_event_id': filters.eventId,
        },
      );

      final data = rawData as Map<String, dynamic>;

      // A. Parse Attendance Report
      final attData = data['attendance'] as Map<String, dynamic>;

      final dailyAttendance = (attData['dailyAttendance'] as List<dynamic>).map(
        (e) {
          final m = e as Map<String, dynamic>;
          return DailyTrend(
            date: DateTime.parse(m['date'] as String),
            value: (m['value'] as num).toDouble(),
          );
        },
      ).toList();

      final monthlyAttendance = (attData['monthlyAttendance'] as List<dynamic>)
          .map((e) {
            final m = e as Map<String, dynamic>;
            return MonthlyTrend(
              month: DateTime.parse(m['month'] as String),
              value: (m['value'] as num).toDouble(),
            );
          })
          .toList();

      final perBatchAttendance =
          (attData['perBatchAttendance'] as Map<String, dynamic>).map(
            (key, value) => MapEntry(key, (value as num).toDouble()),
          );

      final perTrainerAttendance =
          (attData['perTrainerAttendance'] as Map<String, dynamic>).map(
            (key, value) => MapEntry(key, (value as num).toDouble()),
          );

      final studentAttendancePercentage =
          (attData['studentAttendancePercentage'] as Map<String, dynamic>).map(
            (key, value) => MapEntry(key, (value as num).toDouble()),
          );

      final lowAttendanceAlerts =
          (attData['lowAttendanceAlerts'] as List<dynamic>).map((e) {
            final m = e as Map<String, dynamic>;
            return LowAttendanceAlert(
              studentId: m['student_id'] as String,
              studentName: m['student_name'] as String,
              attendanceRate: (m['attendance_rate'] as num).toDouble(),
              totalClasses: m['total_classes'] as int,
              attendedClasses: m['attended_classes'] as int,
            );
          }).toList();

      final attendanceReport = AttendanceReport(
        dailyAttendance: dailyAttendance,
        monthlyAttendance: monthlyAttendance,
        perBatchAttendance: perBatchAttendance,
        perTrainerAttendance: perTrainerAttendance,
        studentAttendancePercentage: studentAttendancePercentage,
        lowAttendanceAlerts: lowAttendanceAlerts,
      );

      // B. Parse Revenue Report
      final revData = data['revenue'] as Map<String, dynamic>;

      final dailyRevenue = (revData['dailyRevenue'] as List<dynamic>).map((e) {
        final m = e as Map<String, dynamic>;
        return DailyTrend(
          date: DateTime.parse(m['date'] as String),
          value: (m['value'] as num).toDouble(),
        );
      }).toList();

      final monthlyRevenue = (revData['monthlyRevenue'] as List<dynamic>).map((
        e,
      ) {
        final m = e as Map<String, dynamic>;
        return MonthlyTrend(
          month: DateTime.parse(m['month'] as String),
          value: (m['value'] as num).toDouble(),
        );
      }).toList();

      final yearlyRevenue = (revData['yearlyRevenue'] as List<dynamic>).map((
        e,
      ) {
        final m = e as Map<String, dynamic>;
        return MonthlyTrend(
          month: DateTime.parse(m['month'] as String),
          value: (m['value'] as num).toDouble(),
        );
      }).toList();

      final membershipSales =
          (revData['membershipSales'] as Map<String, dynamic>).map(
            (key, value) => MapEntry(key, value as int),
          );

      final revenueByPlan = (revData['revenueByPlan'] as Map<String, dynamic>)
          .map((key, value) => MapEntry(key, (value as num).toDouble()));

      final revenueReport = RevenueReport(
        dailyRevenue: dailyRevenue,
        monthlyRevenue: monthlyRevenue,
        yearlyRevenue: yearlyRevenue,
        outstandingFees: (revData['outstandingFees'] as num).toDouble(),
        paidCount: revData['paidCount'] as int,
        unpaidCount: revData['unpaidCount'] as int,
        membershipSales: membershipSales,
        revenueByPlan: revenueByPlan,
      );

      // C. Parse Membership Report
      final memData = data['membership'] as Map<String, dynamic>;

      final membershipGrowth = (memData['membershipGrowth'] as List<dynamic>)
          .map((e) {
            final m = e as Map<String, dynamic>;
            return MonthlyTrend(
              month: DateTime.parse(m['month'] as String),
              value: (m['value'] as num).toDouble(),
            );
          })
          .toList();

      final membershipReport = MembershipReport(
        activeMemberships: memData['activeMemberships'] as int,
        expiringMemberships: memData['expiringMemberships'] as int,
        expiredMemberships: memData['expiredMemberships'] as int,
        renewals: memData['renewals'] as int,
        newRegistrations: memData['newRegistrations'] as int,
        membershipGrowth: membershipGrowth,
      );

      // D. Parse Student Report
      final studData = data['students'] as Map<String, dynamic>;

      final studentGrowth = (studData['studentGrowth'] as List<dynamic>).map((
        e,
      ) {
        final m = e as Map<String, dynamic>;
        return MonthlyTrend(
          month: DateTime.parse(m['month'] as String),
          value: (m['value'] as num).toDouble(),
        );
      }).toList();

      final genderDistribution =
          (studData['genderDistribution'] as Map<String, dynamic>).map(
            (key, value) => MapEntry(key, value as int),
          );

      final studentReport = StudentReport(
        totalStudents: studData['totalStudents'] as int,
        activeStudents: studData['activeStudents'] as int,
        inactiveStudents: studData['inactiveStudents'] as int,
        newStudents: studData['newStudents'] as int,
        studentGrowth: studentGrowth,
        genderDistribution: genderDistribution,
      );

      // E. Parse Trainer Report Items
      final trainerReports = (data['trainers'] as List<dynamic>).map((e) {
        final m = e as Map<String, dynamic>;
        return TrainerReportItem(
          trainerId: m['trainer_id'] as String,
          trainerName: m['trainer_name'] as String,
          classesConducted: m['classes_conducted'] as int,
          attendanceHandled: m['attendance_handled'] as int,
          activeBatchesCount: m['active_batches_count'] as int,
          studentCount: m['student_count'] as int,
        );
      }).toList();

      // F. Parse Event Report Items
      final eventReports = (data['events'] as List<dynamic>).map((e) {
        final m = e as Map<String, dynamic>;
        return EventReportItem(
          eventId: m['event_id'] as String,
          title: m['title'] as String,
          startsAt: DateTime.parse(m['starts_at'] as String),
          registrationsCount: m['registrations_count'] as int,
          attendanceCount: m['attendance_count'] as int,
          isFull: m['is_full'] as bool,
          isCancelled: m['is_cancelled'] as bool,
        );
      }).toList();

      // G. Parse Holiday Report Items
      final holidayReports = (data['holidays'] as List<dynamic>).map((e) {
        final m = e as Map<String, dynamic>;
        return HolidayReportItem(
          holidayId: m['holiday_id'] as String,
          name: m['name'] as String,
          date: DateTime.parse(m['date'] as String),
          overlapCount: m['overlap_count'] as int,
        );
      }).toList();

      // H. Parse Batches List
      final batchesList = (data['batches'] as List<dynamic>).map((e) {
        final m = e as Map<String, dynamic>;
        return BatchReportItem(
          id: m['id'] as String,
          name: m['name'] as String,
        );
      }).toList();

      return ReportsData(
        attendance: attendanceReport,
        revenue: revenueReport,
        membership: membershipReport,
        students: studentReport,
        trainers: trainerReports,
        events: eventReports,
        holidays: holidayReports,
        batches: batchesList,
      );
    } on PostgrestException catch (e) {
      throw Exception(e.message);
    }
  }
}
