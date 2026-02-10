import '../../features/weather/domain/entities/weather_condition.dart';

class WeatherCodes {
  WeatherCodes._();

  static WeatherCondition fromWmo(int code) {
    return switch (code) {
      0 => WeatherCondition.sunny,
      1 => WeatherCondition.mostlySunny,
      2 => WeatherCondition.partlyCloudy,
      3 => WeatherCondition.overcast,
      45 || 48 => WeatherCondition.foggy,
      51 || 53 || 55 => WeatherCondition.drizzle,
      56 || 57 => WeatherCondition.freezingRain,
      61 || 63 => WeatherCondition.rain,
      65 => WeatherCondition.heavyRain,
      66 || 67 => WeatherCondition.freezingRain,
      71 || 73 || 77 => WeatherCondition.snow,
      75 => WeatherCondition.blizzard,
      80 => WeatherCondition.drizzle,
      81 => WeatherCondition.rain,
      82 => WeatherCondition.heavyRain,
      85 => WeatherCondition.snow,
      86 => WeatherCondition.blizzard,
      95 => WeatherCondition.thunderstorm,
      96 || 99 => WeatherCondition.hail,
      _ => WeatherCondition.unknown,
    };
  }

  static String description(int code) {
    return switch (code) {
      0 => 'Clear sky',
      1 => 'Mainly clear',
      2 => 'Partly cloudy',
      3 => 'Overcast',
      45 => 'Foggy',
      48 => 'Depositing rime fog',
      51 => 'Light drizzle',
      53 => 'Moderate drizzle',
      55 => 'Dense drizzle',
      56 => 'Light freezing drizzle',
      57 => 'Dense freezing drizzle',
      61 => 'Slight rain',
      63 => 'Moderate rain',
      65 => 'Heavy rain',
      66 => 'Light freezing rain',
      67 => 'Heavy freezing rain',
      71 => 'Slight snowfall',
      73 => 'Moderate snowfall',
      75 => 'Heavy snowfall',
      77 => 'Snow grains',
      80 => 'Slight rain showers',
      81 => 'Moderate rain showers',
      82 => 'Violent rain showers',
      85 => 'Slight snow showers',
      86 => 'Heavy snow showers',
      95 => 'Thunderstorm',
      96 => 'Thunderstorm with slight hail',
      99 => 'Thunderstorm with heavy hail',
      _ => 'Unknown',
    };
  }
}
