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

  static const _sunny = {
    TemperatureTier.singleDigits: [
      AppColors.brightSkyPeriwinkle,
      AppColors.brightFrostLavender,
      AppColors.brightRoyalBlue,
    ],
    TemperatureTier.freezing: [
      AppColors.brightFrostBlue,
      AppColors.brightIcyBlue,
      AppColors.brightWarmSkyBlue,
    ],
    TemperatureTier.jacketWeather: [
      AppColors.brightSkyBlue,
      AppColors.brightAqua,
      AppColors.brightTeal,
    ],
    TemperatureTier.flannelWeather: [
      AppColors.brightSkyBlue,
      AppColors.brightLime,
      AppColors.brightGoldenAmber,
    ],
    TemperatureTier.shortsWeather: [
      AppColors.brightSkyBlue,
      AppColors.brightGoldenAmber,
      AppColors.brightOrange,
    ],
    TemperatureTier.scorcher: [
      AppColors.brightSkyBlue,
      AppColors.brightOrange,
      AppColors.brightHeatPink,
    ],
  };

  static const _mostlySunny = _sunny;

  static const _partlyCloudy = _sunny;

  static const _overcast = {
    TemperatureTier.singleDigits: [
      AppColors.steelGrey,
      AppColors.skyPeriwinkle,
      AppColors.overcastBlue,
    ],
    TemperatureTier.freezing: [
      AppColors.steelGrey,
      AppColors.lavenderBlue,
      AppColors.overcastSlate,
    ],
    TemperatureTier.jacketWeather: [
      AppColors.steelGrey,
      AppColors.overcastSlate,
      AppColors.overcastTeal,
    ],
    TemperatureTier.flannelWeather: [
      AppColors.overcastSlate,
      AppColors.overcastSage,
      AppColors.overcastAmber,
    ],
    TemperatureTier.shortsWeather: [
      AppColors.overcastSage,
      AppColors.overcastAmber,
      AppColors.overcastOrange,
    ],
    TemperatureTier.scorcher: [
      AppColors.overcastAmber,
      AppColors.overcastOrange,
      AppColors.overcastRose,
    ],
  };

  static const _foggy = _overcast;

  static const _drizzle = {
    TemperatureTier.singleDigits: [
      AppColors.lavenderBlue,
      AppColors.skyPeriwinkle,
      AppColors.overcastBlue,
    ],
    TemperatureTier.freezing: [
      AppColors.lavenderBlue,
      AppColors.skyPeriwinkle,
      AppColors.overcastSlate,
    ],
    TemperatureTier.jacketWeather: [
      AppColors.overcastBlue,
      AppColors.overcastTeal,
      AppColors.warmSkyBlue,
    ],
    TemperatureTier.flannelWeather: [
      AppColors.overcastBlue,
      AppColors.cloudySage,
      AppColors.cloudyAmber,
    ],
    TemperatureTier.shortsWeather: [
      AppColors.overcastBlue,
      AppColors.cloudyAmber,
      AppColors.overcastOrange,
    ],
    TemperatureTier.scorcher: [
      AppColors.overcastBlue,
      AppColors.overcastOrange,
      AppColors.overcastRose,
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
      AppColors.brightIcyBlue,
    ],
    TemperatureTier.freezing: [
      AppColors.cream,
      AppColors.brightSkyPeriwinkle,
      AppColors.brightIcyBlue,
    ],
    TemperatureTier.jacketWeather: [
      AppColors.cream,
      AppColors.brightSkyPeriwinkle,
      AppColors.brightWarmSkyBlue,
    ],
    TemperatureTier.flannelWeather: [
      AppColors.cream,
      AppColors.brightSkyPeriwinkle,
      AppColors.brightIcyBlue,
    ],
    TemperatureTier.shortsWeather: [
      AppColors.cream,
      AppColors.brightSkyPeriwinkle,
      AppColors.brightIcyBlue,
    ],
    TemperatureTier.scorcher: [
      AppColors.cream,
      AppColors.brightIcyBlue,
      AppColors.brightWarmSkyBlue,
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
      AppColors.darkMagenta,
    ],
    TemperatureTier.scorcher: [
      AppColors.darkIndigo,
      AppColors.deepPurple,
      AppColors.orangeRed,
    ],
  };

  static const _mostlySunnyNight = _sunnyNight;

  static const _partlyCloudyNight = _sunnyNight;

  static const _overcastNight = {
    TemperatureTier.singleDigits: [
      AppColors.midnightPurple,
      AppColors.darkIndigo,
      AppColors.midnightNavy,
    ],
    TemperatureTier.freezing: [
      AppColors.midnightPurple,
      AppColors.darkIndigo,
      AppColors.slateBlue,
    ],
    TemperatureTier.jacketWeather: [
      AppColors.midnightPurple,
      AppColors.darkIndigo,
      AppColors.coldIndigo,
    ],
    TemperatureTier.flannelWeather: [
      AppColors.midnightPurple,
      AppColors.darkIndigo,
      AppColors.darkTeal,
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

  static const _foggyNight = _overcastNight;

  static const _drizzleNight = {
    TemperatureTier.singleDigits: [
      AppColors.pitchBlack,
      AppColors.darkIndigo,
      AppColors.midnightNavy,
    ],
    TemperatureTier.freezing: [
      AppColors.pitchBlack,
      AppColors.darkIndigo,
      AppColors.slateBlue,
    ],
    TemperatureTier.jacketWeather: [
      AppColors.pitchBlack,
      AppColors.darkIndigo,
      AppColors.coldIndigo,
    ],
    TemperatureTier.flannelWeather: [
      AppColors.pitchBlack,
      AppColors.darkIndigo,
      AppColors.darkTeal,
    ],
    TemperatureTier.shortsWeather: [
      AppColors.pitchBlack,
      AppColors.deepPurple,
      AppColors.darkMagenta,
    ],
    TemperatureTier.scorcher: [
      AppColors.pitchBlack,
      AppColors.darkMagenta,
      AppColors.orangeRed,
    ],
  };

  static const _rainNight = _drizzleNight;

  static const _heavyRainNight = {
    TemperatureTier.singleDigits: [
      AppColors.pitchBlack,
      AppColors.midnightBlue,
      AppColors.slateBlue,
    ],
    TemperatureTier.freezing: [
      AppColors.pitchBlack,
      AppColors.midnightBlue,
      AppColors.coldIndigo,
    ],
    TemperatureTier.jacketWeather: [
      AppColors.pitchBlack,
      AppColors.midnightBlue,
      AppColors.electricIndigo,
    ],
    TemperatureTier.flannelWeather: [
      AppColors.pitchBlack,
      AppColors.midnightBlue,
      AppColors.teal,
    ],
    TemperatureTier.shortsWeather: [
      AppColors.pitchBlack,
      AppColors.midnightBlue,
      AppColors.burntOrange,
    ],
    TemperatureTier.scorcher: [
      AppColors.pitchBlack,
      AppColors.midnightBlue,
      AppColors.magenta,
    ],
  };

  static const _freezingRainNight = _heavyRainNight;

  static const _snowNight = {
    TemperatureTier.singleDigits: [
      AppColors.midnightPurple,
      AppColors.darkIndigo,
      AppColors.palePurple,
    ],
    TemperatureTier.freezing: [
      AppColors.midnightPurple,
      AppColors.darkIndigo,
      AppColors.brightFrostLavender,
    ],
    TemperatureTier.jacketWeather: [
      AppColors.midnightPurple,
      AppColors.darkIndigo,
      AppColors.brightFrostBlue,
    ],
    TemperatureTier.flannelWeather: [
      AppColors.midnightPurple,
      AppColors.darkIndigo,
      AppColors.steelGrey,
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

  static const _blizzardNight = _snowNight;

  static const _thunderstormNight = _heavyRainNight;

  static const _hailNight = _heavyRainNight;
}
