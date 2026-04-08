import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import './air_card.dart';
import './card_display_mode.dart';
import './conditions_card.dart';
import './moon_card.dart';
import './rain_card.dart';
import './sun_card.dart';
import './temp_card.dart';

import '../../../../../core/constants/app_colors.dart';
import '../../../domain/entities/forecast.dart';
import '../../providers/air_quality_provider.dart';
import '../../providers/historical_avg_provider.dart';

class DetailsPage extends ConsumerStatefulWidget {
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
  ConsumerState<DetailsPage> createState() => _DetailsPageState();
}

class _DetailsPageState extends ConsumerState<DetailsPage> {
  int? _expandedIndex;

  @override
  Widget build(BuildContext context) {
    final forecast = widget.forecast;

    // Defensive: when launched from a widget tap with no cached forecast,
    // hourly/daily can be empty (standalone widget seed). Render a blank
    // placeholder until the real forecast arrives instead of crashing on
    // .first / firstWhere calls below.
    if (forecast.hourly.isEmpty || forecast.daily.isEmpty) {
      return const SizedBox.expand();
    }

    final now = forecast.locationNow;
    final next24 = forecast.hourly.take(24).toList();
    final aqi = ref.watch(airQualityProvider((lat: widget.latitude, lon: widget.longitude)));
    final historicalAvg =
        ref.watch(historicalAvgProvider((lat: widget.latitude, lon: widget.longitude)));

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
    // Coherent (sunrise, sunset) pair: today's pair while today's sunset is
    // still ahead, otherwise tomorrow's pair. Keeping these matched ensures
    // the sun arc, daylight length, and solar noon all compute against a
    // single day.
    final useToday = now.isBefore(todayDaily.sunset);
    final nextSunrise = useToday ? todayDaily.sunrise : tomorrowDaily.sunrise;
    final nextSunset = useToday ? todayDaily.sunset : tomorrowDaily.sunset;

    final isSunUp =
        now.isAfter(todayDaily.sunrise) && now.isBefore(todayDaily.sunset);

    final todayDayLength = todayDaily.sunset.difference(todayDaily.sunrise);
    final tomorrowDayLength = tomorrowDaily.sunset.difference(tomorrowDaily.sunrise);
    final dayLengthDeltaMinutes = tomorrowDayLength.inMinutes - todayDayLength.inMinutes;

    // Visibility to show on the expanded Sun card. During the day use the
    // live current visibility; at night, average the next-24h hourly
    // visibility across tomorrow's daytime window so the whole expanded card
    // reads as "tomorrow".
    final double expandedVisibility;
    if (isSunUp) {
      expandedVisibility = forecast.current.visibility;
    } else {
      final tomorrowDaytime = next24
          .where(
            (h) =>
                !h.time.isBefore(tomorrowDaily.sunrise) &&
                h.time.isBefore(tomorrowDaily.sunset),
          )
          .toList();
      expandedVisibility = tomorrowDaytime.isEmpty
          ? forecast.current.visibility
          : tomorrowDaytime.map((h) => h.visibility).reduce((a, b) => a + b) /
                tomorrowDaytime.length;
    }

    // Build the list of card builders
    final cards = <Widget Function(CardDisplayMode mode)>[
      // 0: Conditions
      (mode) => ConditionsCard(
        hourly: forecast.hourly,
        sunrise: nextSunrise,
        sunset: nextSunset,
        now: now,
        mode: mode,
      ),
      // 1: Temperature
      (mode) => TemperatureCard(
        temps: next24.map((h) => h.temperature).toList(),
        hours: next24.map((h) => h.time).toList(),
        now: now,
        averageHigh: historicalAvg.whenOrNull(data: (v) => v),
        todayHigh: forecast.todayDaily.temperatureMax,
        currentTemp: forecast.current.temperature,
        currentFeelsLike: forecast.current.feelsLike,
        currentDewPoint: forecast.current.dewPoint,
        mode: mode,
        feelsLikeTemps: mode == CardDisplayMode.expanded
            ? next24.map((h) => h.feelsLike).toList()
            : const [],
      ),
      // 2: Rain
      (mode) => RainCard(
        precipitationIn: precipSum / 25.4,
        precipitationProbability: next24
            .map((h) => h.precipitationProbability)
            .reduce((a, b) => a > b ? a : b),
        hourlyPrecipProb: next24
            .map((h) => h.precipitationProbability)
            .toList(),
        hours: next24.map((h) => h.time).toList(),
        now: now,
        precipType: precipTypeFromConditions(
          next24.map((h) => h.condition).toList(),
        ),
        humidity: next24.isNotEmpty ? next24.first.humidity : 0,
        dewPoint: next24.isNotEmpty ? next24.first.dewPoint : 0.0,
        mode: mode,
        hourlyHumidity: mode == CardDisplayMode.expanded
            ? next24.map((h) => h.humidity).toList()
            : const [],
        hourlyDewPoint: mode == CardDisplayMode.expanded
            ? next24.map((h) => h.dewPoint).toList()
            : const [],
      ),
      // 3: Air
      (mode) => AirCard(
        aqi: aqi.whenOrNull(data: (v) => v),
        isLoading: aqi.isLoading,
        windSpeed: forecast.current.windSpeed,
        pressure: forecast.current.pressure,
        windGusts: forecast.current.windGusts,
        windDirection: forecast.current.windDirection,
        hourlyPressure: next24.map((h) => h.pressure).toList(),
        mode: mode,
        hourlyWindSpeed: mode == CardDisplayMode.expanded
            ? next24.map((h) => h.windSpeed).toList()
            : const [],
        hourlyWindGusts: mode == CardDisplayMode.expanded
            ? next24.map((h) => h.windGusts).toList()
            : const [],
        hourlyWindDirection: mode == CardDisplayMode.expanded
            ? next24.map((h) => h.windDirection).toList()
            : const [],
        hours: next24.map((h) => h.time).toList(),
      ),
      // 4: Sun
      (mode) => SunCard(
        sunrise: nextSunrise,
        sunset: nextSunset,
        isSunUp: isSunUp,
        uvIndex: next24.map((h) => h.uvIndex).reduce((a, b) => a > b ? a : b),
        hourlyUv: next24.map((h) => h.uvIndex).toList(),
        hours: next24.map((h) => h.time).toList(),
        now: now,
        mode: mode,
        visibility: expandedVisibility,
        dayLengthDeltaMinutes: dayLengthDeltaMinutes,
        tomorrowSunrise: tomorrowDaily.sunrise,
        tomorrowSunset: tomorrowDaily.sunset,
      ),
      // 5: Moon
      (mode) => MoonCard(
        now: now,
        latitude: widget.latitude,
        longitude: widget.longitude,
        mode: mode,
        cloudCover: forecast.current.cloudCover,
        sunrise: todayDaily.sunrise,
        sunset: todayDaily.sunset,
        tomorrowSunrise: tomorrowDaily.sunrise,
        tomorrowSunset: tomorrowDaily.sunset,
        utcOffsetSeconds: forecast.utcOffsetSeconds,
      ),
    ];

    const cardCount = 6;
    const spacing = 6.0;

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
                    style: GoogleFonts.figtree(
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      color: AppColors.cream,
                    ),
                  ),
                ),
              ),
            ),
            Expanded(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final totalHeight = constraints.maxHeight;
                  const totalSpacing = spacing * (cardCount - 1);
                  final isExpanded = _expandedIndex != null;

                  const collapsedHeight = 44.0;
                  final equalHeight = (totalHeight - totalSpacing) / cardCount;
                  final expandedHeight = isExpanded
                      ? totalHeight -
                            totalSpacing -
                            (collapsedHeight * (cardCount - 1))
                      : 0.0;

                  return Column(
                    children: List.generate(cardCount, (i) {
                      final double targetHeight;
                      final CardDisplayMode mode;
                      if (!isExpanded) {
                        targetHeight = equalHeight;
                        mode = CardDisplayMode.normal;
                      } else if (i == _expandedIndex) {
                        targetHeight = expandedHeight;
                        mode = CardDisplayMode.expanded;
                      } else {
                        targetHeight = collapsedHeight;
                        mode = CardDisplayMode.collapsed;
                      }

                      return Padding(
                        padding: EdgeInsets.only(
                          bottom: i < cardCount - 1 ? spacing : 0,
                        ),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                          height: targetHeight,
                          clipBehavior: Clip.hardEdge,
                          decoration: mode == CardDisplayMode.collapsed
                              ? BoxDecoration(
                                  color: AppColors.cream.withValues(alpha: 0.22),
                                  borderRadius: BorderRadius.circular(20),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withValues(alpha: 0.12),
                                      blurRadius: 12,
                                    ),
                                  ],
                                )
                              : const BoxDecoration(
                                  color: Colors.transparent,
                                ),
                          child: Material(
                            color: Colors.transparent,
                            child: InkWell(
                              borderRadius: BorderRadius.circular(20),
                              onTap: () {
                                setState(() {
                                  _expandedIndex =
                                      _expandedIndex == i ? null : i;
                                });
                              },
                              child: cards[i](mode),
                            ),
                          ),
                        ),
                      );
                    }),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
