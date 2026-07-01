import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_theme.dart';
import '../../../shared/widgets/loading_widget.dart';
import '../domain/home_data.dart';
import 'home_provider.dart';
import 'weather_provider.dart';
import 'widgets/weather_widget.dart';

class StudentHomeScreen extends ConsumerWidget {
  const StudentHomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(homeDataProvider);
    return async.when(
      loading: () => const Center(child: ChakraLoader()),
      error: (e, _) => Center(child: Text('Error: $e')),
      data: (data) => _HomeBody(data: data, ref: ref),
    );
  }
}

class _HomeBody extends StatelessWidget {
  const _HomeBody({required this.data, required this.ref});
  final HomeData data;
  final WidgetRef ref;

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () => Future.wait([
        ref.refresh(homeDataProvider.future),
        ref.read(weatherNotifierProvider.notifier).fetchWeather(force: true),
      ]),
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 20, 16, 24),
        children: [
          _GreetingCard(data: data),
          const SizedBox(height: 16),
          if (data.upcomingClasses.isNotEmpty) ...[
            _NextClassBanner(cls: data.upcomingClasses.first),
            const SizedBox(height: 16),
          ],
          _StreakCard(streak: data.streak),
          const SizedBox(height: 16),
          const _QuoteCard(),
          const SizedBox(height: 16),
          const WeatherWidget(),
          const SizedBox(height: 24),
          if (data.upcomingClasses.length > 1) ...[
            const _SectionHeader(title: 'Other Upcoming Classes'),
            const SizedBox(height: 12),
            ...data.upcomingClasses.skip(1).map((c) => _ClassCard(cls: c)),
            const SizedBox(height: 24),
          ] else if (data.upcomingClasses.length == 1) ...[
            const _SectionHeader(title: 'Upcoming Classes'),
            const SizedBox(height: 12),
            _ClassCard(cls: data.upcomingClasses.first),
            const SizedBox(height: 24),
          ],
          if (data.recentActivity.isNotEmpty) ...[
            const _SectionHeader(title: 'Recent Activity'),
            const SizedBox(height: 12),
            _ActivityList(items: data.recentActivity),
          ],
          if (data.upcomingClasses.isEmpty && data.recentActivity.isEmpty)
            _EmptyState(),
        ],
      ),
    );
  }
}

class _GreetingCard extends StatelessWidget {
  const _GreetingCard({required this.data});
  final HomeData data;

