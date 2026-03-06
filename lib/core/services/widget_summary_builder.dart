import 'dart:math';

import '../../features/weather/domain/entities/forecast.dart';
import '../../features/weather/domain/entities/minutely_weather.dart';
import '../../features/weather/domain/entities/temperature_tier.dart';
import '../../features/weather/domain/entities/weather_condition.dart';
import '../utils/astro_events.dart';

// ---------------------------------------------------------------------------
// Summary builder
// ---------------------------------------------------------------------------

/// Builds a contextual 1-2 sentence weather summary for the medium widget.
///
/// Uses time-stable random selection that changes every 3 hours, matching
/// the quip rotation pattern.
String buildWidgetSummary({
  required Forecast forecast,
  String? alertLabel,
  List<String> visiblePlanets = const [],
  String? moonPhase,
  int? moonIllumination,
}) {
  final current = forecast.current;
  final isDay = forecast.isCurrentlyDay;
  final tier = TemperatureTier.fromTemperature(current.temperature);
  final condition = current.condition;
  final locationNow = forecast.locationNow;

  // Time-stable seed: changes every 3 hours
  final seed = locationNow.millisecondsSinceEpoch ~/ (3 * 60 * 60 * 1000);
  final rng = Random(seed);

  // Compute precip info for templates
  final precipLabel = _computeWidgetPrecipInfo(forecast);
  final isRaining = precipConditions.contains(condition);

  // Check for upcoming precip onset
  String? precipOnsetTime;
  if (!isRaining) {
    for (final h in forecast.hourly) {
      if (!h.time.isAfter(locationNow)) continue;
      if (h.time.difference(locationNow).inHours > 6) break;
      if (precipConditions.contains(h.condition) && h.precipitationProbability >= 60) {
        final hour = h.time.hour;
        final h12 = hour == 0 ? 12 : (hour > 12 ? hour - 12 : hour);
        final amPm = hour >= 12 ? 'pm' : 'am';
        precipOnsetTime = '$h12$amPm';
        break;
      }
    }
  }

  // Find when precip clears (for "til Xpm" phrasing)
  String? clearTime;
  if (isRaining) {
    for (final h in forecast.hourly) {
      if (!h.time.isAfter(locationNow)) continue;
      if (!precipConditions.contains(h.condition)) {
        final hour = h.time.hour;
        final h12 = hour == 0 ? 12 : (hour > 12 ? hour - 12 : hour);
        final amPm = hour >= 12 ? 'pm' : 'am';
        clearTime = '$h12$amPm';
        break;
      }
    }
  }

  // Celestial data for night mode
  final astroEvent = activeAstroEvent(locationNow);
  final moonPhaseName = moonPhase;
  final moonIllum = moonIllumination;
  final planetsStr = visiblePlanets.isNotEmpty
      ? visiblePlanets.join(' & ')
      : null;

  // Priority 1: Alert override
  if (alertLabel != null) {
    return _pickRandom(rng, _alertSummaries(alertLabel, tier));
  }

  if (isDay) {
    return _buildDaySummary(
      rng: rng,
      condition: condition,
      tier: tier,
      isRaining: isRaining,
      precipOnsetTime: precipOnsetTime,
      clearTime: clearTime,
      precipLabel: precipLabel,
      forecast: forecast,
    );
  } else {
    return _buildNightSummary(
      rng: rng,
      condition: condition,
      tier: tier,
      isRaining: isRaining,
      clearTime: clearTime,
      precipLabel: precipLabel,
      moonPhase: moonPhaseName,
      moonIllum: moonIllum,
      planetsStr: planetsStr,
      astroEvent: astroEvent,
      forecast: forecast,
    );
  }
}

String _pickRandom(Random rng, List<String> options) {
  return options[rng.nextInt(options.length)];
}

// ---------------------------------------------------------------------------
// Alert summaries
// ---------------------------------------------------------------------------

