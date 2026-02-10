import 'package:flutter/material.dart';

import '../../domain/entities/weather.dart';

class WeatherDetails extends StatelessWidget {
  final Weather weather;

  const WeatherDetails({super.key, required this.weather});

  @override
  Widget build(BuildContext context) {
    final style = Theme.of(
      context,
    ).textTheme.bodySmall?.copyWith(shadows: _textShadows);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(weather.description, style: style),
        const SizedBox(height: 10),
        Row(
          children: [
            _DetailChip(
              icon: Icons.thermostat_outlined,
              label: 'Feels ${weather.feelsLike.round()}°',
              style: style,
            ),
            const SizedBox(width: 20),
            _DetailChip(
              icon: Icons.water_drop_outlined,
              label: '${weather.humidity}%',
              style: style,
            ),
            const SizedBox(width: 20),
            _DetailChip(
              icon: Icons.air,
              label: '${weather.windSpeed.round()} mph',
              style: style,
            ),
          ],
        ),
      ],
    );
  }

  static const _textShadows = [
    Shadow(color: Colors.black26, blurRadius: 4, offset: Offset(0, 1)),
  ];
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
        Icon(icon, size: 18, color: Colors.white70),
        const SizedBox(width: 5),
        Text(label, style: style),
      ],
    );
  }
}
