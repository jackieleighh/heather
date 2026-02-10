import 'package:freezed_annotation/freezed_annotation.dart';

import 'daily_weather.dart';
import 'hourly_weather.dart';
import 'weather.dart';

part 'forecast.freezed.dart';

@freezed
class Forecast with _$Forecast {
  const factory Forecast({
    required Weather current,
    required List<HourlyWeather> hourly,
    required List<DailyWeather> daily,
  }) = _Forecast;
}
