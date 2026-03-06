import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:weather_icons/weather_icons.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/utils/moon_phase.dart';
import '../../../../core/utils/weather_icon_mapper.dart';
import '../../domain/entities/daily_weather.dart';
import '../../domain/entities/forecast.dart';
import '../providers/moon_data_provider.dart';
import 'details_page/card_container.dart';
import 'details_page/conditions_card.dart';
import 'details_page/rain_card.dart';
import 'details_page/temp_card.dart';

class WeeklyForecastPage extends ConsumerStatefulWidget {
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
  ConsumerState<WeeklyForecastPage> createState() => _WeeklyForecastPageState();
}

class _WeeklyForecastPageState extends ConsumerState<WeeklyForecastPage> {
  int? _expandedIndex;

  @override
  Widget build(BuildContext context) {
    final forecast = widget.forecast;
    final daily = forecast.daily.take(10).toList();
    final now = forecast.locationNow;
    final today = DateTime(now.year, now.month, now.day);

    final usno = ref
        .watch(
          moonDataProvider((
            lat: widget.latitude,
            lon: widget.longitude,
            utcOffsetSeconds: forecast.utcOffsetSeconds,
          )),
        )
        .valueOrNull;

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
                    style: GoogleFonts.figtree(
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
                                      moonData: usno,
                                    )
                                  : _CollapsedDayContent(
                                      daily: daily[i],
                                      dayDiff: dayDiff,
                                      isExpanded: isExpanded,
                                      moonData: usno,
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

IconData _precipIcon(DailyWeather daily) {
  final type = precipTypeFromConditions([daily.condition]);
  return switch (type) {
    PrecipType.snow => WeatherIcons.snowflake_cold,
    PrecipType.mixed => WeatherIcons.rain_mix,
    PrecipType.rain => WeatherIcons.raindrop,
  };
}

class _CollapsedDayContent extends StatelessWidget {
  final DailyWeather daily;
  final int dayDiff;
  final bool isExpanded;
  final UsnoMoonData? moonData;

  const _CollapsedDayContent({
    required this.daily,
    required this.dayDiff,
    required this.isExpanded,
    this.moonData,
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
              style: GoogleFonts.figtree(
                fontSize: 20,
                fontWeight: FontWeight.w400,
                color: AppColors.cream,
                shadows: [
                  const Shadow(color: Color(0x28000000), blurRadius: 6),
                ],
              ),
            ),
            const SizedBox(width: 6),
            Text(
              dateStr,
              style: GoogleFonts.quicksand(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: AppColors.cream.withValues(alpha: 0.95),
              ),
            ),
            const SizedBox(width: 10),
            Icon(
              conditionIcon(
                daily.weatherCode,
                isDay: daily.hasSunnyPeriods ? true : null,
              ),
              color: AppColors.cream.withValues(alpha: 0.95),
              size: 18,
            ),
            const Spacer(),
            Text(
              '${daily.temperatureMax.round()}° / ${daily.temperatureMin.round()}°',
              style: GoogleFonts.quicksand(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: AppColors.cream,
              ),
            ),
          ],
        ),
      );
    }

