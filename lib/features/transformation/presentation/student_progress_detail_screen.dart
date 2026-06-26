import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../core/theme/app_theme.dart';
import '../../../shared/widgets/loading_widget.dart' show ChakraLoader;
import '../../auth/presentation/auth_provider.dart';
import '../../shared/students_screen.dart' show AppUser;
import '../domain/transformation_score.dart';
import 'transformation_provider.dart';

class StudentProgressDetailScreen extends ConsumerWidget {
  const StudentProgressDetailScreen({super.key, required this.student});
  final AppUser student;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scoresAsync = ref.watch(studentScoresHistoryProvider(student.id));
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text(student.name),
      ),
      body: RefreshIndicator(
        onRefresh: () => ref.refresh(studentScoresHistoryProvider(student.id).future),
        child: scoresAsync.when(
          loading: () => const Center(child: ChakraLoader()),
          error: (e, _) => Center(child: Text('Error loading scores: $e')),
          data: (scores) {
            final latest = scores.isNotEmpty ? scores.last : null;

            return ListView(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 80),
              children: [
                _StudentSummaryCard(student: student, latestScore: latest?.score),
                const SizedBox(height: 16),
                if (scores.isEmpty) ...[
                  _NoScoresCard(studentName: student.name),
                ] else ...[
                  _RadarChartSection(latest: latest!, isDark: isDark),
                  const SizedBox(height: 16),
                  if (scores.length >= 2) ...[
                    _TrendChartSection(scores: scores, isDark: isDark),
                    const SizedBox(height: 16),
                  ],
                  _ScoresTableSection(scores: scores, studentId: student.id, isDark: isDark),
                ],
              ],
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showRecordScoreSheet(context, student.id, scoresAsync.value),
        icon: const Icon(Icons.add),
        label: const Text('Record Score'),
      ),
    );
  }

  void _showRecordScoreSheet(BuildContext context, String studentId, List<TransformationScore>? currentHistory) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (_) => _RecordScoreSheet(studentId: studentId, history: currentHistory),
    );
  }
}

// ── Student Summary Card ─────────────────────────────────────────────────────

