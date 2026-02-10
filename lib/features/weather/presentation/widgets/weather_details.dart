import 'package:flutter/material.dart';
import 'package:weather_icons/weather_icons.dart';

import '../../domain/entities/weather.dart';

class WeatherDetails extends StatelessWidget {
  final Weather weather;

  const WeatherDetails({super.key, required this.weather});

  @override
  Widget build(BuildContext context) {
    final style = Theme.of(
      context,
    ).textTheme.bodySmall;

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
        Icon(icon, size: 18, color: Colors.black54),
        const SizedBox(width: 5),
        Text(label, style: style),
      ],
    );
  }
}
