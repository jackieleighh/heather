import '../entities/weather.dart';

abstract class QuipRepository {
  /// Returns a random local quip instantly (no network).
  String getLocalQuip({required Weather weather, bool explicit = false});

  /// Fetches quips for all [locations] in a single Gemini call.
  /// Returns a map of cityName → quip.
  /// Falls back to local quips for any location that fails.
  Future<Map<String, String>> getBatchQuips({
    required List<({Weather weather, String cityName})> locations,
    bool explicit = false,
  });
}