    // Equal-height card — two-row layout with background condition icon
    final moonFrac = moonData?.fractionForDate(daily.date);
    final illumination = dayDiff == 0
        ? moonData?.fracIllum.round()
        : moonData?.illuminationForDate(daily.date).round();
    return Stack(
      children: [
        Positioned(
          right: 6,
          top: 0,
          bottom: 0,
          child: LayoutBuilder(
            builder: (context, constraints) {
              return Icon(
                conditionIcon(
                  daily.weatherCode,
                  isDay: daily.hasSunnyPeriods ? true : null,
                ),
                color: AppColors.cream.withValues(alpha: 0.25),
                size: constraints.maxHeight * 0.8,
              );
            },
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(
            left: 14,
            right: 10,
            top: 3,
            bottom: 3,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Row 1: Day + date header
              Row(
                children: [
                  Flexible(
                    child: Text(
                      dayStr,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.figtree(
                        fontSize: 20,
                        fontWeight: FontWeight.w400,
                        color: AppColors.cream,
                        shadows: [
                          const Shadow(color: Color(0x28000000), blurRadius: 6),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    dateStr,
                    style: GoogleFonts.quicksand(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: AppColors.cream.withValues(alpha: 0.95),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Icon(
                    conditionIcon(
                      daily.weatherCode,
                      isDay: daily.hasSunnyPeriods ? true : null,
                    ),
                    color: AppColors.cream.withValues(alpha: 0.95),
                    size: 18,
                  ),
                ],
              ),
              const SizedBox(height: 2),
              // Row 2: Stats left, temp right
              Row(
                children: [
                  Icon(
                    _precipIcon(daily),
                    size: 12,
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
                  if (daily.precipitationSum > 0 &&
                      (daily.precipitationSum / 25.4) >= 0.01) ...[
                    const SizedBox(width: 2),
                    Text(
                      ' ${(daily.precipitationSum / 25.4).toStringAsFixed(2)}"',
                      style: GoogleFonts.poppins(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: AppColors.cream,
                      ),
                    ),
                  ],
                  if (daily.humidityAvg > 0) ...[
                    const SizedBox(width: 8),
                    Icon(
                      WeatherIcons.humidity,
                      size: 10,
                      color: AppColors.cream.withValues(alpha: 0.9),
                    ),
                    const SizedBox(width: 2),
                    Text(
                      '${daily.humidityAvg}%',
                      style: GoogleFonts.poppins(
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                        color: AppColors.cream.withValues(alpha: 0.9),
                      ),
                    ),
                  ],
                  const SizedBox(width: 8),
                  Icon(
                    WeatherIcons.day_sunny,
                    size: 11,
                    color: AppColors.cream.withValues(alpha: 0.9),
                  ),
                  const SizedBox(width: 2),
                  Text(
                    '${daily.uvIndexMax.round()}',
                    style: GoogleFonts.poppins(
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                      color: AppColors.cream.withValues(alpha: 0.9),
                    ),
                  ),
                  if (moonFrac != null && illumination != null) ...[
                    const SizedBox(width: 8),
                    Icon(
                      moonPhaseIcon(moonFrac),
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
                ],
              ),
            ],
          ),
        ),
        Positioned(
          right: 10,
          bottom: 6,
          child: Center(
            child: Text(
              '${daily.temperatureMax.round()}° / ${daily.temperatureMin.round()}°',
              style: GoogleFonts.quicksand(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: AppColors.cream,
              ),
            ),
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
  final UsnoMoonData? moonData;

  const _ExpandedDayContent({
    required this.daily,
    required this.dayDiff,
    required this.forecast,
    this.moonData,
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
    final usno = widget.moonData;
    final moonFrac = usno?.fractionForDate(daily.date);
    final MoonPhase? phase;
    final int? illumination;
    if (usno != null && widget.dayDiff == 0) {
      // Today: use direct API values
      phase =
          usnoPhaseToEnum(usno.curPhase) ??
          phaseFromFraction(usno.fractionForDate(daily.date));
      illumination = usno.fracIllum.round();
    } else if (usno != null) {
      // Future days: interpolate from transitions
      phase = usno.phaseForDate(daily.date);
      illumination = usno.illuminationForDate(daily.date).round();
    } else {
      phase = null;
      illumination = null;
    }

    return Column(
      children: [
        // Header row
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          child: Row(
            children: [
              Text(
                dayStr,
                style: GoogleFonts.figtree(
                  fontSize: 20,
                  fontWeight: FontWeight.w400,
                  color: AppColors.cream,
                  shadows: [
                    const Shadow(color: Color(0x28000000), blurRadius: 6),
                  ],
                ),
              ),
              const SizedBox(width: 6),
              Text(
                dateStr,
                style: GoogleFonts.quicksand(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: AppColors.cream.withValues(alpha: 0.95),
                ),
              ),
              const SizedBox(width: 10),
              Icon(
                conditionIcon(
                  daily.weatherCode,
                  isDay: daily.hasSunnyPeriods ? true : null,
                ),
                color: AppColors.cream.withValues(alpha: 0.95),
                size: 18,
              ),
              const Spacer(),
              Text(
                '${daily.temperatureMax.round()}° / ${daily.temperatureMin.round()}°',
                style: GoogleFonts.quicksand(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
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
                if (phase != null && illumination != null && moonFrac != null)
                  SizedBox(
                    height: 84,
                    child: _SunMoonCard(
                      sunrise: daily.sunrise,
                      sunset: daily.sunset,
                      moonPhaseLabel: moonPhaseLabel(phase),
                      moonIcon: moonPhaseIcon(moonFrac),
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
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Icon(
                WeatherIcons.day_sunny,
                size: 10,
                color: AppColors.cream.withValues(alpha: 0.9),
              ),
              const SizedBox(width: 3),
              Text(
                'Sun & Moon',
                style: GoogleFonts.figtree(
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                  color: AppColors.cream,
                  shadows: [
                    const Shadow(color: Color(0x28000000), blurRadius: 6),
                  ],
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
