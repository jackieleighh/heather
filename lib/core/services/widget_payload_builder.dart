import 'dart:convert';

import '../../features/weather/domain/entities/forecast.dart';
import '../../features/weather/domain/entities/minutely_weather.dart';
import '../../features/weather/domain/entities/temperature_tier.dart';
import '../constants/background_gradients.dart';
import '../utils/geo_utils.dart';

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
