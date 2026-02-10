import 'package:flutter/material.dart';
import 'package:weather_icons/weather_icons.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/utils/moon_phase.dart';
import '../../domain/entities/weather.dart';

class WeatherDetails extends StatelessWidget {
  final Weather weather;

  const WeatherDetails({super.key, required this.weather});

  @override
  Widget build(BuildContext context) {
    final style = Theme.of(
      context,
    ).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w700);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(weather.description, style: style),
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            _DetailChip(
              icon: WeatherIcons.thermometer,
              label: 'Feels ${weather.feelsLike.round()}°',
              style: style,
            ),
            const SizedBox(width: 20),
            _DetailChip(
              icon: WeatherIcons.humidity,
              label: '${weather.humidity}%',
              style: style,
            ),
            const SizedBox(width: 20),
            _DetailChip(
              icon: WeatherIcons.strong_wind,
              label: '${weather.windSpeed.round()} mph',
              style: style,
            ),
          ],
        ),
        const SizedBox(height: 10),
        _DetailChip(
          icon: moonPhaseIcon(DateTime.now()),
          label: moonPhaseLabel(getMoonPhase(DateTime.now())),
          style: style,
        ),
      ],
    );
  }
}

class _DetailChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final TextStyle? style;

  const _DetailChip({required this.icon, required this.label, this.style});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 18, color: AppColors.cream.withValues(alpha: 0.85)),
        const SizedBox(width: 8),
        Text(label, style: style),
      ],
    );
  }
}
