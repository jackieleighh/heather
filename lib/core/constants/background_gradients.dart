import 'dart:ui';

import '../../features/weather/domain/entities/temperature_tier.dart';
import '../../features/weather/domain/entities/weather_condition.dart';
import 'app_colors.dart';

class BackgroundGradients {
  BackgroundGradients._();

  static List<Color> forCondition(
    WeatherCondition condition,
    TemperatureTier tier,
  ) {
    return switch (condition) {
      WeatherCondition.sunny => _sunny[tier]!,
      WeatherCondition.mostlySunny => _mostlySunny[tier]!,
      WeatherCondition.partlyCloudy => _partlyCloudy[tier]!,
      WeatherCondition.overcast => _overcast[tier]!,
      _ => throw ArgumentError('$condition is not a mild condition'),
    };
  }

  /// Night-specific gradients for sunny/clear condition.
  static List<Color> sunnyNight(TemperatureTier tier) => _sunnyNight[tier]!;

  // Sunny
  static const _sunny = {
    TemperatureTier.freezing: [
      AppColors.slateBlue,
      AppColors.icyBlue,
      AppColors.frostLavender,
      AppColors.coldIndigo,
    ],
    TemperatureTier.prettyCold: [
      AppColors.slateBlue,
      AppColors.icyBlue,
      AppColors.frostLavender,
      AppColors.coldIndigo,
    ],
    TemperatureTier.flannelWeather: [
      AppColors.chartreuse,
      AppColors.mustardYellow,
      AppColors.orange,
      AppColors.magenta,
    ],
    TemperatureTier.shortsWeather: [
      AppColors.chartreuse,
      AppColors.mustardYellow,
      AppColors.orange,
      AppColors.magenta,
    ],
    TemperatureTier.scorcher: [
      AppColors.goldenYellow,
      AppColors.hotAmber,
      AppColors.burntOrange,
      AppColors.heatPink,
    ],
  };

  // Sunny night
  static const _sunnyNight = {
    TemperatureTier.freezing: [
      AppColors.coldIndigo,
      AppColors.slateBlue,
      AppColors.steelGrey,
    ],
    TemperatureTier.prettyCold: [
      AppColors.coldIndigo,
      AppColors.slateBlue,
      AppColors.steelGrey,
    ],
    TemperatureTier.flannelWeather: [
      AppColors.midnightPurple,
      AppColors.deepPurple,
      AppColors.darkTeal,
    ],
    TemperatureTier.shortsWeather: [
      AppColors.midnightPurple,
      AppColors.deepPurple,
      AppColors.darkTeal,
    ],
    TemperatureTier.scorcher: [
      AppColors.midnightPurple,
      AppColors.deepPurple,
      AppColors.heatPink,
    ],
  };

  // Mostly sunny
  static const _mostlySunny = {
    TemperatureTier.freezing: [
      AppColors.steelGrey,
      AppColors.icyBlue,
      AppColors.slateBlue,
      AppColors.coldIndigo,
    ],
    TemperatureTier.prettyCold: [
      AppColors.steelGrey,
      AppColors.icyBlue,
      AppColors.slateBlue,
      AppColors.coldIndigo,
    ],
    TemperatureTier.flannelWeather: [
      AppColors.chartreuse,
      AppColors.mustardYellow,
      AppColors.teal,
      AppColors.vibrantPurple,
    ],
    TemperatureTier.shortsWeather: [
      AppColors.chartreuse,
      AppColors.mustardYellow,
      AppColors.teal,
      AppColors.vibrantPurple,
    ],
    TemperatureTier.scorcher: [
      AppColors.goldenYellow,
      AppColors.hotAmber,
      AppColors.warmCoral,
      AppColors.heatPink,
    ],
  };

  // Partly cloudy
  static const _partlyCloudy = {
    TemperatureTier.freezing: [
      AppColors.slateBlue,
      AppColors.steelGrey,
      AppColors.frostLavender,
    ],
    TemperatureTier.prettyCold: [
      AppColors.slateBlue,
      AppColors.steelGrey,
      AppColors.frostLavender,
    ],
    TemperatureTier.flannelWeather: [
      AppColors.teal,
      AppColors.mutedTeal,
      AppColors.palePurple,
    ],
    TemperatureTier.shortsWeather: [
      AppColors.teal,
      AppColors.mutedTeal,
      AppColors.palePurple,
    ],
    TemperatureTier.scorcher: [
      AppColors.hotAmber,
      AppColors.warmCoral,
      AppColors.heatPink,
    ],
  };

  // Overcast
  static const _overcast = {
    TemperatureTier.freezing: [
      AppColors.coldIndigo,
      AppColors.slateBlue,
      AppColors.frostLavender,
    ],
    TemperatureTier.prettyCold: [
      AppColors.coldIndigo,
      AppColors.slateBlue,
      AppColors.frostLavender,
    ],
    TemperatureTier.flannelWeather: [
      AppColors.deepPurple,
      AppColors.mutedTeal,
      AppColors.fogSilver,
    ],
    TemperatureTier.shortsWeather: [
      AppColors.deepPurple,
      AppColors.mutedTeal,
      AppColors.fogSilver,
    ],
    TemperatureTier.scorcher: [
      AppColors.heatPink,
      AppColors.warmCoral,
      AppColors.goldenYellow,
    ],
  };
}
