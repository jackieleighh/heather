import 'dart:convert';

import '../../features/weather/domain/entities/forecast.dart';
import '../../features/weather/domain/entities/hourly_weather.dart';
import '../../features/weather/domain/entities/minutely_weather.dart';
import '../../features/weather/domain/entities/temperature_tier.dart';
import '../constants/background_gradients.dart';
import '../utils/geo_utils.dart';
import 'widget_summary_builder.dart';

/// Builds the JSON payload shared between foreground [WidgetService] and
/// background [_refreshWidgetData].
///
/// [alertLabel] is pre-computed by the caller because foreground and
/// background derive it differently (WeatherAlert list vs raw NWS API).
String buildWidgetPayload({
  required Forecast forecast,
  required String cityName,
  required double latitude,
  required double longitude,
  required String quip,
  String? alertLabel,
  String? alertSeverity,
  List<String> visiblePlanets = const [],
  String? moonPhase,
  int? moonIllumination,
}) {
  final current = forecast.current;
  final today = forecast.daily.first;
  final isDay = forecast.isCurrentlyDay;
  final tier = TemperatureTier.fromTemperature(current.temperature);
  final gradientColors = BackgroundGradients.forCondition(
    current.condition,
    tier,
    isDay: isDay,
  );

  final precipLabel = _computePrecipLabel(forecast);

  // Build timeline segments (12 hours)
  final timelineSegments = _buildTimelineSegments(forecast);
  final locationNow = forecast.locationNow;
  final hasPrecipInTimeline = forecast.hourly
      .where((h) =>
          !h.time.isBefore(locationNow) &&
          h.time.isBefore(locationNow.add(const Duration(hours: 6))))
      .any((h) => precipConditions.contains(h.condition) && h.precipitationProbability >= 60);

  // Build smart summary
  final widgetSummary = buildWidgetSummary(
    forecast: forecast,
    alertLabel: alertLabel,
    visiblePlanets: visiblePlanets,
    moonPhase: moonPhase,
    moonIllumination: moonIllumination,
  );

  return jsonEncode({
    'temperature': current.temperature.round(),
    'feelsLike': current.feelsLike.round(),
    'high': today.temperatureMax.round(),
    'low': today.temperatureMin.round(),
    'conditionName': current.condition.name,
    'description': current.description,
    'isDay': isDay,
    'humidity': current.humidity,
    'windSpeed': current.windSpeed.round(),
    'uvIndex': current.uvIndex.round(),
    'quip': quip,
    'persona': 'heather',
    'cityName': cityName,
    'latitude': latitude,
    'longitude': longitude,
    'lastUpdated': DateTime.now().toIso8601String(),
    'gradientColors': gradientColors.map(colorToHex).toList(),
    'hourly': forecast.hourly.take(24).map((h) {
      final tzCorrection =
          h.time.timeZoneOffset.inSeconds - forecast.utcOffsetSeconds;
      return {
        'time': h.time.toIso8601String(),
        'epoch': (h.time.millisecondsSinceEpoch ~/ 1000) + tzCorrection,
        'temperature': h.temperature.round(),
        'weatherCode': h.weatherCode,
        'isDay': isHourDay(h.time, forecast.daily),
      };
    }).toList(),
    'sunrise': today.sunrise.toIso8601String(),
    'sunset': today.sunset.toIso8601String(),
    'sunriseEpoch': (today.sunrise.millisecondsSinceEpoch ~/ 1000) +
        today.sunrise.timeZoneOffset.inSeconds -
        forecast.utcOffsetSeconds,
    'sunsetEpoch': (today.sunset.millisecondsSinceEpoch ~/ 1000) +
        today.sunset.timeZoneOffset.inSeconds -
        forecast.utcOffsetSeconds,
    'uvIndexMax': today.uvIndexMax.round(),
    'utcOffsetSeconds': forecast.utcOffsetSeconds,
    if (alertLabel != null) 'alertLabel': alertLabel,
    if (alertSeverity != null) 'alertSeverity': alertSeverity,
    if (precipLabel != null) 'precipLabel': precipLabel,
    if (moonPhase != null) 'moonPhase': moonPhase,
    if (moonIllumination != null) 'moonIllumination': moonIllumination,
    'widgetSummary': widgetSummary,
    'summaryIsDay': isDay,
    'timelineSegments': timelineSegments,
    'hasPrecipInTimeline': hasPrecipInTimeline,
  });
}

