import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'dart:ui';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:geocoding/geocoding.dart' as geocoding;
import 'package:geolocator/geolocator.dart';
import 'package:home_widget/home_widget.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:workmanager/workmanager.dart';

import '../../features/weather/data/models/forecast_response_model.dart';
import '../../features/weather/domain/entities/daily_weather.dart';
import '../../features/weather/domain/entities/temperature_tier.dart';
import '../constants/api_endpoints.dart';
import '../constants/background_gradients.dart';
import '../constants/persona.dart';

const _taskName = 'com.totms.heather.alertCheck';
const _locationsKey = 'bg_alert_locations';
const _sentIdsKey = 'sent_alert_ids';

const _alertChannelId = 'heather_weather_alerts';
const _alertChannelName = 'Severe Weather Alerts';
const _alertChannelDescription =
    'Critical weather alerts like tornado warnings and severe thunderstorms';

@pragma('vm:entry-point')
void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    if (task == _taskName || task == Workmanager.iOSBackgroundTask) {
      await _checkAlerts();
      await _refreshWidgetData();
      // iOS doesn't support periodic tasks — re-schedule a one-off
      if (!Platform.isAndroid) {
        await Workmanager().registerOneOffTask(
          _taskName,
          _taskName,
          initialDelay: const Duration(minutes: 5),
          constraints: Constraints(networkType: NetworkType.connected),
          existingWorkPolicy: ExistingWorkPolicy.replace,
        );
      }
    }
    return true;
  });
}

/// Rough bounding box for US territories (CONUS, Alaska, Hawaii, PR/USVI, Guam).
bool _isInUSBounds(double lat, double lon) {
  // Continental US
  if (lat >= 24.0 && lat <= 50.0 && lon >= -125.0 && lon <= -66.0) return true;
  // Alaska
  if (lat >= 51.0 && lat <= 72.0 && lon >= -180.0 && lon <= -129.0) return true;
  // Hawaii
  if (lat >= 18.5 && lat <= 22.5 && lon >= -161.0 && lon <= -154.0) return true;
  // Puerto Rico / US Virgin Islands
  if (lat >= 17.5 && lat <= 18.6 && lon >= -67.5 && lon <= -64.5) return true;
  // Guam / Northern Mariana Islands
  if (lat >= 13.0 && lat <= 21.0 && lon >= 144.0 && lon <= 146.5) return true;
  return false;
}

