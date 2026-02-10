enum WeatherCondition {
  sunny,
  mostlySunny,
  partlyCloudy,
  overcast,
  foggy,
  drizzle,
  rain,
  heavyRain,
  freezingRain,
  snow,
  blizzard,
  thunderstorm,
  hail,
  unknown;

  bool get isMild => switch (this) {
    sunny || mostlySunny || partlyCloudy || overcast => true,
    _ => false,
  };
}
