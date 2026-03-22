import 'package:flutter/material.dart';

import '../../../../../core/constants/background_gradients.dart';
import '../../../domain/entities/temperature_tier.dart';
import '../../../domain/entities/weather_condition.dart';
import 'blizzard_background.dart';
import 'clear_background.dart';
import 'drizzle_background.dart';
import 'fog_background.dart';
import 'freezing_rain_background.dart';
import 'hail_background.dart';
import 'heavy_rain_background.dart';
import 'mostly_sunny_background.dart';
import 'overcast_background.dart';
import 'partly_cloudy_background.dart';
import 'rain_background.dart';
import 'snow_background.dart';
import 'sunny_background.dart';
import 'thunderstorm_background.dart';

class WeatherBackground extends StatelessWidget {
  final WeatherCondition condition;
  final bool isDay;
  final double temperature;
  final bool isActive;

  const WeatherBackground({
    super.key,
    required this.condition,
    required this.isDay,
    required this.temperature,
    this.isActive = true,
  });

  TemperatureTier get _tier => TemperatureTier.fromTemperature(temperature);

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 250),
      transitionBuilder: (child, animation) {
        return FadeTransition(
          opacity: CurvedAnimation(
            parent: animation,
            curve: Curves.easeOut,
          ),
          child: child,
        );
      },
      child: KeyedSubtree(
        key: ValueKey('${condition.name}_${isDay}_${_tier.name}'),
        child: _buildBackground(),
      ),
    );
  }

  Widget _buildBackground() {
    final colors =
        BackgroundGradients.forCondition(condition, _tier, isDay: isDay);
    return switch (condition) {
      WeatherCondition.sunny =>
        isDay
            ? SunnyBackground(gradientColors: colors, isActive: isActive)
            : ClearBackground(isDay: isDay, gradientColors: colors, isActive: isActive),
      WeatherCondition.mostlySunny => MostlySunnyBackground(
        isDay: isDay,
        gradientColors: colors,
        isActive: isActive,
      ),
      WeatherCondition.partlyCloudy => PartlyCloudyBackground(
        isDay: isDay,
        gradientColors: colors,
        isActive: isActive,
      ),
      WeatherCondition.overcast => OvercastBackground(gradientColors: colors, isActive: isActive),
      WeatherCondition.foggy => FogBackground(gradientColors: colors, isActive: isActive),
      WeatherCondition.drizzle => DrizzleBackground(gradientColors: colors, isActive: isActive),
      WeatherCondition.rain => RainBackground(gradientColors: colors, isActive: isActive),
      WeatherCondition.heavyRain => HeavyRainBackground(gradientColors: colors, isActive: isActive),
      WeatherCondition.freezingRain => FreezingRainBackground(
        gradientColors: colors,
        isActive: isActive,
      ),
      WeatherCondition.snow => SnowBackground(gradientColors: colors, isActive: isActive),
      WeatherCondition.blizzard => BlizzardBackground(gradientColors: colors, isActive: isActive),
      WeatherCondition.thunderstorm => ThunderstormBackground(
        gradientColors: colors,
        isActive: isActive,
      ),
      WeatherCondition.hail => HailBackground(gradientColors: colors, isActive: isActive),
      WeatherCondition.unknown => const _DefaultBackground(),
    };
  }
}

class _DefaultBackground extends StatelessWidget {
  const _DefaultBackground();

  @override
  Widget build(BuildContext context) {
    return Container(color: Theme.of(context).colorScheme.secondary);
  }
}
