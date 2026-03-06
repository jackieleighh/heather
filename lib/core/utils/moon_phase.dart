import 'package:weather_icons/weather_icons.dart';
import 'package:flutter/widgets.dart';

enum MoonPhase {
  newMoon,
  waxingCrescent,
  firstQuarter,
  waxingGibbous,
  fullMoon,
  waningGibbous,
  thirdQuarter,
  waningCrescent,
}

/// Returns a display label for the given [phase].
String moonPhaseLabel(MoonPhase phase) => switch (phase) {
  MoonPhase.newMoon => 'New Moon',
  MoonPhase.waxingCrescent => 'Waxing Crescent',
  MoonPhase.firstQuarter => 'First Quarter',
  MoonPhase.waxingGibbous => 'Waxing Gibbous',
  MoonPhase.fullMoon => 'Full Moon',
  MoonPhase.waningGibbous => 'Waning Gibbous',
  MoonPhase.thirdQuarter => 'Third Quarter',
  MoonPhase.waningCrescent => 'Waning Crescent',
};

/// Maps a USNO API phase name string to a [MoonPhase] enum value.
MoonPhase? usnoPhaseToEnum(String usnoPhase) => switch (usnoPhase) {
  'New Moon' => MoonPhase.newMoon,
  'Waxing Crescent' => MoonPhase.waxingCrescent,
  'First Quarter' => MoonPhase.firstQuarter,
  'Waxing Gibbous' => MoonPhase.waxingGibbous,
  'Full Moon' => MoonPhase.fullMoon,
  'Waning Gibbous' => MoonPhase.waningGibbous,
  'Last Quarter' => MoonPhase.thirdQuarter,
  'Third Quarter' => MoonPhase.thirdQuarter,
  'Waning Crescent' => MoonPhase.waningCrescent,
  _ => null,
};

/// Returns the [MoonPhase] for a given cycle [fraction] (0.0–1.0).
MoonPhase phaseFromFraction(double fraction) {
  final f = fraction % 1.0;
  if (f < 0.04) return MoonPhase.newMoon;
  if (f < 0.21) return MoonPhase.waxingCrescent;
  if (f < 0.29) return MoonPhase.firstQuarter;
  if (f < 0.46) return MoonPhase.waxingGibbous;
  if (f < 0.54) return MoonPhase.fullMoon;
  if (f < 0.71) return MoonPhase.waningGibbous;
  if (f < 0.79) return MoonPhase.thirdQuarter;
  if (f < 0.96) return MoonPhase.waningCrescent;
  return MoonPhase.newMoon;
}

/// Returns the appropriate [WeatherIcons] moon icon for a given cycle
/// [fraction] (0.0–1.0, where 0 = new moon, 0.5 = full moon).
IconData moonPhaseIcon(double fraction) {
  final f = fraction % 1.0;

  if (f < 0.04) return WeatherIcons.moon_new;
  if (f < 0.21) {
    final sub = _subIndex(f, 0.04, 0.21);
    return _waxingCrescentIcons[sub];
  }
  if (f < 0.29) return WeatherIcons.moon_first_quarter;
  if (f < 0.46) {
    final sub = _subIndex(f, 0.29, 0.46);
    return _waxingGibbousIcons[sub];
  }
  if (f < 0.54) return WeatherIcons.moon_full;
  if (f < 0.71) {
    final sub = _subIndex(f, 0.54, 0.71);
    return _waningGibbousIcons[sub];
  }
  if (f < 0.79) return WeatherIcons.moon_third_quarter;
  if (f < 0.96) {
    final sub = _subIndex(f, 0.79, 0.96);
    return _waningCrescentIcons[sub];
  }
  return WeatherIcons.moon_new;
}

int _subIndex(double fraction, double start, double end) =>
    ((fraction - start) / (end - start) * 6).floor().clamp(0, 5);

const _waxingCrescentIcons = [
  WeatherIcons.moon_waxing_crescent_1,
  WeatherIcons.moon_waxing_crescent_2,
  WeatherIcons.moon_waxing_crescent_3,
  WeatherIcons.moon_waxing_crescent_4,
  WeatherIcons.moon_waxing_crescent_5,
  WeatherIcons.moon_waxing_crescent_6,
];

const _waxingGibbousIcons = [
  WeatherIcons.moon_waxing_gibbous_1,
  WeatherIcons.moon_waxing_gibbous_2,
  WeatherIcons.moon_waxing_gibbous_3,
  WeatherIcons.moon_waxing_gibbous_4,
  WeatherIcons.moon_waxing_gibbous_5,
  WeatherIcons.moon_waxing_gibbous_6,
];

const _waningGibbousIcons = [
  WeatherIcons.moon_waning_gibbous_1,
  WeatherIcons.moon_waning_gibbous_2,
  WeatherIcons.moon_waning_gibbous_3,
  WeatherIcons.moon_waning_gibbous_4,
  WeatherIcons.moon_waning_gibbous_5,
  WeatherIcons.moon_waning_gibbous_6,
];

const _waningCrescentIcons = [
  WeatherIcons.moon_waning_crescent_1,
  WeatherIcons.moon_waning_crescent_2,
  WeatherIcons.moon_waning_crescent_3,
  WeatherIcons.moon_waning_crescent_4,
  WeatherIcons.moon_waning_crescent_5,
  WeatherIcons.moon_waning_crescent_6,
];

/// Returns the traditional name for a full moon based on its month.
String fullMoonName(DateTime fullMoonDate) => switch (fullMoonDate.month) {
  1 => 'Wolf Moon',
  2 => 'Snow Moon',
  3 => 'Worm Moon',
  4 => 'Pink Moon',
  5 => 'Flower Moon',
  6 => 'Strawberry Moon',
  7 => 'Buck Moon',
  8 => 'Sturgeon Moon',
  9 => 'Harvest Moon',
  10 => "Hunter's Moon",
  11 => 'Beaver Moon',
  12 => 'Cold Moon',
  _ => 'Full Moon',
};