List<String> _alertSummaries(String alertLabel, TemperatureTier tier) {
  final tempAdvice = switch (tier) {
    TemperatureTier.singleDigits ||
    TemperatureTier.freezing => 'Bundle up out there babe.',
    TemperatureTier.jacketWeather => 'Layer up and stay safe.',
    TemperatureTier.flannelWeather => 'Stay alert and stay safe.',
    TemperatureTier.shortsWeather ||
    TemperatureTier.scorcher => 'Stay safe out there.',
  };
  // Strip the ⚠ prefix if present for cleaner sentence
  final event = alertLabel.replaceFirst('\u26A0 ', '');
  return [
    '$event in effect. $tempAdvice',
    '$event active. $tempAdvice',
    'Heads up — $event. $tempAdvice',
  ];
}

// ---------------------------------------------------------------------------
// Day summaries
// ---------------------------------------------------------------------------

String _buildDaySummary({
  required Random rng,
  required WeatherCondition condition,
  required TemperatureTier tier,
  required bool isRaining,
  required String? precipOnsetTime,
  required String? clearTime,
  required String? precipLabel,
  required Forecast forecast,
}) {
  // Precipitating now
  if (isRaining) {
    final tempVibe = _tempVibe(tier);
    if (clearTime != null) {
      return _pickRandom(rng, [
        'Umbrella weather til $clearTime, then clearing up. $tempVibe',
        'Wet out there til $clearTime. $tempVibe',
        'Rain holding til $clearTime, then things improve babe. $tempVibe',
      ]);
    }
    // No clear time found — rain all day
    return _pickRandom(rng, [
      '${_precipName(condition)} all day vibes. $tempVibe',
      'Bring your umbrella — ${_precipName(condition).toLowerCase()} isn\'t quitting. $tempVibe',
      'Cozy inside weather. ${_precipName(condition)} all day. $tempVibe',
    ]);
  }

  // Precip coming soon
  if (precipOnsetTime != null) {
    return _pickRandom(rng, [
      '${_precipName(condition)} rolling in around $precipOnsetTime. Grab an umbrella before you head out.',
      'Dry for now, but rain\'s coming around $precipOnsetTime. Plan accordingly babe.',
      'Enjoy the dry window — ${_precipName(condition).toLowerCase()} expected by $precipOnsetTime.',
    ]);
  }

  // Clear day — condition + temp tier vibe
  return _pickRandom(rng, _clearDayTemplates(condition, tier, forecast));
}

List<String> _clearDayTemplates(
  WeatherCondition condition,
  TemperatureTier tier,
  Forecast forecast,
) {
  return switch ((condition, tier)) {
    (
      WeatherCondition.sunny || WeatherCondition.mostlySunny,
      TemperatureTier.scorcher,
    ) =>
      [
        'Main character weather. Sunscreen is non-negotiable babe.',
        'Hot and sunny — hydrate or regret it girl.',
        'Gorgeous but brutal. SPF 50 babe.',
      ],
    (
      WeatherCondition.sunny || WeatherCondition.mostlySunny,
      TemperatureTier.shortsWeather,
    ) =>
      [
        'Main character weather. Shorts and sunscreen energy.',
        'Perfect day to be outside. Don\'t waste it girl.',
        'Beautiful out there. Soak it up babe.',
      ],
    (
      WeatherCondition.sunny || WeatherCondition.mostlySunny,
      TemperatureTier.flannelWeather,
    ) =>
      [
        'Sunny but crisp. Flannel and coffee vibes today.',
        'Nice day, light layers. Get outside girl.',
        'Sun\'s out in hoodie weather. Enjoy it babe.',
      ],
    (
      WeatherCondition.sunny || WeatherCondition.mostlySunny,
      TemperatureTier.jacketWeather,
    ) =>
      [
        'Cold but sunny. Jacket and good vibes today.',
        'Bright and brisk. Cozy coat weather babe.',
        'Sunny doesn\'t mean warm today. Layer up girl.',
      ],
    (
      WeatherCondition.sunny || WeatherCondition.mostlySunny,
      TemperatureTier.freezing,
    ) =>
      [
        'Sunny but freezing. Don\'t let the sun fool you girl.',
        'Blue skies, bitter cold. Bundle up babe.',
        'Looks warm out the window. It\'s not babe.',
      ],
    (
      WeatherCondition.sunny || WeatherCondition.mostlySunny,
      TemperatureTier.singleDigits,
    ) =>
      [
        'Sunny but dangerously cold. Bundle up babe.',
        'Blue skies won\'t save you from frostbite girl.',
        'Bright and brutally cold. Stay warm girl.',
      ],
    (WeatherCondition.partlyCloudy, _) => [
      'Mix of sun and clouds. ${_tempVibe(tier)}',
      'Partly cloudy, partly vibes. ${_tempVibe(tier)}',
      'Some clouds rolling through. ${_tempVibe(tier)}',
    ],
    (WeatherCondition.overcast, _) => [
      'Gray skies all day. ${_tempVibe(tier)}',
      'Overcast energy today. ${_tempVibe(tier)}',
      'Cloudy and moody. ${_tempVibe(tier)}',
    ],
    (WeatherCondition.foggy, _) => [
      'Foggy and mysterious. Drive carefully. ${_tempVibe(tier)}',
      'Low visibility vibes. ${_tempVibe(tier)}',
      'Oh she\'s foggy foggy. ${_tempVibe(tier)}',
    ],
    (WeatherCondition.snow || WeatherCondition.blizzard, _) => [
      'Snow day energy. ${_tempVibe(tier)}',
      'It\'s snowinggg. ${_tempVibe(tier)}',
      'Winter wonderland mode activated. ${_tempVibe(tier)}',
    ],
    (WeatherCondition.thunderstorm, _) => [
      'Thunderstorms in the area. Stay inside if you can girl.',
      'Storm energy today. Not the fun kind. Stay safe babe.',
      'Lightning and drama. Stay safe out there girl.',
    ],
    _ => [
      '${_conditionPhrase(condition)}. ${_tempVibe(tier)}',
      '${_tempVibe(tier)} ${_conditionPhrase(condition).toLowerCase()} today.',
    ],
  };
}

