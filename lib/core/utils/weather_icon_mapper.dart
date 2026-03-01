import 'package:flutter/material.dart';
import 'package:weather_icons/weather_icons.dart';

import '../constants/weather_codes.dart';

IconData conditionIcon(int code, {bool? isDay = true}) {
  final condition = WeatherCodes.fromWmo(code);
  if (isDay == null) {
    return switch (condition.name) {
      'sunny' => WeatherIcons.day_sunny,
      'mostlySunny' => WeatherIcons.cloud,
      'partlyCloudy' => WeatherIcons.cloudy,
      'overcast' => WeatherIcons.cloud,
      'foggy' => WeatherIcons.fog,
      'drizzle' => WeatherIcons.sprinkle,
      'rain' => WeatherIcons.rain,
      'heavyRain' => WeatherIcons.rain,
      'freezingRain' => WeatherIcons.sleet,
      'snow' => WeatherIcons.snow,
      'blizzard' => WeatherIcons.snow_wind,
      'thunderstorm' => WeatherIcons.thunderstorm,
      'hail' => WeatherIcons.hail,
      _ => WeatherIcons.na,
    };
  }
  return switch (condition.name) {
    'sunny' => isDay ? WeatherIcons.day_sunny : WeatherIcons.night_clear,
    'mostlySunny' =>
      isDay ? WeatherIcons.day_cloudy : WeatherIcons.night_alt_cloudy,
    'partlyCloudy' => isDay ? WeatherIcons.cloudy : WeatherIcons.night_cloudy,
    'overcast' => WeatherIcons.cloud,
    'foggy' => isDay ? WeatherIcons.day_fog : WeatherIcons.night_fog,
    'drizzle' =>
      isDay ? WeatherIcons.day_sprinkle : WeatherIcons.night_alt_sprinkle,
    'rain' => isDay ? WeatherIcons.day_rain : WeatherIcons.night_alt_rain,
    'heavyRain' => isDay ? WeatherIcons.day_rain : WeatherIcons.night_alt_rain,
    'freezingRain' =>
      isDay ? WeatherIcons.day_sleet : WeatherIcons.night_alt_sleet,
    'snow' => isDay ? WeatherIcons.day_snow : WeatherIcons.night_alt_snow,
    'blizzard' =>
      isDay ? WeatherIcons.day_snow_wind : WeatherIcons.night_alt_snow_wind,
    'thunderstorm' =>
      isDay
          ? WeatherIcons.day_thunderstorm
          : WeatherIcons.night_alt_thunderstorm,
    'hail' => isDay ? WeatherIcons.day_hail : WeatherIcons.night_alt_hail,
    _ => WeatherIcons.na,
  };
}
