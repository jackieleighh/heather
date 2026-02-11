import 'dart:ui';

import '../../features/weather/domain/entities/temperature_tier.dart';
import '../../features/weather/domain/entities/weather_condition.dart';
import 'app_colors.dart';

class BackgroundGradients {
  BackgroundGradients._();

  static List<Color> forCondition(
    WeatherCondition condition,
    TemperatureTier tier, {
    required bool isDay,
  }) {
    if (isDay) {
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
    return switch (condition) {
      WeatherCondition.sunny => _sunnyNight[tier]!,
      WeatherCondition.mostlySunny => _mostlySunnyNight[tier]!,
      WeatherCondition.partlyCloudy => _partlyCloudyNight[tier]!,
      WeatherCondition.overcast => _overcastNight[tier]!,
      WeatherCondition.foggy => _foggyNight[tier]!,
      WeatherCondition.drizzle => _drizzleNight[tier]!,
      WeatherCondition.rain => _rainNight[tier]!,
      WeatherCondition.heavyRain => _heavyRainNight[tier]!,
      WeatherCondition.freezingRain => _freezingRainNight[tier]!,
      WeatherCondition.snow => _snowNight[tier]!,
      WeatherCondition.blizzard => _blizzardNight[tier]!,
      WeatherCondition.thunderstorm => _thunderstormNight[tier]!,
      WeatherCondition.hail => _hailNight[tier]!,
      WeatherCondition.unknown => _overcastNight[tier]!,
    };
  }

  // ---------------------------------------------------------------------------
  // DAY GRADIENTS
  // ---------------------------------------------------------------------------

  // Sunny
  static const _sunny = {
    TemperatureTier.singleDigits: [
      AppColors.midnightPurple,
      AppColors.coldIndigo,
      AppColors.icyBlue,
      AppColors.steelGrey,
    ],
    TemperatureTier.freezing: [
      AppColors.slateBlue,
      AppColors.icyBlue,
      AppColors.frostLavender,
      AppColors.coldIndigo,
    ],
    TemperatureTier.jacketWeather: [
      AppColors.slateBlue,
      AppColors.icyBlue,
      AppColors.frostLavender,
      AppColors.teal,
    ],
    TemperatureTier.flannelWeather: [
      AppColors.icyBlue,
      AppColors.chartreuse,
      // AppColors.mustardYellow,
      AppColors.hotAmber,
    ],
    TemperatureTier.shortsWeather: [
      AppColors.mustardYellow,
      AppColors.orange,
      AppColors.warmCoral,
      AppColors.heatPink,
    ],
    TemperatureTier.scorcher: [
      AppColors.hotAmber,
      AppColors.heatPink,
      AppColors.orangeRed,
    ],
  };

  // Sunny night
  static const _sunnyNight = {
    TemperatureTier.singleDigits: [
      AppColors.midnightPurple,
      AppColors.coldIndigo,
      AppColors.slateBlue,
    ],
    TemperatureTier.freezing: [
      AppColors.coldIndigo,
      AppColors.slateBlue,
      AppColors.mutedTeal,
    ],
    TemperatureTier.jacketWeather: [
      AppColors.coldIndigo,
      AppColors.slateBlue,
      AppColors.mutedTeal,
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
      AppColors.magenta,
    ],
  };

  // Mostly sunny
  static const _mostlySunny = _sunny;

  // Mostly sunny night
  static const _mostlySunnyNight = _sunnyNight;

  // Partly cloudy
  static const _partlyCloudy = {
    TemperatureTier.singleDigits: [
      AppColors.midnightPurple,
      AppColors.coldIndigo,
      AppColors.slateBlue,
    ],
    TemperatureTier.freezing: [
      AppColors.coldIndigo,
      AppColors.slateBlue,
      AppColors.steelGrey,
    ],
    TemperatureTier.jacketWeather: [
      AppColors.slateBlue,
      AppColors.steelGrey,
      AppColors.mutedTeal,
    ],
    TemperatureTier.flannelWeather: [
      AppColors.teal,
      AppColors.mutedTeal,
      AppColors.slateBlue,
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

  // Partly cloudy night
  static const _partlyCloudyNight = {
    TemperatureTier.singleDigits: [
      AppColors.midnightPurple,
      AppColors.coldIndigo,
      AppColors.steelGrey,
    ],
    TemperatureTier.freezing: [
      AppColors.midnightPurple,
      AppColors.coldIndigo,
      AppColors.slateBlue,
    ],
    TemperatureTier.jacketWeather: [
      AppColors.midnightPurple,
      AppColors.slateBlue,
      AppColors.coldIndigo,
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

  // Overcast
  static const _overcast = {
    TemperatureTier.singleDigits: [
      AppColors.midnightPurple,
      AppColors.coldIndigo,
      AppColors.steelGrey,
    ],
    TemperatureTier.freezing: [
      AppColors.coldIndigo,
      AppColors.slateBlue,
      AppColors.steelGrey,
    ],
    TemperatureTier.jacketWeather: [
      AppColors.coldIndigo,
      AppColors.slateBlue,
      AppColors.mutedTeal,
    ],
    TemperatureTier.flannelWeather: [
      AppColors.deepPurple,
      AppColors.mutedTeal,
      AppColors.slateBlue,
    ],
    TemperatureTier.shortsWeather: [
      AppColors.mutedTeal,
      AppColors.deepPurple,
      AppColors.slateBlue,
    ],
    TemperatureTier.scorcher: [
      AppColors.goldenYellow,
      AppColors.burntOrange,
      AppColors.mutedTeal,
    ],
  };

  // Overcast night
  static const _overcastNight = {
    TemperatureTier.singleDigits: [
      AppColors.midnightPurple,
      AppColors.coldIndigo,
      AppColors.slateBlue,
    ],
    TemperatureTier.freezing: [
      AppColors.midnightPurple,
      AppColors.coldIndigo,
      AppColors.steelGrey,
    ],
    TemperatureTier.jacketWeather: [
      AppColors.midnightPurple,
      AppColors.coldIndigo,
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
      AppColors.deepPurple,
      AppColors.burntOrange,
    ],
  };

  // Foggy
  static const _foggy = {
    TemperatureTier.singleDigits: [
      AppColors.midnightPurple,
      AppColors.coldIndigo,
      AppColors.steelGrey,
    ],
    TemperatureTier.freezing: [
      AppColors.coldIndigo,
      AppColors.frostLavender,
      AppColors.coldIndigo,
    ],
    TemperatureTier.jacketWeather: [
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
      AppColors.burntOrange,
      AppColors.fogSilver,
      AppColors.warmCoral,
    ],
  };

  // Foggy night
  static const _foggyNight = {
    TemperatureTier.singleDigits: [
      AppColors.midnightPurple,
      AppColors.coldIndigo,
      AppColors.slateBlue,
    ],
    TemperatureTier.freezing: [
      AppColors.midnightPurple,
      AppColors.coldIndigo,
      AppColors.steelGrey,
    ],
    TemperatureTier.jacketWeather: [
      AppColors.midnightPurple,
      AppColors.slateBlue,
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
      AppColors.fogSilver,
    ],
    TemperatureTier.scorcher: [
      AppColors.midnightPurple,
      AppColors.deepPurple,
      AppColors.burntOrange,
    ],
  };

  // Drizzle
  static const _drizzle = {
    TemperatureTier.singleDigits: [
      AppColors.midnightPurple,
      AppColors.coldIndigo,
      AppColors.steelGrey,
    ],
    TemperatureTier.freezing: [
      AppColors.coldIndigo,
      AppColors.steelGrey,
      AppColors.frostLavender,
    ],
    TemperatureTier.jacketWeather: [
      AppColors.slateBlue,
      AppColors.coldIndigo,
      AppColors.frostLavender,
    ],
    TemperatureTier.flannelWeather: [
      AppColors.mutedTeal,
      AppColors.teal,
      AppColors.palePurple,
    ],
    TemperatureTier.shortsWeather: [
      AppColors.teal,
      AppColors.goldenYellow,
      AppColors.hotAmber,
    ],
    TemperatureTier.scorcher: [
      AppColors.teal,
      AppColors.hotAmber,
      AppColors.orangeRed,
    ],
  };

  // Drizzle night
  static const _drizzleNight = {
    TemperatureTier.singleDigits: [
      AppColors.midnightPurple,
      AppColors.coldIndigo,
      AppColors.slateBlue,
    ],
    TemperatureTier.freezing: [
      AppColors.midnightPurple,
      AppColors.coldIndigo,
      AppColors.steelGrey,
    ],
    TemperatureTier.jacketWeather: [
      AppColors.midnightPurple,
      AppColors.coldIndigo,
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
      AppColors.deepPurple,
      AppColors.orangeRed,
    ],
  };

  // Rain
  static const _rain = {
    TemperatureTier.singleDigits: [
      AppColors.midnightPurple,
      AppColors.coldIndigo,
      AppColors.steelGrey,
    ],
    TemperatureTier.freezing: [
      AppColors.coldIndigo,
      AppColors.slateBlue,
      AppColors.steelGrey,
    ],
    TemperatureTier.jacketWeather: [
      AppColors.slateBlue,
      AppColors.mutedTeal,
      AppColors.steelGrey,
    ],
    TemperatureTier.flannelWeather: [
      AppColors.darkTeal,
      AppColors.mutedTeal,
      AppColors.steelGrey,
    ],
    TemperatureTier.shortsWeather: [
      AppColors.darkTeal,
      AppColors.goldenYellow,
      AppColors.mutedTeal,
    ],
    TemperatureTier.scorcher: [
      AppColors.mutedTeal,
      AppColors.hotAmber,
      AppColors.heatPink,
    ],
  };

  // Rain night
  static const _rainNight = {
    TemperatureTier.singleDigits: [
      AppColors.midnightPurple,
      AppColors.coldIndigo,
      AppColors.slateBlue,
    ],
    TemperatureTier.freezing: [
      AppColors.midnightPurple,
      AppColors.coldIndigo,
      AppColors.steelGrey,
    ],
    TemperatureTier.jacketWeather: [
      AppColors.midnightPurple,
      AppColors.coldIndigo,
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
      AppColors.darkTeal,
    ],
    TemperatureTier.scorcher: [
      AppColors.midnightPurple,
      AppColors.deepPurple,
      AppColors.burntOrange,
    ],
  };

  // Heavy rain
  static const _heavyRain = _rain;

  // Heavy rain night
  static const _heavyRainNight = _rainNight;

  // Freezing rain
  static const _freezingRain = {
    TemperatureTier.singleDigits: [
      AppColors.midnightPurple,
      AppColors.coldIndigo,
      AppColors.icyBlue,
    ],
    TemperatureTier.freezing: [
      AppColors.coldIndigo,
      AppColors.icyBlue,
      AppColors.slateBlue,
    ],
    TemperatureTier.jacketWeather: [
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

  // Freezing rain night
  static const _freezingRainNight = {
    TemperatureTier.singleDigits: [
      AppColors.midnightPurple,
      AppColors.coldIndigo,
      AppColors.slateBlue,
    ],
    TemperatureTier.freezing: [
      AppColors.midnightPurple,
      AppColors.coldIndigo,
      AppColors.steelGrey,
    ],
    TemperatureTier.jacketWeather: [
      AppColors.midnightPurple,
      AppColors.coldIndigo,
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
      AppColors.deepPurple,
      AppColors.warmCoral,
    ],
  };

  // Snow
  static const _snow = {
    TemperatureTier.singleDigits: [
      AppColors.palePurple,
      AppColors.coldIndigo,
      AppColors.icyBlue,
    ],
    TemperatureTier.freezing: [
      AppColors.coldIndigo,
      AppColors.icyBlue,
      AppColors.frostLavender,
    ],
    TemperatureTier.jacketWeather: [
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

  // Snow night
  static const _snowNight = {
    TemperatureTier.singleDigits: [
      AppColors.midnightPurple,
      AppColors.coldIndigo,
      AppColors.slateBlue,
    ],
    TemperatureTier.freezing: [
      AppColors.midnightPurple,
      AppColors.coldIndigo,
      AppColors.steelGrey,
    ],
    TemperatureTier.jacketWeather: [
      AppColors.midnightPurple,
      AppColors.coldIndigo,
      AppColors.slateBlue,
    ],
    TemperatureTier.flannelWeather: [
      AppColors.midnightPurple,
      AppColors.deepPurple,
      AppColors.palePurple,
    ],
    TemperatureTier.shortsWeather: [
      AppColors.midnightPurple,
      AppColors.deepPurple,
      AppColors.softMagenta,
    ],
    TemperatureTier.scorcher: [
      AppColors.midnightPurple,
      AppColors.deepPurple,
      AppColors.warmCoral,
    ],
  };

  // Blizzard — severe whiteout, harsh and dark
  static const _blizzard = {
    TemperatureTier.singleDigits: [
      AppColors.palePurple,
      AppColors.coldIndigo,
      AppColors.slateBlue,
    ],
    TemperatureTier.freezing: [
      AppColors.mutedTeal,
      AppColors.coldIndigo,
      AppColors.steelGrey,
    ],
    TemperatureTier.jacketWeather: [
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

  // Blizzard night
  static const _blizzardNight = {
    TemperatureTier.singleDigits: [
      AppColors.midnightPurple,
      AppColors.coldIndigo,
      AppColors.slateBlue,
    ],
    TemperatureTier.freezing: [
      AppColors.midnightPurple,
      AppColors.coldIndigo,
      AppColors.steelGrey,
    ],
    TemperatureTier.jacketWeather: [
      AppColors.midnightPurple,
      AppColors.coldIndigo,
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
      AppColors.darkTeal,
    ],
    TemperatureTier.scorcher: [
      AppColors.midnightPurple,
      AppColors.deepPurple,
      AppColors.heatPink,
    ],
  };

  // Thunderstorm — electric, dramatic with vibrant purple
  static const _thunderstorm = {
    TemperatureTier.singleDigits: [
      AppColors.midnightPurple,
      AppColors.coldIndigo,
      AppColors.deepPurple,
    ],
    TemperatureTier.freezing: [
      AppColors.midnightPurple,
      AppColors.coldIndigo,
      AppColors.slateBlue,
    ],
    TemperatureTier.jacketWeather: [
      AppColors.midnightPurple,
      AppColors.darkTeal,
      AppColors.coldIndigo,
    ],
    TemperatureTier.flannelWeather: [
      AppColors.midnightPurple,
      AppColors.darkTeal,
      AppColors.mutedTeal,
    ],
    TemperatureTier.shortsWeather: [
      AppColors.midnightPurple,
      AppColors.mutedTeal,
      AppColors.deepPurple,
    ],
    TemperatureTier.scorcher: [
      AppColors.midnightPurple,
      AppColors.darkTeal,
      AppColors.burntOrange,
    ],
  };

  // Thunderstorm night
  static const _thunderstormNight = {
    TemperatureTier.singleDigits: [
      AppColors.midnightPurple,
      AppColors.coldIndigo,
      AppColors.deepPurple,
    ],
    TemperatureTier.freezing: [
      AppColors.midnightPurple,
      AppColors.coldIndigo,
      AppColors.slateBlue,
    ],
    TemperatureTier.jacketWeather: [
      AppColors.midnightPurple,
      AppColors.coldIndigo,
      AppColors.deepPurple,
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
      AppColors.coldIndigo,
      AppColors.orangeRed,
    ],
  };

  // Hail — icy and harsh with cold tones
  static const _hail = {
    TemperatureTier.singleDigits: [
      AppColors.midnightPurple,
      AppColors.coldIndigo,
      AppColors.icyBlue,
    ],
    TemperatureTier.freezing: [
      AppColors.coldIndigo,
      AppColors.slateBlue,
      AppColors.steelGrey,
    ],
    TemperatureTier.jacketWeather: [
      AppColors.coldIndigo,
      AppColors.slateBlue,
      AppColors.icyBlue,
    ],
    TemperatureTier.flannelWeather: [
      AppColors.midnightPurple,
      AppColors.slateBlue,
      AppColors.mutedTeal,
    ],
    TemperatureTier.shortsWeather: [
      AppColors.midnightPurple,
      AppColors.mutedTeal,
      AppColors.darkTeal,
    ],
    TemperatureTier.scorcher: [
      AppColors.deepPurple,
      AppColors.burntOrange,
      AppColors.steelGrey,
    ],
  };

  // Hail night
  static const _hailNight = {
    TemperatureTier.singleDigits: [
      AppColors.midnightPurple,
      AppColors.coldIndigo,
      AppColors.slateBlue,
    ],
    TemperatureTier.freezing: [
      AppColors.midnightPurple,
      AppColors.coldIndigo,
      AppColors.steelGrey,
    ],
    TemperatureTier.jacketWeather: [
      AppColors.midnightPurple,
      AppColors.coldIndigo,
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
      AppColors.deepPurple,
      AppColors.orangeRed,
    ],
  };
}
