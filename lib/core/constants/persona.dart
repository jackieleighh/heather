import 'heather_night_quips.dart';
import 'heather_quips.dart';
import '../../features/weather/domain/entities/temperature_tier.dart';
import '../../features/weather/domain/entities/weather_condition.dart';

/// Returns the correct Heather quip map for the given tone and time of day.
Map<WeatherCondition, Map<TemperatureTier, List<String>>> heatherQuipMap({
  required bool altTone,
  required bool isDay,
}) {
  return isDay
      ? (altTone ? HeatherQuips.explicitQuips : HeatherQuips.quips)
      : (altTone ? HeatherNightQuips.explicitQuips : HeatherNightQuips.quips);
}
