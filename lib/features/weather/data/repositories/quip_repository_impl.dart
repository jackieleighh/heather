import 'dart:math';

import '../../../../core/constants/persona.dart';
import '../../domain/entities/temperature_tier.dart';
import '../../domain/entities/weather.dart';
import '../../domain/repositories/quip_repository.dart';

class QuipRepositoryImpl implements QuipRepository {
  final Random _random = Random();

  @override
  String getLocalQuip({
    required Weather weather,
    bool explicit = false,
    Persona persona = Persona.heather,
  }) {
    final condition = weather.condition;
    final tier = TemperatureTier.fromTemperature(weather.temperature);
    final quipMap = persona.quipMap(altTone: explicit, isDay: weather.isDay);

    final quips =
        quipMap[condition]?[tier] ??
        quipMap[condition]?[TemperatureTier.flannelWeather] ??
        quipMap[condition]?[TemperatureTier.shortsWeather] ??
        quipMap.values.first.values.first;
    return quips[_random.nextInt(quips.length)];
  }
}
