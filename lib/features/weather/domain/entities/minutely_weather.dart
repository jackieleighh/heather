import 'package:freezed_annotation/freezed_annotation.dart';

import 'daily_weather.dart';
import 'hourly_weather.dart';
import 'weather_condition.dart';

part 'minutely_weather.freezed.dart';

@freezed
class MinutelyWeather with _$MinutelyWeather {
  const factory MinutelyWeather({
    required DateTime time,
    required double precipitation,
    required double rain,
    required double snowfall,
  }) = _MinutelyWeather;
}

enum PrecipType {
  drizzle,
  slightRain,
  rain,
  heavyRain,
  flurries,
  snow,
  heavySnow,
  slush,
}

typedef PrecipForecast = ({
  bool isCurrentlyRaining,
  PrecipType precipType,
  int? onsetMinutes,
  int? durationMinutes,
});

/// Determines [PrecipType] from a minutely data point's rain (mm/15min)
/// and snowfall (cm/15min) values.
PrecipType _classifyPrecip(MinutelyWeather m) {
  if (m.rain > 0 && m.snowfall > 0) return PrecipType.slush;
  if (m.snowfall > 0) {
    if (m.snowfall > 0.5) return PrecipType.heavySnow;
    if (m.snowfall > 0.1) return PrecipType.snow;
    return PrecipType.flurries;
  }
  if (m.rain > 2.0) return PrecipType.heavyRain;
  if (m.rain > 0.5) return PrecipType.rain;
  if (m.rain > 0.1) return PrecipType.slightRain;
  return PrecipType.drizzle;
}

/// Display name for a [PrecipType].
String precipTypeName(PrecipType type) => switch (type) {
  PrecipType.drizzle => 'Drizzle',
  PrecipType.slightRain => 'Slight Rain',
  PrecipType.rain => 'Rain',
  PrecipType.heavyRain => 'Heavy Rain',
  PrecipType.flurries => 'Flurries',
  PrecipType.snow => 'Snow',
  PrecipType.heavySnow => 'Heavy Snow',
  PrecipType.slush => 'Slush',
};

/// Whether a [PrecipType] is snow-like (for icon selection).
bool isSnowType(PrecipType type) =>
    type == PrecipType.flurries ||
    type == PrecipType.snow ||
    type == PrecipType.heavySnow;

/// Analyzes minutely_15 data to determine precipitation onset and duration.
///
/// When [isCurrentlyRaining] is true, scans forward for when precipitation
/// stops. When false, finds the first onset within 60 minutes and its duration.
PrecipForecast? analyzePrecipitation({
  required List<MinutelyWeather> minutely15,
  required DateTime locationNow,
  required bool isCurrentlyRaining,
}) {
  if (minutely15.isEmpty) return null;

  // Check minutely data for current precipitation — this catches cases where
  // the condition code says "overcast" but the forecast model shows rain.
  var currentlyRaining = isCurrentlyRaining;
  final recent = minutely15.where((m) => !m.time.isAfter(locationNow)).toList();
  if (recent.isNotEmpty && recent.last.precipitation > 0) {
    currentlyRaining = true;
  }

  final future = minutely15.where((m) => m.time.isAfter(locationNow)).toList();
  if (future.isEmpty) return null;

  if (currentlyRaining) {
    // Find when precipitation stops
    for (var i = 0; i < future.length; i++) {
      if (future[i].precipitation <= 0) {
        // Check if rain resumes later — if so, this is just a brief lull
        final resumesLater = future.skip(i + 1).any((m) => m.precipitation > 0);
        if (resumesLater) {
          final refPoint = future.skip(i + 1).firstWhere(
            (m) => m.precipitation > 0,
            orElse: () => recent.isNotEmpty ? recent.last : future.first,
          );
          return (
            isCurrentlyRaining: true,
            precipType: _classifyPrecip(refPoint),
            onsetMinutes: null,
            durationMinutes: null,
          );
        }

        final minutes = future[i].time.difference(locationNow).inMinutes;
        final refPoint = recent.isNotEmpty ? recent.last : future.first;
        return (
          isCurrentlyRaining: true,
          precipType: _classifyPrecip(refPoint),
          onsetMinutes: minutes,
          durationMinutes: null,
        );
      }
    }
    // Rain continues beyond the data window
    final refPoint = recent.isNotEmpty ? recent.last : future.first;
    return (
      isCurrentlyRaining: true,
      precipType: _classifyPrecip(refPoint),
      onsetMinutes: null,
      durationMinutes: null,
    );
  }

  // Not currently raining — find onset within 60 minutes
  final cutoff = locationNow.add(const Duration(minutes: 60));
  int? onsetIndex;
  for (var i = 0; i < future.length; i++) {
    if (future[i].time.isAfter(cutoff)) break;
    if (future[i].precipitation > 0) {
      onsetIndex = i;
      break;
    }
  }
  if (onsetIndex == null) return null;

  final onsetMinutes = future[onsetIndex].time
      .difference(locationNow)
      .inMinutes;

  // Scan for duration — count consecutive precip intervals from onset
  int? durationMinutes;
  for (var i = onsetIndex + 1; i < future.length; i++) {
    if (future[i].precipitation <= 0) {
      durationMinutes = future[i].time
          .difference(future[onsetIndex].time)
          .inMinutes;
      break;
    }
  }

  return (
    isCurrentlyRaining: false,
    precipType: _classifyPrecip(future[onsetIndex]),
    onsetMinutes: onsetMinutes,
    durationMinutes: durationMinutes,
  );
}