  String get _greeting {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good morning';
    if (hour < 17) return 'Good afternoon';
    return 'Good evening';
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
              ? [
                  AppColors.accentViolet.withValues(alpha: 0.25),
                  AppColors.surfaceDark,
                ]
              : [
                  AppColors.accentGold.withValues(alpha: 0.15),
                  AppColors.surfaceLight,
                ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? AppColors.borderDark : AppColors.borderLight,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$_greeting,',
            style: tt.bodyMedium?.copyWith(
              color: isDark
                  ? AppColors.textSecondaryDark
                  : AppColors.textSecondaryLight,
            ),
          ),
          const SizedBox(height: 4),
          Text(data.firstName, style: tt.headlineMedium),
          const SizedBox(height: 4),
          Text(
            'Stay consistent, stay transformed.',
            style: tt.bodySmall?.copyWith(
              color: isDark
                  ? AppColors.textSecondaryDark
                  : AppColors.textSecondaryLight,
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }
}

class _NextClassBanner extends StatelessWidget {
  const _NextClassBanner({required this.cls});
  final UpcomingClass cls;

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.accentViolet.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.accentViolet.withValues(alpha: 0.35),
          width: 1.5,
        ),
      ),
      child: Row(
        children: [
          MediaQuery.of(context).disableAnimations
              ? Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.accentViolet.withValues(alpha: 0.2),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.notifications_active_outlined,
                    color: AppColors.accentViolet,
                    size: 20,
                  ),
                )
              : Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.accentViolet.withValues(alpha: 0.2),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.notifications_active_outlined,
                        color: AppColors.accentViolet,
                        size: 20,
                      ),
                    )
                    .animate(
                      onPlay: (controller) => controller.repeat(reverse: true),
                    )
                    .scaleXY(
                      begin: 0.9,
                      end: 1.1,
                      duration: 1200.ms,
                      curve: Curves.easeInOut,
                    ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Next Class: ${cls.dayLabel} at ${cls.scheduleTime}',
                  style: tt.labelMedium?.copyWith(
                    color: AppColors.accentViolet,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  cls.batchName,
                  style: tt.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
                ),
                if (cls.trainerName != null)
                  Text(
                    'with ${cls.trainerName}',
                    style: tt.bodySmall?.copyWith(fontSize: 11),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _StreakCard extends StatelessWidget {
  const _StreakCard({required this.streak});
  final int streak;

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: streak > 0
              ? AppColors.accentGold.withValues(alpha: 0.5)
              : (isDark ? AppColors.borderDark : AppColors.borderLight),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: AppColors.accentGold.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: MediaQuery.of(context).disableAnimations
                  ? const Text('🔥', style: TextStyle(fontSize: 26))
                  : const Text('🔥', style: TextStyle(fontSize: 26))
                        .animate(
                          onPlay: (controller) =>
                              controller.repeat(reverse: true),
                        )
                        .scaleXY(
                          begin: 0.85,
                          end: 1.15,
                          duration: 1000.ms,
                          curve: Curves.easeInOut,
                        ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  streak == 0
                      ? 'No streak yet'
                      : '$streak day${streak == 1 ? '' : 's'} in a row!',
                  style: tt.titleMedium?.copyWith(
                    color: streak > 0 ? AppColors.accentGold : null,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  streak == 0
                      ? 'Show up today to start your streak.'
                      : 'Keep the momentum going.',
                  style: tt.bodySmall?.copyWith(
                    color: isDark
                        ? AppColors.textSecondaryDark
                        : AppColors.textSecondaryLight,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _QuoteCard extends StatelessWidget {
  const _QuoteCard();

  String getQuoteOfTheDay() {
    final quotes = [
      "The body benefits from movement, and the mind benefits from stillness.",
      "Yoga is the journey of the self, through the self, to the self.",
      "Health is wealth, peace of mind is happiness, yoga shows the way.",
      "Consistency is the key to transformation. Show up for yourself today.",
      "Awaken your inner vision. Breathe in energy, breathe out stress.",
      "Your practice is a mirror. What you do on the mat reflects who you are off the mat.",
      "Transform body, mind, and soul. Every small step counts on the path.",
    ];
    final dayIndex = DateTime.now().weekday - 1; // 0 to 6
    return quotes[dayIndex % quotes.length];
  }

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? AppColors.borderDark : AppColors.borderLight,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text('✨', style: TextStyle(fontSize: 16)),
              const SizedBox(width: 8),
              Text(
                'Mindfulness Quote',
                style: tt.labelSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5,
                  color: isDark
                      ? AppColors.textSecondaryDark
                      : AppColors.textSecondaryLight,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            getQuoteOfTheDay(),
            style: tt.bodyMedium?.copyWith(
              fontStyle: FontStyle.italic,
              height: 1.4,
              color: isDark ? AppColors.textDark : AppColors.textLight,
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title});
  final String title;

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Text(
      title,
      style: tt.titleSmall?.copyWith(
        color: isDark
            ? AppColors.textSecondaryDark
            : AppColors.textSecondaryLight,
        letterSpacing: 0.5,
        fontWeight: FontWeight.w600,
      ),
    );
  }
}

class _ClassCard extends StatelessWidget {
  const _ClassCard({required this.cls});
  final UpcomingClass cls;

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isToday = cls.dayLabel == 'Today';
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isToday
              ? AppColors.accentViolet.withValues(alpha: 0.5)
              : (isDark ? AppColors.borderDark : AppColors.borderLight),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: AppColors.accentViolet.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(
              Icons.self_improvement,
              color: AppColors.accentViolet,
              size: 22,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  cls.batchName,
                  style: tt.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
                ),
                if (cls.trainerName != null)
                  Text(
                    cls.trainerName!,
                    style: tt.bodySmall?.copyWith(
                      color: isDark
                          ? AppColors.textSecondaryDark
                          : AppColors.textSecondaryLight,
                    ),
                  ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                cls.dayLabel,
                style: tt.labelSmall?.copyWith(
                  color: isToday ? AppColors.accentViolet : null,
                  fontWeight: isToday ? FontWeight.bold : FontWeight.w500,
                ),
              ),
              Text(
                cls.scheduleTime,
                style: tt.labelMedium?.copyWith(fontWeight: FontWeight.w600),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ActivityList extends StatelessWidget {
  const _ActivityList({required this.items});
  final List<ActivityItem> items;

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark ? AppColors.borderDark : AppColors.borderLight,
        ),
      ),
      child: Column(
        children: [
          for (int i = 0; i < items.length; i++) ...[
            if (i > 0)
              Divider(
                height: 1,
                color: isDark ? AppColors.borderDark : AppColors.borderLight,
                indent: 16,
                endIndent: 16,
              ),
            _ActivityRow(item: items[i], tt: tt, isDark: isDark),
          ],
        ],
      ),
    );
  }
}

class _ActivityRow extends StatelessWidget {
  const _ActivityRow({
    required this.item,
    required this.tt,
    required this.isDark,
  });
  final ActivityItem item;
  final TextTheme tt;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Text(item.icon, style: const TextStyle(fontSize: 18)),
          const SizedBox(width: 12),
          Expanded(child: Text(item.label, style: tt.bodyMedium)),
          Text(
            item.dateLabel,
            style: tt.labelSmall?.copyWith(
              color: isDark
                  ? AppColors.textSecondaryDark
                  : AppColors.textSecondaryLight,
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 48),
      child: Column(
        children: [
          Icon(
            Icons.self_improvement,
            size: 64,
            color: AppColors.accentViolet.withValues(alpha: 0.3),
          ),
          const SizedBox(height: 16),
          Text('Your journey starts here', style: tt.titleMedium),
          const SizedBox(height: 8),
          Text(
            'Check in to a class to begin your transformation.',
            style: tt.bodyMedium?.copyWith(color: AppColors.textSecondaryDark),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
