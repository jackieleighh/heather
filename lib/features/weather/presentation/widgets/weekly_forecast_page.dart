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
  final double latitude;
  final double longitude;

  const WeeklyForecastPage({
    super.key,
    required this.forecast,
    required this.latitude,
    required this.longitude,
  });

  @override
  State<WeeklyForecastPage> createState() => _WeeklyForecastPageState();
}

class _WeeklyForecastPageState extends State<WeeklyForecastPage> {
  int? _expandedIndex;

  @override
  Widget build(BuildContext context) {
    final forecast = widget.forecast;
    final daily = forecast.daily;
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
                    'Next 7 days',
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

                  const collapsedHeight = 48.0;
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
      1 => isExpanded ? 'Tomorrow' : 'Tmrw',
      _ =>
        isExpanded
            ? DateFormat('EEEE').format(daily.date)
            : DateFormat('EEE').format(daily.date),
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
              conditionIcon(daily.weatherCode),
              color: AppColors.cream.withValues(alpha: 0.95),
              size: 22,
            ),
            const Spacer(),
            Text(
              '${daily.temperatureMax.round()}° / ${daily.temperatureMin.round()}°',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                fontWeight: FontWeight.w700,
                fontSize: 16,
              ),
            ),
            const SizedBox(width: 8),
            Icon(
              WeatherIcons.raindrop,
              size: 12,
              color: AppColors.cream.withValues(alpha: 0.95),
            ),
            const SizedBox(width: 2),
            Text(
              '${daily.precipitationProbabilityMax}%',
              style: GoogleFonts.poppins(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppColors.cream,
              ),
            ),
          ],
        ),
      );
    }

    // Original card look when nothing is expanded
    return Stack(
      children: [
        Positioned(
          right: 0,
          top: 0,
          child: Icon(
            conditionIcon(daily.weatherCode),
            color: AppColors.cream.withValues(alpha: 0.95),
            size: 80,
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  Text(
                    dayStr,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
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
                ],
              ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  Text(
                    '${daily.temperatureMax.round()}° / ${daily.temperatureMin.round()}°',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.w800,
                      fontSize: 26,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 2),
                    child: Icon(
                      WeatherIcons.raindrop,
                      size: 13,
                      color: AppColors.cream.withValues(alpha: 0.95),
                    ),
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
                  const SizedBox(width: 10),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 2),
                    child: Icon(
                      moonPhaseIcon(daily.date),
                      size: 16,
                      color: AppColors.cream.withValues(alpha: 0.95),
                    ),
                  ),
                  const SizedBox(width: 3),
                  Text(
                    '${moonIllumination(daily.date).round()}%',
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
                  fontWeight: FontWeight.w700,
                  fontSize: 18,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                dateStr,
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: AppColors.cream.withValues(alpha: 0.95),
                ),
              ),
              const Spacer(),
              Text(
                '${daily.temperatureMax.round()}° / ${daily.temperatureMin.round()}°',
                style: theme.textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                  fontSize: 16,
                ),
              ),
              const SizedBox(width: 6),
              Icon(
                conditionIcon(daily.weatherCode),
                color: AppColors.cream.withValues(alpha: 0.9),
                size: 24,
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
              padding: const EdgeInsets.fromLTRB(8, 0, 8, 8),
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
                const SizedBox(height: 5),
                SizedBox(
                  height: 92,
                  child: TemperatureCard(
                    temps: dayHourly.map((h) => h.temperature).toList(),
                    hours: dayHourly.map((h) => h.time).toList(),
                    compact: true,
                  ),
                ),
                const SizedBox(height: 5),
                SizedBox(
                  height: 92,
                  child: RainCard(
                    precipitationIn: daily.precipitationSum / 25.4,
                    precipitationProbability: daily.precipitationProbabilityMax,
                    hourlyPrecipProb: dayHourly
                        .map((h) => h.precipitationProbability)
                        .toList(),
                    hours: dayHourly.map((h) => h.time).toList(),
                    compact: true,
                  ),
                ),
                const SizedBox(height: 5),
                SizedBox(
                  height: 90,
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
                size: 12,
                color: AppColors.cream.withValues(alpha: 0.95),
              ),
              const SizedBox(width: 4),
              Text(
                timeFmt.format(sunrise),
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                  fontSize: 13,
                ),
              ),
              const SizedBox(width: 14),
              Icon(
                WeatherIcons.sunset,
                size: 12,
                color: AppColors.cream.withValues(alpha: 0.95),
              ),
              const SizedBox(width: 4),
              Text(
                timeFmt.format(sunset),
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                  fontSize: 13,
                ),
              ),
            ],
          ),
          const SizedBox(height: 3),
          // Moon phase row
          Row(
            children: [
              Icon(
                moonIcon,
                size: 14,
                color: AppColors.cream.withValues(alpha: 0.9),
              ),
              const SizedBox(width: 6),
              Text(
                moonPhaseLabel,
                style: GoogleFonts.poppins(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: AppColors.cream,
                ),
              ),
              const SizedBox(width: 6),
              Text(
                '$illumination% illuminated',
                style: GoogleFonts.poppins(
                  fontSize: 12,
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
