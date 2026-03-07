import 'dart:ui';

import '../../features/weather/domain/entities/temperature_tier.dart';
import '../../features/weather/domain/entities/weather_condition.dart';
import 'app_colors.dart';

class BackgroundGradients {
  BackgroundGradients._();

  /// Compute gradient stops that push the first color (blue) to be dominant.
  /// Matches the iOS widget stop distribution from WidgetGradients.swift.
  static List<double> sunnyStops(int colorCount) {
    return switch (colorCount) {
      3 => [0.0, 0.8, 1.0],
      4 => [0.0, 0.65, 0.85, 1.0],
      5 => [0.0, 0.4, 0.65, 0.85, 1.0],
      _ => List.generate(colorCount, (i) => i / (colorCount - 1)),
    };
  }

  /// Evenly spaced stops for night gradients — produces a subtle, smooth fade.
  static List<double> nightStops(int colorCount) {
    return List.generate(colorCount, (i) => i / (colorCount - 1));
  }

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

  static const _sunny = {
    TemperatureTier.singleDigits: [
      AppColors.frostLavender,
      AppColors.brightFrostLavender,
      AppColors.brightLilac,
    ],
    TemperatureTier.freezing: [
      AppColors.brightLilac,
      AppColors.brightLavenderFrost,
      AppColors.brightFrostBlue,
    ],
    TemperatureTier.jacketWeather: [
      AppColors.brightFrostBlue,
      AppColors.brightDeepAzure,
      AppColors.overcastSage,
    ],
    TemperatureTier.flannelWeather: [
      AppColors.brightDeepAzure,
      AppColors.overcastSage,
      AppColors.overcastAmber,
    ],
    TemperatureTier.shortsWeather: [
      AppColors.overcastSage,
      AppColors.brightSunGold,
      AppColors.burntOrange,
    ],
    TemperatureTier.scorcher: [
      AppColors.brightSunGold,
      AppColors.burntOrange,
      AppColors.magenta,
    ],
  };

  static const _mostlySunny = _sunny;

  static const _partlyCloudy = _sunny;

  static const _overcast = {
    TemperatureTier.singleDigits: [
      AppColors.overcastViolet,
      AppColors.overcastLilac,
      AppColors.overcastLavender,
    ],
    TemperatureTier.freezing: [
      AppColors.overcastWisteria,
      AppColors.overcastBlue,
      AppColors.overcastIce,
    ],
    TemperatureTier.jacketWeather: [
      AppColors.overcastWisteria,
      AppColors.overcastTeal,
      AppColors.overcastSage,
    ],
    TemperatureTier.flannelWeather: [
      AppColors.overcastTeal,
      AppColors.overcastSage,
      AppColors.overcastAmber,
    ],
    TemperatureTier.shortsWeather: [
      AppColors.overcastMauve,
      AppColors.overcastAmber,
      AppColors.burntOrange,
    ],
    TemperatureTier.scorcher: [
      AppColors.overcastOrange,
      AppColors.burntOrange,
      AppColors.magenta,
    ],
  };

  static const _foggy = _overcast;

  static const _drizzle = {
    TemperatureTier.singleDigits: [
      AppColors.overcastWisteria,
      AppColors.overcastIce,
      AppColors.overcastBlue,
    ],
    TemperatureTier.freezing: [
      AppColors.overcastWisteria,
      AppColors.overcastIce,
      AppColors.overcastTeal,
    ],
    TemperatureTier.jacketWeather: [
      AppColors.overcastIce,
      AppColors.overcastTeal,
      AppColors.overcastSage,
    ],
    TemperatureTier.flannelWeather: [
      AppColors.overcastBlue,
      AppColors.overcastSage,
      AppColors.overcastAmber,
    ],
    TemperatureTier.shortsWeather: [
      AppColors.overcastBlue,
      AppColors.overcastAmber,
      AppColors.burntOrange,
    ],
    TemperatureTier.scorcher: [
      AppColors.overcastBlue,
      AppColors.overcastOrange,
      AppColors.overcastDeepRose,
    ],
  };

