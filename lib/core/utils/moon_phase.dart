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

/// Length of one synodic month (new moon to new moon) in days.
const _synodicMonth = 29.53058770576;

/// A known new moon: Jan 18, 2026 19:53 UTC.
final _referenceNewMoon = DateTime.utc(2026, 1, 18, 19, 51);

/// Returns the number of days into the current lunar cycle (0 – ~29.53).
double moonAge(DateTime date) {
  final days = date.toUtc().difference(_referenceNewMoon).inSeconds / 86400;
  return days % _synodicMonth;
}

/// Returns the [MoonPhase] for a given [date].
MoonPhase getMoonPhase(DateTime date) {
  final age = moonAge(date);
  final fraction = age / _synodicMonth; // 0.0 – 1.0

  if (fraction < 0.0625) return MoonPhase.newMoon;
  if (fraction < 0.1875) return MoonPhase.waxingCrescent;
  if (fraction < 0.3125) return MoonPhase.firstQuarter;
  if (fraction < 0.4375) return MoonPhase.waxingGibbous;
  if (fraction < 0.5625) return MoonPhase.fullMoon;
  if (fraction < 0.6875) return MoonPhase.waningGibbous;
  if (fraction < 0.8125) return MoonPhase.thirdQuarter;
  if (fraction < 0.9375) return MoonPhase.waningCrescent;
  return MoonPhase.newMoon;
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

/// Returns the appropriate [WeatherIcons] moon icon for a given [date].
///
/// Uses the finer-grained `_1`–`_6` variants for crescent/gibbous phases
/// based on position within that phase window.
IconData moonPhaseIcon(DateTime date) {
  final age = moonAge(date);
  final fraction = age / _synodicMonth;

  if (fraction < 0.0625) return WeatherIcons.moon_new;
  if (fraction < 0.1875) {
    final sub = _subIndex(fraction, 0.0625, 0.1875);
    return _waxingCrescentIcons[sub];
  }
  if (fraction < 0.3125) return WeatherIcons.moon_first_quarter;
  if (fraction < 0.4375) {
    final sub = _subIndex(fraction, 0.3125, 0.4375);
    return _waxingGibbousIcons[sub];
  }
  if (fraction < 0.5625) return WeatherIcons.moon_full;
  if (fraction < 0.6875) {
    final sub = _subIndex(fraction, 0.5625, 0.6875);
    return _waningGibbousIcons[sub];
  }
  if (fraction < 0.8125) return WeatherIcons.moon_third_quarter;
  if (fraction < 0.9375) {
    final sub = _subIndex(fraction, 0.8125, 0.9375);
    return _waningCrescentIcons[sub];
  }
  return WeatherIcons.moon_new;
}

/// Maps [fraction] within [start]–[end] to an index 0–5.
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