class _StudentSummaryCard extends StatelessWidget {
  const _StudentSummaryCard({required this.student, this.latestScore});
  final AppUser student;
  final double? latestScore;

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            CircleAvatar(
              radius: 28,
              backgroundColor: AppColors.accentViolet.withValues(alpha: 0.15),
              child: Text(
                student.name[0].toUpperCase(),
                style: tt.headlineMedium?.copyWith(color: AppColors.accentViolet),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(student.name, style: tt.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  Text(student.phone ?? student.email ?? 'No contact info', style: tt.bodySmall),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppColors.success.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          student.planStatus,
                          style: tt.labelSmall?.copyWith(color: AppColors.success, fontWeight: FontWeight.bold, fontSize: 10),
                        ),
                      ),
                      if (latestScore != null) ...[
                        const SizedBox(width: 8),
                        Text(
                          'Latest Score: ${latestScore!.toStringAsFixed(1)}',
                          style: tt.labelMedium?.copyWith(
                            color: AppColors.accentGold,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── No Scores Card ───────────────────────────────────────────────────────────

class _NoScoresCard extends StatelessWidget {
  const _NoScoresCard({required this.studentName});
  final String studentName;

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 36),
        child: Column(
          children: [
            Icon(Icons.assessment_outlined, size: 48, color: Colors.grey.withValues(alpha: 0.5)),
            const SizedBox(height: 16),
            Text('No scores recorded yet', style: tt.titleMedium),
            const SizedBox(height: 8),
            Text(
              'No transformation scores have been evaluated for $studentName yet. Tap "Record Score" below to log the first weekly score.',
              style: tt.bodySmall,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

// ── Radar Chart Section ──────────────────────────────────────────────────────

class _RadarChartSection extends StatelessWidget {
  const _RadarChartSection({required this.latest, required this.isDark});
  final TransformationScore latest;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Transformation Balance', style: tt.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            SizedBox(
              height: 200,
              child: RadarChart(
                RadarChartData(
                  dataSets: [
                    RadarDataSet(
                      dataEntries: [
                        RadarEntry(value: latest.consistency),
                        RadarEntry(value: latest.intensity),
                        RadarEntry(value: latest.mindfulness),
                        RadarEntry(value: latest.recovery),
                      ],
                      borderColor: AppColors.accentViolet,
                      fillColor: AppColors.accentViolet.withValues(alpha: 0.2),
                      borderWidth: 2,
                      entryRadius: 3,
                    ),
                  ],
                  radarShape: RadarShape.circle,
                  gridBorderData: BorderSide(
                    color: isDark ? AppColors.borderDark : AppColors.borderLight,
                  ),
                  tickBorderData: BorderSide(
                    color: isDark ? AppColors.borderLightDark : AppColors.borderLightAlt,
                    width: 0.5,
                  ),
                  tickCount: 5,
                  ticksTextStyle: TextStyle(
                    color: isDark ? AppColors.textMutedDark : AppColors.textMutedLight,
                    fontSize: 8,
                  ),
                  getTitle: (index, angle) {
                    final label = switch (index) {
                      0 => 'Consistency',
                      1 => 'Intensity',
                      2 => 'Mindfulness',
                      3 => 'Recovery',
                      _ => '',
                    };
                    return RadarChartTitle(text: label, angle: angle);
                  },
                  titlePositionPercentageOffset: 0.15,
                  titleTextStyle: tt.bodySmall?.copyWith(
                    fontWeight: FontWeight.w600,
                    fontSize: 10,
                    color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Trend Chart Section ──────────────────────────────────────────────────────

class _TrendChartSection extends StatelessWidget {
  const _TrendChartSection({required this.scores, required this.isDark});
  final List<TransformationScore> scores;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Journey Progress Trend', style: tt.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            SizedBox(
              height: 140,
              child: LineChart(
                LineChartData(
                  maxY: 10,
                  minY: 0,
                  titlesData: FlTitlesData(
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, _) {
                          final idx = value.toInt();
                          if (idx < 0 || idx >= scores.length) {
                            return const SizedBox.shrink();
                          }
                          final date = scores[idx].weekStartDate;
                          return Padding(
                            padding: const EdgeInsets.only(top: 4),
                            child: Text(
                              DateFormat('d/M').format(date),
                              style: TextStyle(
                                fontSize: 9,
                                color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 20,
                        getTitlesWidget: (value, meta) {
                          if (value == 0 || value == 10 || value % 2 == 0) {
                            return Text(
                              '${value.toInt()}',
                              style: TextStyle(
                                fontSize: 9,
                                color: isDark ? AppColors.textMutedDark : AppColors.textMutedLight,
                              ),
                            );
                          }
                          return const SizedBox.shrink();
                        },
                      ),
                    ),
                    topTitles: const AxisTitles(),
                    rightTitles: const AxisTitles(),
                  ),
                  borderData: FlBorderData(show: false),
                  gridData: FlGridData(
                    drawVerticalLine: false,
                    getDrawingHorizontalLine: (_) => FlLine(
                      color: isDark
                          ? AppColors.borderLightDark.withValues(alpha: 0.5)
                          : AppColors.borderLightAlt.withValues(alpha: 0.5),
                      strokeWidth: 1,
                    ),
                  ),
                  lineBarsData: [
                    LineChartBarData(
                      spots: List.generate(
                        scores.length,
                        (i) => FlSpot(i.toDouble(), scores[i].score),
                      ),
                      isCurved: true,
                      color: AppColors.accentViolet,
                      barWidth: 2.5,
                      dotData: FlDotData(
                        getDotPainter: (_, _, _, _) => FlDotCirclePainter(
                          radius: 3.5,
                          color: AppColors.accentGold,
                          strokeWidth: 2,
                          strokeColor: isDark ? AppColors.bgDark : AppColors.bgLight,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Scores Table Section ─────────────────────────────────────────────────────

class _ScoresTableSection extends StatelessWidget {
  const _ScoresTableSection({required this.scores, required this.studentId, required this.isDark});
  final List<TransformationScore> scores;
  final String studentId;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Historical Scores', style: tt.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: scores.length,
              separatorBuilder: (_, _) => const Divider(height: 1),
              itemBuilder: (ctx, i) {
                final s = scores[scores.length - 1 - i]; // Reverse order
                return ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(
                    'Week of ${DateFormat('MMM d, yyyy').format(s.weekStartDate)}',
                    style: tt.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
                  ),
                  subtitle: Text(
                    'C:${s.consistency.toStringAsFixed(1)} | I:${s.intensity.toStringAsFixed(1)} | M:${s.mindfulness.toStringAsFixed(1)} | R:${s.recovery.toStringAsFixed(1)}',
                    style: tt.bodySmall,
                  ),
                  trailing: Text(
                    s.score.toStringAsFixed(1),
                    style: tt.titleMedium?.copyWith(
                      color: AppColors.accentViolet,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

// ── Record Score Sheet ───────────────────────────────────────────────────────

class _RecordScoreSheet extends ConsumerStatefulWidget {
  const _RecordScoreSheet({required this.studentId, this.history});
  final String studentId;
  final List<TransformationScore>? history;

  @override
  ConsumerState<_RecordScoreSheet> createState() => _RecordScoreSheetState();
}

class _RecordScoreSheetState extends ConsumerState<_RecordScoreSheet> {
  double _consistency = 7.0;
  double _intensity = 7.0;
  double _mindfulness = 7.0;
  double _recovery = 7.0;
  DateTime _weekStartDate = DateTime.now().subtract(Duration(days: DateTime.now().weekday - 1)); // Most recent Monday

  @override
  void initState() {
    super.initState();
    // Default values from latest history record if available
    if (widget.history != null && widget.history!.isNotEmpty) {
      final latest = widget.history!.last;
      _consistency = latest.consistency;
      _intensity = latest.intensity;
      _mindfulness = latest.mindfulness;
      _recovery = latest.recovery;
    }
  }

  double get _computedScore => (_consistency + _intensity + _mindfulness + _recovery) / 4.0;

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _weekStartDate,
      firstDate: DateTime(2025),
      lastDate: DateTime.now().add(const Duration(days: 7)),
    );
    if (picked != null) {
      // Snap to Monday of the picked week
      setState(() {
        _weekStartDate = picked.subtract(Duration(days: picked.weekday - 1));
      });
    }
  }

  Future<void> _save() async {
    final currentUserId = ref.read(currentUserIdProvider);
    final score = TransformationScore(
      id: '',
      studentId: widget.studentId,
      recordedBy: currentUserId,
      consistency: _consistency,
      intensity: _intensity,
      mindfulness: _mindfulness,
      recovery: _recovery,
      score: _computedScore,
      weekStartDate: _weekStartDate,
    );

    try {
      await ref.read(recordScoreNotifierProvider.notifier).saveScore(score);
      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Weekly score recorded successfully.')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error recording score: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    final recordState = ref.watch(recordScoreNotifierProvider);
    final saving = recordState.isLoading;

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: SingleChildScrollView(
        child: Container(
          padding: const EdgeInsets.fromLTRB(24, 24, 24, 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Record Weekly Score', style: tt.headlineSmall),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              // Date Row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Week Commencing (Monday)', style: tt.bodySmall),
                      Text(
                        DateFormat('EEEE, MMMM d, yyyy').format(_weekStartDate),
                        style: tt.bodyMedium?.copyWith(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  TextButton.icon(
                    onPressed: _selectDate,
                    icon: const Icon(Icons.calendar_month),
                    label: const Text('Change'),
                  ),
                ],
              ),
              const Divider(height: 24),
              // Sliders
              _SliderInput(
                title: 'Consistency',
                value: _consistency,
                color: AppColors.accentGold,
                onChanged: (val) => setState(() => _consistency = val),
              ),
              const SizedBox(height: 12),
              _SliderInput(
                title: 'Intensity',
                value: _intensity,
                color: AppColors.accentViolet,
                onChanged: (val) => setState(() => _intensity = val),
              ),
              const SizedBox(height: 12),
              _SliderInput(
                title: 'Mindfulness',
                value: _mindfulness,
                color: AppColors.success,
                onChanged: (val) => setState(() => _mindfulness = val),
              ),
              const SizedBox(height: 12),
              _SliderInput(
                title: 'Recovery',
                value: _recovery,
                color: Colors.lightBlue,
                onChanged: (val) => setState(() => _recovery = val),
              ),
              const Divider(height: 32),
              // Computed Overall Score
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Computed Overall Score:', style: tt.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                  Text(
                    '${_computedScore.toStringAsFixed(2)} / 10.0',
                    style: tt.titleLarge?.copyWith(
                      color: AppColors.accentViolet,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: saving ? null : _save,
                  child: saving
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                        )
                      : const Text('Save Weekly Score'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SliderInput extends StatelessWidget {
  const _SliderInput({
    required this.title,
    required this.value,
    required this.color,
    required this.onChanged,
  });

  final String title;
  final double value;
  final Color color;
  final ValueChanged<double> onChanged;

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(title, style: tt.bodyMedium?.copyWith(fontWeight: FontWeight.bold)),
            Text(
              '${value.toStringAsFixed(1)} / 10.0',
              style: tt.bodyMedium?.copyWith(color: color, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            activeTrackColor: color,
            inactiveTrackColor: color.withValues(alpha: 0.15),
            thumbColor: color,
            overlayColor: color.withValues(alpha: 0.2),
            valueIndicatorColor: color,
          ),
          child: Slider(
            value: value,
            max: 10.0,
            divisions: 20,
            label: value.toStringAsFixed(1),
            onChanged: onChanged,
          ),
        ),
      ],
    );
  }
}