  static const _rain = _drizzle;

  static const _heavyRain = {
    TemperatureTier.singleDigits: [
      AppColors.stormBlue,
      AppColors.royalBlue,
      AppColors.lavenderBlue,
    ],
    TemperatureTier.freezing: [
      AppColors.stormBlue,
      AppColors.lavenderBlue,
      AppColors.overcastSlate,
    ],
    TemperatureTier.jacketWeather: [
      AppColors.stormBlue,
      AppColors.warmSkyBlue,
      AppColors.overcastTeal,
    ],
    TemperatureTier.flannelWeather: [
      AppColors.stormBlue,
      AppColors.overcastTeal,
      AppColors.goldenAmber,
    ],
    TemperatureTier.shortsWeather: [
      AppColors.stormBlue,
      AppColors.goldenAmber,
      AppColors.dullOrange,
    ],
    TemperatureTier.scorcher: [
      AppColors.stormBlue,
      AppColors.dullOrange,
      AppColors.magenta,
    ],
  };

  static const _freezingRain = _heavyRain;

  static const _snow = {
    TemperatureTier.singleDigits: [
      AppColors.cream,
      AppColors.frostLavender,
      AppColors.brightSkyPeriwinkle,
    ],
    TemperatureTier.freezing: [
      AppColors.cream,
      AppColors.brightSkyPeriwinkle,
      AppColors.brightIcyBlue,
    ],
    TemperatureTier.jacketWeather: [
      AppColors.cream,
      AppColors.brightIcyBlue,
      AppColors.brightAzure,
    ],
    TemperatureTier.flannelWeather: [
      AppColors.cream,
      AppColors.brightAzure,
      AppColors.brightWarmSkyBlue,
    ],
    TemperatureTier.shortsWeather: [
      AppColors.cream,
      AppColors.brightWarmSkyBlue,
      AppColors.overcastTeal,
    ],
    TemperatureTier.scorcher: [
      AppColors.cream,
      AppColors.overcastTeal,
      AppColors.burntOrange,
    ],
  };

  static const _blizzard = _snow;

  static const _thunderstorm = _heavyRain;

  static const _hail = _heavyRain;

  // ---------------------------------------------------------------------------
  // NIGHT GRADIENTS
  // ---------------------------------------------------------------------------

  static const _sunnyNight = {
    TemperatureTier.singleDigits: [
      AppColors.darkIndigo,
      AppColors.deepPurple,
      AppColors.nightPurple,
    ],
    TemperatureTier.freezing: [
      AppColors.darkIndigo,
      AppColors.deepPurple,
      AppColors.nightBlue,
    ],
    TemperatureTier.jacketWeather: [
      AppColors.darkIndigo,
      AppColors.deepPurple,
      AppColors.nightBlueTeal,
    ],
    TemperatureTier.flannelWeather: [
      AppColors.darkIndigo,
      AppColors.deepPurple,
      AppColors.nightGreenTeal,
    ],
    TemperatureTier.shortsWeather: [
      AppColors.darkIndigo,
      AppColors.deepPurple,
      AppColors.nightCoral,
    ],
    TemperatureTier.scorcher: [
      AppColors.darkIndigo,
      AppColors.deepPurple,
      AppColors.darkMagenta,
    ],
  };

  static const _mostlySunnyNight = _sunnyNight;

  static const _partlyCloudyNight = _sunnyNight;

