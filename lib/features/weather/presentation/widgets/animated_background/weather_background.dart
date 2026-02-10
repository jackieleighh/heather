import 'package:flutter/material.dart';

import '../../../../../core/constants/app_colors.dart';
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

  const WeatherBackground({
    super.key,
    required this.condition,
    required this.isDay,
    required this.temperature,
  });

  TemperatureTier get _tier => TemperatureTier.fromTemperature(temperature);

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 800),
      child: KeyedSubtree(
        key: ValueKey(
          condition.isMild
              ? '${condition.name}_${isDay}_${_tier.name}'
              : '${condition.name}_$isDay',
        ),
        child: _buildBackground(),
      ),
    );
  }

  Widget _buildBackground() {
    if (condition.isMild) {
      final colors = BackgroundGradients.forCondition(condition, _tier);
      return switch (condition) {
        WeatherCondition.sunny => isDay
            ? SunnyBackground(gradientColors: colors)
            : ClearBackground(
                isDay: isDay,
                gradientColors: BackgroundGradients.sunnyNight(_tier),
              ),
        WeatherCondition.mostlySunny =>
          MostlySunnyBackground(gradientColors: colors),
        WeatherCondition.partlyCloudy =>
          PartlyCloudyBackground(gradientColors: colors),
        WeatherCondition.overcast =>
          OvercastBackground(gradientColors: colors),
        _ => const _DefaultBackground(),
      };
    }

    return switch (condition) {
      WeatherCondition.foggy => const FogBackground(),
      WeatherCondition.drizzle => const DrizzleBackground(),
      WeatherCondition.rain => const RainBackground(),
      WeatherCondition.heavyRain => const HeavyRainBackground(),
      WeatherCondition.freezingRain => const FreezingRainBackground(),
      WeatherCondition.snow => const SnowBackground(),
      WeatherCondition.blizzard => const BlizzardBackground(),
      WeatherCondition.thunderstorm => const ThunderstormBackground(),
      WeatherCondition.hail => const HailBackground(),
      _ => const _DefaultBackground(),
    };
  }
}

class _DefaultBackground extends StatelessWidget {
  const _DefaultBackground();

  @override
  Widget build(BuildContext context) {
    return Container(color: AppColors.magenta);
  }
}
