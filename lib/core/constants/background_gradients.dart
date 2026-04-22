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
      AppColors.sunnyElectricAqua,
      AppColors.sunnyVividTeal,
      AppColors.sunnyChartreuse,
    ],
    TemperatureTier.flannelWeather: [
      AppColors.sunnyVividTeal,
      AppColors.sunnyChartreuse,
      AppColors.sunnyYellowGreen,
    ],
    TemperatureTier.shortsWeather: [
      AppColors.sunnyYellowGreen,
      AppColors.sunnyAmber,
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
      AppColors.drizzleMidSage,
      AppColors.drizzlePunchyGold,
    ],
    TemperatureTier.shortsWeather: [
      AppColors.drizzleCloudBlue,
      AppColors.drizzleMidLavender,
      AppColors.drizzlePunchyTangerine,
    ],
    TemperatureTier.scorcher: [
      AppColors.drizzleCloudBlue,
      AppColors.drizzleMidMauve,
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
      AppColors.rainMidSage,
      AppColors.rainGold,
    ],
    TemperatureTier.shortsWeather: [
      AppColors.rainBlue,
      AppColors.rainMidLavender,
      AppColors.rainTangerine,
    ],
    TemperatureTier.scorcher: [
      AppColors.rainBlue,
      AppColors.rainMidMauve,
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
      AppColors.stormMidSage,
      AppColors.stormRichGold,
    ],
    TemperatureTier.shortsWeather: [
      AppColors.stormBlue,
      AppColors.stormMidLavender,
      AppColors.stormRichTangerine,
    ],
    TemperatureTier.scorcher: [
      AppColors.stormBlue,
      AppColors.stormMidMauve,
      AppColors.stormRichRose,
    ],
  };

  static const _freezingRain = _heavyRain;

  static const _snow = {
    TemperatureTier.singleDigits: [
      AppColors.cream,
      AppColors.brightSkyPeriwinkle,
      AppColors.frostLavender,
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
      AppColors.deepPurple,
      AppColors.nightSunnyViolet,
      AppColors.nightPurple,
    ],
    TemperatureTier.freezing: [
      AppColors.deepPurple,
      AppColors.nightSunnyPeriwinkle,
      AppColors.nightBlue,
    ],
    TemperatureTier.jacketWeather: [
      AppColors.deepPurple,
      AppColors.nightSunnyBlue,
      AppColors.nightBlueTeal,
    ],
    TemperatureTier.flannelWeather: [
      AppColors.deepPurple,
      AppColors.nightSunnyTeal,
      AppColors.nightGreenTeal,
    ],
    TemperatureTier.shortsWeather: [
      AppColors.deepPurple,
      AppColors.nightSunnyLavender,
      AppColors.nightMagenta,
    ],
    TemperatureTier.scorcher: [
      AppColors.deepPurple,
      AppColors.nightSunnyMauve,
      AppColors.nightCoral,
    ],
  };

  static const _mostlySunnyNight = _sunnyNight;

  static const _partlyCloudyNight = _sunnyNight;

  static const _overcastNight = {
    TemperatureTier.singleDigits: [
      AppColors.midnightPurple,
      AppColors.nightOvercastViolet,
      AppColors.nightPurple,
    ],
    TemperatureTier.freezing: [
      AppColors.midnightPurple,
      AppColors.nightOvercastPeriwinkle,
      AppColors.nightBlue,
    ],
    TemperatureTier.jacketWeather: [
      AppColors.midnightPurple,
      AppColors.nightOvercastBlue,
      AppColors.nightBlueTeal,
    ],
    TemperatureTier.flannelWeather: [
      AppColors.midnightPurple,
      AppColors.nightOvercastTeal,
      AppColors.nightGreenTeal,
    ],
    TemperatureTier.shortsWeather: [
      AppColors.midnightPurple,
      AppColors.nightOvercastLavender,
      AppColors.nightCoral,
    ],
    TemperatureTier.scorcher: [
      AppColors.midnightPurple,
      AppColors.nightOvercastMauve,
      AppColors.nightMagenta,
    ],
  };

  static const _foggyNight = _overcastNight;

  static const _drizzleNight = {
    TemperatureTier.singleDigits: [
      AppColors.pitchBlack,
      AppColors.nightDrizzleViolet,
      AppColors.nightPurple,
    ],
    TemperatureTier.freezing: [
      AppColors.pitchBlack,
      AppColors.nightDrizzlePeriwinkle,
      AppColors.nightBlue,
    ],
    TemperatureTier.jacketWeather: [
      AppColors.pitchBlack,
      AppColors.nightDrizzleBlue,
      AppColors.nightBlueTeal,
    ],
    TemperatureTier.flannelWeather: [
      AppColors.pitchBlack,
      AppColors.nightDrizzleTeal,
      AppColors.nightGreenTeal,
    ],
    TemperatureTier.shortsWeather: [
      AppColors.pitchBlack,
      AppColors.nightDrizzleLavender,
      AppColors.nightMagenta,
    ],
    TemperatureTier.scorcher: [
      AppColors.pitchBlack,
      AppColors.nightDrizzleMauve,
      AppColors.nightCoral,
    ],
  };

  static const _rainNight = {
    TemperatureTier.singleDigits: [
      AppColors.pitchBlack,
      AppColors.nightRainViolet,
      AppColors.nightPurple,
    ],
    TemperatureTier.freezing: [
      AppColors.pitchBlack,
      AppColors.nightRainPeriwinkle,
      AppColors.nightBlue,
    ],
    TemperatureTier.jacketWeather: [
      AppColors.pitchBlack,
      AppColors.nightRainBlue,
      AppColors.nightBlueTeal,
    ],
    TemperatureTier.flannelWeather: [
      AppColors.pitchBlack,
      AppColors.nightRainTeal,
      AppColors.nightGreenTeal,
    ],
    TemperatureTier.shortsWeather: [
      AppColors.pitchBlack,
      AppColors.nightRainLavender,
      AppColors.nightMagenta,
    ],
    TemperatureTier.scorcher: [
      AppColors.pitchBlack,
      AppColors.nightRainMauve,
      AppColors.nightCoral,
    ],
  };

  static const _heavyRainNight = {
    TemperatureTier.singleDigits: [
      AppColors.pitchBlack,
      AppColors.nightStormViolet,
      AppColors.nightPurple,
    ],
    TemperatureTier.freezing: [
      AppColors.pitchBlack,
      AppColors.nightStormPeriwinkle,
      AppColors.nightBlue,
    ],
    TemperatureTier.jacketWeather: [
      AppColors.pitchBlack,
      AppColors.nightStormBlue,
      AppColors.nightBlueTeal,
    ],
    TemperatureTier.flannelWeather: [
      AppColors.pitchBlack,
      AppColors.nightStormTeal,
      AppColors.nightGreenTeal,
    ],
    TemperatureTier.shortsWeather: [
      AppColors.pitchBlack,
      AppColors.nightStormLavender,
      AppColors.magenta,
    ],
    TemperatureTier.scorcher: [
      AppColors.pitchBlack,
      AppColors.nightStormMauve,
      AppColors.orangeRed,
    ],
  };

  static const _freezingRainNight = _heavyRainNight;

  static const _snowNight = {
    TemperatureTier.singleDigits: [
      AppColors.midnightPurple,
      AppColors.deepPurple,
      AppColors.brightFrostLavender,
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
