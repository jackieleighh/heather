import 'dart:async';
import 'dart:convert';
import 'dart:ui';

import 'package:home_widget/home_widget.dart';

import '../../features/weather/domain/entities/daily_weather.dart';
import '../../features/weather/domain/entities/forecast.dart';
import '../../features/weather/domain/entities/location_info.dart';
import '../../features/weather/domain/entities/temperature_tier.dart';
import '../constants/background_gradients.dart';
import '../constants/persona.dart';

const _appGroupId = 'group.com.totms.heather';
const _iOSWidgetName = 'HeatherWeatherWidget';
const _androidWidgetName = 'HeatherWidgetReceiver';
const _dataKey = 'widget_data';

class WidgetService {
  WidgetService._();

  /// Broadcasts when the app is opened via a widget tap.
  static final widgetTapped = StreamController<void>.broadcast();

  static Future<void> init() async {
    await HomeWidget.setAppGroupId(_appGroupId);

    // Handle cold start from widget tap
    final initialUri = await HomeWidget.initiallyLaunchedFromHomeWidget();
    if (initialUri != null) {
      widgetTapped.add(null);
    }

    // Handle warm start (app resumed from background via widget tap)
    HomeWidget.widgetClicked.listen((_) {
      widgetTapped.add(null);
    });
  }

  static Future<void> updateWidget({
    required Forecast forecast,
    required LocationInfo location,
    required String quip,
    required bool explicit,
  }) async {
    final current = forecast.current;
    final today = forecast.daily.first;
    final isDay = forecast.isCurrentlyDay;
    final tier = TemperatureTier.fromTemperature(current.temperature);
    final gradientColors = BackgroundGradients.forCondition(
      current.condition,
      tier,
      isDay: isDay,
    );

    final payload = jsonEncode({
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
      'cityName': location.cityName,
      'latitude': location.latitude,
      'longitude': location.longitude,
      'lastUpdated': DateTime.now().toIso8601String(),
      'gradientColors': gradientColors.map(_colorToHex).toList(),
      'hourly': forecast.hourly.take(24).map((h) {
        // h.time was parsed as device-local but represents location-local time.
        // Compute correct UTC epoch by adjusting for the timezone mismatch.
        final tzCorrection =
            h.time.timeZoneOffset.inSeconds - forecast.utcOffsetSeconds;
        return {
          'time': h.time.toIso8601String(),
          'epoch': (h.time.millisecondsSinceEpoch ~/ 1000) + tzCorrection,
          'temperature': h.temperature.round(),
          'weatherCode': h.weatherCode,
          'isDay': _isHourDay(h.time, forecast.daily),
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
    });

    await HomeWidget.saveWidgetData<String>(_dataKey, payload);
    await _writeQuipMap(explicit, isDay: isDay);
    await HomeWidget.updateWidget(
      iOSName: _iOSWidgetName,
      androidName: _androidWidgetName,
    );
  }

  static Future<void> _writeQuipMap(bool explicit, {required bool isDay}) async {
    final map = heatherQuipMap(altTone: explicit, isDay: isDay);
    final json = map.map(
      (condition, tiers) => MapEntry(
        condition.name,
        tiers.map((tier, quips) => MapEntry(tier.name, quips)),
      ),
    );
    final payload = jsonEncode(json);
    await HomeWidget.saveWidgetData<String>('widget_quips', payload);
  }

  static bool _isHourDay(DateTime time, List<DailyWeather> daily) {
    // Find the matching day's sunrise/sunset
    DateTime? sunrise;
    DateTime? sunset;
    for (final day in daily) {
      if (day.date.year == time.year &&
          day.date.month == time.month &&
          day.date.day == time.day) {
        sunrise = day.sunrise;
        sunset = day.sunset;
        break;
      }
    }
    if (sunrise == null || sunset == null) return true;

    // Transition-hour logic: if sunrise/sunset falls within this hour,
    // use day icon only if the hour has >30 min of daylight.
    if (time.hour == sunrise.hour) {
      return (60 - sunrise.minute) > 30;
    }
    if (time.hour == sunset.hour) {
      return sunset.minute > 30;
    }

    final minutes = time.hour * 60 + time.minute;
    final sunriseMin = sunrise.hour * 60 + sunrise.minute;
    final sunsetMin = sunset.hour * 60 + sunset.minute;
    return minutes >= sunriseMin && minutes < sunsetMin;
  }

  static String _colorToHex(Color color) {
    return '#${color.toARGB32().toRadixString(16).padLeft(8, '0').toUpperCase()}';
  }
}
