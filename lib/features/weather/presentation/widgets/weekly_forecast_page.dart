import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:weather_icons/weather_icons.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/utils/moon_phase.dart';
import '../../../../core/utils/weather_icon_mapper.dart';
import '../../../../core/utils/wind_direction.dart';
import '../../domain/entities/daily_weather.dart';
import '../../domain/entities/forecast.dart';
import '../../domain/entities/hourly_weather.dart';
import '../providers/moon_data_provider.dart';
import 'details_page/conditions_card.dart';
import 'details_page/rain_card.dart';

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

    final usno = ref.watch(moonDataProvider).valueOrNull;

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
                  final isExpanded = _expandedIndex != null;
                  // Tighter spacing + compact row height only when a card is
                  // expanded.
                  final spacing = isExpanded ? 4.0 : 6.0;
                  const baseCollapsedHeight = 30.0;
                  // Hard cap on the expanded card so the 2x2 grid never
                  // dominates the viewport on taller devices. Any leftover
                  // vertical space is redistributed across the nine compact
                  // rows so nothing floats awkwardly mid-screen.
                  const maxExpandedHeight = 320.0;
                  final totalSpacing = spacing * (cardCount - 1);

                  final equalHeight = (totalHeight - totalSpacing) / cardCount;
                  final naturalExpanded = totalHeight -
                      totalSpacing -
                      (baseCollapsedHeight * (cardCount - 1));
                  final expandedHeight = isExpanded
                      ? math.min(naturalExpanded, maxExpandedHeight)
                      : 0.0;
                  final compactExtra = isExpanded &&
                          naturalExpanded > maxExpandedHeight
                      ? (naturalExpanded - maxExpandedHeight) /
                          (cardCount - 1)
                      : 0.0;
                  final collapsedHeight = baseCollapsedHeight + compactExtra;

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
                              onTap: () => setState(() {
                                _expandedIndex =
                                    _expandedIndex == i ? null : i;
                              }),
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
                                      now: now,
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
  final DateTime now;

  const _CollapsedDayContent({
    required this.daily,
    required this.dayDiff,
    required this.isExpanded,
    required this.now,
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
        padding: const EdgeInsets.symmetric(horizontal: 12),
        child: Row(
          children: [
            Text(
              dayStr,
              style: GoogleFonts.figtree(
                fontSize: 18,
                fontWeight: FontWeight.w400,
                color: AppColors.cream,
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
              size: 16,
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
    // For "today", reflect right-now's interpolated illumination so it
    // matches what other surfaces (moon card, current details) display.
    final moonRefDate = dayDiff == 0 ? now : daily.date;
    final moonFrac = moonData?.fractionForDate(moonRefDate);
    final illumination = moonData?.illuminationForDate(moonRefDate).round();
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

class _ExpandedDayContent extends StatelessWidget {
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
  Widget build(BuildContext context) {
    final dayStr = switch (dayDiff) {
      0 => 'Today',
      1 => 'Tomorrow',
      _ => DateFormat('EEEE').format(daily.date),
    };
    final dateStr = '${daily.date.month}/${daily.date.day}';

    final dayHourly = forecast.hourlyForDay(daily.date);
    final usno = moonData;
    // For today, use right-now so the value matches the moon card and the
    // current-conditions chip. For future days, use the day's date.
    final moonRefDate = dayDiff == 0 ? forecast.locationNow : daily.date;
    final moonFrac = usno?.fractionForDate(moonRefDate);
    final MoonPhase? phase;
    final int? illumination;
    if (usno != null) {
      phase = dayDiff == 0
          ? (usnoPhaseToEnum(usno.curPhase) ??
                phaseFromFraction(usno.fractionForDate(moonRefDate)))
          : usno.phaseForDate(moonRefDate);
      illumination = usno.illuminationForDate(moonRefDate).round();
    } else {
      phase = null;
      illumination = null;
    }

    final hasMoon = phase != null && illumination != null && moonFrac != null;

    return Padding(
      padding: const EdgeInsets.fromLTRB(10, 6, 10, 6),
      child: Column(
        children: [
          // 1. Header row — sits flush at the top, no card chrome
          Padding(
            padding: const EdgeInsets.fromLTRB(4, 0, 4, 4),
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
          // 2. Hourly conditions strip — full width, horizontally scrollable
          _TileCard(
            child: SizedBox(
              height: 60,
              child: ConditionsCard(
                hourly: dayHourly,
                compact: true,
                flat: true,
                showHeader: false,
                sunrise: daily.sunrise,
                sunset: daily.sunset,
              ),
            ),
          ),
          const SizedBox(height: 4),
          // 3. 2x2 grid — absorbs remaining vertical space
          Expanded(
            child: Column(
              children: [
                Expanded(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Expanded(
                        child: _TileCard(
                          child: _StatsTile(hourly: dayHourly, daily: daily),
                        ),
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: _TileCard(
                          child: _TempTile(hourly: dayHourly, daily: daily),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 4),
                Expanded(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Expanded(
                        child: _TileCard(
                          child: _RainTile(hourly: dayHourly, daily: daily),
                        ),
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: _TileCard(
                          child: hasMoon
                              ? _SunMoonTile(
                                  sunrise: daily.sunrise,
                                  sunset: daily.sunset,
                                  moonPhaseLabel: moonPhaseLabel(phase),
                                  moonIcon: moonPhaseIcon(moonFrac),
                                  illumination: illumination,
                                  now: forecast.locationNow,
                                  isToday: dayDiff == 0,
                                  moonFrac: moonFrac,
                                )
                              : _SunMoonTile(
                                  sunrise: daily.sunrise,
                                  sunset: daily.sunset,
                                  moonPhaseLabel: null,
                                  moonIcon: null,
                                  illumination: null,
                                  now: forecast.locationNow,
                                  isToday: dayDiff == 0,
                                  moonFrac: null,
                                ),
                        ),
                      ),
                    ],
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

/// Soft mini-card wrapper used for every section inside an expanded day.
/// Matches the styling of `InfoChip` so the expanded view feels like a
/// gallery of small tiles instead of dividing-line panels.
class _TileCard extends StatelessWidget {
  final Widget child;

  const _TileCard({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: AppColors.cream.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(10),
      ),
      child: child,
    );
  }
}

/// Shared header row used by every tile in the 2x2 grid.
class _TileHeader extends StatelessWidget {
  final IconData icon;
  final String label;
  final Widget? trailing;

  const _TileHeader({
    required this.icon,
    required this.label,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Icon(icon, size: 11, color: AppColors.cream.withValues(alpha: 0.9)),
        const SizedBox(width: 4),
        Text(
          label,
          style: GoogleFonts.figtree(
            fontSize: 13,
            fontWeight: FontWeight.w400,
            color: AppColors.cream,
          ),
        ),
        if (trailing != null) ...[
          const Spacer(),
          trailing!,
        ],
      ],
    );
  }
}

/// Temperature tile with hi/lo header and a miniature edge-to-edge curve.
class _TempTile extends StatelessWidget {
  final List<HourlyWeather> hourly;
  final DailyWeather daily;

  const _TempTile({required this.hourly, required this.daily});

  @override
  Widget build(BuildContext context) {
    final temps = hourly.map((h) => h.temperature).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _TileHeader(
          icon: WeatherIcons.thermometer,
          label: 'Temp',
          trailing: Text(
            '${daily.temperatureMax.round()}° / ${daily.temperatureMin.round()}°',
            style: GoogleFonts.poppins(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: AppColors.cream,
            ),
          ),
        ),
        const SizedBox(height: 4),
        if (temps.length >= 2)
          Expanded(
            child: CustomPaint(
              size: Size.infinite,
              painter: _MiniTempPainter(temps),
            ),
          )
        else
          const Spacer(),
        const SizedBox(height: 4),
        const _TileTimeAxis(),
      ],
    );
  }
}

/// Rain tile with amount + chance header and miniature precip-probability bars.
class _RainTile extends StatelessWidget {
  final List<HourlyWeather> hourly;
  final DailyWeather daily;

  const _RainTile({required this.hourly, required this.daily});

  @override
  Widget build(BuildContext context) {
    final precipType = precipTypeFromConditions(
      hourly.map((h) => h.condition).toList(),
    );
    final (label, icon) = switch (precipType) {
      PrecipType.snow => ('Snow', WeatherIcons.snowflake_cold),
      PrecipType.mixed => ('Slush', WeatherIcons.rain_mix),
      PrecipType.rain => ('Rain', WeatherIcons.raindrop),
    };
    final amountIn = daily.precipitationSum / 25.4;
    final amountLabel = amountIn < 0.01 ? '0"' : '${amountIn.toStringAsFixed(2)}"';
    final probs = hourly.map((h) => h.precipitationProbability).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _TileHeader(
          icon: icon,
          label: label,
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                amountLabel,
                style: GoogleFonts.poppins(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: AppColors.cream,
                ),
              ),
              const SizedBox(width: 4),
              Text(
                '${daily.precipitationProbabilityMax}%',
                style: GoogleFonts.poppins(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: AppColors.cream.withValues(alpha: 0.9),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 4),
        if (probs.isNotEmpty)
          Expanded(
            child: CustomPaint(
              size: Size.infinite,
              painter: _MiniPrecipPainter(probs),
            ),
          )
        else
          const Spacer(),
        const SizedBox(height: 4),
        const _TileTimeAxis(),
      ],
    );
  }
}

/// Sun & moon tile with a sun-arc visualization filling the middle band.
/// If [moonPhaseLabel]/[moonIcon]/[illumination] are null the moon chip in
/// the header is hidden and only the sunrise/sunset row renders in the footer.
class _SunMoonTile extends StatelessWidget {
  final DateTime sunrise;
  final DateTime sunset;
  final String? moonPhaseLabel;
  final IconData? moonIcon;
  final int? illumination;
  final DateTime now;
  final bool isToday;
  final double? moonFrac;

  const _SunMoonTile({
    required this.sunrise,
    required this.sunset,
    required this.moonPhaseLabel,
    required this.moonIcon,
    required this.illumination,
    required this.now,
    required this.isToday,
    required this.moonFrac,
  });

  @override
  Widget build(BuildContext context) {
    final timeFmt = DateFormat('h:mm a');
    final hasMoon =
        moonPhaseLabel != null && moonIcon != null && illumination != null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _TileHeader(
          icon: WeatherIcons.day_sunny,
          label: 'Sun & Moon',
          trailing: hasMoon
              ? _StatChip(icon: moonIcon!, value: '$illumination%')
              : null,
        ),
        const SizedBox(height: 4),
        Expanded(
          child: CustomPaint(
            size: Size.infinite,
            painter: _MiniSunArcPainter(
              sunrise: sunrise,
              sunset: sunset,
              now: now,
              isToday: isToday,
              moonFrac: moonFrac,
            ),
          ),
        ),
        const SizedBox(height: 4),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _StatChip(
              icon: WeatherIcons.sunrise,
              value: timeFmt.format(sunrise),
              fontWeight: FontWeight.w400,
            ),
            _StatChip(
              icon: WeatherIcons.sunset,
              value: timeFmt.format(sunset),
              fontWeight: FontWeight.w400,
            ),
          ],
        ),
      ],
    );
  }
}

/// Tile with the day's UV, humidity, and wind summary stats.
class _StatsTile extends StatelessWidget {
  final List<HourlyWeather> hourly;
  final DailyWeather daily;

  const _StatsTile({required this.hourly, required this.daily});

  @override
  Widget build(BuildContext context) {
    final uvHours = hourly.map((h) => h.uvIndex).toList();

    // Humidity: prefer daily.humidityAvg; fall back to hourly mean.
    int humidity = daily.humidityAvg;
    if (humidity == 0 && hourly.isNotEmpty) {
      final sum = hourly.fold<int>(0, (a, h) => a + h.humidity);
      humidity = (sum / hourly.length).round();
    }

    // Wind: mean speed + circular-mean direction over the day's hourly data.
    double? meanWind;
    int? domDir;
    if (hourly.isNotEmpty) {
      meanWind =
          hourly.fold<double>(0, (a, h) => a + h.windSpeed) / hourly.length;
      var sinSum = 0.0;
      var cosSum = 0.0;
      for (final h in hourly) {
        final rad = h.windDirection * math.pi / 180.0;
        sinSum += math.sin(rad);
        cosSum += math.cos(rad);
      }
      final meanRad = math.atan2(sinSum, cosSum);
      var deg = (meanRad * 180.0 / math.pi).round();
      if (deg < 0) deg += 360;
      domDir = deg;
    }

    final hasUv = uvHours.any((v) => v > 0);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _TileHeader(
          icon: Icons.bar_chart,
          label: 'Day',
          trailing: _StatChip(
            icon: WeatherIcons.day_sunny,
            value: 'UV ${daily.uvIndexMax.round()}',
          ),
        ),
        const SizedBox(height: 4),
        if (hasUv && uvHours.length >= 2)
          Expanded(
            child: CustomPaint(
              size: Size.infinite,
              painter: _MiniUvPainter(uvHours),
            ),
          )
        else
          const Spacer(),
        const SizedBox(height: 4),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            if (humidity > 0)
              _StatChip(icon: WeatherIcons.humidity, value: '$humidity%', fontWeight: FontWeight.w400),
            if (meanWind != null && domDir != null)
              _StatChip(
                icon: WeatherIcons.windy,
                value: '${meanWind.round()} ${windDirectionLabel(domDir)}',
                fontWeight: FontWeight.w400,
              ),
          ],
        ),
      ],
    );
  }
}

/// Half-of-day labels ("AM" / "PM") shown under the Temp and Rain graphs.
/// The sparklines span a full 24 hours (midnight → 11pm), so "AM" anchors the
/// left half (midnight → noon) and "PM" the right half (noon → midnight).
/// Uses the same Poppins 11 metrics as `_StatChip` so the row height matches
/// the footer chip rows in sibling tiles and the graph baselines line up
/// across the 2x2 grid.
class _TileTimeAxis extends StatelessWidget {
  const _TileTimeAxis();

  @override
  Widget build(BuildContext context) {
    final style = GoogleFonts.poppins(
      fontSize: 11,
      fontWeight: FontWeight.w400,
      color: AppColors.cream.withValues(alpha: 0.7),
    );
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text('AM', style: style),
        Text('PM', style: style),
      ],
    );
  }
}

/// Compact icon + value chip used as a Wrap child inside stat tiles.
class _StatChip extends StatelessWidget {
  final IconData icon;
  final String value;
  final FontWeight fontWeight;

  const _StatChip({
    required this.icon,
    required this.value,
    this.fontWeight = FontWeight.w700,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 12, color: AppColors.cream.withValues(alpha: 0.9)),
        const SizedBox(width: 5),
        Text(
          value,
          style: GoogleFonts.poppins(
            fontSize: 11,
            fontWeight: fontWeight,
            color: AppColors.cream,
          ),
        ),
      ],
    );
  }
}

