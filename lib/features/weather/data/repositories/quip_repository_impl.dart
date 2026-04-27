import 'dart:math';

import '../../../../core/constants/persona.dart';
import '../../../../core/constants/quips/alert_quip_category.dart';
import '../../../../core/constants/quips/clean/alert_quips.dart';
import '../../../../core/constants/quips/explicit/alert_quips.dart';
import '../../domain/entities/temperature_tier.dart';
import '../../domain/entities/weather.dart';
import '../../domain/entities/weather_alert.dart';
import '../../domain/repositories/quip_repository.dart';

class QuipRepositoryImpl implements QuipRepository {
  final Random _random = Random();

  @override
  String getLocalQuip({required Weather weather, bool explicit = false}) {
    final condition = weather.condition;
    final tier = TemperatureTier.fromTemperature(weather.temperature);
    final quipMap = heatherQuipMap(altTone: explicit, isDay: weather.isDay);

    final quips =
        quipMap[condition]?[tier] ??
        quipMap[condition]?[TemperatureTier.flannelWeather] ??
        quipMap[condition]?[TemperatureTier.shortsWeather] ??
        quipMap.values.first.values.first;
    return quips[_random.nextInt(quips.length)];
  }

  @override
  String? getAlertQuip({
    required List<WeatherAlert> alerts,
    bool explicit = false,
  }) {
    for (final alert in alerts) {
      final category = AlertQuipCategory.fromEvent(alert.event, alert.severity);
      if (category != null) {
        final quips = explicit
            ? alertExplicitQuips[category]!
            : alertCleanQuips[category]!;
        return quips[_random.nextInt(quips.length)];
      }
    }
    return null;
  }
}
