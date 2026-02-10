import 'package:flutter/material.dart';
import 'package:weather_icons/weather_icons.dart';

import '../constants/weather_codes.dart';

IconData conditionIcon(int code) {
  final condition = WeatherCodes.fromWmo(code);
  return switch (condition.name) {
    'sunny' => WeatherIcons.day_sunny,
    'mostlySunny' => WeatherIcons.day_sunny_overcast,
    'partlyCloudy' => WeatherIcons.day_cloudy,
    'overcast' => WeatherIcons.cloudy,
    'foggy' => WeatherIcons.fog,
    'drizzle' => WeatherIcons.sprinkle,
    'rain' => WeatherIcons.rain,
    'heavyRain' => WeatherIcons.rain_wind,
    'freezingRain' => WeatherIcons.rain_mix,
    'snow' => WeatherIcons.snow,
    'blizzard' => WeatherIcons.snow_wind,
    'thunderstorm' => WeatherIcons.thunderstorm,
    'hail' => WeatherIcons.hail,
    _ => WeatherIcons.na,
  };
}
