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
      WeatherCondition.foggy => _foggy[tier]!,
      WeatherCondition.drizzle => _drizzle[tier]!,
      WeatherCondition.rain => _rain[tier]!,
      WeatherCondition.heavyRain => _heavyRain[tier]!,
      WeatherCondition.freezingRain => _freezingRain[tier]!,
      WeatherCondition.snow => _snow[tier]!,
      WeatherCondition.blizzard => _blizzard[tier]!,
      WeatherCondition.thunderstorm => _thunderstorm[tier]!,
      WeatherCondition.hail => _hail[tier]!,
      WeatherCondition.unknown => _overcast[tier]!,
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
      AppColors.icyBlue,
      AppColors.slateBlue,
      AppColors.frostLavender,
      AppColors.steelGrey,
    ],
    TemperatureTier.flannelWeather: [
      AppColors.chartreuse,
      AppColors.mustardYellow,
      AppColors.orange,
      AppColors.magenta,
    ],
    TemperatureTier.shortsWeather: [
      AppColors.mustardYellow,
      AppColors.orange,
      AppColors.warmCoral,
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
      AppColors.slateBlue,
      AppColors.coldIndigo,
      AppColors.frostLavender,
    ],
    TemperatureTier.flannelWeather: [
      AppColors.midnightPurple,
      AppColors.deepPurple,
      AppColors.darkTeal,
    ],
    TemperatureTier.shortsWeather: [
      AppColors.midnightPurple,
      AppColors.deepPurple,
      AppColors.mutedTeal,
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
      AppColors.icyBlue,
      AppColors.frostLavender,
      AppColors.slateBlue,
      AppColors.steelGrey,
    ],
    TemperatureTier.flannelWeather: [
      AppColors.chartreuse,
      AppColors.mustardYellow,
      AppColors.teal,
      AppColors.vibrantPurple,
    ],
    TemperatureTier.shortsWeather: [
      AppColors.mustardYellow,
      AppColors.orange,
      AppColors.teal,
      AppColors.magenta,
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
      AppColors.steelGrey,
      AppColors.frostLavender,
      AppColors.palePurple,
    ],
    TemperatureTier.flannelWeather: [
      AppColors.teal,
      AppColors.mutedTeal,
      AppColors.palePurple,
    ],
    TemperatureTier.shortsWeather: [
      AppColors.mustardYellow,
      AppColors.teal,
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
      AppColors.slateBlue,
      AppColors.steelGrey,
      AppColors.frostLavender,
    ],
    TemperatureTier.flannelWeather: [
      AppColors.deepPurple,
      AppColors.mutedTeal,
      AppColors.fogSilver,
    ],
    TemperatureTier.shortsWeather: [
      AppColors.mutedTeal,
      AppColors.deepPurple,
      AppColors.palePurple,
    ],
    TemperatureTier.scorcher: [
      AppColors.heatPink,
      AppColors.warmCoral,
      AppColors.goldenYellow,
    ],
  };

  // Foggy
  static const _foggy = {
    TemperatureTier.freezing: [
      AppColors.coldIndigo,
      AppColors.frostLavender,
      AppColors.coldIndigo,
    ],
    TemperatureTier.prettyCold: [
      AppColors.slateBlue,
      AppColors.frostLavender,
      AppColors.slateBlue,
    ],
    TemperatureTier.flannelWeather: [
      AppColors.mutedTeal,
      AppColors.fogSilver,
      AppColors.mutedTeal,
    ],
    TemperatureTier.shortsWeather: [
      AppColors.fogSilver,
      AppColors.mutedTeal,
      AppColors.palePurple,
    ],
    TemperatureTier.scorcher: [
      AppColors.warmCoral,
      AppColors.fogSilver,
      AppColors.hotAmber,
    ],
  };

  // Drizzle
  static const _drizzle = {
    TemperatureTier.freezing: [
      AppColors.coldIndigo,
      AppColors.deepPurple,
      AppColors.frostLavender,
    ],
    TemperatureTier.prettyCold: [
      AppColors.slateBlue,
      AppColors.deepPurple,
      AppColors.frostLavender,
    ],
    TemperatureTier.flannelWeather: [
      AppColors.mutedTeal,
      AppColors.deepPurple,
      AppColors.palePurple,
    ],
    TemperatureTier.shortsWeather: [
      AppColors.teal,
      AppColors.vibrantPurple,
      AppColors.palePurple,
    ],
    TemperatureTier.scorcher: [
      AppColors.hotAmber,
      AppColors.deepPurple,
      AppColors.warmCoral,
    ],
  };

  // Rain
  static const _rain = {
    TemperatureTier.freezing: [
      AppColors.coldIndigo,
      AppColors.slateBlue,
      AppColors.steelGrey,
    ],
    TemperatureTier.prettyCold: [
      AppColors.slateBlue,
      AppColors.deepPurple,
      AppColors.steelGrey,
    ],
    TemperatureTier.flannelWeather: [
      AppColors.darkTeal,
      AppColors.deepPurple,
      AppColors.mutedTeal,
    ],
    TemperatureTier.shortsWeather: [
      AppColors.darkTeal,
      AppColors.vibrantPurple,
      AppColors.mutedTeal,
    ],
    TemperatureTier.scorcher: [
      AppColors.hotAmber,
      AppColors.deepPurple,
      AppColors.warmCoral,
    ],
  };

  // Heavy rain
  static const _heavyRain = {
    TemperatureTier.freezing: [
      AppColors.coldIndigo,
      AppColors.deepPurple,
      AppColors.steelGrey,
    ],
    TemperatureTier.prettyCold: [
      AppColors.coldIndigo,
      AppColors.deepPurple,
      AppColors.slateBlue,
    ],
    TemperatureTier.flannelWeather: [
      AppColors.midnightPurple,
      AppColors.deepPurple,
      AppColors.darkTeal,
    ],
    TemperatureTier.shortsWeather: [
      AppColors.midnightPurple,
      AppColors.deepPurple,
      AppColors.mutedTeal,
    ],
    TemperatureTier.scorcher: [
      AppColors.midnightPurple,
      AppColors.heatPink,
      AppColors.hotAmber,
    ],
  };

  // Freezing rain
  static const _freezingRain = {
    TemperatureTier.freezing: [
      AppColors.coldIndigo,
      AppColors.icyBlue,
      AppColors.slateBlue,
    ],
    TemperatureTier.prettyCold: [
      AppColors.slateBlue,
      AppColors.icyBlue,
      AppColors.deepPurple,
    ],
    TemperatureTier.flannelWeather: [
      AppColors.palePurple,
      AppColors.darkTeal,
      AppColors.deepPurple,
    ],
    TemperatureTier.shortsWeather: [
      AppColors.teal,
      AppColors.darkTeal,
      AppColors.vibrantPurple,
    ],
    TemperatureTier.scorcher: [
      AppColors.warmCoral,
      AppColors.darkTeal,
      AppColors.hotAmber,
    ],
  };

  // Snow
  static const _snow = {
    TemperatureTier.freezing: [
      AppColors.coldIndigo,
      AppColors.icyBlue,
      AppColors.frostLavender,
    ],
    TemperatureTier.prettyCold: [
      AppColors.slateBlue,
      AppColors.frostLavender,
      AppColors.palePurple,
    ],
    TemperatureTier.flannelWeather: [
      AppColors.palePurple,
      AppColors.softMagenta,
      AppColors.palePurple,
    ],
    TemperatureTier.shortsWeather: [
      AppColors.softMagenta,
      AppColors.palePurple,
      AppColors.mutedTeal,
    ],
    TemperatureTier.scorcher: [
      AppColors.warmCoral,
      AppColors.softMagenta,
      AppColors.hotAmber,
    ],
  };

  // Blizzard — severe whiteout, harsh and dark
  static const _blizzard = {
    TemperatureTier.freezing: [
      AppColors.midnightPurple,
      AppColors.coldIndigo,
      AppColors.steelGrey,
    ],
    TemperatureTier.prettyCold: [
      AppColors.coldIndigo,
      AppColors.deepPurple,
      AppColors.steelGrey,
    ],
    TemperatureTier.flannelWeather: [
      AppColors.midnightPurple,
      AppColors.deepPurple,
      AppColors.mutedTeal,
    ],
    TemperatureTier.shortsWeather: [
      AppColors.midnightPurple,
      AppColors.deepPurple,
      AppColors.teal,
    ],
    TemperatureTier.scorcher: [
      AppColors.midnightPurple,
      AppColors.heatPink,
      AppColors.warmCoral,
    ],
  };

  // Thunderstorm — electric, dramatic with vibrant purple
  static const _thunderstorm = {
    TemperatureTier.freezing: [
      AppColors.midnightPurple,
      AppColors.coldIndigo,
      AppColors.slateBlue,
    ],
    TemperatureTier.prettyCold: [
      AppColors.midnightPurple,
      AppColors.deepPurple,
      AppColors.coldIndigo,
    ],
    TemperatureTier.flannelWeather: [
      AppColors.midnightPurple,
      AppColors.vibrantPurple,
      AppColors.darkTeal,
    ],
    TemperatureTier.shortsWeather: [
      AppColors.midnightPurple,
      AppColors.vibrantPurple,
      AppColors.deepPurple,
    ],
    TemperatureTier.scorcher: [
      AppColors.midnightPurple,
      AppColors.vibrantPurple,
      AppColors.heatPink,
    ],
  };

  // Hail — icy and harsh with cold tones
  static const _hail = {
    TemperatureTier.freezing: [
      AppColors.coldIndigo,
      AppColors.icyBlue,
      AppColors.steelGrey,
    ],
    TemperatureTier.prettyCold: [
      AppColors.coldIndigo,
      AppColors.slateBlue,
      AppColors.icyBlue,
    ],
    TemperatureTier.flannelWeather: [
      AppColors.deepPurple,
      AppColors.slateBlue,
      AppColors.mutedTeal,
    ],
    TemperatureTier.shortsWeather: [
      AppColors.deepPurple,
      AppColors.mutedTeal,
      AppColors.teal,
    ],
    TemperatureTier.scorcher: [
      AppColors.deepPurple,
      AppColors.heatPink,
      AppColors.steelGrey,
    ],
  };
}