Future<void> _checkAlerts() async {
  final prefs = await SharedPreferences.getInstance();

  final locationsJson = prefs.getString(_locationsKey);
  if (locationsJson == null) return;

  final locations =
      (jsonDecode(locationsJson) as List<dynamic>).cast<Map<String, dynamic>>();
  if (locations.isEmpty) return;

  // Load previously sent alert IDs with timestamps
  final sentIdsJson = prefs.getString(_sentIdsKey);
  final sentIds = <String, int>{};
  if (sentIdsJson != null) {
    final decoded = jsonDecode(sentIdsJson) as Map<String, dynamic>;
    for (final entry in decoded.entries) {
      sentIds[entry.key] = entry.value as int;
    }
  }

  // Prune IDs older than 48 hours
  final cutoff =
      DateTime.now().subtract(const Duration(hours: 48)).millisecondsSinceEpoch;
  sentIds.removeWhere((_, timestamp) => timestamp < cutoff);

  final dio = Dio();
  Map<String, dynamic>? mostSevereNew;
  int bestSortOrder = 999;

  for (final loc in locations) {
    final lat = loc['latitude'] as double;
    final lon = loc['longitude'] as double;

    // NWS alerts only cover US territories — skip non-US coordinates
    if (!_isInUSBounds(lat, lon)) continue;

    try {
      final response = await dio.get(
        ApiEndpoints.nwsAlerts(latitude: lat, longitude: lon),
        options: Options(
          headers: {
            'User-Agent': '(Heather Weather App)',
            'Accept': 'application/geo+json',
          },
        ),
      );

      final data = response.data as Map<String, dynamic>;
      final features = data['features'] as List<dynamic>? ?? [];
      final now = DateTime.now();

      for (final feature in features) {
        final props = feature['properties'] as Map<String, dynamic>;
        final id = props['id'] as String? ?? '';
        final expires = DateTime.tryParse(props['expires'] as String? ?? '');

        if (expires != null && expires.isBefore(now)) continue;
        if (sentIds.containsKey(id)) continue;

        final severityStr = (props['severity'] as String? ?? '').toLowerCase();
        final sortOrder = switch (severityStr) {
          'extreme' => 0,
          'severe' => 1,
          'moderate' => 2,
          'minor' => 3,
          _ => 4,
        };

        if (sortOrder < bestSortOrder) {
          bestSortOrder = sortOrder;
          mostSevereNew = props;
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('Alert check failed for ($lat, $lon): $e');
      }
    }
  }

  if (mostSevereNew != null) {
    final alertId = mostSevereNew['id'] as String? ?? '';
    final event = mostSevereNew['event'] as String? ?? 'Weather Alert';
    final headline = mostSevereNew['headline'] as String? ?? '';

    final localNotifications = FlutterLocalNotificationsPlugin();
    await localNotifications.initialize(
      const InitializationSettings(
        android: AndroidInitializationSettings('@mipmap/launcher_icon'),
        iOS: DarwinInitializationSettings(),
      ),
    );

    await localNotifications.show(
      alertId.hashCode,
      event,
      headline,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          _alertChannelId,
          _alertChannelName,
          channelDescription: _alertChannelDescription,
          importance: Importance.high,
          priority: Priority.high,
          icon: '@mipmap/launcher_icon',
        ),
        iOS: DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      ),
    );

    sentIds[alertId] = DateTime.now().millisecondsSinceEpoch;
    await prefs.setString(_sentIdsKey, jsonEncode(sentIds));
  }

  dio.close();
}

const _appGroupId = 'group.com.totms.heather';
const _iOSWidgetName = 'HeatherWeatherWidget';
const _androidWidgetName = 'HeatherWidgetReceiver';
const _widgetDataKey = 'widget_data';

