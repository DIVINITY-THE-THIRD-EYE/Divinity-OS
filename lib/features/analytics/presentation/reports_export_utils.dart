import 'dart:io';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import '../domain/reports_data.dart';

class ReportsExportUtils {
  static String _cleanCsv(String? val) {
    if (val == null) return '';
    return val.replaceAll(',', ' ').replaceAll('\n', ' ').trim();
  }

  static Future<void> exportAttendance(BuildContext context, ReportsData data) async {
    final buf = StringBuffer();
    buf.writeln('Student,Batch,Attendance Rate %,Total Classes,Attended Classes');
    for (final entry in data.attendance.studentAttendancePercentage.entries) {
      final name = _cleanCsv(entry.key);
      final rate = entry.value.toStringAsFixed(1);
      
      // Find matching low attendance entry if any to get class counts
      final alert = data.attendance.lowAttendanceAlerts.firstWhere(
        (a) => a.studentName == entry.key,
        orElse: () => LowAttendanceAlert(
          studentId: '',
          studentName: entry.key,
          attendanceRate: entry.value,
          totalClasses: 0,
          attendedClasses: 0,
        ),
      );
      
      buf.writeln('$name,$rate,${alert.totalClasses},${alert.attendedClasses}');
    }
    await _shareCsv(context, buf.toString(), 'attendance_analytics');
  }

  static Future<void> exportRevenue(BuildContext context, ReportsData data) async {
    final buf = StringBuffer();
    buf.writeln('Date,Amount,Plan');
    for (final t in data.revenue.dailyRevenue) {
      final date = DateFormat('yyyy-MM-dd').format(t.date);
      buf.writeln('$date,${t.value},');
    }
    await _shareCsv(context, buf.toString(), 'revenue_analytics');
  }

  static Future<void> exportMemberships(BuildContext context, ReportsData data) async {
    final buf = StringBuffer();
    buf.writeln('Plan,Sales Count,Revenue Collected');
    for (final entry in data.revenue.membershipSales.entries) {
      final plan = _cleanCsv(entry.key);
      final count = entry.value;
      final rev = data.revenue.revenueByPlan[entry.key] ?? 0.0;
      buf.writeln('$plan,$count,$rev');
    }
    await _shareCsv(context, buf.toString(), 'membership_sales');
  }

  static Future<void> exportStudents(BuildContext context, ReportsData data) async {
    final buf = StringBuffer();
    buf.writeln('Metric,Value');
    buf.writeln('Total Students,${data.students.totalStudents}');
    buf.writeln('Active Students,${data.students.activeStudents}');
    buf.writeln('Inactive Students,${data.students.inactiveStudents}');
    buf.writeln('New Students,${data.students.newStudents}');
    buf.writeln('Male Students,${data.students.genderDistribution['MALE'] ?? 0}');
    buf.writeln('Female Students,${data.students.genderDistribution['FEMALE'] ?? 0}');
    buf.writeln('Other Students,${data.students.genderDistribution['OTHER'] ?? 0}');
    await _shareCsv(context, buf.toString(), 'student_demographics');
  }

  static Future<void> exportTrainers(BuildContext context, ReportsData data) async {
    final buf = StringBuffer();
    buf.writeln('Trainer,Active Batches,Student Count,Classes Conducted,Attendance Handled');
    for (final t in data.trainers) {
      final name = _cleanCsv(t.trainerName);
      buf.writeln('$name,${t.activeBatchesCount},${t.studentCount},${t.classesConducted},${t.attendanceHandled}');
    }
    await _shareCsv(context, buf.toString(), 'trainer_reports');
  }

  static Future<void> exportEvents(BuildContext context, ReportsData data) async {
    final buf = StringBuffer();
    buf.writeln('Event,Starts At,Registrations,Attendance,Status');
    for (final e in data.events) {
      final title = _cleanCsv(e.title);
      final date = DateFormat('yyyy-MM-dd HH:mm').format(e.startsAt);
      final status = e.isCancelled ? 'Cancelled' : (e.isFull ? 'Full' : 'Open');
      buf.writeln('$title,$date,${e.registrationsCount},${e.attendanceCount},$status');
    }
    await _shareCsv(context, buf.toString(), 'events_reports');
  }

  static Future<void> _shareCsv(BuildContext context, String content, String prefix) async {
    final dir = await getTemporaryDirectory();
    final stamp = DateFormat('yyyyMMdd_HHmm').format(DateTime.now());
    final file = File('${dir.path}/${prefix}_$stamp.csv');
    await file.writeAsString(content);
    
    if (!context.mounted) return;
    await Share.shareXFiles(
      [XFile(file.path, mimeType: 'text/csv')],
      subject: 'Divinity Export $prefix $stamp',
    );
  }
}
