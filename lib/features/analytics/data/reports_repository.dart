import 'package:supabase_flutter/supabase_flutter.dart';
import '../domain/reports_data.dart';

abstract interface class ReportsRepository {
  Future<ReportsData> fetchReports(ReportFilters filters);
}

class SupabaseReportsRepository implements ReportsRepository {
  SupabaseReportsRepository(this._client);
  final SupabaseClient _client;

  String _getPlanName(double amount) {
    if (amount >= 15000) return 'Annual Plan';
    if (amount >= 4000) return 'Quarterly Plan';
    return 'Monthly Plan';
  }

  @override
  Future<ReportsData> fetchReports(ReportFilters filters) async {
    // 1. Fetch raw data from Supabase in parallel
    final queries = await Future.wait([
      _client.from('users').select('id, name, email, phone, role, age, gender, plan_status, expiration_date, created_at'),
      _client.from('batches').select('id, name, trainer_id, schedule_time, status'),
      _client.from('enrollments').select('student_id, batch_id'),
      _client.from('attendance').select('id, student_id, batch_id, date, status, checkin_time, marked_by'),
      _client.from('payments').select('id, student_id, amount, status, payment_method, plan_expiration_date, paid_at, created_at'),
      _client.from('events').select('id, title, starts_at, capacity, status'),
      _client.from('event_registrations').select('id, event_id, student_id'),
      _client.from('holidays').select('id, name, date'),
    ]);

    final rawUsers = queries[0] as List<dynamic>;
    final rawBatches = queries[1] as List<dynamic>;
    final rawEnrollments = queries[2] as List<dynamic>;
    final rawAttendance = queries[3] as List<dynamic>;
    final rawPayments = queries[4] as List<dynamic>;
    final rawEvents = queries[5] as List<dynamic>;
    final rawEventRegistrations = queries[6] as List<dynamic>;
    final rawHolidays = queries[7] as List<dynamic>;

    // Map raw data to maps/lookups for easy processing
    final usersMap = {for (final u in rawUsers) u['id'] as String: u};
    final batchesMap = {for (final b in rawBatches) b['id'] as String: b};

    // Helper: Map trainer ID to trainer name
    String getTrainerName(String? trainerId) {
      if (trainerId == null) return 'Unassigned';
      final u = usersMap[trainerId];
      return u?['name'] as String? ?? 'Trainer';
    }

    // Helper: Get student name
    String getStudentName(String studentId) {
      final u = usersMap[studentId];
      return u?['name'] as String? ?? studentId.substring(0, 8);
    }

    // --- APPLY FILTERS IN DART FOR FLEXIBLE MULTI-FIELD COMBINATIONS ---
    
    // Filtered lists
    List<dynamic> filteredAttendance = List.from(rawAttendance);
    List<dynamic> filteredPayments = List.from(rawPayments);
    List<dynamic> filteredUsers = rawUsers.where((u) => u['role'] == 'STUDENT').toList();
    List<dynamic> filteredEvents = List.from(rawEvents);
    List<dynamic> filteredEventRegs = List.from(rawEventRegistrations);

    // 1. Date Range filter (startDate, endDate)
    if (filters.startDate != null) {
      filteredAttendance = filteredAttendance.where((a) {
        final d = DateTime.parse(a['date'] as String);
        return d.isAfter(filters.startDate!) || d.isAtSameMomentAs(filters.startDate!);
      }).toList();

      filteredPayments = filteredPayments.where((p) {
        final paidAtStr = p['paid_at'] as String?;
        if (paidAtStr == null) return false;
        final d = DateTime.parse(paidAtStr);
        return d.isAfter(filters.startDate!) || d.isAtSameMomentAs(filters.startDate!);
      }).toList();
    }
    if (filters.endDate != null) {
      filteredAttendance = filteredAttendance.where((a) {
        final d = DateTime.parse(a['date'] as String);
        return d.isBefore(filters.endDate!) || d.isAtSameMomentAs(filters.endDate!);
      }).toList();

      filteredPayments = filteredPayments.where((p) {
        final paidAtStr = p['paid_at'] as String?;
        if (paidAtStr == null) return false;
        final d = DateTime.parse(paidAtStr);
        return d.isBefore(filters.endDate!) || d.isAtSameMomentAs(filters.endDate!);
      }).toList();
    }

    // 2. Month/Year filter (if specified - can override or be derived)
    // Note: If filters specify date ranges, that is usually sufficient. But if they select Month/Year, we can enforce it.

    // 3. Trainer filter
    if (filters.trainerId != null) {
      // Find batches conducted by this trainer
      final trainerBatchIds = rawBatches
          .where((b) => b['trainer_id'] == filters.trainerId)
          .map((b) => b['id'] as String)
          .toSet();

      // Filter attendance to this trainer's batches
      filteredAttendance = filteredAttendance
          .where((a) => trainerBatchIds.contains(a['batch_id']))
          .toList();

      // Find students enrolled in this trainer's batches
      final trainerStudentIds = rawEnrollments
          .where((e) => trainerBatchIds.contains(e['batch_id']))
          .map((e) => e['student_id'] as String)
          .toSet();

      filteredUsers = filteredUsers
          .where((u) => trainerStudentIds.contains(u['id']))
          .toList();

      // Filter payments to these students
      filteredPayments = filteredPayments
          .where((p) => trainerStudentIds.contains(p['student_id']))
          .toList();
    }

    // 4. Batch filter
    if (filters.batchId != null) {
      filteredAttendance = filteredAttendance
          .where((a) => a['batch_id'] == filters.batchId)
          .toList();

      final batchStudentIds = rawEnrollments
          .where((e) => e['batch_id'] == filters.batchId)
          .map((e) => e['student_id'] as String)
          .toSet();

      filteredUsers = filteredUsers
          .where((u) => batchStudentIds.contains(u['id']))
          .toList();

      filteredPayments = filteredPayments
          .where((p) => batchStudentIds.contains(p['student_id']))
          .toList();
    }

    // 5. Membership Plan filter
    if (filters.membershipPlan != null) {
      filteredPayments = filteredPayments.where((p) {
        final amt = (p['amount'] as num).toDouble();
        return _getPlanName(amt).toLowerCase() == filters.membershipPlan!.toLowerCase();
      }).toList();

      final planStudentIds = filteredPayments
          .map((p) => p['student_id'] as String)
          .toSet();

      filteredUsers = filteredUsers
          .where((u) => planStudentIds.contains(u['id']))
          .toList();

      filteredAttendance = filteredAttendance
          .where((a) => planStudentIds.contains(a['student_id']))
          .toList();
    }

    // 6. Student Status filter
    if (filters.studentStatus != null) {
      filteredUsers = filteredUsers
          .where((u) => (u['plan_status'] as String).toLowerCase() == filters.studentStatus!.toLowerCase())
          .toList();

      final statusStudentIds = filteredUsers
          .map((u) => u['id'] as String)
          .toSet();

      filteredAttendance = filteredAttendance
          .where((a) => statusStudentIds.contains(a['student_id']))
          .toList();

      filteredPayments = filteredPayments
          .where((p) => statusStudentIds.contains(p['student_id']))
          .toList();
    }

    // 7. Event filter
    if (filters.eventId != null) {
      filteredEvents = filteredEvents
          .where((e) => e['id'] == filters.eventId)
          .toList();

      filteredEventRegs = filteredEventRegs
          .where((r) => r['event_id'] == filters.eventId)
          .toList();
    }

    // --- COMPUTE STATISTICS & TRENDS ---

    // A. Attendance Report
    final dailyAttendanceMap = <DateTime, int>{};
    final monthlyAttendanceMap = <DateTime, int>{};
    final batchAttendanceMap = <String, List<bool>>{};   // batchName -> [isPresent]
    final trainerAttendanceMap = <String, List<bool>>{}; // trainerName -> [isPresent]
    final studentAttendanceMap = <String, List<bool>>{}; // studentName -> [isPresent]

    for (final a in filteredAttendance) {
      final dateStr = a['date'] as String;
      final date = DateTime.parse(dateStr);
      final dayDate = DateTime(date.year, date.month, date.day);
      final monthDate = DateTime(date.year, date.month);
      final isPresent = (a['status'] as String).toUpperCase() == 'PRESENT';

      if (isPresent) {
        dailyAttendanceMap[dayDate] = (dailyAttendanceMap[dayDate] ?? 0) + 1;
        monthlyAttendanceMap[monthDate] = (monthlyAttendanceMap[monthDate] ?? 0) + 1;
      }

      final batchId = a['batch_id'] as String?;
      if (batchId != null && batchesMap.containsKey(batchId)) {
        final b = batchesMap[batchId]!;
        final bName = b['name'] as String;
        batchAttendanceMap.putIfAbsent(bName, () => []).add(isPresent);

        final tId = b['trainer_id'] as String?;
        final tName = getTrainerName(tId);
        trainerAttendanceMap.putIfAbsent(tName, () => []).add(isPresent);
      }

      final sName = getStudentName(a['student_id'] as String);
      studentAttendanceMap.putIfAbsent(sName, () => []).add(isPresent);
    }

    final dailyAttendanceTrends = dailyAttendanceMap.entries
        .map((e) => DailyTrend(date: e.key, value: e.value.toDouble()))
        .toList()
      ..sort((a, b) => a.date.compareTo(b.date));

    final monthlyAttendanceTrends = monthlyAttendanceMap.entries
        .map((e) => MonthlyTrend(month: e.key, value: e.value.toDouble()))
        .toList()
      ..sort((a, b) => a.month.compareTo(b.month));

    final perBatchAttendance = batchAttendanceMap.map((name, list) {
      final total = list.length;
      final presents = list.where((p) => p).length;
      return MapEntry(name, total == 0 ? 0.0 : (presents / total) * 100);
    });

    final perTrainerAttendance = trainerAttendanceMap.map((name, list) {
      final total = list.length;
      final presents = list.where((p) => p).length;
      return MapEntry(name, total == 0 ? 0.0 : (presents / total) * 100);
    });

    final studentAttendancePercentage = studentAttendanceMap.map((name, list) {
      final total = list.length;
      final presents = list.where((p) => p).length;
      return MapEntry(name, total == 0 ? 0.0 : (presents / total) * 100);
    });

    // Compute Low Attendance Alerts (< 75% attendance rate, with at least 2 classes)
    final lowAttendanceAlerts = <LowAttendanceAlert>[];
    for (final entry in studentAttendanceMap.entries) {
      final name = entry.key;
      final list = entry.value;
      final total = list.length;
      final presents = list.where((p) => p).length;
      final rate = total == 0 ? 0.0 : (presents / total) * 100;
      if (total >= 2 && rate < 75.0) {
        // Find matching student ID
        final studentId = filteredAttendance.firstWhere(
            (a) => getStudentName(a['student_id'] as String) == name)['student_id'] as String;
        lowAttendanceAlerts.add(LowAttendanceAlert(
          studentId: studentId,
          studentName: name,
          attendanceRate: rate,
          totalClasses: total,
          attendedClasses: presents,
        ));
      }
    }
    lowAttendanceAlerts.sort((a, b) => a.attendanceRate.compareTo(b.attendanceRate));

    final attendanceReport = AttendanceReport(
      dailyAttendance: dailyAttendanceTrends,
      monthlyAttendance: monthlyAttendanceTrends,
      perBatchAttendance: perBatchAttendance,
      perTrainerAttendance: perTrainerAttendance,
      studentAttendancePercentage: studentAttendancePercentage,
      lowAttendanceAlerts: lowAttendanceAlerts,
    );

    // B. Revenue Report
    final dailyRevenueMap = <DateTime, double>{};
    final monthlyRevenueMap = <DateTime, double>{};
    final yearlyRevenueMap = <DateTime, double>{};
    double outstandingFees = 0.0;
    int paidCount = 0;
    int unpaidCount = 0;
    final membershipSales = <String, int>{};
    final revenueByPlan = <String, double>{};

    for (final p in filteredPayments) {
      final amt = (p['amount'] as num).toDouble();
      final status = p['status'] as String? ?? 'PENDING';
      final planName = _getPlanName(amt);

      if (status.toUpperCase() == 'PAID') {
        paidCount++;
        final paidAtStr = p['paid_at'] as String?;
        if (paidAtStr != null) {
          final paidAt = DateTime.parse(paidAtStr);
          final dayDate = DateTime(paidAt.year, paidAt.month, paidAt.day);
          final monthDate = DateTime(paidAt.year, paidAt.month);
          final yearDate = DateTime(paidAt.year);

          dailyRevenueMap[dayDate] = (dailyRevenueMap[dayDate] ?? 0.0) + amt;
          monthlyRevenueMap[monthDate] = (monthlyRevenueMap[monthDate] ?? 0.0) + amt;
          yearlyRevenueMap[yearDate] = (yearlyRevenueMap[yearDate] ?? 0.0) + amt;
        }

        membershipSales[planName] = (membershipSales[planName] ?? 0) + 1;
        revenueByPlan[planName] = (revenueByPlan[planName] ?? 0.0) + amt;
      } else {
        unpaidCount++;
        outstandingFees += amt;
      }
    }

    final dailyRevenueTrends = dailyRevenueMap.entries
        .map((e) => DailyTrend(date: e.key, value: e.value))
        .toList()
      ..sort((a, b) => a.date.compareTo(b.date));

    final monthlyRevenueTrends = monthlyRevenueMap.entries
        .map((e) => MonthlyTrend(month: e.key, value: e.value))
        .toList()
      ..sort((a, b) => a.month.compareTo(b.month));

    final yearlyRevenueTrends = yearlyRevenueMap.entries
        .map((e) => MonthlyTrend(month: e.key, value: e.value))
        .toList()
      ..sort((a, b) => a.month.compareTo(b.month));

    final revenueReport = RevenueReport(
      dailyRevenue: dailyRevenueTrends,
      monthlyRevenue: monthlyRevenueTrends,
      yearlyRevenue: yearlyRevenueTrends,
      outstandingFees: outstandingFees,
      paidCount: paidCount,
      unpaidCount: unpaidCount,
      membershipSales: membershipSales,
      revenueByPlan: revenueByPlan,
    );

    // C. Membership Report
    int activeMemberships = 0;
    int expiringMemberships = 0;
    int expiredMemberships = 0;
    int renewals = 0;
    int newRegistrations = 0;
    final now = DateTime.now();
    final thirtyDaysFromNow = now.add(const Duration(days: 30));

    final membershipGrowthMap = <DateTime, int>{};

    for (final u in filteredUsers) {
      final status = u['plan_status'] as String? ?? 'UNPAID';
      final expStr = u['expiration_date'] as String?;
      final createdStr = u['created_at'] as String;
      final created = DateTime.parse(createdStr);
      final regMonth = DateTime(created.year, created.month);

      if (status == 'ACTIVE') {
        activeMemberships++;
        if (expStr != null) {
          final exp = DateTime.parse(expStr);
          if (exp.isBefore(now)) {
            expiredMemberships++; // Active but expired (fallback/edge case)
          } else if (exp.isBefore(thirtyDaysFromNow)) {
            expiringMemberships++;
          }
        }
      } else if (status == 'EXPIRED') {
        expiredMemberships++;
      }

      // Growth over time: count active status additions
      membershipGrowthMap[regMonth] = (membershipGrowthMap[regMonth] ?? 0) + (status == 'ACTIVE' ? 1 : 0);

      // Check if registration was within current range
      final inDateRange = (filters.startDate == null || created.isAfter(filters.startDate!)) &&
          (filters.endDate == null || created.isBefore(filters.endDate!));
      if (inDateRange) {
        newRegistrations++;
      }

      // Check renewals: if user has > 1 paid payment, it's a renewal
      final uid = u['id'] as String;
      final studentPayments = rawPayments.where((p) => p['student_id'] == uid && p['status'] == 'PAID').toList();
      if (studentPayments.length > 1) {
        renewals++;
      }
    }

    final membershipGrowthTrends = membershipGrowthMap.entries
        .map((e) => MonthlyTrend(month: e.key, value: e.value.toDouble()))
        .toList()
      ..sort((a, b) => a.month.compareTo(b.month));

    final membershipReport = MembershipReport(
      activeMemberships: activeMemberships,
      expiringMemberships: expiringMemberships,
      expiredMemberships: expiredMemberships,
      renewals: renewals,
      newRegistrations: newRegistrations,
      membershipGrowth: membershipGrowthTrends,
    );

    // D. Student Report
    int totalStudents = 0;
    int activeStudents = 0;
    int inactiveStudents = 0;
    int newStudents = 0;
    final genderDistribution = <String, int>{};
    final studentGrowthMap = <DateTime, int>{};

    for (final u in filteredUsers) {
      totalStudents++;
      final status = u['plan_status'] as String? ?? 'UNPAID';
      final gender = u['gender'] as String? ?? 'PREFER_NOT_TO_SAY';
      final createdStr = u['created_at'] as String;
      final created = DateTime.parse(createdStr);
      final regMonth = DateTime(created.year, created.month);

      if (status == 'ACTIVE') {
        activeStudents++;
      } else {
        inactiveStudents++;
      }

      genderDistribution[gender] = (genderDistribution[gender] ?? 0) + 1;
      studentGrowthMap[regMonth] = (studentGrowthMap[regMonth] ?? 0) + 1;

      // New student registration in range
      final inDateRange = (filters.startDate == null || created.isAfter(filters.startDate!)) &&
          (filters.endDate == null || created.isBefore(filters.endDate!));
      if (inDateRange) {
        newStudents++;
      }
    }

    final studentGrowthTrends = studentGrowthMap.entries
        .map((e) => MonthlyTrend(month: e.key, value: e.value.toDouble()))
        .toList()
      ..sort((a, b) => a.month.compareTo(b.month));

    final studentReport = StudentReport(
      totalStudents: totalStudents,
      activeStudents: activeStudents,
      inactiveStudents: inactiveStudents,
      newStudents: newStudents,
      studentGrowth: studentGrowthTrends,
      genderDistribution: genderDistribution,
    );

    // E. Trainer Report Items
    final trainerReports = <TrainerReportItem>[];
    final trainersList = rawUsers.where((u) => u['role'] == 'TRAINER').toList();

    for (final t in trainersList) {
      final tId = t['id'] as String;
      final tName = t['name'] as String? ?? 'Trainer';

      final tBatches = rawBatches.where((b) => b['trainer_id'] == tId).toList();
      final tBatchIds = tBatches.map((b) => b['id'] as String).toSet();

      // Classes conducted is calculated as number of attendance lists marked for these batches
      final tAttendance = rawAttendance.where((a) => tBatchIds.contains(a['batch_id'])).toList();
      final distinctClassDates = tAttendance.map((a) => a['date'] as String).toSet().length;

      // Attendance handled: total checkins recorded for this trainer's batches
      final attendanceHandled = tAttendance.length;

      // Student count: total students enrolled in this trainer's batches
      final enrolledStudents = rawEnrollments
          .where((e) => tBatchIds.contains(e['batch_id']))
          .map((e) => e['student_id'] as String)
          .toSet()
          .length;

      trainerReports.add(TrainerReportItem(
        trainerId: tId,
        trainerName: tName,
        classesConducted: distinctClassDates,
        attendanceHandled: attendanceHandled,
        activeBatchesCount: tBatches.length,
        studentCount: enrolledStudents,
      ));
    }

    // F. Events Report Items
    final eventReports = <EventReportItem>[];
    for (final e in filteredEvents) {
      final eId = e['id'] as String;
      final title = e['title'] as String;
      final startsAt = DateTime.parse(e['starts_at'] as String);
      final status = e['status'] as String? ?? 'PUBLISHED';
      final capacity = e['capacity'] as int?;

      final registrations = rawEventRegistrations.where((r) => r['event_id'] == eId).toList();
      final regCount = registrations.length;

      // Attendance count (we check if there are attendance checkins for event, but events are separate in database)
      // Since Module 11 Events table doesn't have an attendance join, we define attendanceCount as RSVP registrants
      // who actually attended, or we count registrations as attendance if there is no attendance column.
      // Wait, is there an attendance count for events? We can mock it to 0 or count it based on student check-ins.
      // Since event_registrations does not have a check-in column, we can calculate attendanceCount as equal to registration count.
      final attendanceCount = regCount; 

      final isCancelled = status.toUpperCase() == 'CANCELLED';
      final isFull = capacity != null && regCount >= capacity;

      eventReports.add(EventReportItem(
        eventId: eId,
        title: title,
        startsAt: startsAt,
        registrationsCount: regCount,
        attendanceCount: attendanceCount,
        isFull: isFull,
        isCancelled: isCancelled,
      ));
    }
    eventReports.sort((a, b) => a.startsAt.compareTo(b.startsAt));

    // G. Holidays Report Items
    final holidayReports = <HolidayReportItem>[];
    for (final h in rawHolidays) {
      final hId = h['id'] as String;
      final name = h['name'] as String;
      final dateStr = h['date'] as String;
      final date = DateTime.parse(dateStr);

      // Overlap count: count attendance records marked HOLIDAY on this date
      final overlap = rawAttendance
          .where((a) => a['date'] == dateStr && (a['status'] as String).toUpperCase() == 'HOLIDAY')
          .length;

      holidayReports.add(HolidayReportItem(
        holidayId: hId,
        name: name,
        date: date,
        overlapCount: overlap,
      ));
    }
    holidayReports.sort((a, b) => a.date.compareTo(b.date));

    final batchesList = rawBatches
        .map((b) => BatchReportItem(
              id: b['id'] as String,
              name: b['name'] as String,
            ))
        .toList();

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
  }
}