// ---------------------------------------------------------------------------
// Night summaries
// ---------------------------------------------------------------------------

String _buildNightSummary({
  required Random rng,
  required WeatherCondition condition,
  required TemperatureTier tier,
  required bool isRaining,
  required String? clearTime,
  required String? precipLabel,
  required String? moonPhase,
  required int? moonIllum,
  required String? planetsStr,
  required AstroEvent? astroEvent,
  required Forecast forecast,
}) {
  // Precipitating at night
  if (isRaining) {
    final tempVibe = _nightTempVibe(tier);
    if (clearTime != null) {
      return _pickRandom(rng, [
        '${_precipName(condition)} til $clearTime. $tempVibe',
        'Wet night ahead til $clearTime. $tempVibe',
      ]);
    }
    return _pickRandom(rng, [
      'Rainy night ahead. $tempVibe',
      '${_precipName(condition)} all evening. $tempVibe',
    ]);
  }

  // Meteor shower peak — highest priority celestial
  if (astroEvent != null && astroEvent.label.contains('peak tonight')) {
    final showerName = astroEvent.label
        .replaceFirst('\u2604 ', '')
        .replaceFirst(' peak tonight!', '');
    final isClear =
        condition == WeatherCondition.sunny ||
        condition == WeatherCondition.mostlySunny;
    if (isClear) {
      return _pickRandom(rng, [
        '$showerName peak tonight — look up! Clear skies, perfect conditions.',
        if (moonIllum != null)
          'Perfect night for the $showerName. Clear skies and $moonIllum% moon.'
        else
          'Perfect night for the $showerName. Clear skies out there.',
      ]);
    }
    return _pickRandom(rng, [
      '$showerName peak tonight, but clouds might get in the way.',
      '$showerName active tonight. Clouds may limit visibility.',
    ]);
  }

  // Clear night — celestial focus
  final isClear =
      condition == WeatherCondition.sunny ||
      condition == WeatherCondition.mostlySunny ||
      condition == WeatherCondition.partlyCloudy;

  if (isClear) {
    final tempVibe = _nightTempVibe(tier);

    // Build celestial details
    final celestialParts = <String>[];
    if (planetsStr != null) {
      celestialParts.add('$planetsStr visible tonight');
    }
    if (moonIllum != null && moonPhase != null && moonIllum > 5) {
      celestialParts.add('$moonPhase $moonIllum%');
    }

    if (celestialParts.isNotEmpty) {
      final celestial = celestialParts.join('. ');
      return _pickRandom(rng, [
        'Clear and ${_nightTempWord(tier)}. $celestial.',
        '$tempVibe $celestial.',
      ]);
    }

    // Clear night, no celestial highlights
    return _pickRandom(rng, [
      'Clear and ${_nightTempWord(tier)}. $tempVibe',
      'Beautiful night. $tempVibe',
      'Stars are out tonight. $tempVibe',
    ]);
  }

  // Cloudy/foggy night
  return _pickRandom(rng, [
    '${_conditionPhrase(condition)} tonight. ${_nightTempVibe(tier)}',
    '${_nightTempVibe(tier)} ${_conditionPhrase(condition).toLowerCase()} tonight.',
  ]);
}

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

