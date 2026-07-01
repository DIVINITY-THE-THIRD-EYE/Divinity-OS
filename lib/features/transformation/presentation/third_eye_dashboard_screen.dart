import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../core/theme/app_theme.dart';
import '../../../shared/widgets/loading_widget.dart' show ChakraLoader;
import '../../../shared/widgets/spring_tap.dart';
import '../domain/transformation_score.dart';
import 'transformation_provider.dart';

class ThirdEyeDashboardScreen extends ConsumerWidget {
  const ThirdEyeDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scoresAsync = ref.watch(studentScoresProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: RefreshIndicator(
        onRefresh: () => ref.refresh(studentScoresProvider.future),
        child: scoresAsync.when(
          loading: () => const Center(child: ChakraLoader()),
          error: (e, _) => Center(child: Text('Error loading scores: $e')),
          data: (scores) {
            if (scores.isEmpty) {
              return _EmptyTransformationState();
            }

            final latest = scores.last;

            return ListView(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
              children: [
                _HeaderCard(score: latest.score),
                const SizedBox(height: 16),
                _AiCoachEntrypointCard(score: latest),
                const SizedBox(height: 16),
                _RadarChartCard(
                  consistency: latest.consistency,
                  intensity: latest.intensity,
                  mindfulness: latest.mindfulness,
                  recovery: latest.recovery,
                  isDark: isDark,
                ),
                const SizedBox(height: 16),
                if (scores.length >= 2) ...[
                  _TrendChartCard(scores: scores, isDark: isDark),
                  const SizedBox(height: 16),
                ],
                _MetricsBreakdownCard(
                  consistency: latest.consistency,
                  intensity: latest.intensity,
                  mindfulness: latest.mindfulness,
                  recovery: latest.recovery,
                  isDark: isDark,
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

// ── Header Card ──────────────────────────────────────────────────────────────

class _HeaderCard extends StatelessWidget {
  const _HeaderCard({required this.score});
  final double score;

  String get _badgeText {
    if (score >= 9.0) return 'Ascended';
    if (score >= 7.5) return 'Aligned';
    if (score >= 5.0) return 'Awakened';
    return 'Seeker';
  }

  Color get _badgeColor {
    if (score >= 7.5) return AppColors.accentGold;
    return AppColors.accentViolet;
  }

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isDark
              ? [AppColors.accentViolet.withValues(alpha: 0.25), AppColors.surfaceDark]
              : [AppColors.accentGold.withValues(alpha: 0.15), AppColors.surfaceLight],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? AppColors.borderDark : AppColors.borderLight,
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Third Eye Score',
                  style: tt.bodySmall?.copyWith(
                    color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Text(
                      score.toStringAsFixed(1),
                      style: tt.displaySmall?.copyWith(
                        fontWeight: FontWeight.w900,
                        color: isDark ? AppColors.textDark : AppColors.textLight,
                      ),
                    ),
                    Text(
                      ' / 10',
                      style: tt.titleLarge?.copyWith(
                        color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: _badgeColor.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: _badgeColor.withValues(alpha: 0.3)),
                  ),
                  child: Text(
                    _badgeText,
                    style: tt.labelSmall?.copyWith(color: _badgeColor, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ),
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: isDark ? AppColors.bgDark.withValues(alpha: 0.5) : AppColors.bgLight,
              shape: BoxShape.circle,
              border: Border.all(color: _badgeColor.withValues(alpha: 0.4), width: 1.5),
            ),
            child: Center(
              child: Text(
                '👁',
                style: TextStyle(
                  fontSize: 36,
                  shadows: [
                    Shadow(
                      color: _badgeColor.withValues(alpha: 0.6),
                      blurRadius: 8,
                    )
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Radar Chart Card ─────────────────────────────────────────────────────────

class _RadarChartCard extends StatelessWidget {
  const _RadarChartCard({
    required this.consistency,
    required this.intensity,
    required this.mindfulness,
    required this.recovery,
    required this.isDark,
  });

  final double consistency;
  final double intensity;
  final double mindfulness;
  final double recovery;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Transformation Balance', style: tt.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Text(
              'Weekly wellness dimensions balance',
              style: tt.bodySmall?.copyWith(color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight),
            ),
            const SizedBox(height: 24),
            SizedBox(
              height: 220,
              child: RadarChart(
                RadarChartData(
                  dataSets: [
                    RadarDataSet(
                      dataEntries: [
                        RadarEntry(value: consistency),
                        RadarEntry(value: intensity),
                        RadarEntry(value: mindfulness),
                        RadarEntry(value: recovery),
                      ],
                      borderColor: AppColors.accentViolet,
                      fillColor: AppColors.accentViolet.withValues(alpha: 0.2),
                      borderWidth: 2,
                      entryRadius: 4,
                    ),
                  ],
                  radarBackgroundColor: Colors.transparent,
                  radarBorderData: const BorderSide(color: Colors.transparent),
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
                    return RadarChartTitle(
                      text: label,
                      angle: angle,
                    );
                  },
                  titlePositionPercentageOffset: 0.15,
                  titleTextStyle: tt.bodySmall?.copyWith(
                    fontWeight: FontWeight.w600,
                    fontSize: 11,
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

// ── Trend Chart Card ─────────────────────────────────────────────────────────

class _TrendChartCard extends StatelessWidget {
  const _TrendChartCard({required this.scores, required this.isDark});
  final List<TransformationScore> scores;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;

    // Show at most 8 latest scores for trend readability
    final trendScores = scores.length > 8 ? scores.sublist(scores.length - 8) : scores;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Journey Progress', style: tt.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Text(
              'Weekly overall score trend line',
              style: tt.bodySmall?.copyWith(color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight),
            ),
            const SizedBox(height: 24),
            SizedBox(
              height: 150,
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
                          if (idx < 0 || idx >= trendScores.length) {
                            return const SizedBox.shrink();
                          }
                          final date = trendScores[idx].weekStartDate;
                          return Padding(
                            padding: const EdgeInsets.only(top: 6),
                            child: Text(
                              DateFormat('d MMM').format(date),
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
                        reservedSize: 24,
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
                        trendScores.length,
                        (i) => FlSpot(i.toDouble(), trendScores[i].score),
                      ),
                      isCurved: true,
                      color: AppColors.accentViolet,
                      barWidth: 3,
                      isStrokeCapRound: true,
                      dotData: FlDotData(
                        getDotPainter: (_, _, _, _) => FlDotCirclePainter(
                          radius: 4.5,
                          color: AppColors.accentGold,
                          strokeWidth: 2.5,
                          strokeColor: cs.surface,
                        ),
                      ),
                      belowBarData: BarAreaData(
                        show: true,
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            AppColors.accentViolet.withValues(alpha: 0.25),
                            AppColors.accentViolet.withValues(alpha: 0.0),
                          ],
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

// ── Metrics Breakdown Card ───────────────────────────────────────────────────

class _MetricsBreakdownCard extends StatelessWidget {
  const _MetricsBreakdownCard({
    required this.consistency,
    required this.intensity,
    required this.mindfulness,
    required this.recovery,
    required this.isDark,
  });

  final double consistency;
  final double intensity;
  final double mindfulness;
  final double recovery;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Dimension Breakdown', style: tt.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            _MetricRow(
              title: 'Consistency',
              value: consistency,
              description: 'Regularity in showing up and executing practices.',
              icon: '🔥',
              color: AppColors.accentGold,
            ),
            const Divider(height: 24),
            _MetricRow(
              title: 'Intensity',
              value: intensity,
              description: 'Focus, physical output, and power during classes.',
              icon: '⚡',
              color: AppColors.accentViolet,
            ),
            const Divider(height: 24),
            _MetricRow(
              title: 'Mindfulness',
              value: mindfulness,
              description: 'Breath control, stillness, mental awareness, and attention.',
              icon: '🧘',
              color: AppColors.success,
            ),
            const Divider(height: 24),
            _MetricRow(
              title: 'Recovery',
              value: recovery,
              description: 'Rest quality, therapeutic response, flexibility & stress relief.',
              icon: '🏖',
              color: Colors.lightBlue,
            ),
          ],
        ),
      ),
    );
  }
}

class _MetricRow extends StatelessWidget {
  const _MetricRow({
    required this.title,
    required this.value,
    required this.description,
    required this.icon,
    required this.color,
  });

  final String title;
  final double value;
  final String description;
  final String icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Center(
            child: Text(icon, style: const TextStyle(fontSize: 20)),
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(title, style: tt.bodyMedium?.copyWith(fontWeight: FontWeight.bold)),
                  Text(
                    '${value.toStringAsFixed(1)} / 10',
                    style: tt.bodyMedium?.copyWith(fontWeight: FontWeight.w600, color: color),
                  ),
                ],
              ),
              const SizedBox(height: 2),
              Text(
                description,
                style: tt.bodySmall?.copyWith(fontSize: 11),
              ),
              const SizedBox(height: 6),
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: value / 10.0,
                  backgroundColor: color.withValues(alpha: 0.15),
                  valueColor: AlwaysStoppedAnimation<Color>(color),
                  minHeight: 5,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ── Empty Transformation State ───────────────────────────────────────────────

class _EmptyTransformationState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 90,
              height: 90,
              decoration: BoxDecoration(
                color: AppColors.accentViolet.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Icon(
                  Icons.self_improvement_outlined,
                  size: 48,
                  color: AppColors.accentViolet.withValues(alpha: 0.6),
                ),
              ),
            ),
            const SizedBox(height: 24),
            Text('The Third Eye Journey', style: tt.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            Text(
              'Your weekly transformation scores will be displayed here once your trainer records your first evaluation.',
              style: tt.bodyMedium?.copyWith(
                color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            Text(
              'Focus on your consistency, intensity, mindfulness, and recovery to prepare for your assessment.',
              style: tt.bodySmall?.copyWith(
                fontStyle: FontStyle.italic,
                color: isDark ? AppColors.textMutedDark : AppColors.textMutedLight,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

// ── AI Wellness Coach Card ───────────────────────────────────────────────────

class _AiCoachEntrypointCard extends StatelessWidget {
  const _AiCoachEntrypointCard({required this.score});
  final TransformationScore score;

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return SpringTap(
      semanticsLabel: 'Consult AI Wellness Coach',
      onTap: () {
        showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          backgroundColor: Colors.transparent,
          builder: (context) => _AiWellnessCoachBottomSheet(score: score),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: isDark
                ? [AppColors.accentGold.withValues(alpha: 0.25), AppColors.accentViolet.withValues(alpha: 0.15)]
                : [AppColors.accentViolet.withValues(alpha: 0.15), AppColors.accentGold.withValues(alpha: 0.25)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isDark ? AppColors.borderDark : AppColors.borderLight,
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'AI WELLNESS COACH',
                    style: tt.labelSmall?.copyWith(
                      color: AppColors.accentGold,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.0,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Get Coach Insights',
                    style: tt.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: isDark ? AppColors.textDark : AppColors.textLight,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Receive calm, actionable advice to balance your practice based on your current score.',
                    style: tt.bodySmall?.copyWith(
                      color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: isDark ? AppColors.bgDark.withValues(alpha: 0.5) : AppColors.bgLight,
                shape: BoxShape.circle,
                border: Border.all(
                  color: AppColors.accentGold.withValues(alpha: 0.4),
                  width: 1.5,
                ),
              ),
              child: const Center(
                child: Text(
                  '✨',
                  style: TextStyle(fontSize: 24),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── AI Wellness Coach Bottom Sheet ───────────────────────────────────────────

class _AiWellnessCoachBottomSheet extends ConsumerWidget {
  const _AiWellnessCoachBottomSheet({required this.score});
  final TransformationScore score;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final insightAsync = ref.watch(aiWellnessInsightProvider(score));
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final tt = Theme.of(context).textTheme;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.bgDark : AppColors.bgLight,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        border: Border(
          top: BorderSide(
            color: isDark ? AppColors.borderDark : AppColors.borderLight,
            width: 1.5,
          ),
        ),
      ),
      padding: EdgeInsets.only(
        top: 16,
        left: 20,
        right: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Drag handle
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: isDark ? AppColors.borderDark : AppColors.borderLight,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 16),
          // Title row
          Row(
            children: [
              Text(
                '👁 AI Wellness Insight',
                style: tt.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: isDark ? AppColors.textDark : AppColors.textLight,
                ),
              ),
              const Spacer(),
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
          const Divider(height: 24),
          // Content
          ConstrainedBox(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.5,
            ),
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: insightAsync.when(
                loading: () => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 40),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const ChakraLoader(size: 56),
                      const SizedBox(height: 20),
                      Text(
                        'Divinity is reading your energy...',
                        style: tt.bodyMedium?.copyWith(
                          color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ],
                  ),
                ),
                error: (error, stack) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 40),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.error_outline, size: 48, color: AppColors.error),
                      const SizedBox(height: 16),
                      Text(
                        'Unable to connect to the AI Coach.',
                        style: tt.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: isDark ? AppColors.textDark : AppColors.textLight,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Please verify your network connection or ensure your coach integration credentials are valid.',
                        textAlign: TextAlign.center,
                        style: tt.bodyMedium?.copyWith(
                          color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                        ),
                      ),
                    ],
                  ),
                ),
                data: (insight) => Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: Text(
                    insight,
                    style: tt.bodyMedium?.copyWith(
                      height: 1.5,
                      color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                    ),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          // Action button
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.accentViolet,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text('Acknowledge & Balance'),
          ),
        ],
      ),
    );
  }
}
