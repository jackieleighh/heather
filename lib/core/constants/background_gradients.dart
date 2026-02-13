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
      AppColors.palePurple,
      AppColors.frostLavender,
      AppColors.icyBlue,
    ],
    TemperatureTier.freezing: [
      AppColors.palePurple,
      AppColors.mutedTeal,
      AppColors.icyBlue,
    ],
    TemperatureTier.jacketWeather: [
      AppColors.mutedTeal,
      AppColors.icyBlue,
      AppColors.teal,
    ],
    TemperatureTier.flannelWeather: [
      AppColors.icyBlue,
      AppColors.chartreuse,
      AppColors.goldenYellow,
    ],
    TemperatureTier.shortsWeather: [
      AppColors.chartreuse,
      AppColors.goldenYellow,
      AppColors.orange,
    ],
    TemperatureTier.scorcher: [
      AppColors.hotAmber,
      AppColors.orange,
      AppColors.heatPink,
    ],
  };

  // --- Sunny Night Gradient Map ---
  // These use the refined colors above to ensure a dark, atmospheric feel.
  static const _sunnyNight = {
    TemperatureTier.singleDigits: [
      AppColors.pitchBlack,
      AppColors.darkIndigo,
      AppColors.darkTeal,
    ],
    TemperatureTier.freezing: [
      AppColors.pitchBlack,
      AppColors.darkIndigo,
      AppColors.coldIndigo,
    ],
    TemperatureTier.jacketWeather: [
      AppColors.midnightPurple,
      AppColors.deepPurple,
      AppColors.coldIndigo,
    ],
    TemperatureTier.flannelWeather: [
      AppColors.midnightPurple,
      AppColors.deepPurple,
      AppColors.darkTeal,
    ],
    TemperatureTier.shortsWeather: [
      AppColors.pitchBlack,
      AppColors.midnightPurple,
      AppColors.burntOrange,
    ],
    TemperatureTier.scorcher: [
      AppColors.pitchBlack,
      AppColors.midnightPurple,
      AppColors.orangeRed,
    ],
  };

  // Mostly sunny
  static const _mostlySunny = _sunny;

  // Mostly sunny night
  static const _mostlySunnyNight = _sunnyNight;

  static const _partlyCloudy = {
    TemperatureTier.singleDigits: [
      AppColors.fogSilver,
      AppColors.steelGrey,
      AppColors.icyBlue,
    ],
    TemperatureTier.freezing: [
      AppColors.steelGrey,
      AppColors.slateBlue,
      AppColors.mutedTeal,
    ],
    TemperatureTier.jacketWeather: [
      AppColors.slateBlue,
      AppColors.mutedTeal,
      AppColors.royalBlue,
    ],
    TemperatureTier.flannelWeather: [
      AppColors.steelGrey,
      AppColors.icyBlue,
      AppColors.chartreuse,
    ],
    TemperatureTier.shortsWeather: [
      AppColors.steelGrey,
      AppColors.chartreuse,
      AppColors.mustardYellow,
    ],
    TemperatureTier.scorcher: [
      AppColors.slateBlue,
      AppColors.burntOrange,
      AppColors.hotAmber,
    ],
  };

  static const _partlyCloudyNight = {
    TemperatureTier.singleDigits: [
      AppColors.pitchBlack,
      AppColors.darkIndigo,
      AppColors.slateBlue,
    ],
    TemperatureTier.freezing: [
      AppColors.midnightPurple,
      AppColors.darkIndigo,
      AppColors.steelGrey,
    ],
    TemperatureTier.jacketWeather: [
      AppColors.midnightPurple,
      AppColors.darkTeal,
      AppColors.deepPurple,
    ],
    TemperatureTier.flannelWeather: [
      AppColors.darkIndigo,
      AppColors.deepPurple,
      AppColors.darkMagenta,
    ],
    TemperatureTier.shortsWeather: [
      AppColors.midnightPurple,
      AppColors.darkMagenta,
      AppColors.dullOrange,
    ],
    TemperatureTier.scorcher: [
      AppColors.pitchBlack,
      AppColors.darkMagenta,
      AppColors.orangeRed,
    ],
  };

  static const _overcast = {
    TemperatureTier.singleDigits: [
      AppColors.steelGrey,
      AppColors.slateBlue,
      AppColors.coldIndigo,
    ],
    TemperatureTier.freezing: [
      AppColors.fogSilver,
      AppColors.steelGrey,
      AppColors.slateBlue,
    ],
    TemperatureTier.jacketWeather: [
      AppColors.steelGrey,
      AppColors.slateBlue,
      AppColors.mutedTeal,
    ],
    TemperatureTier.flannelWeather: [
      AppColors.slateBlue,
      AppColors.mutedTeal,
      AppColors.deepPurple,
    ],
    TemperatureTier.shortsWeather: [
      AppColors.steelGrey,
      AppColors.deepPurple,
      AppColors.darkTeal,
    ],
    TemperatureTier.scorcher: [
      AppColors.slateBlue,
      AppColors.burntOrange,
      AppColors.darkMagenta,
    ],
  };

  static const _overcastNight = {
    TemperatureTier.singleDigits: [
      AppColors.pitchBlack,
      AppColors.darkIndigo,
      AppColors.steelGrey,
    ],
    TemperatureTier.freezing: [
      AppColors.midnightPurple,
      AppColors.darkIndigo,
      AppColors.slateBlue,
    ],
    TemperatureTier.jacketWeather: [
      AppColors.midnightPurple,
      AppColors.darkIndigo,
      AppColors.darkTeal,
    ],
    TemperatureTier.flannelWeather: [
      AppColors.midnightPurple,
      AppColors.deepPurple,
      AppColors.darkIndigo,
    ],
    TemperatureTier.shortsWeather: [
      AppColors.midnightPurple,
      AppColors.deepPurple,
      AppColors.darkMagenta,
    ],
    TemperatureTier.scorcher: [
      AppColors.midnightPurple,
      AppColors.darkMagenta,
      AppColors.orangeRed,
    ],
  };

  // Foggy
  static const _foggy = _overcast;

  // Foggy night
  static const _foggyNight = _overcastNight;

  // Drizzle
  static const _drizzle = {
    TemperatureTier.singleDigits: [
      AppColors.fogSilver,
      AppColors.steelGrey,
      AppColors.slateBlue,
    ],
    TemperatureTier.freezing: [
      AppColors.fogSilver,
      AppColors.steelGrey,
      AppColors.icyBlue,
    ],
    TemperatureTier.jacketWeather: [
      AppColors.steelGrey,
      AppColors.mutedTeal,
      AppColors.slateBlue,
    ],
    TemperatureTier.flannelWeather: [
      AppColors.steelGrey,
      AppColors.slateBlue,
      AppColors.vibrantPurple,
    ],
    TemperatureTier.shortsWeather: [
      AppColors.steelGrey,
      AppColors.slateBlue,
      AppColors.magenta,
    ],
    TemperatureTier.scorcher: [
      AppColors.slateBlue,
      AppColors.darkMagenta,
      AppColors.warmCoral,
    ],
  };

  static const _drizzleNight = {
    TemperatureTier.singleDigits: [
      AppColors.pitchBlack,
      AppColors.darkIndigo,
      AppColors.steelGrey,
    ],
    TemperatureTier.freezing: [
      AppColors.midnightPurple,
      AppColors.darkIndigo,
      AppColors.slateBlue,
    ],
    TemperatureTier.jacketWeather: [
      AppColors.midnightPurple,
      AppColors.darkIndigo,
      AppColors.darkTeal,
    ],
    TemperatureTier.flannelWeather: [
      AppColors.midnightPurple,
      AppColors.deepPurple,
      AppColors.darkIndigo,
    ],
    TemperatureTier.shortsWeather: [
      AppColors.midnightPurple,
      AppColors.darkMagenta,
      AppColors.burntOrange,
    ],
    TemperatureTier.scorcher: [
      AppColors.pitchBlack,
      AppColors.darkMagenta,
      AppColors.orangeRed,
    ],
  };

  // Rain
  static const _rain = {
    TemperatureTier.singleDigits: [
      AppColors.steelGrey,
      AppColors.slateBlue,
      AppColors.coldIndigo,
    ],
    TemperatureTier.freezing: [
      AppColors.slateBlue,
      AppColors.coldIndigo,
      AppColors.royalBlue,
    ],
    TemperatureTier.jacketWeather: [
      AppColors.slateBlue,
      AppColors.royalBlue,
      AppColors.darkTeal,
    ],
    TemperatureTier.flannelWeather: [
      AppColors.slateBlue,
      AppColors.electricIndigo,
      AppColors.deepPurple,
    ],
    TemperatureTier.shortsWeather: [
      AppColors.darkIndigo,
      AppColors.deepPurple,
      AppColors.magenta,
    ],
    TemperatureTier.scorcher: [
      AppColors.darkIndigo,
      AppColors.darkMagenta,
      AppColors.orangeRed,
    ],
  };

  static const _rainNight = {
    TemperatureTier.singleDigits: [
      AppColors.pitchBlack,
      AppColors.midnightBlue,
      AppColors.coldIndigo,
    ],
    TemperatureTier.freezing: [
      AppColors.pitchBlack,
      AppColors.darkIndigo,
      AppColors.royalBlue,
    ],
    TemperatureTier.jacketWeather: [
      AppColors.pitchBlack,
      AppColors.darkIndigo,
      AppColors.darkTeal,
    ],
    TemperatureTier.flannelWeather: [
      AppColors.pitchBlack,
      AppColors.midnightPurple,
      AppColors.deepPurple,
    ],
    TemperatureTier.shortsWeather: [
      AppColors.pitchBlack,
      AppColors.midnightPurple,
      AppColors.darkMagenta,
    ],
    TemperatureTier.scorcher: [
      AppColors.pitchBlack,
      AppColors.darkIndigo,
      AppColors.orangeRed,
    ],
  };

  // Heavy rain
  static const _heavyRain = {
    TemperatureTier.singleDigits: [
      AppColors.darkIndigo,
      AppColors.coldIndigo,
      AppColors.royalBlue,
    ],
    TemperatureTier.freezing: [
      AppColors.darkIndigo,
      AppColors.royalBlue,
      AppColors.electricIndigo,
    ],
    TemperatureTier.jacketWeather: [
      AppColors.midnightPurple,
      AppColors.deepPurple,
      AppColors.royalBlue,
    ],
    TemperatureTier.flannelWeather: [
      AppColors.midnightPurple,
      AppColors.darkTeal,
      AppColors.chartreuse,
    ], // Electric storm feel
    TemperatureTier.shortsWeather: [
      AppColors.pitchBlack,
      AppColors.darkMagenta,
      AppColors.vibrantPurple,
    ],
    TemperatureTier.scorcher: [
      AppColors.pitchBlack,
      AppColors.darkMagenta,
      AppColors.magenta,
    ],
  };

  static const _heavyRainNight = {
    TemperatureTier.singleDigits: [
      AppColors.pitchBlack,
      AppColors.midnightBlue,
      AppColors.royalBlue,
    ],
    TemperatureTier.freezing: [
      AppColors.pitchBlack,
      AppColors.darkIndigo,
      AppColors.electricIndigo,
    ],
    TemperatureTier.jacketWeather: [
      AppColors.pitchBlack,
      AppColors.midnightPurple,
      AppColors.darkTeal,
    ],
    TemperatureTier.flannelWeather: [
      AppColors.pitchBlack,
      AppColors.midnightPurple,
      AppColors.deepPurple,
    ],
    TemperatureTier.shortsWeather: [
      AppColors.pitchBlack,
      AppColors.darkMagenta,
      AppColors.magenta,
    ],
    TemperatureTier.scorcher: [
      AppColors.pitchBlack,
      AppColors.darkMagenta,
      AppColors.orangeRed,
    ],
  };

  // Freezing rain
  static const _freezingRain = {
    TemperatureTier.singleDigits: [
      AppColors.steelGrey,
      AppColors.slateBlue,
      AppColors.darkTeal,
    ],
    TemperatureTier.freezing: [
      AppColors.fogSilver,
      AppColors.icyBlue,
      AppColors.darkTeal,
    ],
    TemperatureTier.jacketWeather: [
      AppColors.slateBlue,
      AppColors.royalBlue,
      AppColors.teal,
    ],
    TemperatureTier.flannelWeather: [
      AppColors.slateBlue,
      AppColors.electricIndigo,
      AppColors.darkTeal,
    ],
    TemperatureTier.shortsWeather: [
      AppColors.darkIndigo,
      AppColors.darkTeal,
      AppColors.magenta,
    ],
    TemperatureTier.scorcher: [
      AppColors.pitchBlack,
      AppColors.darkTeal,
      AppColors.orangeRed,
    ],
  };

  static const _freezingRainNight = {
    TemperatureTier.singleDigits: [
      AppColors.pitchBlack,
      AppColors.darkIndigo,
      AppColors.darkTeal,
    ],
    TemperatureTier.freezing: [
      AppColors.pitchBlack,
      AppColors.midnightBlue,
      AppColors.teal,
    ],
    TemperatureTier.jacketWeather: [
      AppColors.pitchBlack,
      AppColors.deepPurple,
      AppColors.darkTeal,
    ],
    TemperatureTier.flannelWeather: [
      AppColors.pitchBlack,
      AppColors.midnightPurple,
      AppColors.darkTeal,
    ],
    TemperatureTier.shortsWeather: [
      AppColors.pitchBlack,
      AppColors.darkMagenta,
      AppColors.burntOrange,
    ],
    TemperatureTier.scorcher: [
      AppColors.pitchBlack,
      AppColors.darkTeal,
      AppColors.orangeRed,
    ],
  };

  // Snow
  static const _snow = {
    TemperatureTier.singleDigits: [
      AppColors.palePurple,
      AppColors.frostLavender,
      AppColors.steelGrey,
    ],
    TemperatureTier.freezing: [
      AppColors.cream,
      AppColors.palePurple,
      AppColors.icyBlue,
    ],
    TemperatureTier.jacketWeather: [
      AppColors.cream,
      AppColors.fogSilver,
      AppColors.mutedTeal,
    ], // Slushy feel
    TemperatureTier.flannelWeather: [
      AppColors.fogSilver,
      AppColors.slateBlue,
      AppColors.vibrantPurple,
    ],
    TemperatureTier.shortsWeather: [
      AppColors.fogSilver,
      AppColors.vibrantPurple,
      AppColors.magenta,
    ],
    TemperatureTier.scorcher: [
      AppColors.fogSilver,
      AppColors.magenta,
      AppColors.orangeRed,
    ],
  };

  static const _snowNight = {
    TemperatureTier.singleDigits: [
      AppColors.voidPurple,
      AppColors.coldIndigo,
      AppColors.frostLavender,
    ],
    TemperatureTier.freezing: [
      AppColors.pitchBlack,
      AppColors.darkIndigo,
      AppColors.palePurple,
    ],
    TemperatureTier.jacketWeather: [
      AppColors.midnightPurple,
      AppColors.deepPurple,
      AppColors.palePurple,
    ],
    TemperatureTier.flannelWeather: [
      AppColors.midnightPurple,
      AppColors.darkMagenta,
      AppColors.palePurple,
    ],
    TemperatureTier.shortsWeather: [
      AppColors.pitchBlack,
      AppColors.darkMagenta,
      AppColors.burntOrange,
    ],
    TemperatureTier.scorcher: [
      AppColors.pitchBlack,
      AppColors.orangeRed,
      AppColors.cream,
    ],
  };

  // Blizzard — severe whiteout, harsh and dark
  static const _blizzard = {
    TemperatureTier.singleDigits: [
      AppColors.cream,
      AppColors.fogSilver,
      AppColors.steelGrey,
    ],
    TemperatureTier.freezing: [
      AppColors.cream,
      AppColors.fogSilver,
      AppColors.slateBlue,
    ],
    TemperatureTier.jacketWeather: [
      AppColors.cream,
      AppColors.slateBlue,
      AppColors.royalBlue,
    ],
    TemperatureTier.flannelWeather: [
      AppColors.cream,
      AppColors.vibrantPurple,
      AppColors.deepPurple,
    ],
    TemperatureTier.shortsWeather: [
      AppColors.cream,
      AppColors.magenta,
      AppColors.pitchBlack,
    ],
    TemperatureTier.scorcher: [
      AppColors.cream,
      AppColors.orangeRed,
      AppColors.pitchBlack,
    ],
  };

  static const _blizzardNight = {
    TemperatureTier.singleDigits: [
      AppColors.pitchBlack,
      AppColors.steelGrey,
      AppColors.cream,
    ],
    TemperatureTier.freezing: [
      AppColors.pitchBlack,
      AppColors.slateBlue,
      AppColors.cream,
    ],
    TemperatureTier.jacketWeather: [
      AppColors.pitchBlack,
      AppColors.darkIndigo,
      AppColors.fogSilver,
    ],
    TemperatureTier.flannelWeather: [
      AppColors.pitchBlack,
      AppColors.deepPurple,
      AppColors.fogSilver,
    ],
    TemperatureTier.shortsWeather: [
      AppColors.pitchBlack,
      AppColors.darkMagenta,
      AppColors.cream,
    ],
    TemperatureTier.scorcher: [
      AppColors.pitchBlack,
      AppColors.orangeRed,
      AppColors.cream,
    ],
  };

  // Thunderstorm — electric, dramatic with vibrant purple
  static const _thunderstorm = {
    TemperatureTier.singleDigits: [
      AppColors.darkIndigo,
      AppColors.electricIndigo,
      AppColors.vibrantPurple,
    ],
    TemperatureTier.freezing: [
      AppColors.midnightPurple,
      AppColors.royalBlue,
      AppColors.chartreuse,
    ],
    TemperatureTier.jacketWeather: [
      AppColors.pitchBlack,
      AppColors.deepPurple,
      AppColors.electricIndigo,
    ],
    TemperatureTier.flannelWeather: [
      AppColors.pitchBlack,
      AppColors.darkIndigo,
      AppColors.vibrantPurple,
    ],
    TemperatureTier.shortsWeather: [
      AppColors.pitchBlack,
      AppColors.deepPurple,
      AppColors.royalBlue,
    ],
    TemperatureTier.scorcher: [
      AppColors.pitchBlack,
      AppColors.darkMagenta,
      AppColors.vibrantPurple,
    ],
  };

  static const _thunderstormNight = {
    TemperatureTier.singleDigits: [
      AppColors.pitchBlack,
      AppColors.darkIndigo,
      AppColors.royalBlue,
    ],
    TemperatureTier.freezing: [
      AppColors.pitchBlack,
      AppColors.midnightPurple,
      AppColors.electricIndigo,
    ],
    TemperatureTier.jacketWeather: [
      AppColors.pitchBlack,
      AppColors.deepPurple,
      AppColors.vibrantPurple,
    ],
    TemperatureTier.flannelWeather: [
      AppColors.pitchBlack,
      AppColors.darkIndigo,
      AppColors.magenta,
    ],
    TemperatureTier.shortsWeather: [
      AppColors.pitchBlack,
      AppColors.midnightPurple,
      AppColors.chartreuse,
    ],
    TemperatureTier.scorcher: [
      AppColors.pitchBlack,
      AppColors.darkMagenta,
      AppColors.magenta,
    ],
  };

  // Hail — icy and harsh with cold tones
  static const _hail = {
    TemperatureTier.singleDigits: [
      AppColors.steelGrey,
      AppColors.slateBlue,
      AppColors.darkTeal,
    ],
    TemperatureTier.freezing: [
      AppColors.slateBlue,
      AppColors.darkTeal,
      AppColors.fogSilver,
    ],
    TemperatureTier.jacketWeather: [
      AppColors.midnightPurple,
      AppColors.darkTeal,
      AppColors.steelGrey,
    ],
    TemperatureTier.flannelWeather: [
      AppColors.darkIndigo,
      AppColors.deepPurple,
      AppColors.darkTeal,
    ],
    TemperatureTier.shortsWeather: [
      AppColors.pitchBlack,
      AppColors.darkTeal,
      AppColors.chartreuse,
    ],
    TemperatureTier.scorcher: [
      AppColors.pitchBlack,
      AppColors.darkMagenta,
      AppColors.darkTeal,
    ],
  };

  static const _hailNight = {
    TemperatureTier.singleDigits: [
      AppColors.pitchBlack,
      AppColors.darkIndigo,
      AppColors.steelGrey,
    ],
    TemperatureTier.freezing: [
      AppColors.pitchBlack,
      AppColors.midnightBlue,
      AppColors.fogSilver,
    ],
    TemperatureTier.jacketWeather: [
      AppColors.pitchBlack,
      AppColors.darkTeal,
      AppColors.midnightPurple,
    ],
    TemperatureTier.flannelWeather: [
      AppColors.pitchBlack,
      AppColors.deepPurple,
      AppColors.darkTeal,
    ],
    TemperatureTier.shortsWeather: [
      AppColors.pitchBlack,
      AppColors.darkMagenta,
      AppColors.darkTeal,
    ],
    TemperatureTier.scorcher: [
      AppColors.pitchBlack,
      AppColors.orangeRed,
      AppColors.darkTeal,
    ],
  };
}