String? _computePrecipLabel(Forecast forecast) {
  final locationNow = forecast.locationNow;
  final isRaining = precipConditions.contains(forecast.current.condition);

  final currentSlot = forecast.hourly
      .where((h) => !h.time.isAfter(locationNow))
      .lastOrNull;
  final probRaining = !isRaining &&
      currentSlot != null &&
      currentSlot.precipitationProbability >= 90;

  if (forecast.minutely15.isNotEmpty) {
    final precipForecast = analyzePrecipitation(
      minutely15: forecast.minutely15,
      locationNow: locationNow,
      isCurrentlyRaining: isRaining || probRaining,
    );
    final label = formatPrecipLabel(precipForecast);
    if (label != null) return label;
  }

  final hourlyLabel = hourlyPrecipLabel(
    hourly: forecast.hourly,
    currentCondition: forecast.current.condition,
    locationNow: locationNow,
    daily: forecast.daily,
  );
  if (hourlyLabel != null) return hourlyLabel;

  if (!forecast.current.isDay) {
    return tomorrowPrecipLabel(
      daily: forecast.daily,
      locationNow: locationNow,
    );
  }
  return null;
}

/// Builds timeline data points covering the next 12 hours.
///
/// Uses minutely15 data for the first ~4 hours (at 15-min intervals),
/// then fills remaining time from hourly data.
List<Map<String, dynamic>> _buildTimelineSegments(Forecast forecast) {
  final locationNow = forecast.locationNow;
  final endTime = locationNow.add(const Duration(hours: 12));
  final segments = <Map<String, dynamic>>[];

  // Track which time range minutely data covers
  DateTime? minutelyCoveredUntil;

  // First: use minutely15 data
  for (final m in forecast.minutely15) {
    if (m.time.isBefore(locationNow)) continue;
    if (!m.time.isBefore(endTime)) break;

    final minuteOffset = m.time.difference(locationNow).inMinutes;
    // Find the closest hourly entry for temperature
    final temp = _closestHourlyTemp(forecast.hourly, m.time) ??
        forecast.current.temperature.round();
    final prob = _closestHourlyPrecipProb(forecast.hourly, m.time);

    segments.add({
      'minuteOffset': minuteOffset,
      'precipitation': m.precipitation,
      'precipProbability': prob,
      'temperature': temp,
    });
    minutelyCoveredUntil = m.time;
  }

  // Then: fill remaining time from hourly data
  for (final h in forecast.hourly) {
    if (h.time.isBefore(locationNow)) continue;
    if (!h.time.isBefore(endTime)) break;
    // Skip if already covered by minutely data
    if (minutelyCoveredUntil != null && !h.time.isAfter(minutelyCoveredUntil)) {
      continue;
    }

    final minuteOffset = h.time.difference(locationNow).inMinutes;
    final precip = precipConditions.contains(h.condition)
        ? (h.precipitationProbability / 100.0)
        : 0.0;

    segments.add({
      'minuteOffset': minuteOffset,
      'precipitation': precip,
      'precipProbability': h.precipitationProbability,
      'temperature': h.temperature.round(),
    });
  }

  // Ensure we have a "now" segment at offset 0
  if (segments.isEmpty || (segments.first['minuteOffset'] as int) > 0) {
    segments.insert(0, {
      'minuteOffset': 0,
      'precipitation': forecast.minutely15.isNotEmpty
          ? forecast.minutely15
              .where((m) => !m.time.isAfter(locationNow))
              .lastOrNull
              ?.precipitation ?? 0.0
          : 0.0,
      'precipProbability':
          _closestHourlyPrecipProb(forecast.hourly, locationNow),
      'temperature': forecast.current.temperature.round(),
    });
  }

  return segments;
}

int _closestHourlyPrecipProb(List<HourlyWeather> hourly, DateTime target) {
  int? closest;
  var bestDiff = 999999;
  for (final h in hourly) {
    final diff = h.time.difference(target).inMinutes.abs();
    if (diff < bestDiff) {
      bestDiff = diff;
      closest = h.precipitationProbability;
    }
  }
  return closest ?? 0;
}

int? _closestHourlyTemp(List<HourlyWeather> hourly, DateTime target) {
  int? closest;
  var bestDiff = 999999;
  for (final h in hourly) {
    final diff = h.time.difference(target).inMinutes.abs();
    if (diff < bestDiff) {
      bestDiff = diff;
      closest = h.temperature.round();
    }
  }
  return closest;
}
