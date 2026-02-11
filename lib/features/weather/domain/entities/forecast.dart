import 'package:freezed_annotation/freezed_annotation.dart';

import 'daily_weather.dart';
import 'hourly_weather.dart';
import 'weather.dart';

part 'forecast.freezed.dart';

@freezed
class Forecast with _$Forecast {
  const Forecast._();

  const factory Forecast({
    required Weather current,
    required List<HourlyWeather> hourly,
    required List<DailyWeather> daily,
    required int utcOffsetSeconds,
  }) = _Forecast;

  /// Whether it's currently daytime at this location,
  /// computed from sunrise/sunset rather than the stale API snapshot.
  bool get isCurrentlyDay {
    final nowUtc = DateTime.now().toUtc();
    final localNow = nowUtc.add(Duration(seconds: utcOffsetSeconds));

    final todayDaily = daily.cast<DailyWeather?>().firstWhere(
          (d) =>
              d!.date.year == localNow.year &&
              d.date.month == localNow.month &&
              d.date.day == localNow.day,
          orElse: () => null,
        );
    if (todayDaily == null) return current.isDay;

    final localMinutes = localNow.hour * 60 + localNow.minute;
    final sunriseMinutes =
        todayDaily.sunrise.hour * 60 + todayDaily.sunrise.minute;
    final sunsetMinutes =
        todayDaily.sunset.hour * 60 + todayDaily.sunset.minute;

    return localMinutes >= sunriseMinutes && localMinutes < sunsetMinutes;
  }
}
