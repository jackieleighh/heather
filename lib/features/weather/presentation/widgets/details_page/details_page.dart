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
    final today = forecast.daily.first;
    final now = forecast.locationNow;
    final next24 = forecast.hourly.take(24).toList();
    final aqi = ref.watch(airQualityProvider((lat: latitude, lon: longitude)));

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
                    '24 hours',
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
              child: Padding(
                padding: const EdgeInsets.only(bottom: 5),
                child: ConditionsCard(hourly: forecast.hourly),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(bottom: 5),
                child: TemperatureCard(
                  temps: next24.map((h) => h.temperature).toList(),
                  hours: next24.map((h) => h.time).toList(),
                  now: now,
                ),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(bottom: 5),
                child: RainCard(
                  precipitationIn: today.precipitationSum / 25.4,
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
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(bottom: 5),
                child: AirCard(
                  aqi: aqi.whenOrNull(data: (v) => v),
                  isLoading: aqi.isLoading,
                  windSpeed: forecast.current.windSpeed,
                  hourlyWind: forecast.hourlyToday
                      .map((h) => h.windSpeed)
                      .toList(),
                ),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(bottom: 5),
                child: SunCard(
                  sunrise: today.sunrise,
                  sunset: today.sunset,
                  uvIndex: forecast.current.uvIndex,
                  hourlyUv: next24.map((h) => h.uvIndex).toList(),
                  hours: next24.map((h) => h.time).toList(),
                  now: now,
                ),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(bottom: 5),
                child: MoonCard(now: now),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
