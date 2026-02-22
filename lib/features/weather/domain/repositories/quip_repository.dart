import '../entities/weather.dart';

abstract class QuipRepository {
  /// Returns a random local quip instantly (no network).
  String getLocalQuip({
    required Weather weather,
    bool explicit = false,
  });
}
