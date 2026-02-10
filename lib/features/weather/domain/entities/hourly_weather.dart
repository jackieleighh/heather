import 'package:freezed_annotation/freezed_annotation.dart';

import 'weather_condition.dart';

part 'hourly_weather.freezed.dart';

@freezed
class HourlyWeather with _$HourlyWeather {
  const factory HourlyWeather({
    required DateTime time,
    required double temperature,
    required int precipitationProbability,
    required int weatherCode,
    required WeatherCondition condition,
    required double windSpeed,
  }) = _HourlyWeather;
}
