import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import './air_card.dart';
import './conditions_card.dart';
import './moon_card.dart';
import './rain_card.dart';
import './sun_card.dart';
import './temp_card.dart';

import '../../../../../core/constants/app_colors.dart';
import '../../../domain/entities/forecast.dart';
import '../../providers/air_quality_provider.dart';

class DetailsPage extends ConsumerWidget {
  final Forecast forecast;
  final double latitude;
  final double longitude;

  const DetailsPage({
    super.key,
    required this.forecast,
    required this.latitude,
    required this.longitude,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final now = forecast.locationNow;
    final next24 = forecast.hourly.take(24).toList();
    final aqi = ref.watch(airQualityProvider((lat: latitude, lon: longitude)));

    // Aggregate precipitation across the days the next 24 hours span
    final next24Start = next24.first.time;
    final next24End = next24.last.time;
    var precipSum = 0.0;
    for (final d in forecast.daily) {
      final dayStart = d.date;
      final dayEnd = dayStart.add(const Duration(days: 1));
      if (dayEnd.isAfter(next24Start) && dayStart.isBefore(next24End)) {
        precipSum += d.precipitationSum;
      }
    }

    // Pick sunrise/sunset relevant to the next 24 hours
    final todayDaily = forecast.todayDaily;
    final tomorrowDaily = forecast.daily.length > 1
        ? forecast.daily[forecast.daily.indexOf(todayDaily) + 1 <
                  forecast.daily.length
              ? forecast.daily.indexOf(todayDaily) + 1
              : 0]
        : todayDaily;
    // If current time is past today's sunset, show tomorrow's sunrise/sunset
    final sunrise = now.isAfter(todayDaily.sunset)
        ? tomorrowDaily.sunrise
        : todayDaily.sunrise;
    final sunset = now.isAfter(todayDaily.sunset)
        ? tomorrowDaily.sunset
        : todayDaily.sunset;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 26, 16),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(right: 44),
              child: SizedBox(
                height: 62,
                child: Align(
                  alignment: Alignment.centerRight,
                  child: Text(
                    'Next 24 hours',
                    style: GoogleFonts.quicksand(
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      color: AppColors.cream,
                    ),
                  ),
                ),
              ),
            ),
            Expanded(
              child: ConditionsCard(
                hourly: forecast.hourly,
                sunrise: sunrise,
                sunset: sunset,
              ),
            ),
            const SizedBox(height: 6),
            Expanded(
              child: TemperatureCard(
                temps: next24.map((h) => h.temperature).toList(),
                hours: next24.map((h) => h.time).toList(),
                now: now,
              ),
            ),
            const SizedBox(height: 6),
            Expanded(
              child: RainCard(
                precipitationIn: precipSum / 25.4,
                precipitationProbability: next24
                    .map((h) => h.precipitationProbability)
                    .reduce((a, b) => a > b ? a : b),
                hourlyPrecipProb: next24
                    .map((h) => h.precipitationProbability)
                    .toList(),
                hours: next24.map((h) => h.time).toList(),
                now: now,
              ),
            ),
            const SizedBox(height: 6),
            Expanded(
              child: AirCard(
                aqi: aqi.whenOrNull(data: (v) => v),
                isLoading: aqi.isLoading,
                windSpeed: forecast.current.windSpeed,
                hourlyWind: next24.map((h) => h.windSpeed).toList(),
              ),
            ),
            const SizedBox(height: 6),
            Expanded(
              child: SunCard(
                sunrise: sunrise,
                sunset: sunset,
                uvIndex: forecast.current.uvIndex,
                hourlyUv: next24.map((h) => h.uvIndex).toList(),
                hours: next24.map((h) => h.time).toList(),
                now: now,
              ),
            ),
            const SizedBox(height: 6),
            Expanded(child: MoonCard(now: now)),
          ],
        ),
      ),
    );
  }
}
