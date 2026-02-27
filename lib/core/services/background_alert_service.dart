import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'dart:ui';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:home_widget/home_widget.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:workmanager/workmanager.dart';

import '../../features/weather/data/models/forecast_response_model.dart';
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
          initialDelay: const Duration(minutes: 15),
          constraints: Constraints(networkType: NetworkType.connected),
          existingWorkPolicy: ExistingWorkPolicy.replace,
        );
      }
    }
    return true;
  });
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
    } catch (_) {
      // Skip location on error, try next
    }
  }

  if (mostSevereNew != null) {
    final alertId = mostSevereNew['id'] as String? ?? '';
    final event = mostSevereNew['event'] as String? ?? 'Weather Alert';
    final headline = mostSevereNew['headline'] as String? ?? '';

    final localNotifications = FlutterLocalNotificationsPlugin();
    await localNotifications.initialize(
      const InitializationSettings(
        android: AndroidInitializationSettings('@mipmap/ic_launcher'),
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
          icon: '@mipmap/ic_launcher',
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

    // Read existing widget data to get location
    final existingJson =
        await HomeWidget.getWidgetData<String>(_widgetDataKey);
    if (existingJson == null) return;

    final existing = jsonDecode(existingJson) as Map<String, dynamic>;
    final lat = existing['latitude'] as double?;
    final lon = existing['longitude'] as double?;
    final cityName = existing['cityName'] as String?;
    if (lat == null || lon == null || cityName == null) return;

    // Read explicit language preference
    final prefs = await SharedPreferences.getInstance();
    final explicit = prefs.getBool('explicit_language') ?? true;

    // Fetch fresh weather data
    final dio = Dio();
    final response = await dio.get(
      ApiEndpoints.forecast(latitude: lat, longitude: lon),
      options: Options(
        receiveTimeout: const Duration(seconds: 15),
        sendTimeout: const Duration(seconds: 15),
      ),
    );
    dio.close();

    final forecast =
        ForecastResponseModel.fromJson(response.data as Map<String, dynamic>)
            .toEntity();

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
      'hourly': forecast.hourly.take(6).map((h) => {
            'time': h.time.toIso8601String(),
            'temperature': h.temperature.round(),
            'weatherCode': h.weatherCode,
          }).toList(),
      'sunrise': today.sunrise.toIso8601String(),
      'sunset': today.sunset.toIso8601String(),
      'uvIndexMax': today.uvIndexMax.round(),
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
          initialDelay: const Duration(minutes: 15),
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
