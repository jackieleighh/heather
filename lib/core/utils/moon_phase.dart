import 'dart:math' as math;

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

/// A known new moon: Jan 18, 2026 19:51 UTC.
final _referenceNewMoon = DateTime.utc(2026, 1, 18, 19, 51);

/// Returns the number of days into the current lunar cycle (0 – ~29.53).
double moonAge(DateTime date) {
  final days = date.toUtc().difference(_referenceNewMoon).inSeconds / 86400;
  return days % _synodicMonth;
}

/// Returns the approximate illumination percentage (0–100) for a given [date].
///
/// Uses the cosine model: 0% at new moon (fraction 0), 100% at full moon
/// (fraction 0.5).
double moonIllumination(DateTime date) {
  final age = moonAge(date);
  final fraction = age / _synodicMonth;
  return (1 - math.cos(2 * math.pi * fraction)) / 2 * 100;
}

/// Returns the [MoonPhase] for a given [date].
///
/// Principal phases (new, quarters, full) get a narrow ±0.04 window
/// (~2.4 days) centred on their astronomical moment, with intermediate
/// phases (crescents, gibbous) filling the rest (~5 days each).
MoonPhase getMoonPhase(DateTime date) {
  final age = moonAge(date);
  final fraction = age / _synodicMonth; // 0.0 – 1.0

  if (fraction < 0.04) return MoonPhase.newMoon;
  if (fraction < 0.21) return MoonPhase.waxingCrescent;
  if (fraction < 0.29) return MoonPhase.firstQuarter;
  if (fraction < 0.46) return MoonPhase.waxingGibbous;
  if (fraction < 0.54) return MoonPhase.fullMoon;
  if (fraction < 0.71) return MoonPhase.waningGibbous;
  if (fraction < 0.79) return MoonPhase.thirdQuarter;
  if (fraction < 0.96) return MoonPhase.waningCrescent;
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

  if (fraction < 0.04) return WeatherIcons.moon_new;
  if (fraction < 0.21) {
    final sub = _subIndex(fraction, 0.04, 0.21);
    return _waxingCrescentIcons[sub];
  }
  if (fraction < 0.29) return WeatherIcons.moon_first_quarter;
  if (fraction < 0.46) {
    final sub = _subIndex(fraction, 0.29, 0.46);
    return _waxingGibbousIcons[sub];
  }
  if (fraction < 0.54) return WeatherIcons.moon_full;
  if (fraction < 0.71) {
    final sub = _subIndex(fraction, 0.54, 0.71);
    return _waningGibbousIcons[sub];
  }
  if (fraction < 0.79) return WeatherIcons.moon_third_quarter;
  if (fraction < 0.96) {
    final sub = _subIndex(fraction, 0.79, 0.96);
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

/// Returns the approximate date of the next new moon after [from].
/// Computes the exact moment from the lunar cycle rather than scanning days.
DateTime nextNewMoon([DateTime? from]) {
  final date = from ?? DateTime.now();
  final age = moonAge(date);
  var daysUntil = _synodicMonth - age;
  if (daysUntil < 1.0) daysUntil += _synodicMonth;
  final moment = date.add(Duration(minutes: (daysUntil * 1440).round()));
  return DateTime(moment.year, moment.month, moment.day);
}

/// Returns the approximate date of the next full moon after [from].
/// Computes the exact moment from the lunar cycle rather than scanning days.
DateTime nextFullMoon([DateTime? from]) {
  final date = from ?? DateTime.now();
  final age = moonAge(date);
  var daysUntil = _synodicMonth / 2 - age;
  if (daysUntil <= 0) daysUntil += _synodicMonth;
  if (daysUntil < 1.0) daysUntil += _synodicMonth;
  final moment = date.add(Duration(minutes: (daysUntil * 1440).round()));
  return DateTime(moment.year, moment.month, moment.day);
}
