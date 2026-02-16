import '../../../../core/constants/persona.dart';
import '../entities/weather.dart';

abstract class QuipRepository {
  /// Returns a random local quip instantly (no network).
  String getLocalQuip({
    required Weather weather,
    bool explicit = false,
    Persona persona = Persona.heather,
  });
}
