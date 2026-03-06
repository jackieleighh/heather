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

  static bool isPrecipitation(WeatherCondition condition) =>
      _precipSeverity.contains(condition);

  static const _precipSeverity = [
    WeatherCondition.hail,
    WeatherCondition.thunderstorm,
    WeatherCondition.blizzard,
    WeatherCondition.heavyRain,
    WeatherCondition.freezingRain,
    WeatherCondition.snow,
    WeatherCondition.rain,
    WeatherCondition.drizzle,
  ];

  static const _clearConditions = {
    WeatherCondition.sunny,
    WeatherCondition.mostlySunny,
  };

  static const _cloudyConditions = {
    WeatherCondition.partlyCloudy,
    WeatherCondition.overcast,
  };

  static const canonicalWmoCode = {
    WeatherCondition.sunny: 0,
    WeatherCondition.mostlySunny: 1,
    WeatherCondition.partlyCloudy: 2,
    WeatherCondition.overcast: 3,
    WeatherCondition.foggy: 45,
    WeatherCondition.drizzle: 51,
    WeatherCondition.rain: 61,
    WeatherCondition.heavyRain: 65,
    WeatherCondition.freezingRain: 66,
    WeatherCondition.snow: 71,
    WeatherCondition.blizzard: 75,
    WeatherCondition.thunderstorm: 95,
    WeatherCondition.hail: 96,
    WeatherCondition.unknown: 0,
  };

  static WeatherCondition dominantDaytimeCondition(
    List<WeatherCondition> conditions,
  ) {
    if (conditions.isEmpty) return WeatherCondition.unknown;

    // Tier 1: precipitation wins by severity
    final precipSet = conditions.toSet().intersection(_precipSeverity.toSet());
    if (precipSet.isNotEmpty) {
      for (final severity in _precipSeverity) {
        if (precipSet.contains(severity)) return severity;
      }
    }

    // Tier 2: sky condition — ignore fog hours
    final sky = conditions.where((c) => c != WeatherCondition.foggy).toList();

    if (sky.isEmpty) return WeatherCondition.foggy;

    final hasClear = sky.any((c) => _clearConditions.contains(c));
    final hasCloudy = sky.any((c) => _cloudyConditions.contains(c));

    if (hasClear && hasCloudy) return WeatherCondition.partlyCloudy;
    if (hasCloudy) return WeatherCondition.overcast;

    // Only clear-ish — return most frequent
    final clearOnly = sky.where((c) => _clearConditions.contains(c)).toList();
    if (clearOnly.isNotEmpty) {
      final freq = <WeatherCondition, int>{};
      for (final c in clearOnly) {
        freq[c] = (freq[c] ?? 0) + 1;
      }
      return freq.entries.reduce((a, b) => a.value >= b.value ? a : b).key;
    }

    // Fallback: most frequent of whatever remains
    final freq = <WeatherCondition, int>{};
    for (final c in sky) {
      freq[c] = (freq[c] ?? 0) + 1;
    }
    return freq.entries.reduce((a, b) => a.value >= b.value ? a : b).key;
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
      82 => 'Heavy rain showers',
      85 => 'Light snow showers',
      86 => 'Heavy snow showers',
      95 => 'Thunderstorm',
      96 => 'Thunderstorm with slight hail',
      99 => 'Thunderstorm with heavy hail',
      _ => 'Unknown',
    };
  }
}
