import 'heather_night_quips.dart';
import 'heather_quips.dart';
import '../../features/weather/domain/entities/temperature_tier.dart';
import '../../features/weather/domain/entities/weather_condition.dart';

/// Returns the correct Heather quip map for the given tone and time of day.
///
/// PG mode (`altTone` false) → clean block only.
/// Non-PG mode (`altTone` true) → explicit only (falls back to clean for
/// any missing condition/tier combos).
Map<WeatherCondition, Map<TemperatureTier, List<String>>> heatherQuipMap({
  required bool altTone,
  required bool isDay,
}) {
  final clean = isDay ? HeatherQuips.quips : HeatherNightQuips.quips;
  if (!altTone) return clean;

  final explicit =
      isDay ? HeatherQuips.explicitQuips : HeatherNightQuips.explicitQuips;
  return {
    for (final condition in clean.keys)
      condition: {
        for (final tier in clean[condition]!.keys)
          tier: explicit[condition]?[tier]?.isNotEmpty == true
              ? explicit[condition]![tier]!
              : clean[condition]![tier]!,
      },
  };
}
