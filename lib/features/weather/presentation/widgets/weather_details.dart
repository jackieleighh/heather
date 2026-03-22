import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:weather_icons/weather_icons.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/utils/moon_phase.dart';
import '../../../../core/utils/weather_icon_mapper.dart';
import '../../domain/entities/daily_weather.dart';
import '../../domain/entities/hourly_weather.dart';
import '../../domain/entities/minutely_weather.dart';
import '../../domain/entities/weather.dart';
import '../providers/moon_data_provider.dart';

class WeatherDetails extends ConsumerWidget {
  final Weather weather;
  final List<HourlyWeather> hourly;
  final List<MinutelyWeather> minutely15;
  final List<DailyWeather> daily;
  final DateTime locationNow;
  final double latitude;
  final double longitude;
  final int utcOffsetSeconds;
  final bool isDay;

  const WeatherDetails({
    super.key,
    required this.weather,
    required this.hourly,
    this.minutely15 = const [],
    this.daily = const [],
    required this.locationNow,
    required this.latitude,
    required this.longitude,
    required this.utcOffsetSeconds,
    required this.isDay,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final style = GoogleFonts.figtree(
      fontSize: 14,
      fontWeight: FontWeight.w500,
      color: AppColors.cream,
    );

    // USNO moon data for the nighttime chip
    final usno = ref
        .watch(
          moonDataProvider((
            lat: latitude,
            lon: longitude,
            utcOffsetSeconds: utcOffsetSeconds,
          )),
        )
        .valueOrNull;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      // width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.cream.withValues(alpha: 0.18),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.12),
            blurRadius: 12,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          _buildConditionRow(),
          const SizedBox(height: 6),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerRight,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _DetailChip(
                  icon: WeatherIcons.thermometer,
                  label: 'Feels ${weather.feelsLike.round()}°',
                  style: style,
                ),
                const SizedBox(width: 16),
                _DetailChip(
                  icon: WeatherIcons.humidity,
                  label: '${weather.humidity}%',
                  style: style,
                ),
                const SizedBox(width: 16),
                _DetailChip(
                  icon: WeatherIcons.windy,
                  label: '${weather.windSpeed.round()} mph',
                  style: style,
                ),
                const SizedBox(width: 16),
                if (isDay)
                  _DetailChip(
                    icon: WeatherIcons.day_sunny,
                    label: 'UV ${weather.uvIndex.round()}',
                    style: style,
                  )
                else
                  _DetailChip(
                    icon: usno != null
                        ? moonPhaseIcon(usno.fractionForDate(locationNow))
                        : WeatherIcons.moon_waxing_crescent_3,
                    label: usno != null ? '${usno.fracIllum.round()}%' : '— %',
                    style: style,
                  ),
              ],
            ),
          ),
          const SizedBox(height: 6),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerRight,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _DetailChip(
                  icon: WeatherIcons.raindrops,
                  label: 'Dew ${weather.dewPoint.round()}°',
                  style: style,
                  dimmed: true,
                ),
                const SizedBox(width: 16),
                _DetailChip(
                  icon: Icons.visibility_outlined,
                  label: '${weather.visibility.toStringAsFixed(1)} mi',
                  style: style,
                  dimmed: true,
                ),
                const SizedBox(width: 16),
                _DetailChip(
                  icon: WeatherIcons.barometer,
                  label: '${weather.pressure.round()} mb',
                  style: style,
                  dimmed: true,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildConditionRow() {
    final precipLabel = _precipLabel();
    final style = GoogleFonts.figtree(
      fontSize: 18,
      fontWeight: FontWeight.w500,
      color: AppColors.cream,
    );

    // When precipitation is active/imminent, replace condition with precip info
    if (precipLabel != null) {
      // When label has a transition arrow, use the current condition
      // (before →) for icon selection.
      final iconText = precipLabel.split('→').first.toLowerCase();
      final isSnowy =
          iconText.contains('snow') || iconText.contains('flurries');
      final precipIcon = isSnowy
          ? WeatherIcons.snow
          : iconText.contains('slush')
          ? WeatherIcons.sleet
          : iconText.contains('thunder')
          ? WeatherIcons.thunderstorm
          : iconText.contains('drizzle') || iconText.contains('slight rain')
          ? WeatherIcons.sprinkle
          : WeatherIcons.rain;
      return _DetailChip(
        icon: precipIcon,
        label: precipLabel,
        style: style.copyWith(fontSize: 16),
      );
    }

    // No precipitation — show normal condition
    return _DetailChip(
      icon: conditionIcon(weather.weatherCode, isDay: isDay),
      label: weather.description,
      style: style,
    );
  }

  String? _precipLabel() {
    final isRaining = precipConditions.contains(weather.condition);

    // Cross-reference hourly precipitation probability — if very high for
    // the current slot, the condition code may lag behind actual conditions
    // (e.g., API says "overcast" but probability is 99%).
    final currentSlot = hourly
        .where((h) => !h.time.isAfter(locationNow))
        .lastOrNull;
    final probRaining =
        !isRaining &&
        currentSlot != null &&
        currentSlot.precipitationProbability >= 90;

    // Primary: use minutely_15 data for sub-hourly precision
    if (minutely15.isNotEmpty) {
      final forecast = analyzePrecipitation(
        minutely15: minutely15,
        locationNow: locationNow,
        isCurrentlyRaining: isRaining || probRaining,
      );
      final label = formatPrecipLabel(forecast);
      if (label != null) return label;
    }

    // Fallback: hourly weather codes with transition detection
    final hourlyLabel = hourlyPrecipLabel(
      hourly: hourly,
      currentCondition: weather.condition,
      locationNow: locationNow,
      daily: daily,
    );
    if (hourlyLabel != null) return hourlyLabel;

    // Fallback: tomorrow's precipitation probability (nighttime only —
    // during the day the "tonight" / "this afternoon" labels cover it)
    if (!isDay) {
      return tomorrowPrecipLabel(daily: daily, locationNow: locationNow);
    }
    return null;
  }
}

class _DetailChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final TextStyle? style;
  final bool dimmed;

  const _DetailChip({
    required this.icon,
    required this.label,
    this.style,
    this.dimmed = false,
  });

  @override
  Widget build(BuildContext context) {
    final alpha = dimmed ? 0.7 : 0.95;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          size: dimmed ? 12 : 14,
          color: AppColors.cream.withValues(alpha: alpha),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: dimmed
              ? style?.copyWith(
                  fontSize: 12,
                  color: AppColors.cream.withValues(alpha: alpha),
                )
              : style,
        ),
      ],
    );
  }
}
