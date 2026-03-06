import 'dart:ui';

import '../../features/weather/domain/entities/daily_weather.dart';

/// Rough bounding box for US territories (CONUS, Alaska, Hawaii, PR/USVI, Guam).
bool isInUSBounds(double lat, double lon) {
  // Continental US
  if (lat >= 24.0 && lat <= 50.0 && lon >= -125.0 && lon <= -66.0) return true;
  // Alaska
  if (lat >= 51.0 && lat <= 72.0 && lon >= -180.0 && lon <= -129.0) return true;
  // Hawaii
  if (lat >= 18.5 && lat <= 22.5 && lon >= -161.0 && lon <= -154.0) return true;
  // Puerto Rico / US Virgin Islands
  if (lat >= 17.5 && lat <= 18.6 && lon >= -67.5 && lon <= -64.5) return true;
  // Guam / Northern Mariana Islands
  if (lat >= 13.0 && lat <= 21.0 && lon >= 144.0 && lon <= 146.5) return true;
  return false;
}

/// Whether [time] falls during daylight for the matching day in [daily].
///
/// Transition-hour logic: if sunrise/sunset falls within the hour,
/// day icon is used only if the hour has >30 min of daylight.
bool isHourDay(DateTime time, List<DailyWeather> daily) {
  DateTime? sunrise;
  DateTime? sunset;
  for (final day in daily) {
    if (day.date.year == time.year &&
        day.date.month == time.month &&
        day.date.day == time.day) {
      sunrise = day.sunrise;
      sunset = day.sunset;
      break;
    }
  }
  return isDayForSunTimes(time, sunrise: sunrise, sunset: sunset);
}

/// Whether [time] falls during daylight given explicit sunrise/sunset.
bool isDayForSunTimes(DateTime time, {DateTime? sunrise, DateTime? sunset}) {
  if (sunrise == null || sunset == null) return true;

  if (time.hour == sunrise.hour) {
    return (60 - sunrise.minute) > 30;
  }
  if (time.hour == sunset.hour) {
    return sunset.minute > 30;
  }

  final minutes = time.hour * 60 + time.minute;
  final sunriseMin = sunrise.hour * 60 + sunrise.minute;
  final sunsetMin = sunset.hour * 60 + sunset.minute;
  return minutes >= sunriseMin && minutes < sunsetMin;
}

/// Converts a [Color] to a hex string like `#AARRGGBB`.
String colorToHex(Color color) {
  return '#${color.toARGB32().toRadixString(16).padLeft(8, '0').toUpperCase()}';
}