/// Edge-to-edge cubic-smoothed temperature curve with a subtle area fill.
/// No axis labels, no padding gutters — fills the available rect entirely.
class _MiniTempPainter extends CustomPainter {
  final List<double> temps;

  _MiniTempPainter(this.temps);

  @override
  void paint(Canvas canvas, Size size) {
    if (temps.length < 2) return;

    final lo = temps.reduce(math.min);
    final hi = temps.reduce(math.max);
    final range = hi - lo;
    if (range == 0) return;

    final w = size.width;
    final h = size.height;
    final stepX = w / (temps.length - 1);

    final points = <Offset>[];
    for (var i = 0; i < temps.length; i++) {
      final x = i * stepX;
      final y = h * (1 - (temps[i] - lo) / range);
      points.add(Offset(x, y));
    }

    final linePath = Path()..moveTo(points.first.dx, points.first.dy);
    for (var i = 1; i < points.length; i++) {
      final prev = points[i - 1];
      final curr = points[i];
      final cpx = (prev.dx + curr.dx) / 2;
      linePath.cubicTo(cpx, prev.dy, cpx, curr.dy, curr.dx, curr.dy);
    }

    final fillPath = Path.from(linePath)
      ..lineTo(points.last.dx, h)
      ..lineTo(points.first.dx, h)
      ..close();
    final fillPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          AppColors.cream.withValues(alpha: 0.18),
          AppColors.cream.withValues(alpha: 0.02),
        ],
      ).createShader(Rect.fromLTWH(0, 0, w, h));
    canvas.drawPath(fillPath, fillPaint);

    canvas.drawPath(
      linePath,
      Paint()
        ..color = AppColors.cream.withValues(alpha: 0.55)
        ..strokeWidth = 1.5
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round,
    );
  }

  @override
  bool shouldRepaint(covariant _MiniTempPainter old) => temps != old.temps;
}

