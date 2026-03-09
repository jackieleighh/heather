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
      AppColors.sunnyViolet,
      AppColors.sunnyLavender,
      AppColors.sunnyOrchid,
    ],
    TemperatureTier.freezing: [
      AppColors.sunnyLilac,
      AppColors.sunnySkyBlue,
      AppColors.sunnyIce,
    ],
    TemperatureTier.jacketWeather: [
      AppColors.brightFrostBlue,
      AppColors.brightDeepAzure,
      AppColors.sunnySage,
    ],
    TemperatureTier.flannelWeather: [
      AppColors.brightDeepAzure,
      AppColors.sunnySage,
      AppColors.sunnyAmber,
    ],
    TemperatureTier.shortsWeather: [
      AppColors.sunnySage,
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

  static const _partlyCloudy = {
    TemperatureTier.singleDigits: [
      AppColors.frostLavender,
      AppColors.brightPeriwinkle,
      AppColors.brightLilac,
    ],
    TemperatureTier.freezing: [
      AppColors.brightLilac,
      AppColors.brightPeriwinkle,
      AppColors.brightFrostBlue,
    ],
    TemperatureTier.jacketWeather: [
      AppColors.brightFrostBlue,
      AppColors.brightDeepAzure,
      AppColors.brightSeafoam,
    ],
    TemperatureTier.flannelWeather: [
      AppColors.brightDeepAzure,
      AppColors.brightSeafoam,
      AppColors.brightDesertGold,
    ],
    TemperatureTier.shortsWeather: [
      AppColors.brightSeafoam,
      AppColors.brightSunGold,
      AppColors.burntOrange,
    ],
    TemperatureTier.scorcher: [
      AppColors.brightSunGold,
      AppColors.burntOrange,
      AppColors.magenta,
    ],
  };

  static const _overcast = {
    TemperatureTier.singleDigits: [
      AppColors.overcastBrightViolet,
      AppColors.overcastBrightLilac,
      AppColors.overcastBrightLavender,
    ],
    TemperatureTier.freezing: [
      AppColors.overcastBrightWisteria,
      AppColors.overcastBrightBlue,
      AppColors.overcastBrightIce,
    ],
    TemperatureTier.jacketWeather: [
      AppColors.overcastWisteria,
      AppColors.overcastSkyBlue,
      AppColors.overcastBrightSage,
    ],
    TemperatureTier.flannelWeather: [
      AppColors.overcastSkyBlue,
      AppColors.overcastBrightSage,
      AppColors.overcastGold,
    ],
    TemperatureTier.shortsWeather: [
      AppColors.overcastMauve,
      AppColors.overcastGold,
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
      AppColors.drizzleWisteria,
      AppColors.drizzleIce,
      AppColors.drizzleBlue,
    ],
    TemperatureTier.freezing: [
      AppColors.drizzleWisteria,
      AppColors.drizzleIce,
      AppColors.drizzleTeal,
    ],
    TemperatureTier.jacketWeather: [
      AppColors.drizzleIce,
      AppColors.drizzleTeal,
      AppColors.drizzleSage,
    ],
    TemperatureTier.flannelWeather: [
      AppColors.drizzleBlue,
      AppColors.drizzleSage,
      AppColors.drizzleAmber,
    ],
    TemperatureTier.shortsWeather: [
      AppColors.drizzleBlue,
      AppColors.drizzleAmber,
      AppColors.burntOrange,
    ],
    TemperatureTier.scorcher: [
      AppColors.drizzleBlue,
      AppColors.drizzleOrange,
      AppColors.drizzleDeepRose,
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
      AppColors.deepPurple,
      AppColors.nightPurple,
    ],
    TemperatureTier.freezing: [
      AppColors.midnightPurple,
      AppColors.deepPurple,
      AppColors.nightBlue,
    ],
    TemperatureTier.jacketWeather: [
      AppColors.midnightPurple,
      AppColors.deepPurple,
      AppColors.nightBlueTeal,
    ],
    TemperatureTier.flannelWeather: [
      AppColors.midnightPurple,
      AppColors.deepPurple,
      AppColors.nightGreenTeal,
    ],
    TemperatureTier.shortsWeather: [
      AppColors.midnightPurple,
      AppColors.deepPurple,
      AppColors.nightCoral,
    ],
    TemperatureTier.scorcher: [
      AppColors.midnightPurple,
      AppColors.deepPurple,
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