/// Formats a [PrecipForecast] into a human-readable label.
String? formatPrecipLabel(PrecipForecast? forecast) {
  if (forecast == null) return null;

  final type = precipTypeName(forecast.precipType);

  if (forecast.isCurrentlyRaining) {
    final mins = forecast.onsetMinutes;
    if (mins == null) return type;
    return '$type stopping in ~${formatDuration(mins)}';
  }

  final onset = forecast.onsetMinutes;
  if (onset == null) return null;

  final dur = forecast.durationMinutes;
  if (dur != null) {
    return '${formatDuration(dur)} of ${type.toLowerCase()} in $onset min';
  }
  return '$type in $onset min';
}

String formatDuration(int minutes) {
  if (minutes >= 60) {
    final hours = minutes ~/ 60;
    final remaining = minutes % 60;
    if (remaining == 0) return '$hours hr';
    return '$hours hr $remaining min';
  }
  return '$minutes min';
}

/// Set of [WeatherCondition] values that represent active precipitation.
const precipConditions = {
  WeatherCondition.drizzle,
  WeatherCondition.rain,
  WeatherCondition.heavyRain,
  WeatherCondition.freezingRain,
  WeatherCondition.thunderstorm,
  WeatherCondition.hail,
  WeatherCondition.snow,
  WeatherCondition.blizzard,
};

/// Display name for a [WeatherCondition] when used in precip labels.
String conditionPrecipName(WeatherCondition condition) => switch (condition) {
      WeatherCondition.drizzle => 'Drizzle',
      WeatherCondition.rain => 'Rain',
      WeatherCondition.heavyRain => 'Heavy Rain',
      WeatherCondition.freezingRain => 'Freezing Rain',
      WeatherCondition.thunderstorm => 'Rain',
      WeatherCondition.hail => 'Hail',
      WeatherCondition.snow => 'Snow',
      WeatherCondition.blizzard => 'Heavy Snow',
      _ => 'Rain',
    };

/// Severity ranking for precipitation conditions (higher = more intense).
int precipSeverity(WeatherCondition c) => switch (c) {
      WeatherCondition.drizzle => 1,
      WeatherCondition.rain => 2,
      WeatherCondition.freezingRain => 3,
      WeatherCondition.heavyRain => 3,
      WeatherCondition.snow => 2,
      WeatherCondition.blizzard => 3,
      WeatherCondition.thunderstorm => 4,
      WeatherCondition.hail => 4,
      _ => 0,
    };

