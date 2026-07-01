import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../shared/widgets/shimmer_loading.dart';
import '../../domain/weather_model.dart';
import '../weather_provider.dart';

class WeatherWidget extends ConsumerWidget {
  const WeatherWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final weatherState = ref.watch(weatherNotifierProvider);
    final tt = Theme.of(context).textTheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return weatherState.when(
      loading: () => const ShimmerCard(),
      error: (error, _) {
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
            children: [
              const Icon(
                Icons.cloud_off,
                color: Colors.grey,
                size: 32,
              ),
              const SizedBox(height: 12),
              Text(
                'Weather service offline',
                style: tt.titleSmall?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 6),
              Text(
                error.toString().replaceAll('WeatherException: ', ''),
                style: tt.bodySmall?.copyWith(
                  color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              ElevatedButton.icon(
                onPressed: () => ref
                    .read(weatherNotifierProvider.notifier)
                    .fetchWeather(force: true),
                icon: const Icon(Icons.refresh, size: 16),
                label: const Text('Retry'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.accentGold,
                  foregroundColor: Colors.black,
                  textStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
              ),
            ],
          ),
        );
      },
      data: (data) {
        final aqiColor = data.aqi <= 50
            ? Colors.green
            : data.aqi <= 100
                ? AppColors.accentGold
                : Colors.redAccent;

        final isOffline = weatherState.hasError;

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
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Text(
                        WeatherData.mapWmoIcon(data.conditionCode),
                        style: const TextStyle(fontSize: 18),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Studio Environment',
                        style: tt.labelSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.5,
                          color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      Text(
                        isOffline ? 'Offline' : 'Updated ${data.lastUpdated}',
                        style: tt.bodySmall?.copyWith(
                          fontSize: 10,
                          color: isDark ? AppColors.textSecondaryDark.withValues(alpha: 0.7) : AppColors.textSecondaryLight.withValues(alpha: 0.7),
                        ),
                      ),
                      const SizedBox(width: 6),
                      IconButton(
                        constraints: const BoxConstraints(),
                        padding: EdgeInsets.zero,
                        icon: const Icon(Icons.refresh, size: 14),
                        onPressed: () => ref
                            .read(weatherNotifierProvider.notifier)
                            .fetchWeather(force: true),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  Text(
                    '${data.temp.round()}°C',
                    style: tt.headlineMedium?.copyWith(
                      fontWeight: FontWeight.w300,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    data.conditionText,
                    style: tt.bodyMedium?.copyWith(
                      color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.accentGold.withValues(alpha: 0.05),
                  border: const Border(
                    left: BorderSide(
                      color: AppColors.accentGold,
                      width: 3,
                    ),
                  ),
                ),
                child: Text(
                  data.recommendation,
                  style: tt.bodyMedium?.copyWith(
                    fontStyle: FontStyle.italic,
                    height: 1.4,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              const Divider(height: 1),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _MetricItem(
                    label: 'Air Quality (AQI)',
                    value: '${data.aqi}',
                    valueColor: aqiColor,
                    tt: tt,
                  ),
                  _MetricItem(
                    label: 'Humidity',
                    value: '${data.humidity}%',
                    tt: tt,
                  ),
                  _MetricItem(
                    label: 'Wind',
                    value: '${data.windSpeed.round()} km/h',
                    tt: tt,
                  ),
                  _MetricItem(
                    label: 'UV Index',
                    value: '${data.uvIndex.round()}',
                    tt: tt,
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}

class _MetricItem extends StatelessWidget {
  final String label;
  final String value;
  final Color? valueColor;
  final TextTheme tt;

  const _MetricItem({
    required this.label,
    required this.value,
    this.valueColor,
    required this.tt,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Column(
      children: [
        Text(
          value,
          style: tt.bodyMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: valueColor ?? (isDark ? AppColors.textDark : AppColors.textLight),
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: tt.bodySmall?.copyWith(
            fontSize: 9,
            color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
          ),
        ),
      ],
    );
  }
}
