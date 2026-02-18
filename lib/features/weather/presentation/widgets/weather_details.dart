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
    ).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w600, fontSize: 14);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.cream.withValues(alpha: 0.22),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(
            weather.description,
            style: style?.copyWith(
              fontWeight: FontWeight.w700,
              fontSize: 18,
              color: AppColors.cream,
            ),
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
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
              if (weather.isDay)
                _DetailChip(
                  icon: WeatherIcons.day_sunny,
                  label: 'UV ${weather.uvIndex.round()}',
                  style: style,
                )
              else
                _DetailChip(
                  icon: moonPhaseIcon(DateTime.now()),
                  label: '${moonIllumination(DateTime.now()).round()}%',
                  style: style,
                ),
            ],
          ),
        ],
      ),
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
        Icon(icon, size: 14, color: AppColors.cream.withValues(alpha: 0.95)),
        const SizedBox(width: 6),
        Text(label, style: style),
      ],
    );
  }
}