/// Builds a precip label from hourly forecast data, detecting intensity
/// transitions (escalation, rain↔snow, de-escalation) instead of only
/// reporting when precipitation stops.
String? hourlyPrecipLabel({
  required List<HourlyWeather> hourly,
  required WeatherCondition currentCondition,
  required DateTime locationNow,
  required List<DailyWeather> daily,
}) {
  final currentSlot =
      hourly.where((h) => !h.time.isAfter(locationNow)).lastOrNull;
  final hourlyShowsRain =
      currentSlot != null && precipConditions.contains(currentSlot.condition);
  final isRaining = precipConditions.contains(currentCondition);

  if (isRaining || hourlyShowsRain) {
    // Prefer the actual current condition when it's precipitation, since
    // it reflects what the user is experiencing right now.
    final activeCondition =
        isRaining ? currentCondition : (currentSlot?.condition ?? currentCondition);
    final activeSeverity = precipSeverity(activeCondition);
    final activeName = conditionPrecipName(activeCondition);

    WeatherCondition? peakCondition;
    DateTime? peakTime;
    String? nextChangeName;
    DateTime? nextChangeTime;
    DateTime? stopTime;

    for (final h in hourly) {
      if (!h.time.isAfter(locationNow)) continue;

      if (!precipConditions.contains(h.condition)) {
        stopTime = h.time;
        break;
      }

      final sev = precipSeverity(h.condition);
      final name = conditionPrecipName(h.condition);

      // Track peak (escalation) — highest severity seen
      if (sev > activeSeverity &&
          (peakCondition == null || sev > precipSeverity(peakCondition))) {
        peakCondition = h.condition;
        peakTime = h.time;
      }

      // Track first condition name change (covers de-escalation,
      // category shifts like rain↔snow, and same-severity changes
      // like hail→thunderstorm).
      if (nextChangeName == null && name != activeName) {
        nextChangeName = name;
        nextChangeTime = h.time;
      }
    }

    // Priority 1: Escalation (only when the display name actually differs)
    if (peakCondition != null) {
      final peakName = conditionPrecipName(peakCondition);
      if (peakName != activeName) {
        final minutes = peakTime!.difference(locationNow).inMinutes;
        return '$activeName → $peakName in ~${formatDuration(minutes)}';
      }
    }

    // Priority 2: Next condition change
    if (nextChangeName != null) {
      final minutes = nextChangeTime!.difference(locationNow).inMinutes;
      return '$activeName → $nextChangeName in ~${formatDuration(minutes)}';
    }

    // Priority 3: No transitions, stop found
    if (stopTime != null) {
      final minutes = stopTime.difference(locationNow).inMinutes;
      return '$activeName stopping in ~${formatDuration(minutes)}';
    }

    // Priority 4: No stop found — delegate to extended daily label
    return extendedPrecipLabel(daily: daily, locationNow: locationNow);
  }

  // Not currently raining — find onset within 1 hour (precise label)
  final cutoff = locationNow.add(const Duration(hours: 1));
  for (final h in hourly) {
    if (!h.time.isAfter(locationNow)) continue;
    if (h.time.isAfter(cutoff)) break;
    if (precipConditions.contains(h.condition)) {
      final minutes = h.time.difference(locationNow).inMinutes;
      return '${conditionPrecipName(h.condition)} in $minutes min';
    }
  }

  // Check rest of today — "60% chance of rain tonight"
  final endOfDay = DateTime(locationNow.year, locationNow.month, locationNow.day, 23, 59);
  int maxProb = 0;
  WeatherCondition? firstPrecipCondition;
  int? firstPrecipHour;
  for (final h in hourly) {
    if (!h.time.isAfter(cutoff)) continue;
    if (h.time.isAfter(endOfDay)) break;
    if (precipConditions.contains(h.condition)) {
      firstPrecipCondition ??= h.condition;
      firstPrecipHour ??= h.time.hour;
      if (h.precipitationProbability > maxProb) {
        maxProb = h.precipitationProbability;
      }
    }
  }
  if (firstPrecipCondition != null && maxProb >= 60) {
    final type = conditionPrecipName(firstPrecipCondition).toLowerCase();
    final hour = firstPrecipHour!;
    final h12 = hour == 0 ? 12 : (hour > 12 ? hour - 12 : hour);
    final amPm = hour >= 12 ? 'pm' : 'am';
    return '$maxProb% chance of $type ~ $h12$amPm';
  }
  return null;
}

/// Fallback label when precipitation extends beyond the minutely/hourly windows.
///
/// Counts consecutive rainy days in the daily forecast starting from today
/// and returns a label like "Rain for 3 days". Returns `null` if fewer than
/// 2 consecutive days have meaningful precipitation (≥ 0.1 mm).
String? extendedPrecipLabel({
  required List<DailyWeather> daily,
  required DateTime locationNow,
}) {
  final todayIndex = daily.indexWhere((d) =>
      d.date.year == locationNow.year &&
      d.date.month == locationNow.month &&
      d.date.day == locationNow.day);
  if (todayIndex < 0) return null;

  var count = 0;
  for (var i = todayIndex; i < daily.length; i++) {
    if (daily[i].precipitationSum < 0.1) break;
    count++;
  }

  if (count < 2) return null;

  final type = conditionPrecipName(daily[todayIndex].condition);
  return '$type for $count days';
}

/// Fallback label showing tomorrow's precipitation probability.
///
/// Returns a label like "80% chance of rain tomorrow" when the probability
/// is ≥ 60%. Derives precip type from the condition when it's a precipitation
/// condition, otherwise infers from temperature (≤ 0 °C → snow, else rain).
String? tomorrowPrecipLabel({
  required List<DailyWeather> daily,
  required DateTime locationNow,
}) {
  final tomorrow = locationNow.add(const Duration(days: 1));
  final tomorrowDay = daily.cast<DailyWeather?>().firstWhere(
        (d) =>
            d!.date.year == tomorrow.year &&
            d.date.month == tomorrow.month &&
            d.date.day == tomorrow.day,
        orElse: () => null,
      );
  if (tomorrowDay == null) return null;

  final prob = tomorrowDay.precipitationProbabilityMax;
  if (prob < 60) return null;

  final String type;
  if (precipConditions.contains(tomorrowDay.condition)) {
    type = conditionPrecipName(tomorrowDay.condition).toLowerCase();
  } else {
    type = tomorrowDay.temperatureMin <= 0 ? 'snow' : 'rain';
  }

  return '$prob% chance of $type tomorrow';
}
