import '../entities/weather.dart';
import '../entities/weather_alert.dart';

abstract class QuipRepository {
  /// Returns a random local quip instantly (no network).
  String getLocalQuip({
    required Weather weather,
    bool explicit = false,
  });

  /// Returns an alert-aware quip for the first extreme/severe alert,
  /// or `null` if no qualifying alert is active.
  String? getAlertQuip({
    required List<WeatherAlert> alerts,
    bool explicit = false,
  });
}
