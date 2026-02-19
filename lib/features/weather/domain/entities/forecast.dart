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
    @Default([]) List<HourlyWeather> hourlyToday,
    @Default([]) List<HourlyWeather> hourlyAll,
    required List<DailyWeather> daily,
    required int utcOffsetSeconds,
  }) = _Forecast;

  /// Today's daily entry, matched by calendar date at the forecast location.
  DailyWeather get todayDaily {
    final now = locationNow;
    return daily.firstWhere(
      (d) =>
          d.date.year == now.year &&
          d.date.month == now.month &&
          d.date.day == now.day,
      orElse: () => daily.first,
    );
  }

  /// Current time at the forecast location, as a local-flagged DateTime
  /// so comparisons with API-parsed times (also local-flagged) work correctly.
  DateTime get locationNow {
    final deviceNow = DateTime.now();
    final locationOffset = Duration(seconds: utcOffsetSeconds);
    return deviceNow.add(locationOffset - deviceNow.timeZoneOffset);
  }

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

  /// Returns hourly data for a specific date, filtered from hourlyAll.
  List<HourlyWeather> hourlyForDay(DateTime date) {
    final dayStart = DateTime(date.year, date.month, date.day);
    final dayEnd = dayStart.add(const Duration(days: 1));
    return hourlyAll
        .where((h) => !h.time.isBefore(dayStart) && h.time.isBefore(dayEnd))
        .toList();
  }
}
