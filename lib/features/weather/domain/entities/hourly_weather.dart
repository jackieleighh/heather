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
    @Default(0.0) double uvIndex,
    @Default(0.0) double feelsLike,
    @Default(0.0) double windGusts,
    @Default(0) int windDirection,
    @Default(0) int humidity,
    @Default(0.0) double pressure,
    @Default(0.0) double precipitation,
    @Default(0) int cloudCover,
    @Default(0.0) double dewPoint,
    @Default(0.0) double visibility,
  }) = _HourlyWeather;
}
