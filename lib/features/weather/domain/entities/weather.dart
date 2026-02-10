import 'package:freezed_annotation/freezed_annotation.dart';

import 'weather_condition.dart';

part 'weather.freezed.dart';

@freezed
class Weather with _$Weather {
  const factory Weather({
    required double temperature,
    required double feelsLike,
    required int humidity,
    required double windSpeed,
    required int weatherCode,
    required WeatherCondition condition,
    required String description,
    required bool isDay,
    required double precipitation,
    required int cloudCover,
  }) = _Weather;
}
