import 'package:flutter/material.dart';
import 'package:weather_icons/weather_icons.dart';

import '../constants/weather_codes.dart';

IconData conditionIcon(int code) {
  final condition = WeatherCodes.fromWmo(code);
  return switch (condition.name) {
    'clear' => WeatherIcons.day_sunny,
    'cloudy' => WeatherIcons.cloudy,
    'rain' => WeatherIcons.rain,
    'drizzle' => WeatherIcons.sprinkle,
    'snow' => WeatherIcons.snow,
    'thunderstorm' => WeatherIcons.thunderstorm,
    'fog' => WeatherIcons.fog,
    _ => WeatherIcons.day_sunny,
  };
}