String _tempVibe(TemperatureTier tier) => switch (tier) {
  TemperatureTier.singleDigits => 'Dangerously cold out there girl.',
  TemperatureTier.freezing => 'Bundle up babe, it\'s freezing.',
  TemperatureTier.jacketWeather => 'Jacket vibes all day.',
  TemperatureTier.flannelWeather => 'Light layers kind of day.',
  TemperatureTier.shortsWeather => 'Shorts weather, let\'s go.',
  TemperatureTier.scorcher => 'Hot hot hot. Hydrate.',
};

String _nightTempVibe(TemperatureTier tier) => switch (tier) {
  TemperatureTier.singleDigits => 'Dangerously cold tonight.',
  TemperatureTier.freezing => 'Bitter cold tonight.',
  TemperatureTier.jacketWeather => 'Chilly night ahead girl.',
  TemperatureTier.flannelWeather => 'Cool and comfortable.',
  TemperatureTier.shortsWeather => 'Warm evening ahead babe.',
  TemperatureTier.scorcher => 'Still hot out there tonight.',
};

String _nightTempWord(TemperatureTier tier) => switch (tier) {
  TemperatureTier.singleDigits => 'brutal',
  TemperatureTier.freezing => 'crispy',
  TemperatureTier.jacketWeather => 'chilly',
  TemperatureTier.flannelWeather => 'cool',
  TemperatureTier.shortsWeather => 'mild',
  TemperatureTier.scorcher => 'warm',
};

String _precipName(WeatherCondition condition) => switch (condition) {
  WeatherCondition.drizzle => 'Drizzle',
  WeatherCondition.rain => 'Rain',
  WeatherCondition.heavyRain => 'Heavy rain',
  WeatherCondition.freezingRain => 'Freezing rain',
  WeatherCondition.thunderstorm => 'Storms',
  WeatherCondition.hail => 'Hail',
  WeatherCondition.snow => 'Snow',
  WeatherCondition.blizzard => 'Blizzard',
  _ => 'Rain',
};

String _conditionPhrase(WeatherCondition condition) => switch (condition) {
  WeatherCondition.sunny => 'Clear skies',
  WeatherCondition.mostlySunny => 'Mostly clear',
  WeatherCondition.partlyCloudy => 'Partly cloudy',
  WeatherCondition.overcast => 'Overcast',
  WeatherCondition.foggy => 'Foggy',
  WeatherCondition.drizzle => 'Light drizzle',
  WeatherCondition.rain => 'Rainy',
  WeatherCondition.heavyRain => 'Heavy rain',
  WeatherCondition.freezingRain => 'Freezing rain',
  WeatherCondition.snow => 'Snowy',
  WeatherCondition.blizzard => 'Blizzard conditions',
  WeatherCondition.thunderstorm => 'Thunderstorms',
  WeatherCondition.hail => 'Hail',
  _ => 'Mixed conditions',
};

/// Simplified precip info for summary context.
String? _computeWidgetPrecipInfo(Forecast forecast) {
  final locationNow = forecast.locationNow;
  final isRaining = precipConditions.contains(forecast.current.condition);

  if (forecast.minutely15.isNotEmpty) {
    final precipForecast = analyzePrecipitation(
      minutely15: forecast.minutely15,
      locationNow: locationNow,
      isCurrentlyRaining: isRaining,
    );
    final label = formatPrecipLabel(precipForecast);
    if (label != null) return label;
  }
  return null;
}
