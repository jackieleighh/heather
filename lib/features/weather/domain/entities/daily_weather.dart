import 'package:freezed_annotation/freezed_annotation.dart';

import 'weather_condition.dart';

part 'daily_weather.freezed.dart';

@freezed
class DailyWeather with _$DailyWeather {
  const factory DailyWeather({
    required DateTime date,
    required double temperatureMax,
    required double temperatureMin,
    required int weatherCode,
    required WeatherCondition condition,
    required double precipitationSum,
    required int precipitationProbabilityMax,
    required DateTime sunrise,
    required DateTime sunset,
  }) = _DailyWeather;
}
