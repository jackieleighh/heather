import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:weather_icons/weather_icons.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/utils/moon_phase.dart';
import '../../../../core/utils/weather_icon_mapper.dart';
import '../../domain/entities/daily_weather.dart';
import '../../domain/entities/forecast.dart';
import 'details_page/card_container.dart';
import 'details_page/conditions_card.dart';
import 'details_page/rain_card.dart';
import 'details_page/temp_card.dart';

class WeeklyForecastPage extends StatefulWidget {
  final Forecast forecast;

  const WeeklyForecastPage({super.key, required this.forecast});

  @override
  State<WeeklyForecastPage> createState() => _WeeklyForecastPageState();
}

class _WeeklyForecastPageState extends State<WeeklyForecastPage> {
  int? _expandedIndex;

  @override
  Widget build(BuildContext context) {
    final forecast = widget.forecast;
    final daily = forecast.daily.take(10).toList();
    final now = forecast.locationNow;
    final today = DateTime(now.year, now.month, now.day);

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 26, 16),
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.only(right: 44),
              child: SizedBox(
                height: 62,
                child: Align(
                  alignment: Alignment.centerRight,
                  child: Text(
                    'Next 10 days',
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
            // Day cards
            Expanded(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final totalHeight = constraints.maxHeight;
                  final cardCount = daily.length;
                  const spacing = 6.0;
                  final totalSpacing = spacing * (cardCount - 1);
                  final isExpanded = _expandedIndex != null;

                  const collapsedHeight = 38.0;
                  final equalHeight = (totalHeight - totalSpacing) / cardCount;
                  final expandedHeight = isExpanded
                      ? totalHeight -
                            totalSpacing -
                            (collapsedHeight * (cardCount - 1))
                      : 0.0;

                  return Column(
                    children: List.generate(cardCount, (i) {
                      final double targetHeight;
                      if (!isExpanded) {
                        targetHeight = equalHeight;
                      } else if (i == _expandedIndex) {
                        targetHeight = expandedHeight;
                      } else {
                        targetHeight = collapsedHeight;
                      }

                      final dayDiff = daily[i].date.difference(today).inDays;

                      return Padding(
                        padding: EdgeInsets.only(
                          bottom: i < cardCount - 1 ? spacing : 0,
                        ),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                          height: targetHeight,
                          clipBehavior: Clip.hardEdge,
                          decoration: BoxDecoration(
                            color: AppColors.cream.withValues(alpha: 0.22),
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.12),
                                blurRadius: 12,
                              ),
                            ],
                          ),
                          child: Material(
                            color: Colors.transparent,
                            child: InkWell(
                              borderRadius: BorderRadius.circular(20),
                              onTap: () {
                                setState(() {
                                  _expandedIndex = _expandedIndex == i
                                      ? null
                                      : i;
                                });
                              },
                              child: _expandedIndex == i
                                  ? _ExpandedDayContent(
                                      daily: daily[i],
                                      dayDiff: dayDiff,
                                      forecast: forecast,
                                    )
                                  : _CollapsedDayContent(
                                      daily: daily[i],
                                      dayDiff: dayDiff,
                                      isExpanded: isExpanded,
                                    ),
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

class _CollapsedDayContent extends StatelessWidget {
  final DailyWeather daily;
  final int dayDiff;
  final bool isExpanded;

  const _CollapsedDayContent({
    required this.daily,
    required this.dayDiff,
    required this.isExpanded,
  });

  @override
  Widget build(BuildContext context) {
    final dateStr = '${daily.date.month}/${daily.date.day}';
    final dayStr = switch (dayDiff) {
      0 => 'Today',
      1 => 'Tomorrow',
      _ => DateFormat('EEEE').format(daily.date),
    };

    if (isExpanded) {
      // Compact single-row for when another card is expanded
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14),
        child: Row(
          children: [
            Text(
              dayStr,
              style: Theme.of(
                context,
              ).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600),
            ),
            const SizedBox(width: 6),
            Text(
              dateStr,
              style: GoogleFonts.poppins(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: AppColors.cream.withValues(alpha: 0.95),
              ),
            ),
            const SizedBox(width: 10),
            Icon(
              conditionIcon(daily.weatherCode, isDay: null),
              color: AppColors.cream.withValues(alpha: 0.95),
              size: 18,
            ),
            const Spacer(),
            Text(
              '${daily.temperatureMax.round()}° / ${daily.temperatureMin.round()}°',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                fontWeight: FontWeight.w700,
                fontSize: 14,
              ),
            ),
            const SizedBox(width: 8),
            Icon(
              WeatherIcons.raindrop,
              size: 10,
              color: AppColors.cream.withValues(alpha: 0.95),
            ),
            const SizedBox(width: 2),
            Text(
              '${daily.precipitationProbabilityMax}%',
              style: GoogleFonts.poppins(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: AppColors.cream,
              ),
            ),
          ],
        ),
      );
    }

    // Equal-height card — two-row layout with background condition icon
    final illumination = moonIllumination(daily.date).round();
    return Stack(
      children: [
        Positioned(
          right: 6,
          top: 0,
          bottom: 0,
          child: Center(
            child: Icon(
              conditionIcon(daily.weatherCode, isDay: null),
              color: AppColors.cream.withValues(alpha: 0.25),
              size: 48,
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 3),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Row(
                children: [
                  Text(
                    dayStr,
                    style: Theme.of(
                      context,
                    ).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    dateStr,
                    style: GoogleFonts.poppins(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: AppColors.cream.withValues(alpha: 0.95),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 2),
              Row(
                children: [
                  Text(
                    '${daily.temperatureMax.round()}°',
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: AppColors.cream,
                    ),
                  ),
                  Text(
                    ' / ${daily.temperatureMin.round()}°',
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.cream.withValues(alpha: 0.9),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Icon(
                    WeatherIcons.raindrop,
                    size: 10,
                    color: AppColors.cream.withValues(alpha: 0.95),
                  ),
                  const SizedBox(width: 2),
                  Text(
                    '${daily.precipitationProbabilityMax}%',
                    style: GoogleFonts.poppins(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: AppColors.cream,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Icon(
                    moonPhaseIcon(daily.date),
                    size: 12,
                    color: AppColors.cream.withValues(alpha: 0.9),
                  ),
                  const SizedBox(width: 3),
                  Text(
                    '$illumination%',
                    style: GoogleFonts.poppins(
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                      color: AppColors.cream.withValues(alpha: 0.9),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _ExpandedDayContent extends StatefulWidget {
  final DailyWeather daily;
  final int dayDiff;
  final Forecast forecast;

  const _ExpandedDayContent({
    required this.daily,
    required this.dayDiff,
    required this.forecast,
  });

  @override
  State<_ExpandedDayContent> createState() => _ExpandedDayContentState();
}

class _ExpandedDayContentState extends State<_ExpandedDayContent> {
  final _scrollController = ScrollController();
  bool _showTopFade = false;
  bool _showBottomFade = true;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    final pos = _scrollController.position;
    final atTop = pos.pixels <= 0;
    final atBottom = pos.pixels >= pos.maxScrollExtent;

    if (_showTopFade == atTop || _showBottomFade == atBottom) {
      setState(() {
        _showTopFade = !atTop;
        _showBottomFade = !atBottom;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final daily = widget.daily;
    final dayStr = switch (widget.dayDiff) {
      0 => 'Today',
      1 => 'Tomorrow',
      _ => DateFormat('EEEE').format(daily.date),
    };
    final dateStr = '${daily.date.month}/${daily.date.day}';

    final dayHourly = widget.forecast.hourlyForDay(daily.date);
    final theme = Theme.of(context);
    final phase = getMoonPhase(daily.date);
    final illumination = moonIllumination(daily.date).round();

    return Column(
      children: [
        // Header row
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          child: Row(
            children: [
              Text(
                dayStr,
                style: theme.textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(width: 6),
              Text(
                dateStr,
                style: GoogleFonts.poppins(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: AppColors.cream.withValues(alpha: 0.95),
                ),
              ),
              const SizedBox(width: 10),
              Icon(
                conditionIcon(daily.weatherCode, isDay: null),
                color: AppColors.cream.withValues(alpha: 0.95),
                size: 18,
              ),
              const Spacer(),
              Text(
                '${daily.temperatureMax.round()}° / ${daily.temperatureMin.round()}°',
                style: theme.textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                  fontSize: 14,
                ),
              ),
              const SizedBox(width: 8),
              Icon(
                WeatherIcons.raindrop,
                size: 10,
                color: AppColors.cream.withValues(alpha: 0.95),
              ),
              const SizedBox(width: 2),
              Text(
                '${daily.precipitationProbabilityMax}%',
                style: GoogleFonts.poppins(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: AppColors.cream,
                ),
              ),
            ],
          ),
        ),
        // Detail cards with scroll fades
        Expanded(
          child: ShaderMask(
            shaderCallback: (bounds) {
              return LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  if (_showTopFade) Colors.transparent else Colors.white,
                  Colors.white,
                  Colors.white,
                  if (_showBottomFade) Colors.transparent else Colors.white,
                ],
                stops: const [0.0, 0.04, 0.94, 1.0],
              ).createShader(bounds);
            },
            blendMode: BlendMode.dstIn,
            child: ListView(
              controller: _scrollController,
              padding: const EdgeInsets.fromLTRB(10, 0, 10, 6),
              children: [
                SizedBox(
                  height: 96,
                  child: ConditionsCard(
                    hourly: dayHourly,
                    compact: true,
                    sunrise: daily.sunrise,
                    sunset: daily.sunset,
                  ),
                ),
                const SizedBox(height: 8),
                SizedBox(
                  height: 82,
                  child: TemperatureCard(
                    temps: dayHourly.map((h) => h.temperature).toList(),
                    hours: dayHourly.map((h) => h.time).toList(),
                    compact: true,
                  ),
                ),
                const SizedBox(height: 8),
                SizedBox(
                  height: 82,
                  child: RainCard(
                    precipitationIn: daily.precipitationSum / 25.4,
                    precipitationProbability: daily.precipitationProbabilityMax,
                    hourlyPrecipProb: dayHourly
                        .map((h) => h.precipitationProbability)
                        .toList(),
                    hours: dayHourly.map((h) => h.time).toList(),
                    precipType: precipTypeFromConditions(
                      dayHourly.map((h) => h.condition).toList(),
                    ),
                    compact: true,
                  ),
                ),
                const SizedBox(height: 8),
                SizedBox(
                  height: 84,
                  child: _SunMoonCard(
                    sunrise: daily.sunrise,
                    sunset: daily.sunset,
                    moonPhaseLabel: moonPhaseLabel(phase),
                    moonIcon: moonPhaseIcon(daily.date),
                    illumination: illumination,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

/// Condensed sun/moon card showing sunrise, sunset, phase, and illumination.
class _SunMoonCard extends StatelessWidget {
  final DateTime sunrise;
  final DateTime sunset;
  final String moonPhaseLabel;
  final IconData moonIcon;
  final int illumination;

  const _SunMoonCard({
    required this.sunrise,
    required this.sunset,
    required this.moonPhaseLabel,
    required this.moonIcon,
    required this.illumination,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final timeFmt = DateFormat('h:mm a');

    return CardContainer(
      backgroundIcon: WeatherIcons.day_sunny,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Icon(
                WeatherIcons.day_sunny,
                size: 12,
                color: AppColors.cream.withValues(alpha: 0.9),
              ),
              const SizedBox(width: 5),
              Text(
                'Sun & Moon',
                style: theme.textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          // Sunrise / Sunset row
          Row(
            children: [
              Icon(
                WeatherIcons.sunrise,
                size: 13,
                color: AppColors.cream.withValues(alpha: 0.9),
              ),
              const SizedBox(width: 5),
              Text(
                timeFmt.format(sunrise),
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: AppColors.cream,
                ),
              ),
              const SizedBox(width: 14),
              Icon(
                WeatherIcons.sunset,
                size: 13,
                color: AppColors.cream.withValues(alpha: 0.9),
              ),
              const SizedBox(width: 5),
              Text(
                timeFmt.format(sunset),
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: AppColors.cream,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          // Moon phase row
          Row(
            children: [
              Icon(
                moonIcon,
                size: 13,
                color: AppColors.cream.withValues(alpha: 0.9),
              ),
              const SizedBox(width: 5),
              Text(
                moonPhaseLabel,
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: AppColors.cream,
                ),
              ),
              const SizedBox(width: 6),
              Text(
                '$illumination% illuminated',
                style: GoogleFonts.poppins(
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                  color: AppColors.cream.withValues(alpha: 0.9),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
