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
          Text(
            weather.description,
            style: style?.copyWith(
              fontWeight: FontWeight.w700,
              fontSize: 18,
              color: AppColors.cream,
            ),
          ),
          const SizedBox(height: 10),
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
        Icon(icon, size: dimmed ? 12 : 14, color: AppColors.cream.withValues(alpha: alpha)),
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