  static const _overcastNight = {
    TemperatureTier.singleDigits: [
      AppColors.midnightPurple,
      AppColors.darkIndigo,
      AppColors.coldIndigo,
    ],
    TemperatureTier.freezing: [
      AppColors.midnightPurple,
      AppColors.deepPurple,
      AppColors.nightBlue,
    ],
    TemperatureTier.jacketWeather: [
      AppColors.midnightNavy,
      AppColors.nightBlueTeal,
      AppColors.nightGreenTeal,
    ],
    TemperatureTier.flannelWeather: [
      AppColors.darkTeal,
      AppColors.nightGreenTeal,
      AppColors.nightAmber,
    ],
    TemperatureTier.shortsWeather: [
      AppColors.deepPurple,
      AppColors.nightAmber,
      AppColors.nightBurntOrange,
    ],
    TemperatureTier.scorcher: [
      AppColors.nightAmber,
      AppColors.nightBurntOrange,
      AppColors.darkMagenta,
    ],
  };

  static const _foggyNight = _overcastNight;

  static const _drizzleNight = {
    TemperatureTier.singleDigits: [
      AppColors.pitchBlack,
      AppColors.deepPurple,
      AppColors.nightPurple,
    ],
    TemperatureTier.freezing: [
      AppColors.pitchBlack,
      AppColors.deepPurple,
      AppColors.nightBlue,
    ],
    TemperatureTier.jacketWeather: [
      AppColors.pitchBlack,
      AppColors.deepPurple,
      AppColors.nightBlueTeal,
    ],
    TemperatureTier.flannelWeather: [
      AppColors.pitchBlack,
      AppColors.deepPurple,
      AppColors.nightGreenTeal,
    ],
    TemperatureTier.shortsWeather: [
      AppColors.pitchBlack,
      AppColors.deepPurple,
      AppColors.nightCoral,
    ],
    TemperatureTier.scorcher: [
      AppColors.pitchBlack,
      AppColors.deepPurple,
      AppColors.darkMagenta,
    ],
  };

  static const _rainNight = _drizzleNight;

  static const _heavyRainNight = {
    TemperatureTier.singleDigits: [
      AppColors.pitchBlack,
      AppColors.deepPurple,
      AppColors.nightPurple,
    ],
    TemperatureTier.freezing: [
      AppColors.pitchBlack,
      AppColors.deepPurple,
      AppColors.nightBlue,
    ],
    TemperatureTier.jacketWeather: [
      AppColors.pitchBlack,
      AppColors.deepPurple,
      AppColors.nightBlueTeal,
    ],
    TemperatureTier.flannelWeather: [
      AppColors.pitchBlack,
      AppColors.deepPurple,
      AppColors.nightGreenTeal,
    ],
    TemperatureTier.shortsWeather: [
      AppColors.pitchBlack,
      AppColors.deepPurple,
      AppColors.orangeRed,
    ],
    TemperatureTier.scorcher: [
      AppColors.pitchBlack,
      AppColors.deepPurple,
      AppColors.magenta,
    ],
  };

  static const _freezingRainNight = _heavyRainNight;

  static const _snowNight = {
    TemperatureTier.singleDigits: [
      AppColors.midnightPurple,
      AppColors.deepPurple,
      AppColors.palePurple,
    ],
    TemperatureTier.freezing: [
      AppColors.midnightPurple,
      AppColors.coldIndigo,
      AppColors.brightFrostLavender,
    ],
    TemperatureTier.jacketWeather: [
      AppColors.midnightPurple,
      AppColors.nightBlueTeal,
      AppColors.brightFrostBlue,
    ],
    TemperatureTier.flannelWeather: [
      AppColors.midnightPurple,
      AppColors.darkTeal,
      AppColors.mutedTeal,
    ],
    TemperatureTier.shortsWeather: [
      AppColors.midnightPurple,
      AppColors.darkMagenta,
      AppColors.burntOrange,
    ],
    TemperatureTier.scorcher: [
      AppColors.midnightPurple,
      AppColors.burntOrange,
      AppColors.heatPink,
    ],
  };

  static const _blizzardNight = _snowNight;

  static const _thunderstormNight = _heavyRainNight;

  static const _hailNight = _heavyRainNight;
}
