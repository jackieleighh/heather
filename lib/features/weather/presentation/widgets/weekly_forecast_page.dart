import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:weather_icons/weather_icons.dart';

import '../../../../core/utils/weather_icon_mapper.dart';
import '../../domain/entities/daily_weather.dart';

class WeeklyForecastPage extends StatelessWidget {
  final List<DailyWeather> daily;

  const WeeklyForecastPage({super.key, required this.daily});

  @override
  Widget build(BuildContext context) {
    // Build rows of 2
    final rows = <List<DailyWeather>>[];
    for (var i = 0; i < daily.length; i += 2) {
      rows.add(daily.sublist(i, (i + 2).clamp(0, daily.length)));
    }

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
        child: Column(
          children: [
            // Header row — same height as the add-location button row
            SizedBox(
              height: 48,
              child: Align(
                alignment: Alignment.centerRight,
                child: Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: Text(
                    '7-Day Forecast',
                    style: GoogleFonts.quicksand(
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                      shadows: _textShadows,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
            ...rows.map((row) => Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: Row(
                      children: [
                        Expanded(child: _DailyCard(daily: row[0])),
                        const SizedBox(width: 10),
                        if (row.length > 1)
                          Expanded(child: _DailyCard(daily: row[1]))
                        else
                          const Expanded(child: SizedBox()),
                      ],
                    ),
                  ),
                )),
          ],
        ),
      ),
    );
  }

  static const _textShadows = [
    Shadow(color: Colors.black26, blurRadius: 8, offset: Offset(0, 2)),
  ];
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
        color: Colors.white.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Stack(
        children: [
          // Large faded icon — centered in card
          Positioned(
            right: -12,
            top: 0,
            bottom: 0,
            child: Center(
              child: Icon(
                conditionIcon(daily.weatherCode),
                color: Colors.white.withValues(alpha: 0.18),
                size: 100,
              ),
            ),
          ),
          // Content on top
          Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  dayStr,
                  style: GoogleFonts.quicksand(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                    fontSize: 22,
                    shadows: _textShadows,
                  ),
                ),
                const Spacer(),
                Text(
                  '${daily.temperatureMax.round()}° / ${daily.temperatureMin.round()}°',
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 20,
                    shadows: _textShadows,
                  ),
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    const Icon(WeatherIcons.raindrop, size: 15, color: Colors.white54),
                    const SizedBox(width: 3),
                    Text(
                      '${daily.precipitationProbabilityMax}%',
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.white.withValues(alpha: 0.6),
                        shadows: _textShadows,
                      ),
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

  static const _textShadows = [
    Shadow(color: Colors.black26, blurRadius: 4, offset: Offset(0, 1)),
  ];
}