Future<void> _refreshWidgetData() async {
  try {
    await HomeWidget.setAppGroupId(_appGroupId);

    // Read existing widget data to get stored location as fallback
    final existingJson =
        await HomeWidget.getWidgetData<String>(_widgetDataKey);
    if (existingJson == null) return;

    final existing = jsonDecode(existingJson) as Map<String, dynamic>;
    final storedLat = existing['latitude'] as double?;
    final storedLon = existing['longitude'] as double?;
    final storedCity = existing['cityName'] as String?;
    if (storedLat == null || storedLon == null || storedCity == null) return;

    var lat = storedLat;
    var lon = storedLon;
    var cityName = storedCity;

    // Try to refresh location from system cache (no GPS activation)
    try {
      final position = await Geolocator.getLastKnownPosition();
      if (position != null) {
        lat = position.latitude;
        lon = position.longitude;
        try {
          final placemarks = await geocoding.placemarkFromCoordinates(lat, lon);
          if (placemarks.isNotEmpty) {
            final place = placemarks.first;
            cityName = place.locality?.isNotEmpty == true
                ? place.locality!
                : place.subAdministrativeArea ??
                    place.administrativeArea ??
                    cityName;
          }
        } catch (_) {
          // Keep existing cityName if reverse geocoding fails
        }
      }
    } catch (_) {
      // Keep stored location on any failure (permission denied, etc.)
    }

    // Read explicit language preference
    final prefs = await SharedPreferences.getInstance();
    final explicit = prefs.getBool('explicit_language') ?? true;

    // Try foreground cache first (shared via SharedPreferences)
    final cacheKey = 'cached_forecast_${lat}_$lon';
    final cacheTsKey = 'cached_forecast_ts_${lat}_$lon';
    final cachedJson = prefs.getString(cacheKey);
    final cachedTs = prefs.getInt(cacheTsKey);

    ForecastResponseModel forecastModel;
    if (cachedJson != null &&
        cachedTs != null &&
        DateTime.now().millisecondsSinceEpoch - cachedTs <
            const Duration(minutes: 14).inMilliseconds) {
      // Cache is <14 min old — reuse foreground data
      forecastModel = ForecastResponseModel.fromJson(
          jsonDecode(cachedJson) as Map<String, dynamic>);
    } else {
      // Cache is stale or missing — fetch from API
      final dio = Dio();
      final response = await dio.get(
        ApiEndpoints.forecast(latitude: lat, longitude: lon),
        options: Options(
          receiveTimeout: const Duration(seconds: 15),
          sendTimeout: const Duration(seconds: 15),
        ),
      );
      dio.close();
      forecastModel =
          ForecastResponseModel.fromJson(response.data as Map<String, dynamic>);

      // Write back to shared cache so foreground benefits too
      await prefs.setString(cacheKey, jsonEncode(forecastModel.toJson()));
      await prefs.setInt(
          cacheTsKey, DateTime.now().millisecondsSinceEpoch);
    }

    final forecast = forecastModel.toEntity();

    final current = forecast.current;
    final today = forecast.daily.first;
    final isDay = forecast.isCurrentlyDay;
    final tier = TemperatureTier.fromTemperature(current.temperature);
    final gradientColors = BackgroundGradients.forCondition(
      current.condition,
      tier,
      isDay: isDay,
    );

    // Pick a random quip
    final quipMap = heatherQuipMap(altTone: explicit, isDay: isDay);
    final quips = quipMap[current.condition]?[tier] ?? ['Stay cozy.'];
    final quip = quips[Random().nextInt(quips.length)];

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
      'cityName': cityName,
      'latitude': lat,
      'longitude': lon,
      'lastUpdated': DateTime.now().toIso8601String(),
      'gradientColors':
          gradientColors.map(_colorToHex).toList(),
      'hourly': forecast.hourly.take(24).map((h) {
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

    await HomeWidget.saveWidgetData<String>(_widgetDataKey, payload);

    // Write quip map for native widget random selection
    final map = heatherQuipMap(altTone: explicit, isDay: isDay);
    final quipJson = map.map(
      (condition, tiers) => MapEntry(
        condition.name,
        tiers.map((tier, quips) => MapEntry(tier.name, quips)),
      ),
    );
    await HomeWidget.saveWidgetData<String>(
        'widget_quips', jsonEncode(quipJson));

    await HomeWidget.updateWidget(
      iOSName: _iOSWidgetName,
      androidName: _androidWidgetName,
    );
  } catch (_) {
    // Silently fail — widget keeps stale data
  }
}

bool _isHourDay(DateTime time, List<DailyWeather> daily) {
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

String _colorToHex(Color color) {
  return '#${color.toARGB32().toRadixString(16).padLeft(8, '0').toUpperCase()}';
}

class BackgroundAlertService {
  BackgroundAlertService._();

  static Future<void> init() async {
    try {
      await Workmanager().initialize(callbackDispatcher);
    } catch (e) {
      if (kDebugMode) {
        print('WorkManager init failed: $e');
      }
    }
  }

  static Future<void> registerPeriodicCheck() async {
    try {
      if (Platform.isAndroid) {
        await Workmanager().registerPeriodicTask(
          _taskName,
          _taskName,
          frequency: const Duration(minutes: 15),
          constraints: Constraints(networkType: NetworkType.connected),
          existingWorkPolicy: ExistingPeriodicWorkPolicy.replace,
        );
      } else {
        await Workmanager().registerOneOffTask(
          _taskName,
          _taskName,
          initialDelay: const Duration(minutes: 5),
          constraints: Constraints(networkType: NetworkType.connected),
          existingWorkPolicy: ExistingWorkPolicy.replace,
        );
      }
    } catch (e) {
      if (kDebugMode) {
        print('WorkManager task registration failed: $e');
      }
    }
  }

  static Future<void> cancelPeriodicCheck() async {
    try {
      await Workmanager().cancelByUniqueName(_taskName);
    } catch (e) {
      if (kDebugMode) {
        print('WorkManager task cancellation failed: $e');
      }
    }
  }

  static Future<void> updateLocations(
    List<Map<String, dynamic>> locations,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_locationsKey, jsonEncode(locations));
  }
}