/// Edge-to-edge cubic-smoothed UV-index curve pinned to a 0–11 y-axis so the
/// natural midday hump reads consistently across days.
class _MiniUvPainter extends CustomPainter {
  final List<double> uv;

  _MiniUvPainter(this.uv);

  @override
  void paint(Canvas canvas, Size size) {
    if (uv.length < 2) return;
    final hi = uv.reduce(math.max);
    if (hi <= 0) return;
    final maxY = math.max(11.0, hi);

    final w = size.width;
    final h = size.height;
    final stepX = w / (uv.length - 1);

    final points = <Offset>[];
    for (var i = 0; i < uv.length; i++) {
      final x = i * stepX;
      final y = h * (1 - (uv[i] / maxY).clamp(0.0, 1.0));
      points.add(Offset(x, y));
    }

    final linePath = Path()..moveTo(points.first.dx, points.first.dy);
    for (var i = 1; i < points.length; i++) {
      final prev = points[i - 1];
      final curr = points[i];
      final cpx = (prev.dx + curr.dx) / 2;
      linePath.cubicTo(cpx, prev.dy, cpx, curr.dy, curr.dx, curr.dy);
    }

    final fillPath = Path.from(linePath)
      ..lineTo(points.last.dx, h)
      ..lineTo(points.first.dx, h)
      ..close();
    final fillPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          AppColors.cream.withValues(alpha: 0.18),
          AppColors.cream.withValues(alpha: 0.02),
        ],
      ).createShader(Rect.fromLTWH(0, 0, w, h));
    canvas.drawPath(fillPath, fillPaint);

    canvas.drawPath(
      linePath,
      Paint()
        ..color = AppColors.cream.withValues(alpha: 0.55)
        ..strokeWidth = 1.5
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round,
    );
  }

  @override
  bool shouldRepaint(covariant _MiniUvPainter old) => uv != old.uv;
}

