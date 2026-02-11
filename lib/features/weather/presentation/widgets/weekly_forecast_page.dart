import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:weather_icons/weather_icons.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/utils/moon_phase.dart';
import '../../../../core/utils/weather_icon_mapper.dart';
import '../../domain/entities/daily_weather.dart';

class WeeklyForecastPage extends StatelessWidget {
  final List<DailyWeather> daily;

  const WeeklyForecastPage({super.key, required this.daily});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
        child: Column(
          children: [
            // Header row — aligned with top icon bar
            Padding(
              padding: const EdgeInsets.only(right: 44),
              child: SizedBox(
                height: 62,
                child: Align(
                  alignment: Alignment.centerRight,
                  child: Text(
                    '7-Day Forecast',
                    style: GoogleFonts.quicksand(
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      color: AppColors.cream,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
            ...daily.map(
              (row) => Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Row(
                    children: [Expanded(child: _DailyCard(daily: row))],
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

class _DailyCard extends StatelessWidget {
  final DailyWeather daily;

  const _DailyCard({required this.daily});

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final dayDiff = daily.date.difference(today).inDays;
    final dayStr = switch (dayDiff) {
      0 => 'Today',
      1 => 'Tmrw',
      _ => DateFormat('EEE').format(daily.date),
    };

    return Container(
      clipBehavior: Clip.hardEdge,
      decoration: BoxDecoration(
        color: AppColors.cream.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Stack(
        children: [
          // Large faded icon
          Positioned(
            right: 0,
            top: 0,
            child: Icon(
              conditionIcon(daily.weatherCode),
              color: AppColors.cream.withValues(alpha: 0.7),
              size: 80,
            ),
          ),
          // Content on top
          Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Flex(
                  direction: Axis.horizontal,
                  children: [
                    Text(
                      dayStr,
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Icon(
                      moonPhaseIcon(daily.date),
                      size: 20,
                      color: AppColors.cream.withValues(alpha: 0.8),
                    ),
                  ],
                ),
                Flex(
                  direction: Axis.horizontal,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '${daily.temperatureMax.round()}° / ${daily.temperatureMin.round()}°',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.w800,
                        fontSize: 26,
                      ),
                    ),
                    Flex(
                      direction: Axis.horizontal,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Icon(
                          WeatherIcons.raindrop,
                          size: 15,
                          color: AppColors.cream.withValues(alpha: 0.7),
                        ),
                        const SizedBox(width: 3),
                        Text(
                          '${daily.precipitationProbabilityMax}%',
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: AppColors.cream,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
