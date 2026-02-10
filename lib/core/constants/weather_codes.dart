import '../../features/weather/domain/entities/weather_condition.dart';

class WeatherCodes {
  WeatherCodes._();

  static WeatherCondition fromWmo(int code) {
    return switch (code) {
      0 || 1 => WeatherCondition.clear,
      2 || 3 => WeatherCondition.cloudy,
      45 || 48 => WeatherCondition.fog,
      51 || 53 || 55 || 56 || 57 => WeatherCondition.drizzle,
      61 || 63 || 65 || 66 || 67 || 80 || 81 || 82 => WeatherCondition.rain,
      71 || 73 || 75 || 77 || 85 || 86 => WeatherCondition.snow,
      95 || 96 || 99 => WeatherCondition.thunderstorm,
      _ => WeatherCondition.clear,
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