/// Edge-to-edge precipitation-probability bars. No axis labels, no grid.
class _MiniPrecipPainter extends CustomPainter {
  final List<int> precipProb;

  _MiniPrecipPainter(this.precipProb);

  @override
  void paint(Canvas canvas, Size size) {
    if (precipProb.isEmpty) return;
    final w = size.width;
    final h = size.height;
    final barW = w / precipProb.length;

    for (var i = 0; i < precipProb.length; i++) {
      final pct = precipProb[i] / 100.0;
      final barH = math.max(h * pct, pct > 0 ? 1.5 : 0.0);
      final x = i * barW;
      final y = h - barH;
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(x + 0.5, y, barW - 1, barH),
          const Radius.circular(1.5),
        ),
        Paint()..color = AppColors.cream.withValues(alpha: 0.45 + 0.45 * pct),
      );
    }
  }

  @override
  bool shouldRepaint(covariant _MiniPrecipPainter old) =>
      precipProb != old.precipProb;
}

/// Flattened elliptical sun arc spanning sunrise → solar noon → sunset.
/// Dashed stroke with a horizon line. Draws a solid "now" dot when
/// [isToday] is true and the current time sits between sunrise and sunset.
/// A small moon-phase disc floats in the top-right corner when [moonFrac]
/// is provided, so the tile tells both the sun *and* moon story.
class _MiniSunArcPainter extends CustomPainter {
  final DateTime sunrise;
  final DateTime sunset;
  final DateTime now;
  final bool isToday;
  final double? moonFrac;

