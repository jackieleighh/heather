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
      AppColors.sunnyElectricBlue,
      AppColors.sunnyBrightCerulean,
      AppColors.sunnyVividViolet,
    ],
    TemperatureTier.freezing: [
      AppColors.sunnyElectricBlueWarm,
      AppColors.sunnyCeruleanAqua,
      AppColors.sunnyElectricAqua,
    ],
    TemperatureTier.jacketWeather: [
      AppColors.sunnyCeruleanAqua,
      AppColors.sunnyElectricAqua,
      AppColors.sunnyVividTeal,
    ],
    TemperatureTier.flannelWeather: [
      AppColors.sunnyElectricAqua,
      AppColors.sunnyVividTeal,
      AppColors.sunnyElectricGold,
    ],
    TemperatureTier.shortsWeather: [
      AppColors.sunnyVividTeal,
      AppColors.sunnyElectricGold,
      AppColors.sunnyVividTangerine,
    ],
    TemperatureTier.scorcher: [
      AppColors.sunnyElectricGold,
      AppColors.sunnyVividTangerine,
      AppColors.sunnyHotMagenta,
    ],
  };

  static const _mostlySunny = _sunny;

  static const _partlyCloudy = _sunny;

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
      AppColors.overcastSage,
    ],
    TemperatureTier.flannelWeather: [
      AppColors.overcastSkyBlue,
      AppColors.overcastSage,
      AppColors.softOvercastGold,
    ],
    TemperatureTier.shortsWeather: [
      AppColors.overcastMauve,
      AppColors.softOvercastGold,
      AppColors.softOrange,
    ],
    TemperatureTier.scorcher: [
      AppColors.overcastMauve,
      AppColors.softOrange,
      AppColors.softRose,
    ],
  };

  static const _foggy = _overcast;

  static const _drizzle = {
    TemperatureTier.singleDigits: [
      AppColors.drizzleCloudBlue,
      AppColors.drizzleCloudViolet,
      AppColors.drizzlePunchyLavender,
    ],
    TemperatureTier.freezing: [
      AppColors.drizzleCloudBlue,
      AppColors.drizzleCloudPeriwinkle,
      AppColors.drizzlePunchyCyan,
    ],
    TemperatureTier.jacketWeather: [
      AppColors.drizzleCloudBlue,
      AppColors.drizzleCloudMid,
      AppColors.drizzlePunchyTeal,
    ],
    TemperatureTier.flannelWeather: [
      AppColors.drizzleCloudBlue,
      AppColors.drizzleCloudTeal,
      AppColors.drizzlePunchyGold,
    ],
    TemperatureTier.shortsWeather: [
      AppColors.drizzleCloudBlue,
      AppColors.drizzleCloudTeal,
      AppColors.drizzlePunchyTangerine,
    ],
    TemperatureTier.scorcher: [
      AppColors.drizzleCloudBlue,
      AppColors.drizzleCloudTeal,
      AppColors.drizzlePunchyRose,
    ],
  };

  static const _rain = {
    TemperatureTier.singleDigits: [
      AppColors.rainBlue,
      AppColors.rainViolet,
      AppColors.rainLavender,
    ],
    TemperatureTier.freezing: [
      AppColors.rainBlue,
      AppColors.rainPeriwinkle,
      AppColors.rainCyan,
    ],
    TemperatureTier.jacketWeather: [
      AppColors.rainBlue,
      AppColors.rainMid,
      AppColors.rainTeal,
    ],
    TemperatureTier.flannelWeather: [
      AppColors.rainBlue,
      AppColors.rainMidTeal,
      AppColors.rainGold,
    ],
    TemperatureTier.shortsWeather: [
      AppColors.rainBlue,
      AppColors.rainMidTeal,
      AppColors.rainTangerine,
    ],
    TemperatureTier.scorcher: [
      AppColors.rainBlue,
      AppColors.rainMidTeal,
      AppColors.rainRose,
    ],
  };

  static const _heavyRain = {
    TemperatureTier.singleDigits: [
      AppColors.stormBlue,
      AppColors.stormViolet,
      AppColors.stormRichLavender,
    ],
    TemperatureTier.freezing: [
      AppColors.stormBlue,
      AppColors.stormPeriwinkle,
      AppColors.stormRichCyan,
    ],
    TemperatureTier.jacketWeather: [
      AppColors.stormBlue,
      AppColors.stormMid,
      AppColors.stormRichTeal,
    ],
    TemperatureTier.flannelWeather: [
      AppColors.stormBlue,
      AppColors.stormTeal,
      AppColors.stormRichGold,
    ],
    TemperatureTier.shortsWeather: [
      AppColors.stormBlue,
      AppColors.stormTeal,
      AppColors.stormRichTangerine,
    ],
    TemperatureTier.scorcher: [
      AppColors.stormBlue,
      AppColors.stormTeal,
      AppColors.stormRichRose,
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
      AppColors.softOrange,
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
      AppColors.nightMagenta,
    ],
    TemperatureTier.scorcher: [
      AppColors.darkIndigo,
      AppColors.deepPurple,
      AppColors.nightCoral,
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
      AppColors.nightMagenta,
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
      AppColors.nightMagenta,
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
      AppColors.magenta,
    ],
    TemperatureTier.scorcher: [
      AppColors.pitchBlack,
      AppColors.deepPurple,
      AppColors.orangeRed,
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
      AppColors.nightCoral,
      AppColors.burntOrange,
    ],
    TemperatureTier.scorcher: [
      AppColors.midnightPurple,
      AppColors.burntOrange,
      AppColors.nightMagenta,
    ],
  };

  static const _blizzardNight = _snowNight;

  static const _thunderstormNight = _heavyRainNight;

  static const _hailNight = _heavyRainNight;
}
