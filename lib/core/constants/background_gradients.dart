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
      AppColors.skyPeriwinkle,
      AppColors.frostLavender,
      AppColors.royalBlue,
    ],
    TemperatureTier.freezing: [
      AppColors.skyPeriwinkle,
      AppColors.lavenderBlue,
      AppColors.icyBlue,
    ],
    TemperatureTier.jacketWeather: [
      AppColors.warmSkyBlue,
      AppColors.icyBlue,
      AppColors.teal,
    ],
    TemperatureTier.flannelWeather: [
      AppColors.warmSkyBlue,
      AppColors.sunnyGreen,
      AppColors.goldenAmber,
    ],
    TemperatureTier.shortsWeather: [
      AppColors.sunnyGreen,
      AppColors.goldenAmber,
      AppColors.orange,
    ],
    TemperatureTier.scorcher: [
      AppColors.hotAmber,
      AppColors.orange,
      AppColors.heatPink,
    ],
  };

  static const _mostlySunny = _sunny;

  static const _partlyCloudy = _sunny;

  static const _overcast = {
    TemperatureTier.singleDigits: [
      AppColors.steelGrey,
      AppColors.skyPeriwinkle,
      AppColors.coldIndigo,
    ],
    TemperatureTier.freezing: [
      AppColors.steelGrey,
      AppColors.lavenderBlue,
      AppColors.slateBlue,
    ],
    TemperatureTier.jacketWeather: [
      AppColors.slateBlue,
      AppColors.steelGrey,
      AppColors.darkTeal,
    ],
    TemperatureTier.flannelWeather: [
      AppColors.slateBlue,
      AppColors.cloudySage,
      AppColors.cloudyAmber,
    ],
    TemperatureTier.shortsWeather: [
      AppColors.cloudySage,
      AppColors.cloudyAmber,
      AppColors.dullOrange,
    ],
    TemperatureTier.scorcher: [
      AppColors.cloudyAmber,
      AppColors.dullOrange,
      AppColors.darkMagenta,
    ],
  };

  static const _foggy = _overcast;

  static const _drizzle = {
    TemperatureTier.singleDigits: [
      AppColors.lavenderBlue,
      AppColors.skyPeriwinkle,
      AppColors.coldIndigo,
    ],
    TemperatureTier.freezing: [
      AppColors.lavenderBlue,
      AppColors.steelGrey,
      AppColors.slateBlue,
    ],
    TemperatureTier.jacketWeather: [
      AppColors.warmSkyBlue,
      AppColors.slateBlue,
      AppColors.darkTeal,
    ],
    TemperatureTier.flannelWeather: [
      AppColors.warmSkyBlue,
      AppColors.cloudySage,
      AppColors.cloudyAmber,
    ],
    TemperatureTier.shortsWeather: [
      AppColors.warmSkyBlue,
      AppColors.cloudyAmber,
      AppColors.dullOrange,
    ],
    TemperatureTier.scorcher: [
      AppColors.warmSkyBlue,
      AppColors.dullOrange,
      AppColors.darkMagenta,
    ],
  };

  static const _rain = _drizzle;

  static const _heavyRain = {
    TemperatureTier.singleDigits: [
      AppColors.coldIndigo,
      AppColors.royalBlue,
      AppColors.slateBlue,
    ],
    TemperatureTier.freezing: [
      AppColors.coldIndigo,
      AppColors.slateBlue,
      AppColors.lavenderBlue,
    ],
    TemperatureTier.jacketWeather: [
      AppColors.coldIndigo,
      AppColors.slateBlue,
      AppColors.darkTeal,
    ],
    TemperatureTier.flannelWeather: [
      AppColors.coldIndigo,
      AppColors.cloudySage,
      AppColors.cloudyAmber,
    ],
    TemperatureTier.shortsWeather: [
      AppColors.coldIndigo,
      AppColors.cloudyAmber,
      AppColors.dullOrange,
    ],
    TemperatureTier.scorcher: [
      AppColors.coldIndigo,
      AppColors.dullOrange,
      AppColors.darkMagenta,
    ],
  };

  static const _freezingRain = _heavyRain;

  static const _snow = {
    TemperatureTier.singleDigits: [
      AppColors.cream,
      AppColors.frostLavender,
      AppColors.lavenderBlue,
    ],
    TemperatureTier.freezing: [
      AppColors.cream,
      AppColors.steelGrey,
      AppColors.lavenderBlue,
    ],
    TemperatureTier.jacketWeather: [
      AppColors.cream,
      AppColors.fogSilver,
      AppColors.lavenderBlue,
    ],
    TemperatureTier.flannelWeather: [
      AppColors.cream,
      AppColors.skyPeriwinkle,
      AppColors.lavenderBlue,
    ],
    TemperatureTier.shortsWeather: [
      AppColors.cream,
      AppColors.steelGrey,
      AppColors.lavenderBlue,
    ],
    TemperatureTier.scorcher: [
      AppColors.cream,
      AppColors.lavenderBlue,
      AppColors.slateBlue,
    ],
  };

  static const _blizzard = {
    TemperatureTier.singleDigits: [
      AppColors.fogSilver,
      AppColors.frostLavender,
      AppColors.lavenderBlue,
    ],
    TemperatureTier.freezing: [
      AppColors.fogSilver,
      AppColors.steelGrey,
      AppColors.lavenderBlue,
    ],
    TemperatureTier.jacketWeather: [
      AppColors.fogSilver,
      AppColors.steelGrey,
      AppColors.lavenderBlue,
    ],
    TemperatureTier.flannelWeather: [
      AppColors.fogSilver,
      AppColors.skyPeriwinkle,
      AppColors.lavenderBlue,
    ],
    TemperatureTier.shortsWeather: [
      AppColors.fogSilver,
      AppColors.lavenderBlue,
      AppColors.slateBlue,
    ],
    TemperatureTier.scorcher: [
      AppColors.fogSilver,
      AppColors.skyPeriwinkle,
      AppColors.slateBlue,
    ],
  };

  static const _thunderstorm = _heavyRain;

  static const _hail = _heavyRain;

  // ---------------------------------------------------------------------------
  // NIGHT GRADIENTS
  // ---------------------------------------------------------------------------

  static const _sunnyNight = {
    TemperatureTier.singleDigits: [
      AppColors.darkIndigo,
      AppColors.deepPurple,
      AppColors.royalBlue,
    ],
    TemperatureTier.freezing: [
      AppColors.darkIndigo,
      AppColors.deepPurple,
      AppColors.midnightNavy,
    ],
    TemperatureTier.jacketWeather: [
      AppColors.darkIndigo,
      AppColors.deepPurple,
      AppColors.coldIndigo,
    ],
    TemperatureTier.flannelWeather: [
      AppColors.darkIndigo,
      AppColors.deepPurple,
      AppColors.darkTeal,
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
      AppColors.midnightPurple,
      AppColors.magenta,
    ],
    TemperatureTier.scorcher: [
      AppColors.pitchBlack,
      AppColors.darkMagenta,
      AppColors.burntOrange,
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
      AppColors.frostLavender,
    ],
    TemperatureTier.jacketWeather: [
      AppColors.midnightPurple,
      AppColors.darkIndigo,
      AppColors.fogSilver,
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

  static const _blizzardNight = {
    TemperatureTier.singleDigits: [
      AppColors.pitchBlack,
      AppColors.slateBlue,
      AppColors.palePurple,
    ],
    TemperatureTier.freezing: [
      AppColors.pitchBlack,
      AppColors.slateBlue,
      AppColors.frostLavender,
    ],
    TemperatureTier.jacketWeather: [
      AppColors.pitchBlack,
      AppColors.slateBlue,
      AppColors.fogSilver,
    ],
    TemperatureTier.flannelWeather: [
      AppColors.pitchBlack,
      AppColors.slateBlue,
      AppColors.cream,
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

  static const _thunderstormNight = _heavyRainNight;

  static const _hailNight = _heavyRainNight;
}