  _MiniSunArcPainter({
    required this.sunrise,
    required this.sunset,
    required this.now,
    required this.isToday,
    required this.moonFrac,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (size.width <= 0 || size.height <= 0) return;

    const left = 4.0;
    const top = 4.0;

    final right = size.width - 4.0;
    final bottom = size.height - 2.0;

    // Horizon line
    canvas.drawLine(
      Offset(left, bottom),
      Offset(right, bottom),
      Paint()
        ..color = AppColors.cream.withValues(alpha: 0.35)
        ..strokeWidth = 1,
    );

    // Arc path using a quadratic bezier — control point above the top so
    // the resulting curve lands with its apex right at y=top, giving a
    // flattened elliptical feel rather than a full semicircle.
    final startPt = Offset(left, bottom);
    final endPt = Offset(right, bottom);
    final controlPt = Offset((left + right) / 2, top - (bottom - top));
    final arcPath = Path()
      ..moveTo(startPt.dx, startPt.dy)
      ..quadraticBezierTo(controlPt.dx, controlPt.dy, endPt.dx, endPt.dy);

    // Dashed stroke of the arc
    final dashPaint = Paint()
      ..color = AppColors.cream.withValues(alpha: 0.5)
      ..strokeWidth = 1.3
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    for (final metric in arcPath.computeMetrics()) {
      var distance = 0.0;
      while (distance < metric.length) {
        final end = math.min(distance + 4, metric.length);
        canvas.drawPath(metric.extractPath(distance, end), dashPaint);
        distance += 7;
      }
    }

    // "Now" dot — only for today, and only while the sun is above the horizon
    if (isToday && now.isAfter(sunrise) && now.isBefore(sunset)) {
      final totalMs = sunset.difference(sunrise).inMilliseconds.toDouble();
      if (totalMs > 0) {
        final t = (now.difference(sunrise).inMilliseconds / totalMs)
            .clamp(0.0, 1.0);
        // Sample the quadratic bezier at parameter t
        final oneMinusT = 1 - t;
        final x = oneMinusT * oneMinusT * startPt.dx +
            2 * oneMinusT * t * controlPt.dx +
            t * t * endPt.dx;
        final y = oneMinusT * oneMinusT * startPt.dy +
            2 * oneMinusT * t * controlPt.dy +
            t * t * endPt.dy;
        canvas.drawCircle(
          Offset(x, y),
          2.5,
          Paint()
            ..color = AppColors.cream.withValues(alpha: 0.95)
            ..style = PaintingStyle.fill,
        );
      }
    }

    // Small moon-phase disc in the top-right corner
    final frac = moonFrac;
    if (frac != null) {
      const moonR = 7.0;
      final moonCenter = Offset(right - moonR - 1, top + moonR + 1);
      final moonRect = Rect.fromCircle(center: moonCenter, radius: moonR);

      canvas.saveLayer(moonRect.inflate(1), Paint());

      // Lit base
      canvas.drawCircle(
        moonCenter,
        moonR,
        Paint()
          ..color = AppColors.cream.withValues(alpha: 0.85)
          ..style = PaintingStyle.fill,
      );

      // Terminator shadow — clear out the shadowed portion with a composited
      // oval, using the same waxing/waning convention as _MoonDiscPainter.
      final shadowPaint = Paint()
        ..blendMode = BlendMode.clear
        ..style = PaintingStyle.fill;

      if (frac > 0.02 && frac < 0.98) {
        final terminatorX = math.cos(2 * math.pi * frac);
        final absTerminatorX = terminatorX.abs();
        final waxing = frac < 0.5;
        final shadowPath = Path();

        if (waxing) {
          shadowPath.addArc(
            Rect.fromCircle(center: moonCenter, radius: moonR),
            -math.pi / 2,
            -math.pi,
          );
          final terminatorRect = Rect.fromCenter(
            center: moonCenter,
            width: absTerminatorX * moonR * 2,
            height: moonR * 2,
          );
          if (frac < 0.25) {
            shadowPath.addArc(terminatorRect, math.pi / 2, -math.pi);
          } else {
            shadowPath.addArc(terminatorRect, math.pi / 2, math.pi);
          }
        } else {
          shadowPath.addArc(
            Rect.fromCircle(center: moonCenter, radius: moonR),
            -math.pi / 2,
            math.pi,
          );
          final terminatorRect = Rect.fromCenter(
            center: moonCenter,
            width: absTerminatorX * moonR * 2,
            height: moonR * 2,
          );
          if (frac > 0.75) {
            shadowPath.addArc(terminatorRect, math.pi / 2, math.pi);
          } else {
            shadowPath.addArc(terminatorRect, math.pi / 2, -math.pi);
          }
        }

        canvas.save();
        canvas.clipPath(
          Path()..addOval(Rect.fromCircle(center: moonCenter, radius: moonR)),
        );
        canvas.drawPath(shadowPath, shadowPaint);
        canvas.restore();
      } else if (frac <= 0.02) {
        canvas.drawCircle(moonCenter, moonR, shadowPaint);
      }

      canvas.restore();

      // Thin outline
      canvas.drawCircle(
        moonCenter,
        moonR,
        Paint()
          ..color = AppColors.cream.withValues(alpha: 0.5)
          ..strokeWidth = 0.8
          ..style = PaintingStyle.stroke,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _MiniSunArcPainter old) =>
      now != old.now ||
      sunrise != old.sunrise ||
      sunset != old.sunset ||
      isToday != old.isToday ||
      moonFrac != old.moonFrac;
}
