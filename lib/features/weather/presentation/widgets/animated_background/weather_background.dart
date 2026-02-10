import 'package:flutter/material.dart';

import '../../../domain/entities/weather_condition.dart';
import 'clear_background.dart';
import 'cloudy_background.dart';
import 'fog_background.dart';
import 'rain_background.dart';
import 'snow_background.dart';
import 'sunny_background.dart';
import 'thunderstorm_background.dart';

class WeatherBackground extends StatelessWidget {
  final WeatherCondition condition;
  final bool isDay;

  const WeatherBackground({
    super.key,
    required this.condition,
    required this.isDay,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 800),
      child: KeyedSubtree(
        key: ValueKey('${condition.name}_$isDay'),
        child: _buildBackground(),
      ),
    );
  }

  Widget _buildBackground() {
    return switch (condition) {
      WeatherCondition.clear =>
        isDay ? const SunnyBackground() : ClearBackground(isDay: isDay),
      WeatherCondition.cloudy => const CloudyBackground(),
      WeatherCondition.rain ||
      WeatherCondition.drizzle => const RainBackground(),
      WeatherCondition.snow => const SnowBackground(),
      WeatherCondition.thunderstorm => const ThunderstormBackground(),
      WeatherCondition.fog => const FogBackground(),
    };
  }
}
